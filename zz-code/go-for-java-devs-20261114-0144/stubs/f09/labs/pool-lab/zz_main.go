package main

import (
	"context"
	"database/sql"
	"log"
	"time"

	_ "github.com/jackc/pgx/v5/stdlib"
)

// Completado en zz-code: el lab no trae main. Pool de 5 y un plazo de 3 s para no colgarse.
func main() {
	db, err := sql.Open("pgx", "postgres://meridian:meridian@gfjd-pg:5432/meridian?sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	db.SetMaxOpenConns(5)
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	LeakConnections(ctx, db)
}
