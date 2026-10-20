# 🔁 Fase be03 — CRUD y el reemplazo

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Fase be03 de be09 · **10 horas**
> Depende de: be02 — la capa de datos y las migraciones · Habilita: be04 — Identidad real

---

## 🎯 1. Propósito

Juliana lo dijo en la primera llamada y lo repite antes de esta fase: el API nuevo se hace *"sin que la consola cambie un archivo"* (`00-historia-del-sistema.md` §3, *Hoy*). Esta es **la bisagra del track**. Todo lo anterior fue preparación: se auditó un contrato, se levantó un servidor y se construyó una capa de datos. Acá se implementan los recursos de ese contrato en capas —handler → service → store—, se siembra la base con **el `db.json` que ya tienes**, y después se hace lo único que de verdad prueba que el trabajo sirvió:

> 🧭 **Se apaga el mock. Se levanta el binario de Go en el puerto `3001`. Se recorre la consola entera. Y el frontend no cambia ni un archivo.**

El criterio de aprobación no es una opinión ni una sensación: es `server/smoke.sh`, escrito en `be00` contra el mock, ejecutado sin modificar una línea contra tu binario. **Pasa o no pasa.**

La deuda 💸 que cobra es la primera de las grandes: `db.json` como almacén. Y con ella se retira el mock del `3001`. 🪦 Las otras deudas que el contrato registró —el giro sin transacción, el chequeo de caso que no protege, la conciliación que el servidor no verifica— se reimplementan **tal cual**, con un comentario que dice qué fase las paga. Un reemplazo que además "arregla cosas" deja de ser verificable: si algo cambia, ya no sabes si fue el reemplazo o el arreglo.

---

## ✅ 2. Qué queda listo al terminar

- [ ] La configuración sale de un único struct validado con `envconfig`, y el proceso **falla al arrancar** si falta algo, no en la primera petición.
- [ ] Las migraciones `000002` y `000003` aplicadas en los dos dialectos: el token de mentira y la forma completa de la conciliación.
- [ ] `server/internal/seed/` siembra Postgres desde `mock/db.json`, es idempotente, conserva los ids originales y le da a cada rueda su versión 1.
- [ ] Las rutas del régimen estricto de `server/CONTRACT.md` están implementadas en capas: handler → service → store.
- [ ] Las dos formas de `404` conviven según `C-04`: `{}` en lo automático y en lo desconocido, `{ "error": … }` en las rutas propias.
- [ ] `name_like` se comporta como en el mock: una expresión regular que no distingue mayúsculas, ni siquiera con tildes.
- [ ] El mock del `3001` está apagado y el binario escucha en el `3001`; el mock de Google Play del `3002` sigue vivo.
- [ ] **`./server/smoke.sh` pasa entero, con las diecisiete verificaciones en verde.**
- [ ] El recorrido completo de `be00` se repite contra el binario y no hay una sola diferencia visible en la consola.
- [ ] `git diff pre-backend-go..HEAD -- . ':!server'` no devuelve nada.

---

## 🚫 3. Qué queda fuera por ahora

- **Autenticación real** → `be04`. El login sigue devolviendo el token de mentira que el frontend espera, ahora guardado en una columna. Sí: vamos a crear una columna para almacenar una credencial falsa, y `be04` la va a borrar. Esa columna es la deuda 💸 hecha DDL.
- **El `409` producido por la base** → `be05`. Acá el giro decide con un `if` en Go sobre una fila leída antes, y el chequeo de caso del envío también. Es el **mismo `if` del mock, traducido de lenguaje**: sigue sin proteger nada bajo concurrencia, y ahora la deuda está escrita en un lenguaje compilado, que es peor porque parece seria.
- **La autoridad del reloj** → `be06`. El cierre de la rueda lo sigue evaluando la consola.
- **La conciliación recalculada en el servidor** → `be07`. Acá `POST /wheels/:id/reconciliation` guarda lo que manda el navegador (`C-07`) y ya.
- **La paginación de la bitácora.** El contrato pide las 10.000 filas de una vez, y así se sirven (régimen estricto, `be00`).

---

## 🧠 4. Conceptos mínimos

### Las tres capas, y qué se prohíbe en cada una

La estructura no es decorativa: cada capa tiene una prohibición, y las prohibiciones son las que hacen que el diseño sirva para algo.

**El handler** habla HTTP y nada más: lee la petición, valida la *forma* de la entrada, llama al service y traduce lo que vuelve a un código de estado y un JSON. *Prohibido:* tocar la base, decidir reglas de negocio.

**El service** tiene el dominio: qué cambios de pesos publican una versión, qué transiciones son legales, qué operaciones van juntas en una transacción. *Prohibido:* conocer `http.ResponseWriter`, códigos de estado o headers. Si un service devuelve un `404`, la capa se rompió.

**El store** habla SQL. *Prohibido:* tomar decisiones de negocio y dejar escapar un `sql.ErrNoRows` hacia arriba: se traduce a un error de dominio en la frontera, como ya hace `wheel.Store` desde `be02`.

La prueba de que las capas están bien puestas es un ejercicio mental de treinta segundos: **si mañana hubiera que exponer esto por gRPC o por una cola de mensajes, ¿cuánto código se reescribe?** Si la respuesta es "solo los handlers", está bien. Si hay que tocar el service, no.

### Reimplementar un dialecto ajeno es aburrido y correcto

Vas a escribir código que te va a dar comezón. `DELETE` que devuelve `{}` en vez de `204`. Dos formas distintas de `404` conviviendo en el mismo servidor. Un endpoint de login que filtra por query string. Un campo `token` que es una constante guardada en una tabla. Un giro que siempre cae en la Esclusa de Oro, porque así lo hace el giro de medición de la Fase 3. Una búsqueda que interpreta lo que escribe el operador como una expresión regular.

Todo eso está mal, y todo eso se implementa exactamente así.

> 🧭 **`D21`, dicho sin adornos.** Un backend "mejor diseñado" que obliga a cambiar el cliente es, para este curso, un backend roto. La única medida de calidad de esta fase es que el frontend no se entere.

La habilidad que se entrena acá no es escribir APIs bonitas: es **reemplazar una pieza de un sistema vivo sin que el resto se dé cuenta**. Es lo que hace falta para modernizar cualquier cosa que ya tenga usuarios, y es lo contrario del instinto que trae casi todo el mundo. El rediseño viene después, cuando ya controlas las dos orillas, y entonces se hace con una migración del cliente planificada, no de contrabando dentro de un reemplazo de backend.

### El punto peligroso: cómo serializa Go

En `json-server`, lo que devuelve la API es literalmente lo que hay en el archivo. No hay capa de serialización, no hay tipos, no hay conversión. En Go hay las tres, y ahí es donde se rompen los contratos.

Las cuatro reglas que hay que tener presentes todo el tiempo:

**Solo se serializan los campos exportados.** Un campo en minúscula no aparece en el JSON, sin aviso, sin error, sin nada. El síntoma es un objeto al que le falta justo el campo que importa.

**El tipo del campo decide la forma del JSON, y los tipos nulos de `database/sql` son una trampa.** Un `sql.NullString` no serializa a `null` ni a un texto: serializa a `{"String":"paid","Valid":true}`. Es la trampa de esta fase y es la pieza forense.

**Un campo que en el mock no existe no es lo mismo que un campo en `null`.** Las filas que escribe el giro de 2019 no tienen `wheelId` ni `origin`: en el mock, esas claves no están. Un puntero con `omitempty` las omite cuando son `nil`, y la respuesta queda igual a la del mock.

**`time.Time` serializa en RFC 3339, con el huso que traiga el valor.** Y el huso que trae depende de la zona de la **sesión** de Postgres, no de lo que guardaste (`be02`, Divergencia 0). `closesAt` tiene que salir con `-05:00`; los instantes que el mock guardaba con `toISOString()` —`createdAt`, `creditedAt`, `reconciledAt`— tienen que salir en UTC con milisegundos y `Z`. Son dos contratos distintos para el mismo tipo, y cada uno se cumple a propósito.

### Configuración: un struct que falla temprano

`be01` leyó variables con `os.Getenv` y lo declaró como deuda. Se paga acá, y no por elegancia: la configuración dispersa **falla tarde**. Un `DATABASE_URL` vacío con `os.Getenv` no rompe nada al arrancar; rompe en la primera petición de un operador, veinte minutos después del despliegue, con un error que no menciona la configuración.

`envconfig` mapea variables de entorno a un struct, aplica valores por defecto y —lo importante— marca lo obligatorio como `required:"true"`. El proceso muere en el segundo cero con un mensaje que dice qué falta. **Fallar temprano y ruidoso es una decisión de operación, no de estilo.**

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
	Port          string `envconfig:"PORT"            default:"3001"`
	DatabaseURL   string `envconfig:"DATABASE_URL"    required:"true"`
	AllowedOrigin string `envconfig:"ALLOWED_ORIGIN"  default:"http://localhost:3000"`
	ChaosLevel    string `envconfig:"CHAOS_LEVEL"     default:"off"`
	ChaosSeed     int64  `envconfig:"CHAOS_SEED"      default:"0"`
	// Lo que tarda el juego en entregar un premio de un envío manual. Es el
	// GRANT_DELIVERY_MS del mock, y el contrato lo conserva (be00, C-07).
	GrantDeliveryMs int `envconfig:"GRANT_DELIVERY_MS" default:"800"`
}

// Load lee el entorno y falla si algo obligatorio no está.
//
// 🧠 El default del puerto es 3001 y no 3011: a partir de esta fase el
// binario ES el backend del 3001. El puerto de transición de be01 y be02
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

Al implementar el contrato aparecen dos huecos del esquema de `be02`. No son descuidos que ocultar: son **exactamente lo que pasa cuando se diseña un esquema sin medir el cuerpo real de las peticiones**, y por eso se documentan.

**`000002` — la columna de la vergüenza.** El contrato dice que `GET /users?email=…&password=…` devuelve un objeto con un campo `token`, y ese token es una constante que vive en `db.json`. Para devolverlo hay que guardarlo.

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

**`000003` — el cuerpo real de una conciliación.** El `POST /wheels/:id/reconciliation` de la Fase 8 manda, además de los conteos y el chi-cuadrado, tres listas que la tabla de `be02` no previó: qué segmentos dieron alarma de banda, qué compras de la tienda no están acreditadas y cuáles se acreditaron dos veces. Las tres **no rompen nada visible** si faltan: el `INSERT` no las nombra, el `201` sale bien, la consola sigue andando. Se pierden en silencio, y la contadora las va a echar de menos en el cierre del semestre.

```sql
-- server/migrations/postgres/000003_reconciliation_full_shape.up.sql
-- El cuerpo que la consola manda de verdad (Fase 8, reconcileWheel) trae tres
-- campos que el esquema de be02 no previó: qué segmentos dieron alarma de banda
-- y qué compras no cuadran contra la tienda, en cada sentido. Medido contra el
-- contrato, no deducido leyendo el slice.
ALTER TABLE reconciliations ADD COLUMN band_alarms        JSONB NOT NULL DEFAULT '[]';
ALTER TABLE reconciliations ADD COLUMN missing_in_api     JSONB NOT NULL DEFAULT '[]';
ALTER TABLE reconciliations ADD COLUMN duplicated_in_api  JSONB NOT NULL DEFAULT '[]';
```

En SQLite, las mismas columnas son `TEXT NOT NULL DEFAULT '[]'`, y los `down` usan `ALTER TABLE … DROP COLUMN`, que SQLite acepta desde la 3.35 (la tuya, medida en `be02`, es la 3.39.4). Antes de esa versión, ese `down` no se podía escribir.

```bash
migrate -path migrations/postgres -database "$DATABASE_URL" up   # 2/u add_user_token, 3/u reconciliation_full_shape
```

### 5.3 La siembra: `internal/seed`

La siembra sale de **tu** `db.json`, no de un dump nuestro. Que después del reemplazo aparezcan exactamente las ruedas, los jugadores y la bitácora que veías en el track base es la mitad del efecto de esta fase: el mock se apagó y la consola sigue mostrando *tus* datos.

