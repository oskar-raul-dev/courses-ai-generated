// server/internal/spin/spin.go

package spin

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"github.com/interoceanic-games/esclusa-api/internal/jsontime"
	"github.com/interoceanic-games/esclusa-api/internal/storage"
)

// Spin es una fila de la bitácora. Los punteros con omitempty no están por
// gusto de Go: el giro de 2019 escribe filas sin rueda, sin origen y sin premio
// entregado (be00, C-03), y en el mock esos campos NO EXISTEN en la fila. Un
// puntero nil con omitempty los omite, y la respuesta queda igual a la del mock.
type Spin struct {
	ID             int64        `json:"id"                       db:"id"`
	WheelID        *int64       `json:"wheelId,omitempty"        db:"wheel_id"`
	WheelVersion   *int         `json:"wheelVersion,omitempty"   db:"wheel_version"`
	PlayerID       int64        `json:"playerId"                 db:"player_id"`
	LandedSegment  string       `json:"landedSegment"            db:"landed_segment"`
	DeliveredPrize *string      `json:"deliveredPrize,omitempty" db:"delivered_prize"`
	Origin         *string      `json:"origin,omitempty"         db:"origin"`
	PurchaseToken  *string      `json:"purchaseToken,omitempty"  db:"purchase_token"`
	IdempotencyKey string       `json:"idempotencyKey"           db:"idempotency_key"`
	CreatedAt      jsontime.ISO `json:"createdAt"                db:"created_at"`
}

type Stock struct {
	ID        int64  `json:"id"        db:"id"`
	WheelID   int64  `json:"wheelId"   db:"wheel_id"`
	SegmentID string `json:"segmentId" db:"segment_id"`
	Remaining int    `json:"remaining" db:"remaining"`
}

// Filter son los filtros por campo de json-server que se usan: la consola filtra
// por rueda (C-02); por clave y por jugador son para diagnosticar desde curl.
type Filter struct {
	WheelID        *int64
	IdempotencyKey string
	PlayerID       *int64
}

var (
	ErrMissingKey = errors.New("falta idempotencyKey")
	ErrSoldOut    = errors.New("agotado")
)

// GoldenSegment es el segmento que mide el giro de la Fase 3: la Esclusa de Oro.
const GoldenSegment = "esclusa-de-oro"

type Service struct{ db *storage.DB }

func NewService(db *storage.DB) *Service { return &Service{db: db} }

// Log devuelve la bitácora entera que pide el filtro, sin paginar: es régimen
// estricto (be00), y con la Semana del Canal sembrada son 180.000 filas.
func (s *Service) Log(ctx context.Context, f Filter) ([]Spin, error) {
	query := `SELECT id, wheel_id, wheel_version, player_id, landed_segment, delivered_prize,
	                 origin, purchase_token, idempotency_key, created_at
	          FROM spin_log WHERE 1 = 1`
	args := []interface{}{}
	if f.WheelID != nil {
		query += ` AND wheel_id = ?`
		args = append(args, *f.WheelID)
	}
	if f.IdempotencyKey != "" {
		query += ` AND idempotency_key = ?`
		args = append(args, f.IdempotencyKey)
	}
	if f.PlayerID != nil {
		query += ` AND player_id = ?`
		args = append(args, *f.PlayerID)
	}
	spins := []Spin{}
	if err := s.db.SelectContext(ctx, &spins, s.db.Rebind(query+` ORDER BY id`), args...); err != nil {
		return nil, fmt.Errorf("leyendo la bitácora: %w", err)
	}
	return spins, nil
}

func (s *Service) Stock(ctx context.Context) ([]Stock, error) {
	stock := []Stock{}
	if err := s.db.SelectContext(ctx, &stock, `SELECT id, wheel_id, segment_id, remaining FROM stock ORDER BY id`); err != nil {
		return nil, fmt.Errorf("leyendo el stock: %w", err)
	}
	return stock, nil
}

// NaiveSpin es el giro de 2019, reimplementado tal cual: tres viajes a la base,
// sin transacción, y la clave de idempotencia se anota pero nadie la mira.
// 1) leer el stock, 2) decidir, 3) descontar y anotar. Como el giro de medición
// de la Fase 3, siempre cae en la Esclusa de Oro.
//
// 💸 Es el mismo if del mock traducido de lenguaje, y sigue sin proteger nada
// bajo concurrencia. Ahora la deuda está escrita en un lenguaje compilado, que
// es peor porque parece seria. La paga be05 (C-01, C-03).
func (s *Service) NaiveSpin(ctx context.Context, playerID int64, idempotencyKey string) (string, error) {
	if idempotencyKey == "" {
		return "", ErrMissingKey
	}
	var remaining int // viaje 1: leer
	err := s.db.GetContext(ctx, &remaining, s.db.Rebind(`
		SELECT remaining FROM stock WHERE segment_id = ? ORDER BY id LIMIT 1`), GoldenSegment)
	if errors.Is(err, sql.ErrNoRows) || (err == nil && remaining <= 0) {
		return "", ErrSoldOut // decidir, con lo que se leyó
	}
	if err != nil {
		return "", fmt.Errorf("leyendo el stock: %w", err)
	}

	// viaje 2: el descuento, relativo al valor actual; la decisión ya se tomó.
	_, err = s.db.ExecContext(ctx, s.db.Rebind(`
		UPDATE stock SET remaining = remaining - 1
		WHERE id = (SELECT id FROM stock WHERE segment_id = ? ORDER BY id LIMIT 1)`), GoldenSegment)
	if err != nil {
		return "", fmt.Errorf("descontando el stock: %w", err)
	}

	// viaje 3: la bitácora, con la forma pobre de 2019 (sin rueda ni origen).
	_, err = s.db.ExecContext(ctx, s.db.Rebind(`
		INSERT INTO spin_log (player_id, idempotency_key, landed_segment) VALUES (?, ?, ?)`),
		playerID, idempotencyKey, GoldenSegment)
	if err != nil {
		return "", fmt.Errorf("anotando el giro: %w", err)
	}
	return GoldenSegment, nil
}
