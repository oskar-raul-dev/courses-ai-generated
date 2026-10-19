# ✅ Soluciones — Fase 18: Bloqueos, deadlocks y DDL

> **Curso:** Ruta SQL · Solucionario de la [Fase 18](../18-bloqueos-deadlocks-y-ddl.md)
> **Ejercicios:** 26 · **Perfil:** M · **Motores:** Postgres y MySQL de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso)
> **Fecha de verificación ejecutada:** 14/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Todas las soluciones suponen `18-bloqueos-deadlocks-y-ddl/01_setup.sql` corrido, y en MySQL las tablas de la Fase 15
(`01_setup_mysql.sql`). Los números de proceso y de transacción cambian en cada corrida; las esperas, los errores y su orden, no.
El boss no tiene solución publicada: es un encargo.

---

## 🟢 Fácil (1–8)

### Ejercicio 1

**Enunciado (resumen):** el almuerzo.

**Solución.** La salida de la sección 4: `pg_blocking_pids` del `UPDATE` de b es el proceso de a, que está `idle in transaction`.
El hematocrito termina en 42: a guardó 40 al volver, b guardó 42 encima apenas pudo.

**Rúbrica.** Una respuesta correcta tiene que:
- identificar al culpable por su estado, no solo por su número;
- notar que la espera no evitó que b pisara a a.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-1--el-almuerzo)

### Ejercicio 2

**Enunciado (resumen):** no esperar.

**Solución.**

```text
ERROR:  canceling statement due to lock timeout
CONTEXT:  while updating tuple (329,31) in relation "hemogram"
ERROR:  could not obtain lock on row in relation "hemogram"
```

Los dos son `55P03` (`lock_not_available`). El primero esperó un segundo (`lock_timeout`) y canceló la sentencia; el segundo no
esperó nada (`NOWAIT`). En los dos, la transacción de b queda abortada.

**Rúbrica.** Una respuesta correcta tiene que:
- distinguir esperar un tiempo de no esperar.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-2--no-esperar)

### Ejercicio 3

**Enunciado (resumen):** la escritura optimista.

**Solución.** b actualiza 1 fila (`version = 1` todavía era cierto); a actualiza 0 (la versión ya era 2). Final: 42, versión 2.
Nadie esperó.

**Rúbrica.** Una respuesta correcta tiene que:
- leer `UPDATE 0` como un conflicto detectado, no como un error.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-3--la-escritura-optimista)

### Ejercicio 4

**Enunciado (resumen):** el *deadlock* en los dos motores.

**Solución.** En Postgres falla a, la primera que empezó a esperar: su `deadlock_timeout` vence primero, revisa el grafo, encuentra
el ciclo y se aborta (`40P01`), un segundo después. En MySQL falla b, en el acto, cuando su pedido cierra el ciclo (`1213`).

**Rúbrica.** Una respuesta correcta tiene que:
- explicar por qué cae una distinta en cada motor.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-4--el-deadlock-en-los-dos-motores)

### Ejercicio 5

**Enunciado (resumen):** la cola.

**Solución.** `(82688, AccessShareLock, True, [])`: a, con la lectura abierta, concedida, no espera a nadie.
`(82689, AccessExclusiveLock, False, [82688])`: b, el `ALTER`, en espera, bloqueado por a. `(82690, AccessShareLock, False,
[82689])`: c, que pide lo mismo que a tiene, en espera, **bloqueado por b**. Es la cola: c no choca con a, choca con b.

**Rúbrica.** Una respuesta correcta tiene que:
- notar que c está bloqueado por b y no por a.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-5--la-cola)

### Ejercicio 6

**Enunciado (resumen):** el *metadata lock*.

**Solución.** Las dos sesiones en `Waiting for table metadata lock`: el `ALTER … ALGORITHM=INSTANT` y el `SELECT`.
`@@lock_wait_timeout` vale 31.536.000 (segundos: un año).

**Rúbrica.** Una respuesta correcta tiene que:
- notar que `INSTANT` también espera.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-6--el-metadata-lock)

### Ejercicio 7

**Enunciado (resumen):** qué reescribe.

