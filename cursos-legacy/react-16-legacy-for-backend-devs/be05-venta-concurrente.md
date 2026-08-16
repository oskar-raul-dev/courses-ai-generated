# ⭐ Fase be05 — Venta concurrente resuelta donde se resuelve

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Fase be05 de be09 · **10 horas**
> Depende de: be04 — ya hay identidad real detrás de cada venta · Habilita: be06 — Hora dura y zonas horarias

---

## 🎯 1. Propósito

La Fase 5 del track base es una de las dos ⭐ del curso y estudia las race
conditions donde el frontend puede estudiarlas: en el store, con doble clic y
peticiones que se cruzan. Hizo bien su trabajo. Pero dejó una verdad incómoda sin
decir del todo:

> 🧭 **Ninguna race condition de venta se resuelve en el cliente.** Se puede
> mitigar, disimular y hasta hacer improbable. Resolver, no.

Esta fase la resuelve donde se resuelve. Vas a ver el **mismo síntoma** —el
número `0347` vendido dos veces— que ya diagnosticaste desde Redux DevTools,
ahora reproducido desde la línea de comandos contra tu propio backend, y
arreglado con las herramientas que sí protegen: una transacción, un bloqueo
explícito y un índice único que no admite discusión.

Y hay algo que esta fase te va a pedir que hagas y que casi nunca se hace:
**medir**. Bloqueo pesimista contra optimista, sobre el mismo caso, con números.
No "el optimista escala mejor" porque lo dice un artículo: tus números, tu
hardware, tu caso.

La deuda 💸 que cobra: el `409` de venta duplicada que la Fase 3 producía con un
`if` en JavaScript sobre un archivo JSON, que `be03` tradujo a un `if` en Go
—sin ganar una gota de protección— y que acá pasa a producirlo **la base**.

> 🩻 **Antes de empezar, vuelve a leer la Fase 5 del track base.** Es lectura
> obligatoria de esta fase, no una sugerencia. El valor de lo que sigue está en
> el contraste entre las dos, y si no tienes fresco el `sellNumber` optimista con
> su rollback, la mitad del contenido se pierde.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Migración `000005`: existe la tabla `sales` con `UNIQUE (raffle_id, number)`
      y los datos históricos migrados desde `raffle_numbers`.
- [ ] Vender es **una transacción**: insertar la venta y actualizar el estado del
      número ocurren juntas o no ocurren.
- [ ] El `409` de venta duplicada lo produce **la restricción de la base**
      (`23505`), no un `if` — y el cuerpo y el mensaje siguen siendo idénticos a
      los del mock.
- [ ] Existe una prueba de concurrencia en Go que lanza N ventas simultáneas
      sobre el mismo número y verifica que **exactamente una** gana.
- [ ] Las reservas tienen expiración **del lado del servidor** (`reserved_until`)
      y hay un trabajo que las vence.
- [ ] Existe `server/evidence/concurrencia.md` con la comparación **medida**
      entre bloqueo pesimista y optimista: intentos, ganadores, errores, latencia
      p50 y p95.
- [ ] La transacción bloqueada quedó observada en `pg_stat_activity`, con la
      captura pegada en ese mismo archivo.
- [ ] Está documentado qué pasa con el mismo escenario contra **SQLite**, y por
      qué eso condena a `be08`.
- [ ] `./server/smoke.sh` sigue pasando entero y el frontend sigue sin tocarse.

---

## 🚫 3. Qué queda fuera por ahora

- **Reintentos automáticos en el cliente.** El frontend no se toca. Si una
  estrategia necesita que el cliente reintente, esa estrategia no sirve acá — y
  esa restricción, lejos de ser un estorbo, es lo que obliga a resolverlo bien.
- **La hora de cierre** → `be06`. Hoy se puede vender pasada la `closesAt` y el
  backend no dice nada. Una cosa a la vez.
- **La liquidación transaccional** → `be07`. Acá la transacción cubre una venta;
  allá cubre un reparto entero.
- **`go test -race` y la regla del motor** → `be08`. Acá se **recoge la
  evidencia** de que SQLite no puede con esto; formalizarla en regla es la otra
  fase.
- **Colas, particionado y sharding.** Si tu solución necesita infraestructura
  nueva para vender un número de rifa, sobredimensionaste el problema.

---

## 🧠 4. Conceptos mínimos

Tienes años de SQL y de transacciones. Lo que sigue no explica qué es `BEGIN`:
explica por qué el código que escribiste en `be03` está roto aunque parezca
correcto, y qué opciones reales hay.

### 4.1 El bug, con precisión

Este es el `SellNumber` de `be03`, y su problema no es de Go:

```go
current, _ := s.store.FindOne(ctx, raffleID, number)  // (1) lee: "available"
if current.Status == "sold" { return ErrAlreadySold } // (2) decide
return s.store.MarkSold(ctx, raffleID, number, ...)   // (3) escribe
```

Entre (1) y (3) hay una ventana. En esa ventana cabe **otra ejecución completa**
de (1), (2) y (3). Dos vendedores leen `available`, los dos deciden que se puede,
los dos escriben, los dos reciben `200`. El número se vendió dos veces y no hay
ningún error en ninguna parte.

Lo que hace peligroso a este bug es que **no se reproduce cuando lo buscas**. La
ventana dura microsegundos; con dos pestañas y dos clics no pasa nunca. Pasa el
día del sorteo grande, con cien vendedores, y llega como un ticket que dice "creo
que vendimos dos veces el 0347, ¿puede ser?".

> 🧠 **El patrón, con su nombre.** Esto es un *check-then-act*: verificar una
> condición y actuar sobre ella en dos operaciones separadas. Es el mismo error
> conceptual que el `if (!file.exists()) file.create()` de cualquier lenguaje. La
> solución nunca es "verificar mejor": es **hacer que la verificación y la acción
> sean una sola cosa indivisible**.

### 4.2 Por qué la transacción sola no alcanza

