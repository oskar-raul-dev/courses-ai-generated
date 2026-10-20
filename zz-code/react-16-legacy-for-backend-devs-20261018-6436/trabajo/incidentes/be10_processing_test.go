// server/internal/spin/processing_test.go

package spin_test

import (
	"context"
	"testing"
	"time"

	"github.com/interoceanic-games/esclusa-api/internal/spin"
)

// be-10: el proceso muere entre decidir y entregar. Pasado el plazo, la misma
// clave tiene que devolver el giro que ya salió, y el barrido tiene que poder
// encontrarlo con la consulta del runbook.
func TestSpinCutDuringDeliveryRecovers(t *testing.T) {
	db := openPostgres(t)
	measurementWheel(t, db, 1000, 1, 5)
	svc := spin.NewService(db, spin.Pessimistic, time.Hour, 200*time.Millisecond)

	// El corte: el contexto se cancela mientras el juego "recibe" el premio.
	ctx, cut := context.WithTimeout(context.Background(), 50*time.Millisecond)
	defer cut()
	if _, err := svc.Spin(ctx, 1, "corte"); err == nil {
		t.Fatal("la entrega no se cortó")
	}

	time.Sleep(300 * time.Millisecond) // vence processing_until
	var stuck int
	db.Get(&stuck, `SELECT count(*) FROM spin_requests WHERE status = 'processing' AND processing_until < now()`)
	if stuck != 1 {
		t.Fatalf("el runbook no encuentra el giro colgado: %d filas", stuck)
	}

	retry := spin.NewService(db, spin.Pessimistic, 0, 200*time.Millisecond)
	r, err := retry.Spin(context.Background(), 1, "corte")
	if err != nil {
		t.Fatalf("la misma clave, pasado el plazo: %v", err)
	}
	var rows int
	db.Get(&rows, `SELECT count(*) FROM spin_log WHERE idempotency_key = 'corte'`)
	if rows != 1 || r.LandedSegment != "esclusa-de-oro" {
		t.Fatalf("el reintento giró otra vez o devolvió otra cosa: %d filas, %+v", rows, r)
	}
}
