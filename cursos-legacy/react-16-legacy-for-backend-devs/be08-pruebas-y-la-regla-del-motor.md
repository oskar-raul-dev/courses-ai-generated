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

> 📓🔥 De esta fase sale el incidente **be-15** ⭐ de `cuaderno-incidentes-be.md`, hermano del **20** del track base. Los dos enseñan lo mismo desde orillas opuestas, y con una simetría que conviene notar: allá la suite está **roja** y dice la verdad; acá lleva tres semanas en **verde** y miente.

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
- **El par contradictorio es material de `bea-03`.** El apéndice de dialectos
  debería citarlo como su cierre: el diccionario de divergencias explica **qué**
  difiere, y estas dos pruebas demuestran **qué cuesta**.
- **La prueba B (comparación de instantes) también es de `bea-06`.** Es la misma
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
