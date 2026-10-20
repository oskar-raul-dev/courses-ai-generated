package spin_test

import (
	"context"
	"os"
	"testing"

	"github.com/interoceanic-games/esclusa-api/internal/storage"
)

func TestNullEnString(t *testing.T) {
	db, err := storage.Open(context.Background(), os.Getenv("PG_URL"))
	if err != nil { t.Fatal(err) }
	defer db.Close()
	var row struct{ Origin string `db:"origin"` }
	err = db.Get(&row, `SELECT origin FROM spin_log WHERE origin IS NULL LIMIT 1`)
	t.Logf("NULL en string: %v", err)
}
