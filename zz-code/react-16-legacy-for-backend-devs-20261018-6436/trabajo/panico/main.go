// Prueba: ¿un pánico en un handler de net/http, sin recover propio, tumba el proceso?
package main

import (
	"log"
	"net/http"
	"time"
)

func main() {
	http.HandleFunc("/boom", func(w http.ResponseWriter, r *http.Request) {
		var players []string
		_ = players[0] // index out of range, en la goroutine que sirve la petición
	})
	http.HandleFunc("/boom-async", func(w http.ResponseWriter, r *http.Request) {
		go func() { // en una goroutine lanzada por el handler
			time.Sleep(10 * time.Millisecond)
			var players []string
			_ = players[0]
		}()
		w.WriteHeader(http.StatusAccepted)
	})
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) { w.Write([]byte("ok\n")) })
	log.Fatal(http.ListenAndServe(":8080", nil))
}
