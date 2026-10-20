# 🧰🔥 Preparaciones de los incidentes — track BE
## Tutorial React 16 — La Esclusa, la consola de Jewel Locks · backend en Go

Este documento **no lo lee el estudiante**. Es el hermano de
[`preparaciones-de-incidentes.md`](preparaciones-de-incidentes.md) para el track
opcional de backend: contiene el **estado roto** de cada incidente de
`cuaderno-incidentes-be.md`, o sea la respuesta que hay que encontrar por cuenta
propia.

> ⚠️ **Si estás haciendo el track, cierra la pestaña.** Acá está el `git diff`.

> 🧭 **Estado de este documento.** De `be-01` a `be-18`, **confirmado por T7 a T10 (19–20/10/2026)**: cada rama existe
> en el repo de prueba, reproduce su síntoma y su corrección lo quita. Cada rama está
> escrita sobre el contrato de nombres de la reescritura (`propuesta-fases-y-alcance.md`
> §2 y `diccionario-codigo-ingles.md` §7bis). Lo que dice qué se rompe, con qué datos
> y cómo se ve el síntoma es el compromiso de P6. **La forma exacta del diff y la
> línea se fijan en la tanda que escribe la fase** (T7–T10), con el backend corrido en
> el repo de prueba; ahí se corrige esta página.

**Por qué existe, y por qué es un archivo aparte.** Los enunciados dicen
`git checkout incidente/be-05` y nunca dijeron qué trae esa rama. Y va aparte del
documento base por la misma razón por la que el cuaderno va aparte: **quien haga solo
las 98 horas del track base no tiene por qué toparse con recetas de Go y Postgres**.
La divergencia está declarada en `prompts/propuesta-fases-backend.md` y los rangos de
IDs no colisionan.

---

## Índice

