# 🐹 Fase be01 — Go 1.19 y la forma del monolito

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Fase be01 de be09 · **8 horas**
> Depende de: be00 — el contrato ya está auditado y escrito · Habilita: be02 — La costura de datos

---

## 🎯 1. Propósito

Cuando Juliana le contó a Carlos que el API nuevo iba a ser en Go, él contestó con su frase de siempre: *"eso es vaina de web"*. Y tiene razón en lo que le importa: nadie del estudio va a mantener este backend (`00-historia-del-sistema.md` §4). Tiene que ser un binario que arranca, atiende, deja rastro de lo que hace, sobrevive a sus propios errores y se apaga sin cortarle la petición a nadie, sin que nadie de Unity tenga que entender cómo. Esta fase levanta ese esqueleto: un servidor HTTP en Go, sin base de datos y sin tocar todavía el contrato de negocio, que además sabe romperse a propósito cuando se lo piden.

La fase tiene un objetivo secundario que en realidad es el principal para el track: **pagar la deuda 💸 de la trazabilidad**. En el mock, el `X-Request-Id` nace y muere en un middleware de tres líneas: el navegador lo puede leer (`C-05`), pero el log del servidor no lo menciona nunca, así que el id no sirve para encontrar nada del otro lado. Acá nace en el borde del servidor, viaja por `context.Context` hasta el fondo de la aplicación y aparece en cada línea de log con el tiempo que tardó la petición. Al terminar esta fase puedes copiar un id de la consola de Chrome y encontrarlo en la terminal del servidor.

> 🧭 Sigue mandando la regla del track: el frontend no se toca. En esta fase ni siquiera lo miramos, salvo para comprobar desde su consola que puede leer un header.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `server/go.mod` con `go 1.19` y `gorilla/mux` v1.8.0 como única dependencia; el layout de `server/` creado según el árbol de §5.1.
- [ ] El binario compila con `go build ./...` y arranca con `go run ./cmd/api`, escuchando en el puerto que indique `PORT`.
- [ ] `GET /health` responde `200` con `{"status":"ok"}` y su `X-Request-Id`.
- [ ] La cadena de middlewares está montada y **en el orden correcto**: `requestID` → `logging` → `cors` → `recover` → `chaos` → rutas.
- [ ] El `X-Request-Id` viaja por `context.Context`, cualquier función del backend puede recuperarlo sin recibirlo como parámetro suelto, y aparece en cada línea de log.
- [ ] La verificación 11 de `server/smoke.sh` (`C-05`) pasa contra el binario en el `3011`, y un `fetch` desde la consola del navegador **lee** el id.
- [ ] Un pánico dentro de un handler devuelve `500` con su `X-Request-Id` y su línea de log, y el proceso sigue atendiendo.
- [ ] `Ctrl+C` cierra el servidor sin cortar una petición en vuelo.
- [ ] El caos existe con doble control (`POST /_chaos` y `CHAOS_LEVEL`), apagado por defecto, con los mismos números que el mock, y su regla de precedencia está escrita y probada.
- [ ] `git diff pre-backend-go..HEAD -- . ':!server'` no devuelve nada.

---

## 🚫 3. Qué queda fuera por ahora

- **Cualquier acceso a base de datos** → `be02`. Esta fase no sirve ni un dato del dominio, y no se disculpa por ello.
- **Los recursos del contrato** (`/users`, `/wheels`, `/players`, `/spinLog`…) → `be03`. Hoy los únicos endpoints vivos son `/health` y `/_chaos`.
- **La configuración con `envconfig`** → `be03`. Acá se lee con `os.Getenv` y una función de ayuda. 💸 Deuda declarada: la configuración queda dispersa y sin validar; lo correcto es un struct único que falle al arrancar si algo falta.
- **La sintaxis de Go** → `bea-01`. Esta fase asume que sabes leer una función y un `struct`; el apéndice cubre punteros, interfaces, `defer`, goroutines y el resto. Ábrelo en cuanto una línea te frene.

---

## 🧠 4. Conceptos mínimos

Sabes qué es HTTP, qué es un middleware y qué es inyección de dependencias. No vamos a gastar una línea en eso. Lo que sigue es lo que Go hace **distinto**, que es donde tropieza todo el mundo que llega de otro lenguaje.

### Los errores son valores, y no hay excepciones

En Go no hay `try/catch`. Una función que puede fallar devuelve dos cosas: el resultado y un `error`. Quien la llama decide qué hacer, ahí mismo, en la línea siguiente:

```go
wheel, err := store.FindWheel(ctx, id)
if err != nil {
    return fmt.Errorf("buscando la rueda %d: %w", id, err)
}
```

