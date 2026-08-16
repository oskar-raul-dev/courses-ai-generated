# 🎲 Apéndice bea-10 — Datos de prueba y faker 🔥

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~2 horas
> **Opcional dentro de un track ya opcional.** Lo referencian: `be03` (ejercicio 🔥 de volumen), `be05` y `be08`

---

Este apéndice existe por una razón práctica y una lección.

**La razón práctica:** las mediciones de `be05` —contención con 50 vendedores— y
de `be08` —índices, tiempos de consulta— **no dicen nada con dos rifas y cuatro
números**. Hace falta volumen, y cincuenta rifas con veinte mil números no se
escriben a mano.

**La lección**, que es lo que de verdad justifica el apéndice y conviene tener
clara antes de empezar:

> 🧭 **Un conjunto de datos aleatorio arruina una prueba de regresión.** El faker
> es una herramienta de **carga** y de **medición**, nunca de **aserción**. Una
> prueba que afirma sobre datos que cambian en cada corrida es una prueba que va a
> fallar sola algún martes, sin que nadie haya tocado nada — y una prueba que
> falla sola es una prueba que el equipo acaba ignorando.

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
| **Semilla** (`db.json`) | Usar la aplicación, el `smoke.sh`, el reemplazo de `be03` | 1 rifa, 2 números | ✅ Sí: son fijos y conocidos |
| **Fixtures de prueba** | Cada caso monta lo suyo | Los mínimos | ✅ Sí: los escribe el test |
| **Volumen** (faker) | Medir contención, índices, tiempos | Decenas de miles | ❌ **No.** §7 |

📖 **La regla que ordena las tres:** si vas a **afirmar** algo sobre un dato, ese
dato lo escribiste tú. Si vas a **medir** algo, puede generarlo una máquina.

---

## 2. La semilla del `db.json`: el camino por defecto

**Esto no se reemplaza.** La siembra de `be03` sale del `db.json` que el alumno
tiene desde la Fase 3, y eso es la mitad del efecto de aquella fase: el mock se
apagó y la aplicación sigue mostrando **tus** rifas.

```bash
go run ./cmd/seed -file ../mock/db.json
```

Es idempotente (`ON CONFLICT DO UPDATE`), conserva los ids originales y reajusta
las secuencias. El faker de este apéndice **se suma** a eso, nunca lo sustituye.

> ⚠️ Y una consecuencia que hay que tener presente: `server/smoke.sh` verifica
> cosas concretas sobre la rifa 1 y el número `0347`. Si el faker pisara esos
> datos, el checklist de contrato dejaría de pasar. Por eso el generador del §3
> **empieza a partir del id 100**.

---

## 3. Volumen con `gofakeit`

```bash
cd server && go get github.com/brianvoe/gofakeit/v6@v6.19.0
```

> 📝 `gofakeit` **no es dependencia del backend**: vive en el paquete de siembra y
> el binario de producción no la incluye. Si quieres asegurarlo, ponla detrás de
> una etiqueta de compilación, igual que `be09` hizo con el driver de SQLite.

```go
// server/internal/seed/fake.go
package seed

import (
	"context"
	"fmt"
	"time"

	"github.com/brianvoe/gofakeit/v6"
	"github.com/rifas-y-chances/raffles-api/internal/storage"
)

// GenerateVolume crea rifas con sus números para poder MEDIR.
//
// 🧭 Los datos que genera no sirven para afirmar nada (§7). Sirven para que
// una medición de contención o un EXPLAIN digan algo.
//
// Empieza en el id 100 para no pisar la semilla del db.json, de la que
// dependen smoke.sh y las pruebas de contrato.
func GenerateVolume(ctx context.Context, db *storage.DB, raffles, numbersPerRaffle int, seed uint64) error {
	// La semilla FIJA es lo que hace reproducible el conjunto (§4).
	faker := gofakeit.New(seed)

	tx, err := db.BeginTxx(ctx, nil)
	if err != nil {
		return fmt.Errorf("abriendo la transacción de volumen: %w", err)
	}
	defer tx.Rollback()

	for i := 0; i < raffles; i++ {
		id := int64(100 + i)

		// Las reglas del dominio se respetan al generar (§5): el precio y
		// el premio son enteros de centavos, y el estado es coherente con
		// la hora de cierre.
		closesAt := time.Now().Add(time.Duration(faker.Number(-720, 720)) * time.Hour)
		status := "open"
		if closesAt.Before(time.Now()) {
			status = "closed"
		}

		_, err := tx.ExecContext(ctx, db.Rebind(`
			INSERT INTO raffles (id, name, lottery_id, closes_at, number_price, base_prize, status)
			VALUES (?, ?, ?, ?, ?, ?, ?)
			ON CONFLICT (id) DO NOTHING`),
			id,
			// El nombre lo lee un humano y va en español, igual que en el
			// db.json: es dato de dominio, no identificador.
			fmt.Sprintf("Rifa %s %d", faker.RandomString([]string{"del barrio", "de fin de mes", "del colegio"}), id),
			faker.RandomString([]string{"boyaca", "cruzverde", "meta"}),
			closesAt,
			int64(faker.Number(1, 20))*100000,   // 1.000 a 20.000 pesos, en centavos
			int64(faker.Number(1, 50))*1000000,  // 10.000 a 500.000 pesos
			status)
		if err != nil {
			return fmt.Errorf("generando la rifa %d: %w", id, err)
		}

		for n := 0; n < numbersPerRaffle; n++ {
			// El número es TEXT con ceros a la izquierda: contrato de be00.
			// Un %04d aquí y un INTEGER allá romperían el tablero de la
			// Fase 5 sin un solo error en consola.
			number := fmt.Sprintf("%04d", n)

			_, err := tx.ExecContext(ctx, db.Rebind(`
				INSERT INTO raffle_numbers (raffle_id, number, status)
				VALUES (?, ?, 'available')
				ON CONFLICT (raffle_id, number) DO NOTHING`),
				id, number)
			if err != nil {
				return fmt.Errorf("generando el número %s de la rifa %d: %w", number, id, err)
			}
		}
	}

	return tx.Commit()
}
```

