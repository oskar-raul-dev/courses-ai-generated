// trabajo/bea06/go/main.go — el reloj monótono y ==, y el peso de time/tzdata.
package main

import (
	"fmt"
	"time"
)

func main() {
	t1 := time.Now()
	t2 := t1.Round(0) // Round(0) descarta la lectura monótona
	fmt.Println("t1 == t2:", t1 == t2, "· t1.Equal(t2):", t1.Equal(t2))
	fmt.Printf("%+v\n", t1)
}