El primer instinto es envolver los tres pasos en `BEGIN … COMMIT` y darlo por
resuelto. No lo resuelve, y entender por qué es el corazón de la fase.

PostgreSQL usa `READ COMMITTED` por defecto. En ese nivel, cada sentencia ve una
foto de los datos confirmados **en el momento en que esa sentencia empieza**. Dos
transacciones concurrentes que hacen `SELECT status` ven las dos `available`,
porque ninguna había confirmado nada todavía. La transacción te da atomicidad —o
pasan las dos escrituras o ninguna— pero **no te da exclusión mutua**.

Lo que hay que sumar es una de estas tres cosas:

**Bloqueo pesimista.** `SELECT … FOR UPDATE` toma un bloqueo sobre la fila. La
segunda transacción que pida la misma fila **espera** hasta que la primera
confirme o revierta. Al despertar, ve el dato ya actualizado. Es explícito,
predecible, y serializa el acceso a esa fila.

**Bloqueo optimista.** No se bloquea nada: se escribe con una condición que solo
puede cumplirse una vez —`UPDATE … WHERE status = 'available'`— y se mira cuántas
filas se afectaron. Si son cero, perdiste la carrera. Nadie espera a nadie; el
perdedor se entera al final.

**Una restricción de la base.** Se diseña el esquema para que la operación
duplicada sea **imposible de representar**. Un `UNIQUE` no se puede burlar con
ninguna combinación de tiempos: es la base la que se niega. Esta es la única de
las tres que sigue protegiendo el día que alguien escriba un `INSERT` desde
`psql`, desde un script de migración o desde el servicio nuevo que nadie te
avisó que existía.

### 4.3 El problema de diseño que hay que resolver primero

Acá hay una trampa que conviene ver antes de escribir código. Hoy vender es un
`UPDATE` sobre `raffle_numbers`: la fila del número `0347` ya existe y solo cambia
su `status`. **Un `UNIQUE` no puede protegerte contra eso**, porque no hay una
segunda fila que insertar; hay una misma fila que se actualiza dos veces, y
actualizar dos veces no viola ninguna restricción.

Dicho de otro modo: con el modelo actual, la tercera opción —la más fuerte— **no
está disponible**. Y esto no es un detalle de implementación: es lo que decide
qué defensas puedes tener.

> 🧭 **Decisión de esta fase: la venta se modela como un hecho, no como un
> estado.** Se crea la tabla `sales`, donde cada venta es una fila nueva con
> `UNIQUE (raffle_id, number)`. Vender pasa a ser un `INSERT`, y entonces el
> índice único sí puede ser la última línea de defensa.

El `status` de `raffle_numbers` no desaparece —lo consume el frontend y el
contrato manda— pero cambia de naturaleza: pasa de ser **la verdad** a ser una
**proyección** de la verdad, mantenida en la misma transacción. Esa distinción
vale para el resto de tu carrera:

📖 **Un estado es un campo que se pisa. Un hecho es una fila que se agrega.** Los
estados pierden historia y no se pueden restringir; los hechos se acumulan, se
auditan y se protegen con índices. Cuando algo tiene consecuencias —dinero,
inventario, una plaza reservada—, modélalo como hecho.

Y hay un beneficio que `be07` te va a agradecer: cuando alguien pregunte quién
vendió el número ganador y a qué hora, la respuesta va a existir.

### 4.4 Niveles de aislamiento, sin misticismo

Tres niveles importan en Postgres, y la diferencia práctica es corta:

- **`READ COMMITTED`** (el de por defecto): cada sentencia ve lo confirmado al
  empezar *esa sentencia*. Permite el *check-then-act* de 4.1.
- **`REPEATABLE READ`**: toda la transacción ve la misma foto. No arregla lo
  nuestro — arregla que dos lecturas iguales devuelvan lo mismo.
- **`SERIALIZABLE`**: Postgres vigila los conflictos y **aborta** una de las
  transacciones con el error `40001` si el resultado no habría podido ocurrir en
  ningún orden secuencial.

`SERIALIZABLE` resuelve el bug sin `FOR UPDATE` y sin cambiar el modelo. Su
precio es que **el cliente tiene que reintentar**, porque una transacción abortada
no es un error de negocio: es "vuelve a intentarlo". Y acá el cliente es el
frontend heredado, que no reintenta y no se toca.

📝 Eso convierte a `SERIALIZABLE` en una opción interesante que este sistema no
puede tomar hoy — y es la clase de restricción que decide arquitecturas de
verdad. Vas a implementarla igual, en el ejercicio 29, para poder decir con
autoridad por qué no se eligió.

---

## 💻 5. Implementación y código comentado

### 5.1 La migración: el hecho en vez del estado

```sql
-- server/migrations/postgres/000005_sales_table.up.sql

-- Cada venta es un HECHO: una fila que se agrega y no se pisa. Esta tabla
-- es también el registro inmutable que be07 va a necesitar para la
-- trazabilidad de la liquidación.
CREATE TABLE sales (
    id             BIGSERIAL   PRIMARY KEY,
    raffle_id      BIGINT      NOT NULL REFERENCES raffles(id) ON DELETE CASCADE,
    number         TEXT        NOT NULL,
    participant_id BIGINT      REFERENCES participants(id),
    -- Quién vendió. Sale del token (be04), nunca del cuerpo de la petición.
    sold_by        BIGINT      NOT NULL REFERENCES users(id),
    sold_at        TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- 🧭 LA ÚLTIMA LÍNEA DE DEFENSA.
    -- No es una optimización ni una validación: es una imposibilidad. Da
    -- igual cuántas transacciones concurrentes lo intenten, en qué orden,
    -- con qué nivel de aislamiento, o si alguien entra por psql a las tres
    -- de la mañana: la segunda fila no existe.
    CONSTRAINT sales_unique_number_per_raffle UNIQUE (raffle_id, number)
);

-- Migración de los datos que ya están vendidos. El sold_by de las ventas
-- históricas no se puede saber —se hicieron cuando el backend no preguntaba
-- quién vendía (esa era la tercera deuda, y la pagó be04)— así que se
-- atribuyen al usuario 1 y se marcan.
--
-- 💸 Deuda declarada: hay ventas en la base sin autoría real. No se puede
-- reconstruir el pasado; lo que sí se puede es no esconderlo.
INSERT INTO sales (raffle_id, number, participant_id, sold_by, sold_at)
SELECT raffle_id, number, participant_id, 1, COALESCE(sold_at, now())
FROM raffle_numbers
WHERE status = 'sold';

-- Y la expiración de reservas, que ahora vive del lado del servidor.
-- La columna reserved_until existe desde be02 y nadie la había usado.
CREATE INDEX raffle_numbers_reserved_until
    ON raffle_numbers (reserved_until)
    WHERE status = 'reserved';
```

