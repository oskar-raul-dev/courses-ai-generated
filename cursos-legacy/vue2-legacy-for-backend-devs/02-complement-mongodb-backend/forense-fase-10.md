# 🕵️ Forense Fase 10 — "El request se queda girando para siempre" ⭐

> **Sale de:** [Fase 10 — Express, el vehículo](10-express-el-vehiculo.md) ·
> **Herramientas:** los logs de morgan, `curl`, y la pestaña Network del
> frontend · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** el request entra, no vuelve, y no hay error en
> ninguna parte.

Esta pieza promueve a archivo el recorrido que la Fase 10 ya traía en su sección
6 y le añade la otra mitad de la fase: **la frontera**. Las dos cosas que se
rompen acá son el request que desaparece y el contrato que se cumple a medias, y
las dos fallan en silencio — que es lo que las hace caras.

---

## 🎫 Los dos tickets

> **1.** "La pantalla de detalle se queda cargando para siempre con ciertos
> tickets. No sale error, no sale 404, se queda con la ruedita. Otros tickets
> abren bien."
>
> **2.** "Apuntamos el frontend al backend nuevo y el dashboard sale vacío. Pero
> si hago `curl` a la API, los tickets están ahí."

El segundo es el incidente de costura por excelencia del paquete, y su
diagnóstico está en el paso 4.

---

## 🧭 La ruta

Del más barato al más caro: el log de morgan ya está escrito, `curl` cuesta diez
segundos, y el código es lo último. Y hay que leer el log **al revés** de como
sugiere el instinto.

### Paso 1 — mira el log de morgan, y su ausencia

```
GET /tickets 200 41.271 ms - 12843
GET /tickets/5f8a1c2e4b3d2f0012a4e991
```

La segunda línea nunca se completa.

**Qué descarta.** Es el paso que hay que leer con cuidado, porque contesta al
revés de lo que uno espera: en `morgan("dev")` la línea se imprime **cuando la
respuesta se cierra**. Que no haya línea **no significa que el request no
llegó**: significa que nunca se contestó. El handler entró y no salió. Descarta,
de paso, la red y el frontend.

### Paso 2 — ¿es este handler o es el servidor entero?

```bash
curl -i -m 5 http://localhost:4000/tickets/5f8a1c2e4b3d2f0012a4e991
curl -i http://localhost:4000/health
```

```
curl: (28) Operation timed out after 5001 milliseconds with 0 bytes received
HTTP/1.1 200 OK
{"ok":true,"db":"up"}
```

**Qué descarta.** Descarta que el proceso esté caído o bloqueado: atiende otras
rutas sin problema. El problema es **un** handler, no el servidor. Si `/health`
también colgara, la investigación se iría al pool de conexiones — paso 5.

### Paso 3 — el `await` sin red

Ahora sí, el código, y solo el handler que falla:

```js
router.get("/tickets/:id", async function (req, res) {
  var ticket = await service.getById(req.params.id);   // ⚠️ si esto lanza…
  res.json(serialize(ticket));
});
```

**Qué descarta.** Cierra el caso. **Express 4 no captura el rechazo de una
promesa** en un handler async: la excepción no llega al middleware de errores, el
handler muere en silencio y el request queda colgado. No es un 500 — es un
*no-response*. Confírmalo envolviendo el handler en `asyncHandler` o añadiendo
`try { … } catch (err) { next(err) }`: el mismo request pasa a devolver el 500
del middleware central —o el 404 limpio, si era eso— y morgan por fin imprime su
línea.

### Paso 4 — el frontend vacío con `curl` en verde

Segundo ticket, otra rama, misma fase. Compara lo que devuelve la API con lo que
el contrato promete:

```bash
curl -s http://localhost:4000/tickets | head -c 200
```

```json
{"data":[{"_id":"5f8a1c2e4b3d2f0012a4e991","title":"La impresora no imprime",
"createdAt":"2020-03-10T10:00:00.000Z"}]}
```

**Qué descarta.** Descarta Mongo, el service y la red: los datos están y son
correctos. Lo que falla es la **frontera**, y hay dos delitos en esa única línea:

- el **envelope reflejo** `{ data: [...] }`, cuando el frontend hace `res.data`
  de axios y espera el recurso directo — rompe todo, silenciosamente;
