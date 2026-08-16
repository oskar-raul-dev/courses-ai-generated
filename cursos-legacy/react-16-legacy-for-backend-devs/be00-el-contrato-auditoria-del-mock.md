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

> 📓🔥 De esta fase salen los incidentes **be-01** y **be-02** de `cuaderno-incidentes-be.md`, los dos de contrato: uno donde el backend hace todo bien y el síntoma es invisible desde el lado que lo produce, y otro donde el dato que falta no lo perdió nadie — nunca se pidió.

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
- **Para `bea-07`:** el recorrido del `X-Request-Id` que acá queda a medias es
  su columna vertebral. El apéndice debería abrir con las dos capturas de la
  pieza forense de esta fase.
