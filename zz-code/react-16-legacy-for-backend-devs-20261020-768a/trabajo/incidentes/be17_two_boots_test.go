// server/internal/spin/random_test.go — la regresión de be-17

package spin

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"testing"
)

// Dos arranques del binario no pueden sortear la misma secuencia. Un arranque
// es un proceso: la prueba se vuelve a lanzar a sí misma dos veces, cada una
// sortea diez segmentos, y compara lo que imprimieron.
func TestTwoBootsDrawDifferentSequences(t *testing.T) {
	if os.Getenv("SPIN_DRAW_CHILD") == "1" {
		d := NewDrawer()
		segments := []Segment{{SegmentID: "a", WeightBp: 1000}, {SegmentID: "b", WeightBp: 1000},
			{SegmentID: "c", WeightBp: 1000}, {SegmentID: "d", WeightBp: 1000}, {SegmentID: "e", WeightBp: 1000},
			{SegmentID: "f", WeightBp: 1000}, {SegmentID: "g", WeightBp: 1000}, {SegmentID: "h", WeightBp: 1000},
			{SegmentID: "i", WeightBp: 1000}, {SegmentID: "j", WeightBp: 1000}}
		var out []string
		for i := 0; i < 10; i++ {
			out = append(out, d.Draw(segments).SegmentID)
		}
		fmt.Println("SECUENCIA", strings.Join(out, ""))
		return
	}

	boot := func() string {
		cmd := exec.Command(os.Args[0], "-test.run=^TestTwoBootsDrawDifferentSequences$", "-test.count=1")
		cmd.Env = append(os.Environ(), "SPIN_DRAW_CHILD=1")
		out, err := cmd.CombinedOutput()
		if err != nil {
			t.Fatalf("el arranque falló: %v\n%s", err, out)
		}
		for _, line := range strings.Split(string(out), "\n") {
			if strings.HasPrefix(line, "SECUENCIA ") {
				return strings.TrimPrefix(line, "SECUENCIA ")
			}
		}
		t.Fatalf("el arranque no imprimió su secuencia:\n%s", out)
		return ""
	}
	first, second := boot(), boot()
	t.Logf("arranque 1: %s · arranque 2: %s", first, second)
	if first == second {
		t.Fatalf("dos arranques sortearon la misma secuencia: %s", first)
	}
}
