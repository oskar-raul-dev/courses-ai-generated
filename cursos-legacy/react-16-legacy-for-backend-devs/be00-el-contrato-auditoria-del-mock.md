# 📜 Fase be00 — El contrato: auditoría del mock

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Fase be00 de be09 · **6 horas**
> Depende de: Fase 11 del track base · Habilita: be01 — Go 1.19 y la forma del monolito

---

## 🎯 1. Propósito

Juliana lo pone como primera condición antes de escribir una línea de Go: *"el contrato antes del reemplazo; lo que el API hace, no lo que dice el README"*. El README que dejó la agencia de San José en 2020 describe un API que ya no existe, y el mock de la Fase 3 imita el que sí existe, con sus defectos (`00-historia-del-sistema.md` §6 y §7). Antes de escribir un backend que lo reemplace hay que saber **qué está obligado a hacer**, y esa obligación no es la que dice el código del mock: es la que ejercen sus clientes. Esta fase levanta ese inventario midiendo tráfico real —pestaña Network, recorrido completo por la consola— y lo deja por escrito como un contrato verificable, con su checklist de smoke test.

Es la única fase del track que no escribe una línea de Go. También es la única cuyo error se propaga a las nueve siguientes: si el contrato queda mal auditado, `be03` falla, la consola se rompe y pierdes la fe en el track. Por eso se mide.

> 🧭 **La regla que gobierna el track entero, y que esta fase deja por escrito.** El frontend heredado **no se toca**. El backend se adapta al contrato existente, nunca al revés. Un backend "mejor diseñado" que obliga a cambiar el cliente es, para este curso, un backend roto.

---

## ✅ 2. Qué queda listo al terminar

- [ ] El estado actual del frontend queda marcado con el tag `pre-backend-go`, que es la referencia contra la que todas las fases BE demuestran que no lo tocaron.
- [ ] Existe una captura HAR de un recorrido completo por la consola (`server/evidence/recorrido.har`), tomada con el caos apagado.
- [ ] Existe `server/CONTRACT.md` con el inventario de **todo** lo que los clientes consumen del `3001`: método, ruta, entrada, salida, códigos de error y rarezas.
- [ ] El contrato separa explícitamente **régimen estricto** (lo que no puede cambiar) de **régimen de crecimiento** (lo que el backend puede añadir sin romper nada), y cada entrada del estricto cita la fase y el archivo que la consume.
- [ ] Los siete hallazgos de la auditoría (`C-01` a `C-07`) están registrados con su evidencia, incluida la **única excepción negociada** del track.
- [ ] Existe `server/smoke.sh`: el checklist de smoke test ejecutable con `curl`, que hoy pasa entero contra el mock y que se corre al final de `be03` y de cada fase posterior.
- [ ] `git diff pre-backend-go..HEAD -- . ':!server'` no devuelve nada.

---

## 🚫 3. Qué queda fuera por ahora

- **Go, en cualquier cantidad.** El primer `go.mod` es de `be01`.
- **El esquema de base de datos.** El contrato describe formas JSON, no tablas. Traducirlas a `wheels`, `wheel_segments`, `spin_log` y compañía es trabajo de `be02`.
- **El mock de Google Play del `3002`.** Se audita para saber dónde está la frontera, pero **no se reescribe nunca**: es un proveedor externo y esa frontera es contenido, no descuido.
- **Arreglar lo que encuentres.** Esta fase registra los defectos del API heredado; no los corrige. Cada hallazgo dice qué fase lo paga, y hasta entonces `be03` los reimplementa tal cual.

---

## 🧠 4. Conceptos mínimos

### Un contrato es lo que se observa, no lo que se documentó

La palabra "contrato" está gastada, así que vale la pena afilarla para lo que vamos a hacer. Acá un contrato es **el conjunto de comportamientos observables de los que depende un cliente ya escrito**. No es lo que el servidor pretende ofrecer, no es lo que su README dice, y —esto es lo que más cuesta aceptar— no es lo que su código sugiere leyendo los handlers. Es lo que pasaría si mañana lo cambias: si un cliente se rompe, era contrato.

De ahí se siguen dos cosas incómodas. La primera: el mock tiene rutas que nadie llama, y esas no son contrato. La segunda pesa más: **el contrato lo define el consumidor, no el proveedor, y no todos los consumidores viven en tu repositorio.** La consola es uno. El otro es Jewel Locks, el juego de Unity que pide los giros desde el celular de cada jugador, y que en este curso no se ve: el generador de tráfico de la Fase 3 (`scripts/traffic.js`) imita lo que manda.

### Por qué se mide con Network y no se lee el código

Podrías reconstruir esta lista con `grep apiClient src/`. Sería más rápido y estaría mal por tres razones que vas a comprobar tú mismo en la pieza forense.

La primera es que el código miente por omisión: los interceptores agregan headers que no aparecen en ninguna llamada, y el navegador agrega otros por su cuenta (`Content-Type`, el `OPTIONS` de preflight, el `If-None-Match` de la caché) que ningún `grep` te va a mostrar. La segunda es que no todas las llamadas usan el nombre que buscas: los epics de la Fase 6 reciben el cliente HTTP por inyección de dependencias y lo llaman `api`, y la Fase 7 suma una segunda instancia, `apiStore`. La tercera es la que importa: **leyendo el código encuentras lo que el frontend pretende pedir; midiendo encuentras lo que pide**. Cuando las dos listas no coinciden, la diferencia es exactamente el bug que `be03` te va a explotar en la cara.

### Régimen estricto y régimen de crecimiento

Un contrato con una sola categoría no sirve: o te ata las manos o no te ata nada. Este se parte en dos.

El **régimen estricto** es lo que los clientes consumen hoy, medido. Cambiar cualquier cosa de acá rompe la aplicación: el nombre de un campo, el tipo de un valor, un código de estado, la forma de un cuerpo de error. No se negocia, no se mejora, no se "moderniza". Se reimplementa tal cual, y sí, a veces es aburrido: reimplementar el dialecto ajeno es *aburrido y correcto*.

El **régimen de crecimiento** es todo lo demás: lo que el backend puede añadir sin que ningún cliente actual se entere. Endpoints nuevos, campos nuevos en una respuesta (que el frontend ignora), headers nuevos, validaciones **más permisivas**. La regla operativa cabe en una línea: agregar es crecimiento, quitar y renombrar es ruptura. Un campo nuevo en el JSON de una rueda es inofensivo porque `wheelSlice` lo ignora; renombrar `closesAt` a `closing_time` mata la Fase 7.

### El dialecto de json-server

`json-server` no es un servidor genérico: tiene convenciones propias, y el frontend puede haberse acostumbrado a ellas sin que nadie lo decidiera. Las que hay que buscar en la captura son el filtrado por campo (`?wheelId=4`), los operadores (`name_like`), las relaciones (`_embed`), la paginación (`_page`, `_limit`) con su header `X-Total-Count`, el ordenamiento (`_sort`, `_order`), la búsqueda de texto (`q`), el `404` **con cuerpo vacío** cuando un recurso no existe, y el `POST` que devuelve el recurso creado completo, con el `id` que asignó el servidor.

