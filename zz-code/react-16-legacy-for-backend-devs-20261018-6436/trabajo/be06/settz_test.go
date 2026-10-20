// trabajo/be06/settz_test.go — se copia a internal/storage con gotest-extra.sh.
// Mide el SET TIME ZONE del be06 viejo: una sentencia después de abrir el pool.
package storage_test

import (
	"context"
	"os"
	"strings"
	"sync"
	"testing"

	"github.com/interoceanic-games/esclusa-api/internal/storage"
)

func TestSetTimeZoneOnAPool(t *testing.T) {
	// El DSN sin timezone, y la política del código viejo: un SET al abrir.
	url := strings.Replace(os.Getenv("PG_URL"), "sslmode=disable", "sslmode=disable", 1)
	for _, name := range []string{"set-al-abrir", "politica-be06"} {
		var db *storage.DB
		var err error
		if name == "set-al-abrir" {
			// Abrimos el pool a mano, sin pasar por Open, para no heredar el DSN de be06.
			db, err = storage.OpenRaw(context.Background(), url)
			if err == nil {
				db.MustExec(`SET TIME ZONE 'America/Panama'`)
			}
		} else {
			db, err = storage.Open(context.Background(), url)
		}
		if err != nil {
			t.Fatal(err)
		}
		var mu sync.Mutex
		zones := map[string]int{}
		var wg sync.WaitGroup
		for i := 0; i < 200; i++ {
			wg.Add(1)
			go func() {
				defer wg.Done()
				var z string
				db.Get(&z, `SELECT current_setting('TimeZone') FROM pg_sleep(0.01)`)
				mu.Lock()
				zones[z]++
				mu.Unlock()
			}()
		}
		wg.Wait()
		t.Logf("%s: %v", name, zones)
		db.Close()
	}
}