- [1. Las cuatro formas de preparación de este track](#1-las-cuatro-formas-de-preparación-de-este-track)
- [2. Mapa: qué necesita cada incidente](#2-mapa-qué-necesita-cada-incidente)
- [3. Las ramas con cambio de código](#3-las-ramas-con-cambio-de-código)
- [4. Las ramas de diff vacío](#4-las-ramas-de-diff-vacío)
- [5. El que se reproduce contra el mock](#5-el-que-se-reproduce-contra-el-mock)
- [6. La carga concurrente](#6-la-carga-concurrente)
- [7. Verificar que la preparación sirve](#7-verificar-que-la-preparación-sirve)
- [⚠️ Advertencias](#️-advertencias)

---

## 1. Las cuatro formas de preparación de este track

El track base tiene tres palancas —rama, `CHAOS_LEVEL` y `db.json`—. Acá el dato vive
en Postgres y el proceso es un binario, así que las formas cambian. Son cuatro, de la
más barata a la más cara:

1. **Una variable de entorno.** `JWT_TTL=3m`, `TZ=UTC`, `CHAOS_LEVEL=high`. No toca el
   árbol de fuentes y es la forma propia del track: la que casi nadie considera cuando
   busca un bug.
2. **El estado de la máquina o de la configuración.** El reloj del sistema, el
   `DATABASE_URL` sin la zona de la sesión, la caché de capas de `docker build`.
   Tampoco hay diff, y es justamente lo que enseña.
3. **Una rama `incidente/be-NN`.** El cambio mínimo en el código de Go que produce el
   síntoma. Son catorce, contando las dos nuevas (be-17 y be-18).
4. **Carga o repetición.** Algunos incidentes no existen sin gente: el stock que se
   excede, el giro que se duplica, y el pool que se agota con envíos repetidos. Va en §6.

> 🧭 **Las ramas de este track llevan `be-` adentro y no un namespace propio.** Se
> llaman `incidente/be-09`, igual que los IDs del cuaderno, y salen del tag
> `fase-beNN-<slug>` de la fase que produce el incidente
> (`00-convencion-de-git-y-tags.md`). El track BE **no estrena repositorio**: vive en
> el mismo, en `server/`, y sus ramas conviven con las del track base sin pisarse.

```bash
git checkout -b incidente/be-09 fase-be05-giro-concurrente
# …se aplica el cambio de la receta…
git commit -am "incidente(be-09): el stock de la Esclusa de Oro sin FOR UPDATE, con el valor calculado en Go"
git checkout main
```

---

## 2. Mapa: qué necesita cada incidente

| ID | Fase | Preparación | Artefacto |
|---|---|---|---|
| be-01 | be01 | rama | `incidente/be-01` (el CORS del binario sin `Expose-Headers`) |
| be-02 | be00 | **ninguna** | el mock tal como quedó en la Fase 11, y veinte giros del juego |
| be-03 | be01 | rama | `incidente/be-03` (un `GET /players` que indexa `[0]`, y la cadena sin `recover`) |
| be-04 | be02, desde be03 | rama de diff vacío | `DATABASE_URL` sin `timezone=America/Panama` |
| be-05 | be02, desde be03 | rama + repetición | `incidente/be-05` + veinticinco envíos del mismo caso |
| be-06 | be03 | rama | `incidente/be-06` (`origin` como `sql.NullString`) |
| be-07 | be03 | rama + migración | `incidente/be-07` (sin la `000003`) |
| be-08 | be04 | rama de diff vacío | `JWT_TTL=3m` |
| be-09 ⭐ | be05 | rama + carga | `incidente/be-09` (sin `FOR UPDATE` y con el valor calculado en Go) + la rueda de medición y el escenario `notificacion` de k6 |
| be-10 | be05 | rama + corte | `incidente/be-10` (pedido sin fecha límite y sin barrido) + `SPIN_DELIVERY_MS=5000` y `kill -9` durante la entrega |
| be-11 | be06 | rama de diff vacío | el reloj de la consola, una hora adelante (a mano o `cy.clock`) |
| be-12 | be06 | rama + carga | `incidente/be-12` (el giro confía en el barrido) + la rueda de medición cerrando durante `giro.js` |
| be-13 | be07 | rama + consola | `incidente/be-13` (guarda la conciliación de la consola) + `tok-ago-31` acreditada con la pantalla abierta |
| be-14 | be07 | rama + repetición | `incidente/be-14` (acredita en pasos sueltos) + los avisos repetidos del juego y de la notificación |
| be-15 ⭐ | be08 | rama (dos commits) | `incidente/be-15` (la suite salta sin Postgres; `LastInsertId`) |
| be-16 | be09 | rama | `incidente/be-16` (el `Dockerfile` vuelve a encender cgo) |
| be-17 ➕ | be05 | rama + dos reinicios | `incidente/be-17` (el sorteo con el generador global de `math/rand`) |
| be-18 ➕ | be06 | rama + reloj del cliente | `incidente/be-18` (`X-Client-Now`) + el reclamo con el celular 4 h 1 min adelante |

**Catorce ramas con código, tres de diff vacío, una sin rama.** Es la proporción que
declara la guía (§16): allá cada fase paga su deuda antes de cerrar, así que para que
haya bug hay que devolverlo a mano; acá varias deudas **siguen vivas** durante fases
enteras —el giro sin transacción hasta `be05`, la zona de la sesión hasta `be06`, la
renovación del token nunca— y el incidente es la deuda haciéndose notar.

`be-04` y `be-05` son de `be02` —ahí nace su causa: el tipo de la columna y el pool— y
sus ramas salen de `fase-be03-crud-y-el-reemplazo`, porque `be02` no tiene rutas y el
síntoma solo se ve cuando la consola lee del binario (decisión del autor, 19/10/2026).

---

## 3. Las ramas con cambio de código

### `incidente/be-01` — el header que el binario no expone

**Sale de:** `fase-be01-go-y-la-forma-del-monolito`
**Archivo:** `server/internal/http/middleware.go`

Se quita del `corsMiddleware` la línea `w.Header().Set("Access-Control-Expose-Headers", requestIDHeader)`.

**Queda bien si** (medido el 19/10/2026 en Electron, con la consola en el `3000`, el mock en el
`3001` y el binario de la rama en el `3011`): `fetch('http://localhost:3011/health')` devuelve
`200` y `r.headers.get('X-Request-Id')` vale `null`, mientras el mismo `fetch` contra el `3001` lee
el id. Network muestra el header en las dos. La prueba `TestRequestIDIsExposedToTheBrowser` falla en
la rama con `Access-Control-Expose-Headers=""` y pasa en la fase.

### `incidente/be-03` — el pánico que corta la conexión

**Sale de:** `fase-be01-go-y-la-forma-del-monolito`
**Archivos:** dos, y los dos hacen falta: `server/internal/http/players.go` (nuevo: un
`GET /players` con jugadores en memoria que hace `r.URL.Query()["name_like"][0]`) y
`server/internal/http/router.go` (monta la ruta y quita `recoverMiddleware` de la cadena).

El pánico viene de un pedido real: al abrirse, el asistente de envíos pide `GET /players` **sin**
`name_like` (`searchPlayerEpic`, Fase 6). Y el "a ratos" del ticket también es real: si el operador
escribe antes de los 300 ms del `debounceTime`, esa petición no sale.

**Queda bien si** (medido): `GET /players` sin filtro da `TypeError: Failed to fetch` en `fetch` y
`Network Error` sin `response` en `axios`; `curl` sale con código 52; el log dice `http: panic
serving …: runtime error: index out of range [0] with length 0`, sin `X-Request-Id`; y el proceso
**sigue vivo** (`/health` responde). Con `name_like=ju`, `200`. La corrección (`recoverMiddleware`
de vuelta y `Query().Get`) da `500` con id y después `200`.

### `incidente/be-05` — el `Rows` que no vuelve al pool

**Sale de:** `fase-be03-crud-y-el-reemplazo`
**Archivo:** `server/internal/player/player.go`

El chequeo de caso de `SendGrant` pasa de `GetContext` sobre un `count(*)` a `s.db.Query(…)` **sin
contexto**, con `if rows.Next() { return Grant{}, ErrCaseGranted }` y sin `rows.Close()`.

⚠️ La receta de P6 —quitar el `defer rows.Close()` del listado de ruedas— **no reproduce nada**
(medido): el listado recorre todo y `Next` cierra el `Rows` al final; y aunque saliera antes, el
contexto de la petición lo cierra al cancelarse. Hacen falta las dos faltas juntas: salida temprana
y consulta sin contexto.

**Queda bien si** (medido): con un caso ya compensado, veinticinco envíos repetidos dan `409` y el
siguiente se cuelga; `GET /wheels` se cuelga, `/health` responde `503` a los 2 s, y
`pg_stat_activity` muestra 25 conexiones `idle`. La prueba `TestDuplicateGrantsDoNotDrainThePool`
(pool de 3) falla en la rama con `el envío duplicado 4 se colgó` y pasa en la fase.

### `incidente/be-06` — el `sql.NullString` que cruzó hasta el JSON

**Sale de:** `fase-be03-crud-y-el-reemplazo`
**Archivo:** `server/internal/spin/spin.go`

El campo `Origin` de `spin.Spin` pasa de `*string` (con `omitempty`) a `sql.NullString`.

**Queda bien si** (medido): `GET /spinLog?wheelId=4` trae `"origin":{"String":"free","Valid":true}`
(y `{"String":"","Valid":false}` en las filas del giro de 2019); el tablero de la Rueda de fin de mes
dice *Giros 10000 · 10000 gratis · 0 pagos* junto a *Ingresos netos US$135,60*; y no hay un error en
consola. Si dice *7566 gratis · 2434 pagos*, la rama no está aplicada.

### `incidente/be-07` — la conciliación que no tiene sitio para tres campos

**Sale de:** `fase-be03-crud-y-el-reemplazo`
**Archivos:** los cuatro de la migración `000003_reconciliation_full_shape` se borran (con `rm`), y
`server/internal/reconciliation/reconciliation.go` vuelve al `INSERT` de ocho columnas (y su `Find`
lee las tres listas como `'[]'`).

**Queda bien si** (medido): la base migrada con la rama queda en la versión `2`; conciliar la
Rueda de fin de mes desde la consola responde `201` y el recorrido pasa entero; la tabla no tiene
`band_alarms`, `missing_in_api` ni `duplicated_in_api`; y `GET /wheels/4/reconciliation` devuelve
`missingInApi: []` y `duplicatedInApi: []`, donde la fase guarda `["tok-ago-31"]` y `["tok-ago-17"]`.

### `incidente/be-09` ⭐ — el stock que se mide dos veces

**Sale de:** `fase-be05-giro-concurrente`
**Archivo:** `server/internal/spin/service.go`, en `takeStock`

Un commit de "optimización" quita el `FOR UPDATE` del stock —*"bloqueaba, y bajo carga el p95
subía"*— y, de paso, escribe el valor calculado en Go en vez del descuento relativo:

```diff
-			SELECT remaining FROM stock WHERE id = ?`+s.db.ForUpdate()), stockID)
+			SELECT remaining FROM stock WHERE id = ?`), stockID)
 …
-				UPDATE stock SET remaining = remaining - 1 WHERE id = ?`), stockID); err != nil {
+				UPDATE stock SET remaining = ? WHERE id = ?`), remaining-1, stockID); err != nil {
```

⚠️ **Las dos mitades importan.** Sin el bloqueo, el *check-then-act* vuelve dentro de una
transacción que no excluye; con el valor absoluto, cada choque es una actualización perdida, y
**el contador sobra en vez de quedar negativo**: la evidencia se borra sola.

**Caos:** `off`. **Datos:** la rueda de medición de `be05` (`server/load/rueda-de-medicion.sql`:
un segmento, la Esclusa con 10.000 bp, stock 1.000, 300 jugadores con 5 giros).

**Queda bien si** (medido el 19/10/2026): con `SCENARIO=notificacion`, 1.500 Esclusas entregadas y
el contador en 874 (50 VUs) o 904 (200 VUs); con `SCENARIO=pico` a 50/s, **1.000 y 0**: a ritmo parejo
la rama da bien, y eso es parte del incidente. `TestStockNeverExceeded` falla en la estrategia
pesimista (*"entregadas 1500, sustitutos 0, stock 916"*; 918 y 919 en otras corridas) y pasa en la
fase. Contra SQLite, la rama pasa en verde.

### `incidente/be-10` — el giro que nadie termina

**Sale de:** `fase-be05-giro-concurrente`
**Archivos:** `server/internal/spin/service.go` (en `decide`) y `server/cmd/api/main.go`

El estado del pedido vive en `spin_requests`, no en la bitácora, que solo se agrega (D35). La rama
escribe el pedido sin fecha límite y quita el arranque del barrido:

```diff
-		until := time.Now().UTC().Add(s.processing)
+		// El juego reintenta cuando quiera; el pedido no necesita fecha límite. 💸
 …
-			VALUES (?, ?, 'processing', ?)
+			VALUES (?, ?, 'processing', NULL)
```

```diff
-	sweepCtx, stopSweep := context.WithCancel(context.Background())
-	defer stopSweep()
-	go spins.RunSweeper(sweepCtx, cfg.SpinSweepEvery)
```

(y el `stopSweep()` del apagado). **Las dos mitades importan**: sin el barrido el pedido no se
cierra, y sin la fecha la consulta del runbook —`WHERE processing_until < now()`— no encuentra nada.

**Queda bien si** (medido el 19/10/2026): con `SPIN_DELIVERY_MS=5000` y `kill -9` a los 2 s de la
entrega, el pedido queda `processing|NULL`, la bitácora con una fila y el saldo de 5 en 4; al
reiniciar, `409 giro en proceso`, y a los 40 s sigue igual, con el runbook en 0 filas y sin líneas
`[barrido]`. Con la fase, el barrido lo cierra 8 s después del vencimiento y el reintento devuelve
`200` con el mismo premio. La regresión (`processing_test.go`) falla en la rama con *"el runbook no
encuentra el giro colgado: 0 filas"*.

### `incidente/be-12` — el giro que confía en el barrido

**Sale de:** `fase-be06-hora-dura-y-la-autoridad-del-reloj`
**Archivo:** `server/internal/spin/service.go`

`liveWheel` deja de comparar el cierre con el reloj y elige la rueda por su estado: si dice `live`, está abierta. El
barrido de cierre sigue funcionando, así que la rueda pasa a `ended` en la próxima vuelta (`WHEEL_CLOSE_EVERY`, 10 s):

```diff
 	for _, w := range wheels {
-		// Instantes con Before, nunca componentes de fecha ni ==. En el
-		// instante exacto del cierre la rueda ya está cerrada: el mismo borde
-		// que isWheelClosed de la Fase 7 (now >= closesAt).
-		if !now.Before(w.ClosesAt) {
-			continue
-		}
+		// El barrido de cierre ya pasa las ruedas vencidas a ended: si dice
+		// live, está abierta.
```

**Carga:** la rueda de medición (`load/rueda-de-medicion.sql`) cerrando a los 5 s, y `giro.js` con `RATE=50 KEYS=750`.

**Queda bien si:** la consulta de la Pista 2 cuenta giros de la rueda 900 con `created_at >= closes_at`. Medido el
19/10/2026 en tres corridas: 108, 61 y 5 (depende de en qué punto del ciclo del barrido cae el cierre); con la fase, 0.
`TestSpinRespectsClosing` falla en los tres casos de después del cierre.

### `incidente/be-13` — la conciliación que guarda la foto de la consola

**Sale de:** `fase-be07-compras-y-conciliacion`
**Archivo:** `server/internal/reconciliation/reconciliation.go`

`Reconcile` deja de recalcular y guarda el cuerpo que manda la consola. El commit lo justifica con que las funciones son
las mismas, y son las mismas: lo que difiere son los datos.

```diff
-	r, err := s.Recalculate(ctx, wheelID)
-	…
-	w, saved, err := s.record(ctx, wheelID, r)
-	return w, saved, diffs, err
+	w, saved, err := s.record(ctx, wheelID, client)
+	return w, saved, nil, err
```

**Datos:** la base sembrada. `tok-ago-31` está en el reporte de la tienda y no acreditada (`missingInApi`).

**Queda bien si:** con la conciliación de la Rueda de fin de mes abierta en la consola (sesión `mdegracia`), la tienda
confirma `tok-ago-31` y el juego la avisa para el jugador 42; al conciliar, lo guardado dice
`missingInApi: ["tok-ago-31"]` aunque la compra ya esté en `purchases`. Con la fase, `[]` y la línea *"difiere"* en el
log. Medido el 19/10/2026 con Cypress (`be13-conciliacion.cy.js`). La regresión (`stale_client_test.go`) falla en la
rama con *"la conciliación guardó como faltante una compra acreditada: [tok-ago-31]"*.

### `incidente/be-14` — la compra que se acredita en pasos sueltos

**Sale de:** `fase-be07-compras-y-conciliacion`
**Archivo:** `server/internal/purchase/service.go`

`credit` deja de ser una transacción y pasa a ser tres sentencias con su conexión cada una: leer el paquete, **sumar los
giros** y anotar la compra con un `INSERT` simple. El índice único parcial de la `000008` **se queda**: es lo que
convierte la repetición en un `23505` que llega tarde, en vez de en una segunda compra.

**Datos:** la compra de la pieza forense de `be07`: una con tarjeta y otra en efectivo, dos avisos del juego y la
notificación duplicada (`trabajo/be07-compra.sh` en el laboratorio). No hace falta caos: las repeticiones del juego y de
la notificación bastan.

**Queda bien si:** una fila por token en `purchases` y **60** giros pagos para la jugadora 43 (la fase da 20); cuatro
`500` con `duplicate key value violates unique constraint "purchases_unique_token"` en el log; y la consulta de
*Cuántos son* la encuentra. Medido el 19/10/2026. `TestDuplicateNotificationCreditsOnce` falla en la rama.

### `incidente/be-15` ⭐ — el `LastInsertId` que SQLite perdona

**Sale de:** `fase-be08-pruebas-y-la-regla-del-motor`
**Archivos:** `server/internal/testsupport/db.go` y `server/internal/wheel/store.go`, en dos commits

Desde be08, `go test ./...` sin Postgres **falla**: el incidente necesita primero desarmar eso. Primer commit,
*"la suite corre en cualquier máquina"*: `OpenPostgres` y `MustPostgres` saltan (`t.Skip`) en vez de fallar. Segundo
commit: `Create` del store de ruedas cambia `RETURNING id` por `ExecContext` y `res.LastInsertId()`.

**Queda bien si** —las dos mitades—: sin `TEST_DATABASE_URL`, `go test ./...` da `ok` en los seis paquetes; contra
Postgres caen `TestCreateAndFind` y `TestChangingWeightsPublishesANewVersion` con
`LastInsertId is not supported by this driver`; y el binario responde `500` a `POST /wheels` con ese texto en el log.
Medido el 20/10/2026. En la fase, sin Postgres la suite falla y con Postgres pasa. La suite de contrato no lo ve: siembra
directo con el `db.json` y no llama a `Create`.

### `incidente/be-16` — la imagen que volvió a tener cgo

**Sale de:** `fase-be09-empaquetado-ambientes-y-pipeline`
**Archivo:** `server/Dockerfile`

La línea del API vuelve a `CGO_ENABLED=1 go build -tags sqlite …`, *"para la demo sin Postgres"*. La imagen de
ejecución **no se toca**: distroless *static*, sin `libc`. (La especificación de P6 cambiaba la imagen de ejecución a
Alpine; desde be09 el binario es estático y eso ya no rompe nada: hay que volver a encender cgo.)

**Queda bien si:** `docker build --no-cache` termina sin avisos y el contenedor sale con 255 y
`exec /api: no such file or directory`; el mismo binario compilado en `golang:1.19.13` muestra `libc.so.6` con `ldd`.
Medido el 20/10/2026. El paso de CI de la solución (arrancar la imagen sin base y buscar `DATABASE_URL` en la salida)
falla con la rama y pasa con la fase.

### `incidente/be-17` ➕ — la misma secuencia en cada reinicio

**Sale de:** `fase-be05-giro-concurrente`
**Archivo:** `server/internal/spin/random.go`

La versión de `be05` sortea con una fuente propia, sembrada desde `crypto/rand` y protegida con un
mutex (D37). La rama la "simplifica" al generador global de `math/rand`, que sí es seguro entre
goroutines; en Go 1.19 arranca como si lo hubieran sembrado con `Seed(1)`:

```diff
-type Drawer struct {
-	mu  sync.Mutex
-	rng *rand.Rand
-}
+// Usa el generador global de math/rand: ya es seguro entre goroutines, así
+// que no hace falta ni el mutex ni una fuente propia.
+type Drawer struct{}
 …
-	d.mu.Lock()
-	n := d.rng.Intn(10000)
-	d.mu.Unlock()
+	n := rand.Intn(10000)
```

**Queda bien si** (medido el 19/10/2026): dos arranques del binario de 2.000 giros cada uno sobre la
Esclusa de Oro coinciden en las 2.000 posiciones, con χ² = 6,04 en los dos (sin alarma); en la fase
coinciden 357. La regresión (`random_test.go`, que se relanza a sí misma dos veces) falla con *"dos
arranques sortearon la misma secuencia: ihbecbecad"*, y la misma rama compilada con
`golang:1.20.14` la pasa. **La prueba no vive en la fase**: es la regresión del incidente (DR-02).

### `incidente/be-18` ➕ — el giro gratis con el reloj del celular

**Sale de:** `fase-be06-hora-dura-y-la-autoridad-del-reloj`
**Archivos:** `server/internal/http/handlers.go`, `server/internal/spin/free.go`

El handler de `POST /players/:id/free-spins` usa la hora de la cabecera `X-Client-Now` si viene, con un `ClaimFreeAt`
nuevo en el servicio; si no viene, `ClaimFree` como en la fase. El commit lo justifica con la cuenta regresiva del juego.

**Datos:** cualquier jugador; en el cuaderno, María R. (43). El celular adelantado **cuatro horas y un minuto**: con
cuatro exactas no alcanza, porque `nextFreeSpinAt` lleva milisegundos y la cabecera no.

**Queda bien si:** el segundo reclamo, con `X-Client-Now` adelantado, responde `200`; en `spin_log` hay dos giros gratis
de la misma jugadora con 16 ms de diferencia; y `next_free_spin_at > now() + interval '4 hours'` la encuentra. Con la
fase, `409 todavía no`. La regresión (`server/internal/http/free_spin_test.go`) falla en la rama con *"con el celular
cuatro horas adelante: 200 (esperaba 409)"*.

---

## 4. Las ramas de diff vacío

Tres incidentes no tienen ninguna línea que cambiar. La rama existe igual, porque el
enunciado la nombra y porque **fija el estado de la fase**: sale de su tag y no
commitea nada.

```bash
git checkout -b incidente/be-04 fase-be03-crud-y-el-reemplazo
```

Que su `git diff` esté vacío no es una omisión: es la lección. Son los tres casos en que
el código hace exactamente lo que dice y el problema vive en otra parte.

### `incidente/be-04` — la sesión en UTC

**Sale de:** `fase-be03-crud-y-el-reemplazo`, sin cambios.
**Qué lo produce:** el `DATABASE_URL` sin `timezone=America/Panama`. La sesión de Postgres queda en
la zona del servidor (`Etc/UTC` en `postgres:13`), `TIMESTAMPTZ` devuelve el instante en esa zona y
`encoding/json` lo serializa con `Z`. La zona en el DSN la fija `be03` como corrección mínima, y
`be06` la convierte en decisión (D29).

**Queda bien si** (medido): la tabla de ruedas muestra `2031-01-01T01:00:00Z` para la Esclusa de
Oro, donde la fase muestra `2030-12-31T20:00:00-05:00`; `SHOW TimeZone` dice `Etc/UTC`; la
verificación 3 de `smoke.sh` falla; y la guarda de cierre de la Fase 7 no cambia, porque el instante
es el mismo.

### `incidente/be-08` — el token que vence

**Sale de:** `fase-be04-identidad-real-jwt-y-un-cve`, sin cambios.
**Qué lo produce:** una variable de entorno, y nada más.

```bash
cd server && JWT_TTL=3m go run ./cmd/api
```

La renovación del token **no existe en ninguna fase del track** y está declarada como deuda 💸 viva
en `bea-09`, con su motivo escrito. El sistema hace lo correcto: un token que expira es una
propiedad de seguridad.

**Queda bien si** (medido en Electron): a los tres minutos y diez segundos, el primer clic termina
en `/login` con la sesión borrada, y el log del servidor dice `401: token inválido o expirado: token
is expired by 11.080124218s`. Y la otra mitad, la que explica el ticket: si cierras sesión y vuelves
a entrar, el reloj empieza de nuevo.

### `incidente/be-11` — el reloj adelantado

**Qué lo produce:** el reloj de la máquina de la operadora, una hora adelante, y una rueda que cierra en treinta minutos
(`UPDATE wheels SET closes_at = now() + interval '30 minutes' WHERE id = 1`). A mano, con la sincronización automática
apagada; en contenedor, con `cy.clock(Date.now() + 3600000, ["Date"])` en Cypress, que adelanta solo `Date` y deja
correr los temporizadores.

⚠️ **Poner `TZ` no reproduce este incidente.** `isWheelClosed` compara instantes, y una comparación de instantes es
independiente de la zona. Confundir zona con hora es precisamente la teoría del ticket (*"el horario de verano de
Chile"*), y si la preparación la usa, el enunciado se queda sin su lección.

**Queda bien si:** en el asistente de envíos la opción *Giro en Esclusa de Oro (cerrada)* está deshabilitada, y el mismo
envío `spin:1` mandado al servidor responde `201`. Medido el 19/10/2026: la consola en `04:11:12Z`, `X-Server-Time`
`03:11:14Z`. La asimetría es la respuesta: con el reloj adelantado se pierden giros legítimos, pero **los datos siguen
correctos**.

---

## 5. El que se reproduce contra el mock

`be-02` es de `be00`, la fase que **no escribe código**: la auditoría del contrato. Se reproduce
contra el mock de la Fase 11 tal como quedó, sin rama: veinte giros del juego y el tablero.

```bash
CHAOS_LEVEL=off npm run mock:all
npm start
for i in $(seq 1 20); do
  curl -s -o /dev/null -X POST -H 'Content-Type: application/json' \
       -d "{\"idempotencyKey\":\"k-be02-$i\"}" localhost:3001/players/42/spins
done
```

**Queda bien si** (medido el 19/10/2026): `stock.remaining` de la Esclusa de Oro baja de 1.000 a 980,
`GET /spinLog?wheelId=1` devuelve cero filas, y el tablero de esa rueda dice *Giros 0* y *Sin
alarma, χ² = 0.00*. El entregable es el hallazgo `C-03` en `server/CONTRACT.md`, no un commit.

(`be-01` era el otro incidente de `be00` y pasó a `be01`: el mock expone `X-Request-Id` desde la
Fase 2, así que el defecto ya no existe contra el mock. Decisión del autor, 18/10/2026.)

## 6. La carga concurrente

Tres incidentes no existen sin gente: `be-05`, `be-09` y `be-17`. Para `be-05` no hace
falta volumen sino **repetición**: veinticinco envíos del mismo caso, que es lo que hacen dos
operadoras compensando la misma lista. La receta está en el enunciado del incidente.

Para `be-09` **no alcanza**, y este es el error de preparación más común del track:
**la forma de la carga importa más que su tamaño.** Medido contra el giro de 2019: 3.000 peticiones
en llegadas parejas (`constant-arrival-rate`) a 50, 500 y 1.000 por segundo dejaron el stock exacto;
las mismas 3.000 con 50 usuarios virtuales girando apenas reciben respuesta (`shared-iterations`)
entregaron 1.030. Lo mismo con la rama de `be-09`: a 50 por segundo, bien; con la notificación,
1.500. El escenario `notificacion` de `server/load/giro.js` es la preparación.

En la prueba de Go, lo mismo lo hace la **barrera**: todos los clientes soltados a la vez, que es lo
que `race` construye en `race_test.go`. Sin ella, las goroutines salen escalonadas, la ventana entre
el `SELECT` y el `UPDATE` no se solapa, y el bug **no aparece**, con lo cual alguien concluye que el
giro concurrente está bien resuelto. Es el peor desenlace posible de una preparación mal hecha.

Para `be-17` no hay carga: son dos arranques del binario y una comparación de las
secuencias (§3).

---

## 7. Verificar que la preparación sirve

Lo mismo que en el track base, con una comprobación de más que este track necesita:

1. **El síntoma aparece**, y como lo describe el ticket.
2. **El resto del sistema sigue en pie**: `go test ./...` en la rama falla en lo que el
   incidente rompió y en nada más.
3. **El diff cabe en una pantalla** (o está vacío a propósito, §4).
4. **El frontend no cambió ni un archivo.** Es la regla que ordena todo el track, y
   también aplica a las ramas de incidente: si tu preparación tocó `src/`, la
   preparación está mal.

```bash
git diff --stat fase-be05-giro-concurrente...incidente/be-09 -- src/   # tiene que salir vacío
```

Para cada rama se corre la comprobación en la tanda que escribe su fase, y el resultado
(síntoma visto, o «no verificado por ejecución») va a la bitácora del plan.

---

## ⚠️ Advertencias

- **No abras este archivo mientras resuelves.**
- **El binario se arranca en el `3011` mientras el mock sigue en el `3001`** durante
  `be01` y `be02`; desde `be03` toma el `3001` y el mock se apaga (D21). Cada receta usa
  el puerto de su fase — si copias el comando de otra, vas a estar mirando el proceso
  equivocado, que es una forma muy cara de perder media hora.
- **La base se siembra antes de cada incidente**, con
  `go run ./cmd/seed -file ../mock/db.json`, para que los ids de los enunciados
  coincidan con los tuyos.
- **Las ramas no se mezclan entre sí**, y no se borran al terminar: son la única copia
  del estado roto.
- **Si una receta no reproduce el síntoma en tu repo, gana tu repo.** El código de
  `server/` lo escribiste tú siguiendo las fases; estas recetas describen el del curso.
  Ajusta la línea, no el enunciado.
