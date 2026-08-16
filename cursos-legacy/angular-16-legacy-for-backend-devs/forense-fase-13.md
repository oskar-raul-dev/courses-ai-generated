# 🕵️ Forense Fase 13 — "En UAT funciona y en PROD no"

> Pieza forense de la **Fase 13 — Build, despliegue y cierre** · Recorrido: ~45 min
> Herramientas: `docker inspect` · `docker exec` · `curl -I` · source maps
> Síntoma que cubre: el ticket que ordena el final del curso, y su hermano — "desplegamos el fix y la gente sigue viendo el error".

Este ticket casi nunca es un bug de código. Es, **por orden de frecuencia**: configuración distinta, caché, versiones distintas creyendo ser la misma, y sólo al final, código. Ir al código primero es lo que convierte una hora en una tarde, y por eso la ruta descarta una capa entera en cada paso.

La fase resume los cuatro pasos. Aquí están los dos tickets literales y la salida de cada uno.

---

## 🎫 Ticket A — el ambiente

> *"En UAT entra bien y en producción la pantalla se queda en blanco. Es el mismo despliegue de esta mañana."*

**Reportado por:** el equipo de soporte · **Ambiente:** PROD · **Es el incidente 19**

## 🎫 Ticket B — el fix que no llegó

> *"Desplegamos el arreglo hace dos horas y la gente sigue viendo el error. A mí me funciona."*

**Reportado por:** tu líder técnico · **Ambiente:** PROD · **Es el incidente 18**

**"A mí me funciona"** es, en este ticket, un dato técnico y no una excusa: significa que quien lo dice tiene el navegador con *Disable cache* puesto desde hace meses.

---

## 🧭 La ruta

Cinco pasos, y **el código va el último a propósito**. Comparar dos digests o leer una cabecera con `curl` cuesta segundos y descarta el despliegue, la configuración del servidor y la caché; abrir el proyecto y buscar en qué se diferencian dos entornos cuesta una tarde. Si empiezas por el editor —que es lo que hace todo el mundo con este ticket— vas a encontrar el bug igual, pero tres horas después.

### Paso 1 — ¿Es de verdad la misma imagen?

Antes de mirar nada más. Diez segundos, y descarta la capa más grande:

```bash
docker inspect --format '{{.Image}}' certcore-prod certcore-uat
```

```
sha256:9f2c4b1e7a8d3c5f0e6b2a94d17c8e3f5a0b6d2c9e4f1a8b3d7c0e5f2a9b4c1d
sha256:9f2c4b1e7a8d3c5f0e6b2a94d17c8e3f5a0b6d2c9e4f1a8b3d7c0e5f2a9b4c1d
```

**Qué descarta.** Digests idénticos: **es el mismo artefacto**, así que ninguna diferencia de comportamiento puede venir del código. Pasa al 2.

Digests distintos: **no tienes un problema de configuración, tienes dos artefactos distintos**, y la pregunta cambia por completo — quién construyó cuál, desde qué commit, y por qué el pipeline produjo dos.

> ⚠️ **Ésta es la comprobación que la etiqueta `:latest` hace imposible**, y es la mitad de la razón por la que la convención del curso pide etiquetar la imagen con el nombre del tag de git que la produjo. Con `certcore:latest` en los dos ambientes, la pregunta *"¿qué código hay dentro de cada uno?"* no tiene respuesta. Con `certcore:fase-13` y `certcore:hotfix-2026-03-14`, se contesta leyendo. **A09** §2 lo desarrolla.

### Paso 2 — ¿Qué configuración tiene cada uno?

Los dos archivos, uno al lado del otro:

```bash
docker exec certcore-prod cat /usr/share/nginx/html/assets/config.json
docker exec certcore-uat  cat /usr/share/nginx/html/assets/config.json
```

```json
{"apiBaseUrl": "/api", "environmentName": "PROD"}
{"apiBaseUrl": "/api", "environmentName": "UAT"}
```

Y sin entrar al contenedor, que es lo que un equipo de plataforma sí te va a dejar hacer:

```bash
docker logs certcore-prod 2>&1 | grep certcore
# [certcore] configuración de arranque: PROD -> /api
```

**Qué descarta.** El `echo` del `entrypoint.sh` está en los logs exactamente por esto: contesta la pregunta sin `docker exec`, que en un cluster real puede estar prohibido.

Las tres salidas que resuelven el ticket A:

| Lo que ves | Qué pasó |
|---|---|
| El JSON con los valores esperados | la configuración está bien: pasa al 3 |
| El JSON con los valores de **otro** ambiente | la imagen se levantó con las variables equivocadas |
| **No existe el archivo** | el `entrypoint.sh` no corrió → pantalla en blanco garantizada |
| El archivo existe y está vacío o mal formado | corrió y falló a medias |

Los dos últimos son la causa clásica del ticket A, y su mecanismo merece nombrarse: `APP_INITIALIZER` **bloquea el arranque** de la aplicación hasta que resuelve. Si la petición a `assets/config.json` devuelve un `404` o un JSON inválido, la promesa se rechaza, Angular no arranca, y lo que ve el usuario es **una página en blanco sin ningún error visible** — porque el error ocurrió antes de que hubiera dónde pintarlo.

```bash
# Y la causa raíz más tonta de las tres, comprobable en un segundo:
docker exec certcore-prod ls -l /docker-entrypoint.d/
# -rw-r--r--  1 root root  412 40-certcore-config.sh    ← SIN el bit de ejecución
```

Sin `+x`, nginx **ignora el script en silencio**, arranca perfectamente, y sirve la aplicación sin `config.json`. No hay error en ningún log. Es la causa raíz del incidente 19 y es una línea del Dockerfile.

### Paso 3 — ¿Qué llega al navegador? No lo que crees: lo que llega

```bash
# Las cabeceras del index.html.
curl -I http://localhost:8080/
```

```
HTTP/1.1 200 OK
Server: nginx/1.25.3
Content-Type: text/html
Cache-Control: no-store          ← lo que TIENE que decir
```

```
Cache-Control: public, max-age=31536000    ← el incidente 18, completo
```

**Qué descarta.** Si el `index.html` se está cacheando, el ticket B está resuelto: despliegas el fix, el usuario recarga, y **sigue recibiendo el `index.html` de ayer** — que referencia los bundles de ayer, que siguen existiendo porque nadie borra nada. La aplicación vieja funciona perfectamente, y por eso nadie ve ningún error.

```bash
# Y el config.json, tal como lo ve un cliente cualquiera:
curl -s http://localhost:8080/assets/config.json
curl -I http://localhost:8080/assets/config.json | grep -i cache
```

> 🧭 **La regla que cabe en una frase y resuelve toda la política de caché de una SPA: lo que lleva hash en el nombre se cachea para siempre; lo que no lleva hash no se cachea nunca.** Los bundles (`main.8a1f2c.js`) llevan hash: un nombre distinto es un archivo distinto, así que se pueden cachear un año sin riesgo. El `index.html` y el `config.json` **no llevan hash** y cambian en cada despliegue. Equivocarse en el lado del `index.html` produce el bug más frustrante que existe: el que ya arreglaste.

**Y hazlo con `curl`, no con tu navegador.** Tu navegador lleva meses con *Disable cache* puesto y te va a mentir con la mejor intención. Ése es el mecanismo exacto del *"a mí me funciona"* del ticket B.

### Paso 4 — ¿Y la ruta profunda?

Un caso concreto del ticket A que merece su propia comprobación:

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8080/inspections/500
# 200 → try_files está puesto
# 404 → falta, y recargar cualquier ruta profunda da 404
```

nginx busca un **archivo** llamado `inspections/500`. No existe: esa ruta sólo vive dentro del router de Angular, en el navegador. `try_files $uri $uri/ /index.html;` es la línea que lo arregla, y el síntoma que produce su ausencia es desconcertante porque **navegar funciona y recargar no**.

**Qué descarta.** Un `404` localiza el bug en la configuración del servidor y descarta el código de la aplicación: no hay nada que buscar en el proyecto. Un `200` descarta el `try_files` y deja un solo sospechoso, que es el del **Paso 5** — y por eso el código va el último.

### Paso 5 — Y sólo ahora, el código

Si la imagen es la misma, la configuración es la esperada, las cabeceras están bien y las rutas profundas responden, **entonces sí es un bug de la aplicación**. Y lo que tienes es esto:

```
ERROR TypeError: Cannot read properties of null (reading 'validUntil')
    at t.<anonymous> (main.8a1f2c.js:1:48213)
    at Object.next (main.8a1f2c.js:1:12994)
```

Con `sourceMap.hidden: true` en la configuración de producción, el `.map` **se genera y no se sirve**: lo tienes tú, no el usuario. Dos formas de usarlo:

```
1. DevTools → Sources → clic derecho sobre el archivo → "Add source map…"
   y pega la ruta del .map que guardaste al construir.
