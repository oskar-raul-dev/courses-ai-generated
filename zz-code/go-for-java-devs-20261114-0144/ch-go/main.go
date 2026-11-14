// ClearingHouse, versión Go de referencia para el duelo de la Fase 16.
//
// NO se publica con el curso (allí la versión Go es la que construye el lector): vive
// en zz-code para poder medir el gemelo Spring Boot contra algo. Sigue la Fase 13:
// fragmentos por cursor, punto de control en la misma transacción que los asientos,
// idempotencia confiada al índice único.
//
// Subcomandos: serve (por defecto) · seed --movements N --seed S · close --day D --chunk-size N
package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"log"
	"math/rand/v2"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"strings"
	"syscall"
	"time"

	"github.com/jackc/pgx/v5/pgconn"
	_ "github.com/jackc/pgx/v5/stdlib"
)

var version = "dev"

func main() {
	dsn := env("DATABASE_URL", "postgres://meridian:meridian@localhost:5432/meridian?sslmode=disable")
	db, err := sql.Open("pgx", dsn)
	if err != nil {
		log.Fatal(err)
	}
	db.SetMaxOpenConns(20)
	db.SetMaxIdleConns(20)

	cmd := "serve"
	if len(os.Args) > 1 {
		cmd = os.Args[1]
	}
	switch cmd {
	case "serve":
		serve(db)
	case "seed":
		fs := flag.NewFlagSet("seed", flag.ExitOnError)
		n := fs.Int("movements", 1000, "")
		seed := fs.Uint64("seed", 42, "")
		day := fs.String("day", "2026-09-11", "")
		_ = fs.Parse(os.Args[2:])
		must(seedDB(context.Background(), db, *n, *seed, *day))
	case "close":
		fs := flag.NewFlagSet("close", flag.ExitOnError)
		day := fs.String("day", "2026-09-11", "")
		chunk := fs.Int("chunk-size", 5000, "")
		_ = fs.Parse(os.Args[2:])
		start := time.Now()
		b, err := startRun(context.Background(), db, *day)
		must(err)
		must(runClose(context.Background(), db, b, *chunk))
		fmt.Printf("cierre %s completado en %s\n", *day, time.Since(start).Round(time.Millisecond))
	default:
		log.Fatalf("subcomando desconocido: %s", cmd)
	}
}

// ─── HTTP ────────────────────────────────────────────────────────────────────

func serve(db *sql.DB) {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, 200, map[string]string{"status": "ok"})
	})
	mux.HandleFunc("POST /sync/batches", func(w http.ResponseWriter, r *http.Request) { syncBatch(w, r, db) })
	mux.HandleFunc("GET /movements/{id}", func(w http.ResponseWriter, r *http.Request) { getMovement(w, r, db) })
	mux.HandleFunc("GET /movements", func(w http.ResponseWriter, r *http.Request) { listMovements(w, r, db) })
	mux.HandleFunc("POST /runs", func(w http.ResponseWriter, r *http.Request) { postRun(w, r, db) })
	mux.HandleFunc("GET /runs/{id}", func(w http.ResponseWriter, r *http.Request) { getRun(w, r, db) })

	srv := &http.Server{
		Addr: env("HTTP_ADDR", ":8080"), Handler: mux,
		ReadHeaderTimeout: 5 * time.Second, ReadTimeout: 15 * time.Second,
		WriteTimeout: 30 * time.Second, IdleTimeout: 120 * time.Second,
	}
	go func() {
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatal(err)
		}
	}()
	log.Printf("clearinghouse %s escuchando en %s", version, srv.Addr)
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, syscall.SIGINT, syscall.SIGTERM)
	<-stop
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	_ = srv.Shutdown(ctx)
}

