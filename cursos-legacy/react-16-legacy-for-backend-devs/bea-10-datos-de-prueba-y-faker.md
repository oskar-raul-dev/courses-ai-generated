# 🎲 Apéndice bea-10 — Datos de prueba y faker 🔥

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Consulta rápida · ~2 horas
> **Opcional dentro de un track ya opcional.** Lo referencian: `be03` (ejercicio 🔥 de volumen), `be05` y `be08`

---

Este apéndice existe por una razón práctica y una lección.

**La razón práctica:** las mediciones de `be05` —el saldo de miles de jugadores girando a la vez— y de `be08` —índices, tiempos de consulta— **no dicen nada con cuatro jugadores**. El `db.json` tiene cuatro. Hace falta volumen, y diez mil jugadores con su saldo y su inventario no se escriben a mano.

**La lección**, que es lo que de verdad justifica el apéndice y conviene tener clara antes de empezar:

> 🧭 **Un conjunto de datos aleatorio arruina una prueba de regresión.** El faker es una herramienta de **carga** y de **medición**, nunca de **aserción**. Una prueba que afirma sobre datos que cambian es una prueba que va a fallar sola algún martes, sin que nadie haya tocado nada, y una prueba que falla sola es una prueba que el equipo acaba ignorando.

---

## 🧭 Índice de salto rápido

