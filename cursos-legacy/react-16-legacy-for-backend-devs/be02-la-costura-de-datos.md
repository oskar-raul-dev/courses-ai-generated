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
`TIMESTAMPTZ`, ni `BIGSERIAL`, ni `ALTER COLUMN`, ni tipos que se hagan cumplir
—las tablas `STRICT` de SQLite llegaron en la 3.37, después de nuestra cota—. Escribir el DDL en ese subconjunto significa **renunciar a Postgres
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
> `bea-02`.

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
// motores pasa por acá o por bea-03; ninguna se resuelve improvisando un
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

import (
	"context"
	"time"
)

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
> lado. `bea-08` trata la distinción con el detalle que merece.

### 5.7 Las pruebas: la capa se prueba desde Go, no desde HTTP

```go
// server/internal/raffle/store_test.go
package raffle_test

import (
	"context"
	"os"
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
`bea-07`.

---

> 📓🔥 De esta fase salen los incidentes **be-04** y **be-05** de `cuaderno-incidentes-be.md`. El be-05 es hermano del incidente **19** del track base —el mismo *"anda bien hasta que crece"*— con el recurso agotado en esta orilla del cable en vez de la otra.

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
documentación del pool de `database/sql` → y `bea-03` para el diccionario
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
  `be08` lo usa como base de su regla del motor y `bea-03` lo amplía a
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