El `%w` de `fmt.Errorf` **envuelve** el error original en vez de aplastarlo a texto: quien reciba el error de arriba puede seguir preguntando con `errors.Is` / `errors.As` si en el fondo era un `sql.ErrNoRows`. Envolver con contexto en cada capa es lo que reemplaza al stack trace que traías de otros lenguajes, y es mejor, porque el contexto lo escribiste tú y dice algo útil.

El precio es la verbosidad, y no hay que negociarlo: vas a escribir `if err != nil` cientos de veces. Lo que se gana es que **ninguna ruta de fallo es invisible**. En el frontend del track base, una promesa rechazada sin `.catch()` desaparece; acá, un error que no manejas es una variable que el compilador te obliga a nombrar.

> 🧠 **El corolario que importa para este track: los pánicos.** Un `panic` es lo que queda para lo que no es un error esperado —un índice fuera de rango, un puntero nulo—, y lo que pasa después depende de **en qué goroutine** ocurre. Si ocurre en la goroutine que atiende la petición, `net/http` lo recupera por su cuenta: escribe `http: panic serving …` en el log y **cierra la conexión sin responder**. El proceso sigue vivo, pero el cliente no recibe status, ni cuerpo, ni `X-Request-Id`, y el log no dice qué petición fue. Si ocurre en una goroutine que el handler lanzó, nadie lo recupera, y **el proceso entero muere** con todas sus conexiones. En Express, un `throw` síncrono dentro de un handler lo atrapa el framework y responde `500`. Lo medimos en la pieza forense.

### Las interfaces son implícitas

No existe `implements`. Un tipo satisface una interfaz por tener sus métodos, y punto: el tipo puede haberse escrito años antes que la interfaz, en otro paquete, sin conocerla. Esto tiene una consecuencia de diseño que vas a usar en `be02` y que conviene entender ahora: **las interfaces se declaran del lado del consumidor, no del proveedor**. El paquete que necesita guardar ruedas declara `WheelStore` con los métodos que usa; el paquete que habla con Postgres no sabe que esa interfaz existe.

En esta fase la ves en su forma más simple, la que sostiene todo `net/http`:

```go
type Handler interface {
    ServeHTTP(ResponseWriter, *Request)
}
```

Un middleware, entonces, no es un concepto del framework: es simplemente **una función que recibe un `Handler` y devuelve otro `Handler`**. Nada más. Toda la cadena de esta fase son cinco funciones de esa forma, compuestas.

### `context.Context`: el vehículo transversal

`context.Context` es el primer parámetro de todo lo que cruce una frontera —handler, service, store— y hace dos trabajos a la vez.

El primero es **cancelación**. Cuando el cliente cierra la pestaña, el `r.Context()` de esa petición se cancela; si tu consulta a la base recibió ese contexto, Postgres cancela la consulta en vez de seguir gastando CPU por un resultado que nadie va a leer. Es el `takeUntil` de la Fase 6, del lado del servidor y con la misma idea: **lo que ya no le importa a nadie se apaga**.

El segundo es **transportar valores de alcance de petición**, y acá entra el `X-Request-Id`. La regla de oro es que esa vía es para datos que atraviesan capas sin ser parte de la lógica: el request id, la identidad del operador (que llega en `be04`). Nunca para parámetros de negocio disfrazados.

### El orden de los middlewares es contenido, no detalle

Una cadena de middlewares es una cebolla, y quién queda adentro de quién decide qué rastro deja el sistema en sus peores momentos. Este es el orden de la fase, de afuera hacia adentro, con el porqué de cada posición:

1. **`requestID`** primero de todos, porque **todo** lo que venga después —incluida la línea de log de un pánico— necesita el id para ser útil.
2. **`logging`** por fuera de `recover`, para que la línea de log registre el `500` que `recover` escribió y su duración real.
3. **`cors`** por fuera de `recover` y de `chaos`: escribe sus headers en la respuesta **antes** de llamar al siguiente, así que todo lo que venga adentro —un `500`, un `503` del caos— sale con ellos; y contesta el preflight sin dejarlo bajar.
4. **`recover`** envolviendo todo lo que ejecuta código de aplicación.
5. **`chaos`** lo más adentro posible, justo antes de las rutas, porque simula fallos **del handler**, no del transporte.

> ⚠️ El error clásico es poner `recover` de primero "por seguridad". Parece más defensivo y es peor, aunque el cliente no lo note: el `500` le llega igual, con su id y sus headers de CORS, pero en el log el pánico queda **sin id** —`recover` mira el contexto antes de que `requestID` lo llene— y **sin línea de acceso**, porque el pánico se llevó por delante a `logging`. Cuando te toque diagnosticar eso, no vas a tener con qué cruzar.

### El apagado ordenado

