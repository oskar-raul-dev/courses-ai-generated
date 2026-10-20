# 🗄️ Fase be02 — La costura de datos y el mito de la agnosia

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Fase be02 de be09 · **10 horas**
> Depende de: be01 — el servidor HTTP ya corre · Habilita: be03 — CRUD y el reemplazo

---

## 🎯 1. Propósito

Juliana lo dice mirando el `db.json` de la Fase 11: *"la bitácora y el inventario que el estudio necesita no existen en el API viejo; los vamos a tener que poner nosotros"* (`00-historia-del-sistema.md` §9 y §11). El API de 2019 guardaba lo que el jugador recibía y nada más; el mock imita esa pobreza, y lo que la Fase 8 sembró para conciliar —las versiones de pesos, la bitácora completa, las compras— no tiene dónde vivir más allá de un archivo. Esta fase construye la capa de datos del backend: el pool de conexiones, las migraciones versionadas, el esquema completo de la rueda y el acceso con SQL escrito a mano. Y, mientras se construye, demuestra la tesis que le da nombre a la fase.

> 🧭 **La agnosia total de base de datos no existe.** Lo que existe es **portabilidad por disciplina**: una costura donde el dialecto se hace explícito, en vez de esconderse detrás de una abstracción que promete lo que no puede cumplir.

Esto no es una opinión de sobremesa y no se va a suavizar. Al terminar la fase vas a tener la misma prueba corriendo contra PostgreSQL y contra SQLite, y la misma consulta devolviendo **resultados distintos**, con los dos motores comportándose correctamente según su propia especificación. Esa evidencia es la que justifica la regla del motor de `be08`, y es la razón de que este track use `database/sql` y SQL a mano en vez de un ORM: un ORM esconde el dialecto exactamente donde queremos que se vea.

La deuda 💸 que prepara: `db.json` como almacén. Todavía no la cobra —eso es `be03`—, pero acá se construye la caja donde va a entrar.

---

## ✅ 2. Qué queda listo al terminar

- [ ] PostgreSQL 13 corriendo en contenedor y accesible por `DATABASE_URL`.
- [ ] `server/migrations/postgres/` y `server/migrations/sqlite/` con la migración del esquema completo, `up` y `down`, aplicable y reversible con `golang-migrate` v4.15.2.
- [ ] Las doce tablas de la rueda creadas: `users`, `wheels`, `wheel_versions`, `wheel_segments`, `players`, `player_inventory`, `packages`, `purchases`, `stock`, `spin_log`, `grants` y `reconciliations`.
- [ ] `server/internal/storage/` con el pool configurado, la costura de dialecto y el chequeo de salud de la base.
- [ ] `GET /health` reporta el estado de la conexión, con la decisión `200` contra `503` tomada y justificada por escrito.
- [ ] `server/internal/wheel/` con la interfaz `Store` y su implementación en `sqlx`, probada **desde pruebas de Go y no desde HTTP**.
- [ ] `go test ./...` pasa contra los dos motores.
- [ ] Existe `server/evidence/divergencias.md`: el inventario **medido** —con la salida pegada— de las divergencias entre SQLite y PostgreSQL que afectan a este backend.
- [ ] `git diff pre-backend-go..HEAD -- . ':!server'` no devuelve nada.

---

## 🚫 3. Qué queda fuera por ahora

- **Los handlers del contrato** → `be03`. Acá se construye la capa de datos y se prueba desde pruebas. Ni una ruta nueva que devuelva una rueda.
- **La siembra desde el `db.json` de la Fase 11** → `be03`. En esta fase los datos salen de las pruebas, que son otra cosa y tienen otro dueño.
- **`SELECT … FOR UPDATE`, aislamiento y el `409` de la base** → `be05`. Acá se **mide** que la semántica de bloqueo diverge; resolverlo con esa semántica es la fase ⭐ del track y no se le adelanta el final. Por la misma razón, la bitácora todavía no hace cumplir su clave de idempotencia ni rechaza un `UPDATE`.
- **El manejo fino de zonas horarias** → `be06`. Acá se elige `TIMESTAMPTZ` y se demuestra por qué SQLite no puede seguirle el paso; qué hace Postgres *realmente* con ese tipo es tema de la otra fase.
- **La decisión sobre `mattn/go-sqlite3` y cgo** → `be09`, donde se **mide** en tamaño de imagen y tiempo de compilación. Acá se usa `mattn` y ya se empieza a sentir el peso de `CGO_ENABLED=1`.

---

## 🧠 4. Conceptos mínimos

Tienes años de SQL. No vamos a explicar qué es un índice, una transacción ni una clave foránea. Lo que sigue es lo que Go hace distinto y lo que la convivencia de dos motores obliga a decidir.

### `*sql.DB` no es una conexión: es un pool

El error de modelo mental más caro para quien llega de otros lenguajes. Un `*sql.DB` es un **pool** de conexiones, seguro para uso concurrente, que se abre una vez al arrancar el proceso y se comparte con todas las goroutines. No se abre por petición, no se cierra al terminar un handler, y no se pasa por parámetro "para no compartir estado".

De ahí se derivan las tres cosas que hay que configurar y que nadie configura:

- **`SetMaxOpenConns`.** Sin límite, Go abre tantas conexiones como peticiones concurrentes haya, y Postgres las rechaza al llegar a `max_connections` (100 por defecto). El síntoma en producción es de manual: todo va perfecto hasta que hay carga, y entonces falla *todo* a la vez. La noche de la Esclusa de Oro tiene esa forma.
- **`SetMaxIdleConns`.** Si es menor que el máximo abierto, el pool cierra y reabre conexiones sin parar bajo carga sostenida. Cada reapertura es un handshake TCP y una autenticación.
- **`SetConnMaxLifetime`.** Las conexiones eternas sobreviven a los balanceadores y a los reinicios del servidor de base; una vida acotada las recicla antes de que se pudran.

