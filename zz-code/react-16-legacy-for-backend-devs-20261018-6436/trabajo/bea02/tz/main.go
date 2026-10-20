// trabajo/bea02/tz/main.go — ¿encuentra la zona de Panamá dentro de la imagen?
package main

import (
	"fmt"
	"time"
)

func main() {
	_, err := time.LoadLocation("America/Panama")
	fmt.Println("America/Panama:", err)
}
