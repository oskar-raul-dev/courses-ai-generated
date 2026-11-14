package workitem

import "time"

// JobExecution registra una ejecución del motor (F06). Completado en zz-code a partir
// del literal que construye engine.go.
type JobExecution struct {
	WorkItemID string
	WorkerID   int
	StartedAt  time.Time
	FinishedAt time.Time
	DurationMS int64
	Error      string
}
