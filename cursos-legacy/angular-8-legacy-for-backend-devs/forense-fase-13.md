# 🕵️ Forense Fase 13 — "En UAT entra y en PROD no"

> Pieza forense de la [**Fase 13 — Build, despliegue y cierre**](./13-build-despliegue.md) · Recorrido: ~50 min · [Índice del track](./forense-master.md)
> Herramientas: Network buscando `config.json` · el log del contenedor · `docker inspect` · el feature flag
> Síntoma que cubre: una aplicación que hace lo correcto con los datos equivocados, sin un solo error.

Lo que se depura acá no es un stack trace: es un **diff entre ambientes**. El bug clásico de despliegue no tiene error en consola —tiene una aplicación que arrancó con la configuración de otro sitio y se comporta impecablemente mal—. Y como la imagen es la misma en los dos ambientes, la pregunta "¿qué cambió en el código?" no tiene respuesta útil: no cambió nada.

Es la tesis del curso puesta a prueba: **la configuración se hornea en tiempo de compilación y el contenedor la inyecta en tiempo de arranque**, y toda la fricción vive en esa frontera.

---

## 🎫 El ticket

> *"Desplegamos ayer. En UAT todo bien. En PROD la pantalla de pacientes queda cargando y después dice que no se pudo. El backend de PROD está arriba, lo acabamos de comprobar."*

**Reportado por:** el líder del despliegue, a las siete de la tarde
**Ambiente:** PROD
**Presión:** alta, que es parte del ejercicio.

"El backend está arriba" es cierto y es inútil hasta que sepas **a qué backend le está hablando la aplicación**. Ésa es toda la investigación.

---

## 🧭 La ruta

Seis pasos. Los tres primeros se hacen desde el navegador de cualquiera que pueda abrir la aplicación y cuestan un minuto; los dos siguientes necesitan acceso al contenedor; el último no es diagnóstico sino contención, y en un despliegue a las siete de la tarde suele ser lo primero que hay que decidir.

### Paso 1 — A qué backend le está hablando, de verdad

Network → filtro `XHR` → recarga → busca **`config.json`**, que es la primera petición que hace la aplicación antes de mostrar nada. Pestaña **Response**:

```json
{"apiUrl":"http://uat.interno:3000","environmentName":"uat","timeZone":"America/Bogota","features":{"deliveryPdfEnabled":true}}
```

**Qué descarta.** Todo. La aplicación desplegada en PROD arrancó con la configuración de UAT, y el `environmentName` lo confirma sin margen de interpretación. El backend de PROD está arriba y nadie le está hablando; el de UAT probablemente no acepta peticiones desde este origen, o responde con datos que no son.

Cinco posibles resultados de este paso, y cada uno cierra una investigación distinta:

| Lo que trae el `config.json` | Qué pasó |
|---|---|
| La URL del otro ambiente | el contenedor arrancó con las variables equivocadas → paso 3 |
| `"apiUrl": "${API_URL}"` literal | `envsubst` no expandió esa variable → paso 4 |
| La URL correcta | la config está bien; el problema es otro → paso 2 |
| `404` | el `config.json` no se generó: el entrypoint falló → paso 5 |
| Nada: la petición no aparece | el `APP_INITIALIZER` no llegó a correr, o el bundle es viejo |

### Paso 2 — Si el `config.json` está bien: ¿lo está leyendo alguien?

Antes de irte a la infraestructura, comprueba que la aplicación **usa** lo que leyó. Mira la petición siguiente en Network, la que va a los datos:

```
Name       Status   Type  Time
config.json   200   xhr   4 ms     ← "apiUrl": "http://prod.interno:3000"
patients      (failed)  xhr  3 ms  ← Request URL: http://localhost:3000/patients
```

**Qué descarta.** Dos direcciones distintas en dos peticiones consecutivas: el `config.json` dice una cosa y el servicio le habla a otra. Eso es un servicio que **sigue leyendo de `environment`** en vez del `AppConfigService`, que es la deuda declarada de la fase: hay servicios nuevos leyendo del config y servicios viejos leyendo del bundle, conviviendo en la misma imagen.

```bash
grep -rn "environment.apiUrl" src/
```

Si hay resultados, el diagnóstico está cerrado y no es de despliegue: es de migración incompleta. Y el rezagado que más se escapa no es un servicio, es `environment.timeZone`.

### Paso 3 — Qué variables recibió el contenedor

