// payments-go — procesador de pagos (Go, net/http)
//
// Tercer lenguaje del juguete. Ligero y rápido. En la fase de
// coreografía (Fase 8) publicará eventos "payment.approved" en
// Redis, que otros servicios consumirán sin acoplarse directamente.
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"
)

type PaymentRequest struct {
	OrderID string  `json:"orderId"`
	Amount  float64 `json:"amount"`
}

type PaymentResponse struct {
	OrderID   string    `json:"orderId"`
	Status    string    `json:"status"`
	Processed time.Time `json:"processedAt"`
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8090"
	}

	// Healthcheck para las probes de Kubernetes.
	http.HandleFunc("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
	})

	// Procesar un pago. En este juguete siempre aprueba, pero es el
	// punto donde en la fase de sagas introduciremos fallos para
	// practicar compensaciones.
	http.HandleFunc("/pay", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}
		var req PaymentRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "bad request", http.StatusBadRequest)
			return
		}
		resp := PaymentResponse{
			OrderID:   req.OrderID,
			Status:    "APPROVED",
			Processed: time.Now().UTC(),
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(resp)
		log.Printf("pago aprobado para orden %s por %.2f", req.OrderID, req.Amount)
	})

	log.Printf("payments-go escuchando en :%s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}