`http.Server.Shutdown(ctx)` deja de aceptar conexiones nuevas y espera a que las que están en curso terminen, hasta que el contexto se cancele. Sin él, un `Ctrl+C` mata el proceso en el acto, y el operador que estaba a mitad de un envío recibe una conexión cortada: sin `409`, sin `500`, sin nada que un frontend pueda interpretar. En un despliegue real es la diferencia entre un deploy transparente y una racha de errores en cada release.

---

## 💻 5. Implementación y código comentado

### 5.1 El módulo y el layout

```bash
mkdir -p server/cmd/api server/internal/http
cd server
go mod init github.com/interoceanic-games/esclusa-api
go get github.com/gorilla/mux@v1.8.0
```

```
server/
├── go.mod
├── go.sum
├── CONTRACT.md              # el contrato auditado en be00
├── smoke.sh                 # el checklist de contrato
├── evidence/                # el HAR y los inventarios de be00
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

Dos decisiones del layout que conviene entender ahora porque se repiten en todas las fases.

**`cmd/api/` contiene el `main` y nada más.** Su trabajo es leer configuración, construir las piezas y arrancar el servidor. Toda la lógica vive en `internal/`, que es un directorio con significado para el compilador: **nada fuera de este módulo puede importar un paquete bajo `internal/`**. Es encapsulamiento a nivel de proyecto, gratis y verificado por el compilador.

**El directorio se llama `http` pero el paquete se llama `httpapi`.** El nombre del paquete no está obligado a coincidir con el de la carpeta, y acá el desvío es a propósito: un paquete llamado `http` que importa `net/http` obliga a poner alias en cada archivo, y eso ensucia más de lo que ordena. La ruta de la carpeta la fija el diccionario del curso; el nombre del paquete lo fija la legibilidad.

Cuando termines de escribir los archivos de esta sección, corre `go mod tidy`. El `go get` de arriba se hizo antes de que existiera un solo `import`, y por eso deja la dependencia marcada `// indirect`; `tidy` mira los `import` reales y la corrige. El `go.mod` queda así:

<<<archivo:server/go.mod>>>

> 📝 **Nota de época sobre `gorilla/mux`.** Era el router por defecto de medio ecosistema Go. A fines de 2022 el proyecto **se archivó**, y más tarde volvió a tener mantenedores. Una dependencia central de tu sistema que se muere —y resucita— es exactamente el tipo de evento que define la vida de un sistema legacy, y por eso está en el curso como contenido y no como accidente. 💸 Verifica tú mismo el estado del repositorio hoy antes de apoyarte en él para algo real; no lo des por sentado leyendo esto.

### 5.2 Las respuestas JSON: `respond.go`

Antes que nada, las funciones que van a escribir todas las respuestas del backend. Que existan desde el primer día hace que reproducir la inconsistencia que `be00` documentó como `C-04` —dos formas de `404` conviviendo, `{}` y `{ "error": … }`— sea en `be03` una decisión y no un descuido.

<<<archivo:server/internal/http/respond.go>>>

### 5.3 Los middlewares: `middleware.go`

El archivo más importante de la fase. Léelo entero antes de escribirlo: cada función es corta, pero las decisiones están en los comentarios.

<<<archivo:server/internal/http/middleware.go>>>

> 🧠 **`defer` en una frase.** Registra una función para que se ejecute al salir de la función actual, siempre: con `return`, con error o con pánico. Es el `finally` de Go, y es la única forma de que `recover()` llegue a ejecutarse. Si te resulta ajeno, `bea-01` lo cubre con más calma.

### 5.4 El caos en Go: `chaos.go`

El mock de la Fase 3 se rompía a propósito, y las prácticas del track base dependen de eso. `D22` obliga a reimplementarlo con **doble control**, y a decidir por escrito qué pasa cuando los dos controles se contradicen.

> 🧭 **Regla de precedencia.** Gana **la última orden recibida**, y el arranque cuenta como orden. Es decir: `CHAOS_LEVEL` fija el nivel inicial; cualquier `POST /_chaos` posterior lo reemplaza; un reinicio vuelve a lo que diga la variable. Sin memoria, sin archivo de estado, sin sorpresas.

Los números no se inventan: son los de `mock/chaosMiddleware.js`, en el mismo orden de tiradas, con los mismos `503` y `401` y el mismo cuerpo roto. Y hay una advertencia que en Go no es opcional: **el nivel y el generador de números los usan muchas goroutines a la vez** —una por petición— mientras otra puede estar cambiando el nivel. Un campo compartido sin candado es una condición de carrera de manual, de las que `go test -race` detecta y el ojo no. Por eso el `sync.Mutex`.

<<<archivo:server/internal/http/chaos.go>>>