Ahora sí, del lado de la infraestructura. Dos comandos, y el primero es más barato:

```bash
# 👁️ El log del contenedor. El entrypoint deja rastro en su primera línea.
docker logs lab-frontend-prod | head -3
# [entrypoint] config generada para ambiente: uat -> http://uat.interno:3000
```

```bash
# 👁️ Lo que se le paso al arrancar, tal cual.
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' lab-frontend-prod
# API_URL=http://uat.interno:3000
# ENVIRONMENT_NAME=uat
# APP_TIME_ZONE=America/Bogota
# FEATURE_DELIVERY_PDF=true
```

**Qué descarta.** La causa raíz está a la vista: el contenedor de PROD se levantó con las variables de UAT. No es un bug de la aplicación, ni de la imagen, ni del build — es el comando de arranque. **Y esa primera línea del log existe exactamente para este momento**: cuando algo falla, la primera pregunta siempre es "¿a qué ambiente arrancó esto?", y tenerla escrita ahorra media hora.

Si el log dice el ambiente correcto y el `config.json` dice otro, entonces hay dos contenedores y le estás preguntando al que no era, que es un clásico de las siete de la tarde.

### Paso 4 — Si quedó un `${...}` sin expandir

`envsubst` sustituye **sólo** las variables que se le listan explícitamente. Si alguien añadió una clave a la plantilla y se olvidó de la lista, esa clave viaja con el marcador literal:

```json
{"apiUrl":"http://prod.interno:3000","features":{"deliveryPdfEnabled":${FEATURE_DELIVERY_PDF}}}
```

Y entonces el `JSON.parse` del navegador revienta con un mensaje que no menciona ni al entrypoint ni a la plantilla. Compruébalo en el archivo, no en la memoria:

```bash
# 👁️ La lista de variables del envsubst, contra las claves de la plantilla.
docker exec lab-frontend-prod cat /entrypoint.sh | grep envsubst
docker exec lab-frontend-prod cat /usr/share/nginx/html/assets/config.template.json
```

**Qué descarta.** Si la clave está en la plantilla y no en la lista, ése es el bug y es de una línea. Es la parte del `entrypoint.sh` que más veces se olvida, y no avisa: el contenedor arranca contento.

### Paso 5 — Si el `config.json` da 404, o la aplicación no arranca

El entrypoint corre con `set -e`: si cualquier comando falla, el script termina y **nunca se llega al `exec nginx`**. El contenedor muere en el arranque sin servir un solo byte.

```bash
# 👁️ Lo que dijo antes de morir. Sin --previous no ves nada util si reinicio.
docker logs --tail 20 lab-frontend-prod
```

**Qué descarta.** Un error de escritura sobre el `$TARGET` —permisos, un volumen de sólo lectura montado encima— explica a la vez que no haya `config.json` y que nginx no responda. Ése es exactamente el fallo que la Fase 14 provoca a propósito montando un ConfigMap sobre esa misma ruta, y su recorrido está en [`forense-fase-14.md`](./forense-fase-14.md).

### Paso 6 — El artefacto: ¿es la misma imagen?

La pregunta que cierra el diff entre ambientes. Si los dos contenedores no corren el mismo artefacto, todo lo anterior puede ser cierto y aun así estar persiguiendo el bug equivocado:

```bash
# 👁️ El digest de la imagen que corre cada contenedor.
docker inspect -f '{{.Image}}' lab-frontend-uat
docker inspect -f '{{.Image}}' lab-frontend-prod
```

Y desde el navegador, sin acceso al servidor, el equivalente pobre pero suficiente: comparar el **nombre con hash** del bundle principal en la pestaña Network de los dos ambientes.

```
uat  → main.8a1f2c.js
prod → main.4d90e7.js      ← no es el mismo build
```

**Qué descarta.** Hashes distintos significan que alguien recompiló cuando no debía, y la premisa de la fase —una imagen, dos configuraciones— se rompió en algún punto de la cadena. Ahí la investigación deja de ser de configuración y pasa a ser del pipeline. Hashes iguales confirman la premisa y dejan a la configuración como única variable, que es lo que quieres.

### Paso 7 — Contención: el feature flag, a las siete de la tarde

Esto no es diagnóstico, y por eso va al final aunque en la vida real muchas veces sea lo primero. Si lo que está roto en PROD es una funcionalidad concreta —la entrega de PDF, por ejemplo—, no hace falta desplegar código para apagarla:

