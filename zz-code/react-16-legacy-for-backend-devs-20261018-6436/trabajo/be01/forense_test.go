package httpapi

// Mide lo que be01 afirma sobre el pánico y el orden de la cadena. Se copia a una
// copia descartable de server/internal/http; no vive en el repo de prueba.
import (
	"bytes"
	"fmt"
	"log"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/gorilla/mux"
)

func boomRouter() http.Handler {
	r := mux.NewRouter()
	r.HandleFunc("/_boom", func(w http.ResponseWriter, r *http.Request) {
		segments := []string{"esclusa-de-oro"}
		writeJSON(w, http.StatusOK, segments[5]) // 💥
	})
	return r
}

func chain(order string) http.Handler {
	chaos := NewChaosController("off", 1)
	var h http.Handler = boomRouter()
	c := corsMiddleware("http://localhost:3000")
	switch order {
	case "correcta": // requestID → logging → cors → recover → chaos
		h = chaosMiddleware(chaos)(h); h = recoverMiddleware(h); h = c(h); h = loggingMiddleware(h); h = requestIDMiddleware(h)
	case "sin-recover":
		h = chaosMiddleware(chaos)(h); h = c(h); h = loggingMiddleware(h); h = requestIDMiddleware(h)
	case "cors-adentro": // requestID → logging → recover → cors → chaos
		h = chaosMiddleware(chaos)(h); h = c(h); h = recoverMiddleware(h); h = loggingMiddleware(h); h = requestIDMiddleware(h)
	case "recover-primero": // recover → requestID → logging → cors → chaos
		h = chaosMiddleware(chaos)(h); h = c(h); h = loggingMiddleware(h); h = requestIDMiddleware(h); h = recoverMiddleware(h)
	}
	return h
}

func TestForense(t *testing.T) {
	for _, order := range []string{"correcta", "sin-recover", "cors-adentro", "recover-primero"} {
		var buf bytes.Buffer
		log.SetOutput(&buf)
		srv := httptest.NewServer(chain(order))
		srv.Config.ErrorLog = log.New(&buf, "", 0)
		req, _ := http.NewRequest("GET", srv.URL+"/_boom", nil)
		req.Header.Set("Origin", "http://localhost:3000")
		res, err := http.DefaultClient.Do(req)
		out := fmt.Sprintf("== %s\n", order)
		if err != nil {
			out += fmt.Sprintf("cliente: error de red: %v\n", err)
		} else {
			body := new(bytes.Buffer)
			body.ReadFrom(res.Body)
			out += fmt.Sprintf("cliente: %d %s | X-Request-Id=%q Allow-Origin=%q Expose=%q\n", res.StatusCode, strings.TrimSpace(body.String()),
				res.Header.Get("X-Request-Id"), res.Header.Get("Access-Control-Allow-Origin"), res.Header.Get("Access-Control-Expose-Headers"))
		}
		// ¿el proceso (el servidor) sigue atendiendo?
		res2, err2 := http.Get(srv.URL + "/nada")
		if err2 == nil { out += fmt.Sprintf("después: el servidor responde (%d)\n", res2.StatusCode) } else { out += "después: no responde\n" }
		srv.Close()
		lines := strings.Split(strings.TrimSpace(buf.String()), "\n")
		for _, l := range lines {
			if len(l) > 140 { l = l[:140] + "…" }
			if strings.Contains(l, "goroutine") || strings.HasPrefix(l, "\t") || strings.HasPrefix(l, "net/http") || strings.HasPrefix(l, "github.com") || strings.HasPrefix(l, "panic(") || strings.HasPrefix(l, "created by") || strings.Contains(l, "httpapi.") || l == "" { continue }
			out += "log: " + l + "\n"
		}
		fmt.Print(out)
	}
}
