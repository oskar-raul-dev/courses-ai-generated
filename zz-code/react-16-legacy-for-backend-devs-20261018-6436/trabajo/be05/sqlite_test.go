package spin_test

// be05 §6, pieza forense: la carrera del stock contra SQLite. Se copia a
// internal/spin/ de una copia del server (trabajo/gotest-extra.sh).

import (
	"context"
	"errors"
	"fmt"
	"testing"
	"time"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/sqlite3"

	"github.com/interoceanic-games/esclusa-api/internal/spin"
	"github.com/interoceanic-games/esclusa-api/internal/storage"
)

func TestStockRaceOnSQLite(t *testing.T) {
	for _, locking := range []spin.Locking{spin.Pessimistic, spin.Optimistic} {
		t.Run(string(locking), func(t *testing.T) {
			url := fmt.Sprintf("file:/tmp/forense-%s.db?_busy_timeout=5000", locking)
			db, err := storage.Open(context.Background(), url)
			if err != nil {
				t.Fatal(err)
			}
			defer db.Close()
			driver, _ := sqlite3.WithInstance(db.DB.DB, &sqlite3.Config{})
			m, _ := migrate.NewWithDatabaseInstance("file://../../migrations/sqlite", "sqlite3", driver)
			if err := m.Down(); err != nil && !errors.Is(err, migrate.ErrNoChange) {
				t.Fatal(err)
			}
			if err := m.Up(); err != nil {
				t.Fatal(err)
			}
			db.MustExec(`INSERT INTO wheels (id, name, closes_at, status) VALUES (900, 'Rueda de medición', '2030-01-01T00:00:00Z', 'live')`)
			db.MustExec(`INSERT INTO wheel_versions (id, wheel_id, version) VALUES (900, 900, 1)`)
			db.MustExec(`INSERT INTO wheel_segments (wheel_version_id, segment_id, prize_type, weight_bp, substitute) VALUES (900, 'esclusa-de-oro', 'avatar', 10000, 'set-gemas-plata')`)
			db.MustExec(`INSERT INTO stock (wheel_id, segment_id, remaining) VALUES (900, 'esclusa-de-oro', 1000)`)
			for p := 1; p <= 300; p++ {
				db.MustExec(`INSERT INTO players (id, name, free_spins) VALUES (?, 'J', 5)`, p)
			}
			svc := spin.NewService(db, locking, 0, 30*time.Second)
			t0 := time.Now()
			errs := race(1500, func(i int) error {
				_, err := svc.Spin(context.Background(), int64(i%300+1), fmt.Sprintf("stock-%d", i))
				return err
			})
			got := count(errs)
			var golden, remaining int
			db.Get(&golden, `SELECT count(*) FROM spin_log WHERE delivered_prize = 'esclusa-de-oro'`)
			db.Get(&remaining, `SELECT remaining FROM stock WHERE wheel_id = 900`)
			t.Logf("SQLite %s: %v · entregadas %d · stock %d · %s", locking, got, golden, remaining, time.Since(t0).Round(time.Millisecond))
		})
	}
}