```bash
# 50 rifas × 400 números = 20.000 números, en una transacción.
go run ./cmd/seed -volume -raffles 50 -numbers 400 -seed 42
```

> ⚠️ **Una sola transacción para veinte mil filas está bien; para dos millones,
> no.** Una transacción enorme retiene recursos, hincha el WAL y bloquea el
> recolector. Si subes el volumen en serio, confirma por lotes de unos pocos
> miles. Y si necesitas cargar de verdad rápido, `COPY` de Postgres es un orden de
> magnitud más veloz que `INSERT` fila a fila — es el ejercicio 6.

---

## 4. Fijar la semilla del generador

Es el detalle que separa un conjunto de datos **útil** de uno inservible.

```go
faker := gofakeit.New(42)   // ✅ misma semilla → mismos datos, siempre
faker := gofakeit.New(0)    // ❌ semilla del reloj → datos distintos cada vez
```

Con semilla fija, la secuencia de valores es determinista: `-seed 42` produce hoy
y dentro de seis meses exactamente las mismas cincuenta rifas. Eso te da tres
cosas que sin ella no tienes:

- **Comparar mediciones entre corridas.** Si la contención tardó distinto, fue el
  código o la máquina, **no los datos**.
- **Compartir un caso.** *"Corre con `-seed 42` y mira la rifa 137"* funciona en la
  máquina de otra persona.
- **Reproducir un hallazgo.** Si el faker generó por casualidad el caso que rompe
  algo, con la semilla lo vuelves a generar. Sin ella, lo perdiste.

> 🧠 **Y aun con semilla fija, sigue sin servir para afirmar.** Determinista no es
> lo mismo que estable: basta con actualizar la versión de `gofakeit` —o cambiar
> el orden de dos llamadas al generador— para que los mismos 42 produzcan otros
> datos. Es reproducible **dentro de una versión y un código**, no a través de
> ellos. Por eso el §7 no admite matices.

Anota siempre la semilla junto a la medición:

```markdown
<!-- server/evidence/concurrencia.md -->
Volumen: 50 rifas × 400 números, `-seed 42`, gofakeit v6.19.0
Contención: 50 goroutines sobre el número 0347 de la rifa 137
p50 12ms · p95 148ms · ganadores 1 · conflictos 49
```

Una medición sin su semilla no se puede repetir, y una medición que no se puede
repetir no es una medición: es una anécdota.

---

## 5. Datos que respetan el dominio

Un generador que ignora las reglas del negocio produce basura que **parece**
datos, y la basura se detecta tarde: en la mitad de una medición, cuando algo
falla por un motivo que no tiene que ver con lo que medías.

Las cuatro reglas de este dominio que el generador debe respetar:

| Regla | Si se ignora… |
|---|---|
| Una rifa cerrada no puede tener ventas **posteriores** a su `closesAt` | La liquidación de `be07` calcula sobre datos imposibles |
| El `status` de la rifa es coherente con su hora de cierre | El *worker* de `be06` "cierra" cientos de rifas en el primer tick |
| El `number` es `TEXT` de cuatro dígitos con ceros a la izquierda | El tablero de la Fase 5 se rompe sin un error en consola |
| Los montos son enteros de centavos, no decimales | `A10` y `be07` dejan de cuadrar |