Ojo con el sesgo acá: la lista de arriba es lo que **hay que buscar**, no lo que **hay que encontrar**. Uno de los hallazgos de esta fase es justamente que la consola usa una parte del dialecto y la otra no la usa nadie.

### El smoke test de contrato

El entregable que más vas a usar no es el documento: es `server/smoke.sh`. Un smoke test de contrato es una secuencia corta de peticiones que ejercita el régimen estricto de punta a punta y **falla ruidosamente** ante cualquier desviación. No prueba lógica de negocio ni casos borde —eso es `be08`—; prueba que el que contesta al otro lado sigue hablando el mismo idioma.

Su propiedad importante es que hoy tiene que pasar **contra el mock**. Un checklist escrito contra un servidor que todavía no existe es una lista de deseos; escrito contra el que sí existe, es un criterio de aceptación. En `be03` lo vas a correr sin cambiar una línea contra tu binario de Go, y ahí sabrás si el reemplazo salió bien: pasa o no pasa, y no es opinable.

---

## 💻 5. Implementación y código comentado

No hay código de aplicación en esta fase. Hay evidencia, un documento y un script, y los tres son entregables verificables.

### 5.1 Preparar el terreno: marcar el antes

Antes de nada, marca dónde estaba el frontend. Este tag es la referencia contra la que cada fase BE demuestra que cumplió la regla.

```bash
# Con la Fase 11 del track base cerrada y git status limpio:
git tag -a pre-backend-go -m "Frontend congelado: estado previo al track BE. \
Toda fase beNN demuestra que no lo tocó con: git diff pre-backend-go..HEAD -- . ':!server'"

mkdir -p server/evidence
```

> 🧭 **La regla, hecha comando.** `git diff pre-backend-go..HEAD -- . ':!server'` tiene que devolver vacío al cerrar cualquier fase del track. El día que devuelva algo, o encontraste la excepción negociada (`C-06`), o la fase está mal diseñada.

### 5.2 La captura: un recorrido completo con el caos apagado

El caos de la Fase 3 inyecta latencia, `401`, `503`, timeouts y respuestas malformadas. **Nada de eso es contrato**: es andamiaje del curso. Auditar con caos encendido es la forma más rápida de meter un `503` aleatorio en el inventario y pasarte `be03` intentando reproducirlo.

```bash
# Para la auditoría, y solo para la auditoría: el caos apagado en los dos mocks.
CHAOS_LEVEL=off npm run mock:all     # 3001 (API) y 3002 (Google Play)
npm start                            # la consola en el 3000
```

En DevTools → Network: activa **Preserve log**, activa **Disable cache** (sin eso, las segundas lecturas vuelven como `304` y ensucian el inventario), y recorre la consola entera sin saltarte nada. El recorrido no es opcional ni aproximado, porque lo que no ejecutes no aparece en el contrato:

1. Login con `ibatista@esclusa.test` / `esclusa123`.
2. *Ruedas*: el listado; crear una rueda; editarla; borrar la que creaste.
3. *Envíos*: abre el asistente y **espera un segundo** antes de escribir —al abrir pide todos los jugadores—; busca "ju"; marca a Juan P.; escribe un caso (`C-9001`) y un motivo; *Compensar*; *Enviar ahora*.
4. Repite el mismo caso para el mismo jugador y envíalo: el `409`.
5. *Compras*: consulta un token cualquiera (`tok-efecty-1`) y deja correr un par de ticks del polling.
6. *Conciliación*: elige la *Rueda de fin de mes* y concíliala.
7. *Dashboard*: elige la *Rueda de fin de mes*.
8. *Cerrar sesión*.

Al terminar, clic derecho sobre la lista → **Save all as HAR with content** → `server/evidence/recorrido.har`. Esa captura es la evidencia primaria de toda la fase; el documento que sigue es su interpretación.

> ⚠️ **El recorrido escribe en `mock/db.json`**: deja una rueda conciliada para siempre (`reconciled` no tiene vuelta atrás) y un envío registrado. Al terminar, **detén los mocks**, restaura el archivo con `git checkout -- mock/db.json` y vuelve a levantarlos. El orden importa: json-server guarda la base en memoria, y si restauras el archivo con el mock vivo, su próxima escritura lo vuelve a pisar.

Para leer el HAR sin abrir DevTools de nuevo, cualquier `jq` sirve:

```bash
# Inventario crudo: método, estado y ruta, sin duplicados, ya ordenado.
jq -r '.log.entries[]
       | [.request.method, (.response.status|tostring), .request.url]
       | @tsv' server/evidence/recorrido.har \
  | sed 's#http://localhost:300[12]##' \
  | sort -u
```

> ⚠️ El HAR guarda los headers, y en tu captura viaja el `Authorization` con el token de la Fase 2. Es un token de mentira sobre datos de mentira, así que no hay incidente que reportar, pero el hábito de mirar qué contiene un HAR **antes** de adjuntarlo a un ticket vale para el resto de tu carrera. En producción, un HAR es material sensible.

### 5.3 El contrato: `server/CONTRACT.md`

Este es el documento que `be03` tiene que satisfacer. Va en inglés donde nombra código —rutas, campos, headers— y en español donde explica, igual que todo el curso. Lo que sigue es su contenido; escríbelo con **tu** captura al lado y corrige cualquier discrepancia contra lo que tú mediste, que es lo que manda.

#### Régimen estricto — autenticación (Fase 2)

| Petición | Respuesta esperada | La consume |
|---|---|---|
| `GET /users?email=<email>&password=<password>` | `200` con un **array** de usuarios; array vacío si no hay coincidencia | `src/api/authService.js` |

El frontend lee de cada elemento exactamente cuatro campos: `id`, `email`, `name` y `token`. El campo `password` viaja en la respuesta y `authService` lo descarta; que llegue o no llegue es indiferente para el cliente. Y hay una sutileza que un backend "bien diseñado" arruinaría: **cero coincidencias es un `200` con `[]`, no un `401`**. `authService.js` traduce el array vacío a `throw new Error("Email o contraseña incorrectos")`; si el servidor contestara `401`, el interceptor de respuesta lo tomaría por sesión caída y dispararía el logout global en mitad del login.

#### Régimen estricto — ruedas y segmentos (Fases 4, 7, 8 y 9)

| Petición | Respuesta esperada | La consume |
|---|---|---|
| `GET /wheels?_embed=segments` | `200` con array de ruedas, cada una con su array `segments` | `wheelSlice.js` (`fetchWheels`) |
| `POST /wheels` | `201` con la rueda creada y sus segmentos, **incluido el `id` que asignó el servidor**; `422` con `{ "error": … }` si los pesos no suman 10.000 | `wheelSlice.js` (`createWheel`) |
| `PUT /wheels/:id` | `200` con la rueda completa ya actualizada; `409` si la rueda está `live` y cambian los pesos; `422` si los pesos no suman; `404` con `{ "error": … }` si no existe | `wheelSlice.js` (`updateWheel`) |
| `DELETE /wheels/:id` | `200` con `{}`; `404` con `{ "error": … }` si no existe | `wheelSlice.js` (`deleteWheel`) |
| `GET /segments?wheelId=<id>` | `200` con los segmentos de esa rueda | `reconciliationSlice.js`, `dashboardSlice.js` |

