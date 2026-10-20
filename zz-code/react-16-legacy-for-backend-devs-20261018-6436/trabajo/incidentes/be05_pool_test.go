// server/internal/player/pool_test.go

package player_test

import (
	"context"
	"errors"
	"os"
	"testing"
	"time"

	"github.com/interoceanic-games/esclusa-api/internal/player"
	"github.com/interoceanic-games/esclusa-api/internal/storage"
)

// be-05: veinte envíos del mismo caso, con un pool de tres conexiones. Cada uno
// tiene que volver con ErrCaseGranted, y al final no puede quedar ninguna tomada.
func TestDuplicateGrantsDoNotDrainThePool(t *testing.T) {
	db, err := storage.Open(context.Background(), os.Getenv("TEST_DATABASE_URL"))
	if err != nil {
		t.Skip("necesita TEST_DATABASE_URL (Postgres): ", err)
	}
	defer db.Close()
	db.SetMaxOpenConns(3)
	db.MustExec(`DELETE FROM grants WHERE case_id = 'C-POOL'`)
	db.MustExec(`INSERT INTO players (id, name, status) VALUES (9001, 'Prueba del pool', 'active') ON CONFLICT (id) DO NOTHING`)

	svc := player.NewService(db, 0)
	g := player.Grant{GrantID: "g-0", PlayerID: 9001, CaseID: "C-POOL", Prize: "vidas-5", Reason: "caída"}
	if _, err := svc.SendGrant(context.Background(), g); err != nil {
		t.Fatal(err)
	}
	for i := 1; i <= 20; i++ {
		done := make(chan error, 1)
		go func() { _, err := svc.SendGrant(context.Background(), g); done <- err }()
		select {
		case err := <-done:
			if !errors.Is(err, player.ErrCaseGranted) {
				t.Fatalf("envío %d: %v", i, err)
			}
		case <-time.After(3 * time.Second):
			t.Fatalf("el envío duplicado %d se colgó: el pool está agotado (en uso: %d)", i, db.Stats().InUse)
		}
	}
	if inUse := db.Stats().InUse; inUse != 0 {
		t.Fatalf("quedaron %d conexiones tomadas", inUse)
	}
}
