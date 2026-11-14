package worker

import (
	"context"
	"time"
)

// Completado en zz-code: la F07 usa estas piezas y no las escribe.
type Job struct{ ID int }

func process(j Job) { time.Sleep(10 * time.Millisecond) }

func processCtx(ctx context.Context, j Job) {
	select {
	case <-time.After(10 * time.Millisecond):
	case <-ctx.Done():
	}
}