> ⚠️ **`math/rand` y no `crypto/rand`.** Para decidir si una petición falla, `math/rand` sobra y es más rápido. Para generar un id, no: ahí sí va `crypto/rand`, como en `newRequestID`. Confundirlos en el otro sentido —usar `math/rand` para un token— es un hallazgo de seguridad real, y `bea-08` lo trata.
>
> 📝 La semilla es explícita por la misma razón que en el mock: con `CHAOS_SEED=7`, dos arranques producen exactamente la misma secuencia de fallos, y una práctica que falló en la Fase 3 se puede repetir igual. Sin `CHAOS_SEED`, se siembra con el reloj y cada arranque es distinto.

### 5.5 El router y la cadena: `router.go`

<<<archivo:server/internal/http/router.go>>>

> ⚠️ **`gorilla/mux` no trae recuperación de pánicos.** A diferencia de otros routers, `mux` no recupera nada: lo que hay debajo es la recuperación mínima de `net/http`, que corta la conexión y escribe una línea sin id. Si esperabas que el framework te cubriera —como hace Express con los `throw` síncronos—, no lo hace. Por eso `recoverMiddleware` es tuyo y es obligatorio.

### 5.6 El arranque y el apagado: `main.go`

<<<archivo:server/cmd/api/main.go>>>

### 5.7 Comprobarlo

```bash
cd server
go mod tidy && go build ./... && PORT=3011 go run ./cmd/api

# En otra terminal:
curl -i localhost:3011/health
# → 200, X-Request-Id presente, {"status":"ok"}

# El id que mandas es el id que se respeta y el que aparece en el log:
curl -s -D - -o /dev/null localhost:3011/health -H 'X-Request-Id: mi-id-de-prueba'

# El preflight: 204, con el header authorization aceptado.
curl -s -D - -o /dev/null -X OPTIONS localhost:3011/wheels \
  -H 'Origin: http://localhost:3000' -H 'Access-Control-Request-Method: GET' \
  -H 'Access-Control-Request-Headers: authorization'

# Y C-05 en la respuesta real, que es donde cuenta:
BASE_URL=http://localhost:3011 ./smoke.sh

# El caos, con sus dos controles:
CHAOS_LEVEL=high PORT=3011 go run ./cmd/api                   # orden de arranque
curl -X POST localhost:3011/_chaos -d '{"level":"off"}'        # última orden, gana
```

El `smoke.sh` contra el binario falla en quince de las diecisiete verificaciones, con quejas de `jq` de por medio (no puede leer como JSON el `404 page not found` de `mux`), y está bien: todavía no hay ni un recurso del contrato. Las dos que importan hoy son la 10 y la 11, el header presente y expuesto, y esas pasan. Las demás se ponen en verde en `be03`.

Y la verificación que importa de verdad, porque `curl` no distingue entre ver un header y poder leerlo: con el servidor arriba, abre la consola en `localhost:3000`, y en la consola del navegador:

```javascript
// Solo para comprobar C-05 contra el binario. No toca ningún archivo del frontend.
fetch('http://localhost:3011/health')
  .then(r => console.log('X-Request-Id legible:', r.headers.get('X-Request-Id')));
```

Si imprime un id en vez de `null`, tu binario cumple `C-05`. Busca ese mismo id en la terminal del servidor: ahí está, con la ruta, el status y el tiempo. Eso es lo que el mock nunca pudo darte.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. `WriteHeader` después de escribir el cuerpo.** Síntoma: el cliente recibe `200` cuando tu código dice `404`, y en la terminal aparece `http: superfluous response.WriteHeader call from …`. Causa: en cuanto escribes un byte, Go manda un `200` implícito y el status ya no se puede cambiar. Fix mínimo: fijar `Content-Type` y `WriteHeader` **antes** de encodear, que es justo el orden que impone `writeJSON`, y por eso existe.

**2. El `return` que no cancela nada.** Síntoma: el cliente recibe el `400` que escribiste y, pegado detrás, el cuerpo del camino feliz: `{"error":"Falta el nivel"}` y `{"level":"off"}` en la misma respuesta, más el aviso de `superfluous response.WriteHeader`. Causa: `writeError` no interrumpe el flujo; en Go no hay `return res.status(400).json(...)` que corte por ti. Fix: `return` explícito en la línea siguiente, siempre. Es el error más frecuente de quien llega de Express y el más fácil de no ver en revisión.

**3. Poner `recover` de primero en la cadena.** Síntoma: los pánicos llegan bien al cliente —`500`, id, CORS—, pero en el log la línea dice `[req-id ] PÁNICO …`, sin id, y no hay línea de acceso para esa petición. Causa: el orden. `recover` lee el contexto antes de que `requestID` lo llene, y el pánico desenrolla a `logging` antes de que escriba. Fix: `requestID` → `logging` → `cors` → `recover`. Corrección mínima frente a refactorización: mover una línea en `NewRouter` es la corrección; rediseñar la cadena con un framework de middlewares es la refactorización, y no hace falta.

