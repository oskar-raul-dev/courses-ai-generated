package postgres

import "database/sql"

// Completado en zz-code: la F09 usa DeliveryStore y no muestra el struct.
type DeliveryStore struct{ db *sql.DB }

func NewDeliveryStore(db *sql.DB) *DeliveryStore { return &DeliveryStore{db: db} }
