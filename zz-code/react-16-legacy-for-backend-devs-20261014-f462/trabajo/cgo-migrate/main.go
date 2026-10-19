// Verificación P7: cgo con mattn/go-sqlite3 v1.14.16 y golang-migrate v4.15.2 en
// golang:1.19.13 (arm64). Compila, abre SQLite en memoria y lista el driver de Postgres.
package main

import (
	"database/sql"
	"fmt"

	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/database/sqlite3"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	_ "github.com/lib/pq"
	_ "github.com/mattn/go-sqlite3"
)

func main() {
	db, err := sql.Open("sqlite3", ":memory:")
	if err != nil {
		panic(err)
	}
	defer db.Close()
	var v string
	if err := db.QueryRow("select sqlite_version()").Scan(&v); err != nil {
		panic(err)
	}
	fmt.Println("sqlite_version:", v)
}