```go
// server/internal/seed/seed.go

package seed

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strings"

	"github.com/jmoiron/sqlx"

	"github.com/interoceanic-games/esclusa-api/internal/storage"
)

// dbJSON refleja la forma del mock/db.json de la Fase 11. Los nombres de los
// campos son los del CONTRATO (camelCase), no los de las columnas.
type dbJSON struct {
	Users []struct {
		ID       int64  `json:"id"`
		Email    string `json:"email"`
		Password string `json:"password"`
		Name     string `json:"name"`
		Token    string `json:"token"`
	} `json:"users"`
	Wheels []struct {
		ID       int64  `json:"id"`
		Name     string `json:"name"`
		Timezone string `json:"timezone"`
		ClosesAt string `json:"closesAt"`
		Status   string `json:"status"`
	} `json:"wheels"`
	// Ojo con el nombre: la colección del mock se llama "segments" y cuelga de
	// la rueda; la tabla se llama wheel_segments y cuelga de una VERSIÓN. La
	// traducción vive acá, en un solo lugar: todo lo sembrado es la versión 1.
	Segments []struct {
		ID        int64  `json:"id"`
		WheelID   int64  `json:"wheelId"`
		SegmentID string `json:"segmentId"`
		PrizeType string `json:"prizeType"`
		WeightBp  int    `json:"weightBp"`
	} `json:"segments"`
	Players []struct {
		ID      int64   `json:"id"`
		Name    string  `json:"name"`
		Country *string `json:"country"`
		Status  string  `json:"status"`
	} `json:"players"`
	Packages []struct {
		ProductID         string `json:"productId"`
		Spins             int    `json:"spins"`
		PackagePriceCents int64  `json:"packagePriceCents"`
	} `json:"packages"`
	Purchases []struct {
		PurchaseToken string `json:"purchaseToken"`
		ProductID     string `json:"productId"`
		CreditedAt    string `json:"creditedAt"`
	} `json:"purchases"`
	Stock []struct {
		ID        int64  `json:"id"`
		WheelID   int64  `json:"wheelId"`
		SegmentID string `json:"segmentId"`
		Remaining int    `json:"remaining"`
	} `json:"stock"`
	SpinLog []struct {
		ID             int64   `json:"id"`
		WheelID        *int64  `json:"wheelId"`
		PlayerID       int64   `json:"playerId"`
		LandedSegment  string  `json:"landedSegment"`
		DeliveredPrize *string `json:"deliveredPrize"`
		Origin         *string `json:"origin"`
		PurchaseToken  *string `json:"purchaseToken"`
		IdempotencyKey string  `json:"idempotencyKey"`
		CreatedAt      string  `json:"createdAt"`
	} `json:"spinLog"`
}

// FromFile siembra la base desde el db.json indicado.
//
// Es IDEMPOTENTE a propósito: se puede correr veinte veces seguidas sin
// duplicar nada. Una siembra que solo funciona sobre una base vacía es una
// siembra que nadie se atreve a correr, y entonces todo el mundo termina
// restaurando dumps a mano. Conserva los ids del db.json: la consola los
// guarda en el store y cambiarlos sería cambiar datos observables.
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
	// Rollback después de un Commit exitoso no hace nada: este defer es
	// seguro y es la forma idiomática de no dejar transacciones colgadas.
	defer tx.Rollback()

	exec := func(what, query string, args ...interface{}) error {
		if _, err := tx.ExecContext(ctx, tx.Rebind(query), args...); err != nil {
			return fmt.Errorf("sembrando %s: %w", what, err)
		}
		return nil
	}

	for _, u := range data.Users {
		if err := exec("el usuario "+u.Email, `
			INSERT INTO users (id, email, password, name, token) VALUES (?, ?, ?, ?, ?)
			ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, password = EXCLUDED.password,
			    name = EXCLUDED.name, token = EXCLUDED.token`,
			u.ID, u.Email, u.Password, u.Name, u.Token); err != nil {
			return err
		}
	}

	versionOf := map[int64]int64{} // rueda → id de su versión 1
	for _, w := range data.Wheels {
		if err := exec(fmt.Sprintf("la rueda %d", w.ID), `
			INSERT INTO wheels (id, name, timezone, closes_at, status) VALUES (?, ?, ?, ?, ?)
			ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, timezone = EXCLUDED.timezone,
			    closes_at = EXCLUDED.closes_at, status = EXCLUDED.status`,
			w.ID, w.Name, w.Timezone, w.ClosesAt, w.Status); err != nil {
			return err
		}
		if err := exec(fmt.Sprintf("la versión 1 de la rueda %d", w.ID), `
			INSERT INTO wheel_versions (wheel_id, version) VALUES (?, 1)
			ON CONFLICT (wheel_id, version) DO NOTHING`, w.ID); err != nil {
			return err
		}
		var versionID int64
		if err := tx.GetContext(ctx, &versionID, tx.Rebind(`
			SELECT id FROM wheel_versions WHERE wheel_id = ? AND version = 1`), w.ID); err != nil {
			return fmt.Errorf("buscando la versión 1 de la rueda %d: %w", w.ID, err)
		}
		versionOf[w.ID] = versionID
	}

	for _, s := range data.Segments {
		if err := exec(fmt.Sprintf("el segmento %d", s.ID), `
			INSERT INTO wheel_segments (id, wheel_version_id, segment_id, prize_type, weight_bp)
			VALUES (?, ?, ?, ?, ?)
			ON CONFLICT (id) DO UPDATE SET wheel_version_id = EXCLUDED.wheel_version_id,
			    segment_id = EXCLUDED.segment_id, prize_type = EXCLUDED.prize_type, weight_bp = EXCLUDED.weight_bp`,
			s.ID, versionOf[s.WheelID], s.SegmentID, s.PrizeType, s.WeightBp); err != nil {
			return err
		}
	}

	for _, p := range data.Players {
		status := p.Status
		if status == "" {
			status = "active"
		}
		if err := exec(fmt.Sprintf("el jugador %d", p.ID), `
			INSERT INTO players (id, name, country, status) VALUES (?, ?, ?, ?)
			ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, country = EXCLUDED.country, status = EXCLUDED.status`,
			p.ID, p.Name, p.Country, status); err != nil {
			return err
		}
	}

	for _, p := range data.Packages {
		if err := exec("el paquete "+p.ProductID, `
			INSERT INTO packages (product_id, spins, package_price_cents) VALUES (?, ?, ?)
			ON CONFLICT (product_id) DO UPDATE SET spins = EXCLUDED.spins,
			    package_price_cents = EXCLUDED.package_price_cents`,
			p.ProductID, p.Spins, p.PackagePriceCents); err != nil {
			return err
		}
	}

	// Las compras no traen id y una está acreditada dos veces (Fase 8): no hay
	// clave natural para un ON CONFLICT. Se reemplazan enteras, dentro de la
	// misma transacción, y la siembra sigue siendo repetible.
	if err := exec("las compras (borrado)", `DELETE FROM purchases`); err != nil {
		return err
	}
	for _, p := range data.Purchases {
		if err := exec("la compra "+p.PurchaseToken, `
			INSERT INTO purchases (purchase_token, product_id, credited_at) VALUES (?, ?, ?)`,
			p.PurchaseToken, p.ProductID, p.CreditedAt); err != nil {
			return err
		}
	}

	for _, s := range data.Stock {
		if err := exec(fmt.Sprintf("el stock %d", s.ID), `
			INSERT INTO stock (id, wheel_id, segment_id, remaining) VALUES (?, ?, ?, ?)
			ON CONFLICT (id) DO UPDATE SET wheel_id = EXCLUDED.wheel_id, segment_id = EXCLUDED.segment_id,
			    remaining = EXCLUDED.remaining`,
			s.ID, s.WheelID, s.SegmentID, s.Remaining); err != nil {
			return err
		}
	}

	// La bitácora va en lotes de 500 filas por INSERT: con la Semana del Canal
	// sembrada son 180.000, y fila por fila la siembra tarda minutos.
	const batch = 500
	for start := 0; start < len(data.SpinLog); start += batch {
		end := start + batch
		if end > len(data.SpinLog) {
			end = len(data.SpinLog)
		}
		var values []string
		var args []interface{}
		for _, r := range data.SpinLog[start:end] {
			values = append(values, "(?, ?, ?, ?, ?, ?, ?, ?, ?)")
			args = append(args, r.ID, r.WheelID, r.PlayerID, r.LandedSegment, r.DeliveredPrize,
				r.Origin, r.PurchaseToken, r.IdempotencyKey, r.CreatedAt)
		}
		if err := exec(fmt.Sprintf("la bitácora (filas %d a %d)", start+1, end), `
			INSERT INTO spin_log (id, wheel_id, player_id, landed_segment, delivered_prize, origin,
			    purchase_token, idempotency_key, created_at)
			VALUES `+strings.Join(values, ", ")+`
			ON CONFLICT (id) DO NOTHING`, args...); err != nil {
			return err
		}
	}

	// ⚠️ Los ids insertados a mano NO mueven la secuencia de BIGSERIAL. Sin
	// esto, la primera alta intenta usar el id 1 y choca con lo sembrado:
	// "duplicate key value violates unique constraint". Es el error más
	// frecuente de toda esta fase y no tiene nada que ver con tu código.
	if db.Dialect == storage.Postgres {
		if err := fixSequences(ctx, tx); err != nil {
			return err
		}
	}
	return tx.Commit()
}

func fixSequences(ctx context.Context, tx *sqlx.Tx) error {
	for _, table := range []string{"users", "wheels", "wheel_versions", "wheel_segments", "players",
		"purchases", "stock", "spin_log", "grants", "reconciliations"} {
		_, err := tx.ExecContext(ctx, fmt.Sprintf(
			`SELECT setval(pg_get_serial_sequence('%s', 'id'), COALESCE((SELECT MAX(id) FROM %s), 1))`, table, table))
		if err != nil {
			return fmt.Errorf("ajustando la secuencia de %s: %w", table, err)
		}
	}
	return nil
}
```

```go
// server/cmd/seed/main.go

// Un binario aparte, no un flag del servidor. Sembrar es una operación de
// operador, no de arranque: mezclarla con el servidor es la misma clase de
// error que ejecutar migraciones al arrancar.
package main

import (
	"context"
	"flag"
	"log"
	"time"

	"github.com/interoceanic-games/esclusa-api/internal/config"
	"github.com/interoceanic-games/esclusa-api/internal/seed"
	"github.com/interoceanic-games/esclusa-api/internal/storage"
)

func main() {
	path := flag.String("file", "../mock/db.json", "ruta al db.json del track base")
	flag.Parse()

	cfg, err := config.Load()
	if err != nil {
		log.Fatal(err)
	}
	db, err := storage.Open(context.Background(), cfg.DatabaseURL)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	start := time.Now()
	if err := seed.FromFile(context.Background(), db, *path); err != nil {
		log.Fatalf("la siembra falló: %v", err)
	}
	log.Printf("siembra completa desde %s en %s", *path, time.Since(start).Round(time.Millisecond))
}
```

```bash
go run ./cmd/seed -file ../mock/db.json
go run ./cmd/seed -file ../mock/db.json    # otra vez: no duplica nada
```

Corrida del 19/10/2026 contra `postgres:13`: `siembra completa desde ../mock/db.json en 144ms`, con las 10.000 filas de la bitácora de la Rueda de fin de mes, y la segunda vez igual.

### 5.4 El tipo que rompe el contrato, y cómo se arregla

Antes de escribir un solo handler, el problema que va a aparecer sí o sí.

Las columnas `wheel_id`, `origin`, `delivered_prize` y `purchase_token` de la bitácora son anulables, porque el giro de 2019 escribe filas sin ellas (`C-03`). Si las declaras `string`, el primer `NULL` revienta el `Scan` con `converting NULL to string is unsupported`. La forma directa de arreglarlo es `sql.NullString`, y **eso rompe el contrato en silencio**: el JSON sale `{"String":"paid","Valid":true}`, la consola compara `row.origin === "paid"` y un objeto nunca es igual a un texto.

La forma correcta es un puntero con `omitempty`: `sqlx` lo escanea igual de bien, y `encoding/json` omite la clave cuando es `nil`, que es exactamente lo que el mock devolvía.