> 🧠 **Ese índice parcial (`WHERE status = 'reserved'`) merece un segundo.** El
> trabajo que vence reservas solo consulta filas reservadas, que son un puñado
> entre decenas de miles. Un índice parcial ocupa una fracción y se mantiene casi
> gratis.
>
> Y una nota honesta para tu inventario de divergencias: **esta sí porta**.
> SQLite tiene índices parciales desde la 3.8.0, de 2013. No todo diverge, y dar
> por sentado que sí es el error simétrico del que esta fase avisa: verifica
> antes de asumir, en las dos direcciones.

### 5.2 La venta, en una transacción

```go
// server/internal/rafflenumber/service.go

// SellNumber vende un número.
//
// Comparado con la versión de be03, lo que cambió no es el largo: es que ya
// no hay una ventana entre decidir y escribir. Todo ocurre dentro de una
// transacción, con la fila bloqueada, y con el índice único detrás por si
// algo se me escapó.
func (s *Service) SellNumber(ctx context.Context, raffleID int64, number string, participantID *int64) (RaffleNumber, error) {
	// La identidad sale del contexto (be04). Si es 0, alguien montó esta
	// ruta fuera del middleware de autenticación: se rechaza, no se asume.
	soldBy := httpapi.UserIDFrom(ctx)
	if soldBy == 0 {
		return RaffleNumber{}, ErrUnauthenticated
	}

	var sold RaffleNumber

	// WithTx abre la transacción, ejecuta, y hace Commit o Rollback según
	// el error. Que exista este helper evita el fallo más común de todos:
	// una transacción que nadie cerró porque el return de un error se
	// saltó el Commit.
	err := s.store.WithTx(ctx, func(tx Tx) error {
		// (1) BLOQUEO PESIMISTA. Esta línea es la que arregla el bug.
		//
		// FOR UPDATE toma un bloqueo exclusivo sobre la fila del número.
		// Una segunda transacción que ejecute este mismo SELECT se queda
		// ESPERANDO acá —no lee un dato viejo, no falla: espera— hasta que
		// esta confirme o revierta. Cuando despierte, va a leer el estado
		// ya actualizado y va a decidir bien.
		current, err := tx.FindOneForUpdate(ctx, raffleID, number)
		if err != nil {
			return err
		}

		// (2) Ahora sí, decidir es seguro: nadie más puede tocar esta fila
		// mientras la tengamos bloqueada.
		if current.Status == "sold" {
			return ErrAlreadySold
		}

		// (3) El hecho. Si por lo que sea dos transacciones llegaran acá
		// —un bug futuro, una ruta nueva, un script—, la restricción
		// UNIQUE rechaza la segunda con el código 23505 y el store lo
		// traduce a ErrAlreadySold. Cinturón y tirantes, y los dos hacen
		// falta: el cinturón protege esta ruta, los tirantes protegen las
		// que todavía no existen.
		if err := tx.InsertSale(ctx, raffleID, number, participantID, soldBy); err != nil {
			return err
		}

		// (4) La proyección que el contrato exige. Va en la MISMA
		// transacción: o hay venta y estado coherente, o no hay nada.
		sold, err = tx.MarkSold(ctx, raffleID, number, participantID)
		return err
	})
	if err != nil {
		return RaffleNumber{}, err
	}
	return sold, nil
}
```

```go
// server/internal/rafflenumber/store.go (los métodos nuevos)

// FindOneForUpdate lee la fila y la bloquea hasta el fin de la transacción.
//
// ⚠️ FOR UPDATE solo existe en Postgres. En SQLite esta consulta es un
// error de sintaxis, y esa es exactamente la evidencia que justifica la
// regla del motor de be08. No se emula: se documenta.
func (t *sqlTx) FindOneForUpdate(ctx context.Context, raffleID int64, number string) (RaffleNumber, error) {
	query := t.Rebind(`
		SELECT id, raffle_id, number, status, participant_id, reserved_until, sold_at
		FROM raffle_numbers
		WHERE raffle_id = ? AND number = ?
		FOR UPDATE`)

	var n RaffleNumber
	err := t.GetContext(ctx, &n, query, raffleID, number)
	if errors.Is(err, sql.ErrNoRows) {
		return RaffleNumber{}, ErrNotFound
	}
	if err != nil {
		return RaffleNumber{}, fmt.Errorf("bloqueando el número %s de la rifa %d: %w", number, raffleID, err)
	}
	return n, nil
}

// InsertSale registra el hecho y traduce la violación de unicidad.
func (t *sqlTx) InsertSale(ctx context.Context, raffleID int64, number string, participantID *int64, soldBy int64) error {
	query := t.Rebind(`
		INSERT INTO sales (raffle_id, number, participant_id, sold_by)
		VALUES (?, ?, ?, ?)`)

	_, err := t.ExecContext(ctx, query, raffleID, number, participantID, soldBy)
	if err == nil {
		return nil
	}

	// 🧭 ACÁ ES DONDE EL 409 DEJA DE SER UN if.
	//
	// El código 23505 es "unique_violation" del estándar SQL. Que el
	// conflicto lo declare la BASE y no nuestro código es toda la
	// diferencia: nuestro código puede equivocarse en las condiciones de
	// carrera; la restricción, no.
	//
	// El errors.As con *pq.Error es específico de lib/pq: otro punto de la
	// costura donde el motor se hace visible. Está acá, nombrado, en vez
	// de escondido detrás de un string matching frágil.
	var pqErr *pq.Error
	if errors.As(err, &pqErr) && pqErr.Code == "23505" {
		return ErrAlreadySold
	}
	return fmt.Errorf("registrando la venta del número %s: %w", number, err)
}
```

