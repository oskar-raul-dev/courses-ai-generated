package wheel_test

// Las divergencias de be02 §6, medidas en los dos motores. Copia descartable.
import (
	"context"
	"fmt"
	"os"
	"testing"

	"github.com/interoceanic-games/esclusa-api/internal/storage"
)

func engines(t *testing.T) map[string]*storage.DB {
	out := map[string]*storage.DB{}
	for name, url := range map[string]string{
		"sqlite":   "file::memory:?cache=shared&_foreign_keys=on&_busy_timeout=5000",
		"postgres": os.Getenv("PG_URL"),
	} {
		db, err := storage.Open(context.Background(), url)
		if err != nil { t.Fatal(err) }
		applyMigrations(t, db)
		out[name] = db
	}
	return out
}

func try(db *storage.DB, q string, args ...interface{}) string {
	rows, err := db.Queryx(db.Rebind(q), args...)
	if err != nil { return "ERROR: " + err.Error() }
	defer rows.Close()
	res := ""
	for rows.Next() {
		vals, _ := rows.SliceScan()
		for _, v := range vals {
			if b, ok := v.([]byte); ok { v = string(b) }
			res += fmt.Sprintf("%v ", v)
		}
		res += "| "
	}
	if err := rows.Err(); err != nil { return "ERROR: " + err.Error() }
	if res == "" { return "(sin filas)" }
	return res
}

func TestDivergencias(t *testing.T) {
	for name, db := range engines(t) {
		t.Logf("################ %s", name)
		t.Logf("versión: %s", try(db, map[string]string{"sqlite": "SELECT sqlite_version()", "postgres": "SHOW server_version"}[name]))
		// 1. afinidad de tipos
		t.Logf("D1 insert 99: %s", try(db, "INSERT INTO packages (product_id, spins, package_price_cents) VALUES ('spins-10', 10, 99) RETURNING product_id"))
		t.Logf("D1 insert texto: %s", try(db, "INSERT INTO packages (product_id, spins, package_price_cents) VALUES ('spins-x', 10, 'mucha plata') RETURNING product_id"))
		t.Logf("D1 suma: %s", try(db, "SELECT sum(package_price_cents), count(*) FROM packages"))
		// 2. el instante que es una cadena
		t.Logf("D2 insert: %s", try(db, "INSERT INTO wheels (name, closes_at, status) VALUES ('Semana del Canal', '2026-08-15T20:00:00-05:00', 'live') RETURNING id"))
		t.Logf("D2 cerradas después de las 00:00Z del 16: %s", try(db, "SELECT name FROM wheels WHERE closes_at > '2026-08-16T00:00:00Z'"))
		t.Logf("D2 lo guardado: %s", try(db, "SELECT CAST(closes_at AS TEXT) FROM wheels"))
		// 4. el bloqueo que no existe
		t.Logf("D4 FOR UPDATE: %s", try(db, "SELECT id FROM wheels WHERE id = 1 FOR UPDATE"))
		// 6. LIKE y las mayúsculas, con y sin tilde (name_like del contrato)
		try(db, "INSERT INTO players (id, name, country) VALUES (901, 'Juan P.', 'Colombia'), (902, 'Ángela M.', 'Panamá')")
		t.Logf("D6 LIKE '%%juan%%': %s", try(db, "SELECT name FROM players WHERE name LIKE '%juan%'"))
		t.Logf("D6 LIKE '%%ángela%%': %s", try(db, "SELECT name FROM players WHERE name LIKE '%ángela%'"))
		t.Logf("D6 lower() LIKE '%%ángela%%': %s", try(db, "SELECT name FROM players WHERE lower(name) LIKE '%ángela%'"))
		if name == "postgres" {
			t.Logf("D6 ILIKE '%%ángela%%': %s", try(db, "SELECT name FROM players WHERE name ILIKE '%ángela%'"))
		}
		db.Close()
	}
}

// 5. las claves foráneas apagadas: SQLite sin _foreign_keys=on en el DSN.
func TestDivergenciaFK(t *testing.T) {
	db, err := storage.Open(context.Background(), "file:fkoff?mode=memory&cache=shared")
	if err != nil { t.Fatal(err) }
	defer db.Close()
	applyMigrations(t, db)
	t.Logf("D5 sqlite sin _foreign_keys: %s", try(db, "INSERT INTO wheel_segments (wheel_version_id, segment_id, prize_type, weight_bp) VALUES (999, 'x', 'none', 1) RETURNING id"))
	t.Logf("D5 PRAGMA foreign_keys: %s", try(db, "PRAGMA foreign_keys"))
	pg, _ := storage.Open(context.Background(), os.Getenv("PG_URL"))
	defer pg.Close()
	applyMigrations(t, pg)
	t.Logf("D5 postgres: %s", try(pg, "INSERT INTO wheel_segments (wheel_version_id, segment_id, prize_type, weight_bp) VALUES (999, 'x', 'none', 1) RETURNING id"))
}