- el `_id` sin traducir a `id`, que es lo que
  [`00-audit-contrato.md`](00-audit-contrato.md) contrata y de lo que vive cada
  `:key` del frontend.

Ninguna de las dos produce un error: producen una pantalla vacía en el otro
extremo del sistema.

### Paso 5 — el servidor que se degrada solo

Si el síntoma no es un endpoint sino todo, a los pocos minutos:

```
MongoServerError: connection pool exhausted
```

```bash
grep -rn "MongoClient.connect" src/
```

```
src/routes/tickets.js:12:  var client = await MongoClient.connect(uri);
```

**Qué descarta.** Descarta el código de negocio: es infraestructura. Un
`MongoClient.connect` por request abre una conexión nueva cada vez y agota el
pool en minutos. El cliente se crea **una vez** al arrancar y se comparte — es el
mismo principio del singleton del socket del Curso 01, con otra librería.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Request en `pending` eterno, sin línea en morgan | Handler async sin `next(err)`: entró y no salió |
| 500 sin detalle en todos los errores | El middleware de error está, pero nadie le pasa nada |
| El frontend no muestra nada y `curl` sí trae datos | La frontera: envelope de más, o `_id` sin serializar |
| Fechas que el frontend no sabe formatear | `Date` crudo en vez de ISO en el serializer |
| Campos internos visibles en la API | Se devolvió el documento crudo: `history`, `schemaVersion` |
| Conexiones agotadas a los pocos minutos | Un `MongoClient.connect` por request |
| `?q=` que revienta con ciertos textos | Regex sin escapar: funciona hasta el primer `(` |
| `_sort=id` que no ordena | Falta traducir `id` → `_id` en el sort |
| Un id malformado devuelve 500 en vez de 404 | Falta validar el hex antes de construir el `ObjectId` |
| CORS bloqueando desde el navegador y `curl` bien | Falta el middleware de CORS: una hora perdida culpando al código |

---

## ⚰️ Los callejones

**"El servidor se cayó."** El paso 2 lo descarta en diez segundos: `/health`
responde. Un proceso Node que atiende una ruta y cuelga en otra no está caído, y
la diferencia cambia por completo dónde buscar.

**"Mongo está lento."** Es la conclusión que salta cuando algo tarda, y acá es
falsa: si el request estuviera esperando a Mongo, la consulta aparecería en
`db.currentOp()`. No aparece, porque nunca se llegó a hacer o porque ya terminó y
el que no volvió fue el handler.

**"Le pongo un timeout al frontend y listo."** Convierte un cuelgue en un error
—que es una mejora real de experiencia— y no arregla nada del servidor: el
handler sigue muriendo en silencio y el request colgado sigue consumiendo un
socket. Es un parche legítimo mientras arreglas la causa, no en lugar de
arreglarla.

**"El frontend está mal, que se adapte al envelope."** Es el callejón más caro
del paquete, porque parece razonable y viola el contrato: el frontend se escribió
contra `00-audit-contrato.md` y el backend nuevo se comprometió a honrarlo. Si de
verdad el envelope es mejor, se cambia el contrato primero — no la API en
silencio.

---

## 🧠 El patrón transferible

**Un fallo silencioso es una decisión de diseño de alguien, casi siempre del
framework.** Express 4 no captura promesas rechazadas porque nació antes de
`async/await`, y esa decisión convierte un error de negocio en un request que
desaparece. Cuando llegues a un stack nuevo, la pregunta que más rinde es
justamente ésa: **¿qué se traga este framework, y dónde reaparece?**

Y el segundo patrón, propio de las fronteras: **un contrato que se cumple a
medias no da error, da una pantalla vacía a tres capas de distancia.** Por eso el
desempate del paso 4 —`curl` contra la API, comparando con el contrato escrito—
vale más que cualquier hipótesis: separa "el dato no está" de "el dato está y no
tiene la forma pactada", que son dos investigaciones completamente distintas.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 10](10-express-el-vehiculo.md); el contrato completo en
[`00-audit-contrato.md`](00-audit-contrato.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); y el caso completo en el
[incidente 10](cuaderno-incidentes.md), que es de costura y trae el frontend ya
construido.
