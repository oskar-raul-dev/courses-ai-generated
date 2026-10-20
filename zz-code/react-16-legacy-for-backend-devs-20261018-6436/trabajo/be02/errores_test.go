package wheel_test

// Errores comunes de be02 §6, medidos. Copia descartable.
import (
	"context"
	"encoding/json"
	"os"
	"testing"

	"github.com/interoceanic-games/esclusa-api/internal/storage"
	"github.com/interoceanic-games/esclusa-api/internal/wheel"
)

func TestErroresComunes(t *testing.T) {
	for name, url := range map[string]string{"sqlite": "file::memory:?cache=shared&_foreign_keys=on", "postgres": os.Getenv("PG_URL")} {
		db, err := storage.Open(context.Background(), url)
		if err != nil { t.Fatal(err) }
		applyMigrations(t, db)
		res, err := db.Exec("INSERT INTO packages (product_id, spins, package_price_cents) VALUES ('spins-10', 10, 99)")
		if err != nil { t.Fatal(err) }
		_, errID := res.LastInsertId()
		t.Logf("%s · LastInsertId: err=%v", name, errID)
		var n int
		errDollar := db.Get(&n, "SELECT count(*) FROM packages WHERE product_id = $1", "spins-10")
		t.Logf("%s · placeholder $1 literal: n=%d err=%v", name, n, errDollar)
		var q int
		errQ := db.Get(&q, "SELECT count(*) FROM packages WHERE product_id = ?", "spins-10")
		t.Logf("%s · placeholder ? sin Rebind: n=%d err=%v", name, q, errQ)
		db.Close()
	}
	var nilWheels []wheel.Wheel
	a, _ := json.Marshal(nilWheels)
	b, _ := json.Marshal([]wheel.Wheel{})
	t.Logf("slice nil → %s · slice vacío → %s", a, b)
}