**Solución.** La tabla de la sección 5.4: reescriben la columna con valor volátil (11,2 s) y el cambio de `integer` a `bigint`
(10,2 s); no reescriben la columna sin valor (3 ms), la de valor constante (2 ms) ni el `varchar` más largo (1 ms). El
`relfilenode` cambia solo en los dos primeros.

**Rúbrica.** Una respuesta correcta tiene que:
- usar el `relfilenode` como prueba, no el tiempo.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-7--qué-reescribe)

### Ejercicio 8

**Enunciado (resumen):** el 1205 que no deshace.

**Solución.** Quedó confirmado el pago (`comprobación: 1`) sin el cambio de saldo: el 1205 deshizo solo el `UPDATE`, y el `COMMIT`
de b confirmó lo demás. `innodb_rollback_on_timeout` está en 0.

**Rúbrica.** Una respuesta correcta tiene que:
- explicar por qué el mensaje dice "restarting transaction" y la transacción sigue viva.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-8--el-1205-que-no-deshace)

---

## 🟡 Intermedio (9–15)

### Ejercicio 9

**Enunciado (resumen):** el orden que evita el *deadlock*.

**Solución.**

```text
a1: BEGIN;   b1: BEGIN;
a2: UPDATE staging.hemogram SET notes = 'a' WHERE hemogram_id = 1;
b2: UPDATE staging.hemogram SET notes = 'b' WHERE hemogram_id = 1;
a3: UPDATE staging.hemogram SET notes = 'a' WHERE hemogram_id = 2;
a4: ROLLBACK;
b3: UPDATE staging.hemogram SET notes = 'b' WHERE hemogram_id = 2;
```

```text
 a2  UPDATE 1
 b2  ⏳ espera un bloqueo
 a3  UPDATE 1
 a4  ROLLBACK
   ↳ b2  UPDATE 1
 b3  UPDATE 1
```

Con el mismo orden, b espera a a desde su primer pedido, y nunca tiene nada que a necesite.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar que b espera y nadie falla.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-9--el-orden-que-evita-el-deadlock)

### Ejercicio 10

**Enunciado (resumen):** un *deadlock* con una sola fila.

**Solución.**

```text
 a2  1 fila  (42)                          FOR SHARE
 b2  1 fila  (42)                          FOR SHARE: compatible con el de a
 a3  ⏳ espera un bloqueo                  UPDATE: necesita exclusivo, espera el compartido de b
 b3  ⏳ espera un bloqueo                  UPDATE: espera el compartido de a
   ↳ a3  ✗ 40P01 deadlock detected
   ↳ b3  UPDATE 1
```

Dos lecturas compartidas que después quieren escribir: cada una espera que la otra suelte lo que ella también tiene. Es el
*deadlock* del `SERIALIZABLE` de MySQL en la Fase 15, escrito a mano. La cura es leer con `FOR UPDATE` si se va a escribir.

**Rúbrica.** Una respuesta correcta tiene que:
- explicar la compatibilidad de los dos `FOR SHARE`.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-10--un-deadlock-con-una-sola-fila)

### Ejercicio 11

**Enunciado (resumen):** `lock_timeout` para el DDL.

**Solución.** En Postgres, el `ALTER` se rinde al segundo (`55P03 canceling statement due to lock timeout`) y c pasa enseguida
(`↳ c1`), antes de que a termine. En MySQL, con `lock_wait_timeout = 1`, lo mismo con `1205 Lock wait timeout exceeded`: el
mismo número que el de las filas, para el *metadata lock*.

**Rúbrica.** Una respuesta correcta tiene que:
- notar que c pasa sin esperar a que a termine.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-11--lock_timeout-para-el-ddl)

### Ejercicio 12

**Enunciado (resumen):** `INSTANT`, `INPLACE` y `COPY`.

**Solución.**

| Cambio | `INSTANT` | `INPLACE` | `COPY` |
|---|---|---|---|
| agregar una columna | sí | sí | sí |
| cambiar `decimal(12,2)` a `decimal(15,2)` | 1846: *Need to rebuild the table to change column type. Try ALGORITHM=COPY/INPLACE.* | 1846: *Cannot change column type INPLACE. Try ALGORITHM=COPY.* | sí |

