// server/internal/http/cors_test.go

package httpapi

import (
	"net/http/httptest"
	"strings"
	"testing"
)

// be-01: el X-Request-Id no basta con que viaje; la respuesta real tiene que exponerlo.
func TestRequestIDIsExposedToTheBrowser(t *testing.T) {
	req := httptest.NewRequest("GET", "/health", nil)
	req.Header.Set("Origin", "http://localhost:3000")
	rec := httptest.NewRecorder()

	NewRouter(Config{AllowedOrigin: "http://localhost:3000", ChaosLevel: "off"}).ServeHTTP(rec, req)

	if rec.Header().Get("X-Request-Id") == "" {
		t.Fatal("la respuesta no trae X-Request-Id")
	}
	if !strings.Contains(rec.Header().Get("Access-Control-Expose-Headers"), "X-Request-Id") {
		t.Fatalf("X-Request-Id viaja pero no está expuesto: Access-Control-Expose-Headers=%q",
			rec.Header().Get("Access-Control-Expose-Headers"))
	}
}
