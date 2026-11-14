package txlab

import "errors"

// Completado en zz-code: el lab lo usa y no lo define (en OpsReport vive en postgres/errors.go).
var ErrRetryable = errors.New("conflicto de concurrencia; se puede reintentar")