```go
// server/internal/spin/spin.go

package spin

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"github.com/interoceanic-games/esclusa-api/internal/jsontime"
	"github.com/interoceanic-games/esclusa-api/internal/storage"
)

// Spin es una fila de la bitácora. Los punteros con omitempty no están por
// gusto de Go: el giro de 2019 escribe filas sin rueda, sin origen y sin premio
// entregado (be00, C-03), y en el mock esos campos NO EXISTEN en la fila. Un
// puntero nil con omitempty los omite, y la respuesta queda igual a la del mock.
type Spin struct {
	ID             int64        `json:"id"                       db:"id"`
	WheelID        *int64       `json:"wheelId,omitempty"        db:"wheel_id"`
	WheelVersion   *int         `json:"wheelVersion,omitempty"   db:"wheel_version"`
	PlayerID       int64        `json:"playerId"                 db:"player_id"`
	LandedSegment  string       `json:"landedSegment"            db:"landed_segment"`
	DeliveredPrize *string      `json:"deliveredPrize,omitempty" db:"delivered_prize"`
	Origin         *string      `json:"origin,omitempty"         db:"origin"`
	PurchaseToken  *string      `json:"purchaseToken,omitempty"  db:"purchase_token"`
	IdempotencyKey string       `json:"idempotencyKey"           db:"idempotency_key"`
	CreatedAt      jsontime.ISO `json:"createdAt"                db:"created_at"`
}

type Stock struct {
	ID        int64  `json:"id"        db:"id"`
	WheelID   int64  `json:"wheelId"   db:"wheel_id"`
	SegmentID string `json:"segmentId" db:"segment_id"`
	Remaining int    `json:"remaining" db:"remaining"`
}

// Filter son los filtros por campo de json-server que se usan: la consola filtra
// por rueda (C-02); por clave y por jugador son para diagnosticar desde curl.
type Filter struct {
	WheelID        *int64
	IdempotencyKey string
	PlayerID       *int64
}

var (
	ErrMissingKey = errors.New("falta idempotencyKey")
	ErrSoldOut    = errors.New("agotado")
)

// GoldenSegment es el segmento que mide el giro de la Fase 3: la Esclusa de Oro.
const GoldenSegment = "esclusa-de-oro"

type Service struct{ db *storage.DB }

func NewService(db *storage.DB) *Service { return &Service{db: db} }

// Log devuelve la bitácora entera que pide el filtro, sin paginar: es régimen
// estricto (be00), y con la Semana del Canal sembrada son 180.000 filas.
func (s *Service) Log(ctx context.Context, f Filter) ([]Spin, error) {
	query := `SELECT id, wheel_id, wheel_version, player_id, landed_segment, delivered_prize,
	                 origin, purchase_token, idempotency_key, created_at
	          FROM spin_log WHERE 1 = 1`
	args := []interface{}{}
	if f.WheelID != nil {
		query += ` AND wheel_id = ?`
		args = append(args, *f.WheelID)
	}
	if f.IdempotencyKey != "" {
		query += ` AND idempotency_key = ?`
		args = append(args, f.IdempotencyKey)
	}
	if f.PlayerID != nil {
		query += ` AND player_id = ?`
		args = append(args, *f.PlayerID)
	}
	spins := []Spin{}
	if err := s.db.SelectContext(ctx, &spins, s.db.Rebind(query+` ORDER BY id`), args...); err != nil {
		return nil, fmt.Errorf("leyendo la bitácora: %w", err)
	}
	return spins, nil
}

func (s *Service) Stock(ctx context.Context) ([]Stock, error) {
	stock := []Stock{}
	if err := s.db.SelectContext(ctx, &stock, `SELECT id, wheel_id, segment_id, remaining FROM stock ORDER BY id`); err != nil {
		return nil, fmt.Errorf("leyendo el stock: %w", err)
	}
	return stock, nil
}

// NaiveSpin es el giro de 2019, reimplementado tal cual: tres viajes a la base,
// sin transacción, y la clave de idempotencia se anota pero nadie la mira.
// 1) leer el stock, 2) decidir, 3) descontar y anotar. Como el giro de medición
// de la Fase 3, siempre cae en la Esclusa de Oro.
//
// 💸 Es el mismo if del mock traducido de lenguaje, y sigue sin proteger nada
// bajo concurrencia. Ahora la deuda está escrita en un lenguaje compilado, que
// es peor porque parece seria. La paga be05 (C-01, C-03).
func (s *Service) NaiveSpin(ctx context.Context, playerID int64, idempotencyKey string) (string, error) {
	if idempotencyKey == "" {
		return "", ErrMissingKey
	}
	var remaining int // viaje 1: leer
	err := s.db.GetContext(ctx, &remaining, s.db.Rebind(`
		SELECT remaining FROM stock WHERE segment_id = ? ORDER BY id LIMIT 1`), GoldenSegment)
	if errors.Is(err, sql.ErrNoRows) || (err == nil && remaining <= 0) {
		return "", ErrSoldOut // decidir, con lo que se leyó
	}
	if err != nil {
		return "", fmt.Errorf("leyendo el stock: %w", err)
	}

	// viaje 2: el descuento, relativo al valor actual; la decisión ya se tomó.
	_, err = s.db.ExecContext(ctx, s.db.Rebind(`
		UPDATE stock SET remaining = remaining - 1
		WHERE id = (SELECT id FROM stock WHERE segment_id = ? ORDER BY id LIMIT 1)`), GoldenSegment)
	if err != nil {
		return "", fmt.Errorf("descontando el stock: %w", err)
	}

	// viaje 3: la bitácora, con la forma pobre de 2019 (sin rueda ni origen).
	_, err = s.db.ExecContext(ctx, s.db.Rebind(`
		INSERT INTO spin_log (player_id, idempotency_key, landed_segment) VALUES (?, ?, ?)`),
		playerID, idempotencyKey, GoldenSegment)
	if err != nil {
		return "", fmt.Errorf("anotando el giro: %w", err)
	}
	return GoldenSegment, nil
}
```

Y los instantes que el mock escribía con `toISOString()` tienen su propio tipo, para que salgan en UTC, con milisegundos y `Z`, por más que la sesión esté en Panamá:

```go
// server/internal/jsontime/jsontime.go

package jsontime

import (
	"database/sql/driver"
	"fmt"
	"time"
)

// ISO es un instante que se serializa como lo hace toISOString() en JavaScript:
// UTC, con milisegundos y "Z" ("2026-08-01T05:00:00.000Z"). Es la forma con
// que el mock guarda createdAt, creditedAt y reconciledAt, y por lo tanto la
// del contrato. closesAt NO usa este tipo: su contrato es con offset (be00).
type ISO struct{ time.Time }

const isoLayout = "2006-01-02T15:04:05.000Z07:00"

func (t ISO) MarshalJSON() ([]byte, error) {
	return []byte(`"` + t.UTC().Format(isoLayout) + `"`), nil
}

func (t *ISO) UnmarshalJSON(b []byte) error {
	parsed, err := time.Parse(`"`+time.RFC3339Nano+`"`, string(b))
	if err != nil {
		return fmt.Errorf("instante inválido %s: %w", b, err)
	}
	t.Time = parsed
	return nil
}

// Scan y Value lo hacen pasar por sqlx como un time.Time. En SQLite, una
// columna con DEFAULT (datetime('now')) llega como texto sin zona, que es UTC:
// la costura de dialecto, otra vez, en el único lugar que la necesita.
func (t *ISO) Scan(src interface{}) error {
	switch v := src.(type) {
	case time.Time:
		t.Time = v
		return nil
	case string:
		return t.parseText(v)
	case []byte:
		return t.parseText(string(v))
	}
	return fmt.Errorf("jsontime.ISO: no sé leer %T", src)
}

func (t *ISO) parseText(s string) error {
	for _, layout := range []string{time.RFC3339Nano, "2006-01-02 15:04:05"} {
		if parsed, err := time.Parse(layout, s); err == nil {
			t.Time = parsed
			return nil
		}
	}
	return fmt.Errorf("jsontime.ISO: instante ilegible %q", s)
}

func (t ISO) Value() (driver.Value, error) { return t.Time, nil }
```

### 5.5 Los services: donde viven las reglas (y donde todavía no protegen)

La rueda: crear con su versión 1, editar publicando una versión nueva cuando cambian los pesos, el `409` en vivo, y los mensajes de la regla de pesos copiados del mock palabra por palabra.

```go
// server/internal/wheel/service.go

package wheel

import (
	"context"
	"errors"
	"fmt"
	"math"
	"strings"
)

// TotalBp es la suma que tienen que dar los pesos de una rueda (D33).
const TotalBp = 10000

// ErrLiveWeights: una rueda en vivo no cambia sus pesos (historia §9).
var ErrLiveWeights = errors.New("La rueda está en vivo: sus pesos no se cambian. Para cambiarlos se publica una versión nueva.")

// ValidationError lleva los mensajes de la regla rota, en español, tal como
// los escribe el mock: la consola los muestra sin traducir (C-04).
type ValidationError struct{ Messages []string }

func (e *ValidationError) Error() string { return strings.Join(e.Messages, " ") }

// SegmentInput es un segmento como llega en el cuerpo. El peso es float64 a
// propósito: el mock acepta 1500.5 y responde 422 con un mensaje; si Go lo
// decodificara como int, respondería 400 al decodificar, y eso es otro contrato.
type SegmentInput struct {
	SegmentID string  `json:"segmentId"`
	PrizeType string  `json:"prizeType"`
	WeightBp  float64 `json:"weightBp"`
}

// ValidateWeights repite la regla de src/features/wheels/weightRules.js y del
// mock: enteros, mayores que cero, que suman 10.000. El servidor no confía en
// lo que validó la consola.
func ValidateWeights(segments []SegmentInput) []string {
	var errs []string
	sum, nonInteger, nonPositive := 0, false, false
	for _, s := range segments {
		if s.WeightBp != math.Trunc(s.WeightBp) {
			nonInteger = true
			continue
		}
		if s.WeightBp < 1 {
			nonPositive = true
		}
		sum += int(s.WeightBp)
	}
	if nonInteger {
		errs = append(errs, "Cada peso debe ser un número entero de puntos básicos.")
	}
	if nonPositive {
		errs = append(errs, "Ningún segmento puede pesar 0 o menos.")
	}
	if sum != TotalBp {
		errs = append(errs, fmt.Sprintf("Los pesos suman %d y deben sumar %d.", sum, TotalBp))
	}
	return errs
}

// Service tiene las reglas de la rueda. No sabe de HTTP: si devolviera un
// status, la capa se habría roto.
type Service struct {
	store Store
}

func NewService(store Store) *Service { return &Service{store: store} }

func (s *Service) List(ctx context.Context) ([]Wheel, error) { return s.store.List(ctx) }

func (s *Service) Find(ctx context.Context, id int64) (Wheel, error) {
	return s.store.FindByID(ctx, id)
}

func (s *Service) Segments(ctx context.Context, wheelID *int64) ([]Segment, error) {
	return s.store.ListSegments(ctx, wheelID)
}

func toSegments(in []SegmentInput) []Segment {
	out := make([]Segment, 0, len(in))
	for _, s := range in {
		out = append(out, Segment{SegmentID: s.SegmentID, PrizeType: s.PrizeType, WeightBp: int(s.WeightBp)})
	}
	return out
}

// weightsKey resume la tabla como la compara el mock: slug y peso, en orden.
func weightsKey(segments []Segment) string {
	parts := make([]string, 0, len(segments))
	for _, s := range segments {
		parts = append(parts, fmt.Sprintf("%s:%d", s.SegmentID, s.WeightBp))
	}
	return strings.Join(parts, "|")
}

// Create da de alta una rueda con su versión 1. Como el mock: borrador y
// zona de Panamá si no vienen.
func (s *Service) Create(ctx context.Context, w Wheel, segments []SegmentInput) (Wheel, error) {
	if errs := ValidateWeights(segments); len(errs) > 0 {
		return Wheel{}, &ValidationError{Messages: errs}
	}
	if w.Status == "" {
		w.Status = "draft"
	}
	if w.Timezone == "" {
		w.Timezone = "America/Panama"
	}
	w.Segments = toSegments(segments)
	return s.store.Create(ctx, w)
}

// Update edita la rueda. Si los pesos cambian, publica una versión nueva; si
// la rueda está en vivo, no los deja cambiar. El orden de los chequeos es el
// del mock: existe, después en vivo, después la suma.
func (s *Service) Update(ctx context.Context, w Wheel, segments []SegmentInput) (Wheel, error) {
	current, err := s.store.FindByID(ctx, w.ID)
	if err != nil {
		return Wheel{}, err
	}
	incoming := toSegments(segments)
	changed := weightsKey(current.Segments) != weightsKey(incoming)
	if current.Status == "live" && changed {
		return Wheel{}, ErrLiveWeights
	}
	if errs := ValidateWeights(segments); len(errs) > 0 {
		return Wheel{}, &ValidationError{Messages: errs}
	}
	if w.Timezone == "" {
		w.Timezone = current.Timezone
	}
	if err := s.store.Update(ctx, w); err != nil {
		return Wheel{}, err
	}
	if changed {
		if err := s.store.AddVersion(ctx, w.ID, incoming); err != nil {
			return Wheel{}, err
		}
	}
	return s.store.FindByID(ctx, w.ID)
}

func (s *Service) Delete(ctx context.Context, id int64) error { return s.store.Delete(ctx, id) }
```