La forma de una rueda, con los tipos exactos que el frontend asume:

```json
{
  "id": 1,
  "name": "Esclusa de Oro",
  "timezone": "America/Panama",
  "closesAt": "2030-12-31T20:00:00-05:00",
  "status": "live",
  "segments": [
    { "id": 1, "wheelId": 1, "segmentId": "sin-premio", "prizeType": "none", "weightBp": 3000 }
  ]
}
```

Cuatro detalles que parecen menores y no lo son. El `id` es **número**, no string: `wheelSlice` lo compara con `===`. El `closesAt` es una cadena RFC 3339 **con offset**, no UTC con `Z`: `WheelTable` y el formulario la muestran tal cual llega, y la Fase 7 la compara como instante. `status` es uno de cinco literales —`draft`, `scheduled`, `live`, `ended`, `reconciled`— con los que la UI hace comparaciones exactas. Y `segmentId` es un **slug de texto** (`esclusa-de-oro`): la bitácora y la conciliación lo usan como llave, y `weightBp` es un entero de puntos básicos (D33).

El cuerpo que la consola manda en el `POST` y el `PUT` es la rueda entera con sus segmentos, y los segmentos viajan **sin `id`**: el servidor los reemplaza en bloque. Que el `POST` devuelva `201` y no `200` es contrato: el slice no lo mira, pero cambiarlo convierte cualquier captura de un ticket viejo en una pista falsa.

#### Régimen estricto — jugadores y envíos (Fases 5, 6 y 9)

| Petición | Respuesta esperada | La consume |
|---|---|---|
| `GET /players` | `200` con todos los jugadores | `searchPlayerEpic.js` (al abrir el asistente) |
| `GET /players?name_like=<texto>` | `200` con los jugadores cuyo nombre contiene el texto, sin distinguir mayúsculas | `searchPlayerEpic.js` |
| `POST /players/:id/grants` | `201` con el envío registrado; `422` si falta el motivo; `404` si no existe el jugador; `409` si ese caso ya se compensó para ese jugador | `sendGrantEpic.js`, `retryGrantEpic.js` |
| `GET /grants` | `200` con todos los envíos registrados | `dashboardSlice.js` |

```json
{ "id": "g-1", "playerId": 42, "caseId": "C-9001", "prize": "vidas-5", "reason": "Caída del 14/10", "createdAt": "2026-10-18T…Z" }
```

El jugador se nombra en la **URL**, no en el cuerpo, y el `id` del envío lo genera la consola (`g-1`, `g-2`…): el servidor lo guarda tal como llega. El cuerpo de error de las rutas propias es `{ "error": "…" }` con el mensaje **en español**, porque lo consume `toReadableError` y termina a la vista del operador. Los mensajes exactos que hoy devuelve el mock están en las Fases 4 y 5, y conviene conservarlos: no porque el frontend los compare —no lo hace— sino porque cambiarlos convierte cualquier captura de un ticket viejo en una pista falsa.

#### Régimen estricto — bitácora, compras y conciliación (Fases 8 y 9)

| Petición | Respuesta esperada | La consume |
|---|---|---|
| `GET /spinLog?wheelId=<id>` | `200` con **todas** las filas de la bitácora de esa rueda, sin paginar | `reconciliationSlice.js`, `dashboardSlice.js` |
| `GET /purchases` | `200` con las compras acreditadas | `reconciliationSlice.js` |
| `GET /packages` | `200` con el catálogo (`productId`, `spins`, `packagePriceCents`) | `reconciliationSlice.js` |
| `POST /wheels/:id/reconciliation` | `201` con `{ wheel, reconciliation }`, la rueda ya en `reconciled`; `409` con `{ "error": … }` si la rueda no está `ended` | `reconciliationSlice.js` (`reconcileWheel`) |

La fila de la bitácora que la consola lee, y los montos, siempre **enteros en centavos** (A10):

```json
{ "id": 1, "wheelId": 4, "playerId": 1538, "landedSegment": "sin-premio", "deliveredPrize": "sin-premio",
  "origin": "free", "idempotencyKey": "seed-42-0", "createdAt": "2026-08-01T05:00:00.000Z" }
```

Las filas de los giros pagos traen un campo más, `purchaseToken`: la compra de la que salió el giro. La consola no lo muestra, pero la conciliación de la Fase 8 agrupa por él para prorratear el precio de cada paquete entre sus giros, así que es tan contrato como los demás. No aparece en ninguna petición: está en las respuestas, y solo lo ves si lees el **contenido** del HAR, no la lista de URLs.

`GET /spinLog` sin paginar no es un descuido de la auditoría: la Rueda de fin de mes trae 10.000 filas, la Semana del Canal sembrada con `--event` trae 180.000, y la consola las pide todas en una sola petición. Es régimen estricto, y es una deuda 💸 que el contrato registra con su cifra: el día que alguien pagine, la Fase 9 tiene que cambiar primero.

#### Régimen estricto — el juego (`C-01`)

| Petición | Respuesta esperada | La consume |
|---|---|---|
| `POST /players/:id/spins` con `{ "idempotencyKey": "…" }` | `200` con `{ "landedSegment": "…" }`; `409` con `{ "error": "agotado" }` si no queda stock; `400` sin clave | Jewel Locks (`scripts/traffic.js` lo imita) |

#### Régimen estricto — headers y CORS

Esto no aparece en ninguna tabla de rutas y es lo que más veces rompe un reemplazo:

- **Petición:** `Authorization: Bearer <token>` en toda petición hecha con sesión activa. El interceptor de la Fase 2 lo pone sin excepción, y el backend no puede exigirlo donde hoy no se exige (el `GET /users` del login sale **sin** header).
- **Respuesta:** `X-Request-Id` en **todas** las respuestas, incluidas las de error. El interceptor lo lee en las dos ramas.
- **CORS:** el origen es `http://localhost:3000`, y el preflight (`OPTIONS`) tiene que aceptar el header `authorization`. Y hay una condición que no es opcional: la **respuesta real** —no el preflight— tiene que traer `Access-Control-Expose-Headers: X-Request-Id`. Sin ella el header viaja, se ve perfectamente en Network, y `response.headers["x-request-id"]` vale `undefined`: el navegador no deja leerlo. Ver hallazgo `C-05`.

#### Régimen estricto — el caos, que es andamiaje declarado