El mensaje de `INSTANT` sugiere `INPLACE`, y `INPLACE` dice que no: cambiar el tipo de una columna copia la tabla. Pedir el
algoritmo explícito es la forma de que MySQL falle antes de cerrar nada.

**Rúbrica.** Una respuesta correcta tiene que:
- pedir el algoritmo explícito en cada prueba.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-12--instant-inplace-y-copy)

### Ejercicio 13

**Enunciado (resumen):** `CREATE INDEX CONCURRENTLY`.

**Solución.** `CREATE INDEX`: 2,4 s, y una escritura que llegó al segundo esperó 1.434 ms (el `SHARE` bloquea escrituras hasta
terminar). `CONCURRENTLY`: 4,0 s, y la escritura esperó 57 ms (12 en otra corrida). Tarda más porque recorre la tabla dos veces y espera a que terminen
las transacciones que podrían no ver el índice; a cambio, toma `SHARE UPDATE EXCLUSIVE`, que deja escribir.

**Rúbrica.** Una respuesta correcta tiene que:
- nombrar los dos bloqueos.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-13--create-index-concurrently)

### Ejercicio 14

**Enunciado (resumen):** `NOT NULL` sin reescribir.

**Solución.** La primera restricción se agrega `NOT VALID` en 2 ms, y `VALIDATE` falla en el acto:

```text
ERROR:  check constraint "result_ddl_has_value" of relation "result_ddl" is violated by some row
```

Hay 359.662 resultados sin valor, sin número y sin leyenda: el 3 % de vacíos de la caja. `NOT VALID` deja la regla vigente para las
filas nuevas mientras se decide qué hacer con esas. La segunda (`recorded_at >= '1996-01-01'`): `NOT VALID` en 1 ms, `VALIDATE` en
1,0 s con `ShareUpdateExclusiveLock`, y una escritura en el medio esperó 2 ms.

**Rúbrica.** Una respuesta correcta tiene que:
- leer la primera falla como información sobre los datos;
- nombrar el bloqueo de `VALIDATE`.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-14--not-null-sin-reescribir)

### Ejercicio 15

**Enunciado (resumen):** la autopsia.

**Solución.**

| `ALTER` | Más de 1 s | Mediana | La peor | El `ALTER` |
|---|---|---|---|---|
| constante, sin `lock_timeout` | 21 de 30 | 1,63 s | 3,06 s | 3,3 s |
| volátil, sin `lock_timeout` | 30 de 30 | 11,59 s | 13,02 s | 13,3 s |
| volátil, con `lock_timeout` y reintento | 2 de 30 | 0,30 s | 9,71 s | 12,8 s, 3 intentos |
| constante, con `lock_timeout` y reintento | 0 de 30 | 0,21 s | 0,98 s | 3,3 s, 3 intentos |

La primera fila es la cola sola; la segunda, la cola más la reescritura; la tercera saca la cola pero no la reescritura (las
lecturas que llegan mientras reescribe esperan igual); la cuarta saca las dos.

**Rúbrica.** Una respuesta correcta tiene que:
- separar la cola de la reescritura.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-15--la-autopsia)

---

## 🟠 Difícil (16–21)

### Ejercicio 16

**Enunciado (resumen):** el árbol de esperas.

**Solución de referencia.**

```sql
WITH RECURSIVE waits AS (
    SELECT pid, unnest(pg_blocking_pids(pid)) AS blocker FROM pg_stat_activity WHERE cardinality(pg_blocking_pids(pid)) > 0
), chain AS (
    SELECT pid, blocker, ARRAY[pid, blocker] AS path FROM waits
    UNION ALL
    SELECT c.pid, w.blocker, c.path || w.blocker FROM chain c JOIN waits w ON w.pid = c.blocker
    WHERE NOT w.blocker = ANY (c.path)
)
SELECT pid, path FROM chain c WHERE NOT EXISTS (SELECT 1 FROM waits w WHERE w.pid = c.blocker) ORDER BY pid;
```

Con la cola de `ddl_queue.race`: `(87198, [87198, 87197])` y `(87199, [87199, 87198, 87197])`. c (87199) espera a b (87198), que
espera a a (87197), que no espera a nadie: a es la raíz, y matar a b no destraba a c más que unos milisegundos, porque a sigue ahí.

