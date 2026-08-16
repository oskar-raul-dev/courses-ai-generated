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
- **La sintaxis de Go** → `bea-01`. Esta fase asume que sabes leer una función y
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
// bea-07 se discute qué cambia con log estructurado y por qué importa el
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
				// —y qué se filtra sin darse cuenta— es tema de bea-08.
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
> Si te resulta ajeno, `bea-01` lo cubre con más calma.

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
	"time"
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
> token— es un hallazgo de seguridad real, y `bea-08` lo trata.
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
	// crecimiento. Lo usan el compose de bea-02 y el pipeline de be09.
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

> 📓🔥 De esta fase sale el incidente **be-03** de `cuaderno-incidentes-be.md`: un proceso que se cae y vuelve tres veces al día sin que nadie se queje, porque el orquestador lo tapa.

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
20. Haz que el pánico registre también el stack trace con `runtime/debug.Stack()`, y decide qué parte va al log y qué parte **nunca** va al cliente. Argumenta con `bea-08` en mente.
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
que son tres párrafos y explican toda la cadena → `bea-01` para cualquier
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
  estructurado (se discute en `bea-07`, no se paga en el track: es coherente
  con la época y con D14).
- **Para `be02`:** `healthHandler` tiene que crecer para reportar el estado de la
  base, y ahí aparece la pregunta del ejercicio 31 —`200` o `503`— que `be09`
  necesita resuelta porque el orquestador actúa según esa respuesta. Conviene que
  `be02` la cierre explícitamente en vez de dejarla al ejercicio.
- **Para `be08`:** el ejercicio 21 (carrera de datos en `ChaosController` con
  `-race`) es el germen natural de la sección de `go test -race`. Y la regla de
  precedencia del caos hay que probarla ahí, como pide la propuesta §11.
- **Para `bea-01`:** esta fase da por conocidos `defer`, punteros, goroutines,
  canales, `interface{}` y el patrón de envoltorio de `ResponseWriter`. El
  apéndice tiene que cubrir los seis, y el envoltorio merece su propia sección
  porque reaparece en `be08`.
- **Reserva para el cuaderno de incidentes:** `be-03` — *"el backend se cae solo
  y vuelve, tres veces al día"* (categoría 🔥 despliegue, dificultad 🟡), que es
  el pánico sin `recover` visto desde afuera, cuando el contenedor se reinicia y
  el único síntoma es una racha de errores de red sin patrón.