El middleware de caos **no es contrato de negocio**, pero sí es contrato de laboratorio: las prácticas de las Fases 3 y 7 lo usan y tienen que seguir funcionando después de `be03`. Por decisión `D22` el backend lo reimplementa con doble control —`POST /_chaos` y la variable `CHAOS_LEVEL`—, **apagado por defecto**. Su forma exacta la define `be01`, porque no hay forma previa que honrar: el mock de la Fase 3 solo lee `CHAOS_LEVEL` al arrancar.

#### La frontera que no se cruza: el `3002`

El mock de Google Play responde `GET /purchases/:token` (`{ purchaseToken, state }`, con `state` en `pending` o `confirmed`, y `404` si no conoce la compra) y `GET /earnings` (el reporte de ganancias de la tienda). **Ese servidor no se reescribe en Go, nunca.** Es un tercero, tiene su propio perfil de fallo, no emite `X-Request-Id`, y el `apiStore` de la Fase 7 le habla con una instancia de `axios` distinta y sin interceptor de `401`. Conservar la frontera es contenido: un backend propio no absorbe a sus proveedores porque le quede cómodo.

#### Régimen de crecimiento

Lo que el backend **puede** añadir sin romper nada, con la evidencia de por qué es seguro:

- El resto del dialecto de `json-server` (`_page`, `_limit`, `_sort`, `_order`, `q`, `X-Total-Count`). Ver `C-02`.
- Las respuestas `304` con `ETag`: la consola funciona igual con un `200` en cada lectura.
- Campos nuevos en cualquier respuesta: el frontend los ignora. `wheelVersion` en la rueda es el primero que va a aparecer (`be02`).
- Un `GET /wheels/:id`: la consola no lo pide (el detalle todavía lee de `src/mock/wheels.js`, A12), así que existe o no existe sin que nadie se entere.

### 5.4 Los siete hallazgos

Un contrato sin hallazgos es un contrato que se copió del código. Estos salieron de comparar lo que los clientes piden con lo que el mock ofrece, y cada uno tiene consecuencias en una fase concreta del track. Los que dicen *medido* los puedes repetir con `curl` contra el mock con el caos apagado.

**`C-01` · El consumidor que no está en el repositorio.** `POST /players/:id/spins` no aparece en el HAR ni en ningún `grep` de `src/`: lo llama el juego, desde el celular de cada jugador. Es régimen estricto igual que cualquier ruta de la consola, y trae los dos defectos del giro de 2019 (`00-historia-del-sistema.md` §3, Era 1). *Medido:* la misma clave dos veces a la vez da dos `200` y dos filas en la bitácora; y el stock se descuenta **después** de decidir, con lo que dos giros que leen el último stock ganan los dos. Las cifras a escala de la noche de la Esclusa de Oro son las de la Fase 3. **El contrato obliga a la forma, no a los defectos**: `be03` reimplementa el giro tal cual —el mismo `if`, traducido—, y la deuda 💸 se paga en `be05`.

```bash
for i in 1 2; do
  curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: application/json' \
       -d '{"idempotencyKey":"k-demo-1"}' localhost:3001/players/42/spins &
done; wait                                                     # 200 y 200
curl -s 'localhost:3001/spinLog?idempotencyKey=k-demo-1' | jq length   # 2
```

**`C-02` · El dialecto de `json-server`, usado a medias.** La consola usa tres piezas: `_embed=segments` en el listado de ruedas, el operador `name_like` en la búsqueda de jugadores y el filtro por campo `?wheelId=` en la bitácora y los segmentos. Esas tres son régimen estricto. El resto —`_page`, `_limit`, `_sort`, `_order`, `q` y la lectura de `X-Total-Count`— no lo usa ninguna de las once fases del track base, y baja a régimen de crecimiento: `be03` no lo implementa.

> 🧠 **Y este es el hallazgo que justifica la fase.** Si hubieras "reimplementado el dialecto de json-server" leyendo su documentación, habrías escrito paginación, ordenamiento y búsqueda para cero consumidores, y te habrías perdido `name_like`, que sí tiene uno. El contrato medido no es solo más fiel que el leído: casi siempre es **más chico**.

Hay una rareza más, que no es contrato y que conviene saber: cuando una petición lleva `_page`, json-server responde `Access-Control-Expose-Headers: X-Total-Count, Link` y **pisa** el que pone el mock. En esa respuesta el navegador ya no deja leer el `X-Request-Id`. Nadie pagina, así que hoy no le pasa a nadie; el día que alguien pagine, la trazabilidad se apaga en silencio.

**`C-03` · Dos escritores, dos formas de la misma fila.** La bitácora tiene dos escritores. Las filas que trae `mock/db.json` desde la Fase 8 llevan `wheelId`, `origin` y `deliveredPrize` (y `purchaseToken` las pagas); las que escribe el giro de 2019 llevan solo `playerId`, `idempotencyKey`, `landedSegment` y `createdAt`. *Medido:* después de los giros de `C-01`, `GET /spinLog?wheelId=1` sigue devolviendo **cero** filas aunque el stock de la Esclusa de Oro bajó, porque las filas nuevas no dicen de qué rueda son. Lo que la consola filtra por rueda no las ve, y el tablero de la Fase 9 tampoco. El contrato fija la forma completa de la fila como canónica y anota que el giro de hoy no la cumple; la causa raíz se paga en `be05`, cuando el giro escriba el hecho completo.

**`C-04` · Dos formas de `404` conviviendo.** `json-server` responde `404` con un **cuerpo vacío** (`{}`); las rutas propias del mock —ruedas con sus segmentos, envíos, conciliación— responden `404` con `{ "error": … }`. Las dos son contrato, cada una en su ruta, y el backend Go tiene que reproducir la inconsistencia. Uniformarla es exactamente el tipo de mejora razonable que rompe un cliente: `toReadableError` usa el `error` del cuerpo si lo hay, y si no, arma un mensaje genérico con el status.

**`C-05` · El header que se ve y el que se lee.** `X-Request-Id` viaja en todas las respuestas del `3001`, y la consola lo puede leer porque el middleware del mock agrega `Access-Control-Expose-Headers: X-Request-Id` en cada una (la Fase 2 lo explica). Compruébalo en tu captura antes de creerme: mira el header en Network **y** mira si tu consola imprimió la línea `[req-id …]` del interceptor. Esa línea de `requestIdMiddleware.js` es contrato aunque no figure en ninguna tabla de rutas: un backend que emita el header y olvide exponerlo deja la trazabilidad visible en Network y muda en el código. Tu binario de Go tendrá que garantizarlo por su cuenta, y `be01` lo comprueba.

**`C-06` · La única excepción negociada del track, con nombre y apellido.** El frontend no hace login con `POST /login`: hace `GET /users?email=…&password=…`. Honrarlo al pie de la letra obligaría al backend real a aceptar contraseñas en la query string para siempre, que es indefendible y además hace inauditable el `be04` que enseña `bcrypt`. Se negocia entonces la excepción, y se registra acotada:

> 🧭 **Excepción `C-06`.** En `be04` se modifica **un solo archivo del frontend**: `src/api/authService.js`, para que llame a `POST /login` con las credenciales en el cuerpo. No se toca `apiClient.js`, ni sus dos interceptores, ni `authSlice.js`, ni ningún componente. El campo `token` de la respuesta conserva su nombre y su forma de string opaca, de modo que el `Bearer` del interceptor sigue funcionando sin enterarse de que ahora es un JWT firmado.

No es una licencia general: es una excepción con archivo, fase y límite. Y además estaba prevista: la Fase 2 dice que, cuando haya un `POST /login` real, se cambia **ese** archivo y nada más. El contrato solo cobra una promesa que el track base ya había hecho. A partir de `be04`, el comando de verificación de la sección 2 lleva una exclusión más, y una sola:

```bash
git diff pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js'
```

**`C-07` · Lo que el servidor cree sin comprobar.** Dos rutas propias del mock aceptan lo que llega con una confianza que el contrato tiene que dejar escrita. La primera es el envío: el mock comprueba si el caso ya se compensó, **espera** a que el juego entregue el premio y recién después anota. *Medido:* dos envíos del mismo caso para el mismo jugador, lanzados a la vez, dan `201` y `201` y dejan dos registros; el `409` solo aparece cuando el segundo llega después. Es la mitad del servidor del incidente 11 del track base, y se paga en `be05` con una restricción de unicidad. La segunda es la conciliación: el navegador calcula los conteos, el chi-cuadrado y el cruce de compras, y `POST /wheels/:id/reconciliation` **guarda el cuerpo tal como llega**. *Medido:* una conciliación con `"counts": [1, 1, 1]` sobre la rueda de 10.000 giros se guarda con `201`. El contrato obliga a aceptar ese cuerpo; recalcularlo del lado del servidor es crecimiento, y es lo que hace `be07`.

### 5.5 El smoke test: `server/smoke.sh`

El checklist ejecutable. Hoy pasa contra el mock; en `be03` tiene que pasar, idéntico, contra tu binario. Que sea `bash` y `curl` y no un framework de pruebas es deliberado: `be08` traerá la suite de contrato en Go, pero este script tiene que poder correrlo cualquiera, en cualquier máquina, sin compilar nada. Y **no modifica datos**: las tres verificaciones que escriben están armadas para que el servidor las rechace (`409`, `422` y `400`), así que se puede correr cien veces seguidas.

```bash
#!/usr/bin/env bash
# server/smoke.sh — checklist de contrato del puerto 3001.
# Corre igual contra el mock (hasta be02) y contra el binario de Go
# (desde be03). Si deja de pasar, el reemplazo rompió el contrato.
#
# Uso: ./server/smoke.sh            (BASE_URL=http://localhost:3011 ./server/smoke.sh para otro puerto)
# Requisitos: bash, curl y jq. El caos DEBE estar apagado (CHAOS_LEVEL=off).
# No modifica datos: cada verificación que escribe está hecha para que el servidor la rechace.

set -u
BASE="${BASE_URL:-http://localhost:3001}"
ORIGIN="http://localhost:3000"
TMP="$(mktemp)"
FAILED=0

# Compara lo esperado contra lo obtenido y lleva la cuenta.
check() {
  local label="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    printf '  ✅ %s\n' "$label"
  else
    printf '  ❌ %s — esperaba [%s], obtuve [%s]\n' "$label" "$expected" "$actual"
    FAILED=$((FAILED + 1))
  fi
}

echo "== Contrato del 3001 ($BASE) =="

# 1. Login: array con un elemento, y el token presente.
LOGIN=$(curl -s "$BASE/users?email=ibatista@esclusa.test&password=esclusa123")
check "GET /users con credenciales válidas devuelve 1 usuario" "1" "$(echo "$LOGIN" | jq 'length')"
check "el usuario trae el campo token" "true" "$(echo "$LOGIN" | jq '.[0] | has("token")')"

# 2. Credenciales inválidas: array VACÍO con 200. Nunca 401.
check "credenciales inválidas devuelven 200 con array vacío" "200-0" \
  "$(curl -s -o "$TMP" -w '%{http_code}' "$BASE/users?email=nadie@esclusa.test&password=x")-$(jq 'length' "$TMP")"

# 3. Las ruedas con sus segmentos (_embed): id numérico, closesAt con offset, pesos enteros, slug de texto.
WHEELS=$(curl -s "$BASE/wheels?_embed=segments")
check "wheel.id es número" "number" "$(echo "$WHEELS" | jq -r '.[0].id | type')"
check "wheel.closesAt trae offset" "true" \
  "$(echo "$WHEELS" | jq -r '.[0].closesAt | test("[+-][0-9]{2}:[0-9]{2}$")')"
check "_embed trae los segmentos" "array" "$(echo "$WHEELS" | jq -r '.[0].segments | type')"
check "weightBp es número y segmentId es texto" "number-string" \
  "$(echo "$WHEELS" | jq -r '.[0].segments[0] | "\(.weightBp | type)-\(.segmentId | type)"')"

# 4. C-04: el 404 automático, con cuerpo vacío ({})...
check "GET /wheels/9999 devuelve 404 con {}" "404-{}" \
  "$(curl -s -o "$TMP" -w '%{http_code}' "$BASE/wheels/9999")-$(jq -c . "$TMP")"
# ...y el 404 de una ruta propia, con { error }.
check "PUT /wheels/9999 devuelve 404 con error" "404-true" \
  "$(curl -s -o "$TMP" -w '%{http_code}' -X PUT -H 'Content-Type: application/json' -d '{"segments":[]}' "$BASE/wheels/9999")-$(jq 'has("error")' "$TMP")"

# 5. Una rueda en vivo no cambia sus pesos: 409 con { error }, y no se escribe nada.
LIVE=$(echo "$WHEELS" | jq -c 'map(select(.status == "live"))[0] | .segments |= map({segmentId, prizeType, weightBp})
                                | .segments[0].weightBp -= 1 | .segments[1].weightBp += 1')
check "cambiar pesos de una rueda live devuelve 409 con error" "409-true" \
  "$(echo "$LIVE" | curl -s -o "$TMP" -w '%{http_code}' -X PUT -H 'Content-Type: application/json' -d @- "$BASE/wheels/$(echo "$LIVE" | jq .id)")-$(jq 'has("error")' "$TMP")"

# 6. Jugadores: sin filtro (lo que pide el asistente al abrir) y con name_like.
check "GET /players sin filtro devuelve un array" "array" "$(curl -s "$BASE/players" | jq -r 'type')"
check "GET /players?name_like=ju encuentra a Juan P." "true" \
  "$(curl -s "$BASE/players?name_like=ju" | jq 'map(.name) | index("Juan P.") != null')"

# 7. Envío sin motivo: 422 con { error }. El servidor lo rechaza antes de escribir.
check "un envío sin motivo devuelve 422 con error" "422-true" \
  "$(curl -s -o "$TMP" -w '%{http_code}' -X POST -H 'Content-Type: application/json' \
     -d '{"grantId":"g-smoke","caseId":"C-SMOKE","prize":"vidas-5"}' "$BASE/players/42/grants")-$(jq 'has("error")' "$TMP")"

# 8. La bitácora de una rueda, filtrada por wheelId, sin paginar.
check "GET /spinLog?wheelId=4 devuelve filas de esa rueda" "true" \
  "$(curl -s "$BASE/spinLog?wheelId=4" | jq 'length > 0 and all(.[]; .wheelId == 4 and (.landedSegment | type) == "string")')"

# 9. C-01: el contrato del juego. Sin clave de idempotencia, 400; el giro no se intenta.
check "un giro sin idempotencyKey devuelve 400" "400" \
  "$(curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' -d '{}' "$BASE/players/42/spins")"

# 10. Trazabilidad: el header en la respuesta...
check "X-Request-Id presente en la respuesta" "1" \
  "$(curl -s -D - -o /dev/null "$BASE/wheels" | grep -ci '^x-request-id:')"

# 11. ...y C-05: que el navegador pueda LEERLO. curl lo ve siempre; el navegador, solo si
#     la respuesta real (no el preflight) lo declara en Access-Control-Expose-Headers.
check "X-Request-Id expuesto a CORS (C-05)" "1" \
  "$(curl -s -D - -o /dev/null "$BASE/wheels" -H "Origin: $ORIGIN" \
     | grep -ci '^access-control-expose-headers:.*x-request-id')"

rm -f "$TMP"
echo
if [ "$FAILED" -eq 0 ]; then
  echo "Contrato OK."
else
  echo "Contrato ROTO: $FAILED verificación(es) fallida(s)."
fi
exit "$FAILED"
```