```bash
# ✍️ Apagar la feature y reiniciar. Sin recompilar, sin desplegar.
docker run -d -p 80:80 -e API_URL=http://prod.interno:3000 \
  -e ENVIRONMENT_NAME=prod -e FEATURE_DELIVERY_PDF=false lab-frontend:1.0.0
```

Eso compra el tiempo para arreglarlo bien el lunes, que es exactamente para lo que existe un feature flag. **Y no lo confundas con el fix:** apagar la feature deja el sistema estable y el bug intacto. Un post-mortem que dice "se resolvió apagando el flag" está describiendo la contención, no la causa.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Dónde miras |
|---|---|---|
| Funciona en UAT y no en PROD, sin errores raros | configuración, casi siempre | `config.json` en Network, **antes que nada** |
| `config.json` con la URL del otro ambiente | el contenedor arrancó con otras variables | `docker inspect`, y la primera línea del log |
| `config.json` con un `${VAR}` literal | falta esa variable en la lista de `envsubst` | el `entrypoint.sh` contra la plantilla |
| `Unexpected token $ in JSON` al arrancar | lo mismo, visto desde el navegador | el cuerpo del `config.json` servido |
| `config.json` correcto y peticiones a otra URL | un servicio sigue leyendo de `environment` | `grep -rn "environment.apiUrl" src/` |
| El `-e` no tiene ningún efecto | el navegador cacheó un `config.json` viejo | `Ctrl+Shift+R`, y el `no-store` del nginx |
| Recargar una ruta profunda da 404 | falta `try_files … /index.html` | el `nginx.conf` que copió el Dockerfile |
| `Unexpected token < in JSON at position 0` | `try_files` devolvió `index.html` con un 200 | el `location` de `assets/i18n/` con `=404` |
| Un texto corregido no llega a los usuarios | los assets no llevan hash y se cachearon | las cabeceras `Cache-Control` de ese `location` |
| El contenedor muere al arrancar | el entrypoint falló y `set -e` cortó antes del `exec` | `docker logs`, últimas líneas |
| La imagen pesa 900 MB | el Dockerfile no es multi-stage | la etapa final: `nginx:stable-alpine` |
| Compila con `ng serve` y falla en `docker build` | una arrow anónima en un `useFactory`: el AOT no la serializa | las factories exportadas con nombre |
| Bundles con hashes distintos entre ambientes | alguien recompiló: no es la misma imagen | el digest, o el nombre del `main.*.js` |

---

## ⚰️ Los callejones

**"El backend está caído."** Es lo que dice la pantalla y lo que dijo el ticket al revés. Se descarta en un minuto y sin salir del navegador: mira **a qué host** se está intentando conectar antes de comprobar si ese host responde. Media hora de investigación se pierde así, todos los meses, en todos los equipos.

**"Hay que volver a desplegar."** Redesplegar con el mismo comando de arranque reproduce el bug idéntico, y encima destruye la evidencia: el contenedor con las variables equivocadas es lo que estás investigando. Primero se lee `docker inspect`, después se decide.

**"Es CORS."** Aparece siempre y es un síntoma, no la causa: si la aplicación de PROD le habla a UAT, es normal que el navegador bloquee. Arreglar CORS en UAT para que acepte al origen de PROD sería tapar el diagnóstico con una configuración nueva y equivocada.

**"El código de PROD es distinto."** Comprobable en treinta segundos con el paso 6 y casi siempre falso: la premisa de la fase es que la imagen es la misma. Cuando resulta ser cierto, deja de ser un problema de despliegue y pasa a ser uno de pipeline — y eso cambia a quién le corresponde el ticket.

**"Lo arreglamos con el flag."** Es contención, no fix, y confundirlas tiene un costo real: la feature apagada se queda apagada meses porque nadie recuerda que había un bug detrás. Un flag encendido en un ambiente y apagado en otro es, además, otra diferencia entre ambientes — es decir, más material para el próximo "en UAT funciona y en PROD no".

---

## 🧨 Deshacer

El recorrido puede dejar contenedores levantados y un navegador con caché envenenada:

```bash
# 1. Los contenedores de prueba. Listalos antes de borrar nada.
docker ps -a --filter "name=lab-frontend"
docker rm -f lab-frontend-prueba

# 2. El config.json local, que es artefacto de arranque y no código fuente.
#    Si aparece en git status, falta la línea en .gitignore.
git status --short src/assets/
```

