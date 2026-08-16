# 🕵️ Forense Fase 03 — "A veces carga y a veces se queda pensando"

> **Sale de:** [Fase 3 — Mock API mínima](03-mock-api-minima.md) ·
> **Herramientas:** Network, el inyector de caos (`mock/chaos.js`), `curl` y la
> consola · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** el spinner se queda girando, o la pantalla
> queda vacía, y el `catch` no siempre puede decirte por qué.

Ésta es la pieza más rentable del tronco, y no porque el bug sea difícil: es
porque acá se aprende la lectura de Network, que sirve para todas las fases que
vienen. La lección central es incómoda y hay que decirla sin adornos: **desde el
código del cliente, "el servidor está apagado", "el navegador me bloqueó la
respuesta" y "el servidor recibió el request y no contestó" son el mismo
evento.** Tu `catch` no puede distinguirlos. Network sí.

---

## 🎫 El ticket

> "La lista de tickets a veces carga y a veces se queda cargando para siempre.
> No es que salga error, no sale nada, se queda con la ruedita. Si le doy F5
> unas cuantas veces al final entra. Ah, y a veces entra pero sale vacía, como
> si no hubiera tickets, y sí hay."
>
> — agente de soporte · **Ambiente:** desarrollo

Dos síntomas en un solo ticket, que es lo normal: "se queda cargando" y "sale
vacía" son distintos, y probablemente tengan causas distintas. El paso 1 los
separa.

---

## 🧭 La ruta

Del más barato al más caro: la pestaña Network ya está abierta y contesta el 80%
del caso; `curl` cuesta diez segundos y desempata cliente contra servidor; el
código es lo último.

### Paso 1 — ¿el request salió, volvió, o se quedó a medias?

DevTools → **Network** → filtro `XHR` → recarga `/tickets`.

```
Name      Status    Type   Size     Time
tickets   (pending) xhr    —        18.4 s
```

**Qué descarta.** Descarta todo tu código. Un request en `(pending)` significa
que el navegador mandó y está esperando: no hubo respuesta, no hubo error, y por
lo tanto ni tu `.then` ni tu `.catch` se ejecutaron nunca — por eso el spinner
sigue vivo, porque el `.finally` tampoco corrió. Compara con las otras dos
formas que puede tomar esta misma fila:

```
tickets   200       xhr    1.2 kB   61 ms     ← normal
tickets   (failed)  xhr    —        3 ms      ← no hubo servidor, o el navegador cortó
```

Si ves `(pending)`, sigue al paso 2. Si ves `(failed)`, salta al paso 3.

### Paso 2 — ¿el servidor está vivo y solo no contesta esta ruta?

Desde otra terminal, sin tocar el navegador:

```bash
curl -i -m 5 http://localhost:3000/tickets
```

```
curl: (28) Operation timed out after 5001 milliseconds with 0 bytes received
```

**Qué descarta.** Descarta el navegador entero: CORS, extensiones, caché,
service workers. Si `curl` también se queda esperando, el que no contesta es el
servidor, y ya sabes que tu frontend no tiene nada que ver. En este curso eso
significa casi siempre `CHAOS=timeout` encendido; en producción significa un
handler que entró y no salió — exactamente el request colgado que el Curso 02
investiga en su Fase 10.

Si `curl` **sí** contesta y el navegador no, el problema está entre los dos: ve
al paso 3.

### Paso 3 — el servidor contesta a `curl` y no al navegador

Ese cuadro tiene un solo sospechoso serio, y no deja rastro en tu código:

```bash
curl -i http://localhost:3000/tickets
```

```
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
X-Powered-By: Express
```

Y en la **consola** del navegador (no en Network, no en tu `catch`):

```
Access to XMLHttpRequest at 'http://localhost:3000/tickets' from origin
'http://localhost:8080' has been blocked by CORS policy: No
'Access-Control-Allow-Origin' header is present on the requested resource.
```

**Qué descarta.** Descarta el servidor: contestó `200`, con cuerpo, y `curl` lo
recibió sin queja. El que se negó a entregarte la respuesta fue tu propio
navegador, aplicando una regla que `curl` no tiene por qué respetar. Reprodúcelo
a voluntad con `CHAOS=cors npm run mock`. Y fíjate en el detalle que hace a este
fallo tan caro: **la palabra "CORS" aparece en un solo sitio de todo el
sistema** —esa línea de la consola—; en tu `catch` llega el mismo error genérico
que si el servidor estuviera apagado.

### Paso 4 — el request volvió en verde y la pantalla igual está vacía

Otro síntoma del mismo ticket, otra rama. Si Network dice `200`:

```
tickets   200   xhr   38 B   45 ms
```

Mira el **cuerpo**, pestaña Response, y después pregúntale al servicio qué te
devolvió:

```js
> ticketService.getTickets().then(function (d) { console.log(typeof d, d); })
object []          // ← respuesta vacía: CHAOS=empty
string [{"id":1,"title":"La impresora no imp    // ← cuerpo roto: CHAOS=malformed
```