```bash
chmod +x server/smoke.sh
./server/smoke.sh
```

Contra el mock con el caos apagado, las diecisiete verificaciones pasan (corrida del 18/10/2026). Pega esa salida en `CONTRACT.md` como **línea base**, con la fecha: es lo que te va a dejar afirmar en `be03` que el reemplazo conserva el contrato, en vez de suponerlo.

> ⚠️ **Lo que el smoke no ve.** Que pase entero no dice que el contrato esté completo: los defectos de `C-01`, `C-03` y `C-07` no tienen verificación, porque el contrato obliga a la forma y no a los defectos, y una verificación que exigiera el defecto le impediría a `be05` pagarlo. Esos tres viven en `CONTRACT.md` con su comando de reproducción, no en el smoke.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Auditar leyendo el código en vez de midiendo.** Síntoma: el contrato queda prolijo, coherente y le faltan dos rutas; `be03` explota en la primera pantalla que nadie recorrió. Causa: `grep` encuentra lo que el frontend pretende pedir, no lo que pide. Fix mínimo: recorrer la consola entera con Preserve log y reconciliar las dos listas. La reconciliación **es** el trabajo de esta fase: las diferencias son los hallazgos.

**2. Auditar con el caos encendido.** Síntoma: en el contrato aparecen un `503` sin causa, un `401` en una ruta pública y una respuesta que no es JSON. Causa: el middleware de la Fase 3 inyectando fallos. Fix: `CHAOS_LEVEL=off`, capturar de nuevo, y anotar en el documento que el caos es andamiaje y no contrato, porque esa distinción se te va a olvidar en `be01`, que es donde toca reimplementarlo.

**3. Confundir "el header está" con "puedo leerlo".** Síntoma: en Network se ve `X-Request-Id` perfecto, y en el código `response.headers["x-request-id"]` es `undefined`. Causa: la respuesta no lo declara en `Access-Control-Expose-Headers`. Fix mínimo: declararlo en la respuesta real; ponerlo en el preflight no sirve de nada. Es el error de esta lista que más caro sale, porque el síntoma —trazabilidad que "a veces no funciona"— manda a la gente a leer el interceptor durante horas.

**4. Olvidar al consumidor que no está en el repo.** Síntoma: el contrato tiene todas las rutas de la consola, `be03` las implementa, la consola anda perfecto y esa noche el juego no puede girar. Causa: el inventario salió solo del navegador. Fix: preguntar quién más le habla al servidor. En este sistema la respuesta está en la historia (§7) y en `scripts/traffic.js`; en uno real, en los logs de acceso del servidor, agrupados por `User-Agent`.

**5. "Mientras estamos, lo dejamos consistente".** Síntoma: el contrato dice que todos los `404` devuelven `{ error }` y que la bitácora se pagina "porque es más sano". Causa: el instinto de arquitecto operando sobre un sistema que ya tiene clientes. Fix: separar en dos columnas lo que **es** de lo que **debería ser**, y mandar la segunda al régimen de crecimiento o al mapa de deuda. Cuál de las dos va al contrato no se discute: la primera.

### 🩻 Pieza forense de esta fase

**Convertir una captura en un contrato, y encontrar las cuatro diferencias.**

Esta es la pieza forense fundacional del track BE: en vez de perseguir un bug, persigues una **discrepancia entre dos descripciones del mismo sistema**. Es la misma habilidad, aplicada al momento en que todavía se puede prevenir el bug.

*Paso 1 — el inventario leído.* Sin abrir el navegador, saca la lista de llamadas del código, como lo haría cualquiera la primera vez:

```bash
grep -rn "apiClient\.\(get\|post\|put\|patch\|delete\)" src/ | grep -v "\.test\." | \
  sed 's/.*apiClient\.//' | sort -u
```

Guárdala en `server/evidence/inventario-leido.txt`.

*Paso 2 — el inventario medido.* El `jq` de la sección 5.2 sobre tu HAR, a `server/evidence/inventario-medido.txt`.

*Paso 3 — la diferencia.* Compáralos. Vas a encontrar, como mínimo, cuatro clases de discrepancia, y cada una enseña algo distinto:

- **Algo que el código pide y la captura no muestra** → una ruta que solo se ejecuta en un camino que no recorriste. **Vuelve y recórrelo**: es la ruta que `be03` va a romper.
- **Algo que la captura muestra y el `grep` no ve** → `GET /players` y `POST /players/:id/grants`. Los dos salen de los epics de la Fase 6, que reciben el cliente por `createEpicMiddleware({ dependencies })` y lo llaman `api`, no `apiClient`. Y en la misma clase cae el `OPTIONS` del preflight, que no sale de ninguna línea del código y es contrato: si tu backend no lo contesta, no hay consola.
- **La misma ruta con dos respuestas distintas** → el `200` y el `304` de una lectura repetida, si te olvidaste de *Disable cache*. No es contrato: es la caché del navegador hablando con el `ETag` de json-server.
- **Algo que ni la captura ni el `grep` muestran** → `POST /players/:id/spins`, el consumidor que no está en el repo (`C-01`).

Corre el `grep` otra vez, ahora buscando los tres nombres del cliente HTTP, y comprueba que la segunda clase desaparece:

```bash
grep -rnE "\b(apiClient|api|apiStore)\.(get|post|put|patch|delete)\(" src/ | grep -v "\.test\." | \
  sed -E 's/.*\b(apiClient|api|apiStore)\./\1./' | sort -u
```