Y una que casi siempre se olvida: **las restricciones de la base ya te están
ayudando**. Si el generador produce algo imposible, el `CHECK` del `status` o el
`UNIQUE (raffle_id, number)` lo rechazan. Un fallo al generar volumen es, la
mitad de las veces, un generador que no entendió el dominio — y esa es una buena
noticia, porque lo descubres en la carga y no en la medición.

**Si necesitas ventas simuladas** —para `be07` o para medir agregaciones—,
genéralas **a través del servicio**, no con un `INSERT` directo:

```go
// ✅ Pasa por SellNumber: respeta la transacción, la hora dura y el índice.
//    Es más lento y produce datos que de verdad podrían existir.
for _, n := range aVender {
    _, _ = svc.SellNumber(ctx, raffleID, n, nil)
}

// ❌ INSERT directo en sales: rápido, y puede dejar el estado de
//    raffle_numbers desincronizado con las ventas. Estás fabricando
//    exactamente el bug que be05 hizo imposible.
```

---

## 6. Limpiar y regenerar sin romper migraciones

```bash
# Borrar SOLO el volumen, conservando la semilla del db.json:
psql "$DATABASE_URL" -c "DELETE FROM raffles WHERE id >= 100;"
# el ON DELETE CASCADE de raffle_numbers se encarga del resto

# Empezar de cero, esquema incluido:
migrate -path migrations/postgres -database "$DATABASE_URL" down -all
migrate -path migrations/postgres -database "$DATABASE_URL" up
go run ./cmd/seed -file ../mock/db.json
go run ./cmd/seed -volume -raffles 50 -numbers 400 -seed 42
```

> ⚠️ **Nunca `TRUNCATE` en la base de desarrollo por costumbre.** Ese es el
> mecanismo de la suite de `be08`, que corre contra `rifas_test` y **comprueba el
> nombre antes de ejecutarse**. Aquí, el corte por `id >= 100` es lo que separa el
> volumen de tus datos.
>
> Y borrar rifas con liquidaciones **falla a propósito**: `prize_payouts` tiene
> `ON DELETE RESTRICT` (`be07`). En dinero, el borrado en cascada silencioso es
> exactamente lo que no quieres. Si el volumen incluye liquidaciones, bórralas en
> orden explícito.

**Después de generar, actualiza las estadísticas.** Sin esto, el planificador de
Postgres sigue creyendo que la tabla tiene cuatro filas y elige planes absurdos —
y tu `EXPLAIN` medirá una fantasía:

```sql
ANALYZE raffle_numbers;
ANALYZE sales;
```

---

## 7. Por qué el faker no sirve para afirmar

El punto que justifica el apéndice. Mira estas dos pruebas:

```go
// ❌ Pasa hoy. Falla algún martes, sola, sin que nadie toque nada.
func TestRecaudoDeLaRifa(t *testing.T) {
	seedVolume(t, 42)
	total := svc.TotalCollected(ctx, 137)
	require.Equal(t, int64(4200000), total)   // ¿de dónde salió ese número?
}

// ✅ Datos escritos por el test. Afirma sobre lo que el test decidió.
func TestRecaudoDeLaRifa(t *testing.T) {
	raffle := insertRaffle(t, withNumberPrice(500000))
	sellNumbers(t, raffle.ID, "0001", "0002", "0003")
	require.Equal(t, int64(1500000), svc.TotalCollected(ctx, raffle.ID))
}
```

La primera tiene **cuatro** formas de romperse sin que nadie haya introducido un
bug: actualizas `gofakeit`, alguien agrega una llamada al generador antes (y
corre la secuencia entera), alguien cambia el número de rifas, o el generador
usa el reloj para algo. Cuando falle, vas a pasar una hora buscando un bug que no
existe.

La segunda es legible por sí sola: **`500000 × 3 = 1500000`**. Quien la lea dentro
de dos años entiende qué se afirma y por qué.

> 🧭 **La regla, en una línea:** el faker llena la base para que **medir** tenga
> sentido; el test escribe sus propios datos para que **afirmar** tenga sentido.
> Nunca al revés.

**Y el matiz honesto, porque hay una excepción real.** Las pruebas **basadas en
propiedades** sí usan datos generados, y son perfectamente legítimas — pero no
afirman valores concretos: afirman **invariantes**. La de `be07` es el ejemplo:

```go
// ✅ Datos generados, y la aserción es una PROPIEDAD, no un número.
for prize := int64(0); prize <= 1000; prize++ {
    for winners := 1; winners <= 17; winners++ {
        shares, _ := PrizeShare(prize, winners)
        require.Equal(t, prize, SumShares(shares))   // las partes suman el todo
    }
}
```

Esa prueba no se rompe si cambia el generador, porque no depende de qué valores
salgan: depende de que la propiedad se cumpla **para todos**. Es la diferencia
entre *"el recaudo es 4.200.000"* y *"el recaudo siempre es números vendidos por
precio"*.

