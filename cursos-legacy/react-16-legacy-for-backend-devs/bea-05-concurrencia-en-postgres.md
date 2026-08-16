# 🔒 Apéndice bea-05 — Concurrencia en PostgreSQL

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~3 horas
> Lo referencian: `be05` principalmente; `be07` y `be08` lo consultan

---

Este apéndice es **ejecutable**. Cada mecanismo viene con su sesión doble
reproducible en dos terminales de `psql`, porque la concurrencia es de esas cosas
que no se entienden leyendo: se entienden viendo una transacción esperar.

Damos por sabido qué es una transacción y qué es un nivel de aislamiento. Lo que
probablemente no hayas tenido que hacer nunca es **elegir uno con un número de
rifa de por medio**, sabiendo que si te equivocas alguien paga dos veces por lo
mismo. Eso es lo que se practica acá.

**Preparación**, una sola vez:

```sql
CREATE TABLE IF NOT EXISTS demo_numbers (
    id       BIGSERIAL PRIMARY KEY,
    raffle_id BIGINT NOT NULL,
    number   TEXT   NOT NULL,
    status   TEXT   NOT NULL DEFAULT 'available',
    UNIQUE (raffle_id, number)
);
INSERT INTO demo_numbers (raffle_id, number) VALUES (1, '0347')
ON CONFLICT DO NOTHING;
```

Abre **dos terminales** contra la misma base. En lo que sigue, **T1** y **T2**.

---

## 🧭 Índice de salto rápido

