// server/internal/reconciliation/shape_test.go

package reconciliation_test

import (
	"context"
	"os"
	"reflect"
	"testing"

	"github.com/interoceanic-games/esclusa-api/internal/reconciliation"
	"github.com/interoceanic-games/esclusa-api/internal/storage"
	"github.com/interoceanic-games/esclusa-api/internal/wheel"
)

// be-07: lo que la consola manda es lo que queda guardado. Los tres campos que
// el INSERT podría olvidar se comparan al volver a leer.
func TestReconciliationKeepsEveryField(t *testing.T) {
	db, err := storage.Open(context.Background(), os.Getenv("TEST_DATABASE_URL"))
	if err != nil {
		t.Skip("necesita TEST_DATABASE_URL (Postgres): ", err)
	}
	defer db.Close()
	db.MustExec(`DELETE FROM reconciliations WHERE wheel_id = 9002`)
	db.MustExec(`DELETE FROM wheels WHERE id = 9002`)
	db.MustExec(`INSERT INTO wheels (id, name, closes_at, status) VALUES (9002, 'Prueba', '2026-08-31T20:00:00-05:00', 'ended')`)
	db.MustExec(`INSERT INTO wheel_versions (wheel_id, version) VALUES (9002, 1)`)

	svc := reconciliation.NewService(db, wheel.NewStore(db))
	sent := reconciliation.Reconciliation{Spins: 3, Counts: []int{1, 1, 1}, BandAlarms: []string{"sin-premio"},
		Purchases: reconciliation.Totals{MissingInAPI: []string{"tok-ago-31"}, DuplicatedInAPI: []string{"tok-ago-17"}}}
	if _, _, err := svc.Reconcile(context.Background(), 9002, sent); err != nil {
		t.Fatal(err)
	}
	got, err := svc.Find(context.Background(), 9002)
	if err != nil {
		t.Fatal(err)
	}
	if !reflect.DeepEqual(got.BandAlarms, sent.BandAlarms) ||
		!reflect.DeepEqual(got.Purchases.MissingInAPI, sent.Purchases.MissingInAPI) ||
		!reflect.DeepEqual(got.Purchases.DuplicatedInAPI, sent.Purchases.DuplicatedInAPI) {
		t.Fatalf("se guardó otra cosa: mandé %+v, leí %+v", sent, got)
	}
}
