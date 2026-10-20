// server/internal/http/free_spin_test.go

package httpapi_test

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"

	"github.com/interoceanic-games/esclusa-api/internal/auth"
	"github.com/interoceanic-games/esclusa-api/internal/clock"
	httpapi "github.com/interoceanic-games/esclusa-api/internal/http"
	"github.com/interoceanic-games/esclusa-api/internal/spin"
	"github.com/interoceanic-games/esclusa-api/internal/storage"
)

// be-18: el celular adelantado cuatro horas no cobra otro giro gratis. La hora
// la pone el servidor; una cabecera con la hora del cliente no cambia nada.
func TestClientClockDoesNotGrantFreeSpins(t *testing.T) {
	url := os.Getenv("TEST_DATABASE_URL")
	if url == "" {
		t.Skip("falta TEST_DATABASE_URL")
	}
	db, err := storage.Open(context.Background(), url)
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	driver, _ := postgres.WithInstance(db.DB.DB, &postgres.Config{})
	m, _ := migrate.NewWithDatabaseInstance("file://../../migrations/postgres", "postgres", driver)
	if err := m.Down(); err != nil && !errors.Is(err, migrate.ErrNoChange) {
		t.Fatal(err)
	}
	if err := m.Up(); err != nil {
		t.Fatal(err)
	}
	db.MustExec(`INSERT INTO players (id, name) VALUES (43, 'María R.')`)

	now := time.Date(2026, 10, 19, 15, 0, 0, 0, time.UTC)
	clk := clock.Fixed{T: now}
	signer, _ := auth.NewSigner("secreto-de-prueba-de-32-bytes-o-mas!!", time.Hour)
	router := httpapi.NewRouter(httpapi.Config{AllowedOrigin: "http://localhost:3000", ChaosLevel: "off", DB: db,
		Signer: signer, Clock: clk, Spins: spin.NewService(db, spin.Pessimistic, 0, 30*time.Second, clk, 4*time.Hour)})

	claim := func(clientNow string) int {
		req := httptest.NewRequest(http.MethodPost, "/players/43/free-spins", nil)
		if clientNow != "" {
			req.Header.Set("X-Client-Now", clientNow)
		}
		rec := httptest.NewRecorder()
		router.ServeHTTP(rec, req)
		return rec.Code
	}
	if code := claim(""); code != http.StatusOK {
		t.Fatalf("el primer reclamo: %d", code)
	}
	if code := claim(now.Add(4 * time.Hour).Format(time.RFC3339)); code != http.StatusConflict {
		t.Fatalf("con el celular cuatro horas adelante: %d (esperaba 409)", code)
	}
	var free int
	db.Get(&free, `SELECT free_spins FROM players WHERE id = 43`)
	if free != 1 {
		t.Fatalf("el jugador tiene %d giros gratis (esperaba 1)", free)
	}
}
