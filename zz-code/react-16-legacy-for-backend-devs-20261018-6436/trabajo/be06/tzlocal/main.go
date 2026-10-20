// trabajo/be06/tzlocal/main.go — ¿qué fija de verdad el proceso en UTC?
package main

import (
	"fmt"
	"os"
	"time"
)

var atInit = time.Now().Format("15:04 MST") // un paquete que usa la hora local en su init

func main() {
	switch os.Args[1] {
	case "setenv":
		os.Setenv("TZ", "UTC")
	case "local":
		time.Local = time.UTC
	}
	fmt.Printf("%-8s init: %s · main: %s\n", os.Args[1], atInit, time.Now().Format("15:04 MST"))
}