Y la fuga de recursos clásica de Go no es olvidar cerrar la base: es **olvidar cerrar un `*sql.Rows`**, con una precisión que casi nadie conoce y que medimos: un `Rows` devuelve su conexión al pool cuando lo cierra `Close`, cuando `Next` llega al final, **o cuando se cancela su contexto**. Un bucle que recorre todo no pierde nada aunque no cierre, y una consulta hecha con el contexto de la petición tampoco, porque ese contexto se cancela al terminar el handler. La conexión se queda tomada cuando se juntan dos faltas: salir antes de recorrer el resultado, y consultar sin contexto. Medido con un pool de tres: cinco consultas que salen con la primera fila y usan `QueryContext` dejan 0 conexiones tomadas; las mismas con `Query` a secas dejan 3, y la cuarta se cuelga esperando. El síntoma, cuando pasa, es idéntico a "la base no responde".

### `sqlx` es una capa fina, y esa es toda su virtud

`sqlx` no es un ORM, no genera SQL y no esconde nada. Envuelve `database/sql` para ahorrarte el `rows.Scan(&a, &b, &c, …)` campo por campo —`Get`, `Select` y `StructScan` mapean a structs por etiquetas `db:"…"`— y agrega `Rebind`, que es lo que de verdad importa acá:

```go
// El mismo SQL, escrito una sola vez con placeholders "?":
query := db.Rebind(`SELECT id, name FROM wheels WHERE status = ? AND closes_at > ?`)
// contra Postgres  → WHERE status = $1 AND closes_at > $2
// contra SQLite    → WHERE status = ? AND closes_at > ?
```

Eso es una costura: un punto único, nombrado, donde la diferencia entre motores se resuelve a la vista. No es magia y no pretende serlo. **Y no alcanza**, que es justamente lo que vamos a demostrar.

> ⚠️ `Rebind` resuelve la sintaxis de los placeholders y nada más. No traduce tipos, ni funciones de fecha, ni semántica de bloqueo, ni `RETURNING`, ni `ON CONFLICT`, ni `ILIKE`. Creer que un `Rebind` te dio portabilidad es exactamente el mito que esta fase desmonta.

### Migraciones: dos archivos por versión, y un paso explícito

`golang-migrate` trabaja con pares `NNNNNN_nombre.up.sql` / `.down.sql` y una tabla de control (`schema_migrations`) donde anota en qué versión está la base. Dos reglas del curso, y las dos están en `D20`:

**Todo cambio de esquema es una versión nueva.** Editar una migración ya aplicada es la forma más rápida de que dos ambientes queden distintos sin que nadie pueda demostrarlo.

**Las migraciones se ejecutan como paso explícito, nunca al arrancar en producción.** La comodidad de `migrate.Up()` dentro de `main()` cuesta cara el día que tres réplicas arrancan a la vez y se pelean por aplicar el mismo `ALTER`: en el mejor caso una espera, en el peor la base queda a medio migrar. En las pruebas, la librería se usa desde el código y está bien; que sea distinto en producción es contenido de `be09`.

### La decisión de esta fase: DDL por dialecto, no subconjunto común

`D20` deja abierta una pregunta y hay que cerrarla: con dos motores, ¿el DDL es un **subconjunto común** que ambos entiendan, o se mantiene **uno por dialecto**?

> 🧭 **Decisión: uno por dialecto (D25).** `server/migrations/postgres/` y `server/migrations/sqlite/`, con los mismos números de versión y los mismos nombres.

El subconjunto común suena mejor y es peor, por una razón que se ve en cuanto lo intentas: el mínimo común denominador de PostgreSQL 13 y SQLite 3.35 no tiene `TIMESTAMPTZ`, ni `BIGSERIAL`, ni `JSONB`, ni `BOOLEAN`, ni tipos que se hagan cumplir —las tablas `STRICT` de SQLite llegaron en la 3.37—. Escribir el DDL en ese subconjunto significa **renunciar a Postgres para complacer al motor de pruebas**: degradar el sistema real para que el andamiaje sea más cómodo. Al revés de como debe ser.

Mantener dos juegos tiene un costo honesto y hay que decirlo: **pueden divergir**. Ese riesgo se administra con dos cosas, no con buenas intenciones: la prueba de `be08` que corre el mismo caso contra los dos motores, y la regla del motor que dice cuándo SQLite directamente no vale. El costo se paga a la vista; la alternativa lo escondía.

### Las tablas de la rueda, y por qué `/segments` se llama `wheel_segments`

El contrato de `be00` tiene una colección `segments` y otra `spinLog`. Las tablas se llaman `wheel_segments` y `spin_log`. No es capricho ni inconsistencia: **la etiqueta JSON es la frontera del contrato y la columna no lo es**. La consola recibe `{"wheelId":1,"segmentId":"esclusa-de-oro","weightBp":50}` y nunca ve un nombre de tabla. Adentro mandan las convenciones de SQL —plural, `snake_case`, prefijo del agregado— y afuera manda el contrato. La costura entre las dos convenciones vive en las etiquetas del struct, en un solo lugar, y se lee de un vistazo.

Hay una tabla que el contrato no muestra y que el dominio exige: **`wheel_versions`**. Una rueda en `live` no cambia sus pesos; cambiarlos es publicar una versión nueva (historia §9, D33). Cada versión es inmutable, tiene sus segmentos, y la vigente es la de número más alto. Hoy la consola no sabe que existen: ve los segmentos de la vigente. Mañana cada giro va a decir con qué versión se tiró, y la conciliación de `be07` va a agrupar por ella.

