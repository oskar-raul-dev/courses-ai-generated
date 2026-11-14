package patterns

import (
	"strings"
	"time"
)

// Completado en zz-code: el catálogo de la F06 usa estos tipos y no los define.
type Input struct{ ID int }
type Item = Input
type Result struct{ ID int }
type Movement struct{ Line string }

func process(i Input) Result { return Result{ID: i.ID} }

func parseAll(data []byte) []Movement {
	var out []Movement
	for _, l := range strings.Split(string(data), "\n") {
		if l != "" {
			out = append(out, Movement{Line: l})
		}
	}
	return out
}

func validate(in <-chan Movement) <-chan Movement { return in }

func searchDB(q string) string    { time.Sleep(30 * time.Millisecond); return "db:" + q }
func searchCache(q string) string { time.Sleep(5 * time.Millisecond); return "cache:" + q }
func searchIndex(q string) string { time.Sleep(15 * time.Millisecond); return "index:" + q }
