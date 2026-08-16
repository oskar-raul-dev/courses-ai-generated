# 🧰🔥 Preparaciones de los incidentes — track BE
## Tutorial React 16 — Rifas y chances · backend en Go

Este documento **no lo lee el estudiante**. Es el hermano de
[`preparaciones-de-incidentes.md`](preparaciones-de-incidentes.md) para el track
opcional de backend: contiene el **estado roto** de cada incidente de
`cuaderno-incidentes-be.md`, o sea la respuesta que hay que encontrar por cuenta
propia.

> ⚠️ **Si estás haciendo el track, cierra la pestaña.** Acá está el `git diff`.

**Por qué existe, y por qué es un archivo aparte.** Los enunciados dicen
`git checkout incidente/be-05` y nunca dijeron qué trae esa rama. Y va aparte del
documento base por la misma razón por la que el cuaderno va aparte: **quien haga
solo las 96 horas del track base no tiene por qué toparse con recetas de Go y
Postgres**. La divergencia está declarada en
`prompts/propuesta-fases-backend.md` y los rangos de IDs no colisionan.

---

## Índice

- [1. Las cuatro formas de preparación de este track](#1-las-cuatro-formas-de-preparación-de-este-track)
- [2. Mapa: qué necesita cada incidente](#2-mapa-qué-necesita-cada-incidente)
- [3. Las ramas con cambio de código](#3-las-ramas-con-cambio-de-código)
- [4. Las ramas de diff vacío](#4-las-ramas-de-diff-vacío)
- [5. Los dos que se reproducen contra el mock](#5-los-dos-que-se-reproducen-contra-el-mock)
- [6. La carga concurrente](#6-la-carga-concurrente)
- [7. Verificar que la preparación sirve](#7-verificar-que-la-preparación-sirve)
- [⚠️ Advertencias](#️-advertencias)

---

## 1. Las cuatro formas de preparación de este track

El track base tiene tres palancas —rama, `CHAOS_LEVEL` y `db.json`—. Acá el dato
vive en Postgres y el proceso es un binario, así que las formas cambian. Son
cuatro, de la más barata a la más cara:

1. **Una variable de entorno.** `JWT_TTL=3m`, `TZ=UTC`, `CHAOS_LEVEL=high`. No
   toca el árbol de fuentes y es la forma propia del track: la que casi nadie
   considera cuando busca un bug, y por eso vale la pena que dos incidentes la
   usen.
2. **El estado de la máquina o del contenedor.** El reloj del sistema, la zona del
   contenedor de Postgres, la caché de capas de `docker build`. Tampoco hay diff, y
   es justamente lo que enseña.
3. **Una rama `incidente/be-NN`.** El cambio mínimo en el código de Go que produce
   el síntoma. Son once.
4. **Carga concurrente.** Dos incidentes no existen sin gente: el pool agotado y la
   venta duplicada. Va en §6.

> 🧭 **Las ramas de este track llevan `be-` adentro y no un namespace propio.** Se
> llaman `incidente/be-05`, igual que los IDs del cuaderno, y salen del tag
> `fase-beNN-<slug>` de la fase que produce el incidente
> (`00-convencion-de-git-y-tags.md`). El track BE **no estrena repositorio**: vive
> en el mismo, en `server/`, y sus ramas conviven con las del track base sin
> pisarse.

```bash
git checkout -b incidente/be-09 fase-be05-venta-concurrente
# …se aplica el cambio de la receta…
git commit -am "incidente(be-09): SellNumber sin transacción ni bloqueo"
git checkout main
```

---

## 2. Mapa: qué necesita cada incidente

| ID | Fase | Preparación | Artefacto |
|---|---|---|---|
| be-01 | be00 | **ninguna** | el mock de la Fase 3, tal cual |
| be-02 | be00 | **ninguna** | el mock y los dos caminos de venta |
| be-03 | be01 | rama | `incidente/be-03` |
| be-04 | be02 | rama de diff vacío | el contenedor de Postgres en UTC |
| be-05 | be02 | rama + carga | `incidente/be-05` + 200 peticiones |
| be-06 | be03 | rama | `incidente/be-06` |
| be-07 | be03 | rama + migración | `incidente/be-07` |
| be-08 | be04 | rama de diff vacío | `JWT_TTL=3m` |
| be-09 | be05 | rama + carga | `incidente/be-09` + el `WaitGroup` de barrera |
| be-10 | be05 | rama | `incidente/be-10` |
| be-11 | be06 | rama de diff vacío | el reloj del sistema, adelantado |
| be-12 | be06 | rama | `incidente/be-12` |
| be-13 | be07 | rama | `incidente/be-13` |
| be-14 | be07 | rama + caos | `incidente/be-14` + `CHAOS_LEVEL=high` |
| be-15 | be08 | rama | `incidente/be-15` |
| be-16 | be09 | rama | `incidente/be-16` (toca el `Dockerfile`) |

**Once ramas con código, tres de diff vacío, dos sin rama.** La proporción es
distinta a la del track base y el motivo es de diseño: allá cada fase paga su deuda
antes de cerrar, así que para que haya bug hay que devolverlo a mano; acá varias
deudas **siguen vivas** durante fases enteras —la expiración de reservas hasta
`be05`, la zona de la sesión hasta `be06`, la renovación del token nunca— y el
incidente es la deuda haciéndose notar.

---

## 3. Las ramas con cambio de código

### `incidente/be-03` — el pánico que se lleva el proceso

**Sale de:** `fase-be01-go-y-la-forma-del-monolito`
**Archivos:** dos, y los dos hacen falta.

```diff
 // server/internal/http/router.go
 	handler = requestIDMiddleware(handler)
 	handler = loggingMiddleware(handler)
-	handler = recoverMiddleware(handler)
```

Y la fuente del pánico, que engancha con el hallazgo `C-03` de `be00`:

```diff
 // server/internal/http/numbers.go
-	if body.ParticipantID == nil {
-		writeError(w, http.StatusBadRequest, "participantId es obligatorio")
-		return
-	}
-	participantID := *body.ParticipantID
+	// El cuerpo "siempre" trae participantId. Casi siempre.
+	participantID := *body.ParticipantID
```

```bash
grep -n "recoverMiddleware" server/internal/http/router.go   # no tiene que aparecer
```

**Por qué esas dos y no un `panic("boom")`:** el pánico tiene que venir de un dato
real, porque el ticket dice *"tres veces al día"* y esa frecuencia es la del
`sellNumberEpic` de la Fase 6, el único cliente que manda `{participant: …}` en vez
de `{participantId: …}`. Un pánico artificial reproduce el síntoma y borra la mitad
del aprendizaje.

**Queda bien si:** vendiendo por el camino del epic, el proceso **muere** —la
terminal vuelve al prompt— y el navegador muestra un `Network Error` de axios **sin
`error.response`**, o sea sin status, sin cuerpo y sin `X-Request-Id`. Un `500`
normal sí trae las tres cosas: esa diferencia es el incidente.

---

### `incidente/be-05` — el `Rows` que no vuelve al pool

**Sale de:** `fase-be02-la-costura-de-datos`
**Archivo:** `server/internal/raffle/store.go`

```diff
 	rows, err := s.db.QueryContext(ctx, query)
 	if err != nil {
 		return nil, err
 	}
-	defer rows.Close()
 
 	for rows.Next() {
```

```bash
grep -n "rows.Close" server/internal/raffle/store.go   # no tiene que aparecer
```

**Queda bien si:** las primeras peticiones responden normal y, pasadas unas
veinticinco, `GET /raffles` **se queda colgado sin error y sin log**. El proceso
sigue vivo (`/health` responde si no usa la base) y `pg_stat_activity` muestra las
conexiones tomadas y ociosas:

```sql
SELECT state, count(*) FROM pg_stat_activity WHERE datname = 'rifas' GROUP BY state;
```

La carga que hace falta está en §6.

---

### `incidente/be-06` — el `sql.NullInt64` que cruzó hasta el JSON

**Sale de:** `fase-be03-crud-y-el-reemplazo`
**Archivo:** `server/internal/rafflenumber/rafflenumber.go`

```diff
 type RaffleNumber struct {
 	RaffleID      int64  `json:"raffleId"      db:"raffle_id"`
 	Number        string `json:"number"        db:"number"`
 	Status        string `json:"status"        db:"status"`
-	ParticipantID *int64 `json:"participantId" db:"participant_id"`
+	// Escanea perfecto desde la base, que es lo que uno mira al escribirlo.
+	ParticipantID sql.NullInt64 `json:"participantId" db:"participant_id"`
 }
```

```bash
grep -n "ParticipantID" server/internal/rafflenumber/rafflenumber.go
curl -s localhost:3011/raffles/1/numbers | jq '.[0].participantId'
```

**Queda bien si:** ese `jq` devuelve `{"Int64":0,"Valid":false}` y no `null`, la
petición es `200`, **no hay un solo error en consola**, y en el tablero todos los
números —incluidos los disponibles— aparecen "con comprador" y el nombre sale en
blanco. Si el JSON dice `null`, la rama no está aplicada.

---

### `incidente/be-07` — la tabla que no tiene sitio para tres campos

**Sale de:** `fase-be03-crud-y-el-reemplazo`
**Archivos:** la migración y el `INSERT`.

La migración `000003_settlement_full_shape` es el fix, así que la rama **la saca del
camino**:

```bash
migrate -path migrations/postgres -database "$DATABASE_URL" down 1
git rm server/migrations/postgres/000003_settlement_full_shape.*.sql
```

Y el `INSERT` vuelve a sus cinco columnas:

```diff
 // server/internal/settlement/store.go
 	INSERT INTO settlements
-	  (raffle_id, winning_number, total_collected, prize_amount, margin,
-	   is_winner_sold, sold_count, settled_at)
-	VALUES (?, ?, ?, ?, ?, ?, ?, ?)
+	  (raffle_id, winning_number, total_collected, prize_amount, margin)
+	VALUES (?, ?, ?, ?, ?)
```

```bash
psql "$DATABASE_URL" -c '\d settlements'
```

**Queda bien si:** liquidar una rifa desde la aplicación responde **`201` sin
ningún error**, el panel muestra la liquidación completa, y `SELECT * FROM
settlements` no tiene ni `is_winner_sold`, ni `sold_count`, ni `settled_at`. Que no
falle nada es el incidente entero: el dato se pierde en el momento de guardarse y el
síntoma aparece seis meses después.

---

### `incidente/be-09` ⭐ — el check-then-act sin bloqueo

**Sale de:** `fase-be05-venta-concurrente`
**Archivo:** `server/internal/rafflenumber/service.go`

```diff
 func (s *Service) SellNumber(ctx context.Context, raffleID int64, number string, participantID int64) error {
-	return s.store.WithTx(ctx, func(tx Tx) error {
-		current, err := tx.FindOneForUpdate(ctx, raffleID, number)
-		if err != nil {
-			return err
-		}
-		if current.Status == "sold" {
-			return ErrAlreadySold
-		}
-		return tx.MarkSold(ctx, raffleID, number, participantID)
-	})
+	// Leer, decidir, escribir. Lo natural, y lo que funciona hasta que hay dos.
+	current, err := s.store.FindOne(ctx, raffleID, number)
+	if err != nil {
+		return err
+	}
+	if current.Status == "sold" {
+		return ErrAlreadySold
+	}
+	return s.store.MarkSold(ctx, raffleID, number, participantID)
+}
```

```bash
grep -n "WithTx\|FOR UPDATE\|FindOneForUpdate" server/internal/rafflenumber/service.go
```

⚠️ **El índice único no se toca.** La venta es un `UPDATE` sobre una fila que ya
existe, así que ninguna restricción de unicidad la frena, y esa es justamente la
parte que sorprende: *la evidencia del bug se destruye a sí misma*, porque la
segunda escritura pisa a la primera y en la base queda **una sola** venta.

**Caos:** `off`. Acá el caos estorba: un `500` aleatorio se confunde con el fallo
que se está buscando.

**Queda bien si:** con la carga de §6 sobre el mismo número, **dos clientes o más
reciben `200`** y `SELECT count(*) FROM raffle_numbers WHERE number = '0347' AND
status = 'sold'` devuelve `1`. Y el sesgo hacia los números redondos aparece solo:
son los que la gente elige a la vez.

---

### `incidente/be-10` — la reserva que nadie caduca

**Sale de:** `fase-be05-venta-concurrente`
**Archivo:** `server/internal/rafflenumber/expiry.go`

```diff
 // server/internal/http/router.go  (o donde arranque el barrido)
-	go expiry.RunSweeper(ctx, store, expirySweepInterval)
```

Y el lado que deja el rastro:

```diff
 // server/internal/rafflenumber/service.go, en Reserve
-	reservedUntil := s.clock.Now().Add(reservationTTL)
-	return s.store.MarkReserved(ctx, raffleID, number, participantID, &reservedUntil)
+	// El cliente ya expira la reserva con su setTimeout. 💸
+	return s.store.MarkReserved(ctx, raffleID, number, participantID, nil)
```

```bash
grep -n "RunSweeper\|reserved_until" server/internal/rafflenumber/*.go
```

**Las dos mitades importan.** Sin el barrido, el número no se libera; sin escribir
`reserved_until`, la consulta obvia del runbook —`WHERE reserved_until < now()`— **no
libera nada**, y ese es el hallazgo dentro del hallazgo que el enunciado premia.

**Queda bien si:** reservas un número desde el tablero, cierras la pestaña antes de
comprar, y pasado cualquier tiempo el número sigue en `reserved` con
`reserved_until` en `NULL`.

---

### `incidente/be-12` — la hora que el servidor no comprueba

**Sale de:** `fase-be06-hora-dura-y-la-autoridad-del-reloj`
**Archivo:** `server/internal/rafflenumber/service.go`

```diff
 	return s.store.WithTx(ctx, func(tx Tx) error {
-		raffle, err := tx.FindRaffleForShare(ctx, raffleID)
-		if err != nil {
-			return err
-		}
-		if !s.clock.Now().Before(raffle.ClosesAt) {
-			return ErrRaffleClosed
-		}
 		current, err := tx.FindOneForUpdate(ctx, raffleID, number)
```

```bash
grep -n "ErrRaffleClosed\|ClosesAt" server/internal/rafflenumber/service.go
```

La guarda del cliente **se deja intacta**: `isPastClosing` sigue viva en el tablero y
en el epic de la Fase 7. Que la única defensa esté del lado que no decide es el
incidente, y por eso el síntoma solo aparece cuando alguien la esquiva.

**Queda bien si:** con una rifa ya cerrada, esto responde `200`:

```bash
curl -s -o /dev/null -w '%{http_code}\n' -X POST \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"participantId":1}' \
  localhost:3011/raffles/1/numbers/0347/sell
```

`curl` no ejecuta `isPastClosing`, y esa es la demostración más corta de dónde vivía
la regla. Desde el navegador, con la pestaña abierta desde antes del cierre, tiene
que pasar lo mismo.

---

### `incidente/be-13` — el total que calculó el cliente

**Sale de:** `fase-be07-liquidacion-dinero-entero-y-transaccional`
**Archivo:** `server/internal/settlement/service.go`

```diff
 func (s *Service) Create(ctx context.Context, in Input) (*Settlement, error) {
-	// La verdad la tiene el servidor: se recalcula contra las ventas reales.
-	recalculated, err := s.math.TotalCollected(ctx, in.RaffleID)
-	if err != nil {
-		return nil, err
-	}
-	in.TotalCollected = recalculated
+	// El cliente ya hizo la cuenta con los números que tiene en el store.
 	return s.store.Insert(ctx, in)
 }
```

```bash
grep -n "TotalCollected" server/internal/settlement/service.go
```

**Queda bien si:** con la aplicación abierta en **dos pestañas** sobre la misma
rifa, vendes tres números en la pestaña B, liquidas desde la pestaña A —que cargó el
tablero antes— y la liquidación guardada queda corta exactamente por esos tres. El
`201` sale limpio y ninguna capa se queja: el cliente no mintió, **no tenía los
datos**.

---

### `incidente/be-14` — la liquidación que no es una operación

**Sale de:** `fase-be07-liquidacion-dinero-entero-y-transaccional`
**Archivo:** `server/internal/settlement/service.go`

```diff
-	return s.store.WithTx(ctx, func(tx Tx) error {
-		if existing, _ := tx.FindByRaffle(ctx, in.RaffleID); existing != nil {
-			return ErrAlreadySettled   // idempotencia: reintentar no cobra dos veces
-		}
-		…los seis pasos, dentro de la misma transacción…
-	})
+	// Seis pasos, cada uno con su conexión. Funcionó durante meses.
+	if err := s.store.Insert(ctx, in); err != nil {
+		return nil, err
+	}
+	if err := s.store.InsertPayouts(ctx, in.RaffleID, payouts); err != nil {
+		return nil, err
+	}
+	return s.store.MarkSettled(ctx, in.RaffleID)
```

```bash
grep -n "WithTx\|ErrAlreadySettled" server/internal/settlement/service.go
```

⚠️ **El `UNIQUE (raffle_id)` de `be02` se queda donde está.** Es lo que convierte el
segundo intento en un `23505` incomprensible en vez de en dos liquidaciones, y el
enunciado vive de esa confusión: el usuario ve una rifa *sin liquidar* y recibe un
error que dice que ya existe.

**Caos:** `CHAOS_LEVEL=high` en el binario de Go, para que perder la respuesta —y
por lo tanto reintentar— sea habitual y no una casualidad.

**Queda bien si:** liquidas con caos alto hasta que una respuesta se pierda,
reintentas desde la aplicación, y quedan **dos pagos** en `prize_payouts` para una
sola liquidación. La consulta que lo demuestra:

```sql
SELECT raffle_id, count(*) FROM prize_payouts GROUP BY raffle_id HAVING count(*) > 1;
```

---

### `incidente/be-15` ⭐ — el `LastInsertId` que SQLite perdona

**Sale de:** `fase-be08-pruebas-y-la-regla-del-motor`
**Archivo:** `server/internal/raffle/store.go`

```diff
-	// RETURNING funciona en los dos motores, y por eso D18 fija SQLite >= 3.35.
-	query := s.db.Rebind(`
-		INSERT INTO raffles (name, lottery_id, closes_at, number_price, base_prize, status)
-		VALUES (?, ?, ?, ?, ?, ?)
-		RETURNING id`)
-	var id int64
-	if err := s.db.GetContext(ctx, &id, query, …); err != nil {
+	// La forma "obvia" de recuperar el id recién insertado.
+	res, err := s.db.ExecContext(ctx, query, …)
+	if err != nil {
 		return 0, err
 	}
+	id, err := res.LastInsertId()
```

```bash
grep -rn "LastInsertId\|RETURNING" server/internal/raffle/store.go
```

**No se toca la configuración de las pruebas.** La suite corre contra SQLite en
memoria porque es rápida y no necesita contenedor, que es exactamente la decisión
que el equipo tomó de buena fe y la que el incidente pone en cuestión.

**Queda bien si** —y son las dos mitades, sin una de ellas no hay incidente—:

```bash
go test ./...                                        # verde, contra SQLite
TEST_DATABASE_URL="$DATABASE_URL" go test ./...      # rojo
curl -s -X POST localhost:3011/raffles -d '…'        # 500 en cualquier ambiente con Postgres
```

El error tiene que decir, textual: `LastInsertId is not supported by this driver`.

---

### `incidente/be-16` — la imagen que aligeraron

**Sale de:** `fase-be09-empaquetado-ambientes-y-pipeline`
**Archivo:** `server/Dockerfile`

```diff
-FROM debian:bullseye-slim
+# "Son 80 MB contra 6. Obvio." — el commit de ayer.
+FROM alpine:3.17
 COPY --from=builder /out/api /usr/local/bin/api
```

La etapa de compilación **no se toca**: sigue siendo `golang:1.19-bullseye` con
`CGO_ENABLED=1`, que es lo que exige `mattn/go-sqlite3` (D19) y lo que hace que el
binario arrastre `glibc` sin que nadie lo haya pedido.

```bash
grep -n "^FROM\|CGO_ENABLED" server/Dockerfile
```

**Queda bien si:** la imagen **construye sin un solo warning** y falla al arrancar
con el error más desconcertante que existe, sobre un archivo que está ahí:

```bash
docker build --no-cache -t rifas:sospechosa server/
docker run --rm rifas:sospechosa
# exec /usr/local/bin/api: no such file or directory
```

El `--no-cache` no es opcional en la verificación: con capas reutilizadas el fallo
puede no aparecer, que es —literalmente— por qué el incidente llegó a producción.

---

## 4. Las ramas de diff vacío

Tres incidentes no tienen ninguna línea que cambiar. La rama existe igual, porque el
enunciado la nombra y porque **fija el estado de la fase**: sale de su tag y no
commitea nada.

```bash
git checkout -b incidente/be-04 fase-be02-la-costura-de-datos
```

Que su `git diff` esté vacío no es una omisión: es la lección. Son los tres casos en
que el código hace exactamente lo que dice y el problema vive en otra parte.

### `incidente/be-04` — el contenedor en UTC

**Qué lo produce:** nada del árbol de fuentes. El contenedor de Postgres arranca con
`TimeZone = UTC`, `TIMESTAMPTZ` devuelve el instante en la zona de la sesión, y
`encoding/json` lo serializa con `Z`. `SET TIME ZONE 'America/Bogota'` llega en
`be06`, dos fases después — así que en `be02` el sistema se comporta así **por
diseño**.

**Queda bien si:** el instante es el mismo y la representación cambió, que es lo que
el estudiante tiene que demostrar y no suponer:

```bash
psql "$DATABASE_URL" -c 'SHOW TimeZone;'                 # UTC
curl -s localhost:3011/raffles/1 | jq -r .closesAt       # 2026-08-31T03:00:00Z
```

El listado se ve **bien** —`new Date()` interpreta las dos formas igual— y el único
sitio donde se nota es el formulario de edición, que lee la cadena cruda. Si el
listado también se ve mal, rompiste otra cosa.

### `incidente/be-08` — el token que vence

**Qué lo produce:** una variable de entorno, y nada más.

```bash
cd server && JWT_TTL=3m go run ./cmd/api
```

La renovación del token **no existe en ninguna fase del track** y está declarada
como deuda 💸 viva en `bea-09` §1, con su motivo escrito. El sistema hace lo
correcto: un token que expira es una propiedad de seguridad.

**Queda bien si:** entras, trabajas tres minutos sin recargar, y a la primera
petición posterior el `401` del middleware de `be04` dispara el logout global del
interceptor de la Fase 2 — sin explicación y perdiendo lo que estuvieras
escribiendo. Y la otra mitad, la que explica el ticket: si cierras sesión y vuelves
a entrar, **no te pasa nunca**.

### `incidente/be-11` — el reloj adelantado

**Qué lo produce:** el reloj de la máquina del estudiante, desincronizado una hora
hacia adelante. En macOS y en Linux se desactiva la sincronización automática y se
adelanta a mano; también sirve arrancar el navegador contra una máquina virtual con
la hora corrida.

⚠️ **Poner `TZ` no reproduce este incidente.** `isPastClosing` compara instantes, y
una comparación de instantes es independiente de la zona. Confundir zona con hora es
precisamente la teoría falsa que trae el reporte, y si la preparación la usa, el
enunciado se queda sin su lección.

**Queda bien si:** en esa máquina el botón de vender desaparece una hora antes que
en las demás, y el servidor —al que se le pregunta con `curl`— sigue aceptando
ventas durante esa hora. La asimetría es la respuesta: con el reloj adelantado se
pierden ventas legítimas, pero **los datos siguen correctos**.

---

## 5. Los dos que se reproducen contra el mock

`be-01` y `be-02` son incidentes de `be00`, la fase que **no escribe código**: es la
auditoría del contrato. Los dos se reproducen contra el mock de la Fase 3 tal como
quedó, sin rama y sin datos especiales.

```bash
CHAOS_LEVEL=off npm run mock:api
npm start
```

- **`be-01`** (el `X-Request-Id` que se ve y no se lee) necesita que la aplicación
  hable con el `3001` **por origen cruzado**. Si el estudiante levantó el `proxy` del
  dev server de CRA, no hay CORS y el incidente desaparece — y esa es la pista del
  compañero al que "sí le sale". Para prepararlo: `src/setupProxy.js` fuera del
  camino, o `REACT_APP_API_URL` apuntando directo a `http://localhost:3001`.
- **`be-02`** (el número ganador sin dueño) solo necesita que se venda por **los dos
  caminos**: el thunk de la Fase 5 manda `{participantId}` y el `sellNumberEpic` de
  la Fase 6 manda `{participant}`. El mock lee el primero y guarda `null` en
  silencio.

**Quedan bien si:** el `smoke.sh` de `be00` falla en su verificación 9 (la de
`Access-Control-Expose-Headers`) y `db.json` tiene números `sold` con
`participantId: null`. Las dos cosas son hallazgos de contrato —`C-05` y `C-03`—, y
el entregable de los dos incidentes es `server/CONTRACT.md`, no un commit de código.

---

## 6. La carga concurrente

Dos incidentes —`be-05` y `be-09`— no existen sin gente. Para `be-05` alcanza con
volumen bruto:

```bash
for i in $(seq 1 200); do curl -s -o /dev/null localhost:3011/raffles & done; wait
```

Para `be-09` **no alcanza**, y este es el error de preparación más común del track:
doscientas peticiones lanzadas en secuencia por un `for` de shell no coinciden en el
tiempo. Hace falta la **barrera** —todos los clientes soltados a la vez—, que es
exactamente lo que el `WaitGroup` de `be05` §5.4 construye:

```go
// server/internal/rafflenumber/bench_concurrency_test.go (ya existe, se reusa)
var start sync.WaitGroup
start.Add(1)                 // la barrera: nadie sale hasta que esta se libere
var wg sync.WaitGroup
for i := 0; i < 50; i++ {
	wg.Add(1)
	go func() {
		defer wg.Done()
		start.Wait()         // …acá esperan los cincuenta…
		sell(raffleID, "0347")
	}()
}
start.Done()                 // …y acá salen todos juntos.
wg.Wait()
```

Sin esa barrera las goroutines se lanzan escalonadas, la ventana entre el `SELECT` y
el `UPDATE` no se solapa nunca, y el bug **no aparece** — con lo cual alguien
concluye que la venta concurrente está bien resuelta. Es el peor desenlace posible
de una preparación mal hecha.

---

## 7. Verificar que la preparación sirve

Lo mismo que en el track base, con una comprobación de más que este track necesita:

1. **El síntoma aparece**, y como lo describe el ticket.
2. **El resto del sistema sigue en pie**: `go test ./...` en la rama falla en lo que
   el incidente rompió y en nada más.
3. **El diff cabe en una pantalla** (o está vacío a propósito, §4).
4. **El frontend no cambió ni un archivo.** Es la regla que ordena todo el track, y
   también aplica a las ramas de incidente: si tu preparación tocó `src/`, la
   preparación está mal.

```bash
git diff --stat fase-be05-venta-concurrente...incidente/be-09 -- src/   # tiene que salir vacío
```

---

## ⚠️ Advertencias

- **No abras este archivo mientras resuelves.**
- **El binario se arranca en el `3011` mientras el mock sigue en el `3001`** durante
  `be01` y `be02`; desde `be03` toma el `3001` y el mock se apaga (D21). Cada receta
  usa el puerto de su fase — si copias el comando de otra, vas a estar mirando el
  proceso equivocado, que es una forma muy cara de perder media hora.
- **La base se siembra antes de cada incidente**, con
  `go run ./cmd/seed -file ../mock/db.json`, para que los ids de los enunciados
  coincidan con los tuyos.
- **Las ramas no se mezclan entre sí**, y no se borran al terminar: son la única
  copia del estado roto.
- **Si una receta no reproduce el síntoma en tu repo, gana tu repo.** El código de
  `server/` lo escribiste tú siguiendo las fases; estas recetas describen el del
  curso. Ajusta la línea, no el enunciado.