Y hay tres tablas que se escriben con la forma que el dato tiene hoy, no con la que debería tener, y las tres lo dicen en un comentario: la bitácora acepta filas sin rueda ni origen, porque el giro de 2019 las escribe así (`C-03`); las compras no tienen `UNIQUE` sobre el token, porque la conciliación de la Fase 8 encontró una acreditada dos veces; y los saldos y el stock no tienen `CHECK (>= 0)`, porque esa defensa es de `be05`.

---

## 💻 5. Implementación y código comentado

### 5.1 Levantar PostgreSQL 13

```bash
docker run -d --name esclusa-pg \
  -e POSTGRES_USER=esclusa \
  -e POSTGRES_PASSWORD=esclusa \
  -e POSTGRES_DB=esclusa \
  -p 5432:5432 \
  postgres:13

# Si ya tienes un Postgres local en el 5432, publica en 5433 y ajusta la URL.
export DATABASE_URL="postgres://esclusa:esclusa@localhost:5432/esclusa?sslmode=disable"
psql "$DATABASE_URL" -c 'select version();'
```

> 📝 `sslmode=disable` es correcto para un laboratorio local y sería un hallazgo de seguridad en cualquier otra parte. Queda declarado acá y se retoma en `be09`, donde la configuración por ambiente decide qué modo corresponde a cada uno. La receta completa del contenedor y el `docker-compose.yml` viven en `bea-02`.

### 5.2 Las dependencias

```bash
cd server
go get github.com/jmoiron/sqlx@v1.3.5 \
       github.com/lib/pq@v1.10.7 \
       github.com/mattn/go-sqlite3@v1.14.16 \
       github.com/golang-migrate/migrate/v4@v4.15.2
```

Cuando termines la sección, `go mod tidy`. Las cuatro quedan, porque el código las importa: `migrate` la usan las pruebas de 5.7 para aplicar el esquema.

> ⚠️ **`mattn/go-sqlite3` exige `CGO_ENABLED=1`.** Si tu `go build` empieza a tardar el triple y a pedirte un compilador de C, no está roto: acabas de adoptar una dependencia nativa. Ese peso es real, se va a hacer insoportable en `be09` al construir la imagen, y es exactamente la medición que `D19` deja pendiente para esa fase. No lo cambies todavía: la incomodidad es el dato.

### 5.3 Las migraciones

`server/migrations/postgres/000001_initial_schema.up.sql`:

<<<archivo:server/migrations/postgres/000001_initial_schema.up.sql>>>

`server/migrations/postgres/000001_initial_schema.down.sql`:

<<<archivo:server/migrations/postgres/000001_initial_schema.down.sql>>>

Y ahora **el mismo esquema para SQLite**, que es donde la costura deja de ser teórica. `server/migrations/sqlite/000001_initial_schema.up.sql`:

<<<archivo:server/migrations/sqlite/000001_initial_schema.up.sql>>>

El `down` de SQLite es el mismo de Postgres, con su ruta en el comentario: `DROP TABLE IF EXISTS` lo entienden los dos.

Aplicarlas:

```bash
# El binario de la misma versión que la librería (D20), con los dos drivers.
go install -tags 'postgres sqlite3' \
  github.com/golang-migrate/migrate/v4/cmd/migrate@v4.15.2

migrate -path migrations/postgres -database "$DATABASE_URL" up
migrate -path migrations/postgres -database "$DATABASE_URL" version
migrate -path migrations/postgres -database "$DATABASE_URL" down 1   # y vuelve
migrate -path migrations/postgres -database "$DATABASE_URL" up
```

Corrida del 19/10/2026: `1/u initial_schema (38.21725ms)`, `version` responde `1`, `down 1` deja la base sin versión (`error: no migration`) y el segundo `up` la vuelve a dejar en `1`. Con SQLite, `-database "sqlite3:///tmp/esclusa.db"` hace lo mismo. El `go install` compila con cgo y tardó 29 segundos en un contenedor arm64: es la primera vez que lo sientes.

> ⚠️ **El estado `dirty`.** Si una migración falla a la mitad, `golang-migrate` marca la base como sucia y **se niega a seguir** hasta que alguien decida qué pasó. Es lo correcto y es lo que más asusta la primera vez. Se sale con `migrate … force <versión>`, después de mirar con `psql` en qué quedó de verdad el esquema. Provócalo a propósito en el ejercicio 14: es mejor conocerlo un martes de laboratorio que la noche de un evento.

### 5.4 El pool y la costura: `internal/storage`

<<<archivo:server/internal/storage/storage.go>>>

Y la conexión de SQLite necesita un DSN con dos parámetros que casi nadie pone:

```go
// Para pruebas. Los dos parámetros son obligatorios y por motivos distintos:
//   _foreign_keys=on  → sin esto las FK son decorativas (SQLite las apaga
//                       por defecto, y por conexión, no por base).
//   _busy_timeout     → sin esto, dos escrituras simultáneas devuelven
//                       SQLITE_BUSY al instante en vez de esperar su turno.
const testDSN = "file::memory:?cache=shared&_foreign_keys=on&_busy_timeout=5000"
```

### 5.5 `GET /health` crece, y hay que decidir `200` o `503`

`be01` dejó la pregunta abierta y el ejercicio 31 la planteó. Se cierra acá, porque el orquestador de `be09` va a actuar según esta respuesta.