Y el handler **no cambia ni una línea**. Sigue traduciendo `ErrAlreadySold` a
`409` con el mismo mensaje del mock. Ese es el punto: cambió por completo la
garantía y no cambió nada de lo observable.

### 5.3 Las reservas, que ahora expiran donde deben

La Fase 5 del track base expiraba las reservas con un `setTimeout` del navegador,
y la Fase 6 con un epic. Las dos tienen el mismo agujero, declarado 💸 desde el
mock: **si el usuario cierra la pestaña, el número queda reservado para siempre**.

```go
// ReserveNumber reserva un número por una ventana acotada.
func (s *Service) ReserveNumber(ctx context.Context, raffleID int64, number string) (RaffleNumber, error) {
	var reserved RaffleNumber
	err := s.store.WithTx(ctx, func(tx Tx) error {
		current, err := tx.FindOneForUpdate(ctx, raffleID, number)
		if err != nil {
			return err
		}

		// Una reserva vencida cuenta como disponible aunque el trabajo de
		// limpieza todavía no haya pasado. La verdad es el reloj, no el
		// último barrido: si dependiéramos del barrido, la ventana entre
		// ejecuciones sería un agujero funcional.
		expired := current.ReservedUntil != nil && current.ReservedUntil.Before(time.Now())
		if current.Status != "available" && !(current.Status == "reserved" && expired) {
			return ErrNotAvailable
		}

		until := time.Now().Add(s.reservationTTL)
		reserved, err = tx.MarkReserved(ctx, raffleID, number, until)
		return err
	})
	return reserved, err
}
```

```go
// server/internal/rafflenumber/expiry.go

// StartExpiryWorker lanza el trabajo que devuelve al tablero los números
// cuya reserva venció.
//
// 🧠 Fíjate en la forma: recibe un context y muere cuando se cancela. Eso
// lo conecta con el apagado ordenado de be01 —un worker que no sabe morir
// convierte un Shutdown limpio en un proceso zombi— y es la misma idea del
// takeUntil de la Fase 6, ahora del lado del servidor y por tercera vez.
func StartExpiryWorker(ctx context.Context, store Store, every time.Duration) {
	go func() {
		ticker := time.NewTicker(every)
		defer ticker.Stop()

		for {
			select {
			case <-ctx.Done():
				log.Println("[expiry] worker detenido")
				return
			case <-ticker.C:
				// Un solo UPDATE, sin leer antes. No hay check-then-act
				// porque no hay check: la condición está en el WHERE y la
				// evalúa la base sobre el dato vigente.
				n, err := store.ExpireReservations(ctx)
				if err != nil {
					// Un fallo acá no debe tumbar el worker: la próxima
					// vuelta lo reintenta. Pero sí tiene que verse.
					log.Printf("[expiry] error venciendo reservas: %v", err)
					continue
				}
				if n > 0 {
					log.Printf("[expiry] %d reservas vencidas y liberadas", n)
				}
			}
		}
	}()
}
```

```sql
-- El UPDATE del worker. Sin subconsultas, sin leer antes, idempotente.
UPDATE raffle_numbers
SET status = 'available', reserved_until = NULL
WHERE status = 'reserved' AND reserved_until < now();
```

> ⚠️ **Con más de una réplica, este worker corre en todas a la vez.** No rompe
> nada —el `UPDATE` es idempotente y la segunda ejecución afecta cero filas—
> pero es trabajo desperdiciado y un patrón que en otras operaciones sí haría
> daño. La solución honesta (un bloqueo de aviso con `pg_advisory_lock`) es el
> ejercicio 26, y la decisión de si hace falta es de `be09`.

### 5.4 La comparación medida: pesimista contra optimista

Acá está el trabajo que hace valiosa la fase. Implementa **las dos** estrategias
y mide. No copies conclusiones de un artículo: los números dependen del hardware,
del número de contendientes y de cuánto dura la transacción.

La variante optimista, sin bloqueo y sin espera:

```go
// SellNumberOptimistic vende sin bloquear a nadie.
//
// La idea: no preguntar si se puede, sino intentar hacerlo de forma que
// solo pueda salir bien una vez, y mirar el resultado. La condición vive
// en el WHERE, que la base evalúa de forma atómica sobre el dato vigente.
func (s *Service) SellNumberOptimistic(ctx context.Context, raffleID int64, number string, participantID *int64) (RaffleNumber, error) {
	soldBy := httpapi.UserIDFrom(ctx)
	var sold RaffleNumber

	err := s.store.WithTx(ctx, func(tx Tx) error {
		// El INSERT es la carrera. ON CONFLICT DO NOTHING hace que el
		// perdedor no reciba un error de base sino cero filas afectadas,
		// que es una forma más limpia de perder.
		inserted, err := tx.InsertSaleIfAbsent(ctx, raffleID, number, participantID, soldBy)
		if err != nil {
			return err
		}
		if !inserted {
			// Alguien llegó primero. Nadie esperó a nadie.
			return ErrAlreadySold
		}
		sold, err = tx.MarkSold(ctx, raffleID, number, participantID)
		return err
	})
	return sold, err
}
```

```sql
-- InsertSaleIfAbsent
INSERT INTO sales (raffle_id, number, participant_id, sold_by)
VALUES ($1, $2, $3, $4)
ON CONFLICT (raffle_id, number) DO NOTHING;
-- RowsAffected() == 1 → ganaste. == 0 → perdiste, y no hubo espera.
```

