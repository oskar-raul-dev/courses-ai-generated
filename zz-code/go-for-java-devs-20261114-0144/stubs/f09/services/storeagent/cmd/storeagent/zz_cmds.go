package main

// Completado en zz-code: la F09 enumera los subcomandos y no los escribe. Versión mínima
// para comprobar el esquema, el WAL y las restricciones.

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"flag"
	"fmt"
	"os"
	"time"

	"github.com/meridian/storeagent/internal/sqlite"
)

const schema = `CREATE TABLE IF NOT EXISTS movements (
    id TEXT PRIMARY KEY, store_id TEXT NOT NULL, occurred_at TEXT NOT NULL, kind TEXT NOT NULL,
    amount_minor INTEGER NOT NULL, currency TEXT NOT NULL, synced_at TEXT, content_hash TEXT NOT NULL,
    CHECK (kind IN ('SALE','REFUND','VOID','DEPOSIT','WITHDRAWAL')),
    CHECK (currency GLOB '[A-Z][A-Z][A-Z]'), CHECK (length(occurred_at) = 20));
CREATE UNIQUE INDEX IF NOT EXISTS movements_hash_idx ON movements (content_hash);`

func dbPath() string {
	if p := os.Getenv("STOREAGENT_DB"); p != "" {
		return p
	}
	return "/tmp/storeagent.db"
}

func usage() { fmt.Fprintln(os.Stderr, "uso: storeagent record|list|sync|status") }

func runRecord(ctx context.Context, args []string) error {
	fs := flag.NewFlagSet("record", flag.ContinueOnError)
	kind := fs.String("kind", "SALE", "")
	amount := fs.Int64("amount", 0, "")
	cur := fs.String("currency", "COP", "")
	if err := fs.Parse(args); err != nil {
		return err
	}
	db, err := sqlite.Open(ctx, dbPath())
	if err != nil {
		return err
	}
	defer db.Close()
	if _, err := db.ExecContext(ctx, schema); err != nil {
		return err
	}
	now := time.Now().UTC().Format("2006-01-02T15:04:05Z")
	sum := sha256.Sum256([]byte(fmt.Sprint("ST-014", now, *kind, *amount, *cur)))
	h := hex.EncodeToString(sum[:])
	_, err = db.ExecContext(ctx, `INSERT INTO movements VALUES (?, 'ST-014', ?, ?, ?, ?, NULL, ?)`, h[:12], now, *kind, *amount, *cur, h)
	return err
}

func runList(ctx context.Context, args []string) error { return errors.New("list: no completado") }
func runSync(ctx context.Context, args []string) error { return errors.New("sync: es de la Fase 10") }

func runStatus(ctx context.Context, args []string) error {
	db, err := sqlite.Open(ctx, dbPath())
	if err != nil {
		return err
	}
	defer db.Close()
	var mode string
	var n int
	if err := db.QueryRowContext(ctx, "PRAGMA journal_mode").Scan(&mode); err != nil {
		return err
	}
	if err := db.QueryRowContext(ctx, "SELECT count(*) FROM movements").Scan(&n); err != nil {
		return err
	}
	fmt.Printf("journal_mode=%s movimientos=%d\n", mode, n)
	return nil
}