> 🧭 **Decisión: `/health` responde `503` si la base no responde (D26).** El endpoint reporta si el servicio **puede hacer su trabajo**, no si el proceso está vivo. Un backend de la rueda sin base no puede hacer absolutamente nada útil: mantenerlo en `200` solo consigue que el balanceador le siga mandando tráfico para que falle petición por petición.

El matiz que evita el desastre —y que hay que escribir junto a la decisión— es que **reiniciar el contenedor no arregla una base caída**. Si el orquestador usa este endpoint como *liveness probe*, va a reiniciar el backend en bucle mientras Postgres se recupera. Este `/health` es una *readiness probe*: "no me mandes tráfico". La distinción se implementa en `be09` con dos rutas.

<<<archivo:server/internal/http/health.go>>>

El router lo recibe con el pool, que ahora viaja en `Config`, y `main.go` abre la base una sola vez al arrancar. Los dos cambios, en sus fragmentos:

<<<fragmento:server/internal/http/router.go|type Config struct {|r.HandleFunc("/health", healthHandler(cfg.DB)).Methods(http.MethodGet)>>>

<<<fragmento:server/cmd/api/main.go|	// El pool se abre una vez y se comparte.|		DB:            db,
	})>>>

Medido el 19/10/2026: con la base arriba, `{"database":"ok","status":"ok"}` y `200`; con el contenedor de Postgres detenido, `{"database":"unreachable","status":"degraded"}` y `503`, en medio milisegundo. Y si la base no está al arrancar, el proceso no arranca: `no se pudo abrir la base: la base no responde (postgres): dial tcp …`. Ese es el `Ping` de `Open` haciendo su trabajo.

### 5.6 El primer store: `internal/wheel`

Acá aparece la arquitectura en capas que sostiene el resto del track. Hoy solo existe la capa de abajo.

<<<archivo:server/internal/wheel/wheel.go>>>

<<<archivo:server/internal/wheel/store.go>>>

> 🧠 **Fíjate en `currentVersion` concatenado en las consultas.** Es concatenación de string en una consulta, que en cualquier otro contexto sería un pecado; acá el fragmento sale de una constante del propio código y no de una entrada del usuario. **Los datos siempre van por placeholder, sin excepción**; los fragmentos de SQL salen de constantes o de la costura (`Now()`), y de ningún otro lado. `bea-08` trata la distinción con el detalle que merece.

### 5.7 Las pruebas: la capa se prueba desde Go, no desde HTTP

<<<archivo:server/internal/wheel/store_test.go>>>

```bash
go test ./...                                                       # SQLite en memoria

# Postgres, contra una base APARTE: las pruebas bajan y suben todas las migraciones.
psql "$DATABASE_URL" -c 'CREATE DATABASE esclusa_test'
TEST_DATABASE_URL="postgres://esclusa:esclusa@localhost:5432/esclusa_test?sslmode=disable" go test ./...
```

> ⚠️ **Nunca `TEST_DATABASE_URL="$DATABASE_URL"`.** `applyMigrations` empieza con todos los `down`: contra la base de desarrollo, la prueba borra todo lo que tengas, y desde `be03` eso es tu siembra.

> ⚠️ **`TestCreateAndFind` es la primera prueba que se comporta distinto según el motor**, y no por un bug tuyo. Córrela con los dos y anota qué pasa con `ClosesAt`. Esa diferencia es la pieza forense.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. `LastInsertId` en vez de `RETURNING`.** Síntoma: las pruebas pasan en SQLite y en producción todo alta devuelve `500` con `LastInsertId is not supported by this driver` (medido con `lib/pq` v1.10.7). Causa: `lib/pq` no lo implementa —el protocolo de Postgres no lo ofrece— y `mattn/go-sqlite3` sí. Fix mínimo: `RETURNING id`. Este error es el arquetipo de todo lo que `be08` va a formalizar: **una suite verde contra el motor equivocado es peor que no tener suite, porque da permiso para desplegar**.

**2. Devolver `nil` en vez de un slice vacío.** Síntoma: la consola recibe `null` donde esperaba `[]`, y `wheels.map is not a function` explota en `WheelTable`. Causa: `var wheels []Wheel` sin inicializar serializa a `null` (medido: `null` contra `[]`). Fix: `wheels := []Wheel{}`. Contrato de `be00`, régimen estricto, y una línea de código; `TestListWithoutWheelsIsAnEmptyArray` lo cuida.

**3. Un `?` que llega a Postgres sin `Rebind`.** Síntoma: la consulta funciona en todas las pruebas con SQLite y en Postgres devuelve `pq: syntax error at end of input`. Causa: saltarse `Rebind`; SQLite entiende `?` y Postgres no. El sentido contrario no te salva: un `$1` escrito a mano funciona en los **dos** motores (SQLite lo toma como parámetro con nombre, medido), así que la mezcla pasa todas las pruebas hasta que no. Regla operativa: **todo el SQL del store se escribe con `?` y pasa por `Rebind`**, y un `$1` literal en un archivo de store es un hallazgo de revisión aunque hoy funcione.

**4. Confiar en que SQLite valida tipos.** Síntoma: una prueba inserta `package_price_cents` como texto, pasa feliz, y el mismo caso revienta en Postgres con `invalid input syntax for type bigint`. Causa: la **afinidad de tipos** de SQLite, que acepta casi cualquier cosa en casi cualquier columna. Fix: no hay fix en el código; hay una regla, y es la de `be08`.

**5. `*sql.Rows` sin cerrar.** Síntoma: después de un rato de tráfico, todo se cuelga esperando una conexión. Causa: un `Rows` que sale antes de recorrerse, en una consulta sin contexto: nadie lo cierra, ni `Next` ni la cancelación. Fix: `defer rows.Close()` sin excepción, contexto en toda consulta (guía §16.3), o `Select`/`Get` de `sqlx`, que cierran solos. `List` usa `QueryxContext` a propósito, con su `defer`, para que lo veas escrito una vez; y si alguna vez lo olvidas en un bucle que recorre todo, no va a pasar nada, que es justo por qué el olvido sobrevive a la revisión.