**Rúbrica.**
- **Aprobado:** la cadena.
- **Bien:** la condición que corta los ciclos (`NOT … = ANY (path)`).
- **Excelente:** la raíz como el proceso a revisar.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-16--el-árbol-de-esperas)

### Ejercicio 17

**Enunciado (resumen):** el *deadlock* en el registro.

**Solución de referencia.** El servidor del curso escribe su registro en la salida del contenedor (`docker logs`); con o sin
`log_lock_waits`, un *deadlock* queda así:

```text
… [83965] DETAIL:  Process 83965 waits for ShareLock on transaction 378885; blocked by process 83966.
	Process 83966 waits for ShareLock on transaction 378884; blocked by process 83965.
	Process 83965: UPDATE staging.hemogram SET notes = 'a' WHERE hemogram_id = 2
	Process 83966: UPDATE staging.hemogram SET notes = 'b' WHERE hemogram_id = 1
```

El registro agrega lo que el cliente no ve: **la consulta de cada proceso** (el cliente recibe solo `HINT: See server log for query
details`). `log_lock_waits = on` agrega además una línea por cada espera que pasa `deadlock_timeout`, aunque no termine en *deadlock*.

**Rúbrica.**
- **Aprobado:** las líneas del registro.
- **Bien:** lo que agregan al mensaje del cliente.
- **Excelente:** `log_lock_waits` para las esperas largas que no son *deadlock*.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-17--el-deadlock-en-el-registro)

### Ejercicio 18

**Enunciado (resumen):** `SKIP LOCKED` en MySQL.

**Solución de referencia.** Con funciones de `lab race` (en MySQL, `UPDATE` no puede leer la misma tabla en una subconsulta):

```python
def take(who):
    def step(conn):
        with conn.cursor() as c:
            c.execute("SELECT specimen_id FROM staging.specimen WHERE taken_by IS NULL ORDER BY collected_at, specimen_id "
                      "LIMIT 1 FOR UPDATE SKIP LOCKED")
            row = c.fetchone()
            if row is None:
                return "ninguna muestra libre: todas saltadas"
            c.execute("UPDATE staging.specimen SET taken_by = %s WHERE specimen_id = %s", (who, row[0]))
        return row[0]
    return step
```

```text
sin índice (taken_by, collected_at, specimen_id)
 a2  11231555
 b2  ninguna muestra libre: todas saltadas
con índice (taken_by, collected_at, specimen_id)
 a2  11231555
 b2  11231557
```

Sin índice, a bloquea cada fila que recorre para ordenarlas, y b las salta todas. Con el índice, a bloquea una.

**Rúbrica.**
- **Aprobado:** dos muestras distintas con el índice.
- **Bien:** el caso sin índice explicado.
- **Excelente:** que en Postgres el mismo `FOR UPDATE` bloquea solo lo que devuelve.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-18--skip-locked-en-mysql)

### Ejercicio 19

**Enunciado (resumen):** el 1205 bien manejado.

**Solución de referencia.**

```python
for attempt in range(1, 6):
    try:
        with conn.cursor() as c:
            c.execute("START TRANSACTION")
            c.execute("INSERT INTO staging.payment VALUES (1, 10.00)")
            c.execute("UPDATE staging.debtor SET balance = balance - 10 WHERE debtor_id = 1")
            c.execute("COMMIT")
        break
    except pymysql.err.OperationalError as e:
        conn.rollback()                    # el 1205 dejó la transacción abierta: se deshace entera
        time.sleep(0.5)
```

Con otra sesión reteniendo el deudor 2,5 s y `innodb_lock_wait_timeout = 1`:

```text
intento 1: 1205 Lock wait timeout exceeded; try restarting transaction → ROLLBACK y reintento
intento 2: confirmado
pagos: 1
```

Un solo pago: el `ROLLBACK` deshizo el `INSERT` del primer intento. Sin él, quedaban dos.

**Rúbrica.**
- **Aprobado:** `ROLLBACK` antes de reintentar.
- **Bien:** con tope y espera.
- **Excelente:** reintenta solo 1205 y 1213, y explica qué pasa si es otro error.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-19--el-1205-bien-manejado)