**Qué descarta.** Separa los dos casos que se ven idénticos en pantalla. Si es
un arreglo vacío, el sistema funcionó y no hay datos —o el mock te está mintiendo
con `empty`—, y tu vista no distingue "no hay tickets" de "no llegaron
tickets". Si `typeof` dice `string`, el cuerpo no era JSON válido: axios intenta
parsearlo, falla en silencio y te entrega el texto crudo, sin lanzar nada. El
`.catch` no corre, el error aparece más tarde y en otro sitio, con la forma
`tickets.filter is not a function`.

### Paso 5 — ¿y si el error existía y nadie lo vio?

Si nada de lo anterior encaja, queda el caso en el que el fallo se perdió por el
camino:

```js
// El sospechoso, en cualquier servicio o action:
.catch(function () { /* … */ })
```

**Qué descarta.** Descarta la red y apunta al código, que es el último lugar
donde había que mirar. Un `catch` vacío, o una action que no **devuelve** su
Promise, hacen que el error exista y no llegue a ninguna parte: la vista se
queda en el estado en que estaba, con el spinner encendido o con la lista vieja.
Es el mismo error de diseño que la fase enumera en sus errores comunes, y el que
la Fase 10 se vuelve a encontrar con Vuex de por medio.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Spinner infinito, request en `(pending)` | El servidor no contestó: `CHAOS=timeout`, o un handler colgado |
| Spinner infinito, request en `200` | Tu `.finally` no corre, o el `.catch` se comió el error |
| "No se pudieron cargar los tickets", `(failed)` en Network | Mock apagado, o CORS: mira la consola para desempatar |
| `curl` funciona y el navegador no | CORS, siempre. La consola es el único sitio que lo dice |
| Lista vacía, `200` con cuerpo `[]` | No distingue "sin datos" de "sin respuesta útil" |
| `tickets.filter is not a function` | El cuerpo no era JSON: `res.data` te llegó como string |
| Todo funciona pero lento y se crean cosas duplicadas | Falta estado de carga: el usuario hace clic tres veces |
| Editaste `db.json` a mano y tus cambios desaparecieron | json-server con `--watch` reescribió el archivo |
| El error de una petición no aparece por ningún lado | La action no devuelve la Promise, o hay `try/catch` sobre código asíncrono |
| Un 404 en `/tickets/999` que la vista no muestra | El error sí llegó: la vista no tiene caso para él |

---

## ⚰️ Los callejones

**"Es CORS."** Es la primera hipótesis de todo el mundo y casi siempre es falsa,
porque json-server permite CORS por defecto y la Fase 3 no lo toca. La evidencia
que la confirma o la tumba es una sola línea de la consola, y tarda cinco
segundos en mirarse. Cuando la confirmes, recuerda que **CORS no es un error de
tu código**: el servidor y el cliente están bien; falta una cabecera.

**"El backend está caído."** Puede ser, pero es indistinguible de otras dos
cosas desde el frontend, y decirlo sin `curl` es adivinar. Un `curl` te separa
"no hay servidor" de "hay servidor y algo pasa en el medio", y esa frase en un
ticket vale más que cualquier hipótesis.

**"Hay que subir el `timeout` de axios."** Al revés: sin `timeout` configurado,
axios espera **para siempre**, y ese es justamente el spinner eterno. Poner un
timeout no arregla el problema, pero convierte un cuelgue silencioso en un error
que tu `catch` puede contar — que es lo que te hacía falta para depurarlo.

---

## 🧨 Deshacer

Todo el recorrido se hace con el inyector de caos, así que se apaga solo:
`Ctrl+C` en la terminal del mock y `npm run mock` sin variable. Si además
ensuciaste los datos probando:

```bash
git checkout -- db.json     # recupera tus escenarios commiteados
npm run mock:reset          # o regenera desde db.seed.json, y se los lleva
```

La diferencia entre esos dos comandos está en
[la convención de git §🧹](../prompts/convencion-de-git-y-tags.md).

---

## 🧠 El patrón transferible

**Lo que tu `catch` puede contarte es mucho menos de lo que pasó.** En una
petición HTTP fallida hay al menos cuatro historias distintas —no salió, salió y
no volvió, volvió bloqueada, volvió rota— y el código del cliente colapsa todas
en un solo camino de error. Por eso el orden de esta ruta pone Network y `curl`
por delante del código: son las dos únicas herramientas que ven la diferencia.

Y el corolario que te vas a llevar a cualquier stack: **cuando el cliente y una
herramienta de línea de comandos no ven lo mismo, el problema está entre los dos,
no en ninguno de los dos.** Es el desempate más barato que existe, y casi nadie
lo hace primero.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 3](03-mock-api-minima.md), la tabla completa de fallos del inyector en su
sección 🔥, el índice de síntomas en [`forense-master.md`](forense-master.md), y
el caso completo en el [incidente 02](cuaderno-incidentes.md) del cuaderno.