### 🩻 Pieza forense de esta fase

**La misma consulta, dos motores, dos resultados.** No se argumenta la diferencia: se muestra. Guarda todo en `server/evidence/divergencias.md` con la salida pegada: ese archivo es un entregable, y es el que `be08` va a citar para justificar su regla. Las salidas de abajo son las de la corrida del 19/10/2026, con SQLite 3.39.4 (el que trae `mattn/go-sqlite3` v1.14.16) y PostgreSQL 13.23.

*Divergencia 0 — la prueba que no corre.* Antes de cualquier consulta a mano: declara `closes_at TEXT` en la migración de SQLite y corre `go test ./...`. `TestCreateAndFind` revienta con `sql: Scan error on column index 3, name "closes_at": unsupported Scan, storing driver.Value type string into type *time.Time`. Por eso la migración dice `TIMESTAMP`: no es un tipo de SQLite —acepta cualquier nombre y guarda texto igual—, es una pista que `mattn/go-sqlite3` lee para convertir a `time.Time`. Ahora pide en cada motor qué guardó, con la rueda de la prueba (cierre `2030-12-31T20:00:00-05:00`): SQLite guarda el texto `2030-12-31 20:00:00-05:00` y Go lee `2030-12-31T20:00:00-05:00`; Postgres guarda el instante y, con la sesión en UTC, Go lee `2031-01-01T01:00:00Z`. El mismo instante, y la consola de la Fase 7 lo va a mostrar distinto según qué motor conteste. Guarda ese dato: es el incidente `be-04`.

*Divergencia 1 — el motor que acepta cualquier cosa.* La misma sentencia contra los dos:

```sql
INSERT INTO packages (product_id, spins, package_price_cents) VALUES ('spins-10', 10, 99);
INSERT INTO packages (product_id, spins, package_price_cents) VALUES ('spins-x', 10, 'mucha plata');
SELECT sum(package_price_cents), count(*) FROM packages;
```

Postgres rechaza la segunda: `invalid input syntax for type bigint: "mucha plata"`, y la suma da `99 | 1`. SQLite **la acepta y guarda el texto** en una columna `INTEGER`, por afinidad de tipos, y la suma da `99 | 2`: dos paquetes en el catálogo, y la plata de uno no existe. Una de las dos bases acaba de mentir sobre cuánto cuesta lo que vende el estudio.

*Divergencia 2 — el instante que es una cadena.* Esta es la principal, porque toca el corazón del dominio. Inserta la Semana del Canal en los dos motores con `closes_at = '2026-08-15T20:00:00-05:00'` —que es el **16 de agosto a la 01:00 UTC**— y corre en ambos:

```sql
SELECT name FROM wheels WHERE closes_at > '2026-08-16T00:00:00Z';
```

PostgreSQL entiende los dos valores como instantes, compara 01:00Z contra 00:00Z y **devuelve la rueda**. SQLite compara **cadena contra cadena**: `'2026-08-15…'` contra `'2026-08-16…'`, ve que `15 < 16` y **no devuelve nada**. Los dos motores funcionan perfectamente según su especificación, y tu regla de negocio —"no se envían giros de una rueda que ya cerró"— da resultados opuestos según dónde corra.

Escribe la prueba que demuestra esto y déjala en el repositorio. Es el primer miembro del par de pruebas contradictorias que `be08` va a exigir.

*Divergencia 3 — el `RETURNING` que casi no está.* Comprueba tu versión de SQLite con `select sqlite_version();` (la corrida dio `3.39.4`). Si fuera anterior a 3.35, `RETURNING` fallaría y `Create` no correría. Anota la versión que tienes y por qué `D18` fija esa cota: no es un número redondo elegido al azar, es marzo de 2021, cuando llegó la sentencia.

*Divergencia 4 — el bloqueo que no existe.* Solo míralo, no lo resuelvas:

```sql
SELECT id FROM wheels WHERE id = 1 FOR UPDATE;
```

Postgres devuelve la fila y la bloquea hasta el fin de la transacción. SQLite responde `near "FOR": syntax error`. Anótalo y cierra la terminal: resolverlo es la fase ⭐ `be05`, y saber que el problema existe es todo lo que esta fase necesita.

*Divergencia 5 — las claves foráneas apagadas.* Con `_foreign_keys=on` fuera del DSN, inserta un segmento con un `wheel_version_id` que no existe. SQLite lo acepta sin chistar —`PRAGMA foreign_keys` dice `0`, aunque la migración tenga `PRAGMA foreign_keys = ON`: es por conexión, y `migrate` corrió en la suya—; Postgres responde `violates foreign key constraint "wheel_segments_wheel_version_id_fkey"`. Vuelve a ponerlo y repite. Anota cuántas de tus pruebas seguirían pasando con las FK apagadas.

*Divergencia 6 — `LIKE`, las mayúsculas y las tildes.* Esta pega en el contrato. La búsqueda de jugadores de la Fase 6 manda `name_like`, y en el mock eso es una expresión regular de JavaScript con la bandera `i`: `ángela` encuentra a `Ángela M.`. Con dos jugadores, `Juan P.` y `Ángela M.`:

| Consulta | SQLite | PostgreSQL |
|---|---|---|
| `name LIKE '%juan%'` | `Juan P.` | (sin filas) |
| `name LIKE '%ángela%'` | (sin filas) | (sin filas) |
| `lower(name) LIKE '%ángela%'` | (sin filas) | `Ángela M.` |
| `name ILIKE '%ángela%'` | no existe | `Ángela M.` |

