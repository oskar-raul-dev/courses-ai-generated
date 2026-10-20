# 🔒 Apéndice bea-05 — Concurrencia en PostgreSQL

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Consulta rápida · ~3 horas
> Lo referencian: `be05` principalmente; `be07` y `be08` lo consultan

---

Este apéndice es **ejecutable**. Cada mecanismo viene con su sesión doble reproducible en dos terminales de `psql`, porque la concurrencia es de esas cosas que no se entienden leyendo: se entienden viendo una transacción esperar.

Damos por sabido qué es una transacción y qué es un nivel de aislamiento. Lo que probablemente no hayas tenido que hacer nunca es **elegir uno con un premio de edición limitada de por medio**, sabiendo que si te equivocas alguien se lleva una Esclusa de Oro que no existe. Eso es lo que se practica acá.

**Preparación**, en una base aparte para no tocar la de la aplicación (`createdb bea05`):

```sql
CREATE TABLE demo_stock (
    id         BIGSERIAL PRIMARY KEY,
    wheel_id   BIGINT  NOT NULL,
    segment_id TEXT    NOT NULL,
    remaining  INTEGER NOT NULL,
    UNIQUE (wheel_id, segment_id)
);
INSERT INTO demo_stock (wheel_id, segment_id, remaining)
VALUES (1, 'esclusa-de-oro', 1), (1, 'avatar-raro', 5);

CREATE TABLE demo_spins (
    id              BIGSERIAL PRIMARY KEY,
    idempotency_key TEXT   NOT NULL UNIQUE,
    player_id       BIGINT NOT NULL,
    delivered_prize TEXT   NOT NULL
);
CREATE TABLE demo_players (id BIGINT PRIMARY KEY, free_spins INTEGER NOT NULL);
INSERT INTO demo_players VALUES (42, 1);
CREATE TABLE demo_requests (
    idempotency_key TEXT PRIMARY KEY,
    player_id       BIGINT NOT NULL REFERENCES demo_players(id)
);
```

Queda **una** Esclusa de Oro. Abre **dos terminales** contra la misma base; en lo que sigue, **T1** y **T2**. Vuelve a correr la preparación antes de cada sección. Las salidas son de una corrida del 19/10/2026 en `postgres:13` (13.23), con las dos sesiones a la vez.

---

## 🧭 Índice de salto rápido

