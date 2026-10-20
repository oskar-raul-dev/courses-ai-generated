// server/internal/http/panic_test.go

package httpapi

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

// be-03: lo que pide el asistente al abrir (GET /players sin name_like) no puede
// romper el handler, y si algo entra en pánico, el cliente recibe un 500 legible.
func TestPlayersWithoutFilterAnswers(t *testing.T) {
	rec := httptest.NewRecorder()
	NewRouter(Config{AllowedOrigin: "http://localhost:3000", ChaosLevel: "off"}).
		ServeHTTP(rec, httptest.NewRequest("GET", "/players", nil))
	if rec.Code != http.StatusOK {
		t.Fatalf("GET /players sin filtro respondió %d", rec.Code)
	}
}

func TestPanicBecomesReadable500(t *testing.T) {
	boom := http.HandlerFunc(func(http.ResponseWriter, *http.Request) { panic("explota a propósito") })
	handler := requestIDMiddleware(loggingMiddleware(corsMiddleware("http://localhost:3000")(recoverMiddleware(boom))))

	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, httptest.NewRequest("GET", "/boom", nil))

	if rec.Code != http.StatusInternalServerError {
		t.Fatalf("un pánico respondió %d, se esperaba 500", rec.Code)
	}
	if rec.Header().Get("X-Request-Id") == "" || rec.Header().Get("Access-Control-Allow-Origin") == "" {
		t.Fatal("el 500 tiene que llevar su X-Request-Id y los headers de CORS")
	}
}