El `LIKE` de SQLite ignora mayúsculas solo en ASCII, y su `lower()` no toca las tildes; el de Postgres distingue mayúsculas, y `ILIKE` no existe en SQLite. Ninguno de los dos honra el contrato con la misma consulta. `be03` tiene que decidir cómo, y esa decisión ya sabe que no va a ser portable.

*Divergencia 7 — la tuya.* Busca una más. Candidatos honestos: el comportamiento de `ORDER BY` con mayúsculas y tildes, qué hace cada motor con un `ALTER TABLE … DROP COLUMN`, cómo se guarda un `BOOLEAN`, o si `AUTOINCREMENT` reutiliza ids después de un `DELETE`. Mídela, no la busques en un blog.

*El círculo, tercera parte.* En `be00` seguiste un `X-Request-Id` desde la consola del navegador hasta el mock, que no lo anotaba. En `be01` llegó al log del servidor. Ahora agrégalo al log de la consulta: un `Printf` con el id, el SQL y la duración dentro del store, temporal y solo para verlo funcionar.

```go
// Temporal, para la pieza forense.
start := time.Now()
err = s.db.SelectContext(ctx, &segments, query)
log.Printf("[req-id %s] SQL %s → %v en %s",
    httpapi.RequestIDFrom(ctx), "SELECT … FROM wheel_segments", err, time.Since(start))
```

Ese es el recorrido completo que el track prometía: **consola del navegador → línea de log del servidor → consulta SQL con su tiempo**. Quítalo después: en `be03` el paquete `http` va a importar `wheel`, y este import al revés haría un ciclo que el compilador no perdona. El lugar correcto para esto es un middleware de instrumentación, y eso es `bea-07`.

---

> 📓🔥 De esta fase salen los incidentes **be-04** y **be-05** de `cuaderno-incidentes-be.md`. Los dos nacen en el código de esta fase y se ven desde `be03`, cuando la consola empieza a leer del binario. El be-05 es hermano del incidente **19** del track base —el mismo *"anda bien hasta que crece"*— con el recurso agotado en esta orilla del cable en vez de la otra.

---

## 🧪 7. Ejercicios (33)

**🟢 Fácil (1–8)**

1. Levanta Postgres 13 en contenedor y verifica la versión con `psql`.
2. Aplica las migraciones de Postgres, comprueba el `version`, hazles `down 1` y vuelve a subirlas.
3. Verifica en `psql` con `\d wheels` y `\d spin_log` que los tipos son los que escribiste, no los que creías escribir.
4. Corre `go test ./...` contra SQLite en memoria y comprueba que pasa.
5. Crea la base `esclusa_test`, corre la misma suite con `TEST_DATABASE_URL` apuntando a ella y compara la línea de `closesAt leído` que imprime cada motor con `go test -v`.
6. Apaga el contenedor de Postgres y comprueba que `GET /health` responde `503` con `database: unreachable`.
7. Confirma que `Rebind` produce `$1` contra Postgres y `?` contra SQLite, imprimiendo la consulta antes de ejecutarla.
8. Comprueba con `select sqlite_version();` que tu SQLite es 3.35 o superior, y explica en dos líneas por qué importa.

**🟡 Intermedio (9–19)**

9. Agrega a `wheel.Store` un método `Delete` con su prueba, y decide qué tiene que pasar con la bitácora de una rueda borrada. Justifica con el comentario de `spin_log` en la migración.
10. **Diagnóstico.** Cambia `wheels := []Wheel{}` por `var wheels []Wheel`, serializa el resultado y explica qué le pasaría a `WheelTable` de la Fase 4. Sé específico sobre qué línea del frontend rompe.
11. **Diagnóstico.** Reemplaza `RETURNING id` por `LastInsertId` en `Create` y corre la suite contra los dos motores. Pega las dos salidas y explica por qué esto es peligroso y no solo molesto.
12. Escribe la migración `000002` que agrega un índice sobre `wheels(status)`, en los dos dialectos, con su `down`.
13. Mide con `EXPLAIN ANALYZE` una consulta de `spin_log` por `wheel_id` con y sin el índice `spin_log_by_wheel`, sobre diez mil filas.
14. **Diagnóstico.** Provoca a propósito un estado `dirty`: escribe una migración con un error de sintaxis a la mitad, aplícala, y sal del estado con `force`. Documenta el procedimiento como si fuera un runbook.
15. Escribe la Divergencia 1 de la pieza forense como prueba de Go, con las dos aserciones opuestas y un comentario que explique por qué contradecirse es correcto.
16. Configura `SetMaxOpenConns(1)` contra Postgres y observa qué pasa con veinte peticiones concurrentes a `/health`. Mide los tiempos.
17. **Diagnóstico.** Con `SetMaxOpenConns(3)`, escribe una consulta sin `defer rows.Close()` en tres variantes —recorriendo todo, saliendo con la primera fila con `QueryContext`, y saliendo con la primera fila con `Query`— y lánzala cinco veces en cada una. Anota `db.Stats().InUse` después de cada variante y explica por qué solo una agota el pool.
18. Agrega a `Wheel` un campo `CreatedAt` con su etiqueta JSON y decide, citando `be00`, si eso rompe el contrato o es régimen de crecimiento.
19. **Diagnóstico.** Quita `_foreign_keys=on` del DSN de pruebas y determina cuántas pruebas siguen pasando. Explica qué te dice ese número sobre tu suite.

**🟠 Difícil (20–28)**

