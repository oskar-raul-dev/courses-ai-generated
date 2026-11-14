package main

import (
	"fmt"
	"os"
	"strconv"
	"sync"
	"time"
)

// B-07, lado Go: el SpawnN de la Fase 06 con tiempo.
func main() {
	n, _ := strconv.Atoi(os.Args[1])
	t0 := time.Now()
	var wg sync.WaitGroup
	wg.Add(n)
	for i := 0; i < n; i++ {
		go func() { defer wg.Done(); time.Sleep(10 * time.Millisecond) }()
	}
	wg.Wait()
	fmt.Printf("goroutines n=%d tiempo=%d ms\n", n, time.Since(t0).Milliseconds())
}
