// server/internal/spin/ejemplos_test.go — los tres ejemplos de bea-10 §7

package spin_test

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/brianvoe/gofakeit/v6"

	"github.com/interoceanic-games/esclusa-api/internal/seed"
	"github.com/interoceanic-games/esclusa-api/internal/spin"
)

// ❌ Pasa hoy. Falla el día que alguien agregue una llamada al generador.
func TestVolumeFirstPlayer(t *testing.T) {
	db := openPostgres(t)
	if err := seed.GenerateVolume(context.Background(), db, 100, 42); err != nil {
		t.Fatal(err)
	}
	var name string
	db.Get(&name, `SELECT name FROM players WHERE id = 100000`)
	if name != "Jeromy R." { // ¿de dónde salió ese nombre?
		t.Fatalf("el primer jugador es %q", name)
	}
}

// ✅ Datos escritos por la prueba. Afirma sobre lo que la prueba decidió.
func TestSpinSpendsTheLastFreeSpin(t *testing.T) {
	db := openPostgres(t)
	measurementWheel(t, db, 1000, 1, 1) // un jugador, con un solo giro gratis
	svc := spin.NewService(db, spin.Pessimistic, 0, 30*time.Second)

	r, err := svc.Spin(context.Background(), 1, "unico")
	if err != nil {
		t.Fatal(err)
	}
	var free int
	db.Get(&free, `SELECT free_spins FROM players WHERE id = 1`)
	if *r.Origin != "free" || free != 0 {
		t.Fatalf("origen %q, saldo %d: esperaba free y 0", *r.Origin, free)
	}
}

// ✅ Datos generados, y la aserción es una PROPIEDAD, no un valor: para
// cualquier rueda cuyos pesos sumen 10.000, el sorteo cae en un segmento suyo.
func TestDrawAlwaysLandsOnTheWheel(t *testing.T) {
	faker := gofakeit.New(7)
	d := spin.NewDrawer()
	for w := 0; w < 1000; w++ {
		n := faker.Number(2, 8)
		segments := make([]spin.Segment, n)
		left := 10000
		for i := range segments {
			weight := left - (n - 1 - i) // lo que quede, si es el último
			if i < n-1 {
				weight = faker.Number(1, left-(n-1-i))
			}
			left -= weight
			segments[i] = spin.Segment{SegmentID: fmt.Sprintf("s%d", i), WeightBp: weight}
		}
		valid := map[string]bool{}
		for _, s := range segments {
			valid[s.SegmentID] = true
		}
		for k := 0; k < 100; k++ {
			if got := d.Draw(segments).SegmentID; !valid[got] {
				t.Fatalf("rueda %d: cayó en %q, que no está en %+v", w, got, segments)
			}
		}
	}
}