**4. El nivel de caos como campo compartido sin candado.** Síntoma: bajo carga, un `POST /_chaos` produce lecturas inconsistentes, y `go test -race` imprime `WARNING: DATA RACE`. Causa: escritura concurrente sobre un campo compartido, o un `*rand.Rand` usado desde varias goroutines. Fix: el `Mutex` de `ChaosController`. Si nunca lo viste fallar, ese es el problema: una carrera de datos puede pasar meses sin manifestarse.

### 🩻 Pieza forense de esta fase

**Un pánico, y las tres formas de terminar.**

Agrega un handler que reviente a propósito. No es un caso rebuscado: es un índice fuera de rango, el error más común del mundo.

```go
// Solo para la pieza forense. Se borra al terminar el ejercicio.
r.HandleFunc("/_boom", func(w http.ResponseWriter, r *http.Request) {
    segments := []string{"esclusa-de-oro"}
    writeJSON(w, http.StatusOK, segments[5]) // 💥
}).Methods(http.MethodGet)
```

*Paso 1 — con `recover`.* Con la cadena completa, pide `GET /_boom`. Anota qué ve el cliente (`500` con `{"error":"Error interno del servidor"}`, su `X-Request-Id` y los headers de CORS), qué dice el log (la línea `PÁNICO` y la línea de acceso, **con el mismo id**), y comprueba que el proceso sigue atendiendo: pide `/health` otra vez.

*Paso 2 — sin `recover`.* Comenta la línea de `recoverMiddleware` en `NewRouter` y repite. Ahora anota tres cosas distintas:

- El cliente **no recibe un `500`**: recibe una conexión cerrada sin respuesta. `curl` dice `Empty reply from server` (código de salida 52); en la consola del navegador, `fetch` lanza `TypeError: Failed to fetch`; y `axios` entrega un `Network Error` **sin `error.response`**, o sea sin status, sin cuerpo y sin `X-Request-Id`. Todo el diagnóstico que montamos en `be00` desaparece de golpe.
- El proceso **sigue vivo**: pide `/health` y responde. Quien se fue fue esa conexión, y nada más.
- El único rastro es una línea de `net/http` —`http: panic serving 127.0.0.1:50674: runtime error: index out of range [5] with length 1`— seguida del stack, **sin id**. Si el pánico solo pasa con ciertos datos, no hay cómo saber qué petición fue.

*Paso 3 — la goroutine.* Cambia el handler para que el índice fuera de rango ocurra dentro de un `go func() { … }()` lanzado por el handler, responde `202`, y pide `/health` un segundo después. Esta vez no responde nadie: **el proceso murió**, con todas las conexiones de todos los operadores. `recoverMiddleware` no te habría salvado, porque solo cubre la goroutine que atiende la petición. La regla que sale de acá: toda goroutine que lances desde un handler necesita su propio `defer`/`recover`, o no la lances.

*Paso 4 — la comparación cultural.* Escribe en un archivo aparte un servidor Express 4.17.1 con un handler que haga `segments[5].toUpperCase()`. Express atrapa el `throw` síncrono, responde `500` con una página HTML y **sigue vivo**. Escribe en cuatro líneas qué tiene de parecido y qué de distinto con el Paso 2, y qué te obliga a hacer en cada servicio Go que escribas.

*Paso 5 — el círculo, esta vez completo.* Con el `recover` puesto otra vez, haz la petición desde la consola del navegador (el `fetch` de 5.7), copia el `X-Request-Id` que imprime y búscalo con `grep` en el log del servidor. Ese recorrido —consola del navegador → terminal del backend— es la mitad de lo que `be00` dejó pendiente. La otra mitad, con la consulta SQL y su tiempo, llega en `be02`.

*Rompe a propósito, bonus.* Arranca dos veces con `CHAOS_LEVEL=high CHAOS_SEED=7` y pide cuarenta veces `/health` en cada arranque, anotando los status. Las dos secuencias son idénticas. Repite sin `CHAOS_SEED`: ya no. Decide si para este laboratorio la semilla fija es un bug o una función, y escribe en qué situación real la querrías apagada.

---

> 📓🔥 De esta fase salen los incidentes **be-01** y **be-03** de `cuaderno-incidentes-be.md`: un header que el binario manda y el navegador no deja leer, cuando el mock sí lo dejaba; y una consola que a ratos da error de red sin que el servidor se caiga.

---

## 🧪 7. Ejercicios (32)

**🟢 Fácil (1–8)**

