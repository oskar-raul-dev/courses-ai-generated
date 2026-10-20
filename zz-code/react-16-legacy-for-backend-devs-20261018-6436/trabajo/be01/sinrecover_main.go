// Binario de prueba: la cadena de be01 sin recoverMiddleware, con /_boom (pánico en el
// handler) y /_boom-goroutine (pánico en una goroutine lanzada por el handler).
package main

import (
	"log"
	"net/http"
	"time"

	"github.com/gorilla/mux"
)

func main() {
	r := mux.NewRouter()
	r.HandleFunc("/health", func(w http.ResponseWriter, _ *http.Request) { w.Write([]byte(`{"status":"ok"}`)) })
	r.HandleFunc("/_boom", func(w http.ResponseWriter, _ *http.Request) {
		segments := []string{"esclusa-de-oro"}
		w.Write([]byte(segments[5]))
	})
	r.HandleFunc("/_boom-goroutine", func(w http.ResponseWriter, _ *http.Request) {
		go func() {
			time.Sleep(50 * time.Millisecond)
			segments := []string{"esclusa-de-oro"}
			log.Println(segments[5])
		}()
		w.WriteHeader(http.StatusAccepted)
	})
	cors := func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Access-Control-Allow-Origin", "http://localhost:3000")
			w.Header().Set("X-Request-Id", "id-de-prueba")
			w.Header().Set("Access-Control-Expose-Headers", "X-Request-Id")
			next.ServeHTTP(w, r)
		})
	}
	log.Fatal(http.ListenAndServe(":3012", cors(r)))
}