type apiError struct {
	Error string `json:"error"`
	Code  string `json:"code"`
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func fail(w http.ResponseWriter, status int, code, msg string) {
	writeJSON(w, status, apiError{Error: msg, Code: code})
}

type movementIn struct {
	ExternalRef string    `json:"external_ref"`
	Type        string    `json:"type"`
	AmountMinor int64     `json:"amount_minor"`
	Currency    string    `json:"currency"`
	OccurredAt  time.Time `json:"occurred_at"`
}

type movementOut struct {
	ID          string    `json:"id"`
	StoreID     string    `json:"store_id"`
	ExternalRef string    `json:"external_ref"`
	Type        string    `json:"type"`
	AmountMinor int64     `json:"amount_minor"`
	Currency    string    `json:"currency"`
	OccurredAt  time.Time `json:"occurred_at"`
	Status      string    `json:"status"`
}

var validTypes = map[string]bool{"sale": true, "refund": true, "void": true, "withdrawal": true, "deposit": true}

func syncBatch(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	var in struct {
		StoreID   string       `json:"store_id"`
		Movements []movementIn `json:"movements"`
	}
	r.Body = http.MaxBytesReader(w, r.Body, 8<<20)
	if err := json.NewDecoder(r.Body).Decode(&in); err != nil {
		fail(w, 400, "bad_request", "el cuerpo no es JSON válido")
		return
	}
	if in.StoreID == "" || len(in.Movements) == 0 {
		fail(w, 400, "validation_failed", "store_id y movements son obligatorios")
		return
	}
	for _, m := range in.Movements {
		if m.ExternalRef == "" || !validTypes[m.Type] || len(m.Currency) != 3 || m.OccurredAt.IsZero() {
			fail(w, 400, "validation_failed", "movimiento inválido: "+m.ExternalRef)
			return
		}
	}
	tx, err := db.BeginTx(r.Context(), nil)
	if err != nil {
		fail(w, 503, "storage", err.Error())
		return
	}
	defer func() { _ = tx.Rollback() }()
	now := time.Now().UTC()
	accepted := 0
	for _, m := range in.Movements {
		res, err := tx.ExecContext(r.Context(), `INSERT INTO movements
			(id, store_id, external_ref, type, amount_minor, currency, occurred_at, received_at)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8) ON CONFLICT (store_id, external_ref) DO NOTHING`,
			in.StoreID+"-"+m.ExternalRef, in.StoreID, m.ExternalRef, m.Type, m.AmountMinor, m.Currency, m.OccurredAt.UTC(), now)
		if err != nil {
			var pg *pgconn.PgError
			if errors.As(err, &pg) && pg.Code == "23503" {
				fail(w, 404, "not_found", "la tienda no existe: "+in.StoreID)
				return
			}
			fail(w, 503, "storage", err.Error())
			return
		}
		n, _ := res.RowsAffected()
		accepted += int(n)
	}
	if err := tx.Commit(); err != nil {
		fail(w, 503, "storage", err.Error())
		return
	}
	writeJSON(w, 200, map[string]int{"accepted": accepted, "duplicates": len(in.Movements) - accepted})
}

const movementCols = `id, store_id, external_ref, type, amount_minor, currency, occurred_at, status`

func scanMovement(row interface{ Scan(...any) error }) (movementOut, error) {
	var m movementOut
	err := row.Scan(&m.ID, &m.StoreID, &m.ExternalRef, &m.Type, &m.AmountMinor, &m.Currency, &m.OccurredAt, &m.Status)
	m.OccurredAt = m.OccurredAt.UTC()
	return m, err
}

func getMovement(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	m, err := scanMovement(db.QueryRowContext(r.Context(),
		`SELECT `+movementCols+` FROM movements WHERE id = $1`, r.PathValue("id")))
	if errors.Is(err, sql.ErrNoRows) {
		fail(w, 404, "not_found", "el movimiento no existe")
		return
	}
	if err != nil {
		fail(w, 503, "storage", err.Error())
		return
	}
	writeJSON(w, 200, m)
}

func listMovements(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	q := r.URL.Query()
	store := q.Get("store")
	if store == "" {
		fail(w, 400, "validation_failed", "el parámetro store es obligatorio")
		return
	}
	limit := 50
	if s := q.Get("limit"); s != "" {
		n, err := strconv.Atoi(s)
		if err != nil || n < 1 || n > 500 {
			fail(w, 400, "validation_failed", "limit debe estar entre 1 y 500")
			return
		}
		limit = n
	}
	rows, err := db.QueryContext(r.Context(), `SELECT `+movementCols+` FROM movements
		WHERE store_id = $1 AND id > $2 ORDER BY id LIMIT $3`, store, q.Get("cursor"), limit)
	if err != nil {
		fail(w, 503, "storage", err.Error())
		return
	}
	defer rows.Close()
	items := make([]movementOut, 0, limit)
	for rows.Next() {
		m, err := scanMovement(rows)
		if err != nil {
			fail(w, 503, "storage", err.Error())
			return
		}
		items = append(items, m)
	}
	if err := rows.Err(); err != nil {
		fail(w, 503, "storage", err.Error())
		return
	}
	next := ""
	if len(items) == limit {
		next = items[len(items)-1].ID
	}
	writeJSON(w, 200, map[string]any{"items": items, "next_cursor": next})
}

// ─── El cierre ───────────────────────────────────────────────────────────────

type batch struct {
	ID            string `json:"id"`
	Day           string `json:"day"`
	Status        string `json:"status"`
	Checkpoint    string `json:"-"`
	TotalExpected int64  `json:"total_expected"`
	Processed     int64  `json:"processed"`
	ChunksDone    int    `json:"chunks_done"`
}

var errRunExists = errors.New("ya hay un cierre para ese día")

const dayFilter = `(m.occurred_at AT TIME ZONE s.time_zone)::date = $1::date AND m.status = 'received'`

func startRun(ctx context.Context, db *sql.DB, day string) (batch, error) {
	if _, err := time.Parse("2006-01-02", day); err != nil {
		return batch{}, fmt.Errorf("día inválido: %w", err)
	}
	b := batch{ID: "b-" + day, Day: day, Status: "running"}
	if err := db.QueryRowContext(ctx, `SELECT count(*) FROM movements m JOIN stores s ON s.id = m.store_id WHERE `+dayFilter,
		day).Scan(&b.TotalExpected); err != nil {
		return b, err
	}
	now := time.Now().UTC()
	_, err := db.ExecContext(ctx, `INSERT INTO batches (id, period_day, status, total_expected, started_at, updated_at)
		VALUES ($1, $2, 'running', $3, $4, $4)`, b.ID, day, b.TotalExpected, now)
	var pg *pgconn.PgError
	if errors.As(err, &pg) && pg.Code == "23505" {
		return b, errRunExists
	}
	return b, err
}

// accounts es la regla contable del duelo, la misma en las dos implementaciones:
// void no genera asientos; el resto, caja contra ventas o bancos.
func accounts(store, typ string, amount int64) (debit, credit string, signed int64, ok bool) {
	switch typ {
	case "sale":
		return "caja:" + store, "ventas", amount, true
	case "refund":
		return "caja:" + store, "ventas", -amount, true
	case "deposit":
		return "caja:" + store, "bancos", amount, true
	case "withdrawal":
		return "caja:" + store, "bancos", -amount, true
	}
	return "", "", 0, false
}

func runClose(ctx context.Context, db *sql.DB, b batch, chunk int) error {
	for {
		n, err := processChunk(ctx, db, &b, chunk)
		if err != nil {
			_, _ = db.ExecContext(ctx, `UPDATE batches SET status='failed', last_error=$2, updated_at=now() WHERE id=$1`, b.ID, err.Error())
			return err
		}
		if n < chunk {
			break
		}
	}
	_, err := db.ExecContext(ctx, `UPDATE batches SET status='completed', finished_at=now(), updated_at=now() WHERE id=$1`, b.ID)
	return err
}

// processChunk: un fragmento, una transacción, con el punto de control dentro.
func processChunk(ctx context.Context, db *sql.DB, b *batch, chunk int) (int, error) {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return 0, err
	}
	defer func() { _ = tx.Rollback() }()
	rows, err := tx.QueryContext(ctx, `SELECT m.id, m.store_id, m.type, m.amount_minor, m.currency
		FROM movements m JOIN stores s ON s.id = m.store_id
		WHERE `+dayFilter+` AND m.id > $2 ORDER BY m.id LIMIT $3`, b.Day, b.Checkpoint, chunk)
	if err != nil {
		return 0, err
	}
	type mv struct{ id, store, typ, cur string; amount int64 }
	var ms []mv
	for rows.Next() {
		var m mv
		if err := rows.Scan(&m.id, &m.store, &m.typ, &m.amount, &m.cur); err != nil {
			rows.Close()
			return 0, err
		}
		ms = append(ms, m)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return 0, err
	}
	if len(ms) == 0 {
		return 0, tx.Commit()
	}
	now := time.Now().UTC()
	var vals []string
	var args []any
	var matched, unmatched []string
	for _, m := range ms {
		debit, credit, signed, ok := accounts(m.store, m.typ, m.amount)
		if !ok {
			unmatched = append(unmatched, m.id)
			continue
		}
		matched = append(matched, m.id)
		for _, e := range [2]struct{ acc string; amt int64 }{{debit, signed}, {credit, -signed}} {
			i := len(args)
			vals = append(vals, fmt.Sprintf("($%d,$%d,$%d,$%d,$%d,$%d)", i+1, i+2, i+3, i+4, i+5, i+6))
			args = append(args, b.ID, m.id, e.acc, e.amt, m.cur, now)
		}
	}
	if len(vals) > 0 {
		if _, err := tx.ExecContext(ctx, `INSERT INTO ledger_entries (batch_id, movement_id, account, amount_minor, currency, created_at)
			VALUES `+strings.Join(vals, ",")+` ON CONFLICT (movement_id, account) DO NOTHING`, args...); err != nil {
			return 0, err
		}
	}
	for status, ids := range map[string][]string{"matched": matched, "unmatched": unmatched} {
		if len(ids) > 0 {
			if _, err := tx.ExecContext(ctx, `UPDATE movements SET status = $1 WHERE id = ANY($2)`, status, ids); err != nil {
				return 0, err
			}
		}
	}
	b.Checkpoint = ms[len(ms)-1].id
	b.Processed += int64(len(ms))
	b.ChunksDone++
	if _, err := tx.ExecContext(ctx, `UPDATE batches SET checkpoint=$2, processed=$3, chunks_done=$4, updated_at=now() WHERE id=$1`,
		b.ID, b.Checkpoint, b.Processed, b.ChunksDone); err != nil {
		return 0, err
	}
	return len(ms), tx.Commit()
}

