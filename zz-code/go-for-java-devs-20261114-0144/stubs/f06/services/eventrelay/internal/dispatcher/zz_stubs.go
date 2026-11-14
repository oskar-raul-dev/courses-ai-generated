package dispatcher

import (
	"time"

	"github.com/meridian/eventrelay/internal/relay"
)

// Completado en zz-code: las dependencias del dispatcher que la F06 no escribe.
type Sender interface {
	Send(d relay.Delivery) error
}

type Store interface {
	UpdateDelivery(d relay.Delivery) error
}

type Clock interface{ Now() time.Time }
