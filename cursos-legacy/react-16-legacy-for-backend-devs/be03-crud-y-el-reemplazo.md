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

> 📓🔥 De esta fase salen los incidentes **be-06** y **be-07** de `cuaderno-incidentes-be.md`, los dos sobre lo mismo desde ángulos opuestos: un campo que a veces llega vacío y un campo que se perdió en silencio durante seis meses.

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

- 🔥 **Genera volumen con un faker** (`bea-10`): cincuenta rifas y veinte mil números. Sin volumen, las mediciones de `be05` y `be08` no dicen nada — este ejercicio es prácticamente un prerrequisito de las dos fases.
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
- **Para `bea-10`:** el ejercicio 🔥 de volumen es prácticamente prerrequisito
  de `be05` y `be08`. Conviene que las dos fases lo digan al abrir, no solo acá.
- **Reserva para el cuaderno de incidentes:** `be-06` — *"el comprador aparece en
  blanco, pero solo a veces"* (categoría 🔥 contrato, dificultad 🟠), que es el
  Caso A de la pieza forense llegado como ticket; y `be-07` — *"faltan datos en
  las liquidaciones de agosto"* (categoría 🔥 contrato, dificultad 🔴), que es el
  Caso B descubierto seis meses tarde, cuando ya no hay forma de recuperarlos.