func postRun(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	var in struct {
		Day       string `json:"day"`
		ChunkSize int    `json:"chunk_size"`
	}
	if err := json.NewDecoder(r.Body).Decode(&in); err != nil || in.Day == "" {
		fail(w, 400, "validation_failed", "day es obligatorio (AAAA-MM-DD)")
		return
	}
	if in.ChunkSize <= 0 {
		in.ChunkSize = 5000
	}
	b, err := startRun(r.Context(), db, in.Day)
	switch {
	case errors.Is(err, errRunExists):
		fail(w, 409, "conflict", err.Error())
		return
	case err != nil && strings.HasPrefix(err.Error(), "día inválido"):
		fail(w, 400, "validation_failed", err.Error())
		return
	case err != nil:
		fail(w, 503, "storage", err.Error())
		return
	}
	go func() {
		if err := runClose(context.Background(), db, b, in.ChunkSize); err != nil {
			log.Printf("cierre %s falló: %v", b.ID, err)
		}
	}()
	writeJSON(w, 202, b)
}

func getRun(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	var b batch
	var day time.Time
	err := db.QueryRowContext(r.Context(), `SELECT id, period_day, status, total_expected, processed, chunks_done
		FROM batches WHERE id = $1`, r.PathValue("id")).Scan(&b.ID, &day, &b.Status, &b.TotalExpected, &b.Processed, &b.ChunksDone)
	if errors.Is(err, sql.ErrNoRows) {
		fail(w, 404, "not_found", "el cierre no existe")
		return
	}
	if err != nil {
		fail(w, 503, "storage", err.Error())
		return
	}
	b.Day = day.Format("2006-01-02")
	writeJSON(w, 200, b)
}