Y la que más veces salva la siguiente investigación: **recarga sin caché** (`Ctrl+Shift+R`) después de cada cambio de variables. Un `config.json` cacheado del intento anterior te va a mostrar el ambiente equivocado con total convicción, y vas a diagnosticar un bug que ya habías arreglado.

---

## 🧾 El checklist de una página — cierre del track

Ésta es la última pieza del track, y le toca dejar el único artefacto que se lleva al trabajo real. No es un archivo nuevo del proyecto: es una página que escribes tú, y que la **retrospectiva del mes** de [`cuaderno-incidentes.md`](cuaderno-incidentes.md) te pide reescribir con lo que aprendiste. Acá está la versión de partida, destilada de los quince recorridos.

**Antes de escribir código**

1. ¿Se reproduce, y con qué? Un flag del caos, un dato, u otro código. Si no se reproduce, no hay fix: hay una hipótesis.
2. ¿Qué dice la evidencia observable —consola, Network, log de acciones— antes que el código?
3. ¿En qué capa está? Plantilla, componente, selector, reducer, effect, interceptor, mock, build, contenedor.
4. 🧬 ¿Lo escribió el sistema, o llegó ya roto en el dato?

**Al escribir el fix**

5. Escribe primero el test que falla por la misma razón que el usuario sufre, y **míralo en rojo**.
6. Distingue el parche mínimo de la refactorización correcta, y di en voz alta cuál estás haciendo.
7. Si el fix cambia el comportamiento de más de una pantalla, ya no es un hotfix: es un ticket con fecha.

**Antes de desplegar**

8. ¿Qué configuración recibe cada ambiente al arrancar, y son la misma imagen?
9. ¿Hay un feature flag que permita apagar esto sin desplegar? Si lo hay, decide antes si lo vas a usar.
10. ¿Qué se rompe si esto sale mal, y cómo lo revierto? `rollout undo`, el flag, o el tag anterior.

**Después de desplegar**

11. Comprueba en el ambiente real lo mismo que comprobaste en el tuyo, y por la misma vía (`config.json` en Network, no "parece que va bien").
12. Cierra con el **post-mortem de ocho puntos** y el par de tags `inc/<ID>/…-roto` / `-fix`, que dejan el `git diff` del fix aislado del ruido de la fase.

> 🧭 **El árbol de decisión, en tres preguntas.** ¿El sistema está en riesgo ahora mismo? → contén con el flag o revierte, y diagnostica después. ¿Está estable pero equivocado? → diagnostica primero, parchea con lo mínimo, y abre el ticket del fix correcto. ¿Está estable y no sabes si es un bug? → no toques nada hasta poder reproducirlo; un fix sobre un síntoma que no reproduces es un cambio a ciegas.

---

## 🧠 El patrón transferible

> **Cuando algo "no responde", antes de culpar al backend, confirma a qué backend le estás hablando.** Es una comprobación de un minuto que descarta media docena de hipótesis caras, y funciona igual en cualquier arquitectura: la primera pregunta ante un fallo entre ambientes no es qué código cambió, sino **qué configuración recibió cada uno al arrancar**.

Y el segundo, que es la tesis del curso: **la configuración horneada en tiempo de compilación y la inyectada en tiempo de arranque son dos mundos, y la mitad de los "funciona en UAT y no en PROD" viven en la frontera.** Un bundle con la URL adentro obliga a recompilar para cambiar de ambiente; un `config.json` leído al arrancar hace la imagen inmutable y mueve la variable afuera. Reconocer cuál de los dos patrones tiene delante —y detectar los rezagados que quedaron del primero cuando alguien migró a medias— es lo que separa un despliegue tranquilo de una noche larga.

**Incidentes del cuaderno que usan esta ruta:** el **19** —*"desplegamos a PROD y le sigue hablando a UAT"*, que entra por el paso 1— y el **20** —*"si recargo la página en cualquier pantalla, me da 404"*, que es la línea de `try_files`.
**Amplía:** el [**Apéndice A04**](./a04-webpack-oculto.md) para lo que el CLI esconde en el build y el papel de los hashes, el [**Apéndice A09**](./a09-kubernetes.md) para llevar esta misma imagen a un cluster, y [`forense-fase-14.md`](./forense-fase-14.md) para cuando el contenedor ni siquiera llegue a arrancar.