El arnés de medición:

```go
// server/internal/rafflenumber/bench_concurrency_test.go
//
// N goroutines peleando por el MISMO número. Es la prueba que be03 no
// podía escribir y la que be08 va a convertir en parte de la suite.
func runContention(t *testing.T, sell sellFunc, contenders int) result {
	// El WaitGroup arranca a todos a la vez: sin esta barrera, las
	// goroutines se lanzan escalonadas y la carrera no ocurre. Es el error
	// número uno al escribir pruebas de concurrencia — el test pasa, la
	// carrera nunca se produjo, y no probaste nada.
	var start sync.WaitGroup
	start.Add(1)

	var wg sync.WaitGroup
	results := make([]error, contenders)
	latencies := make([]time.Duration, contenders)

	for i := 0; i < contenders; i++ {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			start.Wait() // todos esperan el disparo
			t0 := time.Now()
			_, results[i] = sell(ctx, 1, "0347", nil)
			latencies[i] = time.Since(t0)
		}(i)
	}

	start.Done() // ¡ya!
	wg.Wait()

	return summarize(results, latencies)
}
```

Y lo que hay que anotar en `server/evidence/concurrencia.md`, para 2, 10 y 50
contendientes, con las dos estrategias:

| Qué medir | Por qué importa |
|---|---|
| Ganadores | **Tiene que ser exactamente 1.** Si no, no hay nada más que medir |
| Perdedores con `409` | Deben ser N−1, y con el mensaje del contrato |
| Errores de otro tipo | Cualquiera distinto de `409` es un bug tuyo |
| Latencia p50 y p95 | Acá aparece la diferencia real entre las dos estrategias |

Lo que vas a ver, y que conviene predecir **antes** de correrlo para comprobar
tu intuición: con el pesimista, los perdedores tardan porque **esperan** su turno
en la cola del bloqueo, y la latencia p95 crece con el número de contendientes.
Con el optimista, los perdedores fallan casi instantáneamente y la latencia
apenas se mueve. La contrapartida es que el optimista genera trabajo tirado a la
basura, y con contención muy alta esa basura puede dominar.

> 🧭 **El criterio, que vale más que los números.** El pesimista brilla cuando la
> colisión es **probable** y el trabajo perdido sería caro; el optimista brilla
> cuando la colisión es **rara** y el trabajo perdido es barato. Para una rifa
> —donde solo colisionan los números "bonitos", y muy de vez en cuando— el
> optimista es la respuesta correcta.
>
> Y sin embargo esta fase se queda con el pesimista como camino principal, por
> una razón que no es de rendimiento: **el `FOR UPDATE` se puede observar**. Vas a
> poder mirar el bloqueo en `pg_stat_activity` y entenderlo con los ojos. Cuando
> tengas la intuición construida, el ejercicio 22 te pide que elijas de verdad,
> con tus números.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Envolver en una transacción y darlo por resuelto.** Síntoma: el bug sigue,
menos frecuente. Causa: `READ COMMITTED` no da exclusión mutua (4.2). Fix:
`FOR UPDATE`, `ON CONFLICT` o `SERIALIZABLE`. Es el error más común de esta fase
y el más peligroso, porque **parece** arreglado y la frecuencia baja lo
suficiente como para que las pruebas manuales pasen.

**2. `FOR UPDATE` sobre la consulta equivocada.** Síntoma: no protege. Causa:
bloquear la fila de `raffles` en vez de la del número, o bloquear después de
haber leído el estado. Fix: el bloqueo va sobre **la fila que se va a modificar**
y **antes** de decidir. Regla: si entre el `FOR UPDATE` y el `UPDATE` hay una
decisión basada en una lectura anterior, el bloqueo llegó tarde.

**3. Transacciones que nadie cierra.** Síntoma: el pool se agota, todo se cuelga,
y `pg_stat_activity` se llena de `idle in transaction`. Causa: un `return` de
error que se saltó el `Commit` y el `Rollback`. Fix: el helper `WithTx` con
`defer tx.Rollback()`. **Nunca** manejes transacciones a mano en un handler.

**4. Bloquear más de la cuenta.** Síntoma: la venta funciona perfecto y el
sistema entero se arrastra. Causa: `SELECT … FOR UPDATE` sin `WHERE` selectivo,
o dentro de una transacción que además llama a un servicio externo. Fix:
bloquear la mínima cantidad de filas durante el mínimo tiempo. **Una transacción
no debe contener una petición de red**, nunca.

**5. Deadlock por orden de bloqueo.** Síntoma: `deadlock detected` intermitente.
Causa: dos transacciones bloqueando las mismas filas en orden distinto —vender
`0347` y `1500` en un caso, `1500` y `0347` en el otro—. Fix: **bloquear siempre
en el mismo orden**, típicamente ordenando por clave primaria. Postgres detecta
el deadlock y mata a una de las dos, así que el síntoma es un error y no un
cuelgue; agradécelo.

**6. Probar la concurrencia sin barrera de salida.** Síntoma: el test de carrera
pasa siempre, incluso con el código roto de `be03`. Causa: las goroutines se
lanzan escalonadas y nunca coinciden. Fix: el `WaitGroup` de barrera de 5.4.
**Un test de concurrencia que pasa contra el código vulnerable no es un test.**

### 🩻 Pieza forense de esta fase

**Ver el bloqueo, no imaginarlo.** Esta es la pieza forense más visual del track
y la que más vale la pena hacer despacio.

*Paso 1 — reproduce el bug con el código de `be03`.* Vuelve al `SellNumber` sin
transacción (`git stash` o una rama) y lanza dos ventas simultáneas:

```bash
TOKEN=$(curl -s -X POST localhost:3001/login -H 'Content-Type: application/json' \
        -d '{"email":"organizador@rifas.test","password":"rifas123"}' | jq -r .token)

# El & es lo que importa: las dos salen a la vez.
for i in 1 2; do
  curl -s -o /dev/null -w "cliente $i → %{http_code}\n" \
    -X POST localhost:3001/raffles/1/numbers/0347/sell \
    -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
    -d '{"participantId":null}' &
done; wait
```

