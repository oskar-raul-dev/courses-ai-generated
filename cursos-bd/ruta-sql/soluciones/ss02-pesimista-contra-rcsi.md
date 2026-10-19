# ✅ Soluciones — SQL Server 02: Pesimista contra RCSI

> **Curso:** Ruta SQL · Solucionario de [ss02](../ss02-pesimista-contra-rcsi.md)
> **Ejercicios:** 22 · **Perfil:** M (la base `ss02` copiada de `ALAMEDA`) · **Motores:** SQL Server 2025 CU9
> `mcr.microsoft.com/mssql/server@sha256:2b5b58162112…` (emulado), y Postgres `pgvector/pgvector@sha256:2358fcba361e…` para el contraste
> **Fecha de verificación ejecutada:** 18/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

> 🔒 **Lo que este solucionario no trae.** Quién esperó, quién fue víctima, qué saldo quedó y cuánto ocupó el *version store* en
> SQL Server: son resultados del motor, y no se publican ([`a09`](../a09-licencias-publicacion-y-riesgo.md#-sql-server-la-cláusula-tal-cual)).
> Trae la predicción con su fuente en la documentación, los mensajes de error, las consultas, y todo lo de Postgres.

Las carreras se corren desde `src/`, con `uv run --extra sqlserver lab race -f ss02-pesimista-contra-rcsi/…`, después de
`01_setup.sql`.

---

## 🟢 Fácil (1–7)

### Ejercicio 1

```text
🏁 lab race · postgres · permutación a1 a2 b1 c1 a3
 a1  BEGIN
 a2  UPDATE 1
 b1  1 fila  (41)
 c1  1 fila  (0)
 a3  COMMIT
comprobación: 1 fila  (40, 1)
```

c cuenta las sesiones con `wait_event_type = 'Lock'`, y da cero: el reporte (b) no pidió ningún bloqueo para leer. En Postgres, una
lectura nunca toma un bloqueo que un escritor de filas tenga que respetar, ni al revés: b leyó la versión confirmada (`41`) y a escribió
una nueva, que es la que queda al confirmar (`40`).

### Ejercicio 2

**Predicción, con la guía de Microsoft:** con `READ_COMMITTED_SNAPSHOT` apagado, `READ COMMITTED` *"uses shared locks"*. b pide un
bloqueo `S` sobre la fila que a tiene con `X`, y espera. c1 tiene que mostrar una fila: la sesión de b como `session_id`, la de a como
`blocking_session_id`, y un `wait_type` `LCK_M_S` (espera de un bloqueo compartido). Las tres columnas que identifican la espera son esas.
Resuélvela con la carrera y compara; no publiques la salida.

### Ejercicio 3

```sql
-- sqlserver, desde una tercera sesión, con a sin confirmar
SELECT s.session_id, s.status, ib.event_info
FROM sys.dm_exec_sessions AS s
CROSS APPLY sys.dm_exec_input_buffer(s.session_id, NULL) AS ib
WHERE s.session_id = (SELECT TOP (1) blocking_session_id FROM sys.dm_exec_requests WHERE blocking_session_id <> 0);
```

`sys.dm_exec_requests` solo tiene a quien está **ejecutando** algo, y a no ejecuta nada: está `sleeping` con la transacción abierta,
como la sesión `idle in transaction` de la Fase 18. Por eso el texto sale de `sys.dm_exec_input_buffer`, que da el último lote que la
sesión mandó (`BEGIN TRAN; UPDATE dbo.hemogram SET hematocrit = N'40' …`), y no de `sys.dm_exec_sql_text` sobre la petición, que no
existe. Es el equivalente de mirar la columna `query` de `pg_stat_activity` en una sesión ociosa.

### Ejercicio 4

```sql
SELECT name, is_read_committed_snapshot_on, snapshot_isolation_state_desc FROM sys.databases WHERE name IN ('ss02', 'ALAMEDA');
```

`ALAMEDA` tiene las dos apagadas (`0` y `OFF`): es como la dejó el script de SSMS, y como viene cualquier base nueva de SQL Server. `ss02`
tiene lo que le dejó la última carrera o `02_snapshot.sql`. La que cambia lo que significa `READ COMMITTED` es `READ_COMMITTED_SNAPSHOT`:
el mismo nivel, leído con versiones. `ALLOW_SNAPSHOT_ISOLATION` no cambia nada de lo que ya corre; habilita un nivel más que hay que pedir.

### Ejercicio 5

El reporte pide lo mismo que antes (`READ COMMITTED`, implícito) y la base cambió cómo se implementa. La guía: *"When the
`READ_COMMITTED_SNAPSHOT` database option is set `ON`… the `READ COMMITTED` isolation level uses row versioning to provide statement-level
read consistency."* La predicción es que b lee `41` sin esperar y c1 no encuentra a nadie. Es el único cambio de este motor que arregla un
problema de concurrencia sin tocar la aplicación, y por eso también puede cambiar resultados sin avisar (ejercicio 18).

### Ejercicio 6

```text
✗ 1205 Transaction (Process ID …) was deadlocked on lock resources with another process and has been chosen as the deadlock victim.
Rerun the transaction.
✗ 3960 Snapshot isolation transaction aborted due to update conflict. You cannot use snapshot isolation to access table 'dbo.debtor'
directly or indirectly in database 'ss02' to update, delete, or insert the row that has been modified or deleted by another
transaction. Retry the transaction or change the isolation level for the update/delete statement.
```

En los dos casos la transacción ya no está: el 1205 la deshace (*"rolls back the transaction of the deadlock victim"*, guía de
*deadlocks*), y el 3960 la termina (*"the `SNAPSHOT` transaction is terminated"*, guía de versiones). `SELECT @@TRANCOUNT` da 0 en la
sesión que recibió el error. Las carreras cierran con `IF @@TRANCOUNT > 0` por eso.

### Ejercicio 7

```sql
-- sqlserver
CREATE DATABASE ss02_sin_snapshot;
GO
USE ss02_sin_snapshot; CREATE TABLE t (id int);
SET TRANSACTION ISOLATION LEVEL SNAPSHOT; BEGIN TRAN; SELECT COUNT(*) FROM t; COMMIT;
```

```text
Msg 3952, Level 16, State 1, Server a07be756749e, Line 1
Snapshot isolation transaction failed accessing database 'ss02_sin_snapshot' because snapshot isolation is not allowed in this database. Use ALTER DATABASE to allow snapshot isolation.
```

La línea que lo evita es `ALTER DATABASE ss02 SET ALLOW_SNAPSHOT_ISOLATION ON;` de `02_snapshot.sql`. Al terminar, `DROP DATABASE
ss02_sin_snapshot`.

---

## 🟡 Intermedio (8–14)

### Ejercicio 8

**Predicción:** b lee `18.00`, el saldo que a descontó y no confirmó, y el saldo final es `28.00`, porque a se arrepiente. Es la
lectura sucia que la tabla de la guía de versiones marca como posible en `READ UNCOMMITTED`, y la que Postgres no deja ocurrir. La misma
lectura con la pista de tabla, sin cambiar el nivel de la sesión:

```sql
SELECT balance FROM dbo.debtor WITH (NOLOCK) WHERE debtor_id = 1;
```

La documentación de las pistas de tabla dice que `NOLOCK` equivale a `READUNCOMMITTED`. Una consulta con `NOLOCK` en un reporte de
caja puede sumar un cobro que después se anuló.

### Ejercicio 9

**Predicción con la documentación,** fila por fila, para comparar con tu tabla:
- `READ COMMITTED` (bloqueos): el `UPDATE` de b pide `X` sobre la fila que a tiene con `X`, espera, y al confirmar a escribe su saldo
  encima. Sería la actualización perdida sin error, como en el `READ COMMITTED` de Postgres.
- `REPEATABLE READ`: según la guía, los bloqueos `S` de la lectura se retienen hasta el final de la transacción; si los dos leyeron y
  los dos piden `X` sobre la misma fila, cada uno espera al otro, y eso es un *deadlock*. Postgres da `40001` (M-27).
- `SNAPSHOT`: la guía dice que si la fila cambió después de la foto, *"an update conflict occurs and the snapshot transaction is
  terminated"*: el 3960 para quien escriba segundo.

**Rúbrica.** Cada fila de tu tabla tiene su explicación con la documentación, y la diferencia con Postgres dicha. Queda invalidada si
publica la tabla con lo que pasó en SQL Server.

### Ejercicio 10

```sql
-- sqlserver · versión 1: que el motor haga la cuenta (el cobro es una resta, no un saldo calculado afuera)
a3: UPDATE dbo.debtor SET balance = balance - 10 WHERE debtor_id = 1;
b3: UPDATE dbo.debtor SET balance = balance - 5 WHERE debtor_id = 1;

-- versión 2: leer con bloqueo de actualización antes de calcular
a2: SELECT balance FROM dbo.debtor WITH (UPDLOCK) WHERE debtor_id = 1;
b2: SELECT balance FROM dbo.debtor WITH (UPDLOCK) WHERE debtor_id = 1;     -- espera a que a confirme
```

En la primera, cada `UPDATE` lee la fila de verdad con su bloqueo en el momento de escribir, y b, que espera a a, resta sobre `18.00`:
13,00. En la segunda, `UPDLOCK` es el `SELECT … FOR UPDATE` de Postgres: dos `UPDLOCK` sobre la misma fila son incompatibles, así que b
lee recién cuando a confirmó, y calcula sobre `18.00`. Las dos funcionan porque la lectura que decide y la escritura dejan de estar
separadas por un hueco donde otro escribe.

### Ejercicio 11

**Predicción:** dos tomas. `SNAPSHOT` detecta conflictos de **escritura sobre la misma fila**, y aquí cada técnico inserta una fila
nueva en `specimen_take`: no hay ninguna fila que los dos modifiquen, así que no hay 3960. Es el *write skew*, que tampoco frena el
`REPEATABLE READ` de Postgres: M-27 publica dos tomas en ese nivel. La guía de versiones no promete otra cosa: su tabla de efectos de
concurrencia lista para `SNAPSHOT` que no hay lecturas sucias, ni no repetibles, ni fantasmas, y no menciona el *write skew*.

### Ejercicio 12

```sql
-- sqlserver, desde una tercera sesión, con las dos lecturas SERIALIZABLE hechas
SELECT request_session_id, resource_type, request_mode, request_status, COUNT(*) AS bloqueos
FROM sys.dm_tran_locks
WHERE resource_database_id = DB_ID('ss02') AND request_session_id <> @@SPID
GROUP BY request_session_id, resource_type, request_mode, request_status
ORDER BY 1, 2, 3;
```

El modo que importa es **`RangeS-S`** sobre las claves (`KEY`): cada sesión protege el rango que leyó, el de "no hay ninguna toma de
esta muestra", para que nadie inserte ahí. El `INSERT` de cualquiera de las dos necesita un `RangeI-N` en ese mismo rango, que es
incompatible con el `RangeS-S` de la otra: los dos esperan al otro, y el monitor de *deadlocks* elige una víctima. Es el mecanismo de la
guía (*"Key-range locks protect a range of rows implicitly included in a record set being read"*) y la razón por la que este
`SERIALIZABLE` resuelve con esperas lo que el de Postgres resuelve con un `40001` al confirmar.

### Ejercicio 13

```sql
ALTER TABLE dbo.specimen_take ADD CONSTRAINT specimen_take_once UNIQUE (specimen_id);
```

```text
Violation of UNIQUE KEY constraint 'specimen_take_once'. Cannot insert duplicate key in object 'dbo.specimen_take'. The duplicate key
value is (11231555).
```

Es el Msg 2627. La restricción no depende del nivel de aislamiento ni del motor: la segunda toma falla siempre, sin espera larga ni
víctima, y la aplicación sabe exactamente por qué. La Fase 15 llegó a lo mismo en Postgres (`23505`) con 0 tomas perdidas y 0
duplicadas. Al terminar, `DROP CONSTRAINT specimen_take_once` para que las carreras de esta fase sigan mostrando el *write skew*.

### Ejercicio 14

```sql
-- postgres
SELECT "Fecha"::date AS dia, count(*) FROM legacy."Comprobantes" WHERE "Fecha" >= '2026-01-01'
GROUP BY 1 ORDER BY 2 DESC LIMIT 1;
```

```text
    dia     | count
------------+-------
 2026-06-17 |   304
```

```text
 PuntoVenta | count
------------+-------
          1 |   153
          2 |    48
          3 |    32
          4 |    36
          5 |    35
```

El día más cargado de 2026 tiene 304 comprobantes, 153 en el punto de venta 1. La caja **no guarda la hora**: `Fecha` es `datetime` y
todas las horas son `00:00`, así que no se puede saber cuántos se emitieron cerca del cierre. Una estimación razonada: si las cajas
atienden de 7 a 20 y cada cobro tiene su transacción abierta unos segundos, en el instante del cierre hay del orden de cero a dos cobros
a medio confirmar en el punto 1, y la anomalía es de un comprobante, no de cien. Es rara, y por eso nadie la vio. El dato que habría que
pedir es la hora de cada cobro, que la base de 2026 sí tiene que guardar.

---

## 🟠 Difícil (15–19)

### Ejercicio 15

**Solución.** Se resuelve con `03_version_store.py`. Lo que hay que explicar con la documentación es el tamaño de `dbo.hemogram` al
final. La guía de versiones dice que cada fila puede sumar 14 bytes la primera vez que se modifica con una opción de versiones encendida,
que esos bytes **se quedan** hasta que la fila se modifica con las opciones apagadas, y que agregarlos *"can cause index page splits"*.
Si la tabla quedó más grande que antes de la corrección, y no volvió al cerrar la lectura, la apuesta se ganó: el *version store* vuelve
a cero solo, la marca de cada fila no. No publiques los números.

### Ejercicio 16

```python
# postgres · la misma lectura larga, sobre staging.hemogram de la Fase 18
r.execute("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ")
r.execute("SELECT count(*) FROM staging.hemogram WHERE hematocrit IS NOT NULL")
for _ in range(3):
    x.execute("UPDATE staging.hemogram SET version = version + 1")
```

```text
antes                  hemogram 2640 KB
con la lectura abierta hemogram 10528 KB
VACUUM con la lectura  hemogram 10528 KB · muertas 87723
la lectura ve la misma foto: True
VACUUM al cerrarla     hemogram 10528 KB · muertas 0
```

Tres correcciones de 29.241 filas son 87.723 versiones viejas, y en Postgres viven **en la tabla**: el archivo pasa de 2.640 a 10.528 KB.
Mientras la lectura sigue abierta, `VACUUM` no puede limpiar ninguna, porque la lectura todavía puede necesitarlas. Al cerrarla, `VACUUM`
las limpia (0 muertas), pero **el archivo no se achica**: el espacio queda para reutilizar, como midió la Fase 17. La factura de la
lectura larga la paga la tabla, y queda pagada. En SQL Server con RCSI la paga `tempdb`, que la devuelve sola, y la tabla paga solo la
marca de cada fila. Al terminar, `src/18-bloqueos-deadlocks-y-ddl/01_setup.sql` deja `staging.hemogram` como estaba.

### Ejercicio 17

**Predicción:** con ADR, las versiones van al *persistent version store* (PVS) **dentro de `ss02`**, y
`sys.dm_tran_version_store_space_usage` deja de servir porque, según la guía, *"Applies to the version store in `tempdb` only"*. La vista
que hay que mirar es `sys.dm_tran_persistent_version_store_stats` (columna `persistent_version_store_size_kb`). Se puede encender en el
laboratorio:

```sql
ALTER DATABASE ss02 SET ACCELERATED_DATABASE_RECOVERY = ON WITH ROLLBACK IMMEDIATE;
-- … el ejercicio 15, con la vista del PVS …
ALTER DATABASE ss02 SET ACCELERATED_DATABASE_RECOVERY = OFF WITH ROLLBACK IMMEDIATE;
```

Lo que cambia la decisión: con ADR, la lectura larga vuelve a pagarla **la base**, como en Postgres, y no `tempdb`. No publiques los
números.

### Ejercicio 18

**Solución de referencia.** Una carrera con `dbo.debtor` y una tabla `dbo.receipt (debtor_id, amount)`:

```text
-- @engine sqlserver
-- @database ss02
a1: BEGIN TRAN;
a2: INSERT INTO dbo.receipt (debtor_id, amount) VALUES (1, 10.00);
b1: SET TRANSACTION ISOLATION LEVEL {isolation}; BEGIN TRAN;
b2: SELECT SUM(amount) FROM dbo.receipt;
a3: UPDATE dbo.debtor SET balance = balance - 10 WHERE debtor_id = 1;
a4: COMMIT;
b3: SELECT SUM(balance) FROM dbo.debtor;
b4: COMMIT;
```

**Predicción.** Con bloqueos, b2 espera a que a confirme y b ve las dos cosas consistentes. Con RCSI, b2 no ve el recibo (no estaba
confirmado), y b3, una sentencia nueva, ve el saldo ya descontado: el cierre suma un descuento sin su recibo. Con `SNAPSHOT`, b ve la foto
del comienzo en las dos sentencias: ni el recibo ni el descuento, que es consistente. Para el cierre, lo correcto es `SNAPSHOT` (o una
sola sentencia), y es lo que la sección 9 le pide a cada reporte antes de encender RCSI.

**Rúbrica.** La carrera corre en los tres niveles; la predicción va antes, con la frase de la documentación que la sostiene; la
conclusión no publica lo que vio en SQL Server.

### Ejercicio 19

```python
# sqlserver · la toma con reintento (resumen; la versión completa reintenta también el 1205)
def take(conn, technician):
    for attempt in range(1, 21):
        cur = conn.cursor()
        try:
            cur.execute("SET TRANSACTION ISOLATION LEVEL SNAPSHOT; BEGIN TRAN;")
            cur.execute("SELECT TOP (1) specimen_id FROM dbo.specimen AS s WHERE NOT EXISTS (…) ORDER BY collected_at, specimen_id")
            specimen = cur.fetchone()[0]
            cur.execute("UPDATE dbo.specimen SET site_code = site_code WHERE specimen_id = ?", (specimen,))   # marca la muestra
            cur.execute("INSERT INTO dbo.specimen_take (specimen_id, technician) VALUES (?, ?)", (specimen, technician))
            cur.execute("COMMIT")
            return attempt
        except Exception:
            c2 = conn.cursor(); c2.execute("SELECT @@ERROR, @@TRANCOUNT")
            code, open_tx = c2.fetchone()
            if open_tx: c2.execute("ROLLBACK")
            if str(code) not in ("3960", "1205"): raise
            time.sleep(random.uniform(0, 0.002 * 2 ** min(attempt, 6)))      # la espera de la Fase 15
```

Dos decisiones que hacen que funcione. El `UPDATE` sobre la muestra convierte el *write skew* en un **conflicto de escritura sobre la
misma fila**, que `SNAPSHOT` sí detecta (ejercicio 11): sin él, dos técnicos insertan la misma muestra sin error. Y la espera aleatoria
entre intentos: sin ella, los cuatro hilos vuelven a chocar enseguida sobre la misma primera muestra libre. La Fase 15 lo midió en
Postgres: con ocho técnicos, la espera bajó los reintentos por toma de 3,4 a 0,27. El criterio es cero perdidas y cero duplicadas en `dbo.specimen_take`
(`COUNT(*) = COUNT(DISTINCT specimen_id) = 100`). No publiques los reintentos.

---

## 🔴 Muy difícil (20–22) — rúbrica

### Ejercicio 20

*Encender RCSI en ALAMEDA.*

**Rúbrica (sobre 5 puntos):** 1 punto por la lista de reportes y procesos que contaban con esperar, con al menos el cierre de caja; 1 por
la ventana y el comando (`WITH ROLLBACK IMMEDIATE`, avisando a recepción como en el corte de la Fase 25); 1 por lo que cambia de
comportamiento, con al menos tres casos de esta fase (el lector que ya no espera, la foto por sentencia, la marca de 14 bytes); 1 por el
costo de `tempdb` como una medición que se hace antes y después (`sys.dm_tran_version_store_space_usage`), no como un número supuesto;
1 por la vuelta atrás (`SET READ_COMMITTED_SNAPSHOT OFF`, en otra ventana) y su límite: la marca de cada fila no se va sola.

### Ejercicio 21

**Solución de referencia.** Tres `UPDATE` sobre dos deudores en una transacción, el segundo con una división por cero
(`Divide by zero error encountered.`, Msg 8134), mandados sentencia por sentencia como lo haría una aplicación. Con `XACT_ABORT OFF`, la
documentación dice que solo se deshace la sentencia que falló: la transacción sigue abierta, el tercer `UPDATE` corre dentro de ella y el
`COMMIT` confirma el primero y el tercero. Con `XACT_ABORT ON`, el error deshace la transacción entera, y lo que se manda después corre
**fuera** de ella, en *autocommit*: el tercer `UPDATE` se confirma solo. Es el punto de rotura de la sección 8, otra vez. La regla para el
código nuevo es `SET XACT_ABORT ON` y `IF @@TRANCOUNT > 0` (o `XACT_STATE()`) antes de cada sentencia que asume una transacción. En
Postgres, el comportamiento de fábrica ya es el de `ON`, más una red: después de un error, todo lo que llega antes del `ROLLBACK` falla con
`25P02`, en lugar de confirmarse solo.

**Rúbrica (sobre 4 puntos):** 1 por cada modo demostrado con su estado final; 1 por la regla; 1 por el contraste con Postgres y el
`25P02`.

### Ejercicio 22

*La tabla de traducción completa.*

**Rúbrica (sobre 4 puntos):** 1 punto por notar que la fila "nivel por defecto" está bien solo con RCSI apagado, y que la base de 2026
puede tenerlo encendido; 1 por la fila "leer la foto del comienzo", que con `SNAPSHOT` exige la opción de la base (3952 si falta); 1 por
la fila del error de serialización, que mezcla el 1205 (víctima, transacción deshecha) con el 3960 (conflicto), y en Postgres son dos
códigos distintos, `40P01` y `40001`; 1 por proponer la corrección con la documentación y sin resultados de SQL Server.

---

## 🔥 Opcionales

### Ejercicio 🔥 1

**Rúbrica.** ADR y *optimized locking* se encienden con `ALTER DATABASE ss02 SET ACCELERATED_DATABASE_RECOVERY = ON` y `SET
OPTIMIZED_LOCKING = ON` (los dos con `WITH ROLLBACK IMMEDIATE`), y `DATABASEPROPERTYEX('ss02', 'IsOptimizedLockingOn')` lo confirma. La
página de *optimized locking* dice que un `UPDATE` en RCSI elige las filas sobre la última versión confirmada sin bloquear las que no
califican, y que el bloqueo que se retiene hasta el final es sobre el identificador de la transacción. La respuesta correcta separa lo
que eso cambia (menos esperas entre escritores que tocan filas distintas) de lo que no cambia (dos escritores sobre la misma fila se siguen
esperando, el 1205 sigue existiendo, la actualización perdida de `lost_update.race` sigue pasando porque la aplicación escribe un saldo
calculado afuera). Para el plan del ejercicio 20, *optimized locking* es un paso posterior, que exige ADR y con él el PVS en la base. Al
terminar, las dos opciones se apagan.
