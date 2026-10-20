// server/internal/reconciliation/stale_client_test.go

package reconciliation_test

import (
	"context"
	"errors"
	"os"
	"testing"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"

	"github.com/interoceanic-games/esclusa-api/internal/purchase"
	"github.com/interoceanic-games/esclusa-api/internal/reconciliation"
	"github.com/interoceanic-games/esclusa-api/internal/storage"
	"github.com/interoceanic-games/esclusa-api/internal/wheel"
)

type store []purchase.EarningsRow

func (store) State(context.Context, string) (string, error)            { return "confirmed", nil }
func (s store) Earnings(context.Context) ([]purchase.EarningsRow, error) { return s, nil }

// be-13: la consola concilia con lo que cargó antes; entre medio, la compra que
// faltaba se acreditó. Lo guardado tiene que ser lo de ahora, no lo de antes.
func TestReconcileIgnoresStaleClient(t *testing.T) {
	url := os.Getenv("TEST_DATABASE_URL")
	if url == "" {
		t.Skip("falta TEST_DATABASE_URL")
	}
	db, err := storage.Open(context.Background(), url)
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	driver, _ := postgres.WithInstance(db.DB.DB, &postgres.Config{})
	m, _ := migrate.NewWithDatabaseInstance("file://../../migrations/postgres", "postgres", driver)
	if err := m.Down(); err != nil && !errors.Is(err, migrate.ErrNoChange) {
		t.Fatal(err)
	}
	if err := m.Up(); err != nil {
		t.Fatal(err)
	}
	db.MustExec(`INSERT INTO wheels (id, name, closes_at, status) VALUES (4, 'Rueda de fin de mes', '2026-08-30T20:00:00-05:00', 'ended')`)
	db.MustExec(`INSERT INTO wheel_versions (id, wheel_id, version) VALUES (4, 4, 1)`)
	db.MustExec(`INSERT INTO wheel_segments (wheel_version_id, segment_id, prize_type, weight_bp) VALUES (4, 'sin-premio', 'none', 10000)`)
	db.MustExec(`INSERT INTO packages (product_id, spins, package_price_cents) VALUES ('spins-10', 10, 99)`)
	db.MustExec(`INSERT INTO purchases (purchase_token, product_id, credited_at) VALUES ('tok-ago-30', 'spins-10', now()), ('tok-ago-31', 'spins-10', now())`)
	report := store{{PurchaseToken: "tok-ago-30", ChargedCents: 99, FeeCents: 15}, {PurchaseToken: "tok-ago-31", ChargedCents: 99, FeeCents: 15}}

	// Lo que la consola cargó antes de que tok-ago-31 se acreditara.
	stale := reconciliation.Reconciliation{Purchases: reconciliation.Totals{ChargedCents: 198, FeeCents: 30, NetCents: 168,
		MissingInAPI: []string{"tok-ago-31"}, DuplicatedInAPI: []string{}}}
	svc := reconciliation.NewService(db, wheel.NewStore(db), report)
	if _, _, _, err := svc.Reconcile(context.Background(), 4, stale); err != nil {
		t.Fatal(err)
	}
	saved, err := svc.Find(context.Background(), 4)
	if err != nil {
		t.Fatal(err)
	}
	if len(saved.Purchases.MissingInAPI) != 0 {
		t.Fatalf("la conciliación guardó como faltante una compra acreditada: %v", saved.Purchases.MissingInAPI)
	}
}