### Ejercicio 20

**Enunciado (resumen):** un formulario optimista de verdad.

**Solución de referencia.**

```python
def form(conn, hid, new_value, other=None):
    value, version = conn.execute("SELECT hematocrit, version FROM staging.hemogram WHERE hemogram_id = %s", (hid,)).fetchone()
    if other: other()                                   # mientras el usuario mira la pantalla
    saved = conn.execute("UPDATE staging.hemogram SET hematocrit = %s, version = version + 1 "
                         "WHERE hemogram_id = %s AND version = %s", (new_value, hid, version)).rowcount
    if saved:
        return f"guardado {new_value}"
    now = conn.execute("SELECT hematocrit, version FROM staging.hemogram WHERE hemogram_id = %s", (hid,)).fetchone()
    return f"conflicto: abriste {value} (versión {version}); ahora dice {now[0]} (versión {now[1]}). No se guardó {new_value}."
```

```text
solo: guardado 40 (la versión 1 pasó a 2)
con otro en el medio: conflicto: abriste 40 (versión 2); ahora dice 42 (versión 3). No se guardó 39.
```

**Rúbrica.**
- **Aprobado:** las dos ramas.
- **Bien:** el conflicto muestra el valor nuevo, para que el usuario decida.
- **Excelente:** ninguna transacción abierta mientras el usuario mira.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-20--un-formulario-optimista-de-verdad)

### Ejercicio 21

**Enunciado (resumen):** el `ALTER` en lotes.

**Solución de referencia.**

```text
ADD COLUMN sin valor: 1 ms
SET DEFAULT para las filas nuevas: 1 ms
25 lotes de 500.000 ids · el más largo 1,6 s · total 35 s · la lectura más lenta durante los lotes 1 ms en 675 lecturas
```

Cada lote es una transacción propia (`UPDATE … WHERE result_id > … AND result_id <= … AND loaded_at IS NULL`): bloquea solo sus
filas mientras dura, y la condición `IS NULL` permite cortarlo y retomarlo. Treinta y cinco segundos de trabajo contra once de tabla
cerrada. Los lotes dejan versiones muertas (Fase 17): un `VACUUM` al final.

**Rúbrica.**
- **Aprobado:** los tres pasos medidos.
- **Bien:** la lectura concurrente medida.
- **Excelente:** el lote reanudable y el `VACUUM`.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-21--el-alter-en-lotes)

---

## 🔴 Muy difícil (22–26)

### Ejercicio 22

**Enunciado (resumen):** Oracle.

**Solución de referencia.** No se publica resultado (la regla está en [`a09`](../a09-licencias-publicacion-y-riesgo.md)).

**Rúbrica.**
- **Aprobado:** las tres carreras corridas: la cola con la lectura abierta, con un `UPDATE` sin confirmar, y el *deadlock*.
- **Bien:** el resultado explicado con la documentación de bloqueos DDL y DML y de `DDL_LOCK_TIMEOUT`.
- **Excelente:** la comparación con Postgres y MySQL: en qué motor una lectura larga puede frenar un `ALTER`, y en cuál no.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-22--oracle)

### Ejercicio 23

**Enunciado (resumen):** la regla del DDL de Alameda.

**Solución de referencia.**

1. **Antes:** ¿el cambio reescribe? (la tabla de la sección 5.4; en duda, probarlo en una copia mirando el `relfilenode`). Si
   reescribe, no se corre así: va por pasos (columna sin valor, lotes, `NOT VALID` y `VALIDATE`, [Fase 25](../25-la-migracion-sin-parar.md)).
2. **Antes:** `pg_stat_activity` ordenada por `xact_start`: si hay una transacción de más de unos minutos, se espera o se habla con
   su dueño.
3. **Al correr:** `SET lock_timeout = '1s'` en la sesión, con reintento cada pocos segundos y tope. En MySQL,
   `SET SESSION lock_wait_timeout = 1` y el algoritmo explícito.
4. **Índices:** siempre `CONCURRENTLY`, fuera de una transacción; si falla, `DROP INDEX CONCURRENTLY` del índice `INVALID`.