El store de la rueda suma lo que el CRUD de la Fase 4 necesita. La interfaz crece en `wheel.go`:

```go
type Store interface {
	List(ctx context.Context) ([]Wheel, error)
	FindByID(ctx context.Context, id int64) (Wheel, error)
	Create(ctx context.Context, w Wheel) (Wheel, error)
	// be03: lo que el CRUD de la Fase 4 necesita.
	Update(ctx context.Context, w Wheel) error
	AddVersion(ctx context.Context, wheelID int64, segments []Segment) error
	Delete(ctx context.Context, id int64) error
	ListSegments(ctx context.Context, wheelID *int64) ([]Segment, error)
}
```

```go
// Update cambia los datos de la rueda; los pesos no se tocan acá (AddVersion).
func (s *sqlStore) Update(ctx context.Context, w Wheel) error {
	res, err := s.db.ExecContext(ctx, s.db.Rebind(`
		UPDATE wheels SET name = ?, timezone = ?, closes_at = ?, status = ?, updated_at = `+s.db.Now()+`
		WHERE id = ?`), w.Name, w.Timezone, w.ClosesAt, w.Status, w.ID)
	if err != nil {
		return fmt.Errorf("actualizando la rueda %d: %w", w.ID, err)
	}
	if n, _ := res.RowsAffected(); n == 0 {
		return ErrNotFound
	}
	return nil
}

// AddVersion publica la versión siguiente de los pesos, con sus segmentos.
// Las versiones anteriores no se tocan: la bitácora puede seguir citándolas.
func (s *sqlStore) AddVersion(ctx context.Context, wheelID int64, segments []Segment) error {
	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return fmt.Errorf("abriendo la transacción: %w", err)
	}
	defer tx.Rollback()

	var versionID int64
	err = tx.GetContext(ctx, &versionID, tx.Rebind(`
		INSERT INTO wheel_versions (wheel_id, version)
		VALUES (?, (SELECT COALESCE(MAX(version), 0) + 1 FROM wheel_versions WHERE wheel_id = ?))
		RETURNING id`), wheelID, wheelID)
	if err != nil {
		return fmt.Errorf("creando una versión de la rueda %d: %w", wheelID, err)
	}
	for _, seg := range segments {
		_, err = tx.ExecContext(ctx, tx.Rebind(`
			INSERT INTO wheel_segments (wheel_version_id, segment_id, prize_type, weight_bp)
			VALUES (?, ?, ?, ?)`), versionID, seg.SegmentID, seg.PrizeType, seg.WeightBp)
		if err != nil {
			return fmt.Errorf("guardando el segmento %q: %w", seg.SegmentID, err)
		}
	}
	return tx.Commit()
}

// Delete borra la rueda; sus versiones y segmentos se van en cascada. La
// bitácora, el stock y la conciliación se quedan (ver la migración).
func (s *sqlStore) Delete(ctx context.Context, id int64) error {
	res, err := s.db.ExecContext(ctx, s.db.Rebind(`DELETE FROM wheels WHERE id = ?`), id)
	if err != nil {
		return fmt.Errorf("borrando la rueda %d: %w", id, err)
	}
	if n, _ := res.RowsAffected(); n == 0 {
		return ErrNotFound
	}
	return nil
}

// ListSegments devuelve los segmentos de la versión vigente: de una rueda, o
// de todas si wheelID es nil (GET /segments sin filtro, como json-server).
func (s *sqlStore) ListSegments(ctx context.Context, wheelID *int64) ([]Segment, error) {
	query := `
		SELECT s.id, v.wheel_id, s.segment_id, s.prize_type, s.weight_bp
		FROM wheel_segments s
		JOIN wheel_versions v ON v.id = s.wheel_version_id
		WHERE ` + currentVersion
	args := []interface{}{}
	if wheelID != nil {
		query += ` AND v.wheel_id = ?`
		args = append(args, *wheelID)
	}
	segments := []Segment{}
	if err := s.db.SelectContext(ctx, &segments, s.db.Rebind(query+` ORDER BY s.id`), args...); err != nil {
		return nil, fmt.Errorf("listando segmentos: %w", err)
	}
	return segments, nil
}
```

Los jugadores y sus envíos. Fíjate en dos cosas: `name_like` se resuelve en Go y no en SQL, porque ningún `LIKE` de los dos motores honra una expresión regular que no distingue mayúsculas ni tildes (`be02`, Divergencia 6); y `SendGrant` comprueba, espera y anota, como el mock (`C-07`).

```go
// server/internal/player/player.go

package player

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"regexp"
	"time"

	"github.com/interoceanic-games/esclusa-api/internal/jsontime"
	"github.com/interoceanic-games/esclusa-api/internal/storage"
)

type Player struct {
	ID      int64   `json:"id"      db:"id"`
	Name    string  `json:"name"    db:"name"`
	Country *string `json:"country" db:"country"`
	Status  string  `json:"status"  db:"status"`
}

// Grant es un envío manual. Su "id" del contrato es el que generó la consola
// (g-1, g-2…): se repite entre sesiones, y por eso la clave de la tabla es otra.
type Grant struct {
	DBID      int64        `json:"-"         db:"id"`
	GrantID   string       `json:"id"        db:"grant_id"`
	PlayerID  int64        `json:"playerId"  db:"player_id"`
	CaseID    string       `json:"caseId"    db:"case_id"`
	Prize     string       `json:"prize"     db:"prize"`
	Reason    string       `json:"reason"    db:"reason"`
	CreatedAt jsontime.ISO `json:"createdAt" db:"created_at"`
}

var (
	ErrNotFound      = errors.New("no existe el jugador")
	ErrReasonMissing = errors.New("El motivo es obligatorio.")
	ErrCaseGranted   = errors.New("Ese caso ya fue compensado para este jugador.")
)

type Service struct {
	db       *storage.DB
	delivery time.Duration
}

// NewService recibe la demora de entrega del juego (GRANT_DELIVERY_MS).
func NewService(db *storage.DB, delivery time.Duration) *Service {
	return &Service{db: db, delivery: delivery}
}

// Search honra name_like como lo hace json-server: una expresión regular de
// JavaScript con la bandera "i". Ningún LIKE de los dos motores la honra
// (be02, Divergencia 6), así que el filtro se hace acá, igual en los dos, y la
// base devuelve la lista. Una regex inválida es un error, como en el mock.
func (s *Service) Search(ctx context.Context, nameLike string) ([]Player, error) {
	players := []Player{}
	if err := s.db.SelectContext(ctx, &players, `SELECT id, name, country, status FROM players ORDER BY id`); err != nil {
		return nil, fmt.Errorf("listando jugadores: %w", err)
	}
	if nameLike == "" {
		return players, nil
	}
	re, err := regexp.Compile("(?i)" + nameLike)
	if err != nil {
		return nil, fmt.Errorf("name_like inválido: %w", err)
	}
	found := []Player{}
	for _, p := range players {
		if re.MatchString(p.Name) {
			found = append(found, p)
		}
	}
	return found, nil
}

// SendGrant registra la compensación de un jugador al estilo del API de 2019:
// comprueba, espera a que el juego entregue el premio y recién después anota.
// 💸 Dos pedidos del mismo caso que llegan dentro de esa demora pasan los dos:
// es el mismo if del mock, traducido (be00, C-07). La unicidad llega en be05.
func (s *Service) SendGrant(ctx context.Context, g Grant) (Grant, error) {
	if g.Reason == "" {
		return Grant{}, ErrReasonMissing
	}
	var exists int64
	err := s.db.GetContext(ctx, &exists, s.db.Rebind(`SELECT id FROM players WHERE id = ?`), g.PlayerID)
	if errors.Is(err, sql.ErrNoRows) {
		return Grant{}, ErrNotFound
	}
	if err != nil {
		return Grant{}, fmt.Errorf("buscando el jugador %d: %w", g.PlayerID, err)
	}

	var already int // 1) comprobar
	err = s.db.GetContext(ctx, &already, s.db.Rebind(`
		SELECT count(*) FROM grants WHERE player_id = ? AND case_id = ?`), g.PlayerID, g.CaseID)
	if err != nil {
		return Grant{}, fmt.Errorf("buscando el caso %s: %w", g.CaseID, err)
	}
	if already > 0 {
		return Grant{}, ErrCaseGranted
	}

	time.Sleep(s.delivery) // 2) entregar en el juego

	var saved Grant // 3) anotar
	err = s.db.GetContext(ctx, &saved, s.db.Rebind(`
		INSERT INTO grants (grant_id, player_id, case_id, prize, reason)
		VALUES (?, ?, ?, ?, ?)
		RETURNING id, grant_id, player_id, case_id, prize, reason, created_at`),
		g.GrantID, g.PlayerID, g.CaseID, g.Prize, g.Reason)
	if err != nil {
		return Grant{}, fmt.Errorf("registrando el envío %s: %w", g.GrantID, err)
	}
	return saved, nil
}

func (s *Service) Grants(ctx context.Context) ([]Grant, error) {
	grants := []Grant{}
	err := s.db.SelectContext(ctx, &grants, `
		SELECT id, grant_id, player_id, case_id, prize, reason, created_at FROM grants ORDER BY id`)
	if err != nil {
		return nil, fmt.Errorf("listando envíos: %w", err)
	}
	return grants, nil
}
```

Las compras y el catálogo, el login de la vergüenza y la conciliación que guarda lo que llega:

```go
// server/internal/purchase/purchase.go

package purchase

import (
	"context"
	"fmt"

	"github.com/interoceanic-games/esclusa-api/internal/jsontime"
	"github.com/interoceanic-games/esclusa-api/internal/storage"
)

// Purchase es una compra acreditada. El mock no le da id: el contrato tampoco.
type Purchase struct {
	ID            int64        `json:"-"             db:"id"`
	PurchaseToken string       `json:"purchaseToken" db:"purchase_token"`
	ProductID     string       `json:"productId"     db:"product_id"`
	CreditedAt    jsontime.ISO `json:"creditedAt"    db:"credited_at"`
}

type Package struct {
	ProductID         string `json:"productId"         db:"product_id"`
	Spins             int    `json:"spins"             db:"spins"`
	PackagePriceCents int64  `json:"packagePriceCents" db:"package_price_cents"`
}

type Store struct{ db *storage.DB }

func NewStore(db *storage.DB) *Store { return &Store{db: db} }

func (s *Store) Purchases(ctx context.Context) ([]Purchase, error) {
	out := []Purchase{}
	if err := s.db.SelectContext(ctx, &out, `
		SELECT id, purchase_token, product_id, credited_at FROM purchases ORDER BY id`); err != nil {
		return nil, fmt.Errorf("listando compras: %w", err)
	}
	return out, nil
}

func (s *Store) Packages(ctx context.Context) ([]Package, error) {
	out := []Package{}
	if err := s.db.SelectContext(ctx, &out, `
		SELECT product_id, spins, package_price_cents FROM packages ORDER BY product_id`); err != nil {
		return nil, fmt.Errorf("listando paquetes: %w", err)
	}
	return out, nil
}
```

```go
// server/internal/auth/auth.go

package auth

import (
	"context"
	"fmt"

	"github.com/interoceanic-games/esclusa-api/internal/storage"
)

// User es la forma que GET /users devuelve. El campo password viaja porque el
// mock lo devuelve y authService.js lo descarta (be00): quitarlo hoy sería
// cambiar el contrato. Se va en be04, con el resto de la vergüenza.
type User struct {
	ID       int64  `json:"id"       db:"id"`
	Email    string `json:"email"    db:"email"`
	Password string `json:"password" db:"password"`
	Name     string `json:"name"     db:"name"`
	Token    string `json:"token"    db:"token"`
}

type Store struct{ db *storage.DB }

func NewStore(db *storage.DB) *Store { return &Store{db: db} }

// FindByCredentials es el "login" del contrato: filtra por email y password.
// Cero coincidencias es un slice vacío, no un error: el handler responde 200
// con [] y authService.js lo traduce a "Email o contraseña incorrectos".
func (s *Store) FindByCredentials(ctx context.Context, email, password string) ([]User, error) {
	users := []User{}
	err := s.db.SelectContext(ctx, &users, s.db.Rebind(`
		SELECT id, email, password, name, COALESCE(token, '') AS token
		FROM users WHERE email = ? AND password = ?`), email, password)
	if err != nil {
		return nil, fmt.Errorf("buscando credenciales: %w", err)
	}
	return users, nil
}
```