Con dos clientes puede que no pase. Sube a veinte con `seq 1 20`. Cuando veas
**dos `200`**, ya tienes el bug reproducido a voluntad — que es la mitad del
trabajo de cualquier diagnóstico. Confírmalo en la base:
`SELECT count(*) FROM sales WHERE number = '0347';`

*Paso 2 — mira el bloqueo en vivo.* Con la versión corregida, abre **dos
terminales de `psql`**. En la primera:

```sql
BEGIN;
SELECT * FROM raffle_numbers WHERE raffle_id = 1 AND number = '0347' FOR UPDATE;
-- No hagas COMMIT. Déjala ahí.
```

En la segunda, la misma consulta. **Se queda colgada.** No falló, no devolvió un
dato viejo: está esperando. Ahora, en una tercera terminal, míralo:

```sql
SELECT pid, state, wait_event_type, wait_event,
       left(query, 60) AS consulta
FROM pg_stat_activity
WHERE datname = 'rifas' AND state <> 'idle';
```

Ahí está: `wait_event_type = 'Lock'`, `wait_event = 'transactionid'`. **Eso es
una transacción bloqueada, en pantalla.** Haz `COMMIT` en la primera terminal y
mira cómo la segunda despierta al instante y lee el dato actualizado.

Pega esa salida en `server/evidence/concurrencia.md`. Es la evidencia de que
entendiste el mecanismo y no solo copiaste un `FOR UPDATE`.

*Paso 3 — quién bloquea a quién.* Con el bloqueo activo, la consulta que de
verdad usarías a las tres de la mañana:

```sql
SELECT blocked.pid AS bloqueado, blocking.pid AS bloqueante,
       left(blocked.query, 40) AS espera, left(blocking.query, 40) AS culpable
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking ON blocking.pid = ANY(pg_blocking_pids(blocked.pid));
```

Guárdala. Es de las tres o cuatro consultas que conviene tener a mano para
siempre.

*Paso 4 — el remate, y lo que condena a `be08`.* Corre la **misma** prueba de
concurrencia contra SQLite:

```bash
TEST_DATABASE_URL="" go test -run TestConcurrentSell ./internal/rafflenumber/
```

No hay `FOR UPDATE`: la consulta es un error de sintaxis. Y aunque la quites, lo
que aparece es `database is locked` (`SQLITE_BUSY`), porque SQLite escribe de a
uno y serializa la base entera, no la fila.

Anota las dos cosas y anótalas bien, porque son distintas y las dos importan: en
Postgres, veinte vendedores compiten por una fila y diecinueve reciben un `409`
correcto en milisegundos. En SQLite, veinte vendedores compiten por **el archivo**
y el resultado depende del `busy_timeout`. **El motor de pruebas no puede
demostrar nada sobre concurrencia**, y por lo tanto una suite verde contra SQLite
no dice nada sobre este código. Esa frase es, literalmente, el contenido central
de `be08`.

*El círculo, con concurrencia.* Toma el `X-Request-Id` de una venta que perdió la
carrera, búscalo en el log del backend, y ahí encuentra el `409` con su
transacción y su tiempo de espera. En `be00` ese id no llegaba a ninguna parte;
ahora te dice cuánto esperó un vendedor por un número que ya no era suyo.

---

> 📓🔥 De esta fase salen los incidentes **be-09** ⭐ y **be-10** de `cuaderno-incidentes-be.md`. El be-09 es el hermano del ⭐ **11** del track base y el cruce más formativo del curso: allá el backend se defiende con su `409` y el frontend arruina la defensa; acá el backend no se defiende, porque falta el índice único.

---

## 🧪 7. Ejercicios (34)

**🟢 Fácil (1–8)**

1. Aplica la migración `000005` y verifica que las ventas históricas se migraron a `sales`.
2. Comprueba con `psql` que un segundo `INSERT` sobre `(1, '0347')` falla con `23505`.
3. Vende un número desde la aplicación y verifica que aparece una fila en `sales` con tu `sold_by`.
4. Comprueba con `curl` que la segunda venta del mismo número devuelve `409` con el mensaje exacto del contrato.
5. Reserva un número, espera a que venza el TTL y comprueba en el log que el worker lo liberó.
6. Ejecuta el paso 1 de la pieza forense con veinte clientes contra el código corregido: veinte respuestas, un `200`.
7. Corre `./server/smoke.sh` y confirma que sigue entero en verde.
8. Ejecuta el paso 2 de la pieza forense y pega la salida de `pg_stat_activity`.

**🟡 Intermedio (9–19)**

9. Escribe `TestConcurrentSell` con la barrera de `WaitGroup` y verifica que exactamente uno gana.
10. **Diagnóstico.** Corre ese test contra el `SellNumber` de `be03` y comprueba que falla. Si pasa, tu test está mal: encuentra por qué.
11. **Diagnóstico.** Quita la barrera del test y determina cuántas ejecuciones hacen falta para que la carrera aparezca. Explica qué te dice ese número sobre las pruebas de concurrencia en general.
12. Implementa `SellNumberOptimistic` y comprueba que produce el mismo `409`.
13. Mide las dos estrategias con 2, 10 y 50 contendientes y llena la tabla de 5.4.
14. **Diagnóstico.** Con el pesimista y 50 contendientes, encuentra en `pg_stat_activity` la cola de espera y anota el tiempo máximo que esperó un perdedor.
15. Haz que el worker de expiración corra cada segundo y observa el efecto en el tablero de la aplicación sin recargar la página. Explica por qué se ve (o por qué no).
16. **Diagnóstico.** Detén el worker y determina cuánto tarda un número reservado y abandonado en poder venderse. Explica por qué la comprobación de `expired` en `ReserveNumber` es necesaria además del worker.
17. Verifica que `Ctrl+C` detiene el worker antes de que el proceso muera, y que el log lo dice.
18. **Diagnóstico.** Provoca un `idle in transaction` a propósito (un `BEGIN` sin `COMMIT` desde `psql`) y observa el efecto sobre las ventas de la aplicación. Encuéntralo con `pg_stat_activity`.
19. Escribe la consulta de bloqueos del paso 3 de la pieza forense y déjala en `server/evidence/concurrencia.md` con una explicación de cada columna.