2. O sirve el dist/ completo en local —con los .map al lado— y reproduce ahí.
```

```
// Y el mismo error, ya traducido:
ERROR TypeError: Cannot read properties of null (reading 'validUntil')
    at CertificateDetailComponent.buildView (certificate-detail.component.ts:74:31)
```

**Qué descarta.** Sin el `.map`, `main.8a1f2c.js:1:48213` es todo lo que vas a tener nunca. Con él, tienes archivo y línea. Es la diferencia entre una investigación de diez minutos y una que no se puede hacer, y es la razón por la que la Fase 13 los genera aunque no los sirva.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Comprobación |
|---|---|---|
| Digests distintos entre ambientes | dos artefactos, no un problema de config | `docker inspect --format '{{.Image}}'` |
| Pantalla en blanco, sin errores | `APP_INITIALIZER` rechazado | ¿existe `assets/config.json`? |
| `config.json` no existe | el `entrypoint.sh` no corrió | `ls -l /docker-entrypoint.d/` → falta `+x` |
| `config.json` con valores de otro ambiente | variables equivocadas al levantar | `docker logs \| grep certcore` |
| El fix desplegado no llega a los usuarios | `index.html` cacheado | `curl -I` → `Cache-Control` |
| "A mí me funciona" | *Disable cache* en el navegador de quien lo dice | usa `curl`, no el navegador |
| Navegar funciona, recargar da 404 | falta `try_files` | `curl` a una ruta profunda |
| Stack trace ilegible | sin source map cargado | `Add source map…` en Sources |
| El contenedor no arranca en el cluster | probablemente nginx como root | **A09** §8 |

---

## ⚰️ Los callejones

**"Es un bug de código, ya lo estoy mirando."** El callejón que define el ticket, y cuesta tardes. Los pasos 1 a 4 cuestan cinco minutos entre todos y descartan tres capas. Empezar por el paso 5 significa leer código buscando una diferencia que no está ahí.

**"Reconstruimos y volvemos a desplegar."** A veces "arregla" el ticket B —porque el `index.html` nuevo llega con otro momento de caché— y **no arregla nada**: la política de caché sigue mal y el mismo bug vuelve en el siguiente despliegue. Peor aún: enseña al equipo que redesplegar es un procedimiento de diagnóstico.

**"Es la CDN."** Puede ser, y se descarta en el mismo paso 3: si `curl` directo al origen ya devuelve el `Cache-Control` equivocado, la CDN está obedeciendo. Si el origen está bien y la CDN no, entonces sí es de ellos, y ya tienes la evidencia para el ticket.

**"El backend de PROD está devolviendo otra cosa."** Comprobable sin salir de la terminal, y conviene hacerlo antes de acusar a nadie: `curl` al endpoint desde dentro del contenedor de la aplicación, que es exactamente el camino que recorre el navegador a través del `proxy_pass`.

---

## 🧨 Deshacer

Si cambiaste el `nginx.conf` para reproducir el incidente 18 —quitando el `no-store` del `index.html`—, **devuélvelo y reconstruye la imagen**: una imagen con esa política mal puesta es exactamente el bug, y guardada en tu almacén local va a reaparecer en la Fase 14 sin que la relaciones.

```bash
docker rm -f certcore-prod certcore-uat
rm -rf dist/
```

Y si retiraste el `chmod +x` del Dockerfile para el paso 2, lo mismo: sin esa línea la Fase 14 despliega una aplicación sin configuración y el pod arranca perfectamente sirviendo una pantalla en blanco.

---

## 🧠 El patrón transferible

> **"Funciona en UAT y no en PROD" es una descripción de una diferencia, no de un bug.** El trabajo es encontrar cuál, y sólo hay cuatro candidatas: el artefacto, la configuración, la caché y el código. En ese orden, porque las tres primeras se descartan en cinco minutos y la cuarta cuesta una tarde.

Y el segundo, que es el que se lleva al trabajo real: **si no puedes contestar "¿qué código hay dentro de esta imagen?", no puedes investigar nada.** Etiquetar la imagen con el tag de git que la produjo cuesta un guion en la línea de `docker build` y es la mitad barata de cualquier diagnóstico de ambientes. Es la que casi nadie tiene.

**Incidentes del cuaderno que usan esta ruta:** 18 (el fix que no llegó) y 19 (blanco en PROD).
**Amplía:** **A09** §1 y §2 para imágenes, tags y digests, `forense-fase-14.md` para cuando el mismo despliegue vive en un cluster, y el `HOTFIX.md` que escribes en la Fase 13 §5.9, que es donde todo esto se convierte en una página que te llevas.
