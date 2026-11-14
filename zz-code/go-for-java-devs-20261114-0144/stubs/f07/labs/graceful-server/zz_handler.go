package main

import (
	"net/http"
	"time"
)

// Completado en zz-code: un /slow de 3 s para ver que Shutdown espera a la petición en curso.
func buildHandler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("/slow", func(w http.ResponseWriter, r *http.Request) {
		time.Sleep(3 * time.Second)
		_, _ = w.Write([]byte("terminé\n"))
	})
	return mux
}