**🟠 Difícil (20–29)**

20. **Diagnóstico.** Ejecuta el paso 4 completo (SQLite) y escribe el informe que `be08` va a citar. Distingue con precisión entre "no existe `FOR UPDATE`" y "la base se bloquea entera".
21. Provoca un deadlock a propósito: dos transacciones que venden `0347` y `1500` en orden opuesto. Captura el mensaje de Postgres y arréglalo ordenando los bloqueos.
22. **Decide.** Con tus mediciones, elige la estrategia definitiva del backend y defiéndela por escrito en `concurrencia.md`. Tiene que citar tus números, no un artículo.
23. **Diagnóstico.** Mete un `time.Sleep(2 * time.Second)` dentro de la transacción, simulando una llamada a un servicio externo. Mide qué le pasa al sistema con 20 vendedores y explica por qué "nunca una petición de red dentro de una transacción" es una regla y no una preferencia.
24. Haz que el `409` incluya en el log (no en la respuesta) quién ganó la carrera y quién la perdió, con sus `X-Request-Id`. Argumenta por qué esa información no puede ir en la respuesta.
25. **Diagnóstico.** Sin volumen, tus mediciones no dicen nada. Genera veinte mil números con el faker de `bea-10` y repite el ejercicio 13. Compara y explica las diferencias.
26. Implementa el `pg_advisory_lock` que evita que el worker de expiración corra en varias réplicas a la vez, y demuestra que funciona levantando dos procesos.
27. **Diagnóstico.** ¿Qué pasa si el cliente corta la conexión (`Ctrl+C` en `curl`) justo después del `INSERT` y antes del `COMMIT`? Averígualo, mira el estado de la base, y explica el papel de `r.Context()` en el resultado.
28. Diseña la prueba que detectaría una regresión el día que alguien quite el `FOR UPDATE` "porque estaba de más". Que falle de forma inequívoca y rápida.
29. Implementa la variante `SERIALIZABLE` con reintento **del lado del servidor**, mídela contra las otras dos, y explica con precisión por qué el reintento tiene que estar acá y no en el cliente.

**🔴 Muy difícil (30–34)**

30. **El contraste, que es el corazón de la fase.** Escribe un documento comparando cómo aborda la Fase 5 del track base el mismo síntoma y cómo lo aborda esta: qué garantiza cada capa, qué puede y qué no puede prometer el frontend, y qué pasaría si el backend estuviera arreglado y el frontend no —y al revés. Sé concreto sobre lo que el usuario ve en cada combinación.
31. Argumenta si `raffle_numbers.status` debería existir ahora que `sales` es la verdad. Enumera qué se rompería si se calculara al vuelo, mide el costo de esa consulta con volumen, y decide. Recuerda que el contrato de `be00` no se puede cambiar.
32. **Diagnóstico + regresión.** Ticket: *"el día del sorteo de agosto vendimos tres números dos veces, pero solo en los números redondos"*. Explica por qué el sesgo hacia los números redondos es una pista y no ruido, reconstruye la causa, y escribe la prueba de regresión que la habría atrapado.
33. Diseña cómo detectarías **hoy**, con una sola consulta, si alguna vez se vendió un número dos veces en el histórico. Después explica por qué esa consulta no puede escribirse sobre el modelo de `be03` y qué te dice eso sobre modelar hechos.
34. **Post-mortem.** Escribe el post-mortem de la venta duplicada del ejercicio 32 según la guía §13. La sección de prevención tiene que distinguir tres niveles —la restricción de la base, la prueba de concurrencia y el criterio de revisión de código— y explicar por qué hacen falta los tres.

**🔥 Opcionales**

- 🔥 Implementa la venta con `SELECT … FOR UPDATE SKIP LOCKED` para un caso distinto: "véndeme cualquier número disponible". Explica por qué ahí `SKIP LOCKED` es exactamente lo correcto y en la venta de un número concreto sería un desastre.
- 🔥 Mide el impacto del índice único en la escritura: inserta cien mil ventas con y sin la restricción y compara. Después decide si el costo cambia algo de la decisión.
- 🔥 Reproduce la carrera desde el navegador con dos pestañas y el caos en `high` para ensanchar la ventana. Compara la experiencia de usuario con la del track base, donde el mismo síntoma se veía desde Redux DevTools.

---

## 📚 8. Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/13/transaction-iso.html — niveles de aislamiento, con los ejemplos de anomalías. Es la referencia central de la fase.
- https://www.postgresql.org/docs/13/explicit-locking.html — `FOR UPDATE`, `FOR NO KEY UPDATE`, `SKIP LOCKED` y la tabla de conflictos entre modos.
- https://www.postgresql.org/docs/13/sql-insert.html#SQL-ON-CONFLICT — la cláusula que sostiene la variante optimista.
- https://www.postgresql.org/docs/13/monitoring-stats.html — `pg_stat_activity` y `pg_blocking_pids`, la pieza forense.
- https://www.postgresql.org/docs/13/errcodes-appendix.html — la lista de códigos SQLSTATE. `23505` y `40001` son los de hoy.
- https://www.sqlite.org/lockingv3.html y https://www.sqlite.org/rescode.html#busy — por qué SQLite no puede con esto.
- https://pkg.go.dev/database/sql#Tx — el manejo de transacciones en Go, y por qué el `defer Rollback` es idiomático.