Cada paso con su número: la cola (30 de 30 lecturas detenidas), la reescritura (9 a 11 s), el `lock_timeout` (0 de 30), el índice
(1.434 contra 57 ms).

**Rúbrica.**
- **Aprobado:** `lock_timeout` y saber si reescribe.
- **Bien:** la revisión de transacciones abiertas.
- **Excelente:** los cambios que no se hacen así, y a dónde van.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-23--la-regla-del-ddl-de-alameda)

### Ejercicio 24

**Enunciado (resumen):** los límites por rol.

**Solución de referencia.**

| Rol | `lock_timeout` | `statement_timeout` | `idle_in_transaction_session_timeout` | Por qué |
|---|---|---|---|---|
| la caja | 2 s | 10 s | 30 s | el número no puede esperar a un humano; la llamada al organismo va dentro (Fase 16) |
| el laboratorio | 2 s | 30 s | 30 s | cargas cortas; un formulario no retiene nada (sección 5.1) |
| la exportación | — | — | 5 min | lee mucho y no bloquea a nadie; lo que no puede es quedarse ociosa con la foto (Fase 17) |
| el que cambia el esquema | 1 s | — | — | se rinde rápido y reintenta (sección 9) |

Los valores son el punto de partida, no una medición: cada uno se ajusta con `log_lock_waits` y `pg_stat_statements`.

**Rúbrica.**
- **Aprobado:** un valor por rol.
- **Bien:** el porqué de cada uno con su fase.
- **Excelente:** dice qué no está medido y cómo se mediría.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-24--los-límites-por-rol)

### Ejercicio 25

**Enunciado (resumen):** "nos fuimos a Mongo".

**Solución de referencia.** La respuesta reconoce el dolor (el `ALTER` sí cerró la base) y separa sus dos causas medidas: la cola
detrás de una transacción abierta (con un cambio de 2 ms, 30 lecturas detenidas mientras la transacción siguió) y la reescritura
(9 a 11 s en 12 millones de filas). Las dos tienen arreglo dentro del motor: `lock_timeout` y reintento (0 de 30 detenidas), y
cambios que no reescriben o que van en lotes (35 s de trabajo sin que ninguna lectura espere más de 1 ms). Lo que Mongo sí resuelve:
no hay `ALTER`, porque cada documento trae su forma. Lo que cobra a cambio: la forma vieja y la nueva conviven en los datos para
siempre, y cada lector tiene que entender las dos; es el *expand/contract* de la [Fase 25](../25-la-migracion-sin-parar.md) hecho en el código de la aplicación, sin
fecha de fin.

**Rúbrica.**
- **Aprobado:** las dos causas separadas.
- **Bien:** los arreglos medidos.
- **Excelente:** lo que Mongo resuelve y lo que traslada, dicho sin desprecio.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-25--nos-fuimos-a-mongo)

### Ejercicio 26

**Enunciado (resumen):** bloqueo pesimista u optimista.

**Solución de referencia.**

| Escritura | Elección | Por qué, y la medición |
|---|---|---|
| el folio | pesimista, corto | el organismo exige orden; el número se toma al autorizar (Fase 16: 1,2 ms de espera con el armado afuera) |
| la muestra | pesimista sin espera (`SKIP LOCKED`) | es una cola; el estado en la fila (Fase 15: 0 duplicados, 0 reintentos) |
| el hemograma | optimista | lo edita un humano (sección 5.1: nadie espera, el conflicto se avisa) |
| el contador de la caja | pesimista, el mismo del folio | — |
| la marca de llamado | ninguno: un evento que se inserta | Fase 17: 120 bytes de WAL y ninguna versión muerta |

El criterio: pesimista cuando la operación es corta y el orden importa; optimista cuando la edición la hace un humano; ninguno cuando
el dato es un hecho que se agrega.

**Rúbrica.**
- **Aprobado:** una elección por escritura.
- **Bien:** con su medición.
- **Excelente:** el criterio general, dicho en una línea.

[← Volver al ejercicio](../18-bloqueos-deadlocks-y-ddl.md#-ejercicio-26--bloqueo-pesimista-u-optimista)