1. Crea el módulo con `go mod init` y compila un `main.go` vacío que imprima el puerto. Confirma que `go build ./...` no dice nada: en Go, silencio es éxito.
2. Levanta el servidor en `PORT=3011` y verifica `GET /health` con `curl -i`.
3. Comprueba que el `X-Request-Id` cambia en cada petición y que es el mismo en el header y en el log.
4. Manda tu propio `X-Request-Id` y verifica que el servidor lo respeta en vez de generar uno nuevo.
5. Comprueba el preflight: `OPTIONS /wheels` con `Access-Control-Request-Headers: authorization` devuelve `204` y acepta el header.
6. Arranca con `CHAOS_LEVEL=high` y confirma en el log el nivel inicial; cámbialo a `off` con `POST /_chaos`.
7. Manda `POST /_chaos` con `{"level":"caotico"}` y verifica que devuelve `400` con `error` **y que el nivel anterior no cambió**.
8. Detén el servidor con `Ctrl+C` y confirma en el log las dos líneas del apagado ordenado.

**🟡 Intermedio (9–18)**

9. Agrega a `/health` un campo `uptime` calculado desde el arranque. Decide dónde vive esa variable y por qué no puede ser global mutable sin candado.
10. Escribe un middleware que rechace con `413` cualquier cuerpo mayor a 1 MB. Ubícalo en la cadena y justifica su posición (el ejercicio 30 te va a hacer revisarla).
11. **Diagnóstico.** Invierte `cors` y `recover` en la cadena, provoca un pánico desde la consola del navegador con `fetch` y describe exactamente qué ve JavaScript. Vas a ver que nada cambia: explica por qué, mirando **cuándo** escribe `cors` sus headers y en qué mapa.
12. **Diagnóstico.** Quita `WriteHeader` de `writeJSON` y observa qué status recibe el cliente cuando el handler pedía `404`. Encuentra el aviso en la terminal.
13. Haz que el `statusRecorder` registre también el `Content-Type` de la respuesta y agrégalo a la línea de log. ¿En qué diagnóstico serviría?
14. Provoca el fallo `timeout` del caos y observa qué hace `curl --max-time 2`. Después repítelo con `fetch` y compara.
15. **Diagnóstico.** Con el caos en `high`, pide doscientas veces `/health` y doscientas veces `/users`. ¿En cuál aparece el `401` y en cuál no? Verifícalo contra `chaosMiddleware` y contra el mock, y explica por qué esa excepción existe.
16. Escribe una prueba manual con `curl` que demuestre la regla de precedencia del caos en sus tres pasos: arranque, `POST /_chaos`, reinicio.
17. Ocupa el puerto con otro proceso y verifica que el servidor muere con `no se pudo levantar el servidor: listen tcp :3011: bind: address already in use` en vez de quedarse callado.
18. **Diagnóstico.** Manda una petición y ciérrala a la mitad (`Ctrl+C` en `curl`) durante la latencia del caos. Comprueba en el log qué pasó con esa petición y relaciónalo con `r.Context()`.

**🟠 Difícil (19–27)**

19. **Diagnóstico.** Ejecuta la pieza forense completa y escribe el informe de las tres formas de terminar, con la salida de `curl`, la de la consola del navegador y el objeto de error de `axios` en cada caso.
20. Haz que el pánico registre también el stack trace con `runtime/debug.Stack()`, y decide qué parte va al log y qué parte **nunca** va al cliente. Argumenta con `bea-08` en mente.
21. **Diagnóstico.** Escribe una prueba que dispare cien goroutines leyendo y escribiendo el nivel del caos a la vez, y córrela con `go test -race`. Después quita el `Mutex` y repite. Pega las dos salidas.
22. Implementa un middleware de timeout de servidor con `http.TimeoutHandler` y explica en qué se diferencia del `WriteTimeout` del `http.Server`. Decide cuál corresponde a este backend.
23. **Diagnóstico.** El apagado ordenado, medido: con el caos en `high` (latencia de hasta 1,5 s), lanza una petición y manda `SIGTERM` a mitad de camino. Demuestra con evidencia que esa petición se completó y que una nueva fue rechazada.
24. Reduce el margen de `Shutdown` a 100 ms y repite el ejercicio anterior. Documenta qué ve el cliente cuando el margen no alcanza y qué implica eso para un despliegue.
25. **Diagnóstico.** Sin `defer cancel()` en el `context.WithTimeout` de `main`, ¿qué se filtra exactamente? Explícalo y encuentra la herramienta que lo detectaría (`go vet` es un buen punto de partida).
26. Reescribe la cadena de middlewares como un `[]func(http.Handler) http.Handler` aplicado en un bucle, de modo que se **lea en el mismo orden en que se ejecuta**. Discute si la legibilidad ganada compensa la indirección.
27. **Diagnóstico.** Con el caos en `low`, corre 500 peticiones a `/health` y calcula la tasa real de `503`. ¿Coincide con el 5 % del mock? Si no, decide cuántas peticiones harían falta para distinguir un 5 % de un 7 % (A14 tiene la herramienta).