La lección no es "usa el `grep` bueno": es que **el `grep` correcto solo lo escribe quien ya sabe qué buscar**, y eso lo sabes después de medir, no antes.

*Paso 4 — el cierre del círculo.* Toma el `X-Request-Id` de cualquier respuesta en Network, búscalo en la consola del navegador (el `console.debug` del interceptor) y comprueba que aparece. Guarda las dos capturas: en `be01` vas a repetir este mismo recorrido, y ahí el id además va a aparecer en el log del backend con su ruta y su tiempo. **Ese es el círculo completo que el track promete cerrar**, y esta es la mitad que ya puedes medir hoy.

*Rompe a propósito.* Detén `npm run mock:api` y recorre la consola con el `3001` caído. Anota, por pantalla, qué ve el operador: dónde hay un mensaje legible, dónde un spinner infinito y dónde una pantalla en blanco. Ese inventario de síntomas es tu línea base: cuando en `be03` apagues el mock de verdad y algo se comporte así, sabrás distinguir "el backend nuevo tiene un bug" de "así se veía esto desde siempre".

---

> 📓🔥 De esta fase sale el incidente **be-02** de `cuaderno-incidentes-be.md`, de contrato: un dato que falta y que no perdió nadie, porque uno de los dos escritores nunca lo pidió (`C-03`).

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–7)**

1. Crea el tag `pre-backend-go` y verifica con `git diff pre-backend-go..HEAD -- . ':!server'` que devuelve vacío.
2. Levanta los mocks con `CHAOS_LEVEL=off` y confirma con `curl` que `GET /wheels?_embed=segments` responde `200` con un array de ruedas, cada una con su array `segments`.
3. Captura el HAR del recorrido completo y guárdalo en `server/evidence/recorrido.har`.
4. Con `jq`, saca del HAR la lista de rutas únicas del `3001` y cuenta cuántas son.
5. Separa en dos listas las peticiones al `3001` y las peticiones al `3002`. Explica en dos líneas por qué las segundas no entran al contrato.
6. Verifica con `curl -D -` que el `X-Request-Id` viene en la respuesta de `GET /wheels`, y con `-H 'Origin: http://localhost:3000'` que también viene `Access-Control-Expose-Headers`.
7. Ejecuta `server/smoke.sh` contra el mock y pega su salida en `CONTRACT.md` como línea base, con la fecha.

**🟡 Intermedio (8–16)**

8. Escribe la tabla del régimen estricto de ruedas y segmentos con sus cinco peticiones, citando para cada una el archivo del frontend que la consume.
9. Documenta los tipos exactos de los campos de una rueda y de un segmento, y marca los tres cuya alteración rompería una fase concreta del track base.
10. Comprueba que `GET /users` con credenciales inválidas devuelve `200` con `[]` y explica qué pasaría en la consola si devolviera `401`. Sé específico: nombra el interceptor y el efecto.
11. **Diagnóstico.** Encuentra en el HAR las dos peticiones que el `grep` de `apiClient` no ve. Determina desde qué epic salió cada una y por qué ese epic no nombra `apiClient`.
12. **Diagnóstico.** Reproduce `C-03`: haz dos giros con `curl`, mira cómo bajó el stock de la Esclusa de Oro y explica por qué `GET /spinLog?wheelId=1` no los devuelve.
13. Escribe el régimen de crecimiento completo, y para cada entrada justifica en una línea por qué agregarla no rompe a nadie.
14. Agrega al `smoke.sh` una verificación de que `POST /wheels` con pesos que suman 9.999 devuelve `422` con `error`, sin crear nada. Comprueba después que no quedó ninguna rueda nueva.
15. **Diagnóstico.** Detén el `3002` y determina, sin leer código, qué pantallas dependen de él. Compara tu respuesta con las Fases 7 y 8.
16. Toma un `X-Request-Id` de Network y búscalo en la consola. Documenta el resultado como evidencia de `C-05`.

**🟠 Difícil (17–25)**

17. **Diagnóstico.** Reconcilia el inventario leído con el medido y clasifica cada diferencia en una de las cuatro clases de la pieza forense. Justifica las que no encajen.
18. Demuestra la rareza de `C-02`: pide `GET /spinLog?wheelId=4&_page=1&_limit=5` desde la consola del navegador con `fetch` y muestra que el `X-Request-Id` está en Network y no se puede leer. Explica qué header lo pisó y por qué.
19. **Diagnóstico.** Provoca con `CHAOS_LEVEL=high` los cuatro tipos de fallo del caos (`401`, `503`, timeout, malformado) y clasifica cada uno como contrato o andamiaje. Argumenta el caso del `401`, que es el discutible.
20. Escribe la política de compatibilidad del backend en cinco reglas operativas del tipo "agregar X es seguro, quitar Y no lo es", cada una con el consumidor concreto que la justifica (el juego cuenta).
21. **Diagnóstico.** Reproduce la mitad de `C-07` que toca a los envíos: dos `POST /players/42/grants` del mismo caso, a la vez. Mide cuántos registros quedan y explica por qué el `409` no aparece. Relaciónalo con el incidente 11 del track base.
22. Diseña la sección de `CONTRACT.md` que documenta el `404` doble (`C-04`) de forma que un implementador de `be03` no pueda uniformarlo por descuido.
23. **Diagnóstico.** Recorre la consola con el `3001` caído y levanta el inventario de síntomas por pantalla. Marca cuáles son fallos silenciosos.
24. Mide el tamaño de `GET /spinLog?wheelId=4` en bytes y en tiempo con `curl -w`. Siembra la Semana del Canal con `--event` (Fase 9) y mide `GET /spinLog` de esa rueda. Escribe en `CONTRACT.md` qué significa para el backend que esa respuesta sea régimen estricto.
25. **Diagnóstico.** Encuentra en el HAR alguna petición que ningún `grep` del código habría revelado. Explica de dónde salió.

**🔴 Muy difícil (26–30)**

26. Escribe el contrato del `POST /_chaos` que `be01` deberá implementar: cuerpo, respuesta, precedencia contra `CHAOS_LEVEL` y comportamiento ante un nivel inválido. Justifica cada decisión sabiendo que no hay forma previa que honrar.
27. **Diagnóstico.** Argumenta si los defectos de `C-01` (dos premios por clave, stock descontado después) deben entrar al régimen estricto. Defiende la postura contraria a la tuya en cuatro líneas y después decide, por escrito, con qué criterio se resuelve el empate.
28. Toma la excepción `C-06` y escribe su alternativa: el contrato de un backend que honre `GET /users?email=&password=` con `bcrypt` y JWT sin tocar el frontend. Enumera qué se pierde pedagógicamente y qué riesgo real queda vivo. Después justifica por qué el track eligió la excepción.
29. **Diagnóstico + prevención.** Diseña la prueba de contrato mínima que habría detectado `C-03` el día que se escribió el giro de 2019, y ubica en qué capa tendría que haber corrido para ser útil, sabiendo que el escritor y el lector de la fila los escribieron equipos distintos con años de diferencia.
30. Escribe el post-mortem de `C-07` en su mitad de la conciliación como si hubiera costado una auditoría fallida: síntoma, evidencia, causa raíz, corrección, prueba de regresión y prevención. Sin culpabilización, según los ocho puntos del post-mortem de `cuaderno-incidentes.md`.