20. **Diagnóstico.** Ejecuta la Divergencia 2 completa (el instante que es una cadena) y escribe `server/evidence/divergencias.md` con la evidencia de ambos motores. Este es el entregable central de la fase.
21. Encuentra la divergencia 7 por tu cuenta, con evidencia medida, y agrégala al documento.
22. **Diagnóstico.** Escribe una consulta que devuelva el resultado correcto en SQLite y el incorrecto en Postgres. Sí, en ese sentido: la asimetría no es siempre a favor de Postgres (la Divergencia 6 es una pista), y encontrar el caso contrario es lo que hace honesta la tesis de la fase.
23. Implementa `Now()` para un tercer motor hipotético (MySQL) y enumera todo lo demás que habría que tocar. Usa esa lista para argumentar por escrito cuánta portabilidad daba de verdad la costura.
24. **Diagnóstico.** Las consultas de `sqlStore` concatenan `currentVersion`. Construye el caso en que una concatenación así sería una vulnerabilidad de inyección y demuestra por qué acá no lo es. Después escribe la regla que separa los dos casos.
25. Instrumenta el store con la duración de cada consulta y el `X-Request-Id`, siguiendo la tercera parte de la pieza forense, sin el ciclo de imports, y déjalo detrás de una variable de entorno `SQL_DEBUG`.
26. **Diagnóstico.** Con `SQL_DEBUG` activo, encuentra la consulta más lenta de la suite y explica por qué lo es.
27. Argumenta por escrito la decisión contraria a la de la fase: DDL en subconjunto común. Enumera exactamente qué habría que sacrificar del esquema de 5.3 y decide si en algún proyecto real valdría la pena.
28. **Diagnóstico.** Simula que Postgres se cae a mitad de una consulta larga (detén el contenedor). Determina qué error recibe Go, cuánto tarda en darse cuenta, y qué de eso controlan `SetConnMaxLifetime` y los timeouts.

**🔴 Muy difícil (29–33)**

29. Diseña el mecanismo que garantiza que las migraciones de los dos dialectos no diverjan: qué prueba lo detectaría, en qué momento correría, y qué le impediría a alguien saltárselo. Impleméntalo aunque sea de forma tosca.
30. **Diagnóstico + regresión.** Te entregan este ticket: *"desde ayer, las ruedas aparecen con la hora de cierre corrida cinco horas"*. Con lo que sabes de las Divergencias 0 y 2, enumera las cinco causas posibles ordenadas por probabilidad, di cómo descartarías cada una con una sola consulta, y escribe la prueba de regresión.
31. Escribe el par de pruebas contradictorias que `be08` va a necesitar: una que **pase en SQLite y falle en Postgres**, y otra que haga exactamente lo contrario. Documenta ambas con su justificación.
32. Toma la interfaz `Store` y argumenta si debería vivir en el paquete `wheel` o en el paquete que la consume. Defiende las dos posturas con el argumento de las interfaces implícitas y decide con un criterio operativo, no estético.
33. **Post-mortem.** Escribe el post-mortem del incidente ficticio *"la suite estaba verde y el despliegue rompió el alta de ruedas"*, con causa raíz en `LastInsertId`. Según los ocho puntos del post-mortem de `cuaderno-incidentes.md`: síntoma, evidencia, causa raíz, corrección, prueba de regresión, prevención. La prevención tiene que ser una regla verificable, no "tener más cuidado".

**🔥 Opcionales**

- 🔥 Reescribe `sqlStore` con GORM y compara: líneas de código, SQL generado (actívale el log), y —lo importante— qué le pasa a las divergencias 0 a 6. ¿El ORM las resuelve, las esconde o las empeora?
- 🔥 Sustituye `mattn/go-sqlite3` por `modernc.org/sqlite` y mide el tiempo de `go build` y `go test` antes y después. Guarda los números: `be09` los va a pedir.
- 🔥 Agrega `pgx` como driver alternativo de Postgres y mide si algo cambia en las divergencias. Argumenta si valdría la pena migrar desde `lib/pq` en un sistema real.

---

## 📚 8. Referencias

**Documentación oficial**
- https://pkg.go.dev/database/sql — y sobre todo la sección sobre el pool y el manejo de `Rows`.
- https://go.dev/doc/database/ — la guía oficial de acceso a datos, corta y con las trampas clásicas.
- https://jmoiron.github.io/sqlx/ — la guía de `sqlx`. `Rebind`, `Get`, `Select` y `StructScan` son el 90 % de lo que vas a usar.
- https://www.postgresql.org/docs/13/ — fija la versión 13 en la URL; la documentación de Postgres cambia de una versión a otra en detalles que importan.
- https://www.sqlite.org/datatype3.html — la afinidad de tipos, que es la Divergencia 1 explicada por sus propios autores. Léela entera: son diez minutos y explican la mitad de la fase.
- https://www.sqlite.org/lang_returning.html — `RETURNING`, con su nota de versión.
- https://www.sqlite.org/lang_expr.html#like — el `LIKE` de SQLite y su sensibilidad a mayúsculas, solo en ASCII.
- https://www.sqlite.org/quirks.html — el documento donde SQLite enumera honestamente en qué se aparta de todos los demás. Es el mejor material de esta fase.
- https://github.com/mattn/go-sqlite3 — la sección de tipos de fecha: qué nombres de columna hacen que el driver convierta a `time.Time`.
- https://github.com/golang-migrate/migrate — el CLI, la librería, el estado `dirty` y el formato de los archivos.