1. [Tres clases de datos, tres propósitos](#1-tres-clases-de-datos-tres-propósitos)
2. [La semilla del `db.json`: el camino por defecto](#2-la-semilla-del-dbjson-el-camino-por-defecto)
3. [Volumen con `gofakeit`](#3-volumen-con-gofakeit)
4. [Fijar la semilla del generador](#4-fijar-la-semilla-del-generador)
5. [Datos que respetan el dominio](#5-datos-que-respetan-el-dominio)
6. [Limpiar y regenerar sin romper migraciones](#6-limpiar-y-regenerar-sin-romper-migraciones)
7. [Por qué el faker no sirve para afirmar](#7-por-qué-el-faker-no-sirve-para-afirmar)
8. [🧩 Cuándo usar qué](#-cuándo-usar-qué)

---

## 1. Tres clases de datos, tres propósitos

Confundirlas es el origen de casi todos los problemas de este tema:

| Clase | Para qué | Cuántos | ¿Se puede afirmar sobre ellos? |
|---|---|---|---|
| **Semilla** (`db.json`) | Usar la aplicación, el `smoke.sh`, el reemplazo de `be03` | 4 jugadores, 4 ruedas, la bitácora de la Fase 8 | ✅ Sí: son fijos y conocidos |
| **Fixtures de prueba** | Cada caso monta lo suyo | Los mínimos | ✅ Sí: los escribe la prueba |
| **Volumen** (faker) | Medir contención, índices, tiempos | Decenas de miles | ❌ **No.** §7 |

📖 **La regla que ordena las tres:** si vas a **afirmar** algo sobre un dato, ese dato lo escribiste tú. Si vas a **medir** algo, puede generarlo una máquina.

---

## 2. La semilla del `db.json`: el camino por defecto

**Esto no se reemplaza.** La siembra de `be03` sale del `db.json` que tienes desde la Fase 3, y eso es la mitad del efecto de aquella fase: el mock se apagó y la consola sigue mostrando **tus** ruedas.

```bash
go run ./cmd/seed -file ../mock/db.json
```

Es idempotente (`ON CONFLICT DO UPDATE`), conserva los ids originales y reajusta las secuencias. El faker de este apéndice **se suma** a eso, nunca lo sustituye.

> ⚠️ Y una consecuencia que hay que tener presente: `server/smoke.sh` verifica cosas concretas sobre el jugador 42 y la Rueda de fin de mes, y la rueda de medición de `be05` usa los jugadores 10001 a 10300. Si el faker pisara esos datos, el contrato dejaría de pasar y la medición mediría otra cosa. Por eso el generador del §3 **empieza en el id 100000**.

---

## 3. Volumen con `gofakeit`

```bash
cd server && go get github.com/brianvoe/gofakeit/v6@v6.19.0
```

```go
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
```

Y la bandera en el binario de siembra:

```go
	// bea-10: volumen para MEDIR, nunca para afirmar. Se suma a la siembra del db.json.
	volume := flag.Bool("volume", false, "genera jugadores con gofakeit en vez de sembrar el db.json")
	players := flag.Int("players", 10000, "cuántos jugadores genera -volume")
	seedValue := flag.Int64("seed", 42, "la semilla del generador: misma semilla, mismos datos")
	flag.Parse()

	cfg, err := config.LoadDatabase()
	if err != nil {
		log.Fatal(err)
	}
	db, err := storage.Open(context.Background(), cfg.DatabaseURL)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	start := time.Now()
	if *volume {
		if err := seed.GenerateVolume(context.Background(), db, *players, *seedValue); err != nil {
			log.Fatalf("el volumen falló: %v", err)
		}
		log.Printf("volumen: %d jugadores desde el id %d con -seed %d, en %s",
			*players, seed.FirstVolumeID, *seedValue, time.Since(start).Round(time.Millisecond))
		return
	}
```

```bash
go run ./cmd/seed -volume -players 10000 -seed 42
# volumen: 10000 jugadores desde el id 100000 con -seed 42, en 4.862s
```

Diez mil jugadores con su inventario, en una transacción, en unos cinco segundos (cinco corridas de 4,86 a 4,98 s en la máquina del autor).

> 📝 **`gofakeit` no es dependencia del binario del backend.** Vive en `internal/seed`, que solo importa `cmd/seed`. Medido con `go version -m`: el binario de la siembra la lista (`dep github.com/brianvoe/gofakeit/v6 v6.19.0`) y el de la API no la tiene. Si alguna vez el paquete `seed` termina importado desde el servidor, ese `go version -m` es lo primero que va a delatarlo.

> ⚠️ **Una sola transacción para diez mil jugadores está bien; para dos millones, no.** Una transacción enorme retiene recursos, hincha el WAL y frena al recolector. Si subes el volumen en serio, confirma por lotes de unos pocos miles. Y si necesitas cargar de verdad rápido, `COPY` de Postgres es la herramienta: es el ejercicio 6.

---

## 4. Fijar la semilla del generador

Es el detalle que separa un conjunto de datos **útil** de uno inservible. Con `gofakeit.New(seed)` y la misma semilla, la secuencia de valores es determinista. Medido con una huella `md5` de los diez mil jugadores, sobre bases recreadas desde cero:

| Corrida | Primeros tres jugadores | Huella de `players` |
|---|---|---|
| `-seed 42` | Jeromy R. (Chile) · Bernadette P. (Perú) · Estefania U. (Paraguay) | `0598755897…` |
| `-seed 42`, otra vez | los mismos | `0598755897…` |
| `-seed 43` | otros | `ce7e5d290c…` |

Eso te da tres cosas que sin semilla no tienes:

- **Comparar mediciones entre corridas.** Si la contención tardó distinto, fue el código o la máquina, **no los datos**.
- **Compartir un caso.** *"Corre con `-seed 42` y mira el jugador 100001"* funciona en la máquina de otra persona.
- **Reproducir un hallazgo.** Si el faker generó por casualidad el caso que rompe algo, con la semilla lo vuelves a generar. Sin ella, lo perdiste.

> 🧠 **Y aun con semilla fija, sigue sin servir para afirmar.** Determinista no es lo mismo que estable. Con la misma versión de `gofakeit` y la misma semilla, **una sola llamada de más** al generador antes del bucle —un `faker.Bool()` que alguien agregó para otra cosa— cambia todo lo que viene después: el primer jugador pasa de *Jeromy R., Chile* a *Adriana U., Colombia*, y la huella entera es otra. Es reproducible **dentro de un código y una versión**, no a través de ellos. Por eso el §7 no admite matices.

📝 La semilla fija es para los **datos de prueba**. El sorteo de la rueda quiere exactamente lo contrario —que dos arranques del binario no se parezcan en nada—, y por eso `be05` siembra el suyo desde `crypto/rand` (`D37`). Son dos usos del mismo mecanismo con requisitos opuestos, y confundirlos sale caro.

Anota siempre la semilla junto a la medición:

```markdown
<!-- server/evidence/concurrencia.md -->
Volumen: 10.000 jugadores desde el id 100000, `-seed 42`, gofakeit v6.19.0
Carga: escenario notificacion de server/load/giro.js, 200 VUs
```

Una medición sin su semilla no se puede repetir, y una medición que no se puede repetir no es una medición: es una anécdota.

---

## 5. Datos que respetan el dominio

Un generador que ignora las reglas del negocio produce basura que **parece** datos, y la basura se detecta tarde: en la mitad de una medición, cuando algo falla por un motivo que no tiene que ver con lo que medías. El generador de este apéndice lo demostró en su primera versión: `faker.LetterN(1)` devuelve minúsculas, y los primeros jugadores salieron como *"Jeromy r."*, en un sistema donde todos los nombres siguen la forma *"Juan P."*. Nada falló; la consola los habría mostrado así.

Las reglas de este dominio que el generador debe respetar:

| Regla | Si se ignora… |
|---|---|
| El saldo de giros nunca es negativo (historia §9) | La medición del saldo de `be05` empieza en un estado que el sistema no puede producir |
| El inventario son slugs de premios que existen en una rueda | La protección de duplicados de `be07` compara contra premios que no existen |
| Los nombres siguen la forma de los reales (*"Juan P."*) | La consola los muestra raros, y el ojo que revisa se acostumbra a ver datos raros |
| Los países son los del juego | Las mediciones por país de `be06` miden zonas que nadie usa |
| Los montos son enteros de centavos, no decimales | `A10` y `be07` dejan de cuadrar |

Y una que casi siempre se olvida: **las restricciones de la base ya te están ayudando**. Si el generador produce algo imposible, el `CHECK` del `status`, la clave primaria del inventario o el `UNIQUE` de la clave del giro lo rechazan. Un fallo al generar volumen es, la mitad de las veces, un generador que no entendió el dominio, y esa es una buena noticia: lo descubres en la carga y no en la medición.

**Si necesitas giros simulados** —para `be07` o para medir agregaciones—, genéralos **a través del servicio**, no con un `INSERT` directo en `spin_log`:

```bash
# ✅ Pasa por el giro de be05: respeta la transacción, el saldo, el stock y la clave.
#    Es más lento y produce datos que de verdad podrían existir.
curl -s -X POST -d '{"idempotencyKey":"vol-100000"}' localhost:3001/players/100000/spins
```

Un `INSERT` directo en la bitácora es rápido, y deja el saldo y el stock desincronizados con los giros: estás fabricando exactamente el estado que `be05` hizo imposible. Y además no se puede deshacer, que es el punto siguiente.

---

## 6. Limpiar y regenerar sin romper migraciones

Medido sobre la base de desarrollo, después de generar diez mil jugadores y girar cinco veces con jugadores del volumen:

```sql
DELETE FROM players WHERE id >= 100000;
-- ERROR:  23503: update or delete on table "players" violates foreign key
--         constraint "spin_requests_player_id_fkey" on table "spin_requests"
-- DETAIL:  Key (id)=(100001) is still referenced from table "spin_requests".

DELETE FROM spin_log WHERE player_id >= 100000;
-- ERROR:  spin_log solo se agrega: DELETE rechazado
```

Las dos negativas son correctas, y las dos son de `be05`. El pedido de giro referencia al jugador, y la bitácora **no se borra** (`D35`), ni siquiera para limpiar volumen de prueba. La consecuencia práctica: **un volumen que giró no se limpia, se recrea la base**.

```bash
# Volumen que NO giró: el corte por id basta (el inventario cae en cascada)
psql "$DATABASE_URL" -c "DELETE FROM players WHERE id >= 100000;"

# Volumen que giró, o empezar de cero: base nueva
migrate -path migrations/postgres -database "$DATABASE_URL" drop -f
migrate -path migrations/postgres -database "$DATABASE_URL" up
go run ./cmd/seed -file ../mock/db.json
go run ./cmd/seed -volume -players 10000 -seed 42
```

> ⚠️ **Nunca `TRUNCATE` en la base de desarrollo por costumbre.** Sobre `spin_log` ni siquiera funciona —el disparador de `D35` también lo rechaza—, y sobre el resto es el mecanismo de la suite de `be08`, que corre contra `esclusa_test`, no contra tus datos.

**Después de generar, actualiza las estadísticas.** Sin esto, el planificador de Postgres sigue creyendo lo que creía antes de la carga, y tu `EXPLAIN` medirá una fantasía. Medido con el *autovacuum* de `players` apagado, para que no se adelantara, justo después de generar:

```
EXPLAIN SELECT * FROM players WHERE country = 'Chile';
 Seq Scan on players  (cost=0.00..168.75 rows=28 width=120)      -- antes de ANALYZE
 Seq Scan on players  (cost=0.00..225.05 rows=1444 width=48)     -- después de ANALYZE
```

Las filas reales eran 1.444. Antes de `ANALYZE`, el planificador estimaba 28: cincuenta veces menos. Con una tabla de ese tamaño el plan es el mismo de todos modos, pero con un índice y un `JOIN` de por medio, esa estimación decide qué plan se elige.

```sql
ANALYZE players;
ANALYZE player_inventory;
```

---

## 7. Por qué el faker no sirve para afirmar

El punto que justifica el apéndice. Mira estas tres pruebas, que corren tal cual en `server/internal/spin/` con `TEST_DATABASE_URL` apuntando a Postgres:

```go
// server/internal/spin/ejemplos_test.go — los tres ejemplos de bea-10 §7

package spin_test

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/brianvoe/gofakeit/v6"

	"github.com/interoceanic-games/esclusa-api/internal/seed"
	"github.com/interoceanic-games/esclusa-api/internal/spin"
)

// ❌ Pasa hoy. Falla el día que alguien agregue una llamada al generador.
func TestVolumeFirstPlayer(t *testing.T) {
	db := openPostgres(t)
	if err := seed.GenerateVolume(context.Background(), db, 100, 42); err != nil {
		t.Fatal(err)
	}
	var name string
	db.Get(&name, `SELECT name FROM players WHERE id = 100000`)
	if name != "Jeromy R." { // ¿de dónde salió ese nombre?
		t.Fatalf("el primer jugador es %q", name)
	}
}

// ✅ Datos escritos por la prueba. Afirma sobre lo que la prueba decidió.
func TestSpinSpendsTheLastFreeSpin(t *testing.T) {
	db := openPostgres(t)
	measurementWheel(t, db, 1000, 1, 1) // un jugador, con un solo giro gratis
	svc := spin.NewService(db, spin.Pessimistic, 0, 30*time.Second)

	r, err := svc.Spin(context.Background(), 1, "unico")
	if err != nil {
		t.Fatal(err)
	}
	var free int
	db.Get(&free, `SELECT free_spins FROM players WHERE id = 1`)
	if *r.Origin != "free" || free != 0 {
		t.Fatalf("origen %q, saldo %d: esperaba free y 0", *r.Origin, free)
	}
}

// ✅ Datos generados, y la aserción es una PROPIEDAD, no un valor: para
// cualquier rueda cuyos pesos sumen 10.000, el sorteo cae en un segmento suyo.
func TestDrawAlwaysLandsOnTheWheel(t *testing.T) {
	faker := gofakeit.New(7)
	d := spin.NewDrawer()
	for w := 0; w < 1000; w++ {
		n := faker.Number(2, 8)
		segments := make([]spin.Segment, n)
		left := 10000
		for i := range segments {
			weight := left - (n - 1 - i) // lo que quede, si es el último
			if i < n-1 {
				weight = faker.Number(1, left-(n-1-i))
			}
			left -= weight
			segments[i] = spin.Segment{SegmentID: fmt.Sprintf("s%d", i), WeightBp: weight}
		}
		valid := map[string]bool{}
		for _, s := range segments {
			valid[s.SegmentID] = true
		}
		for k := 0; k < 100; k++ {
			if got := d.Draw(segments).SegmentID; !valid[got] {
				t.Fatalf("rueda %d: cayó en %q, que no está en %+v", w, got, segments)
			}
		}
	}
}
```

Las tres pasan hoy. Ahora agrega **una** llamada al generador al principio de `GenerateVolume` —un `_ = faker.Bool()`, nada más— y vuelve a correrlas:

```
--- FAIL: TestVolumeFirstPlayer (0.14s)
    ejemplos_test.go:26: el primer jugador es "Adriana U."
```

La primera tiene **cuatro** formas de romperse sin que nadie haya introducido un bug: actualizas `gofakeit`, alguien agrega una llamada al generador antes (la que acabas de ver), alguien cambia la cantidad de jugadores o el orden de los campos, o el generador empieza a usar el reloj para algo. Cuando falle, vas a pasar una hora buscando un bug que no existe.

La segunda es legible por sí sola: **un giro gratis, un giro, saldo cero, origen `free`.** Quien la lea dentro de dos años entiende qué se afirma y por qué.

> 🧭 **La regla, en una línea:** el faker llena la base para que **medir** tenga sentido; la prueba escribe sus propios datos para que **afirmar** tenga sentido. Nunca al revés.

**Y el matiz honesto, porque hay una excepción real.** La tercera usa datos generados —mil ruedas con pesos al azar— y es perfectamente legítima, porque no afirma un valor concreto: afirma una **invariante**. Para cualquier rueda cuyos pesos sumen 10.000, el sorteo cae en un segmento de esa rueda. Esa prueba no se rompe si cambia el generador, porque no depende de qué valores salgan: depende de que la propiedad se cumpla **para todos**. Es la diferencia entre *"el primer jugador se llama Jeromy R."* y *"el saldo nunca queda negativo"*.

📖 **Aserciones concretas sobre datos que tú escribiste. Aserciones de propiedad sobre datos generados. Mediciones sobre volumen. Y jamás una aserción concreta sobre volumen generado.**

---

## 🧩 Cuándo usar qué

| Si necesitas… | Usa | Y no |
|---|---|---|
| Usar la aplicación y correr `smoke.sh` | La semilla del `db.json` | Volumen generado |
| Probar una regla de negocio | Fixtures escritas en la prueba | El faker |
| Verificar una invariante para muchos casos | Generación + aserción de **propiedad** | Aserción de valor |
| Medir el saldo con miles de jugadores (`be05`) | Volumen con semilla fija | Los 300 jugadores de la rueda de medición |
| Medir un índice o un `EXPLAIN` (`be08`) | Volumen + `ANALYZE` | Volumen sin `ANALYZE` |
| Reproducir un hallazgo del generador | La misma `-seed`, el mismo código y la misma versión | Volver a generar al azar |
| Simular giros | El servicio (`POST /players/:id/spins`) | `INSERT` directo en `spin_log` |
| Limpiar el volumen | `DELETE … WHERE id >= 100000` si no giró; base nueva si giró | `TRUNCATE` en desarrollo |

---

## 🧪 Ejercicios (7)

1. **🟢** Genera 10.000 jugadores con `-seed 42` y comprueba con `count(*)` que están, y que el jugador 42 del `db.json` sigue intacto.
2. **🟢** Genera dos veces con la misma semilla, sobre bases recreadas, y compara la huella del §4. Después cambia la semilla y comprueba que no coincide.
3. **🟡** Corre `EXPLAIN ANALYZE` sobre una consulta por `country` antes y después de `ANALYZE`, con un índice sobre `country`. Explica por qué el plan cambia aunque los datos sean los mismos.
4. **🟡 Diagnóstico.** Haz que el generador produzca saldos negativos y corre el giro de `be05` con esos jugadores. Anota qué pasa y si algún error lo avisa.
5. **🟠** Repite la medición del saldo de `be05` (ejercicio 25) apuntando el arnés a los diez mil jugadores del volumen, y explica por qué los números cambian. Anota semilla y versión junto al resultado.
6. **🟠** Reescribe la carga con `COPY` en vez de `INSERT` y mide la diferencia con 200.000 jugadores. Decide a partir de qué volumen compensa.
7. **🔴 Diagnóstico.** Escribe la prueba mala del §7 con otro dato, hazla pasar, y después rómpela **sin tocar el código de producción** de tres maneras distintas. Documenta cuánto habrías tardado en diagnosticar cada una sin saber lo de este apéndice.

---

## 📚 Referencias

**Documentación oficial**
- https://github.com/brianvoe/gofakeit — el generador. Fija la v6.19.0 y revisa su registro de cambios antes de actualizar: **una versión nueva puede cambiar lo que produce una misma semilla** (§4).
- https://www.postgresql.org/docs/13/sql-copy.html — `COPY`, el ejercicio 6.
- https://www.postgresql.org/docs/13/sql-analyze.html y https://www.postgresql.org/docs/13/using-explain.html — por qué hace falta `ANALYZE` después de cargar.
- https://pkg.go.dev/testing/quick — la generación con propiedades en la biblioteca estándar. Antigua y limitada, pero explica bien la idea del §7.
- https://go.dev/doc/security/fuzz/ — el *fuzzing* nativo desde Go 1.18: generación de entradas con aserciones de propiedad, que es el pariente riguroso de esto.

**Libros**
- *Unit Testing: Principles, Practices, and Patterns* (Vladimir Khorikov) — su tratamiento de la legibilidad y del "¿de dónde salió ese número?" es el argumento del §7 desarrollado.

**Video / apoyo**
- Busca "property based testing explained". La mayoría del material es de Haskell o Scala; la idea traduce sin problema y es lo que da sentido a la excepción del §7.

**Orden de lectura sugerido:** el §7 primero —es el que decide si este apéndice te sirve o te mete en problemas— → el §4 antes de generar nada → y el resto cuando `be05` o `be08` te pidan volumen.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las referencias a libros y videos son de memoria y pueden ser inexactas. Las huellas y los nombres del §4 son de `gofakeit` v6.19.0 y de este código: con otra versión o con una llamada de más, los tuyos van a ser otros, que es exactamente la lección. La fuente de verdad de versiones es `00-decisiones-y-versiones.md` §7, donde `gofakeit` figura como dependencia **exclusiva de este apéndice**.

---

> 🏷️ **Este apéndice sí deja código.** `server/internal/seed/fake.go` y la bandera `-volume` del binario de siembra. Si lo haces:
>
> ```bash
> git tag -a apendice-bea-10-datos-de-prueba-y-faker -m "bea-10: \
> generador de volumen con gofakeit v6.19.0 y semilla fija, desde el id 100000; \
> respeta las reglas del dominio y no pisa la semilla del db.json ni la rueda de medición"
> ```
>
> Los commits van con el prefijo de la fase desde la que llegaste (`be03: …`, `be05: …`). La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