1. [El bug, en dos terminales](#1-el-bug-en-dos-terminales)
2. [Niveles de aislamiento y qué previene cada uno](#2-niveles-de-aislamiento-y-qué-previene-cada-uno)
3. [`FOR UPDATE` y sus variantes](#3-for-update-y-sus-variantes)
4. [Escribir con la condición: el `UPDATE` condicional y `ON CONFLICT`](#4-escribir-con-la-condición-el-update-condicional-y-on-conflict)
5. [El índice único, última línea de defensa](#5-el-índice-único-última-línea-de-defensa)
6. [Pesimista contra condicional: cómo elegir](#6-pesimista-contra-condicional-cómo-elegir)
7. [Deadlocks](#7-deadlocks)
8. [Observarlo todo: `pg_stat_activity` y `pg_locks`](#8-observarlo-todo-pg_stat_activity-y-pg_locks)
9. [🧩 Cuándo usar qué: girar y descontar el stock](#-cuándo-usar-qué-girar-y-descontar-el-stock)

---

## 1. El bug, en dos terminales

Antes de las soluciones, el problema. Ejecuta **alternando** las líneas:

```sql
-- T1                                    -- T2
BEGIN;
SELECT remaining FROM demo_stock
 WHERE segment_id = 'esclusa-de-oro';
-- 1
                                         BEGIN;
                                         SELECT remaining FROM demo_stock
                                          WHERE segment_id = 'esclusa-de-oro';
                                         -- 1  ← también
UPDATE demo_stock SET remaining = remaining - 1
 WHERE segment_id = 'esclusa-de-oro';
INSERT INTO demo_spins (idempotency_key, player_id, delivered_prize)
VALUES ('k-1', 42, 'esclusa-de-oro');
COMMIT;
                                         UPDATE demo_stock SET remaining = remaining - 1
                                          WHERE segment_id = 'esclusa-de-oro';
                                         INSERT INTO demo_spins (idempotency_key, player_id, delivered_prize)
                                         VALUES ('k-2', 43, 'esclusa-de-oro');
                                         COMMIT;
                                         SELECT remaining FROM demo_stock
                                          WHERE segment_id = 'esclusa-de-oro';
                                         -- -1
```

Las dos leyeron `1`, las dos decidieron que había, las dos escribieron. **Ninguna falló**: dos Esclusas entregadas de una, y el stock en `-1`. Ese es el giro de 2019 que `be03` tradujo a Go, y esa ventana entre leer y escribir es lo que se cierra en el resto del apéndice.

📖 El patrón tiene nombre: **check-then-act**. Verificar una condición y actuar sobre ella en dos operaciones separadas. La solución nunca es "verificar mejor": es hacer que la verificación y la acción sean **una sola cosa indivisible**.

---

## 2. Niveles de aislamiento y qué previene cada uno

| Nivel | Previene | Permite | ¿Resuelve lo nuestro? |
|---|---|---|---|
| `READ COMMITTED` (defecto) | Lecturas sucias | Lectura no repetible, *phantom*, *write skew* | ❌ |
| `REPEATABLE READ` | + lectura no repetible y *phantoms* | *Write skew* | ❌ |
| `SERIALIZABLE` | Todo | Nada | ✅ **con reintento** |

> ⚠️ Postgres **no tiene** `READ UNCOMMITTED`: lo acepta como sintaxis y se comporta como `READ COMMITTED`. Y su `REPEATABLE READ` es, en realidad, aislamiento por instantánea: previene los *phantoms* que el estándar SQL permitiría en ese nivel.

**Por qué `READ COMMITTED` permite el §1.** Cada **sentencia** ve una foto de lo confirmado en el momento en que esa sentencia empieza. Los dos `SELECT` ocurrieron antes de cualquier `COMMIT`, así que los dos vieron `1`. La transacción te da atomicidad —o pasan todas las escrituras o ninguna— pero **no exclusión mutua**.

**`SERIALIZABLE`, en dos terminales:**

```sql
-- T1                                    -- T2
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT remaining FROM demo_stock
 WHERE segment_id = 'esclusa-de-oro';   BEGIN ISOLATION LEVEL SERIALIZABLE;
                                         SELECT remaining FROM demo_stock
                                          WHERE segment_id = 'esclusa-de-oro';
                                         -- 1
UPDATE demo_stock SET remaining = remaining - 1
 WHERE segment_id = 'esclusa-de-oro';
COMMIT;                                  -- ok
                                         UPDATE demo_stock SET remaining = remaining - 1
                                          WHERE segment_id = 'esclusa-de-oro';
                                         -- ERROR:  40001: could not serialize access
                                         --         due to concurrent update
```

Postgres detectó que el resultado no habría podido ocurrir en ningún orden secuencial y abortó una. Correcto, y con un precio:

> 🧭 **Un `40001` no es un error de negocio: es "vuelve a intentarlo".** Y alguien tiene que reintentar. En este sistema ese alguien no puede ser el juego —no es tuyo— ni la consola heredada, así que el reintento tendría que vivir en el servidor, con su límite de intentos y su espera. Es perfectamente viable —es el ejercicio 29 de `be05`— y es más código del que parece.

---

## 3. `FOR UPDATE` y sus variantes

Bloqueo **pesimista**: se toma el bloqueo antes de decidir, y quien llegue después espera.

```sql
-- T1                                    -- T2
BEGIN;
SELECT remaining FROM demo_stock
 WHERE segment_id = 'esclusa-de-oro'
 FOR UPDATE;                             BEGIN;
-- 1, y la fila queda tomada              SELECT remaining FROM demo_stock
                                          WHERE segment_id = 'esclusa-de-oro'
                                          FOR UPDATE;
                                         -- ⏳ SE QUEDA ESPERANDO. No falla.
UPDATE demo_stock SET remaining = remaining - 1
 WHERE segment_id = 'esclusa-de-oro';
COMMIT;
                                         -- despierta y lee 0
```

T2 no leyó un dato viejo ni recibió un error: **esperó** —1,51 s en la corrida, lo que tardó T1 en confirmar—, y al despertar vio la verdad: no queda ninguna, y el giro entrega el sustituto. Esa es toda la idea.

### Las cuatro variantes

| Variante | Qué hace | Cuándo |
|---|---|---|
| `FOR UPDATE` | Bloqueo exclusivo. Los demás esperan, **incluido quien solo quiera verificar una clave foránea** | Vas a modificar **esa** fila, o su clave |
| `FOR NO KEY UPDATE` | Más débil: no choca con el `FOR KEY SHARE` que toma quien inserta una fila que la referencia | Modificas columnas que no son clave (§7) |
| `FOR SHARE` | Compartido: varios leen, nadie modifica | Necesitas que **no cambie**, no excluir a los demás |
| `FOR UPDATE SKIP LOCKED` | **Se salta** las filas bloqueadas | Cola de trabajo: "dame cualquiera libre" |
| `FOR UPDATE NOWAIT` | Falla al instante en vez de esperar | Prefieres un error rápido a una espera |

**`FOR SHARE` en el track**, y el porqué importa: cuando `be06` haga que el giro compruebe el cierre de la rueda dentro de la transacción, le basta con que nadie cambie la `closesAt` mientras gira. Un `FOR UPDATE` sobre la rueda serializaría **todos** los giros de esa rueda contra una sola fila, y tiraría a la basura la granularidad que `be05` consiguió.

**`SKIP LOCKED` y `NOWAIT`**, con T1 reteniendo la Esclusa:

```sql
-- T2
SELECT remaining FROM demo_stock
 WHERE segment_id = 'esclusa-de-oro' FOR UPDATE SKIP LOCKED;
-- (0 rows)
SELECT remaining FROM demo_stock
 WHERE segment_id = 'esclusa-de-oro' FOR UPDATE NOWAIT;
-- ERROR:  55P03: could not obtain lock on row in relation "demo_stock"
```

`SKIP LOCKED` es la joya escondida, y el error es usarla donde no va. Para *"dame cualquier premio de edición limitada que quede"*, sobre varias filas, es exactamente lo correcto: cada giro se lleva una distinta. Para *"descuenta la Esclusa de Oro"*, que es lo que hace el giro, devuelve **cero filas** cuando otro la tiene tomada, y el código concluiría que la Esclusa no tiene stock. Un desastre silencioso.

📖 `SKIP LOCKED` sirve cuando **cualquier** elemento vale (colas, lotes). Cuando pides uno **concreto**, es exactamente lo contrario de lo que necesitas.

---

## 4. Escribir con la condición: el `UPDATE` condicional y `ON CONFLICT`

La alternativa al bloqueo explícito: no leer antes. Se escribe de forma que solo pueda salir bien mientras la condición se cumpla, y se mira el resultado.

```sql
-- T1                                    -- T2
BEGIN;
UPDATE demo_stock SET remaining = remaining - 1
 WHERE segment_id = 'esclusa-de-oro' AND remaining > 0;
-- UPDATE 1
                                         UPDATE demo_stock SET remaining = remaining - 1
                                          WHERE segment_id = 'esclusa-de-oro' AND remaining > 0;
                                         -- ⏳ espera…
COMMIT;
                                         -- UPDATE 0   (esperó 1,50 s)
```

Lo que **no** pasó es lo que dice casi toda la literatura del "optimista": que el perdedor falle al instante. En Postgres, T2 **esperó** a que T1 confirmara —la fila estaba siendo escrita—, después volvió a evaluar la condición sobre el dato nuevo, y no encontró nada que actualizar. Lo que se ahorra es la lectura previa y la decisión en el código, no la espera.

Con la clave del giro pasa lo mismo:

```sql
-- T1                                    -- T2
BEGIN;
INSERT INTO demo_spins (idempotency_key, player_id, delivered_prize)
VALUES ('doble-toque', 42, 'vidas-5')
ON CONFLICT (idempotency_key) DO NOTHING;
-- INSERT 0 1
                                         INSERT INTO demo_spins (idempotency_key, player_id, delivered_prize)
                                         VALUES ('doble-toque', 42, 'vidas-5')
                                         ON CONFLICT (idempotency_key) DO NOTHING;
                                         -- ⏳ espera…
COMMIT;
                                         -- INSERT 0 0   (esperó 1,50 s)
```

T2 no puede saber si hay conflicto mientras la fila de T1 no esté confirmada, porque T1 todavía podría revertir. Espera, y después pierde sin error. En Go, el resultado se lee así:

```go
res, err := tx.ExecContext(ctx, query, …)
n, _ := res.RowsAffected()
if n == 0 {
    // perdiste: la clave ya estaba, o no quedaba stock
}
```

Las dos formas de `ON CONFLICT` y cuál elegir:

- **`DO NOTHING`** — el perdedor se entera por `RowsAffected() == 0`. Es con la que `be05` reclama la clave del giro.
- **`DO UPDATE SET …`** — *upsert*. Útil para la siembra idempotente de `be03`, donde correr el `INSERT` veinte veces tiene que dar el mismo resultado.

> ⚠️ **`ON CONFLICT` necesita un índice único que nombrar.** Sin la restricción del §5, la cláusula no tiene contra qué detectar el conflicto. Las dos cosas van juntas.

---

## 5. El índice único, última línea de defensa

`FOR UPDATE` y la escritura condicional protegen **el camino que escribiste**. Un índice único protege **todos los caminos**, incluidos los que no existen todavía. Sin el `ON CONFLICT`, el mismo `INSERT` de T2 del §4:

```
ERROR:  23505: duplicate key value violates unique constraint "demo_spins_idempotency_key_key"
DETAIL:  Key (idempotency_key)=(doble-toque) already exists.
```

No es una validación: es una **imposibilidad**. Da igual cuántas transacciones lo intenten, en qué orden, con qué nivel de aislamiento, desde qué servicio, o si alguien entra por `psql` a las tres de la mañana. La segunda fila no existe. Y así se traduce, que es donde el `409` deja de ser un `if` (`server/internal/storage/errors.go` de `be05`):

```go
var pqErr *pq.Error
if errors.As(err, &pqErr) && pqErr.Code == "23505" {
    return ErrCaseGranted
}
```

> 🧠 **El requisito de diseño que hay que ver antes.** Un `UNIQUE` solo protege `INSERT`. El stock y el saldo son **contadores**: una fila que ya existe y se actualiza, sin segunda fila que rechazar, así que esta defensa **no está disponible** para ellos. Para la clave del giro sí, porque `be05` modela el giro como un **hecho** (una fila nueva en `spin_log`) y no como un **estado**.
>
> 📖 Un estado es un campo que se pisa; un hecho es una fila que se agrega. Los estados pierden historia y no se pueden restringir. **Cuando algo tiene consecuencias —dinero, inventario, un premio de edición limitada—, modélalo como hecho.**

---

## 6. Pesimista contra condicional: cómo elegir

| | Pesimista (`FOR UPDATE`) | Condicional (`WHERE remaining > 0`, `ON CONFLICT`) |
|---|---|---|
| El perdedor | **Espera** su turno y decide con el dato nuevo | **También espera** la fila sin confirmar (§4), y pierde sin decidir |
| Lectura previa | Sí, bajo el bloqueo | No |
| p95 del giro con 200 jugadores a la vez (`be05` §5.7, tres corridas) | 333 a 509 ms | 266 a 375 ms |
| Visible en `pg_stat_activity` | ✅ Se ve esperar | ✅ También: el `UPDATE` que espera sale con `Lock` / `transactionid` |
| Riesgo de deadlock | Sí (§7) | También: dos `UPDATE` condicionales sobre dos filas, en orden distinto, dan el mismo `40P01` |

> 🧭 **El criterio, que vale más que cualquier número:** el pesimista gana cuando hay que **decidir** con el dato leído —qué premio entregar, de qué saldo descontar— y el trabajo perdido sería caro; la escritura condicional gana cuando la condición cabe en un `WHERE` y el perdedor no necesita saber nada más que *"no hubo"*.

Con 50 jugadores a la vez, los rangos de las dos en `be05` se pisan; con 200, la condicional quedó más baja. Y aun así `be05` usa el pesimista como camino principal, por una razón que no es de rendimiento: **el bloqueo se lee en el código**, antes de la decisión que protege. Cuando ya tengas la intuición construida, elige con tus propias mediciones.

---

## 7. Deadlocks

**El clásico: dos transacciones que bloquean las mismas filas en orden distinto.**

```sql
-- T1                                    -- T2
BEGIN;                                   BEGIN;
SELECT … 'esclusa-de-oro' FOR UPDATE;    SELECT … 'avatar-raro' FOR UPDATE;
SELECT … 'avatar-raro' FOR UPDATE;       SELECT … 'esclusa-de-oro' FOR UPDATE;
-- ⏳ espera a T2                         -- ⏳ espera a T1
```

```
ERROR:  40P01: deadlock detected
DETAIL:  Process 4233 waits for ShareLock on transaction 127598; blocked by process 4232.
         Process 4232 waits for ShareLock on transaction 127597; blocked by process 4233.
CONTEXT:  while locking tuple (0,2) in relation "demo_stock"
```

**Postgres lo detecta y mata a una de las dos.** Agradécelo: la alternativa sería un cuelgue indefinido. El detector actúa al cabo de `deadlock_timeout` (un segundo por defecto), así que cada deadlock cuesta ese segundo antes de resolverse. **Cómo se evita:** bloquear siempre en el mismo orden, típicamente ordenando por clave primaria.

**El que no se ve venir: la clave foránea.** Dos giros del mismo jugador. Cada uno inserta su pedido —que referencia al jugador— y después bloquea la fila del jugador para descontar el saldo:

```sql
-- T1                                    -- T2
BEGIN;
INSERT INTO demo_requests VALUES ('giro-a', 42);
                                         BEGIN;
                                         INSERT INTO demo_requests VALUES ('giro-b', 42);
SELECT free_spins FROM demo_players
 WHERE id = 42 FOR UPDATE;
                                         SELECT free_spins FROM demo_players
                                          WHERE id = 42 FOR UPDATE;
```

```
ERROR:  deadlock detected
DETAIL:  Process 4263 waits for ShareLock on transaction 127640; blocked by process 4264.
         Process 4264 waits for ShareLock on transaction 127639; blocked by process 4263.
CONTEXT:  while locking tuple (0,1) in relation "demo_players"
```

Ninguna sentencia toca dos filas, y aun así hay deadlock. El `INSERT` en `demo_requests` verifica la clave foránea, y para eso toma un `FOR KEY SHARE` sobre la fila 42 de `demo_players`: compartido, así que las dos lo obtienen. Después, cada una pide `FOR UPDATE` sobre la misma fila, que choca con el `KEY SHARE` de la otra. Es exactamente el deadlock que apareció al medir `be05` —48 de 50 giros con saldo de 1—, y tiene dos arreglos, los dos medidos:

- **Bloquear el padre antes de insertar en la hija.** Es lo que hace `be05`: el orden de los bloqueos lo decide el código, no la clave foránea.
- **`FOR NO KEY UPDATE`.** Con las mismas dos sesiones, cambiando solo eso, las dos terminan sin error: la segunda espera a la primera y sigue. No choca con `FOR KEY SHARE` porque promete no tocar la clave.

**Cómo se lee en el log.** Necesitas que estén registrados:

```sql
SHOW log_lock_waits;        -- ponlo en 'on' en desarrollo
SHOW deadlock_timeout;      -- 1s por defecto
```

Con `log_lock_waits = on`, Postgres registra también las esperas largas que **no** llegan a deadlock, que suelen ser la señal temprana del problema.

---

## 8. Observarlo todo: `pg_stat_activity` y `pg_locks`

Las tres consultas que conviene tener guardadas para siempre. Con T1 reteniendo la Esclusa (`FOR UPDATE`) y T2 esperándola, desde una tercera terminal:

**Qué está pasando ahora:**

```sql
SELECT pid, state, wait_event_type, wait_event, left(query, 60) AS consulta
FROM pg_stat_activity
WHERE datname = current_database() AND state <> 'idle' AND pid <> pg_backend_pid()
ORDER BY xact_start;
```

```
 pid  | state  | wait_event_type |  wait_event   |                           consulta
------+--------+-----------------+---------------+--------------------------------------------------------------
 4108 | active | Timeout         | PgSleep       | SELECT pg_sleep(2);
 4107 | active | Lock            | transactionid | SELECT remaining FROM demo_stock WHERE segment_id = 'esclusa
```

(En la corrida, T1 retenía la fila con un `pg_sleep(2)` en vez de una persona tardando en escribir `COMMIT`.) Ahí está `wait_event_type = 'Lock'` y `wait_event = 'transactionid'`. **Eso es una transacción esperando, en pantalla.**

**Quién bloquea a quién**, la que de verdad usarás a las tres de la mañana:

```sql
SELECT blocked.pid   AS bloqueado,
       blocking.pid  AS bloqueante,
       left(blocked.query, 40)  AS espera,
       left(blocking.query, 40) AS culpable
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking
  ON blocking.pid = ANY(pg_blocking_pids(blocked.pid));
```

```
 bloqueado | bloqueante |                  espera                  |      culpable
-----------+------------+------------------------------------------+---------------------
      4107 |       4108 | SELECT remaining FROM demo_stock WHERE s | SELECT pg_sleep(2);
```

**Qué bloqueos hay, con su modo:**

```sql
SELECT l.pid, l.mode, l.granted, c.relname
FROM pg_locks l LEFT JOIN pg_class c ON c.oid = l.relation
WHERE NOT l.granted OR c.relname = 'demo_stock';
```

Y el vecino peligroso que hay que saber reconocer:

> ⚠️ **`idle in transaction`.** Una sesión que hizo `BEGIN`, escribió, y se fue a tomar café conserva **todos** sus bloqueos e impide que el recolector limpie. El síntoma es "la aplicación se arrastra sin motivo". Búscalo:
>
> ```sql
> SELECT state, now() - state_change AS inactiva, left(query, 50) AS ultima_consulta
> FROM pg_stat_activity WHERE state = 'idle in transaction'
> ORDER BY state_change;
> -- y si hace falta:  SELECT pg_terminate_backend(<pid>);
> ```
>
> Con una sesión que hizo un `UPDATE` sobre la Esclusa y se quedó quieta dos segundos, la consulta la encontró con `state = idle in transaction`. La última consulta que muestra es la que la sesión corrió **antes** de quedarse quieta, no la que retiene el bloqueo: no te fíes de esa columna para saber qué filas tiene tomadas, para eso está `pg_locks`.

📖 **Y la regla que evita la mitad de estos casos:** una transacción **nunca** debe contener una petición de red. Mientras esperas dos segundos a un servicio externo, estás bloqueando filas. `be05` entrega el premio en el juego **fuera** de la transacción del giro por exactamente esto.

---

## 🧩 Cuándo usar qué: girar y descontar el stock

El caso concreto, con la decisión y su porqué:

| Herramienta | ¿Para que no salga una Esclusa de más? |
|---|---|
| Transacción a secas | **No basta.** Da atomicidad, no exclusión (§2). Es el incidente `be-09` |
| `READ COMMITTED` + `FOR UPDATE` sobre el stock | ✅ **Lo de `be05`.** Explícito, decide con el dato bajo el bloqueo, sin reintentos |
| `UPDATE … WHERE remaining > 0` | ✅ Igual de correcto, y la variante que `be05` mide al lado |
| `UNIQUE (idempotency_key)` | ✅ **Obligatorio**, para la otra carrera: la clave repetida. Es lo único que protege los caminos futuros |
| `SERIALIZABLE` | Correcto, **pero exige reintento**, y ni el juego ni la consola reintentan por un `40001` |
| `SKIP LOCKED` | ❌ Devolvería cero filas y concluirías que no queda stock |
| Un `if` en el código | ❌ Es el bug del §1, en el lenguaje que sea |

> 🧭 **La receta del track, en tres piezas y las tres hacen falta.**
> 1. Una **transacción** que envuelva leer, decidir y escribir.
> 2. Un **`FOR UPDATE`** sobre la fila caliente —el stock, el saldo—, **antes** de decidir, y siempre en el mismo orden.
> 3. Un **`UNIQUE`** detrás, sobre el hecho, por los caminos que todavía no existen.
>
> La 1 y la 2 protegen este código. La 3 protege el que escribirá otra persona dentro de dos años sin leer nada de esto.

Y el corolario que ordena todo el track: **ninguna de las tres se puede poner en el frontend**. La guarda de origen y el rollback de la Fase 5 mejoran la experiencia mientras el servidor decide, y eso es valioso, pero no protegen nada, porque no pueden.

---

## 🧪 Ejercicios (9)

1. **🟢** Reproduce el §1 en dos terminales y confirma en la tabla que el stock quedó en `-1` con dos Esclusas entregadas.
2. **🟢** Repite con `FOR UPDATE` y observa a T2 esperar. Mide cuánto espera si T1 tarda cinco segundos en confirmar.
3. **🟡** Ejecuta el §2 con `SERIALIZABLE` y captura el `40001`. Escribe qué tendría que hacer el servidor al recibirlo.
4. **🟡 Diagnóstico.** Con un bloqueo activo, corre las tres consultas del §8 y explica qué columna te dice qué.
5. **🟠** Mide el §4 con un `pg_sleep` de 1, 3 y 5 segundos en T1 y confirma que la espera de T2 la decide T1, no T2. Explica qué significa eso para la palabra "optimista".
6. **🟠 Diagnóstico.** Provoca el deadlock por la clave foránea del §7, captura el mensaje completo, y arréglalo de las dos maneras. Explica por qué funciona cada una.
7. **🟠 Diagnóstico.** Deja una sesión en `idle in transaction` sobre el stock real de la rueda de medición, observa el efecto sobre los giros de la aplicación, encuéntrala con el §8 y termínala.
8. **🔴** Usa `SKIP LOCKED` para implementar *"dame cualquier premio de edición limitada que quede"* con cinco giros concurrentes sobre cinco filas, y demuestra que cada uno se lleva uno distinto. Después úsalo mal —para la Esclusa concreta— y documenta el desastre silencioso.
9. **🔴 Diagnóstico.** Quita el `UNIQUE (idempotency_key)` dejando el resto de `be05` y demuestra que el sistema sigue siendo correcto por el camino del giro. Después escribe el script que, entrando por otro camino, deja dos filas con la misma clave. Ese script es el argumento entero del §5.

---

## 📚 Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/13/transaction-iso.html — el §2, con los ejemplos de cada anomalía. La referencia central del apéndice.
- https://www.postgresql.org/docs/13/explicit-locking.html — el §3 completo, con la **tabla de conflictos entre modos de bloqueo de fila**: el deadlock por clave foránea del §7 está escrito en ella.
- https://www.postgresql.org/docs/13/sql-select.html#SQL-FOR-UPDATE-SHARE — `SKIP LOCKED` y `NOWAIT`.
- https://www.postgresql.org/docs/13/sql-insert.html#SQL-ON-CONFLICT — el §4.
- https://www.postgresql.org/docs/13/monitoring-stats.html#MONITORING-PG-STAT-ACTIVITY-VIEW y https://www.postgresql.org/docs/13/view-pg-locks.html — el §8.
- https://www.postgresql.org/docs/13/errcodes-appendix.html — los SQLSTATE: `23505` (unicidad), `40001` (serialización), `40P01` (deadlock), `55P03` (bloqueo no disponible).
- https://www.postgresql.org/docs/13/mvcc.html — el modelo que explica por qué los lectores no bloquean a los escritores.

**Libros**
- *Designing Data-Intensive Applications* (Martin Kleppmann) — el capítulo 7 es, sin competencia, el mejor texto sobre esto. Su tratamiento del *write skew* explica por qué `REPEATABLE READ` no basta.
- *PostgreSQL 14 Internals* (Egor Rogov) — para quien quiera ver MVCC y los modos de bloqueo de fila por dentro. Disponible libremente en PDF; verifica la versión.

**Video / apoyo**
- Busca "PostgreSQL SELECT FOR UPDATE explained" y "SKIP LOCKED queue pattern". **Verifica que los ejemplos sean de Postgres**: la semántica de bloqueo de MySQL es distinta y mezclarlas confunde más que ayuda.

**Orden de lectura sugerido:** haz el §1 en dos terminales antes de leer nada —el bug con las manos vale más que cualquier explicación— → `transaction-iso.html` §13.2 → `explicit-locking.html` §13.3.2, con la tabla de conflictos a la vista → y el capítulo 7 de Kleppmann cuando quieras la teoría completa.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. La documentación de Postgres tiene **una versión por URL**: si aterrizas en la última, cambia el número a 13 antes de creerle. Las referencias a libros son de memoria y pueden ser inexactas. Los números de proceso y de transacción de las salidas son de la corrida del autor: los tuyos van a ser otros. La fuente de verdad de versiones es `00-decisiones-y-versiones.md` §7.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura, y sus tablas viven en una base aparte que puedes borrar al terminar (`dropdb bea05`). La evidencia que generes va en `server/evidence/concurrencia.md`, que es entregable de `be05`.