📖 **Aserciones concretas sobre datos que tú escribiste. Aserciones de propiedad
sobre datos generados. Mediciones sobre volumen. Y jamás una aserción concreta
sobre volumen generado.**

---

## 🧩 Cuándo usar qué

| Si necesitas… | Usa | Y no |
|---|---|---|
| Usar la aplicación y correr `smoke.sh` | La semilla del `db.json` | Volumen generado |
| Probar una regla de negocio | Fixtures escritas en el test | El faker |
| Verificar una invariante para muchos casos | Generación + aserción de **propiedad** | Aserción de valor |
| Medir contención (`be05`) | Volumen con semilla fija | Dos rifas y cuatro números |
| Medir un índice o un `EXPLAIN` (`be08`) | Volumen + `ANALYZE` | Volumen sin `ANALYZE` |
| Reproducir un hallazgo del generador | La misma `-seed` y la misma versión | Volver a generar al azar |
| Simular ventas | El servicio (`SellNumber`) | `INSERT` directo en `sales` |
| Limpiar el volumen | `DELETE … WHERE id >= 100` | `TRUNCATE` en desarrollo |

---

## 🧪 Ejercicios (7)

1. **🟢** Genera 50 rifas × 400 números con `-seed 42` y comprueba con `count(*)` que hay 20.000 números y que la rifa 1 del `db.json` sigue intacta.
2. **🟢** Genera dos veces con la misma semilla y comprueba que los nombres y los precios son idénticos. Después cambia la semilla y comprueba que no.
3. **🟡** Corre `EXPLAIN ANALYZE` sobre una consulta por `status` antes y después de `ANALYZE`. Explica por qué el plan cambia aunque los datos sean los mismos.
4. **🟡 Diagnóstico.** Haz que el generador produzca un `number` como entero sin ceros a la izquierda y observa qué le pasa al tablero de la Fase 5. Anota si aparece algún error en consola.
5. **🟠** Repite la medición de contención de `be05` (ejercicio 13) con y sin volumen, y explica por qué los números cambian. Anota semilla y versión junto al resultado.
6. **🟠** Reescribe la carga con `COPY` en vez de `INSERT` y mide la diferencia con 200.000 números. Decide a partir de qué volumen compensa.
7. **🔴 Diagnóstico.** Escribe la prueba mala del §7, hazla pasar, y después rómpela **sin tocar el código de producción**: actualiza `gofakeit`, o añade una llamada al generador antes. Documenta cuánto habrías tardado en diagnosticarlo sin saber lo de este apéndice.

---

## 📚 Referencias

**Documentación oficial**
- https://github.com/brianvoe/gofakeit — el generador. Fija la v6 y revisa su registro de cambios antes de actualizar: **una versión nueva puede cambiar lo que produce una misma semilla** (§4).
- https://www.postgresql.org/docs/13/sql-copy.html — `COPY`, el ejercicio 6.
- https://www.postgresql.org/docs/13/sql-analyze.html y https://www.postgresql.org/docs/13/using-explain.html — por qué hace falta `ANALYZE` después de cargar.
- https://pkg.go.dev/testing/quick — la generación con propiedades en la biblioteca estándar. Antigua y limitada, pero explica bien la idea del §7.
- https://go.dev/doc/security/fuzz/ — el *fuzzing* nativo desde Go 1.18: generación de entradas con aserciones de propiedad, que es el pariente riguroso de esto.

**Libros**
- *Unit Testing: Principles, Practices, and Patterns* (Vladimir Khorikov) — su tratamiento de la legibilidad y del "¿de dónde salió ese número?" es el argumento del §7 desarrollado.

**Video / apoyo**
- Busca "property based testing explained". La mayoría del material es de Haskell o Scala; la idea traduce sin problema y es lo que da sentido a la excepción del §7.

**Orden de lectura sugerido:** el §7 primero —es el que decide si este apéndice te
sirve o te mete en problemas— → el §4 antes de generar nada → y el resto cuando
`be05` o `be08` te pidan volumen.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros y videos son de memoria y pueden ser inexactas. La fuente
> de verdad de versiones es `prompts/decisiones-y-versiones.md` §7, donde
> `gofakeit` v6.19.x figura como dependencia **exclusiva de este apéndice**.

---

> 🏷️ **Este apéndice sí deja código.** `server/internal/seed/fake.go` y la bandera
> `-volume` del binario de siembra. Si lo haces:
>
> ```bash
> git tag -a apendice-bea-10-datos-de-prueba-y-faker -m "bea-10: \
> generador de volumen con gofakeit y semilla fija, a partir del id 100; \
> respeta las reglas del dominio y no pisa la semilla del db.json"
> ```
>
> Los commits van con el prefijo de la fase desde la que llegaste (`be03: …`,
> `be05: …`). La convención completa está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
