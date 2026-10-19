// Verificación P7: math/rand sin semilla explícita. Imprime los primeros sorteos.
package main

import (
	"fmt"
	"math/rand"
)

func main() {
	out := make([]int, 0, 8)
	for i := 0; i < 8; i++ {
		out = append(out, rand.Intn(10000))
	}
	fmt.Println(out)
}