**🔥 Opcionales**

- 🔥 Genera el contrato en OpenAPI 3.0 a partir del HAR con la herramienta que prefieras, compáralo con tu `CONTRACT.md` y anota qué captura la máquina y qué solo capturaste tú (el juego, para empezar).
- 🔥 Escribe un script que valide el HAR contra `CONTRACT.md` y lo haga fallar si aparece una ruta no inventariada. Es el germen de la suite de contrato de `be08`.
- 🔥 Audita el `3002` con el mismo rigor y escribe su contrato aparte, para tener por escrito la frontera que el track promete no cruzar.

---

## 📚 8. Referencias

**Documentación oficial**
- https://github.com/typicode/json-server/tree/v0.16.3 — el dialecto del mock. Ojo: el README de la rama principal documenta versiones posteriores; fija la 0.16.3, que es la del curso.
- https://developer.mozilla.org/es/docs/Web/HTTP/CORS — CORS en general.
- https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Expose-Headers — el header exacto de `C-05`.
- https://developer.chrome.com/docs/devtools/network/ — Network, Preserve log y exportación de HAR.
- https://w3c.github.io/web-performance/specs/HAR/Overview.html — el formato HAR. Es un borrador que nunca llegó a recomendación, y aun así es el estándar de facto: vale la pena saberlo antes de construir herramientas sobre él.
- https://www.rfc-editor.org/rfc/rfc9110 — semántica de HTTP. Para esta fase: §15.5.5 (`404`), §15.5.10 (`409`), §15.5.21 (`422`) y §15.5.2 (`401`).
- https://www.rfc-editor.org/rfc/rfc3339 — el formato de `closesAt`. Vuelve en `be06`.

**Libros**
- *Building Microservices* (Sam Newman) — el capítulo de integración y versionado de contratos. Ignora la parte de microservicios: lo que sirve acá es su tratamiento de qué rompe a un consumidor.
- *Release It!* (Michael Nygard) — sobre integraciones que fallan de formas que nadie previó. El inventario de síntomas del ejercicio 23 es su idea.

**Video / apoyo**
- Busca en YouTube "Chrome DevTools Network panel deep dive" y "HAR file analysis": hay material bueno y corto de los últimos años. Los detalles de la interfaz cambian entre versiones de Chrome; los conceptos no.

**Orden de lectura sugerido:** el README de `json-server` 0.16.3 para reconocer el dialecto → la página de `Access-Control-Expose-Headers`, que es corta y explica `C-05` → y recién entonces al navegador, porque el resto se aprende midiendo.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido: verifícalos. Las referencias a libros y videos son de memoria y pueden ser inexactas; confirma título, autor y edición antes de citarlas en un documento tuyo. Y cuando un enlace cubra una versión distinta a la del curso, el que manda es `00-decisiones-y-versiones.md`.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Tienes lo único que hacía falta para empezar a escribir Go con seguridad: la lista, medida y no adivinada, de todo lo que la consola y el juego le exigen al puerto `3001`. Tienes siete hallazgos que ningún `grep` habría dado, una excepción negociada y acotada a un archivo, y un checklist ejecutable que hoy pasa entero contra el mock, lo que convierte cada verificación en una promesa que tu binario tiene que cumplir.

`be01` levanta el andamiaje: `go.mod`, `net/http` con `gorilla/mux`, la cadena de middlewares con el `X-Request-Id` viajando por `context.Context`, el apagado ordenado, `GET /health` y el caos reimplementado con doble control. Todavía sin base de datos y sin tocar el contrato de negocio. Pero al terminarla vas a poder cerrar el círculo que hoy quedó a medias: copiar un `X-Request-Id` de la consola del navegador y encontrarlo, con nombre propio, en el log del servidor.

> **La señal de que quedó bien:** *"puedo decir qué se rompe si cambio cualquier línea de este contrato, y puedo demostrarlo señalando el archivo, o el cliente, que lo consume."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be00-el-contrato-auditoria-del-mock -m "be00 cerrada: \
> tag pre-backend-go creado; HAR del recorrido completo capturado con caos apagado; \
> server/CONTRACT.md con régimen estricto y de crecimiento, la consola y el juego; \
> hallazgos C-01 a C-07 registrados con evidencia; \
> excepción C-06 acotada a src/api/authService.js; \
> server/smoke.sh ejecutable, con su línea base contra el mock"
> ```
>
> Los commits de la fase llevan su prefijo (`be00: …`) y los de ejercicio su número (`be00 ej17: …`). Si un ejercicio merece su propio marcador va en `ej/be00/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` / `-fix`, con el ID que le reserva `cuaderno-incidentes-be.md`. Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- ✅ **Resuelto: las rutas nuevas que introduce esta fase** —`server/CONTRACT.md`, `server/smoke.sh` y el directorio `server/evidence/`— quedaron fijadas como rutas canónicas del backend, y `be01` §5.1 las incluye en el árbol de `server/`.
- **`C-06` afecta a `be04` y al comando de verificación de todas las fases posteriores.** Desde `be04`, el `git diff` de la sección 2 lleva la exclusión `':!src/api/authService.js'`. Que ninguna fase entre `be04` y `be09` lo olvide.
- **`C-05` es criterio de aceptación de `be01`**: la verificación 11 de `smoke.sh` tiene que pasar contra el binario en el `3011`, y la fase lo pide en su checklist. De ahí sale el incidente `be-01`.
- **`C-01` y `C-03` se pagan en `be05`**, cuando el giro sea una sola operación y escriba la fila completa de la bitácora; **`C-07` en `be05`** (la unicidad del caso del envío) **y en `be07`** (la conciliación recalculada en el servidor). Cada una de esas fases debe citarlos por su código.
- **`C-04` es una trampa para `be03`.** Conviene que `be03` lo mencione explícitamente en sus errores comunes: uniformar el `404` es la mejora razonable que rompe `toReadableError`.
- **`GET /spinLog` sin paginar es régimen estricto con cifra (10.000 y 180.000 filas).** `be03` lo sirve entero; `bea-09` lo registra como deuda del track.
- **Reserva para el cuaderno de incidentes:** `be-02` — *"el premio entregado no tiene rueda"* (categoría 🔥 contrato, dificultad 🟠), que es `C-03` visto desde el tablero: las Esclusas de Oro de la noche del evento no aparecen en ninguna cuenta. El `be-01` —la trazabilidad que se ve y no se lee— pasa a `be01`, donde el binario de Go puede olvidar lo que el mock ya hace.
- **Para `bea-07`:** el recorrido del `X-Request-Id` que acá queda a medias es su columna vertebral. El apéndice debería abrir con las dos capturas de la pieza forense de esta fase.
