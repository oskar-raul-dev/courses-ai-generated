// labs/build-info/main.go
package main

import (
	"fmt"
	"runtime"
)

// Estas tres variables se sobrescriben en tiempo de enlazado con -ldflags -X.
// Tienen que ser variables de paquete tipo string: el enlazador no sabe
// escribir constantes ni tipos numéricos.
var (
	version   = "dev"
	commit    = "none"
	buildDate = "unknown"
)

func main() {
	fmt.Printf("opsreport %s (commit %s, built %s)\n", version, commit, buildDate)
	fmt.Printf("go %s · %s/%s\n", runtime.Version(), runtime.GOOS, runtime.GOARCH)
}