1. [El bug, en dos terminales](#1-el-bug-en-dos-terminales)
2. [Niveles de aislamiento y qué previene cada uno](#2-niveles-de-aislamiento-y-qué-previene-cada-uno)
3. [`FOR UPDATE` y sus variantes](#3-for-update-y-sus-variantes)
4. [`INSERT … ON CONFLICT`](#4-insert--on-conflict)
5. [El índice único, última línea de defensa](#5-el-índice-único-última-línea-de-defensa)
6. [Pesimista contra optimista: cómo elegir](#6-pesimista-contra-optimista-cómo-elegir)
7. [Deadlocks](#7-deadlocks)
8. [Observarlo todo: `pg_stat_activity` y `pg_locks`](#8-observarlo-todo-pg_stat_activity-y-pg_locks)
9. [🧩 Cuándo usar qué: vender un número](#-cuándo-usar-qué-vender-un-número)

---

## 1. El bug, en dos terminales

Antes de las soluciones, el problema. Ejecuta **alternando** las líneas:

```sql
-- T1                                    -- T2
BEGIN;
SELECT status FROM demo_numbers
 WHERE raffle_id=1 AND number='0347';
-- 'available'
                                         BEGIN;
                                         SELECT status FROM demo_numbers
                                          WHERE raffle_id=1 AND number='0347';
                                         -- 'available'  ← también
UPDATE demo_numbers SET status='sold'
 WHERE raffle_id=1 AND number='0347';
COMMIT;
                                         UPDATE demo_numbers SET status='sold'
                                          WHERE raffle_id=1 AND number='0347';
                                         COMMIT;
```

Las dos leyeron `available`, las dos decidieron que se podía, las dos escribieron.
**Ninguna falló.** Ese es el `SellNumber` de `be03`, y esa ventana entre leer y
escribir es lo que se cierra en el resto del apéndice.

📖 El patrón tiene nombre: **check-then-act**. Verificar una condición y actuar
sobre ella en dos operaciones separadas. La solución nunca es "verificar mejor":
es hacer que la verificación y la acción sean **una sola cosa indivisible**.

---

## 2. Niveles de aislamiento y qué previene cada uno

| Nivel | Previene | Permite | ¿Resuelve lo nuestro? |
|---|---|---|---|
| `READ COMMITTED` (defecto) | Lecturas sucias | Lectura no repetible, *phantom*, *write skew* | ❌ |
| `REPEATABLE READ` | + lectura no repetible y *phantoms* | *Write skew* | ❌ |
| `SERIALIZABLE` | Todo | Nada | ✅ **con reintento** |

> ⚠️ Postgres **no tiene** `READ UNCOMMITTED`: lo acepta como sintaxis y se
> comporta como `READ COMMITTED`. Y su `REPEATABLE READ` es, en realidad, aislamiento
> por instantánea: previene los *phantoms* que el estándar SQL permitiría en ese
> nivel.

**Por qué `READ COMMITTED` permite el §1.** Cada **sentencia** ve una foto de lo
confirmado en el momento en que esa sentencia empieza. Los dos `SELECT` ocurrieron
antes de cualquier `COMMIT`, así que los dos vieron `available`. La transacción te
da atomicidad —o pasan todas las escrituras o ninguna— pero **no exclusión mutua**.

**`SERIALIZABLE`, en dos terminales:**

```sql
-- T1                                    -- T2
BEGIN ISOLATION LEVEL SERIALIZABLE;      BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT status FROM demo_numbers          SELECT status FROM demo_numbers
 WHERE raffle_id=1 AND number='0347';     WHERE raffle_id=1 AND number='0347';
UPDATE demo_numbers SET status='sold'
 WHERE raffle_id=1 AND number='0347';
COMMIT;                                  -- ok
                                         UPDATE demo_numbers SET status='sold'
                                          WHERE raffle_id=1 AND number='0347';
                                         -- ERROR: could not serialize access
                                         --        due to concurrent update
                                         -- SQLSTATE 40001
```

Postgres detectó que el resultado no habría podido ocurrir en ningún orden
secuencial y abortó una. Correcto — y con un precio:

> 🧭 **Un `40001` no es un error de negocio: es "vuelve a intentarlo".** Y
> alguien tiene que reintentar. En este sistema ese alguien no puede ser el
> frontend heredado, así que el reintento tendría que vivir en el servidor, con
> su límite de intentos y su espera. Es perfectamente viable —es el ejercicio 29
> de `be05`— y es más código del que parece.

---

## 3. `FOR UPDATE` y sus variantes

Bloqueo **pesimista**: se toma el bloqueo antes de decidir, y quien llegue después
espera.

```sql
-- T1                                    -- T2
BEGIN;
SELECT * FROM demo_numbers
 WHERE raffle_id=1 AND number='0347'
 FOR UPDATE;                             BEGIN;
-- bloqueada, T1 sigue trabajando        SELECT * FROM demo_numbers
                                          WHERE raffle_id=1 AND number='0347'
                                          FOR UPDATE;
                                         -- ⏳ SE QUEDA ESPERANDO. No falla.
UPDATE demo_numbers SET status='sold' …;
COMMIT;
                                         -- despierta y lee status='sold'
```

T2 no leyó un dato viejo ni recibió un error: **esperó**, y al despertar vio la
verdad. Esa es toda la idea.

### Las cuatro variantes

| Variante | Qué hace | Cuándo |
|---|---|---|
| `FOR UPDATE` | Bloqueo exclusivo. Los demás esperan | Vas a modificar **esa** fila |
| `FOR NO KEY UPDATE` | Más débil: no bloquea a quien la referencie por clave foránea | Modificas columnas que no son clave |
| `FOR SHARE` | Compartido: varios leen, nadie modifica | Necesitas que **no cambie**, no excluir a los demás |
| `FOR UPDATE SKIP LOCKED` | **Se salta** las filas bloqueadas | Cola de trabajo: "dame cualquiera libre" |
| `FOR UPDATE NOWAIT` | Falla al instante (`55P03`) en vez de esperar | Prefieres un error rápido a una espera |

**`FOR SHARE` en el track**, y el porqué importa: `be06` bloquea la **rifa** con
`FOR SHARE` mientras vende, no con `FOR UPDATE`. Solo necesita que nadie cambie la
`closesAt` durante la venta; un `FOR UPDATE` sobre la rifa serializaría **todas**
las ventas de esa rifa contra una sola fila y tiraría a la basura la granularidad
que `be05` consiguió.

**`SKIP LOCKED`** es la joya escondida, y el error es usarla donde no va:

```sql
-- ✅ "véndeme cualquier número disponible": cada worker toma uno distinto
SELECT * FROM demo_numbers
 WHERE raffle_id=1 AND status='available'
 ORDER BY number LIMIT 1
 FOR UPDATE SKIP LOCKED;

-- ❌ "véndeme el 0347": saltarse la fila bloqueada devuelve CERO filas, y el
--    código concluiría que el número no existe. Desastre silencioso.
```

📖 `SKIP LOCKED` sirve cuando **cualquier** elemento vale (colas, lotes). Cuando
pides uno **concreto**, es exactamente lo contrario de lo que necesitas.

---

## 4. `INSERT … ON CONFLICT`

Bloqueo **optimista**: no se bloquea nada; se intenta la operación de forma que
solo pueda salir bien una vez, y se mira el resultado.

```sql
-- Los dos a la vez. Uno afecta 1 fila, el otro 0. Nadie espera a nadie.
INSERT INTO sales (raffle_id, number, sold_by) VALUES (1, '0347', 2)
ON CONFLICT (raffle_id, number) DO NOTHING;
```

En Go, el resultado se lee así:

```go
res, err := tx.ExecContext(ctx, query, …)
n, _ := res.RowsAffected()
if n == 0 {
    return ErrAlreadySold   // perdiste la carrera, sin haber esperado
}
```

Las dos formas y cuál elegir:

- **`DO NOTHING`** — el perdedor se entera por `RowsAffected() == 0`. Es el del
  track.
- **`DO UPDATE SET …`** — *upsert*. Útil para la siembra idempotente de `be03`,
  donde correr el `INSERT` veinte veces tiene que dar el mismo resultado.

> ⚠️ **`ON CONFLICT` necesita un índice único que nombrar.** Sin la restricción
> del §5, la cláusula no tiene contra qué detectar el conflicto. Las dos cosas van
> juntas.

---

## 5. El índice único, última línea de defensa

`FOR UPDATE` y `ON CONFLICT` protegen **el camino que escribiste**. Un índice
único protege **todos los caminos**, incluidos los que no existen todavía:

```sql
CONSTRAINT sales_unique_number_per_raffle UNIQUE (raffle_id, number)
```

No es una validación: es una **imposibilidad**. Da igual cuántas transacciones lo
intenten, en qué orden, con qué nivel de aislamiento, desde qué servicio, o si
alguien entra por `psql` a las tres de la mañana. La segunda fila no existe.

```
ERROR:  duplicate key value violates unique constraint "sales_unique_number_per_raffle"
SQLSTATE: 23505
```

Y así se traduce, que es donde el `409` deja de ser un `if`:

```go
var pqErr *pq.Error
if errors.As(err, &pqErr) && pqErr.Code == "23505" {
    return ErrAlreadySold
}
```

> 🧠 **El requisito de diseño que hay que ver antes.** Un `UNIQUE` solo protege
> `INSERT`. Si vender fuera un `UPDATE` sobre una fila que ya existe —como en
> `be03`— no habría segunda fila que rechazar y esta defensa **no estaría
> disponible**. Por eso `be05` cambia el modelo: la venta pasa a ser un **hecho**
> (`sales`) y no un **estado** (`raffle_numbers.status`).
>
> 📖 Un estado es un campo que se pisa; un hecho es una fila que se agrega. Los
> estados pierden historia y no se pueden restringir. **Cuando algo tiene
> consecuencias —dinero, inventario, una plaza—, modélalo como hecho.**

---

## 6. Pesimista contra optimista: cómo elegir

| | Pesimista (`FOR UPDATE`) | Optimista (`ON CONFLICT`) |
|---|---|---|
| El perdedor | **Espera** su turno | Falla al instante |
| Latencia p95 con contención | Crece con los contendientes | Casi plana |
| Trabajo desperdiciado | Ninguno | El del perdedor |
| Visible en `pg_stat_activity` | ✅ Se ve esperar | ❌ No hay espera que ver |
| Riesgo de deadlock | Sí (§7) | Prácticamente no |

> 🧭 **El criterio, que vale más que cualquier número:** el pesimista gana cuando
> la colisión es **probable** y el trabajo perdido sería **caro**; el optimista
> gana cuando la colisión es **rara** y el trabajo perdido es **barato**.

Para una rifa —donde solo colisionan los números "bonitos", y de vez en cuando—
el optimista es la respuesta correcta. Y aun así `be05` usa el pesimista como
camino principal, por una razón que no es de rendimiento: **se puede observar**
(§8). Cuando ya tengas la intuición construida, elige con tus propias mediciones.

---

## 7. Deadlocks

Dos transacciones que bloquean las mismas filas **en orden distinto**:

```sql
-- T1                                    -- T2
BEGIN;                                   BEGIN;
SELECT … number='0347' FOR UPDATE;       SELECT … number='1500' FOR UPDATE;
SELECT … number='1500' FOR UPDATE;       SELECT … number='0347' FOR UPDATE;
-- ⏳ espera a T2                         -- ⏳ espera a T1 → ERROR
```

```
ERROR:  deadlock detected
DETAIL: Process 8123 waits for ShareLock on transaction 5567; blocked by process 8145.
        Process 8145 waits for ShareLock on transaction 5566; blocked by process 8123.
SQLSTATE: 40P01
```

**Postgres lo detecta y mata a una de las dos.** Agradécelo: la alternativa sería
un cuelgue indefinido. El detector corre cada segundo (`deadlock_timeout`), así
que un deadlock cuesta ese segundo antes de resolverse.

**Cómo se evita:** **bloquear siempre en el mismo orden**, típicamente ordenando
por clave primaria. Si una operación toca varios números, ordénalos antes de
bloquearlos:

```go
sort.Strings(numbers)   // el orden lo decide un criterio, no la casualidad
for _, n := range numbers { … FOR UPDATE … }
```

**Cómo se lee en el log.** Necesitas que estén registrados:

```sql
SHOW log_lock_waits;        -- ponlo en 'on' en desarrollo
SHOW deadlock_timeout;      -- 1s por defecto
```

Con `log_lock_waits = on`, Postgres registra también las esperas largas que
**no** llegan a deadlock — que suelen ser la señal temprana del problema.

---

## 8. Observarlo todo: `pg_stat_activity` y `pg_locks`

Las tres consultas que conviene tener guardadas para siempre.

**Qué está pasando ahora:**

```sql
SELECT pid, state, wait_event_type, wait_event,
       now() - xact_start AS duracion,
       left(query, 60) AS consulta
FROM pg_stat_activity
WHERE datname = current_database() AND state <> 'idle'
ORDER BY xact_start;
```

Con un bloqueo activo verás `wait_event_type = 'Lock'` y
`wait_event = 'transactionid'`. **Eso es una transacción esperando, en pantalla.**

**Quién bloquea a quién** — la que de verdad usarás a las tres de la mañana:

```sql
SELECT blocked.pid   AS bloqueado,
       blocking.pid  AS bloqueante,
       left(blocked.query, 40)  AS espera,
       left(blocking.query, 40) AS culpable
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking
  ON blocking.pid = ANY(pg_blocking_pids(blocked.pid));
```

**Qué bloqueos hay, con su modo:**

```sql
SELECT l.pid, l.mode, l.granted, c.relname
FROM pg_locks l LEFT JOIN pg_class c ON c.oid = l.relation
WHERE NOT l.granted OR c.relname = 'demo_numbers';
```

Y el vecino peligroso que hay que saber reconocer:

> ⚠️ **`idle in transaction`.** Una sesión que hizo `BEGIN` y se fue a tomar café
> conserva **todos** sus bloqueos e impide que el recolector limpie. El síntoma es
> "la aplicación se arrastra sin motivo". Búscalo:
>
> ```sql
> SELECT pid, now() - state_change AS inactiva, left(query,50)
> FROM pg_stat_activity WHERE state = 'idle in transaction'
> ORDER BY state_change;
> -- y si hace falta:  SELECT pg_terminate_backend(<pid>);
> ```

📖 **Y la regla que evita la mitad de estos casos:** una transacción **nunca**
debe contener una petición de red. Mientras esperas dos segundos a un servicio
externo, estás bloqueando filas.

---

## 🧩 Cuándo usar qué: vender un número

El caso concreto, con la decisión y su porqué:

| Herramienta | ¿Para vender el `0347`? |
|---|---|
| Transacción a secas | **No basta.** Da atomicidad, no exclusión (§2) |
| `READ COMMITTED` + `FOR UPDATE` | ✅ **Lo del track.** Explícito, observable, sin reintentos |
| `INSERT … ON CONFLICT DO NOTHING` | ✅ Igual de correcto y más rápido con contención baja |
| `UNIQUE (raffle_id, number)` | ✅ **Obligatorio**, además de lo anterior. Es lo único que protege los caminos futuros |
| `SERIALIZABLE` | Correcto, **pero exige reintento**, y el cliente heredado no reintenta |
| `SKIP LOCKED` | ❌ Devolvería cero filas y concluirías que el número no existe |
| Un `if` en el código | ❌ Es el bug del §1, en el lenguaje que sea |

> 🧭 **La receta del track, en tres piezas y las tres hacen falta.**
> 1. Una **transacción** que envuelva leer, decidir y escribir.
> 2. Un **`FOR UPDATE`** sobre la fila del número, **antes** de decidir.
> 3. Un **`UNIQUE`** detrás, por los caminos que todavía no existen.
>
> La 1 y la 2 protegen este código. La 3 protege el que escribirá otra persona
> dentro de dos años sin leer nada de esto.

Y el corolario que ordena todo el track: **ninguna de las tres se puede poner en
el frontend**. La corrección optimista con rollback de la Fase 5 mejora la
experiencia mientras el servidor decide, y eso es valioso — pero no protege nada,
porque no puede.

---

## 🧪 Ejercicios (9)

1. **🟢** Reproduce el §1 en dos terminales y confirma en la tabla que el número quedó vendido dos veces.
2. **🟢** Repite con `FOR UPDATE` y observa a T2 esperar. Mide cuánto espera si T1 tarda cinco segundos en confirmar.
3. **🟡** Ejecuta el §2 con `SERIALIZABLE` y captura el `40001`. Escribe qué tendría que hacer el cliente al recibirlo.
4. **🟡 Diagnóstico.** Con un bloqueo activo, corre las tres consultas del §8 y explica qué columna te dice qué.
5. **🟠** Compara `FOR UPDATE` y `ON CONFLICT` con 2, 10 y 50 contendientes. Mide ganadores, conflictos y latencia p50 y p95. Es el ejercicio 13 de `be05`.
6. **🟠 Diagnóstico.** Provoca un deadlock con el §7, captura el mensaje completo, y arréglalo ordenando los bloqueos. Explica por qué ordenar funciona.
7. **🟠 Diagnóstico.** Deja una sesión en `idle in transaction`, observa el efecto sobre las ventas de la aplicación, encuéntrala con el §8 y termínala.
8. **🔴** Usa `SKIP LOCKED` para implementar "véndeme cualquier número disponible" con cinco vendedores concurrentes, y demuestra que cada uno se lleva uno distinto. Después úsalo mal —para un número concreto— y documenta el desastre silencioso.
9. **🔴 Diagnóstico.** Quita el `UNIQUE` dejando el `FOR UPDATE` y demuestra que el sistema sigue siendo correcto por este camino. Después escribe el script que, entrando por otro camino, produce la venta duplicada. Ese script es el argumento entero del §5.

---

## 📚 Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/13/transaction-iso.html — el §2, con los ejemplos de cada anomalía. La referencia central del apéndice.
- https://www.postgresql.org/docs/13/explicit-locking.html — el §3 completo, con la tabla de conflictos entre modos de bloqueo.
- https://www.postgresql.org/docs/13/sql-select.html#SQL-FOR-UPDATE-SHARE — `SKIP LOCKED` y `NOWAIT`.
- https://www.postgresql.org/docs/13/sql-insert.html#SQL-ON-CONFLICT — el §4.
- https://www.postgresql.org/docs/13/monitoring-stats.html#MONITORING-PG-STAT-ACTIVITY-VIEW y https://www.postgresql.org/docs/13/view-pg-locks.html — el §8.
- https://www.postgresql.org/docs/13/errcodes-appendix.html — los SQLSTATE: `23505` (unicidad), `40001` (serialización), `40P01` (deadlock), `55P03` (bloqueo no disponible).
- https://www.postgresql.org/docs/13/mvcc.html — el modelo que explica por qué los lectores no bloquean a los escritores.

**Libros**
- *Designing Data-Intensive Applications* (Martin Kleppmann) — el capítulo 7 es, sin competencia, el mejor texto sobre esto. Su tratamiento del *write skew* explica por qué `REPEATABLE READ` no basta.
- *PostgreSQL 14 Internals* (Egor Rogov) — para quien quiera ver MVCC por dentro. Disponible libremente en PDF; verifica la versión.

**Video / apoyo**
- Busca "PostgreSQL SELECT FOR UPDATE explained" y "SKIP LOCKED queue pattern". **Verifica que los ejemplos sean de Postgres**: la semántica de bloqueo de MySQL es distinta y mezclarlas confunde más que ayuda.

**Orden de lectura sugerido:** haz el §1 en dos terminales antes de leer nada —el
bug con las manos vale más que cualquier explicación— → `transaction-iso.html`
§13.2 → `explicit-locking.html` §13.3.2 → y el capítulo 7 de Kleppmann cuando
quieras la teoría completa.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. La
> documentación de Postgres tiene **una versión por URL**: si aterrizas en la
> última, cambia el número a 13 antes de creerle. Las referencias a libros son de
> memoria y pueden ser inexactas. La fuente de verdad de versiones es
> `prompts/decisiones-y-versiones.md` §7.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura. La tabla `demo_numbers`
> es de laboratorio y puedes borrarla al terminar (`DROP TABLE demo_numbers;`). La
> evidencia que generes va en `server/evidence/concurrencia.md`, que es entregable
> de `be05`.