```go
// server/internal/reconciliation/reconciliation.go

package reconciliation

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/interoceanic-games/esclusa-api/internal/jsontime"
	"github.com/interoceanic-games/esclusa-api/internal/storage"
	"github.com/interoceanic-games/esclusa-api/internal/wheel"
)

// Totals es el cruce de compras que calcula la consola (Fase 8).
type Totals struct {
	ChargedCents    int64    `json:"chargedCents"`
	FeeCents        int64    `json:"feeCents"`
	NetCents        int64    `json:"netCents"`
	MissingInAPI    []string `json:"missingInApi"`
	DuplicatedInAPI []string `json:"duplicatedInApi"`
}

// Reconciliation es el registro de una conciliación: el cuerpo que manda
// reconcileWheel, más la rueda y el instante. 💸 El servidor lo guarda tal como
// llega, sin recalcular nada: es lo que hace el mock y lo que el contrato
// obliga a aceptar (be00, C-07). Recalcularlo es crecimiento, y es be07.
type Reconciliation struct {
	Spins        int          `json:"spins"`
	Counts       []int        `json:"counts"`
	Chi2         float64      `json:"chi2"`
	Chi2Alarm    bool         `json:"chi2Alarm"`
	BandAlarms   []string     `json:"bandAlarms"`
	Purchases    Totals       `json:"purchases"`
	WheelID      int64        `json:"wheelId"`
	ReconciledAt jsontime.ISO `json:"reconciledAt"`
}

var (
	ErrWheelNotFound = errors.New("no existe la rueda")
	ErrNotEnded      = errors.New("la rueda no está terminada")
	ErrNotReconciled = errors.New("la rueda no está conciliada")
)

// NotEndedError lleva el estado en que estaba la rueda, para el mensaje.
type NotEndedError struct{ Status string }

func (e *NotEndedError) Error() string {
	return fmt.Sprintf("Solo se concilia una rueda terminada; esta está en %q.", e.Status)
}
func (e *NotEndedError) Unwrap() error { return ErrNotEnded }

type Service struct {
	db     *storage.DB
	wheels wheel.Store
}

func NewService(db *storage.DB, wheels wheel.Store) *Service {
	return &Service{db: db, wheels: wheels}
}

// jsonText guarda listas como JSON: JSONB en Postgres, TEXT en SQLite.
func jsonText(v interface{}) string {
	b, _ := json.Marshal(v)
	return string(b)
}

// Reconcile registra la conciliación y pasa la rueda de ended a reconciled en
// UNA operación: si fueran dos, una caída entre las dos dejaría una rueda
// conciliada sin registro, o un registro de una rueda que sigue abierta.
func (s *Service) Reconcile(ctx context.Context, wheelID int64, r Reconciliation) (wheel.Wheel, Reconciliation, error) {
	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return wheel.Wheel{}, Reconciliation{}, fmt.Errorf("abriendo la transacción: %w", err)
	}
	defer tx.Rollback()

	var status string
	err = tx.GetContext(ctx, &status, tx.Rebind(`SELECT status FROM wheels WHERE id = ?`), wheelID)
	if errors.Is(err, sql.ErrNoRows) {
		return wheel.Wheel{}, Reconciliation{}, ErrWheelNotFound
	}
	if err != nil {
		return wheel.Wheel{}, Reconciliation{}, fmt.Errorf("leyendo la rueda %d: %w", wheelID, err)
	}
	if status != "ended" {
		return wheel.Wheel{}, Reconciliation{}, &NotEndedError{Status: status}
	}

	r.WheelID = wheelID
	err = tx.GetContext(ctx, &r.ReconciledAt, tx.Rebind(`
		INSERT INTO reconciliations
		  (wheel_id, spins, counts, chi2, chi2_alarm, charged_cents, fee_cents, net_cents,
		   band_alarms, missing_in_api, duplicated_in_api)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
		RETURNING reconciled_at`),
		wheelID, r.Spins, jsonText(r.Counts), r.Chi2, r.Chi2Alarm,
		r.Purchases.ChargedCents, r.Purchases.FeeCents, r.Purchases.NetCents,
		jsonText(r.BandAlarms), jsonText(r.Purchases.MissingInAPI), jsonText(r.Purchases.DuplicatedInAPI))
	if err != nil {
		return wheel.Wheel{}, Reconciliation{}, fmt.Errorf("registrando la conciliación de la rueda %d: %w", wheelID, err)
	}
	if _, err := tx.ExecContext(ctx, tx.Rebind(`UPDATE wheels SET status = 'reconciled' WHERE id = ?`), wheelID); err != nil {
		return wheel.Wheel{}, Reconciliation{}, fmt.Errorf("cerrando la rueda %d: %w", wheelID, err)
	}
	if err := tx.Commit(); err != nil {
		return wheel.Wheel{}, Reconciliation{}, fmt.Errorf("confirmando la conciliación: %w", err)
	}
	w, err := s.wheels.FindByID(ctx, wheelID)
	return w, r, err
}

// row es la fila tal como sale de la base, con las listas en JSON.
type row struct {
	WheelID         int64        `db:"wheel_id"`
	Spins           int          `db:"spins"`
	Counts          string       `db:"counts"`
	Chi2            float64      `db:"chi2"`
	Chi2Alarm       bool         `db:"chi2_alarm"`
	ChargedCents    int64        `db:"charged_cents"`
	FeeCents        int64        `db:"fee_cents"`
	NetCents        int64        `db:"net_cents"`
	BandAlarms      string       `db:"band_alarms"`
	MissingInAPI    string       `db:"missing_in_api"`
	DuplicatedInAPI string       `db:"duplicated_in_api"`
	ReconciledAt    jsontime.ISO `db:"reconciled_at"`
}

func (s *Service) Find(ctx context.Context, wheelID int64) (Reconciliation, error) {
	var rw row
	err := s.db.GetContext(ctx, &rw, s.db.Rebind(`
		SELECT wheel_id, spins, CAST(counts AS TEXT) AS counts, chi2, chi2_alarm,
		       charged_cents, fee_cents, net_cents, CAST(band_alarms AS TEXT) AS band_alarms,
		       CAST(missing_in_api AS TEXT) AS missing_in_api,
		       CAST(duplicated_in_api AS TEXT) AS duplicated_in_api, reconciled_at
		FROM reconciliations WHERE wheel_id = ?`), wheelID)
	if errors.Is(err, sql.ErrNoRows) {
		return Reconciliation{}, ErrNotReconciled
	}
	if err != nil {
		return Reconciliation{}, fmt.Errorf("leyendo la conciliación de la rueda %d: %w", wheelID, err)
	}
	r := Reconciliation{WheelID: rw.WheelID, Spins: rw.Spins, Chi2: rw.Chi2, Chi2Alarm: rw.Chi2Alarm,
		Purchases:    Totals{ChargedCents: rw.ChargedCents, FeeCents: rw.FeeCents, NetCents: rw.NetCents},
		ReconciledAt: rw.ReconciledAt}
	json.Unmarshal([]byte(rw.Counts), &r.Counts)
	json.Unmarshal([]byte(rw.BandAlarms), &r.BandAlarms)
	json.Unmarshal([]byte(rw.MissingInAPI), &r.Purchases.MissingInAPI)
	json.Unmarshal([]byte(rw.DuplicatedInAPI), &r.Purchases.DuplicatedInAPI)
	return r, nil
}
```

### 5.6 Los handlers: traducir dominio a HTTP

