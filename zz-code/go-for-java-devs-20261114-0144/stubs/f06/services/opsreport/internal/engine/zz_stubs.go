package engine

import "errors"

// Completado en zz-code: engine.go los usa y la F06 no los muestra enteros.
var (
	ErrShuttingDown = errors.New("el motor se está apagando")
	ErrQueueFull    = errors.New("la cola de trabajos está llena")
)

type Stats struct {
	Completed, Failed, Rejected int
	QueueLen, QueueCap          int
}
