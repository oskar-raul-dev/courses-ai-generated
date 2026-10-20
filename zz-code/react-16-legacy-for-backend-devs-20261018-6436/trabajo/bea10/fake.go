// server/internal/seed/fake.go

package seed

import (
	"context"
	"fmt"
	"strings"

	"github.com/brianvoe/gofakeit/v6"

	"github.com/interoceanic-games/esclusa-api/internal/storage"
)

// FirstVolumeID es donde empieza el volumen: lejos de los jugadores del
// db.json (42 a 45), de los que dependen smoke.sh y las pruebas de contrato, y
// de los 300 de la rueda de medición de be05 (10001 a 10300).
const FirstVolumeID = 100000

// GenerateVolume crea jugadores, con saldo e inventario, para poder MEDIR.
//
// 🧭 Lo que genera no sirve para afirmar nada (§7). Sirve para que una
// medición de contención o un EXPLAIN digan algo.
func GenerateVolume(ctx context.Context, db *storage.DB, players int, seed int64) error {
	// La semilla FIJA es lo que hace reproducible el conjunto (§4).
	faker := gofakeit.New(seed)
	countries := []string{"Panamá", "Colombia", "México", "Perú", "Chile", "Paraguay", "Costa Rica"}
	collectibles := []string{"avatar-comun", "avatar-raro", "set-gemas-basico", "set-gemas-plata"}

	tx, err := db.BeginTxx(ctx, nil)
	if err != nil {
		return fmt.Errorf("abriendo la transacción de volumen: %w", err)
	}
	defer tx.Rollback()

	for i := 0; i < players; i++ {
		id := int64(FirstVolumeID + i)
		// El nombre lo lee un humano y va como en el db.json: "Juan P.".
		name := fmt.Sprintf("%s %s.", faker.FirstName(), strings.ToUpper(faker.LetterN(1)))
		_, err := tx.ExecContext(ctx, db.Rebind(`
			INSERT INTO players (id, name, country, status, free_spins, paid_spins)
			VALUES (?, ?, ?, 'active', ?, ?)
			ON CONFLICT (id) DO NOTHING`),
			id, name, faker.RandomString(countries),
			faker.Number(0, 3),   // gratis: uno cada 10 niveles y uno cada 4 horas
			faker.Number(0, 500)) // pagos: hasta un paquete de 500
		if err != nil {
			return fmt.Errorf("generando el jugador %d: %w", id, err)
		}
		// El inventario: lo que el jugador ya tiene, y que la protección de
		// duplicados de be07 no le va a repetir.
		for _, prize := range collectibles {
			if !faker.Bool() {
				continue
			}
			_, err := tx.ExecContext(ctx, db.Rebind(`
				INSERT INTO player_inventory (player_id, prize) VALUES (?, ?)
				ON CONFLICT (player_id, prize) DO NOTHING`), id, prize)
			if err != nil {
				return fmt.Errorf("generando el inventario del jugador %d: %w", id, err)
			}
		}
	}
	return tx.Commit()
}
