# 🐹 Apéndice bea-01 — Go para quien no escribe Go

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
