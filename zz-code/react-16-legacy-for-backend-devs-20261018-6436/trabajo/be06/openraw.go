// trabajo/be06/openraw.go — solo para la medición: abre el pool sin la política de zona.
package storage

import (
	"context"

	"github.com/jmoiron/sqlx"
)

func OpenRaw(ctx context.Context, url string) (*DB, error) {
	db, err := sqlx.Open("postgres", url)
	if err != nil {
		return nil, err
	}
	db.SetMaxOpenConns(25)
	return &DB{DB: db, Dialect: Postgres}, db.PingContext(ctx)
}