// ─── Datos de prueba ─────────────────────────────────────────────────────────

func seedDB(ctx context.Context, db *sql.DB, n int, seed uint64, day string) error {
	d, err := time.Parse("2006-01-02", day)
	if err != nil {
		return err
	}
	r := rand.New(rand.NewPCG(seed, 0))
	stores := []struct{ id, tz string }{{"ST-001", "America/Bogota"}, {"ST-002", "America/Mexico_City"},
		{"ST-003", "America/Lima"}, {"ST-004", "America/Santiago"}, {"ST-005", "America/Bogota"}}
	for _, s := range stores {
		if _, err := db.ExecContext(ctx, `INSERT INTO stores VALUES ($1,$1,'COP',$2) ON CONFLICT DO NOTHING`, s.id, s.tz); err != nil {
			return err
		}
	}
	types := []string{"sale", "sale", "sale", "sale", "refund", "void", "deposit", "withdrawal"}
	const per = 1000
	for off := 0; off < n; off += per {
		var vals []string
		var args []any
		for i := off; i < off+per && i < n; i++ {
			s := stores[r.IntN(len(stores))]
			loc, _ := time.LoadLocation(s.tz)
			at := time.Date(d.Year(), d.Month(), d.Day(), 0, 0, 0, 0, loc).Add(time.Duration(r.IntN(86400)) * time.Second)
			ref := fmt.Sprintf("R%08d", i)
			k := len(args)
			vals = append(vals, fmt.Sprintf("($%d,$%d,$%d,$%d,$%d,'COP',$%d,$%d)", k+1, k+2, k+3, k+4, k+5, k+6, k+6))
			args = append(args, s.id+"-"+ref, s.id, ref, types[r.IntN(len(types))], int64(1000+r.IntN(500000)), at.UTC())
		}
		if _, err := db.ExecContext(ctx, `INSERT INTO movements (id, store_id, external_ref, type, amount_minor, currency, occurred_at, received_at)
			VALUES `+strings.Join(vals, ",")+` ON CONFLICT DO NOTHING`, args...); err != nil {
			return err
		}
	}
	fmt.Printf("sembrados %d movimientos para %s\n", n, day)
	return nil
}

func env(k, def string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return def
}

func must(err error) {
	if err != nil {
		log.Fatal(err)
	}
}