**🔴 Muy difícil (28–32)**

28. Diseña y escribe la variante del `chaosMiddleware` que puede fallar **solo en una ruta concreta** (`POST /_chaos` con `{"level":"high","path":"/wheels"}`). Justifica si eso pertenece al régimen de crecimiento del contrato o lo rompe.
29. **Diagnóstico + regresión.** Te entregan este bug: "cada tanto, dos peticiones distintas aparecen en el log con el mismo `X-Request-Id`". Reprodúcelo (pista: `newRequestID` no es el único camino por el que se asigna un id), determina la causa raíz y escribe la prueba de regresión que lo habría atrapado.
30. **Diagnóstico.** Un `413` del backend llega al navegador como `Network Error` y `toReadableError` no tiene nada que traducir. El backend jura que respondió `413`, y `curl` le da la razón. Encuentra la causa en la posición del middleware del ejercicio 10 respecto de `cors`, arréglala y demuestra el antes y el después con dos capturas de Network.
31. Argumenta por escrito si `GET /health` debe reportar `503` cuando la base de datos no responde —caso que llega en `be02`— o mantenerse en `200` mientras el proceso viva. Defiende la postura contraria a la tuya y decide con qué criterio se resuelve, sabiendo que el orquestador de `be09` va a actuar según esa respuesta.
32. **Post-mortem.** Escribe el post-mortem del incidente ficticio "a ratos la consola da error de red y después vuelve, y el servidor nunca se cayó", con la causa raíz en la falta de `recover`, según los ocho puntos del post-mortem de `cuaderno-incidentes.md`: síntoma, evidencia, causa raíz, corrección, prueba de regresión, prevención. Sin culpabilización.

**🔥 Opcionales**

- 🔥 Reescribe el enrutamiento con los patrones de método de `http.ServeMux` de Go 1.22 (`mux.HandleFunc("GET /health", …)`) en una rama aparte. Compara líneas de código y dependencias, y explica por qué el curso se queda en 1.19 (D14).
- 🔥 Sustituye el `log.Printf` por log estructurado en JSON escrito a mano (sin `slog`, que no existe en 1.19). Mide cuánto crece cada línea y discute qué gana quien lee los logs con una máquina.
- 🔥 Agrega un middleware de límite de tasa por IP y decide, con el contrato de `be00` en la mano, si puede entrar sin romper a nadie. Piensa en el juego: miles de celulares detrás de la misma IP de un operador móvil.

---

## 📚 8. Referencias

**Documentación oficial**
- https://pkg.go.dev/net/http — la referencia central. Empieza por `Handler`, `HandlerFunc`, `ServeMux` y `Server`; la documentación de `Handler` dice exactamente qué hace el servidor con un pánico.
- https://pkg.go.dev/net/http#Server.Shutdown — el apagado ordenado, con su ejemplo completo.
- https://pkg.go.dev/context — y sobre todo https://go.dev/blog/context, que explica el porqué mejor que la referencia.
- https://github.com/gorilla/mux — verifica el estado del repositorio hoy antes de apoyarte en él; ver la nota de época en 5.1.
- https://go.dev/blog/error-handling-and-go y https://go.dev/blog/go1.13-errors — errores como valores, y el envoltorio con `%w`.
- https://go.dev/blog/defer-panic-and-recover — la mecánica exacta de la pieza forense.
- https://go.dev/ref/mem — el modelo de memoria de Go, para entender por qué el `Mutex` del caos no es opcional.
- https://pkg.go.dev/math/rand#NewSource — la advertencia de que una fuente creada así no es segura para uso concurrente, a diferencia de la del generador global.

**Libros**
- *The Go Programming Language* (Donovan y Kernighan) — el capítulo de concurrencia y el de interfaces. Es de 2015 y sigue siendo el mejor texto sobre las dos cosas.
- *Let's Go* (Alex Edwards) — construye un servidor web con la biblioteca estándar, con este mismo enfoque de middlewares compuestos. Verifica la edición: se actualiza con cada versión de Go.

**Video / apoyo**
- Busca "Go concurrency patterns Rob Pike" y "justforfunc net/http middleware" en YouTube. Son charlas viejas y siguen siendo exactas: `net/http` casi no ha cambiado.

