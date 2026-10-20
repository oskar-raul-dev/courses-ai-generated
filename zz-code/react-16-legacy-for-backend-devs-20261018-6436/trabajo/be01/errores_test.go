package httpapi

// Mide los errores comunes de be01 §6. Copia descartable; no vive en el repo.
import (
	"bytes"
	"io"
	"log"
	"net/http"
	"net/http/httptest"
	"sync"
	"testing"
)

func TestWriteHeaderTarde(t *testing.T) {
	var buf bytes.Buffer
	srv := httptest.NewUnstartedServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(`{"wheels":[]}`))
		w.WriteHeader(http.StatusNotFound)
	}))
	srv.Config.ErrorLog = log.New(&buf, "", 0)
	log.SetOutput(&buf)
	srv.Start()
	defer srv.Close()
	res, _ := http.Get(srv.URL)
	t.Logf("WriteHeader tarde: status=%d log=%q", res.StatusCode, buf.String())
}

func TestSinReturn(t *testing.T) {
	var buf bytes.Buffer
	log.SetOutput(&buf)
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Query().Get("level") == "" {
			writeError(w, http.StatusBadRequest, "Falta el nivel")
			// falta el return
		}
		writeJSON(w, http.StatusOK, map[string]string{"level": "off"})
	}))
	defer srv.Close()
	res, _ := http.Get(srv.URL)
	body, _ := io.ReadAll(res.Body)
	t.Logf("sin return: status=%d cuerpo=%q log=%q", res.StatusCode, body, buf.String())
}

// Un nivel compartido sin candado, leído y escrito a la vez: lo que -race detecta.
type unlockedChaos struct{ level string }

func TestCarreraSinCandado(t *testing.T) {
	c := &unlockedChaos{level: "off"}
	var wg sync.WaitGroup
	for i := 0; i < 50; i++ {
		wg.Add(2)
		go func() { defer wg.Done(); _ = c.level }()
		go func() { defer wg.Done(); c.level = "high" }()
	}
	wg.Wait()
}

func TestControllerConCandado(t *testing.T) {
	c := NewChaosController("off", 1)
	var wg sync.WaitGroup
	for i := 0; i < 50; i++ {
		wg.Add(2)
		go func() { defer wg.Done(); c.draw() }()
		go func() { defer wg.Done(); c.SetLevel("high") }()
	}
	wg.Wait()
}