**Libros**
- *Designing Data-Intensive Applications* (Martin Kleppmann) — el capítulo 7 es, sin competencia, el mejor texto sobre esto. Su tratamiento del *write skew* y las anomalías de serialización cubre exactamente lo que esta fase hace con las manos.
- *PostgreSQL: Up and Running* — para la parte operativa de diagnosticar bloqueos.

**Video / apoyo**
- Busca "PostgreSQL SELECT FOR UPDATE explained" y "optimistic vs pessimistic locking" en YouTube. Verifica que los ejemplos sean de Postgres: la semántica de bloqueo de MySQL es distinta y mezclarlas confunde más que ayuda.

**Orden de lectura sugerido:** `transaction-iso.html` §13.2 primero, que explica
por qué `READ COMMITTED` permite tu bug → `explicit-locking.html` para entender
qué hace exactamente `FOR UPDATE` → hacer la pieza forense con las tres
terminales → y `bea-05` para el panorama completo de concurrencia en Postgres,
que es donde vive el detalle que acá solo se toca.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros son de memoria y pueden ser inexactas. La documentación de
> Postgres tiene una versión por URL; fija el 13. Cualquier discrepancia de
> versiones la resuelve `prompts/decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

El número `0347` ya no se puede vender dos veces, y ahora sabes exactamente por
qué: no porque el código lo verifique mejor, sino porque **la base no puede
representar el estado imposible**. Tienes una transacción que bloquea lo mínimo,
un índice único detrás por si acaso, una prueba que falla contra el código
vulnerable, y —lo que más va a durar— la evidencia medida de dos estrategias y el
criterio para elegir entre ellas.

Y tienes la respuesta a la pregunta que abría la fase. El frontend de la Fase 5
no estaba mal escrito: estaba haciendo lo único que se puede hacer desde ahí, que
es mejorar la experiencia mientras el servidor decide. La corrección optimista
con rollback sigue siendo valiosa —hace que la interfaz responda al instante— y
ahora tiene detrás algo que de verdad protege.

`be06` mueve la segunda autoridad al servidor: **el reloj**. Hoy la hora de cierre
la evalúa el navegador contra un campo de texto, y un reloj de cliente es un reloj
que el usuario controla. Vas a ver `TIMESTAMPTZ` de cerca —que es donde casi todo
el mundo tiene un modelo mental equivocado—, y vas a adelantar el reloj del
navegador para comprobar, en una sola pantalla, que el frontend deja vender y el
backend no.

> **La señal de que quedó bien:** *"puedo explicar, sin hablar de mi código, por
> qué es imposible vender dos veces el mismo número — y puedo mostrar la
> transacción esperando su turno."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be05-venta-concurrente -m "be05 cerrada: \
> tabla sales con UNIQUE como última línea de defensa; venta transaccional con FOR UPDATE; \
> 409 producido por la base (23505) y no por un if; prueba de concurrencia que falla contra be03; \
> reservas con expiración del lado del servidor y worker que las vence; \
> comparación medida pesimista vs optimista en server/evidence/concurrencia.md; \
> bloqueo observado en pg_stat_activity; evidencia de SQLite para be08"
> ```
>
> Los commits de la fase llevan su prefijo (`be05: …`) y los de ejercicio su
> número (`be05 ej30: …`). Si un ejercicio merece su propio marcador va en
> `ej/be05/30`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **Registrar en `prompts/decisiones-y-versiones.md` §7** la decisión de esta
  fase: **la venta se modela como hecho (`sales`) y no como estado**, con el
  `UNIQUE (raffle_id, number)` como última línea de defensa, y el bloqueo
  pesimista como camino principal por observabilidad, no por rendimiento. Afecta
  a `be07` (trazabilidad) y a `be08` (suite de concurrencia).
- **Registrar en `prompts/diccionario-codigo-ingles.md` §7bis.1** la entidad
  nueva: `Sale` / `sales`, y el campo `soldBy`. Es un término del dominio que
  antes no existía y que `be07` va a usar.
- **`raffle_numbers.status` pasó de verdad a proyección.** Que `be07` y `be08` lo
  traten como tal: cualquier consulta de negocio sobre ventas va contra `sales`;
  `status` existe porque el contrato de `be00` lo exige.
- **La deuda 💸 del `sold_by` histórico.** Las ventas migradas se atribuyeron al
  usuario 1 porque su autoría real no existe. `bea-09` debería recogerla: es un
  ejemplo perfecto de deuda que **no se puede pagar**, solo documentar.
- **`be06` hereda dos cosas:** la venta ya es transaccional, así que agregar la
  comprobación de la hora dura dentro de esa transacción es una línea, no un
  rediseño. Y el worker de expiración es el precedente del trabajo que va a
  cerrar rifas por reloj.
- **`be07` hereda `sales` como registro inmutable**, que es exactamente lo que su
  prompt pide para la trazabilidad, y el `WithTx` ya montado.
- **`be08` hereda dos entregables directos:** `TestConcurrentSell` (que ya falla
  contra el código vulnerable, que es la propiedad que lo hace válido) y el
  informe de SQLite del paso 4, que es la evidencia de su regla del motor. Que no
  los reescriba desde cero.
- **`bea-10` es prerrequisito real del ejercicio 25.** Sin volumen, las
  mediciones de contención no dicen nada. Conviene que la fase lo diga al abrir
  y no solo en el ejercicio.
- **Deudas declaradas:** 💸 el worker corre en todas las réplicas (ejercicio 26 lo
  resuelve, `be09` decide si hace falta); 💸 no hay límite de reservas por
  usuario, así que uno solo puede reservar el tablero entero (`bea-08`).
- **Reserva para el cuaderno de incidentes:** `be-09` — *"vendimos tres números
  dos veces, y solo los redondos"* (categoría 🔥 transacciones, dificultad 🔴, y
  candidato a ⭐ porque es el hermano exacto del incidente 11 del track base
  resuelto en la otra capa); y `be-10` — *"un número quedó reservado para
  siempre"* (categoría 🔥 transacciones, dificultad 🟡), que es la reserva
  abandonada antes de que existiera el worker.