```go
// server/internal/http/handlers.go

package httpapi

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"

	"github.com/interoceanic-games/esclusa-api/internal/auth"
	"github.com/interoceanic-games/esclusa-api/internal/player"
	"github.com/interoceanic-games/esclusa-api/internal/purchase"
	"github.com/interoceanic-games/esclusa-api/internal/reconciliation"
	"github.com/interoceanic-games/esclusa-api/internal/spin"
	"github.com/interoceanic-games/esclusa-api/internal/wheel"
)

// handlers habla HTTP y nada más: lee la petición, valida la FORMA de la
// entrada, llama al service y traduce lo que vuelve a un status y un JSON.
// Prohibido: tocar la base y decidir reglas de negocio.
type handlers struct {
	users          *auth.Store
	wheels         *wheel.Service
	players        *player.Service
	spins          *spin.Service
	purchases      *purchase.Store
	reconciliation *reconciliation.Service
}

// internalError deja el error real en el log, con el id de la petición, y le
// da al cliente el mensaje genérico. Nunca se filtra el detalle (bea-08).
func internalError(w http.ResponseWriter, r *http.Request, err error) {
	log.Printf("[req-id %s] ERROR en %s %s: %v", RequestIDFrom(r.Context()), r.Method, r.URL.Path, err)
	writeError(w, http.StatusInternalServerError, "Error interno del servidor")
}

// notFoundHandler es el 404 de json-server: cuerpo {}, sin mensaje (C-04).
// Lo usan las rutas que el mock no conoce y los recursos automáticos.
func notFoundHandler(w http.ResponseWriter, r *http.Request) {
	writeEmptyObject(w, http.StatusNotFound)
}

func pathID(r *http.Request) (int64, error) {
	return strconv.ParseInt(mux.Vars(r)["id"], 10, 64)
}

func optionalID(r *http.Request, key string) (*int64, error) {
	v := r.URL.Query().Get(key)
	if v == "" {
		return nil, nil
	}
	id, err := strconv.ParseInt(v, 10, 64)
	return &id, err
}

// GET /users?email=…&password=… — el login del contrato. Cero coincidencias es
// 200 con [], nunca 401: un 401 dispararía el logout global de la Fase 2.
func (h *handlers) listUsers(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	users, err := h.users.FindByCredentials(r.Context(), q.Get("email"), q.Get("password"))
	if err != nil {
		internalError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, users)
}

// wheelOnly es una rueda sin segmentos: lo que devuelve json-server sin _embed.
type wheelOnly struct {
	ID       int64     `json:"id"`
	Name     string    `json:"name"`
	Timezone string    `json:"timezone"`
	ClosesAt time.Time `json:"closesAt"`
	Status   string    `json:"status"`
	Version  int       `json:"wheelVersion"`
}

func withoutSegments(wh wheel.Wheel) wheelOnly {
	return wheelOnly{ID: wh.ID, Name: wh.Name, Timezone: wh.Timezone, ClosesAt: wh.ClosesAt, Status: wh.Status, Version: wh.Version}
}

// GET /wheels y GET /wheels?_embed=segments (C-02: la consola usa el segundo).
func (h *handlers) listWheels(w http.ResponseWriter, r *http.Request) {
	wheels, err := h.wheels.List(r.Context())
	if err != nil {
		internalError(w, r, err)
		return
	}
	if r.URL.Query().Get("_embed") == "segments" {
		writeJSON(w, http.StatusOK, wheels)
		return
	}
	out := make([]wheelOnly, 0, len(wheels))
	for _, wh := range wheels {
		out = append(out, withoutSegments(wh))
	}
	writeJSON(w, http.StatusOK, out)
}

// GET /wheels/:id — recurso automático de json-server: 404 con {}.
func (h *handlers) getWheel(w http.ResponseWriter, r *http.Request) {
	id, _ := pathID(r)
	wh, err := h.wheels.Find(r.Context(), id)
	if errors.Is(err, wheel.ErrNotFound) {
		notFoundHandler(w, r)
		return
	}
	if err != nil {
		internalError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, withoutSegments(wh))
}

// wheelInput es el cuerpo de POST y PUT: la rueda entera con sus segmentos.
type wheelInput struct {
	Name     string               `json:"name"`
	Timezone string               `json:"timezone"`
	ClosesAt time.Time            `json:"closesAt"`
	Status   string               `json:"status"`
	Segments []wheel.SegmentInput `json:"segments"`
}

func (in wheelInput) wheel(id int64) wheel.Wheel {
	return wheel.Wheel{ID: id, Name: in.Name, Timezone: in.Timezone, ClosesAt: in.ClosesAt, Status: in.Status}
}

// writeWheelError traduce los errores de dominio de la rueda. Las rutas
// propias del mock responden 404 CON mensaje, a diferencia de las automáticas.
func writeWheelError(w http.ResponseWriter, r *http.Request, id int64, err error) {
	var invalid *wheel.ValidationError
	switch {
	case errors.Is(err, wheel.ErrNotFound):
		writeError(w, http.StatusNotFound, fmt.Sprintf("No existe la rueda %d.", id))
	case errors.Is(err, wheel.ErrLiveWeights):
		writeError(w, http.StatusConflict, err.Error())
	case errors.As(err, &invalid):
		writeError(w, http.StatusUnprocessableEntity, invalid.Error())
	default:
		internalError(w, r, err)
	}
}

func (h *handlers) createWheel(w http.ResponseWriter, r *http.Request) {
	var in wheelInput
	if err := json.NewDecoder(r.Body).Decode(&in); err != nil {
		writeError(w, http.StatusBadRequest, "Cuerpo inválido: se espera una rueda con sus segmentos.")
		return
	}
	created, err := h.wheels.Create(r.Context(), in.wheel(0), in.Segments)
	if err != nil {
		writeWheelError(w, r, 0, err)
		return
	}
	writeJSON(w, http.StatusCreated, created)
}

func (h *handlers) updateWheel(w http.ResponseWriter, r *http.Request) {
	id, _ := pathID(r)
	var in wheelInput
	if err := json.NewDecoder(r.Body).Decode(&in); err != nil {
		writeError(w, http.StatusBadRequest, "Cuerpo inválido: se espera una rueda con sus segmentos.")
		return
	}
	updated, err := h.wheels.Update(r.Context(), in.wheel(id), in.Segments)
	if err != nil {
		writeWheelError(w, r, id, err)
		return
	}
	writeJSON(w, http.StatusOK, updated)
}

func (h *handlers) deleteWheel(w http.ResponseWriter, r *http.Request) {
	id, _ := pathID(r)
	if err := h.wheels.Delete(r.Context(), id); err != nil {
		writeWheelError(w, r, id, err)
		return
	}
	writeEmptyObject(w, http.StatusOK)
}

// GET /segments?wheelId=… (C-02).
func (h *handlers) listSegments(w http.ResponseWriter, r *http.Request) {
	wheelID, err := optionalID(r, "wheelId")
	if err != nil {
		writeJSON(w, http.StatusOK, []wheel.Segment{}) // json-server: ningún segmento coincide
		return
	}
	segments, err := h.wheels.Segments(r.Context(), wheelID)
	if err != nil {
		internalError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, segments)
}

// GET /players y GET /players?name_like=… (C-02). Sin filtro es lo que pide el
// asistente al abrirse: Query().Get devuelve "" y no entra en pánico.
func (h *handlers) listPlayers(w http.ResponseWriter, r *http.Request) {
	players, err := h.players.Search(r.Context(), r.URL.Query().Get("name_like"))
	if err != nil {
		internalError(w, r, err) // una regex inválida: el mock también responde 500
		return
	}
	writeJSON(w, http.StatusOK, players)
}

// POST /players/:id/grants — el jugador va en la URL, nunca en el cuerpo.
func (h *handlers) sendGrant(w http.ResponseWriter, r *http.Request) {
	id, _ := pathID(r)
	var in struct {
		GrantID string `json:"grantId"`
		CaseID  string `json:"caseId"`
		Prize   string `json:"prize"`
		Reason  string `json:"reason"`
	}
	if err := json.NewDecoder(r.Body).Decode(&in); err != nil {
		writeError(w, http.StatusBadRequest, "Cuerpo inválido.")
		return
	}
	saved, err := h.players.SendGrant(r.Context(), player.Grant{
		GrantID: in.GrantID, PlayerID: id, CaseID: in.CaseID, Prize: in.Prize, Reason: in.Reason,
	})
	switch {
	case errors.Is(err, player.ErrReasonMissing):
		writeError(w, http.StatusUnprocessableEntity, err.Error())
	case errors.Is(err, player.ErrNotFound):
		writeError(w, http.StatusNotFound, fmt.Sprintf("No existe el jugador %d.", id))
	case errors.Is(err, player.ErrCaseGranted):
		writeError(w, http.StatusConflict, err.Error())
	case err != nil:
		internalError(w, r, err)
	default:
		writeJSON(w, http.StatusCreated, saved)
	}
}

func (h *handlers) listGrants(w http.ResponseWriter, r *http.Request) {
	grants, err := h.players.Grants(r.Context())
	if err != nil {
		internalError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, grants)
}

// GET /spinLog — la bitácora entera que pide el filtro, sin paginar (be00).
func (h *handlers) listSpinLog(w http.ResponseWriter, r *http.Request) {
	wheelID, err1 := optionalID(r, "wheelId")
	playerID, err2 := optionalID(r, "playerId")
	if err1 != nil || err2 != nil {
		writeJSON(w, http.StatusOK, []spin.Spin{})
		return
	}
	spins, err := h.spins.Log(r.Context(), spin.Filter{
		WheelID: wheelID, PlayerID: playerID, IdempotencyKey: r.URL.Query().Get("idempotencyKey"),
	})
	if err != nil {
		internalError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, spins)
}

func (h *handlers) listStock(w http.ResponseWriter, r *http.Request) {
	stock, err := h.spins.Stock(r.Context())
	if err != nil {
		internalError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, stock)
}

// POST /players/:id/spins — el contrato del juego (C-01).
func (h *handlers) naiveSpin(w http.ResponseWriter, r *http.Request) {
	id, _ := pathID(r)
	var in struct {
		IdempotencyKey string `json:"idempotencyKey"`
	}
	json.NewDecoder(r.Body).Decode(&in) // un cuerpo vacío es una clave vacía: 400
	landed, err := h.spins.NaiveSpin(r.Context(), id, in.IdempotencyKey)
	switch {
	case errors.Is(err, spin.ErrMissingKey):
		writeError(w, http.StatusBadRequest, err.Error())
	case errors.Is(err, spin.ErrSoldOut):
		writeError(w, http.StatusConflict, err.Error())
	case err != nil:
		internalError(w, r, err)
	default:
		writeJSON(w, http.StatusOK, map[string]string{"landedSegment": landed})
	}
}

func (h *handlers) listPurchases(w http.ResponseWriter, r *http.Request) {
	purchases, err := h.purchases.Purchases(r.Context())
	if err != nil {
		internalError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, purchases)
}

func (h *handlers) listPackages(w http.ResponseWriter, r *http.Request) {
	packages, err := h.purchases.Packages(r.Context())
	if err != nil {
		internalError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, packages)
}

// POST /wheels/:id/reconciliation — guarda lo que calculó la consola (C-07).
func (h *handlers) reconcileWheel(w http.ResponseWriter, r *http.Request) {
	id, _ := pathID(r)
	var in reconciliation.Reconciliation
	if err := json.NewDecoder(r.Body).Decode(&in); err != nil {
		writeError(w, http.StatusBadRequest, "Cuerpo inválido.")
		return
	}
	wh, saved, err := h.reconciliation.Reconcile(r.Context(), id, in)
	var notEnded *reconciliation.NotEndedError
	switch {
	case errors.Is(err, reconciliation.ErrWheelNotFound):
		writeError(w, http.StatusNotFound, fmt.Sprintf("No existe la rueda %d.", id))
	case errors.As(err, &notEnded):
		writeError(w, http.StatusConflict, notEnded.Error())
	case err != nil:
		internalError(w, r, err)
	default:
		writeJSON(w, http.StatusCreated, map[string]interface{}{"wheel": withoutSegments(wh), "reconciliation": saved})
	}
}

func (h *handlers) getReconciliation(w http.ResponseWriter, r *http.Request) {
	id, _ := pathID(r)
	rec, err := h.reconciliation.Find(r.Context(), id)
	if errors.Is(err, reconciliation.ErrNotReconciled) {
		writeError(w, http.StatusNotFound, fmt.Sprintf("La rueda %d no está conciliada.", id))
		return
	}
	if err != nil {
		internalError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, rec)
}
```

### 5.7 El router completo, y el arranque

```go
// server/internal/http/router.go

package httpapi

import (
	"net/http"
	"time"

	"github.com/gorilla/mux"

	"github.com/interoceanic-games/esclusa-api/internal/auth"
	"github.com/interoceanic-games/esclusa-api/internal/player"
	"github.com/interoceanic-games/esclusa-api/internal/purchase"
	"github.com/interoceanic-games/esclusa-api/internal/reconciliation"
	"github.com/interoceanic-games/esclusa-api/internal/spin"
	"github.com/interoceanic-games/esclusa-api/internal/storage"
	"github.com/interoceanic-games/esclusa-api/internal/wheel"
)

// Config es lo que el router necesita del exterior. Lo arma main.go desde la
// configuración validada (internal/config) y el pool ya abierto.
type Config struct {
	AllowedOrigin string
	ChaosLevel    string
	ChaosSeed     int64
	DB            *storage.DB
	GrantDelivery time.Duration
}

// NewRouter arma la aplicación completa: las rutas y la cebolla de
// middlewares que las envuelve.
func NewRouter(cfg Config) http.Handler {
	chaos := NewChaosController(cfg.ChaosLevel, cfg.ChaosSeed)

	r := mux.NewRouter()

	// GET /health: NO está en el contrato de be00 —la consola no lo
	// consume— así que pertenece al régimen de crecimiento. Lo usan el
	// compose de bea-02 y el pipeline de be09. Desde be02 mira la base.
	r.HandleFunc("/health", healthHandler(cfg.DB)).Methods(http.MethodGet)

	// POST /_chaos: andamiaje del curso, declarado como tal. Ningún
	// backend de producción trae un endpoint para romperse a sí mismo.
	r.HandleFunc("/_chaos", chaosHandler(chaos)).Methods(http.MethodPost)

	// El régimen estricto de server/CONTRACT.md, recurso por recurso. Las
	// capas se arman acá: store → service → handler.
	wheels := wheel.NewStore(cfg.DB)
	h := &handlers{
		users:          auth.NewStore(cfg.DB),
		wheels:         wheel.NewService(wheels),
		players:        player.NewService(cfg.DB, cfg.GrantDelivery),
		spins:          spin.NewService(cfg.DB),
		purchases:      purchase.NewStore(cfg.DB),
		reconciliation: reconciliation.NewService(cfg.DB, wheels),
	}
	r.HandleFunc("/users", h.listUsers).Methods(http.MethodGet)
	r.HandleFunc("/wheels", h.listWheels).Methods(http.MethodGet)
	r.HandleFunc("/wheels", h.createWheel).Methods(http.MethodPost)
	r.HandleFunc("/wheels/{id:[0-9]+}", h.getWheel).Methods(http.MethodGet)
	r.HandleFunc("/wheels/{id:[0-9]+}", h.updateWheel).Methods(http.MethodPut)
	r.HandleFunc("/wheels/{id:[0-9]+}", h.deleteWheel).Methods(http.MethodDelete)
	r.HandleFunc("/wheels/{id:[0-9]+}/reconciliation", h.reconcileWheel).Methods(http.MethodPost)
	r.HandleFunc("/wheels/{id:[0-9]+}/reconciliation", h.getReconciliation).Methods(http.MethodGet)
	r.HandleFunc("/segments", h.listSegments).Methods(http.MethodGet)
	r.HandleFunc("/players", h.listPlayers).Methods(http.MethodGet)
	r.HandleFunc("/players/{id:[0-9]+}/grants", h.sendGrant).Methods(http.MethodPost)
	r.HandleFunc("/players/{id:[0-9]+}/spins", h.naiveSpin).Methods(http.MethodPost)
	r.HandleFunc("/grants", h.listGrants).Methods(http.MethodGet)
	r.HandleFunc("/spinLog", h.listSpinLog).Methods(http.MethodGet)
	r.HandleFunc("/stock", h.listStock).Methods(http.MethodGet)
	r.HandleFunc("/purchases", h.listPurchases).Methods(http.MethodGet)
	r.HandleFunc("/packages", h.listPackages).Methods(http.MethodGet)

	// Lo que nadie conoce responde como json-server: 404 con {} (C-04). Sin
	// esto, mux contesta "404 page not found" en texto, y eso no es JSON.
	r.NotFoundHandler = http.HandlerFunc(notFoundHandler)

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
```

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

	"github.com/interoceanic-games/esclusa-api/internal/config"
	httpapi "github.com/interoceanic-games/esclusa-api/internal/http"
	"github.com/interoceanic-games/esclusa-api/internal/storage"
)

