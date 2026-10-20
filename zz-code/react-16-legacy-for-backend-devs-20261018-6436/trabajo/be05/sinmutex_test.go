package spin

// be05 §6: el sorteo sin el mutex, bajo go test -race. Se copia a una copia de
// internal/spin/ donde random.go perdió sus dos líneas de Lock y Unlock.

import (
	"sync"
	"testing"
)

func TestDrawerConcurrent(t *testing.T) {
	d := NewDrawer()
	segments := []Segment{{SegmentID: "a", WeightBp: 5000}, {SegmentID: "b", WeightBp: 5000}}
	var wg sync.WaitGroup
	for i := 0; i < 8; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for j := 0; j < 1000; j++ {
				d.Draw(segments)
			}
		}()
	}
	wg.Wait()
}
