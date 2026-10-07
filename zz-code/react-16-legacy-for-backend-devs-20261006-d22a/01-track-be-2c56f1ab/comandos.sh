# Comandos Bash de la sesión 2c56f1ab-75fc-4f7e-a091-e4bef521ae0b, en orden. Una bitácora, no un script: no se corre entera.

# --- 2026-09-08T03:34:36 · List prompts dir and count lines
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs && ls -la prompts/ && wc -l *.md prompts/*.md

# --- 2026-09-08T03:34:38 · Read README and project instructions
cat README.md && echo "=====INSTRUCCIONES=====" && cat prompts/instrucciones-del-proyecto.md

# --- 2026-09-08T03:35:45 · Read phase template
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs/prompts && cat plantilla-de-fase.md

# --- 2026-09-08T03:35:49 · Grep section headings
grep -n '^## ' decisiones-y-versiones.md guia-de-estilo-y-convenciones.md diccionario-codigo-ingles.md propuesta-fases-backend.md

# --- 2026-09-08T03:35:52 · Read D14-D23
sed -n '380,700p' decisiones-y-versiones.md

# --- 2026-09-08T03:35:54 · Read style §16 and dict §7bis
sed -n '839,911p' guia-de-estilo-y-convenciones.md; echo "=====DICC 7bis====="; sed -n '356,441p' diccionario-codigo-ingles.md

# --- 2026-09-08T03:35:57 · Read deudas, reglas, horas, be00-be01
sed -n '56,150p;206,300p' propuesta-fases-backend.md

# --- 2026-09-08T03:36:08 · Grep endpoints in base phases
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs && grep -n -E "(GET|POST|PATCH|PUT|DELETE) /|_page|_limit|_sort|_order|X-Total-Count|X-Request-Id|_chaos|3001|3002" 0*.md | head -120

# --- 2026-09-08T03:36:12 · Read fase 3 implementation
sed -n '150,500p' 03-mock-api-express-caos.md

# --- 2026-09-08T03:36:16 · Read fase 2 auth impl
sed -n '100,260p' 02-autenticacion-minima.md; echo ====; sed -n '520,560p' 02-autenticacion-minima.md

# --- 2026-09-08T03:36:30 · Grep api calls in phases 4-9
grep -n -E "_page|_limit|_sort|_order|params:|apiClient\.(get|post|patch|put|delete)|X-Total-Count" 0[4589]*.md 06*.md 07*.md | head -60

# --- 2026-09-08T03:36:43 · Check number GET and participants
sed -n '270,290p' 06-redux-observable-a-fondo.md; echo "=== participants ==="; grep -n "participants" 0[45678]*.md | head -20

# --- 2026-09-08T03:36:55 · Read propuesta sections 8-12
sed -n '422,560p' prompts/propuesta-fases-backend.md

# --- 2026-09-08T03:37:01 · Check cuaderno and CLAUDE for BE
grep -n -i "be0\|backend\|BE " cuaderno-incidentes.md | head -20; echo "=== CLAUDE ==="; grep -n "beNN\|be-a" ../CLAUDE.md

# --- 2026-09-08T03:37:03 · Read cuaderno BE reservation
sed -n '120,160p' cuaderno-incidentes.md

# --- 2026-09-08T03:44:45 · 
cat > be00-el-contrato-auditoria-del-mock.md <<'FIN_DEL_ARCHIVO'
# 📜 Fase be00 — El contrato: auditoría del mock

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Fase be00 de be09 · **6 horas**
> Depende de: Fase 8 del track base · Habilita: be01 — Go 1.19 y la forma del monolito

---

## 🎯 1. Propósito

Antes de escribir un backend que reemplace al mock hay que saber **qué está
obligado a hacer**, y esa obligación no es la que dice el código del mock: es la
que ejerce el frontend. Esta fase levanta ese inventario midiendo tráfico real
—pestaña Network, recorrido completo por la aplicación— y lo deja por escrito
como un contrato verificable, con su checklist de smoke test.

Es la única fase del track que no escribe una línea de Go. También es la única
cuyo error se propaga a las nueve siguientes: si el contrato queda mal auditado,
`be03` falla, la aplicación se rompe y el alumno pierde la fe en el track. Por
eso se mide.

> 🧭 **La regla que gobierna el track entero, y que esta fase deja por escrito.**
> El frontend heredado **no se toca**. El backend se adapta al contrato
> existente, nunca al revés. Un backend "mejor diseñado" que obliga a cambiar el
> cliente es, para este curso, un backend roto.

---

## ✅ 2. Qué queda listo al terminar

- [ ] El estado actual del frontend queda marcado con el tag `pre-backend-go`,
      que es la referencia contra la que todas las fases BE demuestran que no lo
      tocaron.
- [ ] Existe una captura HAR de un recorrido completo por la aplicación
      (`server/evidence/recorrido.har`), tomada con el caos apagado.
- [ ] Existe `server/CONTRACT.md` con el inventario de **todo** lo que el
      frontend consume del `3001`: método, ruta, entrada, salida, códigos de
      error y rarezas.
- [ ] El contrato separa explícitamente **régimen estricto** (lo que no puede
      cambiar) de **régimen de crecimiento** (lo que el backend puede añadir sin
      romper nada), y cada entrada del estricto cita la fase y el archivo del
      frontend que la consume.
- [ ] Los seis hallazgos de la auditoría (`C-01` a `C-06`) están registrados con
      su evidencia, incluida la **única excepción negociada** del track.
- [ ] Existe `server/smoke.sh`: el checklist de smoke test ejecutable con `curl`,
      que se corre al final de `be03` y de cada fase posterior, y que hoy pasa
      entero contra el mock.
- [ ] `git diff pre-backend-go..HEAD -- . ':!server'` no devuelve nada.

---

## 🚫 3. Qué queda fuera por ahora

- **Go, en cualquier cantidad.** El primer `go.mod` es de `be01`.
- **El esquema de base de datos.** El contrato describe formas JSON, no tablas.
  Traducirlas a `raffles`, `raffle_numbers` y compañía es trabajo de `be02`.
- **El mock de lotería del `3002`.** Se audita para saber dónde está la
  frontera, pero **no se reescribe nunca**: es un proveedor externo y esa
  frontera es contenido, no descuido.
- **Las métricas del dashboard.** La Fase 9 queda fuera del contrato
  obligatorio; un `GET /stats` es pendiente 🔥 de `be09` y ninguna fase depende
  de él.

---

## 🧠 4. Conceptos mínimos

### Un contrato es lo que se observa, no lo que se documentó

La palabra "contrato" está gastada, así que vale la pena afilarla para lo que
vamos a hacer. Acá un contrato es **el conjunto de comportamientos observables
de los que depende un cliente ya escrito**. No es lo que el servidor pretende
ofrecer, no es lo que su README dice, y —esto es lo que más cuesta aceptar— no
es lo que su código sugiere leyendo los handlers. Es lo que pasaría si mañana lo
cambias: si el cliente se rompe, era contrato.

De ahí se sigue algo incómodo. El mock de la Fase 3 tiene rutas que nadie llama:
no son contrato. Y el frontend llama al menos una ruta que el mock nunca
implementó: **eso sí es contrato**, aunque hoy responda `404`. El contrato lo
define el consumidor, no el proveedor.

### Por qué se mide con Network y no se lee el código

Podrías reconstruir esta lista con `grep apiClient src/`. Sería más rápido y
estaría mal por tres razones que vas a comprobar tú mismo en la pieza forense.

La primera es que el código miente por omisión: los interceptores agregan
headers que no aparecen en ninguna llamada, y `axios` agrega otros por su cuenta
(`Content-Type`, el `OPTIONS` de preflight) que ningún `grep` te va a mostrar.
La segunda es que las rutas se arman con plantillas —`` `/raffles/${raffleId}/numbers` ``—
y leerlas no te dice qué valores viajan de verdad ni con qué tipo. La tercera es
la que importa: **leyendo el código encuentras lo que el frontend pretende
pedir; midiendo encuentras lo que pide**. Cuando las dos listas no coinciden, la
diferencia es exactamente el bug que `be03` te va a explotar en la cara.

### Régimen estricto y régimen de crecimiento

Un contrato con una sola categoría no sirve: o te ata las manos o no te ata
nada. Este se parte en dos.

El **régimen estricto** es lo que el frontend consume hoy, medido. Cambiar
cualquier cosa de acá rompe la aplicación: el nombre de un campo, el tipo de un
valor, un código de estado, la forma de un cuerpo de error. No se negocia, no se
mejora, no se "moderniza". Se reimplementa tal cual, y sí, a veces es aburrido:
reimplementar el dialecto ajeno es *aburrido y correcto*.

El **régimen de crecimiento** es todo lo demás: lo que el backend puede añadir
sin que ningún cliente actual se entere. Endpoints nuevos, campos nuevos en una
respuesta (que el frontend ignora), headers nuevos, validaciones **más
permisivas**. La regla operativa cabe en una línea: agregar es crecimiento,
quitar y renombrar es ruptura. Un campo nuevo en el JSON de una rifa es
inofensivo porque `raffleSlice` lo ignora; renombrar `closesAt` a `closing_time`
mata la Fase 7.

### El dialecto de json-server

`json-server` no es un servidor genérico: tiene convenciones propias y el
frontend puede haberse acostumbrado a ellas sin que nadie lo decidiera. Las que
hay que buscar en la captura son el filtrado por query (`?email=…`), la
paginación (`_page`, `_limit`) con su header `X-Total-Count`, el ordenamiento
(`_sort`, `_order`), la búsqueda de texto (`q`), el `404` **con cuerpo vacío**
cuando un recurso no existe, y el `POST` que devuelve el recurso creado
completo, con el `id` que asignó el servidor.

Ojo con el sesgo acá: la lista de arriba es lo que **hay que buscar**, no lo que
**hay que encontrar**. Uno de los hallazgos de esta fase es justamente que
buena parte de ese dialecto no la consume nadie.

### El smoke test de contrato

El entregable que más vas a usar no es el documento: es `server/smoke.sh`. Un
smoke test de contrato es una secuencia corta de peticiones que ejercita el
régimen estricto de punta a punta y **falla ruidosamente** ante cualquier
desviación. No prueba lógica de negocio ni casos borde —eso es `be08`—; prueba
que el que contesta al otro lado sigue hablando el mismo idioma.

Su propiedad importante es que hoy tiene que pasar **contra el mock**. Un
checklist escrito contra un servidor que todavía no existe es una lista de
deseos; escrito contra el que sí existe, es un criterio de aceptación. En `be03`
lo vas a correr sin cambiar una línea contra tu binario de Go, y ahí sabrás si
el reemplazo salió bien: pasa o no pasa, y no es opinable.

---

## 💻 5. Implementación y código comentado

No hay código de aplicación en esta fase. Hay evidencia, un documento y un
script — y los tres son entregables verificables.

### 5.1 Preparar el terreno: marcar el antes

Antes de nada, marca dónde estaba el frontend. Este tag es la referencia contra
la que cada fase BE demuestra que cumplió la regla.

```bash
# Con la Fase 8 del track base cerrada y git status limpio:
git tag -a pre-backend-go -m "Frontend congelado: estado previo al track BE. \
Toda fase beNN demuestra que no lo tocó con: git diff pre-backend-go..HEAD -- . ':!server'"

mkdir -p server/evidence
```

> 🧭 **La regla, hecha comando.** `git diff pre-backend-go..HEAD -- . ':!server'`
> tiene que devolver vacío al cerrar cualquier fase del track. El día que
> devuelva algo, o encontraste la excepción negociada (`C-06`), o la fase está
> mal diseñada.

### 5.2 La captura: un recorrido completo con el caos apagado

El caos de la Fase 3 inyecta latencia, `401`, `500`, timeouts y respuestas
malformadas. **Nada de eso es contrato**: es andamiaje del curso. Auditar con
caos encendido es la forma más rápida de meter un `500` aleatorio en el
inventario y pasarte `be03` intentando reproducirlo.

```bash
# .env del mock — para la auditoría, y solo para la auditoría:
CHAOS_LEVEL=off
CHAOS_LOTTERY_LEVEL=off

npm run mock:all          # 3001 (CRUD + caos) y 3002 (lotería)
npm start                 # la app en el 3000
```

En DevTools → Network: activa **Preserve log**, activa **Disable cache**, y
recorre la aplicación entera sin saltarte nada. El recorrido no es opcional ni
aproximado, porque lo que no ejecutes no aparece en el contrato:

1. Login con `organizador@rifas.test`.
2. Listado de rifas; crear una rifa; editarla; borrar la que creaste.
3. Abrir el tablero de números de una rifa.
4. Reservar un número; dejar que expire la reserva.
5. Vender un número; intentar vender uno ya vendido (el `409`).
6. Escribir un número en el campo de validación y esperar el `debounce`.
7. Esperar el cierre de una rifa (o adelanta su `closesAt`) y dejar correr el
   polling de resultados hasta que llegue el ganador.
8. Liquidar la rifa resuelta.
9. Abrir el dashboard.
10. Logout.

Al terminar, clic derecho sobre la lista → **Save all as HAR with content** →
`server/evidence/recorrido.har`. Esa captura es la evidencia primaria de toda la
fase; el documento que sigue es su interpretación.

Para leer el HAR sin abrir DevTools de nuevo, cualquier `jq` sirve:

```bash
# Inventario crudo: método, estado y ruta, sin duplicados, ya ordenado.
jq -r '.log.entries[]
       | [.request.method, (.response.status|tostring), .request.url]
       | @tsv' server/evidence/recorrido.har \
  | sed 's#http://localhost:300[12]##' \
  | sort -u
```

> ⚠️ El HAR guarda los headers, y en tu captura viaja el `Authorization` con el
> token de la Fase 2. Es un token de mentira sobre datos de mentira, así que no
> hay incidente que reportar — pero el hábito de mirar qué contiene un HAR
> **antes** de adjuntarlo a un ticket vale para el resto de tu carrera. En
> producción, un HAR es material sensible.

### 5.3 El contrato: `server/CONTRACT.md`

Este es el documento que `be03` tiene que satisfacer. Va en inglés donde nombra
código —rutas, campos, headers— y en español donde explica, igual que todo el
curso. Lo que sigue es su contenido; escríbelo con **tu** captura al lado y
corrige cualquier discrepancia contra lo que tú mediste, que es lo que manda.

#### Régimen estricto — autenticación (Fase 2)

| Petición | Respuesta esperada |
|---|---|
| `GET /users?email=<email>&password=<password>` | `200` con un **array** de usuarios; array vacío si no hay coincidencia |

El frontend lee de cada elemento exactamente cuatro campos: `id`, `email`,
`name` y `token`. El campo `password` viaja en la respuesta y `authService` lo
descarta; que llegue o no llegue es indiferente para el cliente. Y hay una
sutileza que un backend "bien diseñado" arruinaría: **cero coincidencias es un
`200` con `[]`, no un `401`**. `authService.js` traduce el array vacío a
`throw new Error('Email o contraseña incorrectos')`; si el servidor contestara
`401`, el interceptor de respuesta lo tomaría por sesión caída y dispararía el
logout global en mitad del login.

#### Régimen estricto — rifas (Fase 4)

| Petición | Respuesta esperada |
|---|---|
| `GET /raffles` | `200` con array de rifas |
| `GET /raffles/:id` | `200` con la rifa; `404` con **cuerpo vacío** si no existe |
| `POST /raffles` | `201` con la rifa creada, **incluido el `id` que asignó el servidor** |
| `PUT /raffles/:id` | `200` con la rifa completa ya actualizada |
| `DELETE /raffles/:id` | `200` con `{}` |

La forma de una rifa, con los tipos exactos que el frontend asume:

```json
{
  "id": 1,
  "name": "Rifa fin de mes",
  "lotteryId": "boyaca",
  "closesAt": "2026-08-30T22:00:00-05:00",
  "numberPrice": 5000,
  "basePrize": 500000,
  "status": "open"
}
```

Tres detalles que parecen menores y no lo son. El `id` es **número**, no string:
`raffleSlice` lo compara con `===` contra el `id` que llega por la URL. El
`closesAt` es una cadena RFC 3339 **con offset**, no UTC con `Z`, y la Fase 7
depende de que el offset esté presente. Y `status` es uno de cinco literales
—`draft`, `open`, `closed`, `resolved`, `settled`— con los que la UI hace
comparaciones exactas.

#### Régimen estricto — números (Fases 5, 6 y 7)

| Petición | Respuesta esperada |
|---|---|
| `GET /raffles/:raffleId/numbers` | `200` con array de números de esa rifa |
| `GET /raffles/:raffleId/numbers/:number` | `200` con **un** número — ver hallazgo `C-01` |
| `POST /raffles/:raffleId/numbers/:number/reserve` | `200` con el número actualizado; `409` si no está disponible; `404` si no existe |
| `POST /raffles/:raffleId/numbers/:number/sell` | `200` con el número actualizado; `409` si ya está vendido; `404` si no existe |

```json
{ "raffleId": 1, "number": "0347", "status": "available", "participantId": null }
```

El `number` es **string** —`"0347"`, con sus ceros a la izquierda— y el
`raffleId` es número. Esa asimetría es fea y es contrato: el tablero de la Fase 5
pinta las celdas comparando strings, y un `347` numérico rompe la grilla entera
sin dar un solo error en consola.

El cuerpo de error de las rutas propias es `{ "message": "…" }` con el mensaje
**en español**, porque lo consume `toReadableError` y termina a la vista del
usuario. Los mensajes exactos que hoy devuelve el mock están en la Fase 3 y
conviene conservarlos: no porque el frontend los compare —no lo hace— sino
porque cambiarlos convierte cualquier captura de pantalla de un ticket viejo en
una pista falsa.

#### Régimen estricto — liquidaciones (Fases 8 y 9)

| Petición | Respuesta esperada |
|---|---|
| `POST /settlements` | `201` con la liquidación creada y su `id` |
| `GET /settlements` | `200` con array de liquidaciones |

Todos los montos son **enteros en centavos** (`totalCollected`, `prizeAmount`,
`margin`), coherentes con `A10`. Un decimal en cualquiera de esos campos es un
bug del servidor, no un detalle de formato.

#### Régimen estricto — headers y CORS

Esto no aparece en ninguna tabla de rutas y es lo que más veces rompe un
reemplazo:

- **Petición:** `Authorization: Bearer <token>` en toda petición hecha con
  sesión activa. El interceptor de la Fase 2 lo pone sin excepción, y el backend
  no puede exigirlo donde hoy no se exige (el `GET /users` del login sale **sin**
  header).
- **Respuesta:** `X-Request-Id` en **todas** las respuestas, incluidas las de
  error. El interceptor lo lee en las dos ramas.
- **CORS:** el origen es `http://localhost:3000`. Y hay una condición que no es
  opcional: `Access-Control-Expose-Headers: X-Request-Id`. Sin ella el header
  viaja, se ve perfectamente en Network, y `response.headers['x-request-id']`
  vale `undefined` — el navegador no deja leerlo. Ver hallazgo `C-05`.

#### Régimen estricto — el caos, que es andamiaje declarado

El middleware de caos **no es contrato de negocio**, pero sí es contrato de
laboratorio: las prácticas de las fases 3 y 7 lo usan y tienen que seguir
funcionando después de `be03`. Por decisión `D22` el backend lo reimplementa con
doble control —`POST /_chaos` y la variable `CHAOS_LEVEL`—, **apagado por
defecto**. Su forma exacta la define `be01`, porque no hay forma previa que
honrar: en el mock base la ruta es un ejercicio 🔥 y puede que ni exista en tu
copia.

#### La frontera que no se cruza: el `3002`

`GET /results/:raffleId` en el puerto `3002` devuelve `204 No Content` antes del
cierre y `200` con `{ raffleId, lotteryId, winningNumber, checkedAt, source }`
después. **Ese servidor no se reescribe en Go, nunca.** Es un tercero, tiene su
propio perfil de fallo, y el `apiLottery` de la Fase 7 le habla con una instancia
de `axios` distinta y sin interceptor de `401`. Conservar la frontera es
contenido: un backend propio no absorbe a sus proveedores porque le quede cómodo.

#### Régimen de crecimiento

Lo que el backend **puede** añadir sin romper nada, con la evidencia de por qué
es seguro:

- Todo el dialecto de paginación, orden y búsqueda de `json-server`
  (`_page`, `_limit`, `_sort`, `_order`, `q`, `X-Total-Count`). Ver `C-02`.
- El recurso `/participants`, declarado en `db.json` desde la Fase 3 y jamás
  consumido por el frontend.
- Campos nuevos en cualquier respuesta: el frontend los ignora.
- `GET /stats` para el dashboard — pendiente 🔥 de `be09`.
- Expiración de reservas del lado del servidor, que hoy vive en un `setTimeout`
  del cliente y es una deuda 💸 declarada de la Fase 5.

### 5.4 Los seis hallazgos

Un contrato sin hallazgos es un contrato que se copió del código. Estos salieron
de comparar lo que el frontend pide con lo que el mock ofrece, y cada uno tiene
consecuencias en una fase concreta del track.

**`C-01` · Una ruta que el frontend consume y el mock nunca implementó.**
`validateNumberEpic` (Fase 6) hace `GET /raffles/:raffleId/numbers/:number`. Esa
ruta no está en `rafflesNumbersRouter` ni la resuelve `json-server`. Hoy la
petición cae en `404` y el epic la trata como validación fallida — un bug que
nadie notó porque el síntoma se parece a "ese número no existe". **Es régimen
estricto**: el frontend la consume, el backend Go la implementa, y arreglarla en
`be03` es la primera vez que el track mejora la aplicación sin tocarla.

**`C-02` · El dialecto de `json-server` está, y nadie lo usa.** Ni `_page`, ni
`_limit`, ni `_sort`, ni `_order`, ni `q`, ni una sola lectura de
`X-Total-Count` en las doce fases del track base. El frontend pide `/raffles`
entero y ordena en el cliente. Todo eso baja a régimen de crecimiento: `be03` no
lo implementa, y si algún día lo necesita, lo agrega sin romper a nadie.

> 🧠 **Y este es el hallazgo que justifica la fase.** Si hubieras "reimplementado
> el dialecto de json-server" leyendo su documentación, habrías escrito
> paginación, ordenamiento y búsqueda —tres días de trabajo— para cero
> consumidores, y te habrías perdido la ruta de `C-01`, que sí tiene uno. El
> contrato medido no es solo más fiel que el leído: casi siempre es **más
> chico**.

**`C-03` · Dos clientes, dos cuerpos para el mismo `POST /sell`.** La Fase 5 y
la Fase 7 mandan `{ participantId }`; el `sellNumberEpic` de la Fase 6 manda
`{ participant }`. El mock lee `req.body.participantId ?? null`, así que la
variante de la Fase 6 **guarda `null` en silencio** y nadie se entera hasta que
alguien pregunta de quién era el número ganador. El contrato fija `participantId`
como forma canónica y anota que el backend debe aceptar la otra sin explotar. La
causa raíz se paga en `be04`, cuando la identidad deje de venir del cuerpo.

**`C-04` · Dos formas de `404` conviviendo.** `json-server` responde `404` con
**cuerpo vacío**; las tres rutas propias de la Fase 3 responden `404` con
`{ "message": … }`. Las dos son contrato, cada una en su ruta, y el backend Go
tiene que reproducir la inconsistencia. Uniformarla es exactamente el tipo de
mejora razonable que rompe un cliente: `toReadableError` se apoya en que haya —o
no haya— un `message`.

**`C-05` · El header que se ve y no se lee.** `X-Request-Id` viaja en la
respuesta y aparece en Network, pero en una petición cross-origin el navegador
solo se lo entrega a JavaScript si el servidor manda
`Access-Control-Expose-Headers: X-Request-Id`. Compruébalo en tu captura antes
de creerme: mira el header en Network **y** mira si tu consola imprimió la línea
`[req-id …]` del interceptor. Si ves lo primero y no lo segundo, acabas de
encontrar el bug más silencioso del track base y la deuda 💸 de trazabilidad que
`be01` paga entera. Si ves las dos cosas, anota qué lo hace funcionar en tu
entorno —el `proxy` del dev server de CRA es el sospechoso habitual— porque tu
binario de Go tendrá que garantizarlo sin depender de eso.

**`C-06` · La única excepción negociada del track, con nombre y apellido.**
El frontend no hace login con `POST /login`: hace
`GET /users?email=…&password=…`. Honrarlo al pie de la letra obligaría al backend
real a aceptar contraseñas en la query string para siempre, que es indefendible
y además hace inauditable el `be04` que enseña `bcrypt`. Se negocia entonces la
excepción, y se registra acotada:

> 🧭 **Excepción `C-06`.** En `be04` se modifica **un solo archivo del frontend**:
> `src/api/authService.js`, para que llame a `POST /login` con las credenciales
> en el cuerpo. No se toca `apiClient.js`, ni sus dos interceptores, ni
> `authSlice.js`, ni ningún componente. El campo `token` de la respuesta
> conserva su nombre y su forma de string opaca, de modo que el `Bearer` del
> interceptor sigue funcionando sin enterarse de que ahora es un JWT firmado.

No es una licencia general: es una excepción con archivo, fase y límite. Y
además estaba prevista — la Fase 2 lo dice textual: *"cuando mañana haya un
`POST /login` real, cambia **este** archivo y nada más"*, y lo deja como
ejercicio 🔥. El contrato solo cobra una promesa que el track base ya había
hecho. A partir de `be04`, el comando de verificación de la sección 2 lleva una
exclusión más, y una sola:

```bash
git diff pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js'
```

### 5.5 El smoke test: `server/smoke.sh`

El checklist ejecutable. Hoy pasa contra el mock; en `be03` tiene que pasar,
idéntico, contra tu binario. Que sea `bash` y `curl` y no un framework de
pruebas es deliberado: `be08` traerá la suite de contrato en Go, pero este script
tiene que poder correrlo cualquiera, en cualquier máquina, sin compilar nada.

```bash
#!/usr/bin/env bash
# server/smoke.sh — checklist de contrato del puerto 3001.
# Corre igual contra json-server (hasta be02) y contra el binario de Go
# (desde be03). Si deja de pasar, el reemplazo rompió el contrato.
#
# Uso: ./server/smoke.sh
# Requisitos: curl y jq. El caos DEBE estar apagado (CHAOS_LEVEL=off).

set -u
BASE="${BASE_URL:-http://localhost:3001}"
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

echo "== Contrato del 3001 =="

# 1. Login: array con un elemento, y el token presente.
LOGIN=$(curl -s "$BASE/users?email=organizador@rifas.test&password=rifas123")
check "GET /users con credenciales válidas devuelve 1 usuario" \
      "1" "$(echo "$LOGIN" | jq 'length')"
check "el usuario trae el campo token" \
      "true" "$(echo "$LOGIN" | jq '.[0] | has("token")')"

# 2. Credenciales inválidas: array VACÍO con 200. Nunca 401.
check "credenciales inválidas devuelven 200 con array vacío" \
      "200-0" \
      "$(curl -s -o /tmp/rc.json -w '%{http_code}' \
         "$BASE/users?email=nadie@rifas.test&password=x")-$(jq 'length' /tmp/rc.json)"

# 3. Tipos de la rifa: id numérico, number string, closesAt con offset.
RAFFLE=$(curl -s "$BASE/raffles/1")
check "raffle.id es número"        "number" "$(echo "$RAFFLE" | jq -r '.id | type')"
check "raffle.closesAt trae offset" "true"  \
      "$(echo "$RAFFLE" | jq -r '.closesAt | test("[+-][0-9]{2}:[0-9]{2}$")')"

# 4. El 404 de json-server: cuerpo VACÍO (longitud 2, el "{}").
check "GET /raffles/9999 devuelve 404" \
      "404" "$(curl -s -o /dev/null -w '%{http_code}' "$BASE/raffles/9999")"

# 5. Tablero de números y el tipo del campo number.
BOARD=$(curl -s "$BASE/raffles/1/numbers")
check "el tablero devuelve un array" "array" "$(echo "$BOARD" | jq -r 'type')"
check "number es string"             "string" \
      "$(echo "$BOARD" | jq -r '.[0].number | type')"

# 6. C-01: la ruta que el frontend consume. Hoy falla contra el mock,
#    y ese fallo ES el hallazgo. Desde be03 tiene que dar 200.
check "GET /raffles/1/numbers/0347 (C-01)" \
      "200" "$(curl -s -o /dev/null -w '%{http_code}' "$BASE/raffles/1/numbers/0347")"

# 7. Venta duplicada: el 409 con su message en el cuerpo.
curl -s -o /dev/null -X POST "$BASE/raffles/1/numbers/1500/sell" \
     -H 'Content-Type: application/json' -d '{"participantId":1}'
CONFLICT=$(curl -s -o /tmp/rc.json -w '%{http_code}' \
           -X POST "$BASE/raffles/1/numbers/1500/sell" \
           -H 'Content-Type: application/json' -d '{"participantId":1}')
check "vender dos veces devuelve 409" "409" "$CONFLICT"
check "el 409 trae message"           "true" "$(jq 'has("message")' /tmp/rc.json)"

# 8. Trazabilidad: el header en la respuesta...
check "X-Request-Id presente en la respuesta" "1" \
      "$(curl -s -D - -o /dev/null "$BASE/raffles" | grep -ci '^x-request-id:')"

# 9. ...y C-05: que el navegador pueda LEERLO. curl no distingue; el
#    navegador sí. Por eso lo comprobamos en el preflight.
check "X-Request-Id expuesto a CORS (C-05)" "1" \
      "$(curl -s -D - -o /dev/null -X OPTIONS "$BASE/raffles" \
         -H 'Origin: http://localhost:3000' \
         -H 'Access-Control-Request-Method: GET' \
         | grep -ci 'access-control-expose-headers:.*x-request-id')"

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

> ⚠️ **Contra el mock, este script no pasa entero, y está bien.** Las
> verificaciones 6 (`C-01`) y 9 (`C-05`) fallan hoy: son precisamente los dos
> hallazgos que `be01` y `be03` van a pagar. Anota en `CONTRACT.md` cuáles fallan
> **antes** de empezar `be01`, con su salida pegada. Ese es tu punto de partida
> medido, y es lo que te va a dejar afirmar en `be03` que el reemplazo mejoró
> algo, en vez de suponerlo.
>
> La verificación 7 modifica datos: deja el número `1500` vendido. Restaura tu
> `db.json` desde git antes de seguir (`git checkout -- mock/db.json`), o
> reserva un número de pruebas para esto. 💸 Que un smoke test ensucie la base
> es deuda declarada: se paga en `be08`, cuando la suite tenga sus propios datos
> y su propia transacción.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Auditar leyendo el código en vez de midiendo.** Síntoma: el contrato queda
prolijo, coherente y le faltan dos rutas; `be03` explota en la primera pantalla
que nadie recorrió. Causa: `grep` encuentra lo que el frontend pretende pedir, no
lo que pide. Fix mínimo: recorrer la aplicación entera con Preserve log y
reconciliar las dos listas. La reconciliación **es** el trabajo de esta fase:
las diferencias son los hallazgos.

**2. Auditar con el caos encendido.** Síntoma: en el contrato aparecen un `500`
sin causa, un `401` en una ruta pública y una respuesta HTML. Causa: el
middleware de la Fase 3 inyectando fallos. Fix: `CHAOS_LEVEL=off`, capturar de
nuevo, y anotar en el documento que el caos es andamiaje y no contrato — porque
esa distinción se te va a olvidar en `be01`, que es donde toca reimplementarlo.

**3. Confundir "el header está" con "puedo leerlo".** Síntoma: en Network se ve
`X-Request-Id` perfecto, y en el código `response.headers['x-request-id']` es
`undefined`. Causa: CORS no lo expone. Fix mínimo: `Access-Control-Expose-Headers`.
Es el error de esta lista que más caro sale, porque el síntoma —trazabilidad que
"a veces no funciona"— manda a la gente a leer el interceptor durante horas.

**4. "Mientras estamos, lo dejamos consistente".** Síntoma: el contrato dice que
todos los `404` devuelven `{ message }` y que los ids son strings "porque es más
seguro". Causa: el instinto de arquitecto operando sobre un sistema que ya tiene
clientes. Fix: separar en dos columnas lo que **es** de lo que **debería ser**, y
mandar la segunda al régimen de crecimiento o al mapa de deuda. Cuál de las dos
va al contrato no se discute: la primera.

### 🩻 Pieza forense de esta fase

**Convertir una captura en un contrato, y encontrar las cuatro diferencias.**

Esta es la pieza forense fundacional del track BE: en vez de perseguir un bug,
persigues una **discrepancia entre dos descripciones del mismo sistema**. Es la
misma habilidad, aplicada al momento en que todavía se puede prevenir el bug.

*Paso 1 — el inventario leído.* Sin abrir el navegador, saca la lista de
llamadas del código:

```bash
grep -rn "apiClient\.\(get\|post\|put\|patch\|delete\)" src/ | \
  sed 's/.*apiClient\.//' | sort -u
```

Guárdala en `server/evidence/inventario-leido.txt`.

*Paso 2 — el inventario medido.* El `jq` de la sección 5.2 sobre tu HAR, a
`server/evidence/inventario-medido.txt`.

*Paso 3 — la diferencia.* Compáralos. Vas a encontrar, como mínimo, cuatro
clases de discrepancia, y cada una enseña algo distinto:

- Algo que el código pide y la captura no muestra → una ruta que solo se ejecuta
  en un camino que no recorriste. **Vuelve y recórrelo**: es la ruta que `be03`
  va a romper.
- Algo que la captura muestra y el código no pide → `axios` y sus interceptores.
  El `OPTIONS` del preflight es el caso típico, y es contrato: si tu backend no
  lo contesta, no hay aplicación.
- La misma ruta con dos cuerpos distintos → `C-03`, el `POST /sell` de la Fase 6.
- Una ruta que el frontend pide y el servidor no conoce → `C-01`, tu `404` en
  vivo. Fíltralo en Network con `status-code:404` y velo pasar mientras usas el
  campo de validación.

*Paso 4 — el cierre del círculo.* Toma el `X-Request-Id` de cualquier respuesta
en Network, búscalo en la consola del navegador (el `console.debug` del
interceptor) y anota si aparece o no. Si no aparece, ya tienes `C-05` demostrado
en dos pantallas. Guarda las dos capturas: en `be01` vas a repetir este mismo
recorrido, y ahí el id además va a aparecer en el log del backend con su consulta
SQL y su tiempo. **Ese es el círculo completo que el track promete cerrar**, y
esta es la mitad que ya puedes medir hoy.

*Rompe a propósito.* Detén `json-server` y recorre la aplicación con el backend
caído. Anota, por pantalla, qué ve el usuario: dónde hay un mensaje legible,
dónde un spinner infinito y dónde una pantalla en blanco. Ese inventario de
síntomas es tu línea base: cuando en `be03` apagues el mock de verdad y algo se
comporte así, sabrás distinguir "el backend nuevo tiene un bug" de "así se veía
esto desde siempre".

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–7)**

1. Crea el tag `pre-backend-go` y verifica con `git diff pre-backend-go..HEAD -- . ':!server'` que devuelve vacío.
2. Levanta el mock con `CHAOS_LEVEL=off` y confirma con `curl` que `GET /raffles` responde `200` con un array.
3. Captura el HAR del recorrido completo y guárdalo en `server/evidence/recorrido.har`.
4. Con `jq`, saca del HAR la lista de rutas únicas del `3001` y cuenta cuántas son.
5. Separa en dos listas las peticiones al `3001` y las peticiones al `3002`. Explica en dos líneas por qué las segundas no entran al contrato.
6. Verifica con `curl -D -` que el `X-Request-Id` viene en la respuesta de `GET /raffles`.
7. Ejecuta `server/smoke.sh` contra el mock y pega su salida en `CONTRACT.md` como línea base, indicando cuáles verificaciones fallan hoy.

**🟡 Intermedio (8–16)**

8. Escribe la tabla del régimen estricto de rifas con los cinco métodos, citando para cada uno el archivo del frontend que lo consume.
9. Documenta los tipos exactos de los siete campos de una rifa y marca los tres cuya alteración rompería una fase concreta del track base.
10. Comprueba que `GET /users` con credenciales inválidas devuelve `200` con `[]` y explica qué pasaría en la UI si devolviera `401`. Sé específico: nombra el interceptor y el efecto.
11. **Diagnóstico.** Filtra el HAR por `status-code:404` y encuentra la petición de `C-01`. Determina desde qué componente y qué epic salió.
12. **Diagnóstico.** Localiza en el HAR los dos cuerpos distintos del `POST /sell` (`C-03`) y determina qué guardó el mock en cada caso.
13. Escribe el régimen de crecimiento completo, y para cada entrada justifica en una línea por qué agregarla no rompe a nadie.
14. Agrega al `smoke.sh` una verificación de que `POST /raffles` devuelve el recurso creado **con `id` numérico**.
15. **Diagnóstico.** Detén el `3002` y determina, sin leer código, qué pantallas dependen de él. Compara tu respuesta con la Fase 7.
16. Toma un `X-Request-Id` de Network y búscalo en la consola. Documenta el resultado como evidencia de `C-05`.

**🟠 Difícil (17–25)**

17. **Diagnóstico.** Reconcilia el inventario leído con el medido y clasifica cada diferencia en una de las cuatro clases de la pieza forense. Justifica las que no encajen.
18. Demuestra `C-05` con dos capturas: el header visible en Network y la consola sin la línea del interceptor. Si en tu entorno sí aparece, averigua qué lo hace funcionar y por qué no es replicable en producción.
19. **Diagnóstico.** Provoca los cuatro tipos de fallo del caos (`401`, `500`, timeout, malformado) y clasifica cada uno como contrato o andamiaje. Argumenta el caso del `401`, que es el discutible.
20. Escribe la política de compatibilidad del backend en cinco reglas operativas del tipo "agregar X es seguro, quitar Y no lo es", cada una con el consumidor concreto que la justifica.
21. **Diagnóstico.** El `POST /raffles` de tu captura, ¿devolvió `200` o `201`? Averigua qué hace `raffleSlice` con el código de estado y decide si el contrato puede fijar uno de los dos o tiene que aceptar ambos.
22. Diseña la sección de `CONTRACT.md` que documenta el `404` doble (`C-04`) de forma que un implementador de `be03` no pueda uniformarlo por descuido.
23. **Diagnóstico.** Recorre la app con el `3001` caído y levanta el inventario de síntomas por pantalla. Marca cuáles son fallos silenciosos.
24. Convierte tres verificaciones del `smoke.sh` en aserciones sobre la **forma** del JSON y no solo sobre el código de estado. Explica qué clase de regresión detecta cada versión.
25. **Diagnóstico.** Encuentra en el HAR alguna petición que ningún `grep` del código habría revelado. Explica de dónde salió.

**🔴 Muy difícil (26–30)**

26. Escribe el contrato del `POST /_chaos` que `be01` deberá implementar: cuerpo, respuesta, precedencia contra `CHAOS_LEVEL` y comportamiento ante un nivel inválido. Justifica cada decisión sabiendo que no hay forma previa que honrar.
27. **Diagnóstico.** Argumenta si `C-01` debe entrar al régimen estricto o al de crecimiento. Defiende la postura contraria a la tuya en cuatro líneas y después decide, por escrito, con qué criterio se resuelve el empate.
28. Toma la excepción `C-06` y escribe su alternativa: el contrato de un backend que honre `GET /users?email=&password=` con `bcrypt` y JWT sin tocar el frontend. Enumera qué se pierde pedagógicamente y qué riesgo real queda vivo. Después justifica por qué el track eligió la excepción.
29. **Diagnóstico + prevención.** Diseña la prueba de contrato mínima que habría detectado `C-03` el día que se escribió el `sellNumberEpic`, y ubica en qué capa tendría que haber corrido para ser útil.
30. Escribe el post-mortem de `C-05` como si el bug hubiera costado cuatro horas de un incidente en producción: síntoma, evidencia, causa raíz, corrección, prueba de regresión y prevención. Sin culpabilización, según la guía §13.

**🔥 Opcionales**

- 🔥 Genera el contrato en OpenAPI 3.0 a partir del HAR con la herramienta que prefieras, compáralo con tu `CONTRACT.md` y anota qué captura la máquina y qué solo capturaste tú.
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
- https://www.rfc-editor.org/rfc/rfc9110 — semántica de HTTP. Para esta fase: §15.5.5 (`404`), §15.5.10 (`409`) y §15.5.2 (`401`).
- https://www.rfc-editor.org/rfc/rfc3339 — el formato de `closesAt`. Vuelve en `be06`.

**Libros**
- *Building Microservices* (Sam Newman) — el capítulo de integración y versionado de contratos. Ignora la parte de microservicios: lo que sirve acá es su tratamiento de qué rompe a un consumidor.
- *Release It!* (Michael Nygard) — sobre integraciones que fallan de formas que nadie previó. El inventario de síntomas del ejercicio 23 es su idea.

**Video / apoyo**
- Busca en YouTube "Chrome DevTools Network panel deep dive" y "HAR file analysis": hay material bueno y corto de los últimos años. Los detalles de la interfaz cambian entre versiones de Chrome; los conceptos no.

**Orden de lectura sugerido:** el README de `json-server` 0.16.3 para reconocer
el dialecto → la página de `Access-Control-Expose-Headers`, que es corta y
resuelve `C-05` → y recién entonces al navegador, porque el resto se aprende
midiendo.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido:
> verifícalos. Las referencias a libros y videos son de memoria y pueden ser
> inexactas — confirma título, autor y edición antes de citarlas en un
> documento tuyo. Y cuando un enlace cubra una versión distinta a la del curso,
> el que manda es `prompts/decisiones-y-versiones.md`.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Tienes lo único que hacía falta para empezar a escribir Go con seguridad: la
lista, medida y no adivinada, de todo lo que el frontend le exige al puerto
`3001`. Tienes seis hallazgos que ningún `grep` habría dado, una excepción
negociada y acotada a un archivo, y un checklist ejecutable que ahora mismo falla
en dos puntos — dos puntos que son, exactamente, dos de las promesas del track.

`be01` levanta el andamiaje: `go.mod`, `net/http` con `gorilla/mux`, la cadena de
middlewares con el `X-Request-Id` viajando por `context.Context`, el apagado
ordenado, `GET /health` y el caos reimplementado con doble control. Todavía sin
base de datos y sin tocar el contrato de negocio. Pero al terminarla vas a poder
cerrar el círculo que hoy quedó a medias: copiar un `X-Request-Id` de la consola
del navegador y encontrarlo, con nombre propio, en el log del servidor.

> **La señal de que quedó bien:** *"puedo decir qué se rompe si cambio cualquier
> línea de este contrato, y puedo demostrarlo señalando el archivo del frontend
> que lo consume."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be00-el-contrato-auditoria-del-mock -m "be00 cerrada: \
> tag pre-backend-go creado; HAR del recorrido completo capturado con caos apagado; \
> server/CONTRACT.md con régimen estricto y de crecimiento; \
> hallazgos C-01 a C-06 registrados con evidencia; \
> excepción C-06 acotada a src/api/authService.js; \
> server/smoke.sh ejecutable con su línea base contra el mock"
> ```
>
> Los commits de la fase llevan su prefijo (`be00: …`) y los de ejercicio su
> número (`be00 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/be00/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **Registrar en `prompts/diccionario-codigo-ingles.md` §7bis.3** las dos rutas
  nuevas que introduce esta fase: `server/CONTRACT.md` y `server/smoke.sh`, más
  el directorio `server/evidence/`. Hecho al escribir la fase; verificar que
  sobrevive a futuras ediciones del diccionario.
- **`C-06` afecta a `be04` y al comando de verificación de todas las fases
  posteriores.** Desde `be04`, el `git diff` de la sección 2 lleva la exclusión
  `':!src/api/authService.js'`. Que ninguna fase entre `be04` y `be09` lo olvide.
- **`C-01` y `C-05` son criterio de aceptación de `be03` y `be01`
  respectivamente.** Las verificaciones 6 y 9 de `smoke.sh` tienen que pasar a
  verde ahí, y cada una de esas fases debe pedirlo en su checklist.
- **`C-03` se paga en `be04`**, cuando la identidad salga de `req.Context()` y el
  `participantId` del cuerpo deje de ser la fuente de verdad. `be04` debe citarlo
  por su código.
- **`C-04` es una trampa para `be03`.** Conviene que `be03` lo mencione
  explícitamente en sus errores comunes: uniformar el `404` es la mejora
  razonable que rompe `toReadableError`.
- **Reserva para el cuaderno de incidentes:** `be-01` — *"la trazabilidad
  funciona en Network pero no en la consola"* (categoría 🔥 contrato, dificultad
  🟡), que es `C-05` convertido en ticket vago. Y `be-02` — *"el número ganador
  no tiene dueño"* (categoría 🔥 contrato, dificultad 🟠), que es `C-03`: el
  síntoma aparece semanas después de la venta, cuando alguien reclama el premio.
- **Deuda declarada en esta fase:** 💸 `smoke.sh` ensucia los datos (deja el
  número `1500` vendido). Se paga en `be08`, con datos propios y transacción.
- **Para `be-a-07`:** el recorrido del `X-Request-Id` que acá queda a medias es
  su columna vertebral. El apéndice debería abrir con las dos capturas de la
  pieza forense de esta fase.
FIN_DEL_ARCHIVO
wc -l be00-el-contrato-auditoria-del-mock.md

# --- 2026-09-08T03:44:53 · Register new server paths in dictionary
cd prompts && python3 - <<'PY'
import io
p='diccionario-codigo-ingles.md'
s=io.open(p,encoding='utf-8').read()
old="""- `server/internal/seed/` — siembra desde el `db.json` del alumno, y el faker
  opcional de `be-a-10`."""
new="""- `server/internal/seed/` — siembra desde el `db.json` del alumno, y el faker
  opcional de `be-a-10`.
- `server/CONTRACT.md` — el contrato auditado en `be00`: régimen estricto,
  régimen de crecimiento y hallazgos. Criterio de aceptación de `be03`.
- `server/smoke.sh` — el checklist de contrato ejecutable, en `bash` y `curl`.
  Corre igual contra el mock y contra el binario de Go.
- `server/evidence/` — capturas y evidencia de las piezas forenses (el HAR de
  `be00`, los inventarios leído y medido)."""
assert old in s
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))
print("ok")
PY

# --- 2026-09-08T03:50:35 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs && cat > be01-go-y-la-forma-del-monolito.md <<'FIN_DEL_ARCHIVO'
# 🐹 Fase be01 — Go 1.19 y la forma del monolito

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Fase be01 de be09 · **8 horas**
> Depende de: be00 — el contrato ya está auditado y escrito · Habilita: be02 — La costura de datos

---

## 🎯 1. Propósito

Levantar el esqueleto del backend: un servidor HTTP en Go que arranca, atiende,
loguea, se recupera de sus propios pánicos, se apaga sin cortarle la petición a
nadie y sabe romperse a propósito cuando se lo piden. Sin base de datos y sin
tocar todavía el contrato de negocio.

La fase tiene un objetivo secundario que en realidad es el principal para el
track: **pagar la sexta deuda 💸 —la trazabilidad—**. En el mock, el
`X-Request-Id` nace y muere en un middleware de tres líneas. Acá nace en el borde
del servidor, viaja por `context.Context` hasta el fondo de la aplicación,
aparece en cada línea de log con el tiempo que tardó la petición, y —cerrando el
hallazgo `C-05` de `be00`— el navegador por fin puede **leerlo**. Al terminar
esta fase puedes copiar un id de la consola de Chrome y encontrarlo en la
terminal del servidor.

> 🧭 Sigue mandando la regla del track: el frontend no se toca. En esta fase ni
> siquiera lo miramos, salvo para comprobar que puede leer un header.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `server/go.mod` con `go 1.19` y `gorilla/mux` v1.8.0 como única
      dependencia; el layout de `server/` creado según
      `prompts/diccionario-codigo-ingles.md` §7bis.3.
- [ ] El binario compila con `go build ./...` y arranca con `go run ./cmd/api`,
      escuchando en el puerto que indique `PORT`.
- [ ] `GET /health` responde `200` con `{"status":"ok"}` y su `X-Request-Id`.
- [ ] La cadena de middlewares está montada y **en el orden correcto**:
      `requestID` → `logging` → `cors` → `recover` → `chaos` → rutas.
- [ ] El `X-Request-Id` viaja por `context.Context` y cualquier función del
      backend puede recuperarlo sin recibirlo como parámetro suelto.
- [ ] La verificación 9 de `server/smoke.sh` (`C-05`) pasa a **verde** contra el
      binario: `Access-Control-Expose-Headers` incluye `X-Request-Id`.
- [ ] Un pánico dentro de un handler devuelve `500` con su `X-Request-Id` y
      **el proceso sigue vivo**.
- [ ] `Ctrl+C` cierra el servidor sin cortar una petición en vuelo.
- [ ] El caos existe con doble control (`POST /_chaos` y `CHAOS_LEVEL`), apagado
      por defecto, y su regla de precedencia está escrita y probada.
- [ ] `git diff pre-backend-go..HEAD -- . ':!server'` no devuelve nada.

---

## 🚫 3. Qué queda fuera por ahora

- **Cualquier acceso a base de datos** → `be02`. Esta fase sirve datos fijos o en
  memoria, y no se disculpa por ello.
- **Los recursos del contrato** (`/raffles`, `/users`, `/settlements`) → `be03`.
  Hoy el único endpoint vivo es `/health`.
- **La configuración con `envconfig`** → `be03`. Acá se lee con `os.Getenv` y una
  función de ayuda. 💸 Deuda declarada: la configuración queda dispersa y sin
  validar; lo correcto es un struct único que falle al arrancar si algo falta.
- **La sintaxis de Go** → `be-a-01`. Esta fase asume que sabes leer una función y
  un `struct`; el apéndice cubre punteros, interfaces, `defer`, goroutines y el
  resto. Ábrelo en cuanto una línea te frene.

---

## 🧠 4. Conceptos mínimos

Sabes qué es HTTP, qué es un middleware y qué es inyección de dependencias. No
vamos a gastar una línea en eso. Lo que sigue es lo que Go hace **distinto**, y
que es donde tropieza todo el mundo que llega de otro lenguaje.

### Los errores son valores, y no hay excepciones

En Go no hay `try/catch`. Una función que puede fallar devuelve dos cosas: el
resultado y un `error`. Quien la llama decide qué hacer, ahí mismo, en la línea
siguiente:

```go
raffle, err := store.FindRaffle(ctx, id)
if err != nil {
    return fmt.Errorf("buscando la rifa %d: %w", id, err)
}
```

El `%w` de `fmt.Errorf` **envuelve** el error original en vez de aplastarlo a
texto: quien reciba el error de arriba puede seguir preguntando con
`errors.Is` / `errors.As` si en el fondo era un `sql.ErrNoRows`. Envolver con
contexto en cada capa es lo que reemplaza al stack trace que traías de otros
lenguajes — y es mejor, porque el contexto lo escribiste tú y dice algo útil.

El precio es la verbosidad, y no hay que negociarlo: vas a escribir
`if err != nil` cientos de veces. Lo que se gana es que **ninguna ruta de fallo
es invisible**. En el frontend del track base, una promesa rechazada sin
`.catch()` desaparece; acá, un error que no manejas es una variable que el
compilador te obliga a nombrar.

> 🧠 **El corolario que importa para este track.** En Node, un `throw` dentro de
> un handler de Express lo atrapa el framework y solo muere esa petición. En Go,
> un `panic` que nadie recupera **tumba el proceso entero**. Todo el servidor.
> Todas las conexiones. Esa es la primera lección cultural de Go y es la pieza
> forense de esta fase.

### Las interfaces son implícitas

No existe `implements`. Un tipo satisface una interfaz por tener sus métodos, y
punto — el tipo puede haberse escrito años antes que la interfaz, en otro
paquete, sin conocerla. Esto tiene una consecuencia de diseño que vas a usar en
`be02` y que conviene entender ahora: **las interfaces se declaran del lado del
consumidor, no del proveedor**. El paquete que necesita guardar rifas declara
`RaffleStore` con los tres métodos que usa; el paquete que habla con Postgres no
sabe que esa interfaz existe.

En esta fase la ves en su forma más simple, la que sostiene todo `net/http`:

```go
type Handler interface {
    ServeHTTP(ResponseWriter, *Request)
}
```

Un middleware, entonces, no es un concepto del framework: es simplemente **una
función que recibe un `Handler` y devuelve otro `Handler`**. Nada más. Toda la
cadena de esta fase son cinco funciones de esa forma, compuestas.

### `context.Context`: el vehículo transversal

`context.Context` es el primer parámetro de todo lo que cruce una frontera
—handler, service, store— y hace dos trabajos a la vez.

El primero es **cancelación**. Cuando el cliente cierra la pestaña, el
`r.Context()` de esa petición se cancela; si tu consulta a la base recibió ese
contexto, Postgres cancela la consulta en vez de seguir gastando CPU por un
resultado que nadie va a leer. Es el `takeUntil` de la Fase 6, del lado del
servidor y con la misma idea: **lo que ya no le importa a nadie se apaga**.

El segundo es **transportar valores de alcance de petición**, y acá entra el
`X-Request-Id`. La regla de oro es que esa vía es para datos que atraviesan
capas sin ser parte de la lógica: el request id, la identidad del usuario (que
llega en `be04`). Nunca para parámetros de negocio disfrazados.

### El orden de los middlewares es contenido, no detalle

Una cadena de middlewares es una cebolla, y quién queda adentro de quién decide
el comportamiento del sistema en sus peores momentos. Este es el orden de la
fase, de afuera hacia adentro, con el porqué de cada posición:

1. **`requestID`** primero de todos, porque **todo** lo que venga después
   —incluido el log de un pánico— necesita el id para ser útil.
2. **`logging`** por fuera de `recover`, para que la línea de log registre el
   `500` que `recover` escribió y su duración real. Si lo pones adentro, un
   pánico no deja rastro en el log.
3. **`cors`** por fuera de `recover`, para que **las respuestas de error también
   lleven los headers de CORS**. Un `500` sin ellos es, para el navegador, un
   error de red opaco: `axios` recibe un `Network Error` sin `response`, y el
   `toReadableError` de la Fase 4 no tiene nada que traducir.
4. **`recover`** envolviendo todo lo que ejecuta código de aplicación.
5. **`chaos`** lo más adentro posible, justo antes de las rutas, porque simula
   fallos **del handler**, no del transporte.

> ⚠️ El error clásico es poner `recover` de primero "por seguridad". Parece más
> defensivo y es peor: los pánicos quedan sin id y sin línea de log, y el
> navegador ve un error de red en vez de un `500`. Cuando te toque diagnosticar
> eso, no vas a tener con qué.

### El apagado ordenado

`http.Server.Shutdown(ctx)` deja de aceptar conexiones nuevas y espera a que las
que están en curso terminen, hasta que el contexto se cancele. Sin él, un
`Ctrl+C` mata el proceso en el acto y el cliente que estaba a mitad de una venta
recibe una conexión cortada — sin `409`, sin `500`, sin nada que un frontend
pueda interpretar. En un despliegue real es la diferencia entre un deploy
transparente y una racha de errores en cada release.

---

## 💻 5. Implementación y código comentado

### 5.1 El módulo y el layout

```bash
mkdir -p server/cmd/api server/internal/http
cd server
go mod init github.com/rifas-y-chances/raffles-api
go get github.com/gorilla/mux@v1.8.0
```

```
server/
├── go.mod
├── go.sum
├── cmd/
│   └── api/
│       └── main.go          # configuración, cableado y arranque
└── internal/
    └── http/
        ├── router.go        # las rutas y el armado de la cadena
        ├── middleware.go    # requestID, logging, cors, recover
        ├── chaos.go         # el caos con doble control
        └── respond.go       # helpers de respuesta JSON
```

Dos decisiones del layout que conviene entender ahora porque se repiten en todas
las fases.

**`cmd/api/` contiene el `main` y nada más.** Su trabajo es leer configuración,
construir las piezas y arrancar el servidor. Toda la lógica vive en `internal/`,
que es un directorio con significado para el compilador: **nada fuera de este
módulo puede importar un paquete bajo `internal/`**. Es encapsulamiento a nivel
de proyecto, gratis y verificado por el compilador.

**El directorio se llama `http` pero el paquete se llama `httpapi`.** El nombre
del paquete no está obligado a coincidir con el de la carpeta, y acá el desvío es
a propósito: un paquete llamado `http` que importa `net/http` obliga a poner
alias en cada archivo, y eso ensucia más de lo que ordena. La ruta de la carpeta
la fija el diccionario del curso; el nombre del paquete lo fija la legibilidad.

```go
// server/go.mod
module github.com/rifas-y-chances/raffles-api

go 1.19

require github.com/gorilla/mux v1.8.0
```

> 📝 **Nota de época sobre `gorilla/mux`.** Era el router por defecto de medio
> ecosistema Go. A fines de 2022 el proyecto **se archivó**, y más tarde volvió a
> tener mantenedores. Una dependencia central de tu sistema que se muere —y
> resucita— es exactamente el tipo de evento que define la vida de un sistema
> legacy, y por eso está en el curso como contenido y no como accidente. 💸
> Verifica tú mismo el estado del repositorio hoy antes de apoyarte en él para
> algo real; no lo des por sentado leyendo esto.

### 5.2 Las respuestas JSON: `respond.go`

Antes que nada, la función que va a escribir todas las respuestas del backend.
Que exista desde el primer día evita la inconsistencia que `be00` documentó como
hallazgo `C-04` — dos formas de `404` conviviendo — y hace que reproducir esa
inconsistencia a propósito, en `be03`, sea una decisión y no un descuido.

```go
// server/internal/http/respond.go
package httpapi

import (
	"encoding/json"
	"log"
	"net/http"
)

// errorBody es la forma que el frontend ya sabe leer: un objeto con un
// único campo "message" en español, porque termina a la vista del usuario
// a través de toReadableError. No se le agregan campos sin revisar el
// contrato de be00.
type errorBody struct {
	Message string `json:"message"`
}

// writeJSON serializa v y lo escribe con el status indicado.
//
// El orden importa y es una de las trampas clásicas de net/http: el
// Content-Type debe fijarse ANTES de WriteHeader, y WriteHeader antes de
// escribir el cuerpo. Al revés, Go ya mandó un 200 implícito y tu status
// se pierde con un aviso en el log que nadie lee.
func writeJSON(w http.ResponseWriter, status int, v interface{}) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)

	if v == nil {
		return
	}
	if err := json.NewEncoder(w).Encode(v); err != nil {
		// Acá ya se enviaron los headers: no se puede cambiar el status.
		// Lo único honesto es dejar rastro en el log.
		log.Printf("error serializando la respuesta: %v", err)
	}
}

// writeError escribe la forma de error del contrato.
// El mensaje va en español a propósito: lo lee un humano en la interfaz.
func writeError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, errorBody{Message: message})
}

// writeEmpty responde sin cuerpo. Es la forma del 404 de json-server, que
// el contrato de be00 obliga a conservar en los recursos automáticos.
func writeEmpty(w http.ResponseWriter, status int) {
	w.WriteHeader(status)
}
```

### 5.3 Los middlewares: `middleware.go`

El archivo más importante de la fase. Léelo entero antes de escribirlo: cada
función es corta, pero las decisiones están en los comentarios.

```go
// server/internal/http/middleware.go
package httpapi

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"log"
	"net/http"
	"time"
)

// requestIDHeader es el nombre exacto que el contrato de be00 fija.
// El interceptor de respuesta de la Fase 2 lo lee en minúsculas
// (response.headers['x-request-id']) porque los navegadores normalizan;
// nosotros lo escribimos con la capitalización canónica.
const requestIDHeader = "X-Request-Id"

// ctxKey es un tipo propio para las claves de context. Usar un string
// pelado funcionaría, pero dos paquetes distintos podrían elegir la misma
// clave y pisarse. Un tipo no exportado hace la colisión imposible: nadie
// fuera de este paquete puede construir esta clave.
type ctxKey int

const requestIDKey ctxKey = iota

// RequestIDFrom devuelve el id de la petición que viaja en el contexto,
// o "" si no hay ninguno. Esta es la puerta por la que TODA la aplicación
// —el logger, el store de be02, la consulta SQL de be03— accede al id sin
// tener que recibirlo como parámetro suelto en cada firma.
func RequestIDFrom(ctx context.Context) string {
	if id, ok := ctx.Value(requestIDKey).(string); ok {
		return id
	}
	return ""
}

// newRequestID genera un identificador aleatorio de 16 caracteres hex.
//
// 📝 No hace falta una dependencia para esto. La biblioteca estándar trae
// un generador criptográficamente seguro, y un uuid completo no aporta
// nada acá: el id solo tiene que ser único dentro de una ventana de logs.
func newRequestID() string {
	b := make([]byte, 8)
	if _, err := rand.Read(b); err != nil {
		// crypto/rand fallando es un problema del sistema operativo, no
		// de esta petición. Degradamos a un id basado en el reloj antes
		// que dejar la petición sin trazabilidad.
		return "ts-" + time.Now().UTC().Format("150405.000000")
	}
	return hex.EncodeToString(b)
}

// requestIDMiddleware es el PRIMERO de la cadena. Respeta el id que venga
// del cliente —un proxy o un test pueden querer fijarlo— y si no viene, lo
// genera. Lo deja en tres lugares: el contexto (para el código), el header
// de respuesta (para el navegador) y, de rebote, el log.
func requestIDMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		id := r.Header.Get(requestIDHeader)
		if id == "" {
			id = newRequestID()
		}
		w.Header().Set(requestIDHeader, id)

		ctx := context.WithValue(r.Context(), requestIDKey, id)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// statusRecorder envuelve el ResponseWriter para poder saber, DESPUÉS de
// que el handler terminó, con qué status respondió y cuántos bytes
// escribió. net/http no lo ofrece: el ResponseWriter es de solo escritura.
// Este envoltorio de quince líneas es el precio de tener logs útiles, y
// es un patrón que vas a ver en todos los proyectos Go de esta época.
type statusRecorder struct {
	http.ResponseWriter
	status int
	bytes  int
}

func (rec *statusRecorder) WriteHeader(status int) {
	rec.status = status
	rec.ResponseWriter.WriteHeader(status)
}

func (rec *statusRecorder) Write(b []byte) (int, error) {
	// Un handler que escribe cuerpo sin llamar a WriteHeader produce un
	// 200 implícito. Lo registramos para que el log no mienta.
	if rec.status == 0 {
		rec.status = http.StatusOK
	}
	n, err := rec.ResponseWriter.Write(b)
	rec.bytes += n
	return n, err
}

// loggingMiddleware imprime una línea por petición, con el id adelante
// para que sea grepeable.
//
// 💸 Deuda declarada: esto es log de texto con el paquete `log` estándar.
// Lo correcto en un servicio real es log estructurado en JSON, con niveles
// y campos. Se deja así porque en 2022 `log/slog` no existía todavía (D14)
// y porque una línea legible en la terminal es mejor para aprender. En
// be-a-07 se discute qué cambia con log estructurado y por qué importa el
// día que los logs los lee una máquina.
func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		rec := &statusRecorder{ResponseWriter: w}

		next.ServeHTTP(rec, r)

		// Este es el momento que cierra el círculo del track: el mismo id
		// que el navegador imprimió en su consola aparece acá, con la ruta,
		// el status y el tiempo real que tardó.
		log.Printf("[req-id %s] %s %s → %d (%d bytes) en %s",
			RequestIDFrom(r.Context()),
			r.Method,
			r.URL.RequestURI(),
			rec.status,
			rec.bytes,
			time.Since(start).Round(time.Microsecond),
		)
	})
}

// corsMiddleware habilita el origen del frontend y —esto es lo que paga el
// hallazgo C-05 de be00— EXPONE el X-Request-Id.
//
// 🧠 La distinción que casi nadie tiene clara: un header de respuesta
// siempre llega y siempre se ve en la pestaña Network. Pero en una petición
// cross-origin, el navegador solo se lo entrega a JavaScript si el servidor
// lo declara en Access-Control-Expose-Headers. Sin esta línea, el
// interceptor de la Fase 2 lee undefined mientras DevTools muestra el
// header perfectamente: el bug más desconcertante del track base.
func corsMiddleware(allowedOrigin string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Access-Control-Allow-Origin", allowedOrigin)
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Authorization, Content-Type, "+requestIDHeader)
			w.Header().Set("Access-Control-Expose-Headers", requestIDHeader)

			// El preflight se contesta acá y no sigue bajando: no tiene
			// sentido que el caos le inyecte un 500 a un OPTIONS, y menos
			// que el router intente resolverlo como ruta.
			if r.Method == http.MethodOptions {
				w.WriteHeader(http.StatusNoContent)
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}

// recoverMiddleware atrapa el pánico de cualquier handler, lo convierte en
// un 500 con la forma del contrato y —lo esencial— DEJA VIVO EL PROCESO.
//
// Sin esto, un índice fuera de rango en un handler tumba el servidor
// entero: no solo esa petición, sino todas las conexiones abiertas de todos
// los usuarios. Es la pieza forense de esta fase.
func recoverMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// defer registra la función para que corra al salir de este
		// bloque, pase lo que pase — con return normal o con pánico.
		defer func() {
			if rec := recover(); rec != nil {
				// El id hace diagnosticable el pánico: es lo que te deja
				// correlacionar el 500 que vio el usuario con esta línea.
				log.Printf("[req-id %s] PÁNICO en %s %s: %v",
					RequestIDFrom(r.Context()), r.Method, r.URL.Path, rec)

				// 💸 El mensaje es genérico a propósito: nunca se filtra
				// el detalle interno al cliente. Cómo se maneja esto bien
				// —y qué se filtra sin darse cuenta— es tema de be-a-08.
				writeError(w, http.StatusInternalServerError, "Error interno del servidor")
			}
		}()

		next.ServeHTTP(w, r)
	})
}
```

> 🧠 **`defer` en una frase.** Registra una función para que se ejecute al salir
> de la función actual, siempre: con `return`, con error o con pánico. Es el
> `finally` de Go, y es la única forma de que `recover()` llegue a ejecutarse.
> Si te resulta ajeno, `be-a-01` lo cubre con más calma.

### 5.4 El caos en Go: `chaos.go`

El mock de la Fase 3 se rompía a propósito, y las prácticas del track base
dependen de eso. `D22` obliga a reimplementarlo con **doble control**, y a
decidir por escrito qué pasa cuando los dos controles se contradicen.

> 🧭 **Regla de precedencia.** Gana **la última orden recibida**, y el arranque
> cuenta como orden. Es decir: `CHAOS_LEVEL` fija el nivel inicial; cualquier
> `POST /_chaos` posterior lo reemplaza; un reinicio vuelve a lo que diga la
> variable. Sin memoria, sin archivo de estado, sin sorpresas.

Y una advertencia que en Go no es opcional: **ese nivel lo leen muchas
goroutines a la vez** —una por petición— y lo escribe otra. Un simple campo
`string` compartido es una condición de carrera de manual, de las que `go test
-race` detecta y el ojo no. Por eso el `sync.RWMutex`.

```go
// server/internal/http/chaos.go
package httpapi

import (
	"encoding/json"
	"log"
	"math/rand"
	"net/http"
	"strings"
	"sync"
)

// chaosConfig replica EXACTAMENTE los números del chaosMiddleware.js de la
// Fase 3. No son valores nuevos: si cambian, las prácticas del track base
// dejan de comportarse igual y el alumno no sabría a qué atribuirlo.
type chaosConfig struct {
	minMs    int
	maxMs    int
	failRate float64
}

var chaosLevels = map[string]chaosConfig{
	"off":  {minMs: 0, maxMs: 50, failRate: 0},
	"low":  {minMs: 100, maxMs: 800, failRate: 0.05},
	"high": {minMs: 300, maxMs: 3000, failRate: 0.18},
}

// protectedRoutes: las mismas cuatro del mock, con la misma comprobación
// por prefijo. Que /raffles/1/numbers/0347/sell quede protegida por
// startsWith es intencional y es lo que hace posible el ejercicio de la
// Fase 5 donde el token se cae en mitad de una venta.
var protectedRoutes = []string{"/raffles", "/numbers", "/participants", "/settlements"}

// ChaosController guarda el nivel vigente. Es mutable en caliente y lo leen
// todas las peticiones concurrentemente: de ahí el RWMutex.
//
// 🧠 RWMutex y no Mutex porque el patrón de acceso es asimétrico: miles de
// lecturas (una por petición) contra una escritura muy ocasional (un POST
// /_chaos). RLock permite lecturas simultáneas entre sí.
type ChaosController struct {
	mu    sync.RWMutex
	level string
}

// NewChaosController aplica la primera orden: la del arranque.
func NewChaosController(level string) *ChaosController {
	if _, ok := chaosLevels[level]; !ok {
		log.Printf("[chaos] nivel desconocido %q, se usa \"off\"", level)
		level = "off"
	}
	log.Printf("[chaos] nivel inicial: %s", level)
	return &ChaosController{level: level}
}

func (c *ChaosController) Level() string {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.level
}

// SetLevel aplica una orden nueva. Devuelve false si el nivel no existe,
// y en ese caso NO cambia nada: una orden inválida no apaga el caos.
func (c *ChaosController) SetLevel(level string) bool {
	if _, ok := chaosLevels[level]; !ok {
		return false
	}
	c.mu.Lock()
	defer c.mu.Unlock()
	c.level = level
	log.Printf("[chaos] nivel cambiado a: %s", level)
	return true
}

func isProtectedRoute(path string) bool {
	for _, base := range protectedRoutes {
		if strings.HasPrefix(path, base) {
			return true
		}
	}
	return false
}

// chaosMiddleware inyecta latencia y, según el nivel, uno de los cuatro
// fallos del mock. Va lo más ADENTRO de la cadena: simula que falla el
// handler, no el transporte.
func chaosMiddleware(c *ChaosController) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			cfg := chaosLevels[c.Level()]

			// La latencia se aplica siempre, igual que en el mock.
			// time.Sleep bloquea ESTA goroutine, no el servidor: Go
			// atiende cada petición en la suya. Si vienes de Node, es la
			// diferencia que más cuesta interiorizar — acá bloquear no es
			// pecado, es local.
			if cfg.maxMs > 0 {
				delay := cfg.minMs + rand.Intn(cfg.maxMs-cfg.minMs+1)
				time.Sleep(time.Duration(delay) * time.Millisecond)
			}

			if rand.Float64() >= cfg.failRate {
				next.ServeHTTP(w, r)
				return
			}

			protected := isProtectedRoute(r.URL.Path)
			switch pickFailureType(protected) {
			case "unauthorized":
				writeError(w, http.StatusUnauthorized, "Token inválido o expirado")
			case "serverError":
				writeError(w, http.StatusInternalServerError, "Error interno del servidor")
			case "timeout":
				// El mock simplemente no respondía y la petición quedaba
				// colgada. En Go no alcanza con hacer return: eso cierra
				// la respuesta con un 200 vacío. Hay que quedarse quieto
				// hasta que el cliente se canse y cancele.
				//
				// 🧠 Y acá el contexto deja de ser teoría: r.Context() se
				// cancela solo cuando el cliente corta. Esta es la misma
				// idea del takeUntil de la Fase 6, del otro lado del cable.
				<-r.Context().Done()
			case "malformed":
				// 200 con cuerpo que no es JSON. El fallo más traicionero
				// de los cuatro: no rompe nada hasta que alguien confía en
				// response.data.algo.
				w.WriteHeader(http.StatusOK)
				w.Write([]byte("<html>esto no es JSON, alguien mezcló ambientes</html>"))
			}
		})
	}
}

// pickFailureType usa exactamente los mismos cortes de probabilidad que el
// mock. El 401 solo entra en la baraja de rutas protegidas.
func pickFailureType(protected bool) string {
	roll := rand.Float64()
	if protected {
		switch {
		case roll < 0.25:
			return "unauthorized"
		case roll < 0.55:
			return "serverError"
		case roll < 0.82:
			return "timeout"
		default:
			return "malformed"
		}
	}
	switch {
	case roll < 0.5:
		return "serverError"
	case roll < 0.85:
		return "timeout"
	default:
		return "malformed"
	}
}

// chaosHandler atiende POST /_chaos. La forma del cuerpo la fija esta fase
// —el mock nunca la tuvo, era un ejercicio 🔥— y queda registrada en el
// régimen de crecimiento del contrato: {"level":"low"}.
func chaosHandler(c *ChaosController) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var body struct {
			Level string `json:"level"`
		}
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			writeError(w, http.StatusBadRequest, "Cuerpo inválido: se espera {\"level\":\"off|low|high\"}")
			return
		}
		if !c.SetLevel(body.Level) {
			writeError(w, http.StatusBadRequest, "Nivel de caos desconocido")
			return
		}
		writeJSON(w, http.StatusOK, map[string]string{"level": c.Level()})
	}
}
```

> ⚠️ **`math/rand` y no `crypto/rand`.** Para decidir si una petición falla,
> `math/rand` sobra y es más rápido. Para generar un id, no: ahí sí va
> `crypto/rand`. Confundirlos en el otro sentido —usar `math/rand` para un
> token— es un hallazgo de seguridad real, y `be-a-08` lo trata.
>
> 📝 En Go 1.19 el generador global de `math/rand` **está sembrado con una
> semilla fija** si no llamas a `rand.Seed`. Eso significa que sin sembrar,
> cada arranque produce exactamente la misma secuencia de fallos. Para el
> laboratorio es una ventaja —el caos se vuelve reproducible— pero tienes que
> saberlo. Desde Go 1.20 el comportamiento cambió y siembra al azar; es
> justamente el tipo de detalle que hace que un test "flaky" aparezca al
> actualizar el toolchain.

### 5.5 El router y la cadena: `router.go`

```go
// server/internal/http/router.go
package httpapi

import (
	"net/http"

	"github.com/gorilla/mux"
)

// Config es lo mínimo que el router necesita saber del exterior.
// En be03 esto lo reemplaza un struct de configuración validado con
// envconfig; hoy son dos campos y no vale la pena más ceremonia.
type Config struct {
	AllowedOrigin string
	ChaosLevel    string
}

// NewRouter arma la aplicación completa: las rutas y la cebolla de
// middlewares que las envuelve.
func NewRouter(cfg Config) http.Handler {
	chaos := NewChaosController(cfg.ChaosLevel)

	r := mux.NewRouter()

	// GET /health: el primer endpoint vivo. NO está en el contrato de
	// be00 —el frontend no lo consume— así que pertenece al régimen de
	// crecimiento. Lo usan el compose de be-a-02 y el pipeline de be09.
	r.HandleFunc("/health", healthHandler).Methods(http.MethodGet)

	// POST /_chaos: andamiaje del curso, declarado como tal. Ningún
	// backend de producción trae un endpoint para romperse a sí mismo.
	r.HandleFunc("/_chaos", chaosHandler(chaos)).Methods(http.MethodPost)

	// La cadena, de AFUERA hacia adentro. Se lee al revés de como se
	// escribe, que es la única parte incómoda de este patrón:
	// requestID( logging( cors( recover( chaos( rutas )))))
	var handler http.Handler = r
	handler = chaosMiddleware(chaos)(handler)
	handler = recoverMiddleware(handler)
	handler = corsMiddleware(cfg.AllowedOrigin)(handler)
	handler = loggingMiddleware(handler)
	handler = requestIDMiddleware(handler)

	return handler
}

// healthHandler responde lo mínimo verificable. En be02 crecerá para
// reportar también el estado de la conexión a la base — y ahí aparecerá
// la pregunta interesante: ¿un /health debe caerse si la base no responde?
func healthHandler(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}
```

> ⚠️ **`gorilla/mux` y el `panicHandler` que no existe.** A diferencia de otros
> routers, `mux` no trae recuperación de pánicos incorporada. Si esperabas que el
> framework te cubriera —como hace Express con los `throw` síncronos—, no lo
> hace. Por eso `recoverMiddleware` es tuyo y es obligatorio.

### 5.6 El arranque y el apagado: `main.go`

```go
// server/cmd/api/main.go
package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	httpapi "github.com/rifas-y-chances/raffles-api/internal/http"
)

// getenv lee una variable con valor por defecto.
// 💸 Deuda declarada: la configuración queda dispersa en llamadas sueltas y
// sin validar. Lo correcto es un struct único que falle al arrancar si algo
// falta o está mal — y eso llega en be03 con envconfig (D-be03).
func getenv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func main() {
	// El puerto destino del track es el 3001, el mismo que sirve json-server.
	// Mientras el mock siga levantado (be01 y be02), arranca este binario en
	// otro puerto: PORT=3011 go run ./cmd/api
	// A partir de be03 el mock se apaga y el 3001 es de Go. Ese es el punto.
	addr := ":" + getenv("PORT", "3001")

	handler := httpapi.NewRouter(httpapi.Config{
		AllowedOrigin: getenv("ALLOWED_ORIGIN", "http://localhost:3000"),
		ChaosLevel:    getenv("CHAOS_LEVEL", "off"), // apagado por defecto (D22)
	})

	srv := &http.Server{
		Addr:    addr,
		Handler: handler,

		// Estos tres timeouts no son opcionales y net/http NO los pone por
		// ti: sin ellos, una conexión lenta o maliciosa puede quedarse
		// tomada indefinidamente. Es el equivalente del timeout de axios
		// que la Fase 3 obligó a configurar, del lado del servidor.
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// El servidor corre en su propia goroutine para que main pueda quedarse
	// esperando la señal de apagado. Si ListenAndServe falla al arrancar
	// —puerto ocupado, típicamente— hay que morir con un mensaje claro.
	go func() {
		log.Printf("raffles-api escuchando en %s", addr)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("no se pudo levantar el servidor: %v", err)
		}
	}()

	// Esperamos SIGINT (Ctrl+C) o SIGTERM (lo que manda un orquestador al
	// desplegar). Que las dos se traten igual es lo que hace que el deploy
	// de be09 no genere una racha de errores en cada release.
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("apagando: no se aceptan conexiones nuevas, se esperan las que están en curso")

	// Diez segundos de gracia para las peticiones en vuelo. Si alguna tarda
	// más, se corta: un apagado que espera para siempre no es un apagado.
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("apagado forzado: %v", err)
	}
	log.Println("servidor apagado limpiamente")
}
```

### 5.7 Comprobarlo

```bash
cd server
go build ./... && PORT=3011 go run ./cmd/api

# En otra terminal:
curl -i localhost:3011/health
# → 200, X-Request-Id presente, {"status":"ok"}

# El id que mandas es el id que se respeta y el que aparece en el log:
curl -s -D - -o /dev/null localhost:3011/health -H 'X-Request-Id: mi-id-de-prueba'

# El preflight, que es lo que paga C-05:
curl -s -D - -o /dev/null -X OPTIONS localhost:3011/raffles \
  -H 'Origin: http://localhost:3000' -H 'Access-Control-Request-Method: GET' \
  | grep -i expose

# El caos, con sus dos controles:
CHAOS_LEVEL=high PORT=3011 go run ./cmd/api      # orden de arranque
curl -X POST localhost:3011/_chaos -d '{"level":"off"}'   # última orden, gana
```

Y la verificación que cierra el hallazgo de `be00`: con el servidor arriba,
abre la aplicación en `localhost:3000`, y en la consola del navegador:

```javascript
// Solo para comprobar C-05. No toca ningún archivo del frontend.
fetch('http://localhost:3011/health')
  .then(r => console.log('X-Request-Id legible:', r.headers.get('X-Request-Id')));
```

Si imprime un id en vez de `null`, acabas de pagar la deuda 💸 de trazabilidad
que el mock arrastraba desde la Fase 2. Busca ese mismo id en la terminal del
servidor: ahí está, con la ruta, el status y el tiempo.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. `WriteHeader` después de escribir el cuerpo.** Síntoma: el cliente recibe
`200` cuando tu código dice `404`, y en la terminal aparece
`superfluous response.WriteHeader call`. Causa: en cuanto escribes un byte, Go
manda un `200` implícito y el status ya no se puede cambiar. Fix mínimo: fijar
`Content-Type` y `WriteHeader` **antes** de encodear — que es justo el orden que
impone `writeJSON`, y por eso existe.

**2. El `return` que no cancela nada.** Síntoma: escribes el error y el handler
sigue corriendo, y el cliente recibe dos cuerpos pegados. Causa: `writeError` no
interrumpe el flujo; en Go no hay `return res.status(400).json(...)` que corte
por ti. Fix: `return` explícito en la línea siguiente, siempre. Es el error más
frecuente de quien llega de Express y el más fácil de no ver en revisión.

**3. Poner `recover` de primero en la cadena.** Síntoma: un pánico devuelve `500`
pero no hay línea de log, o el navegador reporta un error de red opaco en vez de
un `500`. Causa: el orden. Fix: `requestID` → `logging` → `cors` → `recover`.
Corrección mínima frente a refactorización: mover una línea en `NewRouter` es la
corrección; rediseñar la cadena con un framework de middlewares es la
refactorización, y no hace falta.

**4. El nivel de caos como campo compartido sin candado.** Síntoma: bajo carga,
un `POST /_chaos` produce lecturas inconsistentes, y `go test -race` grita.
Causa: escritura concurrente sobre un `string` compartido. Fix: el `RWMutex` de
`ChaosController`. Si nunca lo viste fallar, ese es el problema — una carrera de
datos puede pasar meses sin manifestarse.

### 🩻 Pieza forense de esta fase

**Un pánico, y las dos formas de morir.**

Agrega un handler que reviente a propósito. No es un caso rebuscado: es un
índice fuera de rango, el error más común del mundo.

```go
// Solo para la pieza forense. Se borra al terminar el ejercicio.
r.HandleFunc("/_boom", func(w http.ResponseWriter, r *http.Request) {
    numbers := []string{"0347"}
    writeJSON(w, http.StatusOK, numbers[5]) // 💥
}).Methods(http.MethodGet)
```

*Paso 1 — con `recover`.* Con la cadena completa, pide `GET /_boom`. Anota qué
ve el cliente (`500` con `{"message":…}` y su `X-Request-Id`), qué dice el log, y
—lo importante— comprueba que el proceso **sigue vivo**: pide `/health` otra vez
y responde.

*Paso 2 — sin `recover`.* Comenta la línea de `recoverMiddleware` en `NewRouter`
y repite. Ahora anota tres cosas distintas:

- El cliente **no recibe un `500`**: recibe una conexión cortada.
  `curl` dice `Empty reply from server`; Chrome dice `ERR_EMPTY_RESPONSE`; y
  `axios` entrega un `Network Error` **sin `error.response`**, o sea sin status,
  sin cuerpo y sin `X-Request-Id`. Todo el diagnóstico que montamos en `be00`
  desaparece de golpe.
- El proceso **murió**. Pide `/health`: no hay nadie. Todas las conexiones de
  todos los usuarios se cayeron con él.
- El único rastro es el stack trace en la terminal del servidor — que es
  muchísimo, si alguien lo está mirando, y nada si el proceso corre en un
  contenedor que se reinició solo.

*Paso 3 — la comparación cultural.* Vuelve al mock de la Fase 3 y provoca un
error equivalente en un handler de Express (`req.body.nope.nope`). Express atrapa
el `throw` síncrono, responde `500` y **el mock sigue vivo**. Escribe en cuatro
líneas por qué Go eligió lo contrario, y qué te obliga a hacer esa elección en
cada servicio que escribas.

*Paso 4 — el círculo, esta vez completo.* Con el `recover` puesto otra vez, haz
la petición desde la consola del navegador (el `fetch` de 5.7), copia el
`X-Request-Id` que imprime y búscalo con `grep` en el log del servidor. Ese
recorrido —consola del navegador → terminal del backend— es la mitad de lo que
`be00` dejó pendiente. La otra mitad, con la consulta SQL y su tiempo, llega en
`be02`.

*Rompe a propósito, bonus.* Pon `CHAOS_LEVEL=high` y arranca dos veces seguidas
sin tocar nada. ¿La secuencia de fallos es idéntica? Explica por qué (pista: la
nota sobre `math/rand` en 5.4), y decide si para este laboratorio eso es un bug o
una función.

---

## 🧪 7. Ejercicios (32)

**🟢 Fácil (1–8)**

1. Crea el módulo con `go mod init` y compila un `main.go` vacío que imprima el puerto. Confirma que `go build ./...` no dice nada — en Go, silencio es éxito.
2. Levanta el servidor en `PORT=3011` y verifica `GET /health` con `curl -i`.
3. Comprueba que el `X-Request-Id` cambia en cada petición y que es el mismo en el header y en el log.
4. Manda tu propio `X-Request-Id` y verifica que el servidor lo respeta en vez de generar uno nuevo.
5. Comprueba el preflight: `OPTIONS /raffles` devuelve `204` y `Access-Control-Expose-Headers: X-Request-Id`.
6. Arranca con `CHAOS_LEVEL=high` y confirma en el log el nivel inicial; cámbialo a `off` con `POST /_chaos`.
7. Manda `POST /_chaos` con `{"level":"caotico"}` y verifica que devuelve `400` **y que el nivel anterior no cambió**.
8. Detén el servidor con `Ctrl+C` y confirma en el log las dos líneas del apagado ordenado.

**🟡 Intermedio (9–18)**

9. Agrega a `/health` un campo `uptime` calculado desde el arranque. Decide dónde vive esa variable y por qué no puede ser global mutable sin candado.
10. Escribe un middleware que rechace con `413` cualquier cuerpo mayor a 1 MB. Ubícalo en la cadena y justifica su posición.
11. **Diagnóstico.** Invierte `cors` y `recover` en la cadena, provoca un pánico desde la consola del navegador con `fetch` y describe exactamente qué ve JavaScript. Explica por qué.
12. **Diagnóstico.** Quita `WriteHeader` de `writeJSON` y observa qué status recibe el cliente cuando el handler pedía `404`. Encuentra el aviso en la terminal.
13. Haz que el `statusRecorder` registre también el `Content-Type` de la respuesta y agrégalo a la línea de log. ¿En qué diagnóstico serviría?
14. Provoca el fallo `timeout` del caos y observa qué hace `curl --max-time 2`. Después repítelo con `fetch` y compara.
15. **Diagnóstico.** Con el caos en `high`, provoca un `401`. ¿Sobre qué rutas aparece y sobre cuáles no? Verifícalo contra `protectedRoutes` y explica la asimetría.
16. Escribe una prueba manual con `curl` que demuestre la regla de precedencia del caos en sus tres pasos: arranque, `POST /_chaos`, reinicio.
17. Ocupa el puerto con otro proceso y verifica que el servidor muere con un mensaje legible en vez de quedarse callado.
18. **Diagnóstico.** Manda una petición y ciérrala a la mitad (`Ctrl+C` en `curl`) durante la latencia del caos. Comprueba en el log qué pasó con esa petición y relaciónalo con `r.Context()`.

**🟠 Difícil (19–27)**

19. **Diagnóstico.** Ejecuta la pieza forense completa y escribe el informe de las dos formas de morir, con la salida de `curl`, la de Chrome y el objeto de error de `axios` en cada caso.
20. Haz que el pánico registre también el stack trace con `runtime/debug.Stack()`, y decide qué parte va al log y qué parte **nunca** va al cliente. Argumenta con `be-a-08` en mente.
21. **Diagnóstico.** Escribe un programa de veinte líneas que dispare 200 peticiones concurrentes a `/_chaos` y a `/health` a la vez, y córrelo con `go run -race`. Después quita el `RWMutex` y repite. Pega las dos salidas.
22. Implementa un middleware de timeout de servidor con `http.TimeoutHandler` y explica en qué se diferencia del `WriteTimeout` del `http.Server`. Decide cuál corresponde a este backend.
23. **Diagnóstico.** El apagado ordenado, medido: lanza una petición con el caos en `high` (latencia de hasta 3 s) y manda `SIGTERM` a mitad de camino. Demuestra con evidencia que esa petición se completó y que una nueva fue rechazada.
24. Reduce el margen de `Shutdown` a 1 segundo y repite el ejercicio anterior. Documenta qué ve el cliente cuando el margen no alcanza y qué implica eso para un despliegue.
25. **Diagnóstico.** Sin `defer cancel()` en el `context.WithTimeout` de `main`, ¿qué se filtra exactamente? Explícalo y encuentra la herramienta que lo detectaría (`go vet` es un buen punto de partida).
26. Reescribe la cadena de middlewares como un `[]func(http.Handler) http.Handler` aplicado en un bucle, de modo que se **lea en el mismo orden en que se ejecuta**. Discute si la legibilidad ganada compensa la indirección.
27. **Diagnóstico.** Con el caos en `low`, corre 500 peticiones a `/health` y calcula la tasa real de fallos. ¿Coincide con `failRate`? Si no, encuentra por qué (revisa qué cuenta como fallo y sobre qué rutas).

**🔴 Muy difícil (28–32)**

28. Diseña y escribe la variante del `chaosMiddleware` que puede fallar **solo en una ruta concreta** (`POST /_chaos` con `{"level":"high","path":"/raffles"}`). Justifica si eso pertenece al régimen de crecimiento del contrato o lo rompe.
29. **Diagnóstico + regresión.** Te entregan este bug: "cada tanto, dos peticiones distintas aparecen en el log con el mismo `X-Request-Id`". Reprodúcelo (pista: `newRequestID` no es el único camino por el que se asigna un id), determina la causa raíz y escribe la prueba de regresión que lo habría atrapado.
30. **Diagnóstico.** Un `500` del backend llega al navegador y `toReadableError` de la Fase 4 lo convierte en "Error de red" en vez de "Error del servidor". El backend jura que respondió `500`. Encuentra la causa en la cadena de middlewares, arréglala y demuestra el antes y el después con dos capturas de Network.
31. Argumenta por escrito si `GET /health` debe reportar `503` cuando la base de datos no responde —caso que llega en `be02`— o mantenerse en `200` mientras el proceso viva. Defiende la postura contraria a la tuya y decide con qué criterio se resuelve, sabiendo que el orquestador de `be09` va a matar el contenedor según esa respuesta.
32. **Post-mortem.** Escribe el post-mortem del incidente ficticio "el backend se caía entero tres veces por día y nadie sabía por qué", con la causa raíz en la falta de `recover`, según la guía §13: síntoma, evidencia, causa raíz, corrección, prueba de regresión, prevención. Sin culpabilización.

**🔥 Opcionales**

- 🔥 Reescribe el enrutamiento con los patrones de método de `http.ServeMux` de Go 1.22 (`mux.HandleFunc("GET /health", …)`) en una rama aparte. Compara líneas de código y dependencias, y explica por qué el curso se queda en 1.19 (D14).
- 🔥 Sustituye el `log.Printf` por log estructurado en JSON escrito a mano (sin `slog`, que no existe en 1.19). Mide cuánto crece cada línea y discute qué gana quien lee los logs con una máquina.
- 🔥 Agrega un middleware de límite de tasa por IP y decide, con el contrato de `be00` en la mano, si puede entrar sin romper a nadie.

---

## 📚 8. Referencias

**Documentación oficial**
- https://pkg.go.dev/net/http — la referencia central. Empieza por `Handler`, `HandlerFunc`, `ServeMux` y `Server`.
- https://pkg.go.dev/net/http#Server.Shutdown — el apagado ordenado, con su ejemplo completo.
- https://pkg.go.dev/context — y sobre todo https://go.dev/blog/context, que explica el porqué mejor que la referencia.
- https://github.com/gorilla/mux — verifica el estado del repositorio hoy antes de apoyarte en él; ver la nota de época en 5.1.
- https://go.dev/blog/error-handling-and-go y https://go.dev/blog/go1.13-errors — errores como valores, y el envoltorio con `%w`.
- https://go.dev/blog/defer-panic-and-recover — la mecánica exacta de la pieza forense.
- https://go.dev/ref/mem — el modelo de memoria de Go, para entender por qué el `RWMutex` del caos no es opcional.
- https://go.dev/doc/go1.20#math/rand — el cambio de sembrado que explica la nota de 5.4.

**Libros**
- *The Go Programming Language* (Donovan y Kernighan) — el capítulo de concurrencia y el de interfaces. Es de 2015 y sigue siendo el mejor texto sobre las dos cosas.
- *Let's Go* (Alex Edwards) — construye un servidor web con la biblioteca estándar, con este mismo enfoque de middlewares compuestos. Verifica la edición: se actualiza con cada versión de Go.

**Video / apoyo**
- Busca "Go concurrency patterns Rob Pike" y "justforfunc net/http middleware" en YouTube. Son charlas viejas y siguen siendo exactas: `net/http` casi no ha cambiado.

**Orden de lectura sugerido:** el blog de `defer, panic and recover` primero
—veinte minutos y es la pieza forense— → la documentación de `net/http.Handler`,
que son tres párrafos y explican toda la cadena → `be-a-01` para cualquier
sintaxis que te frene → y el blog de `context` recién cuando el código te tenga
cómodo.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros son de memoria y pueden ser inexactas. Casi todo el
> material bueno de Go en la web asume la versión más reciente; cuando algo no
> compile con `go 1.19`, el que manda es
> `prompts/decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Tienes un servidor que atiende, que deja rastro de todo lo que hace, que
sobrevive a sus propios errores y que se apaga sin dejar a nadie colgado. Y
tienes pagada la primera deuda del track: el `X-Request-Id` dejó de ser un
adorno del mock y es una herramienta — nace en el borde, viaja por el contexto y
el navegador puede leerlo.

Lo que no tienes es un solo dato real. `/health` responde una constante y el
contrato de `be00` sigue entero sin implementar. `be02` construye la capa de
datos: `database/sql`, el pool, `sqlx` y sus placeholders, las migraciones
versionadas, el esquema completo del dominio — y la tesis incómoda de la fase,
que la agnosia de base de datos no existe. Vas a ver la misma consulta devolver
resultados distintos contra dos motores, y esa evidencia es la que después
justifica la regla del motor de `be08`.

> **La señal de que quedó bien:** *"tumbé el servidor a propósito, lo volví a
> poner de pie con quince líneas, y ahora cualquier error que ocurra allá adentro
> lo puedo encontrar desde la consola del navegador."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be01-go-y-la-forma-del-monolito -m "be01 cerrada: \
> go.mod con go 1.19 y gorilla/mux 1.8.0; layout de server/ creado; \
> GET /health vivo; cadena requestID→logging→cors→recover→chaos montada en orden; \
> X-Request-Id viajando por context y expuesto a CORS (C-05 en verde); \
> pánico recuperado sin tumbar el proceso; apagado ordenado con Shutdown; \
> caos con doble control y precedencia documentada"
> ```
>
> Los commits de la fase llevan su prefijo (`be01: …`) y los de ejercicio su
> número (`be01 ej21: …`). Si un ejercicio merece su propio marcador va en
> `ej/be01/21`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **Registrar en `prompts/decisiones-y-versiones.md` §7.4** la variable `PORT` y
  la convención del puerto de transición: mientras el mock viva (be01 y be02) el
  binario arranca en `3011`; desde `be03` toma el `3001` por defecto. Hoy está
  decidido en el código de esta fase y comentado en `main.go`, pero la fuente de
  verdad de puertos debería recogerlo.
- **Registrar en el régimen de crecimiento de `server/CONTRACT.md`** la forma de
  `POST /_chaos` que esta fase define (`{"level":"off|low|high"}` → `200` con el
  nivel vigente, `400` ante nivel desconocido sin cambiar nada) y `GET /health`.
  El mock nunca los tuvo con esta forma, así que la define el backend.
- **`C-05` queda cerrado acá.** La verificación 9 de `smoke.sh` pasa a verde. La
  6 (`C-01`) sigue en rojo hasta `be03`, como corresponde.
- **Deudas declaradas en esta fase:** 💸 configuración con `os.Getenv` sin
  validar (se paga en `be03` con `envconfig`); 💸 log de texto en vez de
  estructurado (se discute en `be-a-07`, no se paga en el track: es coherente
  con la época y con D14).
- **Para `be02`:** `healthHandler` tiene que crecer para reportar el estado de la
  base, y ahí aparece la pregunta del ejercicio 31 —`200` o `503`— que `be09`
  necesita resuelta porque el orquestador actúa según esa respuesta. Conviene que
  `be02` la cierre explícitamente en vez de dejarla al ejercicio.
- **Para `be08`:** el ejercicio 21 (carrera de datos en `ChaosController` con
  `-race`) es el germen natural de la sección de `go test -race`. Y la regla de
  precedencia del caos hay que probarla ahí, como pide la propuesta §11.
- **Para `be-a-01`:** esta fase da por conocidos `defer`, punteros, goroutines,
  canales, `interface{}` y el patrón de envoltorio de `ResponseWriter`. El
  apéndice tiene que cubrir los seis, y el envoltorio merece su propia sección
  porque reaparece en `be08`.
- **Reserva para el cuaderno de incidentes:** `be-03` — *"el backend se cae solo
  y vuelve, tres veces al día"* (categoría 🔥 despliegue, dificultad 🟡), que es
  el pánico sin `recover` visto desde afuera, cuando el contenedor se reinicia y
  el único síntoma es una racha de errores de red sin patrón.
FIN_DEL_ARCHIVO
wc -l be01-go-y-la-forma-del-monolito.md

# --- 2026-09-08T03:50:43 · Fix missing time import in chaos.go
python3 - <<'PY'
import io
p='be01-go-y-la-forma-del-monolito.md'
s=io.open(p,encoding='utf-8').read()
old="""	"net/http"
	"strings"
	"sync"
)"""
new="""	"net/http"
	"strings"
	"sync"
	"time"
)"""
assert s.count(old)==1
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))
print('ok')
PY

# --- 2026-09-08T03:56:26 · 
cat > be02-la-costura-de-datos.md <<'FIN_DEL_ARCHIVO'
# 🗄️ Fase be02 — La costura de datos y el mito de la agnosia

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Fase be02 de be09 · **10 horas**
> Depende de: be01 — el servidor HTTP ya corre · Habilita: be03 — CRUD y el reemplazo

---

## 🎯 1. Propósito

Construir la capa de datos del backend: el pool de conexiones, las migraciones
versionadas, el esquema completo del dominio de rifas y el acceso con SQL escrito
a mano. Y, mientras se construye, demostrar la tesis que le da nombre a la fase.

> 🧭 **La agnosia total de base de datos no existe.** Lo que existe es
> **portabilidad por disciplina**: una costura donde el dialecto se hace
> explícito, en vez de esconderse detrás de una abstracción que promete lo que no
> puede cumplir.

Esto no es una opinión de sobremesa y no se va a suavizar. Al terminar la fase
vas a tener la misma consulta corriendo contra PostgreSQL y contra SQLite,
devolviendo **resultados distintos**, con los dos motores comportándose
correctamente según su propia especificación. Esa evidencia es la que justifica
la regla del motor de `be08`, y es la razón de que este track use `database/sql`
y SQL a mano en vez de un ORM: un ORM esconde el dialecto exactamente donde
queremos que se vea.

La deuda 💸 que prepara: `db.json` como almacén. Todavía no la cobra —eso es
`be03`— pero acá se construye la caja donde va a entrar el dinero.

---

## ✅ 2. Qué queda listo al terminar

- [ ] PostgreSQL 13 corriendo en contenedor y accesible por `DATABASE_URL`.
- [ ] `server/migrations/postgres/` y `server/migrations/sqlite/` con las
      migraciones versionadas del esquema completo, `up` y `down`, aplicables y
      reversibles con `golang-migrate` v4.15.2.
- [ ] Las cinco tablas del dominio creadas: `raffles`, `raffle_numbers`,
      `participants`, `settlements` y `users`.
- [ ] `server/internal/storage/` con el pool configurado, la costura de dialecto
      y el chequeo de salud de la base.
- [ ] `GET /health` reporta el estado de la conexión, con la decisión `200`
      contra `503` tomada y justificada por escrito.
- [ ] `server/internal/raffle/store.go` con la interfaz `RaffleStore` y su
      implementación en `sqlx`, probada **desde tests de Go y no desde HTTP**.
- [ ] `go test ./...` pasa contra los dos motores.
- [ ] Existe `server/evidence/divergencias.md`: el inventario **medido** —con la
      salida pegada— de las siete divergencias entre SQLite y PostgreSQL que
      afectan a este backend.
- [ ] `git diff pre-backend-go..HEAD -- . ':!server'` no devuelve nada.

---

## 🚫 3. Qué queda fuera por ahora

- **Los handlers del CRUD** → `be03`. Acá se construye la capa de datos y se
  prueba desde tests. Ni una ruta nueva que devuelva una rifa.
- **La siembra desde el `db.json` del alumno** → `be03`. En esta fase los datos
  salen de fixtures de prueba, que son otra cosa y tienen otro dueño.
- **`SELECT … FOR UPDATE`, aislamiento y el `409` de la base** → `be05`. Acá se
  **mide** que la semántica de bloqueo diverge; resolverlo con esa semántica es
  la fase ⭐ del track y no se le adelanta el final.
- **El manejo fino de zonas horarias** → `be06`. Acá se elige `TIMESTAMPTZ` y se
  demuestra por qué SQLite no puede seguirle el paso; qué hace Postgres
  *realmente* con ese tipo es tema de la otra fase.
- **La decisión entre `mattn/go-sqlite3` (cgo) y `modernc.org/sqlite`** → `be09`,
  donde se **mide** en tamaño de imagen y tiempo de compilación. Acá se usa
  `mattn` y ya se empieza a sentir el peso de `CGO_ENABLED=1`.

---

## 🧠 4. Conceptos mínimos

Tienes años de SQL. No vamos a explicar qué es un índice, una transacción ni una
clave foránea. Lo que sigue es lo que Go hace distinto y lo que la convivencia
de dos motores obliga a decidir.

### `*sql.DB` no es una conexión: es un pool

El error de modelo mental más caro para quien llega de otros lenguajes. Un
`*sql.DB` es un **pool** de conexiones, seguro para uso concurrente, que se abre
una vez al arrancar el proceso y se comparte con todas las goroutines. No se
abre por petición, no se cierra al terminar un handler, y no se pasa por
parámetro "para no compartir estado".

De ahí se derivan las tres cosas que hay que configurar y que nadie configura:

- **`SetMaxOpenConns`.** Sin límite, Go abre tantas conexiones como
  peticiones concurrentes haya, y Postgres las rechaza al llegar a
  `max_connections` (100 por defecto). El síntoma en producción es delicioso:
  todo va perfecto hasta que hay carga, y entonces falla *todo* a la vez.
- **`SetMaxIdleConns`.** Si es menor que el máximo abierto, el pool cierra y
  reabre conexiones sin parar bajo carga sostenida. Cada reapertura es un
  handshake TCP y una autenticación.
- **`SetConnMaxLifetime`.** Las conexiones eternas sobreviven a los balanceadores
  y a los reinicios del servidor de base; una vida acotada las recicla antes de
  que se pudran.

Y la fuga de recursos clásica de Go no es olvidar cerrar la base: es **olvidar
cerrar un `*sql.Rows`**. Cada `Rows` abierto retiene una conexión del pool hasta
que se agota, y el síntoma es idéntico a "la base no responde".

### `sqlx` es una capa fina, y esa es toda su virtud

`sqlx` no es un ORM, no genera SQL y no esconde nada. Envuelve `database/sql`
para ahorrarte el `rows.Scan(&a, &b, &c, …)` campo por campo —`Get`, `Select` y
`StructScan` mapean a structs por etiquetas `db:"…"`— y agrega `Rebind`, que es
lo que de verdad importa acá:

```go
// El mismo SQL, escrito una sola vez con placeholders "?":
query := db.Rebind(`SELECT * FROM raffles WHERE status = ? AND closes_at > ?`)
// contra Postgres  → WHERE status = $1 AND closes_at > $2
// contra SQLite    → WHERE status = ? AND closes_at > ?
```

Eso es una costura: un punto único, nombrado, donde la diferencia entre motores
se resuelve a la vista. No es magia y no pretende serlo. **Y no alcanza**, que es
justamente lo que vamos a demostrar.

> ⚠️ `Rebind` resuelve la sintaxis de los placeholders y nada más. No traduce
> tipos, ni funciones de fecha, ni semántica de bloqueo, ni `RETURNING`, ni
> `ON CONFLICT`. Creer que un `Rebind` te dio portabilidad es exactamente el
> mito que esta fase desmonta.

### Migraciones: dos archivos por versión, y un paso explícito

`golang-migrate` trabaja con pares `NNNNNN_nombre.up.sql` / `.down.sql` y una
tabla de control (`schema_migrations`) donde anota en qué versión está la base.
Dos reglas del curso, y las dos están en `D20`:

**Todo cambio de esquema es una versión nueva.** Editar una migración ya
aplicada es la forma más rápida de que dos ambientes queden distintos sin que
nadie pueda demostrarlo.

**Las migraciones se ejecutan como paso explícito, nunca al arrancar en
producción.** La comodidad de `migrate.Up()` dentro de `main()` cuesta cara el
día que tres réplicas arrancan a la vez y se pelean por aplicar el mismo `ALTER`:
en el mejor caso una espera, en el peor la base queda a medio migrar. En
desarrollo, el atajo es aceptable y lo vas a usar; que sea distinto en producción
es contenido de `be09`.

### La decisión de esta fase: DDL por dialecto, no subconjunto común

`D20` deja abierta una pregunta y hay que cerrarla: con dos motores, ¿el DDL es
un **subconjunto común** que ambos entiendan, o se mantiene **uno por dialecto**?

> 🧭 **Decisión: uno por dialecto.** `server/migrations/postgres/` y
> `server/migrations/sqlite/`, con los mismos números de versión y los mismos
> nombres.

El subconjunto común suena mejor y es peor, por una razón que se ve en cuanto lo
intentas: el mínimo común denominador de PostgreSQL 13 y SQLite 3.35 no tiene
`TIMESTAMPTZ`, ni `BIGSERIAL`, ni índices parciales, ni `CHECK` con enumeraciones
razonables. Escribir el DDL en ese subconjunto significa **renunciar a Postgres
para complacer al motor de pruebas** — es decir, degradar el sistema real para
que el andamiaje sea más cómodo. Al revés de como debe ser.

Mantener dos juegos tiene un costo honesto y hay que decirlo: **pueden
divergir**. Ese riesgo se administra con dos cosas, no con buenas intenciones —
la prueba de `be08` que corre el mismo caso contra los dos motores, y la regla
del motor que dice cuándo SQLite directamente no vale. El costo se paga a la
vista; la alternativa lo escondía.

### Las tablas del dominio, y por qué `numbers` se llama `raffle_numbers`

El `db.json` tiene una colección `numbers`. La tabla se llama `raffle_numbers`,
como fija `prompts/diccionario-codigo-ingles.md` §7bis.1. No es capricho ni
inconsistencia: **la etiqueta JSON es la frontera del contrato y la columna no
lo es**. El frontend recibe `{"raffleId":1,"number":"0347","status":"available"}`
y nunca ve un nombre de tabla. Adentro mandan las convenciones de SQL —plural,
`snake_case`, prefijo del agregado— y afuera manda el contrato de `be00`. La
costura entre las dos convenciones vive en las etiquetas del struct, en un solo
lugar, y se lee de un vistazo.

---

## 💻 5. Implementación y código comentado

### 5.1 Levantar PostgreSQL 13

```bash
docker run -d --name rifas-pg \
  -e POSTGRES_USER=rifas \
  -e POSTGRES_PASSWORD=rifas \
  -e POSTGRES_DB=rifas \
  -p 5432:5432 \
  postgres:13

# Si ya tienes un Postgres local en el 5432, publica en 5433 y ajusta la URL.
export DATABASE_URL="postgres://rifas:rifas@localhost:5432/rifas?sslmode=disable"
psql "$DATABASE_URL" -c 'select version();'
```

> 📝 `sslmode=disable` es correcto para un laboratorio local y sería un hallazgo
> de seguridad en cualquier otra parte. Queda declarado acá y se retoma en
> `be09`, donde la configuración por ambiente decide qué modo corresponde a cada
> uno. La receta completa del contenedor y el `docker-compose.yml` viven en
> `be-a-02`.

### 5.2 Las dependencias

```bash
cd server
go get github.com/jmoiron/sqlx@v1.3.5 \
       github.com/lib/pq@v1.10.7 \
       github.com/mattn/go-sqlite3@v1.14.16 \
       github.com/golang-migrate/migrate/v4@v4.15.2
```

> ⚠️ **`mattn/go-sqlite3` exige `CGO_ENABLED=1`.** Si tu `go build` empieza a
> tardar el triple y a pedirte un compilador de C, no está roto: acabas de
> adoptar una dependencia nativa. Ese peso es real, se va a hacer insoportable en
> `be09` al construir la imagen, y es exactamente la medición que `D19` deja
> pendiente para esa fase. No lo cambies todavía: la incomodidad es el dato.

### 5.3 Las migraciones

`server/migrations/postgres/000001_initial_schema.up.sql`:

```sql
-- Esquema inicial del dominio de rifas.
--
-- Convenciones (prompts/diccionario-codigo-ingles.md §7bis.2):
--   tablas en plural y snake_case; dinero en BIGINT de centavos, coherente
--   con A10; instantes en TIMESTAMPTZ, coherente con el contrato de be00.

CREATE TABLE users (
    id            BIGSERIAL PRIMARY KEY,
    email         TEXT        NOT NULL UNIQUE,
    -- Todavía guarda la contraseña en claro, igual que el mock: be04 la
    -- convierte en un hash bcrypt y renombra la columna en su migración.
    -- 💸 Deuda declarada y fechada: se paga en be04.
    password      TEXT        NOT NULL,
    name          TEXT        NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE raffles (
    id            BIGSERIAL PRIMARY KEY,
    name          TEXT        NOT NULL,
    lottery_id    TEXT        NOT NULL,
    -- El instante de cierre, con zona. La autoridad temporal se muda al
    -- servidor en be06; acá solo se elige el tipo que lo hará posible.
    closes_at     TIMESTAMPTZ NOT NULL,
    -- Dinero en centavos enteros. Un NUMERIC sería defendible; un
    -- DOUBLE PRECISION sería un bug esperando su turno (ver A10).
    number_price  BIGINT      NOT NULL CHECK (number_price >= 0),
    base_prize    BIGINT      NOT NULL CHECK (base_prize >= 0),
    status        TEXT        NOT NULL
                  CHECK (status IN ('draft','open','closed','resolved','settled')),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE participants (
    id            BIGSERIAL PRIMARY KEY,
    name          TEXT        NOT NULL,
    document      TEXT,
    phone         TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE raffle_numbers (
    id             BIGSERIAL PRIMARY KEY,
    raffle_id      BIGINT      NOT NULL REFERENCES raffles(id) ON DELETE CASCADE,
    -- TEXT y no INTEGER, y no es negociable: el contrato de be00 fija que
    -- el número viaja como string con sus ceros a la izquierda ("0347").
    -- Un INTEGER acá convierte "0347" en 347 y rompe el tablero de la Fase 5
    -- sin producir un solo error en consola.
    number         TEXT        NOT NULL,
    status         TEXT        NOT NULL
                   CHECK (status IN ('available','reserved','sold')),
    participant_id BIGINT      REFERENCES participants(id),
    reserved_until TIMESTAMPTZ,
    sold_at        TIMESTAMPTZ,
    -- Que un número no exista dos veces en la misma rifa. Esto NO es todavía
    -- la defensa contra la venta duplicada —el número ya existe y la venta lo
    -- ACTUALIZA, no lo inserta—; esa defensa es el contenido de be05.
    CONSTRAINT raffle_numbers_unique_per_raffle UNIQUE (raffle_id, number)
);

CREATE INDEX raffle_numbers_by_raffle_status
    ON raffle_numbers (raffle_id, status);

CREATE TABLE settlements (
    id               BIGSERIAL PRIMARY KEY,
    -- Una liquidación por rifa. Es la mitad barata de la idempotencia que
    -- be07 va a exigir: acá la base ya impide la segunda.
    raffle_id        BIGINT      NOT NULL UNIQUE REFERENCES raffles(id),
    winning_number   TEXT        NOT NULL,
    total_collected  BIGINT      NOT NULL,
    prize_amount     BIGINT      NOT NULL,
    margin           BIGINT      NOT NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

`server/migrations/postgres/000001_initial_schema.down.sql`:

```sql
-- El down existe y tiene que funcionar. Una migración sin vuelta es una
-- migración que nadie se atreve a aplicar un viernes.
DROP TABLE IF EXISTS settlements;
DROP TABLE IF EXISTS raffle_numbers;
DROP TABLE IF EXISTS participants;
DROP TABLE IF EXISTS raffles;
DROP TABLE IF EXISTS users;
```

Y ahora **el mismo esquema para SQLite**, que es donde la costura deja de ser
teórica. `server/migrations/sqlite/000001_initial_schema.up.sql`:

```sql
-- El mismo esquema, en el dialecto del otro motor.
-- Cada diferencia de este archivo está medida y explicada en
-- server/evidence/divergencias.md. No hay ninguna por gusto.

-- Las claves foráneas están APAGADAS por defecto en SQLite. Hay que
-- encenderlas por conexión, no por base — un olvido acá y las FK de arriba
-- son decorativas. Ver 5.4: va en el DSN.
PRAGMA foreign_keys = ON;

CREATE TABLE users (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,  -- no existe BIGSERIAL
    email      TEXT    NOT NULL UNIQUE,
    password   TEXT    NOT NULL,
    name       TEXT    NOT NULL,
    created_at TEXT    NOT NULL DEFAULT (datetime('now'))  -- no existe now()
);

CREATE TABLE raffles (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    name         TEXT    NOT NULL,
    lottery_id   TEXT    NOT NULL,
    -- ⚠️ Acá está la divergencia grande: SQLite NO TIENE tipo de fecha.
    -- "TEXT" no es una elección de estilo, es la única opción honesta —
    -- y significa que la comparación de instantes es comparación de
    -- CADENAS. Lo demuestra la pieza forense de esta fase.
    closes_at    TEXT    NOT NULL,
    number_price INTEGER NOT NULL CHECK (number_price >= 0),
    base_prize   INTEGER NOT NULL CHECK (base_prize >= 0),
    status       TEXT    NOT NULL
                 CHECK (status IN ('draft','open','closed','resolved','settled')),
    created_at   TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at   TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE participants (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    name       TEXT    NOT NULL,
    document   TEXT,
    phone      TEXT,
    created_at TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE raffle_numbers (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    raffle_id      INTEGER NOT NULL REFERENCES raffles(id) ON DELETE CASCADE,
    number         TEXT    NOT NULL,
    status         TEXT    NOT NULL
                   CHECK (status IN ('available','reserved','sold')),
    participant_id INTEGER REFERENCES participants(id),
    reserved_until TEXT,
    sold_at        TEXT,
    CONSTRAINT raffle_numbers_unique_per_raffle UNIQUE (raffle_id, number)
);

CREATE INDEX raffle_numbers_by_raffle_status
    ON raffle_numbers (raffle_id, status);

CREATE TABLE settlements (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    raffle_id       INTEGER NOT NULL UNIQUE REFERENCES raffles(id),
    winning_number  TEXT    NOT NULL,
    total_collected INTEGER NOT NULL,
    prize_amount    INTEGER NOT NULL,
    margin          INTEGER NOT NULL,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);
```

Aplicarlas:

```bash
# Instala el binario de la misma versión que la librería (D20).
go install -tags 'postgres sqlite3' \
  github.com/golang-migrate/migrate/v4/cmd/migrate@v4.15.2

migrate -path migrations/postgres -database "$DATABASE_URL" up
migrate -path migrations/postgres -database "$DATABASE_URL" version
migrate -path migrations/postgres -database "$DATABASE_URL" down 1   # y vuelve
```

> ⚠️ **El estado `dirty`.** Si una migración falla a la mitad, `golang-migrate`
> marca la base como sucia y **se niega a seguir** hasta que alguien decida qué
> pasó. Es lo correcto y es lo que más asusta la primera vez. Se sale con
> `migrate … force <versión>`, después de mirar con `psql` en qué quedó de
> verdad el esquema. Provócalo a propósito en el ejercicio 14: es mejor conocerlo
> un martes de laboratorio que un viernes de producción.

### 5.4 El pool y la costura: `internal/storage`

```go
// server/internal/storage/storage.go
package storage

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/jmoiron/sqlx"

	// Los drivers se importan SOLO por su efecto secundario: su init() se
	// registra en database/sql. El guion bajo es obligatorio porque no
	// usamos ningún identificador del paquete. Es el patrón más raro que
	// tiene Go para quien llega de fuera, y es idiomático.
	_ "github.com/lib/pq"
	_ "github.com/mattn/go-sqlite3"
)

// Dialect nombra al motor. Que sea un tipo propio y no un string suelto es
// deliberado: la costura tiene que ser buscable con grep y verificable por
// el compilador.
type Dialect string

const (
	Postgres Dialect = "postgres"
	SQLite   Dialect = "sqlite3"
)

// DB envuelve el pool junto con el dialecto activo. TODA divergencia entre
// motores pasa por acá o por be-a-03; ninguna se resuelve improvisando un
// if en medio de un handler.
type DB struct {
	*sqlx.DB
	Dialect Dialect
}

// Open abre el pool y verifica que responda.
//
// 🧠 sqlx.Open NO conecta: solo valida el DSN y prepara el pool. La primera
// conexión real ocurre en la primera consulta — o en el Ping de acá. Sin
// este Ping, un DATABASE_URL equivocado no falla al arrancar: falla en la
// primera petición de un usuario, media hora después del despliegue.
func Open(ctx context.Context, url string) (*DB, error) {
	dialect := Postgres
	driver := "postgres"
	if strings.HasPrefix(url, "file:") || strings.HasSuffix(url, ".db") || url == ":memory:" {
		dialect = SQLite
		driver = "sqlite3"
	}

	db, err := sqlx.Open(driver, url)
	if err != nil {
		return nil, fmt.Errorf("abriendo el pool (%s): %w", dialect, err)
	}

	if dialect == Postgres {
		// Los tres parámetros que nadie configura hasta que se cae algo.
		// 25 conexiones es una elección conservadora para un monolito
		// contra un Postgres de 100: deja aire para migraciones, psql y
		// una segunda réplica.
		db.SetMaxOpenConns(25)
		db.SetMaxIdleConns(25)
		db.SetConnMaxLifetime(5 * time.Minute)
	} else {
		// SQLite escribe de a UNO. Un pool de 25 conexiones contra un
		// archivo no da paralelismo: da SQLITE_BUSY. Esto ya es un
		// adelanto de la regla del motor de be08.
		db.SetMaxOpenConns(1)
	}

	pingCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	if err := db.PingContext(pingCtx); err != nil {
		return nil, fmt.Errorf("la base no responde (%s): %w", dialect, err)
	}

	return &DB{DB: db, Dialect: dialect}, nil
}

// Now devuelve la expresión SQL del instante actual según el motor.
// Es la primera costura explícita y la más pequeña. Que exista una función
// para esto —en vez de escribir now() y que SQLite reviente— es todo el
// método de la fase en tres líneas.
func (db *DB) Now() string {
	if db.Dialect == SQLite {
		return "datetime('now')"
	}
	return "now()"
}

// HealthCheck es lo que consulta GET /health.
func (db *DB) HealthCheck(ctx context.Context) error {
	ctx, cancel := context.WithTimeout(ctx, 2*time.Second)
	defer cancel()
	return db.PingContext(ctx)
}
```

Y la conexión de SQLite necesita un DSN con dos parámetros que casi nadie pone:

```go
// Para pruebas. Los dos parámetros son obligatorios y por motivos distintos:
//   _foreign_keys=on  → sin esto las FK son decorativas (SQLite las apaga
//                       por defecto, y por conexión, no por base).
//   _busy_timeout     → sin esto, dos escrituras simultáneas devuelven
//                       SQLITE_BUSY al instante en vez de esperar su turno.
const testDSN = "file::memory:?cache=shared&_foreign_keys=on&_busy_timeout=5000"
```

### 5.5 `GET /health` crece, y hay que decidir `200` o `503`

`be01` dejó la pregunta abierta y el ejercicio 31 la planteó. Se cierra acá,
porque el orquestador de `be09` va a actuar según esta respuesta.

> 🧭 **Decisión: `/health` responde `503` si la base no responde.** El endpoint
> reporta si el servicio **puede hacer su trabajo**, no si el proceso está vivo.
> Un backend de rifas sin base no puede hacer absolutamente nada útil: mantenerlo
> en `200` solo consigue que el balanceador le siga mandando tráfico para que
> falle petición por petición.

El matiz que evita el desastre —y que hay que escribir junto a la decisión— es
que **reiniciar el contenedor no arregla una base caída**. Si el orquestador usa
este endpoint como *liveness probe*, va a reiniciar el backend en bucle mientras
Postgres se recupera. Este `/health` es una *readiness probe*: "no me mandes
tráfico". La distinción se implementa en `be09` con dos rutas, y por eso conviene
que el nombre sea explícito desde ya.

```go
// server/internal/http/health.go
package httpapi

import (
	"net/http"

	"github.com/rifas-y-chances/raffles-api/internal/storage"
)

func healthHandler(db *storage.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// El contexto de la petición manda: si el cliente cortó, el Ping
		// se cancela y no gastamos una conexión del pool al pedo.
		if err := db.HealthCheck(r.Context()); err != nil {
			writeJSON(w, http.StatusServiceUnavailable, map[string]string{
				"status":   "degraded",
				"database": "unreachable",
			})
			return
		}
		writeJSON(w, http.StatusOK, map[string]string{
			"status":   "ok",
			"database": "ok",
		})
	}
}
```

### 5.6 El primer store: `internal/raffle/store.go`

Acá aparece la arquitectura en capas que sostiene el resto del track. Hoy solo
existe la capa de abajo.

```go
// server/internal/raffle/raffle.go
package raffle

import "time"

// Raffle es el tipo del dominio. Las etiquetas JSON son la FRONTERA DEL
// CONTRATO: lo que el frontend ve, y por lo tanto lo que no se puede
// cambiar (be00, régimen estricto). Las etiquetas db mapean a columnas
// snake_case. Que las dos convivan en la misma línea es la costura entre
// las dos convenciones, y está en un solo lugar a propósito.
type Raffle struct {
	ID          int64     `json:"id"           db:"id"`
	Name        string    `json:"name"         db:"name"`
	LotteryID   string    `json:"lotteryId"    db:"lottery_id"`
	ClosesAt    time.Time `json:"closesAt"     db:"closes_at"`
	NumberPrice int64     `json:"numberPrice"  db:"number_price"`
	BasePrize   int64     `json:"basePrize"    db:"base_prize"`
	Status      string    `json:"status"       db:"status"`
}

// Store es la interfaz de persistencia, declarada acá —del lado del
// CONSUMIDOR— y no junto a su implementación. Es la consecuencia práctica
// de que las interfaces de Go sean implícitas: el service de be03 va a
// depender de estos cuatro métodos, no de Postgres.
type Store interface {
	List(ctx context.Context) ([]Raffle, error)
	FindByID(ctx context.Context, id int64) (Raffle, error)
	Create(ctx context.Context, r Raffle) (Raffle, error)
	Update(ctx context.Context, r Raffle) (Raffle, error)
}
```

```go
// server/internal/raffle/store.go
package raffle

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"github.com/rifas-y-chances/raffles-api/internal/storage"
)

// ErrNotFound es un error de DOMINIO. El resto de la aplicación no debe
// saber que existe sql.ErrNoRows: si el handler de be03 tuviera que
// preguntar por un error de database/sql, la capa de datos habría dejado
// de ser una capa.
var ErrNotFound = errors.New("la rifa no existe")

// sqlStore sirve a los dos motores. El diccionario reserva el nombre
// <motor><Dominio>Store para las implementaciones específicas de un motor,
// que aparecerán en be05 cuando FOR UPDATE obligue a separarlas.
type sqlStore struct {
	db *storage.DB
}

func NewStore(db *storage.DB) Store {
	return &sqlStore{db: db}
}

func (s *sqlStore) List(ctx context.Context) ([]Raffle, error) {
	// El SQL se escribe a mano y queda a la vista. Es el objetivo
	// pedagógico de la fase (D17): un ORM escondería justo esto.
	//
	// SELECT con columnas explícitas y nunca *: el día que alguien agregue
	// una columna, un SELECT * cambia la forma del resultado sin que nadie
	// toque este archivo.
	const query = `
		SELECT id, name, lottery_id, closes_at, number_price, base_prize, status
		FROM raffles
		ORDER BY id`

	raffles := []Raffle{} // slice vacío, NO nil: json.Marshal(nil) da "null"
	                      // y el contrato de be00 exige [] cuando no hay nada.
	if err := s.db.SelectContext(ctx, &raffles, query); err != nil {
		return nil, fmt.Errorf("listando rifas: %w", err)
	}
	return raffles, nil
}

func (s *sqlStore) FindByID(ctx context.Context, id int64) (Raffle, error) {
	query := s.db.Rebind(`
		SELECT id, name, lottery_id, closes_at, number_price, base_prize, status
		FROM raffles
		WHERE id = ?`)

	var r Raffle
	err := s.db.GetContext(ctx, &r, query, id)
	if errors.Is(err, sql.ErrNoRows) {
		// Traducción de error de infraestructura a error de dominio.
		// Esta línea es la frontera de la capa.
		return Raffle{}, ErrNotFound
	}
	if err != nil {
		return Raffle{}, fmt.Errorf("buscando la rifa %d: %w", id, err)
	}
	return r, nil
}

func (s *sqlStore) Create(ctx context.Context, r Raffle) (Raffle, error) {
	// RETURNING y no LastInsertId, y la razón es medible:
	// lib/pq NO IMPLEMENTA LastInsertId — devuelve el error
	// "LastInsertId is not supported by this driver". mattn/go-sqlite3 sí
	// lo implementa. Escribir el código "portable" con LastInsertId
	// produce entonces algo que pasa en las pruebas (SQLite) y explota en
	// producción (Postgres): el caso exacto que be08 convierte en regla.
	//
	// RETURNING funciona en los dos, y por eso D18 fija SQLite >= 3.35,
	// que es la versión donde llegó. Ver server/evidence/divergencias.md.
	query := s.db.Rebind(`
		INSERT INTO raffles (name, lottery_id, closes_at, number_price, base_prize, status)
		VALUES (?, ?, ?, ?, ?, ?)
		RETURNING id, name, lottery_id, closes_at, number_price, base_prize, status`)

	var created Raffle
	err := s.db.GetContext(ctx, &created, query,
		r.Name, r.LotteryID, r.ClosesAt, r.NumberPrice, r.BasePrize, r.Status)
	if err != nil {
		return Raffle{}, fmt.Errorf("creando la rifa %q: %w", r.Name, err)
	}
	return created, nil
}

func (s *sqlStore) Update(ctx context.Context, r Raffle) (Raffle, error) {
	query := s.db.Rebind(`
		UPDATE raffles
		SET name = ?, lottery_id = ?, closes_at = ?, number_price = ?,
		    base_prize = ?, status = ?, updated_at = ` + s.db.Now() + `
		WHERE id = ?
		RETURNING id, name, lottery_id, closes_at, number_price, base_prize, status`)

	var updated Raffle
	err := s.db.GetContext(ctx, &updated, query,
		r.Name, r.LotteryID, r.ClosesAt, r.NumberPrice, r.BasePrize, r.Status, r.ID)
	if errors.Is(err, sql.ErrNoRows) {
		return Raffle{}, ErrNotFound
	}
	if err != nil {
		return Raffle{}, fmt.Errorf("actualizando la rifa %d: %w", r.ID, err)
	}
	return updated, nil
}
```

> 🧠 **Fíjate en `s.db.Now()` dentro del `UPDATE`.** Es la costura otra vez, y
> ahora se ve por qué tenía que existir: `now()` no es SQL portable. Es
> concatenación de string en una consulta, que en cualquier otro contexto sería
> un pecado — pero acá el valor sale de una función del propio código y no de
> una entrada del usuario. **Los datos siempre van por placeholder, sin
> excepción**; los fragmentos de dialecto salen de la costura y de ningún otro
> lado. `be-a-08` trata la distinción con el detalle que merece.

### 5.7 Las pruebas: la capa se prueba desde Go, no desde HTTP

```go
// server/internal/raffle/store_test.go
package raffle_test

import (
	"context"
	"testing"
	"time"

	"github.com/rifas-y-chances/raffles-api/internal/raffle"
	"github.com/rifas-y-chances/raffles-api/internal/storage"
)

// openTestDB abre el motor que indique TEST_DATABASE_URL, y si no hay
// ninguno, SQLite en memoria. Que el MISMO test corra contra los dos
// motores es lo que hace que la fase pueda demostrar su tesis.
//
//   go test ./...                                              → SQLite
//   TEST_DATABASE_URL="postgres://…" go test ./...             → Postgres
func openTestDB(t *testing.T) *storage.DB {
	t.Helper()
	url := os.Getenv("TEST_DATABASE_URL")
	if url == "" {
		url = "file::memory:?cache=shared&_foreign_keys=on&_busy_timeout=5000"
	}
	db, err := storage.Open(context.Background(), url)
	if err != nil {
		t.Fatalf("no se pudo abrir la base de prueba: %v", err)
	}
	// t.Cleanup corre al terminar el test, pase lo que pase. Es el defer
	// de los tests y evita bases colgadas entre casos.
	t.Cleanup(func() { db.Close() })
	applyMigrations(t, db)
	return db
}

func TestCreateAndFind(t *testing.T) {
	db := openTestDB(t)
	store := raffle.NewStore(db)
	ctx := context.Background()

	closesAt, _ := time.Parse(time.RFC3339, "2026-08-30T22:00:00-05:00")

	created, err := store.Create(ctx, raffle.Raffle{
		Name:        "Rifa fin de mes",
		LotteryID:   "boyaca",
		ClosesAt:    closesAt,
		NumberPrice: 5000,
		BasePrize:   500000,
		Status:      "open",
	})
	if err != nil {
		t.Fatalf("Create devolvió error: %v", err)
	}
	if created.ID == 0 {
		t.Fatal("Create no devolvió el id asignado por la base")
	}

	found, err := store.FindByID(ctx, created.ID)
	if err != nil {
		t.Fatalf("FindByID devolvió error: %v", err)
	}
	// Comparar instantes con == compara también el huso y el reloj
	// monótono: casi siempre falla por razones que no son las del test.
	// time.Equal compara el INSTANTE, que es lo que nos importa.
	if !found.ClosesAt.Equal(closesAt) {
		t.Errorf("closesAt no coincide: guardé %s, leí %s", closesAt, found.ClosesAt)
	}
}

func TestFindByIDNotFound(t *testing.T) {
	store := raffle.NewStore(openTestDB(t))
	if _, err := store.FindByID(context.Background(), 9999); err != raffle.ErrNotFound {
		t.Errorf("esperaba ErrNotFound, obtuve %v", err)
	}
}
```

> ⚠️ **`TestCreateAndFind` es el primer test que va a comportarse distinto según
> el motor**, y no por un bug tuyo. Córrelo con los dos y anota qué pasa con
> `ClosesAt`. Esa diferencia es la pieza forense.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. `LastInsertId` en vez de `RETURNING`.** Síntoma: los tests pasan en SQLite y
en producción todo `POST` devuelve `500` con
`LastInsertId is not supported by this driver`. Causa: `lib/pq` no lo implementa
—no es un bug, es que el protocolo de Postgres no lo ofrece— y `mattn/go-sqlite3`
sí. Fix mínimo: `RETURNING id`. Este error es el arquetipo de todo lo que `be08`
va a formalizar: **una suite verde contra el motor equivocado es peor que no
tener suite, porque da permiso para desplegar**.

**2. Devolver `nil` en vez de un slice vacío.** Síntoma: el frontend recibe
`null` donde esperaba `[]`, y `raffles.map is not a function` explota en el
componente. Causa: `var raffles []Raffle` sin inicializar serializa a `null`.
Fix: `raffles := []Raffle{}`. Contrato de `be00`, régimen estricto, y una línea
de código.

**3. Placeholders escritos a mano para un motor.** Síntoma: `$1` funciona en
Postgres y en SQLite devuelve `near "$1": syntax error`. Causa: saltarse
`Rebind`. Fix: escribir siempre con `?` y pasar por `Rebind`. La regla operativa
que conviene adoptar: **si un archivo de store contiene un `$1` literal, está
mal**; ese es un `grep` que vale la pena tener en la revisión de código.

**4. Confiar en que SQLite valida tipos.** Síntoma: un test inserta
`number_price` como texto, pasa feliz, y el mismo caso revienta en Postgres con
`invalid input syntax for type bigint`. Causa: la **afinidad de tipos** de
SQLite, que acepta casi cualquier cosa en casi cualquier columna. Fix: no hay fix
en el código — hay una regla, y es la de `be08`.

**5. `*sql.Rows` sin cerrar.** Síntoma: después de unos minutos de tráfico, todo
se cuelga esperando una conexión. Causa: un `Query` cuyo `Rows` nadie cerró
retiene su conexión para siempre. Fix: `defer rows.Close()` sin excepción, o usar
`Select`/`Get` de `sqlx`, que cierran solos — que es una de las razones de usar
`sqlx` y no `database/sql` pelado.

### 🩻 Pieza forense de esta fase

**La misma consulta, dos motores, dos resultados.** No se argumenta la
diferencia: se muestra. Guarda todo en `server/evidence/divergencias.md` con la
salida pegada — ese archivo es un entregable, y es el que `be08` va a citar para
justificar su regla.

*Divergencia 1 — el motor que acepta cualquier cosa.* La misma sentencia contra
los dos:

```sql
INSERT INTO raffles (name, lottery_id, closes_at, number_price, base_prize, status)
VALUES ('Rifa de prueba', 'boyaca', '2026-08-30T22:00:00-05:00', 'mucha plata', 0, 'open');
```

Postgres la rechaza: `invalid input syntax for type bigint: "mucha plata"`.
SQLite **la acepta y guarda el texto** en una columna `INTEGER`, por afinidad de
tipos. Ahora `SELECT sum(number_price)` en cada motor y anota qué devuelve cada
uno. Una de las dos bases acaba de mentir sobre cuánto dinero hay.

*Divergencia 2 — el instante que es una cadena.* Esta es la principal, porque
toca el corazón del dominio. Inserta la misma rifa en los dos motores con
`closes_at = '2026-08-30T22:00:00-05:00'` —que es el **31 de agosto a las 03:00
UTC**— y corre en ambos:

```sql
SELECT name FROM raffles WHERE closes_at > '2026-08-31T01:00:00Z';
```

PostgreSQL entiende los dos valores como instantes, compara 03:00Z contra 01:00Z
y **devuelve la rifa**. SQLite compara **cadena contra cadena**: `'2026-08-30…'`
contra `'2026-08-31…'`, ve que `30 < 31` y **no devuelve nada**. Los dos motores
funcionan perfectamente según su especificación, y tu regla de negocio —"no se
vende después del cierre"— da resultados opuestos según dónde corra.

Escribe el test que demuestra esto y déjalo en el repositorio. Es el primer
miembro del par de pruebas contradictorias que `be08` va a exigir.

*Divergencia 3 — el `RETURNING` que casi no está.* Comprueba tu versión de
SQLite con `select sqlite_version();`. Si es anterior a 3.35, `RETURNING` falla y
`Create` no compila ni corre. Anota la versión que tienes y por qué `D18` fija
esa cota — no es un número redondo elegido al azar: es marzo de 2021, cuando
llegó la sentencia.

*Divergencia 4 — el bloqueo que no existe.* Solo míralo, no lo resuelvas:

```sql
BEGIN; SELECT * FROM raffle_numbers WHERE id = 1 FOR UPDATE;
```

Postgres bloquea la fila y espera. SQLite responde
`near "FOR": syntax error`. Anótalo y cierra la terminal: resolverlo es la fase
⭐ `be05`, y saber que el problema existe es todo lo que esta fase necesita.

*Divergencia 5 — las claves foráneas apagadas.* Con `_foreign_keys=on` fuera del
DSN, inserta un `raffle_numbers` con un `raffle_id` que no existe. SQLite lo
acepta sin chistar; Postgres lo rechaza. Vuelve a ponerlo y repite. Anota cuántas
de tus pruebas actuales seguirían pasando con las FK apagadas.

*Divergencia 6 y 7 — las tuyas.* Busca dos más. Candidatos honestos: el
comportamiento de `ORDER BY` con mayúsculas y minúsculas, qué hace cada motor con
un `ALTER TABLE … DROP COLUMN`, cómo se comporta `LIKE`, o si `AUTOINCREMENT`
reutiliza ids después de un `DELETE`. Mídelas, no las busques en un blog.

*El círculo, tercera parte.* En `be00` seguiste un `X-Request-Id` desde la
consola del navegador hasta la nada. En `be01` llegó al log del servidor. Ahora
agrégalo al log de la consulta: un `Printf` con el id, el SQL y la duración
dentro del store, temporal y solo para verlo funcionar.

```go
// Temporal, para la pieza forense.
start := time.Now()
err := s.db.SelectContext(ctx, &raffles, query)
log.Printf("[req-id %s] SQL %s → %v en %s",
    httpapi.RequestIDFrom(ctx), "SELECT … FROM raffles", err, time.Since(start))
```

Ese es el recorrido completo que el track prometía: **consola del navegador →
línea de log del servidor → consulta SQL con su tiempo**. Quítalo después: el
lugar correcto para esto es un middleware de instrumentación, y eso es
`be-a-07`.

---

## 🧪 7. Ejercicios (33)

**🟢 Fácil (1–8)**

1. Levanta Postgres 13 en contenedor y verifica la versión con `psql`.
2. Aplica las migraciones de Postgres, comprueba el `version`, hazles `down 1` y vuelve a subirlas.
3. Verifica en `psql` con `\d raffles` que los tipos son los que escribiste, no los que creías escribir.
4. Corre `go test ./...` contra SQLite en memoria y comprueba que pasa.
5. Corre la misma suite con `TEST_DATABASE_URL` apuntando a Postgres y anota cuáles pasan y cuáles no.
6. Apaga el contenedor de Postgres y comprueba que `GET /health` responde `503` con `database: unreachable`.
7. Confirma que `Rebind` produce `$1` contra Postgres y `?` contra SQLite, imprimiendo la consulta antes de ejecutarla.
8. Comprueba con `select sqlite_version();` que tu SQLite es 3.35 o superior, y explica en dos líneas por qué importa.

**🟡 Intermedio (9–19)**

9. Agrega `NumberStore` con `ListByRaffle` y su test, respetando que `number` es `TEXT`.
10. **Diagnóstico.** Cambia `raffles := []Raffle{}` por `var raffles []Raffle`, serializa el resultado y explica qué le pasaría al componente de la Fase 4. Sé específico sobre qué línea del frontend rompe.
11. **Diagnóstico.** Reemplaza `RETURNING` por `LastInsertId` en `Create` y corre la suite contra los dos motores. Pega las dos salidas y explica por qué esto es peligroso y no solo molesto.
12. Escribe la migración `000002` que agrega un índice sobre `raffles(status)`, en los dos dialectos, con su `down`.
13. Mide con `EXPLAIN ANALYZE` una consulta por `status` antes y después de ese índice, sobre una tabla con al menos mil filas.
14. **Diagnóstico.** Provoca a propósito un estado `dirty`: escribe una migración con un error de sintaxis a la mitad, aplícala, y sal del estado con `force`. Documenta el procedimiento como si fuera un runbook.
15. Escribe la Divergencia 1 de la pieza forense como test de Go, con las dos aserciones opuestas y un comentario que explique por qué contradecirse es correcto.
16. Configura `SetMaxOpenConns(1)` contra Postgres y observa qué pasa con veinte peticiones concurrentes a `/health`. Mide los tiempos.
17. **Diagnóstico.** Escribe un `Query` sin `defer rows.Close()`, lánzalo en bucle y observa cómo se agota el pool. Anota el síntoma exacto que verías en producción.
18. Agrega a `Raffle` un campo `CreatedAt` con su etiqueta JSON y decide, citando `be00`, si eso rompe el contrato o es régimen de crecimiento.
19. **Diagnóstico.** Quita `_foreign_keys=on` del DSN de pruebas y determina cuántos tests siguen pasando. Explica qué te dice ese número sobre tu suite.

**🟠 Difícil (20–28)**

20. **Diagnóstico.** Ejecuta la Divergencia 2 completa (el instante que es una cadena) y escribe `server/evidence/divergencias.md` con la evidencia de ambos motores. Este es el entregable central de la fase.
21. Encuentra las divergencias 6 y 7 por tu cuenta, con evidencia medida, y agrégalas al documento.
22. **Diagnóstico.** Escribe una consulta que devuelva el número correcto en SQLite y el incorrecto en Postgres. Sí, en ese sentido: la asimetría no es siempre a favor de Postgres, y encontrar el caso contrario es lo que hace honesta la tesis de la fase.
23. Implementa `Now()` para un tercer motor hipotético (MySQL) y enumera todo lo demás que habría que tocar. Usa esa lista para argumentar por escrito cuánta portabilidad daba de verdad la costura.
24. **Diagnóstico.** El `UPDATE` de `sqlStore` concatena `s.db.Now()` en la consulta. Construye el caso en que esa concatenación sería una vulnerabilidad de inyección y demuestra por qué acá no lo es. Después escribe la regla que separa los dos casos.
25. Instrumenta el store con la duración de cada consulta y el `X-Request-Id`, siguiendo la tercera parte de la pieza forense, y déjalo detrás de una variable de entorno `SQL_DEBUG`.
26. **Diagnóstico.** Con `SQL_DEBUG` activo, encuentra la consulta más lenta de la suite de tests y explica por qué lo es.
27. Argumenta por escrito la decisión contraria a la de la fase: DDL en subconjunto común. Enumera exactamente qué habría que sacrificar del esquema de 5.3 y decide si en algún proyecto real valdría la pena.
28. **Diagnóstico.** Simula que Postgres se cae a mitad de una consulta larga (mata el contenedor). Determina qué error recibe Go, cuánto tarda en darse cuenta, y qué de eso controlan `SetConnMaxLifetime` y los timeouts.

**🔴 Muy difícil (29–33)**

29. Diseña el mecanismo que garantiza que las migraciones de los dos dialectos no diverjan: qué prueba lo detectaría, en qué momento correría, y qué le impediría a alguien saltárselo. Impleméntalo aunque sea de forma tosca.
30. **Diagnóstico + regresión.** Te entregan este ticket: *"desde ayer, las rifas creadas aparecen con la hora de cierre corrida una hora"*. Con lo que sabes de la Divergencia 2, enumera las cinco causas posibles ordenadas por probabilidad, di cómo descartarías cada una con una sola consulta, y escribe la prueba de regresión.
31. Escribe el par de pruebas contradictorias que `be08` va a necesitar: una que **pase en SQLite y falle en Postgres**, y otra que haga exactamente lo contrario. Documenta ambas con su justificación.
32. Toma la interfaz `Store` y argumenta si debería vivir en el paquete `raffle` o en el paquete que la consume. Defiende las dos posturas con el argumento de las interfaces implícitas y decide con un criterio operativo, no estético.
33. **Post-mortem.** Escribe el post-mortem del incidente ficticio *"la suite estaba verde y el despliegue rompió la creación de rifas"*, con causa raíz en `LastInsertId`. Según la guía §13: síntoma, evidencia, causa raíz, corrección, prueba de regresión, prevención. La prevención tiene que ser una regla verificable, no "tener más cuidado".

**🔥 Opcionales**

- 🔥 Reescribe `sqlStore` con GORM y compara: líneas de código, SQL generado (actívale el log), y —lo importante— qué le pasa a las divergencias 1 a 5. ¿El ORM las resuelve, las esconde o las empeora?
- 🔥 Sustituye `mattn/go-sqlite3` por `modernc.org/sqlite` y mide el tiempo de `go build` y `go test` antes y después. Guarda los números: `be09` los va a pedir.
- 🔥 Agrega `pgx` como driver alternativo de Postgres y mide si algo cambia en las divergencias. Argumenta si valdría la pena migrar desde `lib/pq` en un sistema real.

---

## 📚 8. Referencias

**Documentación oficial**
- https://pkg.go.dev/database/sql — y sobre todo la sección sobre el pool y el manejo de `Rows`.
- https://go.dev/doc/database/ — la guía oficial de acceso a datos, corta y con las trampas clásicas.
- https://jmoiron.github.io/sqlx/ — la guía de `sqlx`. `Rebind`, `Get`, `Select` y `StructScan` son el 90 % de lo que vas a usar.
- https://www.postgresql.org/docs/13/ — fija la versión 13 en la URL; la documentación de Postgres cambia de una versión a otra en detalles que importan.
- https://www.sqlite.org/datatype3.html — la afinidad de tipos, que es la Divergencia 1 explicada por sus propios autores. Léela entera: son diez minutos y explica la mitad de la fase.
- https://www.sqlite.org/lang_returning.html — `RETURNING`, con su nota de versión.
- https://www.sqlite.org/quirks.html — el documento donde SQLite enumera honestamente en qué se aparta de todos los demás. Es el mejor material de esta fase.
- https://github.com/golang-migrate/migrate — el CLI, el estado `dirty` y el formato de los archivos.

**Libros**
- *Designing Data-Intensive Applications* (Martin Kleppmann) — los capítulos 2 y 7. No trata de portabilidad, pero es el mejor texto sobre por qué las garantías de una base no son intercambiables.
- *The Art of PostgreSQL* (Dimitri Fontaine) — para el argumento contrario al de esta fase: aprovechar el motor a fondo en vez de escribir para el mínimo común. Vale la pena leerlo con esa tensión en mente.

**Video / apoyo**
- Busca "SQLite quirks" y "Postgres timestamptz explained" en YouTube. Para lo segundo, guárdate el mejor que encuentres: `be06` lo va a necesitar.

**Orden de lectura sugerido:** `datatype3.html` de SQLite primero, que explica la
Divergencia 1 antes de que la veas → la guía de `sqlx`, que es corta → la
documentación del pool de `database/sql` → y `be-a-03` para el diccionario
completo de divergencias, que es donde vive el detalle que acá solo se mide.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros son de memoria y pueden ser inexactas. La documentación de
> Postgres tiene una versión por URL — si aterrizas en la última, cambia el
> número a 13 antes de creerle. Cualquier discrepancia de versiones la resuelve
> `prompts/decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Tienes una capa de datos real: pool configurado, migraciones versionadas y
reversibles en dos dialectos, el esquema completo del dominio, un store con SQL a
la vista y pruebas que corren contra los dos motores. Y tienes algo más valioso
que el código: **la evidencia medida de que la portabilidad total es un mito**,
guardada en un archivo que `be08` va a citar para convertirla en regla.

`be03` es la bisagra del track. Ahí se implementan los recursos del contrato en
capas —handler → service → store—, se siembra la base desde **tu** `db.json`, y
se apaga `json-server` para levantar el binario de Go en el `3001`. El criterio
de aprobación ya está escrito desde `be00` y no es opinable: `server/smoke.sh`
pasa o no pasa, y la aplicación React no cambia ni un archivo.

> **La señal de que quedó bien:** *"puedo señalar en el código las siete líneas
> donde mi backend sabe contra qué motor está hablando, y puedo demostrar con una
> consulta por qué ninguna de las siete sobra."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be02-la-costura-de-datos -m "be02 cerrada: \
> Postgres 13 en contenedor; migraciones versionadas por dialecto con up y down; \
> esquema completo de las cinco tablas; pool configurado y costura de dialecto; \
> GET /health con 503 decidido y justificado; RaffleStore con sqlx probado desde tests; \
> suite verde contra los dos motores; \
> server/evidence/divergencias.md con las siete divergencias medidas"
> ```
>
> Los commits de la fase llevan su prefijo (`be02: …`) y los de ejercicio su
> número (`be02 ej20: …`). Si un ejercicio merece su propio marcador va en
> `ej/be02/20`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **Registrar en `prompts/diccionario-codigo-ingles.md` §7bis.2** la aclaración de
  nombres de store: `sqlStore` cuando una implementación sirve a los dos motores
  (el caso de esta fase) y `<motor><Dominio>Store` cuando es específica de uno
  (el caso que llega en `be05` con `FOR UPDATE`). Hecho al escribir la fase.
- **Registrar en `prompts/decisiones-y-versiones.md` §7** dos decisiones que esta
  fase cierra y que estaban abiertas: **DDL por dialecto** (que `D20` dejaba a
  criterio de `be02`) y **`/health` responde `503`** (que `be01` dejó al
  ejercicio 31). Las dos afectan a `be09` y conviene que estén en la fuente de
  verdad, no solo en la fase.
- **Registrar en `server/evidence/divergencias.md`** que es entregable citable:
  `be08` lo usa como base de su regla del motor y `be-a-03` lo amplía a
  diccionario completo. Que `be08` no lo reescriba desde cero.
- **La columna `users.password`** queda en claro a propósito, replicando el mock.
  `be04` tiene que renombrarla a `password_hash` en su propia migración
  (`000003`, previsiblemente) y esa migración es parte de cobrar la deuda, no un
  detalle de implementación.
- **`be05` necesita de esta fase:** el índice `raffle_numbers_unique_per_raffle`
  existe, pero **no** protege contra la venta duplicada, porque la venta es un
  `UPDATE` sobre una fila que ya existe. Que `be05` lo diga explícitamente —el
  alumno va a creer que ya está protegido— y decida ahí su propia defensa.
- **`be06` hereda la Divergencia 2** como su gancho de apertura. El caso ya está
  medido acá; `be06` no necesita volver a demostrarlo, sino explicar qué hace
  Postgres *realmente* con `TIMESTAMPTZ`.
- **`be09` hereda dos mediciones pendientes:** el peso de `CGO_ENABLED=1` (que
  esta fase deja sentir sin resolver) y los números del ejercicio 🔥 de
  `modernc.org/sqlite`.
- **Deudas declaradas en esta fase:** 💸 `users.password` en claro (se paga en
  `be04`); 💸 `sslmode=disable` (se retoma en `be09`); 💸 las migraciones se
  aplican a mano en desarrollo (la política de producción se decide en `be09`).
- **Reserva para el cuaderno de incidentes:** `be-04` — *"las rifas se crean con
  la hora corrida"* (categoría 🔥 base de datos, dificultad 🟠), que es la
  Divergencia 2 llegada como ticket vago; y `be-05` — *"todo funciona hasta que
  hay gente"* (categoría 🔥 base de datos, dificultad 🔴), que es el pool agotado
  por `Rows` sin cerrar, con el síntoma clásico de que no se reproduce jamás en
  desarrollo.
FIN_DEL_ARCHIVO
wc -l be02-la-costura-de-datos.md

# --- 2026-09-08T03:56:36 · Fix Go imports and update dictionary
python3 - <<'PY'
import io
p='be02-la-costura-de-datos.md'
s=io.open(p,encoding='utf-8').read()

pairs=[
("""// server/internal/raffle/raffle.go
package raffle

import "time"
""",
 """// server/internal/raffle/raffle.go
package raffle

import (
	"context"
	"time"
)
"""),
("""import (
	"context"
	"testing"
	"time"

	"github.com/rifas-y-chances/raffles-api/internal/raffle"
""",
 """import (
	"context"
	"os"
	"testing"
	"time"

	"github.com/rifas-y-chances/raffles-api/internal/raffle"
"""),
]
for old,new in pairs:
    assert s.count(old)==1, old[:40]
    s=s.replace(old,new)
io.open(p,'w',encoding='utf-8').write(s)

# diccionario: store naming clarification
p2='prompts/diccionario-codigo-ingles.md'
d=io.open(p2,encoding='utf-8').read()
old="| Implementación concreta | `<motor><Dominio>Store` | `postgresRaffleStore` |"
new="| Implementación concreta, un motor | `<motor><Dominio>Store` | `postgresRaffleStore` |\n| Implementación concreta, los dos motores | `sqlStore` en el paquete del dominio | `raffle.sqlStore` |"
assert d.count(old)==1
io.open(p2,'w',encoding='utf-8').write(d.replace(old,new))
print('ok')
PY

# --- 2026-09-08T03:57:09 · Register D24-D27 in decisions file
cd prompts && python3 - <<'PY'
import io
p='decisiones-y-versiones.md'
s=io.open(p,encoding='utf-8').read()
anchor="### 7.2 El `go.mod` de referencia"
assert s.count(anchor)==1
add = """#### D24 — El puerto de transición es el `3011`

**Qué se fijó.** El binario lee `PORT` y su valor por defecto es `3001`. Mientras
el mock siga levantado —`be01` y `be02`— el laboratorio arranca el binario con
`PORT=3011`, para que los dos convivan. Desde `be03` el mock se apaga y el
`3001` es de Go, sin variable de por medio.

📝 **Nota.** No es un cuarto puerto del sistema: es un puerto de andamiaje que
existe durante dos fases y desaparece. El `3001` sigue siendo el `3001`, que es
justamente el punto de `D21`.

**Qué la vuelve revisable.** Que el `3011` esté ocupado en la máquina del alumno.
Cualquier otro sirve: la variable ya lo cubre.

---

#### D25 — El DDL se mantiene por dialecto, no en subconjunto común

**Qué se fijó.** `server/migrations/postgres/` y `server/migrations/sqlite/`, con
los mismos números de versión y los mismos nombres de archivo. `D20` dejaba la
pregunta abierta y `be02` la cierra.

📝 **Por qué.** El mínimo común denominador de PostgreSQL 13 y SQLite 3.35 no
tiene `TIMESTAMPTZ`, `BIGSERIAL` ni índices parciales. Escribir el DDL ahí sería
degradar el motor real para complacer al motor de pruebas. El costo —que los dos
juegos diverjan— se administra con la regla del motor de `be08` y queda a la
vista, en vez de esconderse detrás de una abstracción.

**Qué la vuelve revisable.** Que el mantenimiento de los dos juegos consuma más
tiempo del que enseña. Si pasa, se abandona SQLite antes que el DDL por
dialecto.

---

#### D26 — `GET /health` responde `503` si la base no responde

**Qué se fijó.** El endpoint reporta si el servicio **puede trabajar**, no si el
proceso está vivo: sin base, `503` con `{"status":"degraded"}`. `be01` dejó la
pregunta abierta y `be02` la cierra, porque el orquestador de `be09` actúa según
esa respuesta.

📝 **El matiz que evita el desastre.** Esto es una *readiness probe*, no una
*liveness probe*: reiniciar el contenedor no arregla una base caída. La
separación en dos rutas se implementa en `be09`.

**Qué la vuelve revisable.** Nada previsible dentro del track.

---

#### D27 — La única excepción al "el frontend no se toca": `authService.js`

**Qué se fijó.** El frontend hace login con `GET /users?email=…&password=…`, no
con `POST /login`. En `be04` se modifica **un solo archivo del frontend**,
`src/api/authService.js`, para que llame a `POST /login` con las credenciales en
el cuerpo. No se tocan `apiClient.js` ni sus interceptores, ni `authSlice.js`, ni
ningún componente. El campo `token` de la respuesta conserva nombre y forma.

📝 **Por qué es legítima.** La Fase 2 del track base la anunció textualmente
—*"cuando mañana haya un `POST /login` real, cambia **este** archivo y nada
más"*— y la dejó como ejercicio 🔥. La alternativa —honrar la contraseña en la
query string para siempre— haría inauditable el `be04` que enseña `bcrypt`. Se
registra en `be00` como hallazgo `C-06`, con archivo, fase y límite.

📎 **Consecuencia operativa.** Desde `be04`, el comando que demuestra la regla
lleva una exclusión más:
`git diff pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js'`.

**Qué la vuelve revisable.** Nada. Ampliarla a un segundo archivo exige
renegociarla por escrito en la fase que lo pida.

---

"""
io.open(p,'w',encoding='utf-8').write(s.replace(anchor, add+anchor))
print('ok')
PY
grep -n "^#### D2[4-7]" decisiones-y-versiones.md

# --- 2026-09-09T02:34:36 · Read settlement thunk shape
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs && sed -n '355,395p' 08-liquidacion-calculo-premio.md; echo "=== shape ==="; grep -n -A14 "settlement = {" 08-liquidacion-calculo-premio.md | head -40

# --- 2026-09-09T02:34:43 · Check dashboard settlement fields
grep -n "isWinnerSold\|soldCount\|settledAt\|margin" 09-dashboard.md | head -20

# --- 2026-09-09T02:35:00 · Trace participantId origin in fase 5
grep -n "participantId" 05-venta-de-numeros.md | head -20

# --- 2026-09-09T02:39:50 · 
cat > be03-crud-y-el-reemplazo.md <<'FIN_DEL_ARCHIVO'
# 🪦 Fase be03 — CRUD de rifas y el momento del reemplazo

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Fase be03 de be09 · **10 horas**
> Depende de: be02 — la capa de datos ya existe · Habilita: be04 — Identidad real

---

## 🎯 1. Propósito

Esta es **la bisagra del track**. Todo lo anterior fue preparación: se auditó un
contrato, se levantó un servidor y se construyó una capa de datos. Acá se
implementan los recursos de ese contrato en capas —handler → service → store—, se
siembra la base con **el `db.json` que ya tienes**, y después se hace lo único
que de verdad prueba que el trabajo sirvió:

> 🧭 **Se apaga `json-server`. Se levanta el binario de Go en el puerto `3001`.
> Se recorre la aplicación entera. Y el frontend no cambia ni un archivo.**

El criterio de aprobación no es una opinión ni una sensación: es
`server/smoke.sh`, escrito en `be00` contra el mock, ejecutado sin modificar una
línea contra tu binario. **Pasa o no pasa.**

La deuda 💸 que cobra es la primera de las grandes: `db.json` como almacén. Y con
ella se retira `json-server` del sistema. 🪦

---

## ✅ 2. Qué queda listo al terminar

- [ ] La configuración sale de un único struct validado con `envconfig`, y el
      proceso **falla al arrancar** si falta algo — no en la primera petición.
- [ ] `server/internal/seed/` siembra Postgres desde `mock/db.json`, es
      idempotente y conserva los ids originales.
- [ ] Los doce endpoints del régimen estricto de `server/CONTRACT.md` están
      implementados en capas: handler → service → store.
- [ ] `GET /raffles/:raffleId/numbers/:number` responde `200` — el hallazgo
      `C-01` de `be00` queda cerrado, y es la primera vez que el track **mejora**
      la aplicación sin tocarla.
- [ ] Las dos formas de `404` conviven según `C-04`: cuerpo vacío en los recursos
      automáticos, `{"message":…}` en las tres rutas propias del dominio.
- [ ] `json-server` está apagado y el binario escucha en el `3001`.
- [ ] **`./server/smoke.sh` pasa entero, con las nueve verificaciones en verde.**
- [ ] El recorrido completo de `be00` se repite contra el binario y no hay una
      sola diferencia visible en la aplicación.
- [ ] `git diff pre-backend-go..HEAD -- . ':!server'` no devuelve nada.

---

## 🚫 3. Qué queda fuera por ahora

- **Autenticación real** → `be04`. El login sigue devolviendo el token de mentira
  que el frontend espera, ahora guardado en una columna. Sí: vamos a crear una
  columna para almacenar una credencial falsa, y `be04` la va a borrar. Esa
  columna es la deuda 💸 hecha DDL.
- **El `409` producido por la base** → `be05`. Acá el conflicto de venta lo
  decide un `if` en Go sobre una fila leída antes. Es el **mismo `if` del mock,
  traducido de lenguaje**: sigue sin proteger nada bajo concurrencia, y ahora la
  deuda está escrita en un lenguaje compilado, que es peor porque parece seria.
- **La autoridad del reloj** → `be06`. El cierre sigue evaluándolo el navegador.
- **La liquidación transaccional e idempotente** → `be07`. Acá `POST /settlements`
  inserta y ya.
- **El dashboard y `GET /stats`** → pendiente 🔥 de `be09`. La Fase 9 calcula sus
  métricas en el navegador y ahí se quedan.

---

## 🧠 4. Conceptos mínimos

### Las tres capas, y qué se prohíbe en cada una

La estructura no es decorativa: cada capa tiene una prohibición, y las
prohibiciones son las que hacen que el diseño sirva para algo.

**El handler** habla HTTP y nada más: lee la petición, valida la *forma* de la
entrada, llama al service y traduce lo que vuelve a un código de estado y un
JSON. *Prohibido:* tocar la base, decidir reglas de negocio.

**El service** tiene el dominio: qué transiciones son legales, qué reglas se
verifican, qué operaciones van juntas en una transacción. *Prohibido:* conocer
`http.ResponseWriter`, códigos de estado o headers. Si un service devuelve un
`404`, la capa se rompió.

**El store** habla SQL. *Prohibido:* tomar decisiones de negocio, y —esto es lo
que `be02` ya dejó montado— dejar escapar un `sql.ErrNoRows` hacia arriba: se
traduce a un error de dominio en la frontera.

La prueba de que las capas están bien puestas es un ejercicio mental de treinta
segundos: **si mañana hubiera que exponer esto por gRPC o por una cola de
mensajes, ¿cuánto código se reescribe?** Si la respuesta es "solo los handlers",
está bien. Si hay que tocar el service, no.

### Reimplementar un dialecto ajeno es aburrido y correcto

Vas a escribir código que te va a dar comezón. `DELETE` que devuelve `{}` en vez
de `204`. Dos formas distintas de `404` conviviendo en el mismo servidor. Un
endpoint de login que filtra por query string. Un campo `token` que es una
constante guardada en una tabla.

Todo eso está mal, y todo eso se implementa exactamente así.

> 🧭 **`D21`, dicho sin adornos.** Un backend "mejor diseñado" que obliga a
> cambiar el cliente es, para este curso, un backend roto. La única medida de
> calidad de esta fase es que el frontend no se entere.

La habilidad que se entrena acá no es escribir APIs bonitas: es **reemplazar una
pieza de un sistema vivo sin que el resto se dé cuenta**. Es lo que hace falta
para modernizar cualquier cosa que ya tenga usuarios, y es lo contrario del
instinto que trae casi todo el mundo. El rediseño viene después, cuando ya
controlas las dos orillas — y entonces se hace con una migración del cliente
planificada, no de contrabando dentro de un reemplazo de backend.

### El punto peligroso: cómo serializa Go

En `json-server`, lo que devuelve la API es literalmente lo que hay en el
archivo. No hay capa de serialización, no hay tipos, no hay conversión. En Go hay
las tres, y ahí es donde se rompen los contratos.

Las tres reglas que hay que tener presentes todo el tiempo:

**Solo se serializan los campos exportados.** Un campo en minúscula no aparece en
el JSON, sin aviso, sin error, sin nada. El síntoma es un objeto al que le falta
justo el campo que importa.

**El tipo del campo decide la forma del JSON, y los tipos nulos de
`database/sql` son una trampa.** Un `sql.NullInt64` no serializa a `null`:
serializa a `{"Int64":0,"Valid":false}`. Es la trampa de esta fase y es la pieza
forense.

**`time.Time` serializa en RFC 3339, con el huso que traiga el valor.** Y el huso
que trae depende de la zona de la sesión de Postgres, no de lo que guardaste. Es
sutil, es real, y lo vas a medir.

### Configuración: un struct que falla temprano

`be01` leyó variables con `os.Getenv` y lo declaró como deuda. Se paga acá, y no
por elegancia: la configuración dispersa **falla tarde**. Un `DATABASE_URL` vacío
con `os.Getenv` no rompe nada al arrancar; rompe en la primera petición de un
usuario, veinte minutos después del despliegue, con un error que no menciona la
configuración.

`envconfig` mapea variables de entorno a un struct, aplica valores por defecto y
—lo importante— marca lo obligatorio como `required:"true"`. El proceso muere en
el segundo cero con un mensaje que dice qué falta. **Fallar temprano y ruidoso es
una decisión de operación, no de estilo.**

---

## 💻 5. Implementación y código comentado

### 5.1 La configuración

```bash
cd server && go get github.com/kelseyhightower/envconfig@v1.4.0
```

```go
// server/internal/config/config.go
package config

import (
	"fmt"

	"github.com/kelseyhightower/envconfig"
)

// Config es la ÚNICA fuente de configuración del proceso. Un solo struct,
// un solo lugar donde mirar cuando algo no arranca.
type Config struct {
	Port          string `envconfig:"PORT"           default:"3001"`
	DatabaseURL   string `envconfig:"DATABASE_URL"    required:"true"`
	AllowedOrigin string `envconfig:"ALLOWED_ORIGIN"  default:"http://localhost:3000"`
	ChaosLevel    string `envconfig:"CHAOS_LEVEL"     default:"off"`
	SQLDebug      bool   `envconfig:"SQL_DEBUG"       default:"false"`
}

// Load lee el entorno y falla si algo obligatorio no está.
//
// 🧠 El default del puerto es 3001 y no 3011: a partir de esta fase el
// binario ES el backend del 3001. El puerto de transición de be01/be02
// (D24) cumplió su función y desaparece.
func Load() (Config, error) {
	var cfg Config
	if err := envconfig.Process("", &cfg); err != nil {
		return Config{}, fmt.Errorf("configuración inválida: %w", err)
	}
	return cfg, nil
}
```

### 5.2 Las dos migraciones que esta fase necesita

Al implementar el contrato aparecen dos huecos del esquema de `be02`. No son
descuidos que ocultar: son **exactamente lo que pasa cuando se diseña un esquema
sin medir el cuerpo real de las peticiones**, y por eso se documentan.

**`000002` — la columna de la vergüenza.** El contrato dice que
`GET /users?email=…&password=…` devuelve un objeto con un campo `token`, y ese
token es una constante que vive en `db.json`. Para devolverlo hay que guardarlo.

```sql
-- server/migrations/postgres/000002_add_user_token.up.sql
-- 💸 DEUDA CON FECHA DE VENCIMIENTO.
-- Esta columna guarda una credencial que no es una credencial: una constante
-- de texto sin firma, sin expiración y sin secreto. Existe únicamente para
-- que el contrato de be00 se pueda honrar mientras la autenticación real
-- llega. La migración 000004 de be04 la BORRA. Si estás leyendo esto después
-- de be04 y la columna sigue acá, algo salió mal.
ALTER TABLE users ADD COLUMN token TEXT;
```

**`000003` — el cuerpo real de una liquidación.** El `POST /settlements` de la
Fase 8 manda ocho campos y la tabla de `be02` tiene sitio para cinco. Los tres
que faltan —`isWinnerSold`, `soldCount`, `settledAt`— **no rompen nada visible**:
el `INSERT` los ignora, el `201` sale bien, la aplicación sigue andando. Se
pierden en silencio, y alguien los va a echar de menos en una auditoría dentro de
seis meses.

```sql
-- server/migrations/postgres/000003_settlement_full_shape.up.sql
-- El cuerpo que el frontend manda de verdad (Fase 8, createSettlement) trae
-- tres campos que el esquema inicial no previó. Medido contra el contrato,
-- no deducido leyendo el slice.
ALTER TABLE settlements ADD COLUMN is_winner_sold BOOLEAN     NOT NULL DEFAULT false;
ALTER TABLE settlements ADD COLUMN sold_count     INTEGER     NOT NULL DEFAULT 0;
-- settled_at lo calcula el CLIENTE (new Date().toISOString() en el thunk) y
-- por eso llega en el cuerpo. 💸 Que un instante de negocio lo fije el reloj
-- del navegador es la deuda que be06 va a cobrar; hoy se guarda tal cual
-- llega, porque cambiarlo sería cambiar el contrato.
ALTER TABLE settlements ADD COLUMN settled_at     TIMESTAMPTZ;
```

> ⚠️ Los `down` correspondientes son obligatorios, y el de SQLite tiene su
> propia trampa: SQLite no soporta `ALTER TABLE … DROP COLUMN` hasta la versión
> 3.35, y con limitaciones incluso después. Escríbelos, aplícalos y comprueba
> qué pasa en cada motor — es la Divergencia número ocho, y te la ganaste sin
> buscarla.

### 5.3 La siembra: `internal/seed`

La semilla sale de **tu** `db.json`, no de un dump nuestro. Que después del
reemplazo aparezcan exactamente las rifas que veías en el track base es la mitad
del efecto de esta fase: el mock se apagó y la aplicación sigue mostrando *tus*
datos.

```go
// server/internal/seed/seed.go
package seed

import (
	"context"
	"encoding/json"
	"fmt"
	"os"

	"github.com/rifas-y-chances/raffles-api/internal/storage"
)

// dbJSON refleja la forma del mock/db.json del track base. Los nombres de
// los campos son los del CONTRATO (camelCase), no los de las columnas.
type dbJSON struct {
	Raffles []struct {
		ID          int64  `json:"id"`
		Name        string `json:"name"`
		LotteryID   string `json:"lotteryId"`
		ClosesAt    string `json:"closesAt"`
		NumberPrice int64  `json:"numberPrice"`
		BasePrize   int64  `json:"basePrize"`
		Status      string `json:"status"`
	} `json:"raffles"`

	// Ojo con el nombre: la colección del mock se llama "numbers" y la
	// tabla se llama "raffle_numbers". La traducción vive acá, en un solo
	// lugar (diccionario §7bis.1).
	Numbers []struct {
		RaffleID int64  `json:"raffleId"`
		Number   string `json:"number"`
		Status   string `json:"status"`
	} `json:"numbers"`

	Users []struct {
		ID       int64  `json:"id"`
		Email    string `json:"email"`
		Password string `json:"password"`
		Name     string `json:"name"`
		Token    string `json:"token"`
	} `json:"users"`
}

// FromFile siembra la base desde el db.json indicado.
//
// Es IDEMPOTENTE a propósito: se puede correr veinte veces seguidas sin
// duplicar nada. Una semilla que solo funciona sobre una base vacía es una
// semilla que nadie se atreve a correr, y entonces todo el mundo termina
// restaurando dumps a mano.
func FromFile(ctx context.Context, db *storage.DB, path string) error {
	raw, err := os.ReadFile(path)
	if err != nil {
		return fmt.Errorf("leyendo %s: %w", path, err)
	}

	var data dbJSON
	if err := json.Unmarshal(raw, &data); err != nil {
		return fmt.Errorf("interpretando %s: %w", path, err)
	}

	// Todo o nada: si falla la mitad, no queremos una base a medio sembrar.
	tx, err := db.BeginTxx(ctx, nil)
	if err != nil {
		return fmt.Errorf("abriendo la transacción de siembra: %w", err)
	}
	// Rollback después de un Commit exitoso es un no-op: este defer es
	// seguro y es la forma idiomática de no dejar transacciones colgadas.
	defer tx.Rollback()

	for _, u := range data.Users {
		// Conservamos el id del db.json a propósito: el frontend guarda
		// user.id en el store y cambiarlo sería cambiar datos observables.
		// ON CONFLICT DO UPDATE hace la operación repetible.
		_, err := tx.ExecContext(ctx, db.Rebind(`
			INSERT INTO users (id, email, password, name, token)
			VALUES (?, ?, ?, ?, ?)
			ON CONFLICT (id) DO UPDATE
			SET email = EXCLUDED.email, password = EXCLUDED.password,
			    name = EXCLUDED.name, token = EXCLUDED.token`),
			u.ID, u.Email, u.Password, u.Name, u.Token)
		if err != nil {
			return fmt.Errorf("sembrando el usuario %s: %w", u.Email, err)
		}
	}

	for _, r := range data.Raffles {
		_, err := tx.ExecContext(ctx, db.Rebind(`
			INSERT INTO raffles (id, name, lottery_id, closes_at, number_price, base_prize, status)
			VALUES (?, ?, ?, ?, ?, ?, ?)
			ON CONFLICT (id) DO UPDATE
			SET name = EXCLUDED.name, lottery_id = EXCLUDED.lottery_id,
			    closes_at = EXCLUDED.closes_at, number_price = EXCLUDED.number_price,
			    base_prize = EXCLUDED.base_prize, status = EXCLUDED.status`),
			r.ID, r.Name, r.LotteryID, r.ClosesAt, r.NumberPrice, r.BasePrize, r.Status)
		if err != nil {
			return fmt.Errorf("sembrando la rifa %d: %w", r.ID, err)
		}
	}

	for _, n := range data.Numbers {
		// Los números del db.json NO traen id: la clave natural es
		// (raffle_id, number), que es justo el UNIQUE de be02. Por eso el
		// ON CONFLICT va contra la restricción y no contra el id.
		_, err := tx.ExecContext(ctx, db.Rebind(`
			INSERT INTO raffle_numbers (raffle_id, number, status)
			VALUES (?, ?, ?)
			ON CONFLICT (raffle_id, number) DO UPDATE SET status = EXCLUDED.status`),
			n.RaffleID, n.Number, n.Status)
		if err != nil {
			return fmt.Errorf("sembrando el número %s de la rifa %d: %w", n.Number, n.RaffleID, err)
		}
	}

	// ⚠️ Los ids insertados a mano NO mueven la secuencia de BIGSERIAL.
	// Sin esto, el primer POST /raffles intenta usar el id 1 y choca con
	// la rifa sembrada: "duplicate key value violates unique constraint".
	// Es el error más frecuente de toda esta fase y no tiene nada que ver
	// con tu código: tiene que ver con cómo funcionan las secuencias.
	if db.Dialect == storage.Postgres {
		for _, table := range []string{"users", "raffles", "raffle_numbers", "participants", "settlements"} {
			_, err := tx.ExecContext(ctx, fmt.Sprintf(
				`SELECT setval(pg_get_serial_sequence('%s','id'),
				               COALESCE((SELECT MAX(id) FROM %s), 1))`, table, table))
			if err != nil {
				return fmt.Errorf("ajustando la secuencia de %s: %w", table, err)
			}
		}
	}

	return tx.Commit()
}
```

```go
// server/cmd/seed/main.go — un binario aparte, no un flag del servidor.
// Sembrar es una operación de operador, no de arranque: mezclarla con el
// servidor es la misma clase de error que ejecutar migraciones al arrancar.
func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatal(err)
	}
	path := flag.String("file", "../mock/db.json", "ruta al db.json del track base")
	flag.Parse()

	db, err := storage.Open(context.Background(), cfg.DatabaseURL)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	if err := seed.FromFile(context.Background(), db, *path); err != nil {
		log.Fatalf("la siembra falló: %v", err)
	}
	log.Println("siembra completa")
}
```

### 5.4 El tipo que rompe el contrato, y cómo se arregla

Antes de escribir un solo handler, el problema que va a aparecer sí o sí.

La columna `participant_id` es anulable. La forma directa de mapearla en Go es
`sql.NullInt64`, y **eso rompe el contrato en silencio**:

```go
// ❌ Compila, escanea perfecto desde la base, y produce este JSON:
//    {"raffleId":1,"number":"0347","status":"available",
//     "participantId":{"Int64":0,"Valid":false}}
//
// El frontend esperaba null. Y como un objeto es *truthy* en JavaScript,
// cualquier `if (number.participantId)` del tablero de la Fase 5 pasa a ser
// verdadero para TODOS los números. No hay error en consola. La grilla
// simplemente miente.
type RaffleNumber struct {
	ParticipantID sql.NullInt64 `json:"participantId" db:"participant_id"`
}
```

La forma correcta es un puntero: `sqlx` lo escanea igual de bien, y
`encoding/json` serializa `nil` como `null`, que es exactamente lo que el mock
devolvía.

```go
// server/internal/rafflenumber/rafflenumber.go
package rafflenumber

import "time"

// RaffleNumber es un número dentro de una rifa.
//
// 🧠 Los punteros no están acá por gusto de Go: están porque el contrato
// distingue "no hay valor" (null) de "el valor es cero". Un int64 pelado
// serializaría participantId como 0, que en el frontend es un id válido.
type RaffleNumber struct {
	// El id de la fila existe en la tabla y NO estaba en el db.json. Se
	// omite del JSON: agregarlo sería régimen de crecimiento y por lo tanto
	// seguro, pero omitirlo mantiene la respuesta idéntica byte a byte a la
	// del mock, que es lo que hace verificable el reemplazo.
	ID            int64      `json:"-"              db:"id"`
	RaffleID      int64      `json:"raffleId"       db:"raffle_id"`
	Number        string     `json:"number"         db:"number"`
	Status        string     `json:"status"         db:"status"`
	ParticipantID *int64     `json:"participantId"  db:"participant_id"`
	ReservedUntil *time.Time `json:"-"              db:"reserved_until"`
	SoldAt        *time.Time `json:"-"              db:"sold_at"`
}
```

### 5.5 El service: donde vive el `409` (y donde todavía no protege)

```go
// server/internal/rafflenumber/service.go
package rafflenumber

import (
	"context"
	"errors"
)

// Errores de dominio. El handler los traduce a códigos HTTP; el service no
// sabe que existe HTTP.
var (
	ErrNotFound      = errors.New("ese número no existe en la rifa")
	ErrNotAvailable  = errors.New("ese número ya no está disponible")
	ErrAlreadySold   = errors.New("ese número ya fue vendido")
)

type Service struct {
	store Store
}

func NewService(store Store) *Service { return &Service{store: store} }

// SellNumber vende un número.
//
// 💸💸 LEE ESTO CON ATENCIÓN. Este método tiene EXACTAMENTE la misma
// vulnerabilidad que el mock de la Fase 3: lee el estado, decide en
// memoria, y después escribe. Entre la lectura y la escritura cabe otra
// venta completa. Bajo dos vendedores concurrentes, el número 0347 se
// vende dos veces y los dos reciben 200.
//
// Está así a propósito, y es importante que lo esté: be05 tiene que poder
// REPRODUCIR el bug antes de arreglarlo. Traducir un `if` de JavaScript a
// un `if` de Go no protege nada — solo lo hace parecer más serio, que es
// peor. La corrección real (transacción + FOR UPDATE + índice) es la fase
// ⭐ del track.
func (s *Service) SellNumber(ctx context.Context, raffleID int64, number string, participantID *int64) (RaffleNumber, error) {
	current, err := s.store.FindOne(ctx, raffleID, number)
	if err != nil {
		return RaffleNumber{}, err // ya viene traducido a ErrNotFound
	}

	if current.Status == "sold" {
		return RaffleNumber{}, ErrAlreadySold
	}

	// ← Acá cabe otra venta entera. Ver be05.

	return s.store.MarkSold(ctx, raffleID, number, participantID)
}

// ReserveNumber reserva un número. Misma deuda, mismo destino.
func (s *Service) ReserveNumber(ctx context.Context, raffleID int64, number string) (RaffleNumber, error) {
	current, err := s.store.FindOne(ctx, raffleID, number)
	if err != nil {
		return RaffleNumber{}, err
	}
	if current.Status != "available" {
		return RaffleNumber{}, ErrNotAvailable
	}
	// 💸 La reserva no guarda expiración del lado del servidor: la expira
	// un setTimeout del navegador (Fase 5). El cliente puede cerrar la
	// pestaña y dejar el número bloqueado para siempre. Deuda heredada del
	// mock, declarada en su momento, y que be05 evalúa si paga.
	return s.store.MarkReserved(ctx, raffleID, number)
}
```

### 5.6 Los handlers: traducir dominio a HTTP

```go
// server/internal/http/numbers.go
package httpapi

import (
	"encoding/json"
	"errors"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"

	"github.com/rifas-y-chances/raffles-api/internal/rafflenumber"
)

// ListRaffleNumbersHandler → GET /raffles/{raffleId}/numbers
func ListRaffleNumbersHandler(svc *rafflenumber.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		raffleID, err := pathInt64(r, "raffleId")
		if err != nil {
			// json-server, ante un id que no es número, responde 404 con
			// cuerpo vacío. No 400. Lo replicamos: contrato, no criterio.
			writeEmpty(w, http.StatusNotFound)
			return
		}

		numbers, err := svc.ListByRaffle(r.Context(), raffleID)
		if err != nil {
			writeError(w, http.StatusInternalServerError, "Error interno del servidor")
			return
		}
		// Recuerda: slice vacío, nunca nil. Contrato de be00.
		writeJSON(w, http.StatusOK, numbers)
	}
}

// GetRaffleNumberHandler → GET /raffles/{raffleId}/numbers/{number}
//
// 🎯 ESTA ES LA RUTA DEL HALLAZGO C-01: el validateNumberEpic de la Fase 6
// la consume desde que se escribió, y el mock nunca la implementó. Durante
// todo el track base, esa validación devolvió 404 y el epic lo interpretó
// como "el número no existe". Nadie lo notó porque el síntoma era plausible.
// Con estas quince líneas, la validación del tablero empieza a funcionar de
// verdad — y el frontend no cambia una coma.
func GetRaffleNumberHandler(svc *rafflenumber.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		raffleID, err := pathInt64(r, "raffleId")
		if err != nil {
			writeEmpty(w, http.StatusNotFound)
			return
		}
		number := mux.Vars(r)["number"]

		found, err := svc.FindOne(r.Context(), raffleID, number)
		if errors.Is(err, rafflenumber.ErrNotFound) {
			// Ruta propia del dominio → 404 CON message (C-04).
			writeError(w, http.StatusNotFound, "Ese número no existe en la rifa")
			return
		}
		if err != nil {
			writeError(w, http.StatusInternalServerError, "Error interno del servidor")
			return
		}
		writeJSON(w, http.StatusOK, found)
	}
}

// SellNumberHandler → POST /raffles/{raffleId}/numbers/{number}/sell
func SellNumberHandler(svc *rafflenumber.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		raffleID, err := pathInt64(r, "raffleId")
		if err != nil {
			writeEmpty(w, http.StatusNotFound)
			return
		}
		number := mux.Vars(r)["number"]

		// El cuerpo canónico es {"participantId": …}. El sellNumberEpic de
		// la Fase 6 manda {"participant": …} — es el hallazgo C-03 de be00.
		// Aceptamos los dos y no explotamos con ninguno, igual que el mock:
		// romper ahora la variante de la Fase 6 sería cambiar el contrato
		// observable. La causa raíz se paga en be04, cuando la identidad
		// venga del token y no del cuerpo.
		var body struct {
			ParticipantID *int64          `json:"participantId"`
			Participant   json.RawMessage `json:"participant"`
		}
		// Un cuerpo ausente o vacío es válido: el tablero de la Fase 5
		// manda participantId: null. No es un 400.
		_ = json.NewDecoder(r.Body).Decode(&body)

		sold, err := svc.SellNumber(r.Context(), raffleID, number, body.ParticipantID)
		switch {
		case errors.Is(err, rafflenumber.ErrNotFound):
			writeError(w, http.StatusNotFound, "Ese número no existe en la rifa")
		case errors.Is(err, rafflenumber.ErrAlreadySold):
			// El 409 que la Fase 5 aprendió a revertir. Mismo código, mismo
			// mensaje, mismo cuerpo que el mock.
			writeError(w, http.StatusConflict, "Ese número ya fue vendido")
		case err != nil:
			writeError(w, http.StatusInternalServerError, "Error interno del servidor")
		default:
			writeJSON(w, http.StatusOK, sold)
		}
	}
}

// pathInt64 lee una variable de ruta como entero.
func pathInt64(r *http.Request, name string) (int64, error) {
	return strconv.ParseInt(mux.Vars(r)[name], 10, 64)
}
```

Y el login, que es el que más incomoda de escribir:

```go
// server/internal/http/users.go

// ListUsersHandler → GET /users?email=…&password=…
//
// 💸💸💸 Sí: la contraseña llega por query string, se compara en claro
// contra la columna, y devolvemos un array. Es feo de tres maneras
// distintas y las tres son deliberadas: es EXACTAMENTE lo que el
// authService.js de la Fase 2 consume hoy, y el frontend no se toca.
//
// Los dos detalles que parecen menores y son contrato duro (be00):
//   1. Sin coincidencias → 200 con []. NUNCA 401. Un 401 acá dispararía
//      el manejo global de sesión del interceptor en mitad del login.
//   2. La respuesta es un ARRAY, no un objeto.
//
// be04 lo reemplaza por POST /login con bcrypt y JWT, y esa es la única
// excepción negociada del track (C-06 / D27).
func ListUsersHandler(svc *user.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		users, err := svc.FindByCredentials(
			r.Context(),
			r.URL.Query().Get("email"),
			r.URL.Query().Get("password"),
		)
		if err != nil {
			writeError(w, http.StatusInternalServerError, "Error interno del servidor")
			return
		}
		writeJSON(w, http.StatusOK, users)
	}
}
```

### 5.7 El router completo

```go
// server/internal/http/router.go (extracto: las rutas del contrato)

// ⚠️ EL ORDEN DE REGISTRO IMPORTA, y por la misma razón que en el mock de
// la Fase 3: las rutas específicas van ANTES que las genéricas. gorilla/mux
// hace coincidencia por orden de registro, así que /raffles/{id}/numbers
// tiene que estar antes de /raffles/{id} o nunca se alcanza.

// Régimen estricto — números (las tres rutas propias + la de C-01)
r.HandleFunc("/raffles/{raffleId}/numbers", ListRaffleNumbersHandler(numberSvc)).Methods(http.MethodGet)
r.HandleFunc("/raffles/{raffleId}/numbers/{number}", GetRaffleNumberHandler(numberSvc)).Methods(http.MethodGet)
r.HandleFunc("/raffles/{raffleId}/numbers/{number}/reserve", ReserveNumberHandler(numberSvc)).Methods(http.MethodPost)
r.HandleFunc("/raffles/{raffleId}/numbers/{number}/sell", SellNumberHandler(numberSvc)).Methods(http.MethodPost)

// Régimen estricto — rifas
r.HandleFunc("/raffles", ListRafflesHandler(raffleSvc)).Methods(http.MethodGet)
r.HandleFunc("/raffles", CreateRaffleHandler(raffleSvc)).Methods(http.MethodPost)
r.HandleFunc("/raffles/{id}", GetRaffleHandler(raffleSvc)).Methods(http.MethodGet)
r.HandleFunc("/raffles/{id}", UpdateRaffleHandler(raffleSvc)).Methods(http.MethodPut)
r.HandleFunc("/raffles/{id}", DeleteRaffleHandler(raffleSvc)).Methods(http.MethodDelete)

// Régimen estricto — usuarios y liquidaciones
r.HandleFunc("/users", ListUsersHandler(userSvc)).Methods(http.MethodGet)
r.HandleFunc("/settlements", ListSettlementsHandler(settlementSvc)).Methods(http.MethodGet)
r.HandleFunc("/settlements", CreateSettlementHandler(settlementSvc)).Methods(http.MethodPost)

// Régimen de crecimiento — andamiaje del curso
r.HandleFunc("/health", healthHandler(db)).Methods(http.MethodGet)
r.HandleFunc("/_chaos", chaosHandler(chaos)).Methods(http.MethodPost)
```

Y las dos rarezas del dialecto que hay que reproducir aunque duelan:

```go
// DeleteRaffleHandler → DELETE /raffles/{id}
// json-server responde 200 con {} — no 204. Un 204 sin cuerpo es más
// correcto por RFC y rompería el .then(response => response.data) del
// thunk de la Fase 4. Contrato gana.
func DeleteRaffleHandler(svc *raffle.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		id, err := pathInt64(r, "id")
		if err != nil {
			writeEmpty(w, http.StatusNotFound)
			return
		}
		if err := svc.Delete(r.Context(), id); errors.Is(err, raffle.ErrNotFound) {
			writeEmpty(w, http.StatusNotFound) // recurso automático → cuerpo vacío (C-04)
			return
		} else if err != nil {
			writeError(w, http.StatusInternalServerError, "Error interno del servidor")
			return
		}
		writeJSON(w, http.StatusOK, struct{}{}) // el {} literal del mock
	}
}
```

### 5.8 🪦 El momento

Todo lo anterior fue para esto. Sigue los pasos en orden y **no te saltes el
primero**, que es el que hace que el reemplazo sea reversible.

```bash
# 1. Red de seguridad: el estado exacto de tus datos antes de tocar nada.
cp mock/db.json mock/db.json.antes-del-reemplazo
git add -A && git commit -m "be03: checkpoint antes del reemplazo"

# 2. Base limpia, migrada y sembrada desde TU db.json.
cd server
migrate -path migrations/postgres -database "$DATABASE_URL" up
go run ./cmd/seed -file ../mock/db.json

# 3. 🪦 Se apaga el mock. Sin red.
#    (Ctrl+C en la terminal donde corre `npm run mock:api`)
#    El 3002 de la lotería SIGUE VIVO: es un tercero y no se toca.
lsof -i :3001    # tiene que estar libre

# 4. Se levanta el binario en el 3001. El mismo puerto. Ese es el punto.
DATABASE_URL="$DATABASE_URL" go run ./cmd/api

# 5. El criterio de aprobación, sin modificar una línea desde be00.
cd .. && ./server/smoke.sh
```

Y entonces, el recorrido. **El mismo de `be00`**, paso por paso, con Network
abierto: login, listar, crear, editar, borrar, tablero, reservar, vender,
conflicto de venta, validar un número, esperar el cierre, ver llegar el
resultado, liquidar, dashboard, logout.

> 🧭 **El criterio, en una frase que se puede decir en voz alta:** *"apagué el
> mock, levanté mi binario, y la aplicación no se enteró."*
>
> Si algo se comporta distinto, **el que está mal es el backend**. No el
> frontend, no el contrato, no "es que json-server hacía algo raro". El backend.
> Vuelve a `server/CONTRACT.md`, encuentra en qué punto te desviaste, y
> corrígelo ahí.

Cuando pase, escríbelo. Un párrafo en `server/CONTRACT.md` con la fecha, qué
recorriste y qué falló en el camino antes de quedar en verde. Ese párrafo es el
retiro formal de `json-server` del sistema, y en seis meses va a ser el documento
que explique por qué el `3001` responde lo que responde.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. La secuencia que se quedó atrás.** Síntoma: la siembra funciona, la
aplicación lista las rifas perfecto, y el primer `POST /raffles` devuelve `500`
con `duplicate key value violates unique constraint "raffles_pkey"`. Causa:
insertar ids explícitos no mueve la secuencia de `BIGSERIAL`; el `nextval` sigue
en 1. Fix: el `setval` de 5.3. Es el error más frecuente de la fase y no tiene
nada que ver con tu código.

**2. `time.Time` que vuelve en otro huso.** Síntoma: `closesAt` sale
`2026-08-31T03:00:00Z` donde el mock devolvía `2026-08-30T22:00:00-05:00`. Causa:
`TIMESTAMPTZ` guarda el instante y lo devuelve en la zona de la **sesión**, que
por defecto es la del servidor. El instante es el mismo y `new Date()` lo
interpreta igual, así que la aplicación *parece* andar. Fix mínimo: fijar la zona
de la sesión en el DSN (`?timezone=America/Bogota`) para que la respuesta sea
idéntica a la del mock. Corrección frente a refactorización: la línea del DSN es
la corrección; decidir de quién es la autoridad temporal es `be06`, y es una
conversación entera.

**3. Campos en minúscula.** Síntoma: al objeto le falta justo un campo, sin
error, sin aviso. Causa: `encoding/json` solo serializa campos exportados. Fix:
mayúscula inicial. Cuesta cinco minutos encontrarlo la primera vez y treinta
segundos la segunda.

**4. Uniformar los `404`.** Síntoma: `toReadableError` empieza a producir
mensajes distintos y algún caso de la Fase 4 muestra "Error desconocido". Causa:
alguien —con toda la razón del mundo— hizo que todos los `404` devolvieran
`{"message":…}`. Fix: volver a `C-04`. Es la mejora razonable que rompe un
cliente, y por eso `be00` la registró como trampa.

**5. Validar más de lo que validaba el mock.** Síntoma: crear una rifa desde el
formulario devuelve `400` donde antes iba bien. Causa: agregaste validación de
negocio en el `POST /raffles`. Fix: quitarla. Validar más es **romper el
contrato**: el régimen de crecimiento admite validaciones más permisivas, nunca
más estrictas. Guárdala para cuando controles las dos orillas.

### 🩻 Pieza forense de esta fase

**La discrepancia que encuentra el frontend y no encuentra ningún test.**

Es la forma real en que aparecen estos bugs, y por eso la fase la provoca a
propósito. Tus tests de `be02` pasan. `go vet` está limpio. `curl` devuelve algo
que se ve perfecto. Y la aplicación se comporta raro.

*Caso A — el objeto que debía ser `null`.* Cambia `ParticipantID *int64` por
`sql.NullInt64` y recorre el tablero de la Fase 5.

1. Anota qué devuelve `curl localhost:3001/raffles/1/numbers`. Vas a ver
   `{"Int64":0,"Valid":false}` y te va a parecer obvio **ahora que lo buscas**.
2. Anota qué se ve en la aplicación. Según cómo esté escrito el tablero, los
   números aparecen todos asignados, o el detalle de un número muestra un
   participante que no existe. **Sin un solo error en consola.**
3. Escribe el test de Go que lo habría atrapado. Pista incómoda: un test que
   compare structs **no lo atrapa nunca**, porque el problema no está en los
   datos sino en la serialización. Hay que comparar el **JSON**, byte a byte,
   contra la respuesta que daba el mock.
4. Vuelve al puntero y confirma que el JSON queda idéntico al del mock.

*Caso B — los tres campos que se pierden en silencio.* Deshaz la migración
`000003` (`migrate down 1`) y liquida una rifa desde la aplicación.

1. El `POST /settlements` devuelve `201`. La aplicación festeja. El slice guarda
   la liquidación. Todo verde.
2. Ahora `SELECT * FROM settlements` y compara con el cuerpo que viajó, que
   tienes en Network. Faltan `isWinnerSold`, `soldCount` y `settledAt`.
3. **Nadie se entera.** El dashboard de la Fase 9 solo lee `margin`. El dato se
   perdió el día que se guardó, y el síntoma va a aparecer dentro de seis meses,
   cuando alguien pregunte cuántos números se vendieron en la rifa de agosto.
4. Vuelve a aplicar la migración y escribe, en tres líneas, qué prueba habría
   detectado esto. Después responde la pregunta difícil: ¿esa prueba la habrías
   escrito?

*El contraste que hay que anotar.* El Caso A es ruidoso: rompe algo visible y se
encuentra en veinte minutos. El Caso B es silencioso: no rompe nada, no lo
encuentra ningún test, y cuesta muchísimo más caro. **Los bugs de contrato que
duelen no son los que fallan: son los que pasan.**

*Rompe a propósito, bonus.* Con el binario corriendo, borra un campo del
`writeJSON` de rifas —`numberPrice`, por ejemplo— y recorre la aplicación.
Cronometra cuánto tardas en encontrar la causa **sin** mirar el código del
backend, solo con DevTools. Ese cronómetro es la medida de lo que vale un
contrato escrito.

---

## 🧪 7. Ejercicios (33)

**🟢 Fácil (1–8)**

1. Arranca el binario sin `DATABASE_URL` y comprueba que muere en el segundo cero con un mensaje que nombra la variable.
2. Siembra la base desde tu `db.json` y verifica con `psql` que las rifas conservan sus ids originales.
3. Corre la siembra tres veces seguidas y comprueba que no duplica nada.
4. Verifica con `curl` que `GET /raffles/1/numbers/0347` responde `200` — el hallazgo `C-01` cerrado.
5. Comprueba las dos formas de `404`: `GET /raffles/9999` con cuerpo vacío y `GET /raffles/1/numbers/9999` con `{"message":…}`.
6. Verifica que `DELETE /raffles/:id` devuelve `200` con `{}` y no `204`.
7. Apaga `json-server`, levanta el binario en el `3001` y corre `./server/smoke.sh`. Pega la salida.
8. Confirma que `GET /users` con credenciales inválidas devuelve `200` con `[]`.

**🟡 Intermedio (9–19)**

9. Implementa `GET /settlements` y `POST /settlements` con los ocho campos del contrato, y verifica el cuerpo contra el que manda la Fase 8 en Network.
10. **Diagnóstico.** Provoca el error de la secuencia (siembra y después crea una rifa desde la UI). Lee el mensaje de Postgres y explica de dónde sale el id que chocó.
11. Compara byte a byte la respuesta de `GET /raffles` del mock (guárdala antes de apagarlo) contra la de tu binario. Documenta cada diferencia.
12. **Diagnóstico.** Cambia `ParticipantID` a `sql.NullInt64` y recorre el tablero. Describe el síntoma en la UI antes de mirar el JSON.
13. Escribe el test de serialización que compara el JSON de un número contra la respuesta literal del mock.
14. **Diagnóstico.** Quita el `setval` de la siembra y determina cuántas operaciones puedes hacer antes de que algo falle.
15. Haz que el `POST /raffles` devuelva `200` en vez de `201` y determina si algo se rompe. Explica el resultado en términos del régimen estricto.
16. **Diagnóstico.** Compara el `closesAt` que devuelve tu binario contra el del mock. Si difieren, encuentra por qué y arréglalo desde el DSN.
17. Implementa `PUT /raffles/:id` y comprueba que un `PUT` sobre una rifa inexistente devuelve `404` con la forma correcta.
18. Agrega logging del `X-Request-Id` en el store detrás de `SQL_DEBUG` y recorre una venta completa siguiendo un solo id desde la consola del navegador.
19. **Diagnóstico.** Manda un `POST /sell` con `{"participant":{"name":"Ana"}}` —la variante `C-03` de la Fase 6— y determina qué guarda tu backend. Compáralo con lo que guardaba el mock.

**🟠 Difícil (20–28)**

20. **Diagnóstico.** Ejecuta el Caso B de la pieza forense completo y escribe el informe de la pérdida silenciosa, incluida la respuesta honesta a "¿habrías escrito esa prueba?".
21. Escribe una prueba de contrato en Go que verifique los doce endpoints del régimen estricto con `httptest`. Compárala con `smoke.sh`: ¿qué atrapa cada una que la otra no?
22. **Diagnóstico.** Introduce a propósito una discrepancia de contrato en un endpoint a elección, dásela a otra persona (o a tu yo de mañana) y mide cuánto tarda en encontrarla solo con DevTools.
23. Haz que la siembra sea reversible: un `cmd/seed -reset` que vacíe y vuelva a sembrar. Decide qué hace con las secuencias y por qué.
24. **Diagnóstico.** Con el binario corriendo y el caos en `high`, recorre la aplicación entera. ¿Se comporta igual que con el mock en `high`? Si no, encuentra la diferencia — pista: mira el orden de la cadena de middlewares y dónde estaba el caos en el mock.
25. Argumenta por escrito si `GET /raffles/{id}` debería devolver `400` ante un id no numérico en vez del `404` del mock. Después impleméntalo, comprueba qué pasa en la aplicación, y decide.
26. **Diagnóstico.** El `sellNumberEpic` de la Fase 6 y el thunk de la Fase 5 pegan al mismo endpoint. Haz que los dos disparen a la vez sobre el mismo número y describe qué pasa. No lo arregles: documenta el estado en que queda la base. Es la entrada a `be05`.
27. Mide el tiempo de respuesta de `GET /raffles/1/numbers` contra el mock y contra tu binario, con la misma cantidad de números. Explica la diferencia sin recurrir a "Go es más rápido".
28. **Diagnóstico.** Rompe la conexión a Postgres mientras la aplicación está en uso (mata el contenedor) y recorre las pantallas. Compara los síntomas con el inventario que levantaste en `be00` con el mock caído.

**🔴 Muy difícil (29–33)**

29. Diseña la estrategia de reemplazo que habrías usado si esto fuera producción y no un laboratorio: cómo pondrías el backend nuevo en paralelo, cómo compararías respuestas en vivo, y cómo volverías atrás en treinta segundos. Escríbelo como plan operativo, con los comandos.
30. **Diagnóstico + regresión.** Ticket: *"desde el martes, cuando vendo un número el nombre del comprador aparece en blanco, pero solo a veces"*. Con lo que sabes de `C-03` y del Caso A, enumera las causas candidatas ordenadas por probabilidad, di cómo descartas cada una y escribe la prueba de regresión de la que sobreviva.
31. Escribe el generador de "diff de contrato": un programa que tome dos respuestas JSON —la del mock guardada y la de tu binario— y reporte diferencias de estructura y de tipo, ignorando valores. Úsalo sobre los doce endpoints.
32. Argumenta si la columna `users.token` debería existir. Defiende primero que sí (el contrato la exige), después que no (una credencial en claro en la base es un hallazgo de seguridad), y decide con qué criterio se resuelve el empate en un sistema real que no puede tocar su cliente.
33. **Post-mortem.** Escribe el post-mortem del reemplazo como si algo hubiera salido mal en producción: qué falló, cuánto tardaron en notarlo, cómo volvieron atrás y qué control habría cambiado el resultado. Según la guía §13, sin culpabilización.

**🔥 Opcionales**

- 🔥 **Genera volumen con un faker** (`be-a-10`): cincuenta rifas y veinte mil números. Sin volumen, las mediciones de `be05` y `be08` no dicen nada — este ejercicio es prácticamente un prerrequisito de las dos fases.
- 🔥 Implementa el dialecto de paginación de `json-server` (`_page`, `_limit`, `X-Total-Count`) que `be00` mandó al régimen de crecimiento, y demuestra con el `smoke.sh` que no rompe nada. Después responde: ¿qué ganó el sistema?
- 🔥 Levanta el binario y `json-server` a la vez en puertos distintos, y escribe un proxy de veinte líneas que mande cada petición a los dos y compare las respuestas. Es la técnica real de reemplazo en producción y se llama *shadow traffic*.

---

## 📚 8. Referencias

**Documentación oficial**
- https://pkg.go.dev/encoding/json — sobre todo las reglas de `Marshal`: campos exportados, etiquetas, `omitempty` y punteros. Es la causa de la mitad de los bugs de esta fase.
- https://pkg.go.dev/database/sql#NullInt64 — y por qué **no** es un tipo para serializar.
- https://www.postgresql.org/docs/13/functions-sequence.html — `setval` y `pg_get_serial_sequence`, el error común número 1.
- https://www.postgresql.org/docs/13/sql-insert.html — `ON CONFLICT DO UPDATE`, que es lo que hace idempotente la siembra.
- https://github.com/kelseyhightower/envconfig — el mapeo de entorno a struct, con sus etiquetas.
- https://github.com/typicode/json-server/tree/v0.16.3 — para verificar cualquier rareza del dialecto que no hayas medido.
- https://martinfowler.com/bliki/StranglerFigApplication.html — el patrón que estás ejecutando sin haberlo nombrado: reemplazar una pieza por fuera hasta que la vieja se pueda apagar.

**Libros**
- *Working Effectively with Legacy Code* (Michael Feathers) — la idea de la "costura" (*seam*) y de cambiar comportamiento sin cambiar clientes es exactamente esta fase.
- *Building Microservices* (Sam Newman) — el capítulo sobre reemplazar servicios sin interrumpirlos, y el *shadow traffic* del ejercicio 🔥.

**Video / apoyo**
- Busca "strangler fig pattern" y "Go JSON marshaling gotchas" en YouTube. Para lo segundo hay charlas cortas que cubren exactamente la trampa de `NullInt64`.

**Orden de lectura sugerido:** las reglas de `encoding/json` **antes** de escribir
el primer handler —te ahorran la pieza forense entera si las lees a tiempo, y
vale la pena hacerlo igual y provocar el bug a propósito— → `setval` cuando la
siembra funcione → el artículo del *strangler fig* al terminar, para ponerle
nombre a lo que hiciste.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros son de memoria y pueden ser inexactas. La documentación de
> Postgres tiene una versión por URL; fija el 13. Cualquier discrepancia de
> versiones la resuelve `prompts/decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

`json-server` está apagado. 🪦 El `3001` lo sirve un binario de Go contra
PostgreSQL 13, con el esquema migrado y los datos que eran tuyos desde la Fase 3.
El `smoke.sh` que escribiste en `be00` contra el mock pasa entero contra tu
backend, y la ruta que el frontend llamaba al vacío desde la Fase 6 por fin
responde. **Y la aplicación React no cambió ni un archivo.**

Lo que no cambió tampoco son las deudas. El login sigue comparando contraseñas en
claro, ahora en SQL. El token sigue siendo una constante, ahora en una columna. El
`409` de venta duplicada sigue saliendo de un `if`, ahora en Go — traducir de
lenguaje no protegió nada, y esa es la lección más incómoda de la fase.

`be04` cobra cuatro deudas de una vez: `bcrypt` sobre la contraseña, un JWT
firmado en el mismo campo `token` que el interceptor ya lee, la identidad tomada
de `req.Context()` en vez del cuerpo de la petición, y las transiciones del flujo
custodiadas en el service. Y trae la secuencia que ninguna fase inventada podría
mejorar: adoptar una librería que era **la** librería, descubrir que está
abandonada y arrastra un CVE, y migrar al fork con su post-mortem.

> **La señal de que quedó bien:** *"apagué el mock, levanté mi binario, y la
> aplicación no se enteró."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be03-crud-y-el-reemplazo -m "be03 cerrada: \
> configuración con envconfig que falla al arrancar; siembra idempotente desde db.json; \
> doce endpoints del régimen estricto en capas handler→service→store; \
> C-01 cerrado y C-04 reproducido; json-server apagado y binario en el 3001; \
> smoke.sh entero en verde; recorrido completo sin diferencias visibles; \
> frontend intacto"
> ```
>
> Y marca aparte el momento, porque vas a volver a él:
> `git tag -a mock-retirado -m "🪦 json-server fuera del sistema"`.
>
> Los commits de la fase llevan su prefijo (`be03: …`) y los de ejercicio su
> número (`be03 ej20: …`). Si un ejercicio merece su propio marcador va en
> `ej/be03/20`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **Registrar en `prompts/decisiones-y-versiones.md` §7** el tag `mock-retirado`
  y, si se quiere, en `00-convencion-de-git-y-tags.md` como tag de hito del track
  BE. Es el único tag del curso que no sigue el patrón `fase-…`, y está
  justificado: marca un evento, no un cierre de fase.
- **La columna `users.token` (migración `000002`) tiene fecha de vencimiento.**
  `be04` debe borrarla en su propia migración y decirlo explícitamente: es la
  parte visible de cobrar la deuda. Si `be04` la deja, la deuda no se pagó.
- **Las tres columnas de `000003`** (`is_winner_sold`, `sold_count`,
  `settled_at`) salieron de medir el cuerpo real de `createSettlement`. `be07`
  hereda `settled_at` como problema: hoy lo fija el reloj del navegador y esa es
  la deuda que `be06` cobra. Que `be07` no lo pase por alto.
- **`be05` empieza donde termina el ejercicio 26 de esta fase.** El
  `SellNumber` del service tiene la carrera intacta y documentada en su
  comentario. Conviene que `be05` abra reproduciéndola con el código que el
  alumno ya escribió, no con uno nuevo.
- **`be06` hereda el error común 2** (el `closesAt` que vuelve en otro huso) y la
  línea del DSN que lo tapa. Ese parche es exactamente lo que `be06` tiene que
  reemplazar por una decisión sobre quién manda en el reloj.
- **Deudas declaradas en esta fase:** 💸 el `409` producido por un `if` (se paga
  en `be05`); 💸 la reserva sin expiración del lado del servidor (`be05` decide
  si la paga); 💸 `users.password` en claro y `users.token` como constante (se
  pagan en `be04`); 💸 `settled_at` fijado por el cliente (`be06`).
- **Para `be08`:** el ejercicio 21 (prueba de contrato con `httptest`) y el 31
  (diff de contrato) son el germen directo de su suite de contrato. Que `be08`
  los recoja en vez de empezar de cero.
- **Para `be-a-10`:** el ejercicio 🔥 de volumen es prácticamente prerrequisito
  de `be05` y `be08`. Conviene que las dos fases lo digan al abrir, no solo acá.
- **Reserva para el cuaderno de incidentes:** `be-06` — *"el comprador aparece en
  blanco, pero solo a veces"* (categoría 🔥 contrato, dificultad 🟠), que es el
  Caso A de la pieza forense llegado como ticket; y `be-07` — *"faltan datos en
  las liquidaciones de agosto"* (categoría 🔥 contrato, dificultad 🔴), que es el
  Caso B descubierto seis meses tarde, cuando ya no hay forma de recuperarlos.
FIN_DEL_ARCHIVO
wc -l be03-crud-y-el-reemplazo.md

# --- 2026-09-09T02:40:06 · Read style section 10 on references
cd prompts && sed -n '597,643p' guia-de-estilo-y-convenciones.md

# --- 2026-09-09T02:45:38 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs && cat > be04-identidad-real-jwt-y-un-cve.md <<'FIN_DEL_ARCHIVO'
# 🔐 Fase be04 — Identidad real: bcrypt, JWT y un CVE

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Fase be04 de be09 · **8 horas**
> Depende de: be03 — el backend ya sirve a la aplicación · Habilita: be05 — Venta concurrente

---

## 🎯 1. Propósito

Esta fase cobra **cuatro deudas de una vez**, y las cuatro estaban declaradas por
escrito desde la Fase 2 del track base:

1. **El token de mentira.** Una constante de texto en `db.json` que `be03`
   convirtió en una columna. Sin firma, sin expiración, sin secreto.
2. **Las contraseñas en claro.** `json-server` las comparaba como strings y
   `be03` heredó la comparación tal cual, ahora en SQL.
3. **El cliente mentiroso.** Quien crea una rifa, quien la cierra y quien la
   liquida es quien el navegador dice que es. El servidor nunca preguntó.
4. **Las transiciones libres.** El flujo `borrador → abierta → cerrada →
   resuelta → liquidada` lo decide el frontend, y nadie verifica que el orden
   tenga sentido.

Y trae, de regalo, algo que ninguna fase inventada podría mejorar: **la
secuencia completa de adoptar una dependencia que era *la* dependencia,
descubrir que está abandonada con un aviso de seguridad abierto, y migrar al
fork**. No es una anécdota que se cuenta: se hace, con el `go.mod` cambiando en
dos commits y un post-mortem al final.

> 🧭 Y una restricción que ordena toda la fase: **el JWT firmado viaja en el
> mismo campo `token` que el frontend ya lee**. El interceptor de `apiClient`
> manda `Bearer ${token}` desde la Fase 2 justamente para que este día llegara
> sin tocarlo. No se toca.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Migración `000004`: `users.password` pasa a `password_hash` y **la columna
      `users.token` desaparece**. La deuda de `be03` se paga borrando su DDL.
- [ ] La siembra hashea con `bcrypt` las contraseñas que vienen en claro del
      `db.json`, y el `db.json` no se modifica.
- [ ] `POST /login` valida contra el hash y devuelve
      `{ id, email, name, token }` con el `token` firmado.
- [ ] La **única excepción del track** está ejecutada: `src/api/authService.js`
      modificado, y **ningún otro archivo del frontend** (`D27` / `C-06`).
- [ ] Middleware de verificación montado sobre las rutas del dominio; un token
      inválido o vencido devuelve `401` con la forma que el interceptor ya sabe
      manejar.
- [ ] La identidad viaja en `req.Context()` y **ningún handler la lee del cuerpo
      de la petición**.
- [ ] Las transiciones de estado están custodiadas en el service, con su tabla de
      transiciones legales, y una ilegal devuelve `409`.
- [ ] `dgrijalva/jwt-go` v3.2.0 entró al `go.mod` y **salió en la misma fase**,
      reemplazado por `golang-jwt/jwt/v4` v4.4.2.
- [ ] Existe `server/postmortem-jwt.md`, escrito sin culpabilización.
- [ ] `server/CONTRACT.md` y `server/smoke.sh` están actualizados con el nuevo
      login, y el `smoke.sh` pasa entero.
- [ ] `git diff pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js'`
      no devuelve nada.

---

## 🚫 3. Qué queda fuera por ahora

- **Los *refresh tokens*.** No entran, y esto es una decisión, no un olvido: el
  JWT expira, el frontend no lo renueva, y cuando expira el interceptor de la
  Fase 2 hace logout global. **Esa fricción se declara como deuda 💸 viva** en
  vez de tocar el frontend para arreglarla. Para el laboratorio, el token tiene
  vida larga. Ver 4.5.
- **Roles y permisos finos.** Todos los usuarios pueden todo. Autorización a
  nivel de objeto —"¿esta rifa es tuya?"— es tema de `be-a-08`.
- **Límite de tasa e intentos fallidos** → `be-a-08`. Hoy puedes probar
  contraseñas todo el día.
- **El `409` de venta concurrente** → `be05`. El `409` de esta fase es el de una
  transición ilegal, que es otra cosa.
- **La hora de cierre evaluada en el servidor** → `be06`. Las transiciones se
  custodian por *orden*, no todavía por *reloj*.

---

## 🧠 4. Conceptos mínimos

### 4.1 `bcrypt`: por qué no es un hash cualquiera

Sabes qué es una función de hash. Lo que hay que tener claro es por qué SHA-256
—que es una excelente función de hash— **es una pésima forma de guardar
contraseñas**: porque es rápida. Una GPU moderna calcula miles de millones de
SHA-256 por segundo, y eso es exactamente lo que hace un atacante con tu tabla
de usuarios.

`bcrypt` resuelve dos problemas a la vez. Es **deliberadamente lento**, con un
factor de costo ajustable: subir el costo en uno duplica el tiempo, así que la
defensa se puede escalar con el hardware sin cambiar de algoritmo. Y **incorpora
la sal en el propio hash**, así que no hay una columna `salt` que administrar ni
la posibilidad de olvidarla. El resultado se ve así, y las cuatro partes están a
la vista:

```
$2a$10$N9qo8uLOickgx2ZMRZoMye.IjPeCLSjXBSHkVvHXfUqBLNhSHhBFq
 │   │  └── sal (22 caracteres) ─┴── hash (31 caracteres)
 │   └── costo: 10 → 2^10 iteraciones
 └── variante del algoritmo
```

De ahí salen las dos reglas de uso, y las dos son fáciles de romper: **nunca
compares hashes con `==`** —se usa `CompareHashAndPassword`, que además tarda lo
mismo acierte o falle— y **el hash es opaco**: no se parsea, no se indexa, no se
compara por prefijo.

> ⚠️ **La trampa de los 72 bytes.** `bcrypt` ignora todo lo que pase de 72 bytes
> de entrada. Una contraseña de 100 caracteres se trunca en silencio, y las dos
> primeras mitades iguales dan el mismo hash. La implementación de Go es honesta
> y devuelve `bcrypt.ErrPasswordTooLong` en vez de truncar — pero solo si le
> manejas el error, que es lo que casi nadie hace.

### 4.2 JWT en cinco líneas (el resto está en `be-a-04`)

Tres partes separadas por puntos, las dos primeras en Base64URL **sin cifrar**:
cabecera (qué algoritmo), *claims* (quién, cuándo expira, para quién) y firma.
Cualquiera puede leer el contenido de un JWT; nadie puede modificarlo sin el
secreto.

Lo que hay que interiorizar hoy son dos cosas. La primera: **un JWT no es una
sesión**. No hay estado del lado del servidor, y por eso no se puede invalidar —
un token robado sirve hasta que expira, y punto. La segunda: **la cabecera la
elige quien manda el token**, no quien lo verifica. Esa frase inocente es el
origen de la familia de ataques de confusión de algoritmo, incluido el `alg:
none`, y es la pieza forense de esta fase.

### 4.3 La identidad viene del contexto, jamás del cuerpo

Hoy, cuando el frontend crea una rifa, el backend acepta lo que sea que venga en
el JSON. Si mañana alguien manda `{"ownerId": 7}` con el token del usuario 2, el
servidor le cree.

La regla no admite matices: **lo que el cliente afirma sobre sí mismo es un dato
de entrada, no una verdad**. La identidad se extrae del token en el middleware,
se deja en `req.Context()` y de ahí la leen los services. Cualquier campo del
cuerpo que hable de identidad se **ignora**, no se valida — validarlo sería
admitir que a veces es fuente de verdad.

Fíjate en la simetría con `be01`: el `X-Request-Id` y el `userID` viajan por el
mismo canal y por la misma razón. Son datos de alcance de petición que atraviesan
capas sin ser parte de la lógica de negocio. Eso es exactamente para lo que
existe `context.Context`, y es el único uso legítimo de sus valores.

### 4.4 Las transiciones como máquina de estados

El flujo del dominio tiene cinco estados y **no todas las transiciones son
legales**. Hoy el frontend decide y el backend obedece; un `PUT` con
`status: "settled"` sobre una rifa en borrador funciona perfecto y deja el
sistema en un estado imposible.

| Desde | Puede ir a |
|---|---|
| `draft` | `open` |
| `open` | `closed` |
| `closed` | `resolved` |
| `resolved` | `settled` |

Todo lo que no esté en esa tabla es un `409 Conflict`: la petición está bien
formada, pero el estado del recurso no permite lo que pide. La misma semántica
que el `409` de venta duplicada que la Fase 5 ya sabe manejar, aplicada a otra
cosa.

Custodiar esto en el **service** y no en el handler no es purismo: es que la
regla tiene que valer también para el `SettleRaffle` que `be07` va a llamar desde
otro camino, y para cualquier consumidor futuro que no entre por HTTP.

### 4.5 El *refresh token* que no vamos a hacer, y por qué se declara

Un JWT que expira deja al usuario afuera. La solución estándar es un par de
tokens: uno corto para las peticiones y uno largo para renovarlo sin volver a
pedir contraseña. Implementarlo requiere un endpoint nuevo **y que el frontend lo
llame** — o sea, tocar `apiClient.js`, sus interceptores y probablemente el
`authSlice`.

> 🧭 **Decisión: no se hace.** Ampliar la excepción `D27` a media capa de red del
> frontend convertiría "la única excepción negociada" en una licencia general, y
> ahí se cae la regla que ordena el track entero.

Así que el token tiene vida larga en el laboratorio (`JWT_TTL`, doce horas por
defecto), y la fricción se declara: **cuando expire, el interceptor de la Fase 2
recibirá un `401` y hará logout global, y el usuario tendrá que entrar de
nuevo**. Eso no es un bug del backend. Es la consecuencia visible de una decisión
de alcance, anotada en el mapa de deuda con su fecha y su motivo. Un sistema real
la pagaría; este declara por qué no.

---

## 💻 5. Implementación y código comentado

### 5.1 La migración que borra la vergüenza

```sql
-- server/migrations/postgres/000004_real_credentials.up.sql
-- Cobra dos de las cuatro deudas de esta fase, y las cobra en el DDL:
-- la contraseña deja de ser texto comparable y el token de mentira
-- desaparece de la base.

-- El nombre importa: password_hash le dice a quien lea el esquema dentro de
-- dos años que ahí NO hay una contraseña. Un nombre honesto vale más que un
-- comentario.
ALTER TABLE users RENAME COLUMN password TO password_hash;

-- 🪦 La columna que be03 creó con fecha de vencimiento. Guardaba una
-- credencial sin firma ni expiración; a partir de acá el token se firma en
-- cada login y no se guarda en ninguna parte. Un token que vive en la base
-- es un token que se puede robar de la base.
ALTER TABLE users DROP COLUMN token;
```

```sql
-- server/migrations/postgres/000004_real_credentials.down.sql
-- El down existe, y devolver la vulnerabilidad es exactamente lo que debe
-- hacer: una migración reversible no juzga, revierte. Los hashes que queden
-- en la columna dejarán de servir como contraseñas en claro, y eso es un
-- efecto que hay que documentar en el runbook, no esconder.
ALTER TABLE users ADD COLUMN token TEXT;
ALTER TABLE users RENAME COLUMN password_hash TO password;
```

### 5.2 La siembra hashea al entrar

El `db.json` del track base tiene `"password": "rifas123"` en claro, y **no se
modifica**: es el archivo del alumno y es evidencia histórica del sistema. Quien
traduce es la semilla.

```bash
cd server && go get golang.org/x/crypto@v0.4.0
```

```go
// server/internal/seed/seed.go (extracto: el bucle de usuarios cambia)

for _, u := range data.Users {
	// El db.json trae la contraseña en claro porque así vivía el sistema.
	// Acá entra al backend por última vez en esa forma: se hashea antes de
	// tocar la base, y el valor original no se guarda en ningún lado.
	//
	// bcrypt.DefaultCost es 10. Subirlo endurece la defensa y hace más
	// lenta la siembra; para el laboratorio, 10 está bien y es lo que
	// usarías en producción en 2022. Revisa el costo cada par de años:
	// es un parámetro que envejece con el hardware, no con el algoritmo.
	hash, err := bcrypt.GenerateFromPassword([]byte(u.Password), bcrypt.DefaultCost)
	if err != nil {
		// Este error casi siempre significa ErrPasswordTooLong (>72 bytes).
		// Manejarlo en vez de ignorarlo es lo que evita el truncado
		// silencioso del que habla 4.1.
		return fmt.Errorf("hasheando la contraseña de %s: %w", u.Email, err)
	}

	_, err = tx.ExecContext(ctx, db.Rebind(`
		INSERT INTO users (id, email, password_hash, name)
		VALUES (?, ?, ?, ?)
		ON CONFLICT (id) DO UPDATE
		SET email = EXCLUDED.email, password_hash = EXCLUDED.password_hash,
		    name = EXCLUDED.name`),
		u.ID, u.Email, string(hash), u.Name)
	if err != nil {
		return fmt.Errorf("sembrando el usuario %s: %w", u.Email, err)
	}
}
```

> 🧠 **Corre la siembra dos veces y mira los dos hashes.** Son distintos, y la
> contraseña es la misma. Esa es la sal aleatoria haciendo su trabajo: dos
> usuarios con la misma contraseña no comparten hash, y por lo tanto una tabla
> filtrada no revela quién usa la misma clave que quién.

### 5.3 El paquete `auth`, con `dgrijalva/jwt-go` v3.2.0

Ahora la parte que hay que hacer **exactamente así**, aunque sepas cómo termina.

```bash
go get github.com/dgrijalva/jwt-go@v3.2.0+incompatible
```

> 📝 **Por qué esta librería y no otra.** En 2022, `dgrijalva/jwt-go` era *la*
> librería de JWT en Go: la que aparecía en todos los tutoriales, la que estaba
> en el `go.mod` de miles de proyectos. Elegirla no era una mala decisión — era
> **la** decisión. Que esté acá no es una trampa didáctica: es lo que había.
>
> Fíjate en el `+incompatible` del `go get`. Eso significa que el repositorio
> etiquetó una v3 sin declarar el sufijo `/v3` en su módulo, como pide el
> versionado semántico de Go. Es una señal, y es de las que se aprenden a leer
> tarde.

```go
// server/internal/auth/auth.go
package auth

import (
	"errors"
	"fmt"
	"time"

	"github.com/dgrijalva/jwt-go"
	"golang.org/x/crypto/bcrypt"
)

var (
	ErrInvalidCredentials = errors.New("email o contraseña incorrectos")
	ErrInvalidToken       = errors.New("token inválido o expirado")
)

// Claims son los datos que viajan firmados. StandardClaims trae los campos
// registrados del RFC 7519 (sub, exp, iat, aud, iss).
//
// ⚠️ Todo lo que pongas acá viaja en Base64, LEGIBLE POR CUALQUIERA. Está
// firmado, no cifrado. Nada de datos sensibles: ni el hash, ni el documento
// del usuario, ni nada que no pondrías en una postal.
type Claims struct {
	Email string `json:"email"`
	jwt.StandardClaims
}

type Signer struct {
	secret []byte
	ttl    time.Duration
}

func NewSigner(secret string, ttl time.Duration) (*Signer, error) {
	// Un secreto corto es un secreto que se rompe por fuerza bruta offline:
	// el atacante tiene el token y todo el tiempo del mundo. 32 bytes es el
	// mínimo razonable para HS256.
	if len(secret) < 32 {
		return nil, errors.New("JWT_SECRET debe tener al menos 32 caracteres")
	}
	return &Signer{secret: []byte(secret), ttl: ttl}, nil
}

// Sign emite el token de un usuario.
func (s *Signer) Sign(userID int64, email string) (string, error) {
	now := time.Now()
	claims := Claims{
		Email: email,
		StandardClaims: jwt.StandardClaims{
			// sub es el usuario. Es la única fuente de identidad que el
			// backend va a aceptar a partir de esta fase.
			Subject:   fmt.Sprintf("%d", userID),
			IssuedAt:  now.Unix(),
			ExpiresAt: now.Add(s.ttl).Unix(),
			Issuer:    "raffles-api",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := token.SignedString(s.secret)
	if err != nil {
		return "", fmt.Errorf("firmando el token: %w", err)
	}
	return signed, nil
}

// Verify valida firma y expiración, y devuelve el id del usuario.
func (s *Signer) Verify(tokenString string) (int64, error) {
	var claims Claims

	_, err := jwt.ParseWithClaims(tokenString, &claims, func(t *jwt.Token) (interface{}, error) {
		// 🧭 ESTAS TRES LÍNEAS SON LO MÁS IMPORTANTE DEL ARCHIVO.
		//
		// La cabecera del token la elige QUIEN LO MANDA. Sin esta
		// comprobación, un atacante cambia alg a "none", borra la firma, y
		// una implementación ingenua acepta el token porque "el algoritmo
		// declarado dice que no hay que verificar nada".
		//
		// La función de verificación devuelve la clave; si no compruebas
		// que el método es el que TÚ elegiste, estás delegando en el
		// atacante la decisión de cómo se verifica su propio token.
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("algoritmo inesperado: %v", t.Header["alg"])
		}
		return s.secret, nil
	})
	if err != nil {
		return 0, ErrInvalidToken
	}

	var userID int64
	if _, err := fmt.Sscanf(claims.Subject, "%d", &userID); err != nil {
		return 0, ErrInvalidToken
	}
	return userID, nil
}

// CheckPassword compara la contraseña con el hash guardado.
//
// bcrypt.CompareHashAndPassword tarda lo mismo acierte o falle, y eso no es
// casualidad: una comparación que devuelve más rápido cuando el primer byte
// no coincide filtra información. Nunca compares hashes con ==.
func CheckPassword(hash, plain string) error {
	if err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(plain)); err != nil {
		// Se devuelve SIEMPRE el mismo error, tanto si el usuario no existe
		// como si la contraseña está mal. Distinguirlos le regala al
		// atacante un enumerador de cuentas válidas.
		return ErrInvalidCredentials
	}
	return nil
}
```

### 5.4 `POST /login` y el middleware

```go
// server/internal/http/auth.go

// LoginHandler → POST /login
//
// 🧭 La forma de la RESPUESTA es contrato: { id, email, name, token }, con
// token como string opaca. Es exactamente lo que devolvía el mock, y por eso
// el authSlice, el interceptor y los componentes no cambian. Lo único que
// cambia es que ahora ese string está firmado y expira.
func LoginHandler(svc *auth.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var body struct {
			Email    string `json:"email"`
			Password string `json:"password"`
		}
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			writeError(w, http.StatusBadRequest, "Cuerpo inválido")
			return
		}

		session, err := svc.Login(r.Context(), body.Email, body.Password)
		if errors.Is(err, auth.ErrInvalidCredentials) {
			// 401 con el mensaje en español que authService traduce a la UI.
			//
			// ⚠️ Detalle que importa: el interceptor de respuesta de la
			// Fase 2 dispara el manejo global de sesión ante un 401. Que
			// ESTE 401 —el de un login fallido, cuando todavía no hay
			// sesión— no cause un efecto raro es algo que hay que
			// COMPROBAR en el navegador, no suponer. Ejercicio 17.
			writeError(w, http.StatusUnauthorized, "Email o contraseña incorrectos")
			return
		}
		if err != nil {
			writeError(w, http.StatusInternalServerError, "Error interno del servidor")
			return
		}
		writeJSON(w, http.StatusOK, session)
	}
}

// authMiddleware verifica el token y deja el id del usuario en el contexto.
func authMiddleware(signer *auth.Signer) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			header := r.Header.Get("Authorization")
			// El formato lo fija el interceptor de la Fase 2 desde el día
			// uno: "Bearer <token>". Se compara sin distinguir mayúsculas
			// porque el RFC 7235 dice que el esquema es case-insensitive.
			parts := strings.SplitN(header, " ", 2)
			if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
				writeError(w, http.StatusUnauthorized, "Token inválido o expirado")
				return
			}

			userID, err := signer.Verify(parts[1])
			if err != nil {
				// Mismo mensaje que inyectaba el caos del mock, a
				// propósito: el frontend ya sabe reaccionar a este 401 y
				// no tiene por qué distinguir un token vencido de uno
				// falsificado. El que sí tiene que distinguirlos es el
				// log del servidor.
				writeError(w, http.StatusUnauthorized, "Token inválido o expirado")
				return
			}

			// La identidad entra al contexto. De acá en adelante, NINGÚN
			// handler vuelve a mirar el cuerpo para saber quién pide.
			ctx := context.WithValue(r.Context(), userIDKey, userID)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// UserIDFrom es la única puerta a la identidad. Devuelve 0 si no hay
// ninguna, y un service que reciba 0 debe rechazar la operación: es el
// caso "alguien montó una ruta protegida fuera del middleware".
func UserIDFrom(ctx context.Context) int64 {
	if id, ok := ctx.Value(userIDKey).(int64); ok {
		return id
	}
	return 0
}
```

Y el montaje, que tiene una decisión escondida:

```go
// server/internal/http/router.go (extracto)

// Público: solo el login y el andamiaje del laboratorio.
r.HandleFunc("/login", LoginHandler(authSvc)).Methods(http.MethodPost)
r.HandleFunc("/health", healthHandler(db)).Methods(http.MethodGet)
r.HandleFunc("/_chaos", chaosHandler(chaos)).Methods(http.MethodPost)

// Protegido: todo el dominio. Un subrouter con su propio middleware.
api := r.NewRoute().Subrouter()
api.Use(authMiddleware(signer))
api.HandleFunc("/raffles", ListRafflesHandler(raffleSvc)).Methods(http.MethodGet)
// … el resto del dominio
```

> ⚠️ **Esto es una validación MÁS ESTRICTA que la del mock, y por lo tanto un
> riesgo de contrato.** El régimen de crecimiento de `be00` admite validaciones
> más permisivas, nunca más estrictas: hasta ayer, `GET /raffles` respondía sin
> token y ahora exige uno.
>
> Se acepta porque **es la deuda que la fase cobra** —un backend que no verifica
> quién pide no es un backend—, pero no se acepta por fe: se **mide**. El
> frontend manda `Authorization` en toda petición con sesión activa y la guarda
> de rutas impide llegar a esas pantallas sin sesión, así que en la práctica no
> se rompe nada. Compruébalo tú en el recorrido completo antes de darlo por
> bueno, y anota el resultado en `CONTRACT.md`. Si alguna pantalla pide datos
> antes del login, la encontraste ahora y no en producción.

### 5.5 Las transiciones, custodiadas donde corresponde

```go
// server/internal/raffle/transitions.go
package raffle

// legalTransitions es la máquina de estados del dominio, escrita una sola
// vez y en el service. El frontend puede pedir lo que quiera; acá se decide.
var legalTransitions = map[string][]string{
	"draft":    {"open"},
	"open":     {"closed"},
	"closed":   {"resolved"},
	"resolved": {"settled"},
	"settled":  {}, // estado final: de acá no se sale
}

var ErrIllegalTransition = errors.New("esa rifa no puede pasar a ese estado")

func canTransition(from, to string) bool {
	// Un PUT que no cambia el estado no es una transición: es una edición
	// de otros campos. Permitirlo explícitamente evita que el CRUD de la
	// Fase 4 —que manda la rifa entera en cada PUT— empiece a fallar.
	if from == to {
		return true
	}
	for _, allowed := range legalTransitions[from] {
		if allowed == to {
			return true
		}
	}
	return false
}

// Update aplica la edición verificando la transición.
func (s *Service) Update(ctx context.Context, incoming Raffle) (Raffle, error) {
	current, err := s.store.FindByID(ctx, incoming.ID)
	if err != nil {
		return Raffle{}, err
	}

	if !canTransition(current.Status, incoming.Status) {
		return Raffle{}, fmt.Errorf("de %q a %q: %w",
			current.Status, incoming.Status, ErrIllegalTransition)
	}

	// 🧭 La identidad sale del contexto. Si el cuerpo trajera un ownerId,
	// se IGNORA — no se valida, se ignora. Validarlo sería admitir que a
	// veces el cliente puede decidir quién es.
	//
	// 💸 Hoy solo se registra en el log: no hay columna owner_id ni reglas
	// de propiedad. Autorización a nivel de objeto es be-a-08.
	log.Printf("[req-id %s] usuario %d cambia la rifa %d de %s a %s",
		RequestIDFrom(ctx), UserIDFrom(ctx), incoming.ID, current.Status, incoming.Status)

	return s.store.Update(ctx, incoming)
}
```

El handler traduce el error de dominio a `409`, con la misma semántica que el
`409` de venta duplicada que la Fase 5 ya sabe mostrar: la petición está bien
formada, el estado del recurso no la permite.

### 5.6 🚨 El descubrimiento

Con todo funcionando, haz lo que deberías hacer con cualquier dependencia antes
de que llegue a producción:

```bash
cd server
go list -m -u all | grep jwt
go list -m -versions github.com/dgrijalva/jwt-go
```

Y después abre el repositorio. Vas a encontrarte con que el proyecto **está
archivado**, que su README remite a otro sitio, y que hay un aviso de seguridad
abierto **sin parche disponible**.

Este es el aviso, y es el que hay que leer entero:

- **`GHSA-w73w-5m7g-f7qc`** — https://github.com/advisories/GHSA-w73w-5m7g-f7qc
- **`CVE-2020-26160`** — https://nvd.nist.gov/vuln/detail/CVE-2020-26160

Lo verificado contra el aviso, al escribir esta fase: afecta a
`github.com/dgrijalva/jwt-go` **hasta la v3.2.0 inclusive** —o sea, exactamente
la que acabas de instalar—, severidad **alta (CVSS 7.5)**, publicado el **30 de
septiembre de 2020** en la NVD. **No hay parche**: la solución es migrar al fork
`golang-jwt/jwt`, desde su v3.2.1.

El fallo, en una frase: cuando el *claim* de audiencia (`aud`) llega como un
arreglo vacío, la aserción de tipo falla y la audiencia queda como cadena vacía.
Una aplicación que confíe **solo** en esta librería para verificar la audiencia
puede aceptar un token que no era para ella.

> 🧠 **Lee esto antes de encogerte de hombros.** Es tentador decir "pero nosotros
> no usamos `aud`, no nos afecta". Puede que tengas razón — y esa evaluación es
> exactamente el trabajo, no un atajo para saltárselo. Lo que sí te afecta seguro
> es lo otro: **la librería está abandonada**. El CVE es el síntoma; el problema
> es que el próximo hallazgo tampoco va a tener parche. Se migra por eso.
>
> ⚠️ **Verifica todo esto tú mismo antes de citarlo.** Los avisos se actualizan,
> las severidades se recalculan y los enlaces cambian. Los datos de arriba se
> confirmaron contra el aviso oficial al escribir esta fase, y aun así el
> procedimiento correcto es abrirlo y leerlo — que es, además, la mitad de lo que
> esta fase enseña. `be-a-04` explica cómo se lee un aviso de seguridad línea por
> línea.

### 5.7 La migración al fork

```bash
go get github.com/golang-jwt/jwt/v4@v4.4.2
go mod edit -droprequire github.com/dgrijalva/jwt-go
go mod tidy
```

El cambio en el código es sorprendentemente pequeño, y esa pequeñez **también es
contenido**: un fork bien hecho conserva la superficie de la API para que migrar
no sea una excusa para no migrar.

```go
// ANTES                                    // DESPUÉS
import "github.com/dgrijalva/jwt-go"        import "github.com/golang-jwt/jwt/v4"

jwt.StandardClaims                          jwt.RegisteredClaims
IssuedAt:  now.Unix()                       IssuedAt:  jwt.NewNumericDate(now)
ExpiresAt: now.Add(ttl).Unix()              ExpiresAt: jwt.NewNumericDate(now.Add(ttl))
```

Los tres cambios de v4 tienen su razón y vale la pena entenderlos en vez de
aplicarlos a ciegas:

- **`StandardClaims` → `RegisteredClaims`.** El nombre del RFC 7519 es "claims
  registrados". El anterior nunca fue el correcto.
- **`int64` → `*jwt.NumericDate`.** Con `int64`, "sin expiración" y "expira en el
  epoch" son el mismo valor: `0`. Con un puntero, ausente y cero son distintos.
  Es la misma lección del `participantId` de `be03`, en otra capa.
- **La verificación de `aud` cambió**, que es lo que arregla el CVE.

Comprueba que la deuda se pagó de verdad:

```bash
grep -rn "dgrijalva" . ; go list -m all | grep jwt
```

El primero no debe devolver nada, y el segundo solo `golang-jwt`.

### 5.8 La excepción: el único archivo del frontend

Ha llegado el momento de ejecutar `D27` / `C-06`. **Un archivo. Solo este.**

```javascript
// src/api/authService.js
import apiClient from './apiClient';

/**
 * Login contra el backend real (be04). Antes esto filtraba /users por query
 * string con la password a la vista; ahora las credenciales viajan en el
 * cuerpo de un POST y el token que vuelve es un JWT firmado que expira.
 *
 * Lo que NO cambió, y es el punto de toda la fase: la forma que este módulo
 * devuelve al resto de la app. authSlice, apiClient, sus dos interceptores y
 * los componentes siguen exactamente igual, porque siguen recibiendo
 * { id, email, name, token }.
 * @param {{ email: string, password: string }} credentials
 * @returns {Promise<{ id: number, email: string, name: string, token: string }>}
 */
export async function login({ email, password }) {
  try {
    const { data } = await apiClient.post('/login', { email, password });
    return data;
  } catch (error) {
    // El backend responde 401 con { message }. Se traduce al mismo error
    // legible que este módulo tiraba antes, para que LoginForm no cambie.
    if (error.response?.status === 401) {
      throw new Error('Email o contraseña incorrectos');
    }
    throw error;
  }
}

export default { login };
```

Y ahora la verificación que demuestra que la excepción se respetó:

```bash
# Debe listar UN archivo y solo uno.
git diff --name-only pre-backend-go..HEAD -- . ':!server'

# Y este comando —el que usan todas las fases desde acá— debe salir vacío:
git diff pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js'
```

### 5.9 El contrato cambió: actualízalo

`be00` fue tajante: el contrato es lo que se observa. Acabas de cambiar lo que se
observa, así que el contrato y su checklist se actualizan **en esta fase**, no
"cuando haya tiempo".

En `server/CONTRACT.md`: `GET /users?email=…&password=…` sale del régimen
estricto, con una nota de que se retiró en `be04` por la excepción `D27`, y entra
`POST /login` con su cuerpo, su respuesta y su `401`.

En `server/smoke.sh`, las verificaciones 1 y 2:

```bash
# 1. Login correcto: 200 con el token firmado.
LOGIN=$(curl -s -X POST "$BASE/login" -H 'Content-Type: application/json' \
        -d '{"email":"organizador@rifas.test","password":"rifas123"}')
check "POST /login válido devuelve token" \
      "true" "$(echo "$LOGIN" | jq 'has("token")')"
# Un JWT tiene tres partes separadas por puntos. Si esto falla, alguien
# devolvió una constante otra vez.
check "el token es un JWT (tres partes)" \
      "3" "$(echo "$LOGIN" | jq -r '.token' | tr '.' '\n' | wc -l | tr -d ' ')"

# 2. Credenciales inválidas: 401, y NO 200 con array vacío.
check "credenciales inválidas devuelven 401" "401" \
      "$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/login" \
         -H 'Content-Type: application/json' \
         -d '{"email":"nadie@rifas.test","password":"x"}')"
```

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. No comprobar el método de firma.** Síntoma: ninguno, hasta que alguien entra
con un token que se fabricó solo. Causa: la función de verificación devuelve la
clave sin mirar `t.Method`. Fix: las tres líneas de 5.3. Es **la** vulnerabilidad
clásica de JWT y sigue apareciendo en auditorías todos los años.

**2. Distinguir "usuario no existe" de "contraseña incorrecta".** Síntoma:
ninguno visible; el sistema parece más amable. Causa: dos ramas de error
distintas en el login. Por qué importa: le regala a un atacante un enumerador de
cuentas válidas, y con eso el ataque siguiente es dirigido. Fix: un solo error
para los dos casos, y el mismo tiempo de respuesta.

**3. El secreto en el código.** Síntoma: funciona perfecto. Causa: `JWT_SECRET`
con un valor por defecto en el struct de configuración, "para que sea fácil
levantarlo". Fix: `required:"true"` y que el proceso no arranque sin él. Un
secreto con valor por defecto es un secreto público — está en el repositorio, en
la imagen y en el historial de git.

**4. Cambiar el nombre del campo `token`.** Síntoma: el login "funciona" —el
`POST` devuelve `200`— y todas las peticiones siguientes dan `401`. Causa:
alguien lo llamó `accessToken`, que es mejor nombre. Fix: volver a `token`. El
contrato manda: `authSlice` lee `token` y el interceptor lee del store.

**5. Verificar el token en el handler y no en el middleware.** Síntoma: funciona
en las cinco rutas que revisaste y falla —abierta— en la sexta. Causa: la
verificación como responsabilidad de cada handler. Fix: middleware sobre el
subrouter. La regla operativa: **una ruta protegida tiene que estar protegida por
dónde está montada, no por lo que recuerde su autor**.

**6. Olvidar el `exp`.** Síntoma: ninguno, durante años. Causa: no poner
`ExpiresAt`. Un token sin expiración es una llave maestra permanente: quien lo
copie de un log, de una captura o del `localStorage` de un equipo prestado entra
para siempre.

### 🩻 Pieza forense de esta fase

**Un token manipulado, y el ataque que casi funciona.**

*Paso 1 — mira lo que estás mandando.* Loguéate en la aplicación, copia el token
del store (Redux DevTools) o del header `Authorization` en Network, y pégalo en
https://jwt.io. Lee el `payload` **sin ninguna clave**: ahí está el `sub`, el
`exp`, el `email`. Anota la conclusión con tus palabras: *un JWT no es secreto,
es verificable*. Si en algún proyecto tuyo hay datos personales en un token, hoy
es un buen día para revisarlo.

*Paso 2 — modifícalo.* En jwt.io, cambia el `sub` a otro id y copia el token
resultante:

```bash
curl -i localhost:3001/raffles -H "Authorization: Bearer <token-manipulado>"
```

`401`. La firma no cuadra porque no tienes el secreto. Anota el mensaje del log
del servidor y compáralo con el que ve el cliente: **el servidor sabe qué pasó y
el cliente no se entera**. Esa asimetría es deliberada y es buen diseño de
seguridad; `be-a-08` la trata a fondo.

*Paso 3 — el ataque `alg: none`.* Fabrica un token sin firma:

```bash
# Cabecera {"alg":"none","typ":"JWT"} y payload con el sub que quieras,
# en Base64URL, y la tercera parte VACÍA (el punto final va igual).
HEADER=$(printf '{"alg":"none","typ":"JWT"}' | base64 | tr '+/' '-_' | tr -d '=')
PAYLOAD=$(printf '{"sub":"1","exp":9999999999}' | base64 | tr '+/' '-_' | tr -d '=')
curl -i localhost:3001/raffles -H "Authorization: Bearer $HEADER.$PAYLOAD."
```

Con tu código, `401`: la comprobación de `t.Method` lo rechaza antes de mirar
nada más.

*Paso 4 — ahora quita la defensa.* Comenta las tres líneas del `if _, ok :=
t.Method.(*jwt.SigningMethodHMAC)` y repite el paso 3.

Anota lo que pasa. Anótalo con cuidado, porque es el momento de la fase: **el
comportamiento exacto depende de la versión de la librería** —las modernas se
niegan a aceptar `none` aunque tú no lo compruebes— y esa dependencia es
precisamente la lección. Si tu defensa consiste en que la librería se porte bien,
tu defensa es la política de mantenimiento de un tercero. Que es, exactamente,
por lo que acabas de migrar de librería.

*Paso 5 — el token vencido.* Baja `JWT_TTL` a un minuto, loguéate, espera, y usa
la aplicación. El `401` llega, el interceptor de la Fase 2 hace logout global, y
el usuario aterriza en el login sin explicación. **Ese es el aspecto exacto de la
deuda 💸 del refresh token.** Escríbelo tal cual en el mapa de deuda: no como
"falta implementar refresh", sino como "al vencer el token, el usuario pierde lo
que estuviera haciendo".

*Paso 6 — el círculo, con identidad.* Haz una venta y sigue el `X-Request-Id`
desde la consola del navegador hasta el log del backend. Ahora esa línea tiene
también el `userID`, sacado del token y no del cuerpo. Compárala con la de
`be03`: la diferencia entre las dos líneas es toda la fase.

---

## 🧪 7. Ejercicios (32)

**🟢 Fácil (1–8)**

1. Aplica la migración `000004` y comprueba en `psql` que `users.token` ya no existe y que la columna se llama `password_hash`.
2. Siembra dos veces y verifica que los hashes de la misma contraseña son distintos. Explica por qué en una línea.
3. Haz `POST /login` con `curl` y comprueba que el token tiene tres partes.
4. Pega el token en jwt.io y anota qué campos son legibles sin clave.
5. Comprueba que `POST /login` con contraseña incorrecta devuelve `401` con `{"message":…}`.
6. Verifica que `GET /raffles` sin `Authorization` devuelve `401`.
7. Arranca el binario sin `JWT_SECRET` y comprueba que no arranca.
8. Ejecuta el `git diff` de 5.8 y confirma que solo aparece `authService.js`.

**🟡 Intermedio (9–19)**

9. Haz el recorrido completo en la aplicación con el backend nuevo y confirma que el login funciona igual que antes desde la interfaz.
10. **Diagnóstico.** Renombra el campo `token` a `accessToken` en la respuesta y describe con precisión en qué punto falla la aplicación y por qué el login parece haber funcionado.
11. Implementa la tabla de transiciones y comprueba con `curl` que un `PUT` de `draft` a `settled` devuelve `409`.
12. **Diagnóstico.** Manda un `PUT /raffles/1` con un campo `ownerId` inventado. Demuestra que el backend lo ignora y encuentra dónde se descarta.
13. Comprueba que un `PUT` que no cambia el estado sigue funcionando, y explica por qué esa excepción de `canTransition` es necesaria para el CRUD de la Fase 4.
14. **Diagnóstico.** Provoca el paso 2 de la pieza forense (token manipulado) y correlaciona el `401` que ve el navegador con la línea del log del servidor por su `X-Request-Id`.
15. Baja `JWT_TTL` a 60 segundos y documenta la experiencia de usuario completa cuando vence a mitad de una venta.
16. Agrega el `userID` a la línea de log de cada petición autenticada y verifica que sale del token.
17. **Diagnóstico.** Comprueba en el navegador qué hace el interceptor de respuesta de la Fase 2 con el `401` de un login fallido. ¿Dispara el logout global? Si lo hace, ¿se nota? Documenta el resultado: es la clase de interacción que solo aparece midiendo.
18. Actualiza `CONTRACT.md` y `smoke.sh` con el nuevo login y déjalo pasando entero.
19. **Diagnóstico.** Intenta hacer login con una contraseña de 100 caracteres. Determina qué pasa y en qué capa.

**🟠 Difícil (20–27)**

20. **Diagnóstico.** Ejecuta los pasos 3 y 4 de la pieza forense y escribe el informe del `alg: none`, incluida la conclusión sobre depender de la librería para defenderte.
21. Escribe la prueba de Go que falla si alguien quita la comprobación de `t.Method`. Esa prueba es más importante que la comprobación misma: argumenta por qué.
22. **Diagnóstico.** Antes de migrar, evalúa por escrito si `CVE-2020-26160` afecta a **este** backend. Lee el aviso, mira si usamos `aud`, y llega a una conclusión razonada. Después migra igual y explica por qué la conclusión no cambia la decisión.
23. Ejecuta la migración a `golang-jwt/jwt/v4` en un commit propio y deja el `go.mod` limpio. Verifica con `grep` y con `go list -m all`.
24. **Diagnóstico.** Rompe la migración a propósito: migra el import pero deja `StandardClaims`. Lee el error del compilador y explica qué te está diciendo el diseño de v4.
25. Escribe la prueba que verifica que un token firmado con **otro** secreto se rechaza, y otra que verifica que uno vencido se rechaza. Explica por qué son dos pruebas y no una.
26. **Diagnóstico.** Enforcing de auth sobre `/raffles`: demuestra con el recorrido completo que ninguna pantalla pide datos antes del login. Si encuentras una, documéntala como hallazgo de contrato con su código `C-NN`.
27. Diseña el registro de auditoría que dejaría rastro de quién cambió el estado de cada rifa. Decide si va en una tabla, en el log, o en las dos, y justifica con lo que `be07` va a necesitar para su trazabilidad inmutable.

**🔴 Muy difícil (28–32)**

28. **Post-mortem.** Escribe `server/postmortem-jwt.md` según la guía §13: síntoma (una dependencia central archivada con un aviso sin parche), evidencia (el aviso, las fechas, la versión afectada), causa raíz, corrección, prueba de regresión y prevención. **Sin culpabilización**: adoptar `dgrijalva/jwt-go` en 2020 era la decisión correcta con la información de 2020. La prevención tiene que ser un mecanismo verificable, no "estar más atentos".
29. Diseña e implementa ese mecanismo: algo que avise cuando una dependencia del `go.mod` quede archivada o adquiera un aviso. Puede ser tosco (`govulncheck` en CI, un script contra la API de avisos). `be09` lo va a querer en el pipeline.
30. Argumenta por escrito si el token debería guardarse en `localStorage` —donde está hoy— o en una cookie `HttpOnly`. Defiende las dos posturas con XSS y CSRF sobre la mesa, y después responde la pregunta que de verdad importa acá: **¿podrías cambiarlo sin tocar el frontend?** Deja la conclusión en el mapa de deuda.
31. Diseña la implementación completa de *refresh tokens* para este sistema: endpoints, almacenamiento, rotación, revocación. Enumera **exactamente** qué archivos del frontend habría que tocar y calcula si eso cabe dentro de la excepción `D27`. Concluye si se haría, y con qué plan.
32. **Diagnóstico + regresión.** Ticket: *"algunos usuarios dicen que los saca de la sesión al mediodía, todos los días, y otros nunca"*. Con lo que sabes de `exp` y de la ausencia de refresh, reconstruye la causa, di cómo la confirmarías con los logs que tienes, y escribe la prueba de regresión y la comunicación al usuario.

**🔥 Opcionales**

- 🔥 Sustituye HS256 por RS256 (par de claves) y explica qué gana el sistema: quién puede firmar, quién puede verificar, y por qué eso importa el día que haya un segundo servicio.
- 🔥 Implementa una lista de revocación en memoria para invalidar un token antes de su `exp`, y después argumenta qué acabas de perder — pista: era la propiedad que hacía atractivo el JWT.
- 🔥 Ejecuta `govulncheck` sobre el módulo antes y después de la migración, y guarda las dos salidas.

---

## 📚 8. Referencias

**Documentación oficial y avisos**
- https://github.com/advisories/GHSA-w73w-5m7g-f7qc — el aviso de GitHub. **Ábrelo y léelo**: es material de la fase, no una nota al pie.
- https://nvd.nist.gov/vuln/detail/CVE-2020-26160 — la entrada en la NVD, con el vector CVSS desglosado.
- https://github.com/golang-jwt/jwt — el fork, con su guía de migración desde `dgrijalva`.
- https://pkg.go.dev/golang.org/x/crypto/bcrypt — la API, `DefaultCost` y `ErrPasswordTooLong`.
- https://www.rfc-editor.org/rfc/rfc7519 — JWT. Para hoy: §4.1 (claims registrados).
- https://www.rfc-editor.org/rfc/rfc8725 — *JSON Web Token Best Current Practices*. El documento más útil de esta lista: el §3.1 es el `alg: none` explicado por quienes escribieron el estándar.
- https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html — almacenamiento de contraseñas, con recomendaciones de costo actualizadas.
- https://jwt.io — el depurador de la pieza forense. Pega **tokens de laboratorio**, nunca uno de producción: es una página web y el token es una credencial.

**Libros**
- *Web Application Security* (Andrew Hoffman) — los capítulos de autenticación y de ataques sobre tokens.
- *Security Engineering* (Ross Anderson) — el capítulo sobre contraseñas, para entender por qué `bcrypt` es lento a propósito. La tercera edición está disponible en el sitio del autor.

**Video / apoyo**
- Busca "JWT alg none attack" y "bcrypt vs sha256 password" en YouTube. Hay charlas cortas y buenas; verifica que la demostración corresponda a una librería actual, porque muchas usan implementaciones ya corregidas.

**Orden de lectura sugerido:** el aviso `GHSA-w73w-5m7g-f7qc` primero, entero,
antes de escribir código —así la migración de 5.7 llega con contexto— → RFC 8725
§3, que son tres páginas y cubren todos los errores comunes de esta fase →
`be-a-04` para la anatomía completa del token → `be-a-08` cuando quieras el resto
del panorama de seguridad de la API.

> ⚠️ URLs, títulos, severidades y fechas pueden haber cambiado: **verifícalos**.
> Los datos del CVE de esta fase se confirmaron contra el aviso oficial al
> escribirla, y aun así el procedimiento correcto es abrirlo. Las referencias a
> libros son de memoria y pueden ser inexactas. Cualquier discrepancia de
> versiones la resuelve `prompts/decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Cuatro deudas pagadas. Las contraseñas son hashes con sal, el token es un JWT
firmado que expira, la identidad sale del token y no del cuerpo, y las
transiciones de estado las custodia el servicio. La columna de la vergüenza que
`be03` creó ya no existe, y el `go.mod` pasó por una librería abandonada y salió
del otro lado con un post-mortem escrito.

El frontend, mientras tanto, cambió **un archivo**: el que la Fase 2 había
señalado con el dedo dos años antes.

Queda una deuda declarada y viva: sin *refresh token*, un token vencido tira al
usuario al login. Está en el mapa de deuda con su motivo, y `be09` la va a
recoger en el veredicto honesto del track.

`be05` es la primera de las dos fases ⭐ y va al corazón del curso. Ya sabes quién
vende; falta que **dos personas no puedan vender el mismo número**. El `if` de
`SellNumber` sigue exactamente igual de indefenso que en el mock, y esta vez no
se traduce de lenguaje: se resuelve donde se resuelve, con un índice único, una
transacción y `SELECT … FOR UPDATE`. Vas a ver dos clientes peleando por el
número `0347` desde la línea de comandos y la transacción bloqueada en
`pg_stat_activity` — el bloqueo, en pantalla, no imaginado.

> **La señal de que quedó bien:** *"el backend ya no le cree nada al navegador
> sobre quién es, y el frontend no se dio cuenta del cambio."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be04-identidad-real-jwt-y-un-cve -m "be04 cerrada: \
> migración 000004 con password_hash y sin columna token; siembra que hashea con bcrypt; \
> POST /login firmando JWT en el mismo campo token; middleware de verificación; \
> identidad desde req.Context(); transiciones custodiadas en el service; \
> dgrijalva/jwt-go adoptado y migrado a golang-jwt/jwt v4 con post-mortem; \
> excepción D27 ejecutada en un solo archivo; CONTRACT.md y smoke.sh actualizados"
> ```
>
> Los commits de la fase llevan su prefijo (`be04: …`) y los de ejercicio su
> número (`be04 ej28: …`). La adopción y la migración de la librería van en **dos
> commits distintos** —`be04: adopta dgrijalva/jwt-go v3.2.0` y
> `be04: migra a golang-jwt/jwt v4 (CVE-2020-26160)`—: el `git log` de esta fase
> tiene que contar la historia solo. Si un ejercicio merece su propio marcador va
> en `ej/be04/28`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **El comando de verificación cambia a partir de acá.** Todas las fases `be05` a
  `be09` deben usar
  `git diff pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js'` en su
  checklist de la sección 2. Está en `D27`; que ninguna lo olvide.
- **`CONTRACT.md` y `smoke.sh` cambiaron en esta fase.** Es la primera vez que el
  contrato se modifica desde `be00`, y sienta el precedente: cuando una fase
  cambia lo observable, actualiza los dos documentos **en la misma fase**. `be08`
  debería verificarlo automáticamente.
- **El CVE hay que reverificarlo al publicar o revisar el curso.** Los datos se
  confirmaron contra `GHSA-w73w-5m7g-f7qc` al escribir la fase (CVE-2020-26160,
  CVSS 7.5, publicado 2020-09-30, afecta ≤ v3.2.0, sin parche, migrar a
  `golang-jwt` ≥ 3.2.1). Las severidades se recalculan; el texto ya advierte al
  alumno que verifique, pero la revisión editorial debería rehacerlo.
- **Deuda 💸 viva declarada: sin *refresh token*.** Tiene que aparecer en
  `be-a-09` (mapa de deuda del track BE) y en el veredicto honesto de `be09`. Es
  la deuda que el track decide **no** pagar, y decir por qué es más valioso que
  pagarla.
- **Deudas menores declaradas:** 💸 no hay `owner_id` ni autorización a nivel de
  objeto (solo se registra en el log; `be-a-08`); 💸 sin límite de intentos de
  login (`be-a-08`); 💸 el token vive en `localStorage` y cambiarlo requeriría
  tocar el frontend (ejercicio 30, y va al mapa de deuda).
- **`be05` empieza con el `if` de `SellNumber` intacto.** Esta fase no lo tocó a
  propósito. Que `be05` abra reproduciendo la carrera con el código que el alumno
  ya tiene.
- **`be06` hereda las transiciones.** Hoy se custodian por *orden*; cuando el
  reloj sea autoridad del servidor, `open → closed` va a poder dispararse también
  por tiempo y no solo por petición. Que `be06` lo recoja explícitamente.
- **`be07` hereda el ejercicio 27** (registro de auditoría) como insumo directo de
  su trazabilidad como registro inmutable.
- **Reserva para el cuaderno de incidentes:** `be-08` — *"a algunos usuarios los
  saca de la sesión al mediodía y a otros nunca"* (categoría 🔥 autenticación,
  dificultad 🟡), que es el ejercicio 32 llegado como ticket vago. **Con esto se
  agota el rango `be-01`–`be-08`** que reservó `cuaderno-incidentes.md`: las
  fases `be05` a `be09` van a necesitar ampliarlo, y conviene decidir el rango
  nuevo antes de escribir `be05`.
FIN_DEL_ARCHIVO
wc -l be04-identidad-real-jwt-y-un-cve.md

# --- 2026-09-09T02:45:55 · Extend BE incident ID range
python3 - <<'PY'
import io
p='cuaderno-incidentes.md'
s=io.open(p,encoding='utf-8').read()
old="""choquen con los veinte de arriba tienen **rango propio: `be-01` a `be-08`**. No
están redactados ni asignados todavía —se reservan cuando se escriba cada fase,
en su sección de 📌 Pendientes— pero el rango queda tomado desde ya, igual que
los veinte del track base."""
new="""choquen con los veinte de arriba tienen **rango propio: `be-01` a `be-16`**. No
están redactados todavía —se reservan cuando se escriba cada fase, en su sección
de 📌 Pendientes— pero el rango queda tomado desde ya, igual que los veinte del
track base. Los ocho primeros ya están asignados: `be-01` y `be-02` en `be00`,
`be-03` en `be01`, `be-04` y `be-05` en `be02`, `be-06` y `be-07` en `be03`, y
`be-08` en `be04`. El rango se amplió de ocho a dieciséis al escribir `be04`,
porque las cinco fases restantes producen incidentes propios y el rango original
se había agotado a mitad del track."""
assert s.count(old)==1
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))
print('ok')
PY

# --- 2026-09-09T02:58:03 · 
cat > be05-venta-concurrente.md <<'FIN_DEL_ARCHIVO'
# ⭐ Fase be05 — Venta concurrente resuelta donde se resuelve

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Fase be05 de be09 · **10 horas**
> Depende de: be04 — ya hay identidad real detrás de cada venta · Habilita: be06 — Hora dura y zonas horarias

---

## 🎯 1. Propósito

La Fase 5 del track base es una de las dos ⭐ del curso y estudia las race
conditions donde el frontend puede estudiarlas: en el store, con doble clic y
peticiones que se cruzan. Hizo bien su trabajo. Pero dejó una verdad incómoda sin
decir del todo:

> 🧭 **Ninguna race condition de venta se resuelve en el cliente.** Se puede
> mitigar, disimular y hasta hacer improbable. Resolver, no.

Esta fase la resuelve donde se resuelve. Vas a ver el **mismo síntoma** —el
número `0347` vendido dos veces— que ya diagnosticaste desde Redux DevTools,
ahora reproducido desde la línea de comandos contra tu propio backend, y
arreglado con las herramientas que sí protegen: una transacción, un bloqueo
explícito y un índice único que no admite discusión.

Y hay algo que esta fase te va a pedir que hagas y que casi nunca se hace:
**medir**. Bloqueo pesimista contra optimista, sobre el mismo caso, con números.
No "el optimista escala mejor" porque lo dice un artículo: tus números, tu
hardware, tu caso.

La deuda 💸 que cobra: el `409` de venta duplicada que la Fase 3 producía con un
`if` en JavaScript sobre un archivo JSON, que `be03` tradujo a un `if` en Go
—sin ganar una gota de protección— y que acá pasa a producirlo **la base**.

> 🩻 **Antes de empezar, vuelve a leer la Fase 5 del track base.** Es lectura
> obligatoria de esta fase, no una sugerencia. El valor de lo que sigue está en
> el contraste entre las dos, y si no tienes fresco el `sellNumber` optimista con
> su rollback, la mitad del contenido se pierde.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Migración `000005`: existe la tabla `sales` con `UNIQUE (raffle_id, number)`
      y los datos históricos migrados desde `raffle_numbers`.
- [ ] Vender es **una transacción**: insertar la venta y actualizar el estado del
      número ocurren juntas o no ocurren.
- [ ] El `409` de venta duplicada lo produce **la restricción de la base**
      (`23505`), no un `if` — y el cuerpo y el mensaje siguen siendo idénticos a
      los del mock.
- [ ] Existe una prueba de concurrencia en Go que lanza N ventas simultáneas
      sobre el mismo número y verifica que **exactamente una** gana.
- [ ] Las reservas tienen expiración **del lado del servidor** (`reserved_until`)
      y hay un trabajo que las vence.
- [ ] Existe `server/evidence/concurrencia.md` con la comparación **medida**
      entre bloqueo pesimista y optimista: intentos, ganadores, errores, latencia
      p50 y p95.
- [ ] La transacción bloqueada quedó observada en `pg_stat_activity`, con la
      captura pegada en ese mismo archivo.
- [ ] Está documentado qué pasa con el mismo escenario contra **SQLite**, y por
      qué eso condena a `be08`.
- [ ] `./server/smoke.sh` sigue pasando entero y el frontend sigue sin tocarse.

---

## 🚫 3. Qué queda fuera por ahora

- **Reintentos automáticos en el cliente.** El frontend no se toca. Si una
  estrategia necesita que el cliente reintente, esa estrategia no sirve acá — y
  esa restricción, lejos de ser un estorbo, es lo que obliga a resolverlo bien.
- **La hora de cierre** → `be06`. Hoy se puede vender pasada la `closesAt` y el
  backend no dice nada. Una cosa a la vez.
- **La liquidación transaccional** → `be07`. Acá la transacción cubre una venta;
  allá cubre un reparto entero.
- **`go test -race` y la regla del motor** → `be08`. Acá se **recoge la
  evidencia** de que SQLite no puede con esto; formalizarla en regla es la otra
  fase.
- **Colas, particionado y sharding.** Si tu solución necesita infraestructura
  nueva para vender un número de rifa, sobredimensionaste el problema.

---

## 🧠 4. Conceptos mínimos

Tienes años de SQL y de transacciones. Lo que sigue no explica qué es `BEGIN`:
explica por qué el código que escribiste en `be03` está roto aunque parezca
correcto, y qué opciones reales hay.

### 4.1 El bug, con precisión

Este es el `SellNumber` de `be03`, y su problema no es de Go:

```go
current, _ := s.store.FindOne(ctx, raffleID, number)  // (1) lee: "available"
if current.Status == "sold" { return ErrAlreadySold } // (2) decide
return s.store.MarkSold(ctx, raffleID, number, ...)   // (3) escribe
```

Entre (1) y (3) hay una ventana. En esa ventana cabe **otra ejecución completa**
de (1), (2) y (3). Dos vendedores leen `available`, los dos deciden que se puede,
los dos escriben, los dos reciben `200`. El número se vendió dos veces y no hay
ningún error en ninguna parte.

Lo que hace peligroso a este bug es que **no se reproduce cuando lo buscas**. La
ventana dura microsegundos; con dos pestañas y dos clics no pasa nunca. Pasa el
día del sorteo grande, con cien vendedores, y llega como un ticket que dice "creo
que vendimos dos veces el 0347, ¿puede ser?".

> 🧠 **El patrón, con su nombre.** Esto es un *check-then-act*: verificar una
> condición y actuar sobre ella en dos operaciones separadas. Es el mismo error
> conceptual que el `if (!file.exists()) file.create()` de cualquier lenguaje. La
> solución nunca es "verificar mejor": es **hacer que la verificación y la acción
> sean una sola cosa indivisible**.

### 4.2 Por qué la transacción sola no alcanza

El primer instinto es envolver los tres pasos en `BEGIN … COMMIT` y darlo por
resuelto. No lo resuelve, y entender por qué es el corazón de la fase.

PostgreSQL usa `READ COMMITTED` por defecto. En ese nivel, cada sentencia ve una
foto de los datos confirmados **en el momento en que esa sentencia empieza**. Dos
transacciones concurrentes que hacen `SELECT status` ven las dos `available`,
porque ninguna había confirmado nada todavía. La transacción te da atomicidad —o
pasan las dos escrituras o ninguna— pero **no te da exclusión mutua**.

Lo que hay que sumar es una de estas tres cosas:

**Bloqueo pesimista.** `SELECT … FOR UPDATE` toma un bloqueo sobre la fila. La
segunda transacción que pida la misma fila **espera** hasta que la primera
confirme o revierta. Al despertar, ve el dato ya actualizado. Es explícito,
predecible, y serializa el acceso a esa fila.

**Bloqueo optimista.** No se bloquea nada: se escribe con una condición que solo
puede cumplirse una vez —`UPDATE … WHERE status = 'available'`— y se mira cuántas
filas se afectaron. Si son cero, perdiste la carrera. Nadie espera a nadie; el
perdedor se entera al final.

**Una restricción de la base.** Se diseña el esquema para que la operación
duplicada sea **imposible de representar**. Un `UNIQUE` no se puede burlar con
ninguna combinación de tiempos: es la base la que se niega. Esta es la única de
las tres que sigue protegiendo el día que alguien escriba un `INSERT` desde
`psql`, desde un script de migración o desde el servicio nuevo que nadie te
avisó que existía.

### 4.3 El problema de diseño que hay que resolver primero

Acá hay una trampa que conviene ver antes de escribir código. Hoy vender es un
`UPDATE` sobre `raffle_numbers`: la fila del número `0347` ya existe y solo cambia
su `status`. **Un `UNIQUE` no puede protegerte contra eso**, porque no hay una
segunda fila que insertar; hay una misma fila que se actualiza dos veces, y
actualizar dos veces no viola ninguna restricción.

Dicho de otro modo: con el modelo actual, la tercera opción —la más fuerte— **no
está disponible**. Y esto no es un detalle de implementación: es lo que decide
qué defensas puedes tener.

> 🧭 **Decisión de esta fase: la venta se modela como un hecho, no como un
> estado.** Se crea la tabla `sales`, donde cada venta es una fila nueva con
> `UNIQUE (raffle_id, number)`. Vender pasa a ser un `INSERT`, y entonces el
> índice único sí puede ser la última línea de defensa.

El `status` de `raffle_numbers` no desaparece —lo consume el frontend y el
contrato manda— pero cambia de naturaleza: pasa de ser **la verdad** a ser una
**proyección** de la verdad, mantenida en la misma transacción. Esa distinción
vale para el resto de tu carrera:

📖 **Un estado es un campo que se pisa. Un hecho es una fila que se agrega.** Los
estados pierden historia y no se pueden restringir; los hechos se acumulan, se
auditan y se protegen con índices. Cuando algo tiene consecuencias —dinero,
inventario, una plaza reservada—, modélalo como hecho.

Y hay un beneficio que `be07` te va a agradecer: cuando alguien pregunte quién
vendió el número ganador y a qué hora, la respuesta va a existir.

### 4.4 Niveles de aislamiento, sin misticismo

Tres niveles importan en Postgres, y la diferencia práctica es corta:

- **`READ COMMITTED`** (el de por defecto): cada sentencia ve lo confirmado al
  empezar *esa sentencia*. Permite el *check-then-act* de 4.1.
- **`REPEATABLE READ`**: toda la transacción ve la misma foto. No arregla lo
  nuestro — arregla que dos lecturas iguales devuelvan lo mismo.
- **`SERIALIZABLE`**: Postgres vigila los conflictos y **aborta** una de las
  transacciones con el error `40001` si el resultado no habría podido ocurrir en
  ningún orden secuencial.

`SERIALIZABLE` resuelve el bug sin `FOR UPDATE` y sin cambiar el modelo. Su
precio es que **el cliente tiene que reintentar**, porque una transacción abortada
no es un error de negocio: es "vuelve a intentarlo". Y acá el cliente es el
frontend heredado, que no reintenta y no se toca.

📝 Eso convierte a `SERIALIZABLE` en una opción interesante que este sistema no
puede tomar hoy — y es la clase de restricción que decide arquitecturas de
verdad. Vas a implementarla igual, en el ejercicio 29, para poder decir con
autoridad por qué no se eligió.

---

## 💻 5. Implementación y código comentado

### 5.1 La migración: el hecho en vez del estado

```sql
-- server/migrations/postgres/000005_sales_table.up.sql

-- Cada venta es un HECHO: una fila que se agrega y no se pisa. Esta tabla
-- es también el registro inmutable que be07 va a necesitar para la
-- trazabilidad de la liquidación.
CREATE TABLE sales (
    id             BIGSERIAL   PRIMARY KEY,
    raffle_id      BIGINT      NOT NULL REFERENCES raffles(id) ON DELETE CASCADE,
    number         TEXT        NOT NULL,
    participant_id BIGINT      REFERENCES participants(id),
    -- Quién vendió. Sale del token (be04), nunca del cuerpo de la petición.
    sold_by        BIGINT      NOT NULL REFERENCES users(id),
    sold_at        TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- 🧭 LA ÚLTIMA LÍNEA DE DEFENSA.
    -- No es una optimización ni una validación: es una imposibilidad. Da
    -- igual cuántas transacciones concurrentes lo intenten, en qué orden,
    -- con qué nivel de aislamiento, o si alguien entra por psql a las tres
    -- de la mañana: la segunda fila no existe.
    CONSTRAINT sales_unique_number_per_raffle UNIQUE (raffle_id, number)
);

-- Migración de los datos que ya están vendidos. El sold_by de las ventas
-- históricas no se puede saber —se hicieron cuando el backend no preguntaba
-- quién vendía (esa era la tercera deuda, y la pagó be04)— así que se
-- atribuyen al usuario 1 y se marcan.
--
-- 💸 Deuda declarada: hay ventas en la base sin autoría real. No se puede
-- reconstruir el pasado; lo que sí se puede es no esconderlo.
INSERT INTO sales (raffle_id, number, participant_id, sold_by, sold_at)
SELECT raffle_id, number, participant_id, 1, COALESCE(sold_at, now())
FROM raffle_numbers
WHERE status = 'sold';

-- Y la expiración de reservas, que ahora vive del lado del servidor.
-- La columna reserved_until existe desde be02 y nadie la había usado.
CREATE INDEX raffle_numbers_reserved_until
    ON raffle_numbers (reserved_until)
    WHERE status = 'reserved';
```

> 🧠 **Ese índice parcial (`WHERE status = 'reserved'`) merece un segundo.** El
> trabajo que vence reservas solo consulta filas reservadas, que son un puñado
> entre decenas de miles. Un índice parcial ocupa una fracción y se mantiene casi
> gratis. Y es, de paso, una de las cosas que **no existen** en el DDL de SQLite
> — otra entrada para tu inventario de divergencias.

### 5.2 La venta, en una transacción

```go
// server/internal/rafflenumber/service.go

// SellNumber vende un número.
//
// Comparado con la versión de be03, lo que cambió no es el largo: es que ya
// no hay una ventana entre decidir y escribir. Todo ocurre dentro de una
// transacción, con la fila bloqueada, y con el índice único detrás por si
// algo se me escapó.
func (s *Service) SellNumber(ctx context.Context, raffleID int64, number string, participantID *int64) (RaffleNumber, error) {
	// La identidad sale del contexto (be04). Si es 0, alguien montó esta
	// ruta fuera del middleware de autenticación: se rechaza, no se asume.
	soldBy := httpapi.UserIDFrom(ctx)
	if soldBy == 0 {
		return RaffleNumber{}, ErrUnauthenticated
	}

	var sold RaffleNumber

	// WithTx abre la transacción, ejecuta, y hace Commit o Rollback según
	// el error. Que exista este helper evita el fallo más común de todos:
	// una transacción que nadie cerró porque el return de un error se
	// saltó el Commit.
	err := s.store.WithTx(ctx, func(tx Tx) error {
		// (1) BLOQUEO PESIMISTA. Esta línea es la que arregla el bug.
		//
		// FOR UPDATE toma un bloqueo exclusivo sobre la fila del número.
		// Una segunda transacción que ejecute este mismo SELECT se queda
		// ESPERANDO acá —no lee un dato viejo, no falla: espera— hasta que
		// esta confirme o revierta. Cuando despierte, va a leer el estado
		// ya actualizado y va a decidir bien.
		current, err := tx.FindOneForUpdate(ctx, raffleID, number)
		if err != nil {
			return err
		}

		// (2) Ahora sí, decidir es seguro: nadie más puede tocar esta fila
		// mientras la tengamos bloqueada.
		if current.Status == "sold" {
			return ErrAlreadySold
		}

		// (3) El hecho. Si por lo que sea dos transacciones llegaran acá
		// —un bug futuro, una ruta nueva, un script—, la restricción
		// UNIQUE rechaza la segunda con el código 23505 y el store lo
		// traduce a ErrAlreadySold. Cinturón y tirantes, y los dos hacen
		// falta: el cinturón protege esta ruta, los tirantes protegen las
		// que todavía no existen.
		if err := tx.InsertSale(ctx, raffleID, number, participantID, soldBy); err != nil {
			return err
		}

		// (4) La proyección que el contrato exige. Va en la MISMA
		// transacción: o hay venta y estado coherente, o no hay nada.
		sold, err = tx.MarkSold(ctx, raffleID, number, participantID)
		return err
	})
	if err != nil {
		return RaffleNumber{}, err
	}
	return sold, nil
}
```

```go
// server/internal/rafflenumber/store.go (los métodos nuevos)

// FindOneForUpdate lee la fila y la bloquea hasta el fin de la transacción.
//
// ⚠️ FOR UPDATE solo existe en Postgres. En SQLite esta consulta es un
// error de sintaxis, y esa es exactamente la evidencia que justifica la
// regla del motor de be08. No se emula: se documenta.
func (t *sqlTx) FindOneForUpdate(ctx context.Context, raffleID int64, number string) (RaffleNumber, error) {
	query := t.Rebind(`
		SELECT id, raffle_id, number, status, participant_id, reserved_until, sold_at
		FROM raffle_numbers
		WHERE raffle_id = ? AND number = ?
		FOR UPDATE`)

	var n RaffleNumber
	err := t.GetContext(ctx, &n, query, raffleID, number)
	if errors.Is(err, sql.ErrNoRows) {
		return RaffleNumber{}, ErrNotFound
	}
	if err != nil {
		return RaffleNumber{}, fmt.Errorf("bloqueando el número %s de la rifa %d: %w", number, raffleID, err)
	}
	return n, nil
}

// InsertSale registra el hecho y traduce la violación de unicidad.
func (t *sqlTx) InsertSale(ctx context.Context, raffleID int64, number string, participantID *int64, soldBy int64) error {
	query := t.Rebind(`
		INSERT INTO sales (raffle_id, number, participant_id, sold_by)
		VALUES (?, ?, ?, ?)`)

	_, err := t.ExecContext(ctx, query, raffleID, number, participantID, soldBy)
	if err == nil {
		return nil
	}

	// 🧭 ACÁ ES DONDE EL 409 DEJA DE SER UN if.
	//
	// El código 23505 es "unique_violation" del estándar SQL. Que el
	// conflicto lo declare la BASE y no nuestro código es toda la
	// diferencia: nuestro código puede equivocarse en las condiciones de
	// carrera; la restricción, no.
	//
	// El errors.As con *pq.Error es específico de lib/pq: otro punto de la
	// costura donde el motor se hace visible. Está acá, nombrado, en vez
	// de escondido detrás de un string matching frágil.
	var pqErr *pq.Error
	if errors.As(err, &pqErr) && pqErr.Code == "23505" {
		return ErrAlreadySold
	}
	return fmt.Errorf("registrando la venta del número %s: %w", number, err)
}
```

Y el handler **no cambia ni una línea**. Sigue traduciendo `ErrAlreadySold` a
`409` con el mismo mensaje del mock. Ese es el punto: cambió por completo la
garantía y no cambió nada de lo observable.

### 5.3 Las reservas, que ahora expiran donde deben

La Fase 5 del track base expiraba las reservas con un `setTimeout` del navegador,
y la Fase 6 con un epic. Las dos tienen el mismo agujero, declarado 💸 desde el
mock: **si el usuario cierra la pestaña, el número queda reservado para siempre**.

```go
// ReserveNumber reserva un número por una ventana acotada.
func (s *Service) ReserveNumber(ctx context.Context, raffleID int64, number string) (RaffleNumber, error) {
	var reserved RaffleNumber
	err := s.store.WithTx(ctx, func(tx Tx) error {
		current, err := tx.FindOneForUpdate(ctx, raffleID, number)
		if err != nil {
			return err
		}

		// Una reserva vencida cuenta como disponible aunque el trabajo de
		// limpieza todavía no haya pasado. La verdad es el reloj, no el
		// último barrido: si dependiéramos del barrido, la ventana entre
		// ejecuciones sería un agujero funcional.
		expired := current.ReservedUntil != nil && current.ReservedUntil.Before(time.Now())
		if current.Status != "available" && !(current.Status == "reserved" && expired) {
			return ErrNotAvailable
		}

		until := time.Now().Add(s.reservationTTL)
		reserved, err = tx.MarkReserved(ctx, raffleID, number, until)
		return err
	})
	return reserved, err
}
```

```go
// server/internal/rafflenumber/expiry.go

// StartExpiryWorker lanza el trabajo que devuelve al tablero los números
// cuya reserva venció.
//
// 🧠 Fíjate en la forma: recibe un context y muere cuando se cancela. Eso
// lo conecta con el apagado ordenado de be01 —un worker que no sabe morir
// convierte un Shutdown limpio en un proceso zombi— y es la misma idea del
// takeUntil de la Fase 6, ahora del lado del servidor y por tercera vez.
func StartExpiryWorker(ctx context.Context, store Store, every time.Duration) {
	go func() {
		ticker := time.NewTicker(every)
		defer ticker.Stop()

		for {
			select {
			case <-ctx.Done():
				log.Println("[expiry] worker detenido")
				return
			case <-ticker.C:
				// Un solo UPDATE, sin leer antes. No hay check-then-act
				// porque no hay check: la condición está en el WHERE y la
				// evalúa la base sobre el dato vigente.
				n, err := store.ExpireReservations(ctx)
				if err != nil {
					// Un fallo acá no debe tumbar el worker: la próxima
					// vuelta lo reintenta. Pero sí tiene que verse.
					log.Printf("[expiry] error venciendo reservas: %v", err)
					continue
				}
				if n > 0 {
					log.Printf("[expiry] %d reservas vencidas y liberadas", n)
				}
			}
		}
	}()
}
```

```sql
-- El UPDATE del worker. Sin subconsultas, sin leer antes, idempotente.
UPDATE raffle_numbers
SET status = 'available', reserved_until = NULL
WHERE status = 'reserved' AND reserved_until < now();
```

> ⚠️ **Con más de una réplica, este worker corre en todas a la vez.** No rompe
> nada —el `UPDATE` es idempotente y la segunda ejecución afecta cero filas—
> pero es trabajo desperdiciado y un patrón que en otras operaciones sí haría
> daño. La solución honesta (un bloqueo de aviso con `pg_advisory_lock`) es el
> ejercicio 26, y la decisión de si hace falta es de `be09`.

### 5.4 La comparación medida: pesimista contra optimista

Acá está el trabajo que hace valiosa la fase. Implementa **las dos** estrategias
y mide. No copies conclusiones de un artículo: los números dependen del hardware,
del número de contendientes y de cuánto dura la transacción.

La variante optimista, sin bloqueo y sin espera:

```go
// SellNumberOptimistic vende sin bloquear a nadie.
//
// La idea: no preguntar si se puede, sino intentar hacerlo de forma que
// solo pueda salir bien una vez, y mirar el resultado. La condición vive
// en el WHERE, que la base evalúa de forma atómica sobre el dato vigente.
func (s *Service) SellNumberOptimistic(ctx context.Context, raffleID int64, number string, participantID *int64) (RaffleNumber, error) {
	soldBy := httpapi.UserIDFrom(ctx)
	var sold RaffleNumber

	err := s.store.WithTx(ctx, func(tx Tx) error {
		// El INSERT es la carrera. ON CONFLICT DO NOTHING hace que el
		// perdedor no reciba un error de base sino cero filas afectadas,
		// que es una forma más limpia de perder.
		inserted, err := tx.InsertSaleIfAbsent(ctx, raffleID, number, participantID, soldBy)
		if err != nil {
			return err
		}
		if !inserted {
			// Alguien llegó primero. Nadie esperó a nadie.
			return ErrAlreadySold
		}
		sold, err = tx.MarkSold(ctx, raffleID, number, participantID)
		return err
	})
	return sold, err
}
```

```sql
-- InsertSaleIfAbsent
INSERT INTO sales (raffle_id, number, participant_id, sold_by)
VALUES ($1, $2, $3, $4)
ON CONFLICT (raffle_id, number) DO NOTHING;
-- RowsAffected() == 1 → ganaste. == 0 → perdiste, y no hubo espera.
```

El arnés de medición:

```go
// server/internal/rafflenumber/bench_concurrency_test.go
//
// N goroutines peleando por el MISMO número. Es la prueba que be03 no
// podía escribir y la que be08 va a convertir en parte de la suite.
func runContention(t *testing.T, sell sellFunc, contenders int) result {
	// El WaitGroup arranca a todos a la vez: sin esta barrera, las
	// goroutines se lanzan escalonadas y la carrera no ocurre. Es el error
	// número uno al escribir pruebas de concurrencia — el test pasa, la
	// carrera nunca se produjo, y no probaste nada.
	var start sync.WaitGroup
	start.Add(1)

	var wg sync.WaitGroup
	results := make([]error, contenders)
	latencies := make([]time.Duration, contenders)

	for i := 0; i < contenders; i++ {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			start.Wait() // todos esperan el disparo
			t0 := time.Now()
			_, results[i] = sell(ctx, 1, "0347", nil)
			latencies[i] = time.Since(t0)
		}(i)
	}

	start.Done() // ¡ya!
	wg.Wait()

	return summarize(results, latencies)
}
```

Y lo que hay que anotar en `server/evidence/concurrencia.md`, para 2, 10 y 50
contendientes, con las dos estrategias:

| Qué medir | Por qué importa |
|---|---|
| Ganadores | **Tiene que ser exactamente 1.** Si no, no hay nada más que medir |
| Perdedores con `409` | Deben ser N−1, y con el mensaje del contrato |
| Errores de otro tipo | Cualquiera distinto de `409` es un bug tuyo |
| Latencia p50 y p95 | Acá aparece la diferencia real entre las dos estrategias |

Lo que vas a ver, y que conviene predecir **antes** de correrlo para comprobar
tu intuición: con el pesimista, los perdedores tardan porque **esperan** su turno
en la cola del bloqueo, y la latencia p95 crece con el número de contendientes.
Con el optimista, los perdedores fallan casi instantáneamente y la latencia
apenas se mueve. La contrapartida es que el optimista genera trabajo tirado a la
basura, y con contención muy alta esa basura puede dominar.

> 🧭 **El criterio, que vale más que los números.** El pesimista brilla cuando la
> colisión es **probable** y el trabajo perdido sería caro; el optimista brilla
> cuando la colisión es **rara** y el trabajo perdido es barato. Para una rifa
> —donde solo colisionan los números "bonitos", y muy de vez en cuando— el
> optimista es la respuesta correcta.
>
> Y sin embargo esta fase se queda con el pesimista como camino principal, por
> una razón que no es de rendimiento: **el `FOR UPDATE` se puede observar**. Vas a
> poder mirar el bloqueo en `pg_stat_activity` y entenderlo con los ojos. Cuando
> tengas la intuición construida, el ejercicio 22 te pide que elijas de verdad,
> con tus números.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Envolver en una transacción y darlo por resuelto.** Síntoma: el bug sigue,
menos frecuente. Causa: `READ COMMITTED` no da exclusión mutua (4.2). Fix:
`FOR UPDATE`, `ON CONFLICT` o `SERIALIZABLE`. Es el error más común de esta fase
y el más peligroso, porque **parece** arreglado y la frecuencia baja lo
suficiente como para que las pruebas manuales pasen.

**2. `FOR UPDATE` sobre la consulta equivocada.** Síntoma: no protege. Causa:
bloquear la fila de `raffles` en vez de la del número, o bloquear después de
haber leído el estado. Fix: el bloqueo va sobre **la fila que se va a modificar**
y **antes** de decidir. Regla: si entre el `FOR UPDATE` y el `UPDATE` hay una
decisión basada en una lectura anterior, el bloqueo llegó tarde.

**3. Transacciones que nadie cierra.** Síntoma: el pool se agota, todo se cuelga,
y `pg_stat_activity` se llena de `idle in transaction`. Causa: un `return` de
error que se saltó el `Commit` y el `Rollback`. Fix: el helper `WithTx` con
`defer tx.Rollback()`. **Nunca** manejes transacciones a mano en un handler.

**4. Bloquear más de la cuenta.** Síntoma: la venta funciona perfecto y el
sistema entero se arrastra. Causa: `SELECT … FOR UPDATE` sin `WHERE` selectivo,
o dentro de una transacción que además llama a un servicio externo. Fix:
bloquear la mínima cantidad de filas durante el mínimo tiempo. **Una transacción
no debe contener una petición de red**, nunca.

**5. Deadlock por orden de bloqueo.** Síntoma: `deadlock detected` intermitente.
Causa: dos transacciones bloqueando las mismas filas en orden distinto —vender
`0347` y `1500` en un caso, `1500` y `0347` en el otro—. Fix: **bloquear siempre
en el mismo orden**, típicamente ordenando por clave primaria. Postgres detecta
el deadlock y mata a una de las dos, así que el síntoma es un error y no un
cuelgue; agradécelo.

**6. Probar la concurrencia sin barrera de salida.** Síntoma: el test de carrera
pasa siempre, incluso con el código roto de `be03`. Causa: las goroutines se
lanzan escalonadas y nunca coinciden. Fix: el `WaitGroup` de barrera de 5.4.
**Un test de concurrencia que pasa contra el código vulnerable no es un test.**

### 🩻 Pieza forense de esta fase

**Ver el bloqueo, no imaginarlo.** Esta es la pieza forense más visual del track
y la que más vale la pena hacer despacio.

*Paso 1 — reproduce el bug con el código de `be03`.* Vuelve al `SellNumber` sin
transacción (`git stash` o una rama) y lanza dos ventas simultáneas:

```bash
TOKEN=$(curl -s -X POST localhost:3001/login -H 'Content-Type: application/json' \
        -d '{"email":"organizador@rifas.test","password":"rifas123"}' | jq -r .token)

# El & es lo que importa: las dos salen a la vez.
for i in 1 2; do
  curl -s -o /dev/null -w "cliente $i → %{http_code}\n" \
    -X POST localhost:3001/raffles/1/numbers/0347/sell \
    -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
    -d '{"participantId":null}' &
done; wait
```

Con dos clientes puede que no pase. Sube a veinte con `seq 1 20`. Cuando veas
**dos `200`**, ya tienes el bug reproducido a voluntad — que es la mitad del
trabajo de cualquier diagnóstico. Confírmalo en la base:
`SELECT count(*) FROM sales WHERE number = '0347';`

*Paso 2 — mira el bloqueo en vivo.* Con la versión corregida, abre **dos
terminales de `psql`**. En la primera:

```sql
BEGIN;
SELECT * FROM raffle_numbers WHERE raffle_id = 1 AND number = '0347' FOR UPDATE;
-- No hagas COMMIT. Déjala ahí.
```

En la segunda, la misma consulta. **Se queda colgada.** No falló, no devolvió un
dato viejo: está esperando. Ahora, en una tercera terminal, míralo:

```sql
SELECT pid, state, wait_event_type, wait_event,
       left(query, 60) AS consulta
FROM pg_stat_activity
WHERE datname = 'rifas' AND state <> 'idle';
```

Ahí está: `wait_event_type = 'Lock'`, `wait_event = 'transactionid'`. **Eso es
una transacción bloqueada, en pantalla.** Haz `COMMIT` en la primera terminal y
mira cómo la segunda despierta al instante y lee el dato actualizado.

Pega esa salida en `server/evidence/concurrencia.md`. Es la evidencia de que
entendiste el mecanismo y no solo copiaste un `FOR UPDATE`.

*Paso 3 — quién bloquea a quién.* Con el bloqueo activo, la consulta que de
verdad usarías a las tres de la mañana:

```sql
SELECT blocked.pid AS bloqueado, blocking.pid AS bloqueante,
       left(blocked.query, 40) AS espera, left(blocking.query, 40) AS culpable
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking ON blocking.pid = ANY(pg_blocking_pids(blocked.pid));
```

Guárdala. Es de las tres o cuatro consultas que conviene tener a mano para
siempre.

*Paso 4 — el remate, y lo que condena a `be08`.* Corre la **misma** prueba de
concurrencia contra SQLite:

```bash
TEST_DATABASE_URL="" go test -run TestConcurrentSell ./internal/rafflenumber/
```

No hay `FOR UPDATE`: la consulta es un error de sintaxis. Y aunque la quites, lo
que aparece es `database is locked` (`SQLITE_BUSY`), porque SQLite escribe de a
uno y serializa la base entera, no la fila.

Anota las dos cosas y anótalas bien, porque son distintas y las dos importan: en
Postgres, veinte vendedores compiten por una fila y diecinueve reciben un `409`
correcto en milisegundos. En SQLite, veinte vendedores compiten por **el archivo**
y el resultado depende del `busy_timeout`. **El motor de pruebas no puede
demostrar nada sobre concurrencia**, y por lo tanto una suite verde contra SQLite
no dice nada sobre este código. Esa frase es, literalmente, el contenido central
de `be08`.

*El círculo, con concurrencia.* Toma el `X-Request-Id` de una venta que perdió la
carrera, búscalo en el log del backend, y ahí encuentra el `409` con su
transacción y su tiempo de espera. En `be00` ese id no llegaba a ninguna parte;
ahora te dice cuánto esperó un vendedor por un número que ya no era suyo.

---

## 🧪 7. Ejercicios (34)

**🟢 Fácil (1–8)**

1. Aplica la migración `000005` y verifica que las ventas históricas se migraron a `sales`.
2. Comprueba con `psql` que un segundo `INSERT` sobre `(1, '0347')` falla con `23505`.
3. Vende un número desde la aplicación y verifica que aparece una fila en `sales` con tu `sold_by`.
4. Comprueba con `curl` que la segunda venta del mismo número devuelve `409` con el mensaje exacto del contrato.
5. Reserva un número, espera a que venza el TTL y comprueba en el log que el worker lo liberó.
6. Ejecuta el paso 1 de la pieza forense con veinte clientes contra el código corregido: veinte respuestas, un `200`.
7. Corre `./server/smoke.sh` y confirma que sigue entero en verde.
8. Ejecuta el paso 2 de la pieza forense y pega la salida de `pg_stat_activity`.

**🟡 Intermedio (9–19)**

9. Escribe `TestConcurrentSell` con la barrera de `WaitGroup` y verifica que exactamente uno gana.
10. **Diagnóstico.** Corre ese test contra el `SellNumber` de `be03` y comprueba que falla. Si pasa, tu test está mal: encuentra por qué.
11. **Diagnóstico.** Quita la barrera del test y determina cuántas ejecuciones hacen falta para que la carrera aparezca. Explica qué te dice ese número sobre las pruebas de concurrencia en general.
12. Implementa `SellNumberOptimistic` y comprueba que produce el mismo `409`.
13. Mide las dos estrategias con 2, 10 y 50 contendientes y llena la tabla de 5.4.
14. **Diagnóstico.** Con el pesimista y 50 contendientes, encuentra en `pg_stat_activity` la cola de espera y anota el tiempo máximo que esperó un perdedor.
15. Haz que el worker de expiración corra cada segundo y observa el efecto en el tablero de la aplicación sin recargar la página. Explica por qué se ve (o por qué no).
16. **Diagnóstico.** Detén el worker y determina cuánto tarda un número reservado y abandonado en poder venderse. Explica por qué la comprobación de `expired` en `ReserveNumber` es necesaria además del worker.
17. Verifica que `Ctrl+C` detiene el worker antes de que el proceso muera, y que el log lo dice.
18. **Diagnóstico.** Provoca un `idle in transaction` a propósito (un `BEGIN` sin `COMMIT` desde `psql`) y observa el efecto sobre las ventas de la aplicación. Encuéntralo con `pg_stat_activity`.
19. Escribe la consulta de bloqueos del paso 3 de la pieza forense y déjala en `server/evidence/concurrencia.md` con una explicación de cada columna.

**🟠 Difícil (20–29)**

20. **Diagnóstico.** Ejecuta el paso 4 completo (SQLite) y escribe el informe que `be08` va a citar. Distingue con precisión entre "no existe `FOR UPDATE`" y "la base se bloquea entera".
21. Provoca un deadlock a propósito: dos transacciones que venden `0347` y `1500` en orden opuesto. Captura el mensaje de Postgres y arréglalo ordenando los bloqueos.
22. **Decide.** Con tus mediciones, elige la estrategia definitiva del backend y defiéndela por escrito en `concurrencia.md`. Tiene que citar tus números, no un artículo.
23. **Diagnóstico.** Mete un `time.Sleep(2 * time.Second)` dentro de la transacción, simulando una llamada a un servicio externo. Mide qué le pasa al sistema con 20 vendedores y explica por qué "nunca una petición de red dentro de una transacción" es una regla y no una preferencia.
24. Haz que el `409` incluya en el log (no en la respuesta) quién ganó la carrera y quién la perdió, con sus `X-Request-Id`. Argumenta por qué esa información no puede ir en la respuesta.
25. **Diagnóstico.** Sin volumen, tus mediciones no dicen nada. Genera veinte mil números con el faker de `be-a-10` y repite el ejercicio 13. Compara y explica las diferencias.
26. Implementa el `pg_advisory_lock` que evita que el worker de expiración corra en varias réplicas a la vez, y demuestra que funciona levantando dos procesos.
27. **Diagnóstico.** ¿Qué pasa si el cliente corta la conexión (`Ctrl+C` en `curl`) justo después del `INSERT` y antes del `COMMIT`? Averígualo, mira el estado de la base, y explica el papel de `r.Context()` en el resultado.
28. Diseña la prueba que detectaría una regresión el día que alguien quite el `FOR UPDATE` "porque estaba de más". Que falle de forma inequívoca y rápida.
29. Implementa la variante `SERIALIZABLE` con reintento **del lado del servidor**, mídela contra las otras dos, y explica con precisión por qué el reintento tiene que estar acá y no en el cliente.

**🔴 Muy difícil (30–34)**

30. **El contraste, que es el corazón de la fase.** Escribe un documento comparando cómo aborda la Fase 5 del track base el mismo síntoma y cómo lo aborda esta: qué garantiza cada capa, qué puede y qué no puede prometer el frontend, y qué pasaría si el backend estuviera arreglado y el frontend no —y al revés. Sé concreto sobre lo que el usuario ve en cada combinación.
31. Argumenta si `raffle_numbers.status` debería existir ahora que `sales` es la verdad. Enumera qué se rompería si se calculara al vuelo, mide el costo de esa consulta con volumen, y decide. Recuerda que el contrato de `be00` no se puede cambiar.
32. **Diagnóstico + regresión.** Ticket: *"el día del sorteo de agosto vendimos tres números dos veces, pero solo en los números redondos"*. Explica por qué el sesgo hacia los números redondos es una pista y no ruido, reconstruye la causa, y escribe la prueba de regresión que la habría atrapado.
33. Diseña cómo detectarías **hoy**, con una sola consulta, si alguna vez se vendió un número dos veces en el histórico. Después explica por qué esa consulta no puede escribirse sobre el modelo de `be03` y qué te dice eso sobre modelar hechos.
34. **Post-mortem.** Escribe el post-mortem de la venta duplicada del ejercicio 32 según la guía §13. La sección de prevención tiene que distinguir tres niveles —la restricción de la base, la prueba de concurrencia y el criterio de revisión de código— y explicar por qué hacen falta los tres.

**🔥 Opcionales**

- 🔥 Implementa la venta con `SELECT … FOR UPDATE SKIP LOCKED` para un caso distinto: "véndeme cualquier número disponible". Explica por qué ahí `SKIP LOCKED` es exactamente lo correcto y en la venta de un número concreto sería un desastre.
- 🔥 Mide el impacto del índice único en la escritura: inserta cien mil ventas con y sin la restricción y compara. Después decide si el costo cambia algo de la decisión.
- 🔥 Reproduce la carrera desde el navegador con dos pestañas y el caos en `high` para ensanchar la ventana. Compara la experiencia de usuario con la del track base, donde el mismo síntoma se veía desde Redux DevTools.

---

## 📚 8. Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/13/transaction-iso.html — niveles de aislamiento, con los ejemplos de anomalías. Es la referencia central de la fase.
- https://www.postgresql.org/docs/13/explicit-locking.html — `FOR UPDATE`, `FOR NO KEY UPDATE`, `SKIP LOCKED` y la tabla de conflictos entre modos.
- https://www.postgresql.org/docs/13/sql-insert.html#SQL-ON-CONFLICT — la cláusula que sostiene la variante optimista.
- https://www.postgresql.org/docs/13/monitoring-stats.html — `pg_stat_activity` y `pg_blocking_pids`, la pieza forense.
- https://www.postgresql.org/docs/13/errcodes-appendix.html — la lista de códigos SQLSTATE. `23505` y `40001` son los de hoy.
- https://www.sqlite.org/lockingv3.html y https://www.sqlite.org/rescode.html#busy — por qué SQLite no puede con esto.
- https://pkg.go.dev/database/sql#Tx — el manejo de transacciones en Go, y por qué el `defer Rollback` es idiomático.

**Libros**
- *Designing Data-Intensive Applications* (Martin Kleppmann) — el capítulo 7 es, sin competencia, el mejor texto sobre esto. Su tratamiento del *write skew* y las anomalías de serialización cubre exactamente lo que esta fase hace con las manos.
- *PostgreSQL: Up and Running* — para la parte operativa de diagnosticar bloqueos.

**Video / apoyo**
- Busca "PostgreSQL SELECT FOR UPDATE explained" y "optimistic vs pessimistic locking" en YouTube. Verifica que los ejemplos sean de Postgres: la semántica de bloqueo de MySQL es distinta y mezclarlas confunde más que ayuda.

**Orden de lectura sugerido:** `transaction-iso.html` §13.2 primero, que explica
por qué `READ COMMITTED` permite tu bug → `explicit-locking.html` para entender
qué hace exactamente `FOR UPDATE` → hacer la pieza forense con las tres
terminales → y `be-a-05` para el panorama completo de concurrencia en Postgres,
que es donde vive el detalle que acá solo se toca.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros son de memoria y pueden ser inexactas. La documentación de
> Postgres tiene una versión por URL; fija el 13. Cualquier discrepancia de
> versiones la resuelve `prompts/decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

El número `0347` ya no se puede vender dos veces, y ahora sabes exactamente por
qué: no porque el código lo verifique mejor, sino porque **la base no puede
representar el estado imposible**. Tienes una transacción que bloquea lo mínimo,
un índice único detrás por si acaso, una prueba que falla contra el código
vulnerable, y —lo que más va a durar— la evidencia medida de dos estrategias y el
criterio para elegir entre ellas.

Y tienes la respuesta a la pregunta que abría la fase. El frontend de la Fase 5
no estaba mal escrito: estaba haciendo lo único que se puede hacer desde ahí, que
es mejorar la experiencia mientras el servidor decide. La corrección optimista
con rollback sigue siendo valiosa —hace que la interfaz responda al instante— y
ahora tiene detrás algo que de verdad protege.

`be06` mueve la segunda autoridad al servidor: **el reloj**. Hoy la hora de cierre
la evalúa el navegador contra un campo de texto, y un reloj de cliente es un reloj
que el usuario controla. Vas a ver `TIMESTAMPTZ` de cerca —que es donde casi todo
el mundo tiene un modelo mental equivocado—, y vas a adelantar el reloj del
navegador para comprobar, en una sola pantalla, que el frontend deja vender y el
backend no.

> **La señal de que quedó bien:** *"puedo explicar, sin hablar de mi código, por
> qué es imposible vender dos veces el mismo número — y puedo mostrar la
> transacción esperando su turno."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be05-venta-concurrente -m "be05 cerrada: \
> tabla sales con UNIQUE como última línea de defensa; venta transaccional con FOR UPDATE; \
> 409 producido por la base (23505) y no por un if; prueba de concurrencia que falla contra be03; \
> reservas con expiración del lado del servidor y worker que las vence; \
> comparación medida pesimista vs optimista en server/evidence/concurrencia.md; \
> bloqueo observado en pg_stat_activity; evidencia de SQLite para be08"
> ```
>
> Los commits de la fase llevan su prefijo (`be05: …`) y los de ejercicio su
> número (`be05 ej30: …`). Si un ejercicio merece su propio marcador va en
> `ej/be05/30`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **Registrar en `prompts/decisiones-y-versiones.md` §7** la decisión de esta
  fase: **la venta se modela como hecho (`sales`) y no como estado**, con el
  `UNIQUE (raffle_id, number)` como última línea de defensa, y el bloqueo
  pesimista como camino principal por observabilidad, no por rendimiento. Afecta
  a `be07` (trazabilidad) y a `be08` (suite de concurrencia).
- **Registrar en `prompts/diccionario-codigo-ingles.md` §7bis.1** la entidad
  nueva: `Sale` / `sales`, y el campo `soldBy`. Es un término del dominio que
  antes no existía y que `be07` va a usar.
- **`raffle_numbers.status` pasó de verdad a proyección.** Que `be07` y `be08` lo
  traten como tal: cualquier consulta de negocio sobre ventas va contra `sales`;
  `status` existe porque el contrato de `be00` lo exige.
- **La deuda 💸 del `sold_by` histórico.** Las ventas migradas se atribuyeron al
  usuario 1 porque su autoría real no existe. `be-a-09` debería recogerla: es un
  ejemplo perfecto de deuda que **no se puede pagar**, solo documentar.
- **`be06` hereda dos cosas:** la venta ya es transaccional, así que agregar la
  comprobación de la hora dura dentro de esa transacción es una línea, no un
  rediseño. Y el worker de expiración es el precedente del trabajo que va a
  cerrar rifas por reloj.
- **`be07` hereda `sales` como registro inmutable**, que es exactamente lo que su
  prompt pide para la trazabilidad, y el `WithTx` ya montado.
- **`be08` hereda dos entregables directos:** `TestConcurrentSell` (que ya falla
  contra el código vulnerable, que es la propiedad que lo hace válido) y el
  informe de SQLite del paso 4, que es la evidencia de su regla del motor. Que no
  los reescriba desde cero.
- **`be-a-10` es prerrequisito real del ejercicio 25.** Sin volumen, las
  mediciones de contención no dicen nada. Conviene que la fase lo diga al abrir
  y no solo en el ejercicio.
- **Deudas declaradas:** 💸 el worker corre en todas las réplicas (ejercicio 26 lo
  resuelve, `be09` decide si hace falta); 💸 no hay límite de reservas por
  usuario, así que uno solo puede reservar el tablero entero (`be-a-08`).
- **Reserva para el cuaderno de incidentes:** `be-09` — *"vendimos tres números
  dos veces, y solo los redondos"* (categoría 🔥 transacciones, dificultad 🔴, y
  candidato a ⭐ porque es el hermano exacto del incidente 11 del track base
  resuelto en la otra capa); y `be-10` — *"un número quedó reservado para
  siempre"* (categoría 🔥 transacciones, dificultad 🟡), que es la reserva
  abandonada antes de que existiera el worker.
FIN_DEL_ARCHIVO
wc -l be05-venta-concurrente.md

# --- 2026-09-09T02:58:18 · Register Sale entity and D28
cd prompts && python3 - <<'PY'
import io
p='diccionario-codigo-ingles.md'
s=io.open(p,encoding='utf-8').read()
old="| Liquidación | `Settlement` | `settlements` |"
new="| Venta (el hecho) | `Sale`, `sellNumber` | `sales` |\n| Liquidación | `Settlement` | `settlements` |"
assert s.count(old)==1
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))

p='decisiones-y-versiones.md'
d=io.open(p,encoding='utf-8').read()
anchor="### 7.2 El `go.mod` de referencia"
add = """#### D28 — La venta se modela como hecho, no como estado

**Qué se fijó.** En `be05` se crea la tabla `sales`, donde cada venta es una fila
nueva con `UNIQUE (raffle_id, number)`. Vender pasa de ser un `UPDATE` sobre
`raffle_numbers` a ser un `INSERT` en `sales` más la actualización del estado, las
dos en la misma transacción. El `status` de `raffle_numbers` sigue existiendo
—el contrato de `be00` lo exige— pero pasa de ser la verdad a ser una proyección.

📝 **Por qué.** Un `UNIQUE` no puede proteger un `UPDATE` sobre una fila que ya
existe: no hay segunda fila que rechazar. Sin cambiar el modelo, la defensa más
fuerte de las tres —una restricción de la base— sencillamente no está disponible.
El camino principal es el bloqueo pesimista (`SELECT … FOR UPDATE`) por
**observabilidad**, no por rendimiento: se puede mirar en `pg_stat_activity`. La
variante optimista se implementa y se mide en la misma fase.

📎 **Consecuencias.** `be07` usa `sales` como el registro inmutable de su
trazabilidad; `be08` hereda `TestConcurrentSell` y la evidencia de SQLite.

**Qué la vuelve revisable.** Nada dentro del track. Volver al modelo de estado
implicaría renunciar al índice único, que es el punto.

---

"""
assert d.count(anchor)==1
io.open(p,'w',encoding='utf-8').write(d.replace(anchor, add+anchor))
print('ok')
PY

# --- 2026-09-09T02:58:42 · Grep serverNow in fase 7
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs && grep -n "serverNow\|clockSkew\|Date.now\|closesAt" 07-cierre-polling-resultado.md | head -30

# --- 2026-09-09T03:03:01 · 
cat > be06-hora-dura-y-la-autoridad-del-reloj.md <<'FIN_DEL_ARCHIVO'
# 🕰️ Fase be06 — Hora dura, zonas horarias y la autoridad del reloj

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Fase be06 de be09 · **8 horas**
> Depende de: be05 — la venta ya está protegida · Habilita: be07 — Liquidación transaccional

---

## 🎯 1. Propósito

`be05` movió al servidor la autoridad sobre **quién se queda con un número**.
Esta fase mueve la otra autoridad que el sistema tenía prestada al navegador:
**la del reloj**.

Hoy, la regla más dura del negocio —*no se vende un número después de `closesAt`,
ni un segundo*— la evalúa `isPastClosing(closesAt, new Date())` en el cliente. Y
`new Date()` es la hora del equipo del usuario. Un reloj de cliente es un reloj
que el usuario controla: se adelanta con dos clics en el panel de configuración
del sistema operativo, y con eso se compra un número de una rifa cerrada.

> 🧭 **La regla de negocio la aplica quien tiene el dato, no quien tiene la
> pantalla.** El frontend puede —y debe— decidir si muestra el botón. Solo el
> servidor puede decidir si la venta ocurre.

La Fase 7 del track base lo dijo con todas las letras y dejó la deuda 💸 anotada:
*"si el usuario tiene la hora mal, el cierre se corre con ella… sincronizar
contra el reloj del servidor es lo correcto en producción y queda pendiente"*.
Incluso dejó el ejercicio 27 preguntando qué fase debería pagarlo. Es esta.

Y de paso vas a entender qué hace **realmente** PostgreSQL con `TIMESTAMPTZ`, que
es donde casi todo el mundo —incluido gente con quince años de SQL— tiene un
modelo mental equivocado.

> 🩻 **Lectura previa obligatoria:** la Fase 7 del track base. Y ten a mano la
> Divergencia 2 de `be02`, que ya midió lo que acá se explica.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Está decidida y documentada la política de zona horaria del proceso y de la
      sesión de base, y el `closesAt` que sale por la API es **idéntico** al que
      devolvía el mock.
- [ ] La hora de cierre se evalúa **en el servidor**, dentro de la misma
      transacción que la venta, y una venta tardía devuelve `409` con un mensaje
      que el frontend ya sabe mostrar.
- [ ] Existe una prueba que vende un milisegundo antes y un milisegundo después
      del cierre, con un reloj inyectado y no con `time.Now()`.
- [ ] Hay un trabajo que cierra por reloj las rifas cuya `closesAt` pasó, y la
      transición `open → closed` que `be04` custodiaba por orden ahora también se
      dispara por tiempo.
- [ ] `POST /settlements` sella `settledAt` con el reloj del servidor, y el
      desfase contra el que mandó el cliente queda registrado en el log.
- [ ] Existe `server/evidence/reloj.md` con la medición del desfase
      cliente-servidor y la evidencia de la pieza forense.
- [ ] La deuda 💸 que **no** se paga —el frontend sigue mirando su propio reloj
      para pintar la UI— está declarada con lo que costaría pagarla.
- [ ] `./server/smoke.sh` sigue entero y el frontend sigue sin tocarse.

---

## 🚫 3. Qué queda fuera por ahora

- **El mock de lotería del `3002`.** No se reescribe en Go, ni ahora ni nunca. Es
  un proveedor externo, tiene su propio perfil de fallo, y el `pollingEpic` de la
  Fase 7 le habla con una instancia de `axios` aparte. **Esa frontera se
  conserva**, y conservarla es contenido: un backend propio no absorbe a sus
  proveedores porque le quede cómodo.
- **Que el frontend consuma un `serverNow`.** Requeriría tocar `apiClient.js` y
  sus interceptores, y eso excede la excepción `D27`. Se declara como deuda viva
  con su costo estimado (§5.6).
- **Librerías de fecha.** Ni en el backend ni en el frontend. `time` de la
  biblioteca estándar alcanza y sobra.
- **Horarios recurrentes o programación de cierres.** Una rifa tiene un instante
  de cierre y ya. Si aparecen reglas de calendario —"todos los viernes a las
  22:00 hora local"—, ahí sí hace falta guardar la zona además del instante, y
  eso es una conversación distinta que `be-a-06` deja planteada.

---

## 🧠 4. Conceptos mínimos

Sabes qué es UTC y has sufrido zonas horarias. Vamos directo a las tres cosas que
casi nadie tiene bien.

### 4.1 `TIMESTAMPTZ` no guarda ninguna zona horaria

Empecemos por el malentendido, porque es el que produce las facturas.

`TIMESTAMP WITH TIME ZONE` **no almacena una zona horaria**. El nombre es
desafortunado hasta el punto de ser engañoso. Lo que guarda es un **instante**,
internamente en UTC, con la misma cantidad de bytes que un `TIMESTAMP` normal. La
zona aparece solo en dos momentos:

- **Al entrar:** si el valor trae offset, Postgres lo usa para convertir a UTC. Si
  **no** lo trae, asume la zona de la sesión (`SHOW TimeZone`).
- **Al salir:** convierte el instante a la zona de la sesión y lo muestra así.

De ahí se sigue la propiedad que hace correcto usarlo: **dos valores que
representan el mismo instante son iguales**, sin importar con qué offset se
escribieron. `'2026-08-30 22:00:00-05'` y `'2026-08-31 03:00:00+00'` son el mismo
dato, y `=` los declara iguales.

Y el contraste, que es lo que hay que tener grabado:

📖 **`TIMESTAMPTZ` guarda un instante. `TIMESTAMP` guarda un número que parece
una fecha.** Un `TIMESTAMP` sin zona es "las 22:00" sin decir de dónde: no
identifica ningún momento del universo, y compararlo con otro es comparar dos
opiniones. Ordenar por él da resultados sin sentido en cuanto hay más de una
zona en juego.

> 🧭 **La regla operativa, sin excepciones para este dominio.** Todo instante va
> en `TIMESTAMPTZ`. `TIMESTAMP` sin zona solo sirve para fechas de calendario
> —un cumpleaños, un feriado— que no son instantes y que este sistema no tiene.
>
> ⚠️ Y el detalle que muerde: **la zona de la sesión afecta a la salida**. Dos
> aplicaciones leyendo la misma fila pueden ver `22:00-05:00` y `03:00+00:00`, y
> las dos tienen razón. Si tu código compara *strings* de fecha, acabas de heredar
> un bug que depende de la configuración del servidor. Es, exactamente, la
> Divergencia 2 de `be02` — y también el error común nº 2 de `be03`, que tapamos
> con una línea en el DSN y que ahora toca resolver de verdad.

### 4.2 El instante es la verdad; el offset de la serialización es cosmética

El contrato de `be00` fija que `closesAt` sale como `"2026-08-30T22:00:00-05:00"`,
con offset y no con `Z`. Y `be05` te enseñó que el frontend compara instantes con
`new Date(...).getTime()`, así que **el offset con el que se serialice le da
exactamente igual**: `Z` o `-05:00` producen el mismo `Date`.

Entonces, ¿por qué respetar el formato? Por dos razones que no son la corrección
semántica:

1. **Verificabilidad.** El criterio de `be03` fue que la respuesta sea idéntica a
   la del mock. Una diferencia cosmética consume la misma atención que una real
   cuando estás diagnosticando, y no hay ninguna razón para regalarla.
2. **Legibilidad humana.** Cualquiera que mire un log o una respuesta a las tres
   de la mañana lee `22:00-05:00` sin hacer aritmética.

> 🧭 **Decisión de la fase.** El proceso corre en **UTC** (`TZ=UTC`), todas las
> comparaciones internas se hacen entre instantes, y la sesión de base fija
> `TimeZone=America/Bogota` **solo para que la serialización de salida coincida
> con el contrato**. Se registra así, con esa jerarquía explícita: la zona de
> presentación no participa en ninguna decisión.

### 4.3 Dónde se aplica una regla de tiempo

Hay tres lugares donde se puede comprobar que una rifa cerró, y los tres son
necesarios y distintos:

**En la interfaz**, para no ofrecer lo imposible. Es cortesía, no protección: el
usuario controla ese reloj.

**En el servicio, dentro de la transacción de venta.** Es **la** protección, y
por eso va exactamente ahí: no en el handler, no antes de abrir la transacción,
sino junto a las demás comprobaciones y bajo el mismo bloqueo que `be05` montó.
Si se comprueba antes, hay una ventana entre "comprobé que estaba abierta" y
"vendí" — el mismo *check-then-act* de `be05`, con el reloj en vez del estado.

**En un trabajo periódico**, para que el estado del sistema refleje la realidad
aunque nadie pida nada. Sin él, una rifa cuyo cierre pasó a las 22:00 sigue
diciendo `open` hasta que alguien intente venderle algo.

Fíjate en la simetría con `be05`: la comprobación en la transacción es el
`FOR UPDATE`, y el trabajo periódico es el hermano del *worker* que vence
reservas. Los patrones se repiten porque los problemas se repiten.

### 4.4 El reloj es una dependencia, y se inyecta

Una función que llama a `time.Now()` por dentro **no se puede probar** en sus
casos interesantes, que son justamente los bordes: un milisegundo antes del
cierre, un milisegundo después, el instante exacto.

La solución es tratar el reloj como lo que es —una dependencia externa, igual que
la base— y pasarlo:

```go
// Clock existe para poder mentirle al servicio en las pruebas.
// Una interfaz de un solo método puede parecer exagerada; es lo que
// convierte "esto es difícil de probar" en un test de cuatro líneas.
type Clock interface {
	Now() time.Time
}

type systemClock struct{}
func (systemClock) Now() time.Time { return time.Now().UTC() }

// fixedClock, para pruebas: el tiempo se para donde tú quieras.
type fixedClock struct{ t time.Time }
func (c fixedClock) Now() time.Time { return c.t }
```

Y un detalle de Go que conviene conocer antes de que te muerda: `time.Now()`
devuelve un valor con **reloj monótono** adjunto, pensado para medir duraciones.
Ese reloj no sobrevive a una ida y vuelta a la base ni a una serialización, y hace
que `==` entre dos `time.Time` que representan el mismo instante devuelva
`false`. **Para comparar instantes se usa `Equal`, `Before` y `After`, nunca los
operadores.**

---

## 💻 5. Implementación y código comentado

### 5.1 La política de zona, escrita en un solo lugar

```go
// server/cmd/api/main.go (extracto)

func main() {
	// El proceso vive en UTC. No es cosmética: fija que time.Now() dentro
	// del backend sea siempre el mismo instante expresado igual, sin
	// importar cómo esté configurada la máquina del alumno, el contenedor
	// o el runner de CI. Un backend cuyo comportamiento depende de la
	// configuración regional del host es un backend que falla distinto en
	// cada ambiente.
	os.Setenv("TZ", "UTC")

	cfg, err := config.Load()
	// …
}
```

```go
// server/internal/storage/storage.go (extracto de Open, rama Postgres)

// La sesión de base se fija explícitamente. NO es lo mismo que la zona del
// proceso y no cumple la misma función:
//
//   - el proceso en UTC   → decide y compara instantes
//   - la sesión en Bogotá → SERIALIZA la salida con el offset -05:00 que
//                           el contrato de be00 fija
//
// Que estén separadas y nombradas evita el error clásico: creer que
// cambiar una arregla lo que hace la otra. Y fijarlas explícitamente evita
// el error peor: que el comportamiento dependa de cómo esté configurado el
// Postgres que te tocó.
if dialect == Postgres {
	if _, err := db.ExecContext(ctx, "SET TIME ZONE 'America/Bogota'"); err != nil {
		return nil, fmt.Errorf("fijando la zona de la sesión: %w", err)
	}
}
```

> 📝 Esto **reemplaza** el parche del error común nº 2 de `be03` —aquel
> `?timezone=…` metido en el DSN para que el `closesAt` volviera con el offset
> correcto—. Aquello tapaba un síntoma sin decidir nada; esto es una política con
> dos niveles y una razón para cada uno.

### 5.2 La hora dura, dentro de la transacción de venta

```go
// server/internal/rafflenumber/service.go

var ErrRaffleClosed = errors.New("la rifa ya cerró")

func (s *Service) SellNumber(ctx context.Context, raffleID int64, number string, participantID *int64) (RaffleNumber, error) {
	soldBy := httpapi.UserIDFrom(ctx)
	if soldBy == 0 {
		return RaffleNumber{}, ErrUnauthenticated
	}

	var sold RaffleNumber
	err := s.store.WithTx(ctx, func(tx Tx) error {
		// 🧭 LA HORA SE COMPRUEBA ACÁ ADENTRO, y la posición no es un
		// detalle de estilo.
		//
		// Comprobar antes de abrir la transacción reabre exactamente el
		// check-then-act que be05 acaba de cerrar: entre "vi que estaba
		// abierta" y "vendí" cabe el cierre. La ventana es pequeña y
		// justamente por eso el bug sería intermitente, que es la peor
		// clase de bug.
		raffle, err := tx.FindRaffleForShare(ctx, raffleID)
		if err != nil {
			return err
		}

		now := s.clock.Now()

		// Comparación de INSTANTES con After. Nunca strings, nunca
		// componentes de fecha, nunca ==.
		//
		// El borde: si now == closesAt exactamente, ¿se vende? El track
		// base ya lo decidió en isPastClosing con `>=`, o sea NO se vende.
		// Se replica esa decisión, y se replica a propósito: dos capas que
		// contestan distinto en el borde producen el ticket más difícil de
		// diagnosticar que existe.
		if !now.Before(raffle.ClosesAt) {
			return fmt.Errorf("cerró a las %s y ahora son las %s: %w",
				raffle.ClosesAt.Format(time.RFC3339), now.Format(time.RFC3339), ErrRaffleClosed)
		}

		// A partir de acá, exactamente lo de be05.
		current, err := tx.FindOneForUpdate(ctx, raffleID, number)
		if err != nil {
			return err
		}
		if current.Status == "sold" {
			return ErrAlreadySold
		}
		if err := tx.InsertSale(ctx, raffleID, number, participantID, soldBy); err != nil {
			return err
		}
		sold, err = tx.MarkSold(ctx, raffleID, number, participantID)
		return err
	})
	if err != nil {
		return RaffleNumber{}, err
	}
	return sold, nil
}
```

> 🧠 **`FOR SHARE` y no `FOR UPDATE` sobre la rifa.** Solo necesitamos que nadie
> **cambie** la `closesAt` mientras vendemos, no bloquear a los demás vendedores
> entre sí. `FOR UPDATE` sobre la rifa serializaría **todas** las ventas de esa
> rifa contra una sola fila, y acabaríamos de tirar a la basura la granularidad
> que `be05` consiguió. Es el error común nº 4 de `be05` disfrazado de prudencia.

Y el handler, que traduce el error nuevo:

```go
case errors.Is(err, rafflenumber.ErrRaffleClosed):
	// 409 y no 400: la petición está bien formada, el estado del recurso
	// no permite lo que pide. Es la misma semántica del 409 de venta
	// duplicada, y eso importa porque toReadableError de la Fase 5 ya
	// mapea 409 al type 'conflict' y muestra el message. El frontend
	// heredado maneja este caso nuevo sin saber que existe.
	writeError(w, http.StatusConflict, "La rifa ya cerró: no se pueden vender más números")
```

### 5.3 El trabajo que cierra por reloj

```go
// server/internal/raffle/closing.go

// StartClosingWorker cierra las rifas cuya hora pasó.
//
// Sin esto, una rifa cerrada a las 22:00 sigue diciendo "open" hasta que
// alguien intente venderle algo. El estado del sistema tiene que reflejar
// la realidad aunque nadie pregunte — y en este dominio importa el doble,
// porque el pollingEpic de la Fase 7 arranca a buscar el resultado del
// sorteo cuando la rifa cierra.
func StartClosingWorker(ctx context.Context, store Store, clock Clock, every time.Duration) {
	go func() {
		ticker := time.NewTicker(every)
		defer ticker.Stop()
		for {
			select {
			case <-ctx.Done():
				log.Println("[closing] worker detenido")
				return
			case <-ticker.C:
				closed, err := store.CloseExpiredRaffles(ctx, clock.Now())
				if err != nil {
					log.Printf("[closing] error cerrando rifas: %v", err)
					continue
				}
				for _, id := range closed {
					log.Printf("[closing] rifa %d cerrada por reloj", id)
				}
			}
		}
	}()
}
```

```sql
-- CloseExpiredRaffles. Una sola sentencia, sin leer antes, idempotente.
--
-- El WHERE status = 'open' hace dos trabajos: filtra, y garantiza que la
-- transición sea exactamente la que be04 declaró legal (open → closed).
-- No hay forma de que este UPDATE produzca una transición ilegal, y eso es
-- mejor que confiar en que quien lo escribió se acordara de la tabla.
UPDATE raffles
SET status = 'closed', updated_at = now()
WHERE status = 'open' AND closes_at <= $1
RETURNING id;
```

> ⚠️ **Esto es comportamiento nuevo y observable**, igual que el *enforcement* de
> autenticación de `be04`: el mock nunca cerró una rifa solo. Va al **régimen de
> crecimiento** porque nada del frontend se rompe —la Fase 7 ya trata como
> cerrada cualquier rifa cuya `closesAt` pasó, así que el `status` que llega
> ahora **coincide** con lo que la UI ya calculaba— pero mídelo en el recorrido
> antes de darlo por bueno y anótalo en `CONTRACT.md`.
>
> Y algo que conviene notar: con este *worker*, el `status: 'closed'` y el
> `isPastClosing` del cliente por fin dicen lo mismo. La Fase 7 necesitaba las dos
> condiciones (`selectIsRaffleClosedByStatus(id) || isPastClosing(closesAt)`)
> precisamente porque el backend no cerraba nada. Sigue necesitándolas —el
> *worker* tarda hasta un tick— pero ahora la redundancia protege un desfase de
> segundos en vez de una mentira permanente.

### 5.4 El `settledAt` que ahora sella el servidor

`be03` descubrió que el cuerpo de `POST /settlements` trae un `settledAt`
calculado con `new Date().toISOString()` en el navegador, y lo guardó tal cual con
una deuda 💸 anotada. Se paga acá.

```go
// server/internal/settlement/service.go

func (s *Service) Create(ctx context.Context, in Settlement) (Settlement, error) {
	serverNow := s.clock.Now()

	// El instante en que ocurre un hecho de negocio lo fija quien lo
	// registra, no quien lo pide. Si el cliente manda su propia hora, se
	// MIDE la diferencia y se registra — pero no se usa.
	if in.SettledAt != nil {
		skew := serverNow.Sub(*in.SettledAt)
		if skew < -30*time.Second || skew > 30*time.Second {
			// Un desfase grande no es un error del usuario: es un dato de
			// diagnóstico valiosísimo. Cuando alguien reporte "me cerró la
			// rifa antes de tiempo", esta línea del log es la primera que
			// hay que buscar.
			log.Printf("[req-id %s] desfase de reloj: el cliente dice %s, el servidor %s (%s de diferencia)",
				httpapi.RequestIDFrom(ctx), in.SettledAt.Format(time.RFC3339),
				serverNow.Format(time.RFC3339), skew)
		}
	}
	in.SettledAt = &serverNow

	return s.store.Insert(ctx, in)
}
```

> ⚠️ **Esto cambia un valor observable**, y hay que decirlo sin adornos: el
> `settledAt` que vuelve en la respuesta ya no es el que mandó el cliente. Lo
> aceptamos porque es exactamente la autoridad que la fase reclama, y porque el
> único consumidor de ese campo es el ejercicio 🔥 de series temporales de la
> Fase 9 — que además **mejora**: agrupar por un reloj de servidor es correcto y
> agrupar por relojes de clientes distintos no lo es.
>
> Regístralo en `CONTRACT.md` como cambio deliberado, con su motivo. Es la clase
> de decisión que en seis meses alguien va a cuestionar, y va a merecer una
> respuesta escrita.

### 5.5 Probar el borde, con el reloj en la mano

```go
// server/internal/rafflenumber/closing_test.go

func TestSellNumberRespetaLaHoraDura(t *testing.T) {
	closesAt := mustParse(t, "2026-08-30T22:00:00-05:00")

	casos := []struct {
		nombre string
		ahora  time.Time
		quiere error
	}{
		{"un segundo antes", closesAt.Add(-time.Second), nil},
		{"un milisegundo antes", closesAt.Add(-time.Millisecond), nil},
		// El borde exacto. La decisión (no se vende) se hereda de
		// isPastClosing en la Fase 7, y este test es lo que impide que
		// alguien la cambie sin darse cuenta de que hay otra capa que
		// depende de ella.
		{"el instante exacto", closesAt, rafflenumber.ErrRaffleClosed},
		{"un milisegundo después", closesAt.Add(time.Millisecond), rafflenumber.ErrRaffleClosed},

		// Y el que de verdad importa: la misma hora de pared, otra zona.
		// Si este test pasa, ninguna comparación de tu código está mirando
		// componentes de fecha. Si falla, encontraste el bug de medianoche
		// antes que un usuario.
		{"el mismo instante escrito en UTC",
			mustParse(t, "2026-08-31T03:00:00Z"), rafflenumber.ErrRaffleClosed},
	}

	for _, c := range casos {
		t.Run(c.nombre, func(t *testing.T) {
			svc := newServiceWithClock(t, fixedClock{c.ahora})
			_, err := svc.SellNumber(ctxConUsuario(1), 1, "0347", nil)
			if !errors.Is(err, c.quiere) {
				t.Errorf("con ahora=%s: esperaba %v, obtuve %v", c.ahora, c.quiere, err)
			}
		})
	}
}
```

### 5.6 La deuda que **no** se paga, y su precio

El backend ya no se puede engañar. El frontend, sí.

Con el reloj del navegador adelantado tres horas, la interfaz va a mostrar la
rifa como cerrada antes de tiempo y va a ocultar el botón de vender. El usuario
no puede comprar algo que sí estaba disponible. Nada se corrompe —el servidor
nunca se enteró— pero el usuario pierde una venta legítima y no entiende por qué.

Pagarlo requiere que el servidor mande su hora y que **el cliente la use**: el
`serverNow` que la Fase 7 dejó anotado. La primera mitad es gratis y la vamos a
hacer; la segunda toca `apiClient.js` y sus interceptores, y eso excede la
excepción `D27`.

```go
// La mitad que sí podemos: el servidor publica su hora en cada respuesta.
// El header Date es estándar de HTTP y ya viaja; agregamos uno explícito y
// con precisión de milisegundos porque el Date tiene resolución de segundo.
//
// Hoy NADIE lo consume. Se pone igual, y no es un adorno: es el punto
// exacto donde la deuda se vuelve barata de pagar. El día que alguien
// pueda tocar el frontend, el trabajo del lado del servidor ya está hecho.
w.Header().Set("X-Server-Time", s.clock.Now().Format(time.RFC3339Nano))
```

> 💸 **Deuda declarada: el frontend sigue mirando su propio reloj para pintar la
> interfaz.** Consecuencia: con el reloj del cliente desfasado, la UI ofrece o
> esconde el botón de venta en el momento equivocado, aunque el servidor decida
> siempre bien. Costo de pagarla: un interceptor de respuesta que guarde el
> desfase contra `X-Server-Time` y una función `serverNow()` que lo aplique —
> unas treinta líneas en `apiClient.js` y `closing.js`. **No se hace porque
> tocaría el frontend**, y ampliar la excepción `D27` una segunda vez la
> convertiría en una licencia general. Va al mapa de deuda de `be-a-09` y al
> veredicto honesto de `be09`.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Comparar componentes de fecha.** Síntoma: la rifa cierra una hora antes, o
deja vender pasada la medianoche, y solo para algunos usuarios. Causa: alguien
extrajo el día o la hora en vez de comparar instantes. Fix: `Before` / `After`
sobre `time.Time`. Es el mismo error que el track base documenta en su Fase 7
—`getHours()`— reencarnado en Go, y aparece siempre que alguien intenta "hacerlo
más legible".

**2. `==` entre dos `time.Time`.** Síntoma: un test falla comparando dos fechas
que se ven idénticas en el mensaje de error. Causa: el reloj monótono adjunto, y
la zona. Fix: `Equal`. Regla: **en Go, `time.Time` no se compara con
operadores**, jamás.

**3. Comprobar la hora fuera de la transacción.** Síntoma: cada tanto se cuela una
venta unos milisegundos tarde. Causa: el *check-then-act* de `be05`, con el reloj
en vez del estado. Fix: mover la comprobación adentro, como en 5.2. Corrección
mínima frente a refactorización: mover tres líneas es la corrección; discutir si
el reloj debería ser parte del `Tx` es la refactorización, y no hace falta.

**4. Guardar en `TIMESTAMP` sin zona.** Síntoma: todo funciona en desarrollo y
las horas se corren en producción. Causa: el servidor de desarrollo está en la
misma zona que tú y el de producción está en UTC, así que la ambigüedad no se
nota hasta que se nota. Fix: `TIMESTAMPTZ` siempre. Y desconfía del `down` de una
migración que cambie el tipo: la conversión **reinterpreta** los datos existentes.

**5. Dejar que la zona de la sesión decida algo.** Síntoma: el mismo dato produce
resultados distintos según quién consulte. Causa: comparar contra un literal de
fecha sin offset, que Postgres interpreta en la zona de la sesión. Fix: pasar
siempre instantes por placeholder desde Go, nunca literales de fecha en el SQL.

**6. Confiar en que el *worker* cerró a tiempo.** Síntoma: una venta se cuela
segundos después del cierre. Causa: usar `status = 'open'` como la comprobación de
la hora dura. Fix: las dos condiciones, y la que manda es el reloj. **El *worker*
mantiene el estado al día; no es la regla.**

### 🩻 Pieza forense de esta fase

**Adelanta el reloj del navegador y mira cómo las dos capas se contradicen.**

Es la demostración de una sola pantalla de por qué la autoridad temporal vive del
lado del servidor.

*Preparación.* Toma una rifa abierta y pon su `closesAt` unos minutos en el
futuro:

```sql
UPDATE raffles SET closes_at = now() + interval '5 minutes' WHERE id = 1;
```

*Paso 1 — el reloj adelantado.* Adelanta el reloj del sistema operativo **una
hora** (desactiva la sincronización automática) y recarga la aplicación.

La rifa aparece **cerrada**. `isPastClosing` compara contra `new Date()`, que
ahora miente. El botón de vender no está. Anótalo: **el usuario acaba de perder
una venta legítima y el sistema no tiene forma de saberlo**.

*Paso 2 — el servidor no se enteró.* Sin tocar el reloj, desde otra máquina o
con `curl`:

```bash
curl -s -X POST localhost:3001/raffles/1/numbers/1500/sell \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"participantId":null}' | jq
```

`200`. Se vendió. El servidor sabe qué hora es.

*Paso 3 — ahora al revés, que es el caso peligroso.* **Atrasa** el reloj del
navegador una hora y espera a que la rifa cierre de verdad. La interfaz sigue
mostrando el botón de vender, el usuario hace clic con toda confianza, y el
backend responde `409` con "La rifa ya cerró".

**Esta es la escena que resume la fase.** Antes de `be06`, ese clic habría
funcionado: se habría vendido un número de una rifa cerrada, y el desajuste
habría aparecido semanas después, en la liquidación, cuando los números vendidos
no cuadraran con la recaudación. Ahora el usuario ve un mensaje raro y **los
datos están bien**. Una interfaz confusa es un problema; una base de datos
mentirosa es un incidente.

*Paso 4 — mide el desfase.* Restaura tu reloj y compara:

```bash
curl -s -D - -o /dev/null localhost:3001/health | grep -i 'x-server-time\|^date'
date -u +%Y-%m-%dT%H:%M:%SZ
```

Anota la diferencia en `server/evidence/reloj.md`. En tu máquina van a ser
milisegundos. En la máquina de un usuario con la sincronización apagada pueden ser
minutos u horas, y esa es la magnitud contra la que hay que diseñar.

*Paso 5 — el desfase, en el log.* Liquida una rifa con el reloj adelantado y
busca en el log la línea de `desfase de reloj` de 5.4. Ese es el rastro que
convierte un ticket de *"me cerró antes de tiempo"* en un diagnóstico de dos
minutos: el reloj del cliente estaba mal y quedó registrado.

*Paso 6 — el círculo, otra vez.* Sigue el `X-Request-Id` de la venta rechazada
por hora desde la consola del navegador hasta el log del backend, y comprueba que
ahí está la razón exacta —`cerró a las … y ahora son las …`— con las dos horas.
En `be00` ese id no llegaba a ninguna parte. Ahora te dice, en una línea, por qué
el sistema dijo que no.

*Rompe a propósito.* Cambia `!now.Before(raffle.ClosesAt)` por
`now.After(raffle.ClosesAt)` y corre el test de 5.5. Un solo caso falla: el borde
exacto. Piensa cuánto habría tardado en aparecer sin ese test, y qué habría dicho
el ticket.

---

## 🧪 7. Ejercicios (31)

**🟢 Fácil (1–8)**

1. Comprueba con `SHOW TimeZone` cuál es la zona de tu sesión, y verifica que el arranque del backend la fija.
2. Inserta la misma rifa con `-05:00` y con `Z` (el mismo instante) y comprueba con `=` que Postgres las considera iguales.
3. Verifica que el `closesAt` que devuelve `GET /raffles/1` sale con offset `-05:00` y no con `Z`.
4. Intenta vender en una rifa ya cerrada con `curl` y comprueba que devuelve `409` con su mensaje.
5. Pon una rifa a cerrar en un minuto y observa en el log al *worker* cerrarla.
6. Comprueba que el header `X-Server-Time` viaja en las respuestas.
7. Ejecuta el paso 4 de la pieza forense y anota tu desfase real.
8. Corre `./server/smoke.sh` y confirma que sigue entero.

**🟡 Intermedio (9–19)**

9. Escribe el test de la tabla de 5.5 y comprueba que los cinco casos pasan.
10. **Diagnóstico.** Cambia el borde a `After` y determina qué caso falla y por qué. Explica qué habría pasado en producción.
11. Implementa `Clock` e inyéctalo en los dos servicios. Comprueba que ninguno llama a `time.Now()` por dentro (`grep` incluido en la respuesta).
12. **Diagnóstico.** Compara dos `time.Time` con `==` en un test y observa el fallo. Investiga con `%+v` qué trae adjunto el valor.
13. Cambia la columna `closes_at` a `TIMESTAMP` sin zona en una migración de prueba y determina qué se rompe. Revierte.
14. **Diagnóstico.** Cambia la zona de la sesión a `UTC` y compara la respuesta de `GET /raffles/1` con la del contrato. ¿Se rompe algo en la aplicación? Razona la respuesta antes de probarla.
15. Ejecuta los pasos 1 a 3 de la pieza forense y documenta las dos contradicciones con capturas.
16. Haz que el *worker* de cierre corra cada cinco segundos y verifica que la aplicación refleja el cierre sin recargar. Explica qué mecanismo del frontend lo hace visible.
17. **Diagnóstico.** Detén el *worker*, deja pasar la hora de cierre e intenta vender. Determina qué protege la venta cuando el estado dice `open`.
18. Verifica en el log el desfase que registra `POST /settlements` con el reloj adelantado.
19. **Diagnóstico.** Determina qué pasa si `closes_at` es `NULL` o corrupto. Compara tu comportamiento con el de `isPastClosing`, que devuelve `true` (cerrado) ante una fecha inválida. Si difieren, decide cuál gana y por qué "cerrado" es el default seguro.

**🟠 Difícil (20–27)**

20. **Diagnóstico.** Mueve la comprobación de la hora fuera de la transacción y construye el escenario donde se cuela una venta tardía. Mide cuántos intentos hacen falta para reproducirlo.
21. Cambia `FOR SHARE` por `FOR UPDATE` sobre la rifa y mide qué le pasa a la venta concurrente con 50 contendientes. Explica el resultado con lo que aprendiste en `be05`.
22. **Diagnóstico.** Simula un servidor en otra zona: arranca el proceso con `TZ=Asia/Tokyo` y corre la suite entera. Si algo falla, encontraste una comparación que mira componentes de fecha. Si no falla nada, explica por qué eso es la prueba de que la política de 5.1 funciona.
23. Diseña e implementa el registro del desfase cliente-servidor como métrica agregada, no solo como línea de log. Argumenta qué decisión operativa tomarías con ese número.
24. **Diagnóstico.** Con el horario de verano en la mesa: elige una zona que lo tenga (`America/Santiago`, por ejemplo), pon un `closesAt` justo en el salto, y determina qué pasa. Explica por qué guardar un instante te salva de este problema y guardar "hora local + zona" no.
25. Argumenta por escrito si el *worker* de cierre debería existir o si bastaría con calcular el estado al vuelo. Mide el costo de la consulta con volumen y decide, recordando que el `status` es contrato.
26. **Diagnóstico.** Adelanta el reloj del **servidor** (no el del cliente) y describe qué se rompe. Compara la gravedad con el caso del cliente adelantado y saca la conclusión sobre dónde hay que sincronizar el reloj de verdad.
27. Implementa la mitad de frontend del `serverNow` en una rama descartable —el interceptor y la función— y **mídela**: cuántas líneas, cuántos archivos. Después argumenta si eso cabía o no en la excepción `D27`, con el número en la mano.

**🔴 Muy difícil (28–31)**

28. **Diagnóstico + regresión.** Ticket: *"a los vendedores de la costa se les cierra la rifa una hora antes que a los del interior"*. Enumera las cinco causas candidatas ordenadas por probabilidad, di cómo descartas cada una con una sola consulta o una sola línea de log, y escribe la prueba de regresión de la que sobreviva.
29. Diseña la política de tiempo completa del sistema como documento para quien entre nuevo: qué se guarda, en qué tipo, en qué zona corre cada proceso, quién decide, cómo se serializa y qué está prohibido. Máximo una página, y tiene que poder aplicarse sin leer código.
30. Argumenta si el sistema debería guardar, además del instante, la **zona en que se expresó** el cierre. Construye el caso de negocio que lo haría necesario —una regla recurrente— y decide si este dominio lo tiene. Deja la conclusión en `be-a-06`.
31. **Post-mortem.** Escribe el post-mortem de *"vendimos doscientos números después del cierre y nadie lo notó hasta la liquidación"* según la guía §13, ubicando la causa raíz en la autoridad del reloj. La prevención tiene que explicar por qué una validación en el frontend no habría bastado, sin culpar a quien la escribió.

**🔥 Opcionales**

- 🔥 Implementa un endpoint `GET /time` que devuelva el instante del servidor y mide la ida y vuelta desde el navegador para estimar el desfase corrigiendo la latencia. Es media implementación de NTP y explica por qué sincronizar relojes es más difícil de lo que parece.
- 🔥 Reescribe el *worker* de cierre como un `pg_cron` o un `LISTEN/NOTIFY` y compara: menos código en Go, más dependencia del motor. Decide con el criterio de `be02`.
- 🔥 Instrumenta cuántas ventas se rechazan por hora dura en un día de laboratorio y decide si ese número, en producción, sería una señal de reloj desfasado o de comportamiento normal.

---

## 📚 8. Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/13/datatype-datetime.html — el capítulo entero. §8.5.1.3 (`TIMESTAMP` vs `TIMESTAMPTZ`) es exactamente el malentendido de 4.1.
- https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_timestamp_.28without_time_zone.29 — la misma idea, en cinco líneas y sin diplomacia.
- https://pkg.go.dev/time — y en particular la nota sobre el reloj monótono, que explica el error común nº 2.
- https://pkg.go.dev/time#Time.Equal — por qué existe y por qué `==` no sirve.
- https://www.rfc-editor.org/rfc/rfc3339 — el formato. Corto y vale la pena leerlo entero una vez en la vida.
- https://www.iana.org/time-zones — la base de datos de zonas. Cambia varias veces al año, por decisiones políticas, y eso es contenido: **las zonas horarias no son un problema técnico, son un problema legal con consecuencias técnicas**.

**Libros**
- *Designing Data-Intensive Applications* (Martin Kleppmann) — la sección sobre relojes del capítulo 8 (*Unreliable Clocks*) es el mejor texto sobre por qué no se puede confiar en el reloj de nadie, y su idea de "los relojes son intervalos de confianza, no puntos" cambia cómo se diseña.

**Video / apoyo**
- Busca "The Problem with Time & Timezones" (Computerphile) — diez minutos, y es la mejor introducción que existe al tema. Y "Postgres timestamptz explained", que en `be02` te sugerimos guardar: es el momento de verlo.

**Orden de lectura sugerido:** el "Don't Do This" del wiki de Postgres primero,
que son cinco líneas y fija la regla → el vídeo de Computerphile, para la
intuición → `datatype-datetime.html` §8.5 para el detalle → la nota del reloj
monótono en `pkg.go.dev/time` cuando un test te falle sin motivo aparente →
`be-a-06` para el panorama completo.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros y videos son de memoria y pueden ser inexactas. La
> documentación de Postgres tiene una versión por URL; fija el 13. Cualquier
> discrepancia de versiones la resuelve `prompts/decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

El reloj cambió de dueño. La hora de cierre la evalúa el servidor, dentro de la
misma transacción que protege la venta, comparando instantes y no cadenas. Las
rifas se cierran solas cuando les toca. El `settledAt` lo sella quien registra el
hecho. Y el desfase del cliente, que antes era invisible, ahora deja una línea en
el log que convierte un ticket confuso en un diagnóstico de dos minutos.

Queda una deuda 💸 viva y declarada con su precio: la interfaz sigue pintándose
con el reloj del navegador. El servidor ya publica su hora en `X-Server-Time` —la
mitad barata está hecha— y la otra mitad espera al día en que se pueda tocar el
frontend.

`be07` cierra el dominio con lo que no perdona: **el dinero**. La aritmética en
centavos enteros que enseñó `A10` y aplicó la Fase 8 vive hoy solo en el
navegador, sin que la base garantice nada. Vas a ver el cálculo del premio dentro
de una transacción, un reparto que cuadra al centavo con una política explícita
para el residuo, una liquidación idempotente, y la trazabilidad como registro
inmutable en vez de campo actualizable — que es exactamente la forma que `sales`
estrenó en `be05`. Y la pieza forense va a ser una liquidación interrumpida a la
mitad: con transacción no pasa nada, sin ella la base queda con el dinero
repartido y la rifa sin liquidar.

> **La señal de que quedó bien:** *"puedo adelantar el reloj de mi máquina todo lo
> que quiera y el sistema sigue sabiendo qué hora es."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be06-hora-dura-y-la-autoridad-del-reloj -m "be06 cerrada: \
> política de zona decidida (proceso en UTC, sesión en America/Bogota para serializar); \
> hora dura evaluada en el servidor dentro de la transacción de venta; \
> 409 de rifa cerrada con el mensaje que el frontend ya muestra; \
> Clock inyectable y prueba de los bordes; worker que cierra por reloj; \
> settledAt sellado por el servidor con el desfase registrado; \
> X-Server-Time publicado; deuda del reloj del cliente declarada con su precio"
> ```
>
> Los commits de la fase llevan su prefijo (`be06: …`) y los de ejercicio su
> número (`be06 ej28: …`). Si un ejercicio merece su propio marcador va en
> `ej/be06/28`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **Registrar en `prompts/decisiones-y-versiones.md` §7** la política de tiempo:
  proceso en `TZ=UTC`, sesión de base en `America/Bogota` **solo** para
  serializar, todo instante en `TIMESTAMPTZ`, comparación por instantes, y el
  borde del cierre (`now >= closesAt` → cerrado) heredado de `isPastClosing`.
  Afecta a `be07`, `be08` y `be09`.
- **Dos cambios observables que esta fase introduce** y que `CONTRACT.md` tiene
  que recoger: las rifas ahora se cierran solas (régimen de crecimiento,
  compatible con lo que la Fase 7 ya calculaba) y el `settledAt` que vuelve es el
  del servidor (**cambio deliberado de un valor observable**, con su motivo). El
  segundo es el precedente de "a veces el contrato cambia a propósito"; que
  `be08` verifique los dos.
- **La deuda 💸 del reloj del cliente queda viva y con precio estimado** (~30
  líneas en dos archivos del frontend). Es la segunda deuda que el track decide
  **no** pagar, junto con el *refresh token* de `be04`. Las dos tienen que
  aparecer en `be-a-09` y en el veredicto honesto de `be09`, y las dos tienen la
  misma causa: la regla que ordena el track. Decirlo así, junto, es más honesto
  que declararlas por separado.
- **`X-Server-Time` es régimen de crecimiento sin consumidor.** Que `be-a-06`
  explique cómo se usaría, y que `be09` lo mencione en el veredicto como ejemplo
  de "trabajo hecho para que la deuda sea barata de pagar después".
- **`be07` hereda:** el `Clock` inyectable (lo necesita para la idempotencia y
  para sellar la liquidación), `sales` como registro inmutable, y el `WithTx`.
  Su transacción es la más grande del track.
- **`be08` hereda dos pruebas difíciles de escribir y muy fáciles de romper:** la
  tabla de bordes de 5.5 y el ejercicio 22 (`TZ=Asia/Tokyo` sobre la suite
  entera). Esa segunda debería correr en CI: es la que detecta cualquier
  comparación por componentes de fecha que alguien introduzca en el futuro.
- **Deudas declaradas:** 💸 el *worker* de cierre corre en todas las réplicas
  (mismo caso que el de reservas de `be05`, mismo `pg_advisory_lock`); 💸 no hay
  métrica agregada del desfase, solo líneas de log (ejercicio 23).
- **Reserva para el cuaderno de incidentes:** `be-11` — *"a los vendedores de la
  costa se les cierra la rifa una hora antes"* (categoría 🔥 tiempo, dificultad
  🟠), que es el ejercicio 28; y `be-12` — *"vendimos doscientos números después
  del cierre y nos enteramos en la liquidación"* (categoría 🔥 tiempo, dificultad
  🔴), que es el escenario que esta fase vuelve imposible y que sirve para
  entender qué se estaba arriesgando.
FIN_DEL_ARCHIVO
wc -l be06-hora-dura-y-la-autoridad-del-reloj.md

# --- 2026-09-09T03:03:10 · Grep A10 money rules
grep -n -E "residuo|redondeo|reparto|centav|floor|round|Math\.|remainder|distribute" A10-aritmetica-de-dinero.md | head -40

# --- 2026-09-09T03:03:13 · Read A10 distribution rules and fase8 prize calc
sed -n '/## 4. Repartir sin perder/,/## 5/p' A10-aritmetica-de-dinero.md | head -80; echo "=== fase8 calc ==="; grep -n -A20 "function calculatePrize" 08-liquidacion-calculo-premio.md | head -40

# --- 2026-09-09T03:07:16 · 
cat > be07-liquidacion-dinero-entero-y-transaccional.md <<'FIN_DEL_ARCHIVO'
# 💰 Fase be07 — Liquidación: dinero entero y transaccional

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Fase be07 de be09 · **6 horas**
> Depende de: be06 — el cierre ya lo decide el servidor · Habilita: be08 — Pruebas y la regla del motor

---

## 🎯 1. Propósito

El apéndice `A10` enseñó aritmética en centavos enteros y la Fase 8 la aplicó
bien: nada de floats, redondeo explícito, partes que suman exactamente el todo.
Ese trabajo está hecho y esta fase no lo repite.

Lo que falta es la otra mitad, y es la que de verdad protege la plata: **hoy toda
esa disciplina vive en el navegador**. El servidor recibe unos números por HTTP y
los guarda sin preguntar. Si alguien manda un `margin` que no cuadra, se guarda.
Si el cálculo se hace con la mitad de los datos, se guarda. Si el proceso se cae a
mitad de la liquidación, la base queda con el dinero repartido y la rifa sin
liquidar.

> 🧭 **El dinero no se valida: se recalcula.** Un total que llega por la red es
> una **afirmación del cliente**, exactamente igual que la identidad en `be04` y
> la hora en `be06`. Es la tercera vez que el track dice lo mismo, y no es
> casualidad: es el patrón.

Al terminar, la liquidación va a ser una transacción que o cuadra al centavo o no
ocurre, idempotente ante reintentos, con el reparto registrado como **hechos
inmutables** —la misma forma que `sales` estrenó en `be05`— y con la base
garantizando lo que hasta hoy solo garantizaba una función de JavaScript.

> 🩻 **Lectura previa obligatoria:** la Fase 8 del track base y el apéndice `A10`.
> Las reglas de redondeo, el tratamiento del residuo y los nombres salen de ahí y
> **no se reinventan**. Si algo de `A10` no se puede sostener del lado del
> servidor, esta fase lo dice en voz alta en vez de cambiarlo en silencio.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Migración `000006`: existe `prize_payouts`, el registro inmutable de a quién
      le tocó cuánto, con la restricción que impide pagar dos veces al mismo
      ganador de la misma liquidación.
- [ ] El servidor **recalcula** `totalCollected`, `prizeAmount` y `margin` desde
      `sales` y desde la rifa, y sus números son los que se guardan.
- [ ] La discrepancia entre lo que calculó el cliente y lo que calculó el
      servidor queda registrada en el log con su `X-Request-Id`.
- [ ] La liquidación entera —recalcular, insertar, repartir, marcar la rifa como
      `settled`— ocurre en **una transacción**.
- [ ] La liquidación es **idempotente**: un segundo `POST /settlements` sobre la
      misma rifa devuelve la liquidación existente, no un error ni un duplicado.
- [ ] `prizeShare` está portado a Go con **exactamente** la misma política de
      residuo que `A10`, y hay una prueba que verifica que las partes suman el
      todo para cientos de combinaciones.
- [ ] La transacción verifica antes de confirmar que la suma de los pagos es
      igual al premio, y **aborta** si no cuadra.
- [ ] Está documentado en `server/evidence/dinero.md` qué garantiza cada capa y
      qué de `A10` no se pudo sostener igual del lado del servidor.
- [ ] `./server/smoke.sh` sigue entero y el frontend sigue sin tocarse.

---

## 🚫 3. Qué queda fuera por ahora

- **El dashboard y sus métricas** → la Fase 9 del track base queda fuera del
  contrato obligatorio. Un `GET /stats` es pendiente 🔥 de `be09` y **ninguna
  fase depende de él**; las métricas se siguen calculando en el navegador.
- **Pagos reales.** No hay pasarela, no hay transferencias, no hay conciliación
  bancaria. `prize_payouts` registra a quién le corresponde cuánto; que el dinero
  se mueva es otro sistema y otro curso.
- **Impuestos, retenciones y comisiones.** El dominio tiene recaudo, premio y
  margen. Agregar más conceptos no enseñaría nada nuevo sobre aritmética entera.
- **Reversar una liquidación.** Un registro inmutable no se borra; se compensa
  con otro registro. El diseño de esa compensación es el ejercicio 27.

---

## 🧠 4. Conceptos mínimos

Sabes de transacciones y sabes que los floats no sirven para dinero. Vamos a lo
que esta fase agrega.

### 4.1 `BIGINT` y por qué no `NUMERIC`

`be02` fijó `BIGINT` para todos los montos, y conviene justificarlo porque
Postgres ofrece algo aparentemente mejor: `NUMERIC`, decimal exacto de precisión
arbitraria.

`NUMERIC` es correcto y es más lento —es aritmética por software—, pero la razón
para no usarlo acá es otra y es más fuerte: **`A10` ya decidió que la unidad
mínima del sistema es el centavo entero**, y el frontend trabaja así. Un
`NUMERIC(12,2)` en la base con enteros de centavos en el cliente crea una
conversión en la frontera, y las conversiones en la frontera son donde se pierden
los centavos. Un `BIGINT` de centavos a los dos lados del cable no necesita
convertir nada.

📖 **La regla, en una línea:** el tipo de la columna tiene que ser el mismo
concepto que el tipo del código. Si el código dice "centavos enteros", la columna
dice `BIGINT`.

> ⚠️ `BIGINT` llega hasta unos 92 mil billones de centavos. Para rifas de barrio
> sobra con holgura. Menciono el límite porque un `INTEGER` de 32 bits **no**
> alcanza: se agota en unos 21 millones de pesos, que es un mal día de ventas.
> `be02` puso `BIGINT` y esa elección tiene un porqué.

### 4.2 Recalcular no es desconfiar del frontend: es saber quién tiene los datos

El cliente calcula `totalCollected` con los números que tiene cargados en el
store. Esa lista puede estar desactualizada —otra pestaña vendió tres números
hace un minuto—, incompleta o filtrada. **No es mala fe: es que el cliente no
tiene los datos.**

El servidor sí: la tabla `sales` es la verdad, y `be05` la hizo confiable.
Recalcular desde ahí no es una medida de seguridad, es la única forma de que el
número sea correcto.

Qué hacer entonces con lo que manda el cliente es una decisión, y esta fase la
toma explícita:

> 🧭 **Se recalcula todo, gana el servidor, y la diferencia se registra.** No se
> rechaza la petición con un `400` "sus números no cuadran": eso rompería el
> contrato y además culparía al cliente de algo que no puede hacer bien. Se
> recalcula, se guarda lo correcto y **se deja un rastro de la discrepancia**,
> que es información de diagnóstico valiosísima.

Es exactamente lo que `be06` hizo con `settledAt`. Tercera vez que aparece el
patrón, y ya se puede nombrar: **el cliente propone, el servidor dispone, y la
diferencia se mide.**

### 4.3 La idempotencia, que acá no es un lujo

El mock de la Fase 3 falla a propósito, y la Fase 8 tiene un ejercicio 🔴 sobre
qué hacer cuando el `POST /settlements` falla y hay que reintentar. Con caos
encendido, este escenario es rutina: la petición llega al servidor, la
liquidación se crea, y la respuesta se pierde. El cliente reintenta.

Sin idempotencia hay dos finales posibles y los dos son malos: dos liquidaciones
para la misma rifa, o un error que deja al usuario sin saber si se liquidó o no.

La mitad barata ya está desde `be02`: `settlements.raffle_id` es `UNIQUE`. Falta
la otra mitad, que es **qué se hace cuando esa restricción salta**. Y la respuesta
correcta no es un error:

📖 **Una operación idempotente responde lo mismo la primera vez y la quinta.** Si
la rifa ya está liquidada, se devuelve **la liquidación existente** con el mismo
código de éxito. El cliente no tiene forma de distinguir su reintento de un
primer intento, y esa indistinguibilidad es justamente la propiedad.

Y hay un matiz que hace falta pensar: ¿y si el segundo `POST` trae números
distintos? Con recálculo del lado del servidor, la pregunta se disuelve — los
números no vienen del cuerpo. Es un buen ejemplo de cómo una decisión de diseño
elimina una familia entera de casos borde en vez de obligarte a manejarlos.

### 4.4 Registro inmutable en vez de campo actualizable

Es el mismo cambio de forma que `be05`, aplicado al dinero, y conviene verlo
junto:

| Como estado | Como hecho |
|---|---|
| `raffle_numbers.status = 'sold'` | una fila en `sales` |
| `settlements.paid = true` | una fila en `prize_payouts` |

Un campo que se pisa no puede responder *cuándo*, *quién* ni *cuánto* — y en
dinero, esas tres preguntas se hacen siempre, normalmente meses después y
normalmente por alguien de contabilidad. Un registro que se acumula responde las
tres y además **se puede restringir con índices**, que es lo que convierte una
convención en una imposibilidad.

Regla práctica para el resto de tu carrera: **si un dato puede aparecer en un
reclamo, modélalo como hecho.**

---

## 💻 5. Implementación y código comentado

### 5.1 La migración: el reparto como hechos

```sql
-- server/migrations/postgres/000006_prize_payouts.up.sql

-- A quién le corresponde cuánto, una fila por beneficiario. Inmutable:
-- nada de esta tabla se actualiza jamás. Si hay que corregir, se compensa
-- con otro registro (ejercicio 27).
CREATE TABLE prize_payouts (
    id             BIGSERIAL   PRIMARY KEY,
    settlement_id  BIGINT      NOT NULL REFERENCES settlements(id) ON DELETE RESTRICT,
    -- El número ganador que da derecho al pago. Se guarda el número y no
    -- solo el participante porque el número ES el título: si mañana se
    -- corrige a quién pertenecía, el derecho no cambia de número.
    number         TEXT        NOT NULL,
    participant_id BIGINT      REFERENCES participants(id),
    -- Centavos enteros, coherente con A10 y con el resto del esquema.
    amount         BIGINT      NOT NULL CHECK (amount >= 0),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Un número no puede cobrar dos veces la misma liquidación. Misma
    -- idea que el UNIQUE de sales en be05: no es una validación, es una
    -- imposibilidad.
    CONSTRAINT prize_payouts_unique_number UNIQUE (settlement_id, number)
);

CREATE INDEX prize_payouts_by_settlement ON prize_payouts (settlement_id);

-- ON DELETE RESTRICT y no CASCADE, a propósito: borrar una liquidación que
-- tiene pagos registrados tiene que fallar y hacer ruido. En dinero, el
-- borrado en cascada silencioso es exactamente lo que no quieres.
```

### 5.2 La aritmética, portada de `A10` sin cambiarle una regla

```go
// server/internal/settlement/math.go
package settlement

import "errors"

// Este archivo es el gemelo en Go de src/features/settlements/settlementMath.js
// (Fase 8) y del apéndice A10. Las reglas NO se rediseñan: si algo difiere,
// es un bug de esta traducción, no una mejora.
//
// 🧭 Coherencia obligatoria con A10:
//   - todo en centavos enteros, nunca floats
//   - división entera para la parte, resto explícito
//   - el resto se reparte de a un centavo entre los PRIMEROS, en orden
//     determinista
//   - las partes suman EXACTAMENTE el todo

var ErrInvalidShare = errors.New("prizeShare requiere enteros no negativos y al menos un ganador")

// TotalCollected: recaudo = números vendidos × precio unitario.
// Multiplicar enteros no pierde precisión; lo único que hay que vigilar es
// el desbordamiento, y BIGINT / int64 dan margen de sobra (§4.1).
func TotalCollected(soldCount int64, numberPrice int64) int64 {
	return soldCount * numberPrice
}

// PrizeAmount replica la regla de negocio de calculatePrize (Fase 8):
// solo se paga premio si el número ganador se vendió. Si no se vendió, la
// casa no paga. Es una decisión de dominio explícita, no un caso borde.
func PrizeAmount(basePrize int64, winnerSold bool) int64 {
	if !winnerSold {
		return 0
	}
	return basePrize
}

// Margin puede ser NEGATIVO y no se fuerza a cero: un margen negativo es
// información, no un error. Idéntico a calculateMargin de la Fase 8.
func Margin(totalCollected, prizeAmount int64) int64 {
	return totalCollected - prizeAmount
}

// PrizeShare reparte el premio entre N ganadores sin perder ni inventar un
// centavo. Traducción literal de prizeShare de A10 §4.
//
// La "injusticia" de que los primeros se lleven el centavo extra es
// deliberada y está discutida en A10: repartir al azar sería más justo y
// destruiría el determinismo, y un cálculo de dinero que no da el mismo
// resultado dos veces no se puede auditar ni probar.
//
// El orden lo fija quien llama, y acá lo fija el ORDEN DE VENTA (sales.id
// ascendente): quien compró primero cobra el centavo de más. Es una regla
// explícita del dominio, defendible ante un reclamo, y sale de un dato que
// existe gracias a be05.
func PrizeShare(prizeAmount int64, winners int) ([]int64, error) {
	if prizeAmount < 0 || winners <= 0 {
		return nil, ErrInvalidShare
	}

	base := prizeAmount / int64(winners)      // división entera
	remainder := prizeAmount % int64(winners) // 0 .. winners-1

	shares := make([]int64, winners)
	for i := range shares {
		shares[i] = base
		if int64(i) < remainder {
			shares[i]++ // los primeros `remainder` reciben un centavo extra
		}
	}
	return shares, nil
}

// SumShares existe para poder AFIRMAR la propiedad, no solo confiar en ella.
func SumShares(shares []int64) int64 {
	var total int64
	for _, s := range shares {
		total += s
	}
	return total
}
```

> 🧠 **Un detalle que Go hace mejor que JavaScript, y conviene notarlo.** En JS,
> `prizeShare` tiene que comprobar `Number.isInteger` en tiempo de ejecución
> porque un `number` puede traer decimales. En Go, `int64` **es** entero: el
> compilador impide que llegue otra cosa. Una clase entera de bugs desaparece por
> el sistema de tipos.
>
> Y lo que Go hace **peor**: `int64` desborda en silencio. Si `soldCount *
> numberPrice` se pasa, no hay excepción — el número da la vuelta y queda
> negativo. En JS habrías perdido precisión, que también es malo, pero de forma
> más ruidosa. Ninguno de los dos lenguajes te protege gratis; los dos exigen que
> sepas qué estás haciendo. Está anotado en `dinero.md` como lo que `A10` no
> puede sostener igual de este lado, y el ejercicio 24 lo mide.

### 5.3 La liquidación: una transacción, o nada

```go
// server/internal/settlement/service.go

// Create liquida una rifa.
//
// La transacción más grande del track. Adentro pasan seis cosas y o pasan
// todas o no pasa ninguna:
//   1. se bloquea la rifa y se verifica que se pueda liquidar
//   2. se recalculan los montos desde sales (nunca desde el cuerpo)
//   3. se inserta la liquidación
//   4. se reparte el premio en prize_payouts
//   5. se verifica que las partes sumen el todo
//   6. se marca la rifa como settled
func (s *Service) Create(ctx context.Context, in Settlement) (Settlement, error) {
	settledBy := httpapi.UserIDFrom(ctx)
	if settledBy == 0 {
		return Settlement{}, ErrUnauthenticated
	}

	var result Settlement

	err := s.store.WithTx(ctx, func(tx Tx) error {
		// (1) Bloqueo sobre la rifa. Acá sí FOR UPDATE y no FOR SHARE
		// (a diferencia de be06): vamos a MODIFICAR la rifa, y además
		// queremos que dos liquidaciones simultáneas de la misma rifa se
		// serialicen en vez de pelear.
		raffle, err := tx.FindRaffleForUpdate(ctx, in.RaffleID)
		if err != nil {
			return err
		}

		// (1b) IDEMPOTENCIA. Ya bloqueada la rifa, si existe liquidación
		// se devuelve esa. No es un error: es un reintento, y con el caos
		// de la Fase 3 encendido es el caso normal, no el excepcional.
		existing, err := tx.FindSettlementByRaffle(ctx, in.RaffleID)
		if err == nil {
			log.Printf("[req-id %s] liquidación %d ya existía para la rifa %d: se devuelve la misma",
				httpapi.RequestIDFrom(ctx), existing.ID, in.RaffleID)
			result = existing
			return nil
		}
		if !errors.Is(err, ErrNotFound) {
			return err
		}

		// La transición resolved → settled la custodia el service, igual
		// que en be04. Una rifa abierta no se liquida.
		if raffle.Status != "resolved" {
			return fmt.Errorf("la rifa está en %q y no en \"resolved\": %w",
				raffle.Status, raffle.ErrIllegalTransition)
		}

		// (2) RECÁLCULO. Los números salen de la base, no del cuerpo.
		// Esta es la deuda 💸 que la fase cobra: hasta hoy, la aritmética
		// de A10 vivía solo en el navegador y la base no garantizaba nada.
		sold, err := tx.ListSales(ctx, in.RaffleID)
		if err != nil {
			return err
		}
		winners := filterByNumber(sold, in.WinningNumber)

		totalCollected := TotalCollected(int64(len(sold)), raffle.NumberPrice)
		prizeAmount := PrizeAmount(raffle.BasePrize, len(winners) > 0)
		margin := Margin(totalCollected, prizeAmount)

		// La discrepancia se REGISTRA, no se rechaza (§4.2). Cuando alguien
		// reporte "el total que vi no es el que quedó guardado", esta línea
		// es la respuesta.
		if in.TotalCollected != totalCollected || in.PrizeAmount != prizeAmount || in.Margin != margin {
			log.Printf("[req-id %s] discrepancia en la rifa %d — cliente: total=%d premio=%d margen=%d | servidor: total=%d premio=%d margen=%d",
				httpapi.RequestIDFrom(ctx), in.RaffleID,
				in.TotalCollected, in.PrizeAmount, in.Margin,
				totalCollected, prizeAmount, margin)
		}

		// (3) La liquidación, con los números del servidor y el instante
		// del servidor (be06).
		created, err := tx.InsertSettlement(ctx, Settlement{
			RaffleID:       in.RaffleID,
			WinningNumber:  in.WinningNumber,
			IsWinnerSold:   len(winners) > 0,
			SoldCount:      len(sold),
			TotalCollected: totalCollected,
			PrizeAmount:    prizeAmount,
			Margin:         margin,
			SettledAt:      timePtr(s.clock.Now()),
		})
		if err != nil {
			return err
		}

		// (4) El reparto. Con un solo ganador es trivial; con varios es
		// donde A10 gana su sueldo. El orden lo fija sales.id ascendente:
		// quien compró primero se lleva el centavo extra.
		shares, err := PrizeShare(prizeAmount, len(winners))
		if err != nil && len(winners) > 0 {
			return err
		}
		for i, w := range winners {
			if err := tx.InsertPayout(ctx, created.ID, w.Number, w.ParticipantID, shares[i]); err != nil {
				return err
			}
		}

		// (5) LA ASERCIÓN QUE HACE QUE ESTO SEA DINERO Y NO UN CRUD.
		//
		// Comprobar la propiedad DENTRO de la transacción significa que un
		// reparto que no cuadre no llega a existir: el Rollback lo borra.
		// Sin esta línea, un bug futuro en PrizeShare produciría dinero
		// mal repartido y confirmado, que es un incidente contable, no un
		// bug de software.
		if got := SumShares(shares); len(winners) > 0 && got != prizeAmount {
			return fmt.Errorf("el reparto no cuadra: las partes suman %d y el premio es %d", got, prizeAmount)
		}

		// (6) La rifa queda liquidada. En la MISMA transacción: es lo que
		// hace imposible el escenario de la pieza forense —dinero repartido
		// y rifa sin liquidar—.
		if err := tx.UpdateRaffleStatus(ctx, in.RaffleID, "settled"); err != nil {
			return err
		}

		result = created
		return nil
	})
	if err != nil {
		return Settlement{}, err
	}
	return result, nil
}
```

> 🧠 **Fíjate en el paso 6 y compáralo con el frontend.** El thunk de la Fase 8
> hace `POST /settlements` y **después** despacha `raffleSettled` en el store.
> Dos operaciones separadas: si la segunda no ocurre —o si el usuario recarga
> antes—, el store y la base pueden discrepar. Del lado del servidor las dos son
> una sola cosa. **La misma secuencia, con y sin atomicidad, en las dos orillas:**
> compáralas en `dinero.md`, es uno de los contrastes más claros del track.

### 5.4 La prueba que verifica la propiedad, no los casos

```go
// server/internal/settlement/math_test.go

// La propiedad de A10 —las partes suman exactamente el todo— no se prueba
// con tres ejemplos: se prueba con muchos, porque el bug vive en el resto
// y el resto solo aparece cuando el premio no es divisible.
func TestPrizeShareSumaExactamenteElTodo(t *testing.T) {
	for prize := int64(0); prize <= 1000; prize++ {
		for winners := 1; winners <= 17; winners++ {
			shares, err := PrizeShare(prize, winners)
			if err != nil {
				t.Fatalf("premio=%d ganadores=%d: %v", prize, winners, err)
			}
			if got := SumShares(shares); got != prize {
				t.Errorf("premio=%d ganadores=%d: las partes suman %d", prize, winners, got)
			}
			// La segunda propiedad, que se olvida siempre: nadie puede
			// diferir de otro en más de un centavo. Sin esto, un reparto
			// que le da todo al primero también "sumaría el todo".
			if max(shares)-min(shares) > 1 {
				t.Errorf("premio=%d ganadores=%d: reparto desbalanceado %v", prize, winners, shares)
			}
		}
	}
}

// Y el que amarra las dos orillas: los mismos casos del test de
// settlementMath.js de la Fase 8, con los mismos números y los mismos
// resultados esperados. Si esta tabla y la de JavaScript divergen, hay un
// sistema con dos verdades sobre el dinero.
func TestCoherenciaConElFrontend(t *testing.T) {
	casos := []struct{ prize int64; winners int; quiere []int64 }{
		{100, 3, []int64{34, 33, 33}}, // el ejemplo literal de A10 §4
		{0, 1, []int64{0}},            // el ganador no se vendió
		{500000, 1, []int64{500000}},  // el caso del curso base
		{7, 4, []int64{2, 2, 2, 1}},
	}
	// …
}
```

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Confiar en los montos del cuerpo.** Síntoma: ninguno, hasta que el store
está desactualizado y se guarda un recaudo que no corresponde. Causa: guardar lo
que llegó. Fix: recalcular desde `sales`. **La regla operativa: ningún monto que
se guarde puede haber cruzado la red.**

**2. Repartir con `float64`.** Síntoma: un centavo que aparece o desaparece, muy
de vez en cuando. Causa: `prizeAmount / float64(winners)` y redondeo. Fix: la
división entera de `A10`. Si ves un `float64` en un archivo que habla de dinero,
es un bug aunque todavía no haya fallado.

**3. Verificar el cuadre después del `Commit`.** Síntoma: se detecta que el
reparto no cuadra… y ya está guardado. Causa: la aserción fuera de la
transacción. Fix: adentro, como en el paso 5. La diferencia entre detectar y
**prevenir** es dónde va esa línea.

**4. Tratar el reintento como error.** Síntoma: con caos encendido, el usuario ve
"esta rifa ya fue liquidada" y no sabe si su liquidación se guardó. Causa: el
`23505` traducido a error. Fix: idempotencia — devolver la existente.

**5. Marcar la rifa como liquidada fuera de la transacción.** Síntoma: rifas en
`settled` sin liquidación, o al revés. Causa: dos operaciones que deberían ser
una. Fix: el paso 6 adentro. Es exactamente el bug que la pieza forense provoca.

**6. `INTEGER` en vez de `BIGINT`.** Síntoma: montos negativos absurdos en rifas
grandes. Causa: desbordamiento silencioso a los ~21 millones de pesos. Fix:
`BIGINT` (que `be02` ya puso) y una comprobación de rango en el cálculo. El
ejercicio 24 lo provoca.

### 🩻 Pieza forense de esta fase

**Una liquidación interrumpida a la mitad.**

*Preparación.* Deja una rifa en `resolved` con veinte números vendidos, uno de
ellos el ganador.

*Paso 1 — sin transacción.* Escribe una versión de `Create` que ejecute los seis
pasos **sin** `WithTx`, cada uno con su propia conexión. Mete un `panic` entre el
paso 4 (el reparto) y el paso 6 (marcar la rifa):

```go
// Solo para la pieza forense.
if os.Getenv("BOOM_MID_SETTLEMENT") == "1" {
    panic("se cayó el proceso a mitad de la liquidación")
}
```

Liquida desde la aplicación con `BOOM_MID_SETTLEMENT=1` y después mira la base:

```sql
SELECT s.id, s.raffle_id, s.prize_amount, r.status
FROM settlements s JOIN raffles r ON r.id = s.raffle_id
WHERE s.raffle_id = 1;

SELECT * FROM prize_payouts WHERE settlement_id = (SELECT id FROM settlements WHERE raffle_id = 1);
```

Ahí está el desastre, y vale la pena mirarlo con calma: **existe la liquidación,
existen los pagos, y la rifa sigue en `resolved`.** El dinero está repartido y la
rifa no está liquidada.

Ahora piensa en las consecuencias, que es la parte que importa: alguien va a ver
esa rifa como pendiente y la va a liquidar otra vez. La `UNIQUE` la va a frenar
—gracias, `be02`— pero el operador va a ver un error incomprensible sobre una
rifa que él ve sin liquidar. Nadie va a entender nada, y el rastro de por qué
pasó desapareció con el proceso.

*Paso 2 — con transacción.* Restaura `WithTx` y repite exactamente lo mismo. El
`recover` de `be01` atrapa el pánico, el `defer tx.Rollback()` revierte, y la base
queda **idéntica** a como estaba. Compruébalo con las mismas dos consultas: cero
filas en las dos.

**Ese es el valor entero de una transacción, en dos comandos.** No es una
abstracción académica: es la diferencia entre un martes normal y una tarde
reconstruyendo a mano quién cobró qué.

*Paso 3 — el reintento, que ahora es aburrido.* Con el caos en `high`, liquida
una rifa y deja que la respuesta se pierda. El frontend reintenta. Comprueba en
la base que hay **una** liquidación y **un** juego de pagos, y en el log la línea
de "ya existía: se devuelve la misma". Idempotencia: el reintento dejó de ser un
problema y pasó a ser rutina.

*Paso 4 — rompe el cuadre a propósito.* Cambia `PrizeShare` para que el resto no
se reparta (quita el `shares[i]++`) y liquida una rifa con tres ganadores y un
premio no divisible. La aserción del paso 5 dispara, la transacción revierte, y
**la base queda limpia**. Anota qué habría pasado sin esa aserción: tres pagos que
suman menos que el premio, confirmados, y un descuadre que nadie detecta hasta
que alguien sume a mano.

*Paso 5 — la discrepancia cliente-servidor.* Con la aplicación abierta en dos
pestañas, vende tres números en la primera y liquida en la segunda **sin
recargar**. El cliente calcula con datos viejos. Busca en el log la línea de
`discrepancia`: ahí está, con los dos totales y su `X-Request-Id`.

Esto no es un bug del frontend. Es la demostración de que **el cliente no puede
calcular esto bien**, por más cuidado que ponga, porque no tiene los datos. Pega
esa línea en `dinero.md`: es el argumento entero de §4.2 en tres líneas de log.

---

## 🧪 7. Ejercicios (29)

**🟢 Fácil (1–7)**

1. Aplica la migración `000006` y verifica la restricción de `prize_payouts` insertando dos pagos para el mismo número.
2. Liquida una rifa desde la aplicación y comprueba en la base que hay una fila en `settlements` y una en `prize_payouts`.
3. Comprueba que `POST /settlements` dos veces sobre la misma rifa devuelve la misma liquidación, con el mismo `id`.
4. Verifica que la rifa quedó en `settled` y que ocurrió en la misma transacción.
5. Corre `TestPrizeShareSumaExactamenteElTodo` y comprueba que pasa para las 17.000 combinaciones.
6. Liquida una rifa cuyo número ganador **no** se vendió y comprueba que el premio es `0` y no hay pagos.
7. Corre `./server/smoke.sh` y confirma que sigue entero.

**🟡 Intermedio (8–16)**

8. Porta `PrizeShare` y verifica con la tabla de `TestCoherenciaConElFrontend` que da exactamente lo mismo que `settlementMath.js`.
9. **Diagnóstico.** Ejecuta el paso 5 de la pieza forense (dos pestañas) y encuentra la línea de discrepancia en el log.
10. Implementa el recálculo desde `sales` y comprueba que los montos guardados no dependen del cuerpo, mandando un `POST` con montos inventados.
11. **Diagnóstico.** Manda un `POST /settlements` con `margin: 999999` y determina qué se guarda y qué queda en el log.
12. Escribe la prueba que verifica que liquidar dos veces no crea dos filas, con las dos peticiones concurrentes.
13. **Diagnóstico.** Quita el bloqueo `FOR UPDATE` sobre la rifa y lanza dos liquidaciones simultáneas. Describe qué pasa y quién te salva.
14. Agrega a `prize_payouts` el `sold_by` del vendedor del número ganador, aprovechando `sales`. Justifica si eso es información útil o ruido.
15. **Diagnóstico.** Liquida una rifa en estado `open` y comprueba que la transición ilegal la frena el service de `be04`, no el handler.
16. Verifica que el `settledAt` guardado es el del servidor y no el del cliente, y encuentra en el log el desfase (`be06`).

**🟠 Difícil (17–25)**

17. **Diagnóstico.** Ejecuta los pasos 1 y 2 de la pieza forense y escribe el informe de la liquidación interrumpida, con las consultas y sus salidas en los dos casos.
18. **Diagnóstico.** Ejecuta el paso 4 (romper el cuadre) y documenta qué habría pasado sin la aserción. Estima cuánto tardaría alguien en detectarlo en producción.
19. Implementa el caso de varios ganadores de punta a punta: vende el mismo número a… espera, no puedes. Explica por qué `be05` hace imposible que dos personas tengan el número ganador, y rediseña el escenario multi-ganador de forma que tenga sentido en este dominio (pista: mira qué pasaría si la lotería devolviera dos números ganadores).
20. Argumenta si `PrizeShare` debería ordenar por antigüedad de compra, por id de participante, o por número. Decide, impleméntalo, y defiende la elección como se la defenderías a alguien que se quedó sin el centavo extra.
21. **Diagnóstico.** Compara la secuencia del thunk de la Fase 8 (`POST` y después `dispatch`) con la transacción del servidor. Construye el escenario donde el store y la base discrepan, y determina si hoy es posible y por qué.
22. Escribe la consulta que audita todas las liquidaciones existentes y reporta cualquiera cuyos pagos no sumen su `prizeAmount`. Debería devolver cero filas; déjala en `dinero.md` como consulta de auditoría.
23. **Diagnóstico.** Determina qué pasa si alguien borra una fila de `sales` después de liquidar. ¿Se detecta? ¿Con qué consulta? Argumenta si `sales` debería ser inmutable a nivel de permisos y no solo por convención.
24. **Diagnóstico.** Provoca el desbordamiento de `int64` con un `numberPrice` absurdo y un `soldCount` enorme. Determina qué se guarda, y agrega la comprobación de rango que lo impide. Compara el comportamiento con lo que haría el `number` de JavaScript.
25. Escribe `dinero.md`: qué garantiza cada capa (frontend, servicio, base), qué de `A10` no se pudo sostener igual de este lado, y qué invariantes se pueden verificar con una consulta.

**🔴 Muy difícil (26–29)**

26. Diseña la prueba basada en propiedades que verifique, para entradas generadas al azar, que recaudo, premio y margen siempre cumplen `margin == totalCollected - prizeAmount` y que los pagos suman el premio. Explica por qué esta clase de prueba es especialmente apropiada para dinero.
27. Diseña el mecanismo de **corrección** de una liquidación errónea sin borrar nada: qué tabla, qué campos, cómo se calcula el saldo vigente, y cómo se presenta. Argumenta por qué la contabilidad lleva cuatrocientos años haciéndolo con asientos de compensación y no con un `UPDATE`.
28. **Diagnóstico + regresión.** Ticket: *"la liquidación de la rifa de agosto dice que recaudamos 340.000 y el listado de ventas suma 355.000"*. Enumera las causas candidatas ordenadas por probabilidad —incluida la posibilidad de que ninguna sea un bug—, di cómo descartas cada una con una consulta, y escribe la regresión.
29. **Post-mortem.** Escribe el post-mortem de *"repartimos el premio dos veces"* según la guía §13, ubicando la causa raíz en la falta de idempotencia ante un reintento del cliente con el mock caótico. La prevención tiene que distinguir la restricción de la base, el comportamiento idempotente y la consulta de auditoría, y explicar qué cubre cada uno.

**🔥 Opcionales**

- 🔥 Implementa el `GET /stats` que la Fase 9 calcula hoy en el navegador —margen total, top de números, liquidaciones por día— y mide cuánto más rápido es agregarlo en SQL con veinte mil ventas. Después responde la pregunta incómoda: ¿mereció la pena, sabiendo que ningún cliente lo consume?
- 🔥 Agrega un `CHECK` a nivel de base que impida que `margin` difiera de `total_collected - prize_amount`. Discute si una invariante debe vivir en la base, en el código, o en las dos.
- 🔥 Reescribe los montos como `NUMERIC(14,2)` en una rama y mide qué cambia: rendimiento, código de conversión y riesgo de perder centavos en la frontera. Decide con datos.

---

## 📚 8. Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/13/datatype-numeric.html — rangos de `BIGINT` y semántica de `NUMERIC`, para el debate de §4.1.
- https://www.postgresql.org/docs/13/tutorial-transactions.html y https://www.postgresql.org/docs/13/sql-begin.html — atomicidad, que es lo que la pieza forense demuestra.
- https://www.postgresql.org/docs/13/ddl-constraints.html — `CHECK`, `UNIQUE` y `ON DELETE RESTRICT`.
- https://pkg.go.dev/math/bits#Add64 — para la comprobación de desbordamiento del ejercicio 24.
- https://martinfowler.com/eaaDev/AccountingNarrative.html y https://martinfowler.com/eaaDev/AccountingEntry.html — los patrones contables detrás de §4.4 y del ejercicio 27. Son de hace veinte años y no han envejecido un día.

**Libros**
- *Patterns of Enterprise Application Architecture* (Martin Fowler) — el patrón *Money* y por qué el dinero merece un tipo propio.
- *Designing Data-Intensive Applications* (Kleppmann) — el capítulo 7, otra vez: la definición precisa de atomicidad es la que hace entender la pieza forense.

**Video / apoyo**
- Busca "floating point money bugs" y "event sourcing vs CRUD" en YouTube. Lo segundo es el pariente grande de §4.4: no lo necesitas acá, pero conocerlo aclara por qué modelar hechos escala mejor que modelar estados.

**Orden de lectura sugerido:** relee `A10` §2 y §4 primero, que es de donde sale
todo lo de esta fase → el artículo de *Accounting Entry* de Fowler, que explica
§4.4 mejor que yo → la documentación de transacciones de Postgres si la pieza
forense te deja con dudas → y el capítulo 7 de Kleppmann cuando quieras la teoría
completa.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros son de memoria y pueden ser inexactas. La documentación de
> Postgres tiene una versión por URL; fija el 13. Cualquier discrepancia de
> versiones la resuelve `prompts/decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

El dominio está completo del lado del servidor. La aritmética de `A10` vive
ahora a los dos lados del cable con las mismas reglas y las mismas pruebas; los
montos se recalculan desde los hechos en vez de creerle a nadie; el reparto
cuadra al centavo y la transacción lo verifica antes de confirmar; liquidar dos
veces es imposible y reintentar es aburrido; y quién cobró cuánto quedó escrito
en un registro que no se pisa.

Tres deudas del track base pagadas en tres fases seguidas, y siempre la misma
forma: **el cliente propone, el servidor dispone, y la diferencia se mide.**
Identidad en `be04`, reloj en `be06`, dinero en `be07`.

`be08` cambia de tema. Ya no se agrega comportamiento: se demuestra que el que
hay es cierto. Pruebas de handlers con `httptest`, la suite de contrato que
verifica el checklist de `be00` endpoint por endpoint, integración contra Postgres
en contenedor, concurrencia con goroutines, `go test -race` — y el contenido
central, que es una regla y su demostración: **una prueba que pasa en SQLite y
falla en Postgres, y otra que hace exactamente lo contrario**. Toda la evidencia
que vienes acumulando desde `be02` converge ahí.

> **La señal de que quedó bien:** *"puedo matar el proceso en cualquier
> milisegundo de una liquidación y la base nunca queda a medias."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be07-liquidacion-dinero-entero-y-transaccional -m "be07 cerrada: \
> prize_payouts como registro inmutable con su restricción; montos recalculados desde sales; \
> discrepancia cliente-servidor registrada; liquidación en una sola transacción; \
> idempotencia ante reintentos; PrizeShare coherente con A10 y probado por propiedad; \
> aserción de cuadre dentro de la transacción; server/evidence/dinero.md escrito"
> ```
>
> Los commits de la fase llevan su prefijo (`be07: …`) y los de ejercicio su
> número (`be07 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/be07/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **Registrar en `prompts/diccionario-codigo-ingles.md` §7bis.1** la entidad
  `PrizePayout` / `prize_payouts`, y en §7bis.2 los nombres de la aritmética
  (`TotalCollected`, `PrizeAmount`, `Margin`, `PrizeShare`), que son la
  traducción literal de los de `settlementMath.js` y **tienen que seguir
  siéndolo**.
- **Coherencia con `A10`, verificada y con una excepción.** Las reglas se
  portaron sin cambios; lo único que no se sostiene igual es el desbordamiento:
  `int64` desborda en silencio donde el `number` de JS pierde precisión de forma
  más ruidosa. Está anotado en `dinero.md` y medido en el ejercicio 24. Si `A10`
  se revisa alguna vez, esto debería aparecer allá también.
- **Tres cambios observables acumulados** que `CONTRACT.md` recoge y `be08` debe
  verificar: el `settledAt` del servidor (`be06`), los montos recalculados
  (`be07`) y la idempotencia del `POST /settlements` (`be07`). Los tres son
  deliberados y los tres tienen su motivo escrito.
- **El `GET /stats` sigue siendo pendiente 🔥 de `be09`** y ninguna fase depende
  de él. El ejercicio 🔥 de esta fase lo adelanta, con la pregunta honesta de si
  merece la pena construir algo que ningún cliente consume.
- **`be08` hereda de esta fase:** la prueba por propiedades de `PrizeShare` (que
  es la única del track que prueba una propiedad y no casos), la consulta de
  auditoría del ejercicio 22 y la tabla de coherencia con el frontend. Esa última
  es candidata a correr en CI: es la que detecta que alguien cambie una regla en
  una sola orilla.
- **`be09` hereda para el veredicto:** que las tres fases del dominio —`be05`,
  `be06`, `be07`— no agregaron **ni una dependencia** al `go.mod`. Concurrencia,
  tiempo y dinero se resolvieron con la biblioteca estándar y el motor. Es un
  dato para el veredicto honesto y dice mucho sobre dónde vive la complejidad
  real.
- **Deudas declaradas:** 💸 `sales` es inmutable por convención y no por permisos
  (ejercicio 23); 💸 no hay mecanismo de corrección de una liquidación errónea
  (ejercicio 27 lo diseña, no lo implementa); 💸 no hay comprobación de
  desbordamiento en el cálculo del recaudo hasta que el alumno la agrega.
- **Reserva para el cuaderno de incidentes:** `be-13` — *"la liquidación dice
  340.000 y las ventas suman 355.000"* (categoría 🔥 dinero, dificultad 🟠), el
  ejercicio 28; y `be-14` — *"repartimos el premio dos veces"* (categoría 🔥
  transacciones, dificultad 🔴), el ejercicio 29, que es el hermano del incidente
  18 del track base —*la liquidación da un centavo de diferencia*— resuelto en la
  otra capa y con consecuencias mucho peores.
FIN_DEL_ARCHIVO
wc -l be07-liquidacion-dinero-entero-y-transaccional.md; ls be0*.md

# --- 2026-09-09T03:07:24 · Register PrizePayout and money function names
cd prompts && python3 - <<'PY'
import io
p='diccionario-codigo-ingles.md'
s=io.open(p,encoding='utf-8').read()
old="| Liquidación | `Settlement` | `settlements` |"
new="| Liquidación | `Settlement` | `settlements` |\n| Pago del premio | `PrizePayout` | `prize_payouts` |"
assert s.count(old)==1
s=s.replace(old,new)

old2="| Error de dominio | `Err<Caso>` | `ErrNumberAlreadySold`, `ErrRaffleClosed` |"
new2=old2+"\n| Función de aritmética de dinero | el mismo nombre que en `settlementMath.js` | `TotalCollected`, `PrizeAmount`, `Margin`, `PrizeShare` |"
assert s.count(old2)==1
io.open(p,'w',encoding='utf-8').write(s.replace(old2,new2))
print('ok')
PY

# --- 2026-09-09T03:19:14 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs && cat > be08-pruebas-y-la-regla-del-motor.md <<'FIN_DEL_ARCHIVO'
# 🧪 Fase be08 — Pruebas por niveles y la regla del motor

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Fase be08 de be09 · **10 horas**
> Depende de: be07 — el dominio está completo del lado del servidor · Habilita: be09 — Empaquetado y pipeline

---

## 🎯 1. Propósito

Hasta acá el track agregó comportamiento. Esta fase no agrega ninguno: **demuestra
que el que hay es cierto**, y lo hace con una suite organizada por niveles, cada
uno con un trabajo distinto y un costo distinto.

Pero el contenido central de la fase no es la suite. Es una regla, y su
demostración:

> 🧭 **SQLite vale para pruebas que no tocan concurrencia, bloqueos, zonas
> horarias ni SQL específico del motor. En cuanto una prueba toca cualquiera de
> las cuatro, corre contra PostgreSQL o no vale.**

Esa regla no se enuncia como opinión: se demuestra con **una prueba que pasa en
SQLite y falla en Postgres, y otra que hace exactamente lo contrario**. Las dos
existen, las dos van al repositorio, y las dos son correctas.

Y el argumento que la fase tiene que dejar clavado, porque es el que cambia cómo
trabajas:

> 🧠 **Una suite verde contra el motor equivocado es PEOR que no tener suite.**
> No tener suite te deja desconfiado y prudente. Una suite verde te da **permiso
> para desplegar**, y ese permiso es exactamente lo que no tenías derecho a
> recibir.

La deuda 💸 que cobra: la suite de la Fase 10 del track base —Jest, RTL, marbles—
no podía probar absolutamente nada del servidor, porque el servidor era un
`json-server` con un archivo. La mitad invisible del sistema queda cubierta acá.

---

## ✅ 2. Qué queda listo al terminar

- [ ] La suite está organizada en cinco niveles y cada uno se puede correr solo.
- [ ] Pruebas unitarias puras —aritmética, transiciones, bordes de tiempo— que
      corren **sin base de datos** en menos de un segundo.
- [ ] Pruebas de handler con `httptest`, con el servicio sustituido, que verifican
      la traducción HTTP: códigos, cuerpos y las **dos formas de `404`** (`C-04`).
- [ ] La **suite de contrato** verifica el checklist de `be00` endpoint por
      endpoint, incluidos los tres cambios observables que el track introdujo a
      propósito.
- [ ] Pruebas de integración contra PostgreSQL 13 en contenedor, con datos
      propios y aislamiento entre casos.
- [ ] `TestConcurrentSell` corre con N goroutines y **falla contra el código de
      `be03`**.
- [ ] `go test -race ./...` pasa limpio, y hay al menos un caso que lo habría
      hecho fallar antes de `be05`.
- [ ] `mustPostgres` está implementado y **falla** —no salta— cuando una prueba
      que toca las cuatro áreas corre contra el motor equivocado.
- [ ] Existen las dos pruebas contradictorias, documentadas en
      `server/evidence/regla-del-motor.md`.
- [ ] `./server/smoke.sh` sigue entero.

---

## 🚫 3. Qué queda fuera por ahora

- **Las pruebas de extremo a extremo del frontend.** Ya viven en la Fase 10 del
  track base, con Cypress. No se duplican acá y no se mezclan: son otra pirámide,
  con otro dueño.
- **El pipeline de integración continua** → `be09`. Acá se construye la suite que
  **puede** correr en CI; hacerla correr allá es la otra fase.
- **Pruebas de carga y de rendimiento.** Medimos concurrencia para verificar
  **corrección**, no para saber cuántas ventas por segundo aguanta el sistema.
  Son disciplinas distintas y confundirlas produce suites lentas que no prueban
  nada.
- **Mutación, fuzzing y verificación formal.** Se mencionan como comparación 🔥.
  El *fuzzing* nativo de Go llegó en 1.18 y sí está disponible, pero queda como
  ejercicio opcional.

---

## 🧠 4. Conceptos mínimos

### 4.1 Los cinco niveles, y qué prueba cada uno

Un nivel se justifica por lo que puede fallar en él **y no en los otros**. Si dos
niveles atrapan siempre los mismos bugs, sobra uno.

| Nivel | Qué prueba | Necesita base | Cuánto tarda |
|---|---|---|---|
| Unitario | Aritmética, transiciones, bordes de tiempo | No | ms |
| Handler | La traducción a HTTP: código, cuerpo, forma | No | ms |
| Integración | Que el SQL haga lo que dices que hace | Postgres | s |
| Contrato | Que el frontend siga funcionando | Postgres | s |
| Concurrencia | Que las garantías se sostengan bajo carrera | Postgres | s |

Los dos primeros son gratis, así que vive ahí todo lo que pueda vivir. Y hay una
consecuencia de diseño que conviene decir al revés: **si algo importante solo se
puede probar en el nivel de integración, muchas veces el problema es el diseño y
no la prueba**. `PrizeShare` es unitaria porque `be07` la separó del store; la
hora dura es unitaria porque `be06` inyectó el reloj. Las decisiones de diseño de
las fases anteriores son las que hacen barata esta.

### 4.2 La regla del motor, y por qué es una regla y no un consejo

Correr las pruebas contra SQLite en memoria es tentador y en parte es correcto:
arranca en milisegundos, no necesita contenedor, y cada caso puede tener su base
limpia. Para la mitad de la suite es la decisión adecuada.

El problema es que SQLite y PostgreSQL **no son el mismo sistema con distinta
velocidad**: son sistemas con garantías distintas. `be02` lo midió con siete
divergencias y `be05` lo remató mostrando que la concurrencia ni siquiera se
puede simular. Cuando una prueba cruza una de esas fronteras, no está probando tu
código: está probando cómo se comporta tu código **en un motor que no vas a
desplegar**.

Y acá hay una asimetría que hace la situación peor de lo que parece. Un falso
negativo —una prueba que falla en SQLite y pasaría en Postgres— es molesto: lo
investigas y lo entiendes. Un **falso positivo** —verde en SQLite, roto en
Postgres— no produce ninguna señal. Nadie investiga una prueba que pasa. El bug
llega a producción con la bendición de la suite.

> 🧭 **Corolario operativo: `t.Skip` es la forma en que una suite miente.** Si una
> prueba de concurrencia se salta cuando no hay Postgres, la salida dice `ok` y
> nadie mira los `SKIP`. Por eso el helper de esta fase **falla** en vez de
> saltar: una prueba que no puede correr donde importa es un error de
> configuración, no un caso omitido.

### 4.3 Dobles: qué se sustituye y qué no

En Go los dobles de prueba casi no necesitan librería: las interfaces implícitas
de `be01` hacen que cualquier struct con los métodos correctos sirva. No hace
falta un framework de *mocks* y este track no usa ninguno.

La decisión importante no es cómo hacer el doble, es **qué sustituir**:

- **El reloj: siempre.** `be06` lo hizo inyectable justamente para esto.
- **El store, en las pruebas de handler: sí.** Ahí se prueba la traducción HTTP,
  y meter una base solo la hace lenta y frágil.
- **El store, en las pruebas de service: casi nunca.** Un service cuya lógica
  está en el SQL —y en este backend, gran parte lo está— probado contra un store
  falso prueba el doble, no el sistema. Es el error más común de este nivel: una
  suite de services con *mocks* que verifica que el código llama a los métodos
  que el propio autor decidió llamar.
- **La base: nunca.** No hay forma honesta de simular un `FOR UPDATE`.

### 4.4 Aislamiento entre casos

Dos pruebas que comparten datos producen fallos que dependen del orden, y un
fallo que depende del orden se investiga durante horas. Hay tres estrategias y
conviene elegir a conciencia:

**Base nueva por caso.** El aislamiento perfecto y el costo más alto. Con SQLite
en memoria es gratis; con Postgres, no.

**Transacción revertida por caso.** Cada prueba abre una transacción y hace
`Rollback` al final. Rápido y limpio — pero **inservible para esta suite**, porque
el código bajo prueba abre sus propias transacciones y las anidaría. Justo lo que
`be05` y `be07` hacen.

**Truncado entre casos.** Un `TRUNCATE … RESTART IDENTITY CASCADE` antes de cada
prueba. Es la que usamos: sencilla, compatible con el código real, y rápida en
tablas pequeñas.

> ⚠️ Y una regla que ahorra un día entero de tu vida: **la base de pruebas nunca
> es la de desarrollo**. Un `TRUNCATE` apuntando a la base equivocada borra las
> rifas con las que llevas seis fases trabajando. El *helper* de 5.2 lo comprueba
> por nombre y se niega a correr si no cuadra.

---

## 💻 5. Implementación y código comentado

```bash
cd server && go get github.com/stretchr/testify@v1.8.1
```

> 📝 `testify` entra solo por `require` y `assert`, que ahorran ruido en las
> aserciones. **No** usamos su paquete de *mocks*: con interfaces implícitas no
> hace falta (§4.3), y un *mock* generado esconde justo lo que queremos ver.

### 5.1 Nivel 1 y 2: lo que no necesita base

```go
// server/internal/raffle/transitions_test.go
//
// Sin base, sin red, sin reloj real. Corre en microsegundos y cubre la
// máquina de estados entera. Este es el nivel donde debería vivir todo lo
// que pueda vivir acá.
func TestTransiciones(t *testing.T) {
	casos := []struct {
		desde, hasta string
		legal        bool
	}{
		{"draft", "open", true},
		{"open", "closed", true},
		{"closed", "resolved", true},
		{"resolved", "settled", true},
		{"open", "open", true},        // el PUT que no cambia estado (be04)
		{"draft", "settled", false},   // el salto que rompía el sistema
		{"settled", "open", false},    // no se resucita una rifa liquidada
		{"closed", "open", false},
	}
	for _, c := range casos {
		t.Run(c.desde+"→"+c.hasta, func(t *testing.T) {
			require.Equal(t, c.legal, raffle.CanTransition(c.desde, c.hasta))
		})
	}
}
```

```go
// server/internal/http/handlers_test.go
//
// Nivel 2: la traducción a HTTP. El servicio es un doble; lo que se prueba
// es que cada error de dominio salga con su código y su cuerpo.
type stubNumberService struct {
	err error
	out rafflenumber.RaffleNumber
}

func (s stubNumberService) SellNumber(context.Context, int64, string, *int64) (rafflenumber.RaffleNumber, error) {
	return s.out, s.err
}

func TestSellNumberHandlerTraduceErrores(t *testing.T) {
	casos := []struct {
		nombre       string
		err          error
		quiereCodigo int
		quiereCuerpo string
	}{
		{"venta correcta", nil, 200, ""},
		// Los mensajes son CONTRATO: los lee toReadableError y terminan a
		// la vista del usuario. Que estén escritos acá, literales, es lo
		// que impide que alguien los "mejore" sin darse cuenta.
		{"ya vendido", rafflenumber.ErrAlreadySold, 409, "Ese número ya fue vendido"},
		{"rifa cerrada", rafflenumber.ErrRaffleClosed, 409, "La rifa ya cerró: no se pueden vender más números"},
		{"no existe", rafflenumber.ErrNotFound, 404, "Ese número no existe en la rifa"},
		{"error inesperado", errors.New("boom"), 500, "Error interno del servidor"},
	}

	for _, c := range casos {
		t.Run(c.nombre, func(t *testing.T) {
			// httptest.NewRecorder es un ResponseWriter que guarda todo en
			// memoria: no hay puerto, no hay socket, no hay servidor.
			rec := httptest.NewRecorder()
			req := httptest.NewRequest("POST", "/raffles/1/numbers/0347/sell", nil)

			handler := httpapi.SellNumberHandler(stubNumberService{err: c.err})
			handler.ServeHTTP(rec, withUser(req, 1))

			require.Equal(t, c.quiereCodigo, rec.Code)
			if c.quiereCuerpo != "" {
				var body struct{ Message string `json:"message"` }
				require.NoError(t, json.Unmarshal(rec.Body.Bytes(), &body))
				require.Equal(t, c.quiereCuerpo, body.Message)
			}
		})
	}
}
```

> 🧠 **Y el que casi nadie escribe:** la prueba de que el `404` de los recursos
> automáticos llega con **cuerpo vacío** y el de las rutas propias con
> `{"message":…}`. Es el hallazgo `C-04` de `be00`, y la única cosa que impide que
> alguien los uniforme en un rato de limpieza. Escríbela: son ocho líneas y
> protege una rareza que nadie va a recordar dentro de un año.

### 5.2 Nivel 3: integración contra Postgres de verdad

```go
// server/internal/testsupport/db.go
package testsupport

// mustPostgres es el corazón de la regla del motor.
//
// 🧭 FALLA, no salta. Un t.Skip produce una suite verde que no probó lo que
// dice probar, y nadie lee los SKIP de una salida que termina en "ok". Si
// una prueba de concurrencia, bloqueos, zonas horarias o SQL específico no
// tiene Postgres, eso es un error de configuración del entorno, no un caso
// que se pueda omitir.
func mustPostgres(t *testing.T, db *storage.DB, motivo string) {
	t.Helper()
	if db.Dialect != storage.Postgres {
		t.Fatalf(
			"esta prueba requiere PostgreSQL porque %s.\n"+
				"Levanta el contenedor y exporta TEST_DATABASE_URL.\n"+
				"Ver la regla del motor: D18 y server/evidence/regla-del-motor.md",
			motivo)
	}
}

// OpenPostgres abre la base de PRUEBAS y la deja limpia.
func OpenPostgres(t *testing.T) *storage.DB {
	t.Helper()
	url := os.Getenv("TEST_DATABASE_URL")
	if url == "" {
		t.Fatal("TEST_DATABASE_URL no está definida: esta prueba necesita Postgres")
	}

	// ⚠️ La red de seguridad que evita el peor día. TRUNCATE contra la base
	// de desarrollo borra seis fases de trabajo, y el error es fácil: una
	// variable de entorno que quedó exportada de otra terminal.
	if !strings.Contains(url, "rifas_test") {
		t.Fatalf("TEST_DATABASE_URL debe apuntar a una base llamada rifas_test, no a %q", url)
	}

	db, err := storage.Open(context.Background(), url)
	require.NoError(t, err)
	t.Cleanup(func() { db.Close() })

	truncateAll(t, db)
	return db
}

func truncateAll(t *testing.T, db *storage.DB) {
	t.Helper()
	// RESTART IDENTITY reinicia las secuencias: sin eso, los ids crecen
	// entre pruebas y cualquier aserción sobre un id concreto se vuelve
	// dependiente del orden de ejecución.
	_, err := db.Exec(`TRUNCATE prize_payouts, settlements, sales,
	                            raffle_numbers, participants, raffles, users
	                   RESTART IDENTITY CASCADE`)
	require.NoError(t, err)
}
```

```bash
# server/scripts/test-db.sh — el contenedor de pruebas, separado del de
# desarrollo. Dos contenedores y dos puertos es más barato que un susto.
docker run -d --name rifas-pg-test \
  -e POSTGRES_USER=rifas -e POSTGRES_PASSWORD=rifas -e POSTGRES_DB=rifas_test \
  -p 5433:5432 postgres:13

export TEST_DATABASE_URL="postgres://rifas:rifas@localhost:5433/rifas_test?sslmode=disable"
migrate -path migrations/postgres -database "$TEST_DATABASE_URL" up
```

### 5.3 Nivel 4: la suite de contrato

Es la traducción a Go del `smoke.sh` que escribiste en `be00`, y la pregunta
razonable es por qué existen las dos. La respuesta importa:

`smoke.sh` corre **contra un servidor levantado** —el mock, tu binario, el de un
compañero— sin compilar nada. Es la herramienta del reemplazo y de la
verificación en un ambiente. La suite de Go corre **en cada `go test`**, verifica
la forma exacta de cada respuesta y falla antes de que el código llegue a
ninguna parte. Una atrapa "el ambiente está mal", la otra "el código está mal".

```go
// server/internal/http/contract_test.go
//
// Verifica el régimen estricto de server/CONTRACT.md, endpoint por
// endpoint. Cuando esta suite falla, el frontend heredado se rompe. No hay
// matices: es la traducción ejecutable de la regla que ordena el track.
func TestContratoRegimenEstricto(t *testing.T) {
	srv := testsupport.NewServer(t) // app real, base real, datos sembrados
	token := testsupport.Login(t, srv)

	t.Run("GET /raffles devuelve un array, nunca null", func(t *testing.T) {
		body := srv.GET(t, "/raffles", token).ExpectStatus(200).Raw()
		// El caso que un require.NotNil no atrapa: "null" es JSON válido,
		// se deserializa a un slice nil sin error, y rompe el .map() del
		// componente de la Fase 4. Hay que mirar los bytes.
		require.True(t, strings.HasPrefix(strings.TrimSpace(string(body)), "["))
	})

	t.Run("los tipos de una rifa son los del contrato", func(t *testing.T) {
		// Deserializar a map[string]interface{} y mirar el tipo dinámico es
		// justo lo que hace el navegador. Contra un struct tipado, un id
		// que llegara como string se convertiría solito y la prueba pasaría.
		var r map[string]interface{}
		srv.GET(t, "/raffles/1", token).ExpectStatus(200).JSON(t, &r)

		require.IsType(t, float64(0), r["id"], "id debe ser número")
		require.IsType(t, "", r["closesAt"], "closesAt debe ser string")
		require.Regexp(t, `[+-]\d{2}:\d{2}$`, r["closesAt"], "closesAt debe traer offset, no Z")
	})

	t.Run("participantId nulo llega como null y no como objeto", func(t *testing.T) {
		// El Caso A de la pieza forense de be03, convertido en regresión.
		body := srv.GET(t, "/raffles/1/numbers", token).ExpectStatus(200).Raw()
		require.Contains(t, string(body), `"participantId":null`)
		require.NotContains(t, string(body), `"Valid":`)
	})

	t.Run("las dos formas de 404 conviven (C-04)", func(t *testing.T) {
		srv.GET(t, "/raffles/9999", token).ExpectStatus(404).ExpectEmptyBody(t)
		srv.GET(t, "/raffles/1/numbers/9999", token).ExpectStatus(404).ExpectMessage(t)
	})

	t.Run("C-01: la ruta que el frontend consume desde la Fase 6", func(t *testing.T) {
		srv.GET(t, "/raffles/1/numbers/0347", token).ExpectStatus(200)
	})

	t.Run("credenciales inválidas dan 401, no 200 con array vacío", func(t *testing.T) {
		// El contrato CAMBIÓ en be04 (D27) y esta prueba fija el cambio.
		srv.POST(t, "/login", nil, `{"email":"nadie@x.test","password":"x"}`).ExpectStatus(401)
	})
}

// Y los tres cambios observables que el track introdujo A PROPÓSITO. Que
// tengan prueba propia es lo que los distingue de una regresión: alguien
// decidió esto, lo escribió en CONTRACT.md, y acá está verificado.
func TestCambiosDeliberadosDelContrato(t *testing.T) {
	// be06: el settledAt que vuelve es el del servidor, no el del cliente.
	// be07: los montos se recalculan desde sales.
	// be07: POST /settlements es idempotente.
}
```

### 5.4 Nivel 5: concurrencia y `-race`

```go
// server/internal/rafflenumber/concurrency_test.go

func TestVentaConcurrenteSoloUnGanador(t *testing.T) {
	db := testsupport.OpenPostgres(t)
	// La regla del motor, aplicada. Sin Postgres esta prueba no puede
	// existir: no hay FOR UPDATE que probar.
	testsupport.MustPostgres(t, db, "verifica el bloqueo de fila con FOR UPDATE bajo concurrencia real")

	svc := newService(t, db)
	seedRaffleWithNumbers(t, db, 1, "0347")

	const contenders = 20
	var start sync.WaitGroup
	start.Add(1)
	var wg sync.WaitGroup
	errs := make([]error, contenders)

	for i := 0; i < contenders; i++ {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			start.Wait() // la barrera: sin esto la carrera no ocurre (be05)
			_, errs[i] = svc.SellNumber(ctxConUsuario(1), 1, "0347", nil)
		}(i)
	}
	start.Done()
	wg.Wait()

	var ganadores, conflictos int
	for _, err := range errs {
		switch {
		case err == nil:
			ganadores++
		case errors.Is(err, ErrAlreadySold):
			conflictos++
		default:
			t.Fatalf("error inesperado: %v", err) // cualquier otro es un bug
		}
	}

	require.Equal(t, 1, ganadores, "exactamente uno debe ganar")
	require.Equal(t, contenders-1, conflictos)

	// Y la verificación que de verdad importa: la base. Un servicio que
	// devolviera un solo 200 y hubiera insertado dos filas pasaría todas
	// las aserciones de arriba.
	var ventas int
	require.NoError(t, db.Get(&ventas, `SELECT count(*) FROM sales WHERE raffle_id=1 AND number='0347'`))
	require.Equal(t, 1, ventas)
}
```

```bash
# -race instrumenta el binario para detectar accesos concurrentes sin
# sincronizar. Es entre dos y veinte veces más lento, y encuentra bugs que
# no fallan nunca hasta que fallan en producción un viernes.
go test -race ./...
```

> 🧠 **`-race` y `TestVentaConcurrente` prueban cosas distintas, y confundirlas es
> un clásico.** `-race` detecta carreras **en la memoria de tu proceso** —dos
> goroutines tocando el mismo `string` sin candado, como el `ChaosController` de
> `be01` antes de su `RWMutex`—. La prueba de concurrencia detecta carreras **en
> la base**, donde `-race` no ve absolutamente nada porque ahí no hay memoria
> compartida: hay dos transacciones. Necesitas las dos y ninguna sustituye a la
> otra.

### 5.5 🩻 El par contradictorio

Acá está el contenido central. Dos pruebas, las dos correctas, que se contradicen
según el motor. Van al repositorio y van explicadas.

```go
// server/internal/storage/regla_del_motor_test.go
//
// ⚠️ ESTE ARCHIVO EXISTE PARA DEMOSTRAR UNA REGLA, NO PARA PROBAR EL
// SISTEMA. Las dos pruebas de abajo se contradicen a propósito. Antes de
// "arreglar" cualquiera de las dos, lee D18 y regla-del-motor.md.

// PRUEBA A — pasa en SQLite, FALLA en Postgres.
//
// LastInsertId es la forma "obvia" de recuperar el id recién insertado, y
// es la que sale en la mitad de los tutoriales. mattn/go-sqlite3 lo
// implementa; lib/pq NO —el protocolo de Postgres sencillamente no lo
// ofrece— y devuelve "LastInsertId is not supported by this driver".
//
// Un equipo que pruebe solo contra SQLite escribe este código, ve la suite
// verde, despliega, y TODA creación de rifas devuelve 500. La suite no
// falló. La suite dio permiso.
func TestA_LastInsertId(t *testing.T) {
	db := testsupport.OpenAny(t)

	res, err := db.Exec(db.Rebind(
		`INSERT INTO participants (name) VALUES (?)`), "Ana")
	require.NoError(t, err)

	id, err := res.LastInsertId()
	require.NoError(t, err, "lib/pq no implementa LastInsertId: usa RETURNING")
	require.Greater(t, id, int64(0))
}

// PRUEBA B — FALLA en SQLite, pasa en Postgres.
//
// La comparación de instantes. En Postgres, closes_at es TIMESTAMPTZ y la
// comparación es entre instantes: 22:00-05:00 es el 31 a las 03:00 UTC, o
// sea posterior a las 01:00 UTC del 31, y la rifa se devuelve.
//
// En SQLite no existe el tipo fecha: la columna es TEXT y la comparación
// es LEXICOGRÁFICA. '2026-08-30…' contra '2026-08-31…' compara "30" con
// "31", y la rifa NO se devuelve.
//
// Los dos motores están funcionando correctamente según su propia
// especificación. Y tu regla de negocio —"no se vende después del
// cierre"— da resultados OPUESTOS. Es la Divergencia 2 de be02,
// convertida en prueba.
func TestB_ComparacionDeInstantes(t *testing.T) {
	db := testsupport.OpenAny(t)
	insertRaffle(t, db, "Rifa fin de mes", "2026-08-30T22:00:00-05:00")

	var nombres []string
	require.NoError(t, db.Select(&nombres, db.Rebind(
		`SELECT name FROM raffles WHERE closes_at > ?`), "2026-08-31T01:00:00Z"))

	require.Len(t, nombres, 1,
		"el cierre es posterior al umbral; si esto falla, el motor está comparando cadenas")
}
```

Y la ejecución que lo demuestra, que es lo que hay que pegar en el documento:

```bash
# Contra SQLite: A pasa, B falla.
TEST_DATABASE_URL="" go test -run 'TestA_|TestB_' ./internal/storage/

# Contra Postgres: A falla, B pasa.
TEST_DATABASE_URL="postgres://…/rifas_test" go test -run 'TestA_|TestB_' ./internal/storage/
```

> 🧭 **Qué se hace con estas dos pruebas.** No se "arreglan": se **clasifican**.
> La A documenta una trampa y no debe correr en CI —el código correcto usa
> `RETURNING`, y `be03` ya lo hace—. La B es una prueba legítima del sistema y
> tiene que correr **solo contra Postgres**, con su `MustPostgres` y su motivo
> escrito. Clasificar cada prueba por el motor que necesita es el trabajo real de
> esta fase, y `regla-del-motor.md` es donde queda esa clasificación.

### 5.6 La suite, por niveles, desde la terminal

```makefile
# server/Makefile
# Cinco comandos porque son cinco niveles con costos distintos. El de
# arriba corre en un segundo y es el que se usa cien veces al día.

test-unit:            ## sin base, milisegundos
	go test ./internal/... -run 'TestPrizeShare|TestTransiciones|TestSell.*Handler|TestHoraDura' -count=1

test-integration:     ## contra Postgres en contenedor
	TEST_DATABASE_URL=$(TEST_DB) go test ./internal/... -count=1

test-contract:        ## el régimen estricto de be00
	TEST_DATABASE_URL=$(TEST_DB) go test ./internal/http/ -run TestContrato -count=1

test-race:            ## carreras en memoria
	TEST_DATABASE_URL=$(TEST_DB) go test -race ./... -count=1

test-engine-rule:     ## el par contradictorio, contra los dos motores
	@echo "--- SQLite ---";   TEST_DATABASE_URL= go test -run 'TestA_|TestB_' ./internal/storage/ || true
	@echo "--- Postgres ---"; TEST_DATABASE_URL=$(TEST_DB) go test -run 'TestA_|TestB_' ./internal/storage/ || true
```

> ⚠️ **`-count=1` en todos.** Go cachea resultados de pruebas, y una prueba de
> integración cacheada es una prueba que **no corrió** aunque diga `ok`. El
> símbolo `(cached)` en la salida es fácil de pasar por alto y es la segunda
> forma en que una suite miente.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. `t.Skip` cuando falta el entorno.** Síntoma: la suite dice `ok` y la
concurrencia nunca se probó. Causa: saltar en vez de fallar. Fix: `MustPostgres`.
Corrección mínima frente a refactorización: cambiar `Skip` por `Fatal` es la
corrección; reorganizar la suite por etiquetas de compilación es la
refactorización, y probablemente no hace falta.

**2. Probar el service contra un store falso.** Síntoma: cobertura altísima y
bugs en producción. Causa: cuando la lógica está en el SQL, un store falso prueba
el doble. Fix: el service contra base real; los dobles, para el reloj y para los
handlers.

**3. Pruebas que dependen del orden.** Síntoma: pasan solas y fallan en la suite,
o al revés. Causa: datos compartidos, o secuencias que siguen creciendo. Fix:
`TRUNCATE … RESTART IDENTITY` antes de cada caso. Y `go test -shuffle=on`, que
existe desde Go 1.17 y desenmascara esto en un minuto.

**4. Prueba de concurrencia sin barrera.** Síntoma: pasa contra el código de
`be03`. Causa: las goroutines se lanzan escalonadas. Fix: el `WaitGroup` de
barrera. **La prueba de que tu prueba de concurrencia sirve es que falle contra el
código vulnerable.** Si nunca la corriste contra él, no sabes qué tienes.

**5. Aserciones sobre structs en vez de sobre JSON.** Síntoma: el contrato se
rompe y la suite no se entera. Causa: deserializar a un tipo propio hace que el
JSON `"1"` y el `1` acaben en el mismo `int64`. Fix: en las pruebas de contrato,
mirar los bytes o un `map[string]interface{}`.

**6. Confundir cobertura con confianza.** Síntoma: 85 % de cobertura y el bug de
la venta duplicada intacto. Causa: la cobertura mide líneas ejecutadas, no
propiedades verificadas — el `SellNumber` de `be03` tenía cobertura completa. Fix:
usar la cobertura para encontrar lo que **nadie** ejecuta, nunca como objetivo.

### 🩻 Pieza forense de esta fase

**El par de pruebas contradictorias, y la suite que da permiso para desplegar.**

*Paso 1 — la contradicción, medida.* Corre `make test-engine-rule` y pega las dos
salidas en `server/evidence/regla-del-motor.md`. Cuatro resultados: A verde y B
roja en SQLite; A roja y B verde en Postgres. Escribe al lado de cada una **por
qué el motor tiene razón**. Ninguno de los dos está fallando.

*Paso 2 — la simulación del despliegue, que es la parte que convence.* Ponte en
la piel del equipo que solo prueba contra SQLite:

1. Escribe `CreateRaffle` con `LastInsertId` en vez de `RETURNING`.
2. Corre la suite completa contra SQLite. **Verde.**
3. Haz `git commit`. Con la suite verde, es lo que cualquiera haría.
4. Ahora corre exactamente lo mismo contra Postgres y mira cuántas pruebas caen.
5. Y peor: levanta el binario contra Postgres y crea una rifa desde la
   aplicación. `500`. **La funcionalidad más básica del sistema, rota, con la
   suite en verde.**

Escríbelo con tus palabras: *la suite no falló en detectar el bug; la suite
autorizó el bug*. Esa distinción es la fase entera.

*Paso 3 — la concurrencia, que ni siquiera puede fingirse.* Corre
`TestVentaConcurrenteSoloUnGanador` contra SQLite quitando el `MustPostgres`.
Anota el error exacto —`near "FOR": syntax error`, o `database is locked` si
quitas también el `FOR UPDATE`—. Después piensa en la tentación real: alguien va
a proponer quitar el `FOR UPDATE` "para que las pruebas corran en cualquier
lado". Escribe en cuatro líneas por qué esa propuesta, que suena razonable,
desmantela `be05` entero.

*Paso 4 — la prueba que se prueba a sí misma.* Vuelve al `SellNumber` de `be03`
(sin transacción) y corre la prueba de concurrencia contra Postgres. **Tiene que
fallar**, y tiene que fallar diciendo que hubo dos ganadores. Si pasa, tu prueba
no sirve — arréglala y repite. Este paso es el único que te dice si tu red tiene
agujeros.

*Paso 5 — `-race` sobre el bug real.* Vuelve al `ChaosController` de `be01` sin
su `RWMutex`, corre `go test -race`, y lee el informe entero: te dice las dos
goroutines, las dos líneas y el tipo de acceso. Compáralo con lo que verías sin
`-race`: nada. Durante meses.

*Paso 6 — el círculo, cerrado del todo.* Corre la suite de contrato con
`SQL_DEBUG=1` y sigue un `X-Request-Id` desde la petición de la prueba hasta la
consulta SQL. En `be00` ese id no llegaba a ninguna parte. Ahora recorre el
sistema entero, y lo hace **dentro de una prueba automatizada** — que es la forma
final de la trazabilidad: no un ejercicio de diagnóstico, sino una propiedad
verificada.

---

## 🧪 7. Ejercicios (33)

**🟢 Fácil (1–8)**

1. Levanta el contenedor de pruebas en el `5433` y aplica las migraciones sobre `rifas_test`.
2. Corre `make test-unit` y comprueba que tarda menos de un segundo.
3. Corre la suite completa contra Postgres y anota cuánto tarda.
4. Ejecuta `make test-engine-rule` y pega las cuatro salidas.
5. Comprueba que `OpenPostgres` se niega a correr si `TEST_DATABASE_URL` no apunta a `rifas_test`.
6. Corre `go test -race ./...` y confirma que pasa limpio.
7. Escribe la prueba de handler de las dos formas de `404` (`C-04`).
8. Corre `go test ./...` dos veces seguidas sin `-count=1` y encuentra el `(cached)`.

**🟡 Intermedio (9–19)**

9. Escribe la tabla de transiciones completa como prueba unitaria, con los casos ilegales.
10. **Diagnóstico.** Quita `-count=1` de `test-integration`, cambia el código para romperlo, y comprueba que la suite sigue diciendo `ok`. Explica el mecanismo.
11. Escribe la prueba de contrato que verifica que `GET /raffles` devuelve `[` y no `null`, y compruébala rompiendo el código.
12. **Diagnóstico.** Escribe la aserción de tipos contra un struct tipado en vez de un `map` y demuestra que no detecta un `id` que llegue como string.
13. Escribe la prueba de regresión del Caso A de `be03` (`participantId` como objeto).
14. Implementa `MustPostgres` y aplícalo a todas las pruebas que tocan las cuatro áreas. Enumera cuántas son.
15. **Diagnóstico.** Cambia `MustPostgres` por `t.Skip`, corre la suite sin Postgres, y cuenta cuántas pruebas se saltaron sin que la salida lo destaque.
16. Corre la suite con `go test -shuffle=on` diez veces y determina si alguna prueba depende del orden.
17. **Diagnóstico.** Quita `RESTART IDENTITY` del truncado y encuentra qué prueba empieza a fallar y por qué.
18. Escribe las tres pruebas de los cambios deliberados del contrato (`settledAt` del servidor, montos recalculados, idempotencia).
19. Mide la cobertura con `go test -cover` y anota el número. No lo persigas: úsalo para encontrar un archivo que nadie ejecuta.

**🟠 Difícil (20–28)**

20. **Diagnóstico.** Ejecuta el paso 2 de la pieza forense completo —el despliegue autorizado por una suite verde— y escribe el informe.
21. **Diagnóstico.** Ejecuta el paso 4: corre la prueba de concurrencia contra el `SellNumber` de `be03` y demuestra que falla. Pega el mensaje.
22. Escribe `regla-del-motor.md`: la regla, las cuatro áreas, el par contradictorio con su evidencia, y **la clasificación de cada prueba de tu suite** por el motor que necesita.
23. **Diagnóstico.** Ejecuta el paso 5 y transcribe el informe de `-race` completo, explicando qué significa cada bloque.
24. Encuentra una tercera divergencia de `be02` que puedas convertir en prueba contradictoria y agrégala al par. Justifica en qué categoría de las cuatro cae.
25. **Diagnóstico.** Determina cuántas de tus pruebas podrían correr contra SQLite sin mentir. Argumenta si vale la pena mantener esa capacidad o si es una comodidad peligrosa.
26. Escribe la prueba que verifica el apagado ordenado de `be01`: una petición en vuelo, un `SIGTERM`, y la respuesta completa.
27. **Diagnóstico.** Introduce a propósito una regresión de contrato en un endpoint y comprueba que la suite la atrapa. Si no la atrapa, escribe la prueba que faltaba.
28. Mide cuánto tarda la suite completa y decide qué correría en cada momento: al guardar un archivo, antes de un commit, y en CI. Justifica con los tiempos.

**🔴 Muy difícil (29–33)**

29. Diseña el mecanismo que impide que alguien agregue una prueba de concurrencia sin `MustPostgres`. Puede ser una etiqueta de compilación, una convención de nombres verificada por un script, o un `go vet` propio. Impleméntalo.
30. Argumenta por escrito si SQLite debería seguir en el proyecto. Defiende primero eliminarlo —una sola verdad, cero divergencias, cero riesgo de falso positivo— y después conservarlo, y decide con un criterio operativo. Si decides eliminarlo, enumera qué se pierde.
31. **Diagnóstico + regresión.** Ticket: *"la suite lleva tres semanas en verde y ayer se rompió la creación de rifas en producción"*. Reconstruye las tres hipótesis más probables, di cómo descartas cada una, y escribe la prueba que faltaba.
32. Diseña la prueba basada en propiedades del sistema completo: para cualquier secuencia de ventas, reservas y liquidaciones, ninguna rifa termina con más ventas que números ni con pagos que no sumen su premio. Impleméntala con generación aleatoria y semilla fija.
33. **Post-mortem.** Escribe el post-mortem de *"la suite verde autorizó un despliegue roto"* según la guía §13, con la causa raíz en el motor de pruebas. **Sin culpabilización**: usar SQLite en las pruebas es una práctica extendida y razonable, y quien la eligió tenía buenos motivos. La prevención tiene que ser un mecanismo, no una advertencia.

**🔥 Opcionales**

- 🔥 Escribe una prueba de *fuzzing* con `go test -fuzz` (nativo desde Go 1.18) sobre `PrizeShare` y sobre el parseo de fechas del contrato. Anota qué encontró.
- 🔥 Corre pruebas de mutación con alguna herramienta del ecosistema Go sobre `settlement/math.go` y compara el resultado con tu cobertura. La diferencia entre los dos números es la conversación honesta sobre calidad de suite.
- 🔥 Sustituye el contenedor manual por `testcontainers-go` y compara: menos guion, una dependencia más, y arranque más lento por caso. Decide con el criterio de autocontención del track.

---

## 📚 8. Referencias

**Documentación oficial**
- https://pkg.go.dev/testing — `T.Helper`, `T.Cleanup`, subpruebas y `-shuffle`.
- https://pkg.go.dev/net/http/httptest — `NewRecorder` y `NewServer`, el nivel 2 entero.
- https://go.dev/doc/articles/race_detector — cómo funciona `-race`, qué detecta y qué no. Léelo antes del paso 5.
- https://go.dev/blog/subtests — el patrón de tabla con subpruebas que usa toda esta fase.
- https://github.com/stretchr/testify — `require` (aborta) contra `assert` (continúa); saber cuál usar en cada aserción evita cascadas de fallos ilegibles.
- https://www.sqlite.org/quirks.html — otra vez, porque es la fuente primaria de la regla del motor.

**Libros**
- *Unit Testing: Principles, Practices, and Patterns* (Vladimir Khorikov) — su tratamiento de qué sustituir y qué no es exactamente §4.3, y su crítica a las pruebas con *mocks* de todo es la mejor que conozco.
- *Working Effectively with Legacy Code* (Michael Feathers) — la definición de "prueba" que exige que falle cuando el código está mal. El paso 4 de la pieza forense es esa idea.

**Video / apoyo**
- Busca "Go testing best practices" y "table driven tests Go". Y si encuentras alguna charla sobre el detector de carreras de Go, vale mucho la pena: entender cómo funciona cambia cuánto confías en él.

**Orden de lectura sugerido:** el blog de subpruebas primero, que fija el patrón →
`httptest` para el nivel 2 → el artículo del detector de carreras antes de correr
`-race` en serio → y Khorikov cuando quieras la teoría sobre qué sustituir.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros son de memoria y pueden ser inexactas. Cualquier
> discrepancia de versiones la resuelve `prompts/decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

La mitad invisible del sistema quedó cubierta. Cinco niveles, cada uno con su
trabajo: lo que se puede probar sin base se prueba en milisegundos, lo que
depende del motor se prueba contra el motor de verdad, y lo que depende de la
concurrencia se prueba con veinte goroutines y una barrera.

Y quedó demostrada la regla que da nombre a la fase, con dos pruebas que se
contradicen y las dos tienen razón. Ahora puedes decir con autoridad —tuya, con
tus salidas pegadas en un archivo— cuál de tus pruebas te estaría engañando si
corriera contra el motor equivocado, y por qué una suite verde no es lo mismo que
un sistema correcto.

`be09` cierra el track. Build multi-stage, la decisión entre cgo y Go puro **con
su medición** de tamaño de imagen y tiempo de compilación, configuración para los
cuatro ambientes, migraciones al arrancar frente a paso previo del despliegue, y
un workflow de GitHub Actions que compila, prueba contra los dos motores y publica
la imagen. Con la separación de edades que hay que explicar y no esconder: la
aplicación es de 2022 y el pipeline es de hoy.

Y después, el **veredicto honesto**: qué quedó mejor que el mock, qué quedó peor,
qué deudas siguen vivas y cuándo **no** vale la pena reemplazar un mock por un
backend propio.

> **La señal de que quedó bien:** *"sé exactamente cuál de mis pruebas me estaría
> mintiendo si la corriera contra el otro motor, y tengo la salida que lo
> demuestra."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be08-pruebas-y-la-regla-del-motor -m "be08 cerrada: \
> suite en cinco niveles, cada uno ejecutable por separado; handlers con httptest; \
> suite de contrato que verifica el régimen estricto de be00 y los tres cambios deliberados; \
> integración contra Postgres en contenedor con truncado y red de seguridad; \
> TestVentaConcurrente que falla contra el código de be03; go test -race limpio; \
> MustPostgres que falla en vez de saltar; \
> par de pruebas contradictorias documentado en server/evidence/regla-del-motor.md"
> ```
>
> Los commits de la fase llevan su prefijo (`be08: …`) y los de ejercicio su
> número (`be08 ej20: …`). Si un ejercicio merece su propio marcador va en
> `ej/be08/20`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **`be09` hereda la suite tal cual y no debería tocarla:** su trabajo es hacerla
  correr en CI contra los dos motores, no reorganizarla. Los cinco objetivos del
  `Makefile` son la interfaz que el workflow debe usar.
- **El par contradictorio es material de `be-a-03`.** El apéndice de dialectos
  debería citarlo como su cierre: el diccionario de divergencias explica **qué**
  difiere, y estas dos pruebas demuestran **qué cuesta**.
- **La prueba B (comparación de instantes) también es de `be-a-06`.** Es la misma
  Divergencia 2 que arrastra el track desde `be02`, y aparecer en tres sitios con
  el mismo ejemplo es deliberado: es el hilo conductor de la portabilidad.
- **El ejercicio 30 —¿debería seguir SQLite en el proyecto?— es candidato a
  entrar en el veredicto honesto de `be09`.** La respuesta defendible del track
  es que sí, pero solo bajo la regla y con `MustPostgres` haciéndola cumplir; sin
  ese mecanismo, la respuesta sería que no.
- **El ejercicio 29 (impedir pruebas de concurrencia sin `MustPostgres`)** debería
  terminar en el pipeline de `be09` como paso de verificación, no como buena
  intención.
- **Deudas declaradas:** 💸 el contenedor de pruebas se levanta a mano con un
  guion (el ejercicio 🔥 de `testcontainers` lo discute, y `be09` lo resuelve para
  CI); 💸 no hay medición de cobertura en CI, a propósito, y conviene que el
  veredicto de `be09` explique por qué no se puso.
- **Reserva para el cuaderno de incidentes:** `be-15` — *"la suite lleva tres
  semanas en verde y ayer se rompió producción"* (categoría 🔥 contrato,
  dificultad 🔴), el ejercicio 31, que es el incidente más formativo del track BE
  después de la venta duplicada, y el hermano directo del incidente 20 del track
  base —*"el test pasa en mi máquina y falla en la de al lado"*— con la causa raíz
  desplazada del entorno al motor.
FIN_DEL_ARCHIVO
wc -l be08-pruebas-y-la-regla-del-motor.md

# --- 2026-09-09T03:23:29 · 
cat > be09-empaquetado-ambientes-y-pipeline.md <<'FIN_DEL_ARCHIVO'
# 📦 Fase be09 — Empaquetado, ambientes y pipeline

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Fase be09 de be09 · **8 horas**
> Depende de: be08 — hay una suite que puede correr en CI · Habilita: nada. **Cierra el track.**

---

## 🎯 1. Propósito

Convertir el binario que corre en tu máquina en algo que se puede desplegar: una
imagen construida de forma reproducible, configurada por ambiente, con las
migraciones aplicadas cuando corresponde, y un pipeline que compila, prueba
contra los dos motores y publica.

Y cerrar el track con lo que el curso entero viene practicando: **un veredicto
honesto**. Qué quedó mejor que el mock, qué quedó peor, qué deudas siguen vivas
—porque siguen— y en qué situaciones reemplazar un mock por un backend propio
**no vale la pena**.

Hay además una decisión que `D19` dejó abierta desde `be02` y que se paga acá,
midiendo y no opinando: **cgo contra Go puro**, en tamaño de imagen y tiempo de
compilación. Llevas seis fases sintiendo el peso de `CGO_ENABLED=1`; toca ponerle
números.

> 🧭 **Autocontención, y acá es crítico.** Esta fase **no remite a ningún otro
> curso del catálogo**, exista o no uno de contenedores. Todo lo necesario para
> construir la imagen y el pipeline vive acá y en `be-a-02`, escrito como receta
> cerrada y verificable de principio a fin.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `server/Dockerfile` multi-stage produce una imagen que arranca y responde
      `GET /health`.
- [ ] La medición de `D19` está hecha y escrita en `server/evidence/imagen.md`:
      tamaño y tiempo de compilación con cgo y sin cgo, con la decisión tomada y
      justificada con esos números.
- [ ] `docker-compose.yml` levanta backend, Postgres y migraciones, y la
      aplicación React del `3000` funciona contra eso sin cambiar nada.
- [ ] La configuración de los **cuatro ambientes** —desarrollo, QA, UAT y
      producción— está resuelta por variables de entorno, con la lista completa
      de qué cambia en cada uno.
- [ ] Está decidido y justificado si las migraciones corren al arrancar o como
      paso previo del despliegue, **y son distintas en desarrollo y en
      producción**.
- [ ] `.github/workflows/ci.yml` compila, corre los cinco niveles de `be08`
      contra los dos motores y publica la imagen.
- [ ] La separación de edades está explicada en el propio workflow: acciones de
      hoy ejecutando Go de 2022.
- [ ] Existe `server/VEREDICTO.md` con el cierre honesto del track.
- [ ] `./server/smoke.sh` pasa **contra el contenedor**, no solo contra
      `go run`.

---

## 🚫 3. Qué queda fuera por ahora

- **Orquestación y Kubernetes.** Un `docker-compose` y una imagen bien construida
  son el límite del track. Lo demás son decisiones de infraestructura que no
  enseñan nada nuevo sobre este sistema.
- **Despliegue real a un proveedor.** No hay nube, no hay cuenta, no hay tarjeta.
  El pipeline publica la imagen y ahí termina.
- **Observabilidad completa.** Métricas, trazas distribuidas y alertas quedan
  fuera. Lo que sí hay —el `X-Request-Id` recorriendo el sistema entero— se
  construyó en `be01` y se usó en todas las fases.
- **Secretos de verdad.** Se usan variables de entorno y los secretos del
  repositorio. Un gestor de secretos es otra conversación, apuntada en
  `be-a-08`.

---

## 🧠 4. Conceptos mínimos

### 4.1 Multi-stage: por qué la imagen final no lleva compilador

Compilar necesita el toolchain de Go, las fuentes y el módulo entero:
aproximadamente un gigabyte. **Ejecutar** necesita un binario. Un `Dockerfile`
multi-stage hace las dos cosas en la misma receta y descarta la primera etapa.

Y no es solo tamaño. Una imagen sin compilador, sin `git`, sin intérprete y sin
gestor de paquetes tiene una superficie de ataque muchísimo menor: quien
consiguiera ejecutar algo dentro no tendría con qué. Es la razón por la que las
imágenes mínimas se llaman *distroless*.

### 4.2 La cuestión cgo, que ya sufriste

`mattn/go-sqlite3` es una envoltura sobre la biblioteca de C de SQLite y exige
`CGO_ENABLED=1`. Eso arrastra tres consecuencias que llevas seis fases
padeciendo:

- **Compilación lenta**, porque hay que compilar C.
- **El binario deja de ser estático**: enlaza contra la `libc` del sistema donde
  se compiló. Un binario compilado sobre Debian (`glibc`) **no corre** en Alpine
  (`musl`), y el error —`no such file or directory` sobre un binario que
  claramente existe— es de los más desconcertantes que hay.
- **Adiós compilación cruzada.** Construir para `linux/amd64` desde un Mac con
  Apple Silicon deja de ser gratis.

Antes de elegir entre `mattn` y `modernc.org/sqlite`, conviene notar algo que
cambia la pregunta entera:

> 🧠 **SQLite solo se usa en pruebas.** El binario de producción no lo necesita
> jamás. Si el `import _ "github.com/mattn/go-sqlite3"` está en un archivo
> normal, arrastra cgo a **todas** las compilaciones, incluida la de producción,
> por un driver que allí no se usa nunca.
>
> La solución no es cambiar de driver: es **etiquetar la compilación** para que el
> driver de pruebas solo entre cuando se pide.

`D19` pide medir, y lo que se mide entonces son tres escenarios: con cgo, sin cgo
mediante etiqueta de compilación, y con `modernc.org/sqlite` (Go puro, que no
necesita etiqueta pero es más lento en ejecución). La decisión sale de los
números, no del gusto.

### 4.3 Cuatro ambientes, una imagen

La regla es vieja y sigue siendo la correcta: **la misma imagen en todos los
ambientes, y todo lo que cambia va por configuración**. Una imagen "de QA" y otra
"de producción" significan que lo que probaste no es lo que desplegaste.

| Variable | Desarrollo | QA | UAT | Producción |
|---|---|---|---|---|
| `DATABASE_URL` | local | de QA | de UAT | de producción |
| `CHAOS_LEVEL` | `low` | `high` | `off` | `off` (y ver abajo) |
| `JWT_SECRET` | de laboratorio | de QA | de UAT | secreto real |
| `JWT_TTL` | `12h` | `12h` | `1h` | `1h` |
| `SQL_DEBUG` | `true` | `true` | `false` | `false` |
| `ALLOWED_ORIGIN` | `localhost:3000` | el de QA | el de UAT | el real |
| `sslmode` | `disable` | `require` | `require` | `require` |

> ⚠️ **El caos no debería poder existir en producción, y "apagado por defecto" no
> alcanza.** Una ruta `POST /_chaos` en un binario de producción es un endpoint
> para romper tu propio sistema, expuesto a internet. La respuesta correcta no es
> una variable: es que ese código **no esté en el binario**, con una etiqueta de
> compilación. Es el ejercicio 24, y es la única concesión del track a la
> seguridad por construcción.

### 4.4 Migraciones: al arrancar o como paso previo

`D20` fijó que las migraciones son un paso explícito y **nunca implícito al
arrancar en producción**. Acá se implementa, y conviene entender el porqué con
precisión, porque la comodidad del atajo es real.

Aplicarlas en el arranque es cómodo en desarrollo: un comando y ya. En producción
con más de una réplica, tres procesos arrancan a la vez y los tres intentan
aplicar el mismo `ALTER`. `golang-migrate` toma un bloqueo, así que en el mejor
caso dos esperan; en el peor —un despliegue interrumpido a mitad— la base queda
marcada como sucia y **ninguna réplica arranca**. Un incidente total causado por
un atajo de conveniencia.

> 🧭 **Decisión: migraciones como paso previo, con un binario aparte
> (`cmd/migrate`), y una comprobación al arrancar.** El servidor no migra: **mira
> si la base está en la versión que espera** y se niega a arrancar si no. Falla
> temprano, ruidoso, y con un mensaje que dice exactamente qué versión hay y cuál
> hacía falta.
>
> En desarrollo, `docker-compose` corre el paso de migración como un servicio
> previo. Es el mismo mecanismo, orquestado distinto — que es exactamente la
> diferencia que hay entre los ambientes.

### 4.5 Dos edades en el mismo repositorio

`D23` fija algo que parece contradictorio: la aplicación es de 2022 y **el
pipeline es de hoy**.

No es una inconsistencia, es la realidad de cualquier repositorio que se revive.
Un workflow escrito con las acciones de 2022 sencillamente **no corre**: los
runners actuales rechazan aquellas versiones de las acciones. Así que el track
separa las dos edades y lo dice: acciones actuales, ejecutando Go 1.19 dentro de
un `container: golang:1.19` con `services: postgres:13`.

📝 Y es, además, exactamente la conversación que tiene un equipo cuando le toca
revivir un repositorio dormido. La pregunta no es "¿modernizamos todo?" sino
"¿qué tiene que ser de hoy y qué puede seguir siendo de entonces?". La respuesta
suele ser la misma: **la infraestructura que ejecuta, de hoy; el código que se
ejecuta, cuando se pueda**.

---

## 💻 5. Implementación y código comentado

### 5.1 La etiqueta que libera al binario de producción

```go
// server/internal/storage/driver_sqlite.go
//go:build sqlite

// Este archivo solo se compila con -tags sqlite. Es lo que mantiene a cgo
// FUERA del binario de producción, que no necesita SQLite para nada.
//
// La línea //go:build tiene que ir antes del package y separada por una
// línea en blanco, o el compilador la trata como un comentario cualquiera
// y no hace nada. Es un error silencioso: compila igual, con cgo, y solo
// lo notas midiendo.
package storage

import _ "github.com/mattn/go-sqlite3"

const sqliteEnabled = true
```

```go
// server/internal/storage/driver_nosqlite.go
//go:build !sqlite

package storage

const sqliteEnabled = false
```

```go
// Y en Open, un mensaje que evita una hora de desconcierto:
if dialect == SQLite && !sqliteEnabled {
	return nil, errors.New(
		"este binario se compiló sin soporte de SQLite: usa -tags sqlite (solo para pruebas)")
}
```

```bash
go build ./cmd/api                    # producción: puro Go, estático
go test -tags sqlite ./...            # pruebas: con SQLite disponible
```

### 5.2 El `Dockerfile`

```dockerfile
# server/Dockerfile
# Multi-stage: se compila con el toolchain completo y se despacha solo el
# binario. La receta completa, con compose y los tres errores que salen
# siempre, está en be-a-02.

# ---------- etapa 1: compilar ----------
# golang:1.19 y no una versión actual: el código es de 2022 y usa el
# toolchain de 2022 (D14). El pipeline que ejecuta esto sí es de hoy (D23).
FROM golang:1.19 AS builder

WORKDIR /src

# Las dependencias primero y en su propia capa: cambian mucho menos que el
# código, así que Docker reutiliza esta capa en casi todas las
# construcciones. Copiar todo de una vez invalida la caché con cada edición.
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# CGO_ENABLED=0 es la línea que hace todo lo demás posible: sin cgo el
# binario es estático y corre en una imagen vacía. Se puede poner gracias
# a la etiqueta de 5.1.
#
# -ldflags "-s -w" quita la tabla de símbolos y la información de depuración.
# ⚠️ Y con eso pierdes los nombres en los stack traces del pánico de be01.
# Es un intercambio real: unos megas contra diagnosticabilidad. Acá se
# aceptan porque el pánico se registra con recover y su mensaje; en un
# sistema donde dependas del stack trace, no lo hagas.
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags "-s -w" \
    -o /out/api ./cmd/api

RUN CGO_ENABLED=0 GOOS=linux go build -o /out/migrate ./cmd/migrate

# ---------- etapa 2: ejecutar ----------
# gcr.io/distroless/static-debian11: sin shell, sin gestor de paquetes, sin
# libc. Solo trae certificados raíz y los archivos de usuario. Pesa unos
# 2 MB.
FROM gcr.io/distroless/static-debian11:nonroot

COPY --from=builder /out/api /api
COPY --from=builder /out/migrate /migrate
COPY --from=builder /src/migrations /migrations

# nonroot viene del tag de la imagen base. Si el proceso se compromete, no
# es root — que es lo mínimo exigible y cuesta cero.
USER nonroot:nonroot

EXPOSE 3001
ENTRYPOINT ["/api"]
```

Y el detalle que hunde a mucha gente la primera vez:

```go
// server/cmd/api/main.go
import (
	// Una imagen vacía NO TIENE la base de datos de zonas horarias del
	// sistema. Sin esto, cualquier time.LoadLocation("America/Bogota")
	// devuelve "unknown time zone" DENTRO DEL CONTENEDOR y en ningún otro
	// sitio: funciona perfecto en tu máquina y falla en el despliegue.
	//
	// Este import embebe la base de zonas en el binario (unos 450 KB) y
	// existe desde Go 1.15. Es la solución de una línea a un incidente de
	// media tarde, y conecta directamente con be06.
	_ "time/tzdata"
)
```

### 5.3 La medición de `D19`

No opines: mide. Tres escenarios, la misma máquina, la misma caché fría.

```bash
# 1. Con cgo (lo que venías arrastrando desde be02)
time CGO_ENABLED=1 go build -tags sqlite -o /tmp/api-cgo ./cmd/api
docker build --no-cache -f Dockerfile.cgo -t rifas:cgo .

# 2. Sin cgo, con la etiqueta de 5.1
time CGO_ENABLED=0 go build -o /tmp/api-puro ./cmd/api
docker build --no-cache -t rifas:puro .

# 3. Con modernc.org/sqlite (Go puro, sin etiqueta)
time CGO_ENABLED=0 go build -tags modernc -o /tmp/api-modernc ./cmd/api

ls -lh /tmp/api-*
docker images rifas
```

Lo que hay que anotar en `server/evidence/imagen.md`:

| Escenario | Tamaño del binario | Tamaño de la imagen | `go build` en frío | `go test` completo |
|---|---|---|---|---|
| cgo (`mattn`) | | | | |
| puro Go (etiqueta) | | | | |
| `modernc.org/sqlite` | | | | |

Y la decisión, escrita con esos números al lado. La que este track defiende —y
que tienes que verificar tú— es que **la etiqueta de compilación gana**: el
binario de producción queda puro y estático, las pruebas conservan `mattn`, que
es más rápido en ejecución que `modernc`, y no hace falta cambiar de driver. La
pregunta de `D19` resultó estar mal planteada: no era *qué driver de SQLite*, era
*por qué el binario de producción tiene un driver de SQLite*.

> 🧠 **Ese giro es la lección de la sección.** Cuando una decisión técnica parece
> un empate entre dos opciones malas, muchas veces la pregunta está mal hecha.
> `D19` llevaba siete fases abierta como "cgo o puro Go", y la respuesta real fue
> "esto no debería estar en el binario".

### 5.4 `docker-compose` y las migraciones como paso previo

```yaml
# server/docker-compose.yml
# El laboratorio completo. La aplicación React sigue en el 3000, fuera de
# esto, hablándole al 3001 como desde be03.
services:
  db:
    image: postgres:13
    environment:
      POSTGRES_USER: rifas
      POSTGRES_PASSWORD: rifas
      POSTGRES_DB: rifas
    ports: ["5432:5432"]
    healthcheck:
      # Sin esto, el servicio de migraciones arranca contra un Postgres que
      # todavía está inicializándose y falla. "depends_on" solo espera a que
      # el contenedor exista, no a que el servicio esté listo — es el error
      # número uno de compose y produce fallos intermitentes al levantar.
      test: ["CMD-SHELL", "pg_isready -U rifas"]
      interval: 2s
      retries: 15

  migrate:
    build: .
    entrypoint: ["/migrate", "up"]
    environment:
      DATABASE_URL: postgres://rifas:rifas@db:5432/rifas?sslmode=disable
    depends_on:
      db: { condition: service_healthy }

  api:
    build: .
    ports: ["3001:3001"]
    environment:
      DATABASE_URL: postgres://rifas:rifas@db:5432/rifas?sslmode=disable
      ALLOWED_ORIGIN: http://localhost:3000
      JWT_SECRET: laboratorio-no-usar-esto-en-ningun-otro-lado-32
      CHAOS_LEVEL: "off"
    depends_on:
      # El API espera a que las migraciones TERMINEN. Es el paso previo de
      # §4.4, orquestado por compose en vez de por el pipeline.
      migrate: { condition: service_completed_successfully }
```

```go
// server/cmd/api/main.go — la comprobación de versión, no la migración.
//
// El servidor NO migra. Comprueba que la base esté donde debe y se niega a
// arrancar si no. Fallar en el segundo cero con un mensaje claro es
// infinitamente mejor que arrancar y devolver 500 en la primera consulta
// que toque una columna que todavía no existe.
current, dirty, err := storage.MigrationVersion(ctx, db)
if err != nil {
	log.Fatalf("no se pudo leer la versión del esquema: %v", err)
}
if dirty {
	log.Fatalf("la base está en estado 'dirty' en la versión %d: "+
		"reviso el esquema a mano y uso 'migrate force' antes de arrancar", current)
}
if current != storage.ExpectedSchemaVersion {
	log.Fatalf("el esquema está en la versión %d y este binario espera la %d: "+
		"corre las migraciones antes de desplegar", current, storage.ExpectedSchemaVersion)
}
```

### 5.5 El pipeline

```yaml
# .github/workflows/ci.yml
#
# 📝 LAS DOS EDADES (D23). Las acciones son de HOY porque los runners
# actuales rechazan las versiones de 2022. El código que ejecutan es de
# 2022, y por eso corre dentro de container: golang:1.19. No es una
# inconsistencia: es lo que pasa cuando se revive un repositorio dormido, y
# se declara en vez de esconderse.
#
# ⚠️ Verifica las versiones de las acciones antes de usar este archivo: se
# actualizan varias veces al año y las viejas se retiran.

name: CI
on:
  push: { branches: [master] }
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    container: golang:1.19        # el Go de 2022, dentro de un runner de hoy
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_USER: rifas
          POSTGRES_PASSWORD: rifas
          POSTGRES_DB: rifas_test
        options: >-
          --health-cmd pg_isready --health-interval 5s --health-retries 10
    env:
      # "postgres" y no "localhost": dentro de un container, los servicios se
      # resuelven por nombre. Es el error clásico de esta configuración.
      TEST_DATABASE_URL: postgres://rifas:rifas@postgres:5432/rifas_test?sslmode=disable

    steps:
      - uses: actions/checkout@v4

      - name: Migraciones sobre la base de pruebas
        run: |
          go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@v4.15.2
          migrate -path server/migrations/postgres -database "$TEST_DATABASE_URL" up

      # Los cinco niveles de be08, en orden de costo creciente: lo barato
      # primero, para que un error tonto no gaste tres minutos de runner.
      - run: make -C server test-unit
      - run: make -C server test-integration
      - run: make -C server test-contract
      - run: make -C server test-race

      # LA REGLA DEL MOTOR, EJECUTADA. Este paso es la razón de que el
      # pipeline exista tal como está: verifica que la suite corre contra
      # PostgreSQL, que es el motor de verdad (D18). Si alguien agrega una
      # prueba de concurrencia sin MustPostgres, acá revienta.
      - run: make -C server test-engine-rule

  image:
    needs: test
    runs-on: ubuntu-latest
    permissions: { contents: read, packages: write }
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          context: ./server
          push: ${{ github.event_name == 'push' }}
          # El sha y no "latest": una etiqueta móvil hace que "¿qué hay
          # desplegado?" no tenga respuesta. Cada imagen apunta a un commit.
          tags: ghcr.io/${{ github.repository }}/raffles-api:${{ github.sha }}
```

### 5.6 El veredicto honesto

Es el entregable final del track y va en `server/VEREDICTO.md`. Escríbelo tú, con
tu experiencia; lo que sigue es la estructura y las respuestas que este track
defiende.

**Qué quedó mejor que el mock.** Vender dos veces el mismo número pasó de ser
posible a ser **imposible de representar**. La identidad dejó de ser una
afirmación del cliente. El reloj dejó de ser el del usuario. El dinero se
recalcula desde los hechos y una liquidación que no cuadra no llega a existir. El
`X-Request-Id` recorre el sistema entero, desde la consola del navegador hasta la
consulta SQL con su tiempo. Y una ruta que el frontend llamaba al vacío desde la
Fase 6 —`C-01`— por fin responde.

**Qué quedó peor, y hay que decirlo.** Levantar el entorno pasó de `npm run
mock:api` a un contenedor de Postgres, unas migraciones y una siembra. El ciclo de
retroalimentación es más lento: donde antes editabas un JSON y recargabas, ahora
compilas y a veces migras. Hay dos motores que mantener y un DDL duplicado. El
caos hubo que reimplementarlo. Y el track costó **84 horas** que no estaban en el
presupuesto de las 96.

**Qué deudas siguen vivas.** Sin *refresh token*: el JWT vence y el usuario cae al
login (`be04`). El frontend sigue pintándose con el reloj del navegador, aunque el
servidor ya publique el suyo (`be06`). Las ventas migradas no tienen autoría real
y no se puede reconstruir (`be05`). `sales` es inmutable por convención y no por
permisos (`be07`). No hay autorización a nivel de objeto: cualquier usuario puede
todo (`be04`). Los *workers* corren en todas las réplicas. Y `GET /stats` sigue
sin existir.

Y algo que vale la pena notar sobre las dos primeras: **no son descuidos, son la
misma decisión**. Las dos se pagarían tocando el frontend, y el track eligió no
hacerlo. Decidir no pagar una deuda y escribir por qué es una forma perfectamente
respetable de administrarla — muy superior a pagarla a escondidas.

**Cuándo NO vale la pena reemplazar un mock por un backend propio.** Esta es la
parte que hay que responder con la mano en el corazón:

*Cuando el mock cumple.* Si el sistema no tiene concurrencia sobre recursos
únicos, ni dinero, ni reglas que dependan del reloj, ni identidad que proteger,
un mock puede ser suficiente durante años. Este dominio tenía las cuatro. La
mayoría no tiene ninguna.

*Cuando no hay quién lo mantenga.* Un backend propio en Go contra Postgres es un
sistema que alguien tiene que operar, migrar, monitorear y actualizar. Si el
equipo son tres personas de frontend, acabas de crearles un segundo trabajo.

*Cuando lo único que faltaba era persistencia.* Si el problema era "necesitamos
guardar datos de verdad" y no "necesitamos garantías", un servicio gestionado
resuelve eso en una tarde. Escribir un backend para tener una base de datos es
una respuesta cara a una pregunta barata.

*Cuando el proyecto tiene fecha de caducidad.* Ochenta y cuatro horas en un
sistema que se apaga en seis meses son ochenta y cuatro horas.

*Y cuando no puedes tocar al cliente y el contrato es un desastre.* Acá el
contrato era feo pero coherente. Si el frontend dependiera de rarezas
irreproducibles, honrarlo costaría más que el backend entero, y la conversación
correcta sería sobre migrar al cliente, no sobre reemplazar al servidor.

> 🧠 **Y el criterio que resume el track:** reemplazar un mock por un backend
> propio vale la pena cuando lo que necesitas son **garantías** que solo el
> servidor puede dar. Si lo que necesitas son datos, hay caminos más baratos.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. `COPY . .` antes de `go mod download`.** Síntoma: cada construcción tarda lo
mismo que la primera. Causa: cualquier cambio en el código invalida la capa de
dependencias. Fix: el orden de 5.2.

**2. La imagen vacía sin zonas horarias.** Síntoma: `unknown time zone
America/Bogota` solo dentro del contenedor. Causa: `distroless/static` y `scratch`
no traen `/usr/share/zoneinfo`. Fix: `import _ "time/tzdata"`.

**3. `localhost` dentro de un contenedor.** Síntoma: `connection refused` contra
la base, en compose y en CI. Causa: `localhost` es el propio contenedor. Fix: el
nombre del servicio (`db`, `postgres`).

**4. `depends_on` sin `condition`.** Síntoma: falla al levantar, y una de cada
tres veces funciona. Causa: `depends_on` a secas espera a que el contenedor
exista, no a que el servicio esté listo. Fix: `healthcheck` más
`condition: service_healthy`.

**5. Publicar `latest`.** Síntoma: nadie puede responder qué versión está
desplegada. Causa: una etiqueta móvil. Fix: etiquetar por `sha`.

**6. Secretos en el `compose` o en la imagen.** Síntoma: ninguno, hasta que lo
hay. Causa: comodidad. Fix: variables de entorno inyectadas y secretos del
repositorio. Y recuerda que **una capa de imagen conserva lo que borraste en la
capa siguiente**: un secreto copiado y luego eliminado sigue en el historial de
la imagen.

### 🩻 Pieza forense de esta fase

**Compila en mi máquina y no en el runner.**

*Paso 1 — provoca el clásico de cgo.* Vuelve a poner el `import` del driver de
SQLite en un archivo **sin** etiqueta de compilación y construye la imagen sobre
Alpine:

```dockerfile
FROM golang:1.19-alpine AS builder
RUN CGO_ENABLED=1 go build -o /out/api ./cmd/api   # sin gcc en la imagen
```

Falla, y falla con un mensaje que no menciona a cgo por ninguna parte. Anótalo.
Instala `gcc musl-dev`, vuelve a construir sobre Alpine, y ejecuta ese binario en
`debian`. Ahora el error es el mejor de todos: `no such file or directory` sobre
un binario que existe, que puedes ver, y que tiene permisos de ejecución. **El
archivo que no existe es la `libc` que el binario espera.** Confírmalo con `file`
y con `ldd`, y escribe la explicación.

*Paso 2 — la arquitectura.* Si trabajas en un Mac con Apple Silicon, construye
sin especificar plataforma y ejecuta la imagen en el runner (o simula con
`docker run --platform linux/amd64`). El error de formato ejecutable es el otro
clásico. Arréglalo con `--platform` y anota cuánto más tarda una construcción
emulada.

*Paso 3 — la zona horaria que solo falla en el contenedor.* Quita
`_ "time/tzdata"`, construye, y llama desde dentro del contenedor a algo que use
`time.LoadLocation`. Falla ahí y solo ahí. Este es el hermano exacto de lo que
`A3` cuenta sobre "en mi máquina anda", y `be06` es quien lo hace posible.

*Paso 4 — el smoke test contra el contenedor.* Levanta todo con compose y corre
el mismo `server/smoke.sh` de `be00`, sin modificar una línea:

```bash
docker compose up -d
BASE_URL=http://localhost:3001 ./server/smoke.sh
```

Que ese guion —escrito en la primera fase del track contra `json-server`— pase
sin cambios contra una imagen construida en la última, **es el cierre del
círculo**. El contrato sobrevivió a un cambio de lenguaje, de almacenamiento, de
modelo de datos y de empaquetado.

*Paso 5 — el círculo completo, por última vez.* Con todo en contenedores, abre la
aplicación en `localhost:3000`, haz una venta, copia el `X-Request-Id` de la
consola, y búscalo en `docker compose logs api`. Ahí está: la petición, la
consulta SQL, el tiempo, y el usuario que la hizo.

En `be00` ese id no llegaba a ninguna parte. Ese recorrido —consola del navegador
→ log de un contenedor → consulta SQL— es exactamente lo que el track prometió en
su primera página, y es la mejor forma de terminarlo.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–7)**

1. Construye la imagen y comprueba que responde `GET /health`.
2. Verifica con `docker images` cuánto pesa la imagen final.
3. Levanta el compose completo y comprueba que la aplicación React funciona contra él sin cambiar nada.
4. Corre `./server/smoke.sh` contra el contenedor y confirma que pasa entero.
5. Comprueba que el binario de producción es estático (`file` y `ldd`).
6. Arranca el API sin haber corrido las migraciones y comprueba que se niega, diciendo qué versión falta.
7. Verifica que el contenedor no corre como root.

**🟡 Intermedio (8–18)**

8. Implementa la etiqueta de compilación de 5.1 y comprueba que `go build ./cmd/api` ya no necesita cgo.
9. **Diagnóstico.** Pon mal la línea `//go:build` (pegada al `package`) y comprueba que el binario sigue arrastrando cgo. Explica por qué el error es silencioso.
10. Completa la tabla de medición de `D19` con tus tres escenarios.
11. **Diagnóstico.** Ejecuta el paso 1 de la pieza forense hasta el `no such file or directory` y explícalo con `ldd`.
12. **Diagnóstico.** Ejecuta el paso 3 (zonas horarias) y determina qué código exacto del backend fallaría por eso.
13. Invierte el orden de `COPY` en el Dockerfile y mide la diferencia de tiempo entre dos construcciones consecutivas.
14. Escribe las variables de los cuatro ambientes como archivos `.env` de ejemplo, sin secretos reales.
15. **Diagnóstico.** Quita el `healthcheck` del compose y levanta diez veces. Cuenta cuántas fallan.
16. Haz que el pipeline corra en tu repositorio y que los cinco niveles pasen.
17. **Diagnóstico.** Cambia `postgres` por `localhost` en `TEST_DATABASE_URL` del workflow y lee el error. Explica la diferencia entre correr en el runner y correr en un container.
18. Publica la imagen etiquetada por `sha` y comprueba que aparece en el registro.

**🟠 Difícil (19–26)**

19. **Diagnóstico.** Ejecuta el paso 2 (arquitectura) y documenta el error de formato ejecutable, con el tiempo de una construcción emulada frente a una nativa.
20. Escribe `server/evidence/imagen.md` con la medición completa y la decisión de `D19` justificada con tus números. Si tus números contradicen la conclusión de 5.3, defiende la tuya.
21. Implementa `cmd/migrate` y la comprobación de versión del arranque, incluido el caso `dirty`.
22. **Diagnóstico.** Deja la base en estado `dirty` a propósito y comprueba que el API se niega a arrancar con un mensaje accionable. Escribe el runbook de salida.
23. Agrega al pipeline un paso que falle si el binario de producción resulta enlazado dinámicamente. Es la forma de que la decisión de `D19` no se deshaga sola dentro de seis meses.
24. Saca el caos del binario de producción con una etiqueta de compilación, de modo que `POST /_chaos` **no exista** salvo que se compile con `-tags chaos`. Comprueba que el laboratorio sigue funcionando.
25. **Diagnóstico.** Añade `govulncheck` al pipeline (el mecanismo del ejercicio 29 de `be04`) y anota qué reporta hoy sobre tu `go.mod`.
26. Mide el pipeline completo y decide qué correría en cada *pull request* y qué solo en `master`. Justifica con los tiempos.

**🔴 Muy difícil (27–30)**

27. **El veredicto honesto.** Escribe `server/VEREDICTO.md` completo con la estructura de 5.6. No copies las respuestas del track: son las de quien lo escribió. Las tuyas tienen que salir de tus 84 horas, y la sección de "cuándo NO vale la pena" tiene que incluir al menos un caso que acá no esté.
28. Diseña la estrategia de despliegue sin interrupción para este sistema: cómo conviven dos versiones del binario contra un solo esquema, qué clase de migración es segura y cuál no, y qué papel juega el apagado ordenado de `be01`. Escríbelo como plan operativo.
29. **Diagnóstico + regresión.** Ticket: *"la imagen de ayer no arranca en producción y la de anteayer sí, y el código no cambió"*. Enumera las cinco causas candidatas ordenadas por probabilidad —incluyendo las que no están en tu código—, di cómo descartas cada una, y escribe el control que lo habría atrapado.
30. **Post-mortem del track.** Escribe el post-mortem del track BE completo, tratándolo como un proyecto entregado: qué salió mejor de lo esperado, qué salió peor, qué decisión tomarías distinta con lo que sabes ahora, y qué se llevó de aquí que sirve fuera de este dominio. Sin culpabilización, incluida hacia ti.

**🔥 Opcionales**

- 🔥 **`GET /stats`**, el pendiente que el track viene arrastrando desde `be00`. Implementa las agregaciones del dashboard de la Fase 9 en SQL y mide contra veinte mil ventas. Ningún cliente lo consume: es un ejercicio de agregación para quien terminó el curso entero, y ninguna fase depende de él.
- 🔥 Construye la imagen para `linux/amd64` y `linux/arm64` con `buildx` y publica un manifiesto múltiple. Mide cuánto tarda cada una.
- 🔥 Agrega un `HEALTHCHECK` al Dockerfile y decide, con lo que `be02` cerró en `D26`, si debe apuntar a `/health` o a una ruta de *liveness* separada. Implementa la que falte.

---

## 📚 8. Referencias

**Documentación oficial**
- https://docs.docker.com/build/building/multi-stage/ — el patrón de 5.2.
- https://docs.docker.com/compose/compose-file/05-services/#depends_on — `condition` y por qué hace falta.
- https://github.com/GoogleContainerTools/distroless — qué traen y qué no las imágenes mínimas.
- https://pkg.go.dev/time/tzdata — el import de una línea del error común 2.
- https://pkg.go.dev/cmd/go#hdr-Build_constraints — la sintaxis exacta de `//go:build`, incluida la regla de la línea en blanco.
- https://docs.github.com/en/actions/using-jobs/running-jobs-in-a-container y https://docs.github.com/en/actions/using-containerized-services — `container` y `services`, que son `D23` hecho YAML.
- https://go.dev/doc/go1.18#go-generics — no por los genéricos, sino porque en esa página está el contexto de qué había y qué no en el Go de esta época.

**Libros**
- *Continuous Delivery* (Humble y Farley) — "construye el binario una sola vez y promociónalo entre ambientes" es §4.3 en su forma original.
- *The Docker Book* o cualquier referencia actual de Docker — verifica la edición: esta es el área del curso que más rápido envejece.

**Video / apoyo**
- Busca "multi-stage docker build Go" y "distroless images explained". Y para la pieza forense, cualquier charla sobre "static vs dynamic linking cgo" aclara el paso 1 mejor que un texto.

**Orden de lectura sugerido:** la página de multi-stage primero, que es corta →
`build constraints` antes de escribir la etiqueta de 5.1, porque la regla de la
línea en blanco es exactamente el ejercicio 9 → `be-a-02` para la receta completa
con sus tres errores clásicos → y la documentación de Actions cuando el pipeline
no arranque.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos, y acá más que
> en ninguna otra fase — las versiones de las acciones de GitHub se retiran varias
> veces al año y el YAML de 5.5 va a envejecer antes que el resto del curso. Las
> referencias a libros son de memoria y pueden ser inexactas. Cualquier
> discrepancia de versiones la resuelve `prompts/decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre del track

Se acabó. Diez fases, 84 horas, y un backend en Go contra PostgreSQL 13 que
reemplazó a `json-server` sin que la aplicación React cambiara **un solo archivo**
—salvo el que la Fase 2 había señalado con el dedo dos años antes—.

Lo que te llevas no es Go. Go es el vehículo, y en dos años puede ser otro. Lo que
te llevas es esto:

Puedes tomar un contrato de API existente, **medirlo** en vez de adivinarlo, y
reimplementarlo sin romper a quien lo consume. Sabes en qué capa vive de verdad
cada bug de concurrencia, y por qué el frontend nunca fue el lugar para
arreglarlo. Sabes qué prueba puede correr contra SQLite y cuál te estaría
engañando. Puedes seguir un `X-Request-Id` desde la consola del navegador hasta la
consulta SQL que lo produjo. Y sabes decir, con argumentos y con números, cuándo
reemplazar un mock por un backend propio **no** valía la pena.

Y hay una cosa más, que es la que el track base no podía darte. Volviste a mirar
los mismos bugs desde el otro lado del cable y descubriste que **la mitad de los
que parecían del frontend no lo eran**. La venta duplicada de la Fase 5. La hora
de cierre de la Fase 7. El centavo que no cuadra de la Fase 8. Los tres se veían
desde el navegador y ninguno se resolvía ahí.

Esa es la tesis del track, y ahora la tienes demostrada con tus propias manos.

> **La señal de que quedó bien:** *"apagué el mock, levanté mi binario, y la única
> forma de notar el cambio fue que el bug de la venta doble dejó de pasar."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be09-empaquetado-ambientes-y-pipeline -m "be09 cerrada: \
> Dockerfile multi-stage con binario estático y distroless; D19 medida y decidida; \
> compose con migraciones como paso previo y comprobación de versión al arrancar; \
> configuración de los cuatro ambientes; pipeline que prueba contra los dos motores y publica por sha; \
> smoke.sh de be00 pasando contra el contenedor; server/VEREDICTO.md escrito"
> ```
>
> Y el tag que cierra el track entero:
> `git tag -a track-be-completo -m "🔥 Track BE terminado: 10 fases, 84 horas, frontend intacto"`.
>
> Los commits de la fase llevan su prefijo (`be09: …`) y los de ejercicio su
> número (`be09 ej27: …`). Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **Registrar en `prompts/decisiones-y-versiones.md` §7** el cierre de `D19`, que
  llevaba siete fases abierta: **no se cambia de driver, se etiqueta la
  compilación**. El binario de producción va sin cgo y `mattn/go-sqlite3` queda
  detrás de `-tags sqlite` para pruebas. `modernc.org/sqlite` se mide y se
  descarta. Y anotar el giro: la pregunta de `D19` estaba mal planteada.
- **Registrar también el tag de hito `track-be-completo`**, junto con
  `mock-retirado` de `be03`, en `00-convencion-de-git-y-tags.md` como los dos
  únicos tags del track que no siguen el patrón `fase-…`.
- **El YAML de 5.5 es la parte del curso que más rápido envejece.** Conviene
  revisarlo en cada revisión editorial y verificar las versiones de las acciones
  contra su documentación. El texto ya lo advierte al alumno, pero la
  advertencia no arregla el archivo.
- **`be-a-02` tiene que ser autosuficiente.** Esta fase muestra el Dockerfile y
  el compose y remite ahí para la receta cerrada con sus tres errores clásicos.
  El apéndice no puede limitarse a repetir: le corresponde el detalle operativo
  —volúmenes, redes, puertos ocupados, limpieza— que acá no cabe.
- **`be-a-09` (mapa de deuda del track BE) recibe la lista completa** del §5.6, y
  debería ordenarla por lo que `A12` usa como criterio: qué la vuelve exigible.
  Las dos deudas que el track decide **no** pagar —*refresh token* y reloj del
  cliente— merecen tratamiento propio, porque su causa es la misma regla del
  track y no un descuido.
- **El `GET /stats` queda como pendiente 🔥 y así debe quedarse.** Ninguna fase
  depende de él y el `smoke.sh` no lo exige. Está en el ejercicio opcional con la
  pregunta honesta de si merece la pena construir algo sin consumidor.
- **Reserva para el cuaderno de incidentes:** `be-16` — *"la imagen de ayer no
  arranca y el código no cambió"* (categoría 🔥 despliegue, dificultad 🟠), el
  ejercicio 29. **Con esto se completa el rango `be-01`–`be-16`** que se amplió al
  escribir `be04`. Si se redactan los enunciados, conviene revisar que los
  dieciséis cubran las cuatro categorías propias del track —base de datos,
  transacciones, despliegue y contrato— de forma equilibrada; hoy contrato y
  transacciones están mejor servidas que despliegue.
- **Cierre editorial del track:** las diez fases están escritas. Faltan los diez
  apéndices `be-a-01`–`be-a-10`, y conviene escribirlos en orden de dependencia
  —`be-a-01` (Go) y `be-a-02` (imagen) son los que más fases citan— antes que los
  temáticos.
FIN_DEL_ARCHIVO
wc -l be09-empaquetado-ambientes-y-pipeline.md; ls be0*.md | wc -l

# --- 2026-09-09T03:23:40 · Close D19 in decisions file
cd prompts && python3 - <<'PY'
import io
p='decisiones-y-versiones.md'
s=io.open(p,encoding='utf-8').read()

# Cerrar D19 con una nota de resolución
old="""**Qué la vuelve revisable.** Que la fricción de cgo consuma más tiempo del que
enseña. Si pasa, se adopta `modernc.org/sqlite` y la comparación se conserva
como ejercicio."""
new="""**Qué la vuelve revisable.** Que la fricción de cgo consuma más tiempo del que
enseña. Si pasa, se adopta `modernc.org/sqlite` y la comparación se conserva
como ejercicio.

✅ **Cerrada en `be09`, y con un giro.** La pregunta estaba mal planteada: no era
*qué driver de SQLite*, sino *por qué el binario de producción tiene un driver de
SQLite*. SQLite solo se usa en pruebas. La resolución es **etiquetar la
compilación** —el `import` del driver vive en un archivo `//go:build sqlite`—, de
modo que producción compila con `CGO_ENABLED=0`, estático y sin cgo, y las
pruebas conservan `mattn/go-sqlite3`, que es más rápido en ejecución que
`modernc`. No se cambia de driver. La medición de los tres escenarios queda en
`server/evidence/imagen.md`."""
assert s.count(old)==1
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))
print('ok')
PY
cd .. && wc -l be0*.md | tail -1

# --- 2026-09-09T03:26:30 · Read appendix prompts be-a-01 and be-a-02
cd prompts && sed -n '1,120p' prompts-backend-apendice.md

# --- 2026-09-09T03:26:40 · Check A9 content to avoid contradiction
cd .. && grep -n "^#\|^##\|Dockerfile\|docker\|compose" A9-entornos-y-contenedores.md | head -30

# --- 2026-09-09T03:29:01 · 
cat > be-a-01-go-para-quien-no-escribe-go.md <<'FIN_DEL_ARCHIVO'
# 🐹 Apéndice be-a-01 — Go para quien no escribe Go

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~4 horas
> Lo referencian: `be01` y todas las fases siguientes

---

Este apéndice **no es un tour por Go**. Es la lista de cosas que Go hace distinto
de lo que ya sabes, ordenadas por dónde aparecen en el código del track, para que
puedas abrirlo cuando una línea te frene y volver a la fase en cinco minutos.

Damos por sabidos funciones, tipos, punteros como concepto, HTTP y concurrencia
como idea. Lo que se explica es **por qué Go tomó decisiones distintas** y qué
consecuencias tienen en el código que estás escribiendo. Si algo no aparece en el
backend de rifas, no está acá — por interesante que sea.

> 🧭 **Regla de época (`D14`).** El código del track es Go **1.19**, de agosto de
> 2022. Sin `log/slog`, sin `errors.Join`, sin los patrones de método de
> `http.ServeMux`, sin genéricos. Todo eso existe hoy y aparece marcado 🔥 en la
> §11 como comparación, igual que React 18 en el track base.

---

## 🧭 Índice de salto rápido

1. [Paquetes, módulos y el directorio `internal/`](#1-paquetes-módulos-y-el-directorio-internal)
2. [Errores como valores, y el envoltorio con `%w`](#2-errores-como-valores-y-el-envoltorio-con-w)
3. [Interfaces implícitas, y dónde se declaran](#3-interfaces-implícitas-y-dónde-se-declaran)
4. [Punteros, receptores y el `nil` que es contrato](#4-punteros-receptores-y-el-nil-que-es-contrato)
5. [Structs, etiquetas y campos exportados](#5-structs-etiquetas-y-campos-exportados)
6. [`defer`, `panic` y `recover`](#6-defer-panic-y-recover)
7. [`context.Context`](#7-contextcontext)
8. [Goroutines, canales y `sync`](#8-goroutines-canales-y-sync)
9. [Slices y maps: el `nil` que rompe el frontend](#9-slices-y-maps-el-nil-que-rompe-el-frontend)
10. [El tooling mínimo](#10-el-tooling-mínimo)
11. [🔥 Lo moderno que no usamos](#11--lo-moderno-que-no-usamos)
12. [🧩 Cuándo usar qué](#-cuándo-usar-qué)

---

## 1. Paquetes, módulos y el directorio `internal/`

Un **módulo** es la unidad de versionado y se declara en `go.mod` con una ruta
que parece una URL. Un **paquete** es un directorio; todos los archivos de ese
directorio comparten espacio de nombres y se ven entre sí sin importarse.

Tres cosas que sorprenden viniendo de otros lenguajes:

**La visibilidad la decide la mayúscula.** `Raffle` es exportado, `sqlStore` no.
No hay `public` ni `private`, y no hay nada intermedio. La consecuencia práctica
es que la unidad de encapsulamiento es el **paquete**, no el tipo: dentro de un
paquete todo se ve todo.

**`internal/` es una regla del compilador.** Nada fuera del módulo puede importar
un paquete que esté bajo un directorio `internal/`. Es encapsulamiento a nivel de
proyecto, gratis y verificado. Por eso el backend vive en `server/internal/…` y
solo `cmd/api` lo cablea.

**El nombre del paquete no tiene por qué ser el del directorio.** El track usa
esto una vez y a propósito: el directorio es `internal/http/` —lo fija el
diccionario— y el paquete se llama `httpapi`, porque un paquete llamado `http`
que importa `net/http` obliga a poner alias en cada archivo.

```go
// server/internal/raffle/store.go
package raffle   // el paquete se llama por lo que ES, no por lo que hace:
                 // "raffle", no "raffles", no "raffleservice", no "utils"
```

> ⚠️ **El import por efecto secundario.** Cuando veas `_ "github.com/lib/pq"`, el
> guion bajo significa "impórtalo aunque no use ningún identificador suyo": lo
> único que queremos es que corra su `init()`, que registra el driver en
> `database/sql`. Es el patrón más raro de Go para quien llega de fuera, y es
> idiomático.

---

## 2. Errores como valores, y el envoltorio con `%w`

No hay excepciones. Una función que puede fallar devuelve `(resultado, error)` y
quien la llama decide en la línea siguiente. Vas a escribir `if err != nil`
cientos de veces y no hay forma de negociarlo.

Lo que se gana: **ninguna ruta de fallo es invisible**. En el frontend del track
base, una promesa rechazada sin `.catch()` desaparece; acá, un error que no
manejas es una variable que el compilador te obliga a nombrar.

### Envolver, no aplastar

```go
if err := tx.InsertSale(ctx, raffleID, number, participantID, soldBy); err != nil {
    return fmt.Errorf("registrando la venta del número %s: %w", number, err)
}
```

El **`%w`** envuelve el error original en vez de convertirlo a texto. Con `%v` el
mensaje se ve igual y pierdes la capacidad de preguntar qué era en el fondo.
Envolver con contexto en cada capa es lo que reemplaza al stack trace que traías
—y suele ser mejor, porque el contexto lo escribiste tú y dice algo útil.

### Preguntar qué era

```go
// errors.Is compara contra un error CONCRETO, atravesando los envoltorios.
if errors.Is(err, sql.ErrNoRows) { … }

// errors.As extrae un error de un TIPO concreto. Así es como be05 pregunta
// si la base rechazó un duplicado.
var pqErr *pq.Error
if errors.As(err, &pqErr) && pqErr.Code == "23505" { … }
```

### Errores centinela de dominio

El track los usa en todas las capas y son la frontera entre ellas:

```go
var (
    ErrNotFound     = errors.New("la rifa no existe")
    ErrAlreadySold  = errors.New("ese número ya fue vendido")
    ErrRaffleClosed = errors.New("la rifa ya cerró")
)
```

📖 **El patrón del track, en una línea:** el store traduce errores de
infraestructura a errores de dominio, y el handler traduce errores de dominio a
códigos HTTP. Si un `sql.ErrNoRows` llega al handler, una capa se rompió.

---

## 3. Interfaces implícitas, y dónde se declaran

No existe `implements`. Un tipo satisface una interfaz por **tener sus métodos**,
y puede haberse escrito años antes que la interfaz, en otro paquete, sin
conocerla.

Eso invierte una convención que probablemente traes:

> 🧭 **Las interfaces se declaran del lado del consumidor, no del proveedor.** El
> paquete que necesita guardar rifas declara `Store` con los métodos que usa; el
> paquete que habla con Postgres no sabe que esa interfaz existe.

```go
// server/internal/raffle/raffle.go — la declara QUIEN LA USA
type Store interface {
    List(ctx context.Context) ([]Raffle, error)
    FindByID(ctx context.Context, id int64) (Raffle, error)
}
```

Dos consecuencias prácticas que vas a aprovechar:

**Las interfaces pequeñas son mejores.** La comunidad tiene un dicho —*"cuanto
más grande la interfaz, más débil la abstracción"*— y no es estética: una
interfaz de dos métodos la satisface cualquier cosa, incluido un doble de prueba
de cuatro líneas. Una de veinte métodos no la satisface nada.

**Los dobles de prueba no necesitan librería.** `be08` sustituye un servicio con
un struct de tres líneas. No hay framework de *mocks* en este track y no hace
falta.

```go
type stubNumberService struct{ err error }
func (s stubNumberService) SellNumber(context.Context, int64, string, *int64) (RaffleNumber, error) {
    return RaffleNumber{}, s.err
}
```

Y la interfaz que sostiene todo `net/http`, que es la más importante del track:

```go
type Handler interface { ServeHTTP(ResponseWriter, *Request) }
```

Un middleware, entonces, **no es un concepto del framework**: es una función que
recibe un `Handler` y devuelve otro. Toda la cadena de `be01` son cinco funciones
de esa forma, compuestas.

---

## 4. Punteros, receptores y el `nil` que es contrato

### Valor o puntero: la regla práctica

Un método puede tener receptor por valor (`func (c fixedClock) Now()`) o por
puntero (`func (c *ChaosController) SetLevel(…)`). La regla que funciona el 95 %
de las veces:

- **Puntero** si el método muta el receptor, o si el struct es grande, o si
  cualquier otro método del tipo ya usa puntero.
- **Valor** si el tipo es pequeño e inmutable.

**Sé consistente dentro de un tipo.** Mezclar receptores por valor y por puntero
en el mismo tipo es una fuente de confusión y de sorpresas con las interfaces:
solo `*T` satisface una interfaz cuyos métodos tengan receptor por puntero.

### El puntero que es una decisión de contrato

Este es el uso más importante en el track, y no tiene que ver con eficiencia:

```go
ParticipantID *int64 `json:"participantId" db:"participant_id"`
```

Un `int64` pelado no puede distinguir "no hay participante" de "el participante
es el cero". Un puntero sí: `nil` serializa a `null`, que es exactamente lo que
el contrato de `be00` exige. La alternativa obvia —`sql.NullInt64`— serializa a
`{"Int64":0,"Valid":false}` y **rompe el frontend en silencio**. Es la pieza
forense de `be03`.

📖 **Cuando el dominio distingue "ausente" de "cero", el tipo también tiene que
distinguirlo.** Vale para `*int64`, para `*time.Time` y para el
`*jwt.NumericDate` que `be04` se encuentra al migrar a la v4 de la librería.

---

## 5. Structs, etiquetas y campos exportados

```go
type Raffle struct {
	ID          int64     `json:"id"           db:"id"`
	ClosesAt    time.Time `json:"closesAt"     db:"closes_at"`
	NumberPrice int64     `json:"numberPrice"  db:"number_price"`
}
```

Las cadenas entre acentos graves son **etiquetas**: metadatos que las librerías
leen por reflexión. `json:` lo usa `encoding/json`; `db:` lo usa `sqlx`. Acá
conviven las tres convenciones de nombres del sistema —`PascalCase` en Go,
`camelCase` en el contrato, `snake_case` en SQL— en una sola línea y en un solo
lugar. Esa es la costura, y está concentrada a propósito.

> ⚠️ **Solo se serializan los campos exportados.** Un campo en minúscula **no
> aparece en el JSON**: sin error, sin aviso, sin nada. El síntoma es un objeto
> al que le falta justo el campo que importa, y cuesta cinco minutos encontrarlo
> la primera vez.

`json:"-"` omite un campo a propósito. El track lo usa para el `id` de
`raffle_numbers`, que existe en la tabla y no estaba en el `db.json`: mantener la
respuesta idéntica a la del mock es lo que hace verificable el reemplazo.

---

## 6. `defer`, `panic` y `recover`

**`defer`** registra una función para que corra al salir de la función actual,
**pase lo que pase**: con `return`, con error o con pánico. Es el `finally` de
Go, y es la única forma de que `recover()` llegue a ejecutarse.

Los `defer` se apilan y corren en orden inverso. Los argumentos se evalúan **en
el momento del `defer`**, no al ejecutarse — que es la sorpresa clásica.

```go
defer tx.Rollback()  // un Rollback después de un Commit exitoso es un no-op:
                     // por eso este patrón es seguro y es idiomático
```

**`panic`** aborta la ejecución y desenrolla la pila corriendo los `defer`. Y
acá está la diferencia cultural que `be01` convierte en pieza forense:

> 🧠 En Node, un `throw` dentro de un handler de Express lo atrapa el framework y
> solo muere esa petición. En Go, **un `panic` que nadie recupera tumba el
> proceso entero**: todo el servidor, todas las conexiones de todos los usuarios.
> `gorilla/mux` no trae recuperación incorporada. El middleware es tuyo y es
> obligatorio.

```go
defer func() {
	if rec := recover(); rec != nil {
		log.Printf("PÁNICO: %v", rec)
		writeError(w, http.StatusInternalServerError, "Error interno del servidor")
	}
}()
```

📖 **Cuándo usar `panic`:** en el arranque, cuando el programa no puede funcionar
(configuración inválida, dependencia ausente) — y ahí normalmente es
`log.Fatalf`. **Nunca** como mecanismo de control de flujo dentro de una
petición.

---

## 7. `context.Context`

Es el primer parámetro de todo lo que cruce una frontera —handler, service,
store— y hace dos trabajos.

**Cancelación.** Cuando el cliente cierra la pestaña, `r.Context()` se cancela;
si tu consulta recibió ese contexto, Postgres la cancela en vez de gastar CPU por
un resultado que nadie va a leer. Es el `takeUntil` de la Fase 6, del lado del
servidor. `be01` lo usa incluso para simular el timeout del caos: `<-r.Context().Done()`
se queda quieto hasta que el cliente se cansa.

**Transportar valores de alcance de petición.** El `X-Request-Id` de `be01` y el
`userID` de `be04` viajan por acá.

```go
type ctxKey int
const requestIDKey ctxKey = iota   // tipo propio: nadie fuera del paquete
                                   // puede construir esta clave, así que la
                                   // colisión entre paquetes es imposible

func RequestIDFrom(ctx context.Context) string {
	if id, ok := ctx.Value(requestIDKey).(string); ok { return id }
	return ""
}
```

> 🧭 **La regla de los valores en el contexto:** solo para datos que atraviesan
> capas **sin ser parte de la lógica**. El request id, la identidad. Nunca
> parámetros de negocio disfrazados: si el service necesita el `raffleID`, va en
> la firma.

Y el patrón que aparece en todo el track:

```go
ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
defer cancel()   // SIEMPRE. Sin esto se filtra un temporizador y una goroutine.
                 // `go vet` lo detecta.
```

---

## 8. Goroutines, canales y `sync`

Solo hasta donde el track lo necesita, que es menos de lo que la fama de Go
sugiere.

**Una goroutine no es un hilo.** Arranca con unos pocos KB de pila y el runtime
multiplexa miles sobre unos pocos hilos del sistema. Por eso `net/http` atiende
cada petición en la suya y por eso **bloquear no es pecado**: el `time.Sleep` del
caos de `be01` bloquea esa goroutine, no el servidor.

```go
go func() { … }()   // y ahora nadie sabe cuándo termina, salvo que lo coordines
```

**Coordinar la espera: `sync.WaitGroup`.** Lo que usa la prueba de concurrencia
de `be05` y `be08`, con un detalle que decide si la prueba sirve:

```go
var start sync.WaitGroup   // barrera de salida: todos esperan el disparo
start.Add(1)
var wg sync.WaitGroup      // espera de finalización

for i := 0; i < contenders; i++ {
	wg.Add(1)
	go func(i int) {       // el índice se pasa como PARÁMETRO: capturar la
		defer wg.Done()    // variable del bucle es el bug clásico de Go < 1.22
		start.Wait()
		errs[i] = sell(…)
	}(i)
}
start.Done()   // ¡ya!
wg.Wait()
```

Sin la barrera, las goroutines se lanzan escalonadas, la carrera nunca ocurre, y
**la prueba pasa contra el código vulnerable**.

**Proteger estado compartido: `sync.RWMutex`.** El `ChaosController` de `be01` lo
leen miles de peticiones y lo escribe un `POST /_chaos` muy de vez en cuando.
`RWMutex` permite lecturas simultáneas entre sí y serializa las escrituras.

**Canales y `select`.** El track los usa para una sola cosa: los *workers* de
`be05` y `be06`, con la forma que los hace apagables.

```go
for {
	select {
	case <-ctx.Done():        // el apagado ordenado de be01 llega hasta acá
		return
	case <-ticker.C:
		hacerElTrabajo()
	}
}
```

📖 Un worker que no sabe morir convierte un `Shutdown` limpio en un proceso
zombi. Todo lo que arranques con `go` tiene que tener una forma de terminar.

---

## 9. Slices y maps: el `nil` que rompe el frontend

Un slice declarado y no inicializado es `nil`, y **`json.Marshal(nil)` produce
`null`**, no `[]`.

```go
var raffles []Raffle      // → "null"  ❌ rompe el .map() del componente
raffles := []Raffle{}     // → "[]"    ✅ contrato de be00
```

Es literalmente una línea de diferencia y es el error común nº 2 de `be02`. Un
`nil` se puede recorrer, se le puede hacer `append` y tiene `len` cero: se
comporta como vacío en todo **menos al serializarse**, que es justo donde
importa.

Un `map` nil, en cambio, **explota al escribir**. Se inicializa con
`make(map[K]V)` o con un literal.

---

## 10. El tooling mínimo

```bash
go build ./...          # compila todo. En Go, SILENCIO ES ÉXITO
go run ./cmd/api        # compila y ejecuta
go test ./...           # corre las pruebas (archivos *_test.go)
go test -race ./...     # detecta carreras de datos en memoria
go test -count=1 ./...  # sin caché — imprescindible en integración (be08)
go test -shuffle=on     # desordena, y desenmascara pruebas dependientes del orden
go vet ./...            # errores probables que compilan: cancel sin usar,
                        # Printf mal formado, bloqueos copiados
go mod tidy             # agrega lo que falta y quita lo que sobra del go.mod
gofmt -l .              # el formato NO se discute en Go: hay uno solo
go list -m all          # el árbol de dependencias
go build -tags sqlite   # compila con etiquetas (be09)
```

Dos convenciones que conviene saber antes de que te confundan: los archivos
`*_test.go` **no entran en el binario**, y un archivo puede declarar el paquete
`raffle` o `raffle_test` — la segunda forma solo ve la API exportada, que es
buena disciplina para las pruebas de contrato.

---

## 11. 🔥 Lo moderno que no usamos

Todo esto existe hoy, el track no lo usa por `D14`, y conviene que lo reconozcas
cuando lo veas en un ejemplo de internet — porque la mitad de lo que encuentres
buscando "Go http server" lo va a usar.

| Qué | Desde | Qué hace el track en su lugar |
|---|---|---|
| Genéricos | 1.18 | Tipos concretos, o `interface{}` en `writeJSON` |
| `log/slog` | 1.21 | `log.Printf` con el id delante (`be01`) |
| `errors.Join` | 1.20 | Un error a la vez, envuelto con `%w` |
| Patrones en `http.ServeMux` | 1.22 | `gorilla/mux` (`D15`) |
| `for` con variable por iteración | 1.22 | Pasar el índice como parámetro (§8) |
| `time.Now()` sembrado al azar en `math/rand` | 1.20 | El caos es reproducible entre arranques (`be01`) |

Los dos últimos merecen atención porque **cambian el comportamiento del código
que escribiste** si algún día actualizas el toolchain: la captura de la variable
del bucle y el sembrado de `math/rand` son exactamente el tipo de detalle que
hace aparecer un test intermitente en una actualización que "no tocaba nada".

---

## 🧩 Cuándo usar qué

| Si necesitas… | Usa | Y no |
|---|---|---|
| Señalar un fallo esperable | `return err` envuelto con `%w` | `panic` |
| Preguntar qué error es | `errors.Is` / `errors.As` | comparar el texto |
| Que el proceso no muera por un bug | `recover` en un middleware | confiar en el router |
| Distinguir ausente de cero | un puntero (`*int64`) | `sql.NullInt64` |
| Un doble de prueba | un struct con los métodos | una librería de *mocks* |
| Devolver una lista vacía | `[]T{}` | `var s []T` |
| Estado compartido entre goroutines | `sync.RWMutex` | esperar que no colisione |
| Que un worker se apague | `select` con `<-ctx.Done()` | un `for` infinito |
| Liberar lo que abriste | `defer` en la línea siguiente | acordarte al final |
| Cancelar trabajo que ya no importa | pasar el `ctx` hasta la consulta | ignorarlo |

---

## 🧪 Ejercicios (8)

1. **🟢** Escribe una función que devuelva `(int64, error)`, envuelve su error con `%w` desde quien la llama, y recupera el error original con `errors.Is`.
2. **🟢** Serializa un struct con un campo en minúscula y comprueba que desaparece del JSON sin ningún aviso.
3. **🟡** Toma `RaffleNumber` y cambia `ParticipantID` de `*int64` a `sql.NullInt64`. Serializa y compara los dos JSON. Explica qué le pasaría al tablero de la Fase 5.
4. **🟡** Escribe una interfaz de un método, satisfácela con dos tipos distintos —uno real y uno de prueba— y comprueba que el compilador no necesita que declares nada.
5. **🟠 Diagnóstico.** Escribe un bucle que lance cinco goroutines capturando la variable del bucle en vez de pasarla como parámetro. Compila con Go 1.19 y observa el resultado. Explica por qué Go 1.22 lo cambió y qué significa eso para un código viejo que se actualiza.
6. **🟠 Diagnóstico.** Escribe un `context.WithTimeout` sin `defer cancel()` y encuéntralo con `go vet`. Explica qué se filtra exactamente.
7. **🟠** Escribe un worker con `select` sobre `ctx.Done()` y un `time.Ticker`, y demuestra que se detiene cuando el contexto se cancela. Después quita el `case` del contexto y demuestra que el proceso ya no termina.
8. **🔴 Diagnóstico.** Escribe un struct compartido por goroutines sin candado, hazlo fallar con `go test -race`, y transcribe el informe explicando qué significa cada bloque. Después arréglalo con `sync.RWMutex` y comprueba que el informe desaparece.

---

## 📚 Referencias

**Documentación oficial**
- https://go.dev/tour/ — el tour oficial. Para este perfil, los capítulos de métodos e interfaces y el de concurrencia bastan; el resto lo puedes saltar.
- https://go.dev/doc/effective_go — sigue siendo la mejor guía de idiomática, aunque partes hayan envejecido.
- https://go.dev/blog/error-handling-and-go y https://go.dev/blog/go1.13-errors — §2 completa.
- https://go.dev/blog/defer-panic-and-recover — §6, y la pieza forense de `be01`.
- https://go.dev/blog/context — §7, mejor explicado que en la referencia del paquete.
- https://go.dev/blog/slices-intro — §9, incluido el asunto del `nil`.
- https://go.dev/doc/effective_go#interfaces y https://go.dev/doc/faq#implements_interface — por qué las interfaces son implícitas, contado por quienes lo decidieron.
- https://go.dev/wiki/CodeReviewComments — la lista de lo que se comenta en una revisión de código Go. Media hora, y te ahorra media docena de correcciones.

**Libros**
- *The Go Programming Language* (Donovan y Kernighan) — es de 2015 y sigue siendo el mejor texto sobre interfaces y concurrencia. No cubre módulos ni genéricos.
- *Let's Go* (Alex Edwards) — construye un servidor web con la biblioteca estándar, con el mismo enfoque de middlewares compuestos del track. Verifica la edición: se actualiza con cada versión de Go.

**Video / apoyo**
- Busca "Go concurrency patterns Rob Pike" y "Go proverbs". Son charlas viejas y siguen siendo exactas: la parte del lenguaje que tocan casi no ha cambiado.

**Orden de lectura sugerido:** las secciones 2, 3 y 6 de este apéndice antes de
`be01` → el blog de `defer, panic and recover` cuando llegues a su pieza forense
→ la §8 completa antes de `be05` → y `CodeReviewComments` cuando el código ya te
resulte cómodo.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros y videos son de memoria y pueden ser inexactas. **Casi
> todo el material bueno de Go en la web asume la versión más reciente**: cuando
> algo no compile con `go 1.19`, revisa la §11 antes de dudar de tu código, y
> recuerda que la fuente de verdad de versiones es
> `prompts/decisiones-y-versiones.md` §7.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura: no deja código en el
> repositorio del alumno. Los ejercicios que decidas guardar van como commits de
> la fase desde la que los hiciste (`be01 ej05: …`), según
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
FIN_DEL_ARCHIVO
wc -l be-a-01-go-para-quien-no-escribe-go.md

# --- 2026-09-09T03:30:58 · 
cat > be-a-02-receta-de-imagen-y-compose.md <<'FIN_DEL_ARCHIVO'
# 🐳 Apéndice be-a-02 — Receta de imagen y compose

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~3 horas
> Lo referencian: `be02` (Postgres en contenedor), `be03` y `be09`

---

Esto es **la receta**. Vienes a copiar algo que funcione, no a estudiar
contenedores: no hay teoría de imágenes, ni capítulo sobre capas, ni comparación
de runtimes. Hay dos archivos que puedes pegar, los comandos para levantarlos y
tumbarlos, y los cuatro errores que salen **siempre**, con su mensaje literal.

> 🧭 **Autocontención.** Todo lo que necesitas está acá. Este apéndice no remite
> a ningún otro curso del catálogo, exista o no uno de contenedores. Si algo no
> funciona siguiendo estos pasos, es un fallo de esta receta y hay que
> arreglarlo acá.

Lo único que damos por instalado es un runtime de Docker con `docker compose`. El
apéndice `A9` del track base ya cubre cómo tenerlo en cada sistema —incluido
Colima en Apple Silicon, que es la opción por defecto ahí— y esa parte no se
repite. Los comandos de abajo son idénticos con Colima o con Docker Desktop.

> 📝 **Relación con `A9`.** El `docker-compose.yml` de `A9` levanta el
> **frontend** (Node 14 y el mock del `3001`). El de acá levanta el **backend**
> (Go y Postgres). A partir de `be03` conviven: apagas el servicio `mock` de
> `A9` y levantas el `api` de acá, en el mismo puerto `3001`. Ese es el 🪦.

---

## 🧭 Índice de salto rápido

1. [Lo mínimo: solo Postgres](#1-lo-mínimo-solo-postgres)
2. [El `Dockerfile`, en sus dos versiones](#2-el-dockerfile-en-sus-dos-versiones)
3. [El `docker-compose.yml` completo](#3-el-docker-composeyml-completo)
4. [Variables por ambiente](#4-variables-por-ambiente)
5. [Comandos: arrancar, parar, resetear](#5-comandos-arrancar-parar-resetear)
6. [Los cuatro errores que salen siempre](#6-los-cuatro-errores-que-salen-siempre)
7. [🧩 Cuándo usar qué](#-cuándo-usar-qué)

---

## 1. Lo mínimo: solo Postgres

Durante `be02` no hace falta contenerizar el backend: lo corres con `go run` y
solo necesitas una base. Este es el comando, y es el que usarás durante seis
fases:

```bash
docker run -d --name rifas-pg \
  -e POSTGRES_USER=rifas \
  -e POSTGRES_PASSWORD=rifas \
  -e POSTGRES_DB=rifas \
  -p 5432:5432 \
  postgres:13

export DATABASE_URL="postgres://rifas:rifas@localhost:5432/rifas?sslmode=disable"
psql "$DATABASE_URL" -c 'select version();'
```

> ⚠️ **Si el `5432` ya está ocupado** —porque tienes un Postgres instalado en el
> sistema—, publica en otro puerto y ajusta la URL. Nada más cambia: la
> configuración por variables de entorno lo cubre entero.
>
> ```bash
> docker run -d --name rifas-pg … -p 5433:5432 postgres:13
> export DATABASE_URL="postgres://rifas:rifas@localhost:5433/rifas?sslmode=disable"
> ```
>
> El `-p 5433:5432` mapea **el puerto de tu máquina** al del contenedor: adentro
> Postgres sigue en el 5432, siempre.

Y la base de **pruebas**, que desde `be08` es un contenedor aparte:

```bash
docker run -d --name rifas-pg-test \
  -e POSTGRES_USER=rifas -e POSTGRES_PASSWORD=rifas -e POSTGRES_DB=rifas_test \
  -p 5434:5432 postgres:13

export TEST_DATABASE_URL="postgres://rifas:rifas@localhost:5434/rifas_test?sslmode=disable"
```

📖 **Dos contenedores y dos puertos es más barato que un susto.** La suite de
`be08` hace `TRUNCATE` antes de cada caso; apuntada a la base de desarrollo borra
seis fases de trabajo. Por eso el *helper* de `be08` se niega a correr si la URL
no menciona `rifas_test`.

---

## 2. El `Dockerfile`, en sus dos versiones

Y acá hay que explicar algo antes de copiar, porque **la receta cambia en
`be09`** y el motivo es contenido del curso.

Mientras el `import` del driver de SQLite esté en un archivo normal, **todo el
binario arrastra cgo** —aunque SQLite solo se use en pruebas— y un binario con
cgo enlaza contra la `libc` del sistema donde se compiló. En `be09` eso se
resuelve con una etiqueta de compilación y el binario pasa a ser estático.

| Versión | Cuándo | Runtime | Por qué |
|---|---|---|---|
| **A — con cgo** | `be02`–`be08` | `debian:bullseye-slim` | El binario necesita `glibc` |
| **B — estática** | desde `be09` | `distroless/static` | No necesita nada |

### Versión A — con cgo (`be02` a `be08`)

```dockerfile
# server/Dockerfile
# ---------- etapa 1: compilar ----------
FROM golang:1.19-bullseye AS builder
WORKDIR /src

# Las dependencias en su propia capa: cambian mucho menos que el código, así
# que Docker reutiliza esta capa en casi todas las construcciones. Copiar
# todo de una vez invalida la caché con cada edición y cada build tarda lo
# mismo que la primera.
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# CGO_ENABLED=1 porque mattn/go-sqlite3 lo exige (D19). golang:1.19-bullseye
# ya trae gcc, así que no hay nada más que instalar.
RUN CGO_ENABLED=1 GOOS=linux go build -o /out/api ./cmd/api
RUN CGO_ENABLED=1 GOOS=linux go build -o /out/migrate ./cmd/migrate
RUN CGO_ENABLED=1 GOOS=linux go build -o /out/seed ./cmd/seed

# ---------- etapa 2: ejecutar ----------
# 🧭 debian:bullseye-slim y NO Alpine, y esto no es una preferencia.
#
# Alpine usa musl como libc; el builder de arriba es Debian y usa glibc. Un
# binario con cgo compilado contra glibc NO ARRANCA en Alpine, y el error es
# el peor que existe: "no such file or directory" sobre un binario que
# puedes ver, listar y que tiene permisos de ejecución. El archivo que no
# existe es la libc que el binario espera, no el binario.
#
# Se podría compilar sobre Alpine con musl-dev, pero entonces el binario no
# corre en Debian. Mientras haya cgo, builder y runtime tienen que compartir
# libc. Punto.
FROM debian:bullseye-slim

# ca-certificates: sin esto, cualquier llamada HTTPS de salida falla con
# "x509: certificate signed by unknown authority". Hoy el backend no hace
# ninguna, pero cuesta 200 KB y evita una tarde perdida.
# tzdata: las zonas horarias que be06 necesita.
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates tzdata \
 && rm -rf /var/lib/apt/lists/*

# Usuario sin privilegios. Cuesta dos líneas y es lo mínimo exigible.
RUN useradd --uid 10001 --create-home rifas
USER rifas

COPY --from=builder /out/api /usr/local/bin/api
COPY --from=builder /out/migrate /usr/local/bin/migrate
COPY --from=builder /out/seed /usr/local/bin/seed
COPY --from=builder /src/migrations /migrations

EXPOSE 3001
ENTRYPOINT ["/usr/local/bin/api"]
```

### Versión B — estática (desde `be09`)

Cuando `be09` mete el driver de SQLite detrás de `//go:build sqlite`, el binario
de producción ya no necesita cgo y el runtime puede ser una imagen prácticamente
vacía:

```dockerfile
FROM golang:1.19-bullseye AS builder
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .

# Sin cgo → binario estático. -ldflags "-s -w" quita símbolos e información
# de depuración: unos megas menos, a cambio de perder los nombres en los
# stack traces del pánico de be01. Es un intercambio real, no gratis.
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags "-s -w" -o /out/api ./cmd/api
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/migrate ./cmd/migrate
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/seed ./cmd/seed

# Sin shell, sin gestor de paquetes, sin libc. ~2 MB, y trae los
# certificados raíz y un usuario nonroot ya definido.
FROM gcr.io/distroless/static-debian11:nonroot
COPY --from=builder /out/api /api
COPY --from=builder /out/migrate /migrate
COPY --from=builder /out/seed /seed
COPY --from=builder /src/migrations /migrations
USER nonroot:nonroot
EXPOSE 3001
ENTRYPOINT ["/api"]
```

> ⚠️ **La versión B necesita `import _ "time/tzdata"` en `main.go`.** Una imagen
> vacía no tiene `/usr/share/zoneinfo`, así que `time.LoadLocation("America/Bogota")`
> devuelve `unknown time zone` **solo dentro del contenedor**. Funciona perfecto
> en tu máquina y falla en el despliegue. El import embebe la base de zonas en el
> binario (unos 450 KB) y existe desde Go 1.15.

Y el archivo que evita construcciones lentas y filtraciones tontas:

```gitignore
# server/.dockerignore
.git
*_test.go
evidence/
*.db
.env
```

---

## 3. El `docker-compose.yml` completo

El laboratorio entero del backend. La aplicación React sigue fuera, en el `3000`,
hablándole al `3001` exactamente como desde `be03`.

```yaml
# server/docker-compose.yml
services:
  db:
    image: postgres:13
    environment:
      POSTGRES_USER: rifas
      POSTGRES_PASSWORD: rifas
      POSTGRES_DB: rifas
    ports: ["5432:5432"]        # cámbialo a "5433:5432" si el 5432 está ocupado
    volumes:
      # Volumen NOMBRADO y no un directorio del proyecto: los datos
      # sobreviven a `down` y no ensucian tu repositorio. Para borrarlos de
      # verdad hace falta `down -v`, que es justo la fricción que quieres
      # antes de destruir una base.
      - rifas-pgdata:/var/lib/postgresql/data
    healthcheck:
      # Sin esto, migrate arranca contra un Postgres que todavía se está
      # inicializando y falla. `depends_on` a secas solo espera a que el
      # CONTENEDOR exista, no a que el servicio esté listo: es el error nº 4.
      test: ["CMD-SHELL", "pg_isready -U rifas -d rifas"]
      interval: 2s
      timeout: 3s
      retries: 15

  migrate:
    build: .
    entrypoint: ["/usr/local/bin/migrate", "up"]   # "/migrate" en la versión B
    environment:
      DATABASE_URL: postgres://rifas:rifas@db:5432/rifas?sslmode=disable
    depends_on:
      db: { condition: service_healthy }
    restart: "no"                # corre una vez y termina; no es un servicio

  api:
    build: .
    ports: ["3001:3001"]
    environment:
      # "db" y NO "localhost": dentro de un contenedor, localhost es el
      # propio contenedor. Los servicios se resuelven por su nombre.
      DATABASE_URL: postgres://rifas:rifas@db:5432/rifas?sslmode=disable
      ALLOWED_ORIGIN: http://localhost:3000
      JWT_SECRET: laboratorio-no-usar-esto-en-ningun-otro-lado-32
      JWT_TTL: 12h
      CHAOS_LEVEL: "off"
      SQL_DEBUG: "true"
    depends_on:
      # Espera a que las migraciones TERMINEN, no a que arranquen.
      migrate: { condition: service_completed_successfully }

volumes:
  rifas-pgdata:
```

---

## 4. Variables por ambiente

Una sola imagen para todos los ambientes; lo que cambia va por configuración. Una
imagen "de QA" y otra "de producción" significan que lo que probaste no es lo que
desplegaste.

| Variable | Desarrollo | QA | UAT | Producción |
|---|---|---|---|---|
| `DATABASE_URL` | local | de QA | de UAT | de producción |
| `sslmode` | `disable` | `require` | `require` | `require` |
| `ALLOWED_ORIGIN` | `http://localhost:3000` | el de QA | el de UAT | el real |
| `JWT_SECRET` | el del compose | secreto de QA | secreto de UAT | secreto real |
| `JWT_TTL` | `12h` | `12h` | `1h` | `1h` |
| `CHAOS_LEVEL` | `low` | `high` | `off` | `off` ⚠️ |
| `SQL_DEBUG` | `true` | `true` | `false` | `false` |
| `PORT` | `3001` | `3001` | `3001` | `3001` |

En desarrollo, todo eso vive en el `compose`. Para los demás ambientes, un
archivo por ambiente que **no se versiona**:

```bash
# server/.env.uat  (en .gitignore, siempre)
DATABASE_URL=postgres://…?sslmode=require
JWT_SECRET=…
JWT_TTL=1h
CHAOS_LEVEL=off
```

```bash
docker run --env-file .env.uat -p 3001:3001 rifas/raffles-api:<sha>
```

> ⚠️ **`CHAOS_LEVEL=off` no es suficiente para producción.** Una ruta
> `POST /_chaos` en un binario de producción es un endpoint para romper tu propio
> sistema, expuesto a quien lo encuentre. La respuesta correcta es que **ese
> código no esté en el binario**, con una etiqueta de compilación. Es el ejercicio
> 24 de `be09`.
>
> 💸 Y un recordatorio que vale para siempre: **una capa de imagen conserva lo que
> borraste en la capa siguiente**. Un secreto copiado y luego eliminado sigue en
> el historial de la imagen y se puede extraer. Los secretos se inyectan, nunca
> se copian.

---

## 5. Comandos: arrancar, parar, resetear

```bash
cd server

# --- levantar ---
docker compose up -d --build       # construye y levanta en segundo plano
docker compose ps                  # qué está corriendo y con qué salud
docker compose logs -f api         # seguir los logs del backend

# --- verificar que funciona ---
curl -i localhost:3001/health
cd .. && ./server/smoke.sh         # el checklist de be00, sin modificar

# --- sembrar desde TU db.json (be03) ---
docker compose run --rm api /usr/local/bin/seed -file /mock/db.json
# ⚠️ el seed necesita ver el archivo: agrega al servicio api
#    volumes: ["../mock:/mock:ro"]

# --- parar ---
docker compose stop                # para, conserva contenedores y datos
docker compose down                # elimina contenedores, CONSERVA el volumen
docker compose down -v             # elimina TAMBIÉN los datos ⚠️ sin vuelta

# --- resetear la base sin borrar todo ---
docker compose exec db psql -U rifas -d rifas -c \
  'DROP SCHEMA public CASCADE; CREATE SCHEMA public;'
docker compose run --rm migrate

# --- entrar a mirar ---
docker compose exec db psql -U rifas -d rifas
#   \dt          las tablas
#   \d raffles   la definición de una tabla
#   \q           salir

# --- ver el tamaño de lo que construiste (be09) ---
docker images | grep raffles-api
```

---

## 6. Los cuatro errores que salen siempre

### 6.1 `no such file or directory` sobre un binario que existe

```
exec /usr/local/bin/api: no such file or directory
```

**Causa.** Binario con cgo compilado contra `glibc` ejecutándose en Alpine
(`musl`). El archivo que falta es la biblioteca, no el binario.

**Cómo confirmarlo.**

```bash
docker run --rm --entrypoint file <imagen> /usr/local/bin/api
# "dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2" → tiene cgo
# "statically linked"                                          → no lo tiene
```

**Arreglo.** Runtime `debian:bullseye-slim` (versión A), o quitar cgo con la
etiqueta de compilación (versión B). Nunca mezclar builder Debian con runtime
Alpine mientras haya cgo.

### 6.2 `connection refused` contra la base

```
la base no responde (postgres): dial tcp 127.0.0.1:5432: connect: connection refused
```

**Causa.** `localhost` dentro de un contenedor **es ese contenedor**. Postgres
está en otro.

**Arreglo.** El nombre del servicio: `postgres://rifas:rifas@db:5432/rifas`. La
misma URL con `localhost` es la correcta cuando corres el backend con `go run`
fuera de Docker — y por eso el error aparece justo al contenerizar algo que
funcionaba.

### 6.3 La base no está lista todavía

```
error: dial tcp 172.18.0.2:5432: connect: connection refused
# …y a la segunda vez funciona
```

**Causa.** `depends_on` sin `condition` solo espera a que el contenedor **exista**.
Postgres tarda unos segundos en inicializarse la primera vez, así que el fallo es
intermitente — el peor tipo.

**Arreglo.** El `healthcheck` del §3 más `condition: service_healthy`. Compruébalo
levantando diez veces seguidas con `down -v` en medio.

### 6.4 `exec format error`

```
exec /api: exec format error
```

**Causa.** Arquitectura equivocada: imagen construida para `arm64` (un Mac con
Apple Silicon) ejecutándose en `amd64`, o al revés.

**Arreglo.** Fijar la plataforma al construir:

```bash
docker build --platform linux/amd64 -t rifas/raffles-api .
```

Y prepárate: construir emulado tarda bastante más. Si vas a hacerlo seguido, mide
cuánto y decide si prefieres construir nativo y publicar un manifiesto múltiple
(ejercicio 🔥 de `be09`).

### Bonus — `unknown time zone America/Bogota`

Solo con la versión B, y solo dentro del contenedor. Falta `import _ "time/tzdata"`
en `main.go`. Ver §2.

---

## 🧩 Cuándo usar qué

| Si estás en… | Levanta | Con |
|---|---|---|
| `be02` (capa de datos) | solo Postgres | `docker run` del §1 |
| `be03`–`be08` (desarrollo) | Postgres + `go run` del backend | §1 y `go run ./cmd/api` |
| `be08` (pruebas) | un Postgres **aparte** | el `rifas-pg-test` del §1 |
| `be09` (empaquetado) | todo en contenedores | el `compose` del §3, Dockerfile B |
| Enseñarle el laboratorio a alguien | todo en contenedores | `docker compose up -d --build` |

| Si necesitas… | Usa | Y no |
|---|---|---|
| Parar y seguir mañana | `docker compose stop` | `down -v` |
| Empezar de cero con los datos | `down -v` y volver a sembrar | borrar tablas a mano |
| Runtime con cgo | `debian:bullseye-slim` | Alpine |
| Runtime sin cgo | `distroless/static` | Debian |
| Hablarle a la base desde otro contenedor | el nombre del servicio | `localhost` |
| Esperar a que la base esté lista | `healthcheck` + `condition` | un `sleep` |
| Guardar un secreto | variable de entorno inyectada | `COPY` al Dockerfile |

---

## 🧪 Ejercicios (8)

1. **🟢** Levanta Postgres con `docker run`, conéctate con `psql` y comprueba la versión.
2. **🟢** Construye la imagen (versión A) y comprueba que `GET /health` responde desde el contenedor.
3. **🟡** Levanta el compose completo y comprueba que la aplicación React del `3000` funciona contra él sin cambiar un archivo.
4. **🟡** Ejecuta `./server/smoke.sh` con `BASE_URL` apuntando al contenedor y confirma que pasa entero.
5. **🟠 Diagnóstico.** Cambia el runtime a `alpine:3.17` con la versión A y provoca el error 6.1. Confírmalo con `file` y explica qué biblioteca falta.
6. **🟠 Diagnóstico.** Quita el `healthcheck` y levanta diez veces con `down -v` en medio. Cuenta cuántas fallan y explica por qué el fallo es intermitente.
7. **🟠** Invierte el orden de los `COPY` en el Dockerfile y mide el tiempo de dos construcciones consecutivas con y sin ese cambio.
8. **🔴 Diagnóstico.** Construye la versión B sin `import _ "time/tzdata"`, llama desde dentro del contenedor a algo que use `time.LoadLocation`, y documenta por qué el mismo código funciona fuera. Después arréglalo y verifica.

---

## 📚 Referencias

**Documentación oficial**
- https://docs.docker.com/build/building/multi-stage/ — el patrón del §2.
- https://docs.docker.com/reference/dockerfile/ — la referencia completa de instrucciones.
- https://docs.docker.com/compose/compose-file/05-services/#depends_on — `condition`, que es el error 6.3.
- https://docs.docker.com/compose/compose-file/05-services/#healthcheck — la otra mitad del mismo error.
- https://hub.docker.com/_/postgres — variables de entorno de la imagen de Postgres y qué hace en el primer arranque.
- https://github.com/GoogleContainerTools/distroless — qué traen y qué no las imágenes mínimas de la versión B.
- https://pkg.go.dev/time/tzdata — el import de una línea del bonus del §6.
- https://docs.docker.com/build/building/best-practices/ — el orden de las capas del ejercicio 7.

**Video / apoyo**
- Busca "multi-stage docker build Go" y "static vs dynamic linking cgo". Lo segundo aclara el error 6.1 mejor que cualquier texto.

**Orden de lectura sugerido:** nada, si lo que quieres es levantar el laboratorio
— copia el §1 y sigue con tu fase. Cuando algo falle, salta al §6, que está
ordenado por frecuencia. La página de multi-stage vale la pena solo cuando
llegues a `be09` y quieras entender qué estás copiando.

> ⚠️ **Esta es el área del curso que más rápido envejece.** Las etiquetas de
> imagen se mueven, la sintaxis del `compose` evoluciona y las buenas prácticas
> de Docker cambian cada pocos años. Verifica cada URL y cada etiqueta antes de
> apoyarte en ellas. Las versiones fijas del track —`postgres:13`,
> `golang:1.19`— salen de `prompts/decisiones-y-versiones.md` §7 y esas sí no se
> mueven.

---

> 🏷️ **Este apéndice sí deja código.** El `Dockerfile`, el `.dockerignore` y el
> `docker-compose.yml` viven en `server/`. Cuando los tengas funcionando:
>
> ```bash
> git tag -a apendice-be-a-02-receta-de-imagen-y-compose -m "be-a-02: \
> Dockerfile multi-stage (versión con cgo), .dockerignore y docker-compose.yml \
> con Postgres 13, migraciones como paso previo y healthcheck; \
> smoke.sh pasando contra el contenedor"
> ```
>
> Los commits van con el prefijo de la fase desde la que llegaste (`be02: …`,
> `be09: …`), no con el del apéndice. La convención completa está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
FIN_DEL_ARCHIVO
wc -l be-a-02-receta-de-imagen-y-compose.md

# --- 2026-09-09T03:34:38 · Read prompts for be-a-03 to be-a-05
cd prompts && sed -n '/## Apéndice be-a-03/,/## Apéndice be-a-06/p' prompts-backend-apendice.md | grep -v "^Actúa\|^orden:\|^prompts/\|^00-alcance\|^prompts\|fuentes de verdad" | head -110

# --- 2026-09-09T03:35:18 · Fix partial index claims in be02 and be05
cd .. && python3 - <<'PY'
import io
p='be02-la-costura-de-datos.md'
s=io.open(p,encoding='utf-8').read()
old="""el mínimo común denominador de PostgreSQL 13 y SQLite 3.35 no tiene `TIMESTAMPTZ`,
ni `BIGSERIAL`, ni índices parciales, ni `CHECK` con enumeraciones razonables."""
new="""el mínimo común denominador de PostgreSQL 13 y SQLite 3.35 no tiene `TIMESTAMPTZ`,
ni `BIGSERIAL`, ni `ALTER COLUMN`, ni tipos que se hagan cumplir —las tablas
`STRICT` de SQLite llegaron en la 3.37, después de nuestra cota—."""
assert s.count(old)==1
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))

p='be05-venta-concurrente.md'
s=io.open(p,encoding='utf-8').read()
old="""> 🧠 **Ese índice parcial (`WHERE status = 'reserved'`) merece un segundo.** El
> trabajo que vence reservas solo consulta filas reservadas, que son un puñado
> entre decenas de miles. Un índice parcial ocupa una fracción y se mantiene casi
> gratis. Y es, de paso, una de las cosas que **no existen** en el DDL de SQLite
> — otra entrada para tu inventario de divergencias."""
new="""> 🧠 **Ese índice parcial (`WHERE status = 'reserved'`) merece un segundo.** El
> trabajo que vence reservas solo consulta filas reservadas, que son un puñado
> entre decenas de miles. Un índice parcial ocupa una fracción y se mantiene casi
> gratis.
>
> Y una nota honesta para tu inventario de divergencias: **esta sí porta**.
> SQLite tiene índices parciales desde la 3.8.0, de 2013. No todo diverge, y dar
> por sentado que sí es el otro error —el simétrico— del que esta fase avisa.
> Verifica antes de asumir, en las dos direcciones."""
assert s.count(old)==1
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))
print('ok')
PY

# --- 2026-09-09T03:35:22 · Locate exact wording
grep -n "índices parciales" be02-la-costura-de-datos.md be05-venta-concurrente.md

# --- 2026-09-09T03:35:25 · Check working directory
pwd; ls | head

# --- 2026-09-09T03:35:33 · Fix partial index claims
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs && python3 - <<'PY'
import io
p='be02-la-costura-de-datos.md'
s=io.open(p,encoding='utf-8').read()
old="""el mínimo común denominador de PostgreSQL 13 y SQLite 3.35 no tiene `TIMESTAMPTZ`,
ni `BIGSERIAL`, ni índices parciales, ni `CHECK` con enumeraciones razonables."""
new="""el mínimo común denominador de PostgreSQL 13 y SQLite 3.35 no tiene `TIMESTAMPTZ`,
ni `BIGSERIAL`, ni `ALTER COLUMN`, ni tipos que se hagan cumplir —las tablas
`STRICT` de SQLite llegaron en la 3.37, después de nuestra cota—."""
assert s.count(old)==1, "be02"
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))

p='be05-venta-concurrente.md'
s=io.open(p,encoding='utf-8').read()
old="""> gratis. Y es, de paso, una de las cosas que **no existen** en el DDL de SQLite
> — otra entrada para tu inventario de divergencias."""
new="""> gratis.
>
> Y una nota honesta para tu inventario de divergencias: **esta sí porta**.
> SQLite tiene índices parciales desde la 3.8.0, de 2013. No todo diverge, y dar
> por sentado que sí es el error simétrico del que esta fase avisa: verifica
> antes de asumir, en las dos direcciones."""
assert s.count(old)==1, "be05"
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))
print('ok')
PY

# --- 2026-09-09T03:35:37 · Find the exact lines
grep -n "índices parciales" *.md

# --- 2026-09-09T03:35:42 · Find partial index mentions
grep -n "parcial" be02-la-costura-de-datos.md be05-venta-concurrente.md prompts/decisiones-y-versiones.md

# --- 2026-09-09T03:35:49 · Find partial index mentions with absolute paths
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; grep -n "parcial" $R/be02-la-costura-de-datos.md $R/be05-venta-concurrente.md $R/prompts/decisiones-y-versiones.md

# --- 2026-09-09T03:35:59 · Apply partial index corrections
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; python3 - "$R" <<'PY'
import io,sys
R=sys.argv[1]

p=R+'/be02-la-costura-de-datos.md'
s=io.open(p,encoding='utf-8').read()
old="""`TIMESTAMPTZ`, ni `BIGSERIAL`, ni índices parciales, ni `CHECK` con enumeraciones
razonables."""
new="""`TIMESTAMPTZ`, ni `BIGSERIAL`, ni `ALTER COLUMN`, ni tipos que se hagan cumplir
—las tablas `STRICT` de SQLite llegaron en la 3.37, después de nuestra cota—."""
assert s.count(old)==1, "be02"
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))

p=R+'/be05-venta-concurrente.md'
s=io.open(p,encoding='utf-8').read()
old="""> gratis. Y es, de paso, una de las cosas que **no existen** en el DDL de SQLite
> — otra entrada para tu inventario de divergencias."""
new="""> gratis.
>
> Y una nota honesta para tu inventario de divergencias: **esta sí porta**.
> SQLite tiene índices parciales desde la 3.8.0, de 2013. No todo diverge, y dar
> por sentado que sí es el error simétrico del que esta fase avisa: verifica
> antes de asumir, en las dos direcciones."""
assert s.count(old)==1, "be05"
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))

p=R+'/prompts/decisiones-y-versiones.md'
s=io.open(p,encoding='utf-8').read()
old="tiene `TIMESTAMPTZ`, `BIGSERIAL` ni índices parciales. Escribir el DDL ahí sería"
new="tiene `TIMESTAMPTZ`, `BIGSERIAL` ni tipos que se hagan cumplir (las tablas\n`STRICT` de SQLite son de la 3.37). Escribir el DDL ahí sería"
assert s.count(old)==1, "D25"
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))
print('ok')
PY

# --- 2026-09-09T03:37:42 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs && cat > be-a-03-sql-portable-y-dialectos.md <<'FIN_DEL_ARCHIVO'
# 🗃️ Apéndice be-a-03 — SQL portable y dialectos

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~3 horas
> Lo referencian: `be02` principalmente; `be05`, `be06` y `be08` lo consultan

---

Este es el diccionario de divergencias entre **PostgreSQL 13** y **SQLite 3.35**,
para abrir cuando algo no funciona igual en los dos motores. Cada entrada tiene la
misma forma: qué hace cada uno, cómo se ve cuando falla, y **qué hacer**.

La tesis que sostiene el apéndice es la misma de `be02` y no se va a suavizar:

> 🧭 **La agnosia total de base de datos no existe.** Lo que existe es
> **portabilidad por disciplina**: una costura donde el dialecto se hace
> explícito, en vez de esconderse detrás de una abstracción que promete lo que no
> puede cumplir. Un ORM no resuelve esto: lo tapa justo donde necesitas verlo.

Y una advertencia simétrica, que es el error que casi nadie comete y por eso
duele más: **no todo diverge**. Dar por sentada una diferencia que no existe
produce código feo por miedo. Verifica en las dos direcciones.

---

## 🧭 Índice de salto rápido

1. [Placeholders: `?` contra `$1`](#1-placeholders--contra-1)
2. [Identidades autoincrementales](#2-identidades-autoincrementales)
3. [`RETURNING` y `LastInsertId`](#3-returning-y-lastinsertid)
4. [Fechas: el tipo que SQLite no tiene](#4-fechas-el-tipo-que-sqlite-no-tiene)
5. [Booleanos](#5-booleanos)
6. [Números, dinero y la afinidad de tipos](#6-números-dinero-y-la-afinidad-de-tipos)
7. [Bloqueo: `FOR UPDATE` no existe](#7-bloqueo-for-update-no-existe)
8. [Concurrencia de escritura y `SQLITE_BUSY`](#8-concurrencia-de-escritura-y-sqlite_busy)
9. [Claves foráneas apagadas por defecto](#9-claves-foráneas-apagadas-por-defecto)
10. [DDL: `ALTER TABLE` y qué obliga a decidir](#10-ddl-alter-table-y-qué-obliga-a-decidir)
11. [Lo que sí porta](#11-lo-que-sí-porta)
12. [🧩 Cuándo usar qué: la regla del motor](#-cuándo-usar-qué-la-regla-del-motor)

---

## 1. Placeholders: `?` contra `$1`

| PostgreSQL | SQLite |
|---|---|
| `WHERE id = $1 AND status = $2` | `WHERE id = ? AND status = ?` |

**Cómo se ve cuando falla.** `pq: syntax error at or near "?"`, o
`near "$1": syntax error`. Es la divergencia más inofensiva porque revienta en
la primera ejecución.

**Qué hacer.** Escribir siempre con `?` y pasar por `sqlx.Rebind`:

```go
query := s.db.Rebind(`SELECT id FROM raffles WHERE status = ? AND closes_at > ?`)
```

📖 **La regla operativa del track:** si un archivo de store contiene un `$1`
literal, está mal. Es un `grep` que vale la pena tener en la revisión de código.

> ⚠️ Y el límite de `Rebind`, que hay que tener presente todo el tiempo: resuelve
> **la sintaxis de los placeholders y nada más**. No traduce tipos, ni funciones
> de fecha, ni semántica de bloqueo, ni `RETURNING`, ni `ON CONFLICT`. Creer que
> un `Rebind` te dio portabilidad es exactamente el mito que este apéndice
> desmonta.

---

## 2. Identidades autoincrementales

| PostgreSQL | SQLite |
|---|---|
| `id BIGSERIAL PRIMARY KEY` | `id INTEGER PRIMARY KEY AUTOINCREMENT` |
| Una **secuencia** independiente de la tabla | El `rowid` interno de la tabla |

En Postgres, `BIGSERIAL` crea una secuencia aparte. Eso tiene una consecuencia
que muerde en cuanto siembras datos con ids explícitos: **insertar el id 1 a mano
no mueve la secuencia**, así que el siguiente `INSERT` automático intenta usar el
1 y choca.

**Cómo se ve cuando falla.**
`duplicate key value violates unique constraint "raffles_pkey"` justo después de
una siembra que funcionó perfecto. Es el error común nº 1 de `be03`.

**Qué hacer.** Reajustar la secuencia después de sembrar:

```sql
SELECT setval(pg_get_serial_sequence('raffles','id'),
              COALESCE((SELECT MAX(id) FROM raffles), 1));
```

En SQLite no hace falta: el `rowid` se calcula sobre el máximo existente.

> 📝 `BIGSERIAL` es la forma clásica; `GENERATED ALWAYS AS IDENTITY` es la del
> estándar y existe desde Postgres 10. El track usa `BIGSERIAL` porque es lo que
> había en la mayoría de los esquemas de 2022, y porque su rareza con `setval` es
> contenido: la vas a encontrar en cualquier base heredada.

---

## 3. `RETURNING` y `LastInsertId`

Esta es **la divergencia que más caro sale**, porque falla en la dirección
peligrosa.

| | PostgreSQL (`lib/pq`) | SQLite (`mattn/go-sqlite3`) |
|---|---|---|
| `RETURNING` | Siempre | Desde **3.35** (marzo 2021) |
| `res.LastInsertId()` | **No implementado** | Funciona |

`lib/pq` devuelve `LastInsertId is not supported by this driver`. No es un bug del
driver: el protocolo de Postgres sencillamente no ofrece ese dato.

**Por qué es la peor.** El código escrito con `LastInsertId` **pasa las pruebas
contra SQLite y falla en producción contra Postgres**. La suite no detecta el
bug: la suite lo autoriza. Es la Prueba A del par contradictorio de `be08`.

**Qué hacer.** `RETURNING` siempre, en los dos motores:

```go
query := s.db.Rebind(`
    INSERT INTO raffles (name, status) VALUES (?, ?)
    RETURNING id, name, status`)
var created Raffle
err := s.db.GetContext(ctx, &created, query, r.Name, r.Status)
```

> 🧭 Y acá está el porqué de una decisión que parecía arbitraria: `D18` fija
> **SQLite 3.35 o superior**, y 3.35 no es un número redondo. Es marzo de 2021,
> cuando llegó `RETURNING`. Comprueba la tuya con `select sqlite_version();`.

---

## 4. Fechas: el tipo que SQLite no tiene

| PostgreSQL | SQLite |
|---|---|
| `TIMESTAMPTZ` (instante), `TIMESTAMP`, `DATE`, `INTERVAL` | **Ninguno.** `TEXT`, `INTEGER` o `REAL` |
| `now()` | `datetime('now')` |
| Comparación entre **instantes** | Comparación entre **cadenas** |

SQLite no tiene tipo de fecha. Guarda texto, y comparar texto es comparación
lexicográfica. Con formato ISO 8601 y **todo en el mismo huso** funciona por
accidente. Con husos mezclados, no.

**El caso que hay que tener grabado** (Divergencia 2 de `be02`, Prueba B de
`be08`):

```sql
-- closes_at = '2026-08-30T22:00:00-05:00', que es el 31 a las 03:00 UTC
SELECT name FROM raffles WHERE closes_at > '2026-08-31T01:00:00Z';
```

- **Postgres:** compara instantes. 03:00Z > 01:00Z → **devuelve la rifa**.
- **SQLite:** compara `'2026-08-30…'` con `'2026-08-31…'`, ve que `30 < 31` →
  **no devuelve nada**.

Los dos motores funcionan correctamente según su propia especificación, y tu
regla de negocio da resultados **opuestos**.

**Qué hacer.**

- La expresión de "ahora" sale de la costura, nunca escrita a mano:
  `db.Now()` devuelve `now()` o `datetime('now')` según el dialecto.
- **Nunca literales de fecha en el SQL.** Los instantes se pasan como
  `time.Time` por placeholder; el driver los serializa.
- Y la conclusión que `be08` convierte en regla: **cualquier prueba que dependa
  de comparar instantes corre contra Postgres o no vale.**

---

## 5. Booleanos

| PostgreSQL | SQLite |
|---|---|
| Tipo `BOOLEAN` real: `true` / `false` | `INTEGER` con `0` / `1` |

SQLite acepta las palabras `TRUE` y `FALSE` desde la 3.23 como alias de `1` y
`0`, así que el DDL y las consultas suelen portar sin cambios. Lo que **no**
porta es lo que sale por el cable: Postgres devuelve un booleano, SQLite un
entero.

**Qué hacer.** Declarar el campo Go como `bool` y dejar que el driver convierta —
lo hacen los dos. El problema aparece solo si escaneas a `interface{}` o comparas
el valor crudo. No lo hagas.

---

## 6. Números, dinero y la afinidad de tipos

Y acá está la divergencia más **inquietante** de la lista, porque no falla: mira
para otro lado.

```sql
INSERT INTO raffles (name, lottery_id, closes_at, number_price, base_prize, status)
VALUES ('Rifa de prueba', 'boyaca', '2026-08-30T22:00:00-05:00', 'mucha plata', 0, 'open');
```

- **Postgres:** `invalid input syntax for type bigint: "mucha plata"`. Rechaza.
- **SQLite:** **la acepta y guarda el texto** en una columna `INTEGER`.

Es la **afinidad de tipos**: en SQLite el tipo es una sugerencia sobre la columna,
no una restricción sobre el valor. Prueba después `SELECT sum(number_price)` en
cada motor y mira qué devuelve cada uno. Una de las dos bases acaba de mentir
sobre cuánto dinero hay.

**Qué hacer.**

- Validar en el código, porque el motor de pruebas no te va a avisar.
- Dinero en `BIGINT` de centavos a los dos lados (`A10`, `be07`). Un `INTEGER` de
  32 bits se agota a los ~21 millones de pesos.
- Y saber que **las tablas `STRICT`** —que sí hacen cumplir los tipos— llegaron
  en SQLite **3.37**, después de la cota de `D18`. No están disponibles acá.

---

## 7. Bloqueo: `FOR UPDATE` no existe

| PostgreSQL | SQLite |
|---|---|
| `SELECT … FOR UPDATE`, `FOR SHARE`, `SKIP LOCKED`, `NOWAIT` | **Nada de eso** |
| Bloqueo a nivel de **fila** | Bloqueo a nivel de **archivo** |

```
near "FOR": syntax error
```

No hay emulación posible y no hay que intentarla. SQLite no bloquea filas porque
no tiene concurrencia de escritura que administrar (§8): serializa la base
entera.

**Qué hacer.** Nada, salvo aceptarlo y sacar la conclusión: **la concurrencia no
se puede probar contra SQLite**. Ni siquiera mal. Es el remate de la pieza
forense de `be05` y una de las cuatro áreas de la regla del motor. El detalle
completo de `FOR UPDATE` y sus variantes está en `be-a-05`.

---

## 8. Concurrencia de escritura y `SQLITE_BUSY`

SQLite admite **un escritor a la vez** sobre la base completa. Con el modo por
defecto (*rollback journal*), un escritor bloquea también a los lectores; con
`journal_mode=WAL` los lectores no se bloquean, pero el escritor único sigue
siendo único.

```
database is locked
```

**Qué hacer.**

- En pruebas, DSN con `_busy_timeout=5000`: el que llega segundo espera en vez de
  fallar al instante.
- `SetMaxOpenConns(1)` contra SQLite. Un pool de 25 conexiones contra un archivo
  no da paralelismo: da `SQLITE_BUSY`.
- Y otra vez la conclusión: veinte vendedores compitiendo por una fila en
  Postgres producen un ganador y diecinueve `409` en milisegundos; los mismos
  veinte contra SQLite compiten por **el archivo** y el resultado depende del
  `busy_timeout`.

---

## 9. Claves foráneas apagadas por defecto

En SQLite, `PRAGMA foreign_keys` está **en `OFF`** por defecto, y es **por
conexión**, no por base. Las `REFERENCES` de tu DDL son decorativas hasta que
alguien las encienda.

**Cómo se ve cuando falla.** No falla: eso es lo malo. Insertas un
`raffle_numbers` con un `raffle_id` inexistente y SQLite lo acepta sin chistar.
La prueba pasa, el modelo está roto, y en Postgres reventaría.

**Qué hacer.** Ponerlo en el DSN, siempre:

```
file::memory:?cache=shared&_foreign_keys=on&_busy_timeout=5000
```

Y un ejercicio que conviene hacer una vez: quítalo y cuenta cuántas de tus
pruebas siguen pasando. Ese número dice bastante sobre tu suite.

---

## 10. DDL: `ALTER TABLE` y qué obliga a decidir

| Operación | PostgreSQL | SQLite |
|---|---|---|
| `ADD COLUMN` | Sí | Sí, con restricciones |
| `RENAME COLUMN` | Sí | Desde 3.25 |
| `DROP COLUMN` | Sí | Desde 3.35, y no siempre |
| `ALTER COLUMN … TYPE` | Sí | **No** |
| Restricción añadida a posteriori | Sí | **No** |

En SQLite, lo que no se puede alterar se resuelve con el baile clásico: crear
tabla nueva, copiar, borrar la vieja, renombrar. Es tedioso y es lo que hay.

**La decisión que esto obliga a tomar**, y que `D25` cerró en `be02`:

> 🧭 **DDL por dialecto, no subconjunto común.** El mínimo común denominador de
> Postgres 13 y SQLite 3.35 no tiene `TIMESTAMPTZ`, ni `BIGSERIAL`, ni
> `ALTER COLUMN`, ni tipos que se hagan cumplir. Escribir el esquema ahí
> significa **degradar el motor real para complacer al motor de pruebas**.

El costo —que los dos juegos de migraciones diverjan— se administra con la regla
del motor y con las pruebas que corren contra los dos, no con buenas intenciones.
Pero se paga **a la vista**, que es la diferencia con esconderlo.

---

## 11. Lo que sí porta

La lista corta, para que no escribas código feo por miedo:

- **Índices parciales** (`CREATE INDEX … WHERE`). SQLite los tiene desde la
  **3.8.0, de 2013**. El índice de reservas vencidas de `be05` porta tal cual.
- **`CHECK`**, incluidas las enumeraciones por `IN (…)`.
- **`UNIQUE`** compuesto, que es la última línea de defensa de `be05`.
- **`ON CONFLICT DO NOTHING` / `DO UPDATE`.** SQLite lo tiene desde la 3.24, con
  sintaxis compatible para los casos del track.
- **Transacciones, `BEGIN`/`COMMIT`/`ROLLBACK` y savepoints.**
- **Índices por expresión**, subconsultas, CTEs y funciones de ventana.
- **`RIGHT`/`FULL OUTER JOIN`**… ojo, **este no**: llegó a SQLite en la 3.39, y
  `D18` fija 3.35. Ese es el tipo de detalle que hay que verificar y no suponer.

📖 **La moraleja de esta sección.** El inventario de divergencias se hace
**midiendo**, no de memoria ni de un blog. La mitad de lo que "todo el mundo
sabe" que no porta, porta desde hace diez años.

---

## 🧩 Cuándo usar qué: la regla del motor

> 🧭 **SQLite vale para pruebas que no tocan concurrencia, bloqueos, zonas
> horarias ni SQL específico del motor. En cuanto una prueba toca cualquiera de
> las cuatro, corre contra PostgreSQL o no vale.**

| Lo que hace la prueba | ¿SQLite? | Por qué |
|---|---|---|
| Aritmética, transiciones, lógica pura | Ni la necesita | Ni siquiera toca la base |
| Mapear un struct a una fila y volver | ✅ | Nada específico del motor |
| Verificar un `UNIQUE` o un `CHECK` | ✅ | Los dos los hacen cumplir |
| Comparar instantes o rangos de fechas | ❌ §4 | SQLite compara cadenas |
| Cualquier cosa con `FOR UPDATE` | ❌ §7 | No existe |
| Dos escritores a la vez | ❌ §8 | Serializa la base entera |
| `RETURNING`, `setval`, tipos del motor | ❌ §3, §2 | Dialecto puro |
| Que un tipo inválido se rechace | ❌ §6 | SQLite lo acepta |

Y el argumento que sostiene la regla, que es de `be08` y conviene repetir:

> 🧠 **Una suite verde contra el motor equivocado es peor que no tener suite.** No
> tener suite te deja desconfiado y prudente. Una suite verde te da **permiso para
> desplegar**, y ese permiso es exactamente lo que no tenías derecho a recibir.
>
> Por eso el *helper* de `be08` **falla** en vez de saltar: `t.Skip` es la forma
> en que una suite miente.

---

## 🧪 Ejercicios (8)

1. **🟢** Comprueba tu versión de SQLite con `select sqlite_version();` y verifica que cumple la cota de `D18`. Explica qué llegó en la 3.35.
2. **🟢** Ejecuta el `INSERT` del §6 en los dos motores y compara. Después corre `SELECT sum(number_price)` en cada uno.
3. **🟡** Reproduce el §4 completo con los dos motores y pega las dos salidas. Es la Divergencia 2 y la Prueba B de `be08`.
4. **🟡 Diagnóstico.** Sustituye `RETURNING` por `LastInsertId` y corre la suite contra los dos motores. Explica por qué el resultado es peligroso y no solo molesto.
5. **🟠 Diagnóstico.** Quita `_foreign_keys=on` del DSN de pruebas, inserta un `raffle_numbers` huérfano, y determina cuántas de tus pruebas siguen pasando.
6. **🟠** Siembra con ids explícitos, omite el `setval`, y crea una rifa desde la aplicación. Lee el error de Postgres y explica de dónde salió el id que chocó.
7. **🟠** Verifica **midiendo** tres entradas de la §11: crea un índice parcial, un `CHECK` con `IN` y un `ON CONFLICT DO NOTHING` en los dos motores. Si alguna no porta, corrige este apéndice.
8. **🔴 Diagnóstico.** Encuentra una divergencia que **no** esté en este apéndice, con evidencia medida, clasifícala en una de las cuatro áreas de la regla del motor, y decide si obliga a cambiar algo del backend.

---

## 📚 Referencias

**Documentación oficial**
- https://www.sqlite.org/quirks.html — SQLite enumerando honestamente en qué se aparta de todos los demás. Es la mejor fuente de este apéndice y se lee en veinte minutos.
- https://www.sqlite.org/datatype3.html — la afinidad de tipos del §6, explicada por sus autores.
- https://www.sqlite.org/lang_returning.html — `RETURNING` con su nota de versión.
- https://www.sqlite.org/partialindex.html — índices parciales desde la 3.8.0, el §11.
- https://www.sqlite.org/foreignkeys.html#fk_enable — el pragma del §9.
- https://www.sqlite.org/lockingv3.html y https://www.sqlite.org/rescode.html#busy — el §8.
- https://www.sqlite.org/stricttables.html — las tablas `STRICT` de la 3.37, que no alcanzamos.
- https://www.postgresql.org/docs/13/datatype-datetime.html — el §4 desde el otro lado.
- https://wiki.postgresql.org/wiki/Don%27t_Do_This — cinco líneas por tema y sin diplomacia.
- https://jmoiron.github.io/sqlx/ — `Rebind` y el mapeo a structs.

**Libros**
- *SQL Performance Explained* (Markus Winand) — no trata de portabilidad, pero su tratamiento de índices vale para los dos motores. Su sitio `use-the-index-luke.com` es la versión libre.

**Orden de lectura sugerido:** `quirks.html` completo primero —es la fuente de la
mitad de este apéndice— → `datatype3.html` para entender el §6 → y volver a este
índice por saltos, cuando algo falle.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las notas de
> versión de SQLite son especialmente importantes acá: **una función que hoy
> existe puede no existir en la 3.35**, que es la cota del track. Comprueba
> siempre contra tu versión antes de asumir. La fuente de verdad de versiones es
> `prompts/decisiones-y-versiones.md` §7.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura. La evidencia que
> generes al recorrerlo va en `server/evidence/divergencias.md`, que sí es
> entregable de `be02` y se versiona con esa fase.
FIN_DEL_ARCHIVO
wc -l be-a-03-sql-portable-y-dialectos.md

# --- 2026-09-09T03:39:39 · 
cat > be-a-04-jwt-por-dentro-y-su-cve.md <<'FIN_DEL_ARCHIVO'
# 🔑 Apéndice be-a-04 — JWT por dentro y su CVE

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~3 horas
> Lo referencian: `be04`; `be-a-08` lo cruza

---

Este apéndice responde tres preguntas que nacen en `be04` y no caben ahí: **qué
hay realmente dentro de un JWT**, **cómo se lee un aviso de seguridad y se decide
si te afecta**, y **cuándo un JWT es la herramienta correcta y cuándo no**.

No es un curso de criptografía. Damos por sabidos hash, firma y clave simétrica
contra asimétrica. Lo que se explica es lo que la gente sigue equivocando después
de años usando JWT.

---

## 🧭 Índice de salto rápido

1. [Anatomía: tres partes, dos de ellas legibles](#1-anatomía-tres-partes-dos-de-ellas-legibles)
2. [Qué significa "firmado", y qué no significa](#2-qué-significa-firmado-y-qué-no-significa)
3. [Los claims que importan acá](#3-los-claims-que-importan-acá)
4. [Algoritmos y el ataque `alg: none`](#4-algoritmos-y-el-ataque-alg-none)
5. [Por qué un JWT no se puede revocar](#5-por-qué-un-jwt-no-se-puede-revocar)
6. [El CVE de `dgrijalva/jwt-go`](#6-el-cve-de-dgrijalvajwt-go)
7. [Cómo se lee un aviso de seguridad](#7-cómo-se-lee-un-aviso-de-seguridad)
8. [La migración a `golang-jwt/jwt`, paso a paso](#8-la-migración-a-golang-jwtjwt-paso-a-paso)
9. [🧩 Cuándo usar qué: JWT contra sesión](#-cuándo-usar-qué-jwt-contra-sesión)

---

## 1. Anatomía: tres partes, dos de ellas legibles

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwiZXhwIjoxNzg4MDAwMDAwfQ.4f_kR…
└────────── cabecera ──────────┘ └────────── claims ──────────┘ └─ firma ─┘
```

Tres partes separadas por puntos. Las dos primeras son **Base64URL, no
cifrado**:

```bash
# Léelo tú, sin ninguna clave:
echo 'eyJzdWIiOiIyIiwiZXhwIjoxNzg4MDAwMDAwfQ' | base64 -d
# {"sub":"2","exp":1788000000}
```

> 🧭 **Consecuencia operativa, y es la que más se ignora.** Todo lo que pongas en
> un JWT lo puede leer cualquiera que lo tenga: el usuario, un proxy, quien mire
> el `localStorage` de un equipo prestado, quien lea un log donde se coló el
> header. **Nada sensible en un token.** Ni documentos, ni teléfonos, ni roles
> internos que prefieras no publicar, ni el hash de nada.
>
> Base64 no es cifrado. Es codificación para que un binario viaje por un canal de
> texto.

La tercera parte, la firma, se calcula sobre las dos primeras más un secreto que
solo tiene el servidor.

---

## 2. Qué significa "firmado", y qué no significa

**Significa:** que el contenido no se modificó desde que el servidor lo emitió, y
que lo emitió alguien con el secreto.

**No significa:** que sea secreto (§1). Ni que siga siendo válido (§5). Ni que
quien lo presenta sea su dueño legítimo — un token robado funciona perfectamente,
porque el token *es* la credencial.

📖 **Un JWT no prueba quién eres: prueba que alguien con el secreto afirmó, en
algún momento, quién eras.** De ahí se derivan las tres protecciones que hay que
poner siempre: que expire, que viaje por HTTPS, y que no se registre en ningún
log.

---

## 3. Los claims que importan acá

El RFC 7519 registra siete claims estándar. El track usa cuatro y conviene saber
por qué los otros no.

| Claim | Qué es | En el track |
|---|---|---|
| `sub` | El sujeto: **quién** | El `id` del usuario. **La única fuente de identidad que el backend acepta** |
| `exp` | Cuándo deja de valer | `JWT_TTL`, 12 h en laboratorio, 1 h en UAT y producción |
| `iat` | Cuándo se emitió | Diagnóstico: permite saber la edad de un token |
| `iss` | Quién lo emitió | `raffles-api` |
| `aud` | **Para quién** es | **No se usa** — y ver el §6, porque es justo el del CVE |
| `nbf` | No válido antes de | No se usa: no hay tokens programados |
| `jti` | Identificador único | No se usa: haría falta para una lista de revocación (§5) |

**`aud` merece un párrafo** porque es el claim peor entendido. Sirve para que un
token emitido para el servicio A no valga en el servicio B, aunque compartan
secreto o emisor. Con un solo backend no aporta nada, y por eso este sistema no
lo usa. Con dos o más servicios que confíen en el mismo emisor, **no ponerlo es un
agujero**: cualquier token sirve en cualquiera.

> ⚠️ Y el detalle que hay que mirar dos veces: `exp` e `iat` son
> **NumericDate** —segundos desde el epoch, en UTC—, no cadenas ISO. Los verifica
> el servidor **contra su propio reloj**, lo que conecta directamente con `be06`:
> si el reloj del servidor está mal, la expiración está mal.

---

## 4. Algoritmos y el ataque `alg: none`

| Familia | Qué usa | Cuándo |
|---|---|---|
| `HS256` | Un secreto compartido (HMAC) | Un solo servicio firma y verifica. **Lo del track** |
| `RS256` / `ES256` | Par de claves | Uno firma, muchos verifican sin poder firmar |
| `none` | **Nada** | Nunca, en ningún caso, jamás |

`none` existe en el estándar para tokens que se protegen por otro medio, y es la
puerta de la familia de ataques más conocida de JWT.

**El ataque, en tres pasos.** El atacante toma un token válido, cambia la cabecera
a `{"alg":"none"}`, modifica los claims a su gusto, y deja la firma **vacía**
(pero conserva el punto final). Si el servidor confía en el `alg` que viene en la
cabecera para decidir cómo verificar, concluye que no hay que verificar nada.

> 🧭 **La causa raíz, dicha con precisión: la cabecera la elige quien manda el
> token, no quien lo verifica.** Delegar en un dato controlado por el atacante la
> decisión de cómo se comprueba su propio token es el error de diseño, y `none`
> es solo su manifestación más famosa. La variante hermana es la **confusión de
> algoritmo**: un servidor que espera `RS256` y acepta `HS256`, con la clave
> pública usada como secreto HMAC — y la clave pública es pública.

**La defensa, que son tres líneas y van siempre:**

```go
_, err := jwt.ParseWithClaims(tokenString, &claims, func(t *jwt.Token) (interface{}, error) {
    // No preguntes qué algoritmo dice el token: comprueba que sea el TUYO.
    if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
        return nil, fmt.Errorf("algoritmo inesperado: %v", t.Header["alg"])
    }
    return s.secret, nil
})
```

> ⚠️ Las librerías modernas se niegan a aceptar `none` aunque tú no lo
> compruebes. **Eso no te exime**: si tu defensa consiste en que la librería se
> porte bien, tu defensa es la política de mantenimiento de un tercero. Que es,
> exactamente, de lo que trata el §6.

Y el secreto: **32 bytes como mínimo** para HS256. Un secreto corto se rompe por
fuerza bruta *offline* — el atacante tiene el token y todo el tiempo del mundo.

---

## 5. Por qué un JWT no se puede revocar

Un JWT es **autocontenido**: el servidor no guarda nada. Verifica la firma,
comprueba `exp`, y confía. Esa es toda su gracia —no hay consulta a base en cada
petición, cualquier réplica verifica sin estado compartido— y es también su
límite.

**Consecuencia:** un token robado sirve hasta que expira. No hay "cerrar sesión en
todos los dispositivos", no hay "invalidar el token de ese usuario", no hay
"echar al que despedimos esta mañana". El logout del frontend borra el token del
`localStorage`; el token sigue siendo válido hasta su `exp`.

Las salidas, con su precio:

| Estrategia | Qué cuesta |
|---|---|
| `exp` corto | Al usuario lo echan seguido. Se compensa con *refresh token* |
| Lista de revocación | Una consulta por petición: **acabas de perder lo que hacía atractivo el JWT** |
| Versión de token en el usuario | Igual: una consulta por petición |
| Sesión de servidor de toda la vida | Estado compartido, y funciona perfectamente |

> 🧭 **La decisión del track, y su porqué.** `JWT_TTL` largo en laboratorio, sin
> *refresh token*, y la fricción **declarada como deuda 💸 viva**: cuando el token
> vence, el interceptor de la Fase 2 recibe un `401`, hace logout global, y el
> usuario pierde lo que estuviera haciendo.
>
> No es un olvido. Implementar *refresh* exige que el **cliente** lo llame, o sea
> tocar `apiClient.js` y sus interceptores, y eso excede la única excepción
> negociada del track (`D27`). Decidir no pagar una deuda y escribir por qué es
> una forma respetable de administrarla.

---

## 6. El CVE de `dgrijalva/jwt-go`

`D16` manda adoptar `dgrijalva/jwt-go` v3.2.0 **a propósito** en `be04`,
descubrir su estado y migrar. Este es el aviso, con los datos verificados contra
la fuente oficial al escribir este apéndice:

| Dato | Valor |
|---|---|
| Aviso de GitHub | `GHSA-w73w-5m7g-f7qc` |
| CVE | **`CVE-2020-26160`** |
| Paquete | `github.com/dgrijalva/jwt-go` |
| Versiones afectadas | **hasta la v3.2.0 inclusive** |
| Severidad | **Alta — CVSS 7.5** |
| Publicado | **30 de septiembre de 2020** (NVD) |
| Parche | **No hay.** Migrar a `golang-jwt/jwt` ≥ 3.2.1 |

**El fallo, en una frase.** Cuando el claim de audiencia (`aud`) llega como un
arreglo vacío, la aserción de tipo falla y la audiencia queda como cadena vacía.
Una aplicación que confíe **solo** en esta librería para verificar la audiencia
puede aceptar un token que no era para ella.

**¿Afecta a este backend?** Hazte la pregunta en serio, porque hacérsela **es** el
trabajo. Este sistema no emite `aud`, no lo verifica, y tiene un solo servicio: el
vector concreto no aplica.

**Y aun así se migra.** Porque el CVE es el síntoma y no el problema:

> 🧠 **El problema es que la librería está abandonada.** El proyecto está
> archivado y el aviso dice *"no patch available"*. Este hallazgo no te toca; el
> próximo tampoco va a tener parche, y ese sí podría tocarte. Se migra por eso, no
> por el `aud`.

> ⚠️ **Verifica todo esto tú mismo antes de citarlo.** Los avisos se actualizan,
> las severidades se recalculan y los enlaces cambian. Los datos de arriba se
> confirmaron contra el aviso oficial al escribir este apéndice, y aun así el
> procedimiento correcto es abrirlo y leerlo — que es, literalmente, lo que enseña
> el §7. Un apéndice de seguridad con un dato de segunda mano es peor que no
> tenerlo.

---

## 7. Cómo se lee un aviso de seguridad

Un aviso no se lee para asustarse: se lee para **decidir**. Seis preguntas, en
este orden.

**1. ¿Qué paquete y qué versiones?** El rango afectado es lo primero. Un aviso
sobre la v2 de algo que usas en v4 no es tu problema. Comprueba qué tienes de
verdad, no lo que crees:

```bash
go list -m all | grep jwt
go list -m -u all            # y si hay versión nueva
```

**2. ¿Hay parche?** Si lo hay, la decisión suele terminar acá: actualiza. Si dice
*"no patch available"*, la conversación cambia por completo — y esa frase es, casi
siempre, sinónimo de proyecto abandonado.

**3. ¿Cuál es el vector concreto?** No la puntuación: **el mecanismo**. Qué tiene
que hacer un atacante, qué tiene que hacer tu código para ser vulnerable. Acá:
verificar `aud` apoyándote solo en esta librería.

**4. ¿Mi código hace eso?** La pregunta que solo puedes responder tú, y que ningún
escáner responde bien. Búscalo:

```bash
grep -rn "Audience\|aud\|VerifyAudience" .
```

**5. ¿Qué pasa si no hago nada?** Sé concreto: qué se compromete, para quién, con
qué esfuerzo. "Nada, porque no usamos `aud`" es una respuesta válida **si la
verificaste**.

**6. ¿Qué pasa con el próximo?** La pregunta que decide de verdad. Un proyecto
archivado no va a tener parche la próxima vez. Migrar cuando **no** te urge es
barato; migrar durante un incidente, no.

> 🧭 **El criterio, en una línea:** la severidad decide la **urgencia**; el estado
> de mantenimiento decide la **estrategia**.

Y automatiza la pregunta 1, porque nadie la hace a mano:

```bash
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./...
```

`govulncheck` no se limita a mirar el `go.mod`: analiza si tu código **alcanza**
la función vulnerable, lo que reduce muchísimo el ruido. `be09` lo pone en el
pipeline.

---

## 8. La migración a `golang-jwt/jwt`, paso a paso

```bash
go get github.com/golang-jwt/jwt/v4@v4.4.2
go mod edit -droprequire github.com/dgrijalva/jwt-go
go mod tidy
```

```go
// ANTES                                 // DESPUÉS
import "github.com/dgrijalva/jwt-go"     import "github.com/golang-jwt/jwt/v4"

jwt.StandardClaims                       jwt.RegisteredClaims
IssuedAt:  now.Unix()                    IssuedAt:  jwt.NewNumericDate(now)
ExpiresAt: now.Add(ttl).Unix()           ExpiresAt: jwt.NewNumericDate(now.Add(ttl))
```

El cambio es sorprendentemente pequeño, y **esa pequeñez también es contenido**:
un fork bien hecho conserva la superficie de la API para que migrar no sea una
excusa para no migrar.

Los tres cambios de la v4, con su porqué:

- **`StandardClaims` → `RegisteredClaims`.** El RFC 7519 los llama "claims
  registrados". El nombre anterior nunca fue el correcto.
- **`int64` → `*jwt.NumericDate`.** Con `int64`, "sin expiración" y "expira en el
  epoch" son el mismo valor: `0`. Con un puntero, ausente y cero son distintos. Es
  la misma lección del `participantId` de `be03`, en otra capa.
- **La verificación de `aud` cambió**, que es lo que arregla el CVE.

Verifica que la deuda se pagó de verdad:

```bash
grep -rn "dgrijalva" .        # no debe devolver nada
go list -m all | grep jwt     # solo golang-jwt
```

> 📝 Y una nota de lectura para el `go.mod`: el
> `github.com/dgrijalva/jwt-go v3.2.0+incompatible` lleva ese sufijo porque el
> repositorio etiquetó una v3 sin declarar el `/v3` en la ruta del módulo, como
> pide el versionado semántico de Go. Es una señal de proyecto que dejó de
> cuidarse, y de las que se aprenden a leer tarde.

---

## 🧩 Cuándo usar qué: JWT contra sesión

| Necesitas… | JWT | Sesión de servidor |
|---|---|---|
| Verificar sin consultar a nadie | ✅ | ❌ |
| Varias réplicas sin estado compartido | ✅ | Necesita almacén común |
| Varios servicios que confían en un emisor | ✅ (con `aud`) | Complicado |
| **Cerrar sesión de verdad, ya** | ❌ §5 | ✅ |
| Cambiar permisos y que apliquen al instante | ❌ | ✅ |
| Guardar datos sensibles de la sesión | ❌ §1 | ✅ |
| Tokens de vida corta con renovación | Con *refresh* | Nativo |

📖 **La regla honesta:** JWT gana cuando el problema es **escalar la
verificación**. Sesión gana cuando el problema es **controlar el acceso en
tiempo real**. Casi todo el mundo elige JWT por moda y descubre el §5 el día que
alguien pide echar a un usuario.

**Y por qué este sistema usa JWT.** No por escala —un monolito con un Postgres no
la necesita— sino por el contrato: el frontend de la Fase 2 ya guarda una cadena
opaca en un campo `token` y la manda como `Bearer`. Un JWT encaja en ese hueco
**sin tocar un solo archivo del cliente**. Una sesión de servidor encajaría igual
de bien en el hueco, y habría exigido una tabla y una consulta por petición a
cambio de una revocación que este dominio no está pidiendo.

> 🧠 Que la respuesta correcta la haya decidido **el contrato heredado** y no una
> comparación de arquitecturas es, probablemente, lo más realista de esta fase.

---

## 🧪 Ejercicios (8)

1. **🟢** Decodifica con `base64 -d` las dos primeras partes de tu token, sin herramientas. Anota qué campos son legibles.
2. **🟢** Comprueba con `curl` que un token con el `sub` modificado en jwt.io devuelve `401`, y encuentra la línea del log del servidor.
3. **🟡 Diagnóstico.** Fabrica un token `alg: none` con `base64` y compruébalo contra tu API. Después comenta la verificación de `t.Method` y repite. Anota si tu versión de la librería te salva sola, y qué implica eso.
4. **🟡** Baja `JWT_TTL` a 60 segundos, usa la aplicación hasta que venza, y documenta la experiencia completa del usuario. Ese es el aspecto exacto de la deuda del §5.
5. **🟠** Lee `GHSA-w73w-5m7g-f7qc` completo y responde las seis preguntas del §7 por escrito, con los comandos que usaste para cada una.
6. **🟠 Diagnóstico.** Ejecuta `govulncheck ./...` antes y después de la migración del §8 y guarda las dos salidas. Explica la diferencia entre lo que reporta y lo que reportaría un escáner que solo mira el `go.mod`.
7. **🟠** Migra a RS256 con un par de claves y explica qué gana el sistema. Sé concreto sobre quién puede firmar y quién solo verificar, y en qué escenario eso importaría acá.
8. **🔴** Implementa una lista de revocación en memoria para invalidar un token antes de su `exp`. Mide el costo por petición y después argumenta, con ese número, qué acabas de perder — y si valió la pena.

---

## 📚 Referencias

**Avisos y fuentes primarias**
- https://github.com/advisories/GHSA-w73w-5m7g-f7qc — el aviso del §6. **Ábrelo**: es material del apéndice, no una nota al pie.
- https://nvd.nist.gov/vuln/detail/CVE-2020-26160 — la entrada en la NVD, con el vector CVSS desglosado.
- https://github.com/golang-jwt/jwt — el fork, con su guía de migración.

**Documentación oficial**
- https://www.rfc-editor.org/rfc/rfc7519 — JWT. Para el §3: la sección 4.1, claims registrados.
- https://www.rfc-editor.org/rfc/rfc8725 — *JSON Web Token Best Current Practices*. **El documento más útil de esta lista**: su §3.1 es el `alg: none` explicado por quienes escribieron el estándar, y su §2.1 dice literalmente que no confíes en el `alg` de la cabecera.
- https://www.rfc-editor.org/rfc/rfc7515 — JWS, la firma por dentro.
- https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html — el nombre dice Java; el contenido sobre ataques y mitigaciones aplica a cualquier lenguaje.
- https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck — el §7 automatizado.
- https://jwt.io — el depurador. **Pega tokens de laboratorio, nunca uno de producción**: es una página web y el token es una credencial.

**Libros**
- *Web Application Security* (Andrew Hoffman) — los capítulos de autenticación y ataques sobre tokens.
- *API Security in Action* (Neil Madden) — el mejor tratamiento largo de JWT contra sesión que conozco, con el §5 discutido a fondo.

**Video / apoyo**
- Busca "JWT alg none attack" y "why JWT is not a session". Verifica que las demostraciones usen librerías actuales: muchas explotan implementaciones ya corregidas y dan una falsa sensación de facilidad.

**Orden de lectura sugerido:** el §1 y el §4 de este apéndice antes de escribir el
paquete `auth` de `be04` → RFC 8725 §2 y §3, que son tres páginas y cubren todos
los errores comunes → el aviso `GHSA-w73w-5m7g-f7qc` entero antes de migrar →
`be-a-08` cuando quieras el resto del panorama de seguridad de la API.

> ⚠️ URLs, títulos, **severidades y fechas** pueden haber cambiado: verifícalos.
> Los datos del CVE se confirmaron contra el aviso oficial al escribir este
> apéndice, y aun así el procedimiento correcto es abrirlo. Las referencias a
> libros y videos son de memoria y pueden ser inexactas. La fuente de verdad de
> versiones es `prompts/decisiones-y-versiones.md` §7.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura. El código de `auth`, la
> migración en sus dos commits y `server/postmortem-jwt.md` son entregables de
> `be04` y se versionan con esa fase.
FIN_DEL_ARCHIVO
wc -l be-a-04-jwt-por-dentro-y-su-cve.md

# --- 2026-09-09T03:41:32 · 
cat > be-a-05-concurrencia-en-postgres.md <<'FIN_DEL_ARCHIVO'
# 🔒 Apéndice be-a-05 — Concurrencia en PostgreSQL

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~3 horas
> Lo referencian: `be05` principalmente; `be07` y `be08` lo consultan

---

Este apéndice es **ejecutable**. Cada mecanismo viene con su sesión doble
reproducible en dos terminales de `psql`, porque la concurrencia es de esas cosas
que no se entienden leyendo: se entienden viendo una transacción esperar.

Damos por sabido qué es una transacción y qué es un nivel de aislamiento. Lo que
probablemente no hayas tenido que hacer nunca es **elegir uno con un número de
rifa de por medio**, sabiendo que si te equivocas alguien paga dos veces por lo
mismo. Eso es lo que se practica acá.

**Preparación**, una sola vez:

```sql
CREATE TABLE IF NOT EXISTS demo_numbers (
    id       BIGSERIAL PRIMARY KEY,
    raffle_id BIGINT NOT NULL,
    number   TEXT   NOT NULL,
    status   TEXT   NOT NULL DEFAULT 'available',
    UNIQUE (raffle_id, number)
);
INSERT INTO demo_numbers (raffle_id, number) VALUES (1, '0347')
ON CONFLICT DO NOTHING;
```

Abre **dos terminales** contra la misma base. En lo que sigue, **T1** y **T2**.

---

## 🧭 Índice de salto rápido

1. [El bug, en dos terminales](#1-el-bug-en-dos-terminales)
2. [Niveles de aislamiento y qué previene cada uno](#2-niveles-de-aislamiento-y-qué-previene-cada-uno)
3. [`FOR UPDATE` y sus variantes](#3-for-update-y-sus-variantes)
4. [`INSERT … ON CONFLICT`](#4-insert--on-conflict)
5. [El índice único, última línea de defensa](#5-el-índice-único-última-línea-de-defensa)
6. [Pesimista contra optimista: cómo elegir](#6-pesimista-contra-optimista-cómo-elegir)
7. [Deadlocks](#7-deadlocks)
8. [Observarlo todo: `pg_stat_activity` y `pg_locks`](#8-observarlo-todo-pg_stat_activity-y-pg_locks)
9. [🧩 Cuándo usar qué: vender un número](#-cuándo-usar-qué-vender-un-número)

---

## 1. El bug, en dos terminales

Antes de las soluciones, el problema. Ejecuta **alternando** las líneas:

```sql
-- T1                                    -- T2
BEGIN;
SELECT status FROM demo_numbers
 WHERE raffle_id=1 AND number='0347';
-- 'available'
                                         BEGIN;
                                         SELECT status FROM demo_numbers
                                          WHERE raffle_id=1 AND number='0347';
                                         -- 'available'  ← también
UPDATE demo_numbers SET status='sold'
 WHERE raffle_id=1 AND number='0347';
COMMIT;
                                         UPDATE demo_numbers SET status='sold'
                                          WHERE raffle_id=1 AND number='0347';
                                         COMMIT;
```

Las dos leyeron `available`, las dos decidieron que se podía, las dos escribieron.
**Ninguna falló.** Ese es el `SellNumber` de `be03`, y esa ventana entre leer y
escribir es lo que se cierra en el resto del apéndice.

📖 El patrón tiene nombre: **check-then-act**. Verificar una condición y actuar
sobre ella en dos operaciones separadas. La solución nunca es "verificar mejor":
es hacer que la verificación y la acción sean **una sola cosa indivisible**.

---

## 2. Niveles de aislamiento y qué previene cada uno

| Nivel | Previene | Permite | ¿Resuelve lo nuestro? |
|---|---|---|---|
| `READ COMMITTED` (defecto) | Lecturas sucias | Lectura no repetible, *phantom*, *write skew* | ❌ |
| `REPEATABLE READ` | + lectura no repetible y *phantoms* | *Write skew* | ❌ |
| `SERIALIZABLE` | Todo | Nada | ✅ **con reintento** |

> ⚠️ Postgres **no tiene** `READ UNCOMMITTED`: lo acepta como sintaxis y se
> comporta como `READ COMMITTED`. Y su `REPEATABLE READ` es, en realidad, aislamiento
> por instantánea: previene los *phantoms* que el estándar SQL permitiría en ese
> nivel.

**Por qué `READ COMMITTED` permite el §1.** Cada **sentencia** ve una foto de lo
confirmado en el momento en que esa sentencia empieza. Los dos `SELECT` ocurrieron
antes de cualquier `COMMIT`, así que los dos vieron `available`. La transacción te
da atomicidad —o pasan todas las escrituras o ninguna— pero **no exclusión mutua**.

**`SERIALIZABLE`, en dos terminales:**

```sql
-- T1                                    -- T2
BEGIN ISOLATION LEVEL SERIALIZABLE;      BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT status FROM demo_numbers          SELECT status FROM demo_numbers
 WHERE raffle_id=1 AND number='0347';     WHERE raffle_id=1 AND number='0347';
UPDATE demo_numbers SET status='sold'
 WHERE raffle_id=1 AND number='0347';
COMMIT;                                  -- ok
                                         UPDATE demo_numbers SET status='sold'
                                          WHERE raffle_id=1 AND number='0347';
                                         -- ERROR: could not serialize access
                                         --        due to concurrent update
                                         -- SQLSTATE 40001
```

Postgres detectó que el resultado no habría podido ocurrir en ningún orden
secuencial y abortó una. Correcto — y con un precio:

> 🧭 **Un `40001` no es un error de negocio: es "vuelve a intentarlo".** Y
> alguien tiene que reintentar. En este sistema ese alguien no puede ser el
> frontend heredado, así que el reintento tendría que vivir en el servidor, con
> su límite de intentos y su espera. Es perfectamente viable —es el ejercicio 29
> de `be05`— y es más código del que parece.

---

## 3. `FOR UPDATE` y sus variantes

Bloqueo **pesimista**: se toma el bloqueo antes de decidir, y quien llegue después
espera.

```sql
-- T1                                    -- T2
BEGIN;
SELECT * FROM demo_numbers
 WHERE raffle_id=1 AND number='0347'
 FOR UPDATE;                             BEGIN;
-- bloqueada, T1 sigue trabajando        SELECT * FROM demo_numbers
                                          WHERE raffle_id=1 AND number='0347'
                                          FOR UPDATE;
                                         -- ⏳ SE QUEDA ESPERANDO. No falla.
UPDATE demo_numbers SET status='sold' …;
COMMIT;
                                         -- despierta y lee status='sold'
```

T2 no leyó un dato viejo ni recibió un error: **esperó**, y al despertar vio la
verdad. Esa es toda la idea.

### Las cuatro variantes

| Variante | Qué hace | Cuándo |
|---|---|---|
| `FOR UPDATE` | Bloqueo exclusivo. Los demás esperan | Vas a modificar **esa** fila |
| `FOR NO KEY UPDATE` | Más débil: no bloquea a quien la referencie por clave foránea | Modificas columnas que no son clave |
| `FOR SHARE` | Compartido: varios leen, nadie modifica | Necesitas que **no cambie**, no excluir a los demás |
| `FOR UPDATE SKIP LOCKED` | **Se salta** las filas bloqueadas | Cola de trabajo: "dame cualquiera libre" |
| `FOR UPDATE NOWAIT` | Falla al instante (`55P03`) en vez de esperar | Prefieres un error rápido a una espera |

**`FOR SHARE` en el track**, y el porqué importa: `be06` bloquea la **rifa** con
`FOR SHARE` mientras vende, no con `FOR UPDATE`. Solo necesita que nadie cambie la
`closesAt` durante la venta; un `FOR UPDATE` sobre la rifa serializaría **todas**
las ventas de esa rifa contra una sola fila y tiraría a la basura la granularidad
que `be05` consiguió.

**`SKIP LOCKED`** es la joya escondida, y el error es usarla donde no va:

```sql
-- ✅ "véndeme cualquier número disponible": cada worker toma uno distinto
SELECT * FROM demo_numbers
 WHERE raffle_id=1 AND status='available'
 ORDER BY number LIMIT 1
 FOR UPDATE SKIP LOCKED;

-- ❌ "véndeme el 0347": saltarse la fila bloqueada devuelve CERO filas, y el
--    código concluiría que el número no existe. Desastre silencioso.
```

📖 `SKIP LOCKED` sirve cuando **cualquier** elemento vale (colas, lotes). Cuando
pides uno **concreto**, es exactamente lo contrario de lo que necesitas.

---

## 4. `INSERT … ON CONFLICT`

Bloqueo **optimista**: no se bloquea nada; se intenta la operación de forma que
solo pueda salir bien una vez, y se mira el resultado.

```sql
-- Los dos a la vez. Uno afecta 1 fila, el otro 0. Nadie espera a nadie.
INSERT INTO sales (raffle_id, number, sold_by) VALUES (1, '0347', 2)
ON CONFLICT (raffle_id, number) DO NOTHING;
```

En Go, el resultado se lee así:

```go
res, err := tx.ExecContext(ctx, query, …)
n, _ := res.RowsAffected()
if n == 0 {
    return ErrAlreadySold   // perdiste la carrera, sin haber esperado
}
```

Las dos formas y cuál elegir:

- **`DO NOTHING`** — el perdedor se entera por `RowsAffected() == 0`. Es el del
  track.
- **`DO UPDATE SET …`** — *upsert*. Útil para la siembra idempotente de `be03`,
  donde correr el `INSERT` veinte veces tiene que dar el mismo resultado.

> ⚠️ **`ON CONFLICT` necesita un índice único que nombrar.** Sin la restricción
> del §5, la cláusula no tiene contra qué detectar el conflicto. Las dos cosas van
> juntas.

---

## 5. El índice único, última línea de defensa

`FOR UPDATE` y `ON CONFLICT` protegen **el camino que escribiste**. Un índice
único protege **todos los caminos**, incluidos los que no existen todavía:

```sql
CONSTRAINT sales_unique_number_per_raffle UNIQUE (raffle_id, number)
```

No es una validación: es una **imposibilidad**. Da igual cuántas transacciones lo
intenten, en qué orden, con qué nivel de aislamiento, desde qué servicio, o si
alguien entra por `psql` a las tres de la mañana. La segunda fila no existe.

```
ERROR:  duplicate key value violates unique constraint "sales_unique_number_per_raffle"
SQLSTATE: 23505
```

Y así se traduce, que es donde el `409` deja de ser un `if`:

```go
var pqErr *pq.Error
if errors.As(err, &pqErr) && pqErr.Code == "23505" {
    return ErrAlreadySold
}
```

> 🧠 **El requisito de diseño que hay que ver antes.** Un `UNIQUE` solo protege
> `INSERT`. Si vender fuera un `UPDATE` sobre una fila que ya existe —como en
> `be03`— no habría segunda fila que rechazar y esta defensa **no estaría
> disponible**. Por eso `be05` cambia el modelo: la venta pasa a ser un **hecho**
> (`sales`) y no un **estado** (`raffle_numbers.status`).
>
> 📖 Un estado es un campo que se pisa; un hecho es una fila que se agrega. Los
> estados pierden historia y no se pueden restringir. **Cuando algo tiene
> consecuencias —dinero, inventario, una plaza—, modélalo como hecho.**

---

## 6. Pesimista contra optimista: cómo elegir

| | Pesimista (`FOR UPDATE`) | Optimista (`ON CONFLICT`) |
|---|---|---|
| El perdedor | **Espera** su turno | Falla al instante |
| Latencia p95 con contención | Crece con los contendientes | Casi plana |
| Trabajo desperdiciado | Ninguno | El del perdedor |
| Visible en `pg_stat_activity` | ✅ Se ve esperar | ❌ No hay espera que ver |
| Riesgo de deadlock | Sí (§7) | Prácticamente no |

> 🧭 **El criterio, que vale más que cualquier número:** el pesimista gana cuando
> la colisión es **probable** y el trabajo perdido sería **caro**; el optimista
> gana cuando la colisión es **rara** y el trabajo perdido es **barato**.

Para una rifa —donde solo colisionan los números "bonitos", y de vez en cuando—
el optimista es la respuesta correcta. Y aun así `be05` usa el pesimista como
camino principal, por una razón que no es de rendimiento: **se puede observar**
(§8). Cuando ya tengas la intuición construida, elige con tus propias mediciones.

---

## 7. Deadlocks

Dos transacciones que bloquean las mismas filas **en orden distinto**:

```sql
-- T1                                    -- T2
BEGIN;                                   BEGIN;
SELECT … number='0347' FOR UPDATE;       SELECT … number='1500' FOR UPDATE;
SELECT … number='1500' FOR UPDATE;       SELECT … number='0347' FOR UPDATE;
-- ⏳ espera a T2                         -- ⏳ espera a T1 → ERROR
```

```
ERROR:  deadlock detected
DETAIL: Process 8123 waits for ShareLock on transaction 5567; blocked by process 8145.
        Process 8145 waits for ShareLock on transaction 5566; blocked by process 8123.
SQLSTATE: 40P01
```

**Postgres lo detecta y mata a una de las dos.** Agradécelo: la alternativa sería
un cuelgue indefinido. El detector corre cada segundo (`deadlock_timeout`), así
que un deadlock cuesta ese segundo antes de resolverse.

**Cómo se evita:** **bloquear siempre en el mismo orden**, típicamente ordenando
por clave primaria. Si una operación toca varios números, ordénalos antes de
bloquearlos:

```go
sort.Strings(numbers)   // el orden lo decide un criterio, no la casualidad
for _, n := range numbers { … FOR UPDATE … }
```

**Cómo se lee en el log.** Necesitas que estén registrados:

```sql
SHOW log_lock_waits;        -- ponlo en 'on' en desarrollo
SHOW deadlock_timeout;      -- 1s por defecto
```

Con `log_lock_waits = on`, Postgres registra también las esperas largas que
**no** llegan a deadlock — que suelen ser la señal temprana del problema.

---

## 8. Observarlo todo: `pg_stat_activity` y `pg_locks`

Las tres consultas que conviene tener guardadas para siempre.

**Qué está pasando ahora:**

```sql
SELECT pid, state, wait_event_type, wait_event,
       now() - xact_start AS duracion,
       left(query, 60) AS consulta
FROM pg_stat_activity
WHERE datname = current_database() AND state <> 'idle'
ORDER BY xact_start;
```

Con un bloqueo activo verás `wait_event_type = 'Lock'` y
`wait_event = 'transactionid'`. **Eso es una transacción esperando, en pantalla.**

**Quién bloquea a quién** — la que de verdad usarás a las tres de la mañana:

```sql
SELECT blocked.pid   AS bloqueado,
       blocking.pid  AS bloqueante,
       left(blocked.query, 40)  AS espera,
       left(blocking.query, 40) AS culpable
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking
  ON blocking.pid = ANY(pg_blocking_pids(blocked.pid));
```

**Qué bloqueos hay, con su modo:**

```sql
SELECT l.pid, l.mode, l.granted, c.relname
FROM pg_locks l LEFT JOIN pg_class c ON c.oid = l.relation
WHERE NOT l.granted OR c.relname = 'demo_numbers';
```

Y el vecino peligroso que hay que saber reconocer:

> ⚠️ **`idle in transaction`.** Una sesión que hizo `BEGIN` y se fue a tomar café
> conserva **todos** sus bloqueos e impide que el recolector limpie. El síntoma es
> "la aplicación se arrastra sin motivo". Búscalo:
>
> ```sql
> SELECT pid, now() - state_change AS inactiva, left(query,50)
> FROM pg_stat_activity WHERE state = 'idle in transaction'
> ORDER BY state_change;
> -- y si hace falta:  SELECT pg_terminate_backend(<pid>);
> ```

📖 **Y la regla que evita la mitad de estos casos:** una transacción **nunca**
debe contener una petición de red. Mientras esperas dos segundos a un servicio
externo, estás bloqueando filas.

---

## 🧩 Cuándo usar qué: vender un número

El caso concreto, con la decisión y su porqué:

| Herramienta | ¿Para vender el `0347`? |
|---|---|
| Transacción a secas | **No basta.** Da atomicidad, no exclusión (§2) |
| `READ COMMITTED` + `FOR UPDATE` | ✅ **Lo del track.** Explícito, observable, sin reintentos |
| `INSERT … ON CONFLICT DO NOTHING` | ✅ Igual de correcto y más rápido con contención baja |
| `UNIQUE (raffle_id, number)` | ✅ **Obligatorio**, además de lo anterior. Es lo único que protege los caminos futuros |
| `SERIALIZABLE` | Correcto, **pero exige reintento**, y el cliente heredado no reintenta |
| `SKIP LOCKED` | ❌ Devolvería cero filas y concluirías que el número no existe |
| Un `if` en el código | ❌ Es el bug del §1, en el lenguaje que sea |

> 🧭 **La receta del track, en tres piezas y las tres hacen falta.**
> 1. Una **transacción** que envuelva leer, decidir y escribir.
> 2. Un **`FOR UPDATE`** sobre la fila del número, **antes** de decidir.
> 3. Un **`UNIQUE`** detrás, por los caminos que todavía no existen.
>
> La 1 y la 2 protegen este código. La 3 protege el que escribirá otra persona
> dentro de dos años sin leer nada de esto.

Y el corolario que ordena todo el track: **ninguna de las tres se puede poner en
el frontend**. La corrección optimista con rollback de la Fase 5 mejora la
experiencia mientras el servidor decide, y eso es valioso — pero no protege nada,
porque no puede.

---

## 🧪 Ejercicios (9)

1. **🟢** Reproduce el §1 en dos terminales y confirma en la tabla que el número quedó vendido dos veces.
2. **🟢** Repite con `FOR UPDATE` y observa a T2 esperar. Mide cuánto espera si T1 tarda cinco segundos en confirmar.
3. **🟡** Ejecuta el §2 con `SERIALIZABLE` y captura el `40001`. Escribe qué tendría que hacer el cliente al recibirlo.
4. **🟡 Diagnóstico.** Con un bloqueo activo, corre las tres consultas del §8 y explica qué columna te dice qué.
5. **🟠** Compara `FOR UPDATE` y `ON CONFLICT` con 2, 10 y 50 contendientes. Mide ganadores, conflictos y latencia p50 y p95. Es el ejercicio 13 de `be05`.
6. **🟠 Diagnóstico.** Provoca un deadlock con el §7, captura el mensaje completo, y arréglalo ordenando los bloqueos. Explica por qué ordenar funciona.
7. **🟠 Diagnóstico.** Deja una sesión en `idle in transaction`, observa el efecto sobre las ventas de la aplicación, encuéntrala con el §8 y termínala.
8. **🔴** Usa `SKIP LOCKED` para implementar "véndeme cualquier número disponible" con cinco vendedores concurrentes, y demuestra que cada uno se lleva uno distinto. Después úsalo mal —para un número concreto— y documenta el desastre silencioso.
9. **🔴 Diagnóstico.** Quita el `UNIQUE` dejando el `FOR UPDATE` y demuestra que el sistema sigue siendo correcto por este camino. Después escribe el script que, entrando por otro camino, produce la venta duplicada. Ese script es el argumento entero del §5.

---

## 📚 Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/13/transaction-iso.html — el §2, con los ejemplos de cada anomalía. La referencia central del apéndice.
- https://www.postgresql.org/docs/13/explicit-locking.html — el §3 completo, con la tabla de conflictos entre modos de bloqueo.
- https://www.postgresql.org/docs/13/sql-select.html#SQL-FOR-UPDATE-SHARE — `SKIP LOCKED` y `NOWAIT`.
- https://www.postgresql.org/docs/13/sql-insert.html#SQL-ON-CONFLICT — el §4.
- https://www.postgresql.org/docs/13/monitoring-stats.html#MONITORING-PG-STAT-ACTIVITY-VIEW y https://www.postgresql.org/docs/13/view-pg-locks.html — el §8.
- https://www.postgresql.org/docs/13/errcodes-appendix.html — los SQLSTATE: `23505` (unicidad), `40001` (serialización), `40P01` (deadlock), `55P03` (bloqueo no disponible).
- https://www.postgresql.org/docs/13/mvcc.html — el modelo que explica por qué los lectores no bloquean a los escritores.

**Libros**
- *Designing Data-Intensive Applications* (Martin Kleppmann) — el capítulo 7 es, sin competencia, el mejor texto sobre esto. Su tratamiento del *write skew* explica por qué `REPEATABLE READ` no basta.
- *PostgreSQL 14 Internals* (Egor Rogov) — para quien quiera ver MVCC por dentro. Disponible libremente en PDF; verifica la versión.

**Video / apoyo**
- Busca "PostgreSQL SELECT FOR UPDATE explained" y "SKIP LOCKED queue pattern". **Verifica que los ejemplos sean de Postgres**: la semántica de bloqueo de MySQL es distinta y mezclarlas confunde más que ayuda.

**Orden de lectura sugerido:** haz el §1 en dos terminales antes de leer nada —el
bug con las manos vale más que cualquier explicación— → `transaction-iso.html`
§13.2 → `explicit-locking.html` §13.3.2 → y el capítulo 7 de Kleppmann cuando
quieras la teoría completa.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. La
> documentación de Postgres tiene **una versión por URL**: si aterrizas en la
> última, cambia el número a 13 antes de creerle. Las referencias a libros son de
> memoria y pueden ser inexactas. La fuente de verdad de versiones es
> `prompts/decisiones-y-versiones.md` §7.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura. La tabla `demo_numbers`
> es de laboratorio y puedes borrarla al terminar (`DROP TABLE demo_numbers;`). La
> evidencia que generes va en `server/evidence/concurrencia.md`, que es entregable
> de `be05`.
FIN_DEL_ARCHIVO
wc -l be-a-05-concurrencia-en-postgres.md; ls be-a-*.md

# --- 2026-09-09T04:04:03 · Read prompts for be-a-06 to be-a-08
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; sed -n '/## Apéndice be-a-06/,/## Apéndice be-a-09/p' $R/prompts/prompts-backend-apendice.md | grep -v "^Actúa\|^orden:\|^(4)\|^(6)\|^prompts/" | head -100

# --- 2026-09-09T04:05:57 · 
cat > be-a-06-tiempo-zonas-y-relojes.md <<'FIN_DEL_ARCHIVO'
# 🕰️ Apéndice be-a-06 — Tiempo, zonas y relojes

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~3 horas
> Lo referencian: `be06`; `be02` y `be07` lo consultan

---

Ya sufriste zonas horarias. No vamos a explicar qué es UTC ni qué es un offset.
Lo que sigue son **las trampas concretas de este stack** —Postgres 13, Go 1.19,
un navegador y SQLite en pruebas— con el caso del curso como hilo: *una rifa que
cierra a las 22:00 del 30 de agosto en Bogotá*.

La pregunta que ordena el apéndice es una sola:

> 🧭 **¿Esto es un instante o es una fecha de calendario?** Un instante es un
> punto en la línea del tiempo del universo: el cierre de la rifa. Una fecha de
> calendario es una etiqueta local sin instante asociado: un cumpleaños, un
> feriado. **Se guardan distinto, se comparan distinto y se rompen distinto.**
> Este dominio solo tiene instantes, y eso simplifica más de lo que parece.

---

## 🧭 Índice de salto rápido

1. [Qué hace realmente Postgres con `TIMESTAMPTZ`](#1-qué-hace-realmente-postgres-con-timestamptz)
2. [`TIMESTAMP` sin zona, y por qué casi nunca lo quieres](#2-timestamp-sin-zona-y-por-qué-casi-nunca-lo-quieres)
3. [`time.Time` en Go: zona, reloj monótono y `==`](#3-timetime-en-go-zona-reloj-monótono-y-)
4. [RFC 3339 como formato de frontera](#4-rfc-3339-como-formato-de-frontera)
5. [Horario de verano: el minuto que existe dos veces](#5-horario-de-verano-el-minuto-que-existe-dos-veces)
6. [SQLite: sin tipo fecha](#6-sqlite-sin-tipo-fecha)
7. [El reloj del cliente](#7-el-reloj-del-cliente)
8. [🧩 Cuándo usar qué: dónde vive cada cosa](#-cuándo-usar-qué-dónde-vive-cada-cosa)

---

## 1. Qué hace realmente Postgres con `TIMESTAMPTZ`

Empecemos por el malentendido, porque es el que produce las facturas.

> ⚠️ **`TIMESTAMP WITH TIME ZONE` no almacena ninguna zona horaria.** El nombre
> es desafortunado hasta el punto de ser engañoso.

Lo que guarda es un **instante**, internamente en UTC, con los mismos 8 bytes que
un `TIMESTAMP` normal. La zona aparece en dos momentos y en ninguno más:

- **Al entrar.** Si el literal trae offset, lo usa para convertir a UTC. Si **no**
  lo trae, asume la zona de la sesión (`SHOW TimeZone`).
- **Al salir.** Convierte el instante a la zona de la sesión y lo muestra así.

Compruébalo, que es la mejor forma de entenderlo:

```sql
CREATE TEMP TABLE t (a TIMESTAMPTZ, b TIMESTAMP);
INSERT INTO t VALUES ('2026-08-30 22:00:00-05', '2026-08-30 22:00:00-05');

SET TIME ZONE 'America/Bogota';   SELECT * FROM t;
--   a: 2026-08-30 22:00:00-05    b: 2026-08-30 22:00:00
SET TIME ZONE 'UTC';              SELECT * FROM t;
--   a: 2026-08-31 03:00:00+00    b: 2026-08-30 22:00:00   ← b NO cambió
SET TIME ZONE 'Asia/Tokyo';       SELECT * FROM t;
--   a: 2026-08-31 12:00:00+09    b: 2026-08-30 22:00:00
```

La columna `a` dice **el mismo instante** de tres maneras. La `b` dice "las 22:00"
y se niega a decir de dónde: el offset del `INSERT` se descartó sin aviso.

De ahí sale la propiedad que hace correcto usar `TIMESTAMPTZ`: **dos valores que
representan el mismo instante son iguales**, sin importar con qué offset se
escribieron.

```sql
SELECT '2026-08-30 22:00:00-05'::timestamptz = '2026-08-31 03:00:00+00'::timestamptz;
-- t
```

> ⚠️ **El corolario que muerde.** La zona de la sesión afecta a la **salida**. Dos
> aplicaciones leyendo la misma fila pueden ver `22:00-05:00` y `03:00+00:00`, y
> las dos tienen razón. Si tu código compara **cadenas** de fecha, acabas de
> heredar un bug que depende de la configuración del servidor.

Y por eso `be06` fija las dos zonas por separado y con jerarquía explícita:

| Qué | Valor | Para qué |
|---|---|---|
| Zona del **proceso** Go | `TZ=UTC` | Decidir y comparar instantes |
| Zona de la **sesión** de base | `America/Bogota` | **Solo** serializar la salida con el offset del contrato |

📖 **El instante es la verdad; el offset de la serialización es cosmética.** La
zona de presentación no participa en ninguna decisión.

---

## 2. `TIMESTAMP` sin zona, y por qué casi nunca lo quieres

Un `TIMESTAMP` sin zona es un número que parece una fecha. "Las 22:00" sin decir
de dónde **no identifica ningún momento del universo**, y compararlo con otro es
comparar dos opiniones.

Los síntomas son siempre los mismos y siempre tardíos: todo funciona en
desarrollo —donde el servidor está en tu misma zona— y las horas se corren en
producción, donde está en UTC. La ambigüedad no se nota hasta que se nota.

**Cuándo `TIMESTAMP` sin zona sí es lo correcto:** cuando el dato **no es un
instante**. Un feriado nacional es "el 20 de julio", no un punto en la línea del
tiempo; convertirlo a UTC lo empeora. Este dominio no tiene ninguno.

> ⚠️ **Cuidado con las migraciones de tipo.** Un `ALTER COLUMN … TYPE TIMESTAMPTZ`
> **reinterpreta** los datos existentes usando la zona de la sesión. Si los
> valores se guardaron en otra zona, acabas de mover todas tus fechas sin que
> nada falle. Antes de convertir: comprueba en qué zona se escribieron y usa
> `AT TIME ZONE` explícito.

---

## 3. `time.Time` en Go: zona, reloj monótono y `==`

Un `time.Time` lleva tres cosas: el instante, una `*Location`, y —si vino de
`time.Now()`— una lectura de **reloj monótono**.

### El reloj monótono, que rompe las comparaciones

`time.Now()` adjunta una lectura monótona pensada para medir duraciones (inmune a
ajustes de NTP). Esa lectura **no sobrevive** a una serialización ni a una ida y
vuelta a la base. Consecuencia:

```go
t1 := time.Now()
t2 := t1.Round(0)      // Round(0) descarta la lectura monótona
t1 == t2               // false  ❌ aunque sean el mismo instante
t1.Equal(t2)           // true   ✅
```

> 🧭 **En Go, `time.Time` no se compara con operadores. Nunca.** `Equal`, `Before`
> y `After`. El síntoma de olvidarlo es un test que falla comparando dos fechas
> que se ven idénticas en el mensaje de error, y se pierde media hora buscando en
> el lugar equivocado.

### La zona

`time.Now()` devuelve la hora en la zona local del proceso; `time.Now().UTC()`, en
UTC. El instante es el mismo — solo cambia cómo se imprime y qué devuelven
`Hour()`, `Day()` y compañía.

```go
func (systemClock) Now() time.Time { return time.Now().UTC() }
```

Que el `Clock` del track devuelva UTC no es cosmética: fija que el backend se
comporte igual en tu máquina, en el contenedor y en el runner de CI. **Un backend
cuyo comportamiento depende de la configuración regional del host falla distinto
en cada ambiente.**

### El valor cero, y el puntero

El cero de `time.Time` es el 1 de enero del año 1, y `IsZero()` lo detecta. Pero
si el dominio distingue "no hay fecha" de "hay una fecha", **usa un puntero**:
`*time.Time` serializa `nil` a `null`. Es la misma decisión que el
`*int64` del `participantId` de `be03`, y la misma que `golang-jwt` v4 tomó al
cambiar `int64` por `*NumericDate`.

### Cargar zonas

`time.LoadLocation("America/Bogota")` lee la base de datos de zonas **del
sistema**, y una imagen mínima no la tiene:

```go
import _ "time/tzdata"   // embebe la base en el binario (~450 KB)
```

Sin eso, `unknown time zone` **solo dentro del contenedor**: funciona en tu
máquina y falla en el despliegue (`be09`, error común 2).

---

## 4. RFC 3339 como formato de frontera

RFC 3339 es el perfil de ISO 8601 que se usa en APIs. Lo relevante:

```
2026-08-30T22:00:00-05:00     ← con offset
2026-08-31T03:00:00Z          ← el MISMO instante, en UTC
2026-08-30T22:00:00           ← ⚠️ sin offset: ambiguo, no es RFC 3339 válido
```

En Go: `time.RFC3339` (segundos) y `time.RFC3339Nano` (con fracción). En JSON,
`encoding/json` serializa `time.Time` en RFC 3339 automáticamente, con el offset
que traiga el valor.

**Las tres reglas de frontera del track:**

1. **Siempre con offset.** Un instante sin offset es una invitación a que cada
   consumidor lo interprete a su manera.
2. **Nunca literales de fecha en el SQL.** Los instantes viajan como `time.Time`
   por placeholder; el driver los serializa. Un literal sin offset lo interpreta
   Postgres en la zona de la sesión (§1).
3. **`Z` y `-05:00` son intercambiables para el cliente.** `new Date()` produce el
   mismo valor con los dos. El track conserva el offset del contrato por
   verificabilidad y legibilidad, no por semántica.

---

## 5. Horario de verano: el minuto que existe dos veces

Colombia no tiene horario de verano: `America/Bogota` es UTC−5 todo el año. **Este
dominio se libra del problema por suerte geográfica, no por diseño**, y por eso
conviene saber qué habría pasado con otra zona.

En una zona con DST hay dos momentos patológicos cada año:

- **Adelanto (primavera):** una hora local **no existe**. Si el cierre estaba
  programado a las 02:30 y el reloj salta de 02:00 a 03:00, ese instante nunca
  ocurre.
- **Atraso (otoño):** una hora local **existe dos veces**. "Las 01:30" son dos
  instantes distintos separados por una hora, y un `TIMESTAMP` sin zona no puede
  decirte cuál.

```sql
SET TIME ZONE 'America/Santiago';
SELECT '2026-04-04 23:30:00'::timestamp AT TIME ZONE 'America/Santiago';
-- pruébalo alrededor del cambio y mira qué instante te devuelve
```

> 🧭 **Guardar el instante te salva de todo esto. Guardar "hora local + zona", no.**
> Si el dato es un instante ya decidido —el cierre de *esta* rifa— un
> `TIMESTAMPTZ` es inmune: el momento patológico ya se resolvió cuando se
> calculó.
>
> El problema aparece con **reglas recurrentes**: *"todas las rifas cierran los
> viernes a las 22:00 hora local"*. Ahí sí hay que guardar la regla —la hora local
> y **el nombre IANA de la zona**, nunca el offset— y calcular el instante cada
> vez. Porque los offsets **cambian por decisión política**, varias veces al año
> en el mundo, y la base de datos de zonas se actualiza para seguirlas.
>
> 📖 Las zonas horarias no son un problema técnico: son un **problema legal** con
> consecuencias técnicas.

Este dominio no tiene reglas recurrentes. Si algún día las tuviera, esa es la
conversación que habría que abrir — y sería una migración de esquema, no un
parche.

---

## 6. SQLite: sin tipo fecha

SQLite **no tiene** tipo de fecha. Guarda `TEXT`, `INTEGER` o `REAL`, y comparar
texto es comparación lexicográfica. Con formato ISO y **todo en el mismo huso**
funciona por accidente; con husos mezclados, no.

El caso del track (Divergencia 2 de `be02`, Prueba B de `be08`):

```sql
-- closes_at = '2026-08-30T22:00:00-05:00'  →  el 31 a las 03:00 UTC
SELECT name FROM raffles WHERE closes_at > '2026-08-31T01:00:00Z';
```

- **Postgres:** compara instantes → 03:00Z > 01:00Z → **devuelve la rifa**.
- **SQLite:** compara `'2026-08-30…'` con `'2026-08-31…'` → `30 < 31` → **nada**.

Los dos funcionan correctamente según su especificación, y tu regla de negocio da
resultados **opuestos**.

> 🧭 **Consecuencia directa, y es una de las cuatro áreas de la regla del motor:**
> cualquier prueba que dependa de comparar instantes **corre contra Postgres o no
> vale**. El diccionario completo de divergencias está en `be-a-03` §4.

---

## 7. El reloj del cliente

`new Date()` en el navegador devuelve la hora del equipo del usuario, que el
usuario controla con dos clics. La Fase 7 del track base lo dejó anotado como
deuda 💸 y `be06` la cobró **del lado del servidor**.

Los dos escenarios, y no son simétricos:

| El reloj del cliente está… | La interfaz | El servidor | Consecuencia |
|---|---|---|---|
| **Adelantado** | Cierra antes de tiempo, esconde el botón | Sigue vendiendo | El usuario **pierde una venta legítima**. Molesto |
| **Atrasado** | Sigue mostrando el botón | Rechaza con `409` | Mensaje confuso, **datos correctos** |

Antes de `be06`, el segundo caso vendía un número de una rifa cerrada y el
desajuste aparecía semanas después, en la liquidación. **Una interfaz confusa es
un problema; una base de datos mentirosa es un incidente.**

**Qué se hizo y qué no.** El servidor publica su hora en cada respuesta:

```go
w.Header().Set("X-Server-Time", s.clock.Now().Format(time.RFC3339Nano))
```

Hoy **nadie lo consume**. Está puesto igual, y no es un adorno: es el punto donde
la deuda se vuelve barata de pagar. Consumirlo exigiría un interceptor que guarde
el desfase y una función `serverNow()` que lo aplique —unas treinta líneas en dos
archivos del frontend— y eso excede la única excepción negociada del track
(`D27`). 💸 Queda declarada, con su precio, en `be-a-09`.

Y una advertencia sobre medir el desfase: el simple `hora del servidor − hora
local` incluye la latencia de la red. La corrección seria —descontar la mitad del
tiempo de ida y vuelta— es media implementación de NTP, y sirve para entender por
qué sincronizar relojes es más difícil de lo que parece.

---

## 🧩 Cuándo usar qué: dónde vive cada cosa

| Dato | Dónde y cómo |
|---|---|
| Un instante de negocio (cierre, venta, liquidación) | `TIMESTAMPTZ` en la base, `time.Time` en Go, RFC 3339 con offset en el JSON |
| Una fecha de calendario (feriado, cumpleaños) | `DATE`. No lo conviertas a instante |
| Una regla recurrente ("los viernes a las 22:00") | La hora local **y el nombre IANA de la zona**, nunca el offset. Este dominio no tiene ninguna |
| Una duración (TTL de reserva, ventana de gracia) | `time.Duration` / `INTERVAL`. No dos fechas |
| La hora "de ahora" en SQL | La costura (`db.Now()`), nunca `now()` escrito a mano |
| La hora "de ahora" en Go | Un `Clock` inyectado. Nunca `time.Now()` dentro de la lógica |

| Quién decide qué |
|---|
| **El servidor** decide si una venta llega a tiempo. Siempre |
| **El servidor** sella cuándo ocurrió un hecho de negocio (`settledAt`, `soldAt`) |
| **El cliente** decide **cómo se muestra** una fecha al usuario |
| **El cliente** puede decidir si enseña un botón. Es cortesía, no protección |

Y las cinco reglas que resumen el apéndice:

1. **Guarda instantes, no horas de pared**, salvo que el dato sea de calendario.
2. **Compara instantes, nunca cadenas ni componentes de fecha.**
3. **Fija las zonas explícitamente** —proceso y sesión— en vez de heredar la del
   host.
4. **Inyecta el reloj**, o no podrás probar los bordes.
5. **Nunca confíes en el reloj del cliente** para una regla de negocio.

---

## 🧪 Ejercicios (8)

1. **🟢** Ejecuta el experimento del §1 con las tres zonas y anota qué columna cambia y cuál no.
2. **🟢** Comprueba que `'2026-08-30 22:00:00-05'::timestamptz = '2026-08-31 03:00:00+00'::timestamptz` es verdadero, y explica por qué.
3. **🟡 Diagnóstico.** Compara dos `time.Time` con `==` en un test y hazlo fallar. Imprime los valores con `%+v` e identifica qué llevan adjunto.
4. **🟡** Arranca el backend con `TZ=Asia/Tokyo` y corre la suite entera. Si algo falla, encontraste una comparación que mira componentes de fecha. Si no falla nada, explica por qué eso demuestra que la política del §1 funciona.
5. **🟠 Diagnóstico.** Ejecuta el §6 contra los dos motores y pega las dos salidas. Clasifica la divergencia en una de las cuatro áreas de la regla del motor.
6. **🟠 Diagnóstico.** Adelanta el reloj de tu máquina una hora y recorre la aplicación. Documenta los dos escenarios de la tabla del §7, con capturas.
7. **🟠** Elige una zona con horario de verano, pon un `closesAt` justo en el salto, y determina qué pasa. Explica por qué guardar el instante te salva y guardar "hora local + zona" no.
8. **🔴** Escribe la política de tiempo del sistema como documento de una página para quien entre nuevo: qué se guarda, en qué tipo, en qué zona corre cada proceso, quién decide, cómo se serializa y qué está prohibido. Tiene que poder aplicarse sin leer código.

---

## 📚 Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/13/datatype-datetime.html — §8.5.1.3 es exactamente el malentendido del §1.
- https://www.postgresql.org/docs/13/functions-datetime.html — `AT TIME ZONE`, que es la herramienta del §2.
- https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_timestamp_.28without_time_zone.29 — el §2 en cinco líneas y sin diplomacia.
- https://pkg.go.dev/time — y en particular la sección "Monotonic Clocks", que explica el §3.
- https://pkg.go.dev/time#Time.Equal — por qué existe y por qué `==` no sirve.
- https://pkg.go.dev/time/tzdata — el import de una línea del §3.
- https://www.rfc-editor.org/rfc/rfc3339 — corto, y vale la pena leerlo entero una vez en la vida.
- https://www.iana.org/time-zones — la base de datos de zonas. Mira su historial de cambios: es el §5 en estado puro.
- https://www.sqlite.org/lang_datefunc.html — qué ofrece SQLite en lugar de un tipo fecha.

**Libros**
- *Designing Data-Intensive Applications* (Kleppmann) — la sección *Unreliable Clocks* del capítulo 8. Su idea de que "los relojes son intervalos de confianza, no puntos" cambia cómo se diseña.

**Video / apoyo**
- "The Problem with Time & Timezones" (Computerphile) — diez minutos, y es la mejor introducción que existe al tema. Si solo vas a ver una cosa de esta lista, que sea esta.

**Orden de lectura sugerido:** el vídeo de Computerphile para la intuición → el
"Don't Do This" del wiki de Postgres, que fija la regla → el §1 de este apéndice
ejecutado con las manos → `datatype-datetime.html` §8.5 para el detalle → y la
nota del reloj monótono en `pkg.go.dev/time` el día que un test te falle sin
motivo aparente.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros y videos son de memoria y pueden ser inexactas. La
> documentación de Postgres tiene **una versión por URL**: fija el 13. La fuente
> de verdad de versiones es `prompts/decisiones-y-versiones.md` §7.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura. La política de tiempo
> del ejercicio 8 y la evidencia del desfase van en `server/evidence/reloj.md`,
> que es entregable de `be06`.
FIN_DEL_ARCHIVO
wc -l be-a-06-tiempo-zonas-y-relojes.md

# --- 2026-09-09T04:07:42 · 
cat > be-a-07-logs-request-id-y-correlacion.md <<'FIN_DEL_ARCHIVO'
# 🧵 Apéndice be-a-07 — Logs, `request-id` y correlación

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~2 horas
> Lo referencian: `be01` y todas las fases posteriores

---

Este apéndice cierra un bucle que el track base abrió y no pudo terminar.

En la **Fase 2**, el interceptor de respuesta de `apiClient` lee el
`X-Request-Id` que devuelve el mock y lo imprime en la consola. En el mock, ese
id **nace y muere en un middleware de tres líneas**: no hay nada al otro lado con
qué correlacionarlo. El apéndice `A13` enseña a usarlo para distinguir UAT de
producción, y aun así el id sigue siendo medio hilo colgando.

Acá se ata el otro extremo. El mismo id cruza el backend entero —handler,
servicio, store, consulta SQL— y la correlación deja de ser un ejercicio para
volverse una herramienta:

> 🧭 **El recorrido completo que el track promete:** copiar un id de la consola
> del navegador y encontrarlo en el log del servidor, con la consulta que ejecutó,
> cuánto tardó y qué usuario la pidió.

---

## 🧭 Índice de salto rápido

1. [El id: generarlo o respetarlo](#1-el-id-generarlo-o-respetarlo)
2. [Propagación por `context.Context`](#2-propagación-por-contextcontext)
3. [Log estructurado con Go 1.19 (sin `slog`)](#3-log-estructurado-con-go-119-sin-slog)
4. [Qué se loguea y qué NUNCA se loguea](#4-qué-se-loguea-y-qué-nunca-se-loguea)
5. [Niveles y ruido](#5-niveles-y-ruido)
6. [El recorrido completo, paso a paso](#6-el-recorrido-completo-paso-a-paso)
7. [🧩 Cuándo usar qué: logs contra DevTools](#-cuándo-usar-qué-logs-contra-devtools)

---

## 1. El id: generarlo o respetarlo

```go
const requestIDHeader = "X-Request-Id"

func requestIDMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Si viene del cliente, se RESPETA. Un proxy, una prueba o un
		// servicio que ya lo generó tienen derecho a fijarlo, y así el id
		// cruza varios saltos siendo el mismo.
		id := r.Header.Get(requestIDHeader)
		if id == "" {
			id = newRequestID()
		}
		w.Header().Set(requestIDHeader, id)
		ctx := context.WithValue(r.Context(), requestIDKey, id)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// 16 caracteres hex de crypto/rand. NO hace falta una dependencia de UUID:
// el id solo tiene que ser único dentro de una ventana de logs.
func newRequestID() string {
	b := make([]byte, 8)
	if _, err := rand.Read(b); err != nil {
		return "ts-" + time.Now().UTC().Format("150405.000000")
	}
	return hex.EncodeToString(b)
}
```

**Tres decisiones y su porqué:**

- **Respetar el que venga.** Es lo que permite que el id sobreviva a un proxy o
  que una prueba lo fije para buscarlo después.
- **Ponerlo primero en la cadena.** Todo lo que venga después —incluido el log de
  un pánico— lo necesita para ser útil (`be01` §4).
- **Devolverlo en la respuesta.** Y —esto es el hallazgo `C-05` de `be00`—
  **exponerlo a CORS**, o el navegador lo recibe y no deja que JavaScript lo lea:

```go
w.Header().Set("Access-Control-Expose-Headers", requestIDHeader)
```

> ⚠️ Sin esa línea, el header **se ve perfectamente en la pestaña Network** y
> `response.headers['x-request-id']` vale `undefined`. Es el bug más silencioso
> del track base y la deuda que `be01` paga con una línea. Si alguna vez la
> trazabilidad "a veces no funciona", empieza por acá.

---

## 2. Propagación por `context.Context`

El id viaja en el contexto, no en las firmas. Cualquier función del backend lo
recupera sin recibirlo como parámetro suelto:

```go
type ctxKey int
const requestIDKey ctxKey = iota   // tipo propio: nadie fuera del paquete puede
                                   // construir esta clave → colisión imposible

func RequestIDFrom(ctx context.Context) string {
	if id, ok := ctx.Value(requestIDKey).(string); ok { return id }
	return ""
}
```

Y por eso `context.Context` es el **primer parámetro** de todo lo que cruza una
frontera —handler, service, store—: es el vehículo. La misma vía transporta la
identidad del usuario desde `be04`, y por la misma razón.

> 🧭 **La regla de los valores en el contexto:** solo para datos de alcance de
> petición que atraviesan capas **sin ser parte de la lógica**. El request id, la
> identidad. Nunca parámetros de negocio disfrazados.

---

## 3. Log estructurado con Go 1.19 (sin `slog`)

`log/slog` es de Go 1.21 y este código es de 2022 (`D14`). Con la biblioteca
estándar de 1.19 hay dos caminos y los dos son legítimos:

### Texto legible — lo que usa el track

```go
log.Printf("[req-id %s] %s %s → %d (%d bytes) en %s",
	RequestIDFrom(r.Context()), r.Method, r.URL.RequestURI(),
	rec.status, rec.bytes, time.Since(start).Round(time.Microsecond))
```

```
2026/09/08 14:22:31 [req-id 9f3a1c7d2e5b] POST /raffles/1/numbers/0347/sell → 409 (46 bytes) en 12.418ms
```

**El id va delante y entre corchetes**, y eso no es estética: es lo que lo hace
grepeable sin comerse líneas vecinas.

```bash
grep '9f3a1c7d2e5b' server.log
docker compose logs api | grep '9f3a1c7d2e5b'
```

### JSON — cuando los logs los lee una máquina

```go
// Un logger estructurado en 25 líneas, sin dependencias. Es lo que hacía
// medio ecosistema Go antes de slog.
type entry struct {
	Time      string `json:"time"`
	Level     string `json:"level"`
	Msg       string `json:"msg"`
	RequestID string `json:"requestId,omitempty"`
	UserID    int64  `json:"userId,omitempty"`
	Method    string `json:"method,omitempty"`
	Path      string `json:"path,omitempty"`
	Status    int    `json:"status,omitempty"`
	DurMS     int64  `json:"durationMs,omitempty"`
	Err       string `json:"error,omitempty"`
}

func logJSON(e entry) {
	e.Time = time.Now().UTC().Format(time.RFC3339Nano)
	b, _ := json.Marshal(e)
	// Una línea por evento y nada más: es lo que exige cualquier colector.
	os.Stdout.Write(append(b, '\n'))
}
```

**La comparación honesta:**

| | Texto | JSON |
|---|---|---|
| Leerlo en una terminal | ✅ Directo | ❌ Ilegible sin `jq` |
| `grep` por un id | ✅ | ✅ |
| Filtrar por status ≥ 500 | ❌ Con expresiones frágiles | ✅ `jq 'select(.status>=500)'` |
| Agregar y graficar | ❌ | ✅ |
| Tamaño por línea | Menor | ~40 % más |

> 🧭 **Cuándo cambia la respuesta.** Texto mientras el log lo lea una persona en
> una terminal —que es todo este curso—. JSON en cuanto lo lea una máquina: un
> colector, un buscador, un panel. El track se queda en texto porque es coherente
> con la época (`D14`) y porque una línea legible enseña mejor. 💸 Está declarado
> como deuda y esta sección es su pago sobre el papel.

Y una regla operativa que vale para los dos formatos:

📖 **Escribe a `stdout`, no a un archivo.** El proceso no debe saber dónde
terminan sus logs: eso lo decide quien lo ejecuta. `docker compose logs`, el
runner de CI y cualquier orquestador esperan `stdout`. Un backend que abre un
archivo de log se pelea con la rotación, con los permisos y con el contenedor.

---

## 4. Qué se loguea y qué NUNCA se loguea

### Nunca, sin excepciones

| Nunca | Por qué |
|---|---|
| El header `Authorization` completo | **Es la credencial.** Quien lea el log entra como ese usuario |
| Un JWT, entero o en trozos | Igual: el token *es* el acceso |
| Contraseñas, ni siquiera al fallar | Ni en el error de login, ni "temporalmente para depurar" |
| El hash de `bcrypt` | Es material para atacar sin límite de intentos |
| `JWT_SECRET` o el `DATABASE_URL` completo | Trae la contraseña de la base |
| El cuerpo completo de una petición | Hoy no trae nada sensible; mañana sí, y nadie va a revisar el logger |
| Datos personales de participantes | Nombre, documento, teléfono |

> ⚠️ **La trampa del volcado cómodo.** Un `log.Printf("%+v", req)` parece
> inofensivo y es la forma más habitual de filtrar un token: el struct incluye
> los headers. Loguea **campos elegidos**, nunca estructuras enteras.
>
> Y recuerda que los logs viajan: se agregan a tickets, se pegan en chats, se
> mandan por correo a soporte. **Un secreto en un log es un secreto publicado.**

### Sí, y siempre

- El `request-id`, en **todas** las líneas.
- Método, ruta y código de estado.
- La duración.
- El id del usuario (`be04`) — un número, no su email.
- El resultado de la operación de negocio: qué error de dominio se devolvió.
- Los eventos que solo el servidor conoce: el desfase de reloj de `be06`, la
  discrepancia de montos de `be07`, el cambio de nivel de caos, el cierre de una
  rifa por reloj.

**Si tienes que registrar un token para diagnosticar**, registra su huella, nunca
el token:

```go
sum := sha256.Sum256([]byte(token))
log.Printf("[req-id %s] token rechazado (huella %x)", id, sum[:6])
```

Sirve para saber si dos peticiones usaron el mismo token, que suele ser lo que
necesitas, y no sirve para entrar.

---

## 5. Niveles y ruido

Sin `slog` no hay niveles nativos. Lo mínimo que hace falta y lo que significa
cada uno:

| Nivel | Cuándo | Ejemplo del track |
|---|---|---|
| `DEBUG` | Detrás de una variable | Cada consulta SQL con su tiempo (`SQL_DEBUG`) |
| `INFO` | Un evento por petición | La línea de acceso; el cierre de una rifa |
| `WARN` | Algo raro que no rompió | Desfase de reloj (`be06`), discrepancia de montos (`be07`) |
| `ERROR` | Falló y alguien debería mirar | Pánico recuperado, la base no responde |

> 🧭 **El criterio que evita el ruido: un log de `ERROR` es una petición de
> atención humana.** Si nadie va a hacer nada al verlo, no es `ERROR`.
>
> Un `401` por token vencido es rutina: `INFO`. Un `409` por venta duplicada es el
> sistema funcionando: `INFO`. Un pánico recuperado es `ERROR`, siempre. Confundir
> esto produce el peor de los resultados: un log lleno de errores que nadie mira,
> y entre ellos el que sí importaba.

**El SQL solo detrás de una variable.** `SQL_DEBUG=true` en desarrollo y QA,
`false` en UAT y producción (`be09` §4.3). Registrar cada consulta en producción
multiplica el volumen y —peor— es la forma más fácil de que un valor de negocio
acabe en un log sin que nadie lo decidiera.

---

## 6. El recorrido completo, paso a paso

Esto es lo que el track viene construyendo desde `be00`, fase por fase. Hazlo
entero una vez:

**1. En el navegador.** Vende un número y mira la consola. El interceptor de la
Fase 2 imprimió:

```
[req-id 9f3a1c7d2e5b] POST /raffles/1/numbers/0347/sell → 409
```

Si **no** aparece pero el header sí está en Network, te falta
`Access-Control-Expose-Headers` (§1). Ese es el hallazgo `C-05`.

**2. En el log del servidor.** Con el id:

```bash
docker compose logs api | grep 9f3a1c7d2e5b
```

```
[req-id 9f3a1c7d2e5b] POST /raffles/1/numbers/0347/sell → 409 (46 bytes) en 12.418ms
[req-id 9f3a1c7d2e5b] usuario 2 intentó vender 0347: ese número ya fue vendido
```

**3. En la consulta SQL.** Con `SQL_DEBUG=1`:

```
[req-id 9f3a1c7d2e5b] SQL SELECT … FROM raffle_numbers WHERE raffle_id=$1 AND number=$2 FOR UPDATE → 8.1ms
[req-id 9f3a1c7d2e5b] SQL INSERT INTO sales … → error 23505 en 1.9ms
```

**4. Y en la base, si hace falta.** Con la venta ya registrada, el `sold_by` y el
`sold_at` de `sales` dicen quién ganó la carrera que este id perdió.

> 🧠 **Eso es el círculo cerrado.** En `be00` el id no llegaba a ninguna parte. En
> `be01` llegó al log. En `be02` a la consulta. En `be04` trajo la identidad. En
> `be05` explicó una carrera perdida. En `be08` recorre el sistema **dentro de una
> prueba automatizada**, que es la forma final de la trazabilidad: no un ejercicio
> de diagnóstico, sino una propiedad verificada.

**Un truco que vale la pena conocer:** puedes **fijar** el id desde el cliente
(§1). En un guion de diagnóstico, eso te deja buscar exactamente lo que acabas de
hacer:

```bash
curl -H 'X-Request-Id: diagnostico-oskar-01' localhost:3001/raffles
docker compose logs api | grep diagnostico-oskar-01
```

---

## 🧩 Cuándo usar qué: logs contra DevTools

Las dos orillas responden preguntas distintas, y la mitad del tiempo perdido
diagnosticando es haber elegido la herramienta equivocada.

| La pregunta es… | Herramienta |
|---|---|
| ¿Qué pidió el navegador y qué recibió? | **Network** |
| ¿Por qué el componente pinta eso? | **React / Redux DevTools** |
| ¿Salió la petición siquiera? | **Network** — si no está ahí, el bug es del cliente |
| ¿Por qué el servidor decidió eso? | **Log del backend** |
| ¿Cuánto tardó, y en qué parte? | **Log**, con la duración de la consulta |
| ¿Se llegó a escribir en la base? | **Log** + `psql` |
| ¿Quién pidió esto? | **Log**, con el `userId` del token |
| ¿Pasó más de una vez? | **Log**, agrupando por ruta |
| ¿Está pasando **ahora**? | `pg_stat_activity` (`be-a-05` §8) |

> 🧭 **La regla que ordena el diagnóstico.** Empieza en Network: te dice si el
> problema está **antes o después** del cable. Si la petición salió y volvió con
> lo que volvió, el frontend hizo su trabajo y el resto de la investigación es del
> otro lado. Ese único corte ahorra más tiempo que cualquier herramienta.
>
> Y el `X-Request-Id` es lo que hace posible cruzar el corte sin perder el hilo.
> Sin él, correlacionar es adivinar por marcas de tiempo — que es lo que hacía el
> track base, y por eso `A13` cuesta lo que cuesta.

**Lo que este backend no tiene, y hay que decirlo:** no hay trazas distribuidas,
ni métricas agregadas, ni alertas. Con un monolito y un `request-id` bien
propagado, un log de texto llega sorprendentemente lejos. Con diez servicios, no
— ahí empieza otra conversación (OpenTelemetry, y el `request-id` pasa a ser un
`trace-id` con contexto de propagación estándar), y queda fuera del track.

---

## 🧪 Ejercicios (7)

1. **🟢** Haz una petición fijando tú el `X-Request-Id` y encuéntrala en el log con `grep`.
2. **🟢** Comprueba en el navegador que el id de la consola y el de Network coinciden. Si no aparece en la consola, encuentra por qué (§1).
3. **🟡** Activa `SQL_DEBUG` y sigue un id desde la consola del navegador hasta la consulta SQL con su tiempo. Es el §6 completo.
4. **🟡 Diagnóstico.** Quita `Access-Control-Expose-Headers` y documenta con dos capturas que el header se ve en Network y no se puede leer desde JavaScript.
5. **🟠** Sustituye el logger de texto por el JSON del §3, y filtra con `jq` todas las peticiones que devolvieron 5xx. Mide cuánto crece cada línea.
6. **🟠 Diagnóstico.** Escribe a propósito un `log.Printf("%+v", r)` con la petición entera, haz una llamada autenticada, y encuentra el token en el log. Después arréglalo y explica la regla del §4.
7. **🔴** Instrumenta el store para que registre cada consulta con su id, su duración y su resultado, detrás de `SQL_DEBUG`. Después usa esa instrumentación para encontrar la consulta más lenta de la suite de `be08` y explica por qué lo es.

---

## 📚 Referencias

**Documentación oficial**
- https://pkg.go.dev/log — lo que hay en Go 1.19. Corto, y suficiente.
- https://pkg.go.dev/log/slog — lo que llegó en 1.21. Léelo para saber qué te estás perdiendo y por qué `D14` lo deja fuera.
- https://pkg.go.dev/context — la propagación del §2.
- https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Expose-Headers — el hallazgo `C-05`, en una página.
- https://www.w3.org/TR/trace-context/ — el estándar de propagación de contexto de traza. No lo usamos; conviene saber que existe antes de inventar un formato propio.
- https://12factor.net/logs — "trata los logs como flujos de eventos", que es el argumento del `stdout` del §3.
- https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html — el §4 con más detalle.

**Libros**
- *Release It!* (Michael Nygard) — su capítulo sobre transparencia y qué hace que un sistema sea diagnosticable en producción.

**Video / apoyo**
- Busca "structured logging Go" y "correlation id microservices". Casi todo el material asume `slog` o una librería: tradúcelo mentalmente al §3.

**Orden de lectura sugerido:** haz el recorrido del §6 antes de leer nada más —es
media hora y explica el apéndice entero— → la página de
`Access-Control-Expose-Headers` si el paso 1 falla → `12factor.net/logs`, que son
diez líneas → y el resto por saltos.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros y videos son de memoria y pueden ser inexactas. La fuente
> de verdad de versiones es `prompts/decisiones-y-versiones.md` §7.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura. El middleware de
> `request-id`, el logger y la instrumentación del store son entregables de `be01`
> y `be02`, y se versionan con esas fases.
FIN_DEL_ARCHIVO
wc -l be-a-07-logs-request-id-y-correlacion.md

# --- 2026-09-09T04:09:48 · 
cat > be-a-08-seguridad-de-api-aplicada.md <<'FIN_DEL_ARCHIVO'
# 🛡️ Apéndice be-a-08 — Seguridad de API aplicada

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~3 horas
> Lo referencian: `be04` principalmente; `be03` y `be09` lo consultan

---

Esto es **seguridad defensiva aplicada a esta API**, nunca en abstracto. Cada
sección responde a una pregunta concreta sobre el backend de rifas: *¿puede
alguien vender un número que no le corresponde? ¿puede fijar el precio desde el
cuerpo de un `POST`? ¿qué le estamos contando a un atacante en cada mensaje de
error?*

No hay listas genéricas de OWASP copiadas. Hay seis riesgos que **este** sistema
tiene, con la comprobación que los detecta y la defensa que los cierra. Y al
final, lo más importante del apéndice:

> 🧭 **La lista de lo que este backend NO cubre a propósito.** Para que nadie
> confunda un laboratorio de curso con un backend de producción. Está en el §7 y
> es de lectura obligatoria.

---

## 🧭 Índice de salto rápido

1. [Inyección SQL, y la única concatenación permitida](#1-inyección-sql-y-la-única-concatenación-permitida)
2. [Autorización a nivel de objeto](#2-autorización-a-nivel-de-objeto)
3. [Asignación masiva](#3-asignación-masiva)
4. [Qué filtra un mensaje de error](#4-qué-filtra-un-mensaje-de-error)
5. [Límites de tasa](#5-límites-de-tasa)
6. [CORS bien entendido](#6-cors-bien-entendido)
7. [🚫 Lo que este backend NO cubre](#7--lo-que-este-backend-no-cubre)
8. [🧩 Cuándo usar qué](#-cuándo-usar-qué)

---

## 1. Inyección SQL, y la única concatenación permitida

El track escribe SQL a mano (`D17`), así que esto no es negociable: **los datos
viajan por placeholder, siempre**.

```go
// ✅ El valor nunca es parte de la sentencia. El driver lo manda aparte y
//    Postgres jamás lo interpreta como SQL.
query := s.db.Rebind(`SELECT … FROM raffles WHERE status = ? AND id = ?`)
s.db.GetContext(ctx, &r, query, status, id)

// ❌ Un solo caso de esto y el sistema es de quien lo encuentre.
query := "SELECT … FROM raffles WHERE status = '" + status + "'"
```

Con el segundo, un `status` igual a `open'; DROP TABLE sales; --` no es una
hipótesis de manual: es una tarde mala.

### La excepción, que hay que entender para no imitarla mal

El track **sí** concatena, exactamente una vez:

```go
// be02, en el UPDATE de raffles
`… updated_at = ` + s.db.Now() + ` WHERE id = ?`
```

Y es legítimo por una razón precisa: **`s.db.Now()` devuelve `"now()"` o
`"datetime('now')"`, dos constantes elegidas por un `if` sobre el dialecto**. El
valor no viene del usuario, no viene de la red, no viene de la base. No hay
entrada que envenenar.

> 🧭 **La regla que separa los dos casos, y conviene poder recitarla:** los
> **datos** van por placeholder, sin excepción; los **fragmentos de dialecto**
> pueden concatenarse **si y solo si** salen de un conjunto cerrado definido en el
> código. Un nombre de tabla que llega en un parámetro de query **no** es un
> fragmento de dialecto: es un dato.
>
> Y cuando de verdad necesites componer identificadores dinámicos —un `ORDER BY`
> configurable, por ejemplo—, la defensa es una **lista blanca**, nunca un
> escapado:
>
> ```go
> var orderable = map[string]string{"name": "name", "closesAt": "closes_at"}
> col, ok := orderable[r.URL.Query().Get("_sort")]
> if !ok { col = "id" }   // lo que no está en la lista, no existe
> ```

**Cómo comprobarlo en tu código:** `grep -rn "\" +\|fmt.Sprintf" internal/*/store*.go`.
Cada resultado tiene que poder justificarse con el párrafo de arriba.

---

## 2. Autorización a nivel de objeto

**Autenticación** es saber quién eres; **autorización** es saber si **esto** es
tuyo. `be04` resolvió la primera. La segunda está declarada como deuda 💸 y esta
sección explica exactamente qué falta.

El escenario, con nombres: el usuario 2 —Beto— pide
`PUT /raffles/7` sobre una rifa que creó otra persona. Hoy el backend **verifica
el token, ve que es un usuario válido, y le deja**. La rifa no tiene dueño y
nadie pregunta.

```go
// Lo que hay hoy: identidad verificada, propiedad no verificada.
userID := httpapi.UserIDFrom(ctx)   // ✅ sabemos quién es
if userID == 0 { return ErrUnauthenticated }
// ❌ y nadie pregunta si la rifa 7 es suya
```

**La defensa**, cuando el dominio la exija:

```sql
ALTER TABLE raffles ADD COLUMN owner_id BIGINT REFERENCES users(id);
```

```go
raffle, err := s.store.FindByID(ctx, id)
if err != nil { return err }
if raffle.OwnerID != httpapi.UserIDFrom(ctx) {
	// 404 y no 403, a propósito: un 403 confirma que el recurso existe.
	// Ver §4.
	return ErrNotFound
}
```

> ⚠️ **El error que se repite en todas partes:** verificar la propiedad **en el
> handler** y no en el servicio. Funciona en las cinco rutas que revisaste y falla
> —abierta— en la sexta, la que alguien agregó el mes pasado. La comprobación va
> donde vive la regla: **en el servicio**, junto a la transición de estado que
> `be04` ya custodia ahí.

**Cómo se prueba.** No hay atajo: una prueba por operación sensible, con dos
usuarios. Si el dominio tiene propiedad, esa suite es obligatoria, porque este
fallo **no produce ningún síntoma** hasta que alguien lo aprovecha.

---

## 3. Asignación masiva

Es el riesgo más subestimado de cualquier API que deserializa un cuerpo a un
struct. La pregunta: **¿qué campos del JSON puede fijar el cliente?**

En este dominio, tres campos son peligrosos y por motivos distintos:

| Campo | Si el cliente lo fija… |
|---|---|
| `status` | Salta el flujo: una rifa en borrador pasa a `settled` |
| `numberPrice`, `basePrize` | Cambia cuánto se cobra y cuánto se paga |
| `ownerId` (si existiera) | Se apropia de un recurso ajeno |

**Lo que ya protege el track**, y conviene ver que son tres capas distintas:

1. **Las transiciones custodiadas** (`be04`): el `status` que llega en el cuerpo
   se comprueba contra la tabla de transiciones legales. `draft → settled`
   devuelve `409`.
2. **El recálculo de montos** (`be07`): `totalCollected`, `prizeAmount` y `margin`
   **no se leen del cuerpo**. Se recalculan desde `sales`. La discrepancia se
   registra en el log y se ignora el valor del cliente.
3. **La identidad desde el contexto** (`be04`): un `ownerId` en el cuerpo se
   **ignora**, no se valida.

> 🧭 **La diferencia entre ignorar y validar, que no es sutil.** Validar un campo
> de identidad admite que a veces el cliente puede decidir quién es. Ignorarlo
> dice que nunca. Cuando el dato correcto ya lo tienes de otra fuente —el token,
> la base—, **el campo del cuerpo no se valida: se descarta**.

**Lo que falta**, y es una deuda 💸 real: `numberPrice` y `basePrize` sí se leen
del cuerpo en `PUT /raffles/:id`, porque el CRUD de la Fase 4 manda la rifa
entera. Un vendedor podría bajar el precio de una rifa ajena. La defensa es la
del §2 —propiedad— más una regla de dominio: **el precio no se cambia después de
la primera venta**.

```go
if len(sales) > 0 && incoming.NumberPrice != current.NumberPrice {
	return ErrPriceLocked   // 409: el estado del recurso no lo permite
}
```

📖 **La técnica general:** deserializa a un struct que **solo tenga los campos que
el cliente puede fijar**, no a la entidad del dominio. Si el struct no tiene
`OwnerID`, el JSON no puede fijarlo — y eso lo garantiza el compilador, no tu
memoria.

---

## 4. Qué filtra un mensaje de error

Cada mensaje que sale es información que le das a quien pregunta. Las cuatro
fugas de este dominio:

**Enumeración de cuentas.** Si el login distingue "ese email no existe" de
"contraseña incorrecta", acabas de regalar un verificador de cuentas válidas.
`be04` devuelve **el mismo error** para los dos casos, y `bcrypt.CompareHashAndPassword`
tarda lo mismo acierte o falle — porque la diferencia de tiempo también filtra.

**Existencia de recursos.** Un `403` sobre la rifa 7 confirma que existe; un `404`
no dice nada. Cuando la autorización falla por propiedad, **`404` es la respuesta
más discreta** (§2).

**Detalle interno en un `500`.** Lo que jamás debe salir:

```go
// ❌ pq: relation "raffles" does not exist  → le acabas de contar el motor,
//    el esquema y probablemente la versión
writeError(w, 500, err.Error())

// ✅ el detalle al log con su request-id; al cliente, lo mínimo
log.Printf("[req-id %s] %v", RequestIDFrom(ctx), err)
writeError(w, 500, "Error interno del servidor")
```

> 🧠 **La asimetría es deliberada y es buen diseño:** el servidor sabe qué pasó,
> el cliente no. Y el `X-Request-Id` es lo que permite que un usuario reporte
> "me salió un error, id `9f3a…`" y que tú encuentres el detalle exacto sin
> haberlo publicado (`be-a-07`).

**Y la fuga del ejemplo perfecto:** en `be06`, el `409` de rifa cerrada. El
mensaje al cliente es *"La rifa ya cerró: no se pueden vender más números"*. El
log dice *"cerró a las 22:00-05:00 y ahora son las 22:03-05:00"*. Diagnóstico
completo dentro, información mínima fuera.

> ⚠️ Y un caso menos obvio: los mensajes de error del track **están en español y
> son legibles** porque los muestra `toReadableError` al usuario final. Eso es
> contrato (`be00`) y está bien. Lo que no puede pasar es que ese mensaje incluya
> un identificador interno, un nombre de columna o una ruta de archivo.

---

## 5. Límites de tasa

El track **no** los tiene, y hay tres sitios donde harían falta:

| Dónde | Qué evita |
|---|---|
| `POST /login` | Probar contraseñas indefinidamente |
| `POST /…/sell` | Un guion acaparando el tablero entero |
| `POST /…/reserve` | Un usuario reservando todos los números y no comprando ninguno |

El del login es el más grave, porque hoy **puedes probar contraseñas todo el
día**. `bcrypt` con costo 10 hace cada intento lento, y eso es una mitigación
real — pero también significa que un atacante paralelo consume tu CPU, que es
otra forma del mismo problema.

Un limitador mínimo con la biblioteca estándar más `golang.org/x/time/rate`
—que el track no incorpora para no sumar dependencia— cabe en veinte líneas. Lo
importante no es la implementación, son las tres decisiones:

- **¿Por qué se agrupa?** Por IP es lo fácil y castiga a oficinas enteras tras un
  NAT. Por email en el login es más justo y permite que alguien bloquee la cuenta
  de otro. Lo habitual es combinar.
- **¿Qué se devuelve?** `429 Too Many Requests` con `Retry-After`. ⚠️ Ojo: el
  frontend heredado **no sabe manejar un `429`** y lo mostraría como error
  genérico. Otra cosa que el contrato condiciona.
- **¿Dónde vive el contador?** En memoria no sobrevive a un reinicio ni se
  comparte entre réplicas. Compartirlo exige un almacén — y ahí la defensa deja de
  ser gratis.

---

## 6. CORS bien entendido

De todo lo de este apéndice, **es lo que más se malinterpreta**, así que vale la
pena decirlo sin rodeos:

> 🧭 **CORS no protege tu API. CORS protege al usuario del navegador.**
>
> Es una política que **el navegador** aplica sobre las respuestas que recibe. Un
> `curl`, un guion en Python, Postman o cualquier cliente que no sea un navegador
> **la ignoran por completo**. Tu backend con `Access-Control-Allow-Origin`
> restringido sigue respondiendo a todo el mundo.

Compruébalo, que se entiende en diez segundos:

```bash
# Origen no permitido, y responde igual. CORS no rechaza nada del lado del
# servidor: solo omite el header, y es el NAVEGADOR el que descarta.
curl -i localhost:3001/raffles -H 'Origin: http://evil.example' \
     -H "Authorization: Bearer $TOKEN"
```

**Lo que CORS sí hace:** impedir que una página en `evil.example` lea, **con las
credenciales del usuario**, respuestas de tu API desde el navegador de ese
usuario. Eso es valioso y no es poco. Pero no es control de acceso.

**Lo que CORS no hace, y que la gente cree que hace:**

- No sustituye a la autenticación. La autenticación es el `Bearer` de `be04`.
- No impide que nadie llame a tu API desde fuera de un navegador.
- No protege contra CSRF por sí solo. (Este sistema no es vulnerable a CSRF por
  otro motivo: el token va en un header que solo el JavaScript de tu propio
  origen puede poner, no en una cookie que el navegador mande sola.)

**La configuración del track**, con cada línea justificada:

```go
w.Header().Set("Access-Control-Allow-Origin", allowedOrigin)  // el 3000, no "*"
w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
w.Header().Set("Access-Control-Allow-Headers", "Authorization, Content-Type, X-Request-Id")
w.Header().Set("Access-Control-Expose-Headers", "X-Request-Id")  // C-05
```

> ⚠️ **`*` y credenciales no conviven**, y es una regla del propio estándar: con
> `Access-Control-Allow-Credentials: true`, el navegador **rechaza** un
> `Allow-Origin: *`. Este sistema no usa cookies —el token va en un header— así
> que no necesita credenciales, pero el día que alguien mueva el token a una
> cookie `HttpOnly` (ejercicio 30 de `be04`), esta línea deja de ser opcional.
>
> Y el origen sale de configuración (`ALLOWED_ORIGIN`), nunca escrito a mano:
> `be09` §4.3 le da un valor distinto por ambiente.

---

## 7. 🚫 Lo que este backend NO cubre

La sección más importante del apéndice. **Este es un laboratorio de curso y no un
backend de producción.** Lo que sigue no son descuidos: son ausencias declaradas,
y saber enumerarlas es parte de lo que el track enseña.

| No hay | Consecuencia | Dónde se discute |
|---|---|---|
| **Autorización a nivel de objeto** | Cualquier usuario puede editar cualquier rifa | §2, `be04` |
| **Límites de tasa** | Fuerza bruta sin freno sobre el login | §5 |
| **HTTPS** | Todo viaja en claro; el token es interceptable | Se resuelve fuera del proceso, en un proxy |
| **`sslmode=require` en desarrollo** | El tráfico a la base va en claro | `be02`, `be09` §4.3 |
| **Rotación de secretos** | `JWT_SECRET` es fijo; rotarlo invalida todas las sesiones | `be09` |
| **Revocación de tokens** | Un token robado sirve hasta su `exp` | `be-a-04` §5 |
| **Gestor de secretos** | Variables de entorno y ya | `be09` |
| **Auditoría de accesos** | Se registra quién vendió, no quién consultó qué | `be07` |
| **Validación de longitud de entrada** | Un `name` de 10 MB entra sin problema | Ejercicio 10 de `be01` |
| **`POST /_chaos` fuera de producción** | Un endpoint para romper tu propio sistema | `be09` §4.3, ejercicio 24 |
| **Cabeceras de seguridad** (`HSTS`, `X-Content-Type-Options`…) | Van en el proxy, no en la API | — |

> 🧠 **Y la que más conviene tener presente:** el propósito del track es enseñar a
> **reemplazar un backend sin romper a su cliente**, no a construir un backend
> endurecido. Cada ausencia de esta tabla es una decisión de alcance, está escrita,
> y `be-a-09` la recoge en el mapa de deuda con su criterio de exigibilidad.
>
> Si algún día llevas este código a algo real, **esta tabla es tu lista de
> pendientes**, en este orden: HTTPS, límites de tasa en el login, autorización a
> nivel de objeto, y sacar el caos del binario.

---

## 🧩 Cuándo usar qué

| Si el riesgo es… | La defensa es… | Y **no** |
|---|---|---|
| Inyección SQL | Placeholders, siempre | Escapar a mano |
| Un identificador dinámico en el SQL | Lista blanca | Escapar el nombre |
| Alguien tocando lo ajeno | Propiedad verificada **en el servicio** | Verificar en cada handler |
| El cliente fijando `status` o precio | Un struct de entrada con solo lo permitido | Validar la entidad entera |
| El cliente fijando identidad | **Ignorar** el campo; usar el contexto | Validarlo |
| Enumerar cuentas | El mismo error y el mismo tiempo | Mensajes "útiles" |
| Filtrar el esquema en un `500` | Detalle al log, genérico al cliente | `err.Error()` en la respuesta |
| Confirmar que un recurso existe | `404` en vez de `403` | `403` |
| Fuerza bruta | Límite de tasa | Confiar en que `bcrypt` es lento |
| Una página ajena leyendo tu API | CORS restringido | Creer que eso te protege del resto |
| Un cliente que no es navegador | **Autenticación** | CORS |

---

## 🧪 Ejercicios (9)

1. **🟢** Recorre los stores con `grep` buscando concatenación en consultas y justifica cada resultado con la regla del §1.
2. **🟢** Comprueba con `curl` que `POST /login` devuelve el mismo error y tarda parecido con un email inexistente y con una contraseña incorrecta.
3. **🟡 Diagnóstico.** Manda un `PUT /raffles/1` con un `ownerId` y un `status` inventados. Determina qué hace el backend con cada uno y por qué son casos distintos.
4. **🟡** Comprueba con `curl` y un `Origin` no permitido que la API responde igual. Explica en tres líneas qué protege CORS entonces.
5. **🟠** Implementa la propiedad del §2: columna `owner_id`, comprobación en el servicio, y una prueba con dos usuarios por cada operación sensible.
6. **🟠 Diagnóstico.** Haz que un `500` devuelva `err.Error()` al cliente, provoca un error de base, y anota exactamente cuánta información acabas de publicar.
7. **🟠** Implementa la regla de `ErrPriceLocked` del §3 y demuestra con una prueba que el precio no cambia después de la primera venta.
8. **🔴** Implementa un límite de tasa en `POST /login`, decide las tres cuestiones del §5 y documenta qué pasa en el frontend heredado cuando recibe un `429`.
9. **🔴** Escribe la evaluación de riesgo de este backend como si fuera a producción mañana: toma la tabla del §7, ordénala por riesgo real para **este** dominio, y estima el esfuerzo de cada mitigación. Es el insumo directo de `be-a-09`.

---

## 📚 Referencias

**Documentación oficial y guías**
- https://owasp.org/API-Security/editions/2023/en/0x11-t10/ — el top 10 de seguridad de APIs. El §2 es "Broken Object Level Authorization", que es el primero de la lista por algo.
- https://cheatsheetseries.owasp.org/cheatsheets/Mass_Assignment_Cheat_Sheet.html — el §3.
- https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html — el §1, incluida la lista blanca para identificadores.
- https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html — el §4.
- https://developer.mozilla.org/es/docs/Web/HTTP/CORS — el §6, y la parte de "solicitudes con credenciales" es la que casi nadie lee.
- https://fetch.spec.whatwg.org/#cors-protocol — la especificación, para cuando MDN no baste.
- https://pkg.go.dev/golang.org/x/time/rate — el limitador del §5, si decides incorporarlo.

**Libros**
- *API Security in Action* (Neil Madden) — el mejor libro sobre este tema, y su capítulo de autorización cubre el §2 mucho mejor que cualquier resumen.
- *Web Application Security* (Andrew Hoffman) — más introductorio y muy claro sobre por qué cada ataque funciona.

**Video / apoyo**
- Busca "BOLA broken object level authorization" y "CORS explained properly". Para lo segundo, desconfía de cualquier video que presente CORS como un mecanismo de seguridad del servidor: es la confusión del §6.

**Orden de lectura sugerido:** el §7 primero —saber qué **no** cubre el sistema
antes que cómo cubre lo demás— → el §6, porque es lo que más gente tiene mal → el
top 10 de OWASP API para ponerle nombre a cada riesgo → y `be-a-04` para todo lo
que sea tokens.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las guías de
> OWASP se reeditan y sus números cambian entre ediciones. Las referencias a
> libros y videos son de memoria y pueden ser inexactas. La fuente de verdad de
> versiones es `prompts/decisiones-y-versiones.md` §7.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura. Si implementas la
> propiedad del §2 o el límite del §5, van como ejercicios de `be04`
> (`be04 ej…`), según
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
FIN_DEL_ARCHIVO
wc -l be-a-08-seguridad-de-api-aplicada.md; ls be-a-*.md | wc -l

# --- 2026-09-09T04:11:19 · Read be-a-09/10 prompts and A12 structure
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; sed -n '/## Apéndice be-a-09/,$p' $R/prompts/prompts-backend-apendice.md | grep -v "^Actúa\|^orden:\|^(4)\|^(6)\|^prompts/\|^00-alcance" | head -70; echo "=== A12 estructura ==="; grep -n "^#\|^##\|exigible" $R/A12-mapa-de-deuda-tecnica.md | head -30

# --- 2026-09-09T04:11:26 · Read A12 entry format precisely
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; sed -n '26,60p' $R/A12-mapa-de-deuda-tecnica.md; echo "=== una entrada completa ==="; sed -n '56,72p' $R/A12-mapa-de-deuda-tecnica.md

# --- 2026-09-09T04:14:00 · 
cat > be-a-09-mapa-de-deuda-del-track-be.md <<'FIN_DEL_ARCHIVO'
# 💸 Apéndice be-a-09 — Mapa de deuda del track BE

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~2 horas
> Lo referencia `be09`; **cualquier fase que declare una deuda 💸 la registra acá**

---

Este es el hermano de `A12`. Misma estructura, mismo criterio, otra capa: allá la
deuda del frontend, acá la del backend.

Cada entrada tiene las mismas cuatro partes, y **la tercera es la que importa**:

- **Qué se hizo en su lugar** — lo que está en el código hoy.
- **Por qué se dejó** — el razonamiento de quien decidió. Sin esto la entrada es
  inútil: dentro de un año nadie recordará si fue criterio o pereza.
- **Qué la vuelve exigible** — el **disparador**. La condición concreta que
  convierte esta deuda en un bug con fecha.
- **Fase** — dónde está documentada en detalle.

> 🧭 **El trabajo no es pagar todo: es vigilar los disparadores.** Mientras el
> disparador no ocurra, pagar la deuda es trabajo sin retorno — peor, es *riesgo*
> sin retorno, porque estás tocando código que funciona.

Y el tono, que en este apéndice importa tanto como el contenido: **una deuda
declarada y medida es una decisión de ingeniería; una deuda oculta es un
problema.** Nada de lo que sigue es un descuido, y nada de lo que sigue merece
autoflagelación.

---

## 🧭 Índice de salto rápido

1. [Las dos que el track decide NO pagar](#1-las-dos-que-el-track-decide-no-pagar)
2. [Identidad y seguridad](#2-identidad-y-seguridad)
3. [Datos y consistencia](#3-datos-y-consistencia)
4. [Operación](#4-operación)
5. [Andamiaje del curso](#5-andamiaje-del-curso)
6. [La que no se puede pagar](#6-la-que-no-se-puede-pagar)
7. [✅ Las que ya se pagaron](#7--las-que-ya-se-pagaron)
8. [🧩 Cuándo usar qué: el orden si esto fuera a producción](#-cuándo-usar-qué-el-orden-si-esto-fuera-a-producción)

---

## 1. Las dos que el track decide NO pagar

Van juntas y aparte del resto, porque **tienen la misma causa** y separarlas
oscurecería lo único interesante de las dos: no se dejaron por falta de tiempo,
se dejaron por una regla.

> 🧭 **La regla que ordena el track:** el frontend heredado no se toca. La única
> excepción está negociada, escrita y acotada a un archivo (`D27`). Estas dos
> deudas se pagarían tocando el frontend, y ampliar la excepción una segunda vez
> la convertiría en una licencia general.

### 💸 Sin *refresh token*: el JWT vence y el usuario cae al login

**`be04`.** El token tiene vida larga en el laboratorio (`JWT_TTL`, 12 h) y corta
en UAT y producción (1 h). Cuando vence, el interceptor de la Fase 2 recibe un
`401`, dispara el logout global, y el usuario pierde lo que estuviera haciendo.

Se dejó porque implementar renovación exige que **el cliente** llame a un
endpoint nuevo: tocar `apiClient.js`, sus dos interceptores y probablemente
`authSlice.js`. Eso es media capa de red del frontend, no un archivo.

**Se vuelve exigible** en cuanto el sistema tenga usuarios reales trabajando
sesiones largas —un día de ventas dura más de una hora— o el día que se pueda
tocar el frontend. El diseño completo está en el ejercicio 31 de `be04`; el
apéndice `be-a-04` §5 explica por qué un JWT no se puede revocar y qué cuesta
cada alternativa.

### 💸 El frontend se pinta con el reloj del navegador

**`be06`.** El servidor ya es la autoridad temporal: rechaza toda venta posterior
a `closesAt` y publica su hora en `X-Server-Time`. Pero la interfaz sigue
calculando `isPastClosing` contra `new Date()`, o sea contra el reloj del
usuario.

Consecuencia medida, y no es simétrica: con el reloj **adelantado**, la UI cierra
antes de tiempo y el usuario **pierde una venta legítima**; con el reloj
**atrasado**, la UI ofrece el botón y el backend responde `409` — mensaje confuso,
**datos correctos**.

Se dejó por la misma razón que la anterior. Y se hizo **la mitad barata**: el
header ya viaja. Pagar la otra mitad son unas treinta líneas —un interceptor que
guarde el desfase y una función `serverNow()` que lo aplique— repartidas en
`apiClient.js` y `closing.js`. El ejercicio 27 de `be06` pide medirlo de verdad.

**Se vuelve exigible** cuando aparezca el primer reporte de *"me cerró la rifa
antes de tiempo"* que no sea un error del servidor. Hoy ese caso deja rastro en
el log (`be06` §5.4), que es exactamente lo que lo hace diagnosticable en dos
minutos en vez de en una tarde.

> 🧠 **Y lo que estas dos enseñan, que vale más que su solución:** decidir **no**
> pagar una deuda y escribir por qué es una forma perfectamente respetable de
> administrarla. Muy superior a pagarla a escondidas, saltándose la regla que el
> equipo acordó.

---

## 2. Identidad y seguridad

### 💸 Sin autorización a nivel de objeto

**`be04`, detallada en `be-a-08` §2.** Cualquier usuario autenticado puede editar,
cerrar o liquidar **cualquier** rifa. Las rifas no tienen dueño: no hay columna
`owner_id` y nadie pregunta. Lo único que existe es la línea de log que registra
quién hizo el cambio.

Se dejó porque el dominio del curso no tiene el concepto de propiedad —la Fase 4
del track base crea rifas sin autor— e inventarlo habría cambiado el contrato de
`be00`. Añadirlo del lado del servidor sin que el frontend lo mande es posible
(el `owner_id` saldría del token), pero no había regla de negocio que lo pidiera.

**Se vuelve exigible** el día que haya más de un vendedor con intereses
distintos, o el primer requisito del tipo *"que Beto no pueda liquidar las rifas
de Ana"*. La defensa está diseñada en `be-a-08` §2, cuesta una migración y una
comprobación en el servicio, y **exige una prueba por operación sensible** porque
este fallo no produce ningún síntoma hasta que alguien lo aprovecha.

### 💸 Sin límite de intentos en `POST /login`

**`be04`, detallada en `be-a-08` §5.** Se pueden probar contraseñas
indefinidamente. La única mitigación es que `bcrypt` con costo 10 hace cada
intento lento — lo que también significa que un atacante paralelo consume tu CPU.

Se dejó porque un limitador serio necesita decidir por qué se agrupa (IP, email o
los dos) y dónde vive el contador, y la respuesta cambia si hay más de una
réplica. Nada de eso enseñaba algo sobre reemplazar un mock.

**Se vuelve exigible** con el primer despliegue accesible desde fuera de una red
de confianza. ⚠️ Y hay una trampa que hay que resolver antes: el frontend
heredado **no sabe manejar un `429`** y lo mostraría como error genérico.

### 💸 `numberPrice` y `basePrize` se leen del cuerpo del `PUT`

**Descubierta al escribir `be-a-08` §3.** El CRUD de la Fase 4 manda la rifa
entera en cada `PUT`, así que el precio del número y el premio base llegan desde
el cliente y se guardan. Combinado con la deuda anterior —sin propiedad—, un
vendedor podría bajar el precio de una rifa ajena.

Se dejó porque rechazar esos campos rompería el `PUT` del contrato, que manda la
entidad completa. La defensa correcta no es rechazar: es **una regla de dominio**
—el precio no cambia después de la primera venta— que el servicio puede aplicar
sin que el cliente se entere.

**Se vuelve exigible** junto con la propiedad, o antes si aparece cualquier
auditoría de recaudo. La implementación es el ejercicio 7 de `be-a-08`
(`ErrPriceLocked`) y cuesta seis líneas.

### 💸 El token vive en `localStorage`

**Heredada de la Fase 2, y no se puede pagar desde acá.** Es accesible por
cualquier script de la página, así que un XSS se lleva la sesión. La alternativa
—una cookie `HttpOnly`— cambia el vector (protege de XSS, abre CSRF) y **exige
tocar el frontend**.

**Se vuelve exigible** con el primer hallazgo de XSS, o con cualquier requisito
de cumplimiento que lo prohíba explícitamente. Está también en `A12` del track
base, desde la otra orilla; el análisis completo es el ejercicio 30 de `be04`.

### 💸 `JWT_SECRET` sin rotación

**`be09`.** El secreto se inyecta por variable de entorno y no rota nunca.
Rotarlo hoy invalida **todas** las sesiones de golpe.

Se dejó porque rotar en caliente exige aceptar dos secretos a la vez durante una
ventana —verificar con el viejo y el nuevo, firmar solo con el nuevo— y eso es
código que no enseña nada sobre el reemplazo del mock.

**Se vuelve exigible** ante la primera sospecha de filtración, que es
precisamente el momento en que **no** quieres estar diseñando la rotación. Es la
clase de deuda que conviene pagar antes de necesitarla.

---

## 3. Datos y consistencia

### 💸 `sales` es inmutable por convención, no por permisos

**`be07`, ejercicio 23.** Nada impide que alguien con acceso a la base haga
`DELETE FROM sales`. La inmutabilidad del registro de ventas —sobre el que se
calcula todo el dinero— es un acuerdo, no una restricción.

Se dejó porque hacerla cumplir de verdad requiere separar roles de base de datos:
un rol de aplicación sin `DELETE` ni `UPDATE` sobre esa tabla, y un rol de
migración aparte. Es correcto y es una conversación de operación, no de código.

**Se vuelve exigible** en cuanto el dinero de este sistema sea real, o cuando
haya más de una persona con credenciales de producción. La consulta de auditoría
del ejercicio 22 de `be07` detecta el descuadre **después**; los permisos lo
impiden **antes**.

### 💸 Sin mecanismo de corrección de una liquidación errónea

**`be07`, ejercicio 27.** Si una liquidación queda mal, no hay forma prevista de
arreglarla: la tabla es inmutable y el `UNIQUE (raffle_id)` impide crear otra.

Se dejó porque el diseño correcto —asientos de compensación, como lleva
haciéndose en contabilidad cuatrocientos años— es un modelo de datos entero, y el
curso no tiene el caso de uso.

**Se vuelve exigible** con la primera liquidación errónea. Y llegará: el
ejercicio 28 de `be07` es exactamente ese ticket.

### 💸 Sin comprobación de desbordamiento en el cálculo del recaudo

**`be07`, ejercicio 24.** `soldCount * numberPrice` en `int64` desborda en
silencio: el número da la vuelta y queda negativo, sin excepción y sin aviso.

Se dejó porque con `BIGINT` el margen es enorme —unos 92 mil billones de
centavos— y llegar ahí requiere datos absurdos. Pero *silencio* es la palabra
incómoda: en JavaScript habrías perdido precisión de forma más ruidosa.

**Se vuelve exigible** con datos generados por un faker sin cotas (`be-a-10`), o
con cualquier moneda de subdivisión muy pequeña. La comprobación con
`math/bits.Add64` cuesta cuatro líneas.

### 💸 Los *workers* corren en todas las réplicas

**`be05` y `be06`, ejercicio 26 de `be05`.** El que vence reservas y el que cierra
rifas por reloj corren en cada proceso. No rompen nada —los dos son `UPDATE`
idempotentes y la segunda ejecución afecta cero filas— pero es trabajo repetido, y
el patrón sí haría daño en operaciones que no fueran idempotentes.

**Se vuelve exigible** al pasar de una réplica, o el día que alguien agregue un
tercer *worker* sin darse cuenta de que el patrón no protege. La solución es un
`pg_advisory_lock` y son diez líneas.

### 💸 Sin límite de reservas por usuario

**`be05`.** Un solo usuario puede reservar el tablero entero y no comprar nada.
Las reservas vencen solas desde `be05`, así que el daño es temporal, pero durante
la ventana el resto no puede vender.

**Se vuelve exigible** con el primer uso adversarial, o con cualquier rifa donde
la escasez importe.

---

## 4. Operación

### 💸 `sslmode=disable` en desarrollo

**`be02`.** El tráfico a la base va en claro. Es correcto en un laboratorio local
y sería un hallazgo en cualquier otra parte. `be09` §4.3 ya fija `require` para
QA, UAT y producción, así que **la deuda es solo de desarrollo**.

**Se vuelve exigible** en cuanto la base de desarrollo deje de ser `localhost` —
un Postgres compartido en la red de la oficina, por ejemplo.

### 💸 Las migraciones se aplican a mano en desarrollo

**`be02` y `be09`.** En desarrollo se corre `migrate up` cuando toca. `be09`
resolvió la parte que importa —el servidor **no** migra, comprueba la versión y se
niega a arrancar si no coincide— así que lo que queda es incomodidad, no riesgo.

**Se vuelve exigible** con el primer *"a mí me funciona"* causado por una
migración que alguien no corrió. El mensaje de arranque ya lo hace obvio, que es
media solución.

### 💸 Log de texto en vez de estructurado

**`be01`, discutida en `be-a-07` §3.** `log.Printf` con el id delante. Es
grepeable y legible en una terminal, y no se puede filtrar por campos ni agregar.

Se dejó por coherencia de época: `log/slog` es de Go 1.21 y este código es de
2022 (`D14`). Y porque una línea legible enseña mejor.

**Se vuelve exigible** en cuanto los logs los lea una máquina —un colector, un
buscador, un panel—. El logger JSON de veinticinco líneas está escrito en
`be-a-07` §3: la deuda ya tiene su pago redactado.

### 💸 Sin métrica agregada del desfase de reloj

**`be06`, ejercicio 23.** El desfase cliente-servidor se registra línea por línea,
así que responde *"¿qué pasó con esta petición?"* pero no *"¿cuántos usuarios
tienen el reloj mal?"*.

**Se vuelve exigible** cuando haya que decidir si vale la pena pagar la deuda del
§1, porque ese número es justamente el argumento.

### 💸 Sin `HTTPS`

**`be09`, en la tabla de `be-a-08` §7.** El token viaja en claro. Se resuelve
fuera del proceso, en un proxy, y por eso el track no lo trata.

**Se vuelve exigible** con el primer despliegue fuera de `localhost`. **Sin
excepciones**: es la primera de la lista del §8.

---

## 5. Andamiaje del curso

Estas existen **porque esto es un curso**. En un sistema real no serían deuda:
serían un error.

### 💸 `POST /_chaos` en el binario de producción

**`be01` y `be09`, ejercicio 24 de `be09`.** Un endpoint para romper tu propio
sistema, apagado por defecto pero **presente**. `CHAOS_LEVEL=off` no basta: si el
código está en el binario, existe.

Se dejó porque las prácticas de las fases 3 y 7 del track base lo usan tal cual, y
`D22` obliga a conservarlo.

**Se vuelve exigible** en el primer despliegue a un ambiente accesible. La
solución está escrita y es una etiqueta de compilación: `-tags chaos` para el
laboratorio, nada en producción.

### 💸 `server/smoke.sh` ensucia los datos

**`be00`.** La verificación de venta duplicada deja el número `1500` vendido. Hay
que restaurar el `db.json` o reservar un número de pruebas.

**Se vuelve exigible** cuando alguien lo corra contra un ambiente compartido. La
suite de contrato de `be08` ya tiene sus propios datos y su truncado; **portar el
guion a esa disciplina es el pago**.

### 💸 El contenedor de pruebas se levanta a mano

**`be08`.** Un `docker run` desde un guion. `testcontainers-go` lo automatizaría a
cambio de una dependencia y de un arranque más lento por caso.

**Se vuelve exigible** cuando alguien nuevo pierda una tarde porque olvidó
levantarlo. El mensaje de `OpenPostgres` ya nombra el comando, que es media
solución.

### 💸 Sin medición de cobertura en CI, **a propósito**

**`be08`.** Se puede medir con `go test -cover`, pero no hay umbral ni puerta en
el pipeline.

Se dejó **deliberadamente**, y por un argumento que el track defiende: la
cobertura mide líneas ejecutadas, no propiedades verificadas. El `SellNumber` de
`be03` tenía cobertura completa y el bug de la venta duplicada intacto. Un umbral
en CI convierte la cobertura en un objetivo, y un objetivo se cumple escribiendo
pruebas que ejecutan código sin afirmar nada.

**Se vuelve exigible** nunca, en esta forma. Lo que sí valdría la pena es medir
qué **no** ejecuta nadie, o pruebas de mutación (ejercicio 🔥 de `be08`).

### 💸 `GET /stats` no existe

**Pendiente 🔥 de `be09`.** El dashboard de la Fase 9 calcula sus métricas en el
navegador. Ninguna fase depende de este endpoint y el `smoke.sh` no lo exige.

**Se vuelve exigible** cuando el volumen haga inviable calcularlas en el cliente —
con veinte mil ventas ya se nota— o cuando alguien más necesite las mismas cifras.

---

## 6. La que no se puede pagar

### 🪦 El `sold_by` de las ventas históricas

**`be05`.** Al crear la tabla `sales`, las ventas que ya existían se migraron
atribuidas al usuario 1, porque **su autoría real no existe**: se hicieron cuando
el backend no preguntaba quién vendía. Esa era, precisamente, la tercera deuda que
`be04` pagó.

No hay disparador y no hay pago posible. El dato no está en ninguna parte y no se
puede reconstruir. Lo único que se puede hacer —y se hizo— es **no esconderlo**:
está marcado en la migración y está acá.

> 🧠 **Vale la pena que este mapa tenga una entrada así.** No toda deuda se paga;
> algunas solo se documentan para que nadie construya encima creyendo que el dato
> es fiable. Una consulta de auditoría que agrupe ventas por vendedor **mentirá**
> sobre el periodo anterior a `be05`, y quien la escriba tiene derecho a saberlo.

---

## 7. ✅ Las que ya se pagaron

El track no solo declaró deuda: cobró la mitad. Esta lista está acá porque el
ciclo completo —declarar, fechar, pagar— es lo que hace creíble a un mapa de
deuda.

| Deuda | Declarada en | Pagada en |
|---|---|---|
| Contraseñas comparadas en claro | Fase 2 → `be02` | `be04` (`bcrypt`) |
| El token como constante de texto | Fase 2 → `be03` (columna `users.token`) | `be04` (JWT firmado, columna borrada) |
| El cliente decide quién es | Fase 2 | `be04` (`req.Context()`) |
| Transiciones de estado libres | Fase 4 | `be04` (custodiadas en el servicio) |
| El `409` producido por un `if` | Fase 3 → `be03` | `be05` (índice único + transacción) |
| Reservas sin expiración en el servidor | Fase 5 | `be05` (`reserved_until` + *worker*) |
| La hora de cierre la evalúa el navegador | Fase 7 | `be06` (autoridad del servidor) |
| `settledAt` fijado por el cliente | `be03` | `be06` (sellado por el servidor) |
| La aritmética de dinero solo en el frontend | Fase 8 | `be07` (recálculo desde `sales`) |
| `db.json` como almacén | Fase 3 | `be03` 🪦 |
| Configuración con `os.Getenv` sin validar | `be01` | `be03` (`envconfig`) |
| El `X-Request-Id` que nace y muere en el mock | Fase 2 | `be01` (viaja por `context`) |
| `C-05`: el header que no se podía leer | `be00` | `be01` (`Expose-Headers`) |
| `C-01`: la ruta que el frontend llamaba al vacío | `be00` | `be03` |
| `D19`: la cuestión cgo | `be02` | `be09` (etiqueta de compilación) |

---

## 🧩 Cuándo usar qué: el orden si esto fuera a producción

Si mañana hubiera que llevar este backend a un sistema real, **este es el orden**,
y el criterio es riesgo dividido por esfuerzo, no elegancia:

| # | Qué | Por qué primero | Esfuerzo |
|---|---|---|---|
| 1 | **HTTPS** | Sin esto, todo lo demás es decorativo: el token viaja en claro | Un proxy. No toca el código |
| 2 | **Sacar `/_chaos` del binario** | Un endpoint para romperse a sí mismo, expuesto | Una etiqueta de compilación |
| 3 | **Límite de tasa en el login** | Fuerza bruta sin freno | Bajo, con la salvedad del `429` |
| 4 | **Autorización a nivel de objeto** | Cualquiera toca lo de cualquiera | Medio: migración, servicio y **una prueba por operación** |
| 5 | **Permisos sobre `sales`** | El dinero se calcula sobre una tabla que cualquiera puede borrar | Bajo: roles de base |
| 6 | **Rotación de `JWT_SECRET`** | Diseñarla ante una filtración es el peor momento | Medio |
| 7 | **`serverNow` en el frontend** | Ventas legítimas perdidas por relojes desfasados | ~30 líneas, **pero rompe la regla del track** |
| 8 | ***Refresh token*** | Sesiones cortadas a mitad del trabajo | Alto, y toca el frontend |
| 9 | **Log estructurado** | Cuando los lea una máquina | Bajo: ya está escrito en `be-a-07` |
| 10 | **Corrección de liquidaciones** | Hasta que haya una mal, no urge | Alto: modelo de datos |

> 🧭 **Fíjate en los tres primeros.** Ninguno toca la lógica de negocio, los tres
> cuestan poco, y los tres son más urgentes que cualquier refactorización. Es lo
> habitual: **la deuda que más riesgo quita casi nunca es la que más incomoda al
> escribir código.**

### Cómo se mantiene este archivo

- **Una deuda nueva se registra acá el día que se declara**, no "cuando haya
  tiempo". Una fase que marque 💸 sin entrada en este mapa deja el mapa
  incompleto, y un mapa incompleto no se consulta.
- **Cuando una deuda se paga, se mueve al §7** con la fase que la pagó. No se
  borra: el historial es lo que hace creíble al inventario.
- **Si un disparador ocurre**, la entrada deja de ser deuda y pasa a ser un bug
  con fecha. Sácala de acá y ponla donde vayan los bugs.
- **Revisa los disparadores, no las entradas.** Leer este archivo entero cada seis
  meses no sirve; preguntarse *"¿ha pasado alguno de los diez disparadores?"*, sí.

---

## 🧪 Ejercicios (6)

1. **🟢** Recorre las diez fases buscando el marcador 💸 y comprueba que cada una tiene su entrada acá. Si falta alguna, agrégala con las cuatro partes.
2. **🟡** Para tres entradas a tu elección, escribe el **test que fijaría el comportamiento actual como esperado**. Después argumenta si ese test convierte la deuda en deliberada o si solo la congela.
3. **🟡 Diagnóstico.** Toma la tabla del §7 y verifica en el código que cada deuda pagada está de verdad pagada. La columna `users.token`, en particular: si sigue existiendo, `be04` no cerró.
4. **🟠** Estima en horas el pago de las diez entradas del §8 y reordénalas por riesgo dividido por esfuerzo. Si tu orden difiere del propuesto, defiende el tuyo.
5. **🟠** Elige un disparador y **provócalo** en el laboratorio: levanta dos réplicas y observa a los dos *workers* haciendo el mismo trabajo, o crea un segundo usuario y edita con él una rifa ajena. Documenta el síntoma exacto.
6. **🔴** Escribe la entrada que falta: encuentra una deuda del backend que ninguna fase declaró, con evidencia, y redáctala con las cuatro partes. Pista: mira los `TODO`, los valores fijos en el código y cualquier `interface{}`.

---

## 📚 Referencias

**Del propio curso**
- `A12-mapa-de-deuda-tecnica.md` — el hermano de este apéndice, con la deuda del frontend. Léelos juntos: varias entradas son la misma deuda vista desde las dos orillas.
- `be-a-08` §7 — la lista de lo que este backend no cubre a propósito, que es este mapa desde el ángulo de seguridad.
- `server/VEREDICTO.md` (`be09`) — el cierre honesto del track, donde estas deudas se resumen para alguien que decide si vale la pena.

**Externas**
- https://martinfowler.com/bliki/TechnicalDebtQuadrant.html — los cuatro cuadrantes (deliberada/inadvertida × prudente/imprudente). Casi todo lo de este mapa es deliberada y prudente, y saber nombrarlo ayuda a defenderlo.
- https://martinfowler.com/bliki/TechnicalDebt.html — la metáfora original y sus límites.
- https://www.agilealliance.org/introduction-to-the-technical-debt-concept/ — un resumen corto y sensato.

**Libros**
- *Working Effectively with Legacy Code* (Michael Feathers) — la distinción entre código que funciona y código que se puede cambiar, que es lo que este mapa mide.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros son de memoria y pueden ser inexactas.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura, y es **un documento
> vivo**: se actualiza cada vez que una fase declara o paga una deuda. Los
> commits que lo modifiquen llevan el prefijo de la fase que motivó el cambio
> (`be05: registra la deuda del worker en varias réplicas`), según
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
FIN_DEL_ARCHIVO
wc -l be-a-09-mapa-de-deuda-del-track-be.md

# --- 2026-09-09T04:15:50 · 
cat > be-a-10-datos-de-prueba-y-faker.md <<'FIN_DEL_ARCHIVO'
# 🎲 Apéndice be-a-10 — Datos de prueba y faker 🔥

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~2 horas
> **Opcional dentro de un track ya opcional.** Lo referencian: `be03` (ejercicio 🔥 de volumen), `be05` y `be08`

---

Este apéndice existe por una razón práctica y una lección.

**La razón práctica:** las mediciones de `be05` —contención con 50 vendedores— y
de `be08` —índices, tiempos de consulta— **no dicen nada con dos rifas y cuatro
números**. Hace falta volumen, y cincuenta rifas con veinte mil números no se
escriben a mano.

**La lección**, que es lo que de verdad justifica el apéndice y conviene tener
clara antes de empezar:

> 🧭 **Un conjunto de datos aleatorio arruina una prueba de regresión.** El faker
> es una herramienta de **carga** y de **medición**, nunca de **aserción**. Una
> prueba que afirma sobre datos que cambian en cada corrida es una prueba que va a
> fallar sola algún martes, sin que nadie haya tocado nada — y una prueba que
> falla sola es una prueba que el equipo acaba ignorando.

---

## 🧭 Índice de salto rápido

1. [Tres clases de datos, tres propósitos](#1-tres-clases-de-datos-tres-propósitos)
2. [La semilla del `db.json`: el camino por defecto](#2-la-semilla-del-dbjson-el-camino-por-defecto)
3. [Volumen con `gofakeit`](#3-volumen-con-gofakeit)
4. [Fijar la semilla del generador](#4-fijar-la-semilla-del-generador)
5. [Datos que respetan el dominio](#5-datos-que-respetan-el-dominio)
6. [Limpiar y regenerar sin romper migraciones](#6-limpiar-y-regenerar-sin-romper-migraciones)
7. [Por qué el faker no sirve para afirmar](#7-por-qué-el-faker-no-sirve-para-afirmar)
8. [🧩 Cuándo usar qué](#-cuándo-usar-qué)

---

## 1. Tres clases de datos, tres propósitos

Confundirlas es el origen de casi todos los problemas de este tema:

| Clase | Para qué | Cuántos | ¿Se puede afirmar sobre ellos? |
|---|---|---|---|
| **Semilla** (`db.json`) | Usar la aplicación, el `smoke.sh`, el reemplazo de `be03` | 1 rifa, 2 números | ✅ Sí: son fijos y conocidos |
| **Fixtures de prueba** | Cada caso monta lo suyo | Los mínimos | ✅ Sí: los escribe el test |
| **Volumen** (faker) | Medir contención, índices, tiempos | Decenas de miles | ❌ **No.** §7 |

📖 **La regla que ordena las tres:** si vas a **afirmar** algo sobre un dato, ese
dato lo escribiste tú. Si vas a **medir** algo, puede generarlo una máquina.

---

## 2. La semilla del `db.json`: el camino por defecto

**Esto no se reemplaza.** La siembra de `be03` sale del `db.json` que el alumno
tiene desde la Fase 3, y eso es la mitad del efecto de aquella fase: el mock se
apagó y la aplicación sigue mostrando **tus** rifas.

```bash
go run ./cmd/seed -file ../mock/db.json
```

Es idempotente (`ON CONFLICT DO UPDATE`), conserva los ids originales y reajusta
las secuencias. El faker de este apéndice **se suma** a eso, nunca lo sustituye.

> ⚠️ Y una consecuencia que hay que tener presente: `server/smoke.sh` verifica
> cosas concretas sobre la rifa 1 y el número `0347`. Si el faker pisara esos
> datos, el checklist de contrato dejaría de pasar. Por eso el generador del §3
> **empieza a partir del id 100**.

---

## 3. Volumen con `gofakeit`

```bash
cd server && go get github.com/brianvoe/gofakeit/v6@v6.19.0
```

> 📝 `gofakeit` **no es dependencia del backend**: vive en el paquete de siembra y
> el binario de producción no la incluye. Si quieres asegurarlo, ponla detrás de
> una etiqueta de compilación, igual que `be09` hizo con el driver de SQLite.

```go
// server/internal/seed/fake.go
package seed

import (
	"context"
	"fmt"
	"time"

	"github.com/brianvoe/gofakeit/v6"
	"github.com/rifas-y-chances/raffles-api/internal/storage"
)

// GenerateVolume crea rifas con sus números para poder MEDIR.
//
// 🧭 Los datos que genera no sirven para afirmar nada (§7). Sirven para que
// una medición de contención o un EXPLAIN digan algo.
//
// Empieza en el id 100 para no pisar la semilla del db.json, de la que
// dependen smoke.sh y las pruebas de contrato.
func GenerateVolume(ctx context.Context, db *storage.DB, raffles, numbersPerRaffle int, seed uint64) error {
	// La semilla FIJA es lo que hace reproducible el conjunto (§4).
	faker := gofakeit.New(seed)

	tx, err := db.BeginTxx(ctx, nil)
	if err != nil {
		return fmt.Errorf("abriendo la transacción de volumen: %w", err)
	}
	defer tx.Rollback()

	for i := 0; i < raffles; i++ {
		id := int64(100 + i)

		// Las reglas del dominio se respetan al generar (§5): el precio y
		// el premio son enteros de centavos, y el estado es coherente con
		// la hora de cierre.
		closesAt := time.Now().Add(time.Duration(faker.Number(-720, 720)) * time.Hour)
		status := "open"
		if closesAt.Before(time.Now()) {
			status = "closed"
		}

		_, err := tx.ExecContext(ctx, db.Rebind(`
			INSERT INTO raffles (id, name, lottery_id, closes_at, number_price, base_prize, status)
			VALUES (?, ?, ?, ?, ?, ?, ?)
			ON CONFLICT (id) DO NOTHING`),
			id,
			// El nombre lo lee un humano y va en español, igual que en el
			// db.json: es dato de dominio, no identificador.
			fmt.Sprintf("Rifa %s %d", faker.RandomString([]string{"del barrio", "de fin de mes", "del colegio"}), id),
			faker.RandomString([]string{"boyaca", "cruzverde", "meta"}),
			closesAt,
			int64(faker.Number(1, 20))*100000,   // 1.000 a 20.000 pesos, en centavos
			int64(faker.Number(1, 50))*1000000,  // 10.000 a 500.000 pesos
			status)
		if err != nil {
			return fmt.Errorf("generando la rifa %d: %w", id, err)
		}

		for n := 0; n < numbersPerRaffle; n++ {
			// El número es TEXT con ceros a la izquierda: contrato de be00.
			// Un %04d aquí y un INTEGER allá romperían el tablero de la
			// Fase 5 sin un solo error en consola.
			number := fmt.Sprintf("%04d", n)

			_, err := tx.ExecContext(ctx, db.Rebind(`
				INSERT INTO raffle_numbers (raffle_id, number, status)
				VALUES (?, ?, 'available')
				ON CONFLICT (raffle_id, number) DO NOTHING`),
				id, number)
			if err != nil {
				return fmt.Errorf("generando el número %s de la rifa %d: %w", number, id, err)
			}
		}
	}

	return tx.Commit()
}
```

```bash
# 50 rifas × 400 números = 20.000 números, en una transacción.
go run ./cmd/seed -volume -raffles 50 -numbers 400 -seed 42
```

> ⚠️ **Una sola transacción para veinte mil filas está bien; para dos millones,
> no.** Una transacción enorme retiene recursos, hincha el WAL y bloquea el
> recolector. Si subes el volumen en serio, confirma por lotes de unos pocos
> miles. Y si necesitas cargar de verdad rápido, `COPY` de Postgres es un orden de
> magnitud más veloz que `INSERT` fila a fila — es el ejercicio 6.

---

## 4. Fijar la semilla del generador

Es el detalle que separa un conjunto de datos **útil** de uno inservible.

```go
faker := gofakeit.New(42)   // ✅ misma semilla → mismos datos, siempre
faker := gofakeit.New(0)    // ❌ semilla del reloj → datos distintos cada vez
```

Con semilla fija, la secuencia de valores es determinista: `-seed 42` produce hoy
y dentro de seis meses exactamente las mismas cincuenta rifas. Eso te da tres
cosas que sin ella no tienes:

- **Comparar mediciones entre corridas.** Si la contención tardó distinto, fue el
  código o la máquina, **no los datos**.
- **Compartir un caso.** *"Corre con `-seed 42` y mira la rifa 137"* funciona en la
  máquina de otra persona.
- **Reproducir un hallazgo.** Si el faker generó por casualidad el caso que rompe
  algo, con la semilla lo vuelves a generar. Sin ella, lo perdiste.

> 🧠 **Y aun con semilla fija, sigue sin servir para afirmar.** Determinista no es
> lo mismo que estable: basta con actualizar la versión de `gofakeit` —o cambiar
> el orden de dos llamadas al generador— para que los mismos 42 produzcan otros
> datos. Es reproducible **dentro de una versión y un código**, no a través de
> ellos. Por eso el §7 no admite matices.

Anota siempre la semilla junto a la medición:

```markdown
<!-- server/evidence/concurrencia.md -->
Volumen: 50 rifas × 400 números, `-seed 42`, gofakeit v6.19.0
Contención: 50 goroutines sobre el número 0347 de la rifa 137
p50 12ms · p95 148ms · ganadores 1 · conflictos 49
```

Una medición sin su semilla no se puede repetir, y una medición que no se puede
repetir no es una medición: es una anécdota.

---

## 5. Datos que respetan el dominio

Un generador que ignora las reglas del negocio produce basura que **parece**
datos, y la basura se detecta tarde: en la mitad de una medición, cuando algo
falla por un motivo que no tiene que ver con lo que medías.

Las cuatro reglas de este dominio que el generador debe respetar:

| Regla | Si se ignora… |
|---|---|
| Una rifa cerrada no puede tener ventas **posteriores** a su `closesAt` | La liquidación de `be07` calcula sobre datos imposibles |
| El `status` de la rifa es coherente con su hora de cierre | El *worker* de `be06` "cierra" cientos de rifas en el primer tick |
| El `number` es `TEXT` de cuatro dígitos con ceros a la izquierda | El tablero de la Fase 5 se rompe sin un error en consola |
| Los montos son enteros de centavos, no decimales | `A10` y `be07` dejan de cuadrar |

Y una que casi siempre se olvida: **las restricciones de la base ya te están
ayudando**. Si el generador produce algo imposible, el `CHECK` del `status` o el
`UNIQUE (raffle_id, number)` lo rechazan. Un fallo al generar volumen es, la
mitad de las veces, un generador que no entendió el dominio — y esa es una buena
noticia, porque lo descubres en la carga y no en la medición.

**Si necesitas ventas simuladas** —para `be07` o para medir agregaciones—,
genéralas **a través del servicio**, no con un `INSERT` directo:

```go
// ✅ Pasa por SellNumber: respeta la transacción, la hora dura y el índice.
//    Es más lento y produce datos que de verdad podrían existir.
for _, n := range aVender {
    _, _ = svc.SellNumber(ctx, raffleID, n, nil)
}

// ❌ INSERT directo en sales: rápido, y puede dejar el estado de
//    raffle_numbers desincronizado con las ventas. Estás fabricando
//    exactamente el bug que be05 hizo imposible.
```

---

## 6. Limpiar y regenerar sin romper migraciones

```bash
# Borrar SOLO el volumen, conservando la semilla del db.json:
psql "$DATABASE_URL" -c "DELETE FROM raffles WHERE id >= 100;"
# el ON DELETE CASCADE de raffle_numbers se encarga del resto

# Empezar de cero, esquema incluido:
migrate -path migrations/postgres -database "$DATABASE_URL" down -all
migrate -path migrations/postgres -database "$DATABASE_URL" up
go run ./cmd/seed -file ../mock/db.json
go run ./cmd/seed -volume -raffles 50 -numbers 400 -seed 42
```

> ⚠️ **Nunca `TRUNCATE` en la base de desarrollo por costumbre.** Ese es el
> mecanismo de la suite de `be08`, que corre contra `rifas_test` y **comprueba el
> nombre antes de ejecutarse**. Aquí, el corte por `id >= 100` es lo que separa el
> volumen de tus datos.
>
> Y borrar rifas con liquidaciones **falla a propósito**: `prize_payouts` tiene
> `ON DELETE RESTRICT` (`be07`). En dinero, el borrado en cascada silencioso es
> exactamente lo que no quieres. Si el volumen incluye liquidaciones, bórralas en
> orden explícito.

**Después de generar, actualiza las estadísticas.** Sin esto, el planificador de
Postgres sigue creyendo que la tabla tiene cuatro filas y elige planes absurdos —
y tu `EXPLAIN` medirá una fantasía:

```sql
ANALYZE raffle_numbers;
ANALYZE sales;
```

---

## 7. Por qué el faker no sirve para afirmar

El punto que justifica el apéndice. Mira estas dos pruebas:

```go
// ❌ Pasa hoy. Falla algún martes, sola, sin que nadie toque nada.
func TestRecaudoDeLaRifa(t *testing.T) {
	seedVolume(t, 42)
	total := svc.TotalCollected(ctx, 137)
	require.Equal(t, int64(4200000), total)   // ¿de dónde salió ese número?
}

// ✅ Datos escritos por el test. Afirma sobre lo que el test decidió.
func TestRecaudoDeLaRifa(t *testing.T) {
	raffle := insertRaffle(t, withNumberPrice(500000))
	sellNumbers(t, raffle.ID, "0001", "0002", "0003")
	require.Equal(t, int64(1500000), svc.TotalCollected(ctx, raffle.ID))
}
```

La primera tiene **cuatro** formas de romperse sin que nadie haya introducido un
bug: actualizas `gofakeit`, alguien agrega una llamada al generador antes (y
corre la secuencia entera), alguien cambia el número de rifas, o el generador
usa el reloj para algo. Cuando falle, vas a pasar una hora buscando un bug que no
existe.

La segunda es legible por sí sola: **`500000 × 3 = 1500000`**. Quien la lea dentro
de dos años entiende qué se afirma y por qué.

> 🧭 **La regla, en una línea:** el faker llena la base para que **medir** tenga
> sentido; el test escribe sus propios datos para que **afirmar** tenga sentido.
> Nunca al revés.

**Y el matiz honesto, porque hay una excepción real.** Las pruebas **basadas en
propiedades** sí usan datos generados, y son perfectamente legítimas — pero no
afirman valores concretos: afirman **invariantes**. La de `be07` es el ejemplo:

```go
// ✅ Datos generados, y la aserción es una PROPIEDAD, no un número.
for prize := int64(0); prize <= 1000; prize++ {
    for winners := 1; winners <= 17; winners++ {
        shares, _ := PrizeShare(prize, winners)
        require.Equal(t, prize, SumShares(shares))   // las partes suman el todo
    }
}
```

Esa prueba no se rompe si cambia el generador, porque no depende de qué valores
salgan: depende de que la propiedad se cumpla **para todos**. Es la diferencia
entre *"el recaudo es 4.200.000"* y *"el recaudo siempre es números vendidos por
precio"*.

📖 **Aserciones concretas sobre datos que tú escribiste. Aserciones de propiedad
sobre datos generados. Mediciones sobre volumen. Y jamás una aserción concreta
sobre volumen generado.**

---

## 🧩 Cuándo usar qué

| Si necesitas… | Usa | Y no |
|---|---|---|
| Usar la aplicación y correr `smoke.sh` | La semilla del `db.json` | Volumen generado |
| Probar una regla de negocio | Fixtures escritas en el test | El faker |
| Verificar una invariante para muchos casos | Generación + aserción de **propiedad** | Aserción de valor |
| Medir contención (`be05`) | Volumen con semilla fija | Dos rifas y cuatro números |
| Medir un índice o un `EXPLAIN` (`be08`) | Volumen + `ANALYZE` | Volumen sin `ANALYZE` |
| Reproducir un hallazgo del generador | La misma `-seed` y la misma versión | Volver a generar al azar |
| Simular ventas | El servicio (`SellNumber`) | `INSERT` directo en `sales` |
| Limpiar el volumen | `DELETE … WHERE id >= 100` | `TRUNCATE` en desarrollo |

---

## 🧪 Ejercicios (7)

1. **🟢** Genera 50 rifas × 400 números con `-seed 42` y comprueba con `count(*)` que hay 20.000 números y que la rifa 1 del `db.json` sigue intacta.
2. **🟢** Genera dos veces con la misma semilla y comprueba que los nombres y los precios son idénticos. Después cambia la semilla y comprueba que no.
3. **🟡** Corre `EXPLAIN ANALYZE` sobre una consulta por `status` antes y después de `ANALYZE`. Explica por qué el plan cambia aunque los datos sean los mismos.
4. **🟡 Diagnóstico.** Haz que el generador produzca un `number` como entero sin ceros a la izquierda y observa qué le pasa al tablero de la Fase 5. Anota si aparece algún error en consola.
5. **🟠** Repite la medición de contención de `be05` (ejercicio 13) con y sin volumen, y explica por qué los números cambian. Anota semilla y versión junto al resultado.
6. **🟠** Reescribe la carga con `COPY` en vez de `INSERT` y mide la diferencia con 200.000 números. Decide a partir de qué volumen compensa.
7. **🔴 Diagnóstico.** Escribe la prueba mala del §7, hazla pasar, y después rómpela **sin tocar el código de producción**: actualiza `gofakeit`, o añade una llamada al generador antes. Documenta cuánto habrías tardado en diagnosticarlo sin saber lo de este apéndice.

---

## 📚 Referencias

**Documentación oficial**
- https://github.com/brianvoe/gofakeit — el generador. Fija la v6 y revisa su registro de cambios antes de actualizar: **una versión nueva puede cambiar lo que produce una misma semilla** (§4).
- https://www.postgresql.org/docs/13/sql-copy.html — `COPY`, el ejercicio 6.
- https://www.postgresql.org/docs/13/sql-analyze.html y https://www.postgresql.org/docs/13/using-explain.html — por qué hace falta `ANALYZE` después de cargar.
- https://pkg.go.dev/testing/quick — la generación con propiedades en la biblioteca estándar. Antigua y limitada, pero explica bien la idea del §7.
- https://go.dev/doc/security/fuzz/ — el *fuzzing* nativo desde Go 1.18: generación de entradas con aserciones de propiedad, que es el pariente riguroso de esto.

**Libros**
- *Unit Testing: Principles, Practices, and Patterns* (Vladimir Khorikov) — su tratamiento de la legibilidad y del "¿de dónde salió ese número?" es el argumento del §7 desarrollado.

**Video / apoyo**
- Busca "property based testing explained". La mayoría del material es de Haskell o Scala; la idea traduce sin problema y es lo que da sentido a la excepción del §7.

**Orden de lectura sugerido:** el §7 primero —es el que decide si este apéndice te
sirve o te mete en problemas— → el §4 antes de generar nada → y el resto cuando
`be05` o `be08` te pidan volumen.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros y videos son de memoria y pueden ser inexactas. La fuente
> de verdad de versiones es `prompts/decisiones-y-versiones.md` §7, donde
> `gofakeit` v6.19.x figura como dependencia **exclusiva de este apéndice**.

---

> 🏷️ **Este apéndice sí deja código.** `server/internal/seed/fake.go` y la bandera
> `-volume` del binario de siembra. Si lo haces:
>
> ```bash
> git tag -a apendice-be-a-10-datos-de-prueba-y-faker -m "be-a-10: \
> generador de volumen con gofakeit y semilla fija, a partir del id 100; \
> respeta las reglas del dominio y no pisa la semilla del db.json"
> ```
>
> Los commits van con el prefijo de la fase desde la que llegaste (`be03: …`,
> `be05: …`). La convención completa está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
FIN_DEL_ARCHIVO
wc -l be-a-10-datos-de-prueba-y-faker.md; echo "=== TOTAL TRACK BE ==="; wc -l be0*.md be-a-*.md | tail -1; ls be0*.md be-a-*.md | wc -l

# --- 2026-09-09T04:16:02 · Verify all cross-references resolve
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; cd $R && grep -oh "be-a-[0-9][0-9]\|be0[0-9]" be0*.md be-a-*.md | sort -u | while read s; do ls ${s}*.md >/dev/null 2>&1 || echo "FALTA: $s"; done; echo "--- refs a archivos del track base ---"; grep -oh "A1[0-3]-[a-z-]*\.md\|A[1-9]-[a-z-]*\.md\|0[0-9]-[a-z-]*\.md\|cuaderno-incidentes\.md" be0*.md be-a-*.md | sort -u | while read f; do [ -f "$f" ] || echo "FALTA: $f"; done; echo "ok"

# --- 2026-09-09T04:16:20 · Update memory about BE track status
M=/Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory; cat > $M/track-be-react16-sin-escribir.md <<'EOF'
---
name: track-be-react16-escrito
description: El track BE del curso react-16-legacy-for-backend-devs está completo — 10 fases y 10 apéndices escritos en septiembre de 2026.
metadata:
  type: project
---

El track BE opcional de `react-16-legacy-for-backend-devs` (backend en Go 1.19
contra PostgreSQL 13 que reemplaza al mock del puerto 3001) quedó **completo el
8 de septiembre de 2026**: las diez fases `be00`–`be09` y los diez apéndices
`be-a-01`–`be-a-10`, unas 13.500 líneas.

Decisiones nuevas que se registraron en `prompts/decisiones-y-versiones.md` §7 al
escribirlo, y que no estaban en la propuesta original: **D24** (puerto de
transición 3011), **D25** (DDL por dialecto, no subconjunto común), **D26**
(`/health` responde 503 sin base), **D27** (la única excepción a "el frontend no
se toca": `src/api/authService.js` en be04) y **D28** (la venta se modela como
hecho en la tabla `sales`, no como estado, para que el índice único pueda
proteger). **D19** se cerró en be09 con un giro: no era qué driver de SQLite,
sino por qué el binario de producción tiene uno — se resuelve con etiqueta de
compilación.

**Why:** la propuesta y los prompts se escribieron antes que las fases, así que
varias decisiones quedaron abiertas y algunos prompts contradicen lo que las
fases resolvieron después (el de `be-a-02` pide runtime Debian por cgo, que
be09 ya no necesita).

**How to apply:** ante una discrepancia entre un prompt de
`prompts/prompts-backend-*.md` y una fase escrita, gana la fase — y conviene
recoger las dos versiones si ambas son válidas en momentos distintos del track,
como hizo `be-a-02`. El hueco grande que queda en el curso sigue siendo
`cuaderno-incidentes.md`: los IDs `be-01`–`be-16` están reservados y asignados
en los 📌 Pendientes de cada fase, pero **ningún enunciado está redactado**.
EOF
mv $M/track-be-react16-sin-escribir.md $M/track-be-react16-escrito.md
python3 - "$M" <<'PY'
import io,sys
p=sys.argv[1]+'/MEMORY.md'
s=io.open(p,encoding='utf-8').read()
old="- [Track BE de React 16 sin escribir](track-be-react16-sin-escribir.md) — las fases beNN y apéndices be-a-NN están planificados en prompts/ pero ningún archivo existe aún."
new="- [Track BE de React 16 escrito](track-be-react16-escrito.md) — 10 fases y 10 apéndices completos; decisiones D24–D28 nuevas; el hueco vivo es el cuaderno de incidentes."
assert old in s
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))
print('ok')
PY

# --- 2026-09-09T04:22:57 · Read the incidents notebook
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; sed -n '1,60p' $R/cuaderno-incidentes.md; echo "===== 160-339 ====="; sed -n '160,339p' $R/cuaderno-incidentes.md

# --- 2026-09-09T04:24:27 · Write BE incident template
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; cat > $R/prompts/plantilla-de-incidente-be.md <<'FIN_DEL_ARCHIVO'
# 🧩 Plantilla de incidente — Track BE 🔥
## Tutorial React 16 — Rifas y chances

Copia este esqueleto al redactar un incidente del track BE y rellena los
`{{placeholders}}`. Borra las notas entre paréntesis antes de entregar.

Es la variante backend de la plantilla que `cuaderno-incidentes.md` lleva
embebida. **La estructura es la misma y no se toca**: ticket → qué se te pide →
preparación → tres pistas escalonadas → tu investigación → solución de
referencia colapsada. Lo que cambia son las herramientas y el vocabulario, por la
misma razón que cambia la pieza forense de cada fase
(`guia-de-estilo-y-convenciones.md` §16.4).

> 🔄 **Convención de idioma.** El ticket, la narrativa, las pistas y los
> comentarios de código van en **español**. Los identificadores, nombres de
> tabla, columnas, endpoints y errores de dominio van en **inglés**
> (`diccionario-codigo-ingles.md` §7bis).

---

## Lo que cambia respecto del track base

| | Track base | Track BE |
|---|---|---|
| Ambientes | navegador, mock | navegador, **binario, Postgres, contenedor, CI** |
| Evidencia | consola, Network, React/Redux DevTools | **log del backend, `psql`, `pg_stat_activity`, `EXPLAIN`, `go test -race`, `docker logs`** |
| Capas a distinguir | componente / store / epic / mock | **handler / service / store / base / infraestructura** — y **frontend contra backend**, que es la primera pregunta |
| Preparación | rama, `CHAOS_LEVEL`, dato en `db.json` | rama, `CHAOS_LEVEL`, **estado de la base, migración aplicada, variables de entorno** |
| Fix | parche mínimo / refactorización | igual, **más: ¿va en el código, en el esquema o en la configuración?** |
| Regresión | Jest, RTL, marbles | **`go test`, y con el motor correcto** (`D18`) |

Y una pregunta propia que el track base no puede hacer, que va **siempre** en la
sección "Qué se te pide":

> 🧭 **¿De qué lado del cable está la causa?** Antes de abrir un archivo. El
> `X-Request-Id` es la herramienta que cruza el corte sin perder el hilo
> (`be-a-07`).

---

```markdown
## Incidente be-{{NN}} — {{Título en palabras del usuario}}

> **Fase:** {{beNN}} · **Categoría:** 🔥 {{base de datos / transacciones / despliegue / contrato / autenticación / tiempo / dinero}} · **Dificultad:** {{🟢🟡🟠🔴}}
> **Estado:** ⬜ Sin empezar · **Abierto:** {{—}} · **Cerrado:** {{—}}
> **Tiempo sugerido:** {{30-60 min}}
> {{⭐ si es de los más formativos}} {{· Hermano del incidente {{NN}} del track base, con otra causa raíz}}

### 🎫 El ticket

{{El reporte tal como llegó, con su vaguedad incluida. Dos o tres frases en
lenguaje de negocio, escritas por alguien que no sabe qué es una transacción.
"A veces" y "creo que" son datos legítimos, no defectos del reporte. Si el
reporte incluye una teoría del usuario sobre la causa —y suelen incluirla—,
consérvala: descartarla es parte del trabajo.}}

**Reportado por:** {{rol — vendedor, supervisor, tesorería, soporte, el propio equipo}}
**Ambiente:** {{desarrollo / QA / UAT / PROD / CI / varios}}

### 🎯 Qué se te pide

{{Una o dos líneas con el entregable concreto. Y siempre, explícitamente: de qué
lado del cable está la causa. No todos los incidentes terminan en fix: algunos
terminan en "el sistema hizo lo correcto y hay que explicárselo a alguien".}}

### 🔧 Preparación

{{Cómo poner el laboratorio en el estado roto: rama, migración, estado de la
base, variables de entorno, volumen de datos si hace falta.}}

```bash
{{git checkout incidente/be-NN
migrate -path server/migrations/postgres -database "$DATABASE_URL" up
CHAOS_LEVEL=off go run ./cmd/api}}
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable (ábrela si llevas 20 min sin una idea nueva)</summary>

{{Señala la orilla y la herramienta, sin decir qué vas a encontrar. En este track
la primera pista casi siempre es la misma pregunta: ¿la petición salió, y qué
volvió?}}

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

{{Acota a la capa, al archivo o al momento exacto, todavía sin nombrar la causa.}}

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

{{La pregunta cuya respuesta es la causa raíz.}}

</details>

---

### 📝 Tu investigación

**Reproducción**
{{Pasos numerados y exactos, con datos concretos: qué rifa, qué número, en qué
estado, a qué hora, con qué usuario, con cuántos clientes concurrentes. Si no lo
lograste, escribe qué intentaste — no reproducir también es un resultado, y en
concurrencia es el resultado más frecuente al principio.}}

**Evidencia observable**
{{Lo que viste, no lo que supones. Texto, no capturas: el texto se versiona y se
busca. Y siempre que puedas, el `X-Request-Id` que ata las dos orillas.}}

```
{{línea de log, salida de psql, informe de -race, mensaje de docker}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea, o la decisión de diseño culpable. En qué capa vive: handler,
service, store, esquema, configuración o infraestructura. Y de qué lado del
cable.}}

**Tu fix**
{{El parche mínimo que aplicarías un viernes a las seis. Aparte, en una línea, la
corrección correcta. Y di dónde va: código, esquema o configuración — en el
backend, esa distinción decide si hace falta una migración y un despliegue o
solo un reinicio.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

{{Hasta el archivo y la línea. Si es una decisión de diseño, se nombra y se
explica por qué tenía sentido — 📝 nota de época. Si la deuda está declarada en
`be-a-09`, se cita la entrada.}}

**Parche mínimo**

```go
{{el hotfix, con identificadores en inglés y comentarios en español}}
```

**La corrección correcta**

{{Qué haría alguien con tiempo y pruebas, y por qué acá no se hace todavía. Si
toca el esquema, la migración. Si toca el frontend, decir explícitamente que
choca con la regla del track y con `D27`.}}

**Prueba de regresión**

{{El test que falla antes del fix y pasa después. Código, no descripción. Y
declara contra qué motor corre y por qué (`D18`, regla del motor).}}

```go
{{test}}
```

**Prevención**

{{Restricción en la base, prueba, comprobación en el servicio, o alerta. Lo que
evita que el mismo bug vuelva por otra puerta. En este track, la prevención más
fuerte casi siempre es una restricción de la base: protege también los caminos
que todavía no existen.}}

**Por qué llegó a producción**

{{Post-mortem sereno: qué del sistema o del proceso lo permitió. Se analiza el
sistema, nunca a la persona. Acá el humor baja un punto.}}

**Si tu causa fue distinta a esta**

{{Los diagnósticos alternativos plausibles y por qué el síntoma también encaja
con ellos.}}

</details>
```

---

## Recordatorios al rellenar

- **El ID nunca se reasigna.** El rango del track BE es `be-01` a `be-16` y está
  reservado en `cuaderno-incidentes.md`.
- **La fase indicada es la que hay que haber terminado** para poder resolverlo,
  no necesariamente la que introdujo el bug.
- **Cada incidente tiene que poder resolverse con el laboratorio del alumno**, sin
  datos ni servicios externos (autocontención, guía §11).
- **Al menos un tercio son de diagnóstico puro**: reproducir y localizar, sin
  fix. Y al menos uno tiene que terminar en *"el sistema hizo lo correcto"*, que
  es un desenlace real y el que menos se practica.
- **Los hermanos del track base se marcan.** El paralelo —mismo síntoma, otra
  capa, otra causa raíz— es de lo más formativo que ofrece el track
  (`cuaderno-incidentes.md`, reserva del track BE).
- **La prueba de regresión declara su motor.** Si toca concurrencia, bloqueos,
  zonas horarias o SQL específico, corre contra PostgreSQL o no vale (`D18`).
- **Nada de culpabilización** en el post-mortem, ni siquiera implícita (guía §13).
FIN_DEL_ARCHIVO
wc -l $R/prompts/plantilla-de-incidente-be.md

# --- 2026-09-09T04:27:07 · Write BE incidents notebook part 1
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; cat > $R/cuaderno-incidentes-be.md <<'FIN_DEL_ARCHIVO'
# 📓🔥 Cuaderno de incidentes — Track BE

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Documento vivo
> El changelog es `git log -- cuaderno-incidentes-be.md`
> El tiempo ya está contado dentro de las 84 h del track BE; no es un bloque aparte

Este es el cuaderno del **track opcional de backend**. Los dieciséis incidentes
de acá ocurren del otro lado del cable: en el binario de Go, en PostgreSQL, en el
contenedor o en el pipeline. Su rango de IDs —`be-01` a `be-16`— está reservado
en `cuaderno-incidentes.md` y **nunca se reasigna**.

> 📝 **Por qué este archivo existe aparte.** `cuaderno-incidentes.md` se declara
> "el único archivo de incidentes del curso", y esa frase se escribió antes de que
> el track BE existiera. Se **diverge a propósito** y por dos razones: el track BE
> es opcional, y un alumno que solo hace las 96 horas del track base no debería
> encontrarse dieciséis incidentes de Go y Postgres intercalados entre los suyos;
> y los IDs `be-NN` conviven con los `01`–`20` sin colisionar precisamente porque
> están en rangos distintos. El cuaderno base conserva la reserva y apunta acá.
>
> La estructura, las reglas y el tono son **exactamente los mismos**. Lo que
> cambia son las herramientas, y está registrado en
> `prompts/plantilla-de-incidente-be.md`.

**Prerrequisito:** haber terminado la fase que cada incidente indica. Adelantarte
no es imposible, pero vas a pelear con herramientas que todavía no conoces —y en
concurrencia, con un bug que no vas a poder ni reproducir.

---

## 🧭 Cómo se trabaja un incidente

Igual que en el cuaderno base, así que si vienes de allá puedes saltar a la
sección siguiente. Lees el ticket, reproduces, investigas, escribes tu
diagnóstico en el bloque "Tu investigación", y **recién entonces** abres la
solución para compararla.

Las pistas están escalonadas: la primera te dice **de qué lado del cable** mirar,
la segunda **qué** mirar, la tercera casi te lo cuenta. Ábrelas en orden y solo
cuando estés realmente trabado — trabado quiere decir veinte minutos sin una idea
nueva.

Regla del archivo: se **agrega**, no se corrige. Una hipótesis falsa no se borra:
se marca como descartada, con la evidencia que la tumbó al lado.

> 🧭 **La distinción que atraviesa los dos cuadernos.** Cada fix se escribe dos
> veces: el **parche mínimo** —lo que aplicarías un viernes a las seis— y la
> **corrección correcta** —lo que harías con calma y pruebas.
>
> Y acá se le suma una pregunta propia, que es la primera de todas: **¿de qué lado
> del cable está la causa?** El track base solo podía mirar una orilla. Vas a
> descubrir que buena parte de lo que parecía del frontend no lo era — y también
> lo contrario, que es más incómodo.

### La pregunta que cambia todo el método

Antes de abrir un archivo, siempre:

1. **¿La petición salió?** Si no está en Network, el bug es del cliente y el
   backend no tiene nada que ver.
2. **¿Qué volvió?** Código, cuerpo y `X-Request-Id`.
3. **¿Qué dice el log del backend para ese id?**

Ese corte —Network primero, log después— ahorra más tiempo que cualquier
herramienta, y el `X-Request-Id` es lo que permite cruzarlo sin perder el hilo
(`be-a-07` §7).

### Convención de commits

```
incidente(be-09): abre — vendimos tres números dos veces, y solo los redondos
incidente(be-09): repro — 20 clientes concurrentes sobre el 0500, dos ganan
incidente(be-09): hipótesis descartada — no es el frontend, curl sin navegador lo reproduce
incidente(be-09): causa — SellNumber lee, decide y escribe sin transacción ni bloqueo
incidente(be-09): fix — transacción con SELECT ... FOR UPDATE sobre raffle_numbers
incidente(be-09): cierre — prueba de concurrencia contra Postgres y post-mortem
```

Y si el incidente deja el laboratorio roto a propósito, el par de tags de
`00-convencion-de-git-y-tags.md`: `inc/be-09/venta-doble-roto` e
`inc/be-09/venta-doble-fix`.

---

## 📋 Índice

| ID | Fase | Síntoma reportado | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| be-01 | be00 | La trazabilidad funciona en Network pero no en la consola | 🔥 contrato | 🟡 | ⬜ |
| be-02 | be00 | El número ganador no tiene dueño | 🔥 contrato | 🟠 | ⬜ |
| be-03 | be01 | El backend se cae solo y vuelve, tres veces al día | 🔥 despliegue | 🟡 | ⬜ |
| be-04 | be02 | Las rifas se crean con la hora corrida | 🔥 base de datos | 🟠 | ⬜ |
| be-05 | be02 | Todo funciona hasta que hay gente | 🔥 base de datos | 🔴 | ⬜ |
| be-06 | be03 | El comprador aparece en blanco, pero solo a veces | 🔥 contrato | 🟠 | ⬜ |
| be-07 | be03 | Faltan datos en las liquidaciones de agosto | 🔥 contrato | 🔴 | ⬜ |
| be-08 | be04 | A algunos los saca de la sesión al mediodía y a otros nunca | 🔥 autenticación | 🟡 | ⬜ |
| be-09 ⭐ | be05 | Vendimos tres números dos veces, y solo los redondos | 🔥 transacciones | 🔴 | ⬜ |
| be-10 | be05 | Un número quedó reservado para siempre | 🔥 transacciones | 🟡 | ⬜ |
| be-11 | be06 | A los vendedores de la costa se les cierra la rifa una hora antes | 🔥 tiempo | 🟠 | ⬜ |
| be-12 | be06 | Vendimos doscientos números después del cierre | 🔥 tiempo | 🔴 | ⬜ |
| be-13 | be07 | La liquidación dice 340.000 y las ventas suman 355.000 | 🔥 dinero | 🟠 | ⬜ |
| be-14 | be07 | Repartimos el premio dos veces | 🔥 transacciones | 🔴 | ⬜ |
| be-15 ⭐ | be08 | La suite lleva tres semanas en verde y ayer se rompió producción | 🔥 contrato | 🔴 | ⬜ |
| be-16 | be09 | La imagen de ayer no arranca y el código no cambió | 🔥 despliegue | 🟠 | ⬜ |

**Categorías propias del track:** 🔥 base de datos · 🔥 transacciones · 🔥
despliegue · 🔥 contrato. Se suman a las del cuaderno base, de donde salen
autenticación, tiempo y dinero.

**⭐** marca los dos más formativos: la venta duplicada (`be-09`) y la suite que
autorizó un despliegue roto (`be-15`).

### Los hermanos del track base

Seis de estos dieciséis comparten síntoma con un incidente del cuaderno base y
tienen **otra causa raíz**. Ese paralelo es deliberado y es de lo más formativo
que ofrece el track: resolverlos en pareja te enseña más que resolver doce
sueltos.

| Track base | Track BE | Qué cambia |
|---|---|---|
| 11 — el `0347` vendido dos veces ⭐ | **be-09** ⭐ | Allá se diagnostica en el store; acá se resuelve con un índice único y una transacción |
| 16 — la rifa siguió vendiendo tras el cierre | **be-12** | Allá el reloj del navegador; acá la autoridad temporal del servidor |
| 18 — la liquidación da un centavo de diferencia | **be-13** | Allá el redondeo; acá el cliente calculando con datos viejos |
| 20 — el test pasa en mi máquina y falla en la de al lado | **be-15** ⭐ | Allá el entorno; acá el **motor** de la base |
| 08 — la sesión se cae sola *(auth, track base)* | **be-08** | Allá el `401` del caos; acá un `exp` real sin renovación |
| 19 — el dashboard se arrastra al final del día | **be-05** | Allá memoización; acá el pool de conexiones agotado |

---

# 🧪 Incidentes

Ordenados por ID, que es también el orden sugerido. El ID nunca se reasigna.

---

## Incidente be-01 — La trazabilidad funciona en Network pero no en la consola

> **Fase:** be00 · **Categoría:** 🔥 contrato · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-45 min

### 🎫 El ticket

> "Soporte nos pidió que cuando un usuario reporte un error le pasemos el id de
> la petición, ese que sale en la consola. El problema es que casi nunca sale.
> Yo lo veo en la pestaña de red, ahí está el header, pero en la consola no
> aparece nada. Un compañero dice que a él sí le sale, así que a lo mejor es
> algo de mi Chrome."

**Reportado por:** soporte
**Ambiente:** desarrollo y UAT

### 🎯 Qué se te pide

Determinar por qué el header **se ve** y no **se lee**, y de qué lado del cable
está la causa. No hace falta arreglarlo todavía: `be01` lo va a pagar. Lo que sí
hace falta es que quede registrado en `server/CONTRACT.md` como hallazgo, con su
evidencia.

### 🔧 Preparación

```bash
CHAOS_LEVEL=off npm run mock:api        # el mock con el middleware de X-Request-Id
npm start                                # la app en el 3000
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

El header llega: lo estás viendo. Así que el backend hizo su parte. La pregunta
no es si el dato viaja, sino **quién tiene permiso para leerlo** una vez que
llegó.

Y el detalle del reporte que parece ruido y no lo es: *"a un compañero sí le
sale"*. ¿Qué tiene distinto la máquina de esa persona?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Abre la consola del navegador y evalúa a mano, con la aplicación cargada:

```javascript
fetch('http://localhost:3001/raffles')
  .then(r => console.log('leído:', r.headers.get('X-Request-Id')));
```

Compara ese resultado con lo que muestra la pestaña Network para esa **misma**
petición. Después mira los headers de **respuesta** completos, no solo el que
buscas.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En una petición de origen cruzado, ¿qué headers de respuesta le entrega el
navegador a JavaScript, y cuáles se guarda para sí? ¿Qué tiene que declarar el
servidor para ampliar esa lista?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

CORS. En una petición de origen cruzado, el navegador **solo entrega a JavaScript
un puñado de headers de respuesta seguros** (`Content-Type`, `Cache-Control` y
unos pocos más). Cualquier otro —incluido `X-Request-Id`— queda visible en
DevTools pero **inaccesible desde código**, salvo que el servidor lo declare
explícitamente:

```
Access-Control-Expose-Headers: X-Request-Id
```

El mock de la Fase 2 pone el header y **no** lo expone. Por eso
`response.headers['x-request-id']` vale `undefined` en el interceptor de
`apiClient`, y el `console.debug` nunca imprime.

Es el hallazgo **`C-05`** de `be00`.

📝 **Y la pista del compañero era real, no ruido.** A quien le funciona es porque
está usando el `proxy` del dev server de CRA: con él, las peticiones salen al
`3000` y no hay origen cruzado, así que CORS no interviene y todos los headers
son legibles. Dos entornos, dos comportamientos, mismo código. Es el "en mi
máquina anda" de manual, y por eso el reporte lo mencionaba.

**Parche mínimo**

Ninguno en esta fase: `be00` **no escribe código**. El entregable es el registro
del hallazgo en `server/CONTRACT.md`, dentro del régimen estricto, con las dos
evidencias: la captura del header en Network y la consola sin la línea del
interceptor.

Y la verificación 9 de `server/smoke.sh`, que hoy **falla a propósito**:

```bash
check "X-Request-Id expuesto a CORS (C-05)" "1" \
  "$(curl -s -D - -o /dev/null -X OPTIONS "$BASE/raffles" \
     -H 'Origin: http://localhost:3000' -H 'Access-Control-Request-Method: GET' \
     | grep -ci 'access-control-expose-headers:.*x-request-id')"
```

**La corrección correcta**

Una línea en el middleware de CORS de `be01`:

```go
w.Header().Set("Access-Control-Expose-Headers", requestIDHeader)
```

Con eso, la verificación 9 pasa a verde y la trazabilidad funciona de verdad.

**Prueba de regresión**

Vive en la suite de contrato de `be08`, y se verifica sobre el **preflight**:

```go
func TestExposeRequestID(t *testing.T) {
	req := httptest.NewRequest("OPTIONS", "/raffles", nil)
	req.Header.Set("Origin", "http://localhost:3000")
	req.Header.Set("Access-Control-Request-Method", "GET")
	rec := httptest.NewRecorder()

	newRouter(testConfig).ServeHTTP(rec, req)

	// No basta con que el header viaje: tiene que estar EXPUESTO.
	require.Contains(t,
		rec.Header().Get("Access-Control-Expose-Headers"), "X-Request-Id")
}
```

Motor: ninguno. Es una prueba de handler y no toca la base.

**Prevención**

La verificación del `smoke.sh`, que corre en cada fase desde `be03`, y la prueba
de contrato de arriba. Las dos son necesarias: el `smoke.sh` atrapa "el ambiente
está mal configurado" y la prueba atrapa "alguien tocó el middleware".

**Por qué llegó a producción**

Porque el síntoma es invisible desde el lado que lo produce. El backend hizo todo
bien y el header está ahí; nada en el servidor sugiere que falte algo. Y del lado
del cliente, `undefined` en un `console.debug` es exactamente lo que se ve cuando
no pasa nada — no hay error, no hay advertencia, no hay señal.

A eso se suma que **funcionaba en la máquina de algunas personas** por el proxy
del dev server, lo que convierte el problema en "algo de tu Chrome" y desvía la
investigación durante semanas.

**Si tu causa fue distinta a esta**

- *"El interceptor lee la clave mal"* — plausible: los navegadores normalizan los
  headers a minúsculas y `response.headers['X-Request-Id']` con mayúsculas sí
  daría `undefined`. Compruébalo: en `axios`, `response.headers` ya normaliza, y
  el interceptor de la Fase 2 usa `'x-request-id'` correctamente. Descartada por
  lectura, pero era una hipótesis correcta de formular.
- *"El mock no siempre pone el header"* — se descarta mirando diez peticiones en
  Network: está en todas.
- Si concluiste *"hay que loguearlo en el servidor y correlacionar por hora"*,
  tapaste el síntoma: funciona, y te deja sin trazabilidad en el cliente para
  siempre.

</details>

---

## Incidente be-02 — El número ganador no tiene dueño

> **Fase:** be00 · **Categoría:** 🔥 contrato · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "Salió el sorteo de la rifa 1 y el número ganador fue el 0347. Está vendido,
> eso lo vemos, pero cuando entramos a ver a quién se lo vendimos no aparece
> nadie. Miramos otras rifas y algunos números sí tienen comprador y otros no,
> y no encontramos el patrón. Los vendedores juran que siempre ponen el
> comprador."

**Reportado por:** tesorería
**Ambiente:** PROD

### 🎯 Qué se te pide

Encontrar el patrón que tesorería no encontró y determinar de qué lado del cable
está la causa. El entregable es el hallazgo registrado en `server/CONTRACT.md`
con la forma canónica del cuerpo — el fix real llega en `be04`.

### 🔧 Preparación

```bash
CHAOS_LEVEL=off npm run mock:api
npm start
# Vende números por los DOS caminos que ofrece la aplicación.
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

*"Algunos sí y otros no, sin patrón"* casi nunca significa que no haya patrón:
significa que el patrón no está donde lo buscaron. Tesorería miró **los números**.
Mira tú **cómo se vendieron**.

La aplicación tiene más de un camino para vender. ¿Cuántos?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Abre Network, vende un número desde el tablero, y vende otro provocando el camino
del `sellNumberEpic` de la Fase 6. Compara los **cuerpos** de las dos peticiones
`POST /raffles/:id/numbers/:number/sell`, campo por campo.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el servidor lee `req.body.participantId` y el cliente manda `participant`,
¿qué guarda el servidor? ¿Y qué código de estado devuelve?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**Dos clientes mandan dos cuerpos distintos al mismo endpoint.**

- El thunk `sellNumber` de la Fase 5 y el de la Fase 7 mandan `{ participantId }`.
- El `sellNumberEpic` de la Fase 6 manda `{ participant }`.

Y el mock lee:

```javascript
record.assign({ status: "sold", participantId: req.body.participantId ?? null })
```

Así que la variante de la Fase 6 **guarda `null` en silencio**. La venta se
registra, el número queda `sold`, el servidor responde `200`, y el comprador
desaparece. No hay error en ninguna capa.

Es el hallazgo **`C-03`** de `be00`.

📝 **Nota de época.** Esto es lo que pasa cuando dos personas implementan el mismo
caso de uso en momentos distintos —la Fase 5 con un thunk, la Fase 6 con un epic—
sin un contrato escrito que arbitre. No es descuido de nadie en particular: es la
consecuencia previsible de no tener el contrato en ninguna parte, que es
exactamente el vacío que `be00` viene a llenar.

**Parche mínimo**

Ninguno en `be00`: se documenta. En `CONTRACT.md`, régimen estricto:

> `POST /raffles/:raffleId/numbers/:number/sell` — cuerpo canónico
> `{"participantId": <número|null>}`. El `sellNumberEpic` de la Fase 6 manda
> `{"participant": …}`; el backend **debe aceptarlo sin explotar** y lo ignora,
> igual que hacía el mock. Cambiar ese comportamiento rompería el contrato
> observable.

**La corrección correcta**

En `be03`, el handler acepta las dos formas explícitamente y lo dice en un
comentario:

```go
var body struct {
	ParticipantID *int64          `json:"participantId"`
	Participant   json.RawMessage `json:"participant"`   // la variante de la Fase 6
}
```

Y la causa raíz se paga en **`be04`**: cuando la identidad venga de
`req.Context()` y no del cuerpo, el problema desaparece por construcción para el
vendedor. Para el **participante** —el comprador— no: ese sí es un dato del
negocio que el cliente tiene que mandar, y unificarlo exigiría tocar el epic de
la Fase 6, lo que choca con la regla del track.

💸 Queda como deuda declarada. La forma correcta sería que el frontend mande un
solo cuerpo, y eso está fuera de `D27`.

**Prueba de regresión**

En la suite de contrato de `be08`:

```go
func TestSellAceptaLasDosFormasDelCuerpo(t *testing.T) {
	// La canónica: guarda el participante.
	srv.POST(t, "/raffles/1/numbers/0347/sell", token,
		`{"participantId":7}`).ExpectStatus(200)
	require.Equal(t, int64(7), participantIDOf(t, 1, "0347"))

	// La de la Fase 6: NO explota, y guarda null. Este test fija el
	// comportamiento actual como esperado — es lo que impide que alguien
	// lo "arregle" y rompa el epic de la Fase 6.
	srv.POST(t, "/raffles/1/numbers/1500/sell", token,
		`{"participant":{"name":"Ana"}}`).ExpectStatus(200)
	require.Nil(t, participantIDOf(t, 1, "1500"))
}
```

Motor: PostgreSQL. Toca la base, aunque no las cuatro áreas críticas.

**Prevención**

El contrato escrito de `be00` con el cuerpo canónico, y la prueba de arriba. Y a
futuro: una sola función de cliente por caso de uso. Que la Fase 5 y la Fase 6
llamen al mismo endpoint desde dos sitios distintos es la condición que hizo
posible la divergencia.

**Por qué llegó a producción**

Porque el fallo **no produce ningún error**. `req.body.participantId ?? null` es
código defensivo bienintencionado: evita un `undefined` y a cambio convierte un
dato faltante en un dato válido. El `200` confirma el éxito, la UI pinta el
número vendido, y el problema aparece meses después, cuando alguien reclama un
premio.

**Si tu causa fue distinta a esta**

- *"El vendedor no puso el comprador"* — es la hipótesis obvia y la que
  tesorería asumió. Se descarta mirando el cuerpo en Network: el dato **iba** en
  la petición.
- *"Se pierde en la base"* — no hay base todavía; es un archivo JSON.
- Si concluiste *"hay que validar que `participantId` no sea nulo y devolver
  `400`"*, cuidado: la Fase 5 manda `participantId: null` a propósito, porque el
  curso base no tiene formulario de comprador. Ese `400` rompería la venta normal.

</details>

---

## Incidente be-03 — El backend se cae solo y vuelve, tres veces al día

> **Fase:** be01 · **Categoría:** 🔥 despliegue · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-45 min

### 🎫 El ticket

> "Desde que pasamos al backend nuevo, un par de veces al día la aplicación se
> queda muerta unos segundos: cualquier cosa que hagas da error de red, y
> después vuelve sola. No es siempre a la misma hora ni con la misma pantalla.
> El equipo de infraestructura dice que el contenedor se está reiniciando pero
> que ellos no lo tocan."

**Reportado por:** el propio equipo
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducirlo a voluntad —que es la mitad del trabajo— y determinar por qué el
cliente ve un **error de red** y no un `500`. Después, el fix.

### 🔧 Preparación

```bash
git checkout incidente/be-03
cd server && PORT=3011 go run ./cmd/api
```

La rama trae un handler que revienta con ciertos datos. Encuéntralo tú.

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

*"Error de red"* y *"vuelve sola"* son dos datos muy concretos. Un `500` no es un
error de red: llega con status, con cuerpo y con headers. Un error de red es lo
que ve el cliente cuando **no llega nada**.

¿Qué tendría que pasarle al servidor para que no llegue nada, y para que unos
segundos después vuelva a responder?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Mira la **terminal del servidor** mientras reproduces, no el navegador. Y fíjate
en si el proceso sigue vivo después: `curl localhost:3011/health`.

Con `curl -v` sobre la petición que falla, compara el mensaje con el de un `500`
normal (puedes provocar uno con `CHAOS_LEVEL=high`).

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En Go, ¿qué le pasa al proceso cuando un handler entra en pánico y nadie lo
recupera? ¿Y en Node con Express?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

Un `panic` dentro de un handler, sin `recoverMiddleware` en la cadena.

En Go, **un pánico que nadie recupera desenrolla toda la pila y termina el
proceso**. No muere esa petición: muere el servidor entero, con todas las
conexiones de todos los usuarios. El orquestador lo reinicia unos segundos
después, y de ahí el "vuelve sola".

Por eso el cliente ve un error de red y no un `500`: **no hay nadie que responda**.
`axios` entrega un `Network Error` sin `error.response`, o sea sin status, sin
cuerpo y **sin `X-Request-Id`** — todo el aparato de diagnóstico que `be00`
levantó desaparece justo cuando más falta hace.

📝 **La diferencia cultural, que es la lección del incidente.** En Express, un
`throw` síncrono dentro de un handler lo atrapa el framework: responde `500` y el
proceso sigue. Quien viene de Node asume esa red de seguridad. Go no la trae, y
`gorilla/mux` tampoco: **el middleware de recuperación es tuyo y es obligatorio**.

**Parche mínimo**

```go
// server/internal/http/middleware.go
func recoverMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// defer corre al salir, pase lo que pase — también con pánico.
		// Es la única forma de que recover() llegue a ejecutarse.
		defer func() {
			if rec := recover(); rec != nil {
				// El id es lo que vuelve diagnosticable el pánico: ata el
				// 500 que vio el usuario con esta línea del log.
				log.Printf("[req-id %s] PÁNICO en %s %s: %v",
					RequestIDFrom(r.Context()), r.Method, r.URL.Path, rec)
				// Mensaje genérico: nunca se filtra el detalle interno.
				writeError(w, http.StatusInternalServerError, "Error interno del servidor")
			}
		}()
		next.ServeHTTP(w, r)
	})
}
```

Y su **posición en la cadena**, que es la mitad del fix:

```
requestID → logging → cors → recover → chaos → rutas
```

`recover` va **por dentro** de `logging` y de `cors`: por dentro de `logging`
para que el `500` quede registrado con su duración, y por dentro de `cors` para
que la respuesta de error lleve los headers de origen cruzado. Un `500` sin
headers de CORS es, para el navegador, un error de red opaco — o sea, volverías
a ver el mismo síntoma con otra causa.

**La corrección correcta**

Además del `recover`, arreglar el pánico. Un pánico recuperado sigue siendo un
bug: el `recover` evita que se lleve el servidor por delante, no que la petición
falle. Localízalo con el stack trace:

```go
log.Printf("[req-id %s] PÁNICO: %v\n%s",
	RequestIDFrom(r.Context()), rec, debug.Stack())
```

⚠️ El stack trace va **al log**, nunca al cliente: revela rutas, nombres de
paquete y estructura interna (`be-a-08` §4).

**Prueba de regresión**

```go
func TestPanicoDevuelve500YNoTumbaElProceso(t *testing.T) {
	r := mux.NewRouter()
	r.HandleFunc("/boom", func(http.ResponseWriter, *http.Request) {
		panic("explota a propósito")
	})
	handler := buildChain(r)   // la cadena completa

	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, httptest.NewRequest("GET", "/boom", nil))

	require.Equal(t, 500, rec.Code)
	require.Contains(t, rec.Body.String(), "Error interno del servidor")
	// La otra mitad: que la respuesta sea legible desde el navegador.
	require.NotEmpty(t, rec.Header().Get("Access-Control-Allow-Origin"))
	require.NotEmpty(t, rec.Header().Get("X-Request-Id"))
	// Si el proceso hubiera muerto, este test no habría llegado hasta acá.
}
```

Motor: ninguno.

**Prevención**

El middleware, la prueba, y una alerta sobre reinicios del contenedor: **un
proceso que se reinicia solo es siempre un incidente**, aunque el orquestador lo
disimule. Que "vuelve sola" se haya normalizado durante días es parte del
problema.

**Por qué llegó a producción**

Porque el orquestador hace bien su trabajo. Un reinicio automático convierte una
caída total en unos segundos de indisponibilidad, y unos segundos de
indisponibilidad se confunden con "internet estuvo lento". Sin una alerta sobre
reinicios, el sistema estuvo **fallando de la forma más grave posible** —muriendo
entero— y el síntoma parecía menor.

Y el diagnóstico se desvió porque el equipo venía de Node, donde ese síntoma es
imposible: el framework atrapa los `throw` y el proceso no se cae. Es un buen
recordatorio de que las intuiciones no cruzan de lenguaje.

**Si tu causa fue distinta a esta**

- *"Es el `timeout` del caos"* — plausible, porque también da error de red. Se
  descarta comprobando `CHAOS_LEVEL=off` y que el proceso **muere**, cosa que el
  caos no hace.
- *"Se cae la base y el pool se agota"* — daría `500`, no error de red, y el
  proceso seguiría vivo. Es el incidente `be-05`.
- Si tu fix fue *"que el orquestador reinicie más rápido"*, tapaste el síntoma de
  la forma más costosa posible.

</details>
FIN_DEL_ARCHIVO
wc -l $R/cuaderno-incidentes-be.md

# --- 2026-09-09T04:29:07 · Append incidents be-04 to be-06
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; cat >> $R/cuaderno-incidentes-be.md <<'FIN_DEL_ARCHIVO'

---

## Incidente be-04 — Las rifas se crean con la hora corrida

> **Fase:** be02 · **Categoría:** 🔥 base de datos · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "Creo una rifa que cierra a las 10 de la noche, la guardo, y cuando vuelvo a
> abrirla dice que cierra a las 3 de la mañana del día siguiente. Si la edito y
> la vuelvo a guardar, se queda igual. Lo raro es que en la pantalla del listado
> se ve bien. Pasó desde que cambiamos el servidor."

**Reportado por:** supervisor
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Determinar si el **instante** guardado es correcto o si de verdad se movió — no
es lo mismo, y confundirlo lleva a arreglar lo que no está roto. Después, decidir
dónde va el fix: ¿código, esquema o configuración?

### 🔧 Preparación

```bash
git checkout incidente/be-04
docker start rifas-pg
cd server && migrate -path migrations/postgres -database "$DATABASE_URL" up
go run ./cmd/seed -file ../mock/db.json
PORT=3011 go run ./cmd/api
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Antes de nada, contesta esta pregunta con una consulta: *¿el instante que hay en
la base es el mismo que se guardó?* Un instante puede **representarse** de
muchas formas sin cambiar de valor.

`22:00-05:00` y `03:00+00:00` del día siguiente, ¿son horas distintas o la misma
escrita de dos maneras?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```sql
SHOW TimeZone;
SELECT closes_at FROM raffles WHERE id = 1;
SELECT closes_at AT TIME ZONE 'America/Bogota' FROM raffles WHERE id = 1;
```

Y del otro lado, el JSON crudo:

```bash
curl -s localhost:3011/raffles/1 | jq -r .closesAt
```

Compáralo con lo que devolvía el mock antes del cambio.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`TIMESTAMPTZ` no guarda ninguna zona horaria: guarda un instante y lo **muestra**
en la zona de la sesión. ¿En qué zona está tu sesión, y quién la fijó?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**El instante no se movió.** `2026-08-30T22:00:00-05:00` y
`2026-08-31T03:00:00Z` son **exactamente el mismo momento**, escrito en dos
zonas distintas.

`TIMESTAMPTZ` guarda un instante en UTC y lo convierte a la zona de la **sesión**
al leerlo. El contenedor de Postgres arranca con `TimeZone = UTC`, así que
devuelve `03:00+00`, `lib/pq` lo entrega como un `time.Time` en UTC, y
`encoding/json` lo serializa con `Z`. El mock devolvía la cadena literal del
`db.json`, con su `-05:00`.

Así que hay **dos hechos y solo uno es un problema**:

1. El dato es correcto. Nada que arreglar. ✅
2. La **representación** cambió respecto de lo que devolvía el mock, y el
   contrato de `be00` fija el offset. ⚠️

Y por eso el listado se ve bien: la UI hace `new Date(closesAt)`, que interpreta
las dos formas igual y muestra la hora local correcta. El único sitio donde se
nota es donde alguien lee la cadena cruda — el formulario de edición.

Es el **error común nº 2 de `be03`** y la Divergencia 2 de `be02`, vistas desde el
ticket.

**Parche mínimo**

Configuración, no código: fijar la zona de la sesión.

```go
// server/internal/storage/storage.go, en Open()
if dialect == Postgres {
	if _, err := db.ExecContext(ctx, "SET TIME ZONE 'America/Bogota'"); err != nil {
		return nil, fmt.Errorf("fijando la zona de la sesión: %w", err)
	}
}
```

Con eso, `GET /raffles/1` vuelve a devolver `2026-08-30T22:00:00-05:00`, byte a
byte como el mock.

**La corrección correcta**

La de `be06`, que es una **política** y no un parche: dos zonas con jerarquía
explícita y un porqué para cada una.

| Qué | Valor | Para qué |
|---|---|---|
| Proceso Go | `TZ=UTC` | Decidir y comparar instantes |
| Sesión de base | `America/Bogota` | **Solo** serializar la salida |

> 🧭 El instante es la verdad; el offset de la serialización es cosmética. La
> zona de presentación no participa en ninguna decisión.

Lo importante es que la zona quede **fijada explícitamente** y no heredada del
host: un backend cuyo comportamiento depende de cómo esté configurada la máquina
falla distinto en cada ambiente.

**Prueba de regresión**

```go
func TestClosesAtConservaElOffsetDelContrato(t *testing.T) {
	var r map[string]interface{}
	srv.GET(t, "/raffles/1", token).ExpectStatus(200).JSON(t, &r)

	// El contrato de be00 fija offset, no "Z".
	require.Regexp(t, `[+-]\d{2}:\d{2}$`, r["closesAt"])
}

func TestElInstanteNoSeMueve(t *testing.T) {
	original, _ := time.Parse(time.RFC3339, "2026-08-30T22:00:00-05:00")
	created, err := store.Create(ctx, raffle.Raffle{ClosesAt: original, /* … */ })
	require.NoError(t, err)

	found, err := store.FindByID(ctx, created.ID)
	require.NoError(t, err)
	// Equal compara el INSTANTE. Con == compararías también huso y reloj
	// monótono, y fallaría por motivos que no son los del test.
	require.True(t, found.ClosesAt.Equal(original))
}
```

Motor: **PostgreSQL obligatorio**. Toca zonas horarias, que es una de las cuatro
áreas de la regla del motor (`D18`). En SQLite este par de pruebas no significa
nada: no hay tipo fecha.

**Prevención**

La política escrita, las dos pruebas, y —la más eficaz— el ejercicio 22 de
`be06`: correr la suite entera con `TZ=Asia/Tokyo`. Si algo falla, hay una
comparación mirando componentes de fecha. Ese paso debería estar en CI.

**Por qué llegó a producción**

Porque **el dato nunca estuvo mal** y todos los indicadores decían que sí. El
supervisor vio una hora distinta y reportó, con toda la razón, que la hora había
cambiado. Cualquiera habría empezado buscando dónde se suma o resta tiempo — y no
hay ninguna línea así en todo el sistema.

Es el caso arquetípico de un bug donde **la primera media hora se gasta
confirmando qué está realmente roto**. Aquí lo roto era la representación, no el
valor, y esa distinción no se le puede pedir a quien reporta.

**Si tu causa fue distinta a esta**

- *"Alguien suma 5 horas en algún lado"* — la hipótesis natural. Se descarta con
  `git grep -n "Add(.*Hour"`: no hay ninguna.
- *"El navegador convierte mal"* — se descarta mirando el JSON crudo con `curl`:
  el offset ya viene distinto del servidor.
- Si tu fix fue **restar cinco horas al guardar**, acabas de introducir el bug de
  verdad: ahora el instante sí se mueve, y en el próximo ambiente con otra zona
  se moverá otra vez y en otra dirección.

</details>

---

## Incidente be-05 — Todo funciona hasta que hay gente

> **Fase:** be02 · **Categoría:** 🔥 base de datos · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min
> · Hermano del incidente **19** del track base, con otra causa raíz

### 🎫 El ticket

> "En la mañana todo va perfecto. Como a las cinco de la tarde, que es cuando se
> vende más, la aplicación se pone lentísima y al rato ya no responde nada:
> queda todo cargando. Si reiniciamos el servidor, vuelve a funcionar de una y
> aguanta un par de horas. Probamos en la mañana con las mismas pantallas y no
> pasa."

**Reportado por:** supervisor
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducirlo **sin esperar a las cinco de la tarde** —esa es la parte difícil— y
determinar qué recurso se agota. El fix, y una prueba que lo habría atrapado.

### 🔧 Preparación

```bash
git checkout incidente/be-05
docker start rifas-pg
cd server && PORT=3011 SQL_DEBUG=1 go run ./cmd/api
```

Vas a necesitar carga. Un bucle basta:

```bash
for i in $(seq 1 200); do curl -s -o /dev/null localhost:3011/raffles & done; wait
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

*"Reiniciamos y vuelve"* es el dato más informativo del ticket: significa que algo
**se acumula** en el proceso y no se libera. No es la base —esa no se reinició— ni
el frontend.

*"Queda todo cargando"* también dice mucho: las peticiones no fallan, **esperan**.
¿Esperando qué?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Mientras el sistema está lento, desde otra terminal:

```sql
SELECT count(*), state FROM pg_stat_activity
WHERE datname = 'rifas' GROUP BY state;
```

Y desde Go, si instrumentas: `db.Stats()` te da `OpenConnections`, `InUse` y
`WaitCount`. Compáralos con `SetMaxOpenConns(25)`.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`*sql.DB` es un pool. ¿Qué le pasa a una conexión cuando abres un `*sql.Rows` y
nunca lo cierras? ¿Y qué diferencia hay entre `Query` y los `Get`/`Select` de
`sqlx`?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

Un `*sql.Rows` sin cerrar. La rama trae esto:

```go
// ❌ Cada llamada retiene una conexión del pool PARA SIEMPRE.
rows, err := s.db.QueryContext(ctx, query)
if err != nil {
	return nil, err
}
// falta: defer rows.Close()
for rows.Next() { … }
return raffles, nil
```

`Query` devuelve un `Rows` que **mantiene tomada su conexión** hasta que se cierra
—explícitamente o al agotar el iterador—. Un `return` anticipado, un `break`, o
simplemente olvidar el `defer`, y esa conexión no vuelve al pool nunca.

Con `SetMaxOpenConns(25)`, hacen falta 25 llamadas para agotarlo. A partir de la
26, **cada petición espera indefinidamente** una conexión que no va a liberarse.
De ahí el síntoma exacto: no falla, **espera**. Y reiniciar el proceso vacía el
pool, lo que explica por qué "vuelve de una".

📝 **Y por eso solo pasa a las cinco.** El agotamiento no depende del tiempo sino
del **número de llamadas** a esa ruta. En la mañana se llega a 25 en tres horas;
a las cinco, en veinte minutos. El patrón horario es una consecuencia del tráfico,
no una causa — y buscar "qué pasa a las cinco" es el desvío que este ticket
invita a tomar.

**Parche mínimo**

```go
rows, err := s.db.QueryContext(ctx, query)
if err != nil {
	return nil, err
}
// Sin excepción, en la línea siguiente. Cualquier camino de salida —error,
// break, return anticipado— pasa por acá.
defer rows.Close()
```

**La corrección correcta**

No usar `Query` a mano cuando `sqlx` ya resuelve el caso:

```go
// Select cierra el Rows por ti. Es una de las razones de usar sqlx y no
// database/sql pelado: elimina por construcción toda una clase de fugas.
raffles := []Raffle{}
if err := s.db.SelectContext(ctx, &raffles, query); err != nil {
	return nil, fmt.Errorf("listando rifas: %w", err)
}
```

Regla operativa que vale la pena adoptar: **si un archivo de store contiene
`QueryContext`, tiene que tener un `defer rows.Close()` tres líneas más abajo.**
Es un `grep` de revisión de código.

**Prueba de regresión**

```go
func TestElPoolNoSeAgota(t *testing.T) {
	db := testsupport.OpenPostgres(t)
	testsupport.MustPostgres(t, db, "mide el comportamiento real del pool de conexiones")
	db.SetMaxOpenConns(5)   // pool pequeño: la fuga aparece enseguida

	store := raffle.NewStore(db)
	for i := 0; i < 50; i++ {   // 10× el tamaño del pool
		ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
		_, err := store.List(ctx)
		cancel()
		// Con la fuga, a partir de la sexta iteración esto es
		// "context deadline exceeded": la conexión nunca llega.
		require.NoError(t, err, "iteración %d: el pool se agotó", i)
	}
	require.Zero(t, db.Stats().InUse, "quedaron conexiones tomadas")
}
```

Motor: **PostgreSQL obligatorio**. Con SQLite el pool es de una sola conexión
(`be02`) y el test no significa nada.

**Prevención**

Tres capas, y las tres hacen falta:

1. La prueba de arriba, con un pool pequeño.
2. **Exportar `db.Stats()`** —`InUse` y `WaitCount`— y alertar cuando `InUse` se
   acerque al máximo. Es la señal temprana: sube durante horas antes de que algo
   falle.
3. Timeouts en el contexto de cada consulta. No evitan la fuga, pero convierten
   "esperar para siempre" en un error con mensaje, que es diagnosticable.

**Por qué llegó a producción**

Porque **el código funciona perfectamente hasta que no**. No hay error, no hay
advertencia, no hay degradación gradual visible: el sistema va bien con 24
llamadas y se cuelga con 26. Ninguna prueba funcional lo detecta, porque cada
prueba hace una llamada y el pool se recicla entre ellas.

Y el reporte apuntaba a la hora, que es la correlación visible pero no la causa.
Un equipo puede pasar días buscando "qué proceso corre a las cinco".

**Si tu causa fue distinta a esta**

- *"Es un problema de rendimiento de la consulta"* — se descarta mirando
  `SQL_DEBUG`: las consultas que **sí** se ejecutan tardan lo mismo que en la
  mañana. Lo lento es esperar el turno.
- *"La base se queda sin conexiones"* — cerca, y vale la pena distinguirlo: si el
  límite lo pusiera Postgres (`max_connections`), verías `too many connections`
  como **error**. Acá no hay error: hay espera, y eso apunta al pool del cliente.
- *"Hay un deadlock"* — daría `deadlock detected` en el log y Postgres mataría una
  de las transacciones. No es el caso.
- Si tu fix fue **subir `SetMaxOpenConns`**, compraste tiempo: ahora se cuelga a
  las siete en vez de a las cinco.

</details>

---

## Incidente be-06 — El comprador aparece en blanco, pero solo a veces

> **Fase:** be03 · **Categoría:** 🔥 contrato · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "Desde el cambio de servidor, el tablero se ve raro: números que están libres
> aparecen como si tuvieran comprador. Y cuando entras al detalle no hay ningún
> nombre. Los vendedores no confían en la pantalla y están anotando en papel."

**Reportado por:** vendedor
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Determinar de qué lado del cable está la causa y por qué **ningún test la
detectó**. Después el fix, y la prueba que faltaba.

### 🔧 Preparación

```bash
git checkout incidente/be-06
cd server && go run ./cmd/seed -file ../mock/db.json && go run ./cmd/api
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

El frontend no cambió: `git diff pre-backend-go..HEAD -- . ':!server'` está
vacío. Así que si la pantalla se ve distinta, lo que cambió es **lo que llega**.

Mira el JSON crudo antes de mirar el componente.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
curl -s localhost:3001/raffles/1/numbers | jq '.[0]'
```

Compáralo con lo que devolvía el mock, campo por campo. Fíjate en el **tipo** de
cada valor, no solo en si el campo está.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En JavaScript, ¿`if (numero.participantId)` es verdadero para `null`? ¿Y para
`{"Int64":0,"Valid":false}`?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

`sql.NullInt64` serializado a JSON.

```go
// ❌ Escanea perfecto desde la base y produce esto:
//    {"raffleId":1,"number":"0347","status":"available",
//     "participantId":{"Int64":0,"Valid":false}}
type RaffleNumber struct {
	ParticipantID sql.NullInt64 `json:"participantId" db:"participant_id"`
}
```

El mock devolvía `null`. El backend devuelve **un objeto**. Y como en JavaScript
cualquier objeto es *truthy*, todo `if (number.participantId)` del tablero pasa a
ser verdadero **para todos los números**, incluidos los disponibles. De ahí que
aparezcan "con comprador"; y como el objeto no tiene nombre, el detalle sale en
blanco.

**Sin un solo error en consola.** El JSON es válido, la petición es `200`, y el
componente hace exactamente lo que le pidieron.

**Parche mínimo**

Un puntero:

```go
// nil serializa a null, que es lo que el contrato de be00 exige. Y el
// puntero además distingue "no hay participante" de "el participante es
// el cero", que es una distinción del dominio, no un detalle de Go.
ParticipantID *int64 `json:"participantId" db:"participant_id"`
```

`sqlx` lo escanea igual de bien. Es un cambio de una palabra.

**La corrección correcta**

La misma, más la regla general: **`sql.NullX` sirve para escanear, no para
serializar**. Si un tipo de `database/sql` cruza hasta la etiqueta JSON, es un
bug esperando su turno. Lo mismo vale para `sql.NullString`, `sql.NullTime` y
compañía.

**Prueba de regresión**

Y acá está lo que hace especial a este incidente:

```go
// ❌ ESTA PRUEBA NO LO ATRAPA, aunque parezca que sí.
func TestFindOneDevuelveElNumero(t *testing.T) {
	n, err := store.FindOne(ctx, 1, "0347")
	require.NoError(t, err)
	require.Equal(t, "available", n.Status)   // pasa con las dos versiones
}

// ✅ Esta sí. El problema no está en los datos: está en la SERIALIZACIÓN.
// Hay que comparar el JSON, no el struct.
func TestParticipantIdNuloLlegaComoNull(t *testing.T) {
	body := srv.GET(t, "/raffles/1/numbers", token).ExpectStatus(200).Raw()

	require.Contains(t, string(body), `"participantId":null`)
	// El centinela: si aparece "Valid", alguien volvió a meter un sql.NullX.
	require.NotContains(t, string(body), `"Valid":`)
}
```

📖 **La lección transferible:** un test que deserializa a un struct tipado **no
puede detectar un problema de contrato**, porque convierte lo que llegue a lo que
el struct dice. En pruebas de contrato hay que mirar los bytes, o deserializar a
`map[string]interface{}`.

Motor: PostgreSQL.

**Prevención**

La prueba de contrato, y un `grep` en la revisión de código:
`grep -rn "sql.Null" internal/*/[a-z]*.go` — cada resultado tiene que estar en un
struct que **no** se serialice.

**Por qué llegó a producción**

Porque `sql.NullInt64` es **la respuesta correcta a la pregunta equivocada**.
Quien lo escribió resolvía "cómo escaneo una columna anulable", y esa es
exactamente su función. El error está en que ese tipo llegó a la frontera del
contrato, y nada en el compilador ni en las pruebas señala ese cruce.

Y la suite estaba verde: todas las pruebas de `be02` comparaban structs, que es
lo natural. El bug vivía en el único sitio que nadie estaba mirando.

**Si tu causa fue distinta a esta**

- *"El seed no cargó los participantes"* — no hay participantes en el `db.json`;
  es correcto que no haya ninguno. La hipótesis es razonable y se descarta con un
  `SELECT`.
- *"El componente cambió"* — se descarta con el `git diff` del contrato.
- Si tu fix fue **cambiar el componente para que compruebe
  `participantId?.Valid`**, arreglaste la pantalla y rompiste la regla del track:
  el frontend no se toca, y además el día que el backend devuelva `null` correcto,
  volverías a romperlo.

</details>
FIN_DEL_ARCHIVO
wc -l $R/cuaderno-incidentes-be.md

# --- 2026-09-09T04:30:38 · Append incidents be-07 and be-08
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; cat >> $R/cuaderno-incidentes-be.md <<'FIN_DEL_ARCHIVO'

---

## Incidente be-07 — Faltan datos en las liquidaciones de agosto

> **Fase:** be03 · **Categoría:** 🔥 contrato · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min

### 🎫 El ticket

> "Nos pidieron el informe de cierre del semestre y necesitamos, por rifa,
> cuántos números se vendieron y si el ganador estaba vendido. Eso lo veíamos
> antes en la pantalla de liquidación. Ahora sacamos los datos y esos dos campos
> no están en ninguna parte. Las liquidaciones de marzo sí los tienen; las de
> agosto en adelante, no. Nadie tocó nada de liquidaciones."

**Reportado por:** tesorería
**Ambiente:** PROD

### 🎯 Qué se te pide

Determinar qué se perdió, **desde cuándo**, y si es recuperable. Este incidente
no termina necesariamente en un fix: parte del entregable es decidir qué se le
responde a tesorería.

### 🔧 Preparación

```bash
git checkout incidente/be-07
cd server && migrate -path migrations/postgres -database "$DATABASE_URL" up
go run ./cmd/api
# Liquida una rifa desde la aplicación, con Network abierto.
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Los campos que faltan, ¿**salieron** del navegador? Mira el cuerpo del
`POST /settlements` en Network, no la respuesta.

Si el dato viajó y no está guardado, el problema está del lado del servidor. Y
"desde agosto" tiene una fecha: ¿qué cambió entonces?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
curl -s localhost:3001/settlements | jq '.[0]'
```

Compara los campos de esa respuesta con el cuerpo que manda `createSettlement`
(Fase 8). Y después:

```sql
\d settlements
```

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si un `INSERT` solo nombra cinco columnas y el cuerpo trae ocho campos, ¿qué pasa
con los otros tres? ¿Falla, avisa, o devuelve `201`?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

El esquema de `be02` se diseñó **sin medir el cuerpo real** del
`POST /settlements`.

El thunk `createSettlement` de la Fase 8 manda ocho campos:

```json
{ "raffleId": 1, "winningNumber": "0347", "isWinnerSold": true, "soldCount": 42,
  "totalCollected": 21000000, "prizeAmount": 50000000, "margin": -29000000,
  "settledAt": "2026-08-30T22:05:11.031Z" }
```

Y la tabla tiene sitio para cinco: `raffle_id`, `winning_number`,
`total_collected`, `prize_amount`, `margin`. Los otros tres —`isWinnerSold`,
`soldCount`, `settledAt`— **el `INSERT` ni los nombra**.

El resultado es lo peor que puede pasar: **no falla nada**. El `201` sale bien, la
aplicación festeja, el slice guarda la liquidación completa (la que tiene en
memoria), y el dato se pierde en el momento de guardarse. El síntoma aparece seis
meses después, cuando alguien pregunta.

"Desde agosto" es la fecha del reemplazo de `be03`: `json-server` guardaba el
JSON entero, campos incluidos, porque no tenía esquema. **La rigidez del esquema
es lo correcto y es también lo que hizo visible un hueco que antes no existía.**

📝 Y por eso las de marzo sí los tienen: están en el `db.json` viejo.

**¿Es recuperable?** `soldCount` e `isWinnerSold` sí, reconstruyéndolos desde los
números vendidos de cada rifa. `settledAt` no: ese instante no está en ninguna
parte. Eso es lo que hay que responderle a tesorería, y conviene decirlo así de
claro.

**Parche mínimo**

Una migración. El fix **va en el esquema**, no en el código:

```sql
-- server/migrations/postgres/000003_settlement_full_shape.up.sql
ALTER TABLE settlements ADD COLUMN is_winner_sold BOOLEAN     NOT NULL DEFAULT false;
ALTER TABLE settlements ADD COLUMN sold_count     INTEGER     NOT NULL DEFAULT 0;
-- 💸 settledAt lo calcula el CLIENTE (new Date() en el thunk). Se guarda tal
-- cual llega porque cambiarlo sería cambiar el contrato. La autoridad del
-- reloj se cobra en be06.
ALTER TABLE settlements ADD COLUMN settled_at     TIMESTAMPTZ;
```

Más los tres campos en el `INSERT` del store. Y el `down` correspondiente, con su
trampa: SQLite no soporta `DROP COLUMN` hasta la 3.35, y con restricciones incluso
después.

**La corrección correcta**

Además de la migración, el **backfill** de lo recuperable:

```sql
-- soldCount se puede reconstruir desde los números vendidos.
UPDATE settlements s SET sold_count = (
    SELECT count(*) FROM raffle_numbers n
    WHERE n.raffle_id = s.raffle_id AND n.status = 'sold')
WHERE sold_count = 0;
```

⚠️ Y con una advertencia honesta en el informe: ese número es el de **hoy**, no el
del día de la liquidación. Si después se vendió algo más, no coinciden. Un dato
reconstruido no es el dato original y hay que etiquetarlo como tal.

**Prueba de regresión**

```go
func TestSettlementGuardaLosOchoCamposDelContrato(t *testing.T) {
	body := `{"raffleId":1,"winningNumber":"0347","isWinnerSold":true,
	          "soldCount":42,"totalCollected":21000000,"prizeAmount":50000000,
	          "margin":-29000000,"settledAt":"2026-08-30T22:05:11Z"}`

	srv.POST(t, "/settlements", token, body).ExpectStatus(201)

	var s settlement.Settlement
	require.NoError(t, db.Get(&s, `SELECT * FROM settlements WHERE raffle_id = 1`))

	// La aserción que importa: lo que ENTRÓ está en la base. Un test que
	// solo comprobara el 201 pasaría con el bug intacto.
	require.Equal(t, 42, s.SoldCount)
	require.True(t, s.IsWinnerSold)
	require.NotNil(t, s.SettledAt)
}
```

Motor: PostgreSQL.

**Prevención**

Una prueba de contrato por endpoint que verifique que **todo campo que entra se
persiste o se descarta a propósito**. Y una regla de proceso más barata que
cualquier prueba: **el esquema se diseña con el cuerpo real de las peticiones al
lado**, medido en Network, no deducido leyendo el slice. Es exactamente lo que
`be00` predica y lo que `be02` no aplicó del todo.

**Por qué llegó a producción**

Porque **ignorar campos desconocidos es el comportamiento por defecto de casi
todo**: `encoding/json` los descarta sin avisar y SQL solo escribe las columnas
que nombras. Los dos hacen lo razonable, y de la suma sale una pérdida silenciosa.

No hubo ningún síntoma durante seis meses. No hay error que buscar, no hay alerta
que configurar, no hay usuario que se queje — hasta que alguien necesita el dato y
ya no está. Es la clase de bug que solo se previene **antes**, y esa es la
lección: los bugs de contrato que duelen no son los que fallan, son los que pasan.

**Si tu causa fue distinta a esta**

- *"El frontend dejó de mandarlos"* — se descarta en Network: van en el cuerpo.
- *"Se perdieron al migrar los datos"* — se descarta comparando con el `db.json`:
  las viejas los tienen; las nuevas nacieron sin ellos.
- Si concluiste *"hay que guardar el JSON entero en una columna `jsonb` por si
  acaso"*, es una respuesta defendible y vale la pena discutirla: resuelve la
  pérdida y renuncia a que el esquema te avise. Cuál prefieres depende de si el
  dato es de negocio o de auditoría.

</details>

---

## Incidente be-08 — A algunos los saca de la sesión al mediodía y a otros nunca

> **Fase:** be04 · **Categoría:** 🔥 autenticación · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-45 min
> · Hermano del incidente **08** del track base, con otra causa raíz

### 🎫 El ticket

> "Hay dos o tres personas a las que se les cierra la sesión sola casi todos los
> días, siempre más o menos a la misma hora, y pierden lo que estaban haciendo.
> A la mayoría no le pasa nunca. Ya probamos con otro navegador y con otra
> máquina y sigue igual. ¿Será que tienen la cuenta mal configurada?"

**Reportado por:** soporte
**Ambiente:** PROD

### 🎯 Qué se te pide

Explicar el patrón —por qué a unos sí y a otros no, y por qué siempre a la misma
hora— y decidir si hay algo que arreglar. **Ojo con la última parte.**

### 🔧 Preparación

```bash
git checkout incidente/be-08
cd server && JWT_TTL=3m go run ./cmd/api   # tres minutos, para no esperar horas
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

*"Siempre a la misma hora"* suena a algo programado. Pero fíjate: la pregunta no
es a qué hora **se cierra** la sesión, sino a qué hora **empezó**.

Y "a la mayoría no le pasa nunca" es igual de informativo: ¿qué hacen distinto
esas personas durante el día?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Pega el token en https://jwt.io y mira el claim `exp`. Conviértelo a hora local y
compáralo con el `iat`.

Después, en el log del backend, busca los `401` de esas personas y mira qué dice
el mensaje.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el token dura una hora y alguien entra a las 8 y trabaja sin cerrar el
navegador, ¿a qué hora vence? ¿Y alguien que entra y sale cinco veces al día?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

El JWT expira y **no hay renovación**. El sistema funciona exactamente como se
diseñó.

Cuando el `exp` pasa, el middleware de `be04` devuelve `401`, y el interceptor de
respuesta de la Fase 2 —escrito mucho antes, para el `401` que inyectaba el
caos— dispara el logout global. El usuario aterriza en el login sin explicación y
pierde lo que estuviera haciendo.

El patrón se explica solo en cuanto lo ves:

- **A quienes les pasa** entran a primera hora y **no cierran el navegador en todo
  el día**. Su token vence `JWT_TTL` después del login: siempre a la misma hora,
  todos los días.
- **A quienes no les pasa** hacen logout o cierran el navegador varias veces, así
  que renuevan el token sin darse cuenta cada vez que vuelven a entrar.

No tiene nada que ver con la cuenta, ni con el navegador, ni con la máquina — y
por eso las tres pruebas de soporte no encontraron nada.

📝 `be-a-04` §5: **un JWT es autocontenido y no se puede revocar ni renovar solo.**
Esa es su gracia y su límite.

**Parche mínimo**

Ninguno en el código. Y esta es la parte incómoda del incidente:

> 🧭 **El sistema hizo lo correcto.** Un token que expira es una propiedad de
> seguridad, no un fallo. Lo que falta es la **renovación**, y está declarada como
> deuda 💸 viva en `be-a-09` §1 con su motivo escrito.

Lo que sí se puede hacer hoy, y hay que hacerlo:

1. **Responderle a soporte con la explicación real**, para que dejen de buscar en
   la configuración de las cuentas.
2. **Subir `JWT_TTL`** si la ventana operativa lo justifica —una jornada de ventas
   dura más de una hora—. Es configuración, no código, y no rompe nada.
3. **Registrar el caso** como el disparador de la deuda, que es precisamente lo
   que `be-a-09` pide vigilar.

**La corrección correcta**

*Refresh tokens*: un token corto para las peticiones y uno largo para renovarlo.
Diseño completo en el ejercicio 31 de `be04`.

⚠️ Y por qué no se hace acá: exige que **el cliente** llame al endpoint de
renovación, o sea tocar `apiClient.js`, sus dos interceptores y probablemente
`authSlice.js`. Eso es media capa de red del frontend, y **choca con la regla del
track y con `D27`**, cuya única excepción está acotada a `authService.js`.

Decidir no pagar una deuda y escribir por qué es una forma legítima de
administrarla. Lo que no sería legítimo es que el usuario y soporte no sepan que
existe.

**Prueba de regresión**

No hay regresión que probar —no hay bug— pero sí una prueba que **fija el
comportamiento como esperado**, que es lo que impide que alguien lo "arregle"
quitando el `exp`:

```go
func TestTokenVencidoSeRechaza(t *testing.T) {
	signer, _ := auth.NewSigner(testSecret, -1*time.Minute)  // ya nació vencido
	token, err := signer.Sign(2, "organizador@rifas.test")
	require.NoError(t, err)

	_, err = signer.Verify(token)
	require.ErrorIs(t, err, auth.ErrInvalidToken)
}

func TestTokenSinExpiracionNoSeEmite(t *testing.T) {
	// Un token sin exp es una llave maestra permanente. Que esto sea
	// imposible de construir es la prevención.
	_, err := auth.NewSigner(testSecret, 0)
	require.Error(t, err)
}
```

Motor: ninguno.

**Prevención**

No es técnica, y por eso es la parte interesante: **documentar el comportamiento
esperado** en un sitio donde soporte lo encuentre. Un incidente que consume horas
de tres equipos para concluir "funciona como está diseñado" es un fallo de
comunicación, no de código.

Y una mejora de experiencia que **sí** cabría del lado del servidor: distinguir en
el log un token **vencido** de uno **inválido**. Al cliente se le sigue devolviendo
el mismo `401` —no tiene por qué saber la diferencia— pero quien diagnostica sí la
necesita.

**Por qué llegó a producción**

Porque nadie se preguntó **qué le pasa a un usuario cuando el token vence**. Se
decidió la duración, se implementó la expiración, se probó que un token vencido
se rechaza — y no se probó el recorrido completo desde la silla del usuario. La
consecuencia visible de una decisión correcta puede seguir siendo un problema
operativo.

**Si tu causa fue distinta a esta**

- *"El caos está inyectando `401`"* — es la hipótesis natural viniendo del track
  base, donde ese síntoma era exactamente eso. Se descarta con `CHAOS_LEVEL=off`
  y comprobando que el patrón horario persiste. **Es el hermano del incidente 08
  del cuaderno base: mismo síntoma, causa distinta.**
- *"El secreto rota y los tokens dejan de validar"* — daría un fallo masivo y
  simultáneo, no individual y escalonado.
- *"Se cae la base y devuelve `401`"* — no: sin base, `/health` da `503` y las
  rutas dan `500`.
- Si tu fix fue **quitar el `exp`**, cambiaste un problema de experiencia por un
  agujero de seguridad permanente.

</details>
FIN_DEL_ARCHIVO
wc -l $R/cuaderno-incidentes-be.md

# --- 2026-09-09T04:32:25 · Append incidents be-09 and be-10
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; cat >> $R/cuaderno-incidentes-be.md <<'FIN_DEL_ARCHIVO'

---

## Incidente be-09 ⭐ — Vendimos tres números dos veces, y solo los redondos

> **Fase:** be05 · **Categoría:** 🔥 transacciones · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 90-120 min
> ⭐ **Uno de los dos más formativos del track** · Hermano del incidente **11** del track base, con otra causa raíz

### 🎫 El ticket

> "En el sorteo del sábado tuvimos tres reclamos: tres personas con el mismo
> número que otra persona. Los números eran el 0500, el 1000 y el 2000. Nos
> llamó la atención que fueran justo los redondos, así que revisamos y esos son
> los que más piden. Tuvimos que devolver plata. En el sistema el número aparece
> vendido una sola vez, con el último comprador."

**Reportado por:** tesorería
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducirlo **a voluntad** —que acá es la mitad del trabajo y no es trivial—,
explicar por qué el sesgo hacia los números redondos es una pista y no ruido, y
aplicar el fix. Y una pregunta más: ¿por qué el sistema muestra una sola venta?

### 🔧 Preparación

```bash
git checkout incidente/be-09
cd server && migrate -path migrations/postgres -database "$DATABASE_URL" up
go run ./cmd/seed -file ../mock/db.json
CHAOS_LEVEL=off go run ./cmd/api
```

Vas a necesitar clientes concurrentes de verdad. Dos pestañas no bastan.

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Antes que nada, descarta una orilla: reproduce **sin navegador**. Si `curl`
también lo produce, el frontend queda fuera de la investigación y te ahorras la
mitad del terreno.

Y sobre los números redondos: no son especiales para el software. Son especiales
para las **personas**. ¿Qué tiene de particular un número que mucha gente quiere
al mismo tiempo?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Lanza veinte ventas simultáneas sobre el mismo número y cuenta cuántas devuelven
`200`:

```bash
for i in $(seq 1 20); do
  curl -s -o /dev/null -w "%{http_code}\n" \
    -X POST localhost:3001/raffles/1/numbers/0500/sell \
    -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
    -d '{"participantId":null}' &
done; wait
```

Después mira `SellNumber` en `server/internal/rafflenumber/service.go` y cuenta
cuántas operaciones separadas hay entre leer el estado y escribirlo.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si dos transacciones leen `status = 'available'` **antes** de que ninguna
escriba, ¿qué decide cada una? ¿Y qué garantiza `READ COMMITTED` exactamente —
atomicidad, o exclusión mutua?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

Un **check-then-act** sin transacción ni bloqueo. `SellNumber` hace tres
operaciones separadas:

```go
current, _ := s.store.FindOne(ctx, raffleID, number)  // (1) lee: "available"
if current.Status == "sold" { return ErrAlreadySold } // (2) decide
return s.store.MarkSold(ctx, raffleID, number, …)     // (3) escribe
```

Entre (1) y (3) **cabe otra ejecución completa**. Dos vendedores leen
`available`, los dos deciden que se puede, los dos escriben, **los dos reciben
`200`**. No hay error en ninguna capa.

Y como vender era un `UPDATE` sobre una fila que ya existe, la segunda escritura
**pisa** a la primera: en la base queda una sola venta, con el último comprador.
De ahí que el sistema muestre una y tesorería tenga dos reclamos. **La evidencia
del bug se destruyó a sí misma.**

📝 **El sesgo hacia los redondos es la pista principal, no ruido.** La ventana de
la carrera dura microsegundos: para que dos peticiones caigan dentro, tienen que
ser casi simultáneas. Eso solo ocurre con los números que **muchas personas
quieren a la vez**, y los redondos son exactamente esos. El patrón no está en el
código: está en el comportamiento humano que activa el código.

Es el mismo síntoma del **incidente 11 del track base**. Allá se estudia desde el
store, con doble clic y peticiones que se cruzan, y se mitiga con corrección
optimista y rollback. Acá se ve la verdad incómoda: **ninguna race condition de
venta se resuelve en el cliente.** Se puede hacer improbable. Resolver, no.

**Parche mínimo**

No hay parche mínimo honesto, y decirlo es parte de la respuesta. Envolver los
tres pasos en una transacción **no arregla nada**: `READ COMMITTED` da atomicidad,
no exclusión mutua, y las dos transacciones siguen leyendo `available`. Es el
error más peligroso de este incidente porque **parece** arreglado y baja la
frecuencia lo suficiente como para que las pruebas manuales pasen.

Lo mínimo que de verdad protege es una transacción **con bloqueo**:

```go
err := s.store.WithTx(ctx, func(tx Tx) error {
	// FOR UPDATE toma un bloqueo exclusivo sobre la fila. La segunda
	// transacción que pida la misma fila SE QUEDA ESPERANDO —no lee un dato
	// viejo, no falla: espera— hasta que esta confirme. Al despertar, lee
	// el estado ya actualizado y decide bien.
	current, err := tx.FindOneForUpdate(ctx, raffleID, number)
	if err != nil {
		return err
	}
	if current.Status == "sold" {
		return ErrAlreadySold
	}
	return tx.MarkSold(ctx, raffleID, number, participantID)
})
```

**La corrección correcta**

La de `be05`, que además de bloquear cambia el **modelo**:

> 🧭 **La venta se modela como un hecho, no como un estado** (`D28`). Cada venta
> es una fila nueva en `sales` con `UNIQUE (raffle_id, number)`.

Y eso importa por dos razones, las dos visibles en este incidente:

1. **Un `UNIQUE` no puede proteger un `UPDATE`** sobre una fila que ya existe: no
   hay segunda fila que rechazar. Con el modelo de estado, la defensa más fuerte
   —una restricción de la base— sencillamente no estaba disponible.
2. **Los hechos no se pisan.** Con `sales`, la segunda venta habría fallado *y*
   habría quedado el rastro de que alguien lo intentó. Con el modelo de estado, la
   evidencia se perdió.

```sql
CONSTRAINT sales_unique_number_per_raffle UNIQUE (raffle_id, number)
```

```go
// El 409 deja de ser un if: lo produce la BASE. Nuestro código puede
// equivocarse en las condiciones de carrera; la restricción, no.
var pqErr *pq.Error
if errors.As(err, &pqErr) && pqErr.Code == "23505" {
	return ErrAlreadySold
}
```

Cinturón y tirantes, y hacen falta los dos: el `FOR UPDATE` protege **este**
camino; el `UNIQUE` protege los que escribirá otra persona dentro de dos años sin
leer nada de esto.

**Prueba de regresión**

```go
func TestVentaConcurrenteSoloUnGanador(t *testing.T) {
	db := testsupport.OpenPostgres(t)
	testsupport.MustPostgres(t, db, "verifica el bloqueo de fila bajo concurrencia real")

	const contenders = 20
	// La BARRERA es lo que hace válida la prueba: sin ella las goroutines
	// se lanzan escalonadas, la carrera no ocurre, y el test pasa contra el
	// código vulnerable.
	var start sync.WaitGroup
	start.Add(1)
	var wg sync.WaitGroup
	errs := make([]error, contenders)

	for i := 0; i < contenders; i++ {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			start.Wait()
			_, errs[i] = svc.SellNumber(ctxConUsuario(1), 1, "0500", nil)
		}(i)
	}
	start.Done()
	wg.Wait()

	ganadores := 0
	for _, err := range errs {
		if err == nil {
			ganadores++
		} else if !errors.Is(err, ErrAlreadySold) {
			t.Fatalf("error inesperado: %v", err)
		}
	}
	require.Equal(t, 1, ganadores)

	// La verificación que de verdad importa: la BASE. Un servicio que
	// devolviera un solo 200 y hubiera insertado dos filas pasaría todas
	// las aserciones de arriba.
	var ventas int
	require.NoError(t, db.Get(&ventas,
		`SELECT count(*) FROM sales WHERE raffle_id=1 AND number='0500'`))
	require.Equal(t, 1, ventas)
}
```

Motor: **PostgreSQL obligatorio**. Toca concurrencia y bloqueos: dos de las cuatro
áreas de la regla del motor. En SQLite `FOR UPDATE` es un error de sintaxis, y sin
él aparece `SQLITE_BUSY` porque la base se serializa entera. **La concurrencia no
se puede probar contra SQLite ni siquiera mal.**

⚠️ Y la propiedad que hace válida esta prueba: **falla contra el código de
`be03`**. Si pasa contra el código vulnerable, la prueba está mal — arréglala
antes de confiar en ella.

**Prevención**

Tres niveles, y hacen falta los tres:

1. **La restricción de la base.** Protege todos los caminos, incluidos los que no
   existen todavía y los `INSERT` desde `psql` a las tres de la mañana.
2. **La prueba de concurrencia con barrera**, corriendo en CI contra Postgres.
3. **El criterio de revisión de código:** cualquier secuencia leer → decidir →
   escribir sobre un recurso compartido es sospechosa hasta que se demuestre que
   está dentro de una transacción con bloqueo.

**Por qué llegó a producción**

Porque **no se reproduce cuando lo buscas**. La ventana dura microsegundos: con
dos pestañas y dos clics no pasa nunca. Pasa el día del sorteo grande, con cien
vendedores, sobre los tres números que todo el mundo quiere.

Ninguna prueba funcional lo detecta, porque las pruebas funcionales hacen una
llamada por vez. Y una prueba de concurrencia **sin barrera de salida** tampoco:
pasa contra el código roto, que es la forma más traicionera de tener cobertura.

A eso se sumó que la evidencia se destruyó sola —la base muestra una venta— así
que durante días el equipo estuvo investigando si tesorería se había equivocado.
El código funcionaba correctamente el 99,99 % de las veces, que es exactamente
la frecuencia que hace que nadie sospeche del código.

**Si tu causa fue distinta a esta**

- *"Es el doble clic del vendedor"* — es la mitigación que estudia la Fase 5 del
  track base, y es una hipótesis excelente. Se descarta reproduciéndolo con `curl`,
  sin navegador: el bug está del lado del servidor y ninguna guarda de cliente lo
  cierra.
- *"Falta un índice único"* — vas bien, y no alcanza solo: con el modelo de estado
  de `be03`, la venta es un `UPDATE` y no hay unicidad que violar. Hay que cambiar
  el modelo. Si llegaste hasta acá, llegaste a `D28`.
- *"Es el caos inyectando reintentos"* — se descarta con `CHAOS_LEVEL=off`.
- Si tu fix fue **envolver en una transacción sin bloqueo**, léelo otra vez: bajó
  la frecuencia y no cerró la ventana. Es el peor resultado posible, porque parece
  arreglado.

</details>

---

## Incidente be-10 — Un número quedó reservado para siempre

> **Fase:** be05 · **Categoría:** 🔥 transacciones · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-45 min

### 🎫 El ticket

> "El 1500 de la rifa 3 aparece apartado desde el martes y nadie lo compró. Un
> cliente lo quiere y no lo podemos vender: el sistema dice que está reservado.
> ¿Se puede liberar a mano? Nos ha pasado con cuatro o cinco números este mes."

**Reportado por:** vendedor
**Ambiente:** PROD

### 🎯 Qué se te pide

Explicar cómo un número llega a ese estado y decidir dónde debe vivir la
expiración. Y un detalle que parece menor y no lo es: **¿el estado bloqueado es
correcto o es basura?**

### 🔧 Preparación

```bash
git checkout incidente/be-10
cd server && go run ./cmd/api
npm start
# Reserva un número desde el tablero y cierra la pestaña antes de comprar.
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Reserva un número y **cierra la pestaña**. Espera. ¿Se libera?

Ahora pregúntate quién lo iba a liberar: ¿qué proceso, corriendo dónde?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```sql
SELECT number, status, reserved_until FROM raffle_numbers
WHERE raffle_id = 3 AND status = 'reserved';
```

Mira la columna `reserved_until`. ¿Tiene valor? ¿Y quién lo lee?

Después busca en el frontend dónde se cancela una reserva (Fase 5, `setTimeout`;
Fase 6, un epic).

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si quien vence la reserva es un temporizador del navegador, ¿qué pasa cuando el
navegador se cierra?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**La reserva la expiraba el cliente.** La Fase 5 del track base lo hace con un
`setTimeout` y la Fase 6 con un epic; el backend solo marcaba `status =
'reserved'` y se olvidaba.

Si el usuario cierra la pestaña, se le acaba la batería o pierde la conexión, ese
temporizador muere con él y **nadie libera el número jamás**. La columna
`reserved_until` existía en el esquema desde `be02` y no la leía nadie.

Es una deuda 💸 declarada desde el mock de la Fase 3, con esta nota textual:
*"un backend serio expiraría del lado del servidor, porque el cliente puede
cerrar el navegador y dejar el número bloqueado para siempre"*. Está así **para
que el problema se vea**, y este ticket es el problema viéndose.

Y la respuesta a la pregunta incómoda: **el estado no es basura, es correcto**. La
reserva se hizo bien; lo que falta es quién la caduca. Por eso liberar a mano es
un parche legítimo y no una corrupción de datos.

**Parche mínimo**

Liberar a mano lo que está atascado, que es lo que pide el vendedor:

```sql
UPDATE raffle_numbers
SET status = 'available', reserved_until = NULL
WHERE status = 'reserved' AND reserved_until < now();
```

⚠️ Antes de correrlo: si `reserved_until` está en `NULL` —porque nadie lo
escribía— esa consulta **no libera nada**. Ese es el hallazgo dentro del hallazgo.
En ese caso hay que acotar por otro criterio y decirlo en el runbook:

```sql
-- Con reserved_until sin poblar, se usa la antigüedad como aproximación.
-- Es un parche, y hay que anotarlo como tal.
UPDATE raffle_numbers SET status = 'available'
WHERE status = 'reserved' AND raffle_id = 3 AND number = '1500';
```

**La corrección correcta**

La de `be05`, en dos piezas que se complementan:

```go
// 1. La reserva escribe su vencimiento.
until := time.Now().Add(s.reservationTTL)
reserved, err = tx.MarkReserved(ctx, raffleID, number, until)
```

```go
// 2. Un worker las vence. Y sabe morir: el select sobre ctx.Done() lo
//    conecta con el apagado ordenado de be01 — un worker que no termina
//    convierte un Shutdown limpio en un proceso zombi.
for {
	select {
	case <-ctx.Done():
		return
	case <-ticker.C:
		n, err := store.ExpireReservations(ctx)   // un solo UPDATE, idempotente
		if err != nil {
			log.Printf("[expiry] error venciendo reservas: %v", err)
			continue
		}
		if n > 0 {
			log.Printf("[expiry] %d reservas vencidas y liberadas", n)
		}
	}
}
```

Y la tercera pieza, que es la que casi siempre se olvida: **una reserva vencida
cuenta como disponible aunque el barrido todavía no haya pasado.**

```go
expired := current.ReservedUntil != nil && current.ReservedUntil.Before(time.Now())
if current.Status != "available" && !(current.Status == "reserved" && expired) {
	return ErrNotAvailable
}
```

> 🧭 **La verdad es el reloj, no el último barrido.** Si dependieras del worker,
> la ventana entre ejecuciones sería un agujero funcional: un número vencido hace
> diez segundos seguiría sin poder venderse.

**Prueba de regresión**

```go
func TestReservaVencidaSePuedeVender(t *testing.T) {
	// Reserva que nació vencida: el reloj inyectado de be06 hace esto
	// trivial de montar, y sin él habría que esperar de verdad.
	reservarConVencimiento(t, 1, "1500", time.Now().Add(-time.Minute))

	// Sin esperar al worker: el servicio ya debe considerarlo disponible.
	_, err := svc.SellNumber(ctxConUsuario(1), 1, "1500", nil)
	require.NoError(t, err)
}

func TestElWorkerLiberaLasVencidas(t *testing.T) {
	reservarConVencimiento(t, 1, "0347", time.Now().Add(-time.Minute))

	n, err := store.ExpireReservations(context.Background())
	require.NoError(t, err)
	require.Equal(t, int64(1), n)
	require.Equal(t, "available", statusOf(t, 1, "0347"))
}
```

Motor: PostgreSQL.

**Prevención**

El worker, la comprobación de vencimiento en el servicio, y —lo que convierte
esto en operable— **una consulta de vigilancia**: cuántos números llevan
reservados más de `reservationTTL`. Si ese número no es cero, el worker no está
corriendo. Es la clase de métrica que cuesta una consulta y evita el ticket
entero.

💸 Y una deuda que este fix introduce y hay que declarar: **el worker corre en
todas las réplicas**. No rompe nada —el `UPDATE` es idempotente— pero es trabajo
repetido. `be-a-09` §3 lo recoge, y la solución es un `pg_advisory_lock`.

**Por qué llegó a producción**

Porque la expiración en el cliente **funciona en el camino feliz**, que es el que
se prueba. Reservar y comprar funciona; reservar y esperar funciona; reservar y
**desaparecer** es el camino que nadie ejecuta a propósito y que los usuarios
ejecutan todo el día.

Y el daño es acumulativo y silencioso: cuatro o cinco números al mes no disparan
ninguna alarma, pero no se recuperan solos y el inventario se degrada mes a mes.

**Si tu causa fue distinta a esta**

- *"El usuario lo reservó y no lo compró"* — es exactamente lo que pasó, y no es
  la causa: la causa es que el sistema no previó ese caso. Distinguir "qué hizo el
  usuario" de "qué falló en el sistema" es el trabajo.
- *"Se cayó el epic de la Fase 6"* — plausible si el flujo pasó por ahí, y se
  descarta reproduciéndolo con la pestaña cerrada: sin navegador no hay epic que
  caerse.
- Si tu fix fue **un script manual que corre cada noche**, resuelve el síntoma y
  es defendible como parche. Pero deja una ventana de hasta 24 horas y vive fuera
  del sistema, donde nadie lo mantiene ni lo monitorea.

</details>
FIN_DEL_ARCHIVO
wc -l $R/cuaderno-incidentes-be.md

# --- 2026-09-09T04:34:09 · Append incidents be-11 and be-12
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; cat >> $R/cuaderno-incidentes-be.md <<'FIN_DEL_ARCHIVO'

---

## Incidente be-11 — A los vendedores de la costa se les cierra la rifa una hora antes

> **Fase:** be06 · **Categoría:** 🔥 tiempo · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "Los muchachos de la costa dicen que a ellos la rifa se les cierra una hora
> antes que a los del interior: cuando todavía se puede vender, a ellos ya no
> les sale el botón. Debe ser el tema de las zonas horarias, ¿no? Nos están
> reclamando porque pierden ventas."

**Reportado por:** supervisor
**Ambiente:** PROD

### 🎯 Qué se te pide

Evaluar la teoría del reporte —y el reporte trae una, como casi siempre—,
encontrar la causa real, y decidir **qué se puede arreglar y qué no**. Este
incidente termina en una conversación, no en un commit.

### 🔧 Preparación

```bash
git checkout incidente/be-11
cd server && go run ./cmd/api
npm start
# Para simular la máquina afectada, adelanta el reloj del sistema una hora
# (desactivando la sincronización automática).
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Empieza por la teoría del reporte, porque descartarla es rápido: **Colombia
entera está en UTC−5, todo el año, sin horario de verano.** No hay dos zonas.

Descartada esa, queda la pregunta interesante: la hora de cierre, ¿la evalúa el
mismo reloj para todo el mundo?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

En la máquina afectada, en la consola del navegador:

```javascript
new Date().toISOString()
```

Y compáralo con la hora del servidor:

```bash
curl -s -D - -o /dev/null localhost:3001/health | grep -i 'x-server-time'
```

Después mira qué reloj usa `isPastClosing` (Fase 7, `src/features/raffles/closing.js`).

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el frontend esconde el botón y el backend seguiría aceptando la venta, ¿quién
está equivocado? ¿Y qué pierde el usuario exactamente?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**El reloj de esas máquinas está adelantado una hora.** No es la zona horaria: es
la hora.

La teoría del reporte era razonable y es falsa: Colombia es una sola zona
(UTC−5) y no tiene horario de verano. Y aunque hubiera varias, **no importaría**:
`isPastClosing` compara instantes (`new Date(closesAt).getTime()` contra
`new Date().getTime()`), y una comparación de instantes es independiente de la
zona en que esté configurado el equipo.

Lo que sí importa es el **reloj**. `new Date()` devuelve la hora del sistema
operativo del usuario. Si esa hora está adelantada —sincronización desactivada,
una máquina que se configuró a mano, un equipo que estuvo apagado y arrancó con la
hora de la BIOS— la interfaz calcula que la rifa ya cerró y esconde el botón,
mientras el servidor sabe perfectamente que todavía no.

📝 **Y la geografía era una correlación, no una causa.** Un lote de equipos que se
compró junto y se configuró junto comparte el mismo problema de sincronización.
El reporte agrupó por región porque es lo visible; agrupar por lote de compra
habría dado la misma lista.

**Parche mínimo**

No hay parche en el código. Lo que hay es un diagnóstico y dos acciones:

1. **Sincronizar el reloj** de esas máquinas (activar NTP). Resuelve el caso hoy.
2. **Confirmar que no se perdió ninguna venta indebidamente aceptada**: no. El
   servidor nunca se equivocó — este es el escenario "reloj adelantado" de
   `be06` §7, el que solo cuesta ventas perdidas, no datos corruptos.

> 🧭 **La asimetría que hay que entender y explicar.** Con el reloj **adelantado**,
> la UI cierra antes y el usuario **pierde una venta legítima**: molesto. Con el
> reloj **atrasado**, la UI ofrece el botón y el backend rechaza con `409`:
> mensaje confuso, **datos correctos**.
>
> Antes de `be06`, el segundo caso vendía un número de una rifa cerrada. **Una
> interfaz confusa es un problema; una base de datos mentirosa es un incidente.**

**La corrección correcta**

Que el frontend deje de mirar su propio reloj: el `serverNow` que la Fase 7 dejó
anotado como deuda 💸 y que su ejercicio 27 preguntaba qué fase debería pagar.

La **mitad barata ya está hecha** — `be06` publica la hora del servidor en cada
respuesta:

```go
w.Header().Set("X-Server-Time", s.clock.Now().Format(time.RFC3339Nano))
```

Hoy no lo consume nadie. Está puesto igual, y no es un adorno: es el punto donde
la deuda se vuelve barata de pagar. La otra mitad —un interceptor que guarde el
desfase y una función `serverNow()` que lo aplique— son unas treinta líneas en
`apiClient.js` y `closing.js`, y **choca con la regla del track y con `D27`**.

⚠️ Y un detalle técnico que conviene conocer: medir el desfase como *hora del
servidor − hora local* incluye la latencia de la red. La corrección seria
—descontar la mitad del tiempo de ida y vuelta— es media implementación de NTP, y
explica por qué sincronizar relojes es más difícil de lo que parece.

**Prueba de regresión**

No hay bug del backend que probar. Lo que sí se prueba es que **el servidor no
depende del reloj del cliente**, que es lo que hace que el daño sea acotado:

```go
func TestElServidorIgnoraLaHoraDelCliente(t *testing.T) {
	// Una hora antes del cierre, según el reloj del servidor.
	svc := newServiceWithClock(t, fixedClock{closesAt.Add(-time.Hour)})

	// El cliente puede mandar lo que quiera: no hay ningún campo de hora
	// en el cuerpo de una venta, y aunque lo hubiera, no se leería.
	_, err := svc.SellNumber(ctxConUsuario(1), 1, "0347", nil)
	require.NoError(t, err)
}
```

Motor: PostgreSQL. Toca zonas horarias.

**Prevención**

Tres cosas, en orden de coste:

1. **La línea de log del desfase** que `be06` ya registra al liquidar. Convierte
   este ticket en un diagnóstico de dos minutos: *"el cliente dice las 22:03 y el
   servidor las 21:03"*.
2. **La métrica agregada** del ejercicio 23 de `be06`: cuántos usuarios tienen el
   reloj desfasado y cuánto. Es el argumento que decidiría si vale la pena pagar
   la deuda del `serverNow`. 💸 Hoy solo hay líneas sueltas de log.
3. **Sincronización de reloj en el aprovisionamiento** de los equipos. Es la
   prevención real y no es técnica: es de operación.

**Por qué llegó a producción**

Porque **el sistema está funcionando correctamente** y aun así alguien pierde
dinero. No hay ningún componente roto: el backend decide bien, el frontend
calcula bien con el dato que tiene, y el dato que tiene está mal por causas
ajenas al software.

Es el tipo de incidente donde la respuesta *"no es un bug"* es técnicamente cierta
y operativamente inútil. Lo que faltaba era **no depender de un dato que no
controlamos**, y esa dependencia estaba declarada como deuda desde la Fase 7
—con su nota de época y todo— sin que nadie le hubiera puesto una fecha.

**Si tu causa fue distinta a esta**

- *"Es la zona horaria"* — la teoría del reporte, y es **la hipótesis correcta de
  formular**: es lo primero que hay que descartar. Se cae con dos datos: Colombia
  es una sola zona, y la comparación es de instantes.
- *"El backend cierra antes de tiempo"* — se descarta con `curl` desde una máquina
  con el reloj bien: el servidor sigue aceptando ventas.
- *"El worker de cierre marcó la rifa como `closed` antes"* — buena hipótesis, y
  se descarta mirando `status` y `closes_at` en la base.
- Si tu fix fue **restar una hora en el cliente**, arreglaste esas máquinas y
  rompiste todas las demás.

</details>

---

## Incidente be-12 — Vendimos doscientos números después del cierre

> **Fase:** be06 · **Categoría:** 🔥 tiempo · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min
> · Hermano del incidente **16** del track base, con otra causa raíz

### 🎫 El ticket

> "Al liquidar la rifa del 30 nos dio que se recaudaron 1.100.000 pesos pero el
> corte que hicimos a la hora del cierre decía 900.000. Revisando, hay como
> doscientos números con hora de venta posterior a las diez de la noche, que es
> cuando cerraba. Uno de esos es el ganador. No sabemos si pagar el premio."

**Reportado por:** tesorería
**Ambiente:** PROD

### 🎯 Qué se te pide

Determinar cómo entraron esas ventas, si el premio se debe pagar, y qué hace
falta para que no vuelva a pasar. Es el incidente con más consecuencias del
track: hay dinero y hay una decisión de negocio que depende de tu diagnóstico.

### 🔧 Preparación

```bash
git checkout incidente/be-12
cd server && go run ./cmd/api
npm start
# Pon una rifa a cerrar en dos minutos y sigue vendiendo pasada la hora.
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Prueba lo más directo: pasada la hora de cierre, manda una venta con `curl`,
**sin navegador**. Si entra, la interfaz no tiene nada que ver.

Y si entra: ¿quién estaba comprobando la hora, y dónde vive ese código?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
grep -rn "closesAt\|ClosesAt" server/internal/
grep -rn "isPastClosing" src/
```

Cuenta cuántas comprobaciones de la hora de cierre hay en cada orilla.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si la única guarda vive en el cliente, ¿qué la evita? Un reloj mal, una pestaña
abierta desde antes del cierre, o `curl`. ¿Cuál de las tres es la más probable
con doscientos números?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**El backend nunca comprobó la hora de cierre.** La única guarda vivía en el
cliente: `isPastClosing(raffle.closesAt)` en el tablero y en el epic de la Fase 7.

Cualquiera de estas tres cosas la esquiva:

1. **Una pestaña abierta desde antes del cierre**, con el estado de la rifa
   cacheado en el store. Es la más probable con doscientos números: los
   vendedores no recargan la página.
2. **Un reloj de cliente atrasado** — el escenario espejo de `be-11`.
3. **Cualquier cliente que no sea el navegador.** `curl` no ejecuta
   `isPastClosing`.

Y el resultado no es un error: son doscientas ventas **aceptadas y confirmadas**,
con su `200`, indistinguibles de las legítimas salvo por el `sold_at`.

Es el mismo síntoma del **incidente 16 del track base**, donde la causa es que el
frontend compara mal la fecha. Acá la causa es más profunda: **no hay nada que
comparar del lado que decide**.

**Sobre el premio.** El diagnóstico no lo decide, pero sí lo informa, y esa
distinción importa: la venta ganadora fue **aceptada por el sistema**. Quien la
compró hizo todo bien y recibió una confirmación. Que el sistema no debiera
haberla aceptado es un problema de la empresa, no del comprador. Tu entregable es
la evidencia —`sold_at` contra `closes_at`, con precisión de segundos, y en qué
orden llegaron— para que negocio decida con datos.

**Parche mínimo**

Comprobar la hora en el servidor, y comprobarla **dentro de la transacción de
venta**:

```go
err := s.store.WithTx(ctx, func(tx Tx) error {
	// FOR SHARE y no FOR UPDATE: solo necesitamos que nadie CAMBIE la
	// closesAt mientras vendemos, no bloquear a los demás vendedores entre
	// sí. Un FOR UPDATE acá serializaría todas las ventas de la rifa
	// contra una sola fila y tiraría a la basura lo que consiguió be05.
	raffle, err := tx.FindRaffleForShare(ctx, raffleID)
	if err != nil {
		return err
	}

	now := s.clock.Now()
	// Comparación de INSTANTES. El borde (now == closesAt → no se vende)
	// se hereda de isPastClosing: dos capas que contesten distinto en el
	// borde producen el ticket más difícil de diagnosticar que existe.
	if !now.Before(raffle.ClosesAt) {
		return fmt.Errorf("cerró a las %s y ahora son las %s: %w",
			raffle.ClosesAt.Format(time.RFC3339), now.Format(time.RFC3339),
			ErrRaffleClosed)
	}
	// … el resto de be05
})
```

⚠️ **La posición no es estilo.** Comprobar antes de abrir la transacción reabre
el mismo *check-then-act* que `be05` acaba de cerrar: entre "vi que estaba
abierta" y "vendí" cabe el cierre. La ventana es pequeña y justo por eso el bug
sería intermitente.

Y el handler traduce a `409`, no a `400`: la petición está bien formada, el estado
del recurso no la permite. El frontend heredado ya sabe mostrar un `409` como
conflicto, así que **maneja este caso nuevo sin saber que existe**.

**La corrección correcta**

La de `be06` completa, que son tres piezas:

1. La comprobación dentro de la transacción (arriba).
2. Un **worker que cierra por reloj**, para que el estado refleje la realidad
   aunque nadie pida nada. Sin él, una rifa cerrada a las 22:00 sigue diciendo
   `open` hasta que alguien intente venderle algo — y el `pollingEpic` de la Fase
   7 no arrancaría a buscar el resultado.
3. La **política de zonas** explícita: proceso en UTC, sesión de base en
   `America/Bogota` solo para serializar.

> ⚠️ Y una advertencia sobre la pieza 2: el worker mantiene el estado al día,
> **no es la regla**. Usar `status = 'open'` como comprobación de la hora dura
> deja colarse las ventas de los segundos entre un tick y el siguiente. La que
> manda es el reloj.

**Prueba de regresión**

```go
func TestSellNumberRespetaLaHoraDura(t *testing.T) {
	closesAt := mustParse(t, "2026-08-30T22:00:00-05:00")

	casos := []struct {
		nombre string
		ahora  time.Time
		quiere error
	}{
		{"un segundo antes", closesAt.Add(-time.Second), nil},
		{"un milisegundo antes", closesAt.Add(-time.Millisecond), nil},
		{"el instante exacto", closesAt, ErrRaffleClosed},
		{"un milisegundo después", closesAt.Add(time.Millisecond), ErrRaffleClosed},
		// El que de verdad importa: el mismo instante escrito en otra zona.
		// Si este pasa, ninguna comparación mira componentes de fecha.
		{"el mismo instante en UTC",
			mustParse(t, "2026-08-31T03:00:00Z"), ErrRaffleClosed},
	}

	for _, c := range casos {
		t.Run(c.nombre, func(t *testing.T) {
			svc := newServiceWithClock(t, fixedClock{c.ahora})
			_, err := svc.SellNumber(ctxConUsuario(1), 1, "0347", nil)
			require.ErrorIs(t, err, c.quiere)
		})
	}
}
```

Motor: **PostgreSQL obligatorio**. Zonas horarias.

📖 Y fíjate en lo que hace posible esta prueba: el **reloj inyectado**. Con
`time.Now()` dentro del servicio, los casos del borde —un milisegundo antes, un
milisegundo después— no se pueden escribir. Que `be06` haya hecho el reloj una
dependencia no es purismo: es lo que convierte "difícil de probar" en cinco
líneas.

**Prevención**

La prueba de bordes, el worker, y una consulta de auditoría que debería correr
después de cada cierre:

```sql
-- Ventas posteriores al cierre. Tiene que devolver cero filas.
SELECT s.raffle_id, s.number, s.sold_at, r.closes_at
FROM sales s JOIN raffles r ON r.id = s.raffle_id
WHERE s.sold_at > r.closes_at;
```

Si esta consulta hubiera existido, el problema se habría detectado la primera
noche y no en la liquidación.

**Por qué llegó a producción**

Porque la guarda **existía y funcionaba** — en el lugar equivocado. Quien escribió
`isPastClosing` hizo un buen trabajo: función pura, comparación de instantes,
probada, con el borde decidido. Todo correcto. Y toda esa calidad estaba del lado
que el usuario controla.

El sistema pasó meses sin fallar porque el camino feliz —vendedor con reloj bien,
página recargada— respeta la guarda. El fallo necesita una condición que nadie
prueba: seguir usando una pestaña que se abrió antes del cierre.

Y el descubrimiento tardó porque **no hay síntoma en el momento**. La venta se
acepta, el vendedor cobra, el comprador se va contento. El descuadre aparece en la
liquidación, semanas después, cuando ya hay dinero repartido y un premio en
disputa.

**Si tu causa fue distinta a esta**

- *"Los relojes de los vendedores están mal"* — es una de las tres vías y es
  **insuficiente como causa**: aunque todos los relojes estuvieran perfectos,
  `curl` seguiría entrando. La causa es la ausencia de guarda en el servidor.
- *"El worker de cierre no corrió"* — no existía. Y aunque existiera, el estado no
  es la regla: el reloj lo es.
- *"La `closesAt` está mal guardada"* — se descarta comparando con lo que muestra
  la UI: es la misma.
- Si tu fix fue **comprobar la hora en el handler** en vez de en la transacción,
  cerraste el 99 % del agujero y dejaste una ventana intermitente. Es defendible
  como hotfix de un viernes; anótalo como tal.

</details>
FIN_DEL_ARCHIVO
wc -l $R/cuaderno-incidentes-be.md

# --- 2026-09-09T04:35:46 · Append incidents be-13 and be-14
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; cat >> $R/cuaderno-incidentes-be.md <<'FIN_DEL_ARCHIVO'

---

## Incidente be-13 — La liquidación dice 340.000 y las ventas suman 355.000

> **Fase:** be07 · **Categoría:** 🔥 dinero · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min
> · Hermano del incidente **18** del track base, con otra causa raíz

### 🎫 El ticket

> "La liquidación de la rifa de agosto quedó en 340.000 de recaudo. Cuando
> contamos los números vendidos y multiplicamos por el precio nos da 355.000.
> Son 15.000 de diferencia, o sea tres números. No es un centavo de redondeo,
> son tres números enteros que no aparecen en la cuenta."

**Reportado por:** tesorería
**Ambiente:** PROD

### 🎯 Qué se te pide

Encontrar los tres números y explicar por qué no entraron. Y una pregunta que
decide todo lo demás: **¿el número guardado está mal, o está bien y lo que está
mal es otra cosa?**

### 🔧 Preparación

```bash
git checkout incidente/be-13
cd server && go run ./cmd/api
npm start
# Abre la aplicación en DOS pestañas sobre la misma rifa.
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

"No es un centavo de redondeo, son tres números enteros" es un dato excelente:
descarta toda la familia de bugs de aritmética. `A10` y `be07` usan enteros de
centavos y las partes suman el todo.

Entonces la pregunta no es *cómo se calculó*, sino **con qué datos**. ¿Quién hizo
la cuenta?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Mira el **cuerpo** del `POST /settlements` en Network. ¿De dónde salieron
`totalCollected` y `soldCount`?

Y en el backend:

```sql
SELECT count(*) FROM sales WHERE raffle_id = 1;
SELECT sold_count, total_collected FROM settlements WHERE raffle_id = 1;
```

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el navegador calcula con los números que tiene cargados en el store, y otra
persona vendió tres números hace diez minutos sin que esa pestaña se enterara,
¿qué total manda?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**El cliente calculó el recaudo y el servidor lo guardó sin preguntar.**

El thunk `createSettlement` de la Fase 8 hace las cuentas con los números que
tiene en el store, y las manda en el cuerpo:

```javascript
const totalCollected = calculateTotalCollected({
  soldCount: soldNumbers.length,        // ← los que ESTA pestaña conoce
  numberPrice: raffle.numberPrice,
});
```

Si otra persona vendió tres números después de que esa pestaña cargara el
tablero, el store está desactualizado y el total sale corto. El backend recibe
`340000`, lo guarda tal cual, y devuelve `201`.

**No es mala fe ni un bug del frontend: el cliente no tiene los datos.** Puede
tener una foto de hace diez minutos; el servidor tiene la verdad.

Reprodúcelo en dos minutos: dos pestañas sobre la misma rifa, vende tres números
en la primera, liquida en la segunda **sin recargar**.

Es el hermano del **incidente 18 del track base** —*"la liquidación da un centavo
de diferencia"*—, donde la causa es el redondeo. Acá la aritmética es impecable y
lo que falla es la **fuente de los datos**. Mismo síntoma, distinta capa, y por
eso el detalle del ticket —"no es un centavo, son tres números"— es la pista que
separa los dos casos.

**Parche mínimo**

Recalcular en el servidor:

```go
sold, err := tx.ListSales(ctx, in.RaffleID)
if err != nil {
	return err
}
totalCollected := TotalCollected(int64(len(sold)), raffle.NumberPrice)
```

**La corrección correcta**

La de `be07`: recalcular **todo** —`totalCollected`, `prizeAmount`, `margin`— desde
`sales`, y **registrar la discrepancia** en vez de rechazar la petición:

```go
if in.TotalCollected != totalCollected || in.PrizeAmount != prizeAmount || in.Margin != margin {
	log.Printf("[req-id %s] discrepancia en la rifa %d — cliente: total=%d premio=%d margen=%d | servidor: total=%d premio=%d margen=%d",
		httpapi.RequestIDFrom(ctx), in.RaffleID,
		in.TotalCollected, in.PrizeAmount, in.Margin,
		totalCollected, prizeAmount, margin)
}
```

> 🧭 **Por qué se registra y no se rechaza.** Un `400` "sus números no cuadran"
> rompería el contrato y además culparía al cliente de algo que no puede hacer
> bien. Se recalcula, se guarda lo correcto, y queda el rastro — que es
> información de diagnóstico valiosísima el día que alguien pregunte por qué el
> total que vio no es el que quedó guardado.

📖 Y es la tercera vez que el track dice lo mismo, así que ya se puede nombrar:
**el cliente propone, el servidor dispone, y la diferencia se mide.** Identidad en
`be04`, reloj en `be06`, dinero en `be07`.

**Prueba de regresión**

```go
func TestLosMontosSeRecalculanYNoSeLeenDelCuerpo(t *testing.T) {
	seedRaffleConVentas(t, 1, 71, /* numberPrice */ 500000)   // 35.500.000

	// El cliente manda cifras inventadas.
	body := `{"raffleId":1,"winningNumber":"0347","isWinnerSold":true,
	          "soldCount":68,"totalCollected":34000000,"prizeAmount":0,
	          "margin":34000000,"settledAt":"2026-08-30T22:05:11Z"}`
	srv.POST(t, "/settlements", token, body).ExpectStatus(201)

	var s settlement.Settlement
	require.NoError(t, db.Get(&s, `SELECT * FROM settlements WHERE raffle_id = 1`))

	// Lo guardado sale de la base, no del cuerpo.
	require.Equal(t, 71, s.SoldCount)
	require.Equal(t, int64(35500000), s.TotalCollected)
}
```

Motor: PostgreSQL.

**Prevención**

La regla operativa, que vale más que la prueba: **ningún monto que se guarde puede
haber cruzado la red**. Si un campo de dinero se lee de un cuerpo de petición, es
un bug aunque todavía no haya fallado.

Y la consulta de auditoría del ejercicio 22 de `be07`, que debería devolver cero
filas siempre:

```sql
SELECT s.raffle_id, s.total_collected,
       (SELECT count(*) * r.number_price FROM sales v WHERE v.raffle_id = s.raffle_id) AS recalculado
FROM settlements s JOIN raffles r ON r.id = s.raffle_id
WHERE s.total_collected <> (SELECT count(*) * r.number_price FROM sales v WHERE v.raffle_id = s.raffle_id);
```

**Por qué llegó a producción**

Porque el frontend hace la cuenta **bien**. `A10` y la Fase 8 son ejemplares:
enteros de centavos, redondeo explícito, partes que suman el todo, con sus
pruebas. Toda esa disciplina es correcta y no sirve de nada si la entrada está
desactualizada.

Es un error de **arquitectura**, no de implementación, y por eso ninguna revisión
de código lo detecta: cada archivo, leído solo, está bien. Solo se ve preguntando
*"¿quién es el dueño de este dato?"*, y esa pregunta no se hace leyendo un diff.

**Si tu causa fue distinta a esta**

- *"Es el redondeo"* — la hipótesis del incidente 18 del track base, y el propio
  ticket la descarta: 15.000 pesos no son un redondeo. Que tesorería lo
  especificara es un reporte de calidad excepcional.
- *"Se borraron ventas"* — se descarta contando `sales`: están todas.
- *"Se vendieron después del cierre"* — ese es `be-12`, y el síntoma sería el
  contrario: la liquidación diría **más**, no menos.
- Si tu fix fue **recargar el tablero antes de liquidar**, reduces la ventana y no
  la cierras: entre la recarga y el `POST` cabe otra venta. Y además exige que el
  usuario se acuerde.

</details>

---

## Incidente be-14 — Repartimos el premio dos veces

> **Fase:** be07 · **Categoría:** 🔥 transacciones · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min

### 🎫 El ticket

> "En la rifa del 15 el premio salió dos veces en el reporte de pagos. La
> persona que liquidó dice que le dio error la primera vez y volvió a darle, que
> siempre hace eso. Y hay otra rifa donde pasó al revés: aparece el pago
> registrado pero la rifa sigue como pendiente de liquidar, y cuando intentamos
> liquidarla otra vez da un error raro que nadie entiende."

**Reportado por:** tesorería
**Ambiente:** PROD

### 🎯 Qué se te pide

Son **dos síntomas y hay que decidir si es un bug o dos**. Reproduce los dos,
explica el error "raro" del segundo caso, y arregla.

### 🔧 Preparación

```bash
git checkout incidente/be-14
cd server && CHAOS_LEVEL=high go run ./cmd/api    # el caos hace habitual el reintento
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

*"Le dio error y volvió a darle"* es el dato que abre el primer caso. Con el caos
encendido, un `timeout` significa que **la petición pudo haber llegado igual**.

El segundo caso es distinto: pago registrado, rifa sin liquidar. ¿Qué tienen que
ser esas dos operaciones para que ese estado sea imposible?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```sql
SELECT id, raffle_id FROM settlements WHERE raffle_id = 15;
SELECT count(*) FROM prize_payouts WHERE settlement_id IN (…);
SELECT status FROM raffles WHERE id = 15;
```

Y en el código, cuenta cuántas operaciones separadas hace `Create` y con cuántas
conexiones.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el proceso muere entre insertar los pagos y marcar la rifa como liquidada,
¿qué queda en la base? ¿Y qué pasa cuando alguien reintenta sobre esa rifa?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**Son dos bugs, y comparten origen: la liquidación no es una operación única.**

`Create` ejecuta seis pasos, cada uno con su propia conexión y sin transacción:
verificar, recalcular, insertar la liquidación, repartir el premio, comprobar el
cuadre, y marcar la rifa como `settled`.

**Caso 1 — el premio repartido dos veces.** Con el caos en `high`, la petición
llega, la liquidación se crea, y la respuesta se pierde. El usuario reintenta, y
como no hay comportamiento idempotente, se ejecuta otra vez. Sin el `UNIQUE
(raffle_id)` de `be02` habría dos liquidaciones; con él, salta el `23505` y el
usuario recibe un error incomprensible sobre una rifa que él ve sin liquidar. En
el caso reportado, los pagos ya se habían insertado en el primer intento.

**Caso 2 — pago sin liquidación.** El proceso murió entre el paso 4 y el paso 6.
Quedó la liquidación, quedaron los pagos, y la rifa siguió en `resolved`: **el
dinero repartido y la rifa sin liquidar.** El "error raro" del reintento es
exactamente el `23505` del `UNIQUE`, que hace bien su trabajo y comunica fatal.

📖 **Y ese es el valor entero de una transacción, visto desde el ticket.** No es
una abstracción académica: es la diferencia entre un martes normal y una tarde
reconstruyendo a mano quién cobró qué.

**Parche mínimo**

Una transacción alrededor de los seis pasos:

```go
err := s.store.WithTx(ctx, func(tx Tx) error {
	// … los seis pasos, todos con tx
})
```

Con eso, el caso 2 desaparece: el `recover` de `be01` atrapa el pánico, el
`defer tx.Rollback()` revierte, y la base queda **idéntica** a como estaba.
Compruébalo con las mismas consultas: cero filas en las dos.

**La corrección correcta**

La transacción **más la idempotencia**, que es lo que cierra el caso 1:

```go
// Ya bloqueada la rifa, si existe liquidación se devuelve ESA. No es un
// error: es un reintento, y con el caos de la Fase 3 encendido es el caso
// normal, no el excepcional.
existing, err := tx.FindSettlementByRaffle(ctx, in.RaffleID)
if err == nil {
	log.Printf("[req-id %s] liquidación %d ya existía para la rifa %d: se devuelve la misma",
		httpapi.RequestIDFrom(ctx), existing.ID, in.RaffleID)
	result = existing
	return nil
}
if !errors.Is(err, ErrNotFound) {
	return err
}
```

📖 **Una operación idempotente responde lo mismo la primera vez y la quinta.** El
cliente no puede distinguir su reintento de un primer intento, y esa
indistinguibilidad **es** la propiedad. El reintento deja de ser un problema y
pasa a ser rutina.

Y el paso que hace que esto no pueda romperse por otro lado, dentro de la misma
transacción:

```go
// La aserción que convierte esto en dinero y no en un CRUD. Comprobar el
// cuadre DENTRO de la transacción significa que un reparto que no cuadre no
// llega a existir: el Rollback lo borra.
if got := SumShares(shares); len(winners) > 0 && got != prizeAmount {
	return fmt.Errorf("el reparto no cuadra: las partes suman %d y el premio es %d", got, prizeAmount)
}
```

**Prueba de regresión**

```go
func TestLiquidacionEsIdempotente(t *testing.T) {
	primera := srv.POST(t, "/settlements", token, cuerpoValido).ExpectStatus(201)
	segunda := srv.POST(t, "/settlements", token, cuerpoValido).ExpectStatus(201)

	// Mismo id: es la misma liquidación, no una nueva.
	require.Equal(t, idOf(primera), idOf(segunda))

	var liquidaciones, pagos int
	require.NoError(t, db.Get(&liquidaciones, `SELECT count(*) FROM settlements WHERE raffle_id=1`))
	require.NoError(t, db.Get(&pagos, `SELECT count(*) FROM prize_payouts`))
	require.Equal(t, 1, liquidaciones)
	require.Equal(t, 1, pagos)
}

func TestLiquidacionInterrumpidaNoDejaRastro(t *testing.T) {
	// Falla en el paso 6, después de repartir.
	svc := newServiceConFalloEn(t, "UpdateRaffleStatus")

	_, err := svc.Create(ctxConUsuario(1), liquidacionValida)
	require.Error(t, err)

	// Todo o nada: ni liquidación, ni pagos, ni rifa a medio marcar.
	var liquidaciones, pagos int
	db.Get(&liquidaciones, `SELECT count(*) FROM settlements WHERE raffle_id=1`)
	db.Get(&pagos, `SELECT count(*) FROM prize_payouts`)
	require.Zero(t, liquidaciones)
	require.Zero(t, pagos)
	require.Equal(t, "resolved", statusOf(t, 1))
}
```

Motor: **PostgreSQL obligatorio**. Transacciones y bloqueos.

**Prevención**

Cuatro capas, cada una cubriendo lo que las otras no:

1. **La transacción** — que no exista el estado intermedio.
2. **El `UNIQUE (raffle_id)`** — que no exista la segunda liquidación, venga por
   donde venga.
3. **El comportamiento idempotente** — que el reintento sea aburrido.
4. **La consulta de auditoría**: liquidaciones cuyos pagos no sumen su
   `prizeAmount`, y rifas con liquidación pero sin estado `settled`. Las dos
   deberían devolver cero filas siempre.

**Por qué llegó a producción**

Por dos motivos que se refuerzan.

El primero: **el reintento del usuario es un comportamiento esperado y nadie lo
diseñó**. "Me dio error y volví a darle" es lo que hace todo el mundo, con
cualquier sistema. Con un mock que falla a propósito —el caos de la Fase 3— eso
pasó de ser excepcional a rutinario, y aun así la idempotencia no se consideró.

El segundo: **el caso 2 no se puede reproducir a propósito sin quererlo**. Nadie
mata el proceso a mitad de una liquidación en desarrollo. Es un fallo que solo
aparece cuando la infraestructura hace lo que la infraestructura hace: reiniciar,
desplegar, quedarse sin memoria.

Y el error que veía el operador —el `23505`— era técnicamente correcto y
completamente inútil: le hablaba de una restricción de unicidad sobre una rifa
que él veía sin liquidar.

**Si tu causa fue distinta a esta**

- *"El usuario liquidó dos veces por error"* — es la mitad del caso 1 y no es la
  causa: la causa es que el sistema no está preparado para que eso pase, cuando es
  exactamente lo que va a pasar.
- *"Falta el `UNIQUE`"* — está desde `be02`. Y protege contra la segunda
  liquidación, no contra el estado intermedio del caso 2.
- *"Es un problema de concurrencia"* — plausible y distinto: dos liquidaciones
  simultáneas de la misma rifa. Se cubre con el `FOR UPDATE` sobre la rifa, que va
  en el mismo fix. Buena hipótesis.
- Si tu fix fue **devolver un mensaje más claro ante el `23505`**, mejoraste la
  comunicación y no arreglaste nada: la rifa sigue con dinero repartido y sin
  liquidar.

</details>
FIN_DEL_ARCHIVO
wc -l $R/cuaderno-incidentes-be.md

# --- 2026-09-09T04:37:45 · Append be-15, be-16 and closing sections
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; cat >> $R/cuaderno-incidentes-be.md <<'FIN_DEL_ARCHIVO'

---

## Incidente be-15 ⭐ — La suite lleva tres semanas en verde y ayer se rompió producción

> **Fase:** be08 · **Categoría:** 🔥 contrato · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min
> ⭐ **Uno de los dos más formativos del track** · Hermano del incidente **20** del track base, con otra causa raíz

### 🎫 El ticket

> "Ayer desplegamos y dejó de funcionar crear rifas: cualquier intento da error
> del servidor. Lo raro es que la suite estaba verde, el pipeline pasó, y en las
> máquinas de los tres que trabajamos en eso funciona perfecto. Volvimos a la
> versión anterior y ya está bien, pero no sabemos qué pasó y no nos atrevemos a
> volver a desplegar."

**Reportado por:** el propio equipo
**Ambiente:** PROD (y no se reproduce en desarrollo)

### 🎯 Qué se te pide

Explicar cómo una suite verde puede autorizar un despliegue roto. El fix es
menor; **lo que importa es el diagnóstico y lo que se cambia después para que no
vuelva a pasar**.

### 🔧 Preparación

```bash
git checkout incidente/be-15
cd server
make test-unit          # verde
go test ./...           # verde, contra SQLite
```

Ahora corre lo mismo contra Postgres. Ahí empieza el incidente.

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

*"En nuestras máquinas funciona"* + *"la suite está verde"* + *"en producción no"*
tienen un factor común que no es el código, porque el código es el mismo en los
tres sitios.

¿Qué es distinto entre tu máquina y producción? Haz la lista completa antes de
seguir.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
go test ./... -count=1                                   # ¿contra qué motor?
TEST_DATABASE_URL="postgres://…/rifas_test" go test ./... -count=1
```

Y mira el error de producción entero, sin recortar. La primera línea nombra al
culpable.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`res.LastInsertId()` funciona en un motor y no en el otro. ¿En cuál corren tus
pruebas y en cuál corre producción?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**Las pruebas corren contra SQLite y producción contra PostgreSQL.**

Alguien reemplazó `RETURNING` por `LastInsertId` — que es la forma "obvia" de
recuperar el id recién insertado y la que sale en la mitad de los tutoriales:

```go
// ❌ Compila, y funciona en SQLite.
res, err := s.db.ExecContext(ctx, query, …)
id, err := res.LastInsertId()
```

`mattn/go-sqlite3` lo implementa. **`lib/pq` no**, y no es un bug del driver: el
protocolo de Postgres sencillamente no ofrece ese dato. Devuelve:

```
LastInsertId is not supported by this driver
```

Así que **todo** `POST /raffles` responde `500` en cualquier ambiente con
Postgres. Y la suite —que corría contra SQLite en memoria, porque es rápido y no
necesita contenedor— pasó en verde.

> 🧠 **Y acá está lo que hay que entender, que es más incómodo que el bug: la
> suite no falló en detectar el problema. La suite lo autorizó.** No tener suite
> te deja desconfiado y prudente; una suite verde te da **permiso para
> desplegar**, y ese permiso es exactamente lo que el equipo no tenía derecho a
> recibir.

Es el hermano del **incidente 20 del track base** —*"el test pasa en mi máquina y
falla en la de al lado"*—, con la causa raíz desplazada del **entorno** al
**motor**.

**Parche mínimo**

```go
// RETURNING funciona en los dos motores, y por eso D18 fija SQLite >= 3.35:
// es marzo de 2021, cuando llegó la sentencia. La cota no es un número
// redondo elegido al azar.
query := s.db.Rebind(`
	INSERT INTO raffles (name, lottery_id, closes_at, number_price, base_prize, status)
	VALUES (?, ?, ?, ?, ?, ?)
	RETURNING id, name, lottery_id, closes_at, number_price, base_prize, status`)

var created Raffle
err := s.db.GetContext(ctx, &created, query, …)
```

**La corrección correcta**

Arreglar el `LastInsertId` es media hora. Lo que hay que cambiar es **cómo se
prueba**, y eso es el contenido de `be08`:

> 🧭 **La regla del motor (`D18`).** SQLite vale para pruebas que no tocan
> concurrencia, bloqueos, zonas horarias ni SQL específico del motor. En cuanto
> una prueba toca cualquiera de las cuatro, **corre contra PostgreSQL o no vale**.

Y el mecanismo que la hace cumplir, que es la parte que de verdad importa:

```go
// FALLA, no salta. Un t.Skip produce una suite verde que no probó lo que
// dice probar, y nadie lee los SKIP de una salida que termina en "ok".
func mustPostgres(t *testing.T, db *storage.DB, motivo string) {
	t.Helper()
	if db.Dialect != storage.Postgres {
		t.Fatalf("esta prueba requiere PostgreSQL porque %s.\n"+
			"Levanta el contenedor y exporta TEST_DATABASE_URL.\n"+
			"Ver D18 y server/evidence/regla-del-motor.md", motivo)
	}
}
```

📖 **`t.Skip` es la forma en que una suite miente.** Y `(cached)` es la segunda:
`go test` sin `-count=1` puede decir `ok` sin haber ejecutado nada.

**Prueba de regresión**

No es una prueba: es **el par contradictorio** de `be08`, que va al repositorio
con su explicación.

```go
// PRUEBA A — pasa en SQLite, FALLA en Postgres.
// Documenta la trampa. NO debe correr en CI: el código correcto usa RETURNING.
func TestA_LastInsertId(t *testing.T) {
	db := testsupport.OpenAny(t)
	res, err := db.Exec(db.Rebind(`INSERT INTO participants (name) VALUES (?)`), "Ana")
	require.NoError(t, err)
	id, err := res.LastInsertId()
	require.NoError(t, err, "lib/pq no implementa LastInsertId: usa RETURNING")
	require.Greater(t, id, int64(0))
}

// PRUEBA B — FALLA en SQLite, pasa en Postgres.
// Prueba legítima del sistema. Corre SOLO contra Postgres.
func TestB_ComparacionDeInstantes(t *testing.T) {
	db := testsupport.OpenAny(t)
	insertRaffle(t, db, "Rifa fin de mes", "2026-08-30T22:00:00-05:00")

	var nombres []string
	require.NoError(t, db.Select(&nombres, db.Rebind(
		`SELECT name FROM raffles WHERE closes_at > ?`), "2026-08-31T01:00:00Z"))
	require.Len(t, nombres, 1,
		"si esto falla, el motor está comparando cadenas y no instantes")
}
```

Las dos son correctas y se contradicen. **No se arreglan: se clasifican**, y esa
clasificación vive en `server/evidence/regla-del-motor.md`.

**Prevención**

1. **`mustPostgres` en toda prueba que toque las cuatro áreas.**
2. **El pipeline corre contra Postgres**, con `services: postgres:13`. Que la
   suite pudiera pasar sin un Postgres levantado era el agujero real.
3. **Un paso de CI que verifique la regla** (`make test-engine-rule`).
4. Y el mecanismo del ejercicio 29 de `be08`: algo que **impida** agregar una
   prueba de concurrencia sin `mustPostgres` — una etiqueta de compilación, una
   convención verificada por un script, lo que sea, pero verificable.

**Por qué llegó a producción**

Porque usar SQLite en memoria para las pruebas es una práctica **extendida y
razonable**: arranca en milisegundos, no necesita contenedor, cada caso tiene su
base limpia. Quien la eligió tenía buenos motivos y para la mitad de la suite
seguía siendo la decisión correcta.

Lo que faltaba era el **límite escrito**: hasta dónde vale ese motor y qué pasa
cuando una prueba lo cruza. Sin ese límite, la frontera se cruza sola, poco a
poco, sin que nadie tome una decisión — y el día que se cruza en algo importante,
no hay ninguna señal.

Y la asimetría que lo hace grave: un falso **negativo** —una prueba que falla y
pasaría en producción— es molesto pero se investiga. Un falso **positivo** —verde
en SQLite, roto en Postgres— **no produce ninguna señal**. Nadie investiga una
prueba que pasa.

**Si tu causa fue distinta a esta**

- *"Es un problema de configuración de producción"* — la hipótesis natural con
  *"en mi máquina funciona"*, y la del incidente 20 del track base. Se descarta
  levantando Postgres en local: se reproduce al instante.
- *"Falló la migración"* — se descarta comprobando la versión del esquema, que
  `be09` además verifica al arrancar.
- *"Es la versión de Go del runner"* — se descarta: el pipeline corre
  `container: golang:1.19`, el mismo de siempre.
- Si tu fix fue **solo** cambiar `LastInsertId` por `RETURNING`, arreglaste este
  caso y dejaste intacta la condición que lo produjo. La próxima diferencia entre
  motores va a pasar por el mismo agujero, y hay siete documentadas en `be-a-03`.

</details>

---

## Incidente be-16 — La imagen de ayer no arranca y el código no cambió

> **Fase:** be09 · **Categoría:** 🔥 despliegue · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "La imagen que construimos ayer no arranca en el servidor: se levanta el
> contenedor y se muere solo. La de anteayer funciona bien. Comparamos el código
> y no hay ni un commit de diferencia en la aplicación. En la máquina de quien
> la construyó arranca perfecto."

**Reportado por:** el propio equipo
**Ambiente:** UAT

### 🎯 Qué se te pide

Encontrar qué cambió si el código no cambió, y arreglar la construcción para que
sea **reproducible**. Hay más de una causa posible: identifica la tuya con
evidencia, no por descarte.

### 🔧 Preparación

```bash
git checkout incidente/be-16
cd server
docker build -t rifas:sospechosa .
docker run --rm rifas:sospechosa
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Ni siquiera es el cable: es la **imagen**. Y el dato clave es *"el código no
cambió"*, que descarta la aplicación y deja tres sospechosos: la receta de
construcción, la máquina que construye, y las **imágenes base**.

¿Qué versión exacta de la imagen base usa tu Dockerfile? ¿Y qué versión usaba
anteayer?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Lee el error del contenedor **entero**, sin recortar. Después:

```bash
docker run --rm --entrypoint file rifas:sospechosa /usr/local/bin/api
docker image inspect rifas:sospechosa --format '{{.Architecture}} {{.Os}}'
docker history rifas:sospechosa
```

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el binario está enlazado dinámicamente contra `glibc` y el runtime usa `musl`,
¿qué archivo es el que "no existe"? Pista: no es el binario.

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**El binario tiene cgo y el runtime cambió de `libc`.**

Alguien tocó el Dockerfile para "aligerar la imagen" y cambió el runtime de
`debian:bullseye-slim` a `alpine`. El código de la aplicación no cambió — el
ticket dice la verdad. Lo que cambió fue la receta.

Y el error es el más desconcertante que existe:

```
exec /usr/local/bin/api: no such file or directory
```

sobre un binario que puedes listar, ver y que tiene permisos de ejecución. **El
archivo que no existe es la `libc` que el binario espera**, no el binario:

```bash
docker run --rm --entrypoint file rifas:sospechosa /usr/local/bin/api
# ELF 64-bit LSB executable, dynamically linked,
# interpreter /lib64/ld-linux-x86-64.so.2
```

El builder es Debian (`glibc`); Alpine usa `musl`. El binario arrastra cgo porque
`mattn/go-sqlite3` lo exige y su `import` está en un archivo sin etiqueta de
compilación — o sea, **el binario de producción lleva un driver de SQLite que no
usa jamás**.

**Por qué funcionaba en la máquina de quien construyó:** no ejecutó la imagen; o
la ejecutó con una caché de capas anterior al cambio. `docker build` sin
`--no-cache` puede reutilizar capas viejas y esconder exactamente esta clase de
problema.

📝 **Y hay dos hermanas de esta causa** que producen síntomas parecidos y conviene
reconocer:
- **Arquitectura:** imagen construida en un Mac con Apple Silicon (`arm64`)
  ejecutándose en un runner `amd64` → `exec format error`.
- **Zonas horarias:** con una imagen mínima sin `/usr/share/zoneinfo`,
  `time.LoadLocation("America/Bogota")` devuelve `unknown time zone` **solo dentro
  del contenedor**.

**Parche mínimo**

Volver al runtime compatible:

```dockerfile
# Mientras haya cgo, builder y runtime tienen que compartir libc. Punto.
FROM debian:bullseye-slim
```

**La corrección correcta**

La de `be09`, y tiene un giro que vale la pena entender: **la pregunta estaba mal
planteada**. No era *qué imagen base aguanta cgo*, sino **por qué el binario de
producción tiene un driver de SQLite**.

SQLite solo se usa en pruebas. Se saca de la compilación con una etiqueta:

```go
// server/internal/storage/driver_sqlite.go
//go:build sqlite

package storage

import _ "github.com/mattn/go-sqlite3"
```

⚠️ La línea `//go:build` va **antes del `package` y separada por una línea en
blanco**, o el compilador la trata como un comentario cualquiera. Es un error
silencioso: compila igual, con cgo, y solo lo notas midiendo.

Y entonces:

```dockerfile
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags "-s -w" -o /out/api ./cmd/api

FROM gcr.io/distroless/static-debian11:nonroot
```

Binario estático, imagen de ~2 MB, sin `libc` que emparejar. Y `D19` —abierta
desde `be02`— cerrada con una medición en vez de con una opinión.

**Prueba de regresión**

En el pipeline, no en `go test`:

```yaml
- name: El binario de producción tiene que ser estático
  run: |
    CGO_ENABLED=0 go build -o /tmp/api ./cmd/api
    # Si aparece "dynamically linked", alguien volvió a meter cgo.
    file /tmp/api | grep -q "statically linked" || {
      echo "El binario quedó enlazado dinámicamente: revisa las etiquetas de compilación"
      exit 1
    }

- name: La imagen tiene que arrancar
  run: |
    docker build --no-cache -t rifas:ci ./server
    docker run -d --name smoke -p 3001:3001 -e DATABASE_URL="$DB" rifas:ci
    sleep 3 && curl -fsS localhost:3001/health
```

**Prevención**

1. **El paso de CI de arriba.** Es lo que impide que la decisión de `D19` se
   deshaga sola dentro de seis meses.
2. **`docker build --no-cache` en el pipeline.** La caché es una optimización de
   desarrollo y una fuente de falsos positivos en CI.
3. **Fijar la plataforma** (`--platform linux/amd64`) para que construir en un
   Mac y desplegar en un servidor den lo mismo.
4. **Etiquetar por `sha`** y no por `latest`: sin eso, "la imagen de ayer" y "la
   de anteayer" no son identificables, y media hora del diagnóstico se va en
   averiguar qué se desplegó.
5. **Correr `smoke.sh` contra el contenedor**, no solo contra `go run`. Es la
   diferencia entre "el código funciona" y "lo que vamos a desplegar funciona".

**Por qué llegó a producción**

Porque el cambio era **una mejora**. Alguien vio una imagen de 80 MB, la cambió
por una de 15, comprobó que el `docker build` terminaba sin errores, y lo subió.
Todo razonable.

El pipeline **construía** la imagen y no la **ejecutaba**: verificaba que el
Dockerfile fuera válido, no que el resultado arrancara. Es una distinción que
parece obvia dicha así y que falta en la mayoría de los pipelines.

Y el error final era ilegible. *"No such file or directory"* sobre un archivo que
existe manda a cualquiera a revisar rutas y permisos durante un buen rato — que
es justo donde no está el problema.

**Si tu causa fue distinta a esta**

- *"Es la arquitectura"* — es la hermana, y produce `exec format error`, no
  `no such file or directory`. El mensaje exacto los distingue.
- *"Falta `tzdata`"* — la otra hermana. Daría un error de zona horaria en tiempo
  de ejecución, con el proceso ya arrancado.
- *"Cambió la imagen base sin que nadie lo tocara"* — plausible y muy real si el
  Dockerfile usa una etiqueta móvil (`golang:1.19` puede apuntar a una imagen
  distinta que hace un mes). Se comprueba con `docker image inspect` y sus
  digests, y refuerza la conclusión: **fija versiones y no confíes en etiquetas
  móviles**.
- Si tu fix fue **instalar `gcc` y `musl-dev` en el builder de Alpine**, funciona…
  y ahora el binario no corre en Debian. Cambiaste de sitio el problema.

</details>

---

# 🪞 Retrospectiva del track BE

Se llena al terminar los dieciséis, de una sola vez, releyendo tu propio
`git log`.

- **Cuántos abriste, cuántos cerraste, cuántos quedaron ⚪.**
- **Cuántas veces tu causa raíz coincidió con la de referencia**, y en cuáles no.
  El patrón importa más que el número.
- **En qué capa te costó más**: handler, service, store, esquema, transacción,
  infraestructura. Si la respuesta es "transacciones", estás en buena compañía.
- **Cuántas veces empezaste buscando del lado equivocado del cable**, y qué dato
  del ticket te habría ahorrado ese desvío.
- **Los seis hermanos.** Compara tu diagnóstico del incidente BE con el del track
  base. ¿Habrías llegado a la causa de acá teniendo solo las herramientas de allá?
  Esa respuesta es la tesis del track, medida contigo mismo.
- **Qué pista abriste antes de tiempo y por qué.** Sin culpa: es un dato sobre
  dónde te falta confianza.
- **Tu checklist de diagnóstico de backend**, la de una página, escrita con lo que
  aprendiste acá. Es lo único de este archivo que te llevas al trabajo real.

> **La señal de que quedó bien:** cuando te llegue un ticket que dice "a veces no
> anda", tu primera reacción no sea abrir el código, sino preguntar *"¿la petición
> salió, qué volvió, y qué dice el log para ese `X-Request-Id`?"*.

---

# 📌 Pendientes que salieron de los incidentes

*(Fuera de lo que lee el estudiante.)*

- **Las ramas `incidente/be-NN` no existen todavía.** Cada incidente declara su
  preparación con una rama que hay que crear en el repositorio del alumno —o
  reescribir la sección `🔧 Preparación` para que el estado roto se produzca con
  un `git revert` o con una edición guiada. Es el trabajo pendiente más concreto
  de este archivo.
- **Cobertura por categoría**, revisada al cerrar: contrato 5, transacciones 3,
  tiempo 2, base de datos 2, despliegue 2, autenticación 1, dinero 1. **Despliegue
  quedó algo servido y dinero apenas con uno**; si se amplía el rango en el
  futuro, por ahí conviene crecer.
- **Reparto por dificultad:** 🟡 4 · 🟠 6 · 🔴 6. Sin ninguno 🟢, y es
  deliberado: no hay incidentes de backend fáciles en este dominio, y fabricar uno
  artificialmente sería peor que no tenerlo.
- **Seis terminan sin fix en el código**, que era el objetivo: `be-01` y `be-02`
  registran hallazgos, `be-08` y `be-11` concluyen que el sistema hizo lo
  correcto, `be-07` termina en una conversación con tesorería y `be-12` en una
  decisión de negocio. Ese desenlace es real y casi nunca se practica.
- **`be-08` y `be-11` son los dos que más se van a discutir**, porque su respuesta
  es *"no se arregla, y aquí está por qué"*. Si la revisión editorial los suaviza,
  se pierde lo mejor que tienen.
- **Los seis hermanos del track base están cruzados en el índice**, pero el
  cuaderno base **no los referencia de vuelta** porque sus veinte enunciados
  siguen sin redactar. Cuando se escriban, conviene añadir la referencia cruzada
  en los incidentes 08, 11, 16, 18, 19 y 20.
- **Ningún incidente depende de datos generados con faker.** Es deliberado: un
  conjunto aleatorio arruinaría la reproducibilidad (`be-a-10` §7). `be-09` y
  `be-05` se benefician del volumen para reproducirse más rápido, pero no lo
  exigen.
- **Nada de esto reemplaza a `cuaderno-incidentes.md`**, cuyos veinte incidentes
  del track base siguen siendo el hueco declarado más grande del curso.
FIN_DEL_ARCHIVO
wc -l $R/cuaderno-incidentes-be.md

# --- 2026-09-09T04:38:15 · Update base notebook and style guide
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; python3 - "$R" <<'PY'
import io,sys
R=sys.argv[1]

# 1) cuaderno base: la reserva apunta al archivo nuevo
p=R+'/cuaderno-incidentes.md'
s=io.open(p,encoding='utf-8').read()
old="""choquen con los veinte de arriba tienen **rango propio: `be-01` a `be-16`**. No
están redactados todavía —se reservan cuando se escriba cada fase, en su sección
de 📌 Pendientes— pero el rango queda tomado desde ya, igual que los veinte del
track base. Los ocho primeros ya están asignados: `be-01` y `be-02` en `be00`,
`be-03` en `be01`, `be-04` y `be-05` en `be02`, `be-06` y `be-07` en `be03`, y
`be-08` en `be04`. El rango se amplió de ocho a dieciséis al escribir `be04`,
porque las cinco fases restantes producen incidentes propios y el rango original
se había agotado a mitad del track."""
new="""choquen con los veinte de arriba tienen **rango propio: `be-01` a `be-16`**, y
viven en su propio archivo:

> 📓🔥 **[`cuaderno-incidentes-be.md`](cuaderno-incidentes-be.md)** — los dieciséis
> incidentes del track BE, **redactados**, con la misma estructura, las mismas
> reglas y el mismo tono que este cuaderno.

**Por qué en un archivo aparte**, si arriba dice que este es el único archivo de
incidentes del curso: porque el track BE es opcional, y quien haga solo las 96
horas del track base no debería encontrarse dieciséis incidentes de Go y Postgres
intercalados entre los suyos. La divergencia está declarada allá y los rangos de
IDs no colisionan. Su plantilla —igual a esta, con las herramientas del backend en
vez de las del navegador— está en `prompts/plantilla-de-incidente-be.md`.

**Seis de los dieciséis son hermanos de incidentes de este cuaderno**: mismo
síntoma, otra capa, otra causa raíz. Resolverlos en pareja enseña más que
resolverlos sueltos, y el cruce está en el índice de aquel archivo.

| Este cuaderno | Track BE | Qué cambia |
|---|---|---|
| 11 — el `0347` vendido dos veces ⭐ | `be-09` ⭐ | Allá el store; acá el índice único y la transacción |
| 16 — la rifa siguió vendiendo tras el cierre | `be-12` | Allá el reloj del navegador; acá la autoridad del servidor |
| 18 — la liquidación da un centavo de diferencia | `be-13` | Allá el redondeo; acá el cliente calculando con datos viejos |
| 19 — el dashboard se arrastra al final del día | `be-05` | Allá memoización; acá el pool de conexiones agotado |
| 20 — el test pasa en mi máquina y falla en la de al lado | `be-15` ⭐ | Allá el entorno; acá el **motor** de la base |
| 08 — la sesión se cae sola | `be-08` | Allá el `401` del caos; acá un `exp` real sin renovación |"""
assert s.count(old)==1, "cuaderno"
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))

# 2) guía de estilo §16: registrar la convención
p=R+'/prompts/guia-de-estilo-y-convenciones.md'
s=io.open(p,encoding='utf-8').read()
old="""### 16.2 La regla que ordena el track entero"""
new="""### 16.1bis Los incidentes del track viven aparte

Los dieciséis incidentes del track BE (`be-01`–`be-16`) están en
**`cuaderno-incidentes-be.md`**, no en `cuaderno-incidentes.md`. Es una
divergencia deliberada de la frase *"este es el único archivo de incidentes del
curso"*, escrita antes de que el track existiera, y su motivo está declarado en
los dos archivos: el track BE es opcional y no debe filtrarse al cuaderno de
quien solo hace las 96 horas base.

La estructura, las reglas y el tono son **idénticos**; lo único que cambia son las
herramientas —logs, `psql`, `pg_stat_activity`, `EXPLAIN`, `go test -race`,
`docker`— y una pregunta propia que encabeza cada enunciado: **de qué lado del
cable está la causa**. La plantilla está en
`prompts/plantilla-de-incidente-be.md`, y es a `cuaderno-incidentes-be.md` lo que
`prompts/plantilla-de-fase.md` es a una fase.

Cuando un incidente BE comparta síntoma con uno del track base, **se marca en los
dos sentidos**: el paralelo —mismo síntoma, otra capa, otra causa raíz— es de lo
más formativo que ofrece el track.

### 16.2 La regla que ordena el track entero"""
assert s.count(old)==1, "guia"
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))
print('ok')
PY

# --- 2026-09-09T04:38:21 · Find README notebook mentions
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; grep -n "cuaderno-incidentes\|Estado del cuaderno" $R/README.md | head

# --- 2026-09-09T04:38:25 · Read README sections to update
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; sed -n '96,110p' $R/README.md; echo "=== BE track table end ==="; sed -n '135,150p' $R/README.md

# --- 2026-09-09T04:38:40 · Update README with BE notebook
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; python3 - "$R" <<'PY'
import io,sys
R=sys.argv[1]
p=R+'/README.md'
s=io.open(p,encoding='utf-8').read()

old="""> ⚠️ **Estado del cuaderno.** Los veinte IDs están reservados y trazados desde
> las fases que los producen, pero **los enunciados todavía no están
> redactados**: el archivo tiene la plantilla y el índice, no los incidentes. Es
> el hueco conocido más grande del curso. Mientras tanto, cada fase trae sus
> propios ejercicios de diagnóstico y su
> pieza forense, que cubren el mismo músculo con menos ceremonia."""
new="""> ⚠️ **Estado del cuaderno.** Los veinte IDs están reservados y trazados desde
> las fases que los producen, pero **los enunciados todavía no están
> redactados**: el archivo tiene la plantilla y el índice, no los incidentes. Es
> el hueco conocido más grande del curso. Mientras tanto, cada fase trae sus
> propios ejercicios de diagnóstico y su
> pieza forense, que cubren el mismo músculo con menos ceremonia.
>
> El cuaderno del **track BE opcional** (`cuaderno-incidentes-be.md`) sí está
> completo: sus dieciséis incidentes están redactados, y seis de ellos son
> hermanos de los de arriba — mismo síntoma, otra capa, otra causa raíz."""
assert s.count(old)==1, "estado"
s=s.replace(old,new)

old2="""Y **diez apéndices propios** (`be-a-01` a `be-a-10`): Go para quien no escribe
Go, la receta de imagen y compose, dialectos SQL, JWT por dentro, concurrencia
en Postgres, tiempo y relojes, correlación por `request-id`, seguridad de API,
el mapa de deuda del backend y —opcional— datos de prueba con faker."""
new2=old2+"""

Y **su propio cuaderno de incidentes** (`cuaderno-incidentes-be.md`): dieciséis
tickets vagos que ocurren del otro lado del cable —en el binario, en Postgres, en
el contenedor o en el pipeline—, **redactados de punta a punta**, con pistas
escalonadas y solución de referencia colapsada. Seis son hermanos de incidentes
del track base: el mismo síntoma resuelto en la capa donde de verdad vivía.

> 🧭 Y seis de los dieciséis **no terminan en un commit**. Dos registran hallazgos
> de contrato, dos concluyen que el sistema hizo lo correcto y hay que
> explicárselo a alguien, y dos terminan en una decisión de negocio. Ese desenlace
> es tan real como un fix, y casi nunca se practica."""
assert s.count(old2)==1, "apendices"
io.open(p,'w',encoding='utf-8').write(s.replace(old2,new2))
print('ok')
PY
grep -c "cuaderno-incidentes-be" $R/README.md

# --- 2026-09-09T04:38:51 · Update CLAUDE.md and verify references
C=/Users/oskar/Developer/Learning/courses-ia-generated/CLAUDE.md; python3 - "$C" <<'PY'
import io,sys
p=sys.argv[1]
s=io.open(p,encoding='utf-8').read()
old="""  and separated without subdirectories. See the React 16 course's optional
  backend track."""
new="""  and separated without subdirectories. See the React 16 course's optional
  backend track. When such a track needs its own incident notebook or template,
  the same suffix applies to the shared documents: `cuaderno-incidentes-be.md`,
  `prompts/plantilla-de-incidente-be.md`. Keeping the optional track's incidents
  out of the base notebook is deliberate — a student who only does the base track
  shouldn't get the optional one's material mixed into theirs."""
assert s.count(old)==1
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))
print('ok')
PY
R=/Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs; cd $R && grep -oh "be-a-[0-9][0-9]\|be0[0-9]" cuaderno-incidentes-be.md prompts/plantilla-de-incidente-be.md | sort -u | while read s; do ls ${s}*.md >/dev/null 2>&1 || echo "FALTA: $s"; done; echo "refs ok"; grep -c "^## Incidente" cuaderno-incidentes-be.md

