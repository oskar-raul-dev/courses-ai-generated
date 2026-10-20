package wheel_test

// ¿Cuándo un Rows sin Close retiene la conexión? Copia descartable.
import (
	"context"
	"os"
	"testing"
	"time"

	"github.com/interoceanic-games/esclusa-api/internal/storage"
)

func TestRowsSinClose(t *testing.T) {
	db, err := storage.Open(context.Background(), os.Getenv("PG_URL"))
	if err != nil { t.Fatal(err) }
	defer db.Close()
	db.SetMaxOpenConns(3)
	q := `SELECT n FROM generate_series(1, 5) AS n`
	for _, mode := range []string{"recorrido entero, con contexto", "sale con el primero, con contexto", "sale con el primero, sin contexto"} {
		for i := 0; i < 5; i++ {
			ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
			var rows interface{ Next() bool }
			var err error
			if mode == "sale con el primero, sin contexto" {
				done := make(chan struct{})
				go func() { rows, err = db.Query(q); close(done) }()
				select {
				case <-done:
				case <-time.After(2 * time.Second):
					err = context.DeadlineExceeded
				}
			} else {
				rows, err = db.QueryContext(ctx, q)
			}
			if err != nil { t.Logf("%s · consulta %d: %v", mode, i+1, err); cancel(); break }
			if mode == "recorrido entero, con contexto" { for rows.Next() {} } else { rows.Next() } // sin rows.Close()
			cancel()
			time.Sleep(50 * time.Millisecond)
		}
		t.Logf("%s · conexiones en uso tras 5 consultas: %d (máximo 3)", mode, db.Stats().InUse)
	}
}