**Libros**
- *Designing Data-Intensive Applications* (Martin Kleppmann) — los capítulos 2 y 7. No trata de portabilidad, pero es el mejor texto sobre por qué las garantías de una base no son intercambiables.
- *The Art of PostgreSQL* (Dimitri Fontaine) — para el argumento contrario al de esta fase: aprovechar el motor a fondo en vez de escribir para el mínimo común. Vale la pena leerlo con esa tensión en mente.

**Video / apoyo**
- Busca "SQLite quirks" y "Postgres timestamptz explained" en YouTube. Para lo segundo, guárdate el mejor que encuentres: `be06` lo va a necesitar.

**Orden de lectura sugerido:** `datatype3.html` de SQLite primero, que explica la Divergencia 1 antes de que la veas → la guía de `sqlx`, que es corta → la documentación del pool de `database/sql` → y `bea-03` para el diccionario completo de divergencias, que es donde vive el detalle que acá solo se mide.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las referencias a libros son de memoria y pueden ser inexactas. La documentación de Postgres tiene una versión por URL: si aterrizas en la última, cambia el número a 13 antes de creerle. Cualquier discrepancia de versiones la resuelve `00-decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Tienes una capa de datos real: pool configurado, migraciones versionadas y reversibles en dos dialectos, el esquema completo de la rueda —con las versiones de pesos y la bitácora que el API de 2019 nunca tuvo—, un store con SQL a la vista y pruebas que corren contra los dos motores. Y tienes algo más valioso que el código: **la evidencia medida de que la portabilidad total es un mito**, guardada en un archivo que `be08` va a citar para convertirla en regla.

`be03` es la bisagra del track. Ahí se implementan los recursos del contrato en capas —handler → service → store—, se siembra la base desde **tu** `db.json`, y se apaga el mock para levantar el binario de Go en el `3001`. El criterio de aprobación ya está escrito desde `be00` y no es opinable: `server/smoke.sh` pasa o no pasa, y la consola no cambia ni un archivo.

> **La señal de que quedó bien:** *"puedo señalar en el código las líneas donde mi backend sabe contra qué motor está hablando, y puedo demostrar con una consulta por qué ninguna sobra."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be02-la-costura-de-datos -m "be02 cerrada: \
> Postgres 13 en contenedor; migraciones versionadas por dialecto con up y down; \
> esquema de las doce tablas de la rueda; pool configurado y costura de dialecto; \
> GET /health con 503 decidido y justificado; wheel.Store con sqlx probado desde pruebas; \
> suite verde contra los dos motores; \
> server/evidence/divergencias.md con las divergencias medidas"
> ```
>
> Los commits de la fase llevan su prefijo (`be02: …`) y los de ejercicio su número (`be02 ej20: …`). Si un ejercicio merece su propio marcador va en `ej/be02/20`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` / `-fix`, con el ID que le reserva `cuaderno-incidentes-be.md`. Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- ✅ **Resuelto: los nombres de store** quedaron como convención del backend: `sqlStore` cuando una implementación sirve a los dos motores (el caso de esta fase) y `<motor><Dominio>Store` cuando es específica de uno (el caso que llega en `be05` con `FOR UPDATE`).
- ✅ **Registradas en `00-decisiones-y-versiones.md` como `D25` y `D26`** las dos decisiones que esta fase cierra: **DDL por dialecto** y **`/health` responde `503`**. Las dos afectan a `be09`.
- **`server/evidence/divergencias.md` es entregable citable:** `be08` lo usa como base de su regla del motor y `bea-03` lo amplía a diccionario completo. Que `be08` no lo reescriba desde cero.
- **Para `be03`:** (1) la Divergencia 6 decide cómo se implementa `name_like`, que en el mock es una expresión regular con la bandera `i`; (2) la Divergencia 0 decide la zona de la sesión: sin ella, `closesAt` sale con `Z` y la verificación 3 de `smoke.sh` falla; (3) `reconciliations` nace sin `band_alarms`, `missing_in_api` ni `duplicated_in_api`, y la migración `000003` de `be03` los agrega (es la que quita el incidente `be-07`).
- **La columna `users.password`** queda en claro a propósito, replicando el mock. `be04` la renombra a `password_hash` en su propia migración (`000004`), y esa migración es parte de cobrar la deuda, no un detalle de implementación.
- **`be05` necesita de esta fase:** `spin_log.idempotency_key` existe pero no es `UNIQUE`; `players.free_spins`, `players.paid_spins` y `stock.remaining` no tienen `CHECK (>= 0)`; `grants` no tiene `UNIQUE (player_id, case_id)`. Que `be05` lo diga explícitamente —el lector va a creer que ya está protegido— y decida ahí sus defensas.
- **`be07` necesita de esta fase:** `purchases` sin `UNIQUE` sobre el token, con la compra duplicada de la Fase 8 adentro; la migración que lo agregue tiene que limpiar primero.
- **`be06` hereda la Divergencia 2** como su gancho de apertura. El caso ya está medido acá.
- **`be09` hereda dos mediciones pendientes:** el peso de `CGO_ENABLED=1` (29 segundos de `go install` del CLI de `migrate`, que esta fase deja sentir) y los números del ejercicio 🔥 de `modernc.org/sqlite`.
- **Deudas declaradas en esta fase:** 💸 `users.password` en claro (se paga en `be04`); 💸 `sslmode=disable` (se retoma en `be09`); 💸 las migraciones se aplican a mano en desarrollo (la política de producción se decide en `be09`).
- **Reserva para el cuaderno de incidentes:** `be-04` — *"las ruedas aparecen con la hora corrida"* (🔥 base de datos, 🟠), la Divergencia 0 llegada como ticket vago; y `be-05` — *"todo funciona hasta que hay gente"* (🔥 base de datos, 🔴), el pool agotado por `Rows` sin cerrar. Los dos se reproducen desde `be03`.