func main() {
	// La configuración se lee y se valida ANTES de cualquier otra cosa: si
	// falta DATABASE_URL, el proceso muere acá, en el segundo cero, con un
	// mensaje que dice qué falta. La deuda de os.Getenv de be01 se pagó.
	cfg, err := config.Load()
	if err != nil {
		log.Fatal(err)
	}

	// El pool se abre una vez y se comparte. Si la base no responde al
	// arrancar, se muere acá, con un mensaje que dice por qué.
	db, err := storage.Open(context.Background(), cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("no se pudo abrir la base: %v", err)
	}
	defer db.Close()

	handler := httpapi.NewRouter(httpapi.Config{
		AllowedOrigin: cfg.AllowedOrigin,
		ChaosLevel:    cfg.ChaosLevel, // apagado por defecto (D22)
		ChaosSeed:     cfg.ChaosSeed,
		DB:            db,
		GrantDelivery: time.Duration(cfg.GrantDeliveryMs) * time.Millisecond,
	})

	// Desde esta fase el default es el 3001: el binario ES el backend (D21).
	addr := ":" + cfg.Port
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
		log.Printf("esclusa-api escuchando en %s", addr)
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

> 🧭 **La zona de la sesión va en el DSN.** `closesAt` tiene que salir con `-05:00` (verificación 3 de `smoke.sh`), y Postgres lo devuelve en la zona de la sesión. `lib/pq` pasa a la sesión cualquier parámetro del DSN que no sea suyo, así que basta con agregarlo: `DATABASE_URL="postgres://esclusa:esclusa@localhost:5432/esclusa?sslmode=disable&timezone=America/Panama"`. Medido: sin el parámetro, `SHOW TimeZone` dice `Etc/UTC`; con él, `America/Panama`. Por qué es la sesión y no el proceso quien decide esto es `be06`.

Y las pruebas del service, que corren en los dos motores igual que las de `be02` (Postgres siempre en `esclusa_test`):

```go
// server/internal/wheel/service_test.go

package wheel_test

import (
	"context"
	"errors"
	"reflect"
	"testing"
	"time"

	"github.com/interoceanic-games/esclusa-api/internal/wheel"
)

func inputs(w wheel.Wheel) []wheel.SegmentInput {
	out := []wheel.SegmentInput{}
	for _, s := range w.Segments {
		out = append(out, wheel.SegmentInput{SegmentID: s.SegmentID, PrizeType: s.PrizeType, WeightBp: float64(s.WeightBp)})
	}
	return out
}

// Los mensajes son los del mock, palabra por palabra: la consola los muestra tal cual.
func TestValidateWeightsSpeaksLikeTheMock(t *testing.T) {
	cases := map[string]struct {
		weights []float64
		want    []string
	}{
		"suma 9.999":  {[]float64{4999, 5000}, []string{"Los pesos suman 9999 y deben sumar 10000."}},
		"suma 10.001": {[]float64{5001, 5000}, []string{"Los pesos suman 10001 y deben sumar 10000."}},
		"cero":        {[]float64{0, 10000}, []string{"Ningún segmento puede pesar 0 o menos."}},
		"decimal": {[]float64{4999.5, 5000.5}, []string{
			"Cada peso debe ser un número entero de puntos básicos.", "Los pesos suman 0 y deben sumar 10000."}},
		"válida": {[]float64{5000, 5000}, nil},
	}
	for name, c := range cases {
		var in []wheel.SegmentInput
		for _, w := range c.weights {
			in = append(in, wheel.SegmentInput{WeightBp: w})
		}
		if got := wheel.ValidateWeights(in); !reflect.DeepEqual(got, c.want) {
			t.Errorf("%s: %q, se esperaba %q", name, got, c.want)
		}
	}
}

func TestChangingWeightsPublishesANewVersion(t *testing.T) {
	ctx := context.Background()
	svc := wheel.NewService(wheel.NewStore(openTestDB(t)))
	closesAt, _ := time.Parse(time.RFC3339, "2030-12-20T20:00:00-05:00")
	golden := goldenWheel(closesAt)

	created, err := svc.Create(ctx, wheel.Wheel{Name: golden.Name, ClosesAt: closesAt}, inputs(golden))
	if err != nil {
		t.Fatal(err)
	}
	renamed := created
	renamed.Name = "Esclusa de Oro (2)"
	same, err := svc.Update(ctx, renamed, inputs(golden))
	if err != nil || same.Version != 1 {
		t.Fatalf("cambiar el nombre no publica versión: versión=%d err=%v", same.Version, err)
	}

	changed := inputs(golden)
	changed[0].WeightBp, changed[1].WeightBp = 2999, 2001
	v2, err := svc.Update(ctx, renamed, changed)
	if err != nil || v2.Version != 2 || v2.Segments[0].WeightBp != 2999 {
		t.Fatalf("cambiar pesos publica la versión 2: %+v err=%v", v2, err)
	}

	live := v2
	live.Status = "live"
	if _, err := svc.Update(ctx, live, changed); err != nil {
		t.Fatal(err)
	}
	if _, err := svc.Update(ctx, live, inputs(golden)); !errors.Is(err, wheel.ErrLiveWeights) {
		t.Fatalf("en vivo, cambiar pesos tiene que dar ErrLiveWeights: %v", err)
	}
}
```

### 5.8 🪦 El momento

Todo lo anterior fue para esto. Sigue los pasos en orden y **no te saltes el primero**, que es el que hace que el reemplazo sea reversible.

```bash
# 1. Red de seguridad: el estado exacto de tus datos antes de tocar nada.
cp mock/db.json mock/db.json.antes-del-reemplazo
git add -A && git commit -m "be03: checkpoint antes del reemplazo"

# 2. Base limpia, migrada y sembrada desde TU db.json, con la zona en el DSN.
cd server
export DATABASE_URL="postgres://esclusa:esclusa@localhost:5432/esclusa?sslmode=disable&timezone=America/Panama"
migrate -path migrations/postgres -database "$DATABASE_URL" up
go run ./cmd/seed -file ../mock/db.json

# 3. 🪦 Se apaga el mock del 3001. Sin red.
#    El 3002 de Google Play SIGUE VIVO: es un tercero y no se toca.
#    (Ctrl+C en la terminal de npm run mock:all, y después npm run mock:googleplay)
lsof -i :3001    # tiene que estar libre

# 4. Se levanta el binario en el 3001. El mismo puerto. Ese es el punto.
go run ./cmd/api

# 5. El criterio de aprobación, sin modificar una línea desde be00.
cd .. && ./server/smoke.sh
```

Corrida del 19/10/2026: `Contrato OK.`, diecisiete de diecisiete. Y entonces, el recorrido. **El mismo de `be00`**, paso por paso, con Network abierto: login, listar, crear, editar y borrar una rueda, abrir el asistente, buscar, compensar, el `409` del caso repetido, consultar una compra, conciliar la Rueda de fin de mes, el tablero, cerrar sesión.

Medido con el recorrido automatizado de `be00` contra los dos servidores: las mismas peticiones, con los mismos status, y dos diferencias que son de crecimiento y no de contrato. Una: Go no manda `ETag`, así que las lecturas repetidas son `200` y nunca `304`. La otra: el `PUT` de la consola lleva un campo `wheelVersion`, porque devuelve la rueda que recibió, y Go lo ignora. Las lecturas del contrato comparadas campo por campo con el mock son idénticas, salvo `wheelVersion`; y una secuencia de veintitrés escrituras —altas, pesos que no suman, decimales, versiones, `409` en vivo, borrados, envíos, giros, conciliaciones— da los mismos status y los mismos cuerpos en los dos.

> 🧭 **El criterio, en una frase que se puede decir en voz alta:** *"apagué el mock, levanté mi binario, y la consola no se enteró."*
>
> Si algo se comporta distinto, **el que está mal es el backend**. No el frontend, no el contrato, no "es que json-server hacía algo raro". El backend. Vuelve a `server/CONTRACT.md`, encuentra en qué punto te desviaste, y corrígelo ahí.

Cuando pase, escríbelo. Un párrafo en `server/CONTRACT.md` con la fecha, qué recorriste y qué falló en el camino antes de quedar en verde. Ese párrafo es el retiro formal del mock del `3001`, y en seis meses va a ser el documento que explique por qué el `3001` responde lo que responde.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. La secuencia que se quedó atrás.** Síntoma: la siembra funciona, la consola lista las ruedas perfecto, y la primera alta devuelve `500`; en el log, `pq: duplicate key value violates unique constraint "wheels_pkey"`. Causa: insertar ids explícitos no mueve la secuencia de `BIGSERIAL`; el `nextval` sigue en 1. Fix: el `setval` de `fixSequences`. Es el error más frecuente de la fase y no tiene nada que ver con tu código.

**2. `time.Time` que vuelve en otro huso.** Síntoma: `closesAt` sale `2031-01-01T01:00:00Z` donde el mock devolvía `2030-12-31T20:00:00-05:00`, y la verificación 3 de `smoke.sh` falla. Causa: `TIMESTAMPTZ` guarda el instante y lo devuelve en la zona de la **sesión**, que por defecto es la del servidor de base (`Etc/UTC` en `postgres:13`). Fix mínimo: `timezone=America/Panama` en el DSN. Corrección frente a refactorización: la línea del DSN es la corrección; decidir de quién es la autoridad temporal es `be06`, y es una conversación entera.

**3. Campos en minúscula.** Síntoma: al objeto le falta justo un campo, sin error, sin aviso. Causa: `encoding/json` solo serializa campos exportados. Fix: mayúscula inicial. Cuesta cinco minutos encontrarlo la primera vez y treinta segundos la segunda.

**4. Uniformar los `404`.** Síntoma: `toReadableError` empieza a mostrar mensajes que nadie escribió, o deja de mostrar los que sí. Causa: alguien —con toda la razón del mundo— hizo que todos los `404` devolvieran `{ "error": … }`, o que ninguno lo hiciera. Fix: volver a `C-04`. Es la mejora razonable que rompe un cliente, y por eso `be00` la registró como trampa.

**5. Validar más de lo que validaba el mock.** Síntoma: una alta que antes iba bien devuelve `400` o `422`. Causa: agregaste validación de negocio en el `POST /wheels`. Fix: quitarla. Validar más es **romper el contrato**: el régimen de crecimiento admite validaciones más permisivas, nunca más estrictas. Hay una sola excepción en esta fase, y está declarada: el mock acepta `"closesAt": "mañana"` y lo guarda tal cual; Go responde `400`, porque `TIMESTAMPTZ` no puede guardar algo que no es un instante. El formulario de la Fase 4 pide el texto con su ejemplo, y en el recorrido no aparece; anótalo en `CONTRACT.md` como desvío deliberado.

**6. `name_like` con `LIKE`.** Síntoma: la búsqueda de jugadores funciona en las pruebas con SQLite y en la consola no encuentra a "Ángela" cuando escribes "ángela", o al revés. Causa: la Divergencia 6 de `be02`. Fix: el filtro con `regexp` y `(?i)`, igual en los dos motores. Y si el operador escribe `(`, el mock responde `500` con el `SyntaxError` de la expresión regular, y Go, un `500` con su mensaje genérico: el mismo contrato.

### 🩻 Pieza forense de esta fase

**La discrepancia que encuentra el frontend y no encuentra ningún test.**

Es la forma real en que aparecen estos bugs, y por eso la fase la provoca a propósito. Tus pruebas de `be02` pasan. `go vet` está limpio. `curl` devuelve algo que se ve perfecto. Y la consola se comporta raro.

*Caso A — el objeto que debía ser un texto.* Cambia `Origin *string` por `sql.NullString` en `spin.Spin` y abre el tablero de la Rueda de fin de mes.

1. Anota qué devuelve `curl localhost:3001/spinLog?wheelId=4 | jq '.[0].origin'`. Vas a ver `{"String":"free","Valid":true}`, y te va a parecer obvio **ahora que lo buscas**.
2. Anota qué se ve en la consola. Medido: la tarjeta de giros dice *10000 · 10000 gratis · 0 pagos*, al lado de unos ingresos netos de US$135,60. **Sin un solo error en consola.**
3. Escribe la prueba de Go que lo habría atrapado. Pista incómoda: una prueba que compare structs **no lo atrapa nunca**, porque el problema no está en los datos sino en la serialización. Hay que comparar el **JSON** contra la respuesta que daba el mock.
4. Vuelve al puntero y confirma que el JSON queda idéntico al del mock.

*Caso B — los tres campos que se pierden en silencio.* Deshaz la migración `000003` (`migrate down 1`), quita del `INSERT` de `Reconcile` las tres columnas, y concilia la Rueda de fin de mes desde la consola.

1. El `POST /wheels/4/reconciliation` devuelve `201`. La consola festeja. La rueda pasa a conciliada. Todo verde.
2. Ahora `GET /wheels/4/reconciliation` y compara con el cuerpo que viajó, que tienes en Network. Medido: la consola mandó `missingInApi: ["tok-ago-31"]` y `duplicatedInApi: ["tok-ago-17"]`, los dos descuadres de agosto; lo guardado dice `[]` y `[]`.
3. **Nadie se entera.** La pantalla de conciliación no vuelve a leer el registro. El dato se perdió el día que se guardó, y el síntoma va a aparecer dentro de meses, cuando alguien pregunte qué compras no cuadraban en agosto.
4. Vuelve a aplicar la migración y escribe, en tres líneas, qué prueba habría detectado esto. Después responde la pregunta difícil: ¿esa prueba la habrías escrito?

*El contraste que hay que anotar.* El Caso A es ruidoso: rompe algo visible y se encuentra en veinte minutos. El Caso B es silencioso: no rompe nada, no lo encuentra ningún test, y cuesta muchísimo más caro. **Los bugs de contrato que duelen no son los que fallan: son los que pasan.**

*Rompe a propósito, bonus.* Con el binario corriendo, quita un campo de una respuesta —`segmentId` de `wheel.Segment`, por ejemplo— y recorre la consola. Cronometra cuánto tardas en encontrar la causa **sin** mirar el código del backend, solo con DevTools. Ese cronómetro es la medida de lo que vale un contrato escrito.

---

> 📓🔥 De esta fase salen los incidentes **be-06** y **be-07** de `cuaderno-incidentes-be.md`, los dos sobre lo mismo desde ángulos opuestos: un campo que cambió de forma y un campo que se perdió en silencio. Y desde acá se reproducen **be-04** y **be-05**, que nacieron en el código de `be02` y recién se ven cuando la consola lee del binario.

---

## 🧪 7. Ejercicios (33)

**🟢 Fácil (1–8)**

1. Arranca el binario sin `DATABASE_URL` y comprueba que muere en el segundo cero con un mensaje que dice qué falta.
2. Siembra dos veces seguidas y verifica con `psql` que no hay filas duplicadas en `wheels`, `players` ni `spin_log`.
3. Comprueba con `curl` que `GET /wheels/1` y `GET /wheels/9999` responden lo mismo que respondían contra el mock.
4. Corre `server/smoke.sh` contra el binario en el `3001` y pega la salida en `CONTRACT.md`.
5. Comprueba que `GET /players?name_like=ANA` encuentra a "Ana" y a "Anaís", como en el mock.
6. Verifica que el mock de Google Play sigue respondiendo en el `3002` con el `3001` en manos de Go.
7. Abre el tablero de la Rueda de fin de mes y confirma que muestra los mismos cuatro números que con el mock.
8. Comprueba con `psql` que el `PUT` que cambia pesos de una rueda en borrador crea la versión 2 en `wheel_versions`.

**🟡 Intermedio (9–18)**

9. **Diagnóstico.** Quita `fixSequences` de la siembra, siembra en una base limpia y crea una rueda. Encuentra el error en el log, explica por qué pasa y por qué no pasa con SQLite.
10. **Diagnóstico.** Quita `timezone=America/Panama` del DSN y corre `smoke.sh`. Encuentra qué verificación falla y qué ve el operador en la tabla de ruedas.
11. Escribe una prueba de Go que compare el JSON de `GET /spinLog?wheelId=4` contra un archivo con la respuesta del mock, byte a byte después de normalizar.
12. **Diagnóstico.** Cambia el tipo de `Segment.WeightBp` a `float64` y mira qué ve `WheelForm`. ¿Rompe algo? Explica por qué sí o por qué no.
13. Agrega `GET /stock/:id` como crecimiento, con su `404` de json-server, y escribe en `CONTRACT.md` por qué no rompe a nadie.
14. **Diagnóstico.** Manda a `PUT /wheels/1` un cuerpo con `"weightBp": "1500"` (texto) y compara qué responde el mock y qué responde Go. Decide si la diferencia es contrato.
15. Mide con `curl -w` el tiempo de `GET /spinLog?wheelId=4` contra el mock y contra Go, cinco veces cada uno. Explica la diferencia.
16. Siembra la Semana del Canal con `--event` (Fase 9), vuelve a sembrar Go y mide `GET /spinLog` de esa rueda: bytes, tiempo y memoria del proceso.
17. **Diagnóstico.** Busca `(` en el asistente de envíos contra el mock y contra Go. Compara lo que ve el operador en los dos casos y decide si es la misma respuesta.
18. Escribe en `CONTRACT.md` el párrafo del retiro del mock: fecha, recorrido y lo que falló antes de quedar en verde.

**🟠 Difícil (19–27)**

19. **Diagnóstico.** Ejecuta el Caso A de la pieza forense y escribe la prueba que compara el JSON contra el del mock. Muestra que falla con `sql.NullString` y pasa con el puntero.
20. **Diagnóstico.** Ejecuta el Caso B y escribe la prueba que lo habría detectado. Justifica en qué capa vive.
21. Implementa `name_like` en SQL para Postgres con el operador `~*` y compara con la versión en Go: qué expresiones dan distinto, y qué gana y qué pierde cada una.
22. Mide qué pasa con dos `POST /players/42/grants` del mismo caso lanzados a la vez contra Go. Compáralo con el `C-07` medido contra el mock en `be00`.
23. **Diagnóstico.** Mide el `C-01` contra Go: la misma clave de giro dos veces a la vez, y mil quinientos giros con el generador de la Fase 3. Compara las cifras con las del mock y explica por qué no son iguales aunque el código haga lo mismo.
24. Diseña la prueba de contrato en Go que reemplazaría a `smoke.sh` en `be08`, con una tabla de casos. No la escribas entera: escribe su esqueleto y tres casos.
25. **Diagnóstico.** Apaga Postgres con la consola abierta y recorre las pantallas. Compara con el inventario de síntomas que levantaste en `be00` con el mock caído.
26. Argumenta por escrito si `GET /spinLog` debería paginar. Escribe qué tendría que cambiar en la Fase 9 primero, y qué régimen del contrato toca.
27. Agrega al `logging` el número de filas que devolvió cada lectura de la bitácora, y úsalo para encontrar la pantalla que más filas pide.

**🔴 Muy difícil (28–33)**

28. **Diagnóstico.** Recorre la consola con el caos en `high` contra el mock y contra Go, y compara los síntomas. ¿Son los mismos? Si no, encuentra la diferencia en `chaos.go`.
29. Reescribe el giro de 2019 para que escriba la fila completa de la bitácora sin cambiar su respuesta. Mide si el tablero cambia y decide si eso es un arreglo de contrato o de crecimiento. (No lo dejes en la rama principal: es `be05`.)
30. Escribe la estrategia de corte para producción: cómo pasarías del API heredado de Node a este binario con el juego y la consola en vivo, sin ventana de mantenimiento. Incluye cómo volver atrás.
31. **Diagnóstico + regresión.** Ticket: *"desde el cambio de servidor, la conciliación de agosto no dice qué compras faltan"*. Reconstruye la causa sin mirar este documento, escribe la prueba de regresión y el mensaje a la contadora.
32. Argumenta si el servidor debería empezar a recalcular la conciliación ya, en esta fase, o esperar a `be07`. Defiende las dos posturas con el criterio del reemplazo verificable.
33. **Post-mortem.** Escribe el post-mortem del Caso B como si hubiera ocurrido en producción, según los ocho puntos del post-mortem de `cuaderno-incidentes.md`. Sin culpabilización.

**🔥 Opcionales**

- 🔥 Agrega `ETag` a `GET /spinLog` y mide cuánto ahorra con el tablero abierto. Decide si es crecimiento.
- 🔥 Implementa `_page` y `_limit` en `GET /spinLog` y comprueba que la consola no se entera. Mira qué pasa con `Access-Control-Expose-Headers` (la rareza de `C-02`).
- 🔥 Reescribe la siembra con `COPY` de Postgres y compara tiempos con la de lotes de 500 filas.

---

## 📚 8. Referencias

**Documentación oficial**
- https://github.com/kelseyhightower/envconfig — la etiqueta `required`, los valores por defecto y los tipos que entiende (`time.Duration` incluido).
- https://pkg.go.dev/encoding/json — la sección sobre `omitempty` y sobre qué campos se serializan.
- https://pkg.go.dev/database/sql#NullString — el tipo de la pieza forense, con su forma exportada.
- https://pkg.go.dev/github.com/lib/pq — los parámetros del DSN y cómo pasa a la sesión los que no son suyos.
- https://www.postgresql.org/docs/13/functions-sequence.html — `setval` y `pg_get_serial_sequence`.
- https://github.com/gorilla/mux — `NotFoundHandler` y las variables de ruta con expresión regular.

**Libros**
- *Working Effectively with Legacy Code* (Michael Feathers) — la idea de "costura" y de reemplazar sin que el resto se entere es suya.
- *Monolith to Microservices* (Sam Newman) — el patrón *strangler fig*, que es lo que esta fase hace con un solo servicio.

**Video / apoyo**
- Busca "strangler fig pattern" y "Go json omitempty pointer" en YouTube.

**Orden de lectura sugerido:** la documentación de `encoding/json` sobre `omitempty` primero —es corta y es la pieza forense— → la de `envconfig` → el capítulo de costuras de Feathers, cuando el reemplazo ya esté en verde.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las referencias a libros son de memoria y pueden ser inexactas. Cualquier discrepancia de versiones la resuelve `00-decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

El mock del `3001` ya no existe para la consola. Lo que contesta es tu binario, con tus datos, en el mismo puerto, y la consola no se enteró: diecisiete verificaciones en verde, el mismo recorrido con las mismas peticiones, las mismas respuestas campo por campo. Con él se fueron el `db.json` como almacén y la configuración sin validar.

Lo que no se fue, porque no tenía que irse todavía, está escrito en `CONTRACT.md` con su fase: el login por query string con su token de mentira, el giro que decide con lo que leyó antes, el caso que se compensa dos veces, la conciliación que el servidor no verifica. `be04` cobra el primero: contraseñas con `bcrypt`, un JWT firmado en el mismo campo `token`, la identidad que sale del token y no del cuerpo, y una librería de JWT que se adopta y se abandona en la misma fase.

> **La señal de que quedó bien:** *"apagué el mock, levanté mi binario, y la consola no se enteró; y puedo señalar en `CONTRACT.md` cada deuda que reimplementé a propósito."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be03-crud-y-el-reemplazo -m "be03 cerrada: \
> configuración validada con envconfig; migraciones 000002 y 000003; \
> siembra idempotente desde mock/db.json; régimen estricto de CONTRACT.md en capas; \
> las dos formas de 404 (C-04); mock del 3001 apagado y binario en el 3001; \
> smoke.sh 17/17 contra Go; recorrido de be00 repetido sin diferencias visibles"
> ```
>
> Los commits de la fase llevan su prefijo (`be03: …`) y los de ejercicio su número (`be03 ej19: …`). Si un ejercicio merece su propio marcador va en `ej/be03/19`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` / `-fix`, con el ID que le reserva `cuaderno-incidentes-be.md`. Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **El retiro del mock queda escrito en `CONTRACT.md`**, con fecha. Que `be08` lo use como línea base de su suite de contrato.
- **Deudas reimplementadas a propósito, con su fase:** el giro sin idempotencia y con el stock descontado después (`C-01`, `be05`); la fila pobre de la bitácora (`C-03`, `be05`); el chequeo de caso del envío no atómico (`C-07`, `be05`); la conciliación guardada sin verificar (`C-07`, `be07`); el token de mentira en una columna (`be04`).
- **Desvío deliberado del contrato:** `closesAt` que no es un instante responde `400` (el mock lo guarda). Va a `CONTRACT.md` y a `bea-09`.
- **`be06` hereda la zona de la sesión en el DSN** como corrección mínima, y la decide como autoridad (D29).
- **Reserva para el cuaderno de incidentes:** `be-06` — *"el tablero dice que nadie compró giros"* (🔥 contrato, 🟠), el Caso A; y `be-07` — *"faltan datos en las conciliaciones"* (🔥 contrato, 🔴), el Caso B. `be-04` y `be-05` (de `be02`) se reproducen desde el tag de esta fase.
