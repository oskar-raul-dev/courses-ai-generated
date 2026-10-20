// server/internal/spin/spin_json_test.go

package spin_test

import (
	"encoding/json"
	"strings"
	"testing"

	"github.com/interoceanic-games/esclusa-api/internal/spin"
)

// be-06: el JSON de una fila de la bitácora, comparado como texto. Una prueba
// que compare structs no ve la diferencia; la consola sí.
func TestSpinSerializesLikeTheMock(t *testing.T) {
	var row spin.Spin
	if err := json.Unmarshal([]byte(`{"id":1,"wheelId":4,"playerId":1538,"landedSegment":"sin-premio",
		"deliveredPrize":"sin-premio","origin":"paid","idempotencyKey":"k","createdAt":"2026-08-01T05:00:00.000Z"}`), &row); err != nil {
		t.Fatalf("la fila del mock no entra en spin.Spin: %v", err)
	}
	out, _ := json.Marshal(row)
	if !strings.Contains(string(out), `"origin":"paid"`) {
		t.Fatalf("origin no sale como texto: %s", out)
	}
	var poor spin.Spin // la fila del giro de 2019: sin origen
	out, _ = json.Marshal(poor)
	if strings.Contains(string(out), `"origin"`) {
		t.Fatalf("una fila sin origen no puede traer la clave origin: %s", out)
	}
}