**Orden de lectura sugerido:** el blog de `defer, panic and recover` primero —veinte minutos y es la pieza forense— → la documentación de `net/http.Handler`, que son tres párrafos y explican toda la cadena y el pánico → `bea-01` para cualquier sintaxis que te frene → y el blog de `context` recién cuando el código te tenga cómodo.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las referencias a libros son de memoria y pueden ser inexactas. Casi todo el material bueno de Go en la web asume la versión más reciente; cuando algo no compile con `go 1.19`, el que manda es `00-decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Tienes un servidor que atiende, que deja rastro de todo lo que hace, que convierte sus propios pánicos en una respuesta que el cliente entiende y que se apaga sin dejar a nadie colgado. Y tienes pagada la primera deuda del track: el `X-Request-Id` dejó de ser un adorno del mock y es una herramienta, que nace en el borde, viaja por el contexto, el navegador puede leer y el log nombra.

Lo que no tienes es un solo dato real. `/health` responde una constante y el contrato de `be00` sigue entero sin implementar. `be02` construye la capa de datos: `database/sql`, el pool, `sqlx` y sus placeholders, las migraciones versionadas, el esquema completo de la rueda, y la tesis incómoda de la fase, que la agnosia de base de datos no existe. Vas a ver la misma consulta devolver resultados distintos contra dos motores, y esa evidencia es la que después justifica la regla del motor de `be08`.

> **La señal de que quedó bien:** *"rompí el servidor de tres maneras a propósito, sé cuál de las tres lo mata, y ahora cualquier error que ocurra allá adentro lo puedo encontrar desde la consola del navegador."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be01-go-y-la-forma-del-monolito -m "be01 cerrada: \
> go.mod con go 1.19 y gorilla/mux 1.8.0; layout de server/ creado; \
> GET /health vivo; cadena requestID→logging→cors→recover→chaos montada en orden; \
> X-Request-Id viajando por context, en el log y expuesto a CORS (C-05); \
> pánico convertido en 500 con id; apagado ordenado con Shutdown; \
> caos con doble control, semilla y precedencia documentada"
> ```
>
> Los commits de la fase llevan su prefijo (`be01: …`) y los de ejercicio su número (`be01 ej21: …`). Si un ejercicio merece su propio marcador va en `ej/be01/21`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` / `-fix`, con el ID que le reserva `cuaderno-incidentes-be.md`. Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- ✅ **Registrado en `00-decisiones-y-versiones.md` como `D24`:** la variable `PORT` y la convención del puerto de transición: mientras el mock viva (be01 y be02) el binario arranca en `3011`; desde `be03` toma el `3001` por defecto.
- **Registrar en el régimen de crecimiento de `server/CONTRACT.md`** la forma de `POST /_chaos` que esta fase define (`{"level":"off|low|high"}` → `200` con el nivel vigente, `400` con `error` ante nivel desconocido sin cambiar nada), `CHAOS_SEED` y `GET /health`. El mock nunca tuvo `POST /_chaos`, así que la forma la define el backend.
- **`C-05` queda cerrado acá.** La verificación 11 de `smoke.sh` pasa contra el binario; las de los recursos siguen en rojo hasta `be03`, como corresponde.
- **Para `be03`:** la ruta desconocida de `mux` responde `404 page not found` en texto plano, y el contrato (`C-04`) pide `{}`. El `NotFoundHandler` del router tiene que escribirlo.
- **Deudas declaradas en esta fase:** 💸 configuración con `os.Getenv` sin validar (se paga en `be03` con `envconfig`); 💸 log de texto en vez de estructurado (se discute en `bea-07`, no se paga en el track: es coherente con la época y con D14).
- **Para `be02`:** `healthHandler` tiene que crecer para reportar el estado de la base, y ahí aparece la pregunta del ejercicio 31 —`200` o `503`— que `be09` necesita resuelta porque el orquestador actúa según esa respuesta. `be02` la cierra (D26).
- **Para `be08`:** el ejercicio 21 (carrera de datos en `ChaosController` con `-race`) es el germen natural de la sección de `go test -race`. Y la regla de precedencia del caos hay que probarla ahí.
- **Para `bea-01`:** esta fase da por conocidos `defer`, punteros, goroutines, canales, `interface{}` y el patrón de envoltorio de `ResponseWriter`. El apéndice tiene que cubrir los seis, y el envoltorio merece su propia sección porque reaparece en `be08`.
- **Para `be-17`:** esta fase siembra el caos de forma explícita y no explica qué pasaría sin semilla. Es a propósito: la trampa del generador global de Go 1.19 la descubre el incidente.
- **Reserva para el cuaderno de incidentes:** `be-01` — *"la trazabilidad funciona en Network pero no en la consola"* (🔥 contrato, 🟡), con la rama que quita `Access-Control-Expose-Headers` del CORS del binario; y `be-03` — *"a ratos la consola da error de red y después vuelve"* (🔥 despliegue, 🟡), el pánico sin `recover` visto desde afuera: `net/http` corta la conexión y el servidor sigue vivo.
