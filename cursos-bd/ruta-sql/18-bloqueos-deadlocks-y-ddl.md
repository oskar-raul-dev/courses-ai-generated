# 🔐 Fase 18 — Bloqueos, deadlocks y DDL: quién espera a quién, y el ALTER que cerró la base

> **Curso:** Ruta SQL · Fase 18 de 27 · Bloque III — La concurrencia · **10 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · contraste MySQL `mysql@sha256:e2bde46db656…` · Oracle, solo con la documentación (🪞🔒)
> **Entorno de ejecución:** SQL y Python, con `uv run lab race`
> **Perfil de volumen:** M, con el modelo de `uv run lab load --profile m --model`
> **El dolor de Alameda:** el formulario de hemograma abierto a la hora del almuerzo (historia §3, 2005), y el `ALTER TABLE` que bloqueó producción, como escenario
> **Depende de:** Fase 17 · **Habilita:** Fase 19
> **Apéndices de apoyo:** a03, a04, a07, a08
> **Fecha de verificación ejecutada:** 14/10/2026
> **Objetivo:** ver quién espera a quién en los dos motores, provocar y leer un *deadlock*, medir la cola que se forma detrás de un
> cambio de esquema, y decidir cuándo el DDL en línea no alcanza. Cierra el Bloque III con su boss.

---

## 🧭 1. Dónde estamos

Las fases [15](15-aislamiento-comparado.md), [16](16-el-folio-sin-huecos.md) y [17](17-mvcc-y-su-factura.md) mostraron
esperas como resultado: el ⏳ de `lab race`, la caja que espera el número, la exportación que retiene versiones. Esta fase las
**diagnostica**. Una espera tiene un culpable con número de proceso, un modo de bloqueo y un objeto, y los dos motores lo dicen si
se les pregunta.

También agrega el bloqueo que menos se ve venir: el de un cambio de esquema. Un `ALTER TABLE` que tarda dos milisegundos puede
cerrar una tabla durante horas, y no por lo que hace, sino por lo que espera.

---

## 🎯 2. Objetivos de esta fase

1. Reproducir el formulario abierto a la hora del almuerzo y encontrar al culpable con `pg_stat_activity` y `pg_locks`.
2. Usar `lock_timeout`, `NOWAIT`, `SKIP LOCKED` y la escritura optimista, y saber cuál corresponde a cada caso.
3. Provocar un *deadlock* por orden de adquisición en los dos motores, y leer su mensaje.
4. Medir la cola detrás de un `ACCESS EXCLUSIVE` en Postgres y de un *metadata lock* en MySQL.
5. Saber qué `ALTER` reescribe la tabla, cuánto la cierra, y qué hacen `CREATE INDEX CONCURRENTLY` y el DDL en línea de MySQL.
6. Resolver el boss del bloque: una tarde de julio con las tres cajas, la planilla y el formulario.

---

## 🚫 3. Qué NO entra todavía

- **Cambiar el esquema sin cortar el servicio en ninguna fase** (*expand/contract*, columnas puente, doble escritura) → [Fase 25](25-la-migracion-sin-parar.md).
- **Bloqueos en una réplica**, conflictos de recuperación y `hot_standby_feedback`: fuera del curso.
- **Herramientas externas de DDL en línea** (`gh-ost`, `pt-online-schema-change`, `pg_repack`): se nombran, no se miden.

---

## 🏚️ 4. El dolor, en la caja

2005. La base vive en una carpeta compartida y la usan cinco PC. Access bloquea el registro que un formulario está editando, y
*"alguien deja el formulario de hemograma abierto a la hora del almuerzo y nadie más puede cargar"*. `01_setup.sql` copia la tabla
`Hemograma` de la caja (29.241 hemogramas, de 1997 a 2008) en `staging.hemogram`, con una columna `version`.
`lunch_form.race` reproduce la escena: a abre el hemograma para editarlo, b quiere corregir el mismo, c pregunta quién espera a
quién:

```text
 a2  1 fila  (41)                          a abre el formulario: SELECT … FOR UPDATE
 b1  ⏳ espera un bloqueo                  b quiere corregir: UPDATE
 c1  2 filas  (82651, [], Client, idle in transaction, SELECT hematocrit FROM staging.hemogram WHERE),
              (82652, [82651], Lock, active, UPDATE staging.hemogram SET hematocrit = '42')
 a3  UPDATE 1                              a vuelve del almuerzo, guarda 40
 a4  COMMIT
   ↳ b1  UPDATE 1                          b, que esperaba, guarda 42 encima
comprobación: 1 fila  (42, 1)
```

Dos cosas en esa salida. `pg_blocking_pids` dice exactamente quién bloquea a quién: el proceso 82652 espera al 82651, que está
`idle in transaction` (abrió el formulario y no hace nada). Y la espera **no protegió nada**: b guardó su valor sobre el de a
apenas pudo, sin saber que a lo había cambiado. Bloquear durante el almuerzo no evitó la actualización perdida; solo la demoró.

---

## 🧩 5. Quién espera a quién

### 5.1 Las salidas de una espera

Un bloqueo de fila se suelta al terminar la transacción. La pregunta de diseño es qué hace el que llega después:

| Salida | Qué hace b | Medido en `lunch_form_timeout.race` |
|---|---|---|
| esperar (por defecto) | espera lo que dure el almuerzo | — |
| `SET lock_timeout = '1s'` | espera un segundo y falla | `55P03 canceling statement due to lock timeout` |
| `FOR UPDATE NOWAIT` | falla en el acto | `55P03 could not obtain lock on row in relation "hemogram"` |
| `FOR UPDATE SKIP LOCKED` | toma otra fila, la próxima libre | la planilla de la [Fase 15](15-aislamiento-comparado.md) |
| escritura optimista | no espera: guarda solo si nadie guardó antes | `optimistic.race` |

Las tres primeras convierten una espera en un error, lo que es mejor que una pantalla congelada, pero sigue siendo un error. La
escritura optimista cambia el diseño: el formulario **no bloquea mientras el usuario edita**. Lee la fila con su `version`, y al
guardar exige que la versión no haya cambiado:

```text
 a1  1 fila  (41, 1)                       a abre el formulario (sin bloquear)
 b1  1 fila  (41, 1)
 b2  UPDATE 1                              b guarda: … SET version = version + 1 WHERE hemogram_id = 1 AND version = 1
 a2  UPDATE 0                              a guarda con la versión vieja: cero filas, y lo sabe
comprobación: 1 fila  (42, 2)
```

Nadie esperó y nadie pisó a nadie: a recibe "cero filas" y puede mostrarle al usuario el valor nuevo. Es la forma correcta de
cualquier formulario que se abre, se edita durante un tiempo humano y se guarda. Un bloqueo de base de datos dura lo que dura una
transacción, y una transacción no puede durar lo que dura un almuerzo.

### 5.2 *Deadlock*: dos esperas que se cruzan

Si a bloquea el hemograma 1 y después pide el 2, mientras b bloqueó el 2 y pide el 1, ninguno puede seguir (`deadlock.race`):

```text
 a2  UPDATE 1                              a toma el 1
 b2  UPDATE 1                              b toma el 2
 a3  ⏳ espera un bloqueo                  a pide el 2
 b3  ⏳ espera un bloqueo                  b pide el 1
   ↳ a3  ✗ 40P01 deadlock detected
   ↳ b3  UPDATE 1
```

Postgres no busca ciclos todo el tiempo: el proceso que lleva esperando `deadlock_timeout` (un segundo) revisa el grafo de
esperas, y si encuentra un ciclo, se aborta a sí mismo. Aquí fue a, que esperaba desde antes. El mensaje completo dice todo lo
que hace falta para encontrar el par:

```text
ERROR:  deadlock detected
DETAIL:  Process 83965 waits for ShareLock on transaction 378885; blocked by process 83966.
Process 83966 waits for ShareLock on transaction 378884; blocked by process 83965.
HINT:  See server log for query details.
CONTEXT:  while updating tuple (0,2) in relation "hemogram"
```

La cura no es un *timeout* más corto: es **tomar los bloqueos siempre en el mismo orden**. Si las dos correcciones ordenan los
hemogramas por `hemogram_id` antes de actualizarlos, la segunda espera a la primera y nunca se cruzan.

### 5.3 La cola detrás de un `ACCESS EXCLUSIVE`

Cada sentencia toma un bloqueo sobre la tabla, además de los de fila. Un `SELECT` toma `ACCESS SHARE`, el más débil, que solo
choca con uno: `ACCESS EXCLUSIVE`, el de casi todos los `ALTER TABLE`. Y los bloqueos de tabla se conceden **en orden de
llegada**: un pedido que no choca con los concedidos, pero sí con uno que está esperando, se pone en la fila detrás de él. Tres
sesiones bastan (`ddl_queue.race`):

```text
 a2  1 fila  (29241)                       a lee y no termina: ACCESS SHARE, concedido
 b1  ⏳ espera un bloqueo                  ALTER TABLE … ADD COLUMN reviewed_by text: ACCESS EXCLUSIVE, en espera
 c1  ⏳ espera un bloqueo                  SELECT de un hemograma: ACCESS SHARE… detrás del ALTER
 d1  3 filas  (82688, AccessShareLock, True, []),
              (82689, AccessExclusiveLock, False, [82688]),
              (82690, AccessShareLock, False, [82689])
 a3  COMMIT
   ↳ b1  ALTER TABLE
   ↳ c1  1 fila  (42)
```

`pg_locks` lo muestra entero: c pide lo mismo que a ya tiene, y no se lo dan, porque **lo bloquea b** (`blocked_by` 82689), que a
su vez espera a a. Desde que el `ALTER` entra en la cola, ninguna lectura nueva de la tabla pasa. Con `lock_timeout` en la sesión del
`ALTER` (`ddl_lock_timeout.race`), b se rinde al segundo, `↳ c1` pasa enseguida, y la tabla vuelve a estar abierta.

### 5.4 Qué `ALTER` reescribe la tabla

El otro costo de un `ALTER` es lo que hace cuando por fin consigue el bloqueo. `ddl_rewrite.py` aplica cinco cambios a
`staging.result_ddl`, una copia de los 12,1 millones de resultados (686 MB), y mira si cambió el archivo de la tabla:

> 📐 **Medición: el tiempo con `ACCESS EXCLUSIVE`** · `pgvector/pgvector@sha256:2358fcba361e…` · verificado el 14/10/2026
>
> | `ALTER` | Reescribe la tabla | Tiempo con la tabla cerrada |
> |---|---|---|
> | agregar una columna sin valor por defecto | no | 3 ms |
> | agregar una columna con un valor constante (`DEFAULT false`) | no | 2 ms |
> | agregar una columna con un valor volátil (`DEFAULT clock_timestamp()`) | **sí** | **11.241 ms** (8.805 en la validación del bloque) |
> | agrandar un `varchar` (50 a 100) | no | 1 ms |
> | `integer` a `bigint` en la clave | **sí** | **10.167 ms** (9.705) |

Desde Postgres 11, una columna con un valor constante se agrega sin tocar las filas: el valor se guarda una vez en el catálogo. Uno
volátil tiene que calcularse fila por fila, y cambiar el tipo de una columna a uno de otro tamaño, también, con sus índices. Un
índice nuevo bloquea las escrituras mientras se construye (`SHARE`): una escritura que llegó al segundo esperó 1.434 ms con `CREATE
INDEX`, y entre 12 y 57 ms con `CREATE INDEX CONCURRENTLY`, que tardó 4,0 s en lugar de 2,4 y no se puede usar dentro de una transacción.

### 5.5 Cambiar sin cerrar la tabla

Lo que reescribe se puede partir en pasos que no la cierran. Una restricción nueva se agrega `NOT VALID` (1 ms: solo vale para las
filas que vienen) y se valida después con `VALIDATE CONSTRAINT`, que recorre la tabla con un bloqueo `SHARE UPDATE EXCLUSIVE`,
compatible con lecturas y escrituras: sobre los 12,1 millones de resultados tardó 1,0 s, y una escritura que llegó en el medio
esperó 2 ms. La validación, además, dice la verdad sobre los datos. El primer intento fue "todo resultado tiene un valor" (`value_text`,
`value_numeric` o `sample_flag`), y `VALIDATE` falló en el acto: `check constraint … is violated by some row`, porque la caja trae
resultados vacíos. `NOT VALID` deja la regla vigente para lo nuevo mientras se decide qué hacer con lo viejo.

Una columna con un valor que hay que calcular se agrega sin valor (1 ms), se le pone el valor por defecto para las filas nuevas (1
ms) y se llena en lotes: 25 lotes de 500.000 claves, el más largo de 1,6 s, 35 s en total, y una lectura cada 50 ms durante todo
ese tiempo no esperó nunca más de 1 ms. Treinta y cinco segundos de trabajo en lugar de once de tabla cerrada: es más lento, y nadie
lo nota.

> 🩻 **Esto sí funciona igual** en los dos motores: un bloqueo de fila se suelta al terminar la transacción, un ciclo de esperas se
> detecta y se rompe abortando a uno, y un cambio de esquema necesita la tabla para él solo aunque sea un instante.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

**MySQL detecta el *deadlock* en el acto**, cuando se pide la espera que cierra el ciclo, sin el segundo de Postgres, y aborta a
una de las dos: InnoDB elige la que menos trabajo deshace; aquí, b (`deadlock_mysql.race`:
`b3 ✗ 1213 Deadlock found when trying to get lock; try restarting transaction`). Y deshace la transacción entera.

**El tiempo de espera de MySQL deshace la sentencia, no la transacción.** Con `innodb_lock_wait_timeout = 1`
(`lock_wait_timeout_mysql.race`), b anota un pago, intenta tocar el deudor que a tiene bloqueado, recibe el error, y confirma:

```text
 b3  INSERT 1                              b anota el pago
 b4  ⏳ espera un bloqueo
   ↳ b4  ✗ 1205 Lock wait timeout exceeded; try restarting transaction
 b5  1 fila  (1)                           el pago sigue en la transacción
 b6  COMMIT
comprobación: 1 fila  (1)                  y quedó confirmado, sin el cambio de saldo
```

El mensaje dice "restarting transaction", pero con `innodb_rollback_on_timeout` apagado, como viene, la transacción sigue viva con
la mitad del trabajo. Una aplicación que confirma después de atrapar el 1205 deja un pago sin su saldo. En Postgres, cualquier
error deja la transacción abortada: el `COMMIT` siguiente se convierte en `ROLLBACK`.

**`SKIP LOCKED` necesita un índice en MySQL.** La planilla de la Fase 15, en MySQL, con el estado en la fila y `FOR UPDATE SKIP
LOCKED`: sin un índice que sirva al `ORDER BY`, InnoDB bloquea **cada fila que recorre**, no solo la que devuelve. El técnico a
recorrió la tabla entera para encontrar la primera libre y la dejó bloqueada; el técnico b las saltó todas y no recibió ninguna
muestra. Con un índice `(taken_by, collected_at, specimen_id)`, a bloquea una y b toma la siguiente. En Postgres, el mismo `FOR
UPDATE` bloquea solo las filas que devuelve, con o sin índice. La decisión que cambia: en MySQL, una cola con `SKIP LOCKED` sin su
índice no reparte trabajo, lo serializa.

**El *metadata lock* forma la misma cola, con otro nombre, y espera un año.** En MySQL, cualquier sentencia sobre una tabla toma un
*metadata lock* compartido hasta el final de su transacción, y el DDL necesita uno exclusivo, aunque sea `ALGORITHM=INSTANT`
(`ddl_queue_mysql.race`):

```text
 b1  ⏳ espera un bloqueo                  ALTER TABLE … ADD COLUMN …, ALGORITHM=INSTANT
 c1  ⏳ espera un bloqueo                  SELECT de un deudor
 d1  2 filas  (10257, Waiting for table metadata lock, ALTER TABLE staging.ddl_target ADD COLUMN reviewed),
              (10258, Waiting for table metadata lock, SELECT balance FROM staging.ddl_target WHERE debto)
```

`lock_wait_timeout`, el límite de esa espera, viene en **31.536.000 segundos**: un año. Con 1 segundo en la sesión del `ALTER`, se
rinde con el mismo 1205 y la cola sigue (`ddl_lock_timeout_mysql.race`). El DDL en línea de MySQL dice de antemano qué puede
hacer sin copiar: pedirle un algoritmo que no corresponde falla antes de tocar nada,

```text
ERROR 1846 (0A000) at line 1: ALGORITHM=INPLACE is not supported. Reason: Cannot change column type INPLACE. Try ALGORITHM=COPY.
```

y eso es mejor que Postgres, que no tiene forma de pedir "solo si no reescribe": hay que saber cuáles reescriben (la tabla de la
sección 5.4) o probarlo en una copia.

> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: en Oracle, la cola de `ddl_queue.race` no se forma. La lectura abierta no
> retiene ningún bloqueo de tabla (las consultas de Oracle no lo toman), así que el `ALTER TABLE … ADD` termina enseguida; y si
> la transacción abierta hubiera modificado una fila, el `ALTER` no esperaría, sino que fallaría en el acto con `ORA-00054`, porque
> `DDL_LOCK_TIMEOUT` vale 0 por defecto. El *deadlock* de `deadlock.race` termina en `ORA-00060: deadlock detected while waiting for
> resource` para una de las dos, que conserva el resto de su transacción. Condiciones: `staging.hemogram` en el esquema de la
> aplicación, tres sesiones de `sqlplus` ([`a03`](a03-clis-de-los-motores.md#️-oracle--sqlplus)) con los pasos de `ddl_queue.race`
> (una vez con la lectura abierta y otra con un `UPDATE` sin confirmar) y de `deadlock.race`. El mecanismo, en la documentación oficial de los bloqueos DDL y DML de Oracle. 📝 No
> publicamos números de Oracle; el porqué está en [`a09`](a09-licencias-publicacion-y-riesgo.md).

---

## 🪞 7. Tu instinto dice… y la apuesta

**Tu instinto dice** que un `ALTER TABLE` que agrega una columna sin reescribir nada es inofensivo: tarda dos milisegundos, y
dos milisegundos de bloqueo no los nota nadie.

> 🪞 **Apuesta antes de ejecutar** (escrita el 30/09/2026, al diseñar esta fase). *"Un `ALTER TABLE` que espera detrás de una
> lectura larga bloquea a todas las sesiones nuevas, aunque él mismo tarde milisegundos."*
> **Resultado:** **ganada.** `ten_am.py` abre la exportación sobre `staging.result_ddl`, lanza `ADD COLUMN … DEFAULT false` (2 ms
> cuando consigue el bloqueo), y manda una lectura de un resultado cada 100 ms durante 3 s. **Las 30 lecturas quedaron en la cola
> hasta que la exportación terminó**: 21 esperaron más de un segundo, la mediana fue 1,63 s y la peor, 3,06 s, la duración entera
> de la exportación. El `ALTER` terminó a los 3,3 s, de los cuales trabajó 2 ms.

En la máquina del curso, la exportación duró 3 segundos porque así la programó el script. La de Alameda dura desde las 22:00 hasta
las 9:40.

---

## 💥 8. El punto de rotura

**El *deadlock* detectado, y el tiempo de espera de MySQL, con sus mensajes.** Los dos de la sección 5.2 y la 6:

```text
ERROR:  deadlock detected                                                              (Postgres, 40P01, después de deadlock_timeout)
ERROR 1213 (40001) at line 1: Deadlock found when trying to get lock; try restarting transaction   (MySQL, en el acto)
ERROR 1205 (HY000) at line 1: Lock wait timeout exceeded; try restarting transaction               (MySQL, solo la sentencia)
```

El primero y el segundo se reintentan enteros, como un error de serialización de la Fase 15. El tercero no se puede reintentar
igual: la transacción sigue abierta, y lo correcto es deshacerla a mano antes de volver a empezar.

---

## ⚰️ 9. Autopsia: el `ALTER TABLE` de las diez de la mañana

Un escenario, declarado como tal: la historia de Alameda no lo cuenta. Es la historia típica de los equipos que se fueron de una
base relacional "porque un `ALTER TABLE` bloqueó producción", y la que el sistema nuevo va a escuchar el día que haya que
agregarle una columna a los resultados.

**1. La decisión.** *"Agregamos `loaded_at` a los resultados, con la hora de carga por defecto, a las diez, que hay poca gente."*
`ALTER TABLE … ADD COLUMN loaded_at timestamptz DEFAULT clock_timestamp()`.

**2. Por qué era razonable.** En desarrollo, sobre una tabla chica, tardó un instante. A las diez la carga es baja. Y "agregar una
columna" suena a la operación más inocente que hay.

**3. Qué pasó después.** La exportación de la noche todavía estaba abierta. `ten_am.py` lo reproduce con 30 lecturas en 3 s de
exportación:

| `ALTER` | Lecturas que esperaron más de 1 s | Mediana | La peor | El `ALTER` |
|---|---|---|---|---|
| volátil, sin `lock_timeout` (las diez de la mañana) | **30 de 30** | 11,59 s | 13,02 s | 13,3 s (12,1 en la validación) |
| volátil, con `lock_timeout` de 1 s y reintento | 2 de 30 | 0,30 s | 9,71 s | 12,8 s, en 3 intentos |
| constante, con `lock_timeout` de 1 s y reintento | **0 de 30** | 0,21 s | 0,98 s | 3,3 s, en 3 intentos |

Primero la cola: nadie lee mientras la exportación siga. Después la reescritura: 10 segundos más con la tabla cerrada. Con la
exportación de verdad, la cola dura hasta las 9:40 y la reescritura de los 140 millones de filas de Alameda, diez veces más que la
de M. La pantalla de resultados se congela, alguien mata procesos al azar, y en la reunión de la tarde se dice que "el relacional
no escala".

**4. Cuánto cuesta salir.** Dos cosas, y ninguna es cambiar de motor. `SET lock_timeout = '1s'` en la sesión que corre el DDL, con
un reintento: el `ALTER` se pone en la cola un segundo como máximo, y si no consigue el bloqueo se va y deja pasar a los demás. Y
un `ALTER` que no reescriba: la columna con un valor constante (o sin valor, llenada después en lotes) se agrega en 2 ms.

**5. Qué lo habría cambiado.** Preguntar qué bloqueo toma el cambio y qué hay abierto en la base antes de correrlo:
`pg_stat_activity` ordenada por `xact_start`, la misma consulta que la Fase 17 usa para encontrar la exportación.

**Antes y después, con números:** 30 de 30 lecturas detenidas más de un segundo, la peor 13,02 s, contra 0 de 30 y la peor 0,98 s.

---

## 📖 10. Traducción

| Concepto | Access / T-SQL | Postgres | MySQL | Oracle |
|---|---|---|---|---|
| quién bloquea a quién | `sys.dm_exec_requests.blocking_session_id` | `pg_blocking_pids(pid)` | `performance_schema.data_lock_waits` | `V$SESSION.BLOCKING_SESSION` |
| los bloqueos vigentes | `sys.dm_tran_locks` | `pg_locks` | `performance_schema.data_locks`, `metadata_locks` | `V$LOCK` |
| no esperar | `SET LOCK_TIMEOUT 0` | `NOWAIT`, `lock_timeout` | `NOWAIT`, `innodb_lock_wait_timeout` | `NOWAIT`, `WAIT n` |
| saltar lo bloqueado | `WITH (READPAST)` | `SKIP LOCKED` | `SKIP LOCKED` | `SKIP LOCKED` |
| el error de *deadlock* | 1205 | `40P01` | 1213 | `ORA-00060` |
| límite para el DDL | `WAIT_AT_LOW_PRIORITY` | `lock_timeout` | `lock_wait_timeout` | `DDL_LOCK_TIMEOUT` |
| índice sin bloquear escrituras | `ONLINE = ON` (Enterprise) | `CREATE INDEX CONCURRENTLY` | `ALGORITHM=INPLACE, LOCK=NONE` | `CREATE INDEX … ONLINE` |
| el registro bloqueado de Access | "registro bloqueado por otro usuario" | `55P03` | 1205 | `ORA-00054` |

Hacia la NoSQL Lite: en MongoDB, una escritura que choca con una transacción abierta sobre el mismo documento espera o falla con
un `WriteConflict`, y los cambios de índice se construyen en línea; lo que no existe es el `ALTER TABLE`, porque no hay esquema que
alterar, y ese es exactamente el argumento de la autopsia. El diccionario completo está en [`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo el DDL en línea no alcanza

**Cuándo alcanza.** Agregar una columna sin valor o con uno constante, agrandar un `varchar`, crear un índice con
`CONCURRENTLY`: milisegundos con la tabla cerrada, siempre que el bloqueo se consiga. Con `lock_timeout` y reintento, el riesgo de
la cola desaparece (0 de 30 lecturas detenidas en la autopsia).

**Cuándo no alcanza.** Cuando el cambio reescribe la tabla: un tipo distinto, un valor volátil, una columna que pasa a `NOT NULL`
sobre datos que hay que revisar. Ahí ningún `lock_timeout` ayuda, porque cuando el `ALTER` consigue el bloqueo lo retiene lo que
dure reescribir (9 a 11 s en M, más de cien en la escala de Alameda). Ese cambio se hace en pasos que nunca cierran la tabla:
columna nueva, escritura en las dos, copia en lotes, cambio de lectura, borrado de la vieja. Es *expand/contract*, y es la [Fase 25](25-la-migracion-sin-parar.md).

**Cuándo no bloquear nada.** Cuando lo que se protege es el tiempo de un humano: un formulario, una revisión, un carrito. La
escritura optimista con `version` no espera ni pisa (sección 5.1); el bloqueo de fila, en cambio, demoró la actualización perdida
sin evitarla.

**Lo que no se mide aquí:** `gh-ost` y `pt-online-schema-change` en MySQL, `pg_repack` en Postgres, el DDL de Oracle (apuesta), y
los bloqueos en réplicas.

Las cinco preguntas, para lo que enseñó esta fase:

- **Frontera transaccional:** un bloqueo dura lo que la transacción; si la transacción abarca a un humano, el bloqueo también.
- **Consultas conocidas:** el DDL es una consulta conocida de antemano; se puede saber qué bloqueo toma y qué hay abierto antes
  de correrla.
- **Unidad de lectura:** un `SELECT` de una fila toma un bloqueo de la tabla entera, y por eso queda en la cola del `ALTER`.
- **Saltos:** dos filas en distinto orden son dos saltos que se cruzan: el *deadlock*.
- **Exactitud o parecido:** el formulario necesita saber si alguien cambió la fila, no impedirlo: `version` basta.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **`ERROR: deadlock detected` (`40P01`).** 🩺 El `DETAIL` nombra los dos procesos y las transacciones; el registro del servidor,
  las consultas. Ordena los bloqueos de las dos rutas de código de la misma forma.
- **`ERROR: canceling statement due to lock timeout` (`55P03`).** 🩺 La sesión tiene `lock_timeout`, y alguien retiene lo que
  pide: `pg_stat_activity` con `pg_blocking_pids`.
- **`ERROR: could not obtain lock on row in relation "…"` (`55P03`).** 🩺 Un `NOWAIT` que encontró la fila tomada.
- **`ERROR 1205 (HY000): Lock wait timeout exceeded`.** 🩺 En MySQL, la transacción **sigue abierta**: haz `ROLLBACK` antes de
  reintentar, o pon `innodb_rollback_on_timeout`.
- **Todas las consultas de una tabla esperan, y ninguna escribe.** 🩺 Un DDL en la cola: `pg_locks` con un `AccessExclusiveLock`
  sin conceder; en MySQL, `processlist` con `Waiting for table metadata lock`.
- **`ERROR 1846 (0A000): ALGORITHM=INPLACE is not supported`.** 🩺 El cambio necesita copiar la tabla; el mensaje dice por qué y
  qué algoritmo sí sirve.
- **`CREATE INDEX CONCURRENTLY` terminó con error y dejó un índice `INVALID`.** 🩺 `\d` lo muestra así: bórralo con `DROP INDEX
  CONCURRENTLY` y vuelve a crearlo.

---

## 📋 13. Checklist de validación

```text
[ ] lunch_form.race: b espera a a, pg_blocking_pids lo dice, y b pisa la corrección de a
[ ] lunch_form_timeout.race: 55P03 por lock_timeout y por NOWAIT
[ ] optimistic.race: a recibe UPDATE 0 y nadie espera
[ ] deadlock.race y deadlock_mysql.race: 40P01 en Postgres, 1213 en MySQL
[ ] lock_wait_timeout_mysql.race: 1205, y el pago confirmado sin su saldo
[ ] ddl_queue.race: c espera detrás del ALTER, con pg_locks mostrando la cola
[ ] ddl_rewrite.py: dos ALTER reescriben (9 a 11 s), tres no (1 a 3 ms)
[ ] ten_am.py: 30 de 30 lecturas detenidas sin lock_timeout, 0 de 30 con él y un ALTER que no reescribe
[ ] boss/afternoon.py: los cinco criterios, primero en rojo
```

---

## 🧪 14. Ejercicios (26)

Los escenarios se corren desde `src/` después de `18-bloqueos-deadlocks-y-ddl/01_setup.sql`:
`uv run lab race -f 18-bloqueos-deadlocks-y-ddl/<escenario>.race` y `uv run python 18-bloqueos-deadlocks-y-ddl/<script>.py`.

## 🟢 Fácil — ver las esperas (1–8)

### 🟢 Ejercicio 1 — El almuerzo

Corre `lunch_form.race`.

**Objetivo:** quién espera a quién según `pg_blocking_pids`, y el valor final del hematocrito.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-1)

### 🟢 Ejercicio 2 — No esperar

Corre `lunch_form_timeout.race`.

**Objetivo:** los dos mensajes `55P03` y en qué se diferencian.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-2)

### 🟢 Ejercicio 3 — La escritura optimista

Corre `optimistic.race`.

**Objetivo:** las filas que actualiza cada uno, y el valor y la versión finales.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-3)

### 🟢 Ejercicio 4 — El *deadlock* en los dos motores

Corre `deadlock.race` y `deadlock_mysql.race`.

**Objetivo:** quién falla en cada motor, y cuándo.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-4)

### 🟢 Ejercicio 5 — La cola

Corre `ddl_queue.race`.

**Objetivo:** las tres filas de `pg_locks` explicadas una por una.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-5)

### 🟢 Ejercicio 6 — El *metadata lock*

Corre `ddl_queue_mysql.race`.

**Objetivo:** el estado de las dos sesiones en espera, y el valor de `lock_wait_timeout`.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-6)

### 🟢 Ejercicio 7 — Qué reescribe

Corre `ddl_rewrite.py`.

**Objetivo:** la tabla de la sección 5.4.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-7)

### 🟢 Ejercicio 8 — El 1205 que no deshace

Corre `lock_wait_timeout_mysql.race`.

**Objetivo:** qué quedó confirmado, y por qué.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-8)

## 🟡 Intermedio — elegir la salida (9–15)

### 🟡 Ejercicio 9 — El orden que evita el *deadlock*

Reescribe `deadlock.race` para que las dos sesiones actualicen los hemogramas en el mismo orden, y córrelo.

**Objetivo:** b espera a a, y nadie falla.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-9)

### 🟡 Ejercicio 10 — Un *deadlock* con una sola fila

Provoca un *deadlock* con dos sesiones que leen la misma fila con `FOR SHARE` y después la actualizan.

**Objetivo:** el error, y por qué dos lecturas compartidas alcanzan.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-10)

### 🟡 Ejercicio 11 — `lock_timeout` para el DDL

Corre `ddl_lock_timeout.race` y `ddl_lock_timeout_mysql.race`.

**Objetivo:** cuándo se rinde el `ALTER` en cada motor, y cuándo pasa c.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-11)

### 🟡 Ejercicio 12 — `INSTANT`, `INPLACE` y `COPY`

En MySQL, sobre `staging.ddl_target`, prueba agregar una columna y cambiar el tipo de `balance` con cada algoritmo.

**Objetivo:** cuál acepta cada cambio, y el mensaje de los que no.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-12)

### 🟡 Ejercicio 13 — `CREATE INDEX CONCURRENTLY`

Repite la última parte de `ddl_rewrite.py` y explica la diferencia de tiempos.

**Objetivo:** el tiempo de la construcción y la espera de la escritura en cada caso.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-13)

### 🟡 Ejercicio 14 — `NOT NULL` sin reescribir

Agrega a `staging.result_ddl` una restricción `CHECK (value_text IS NOT NULL OR value_numeric IS NOT NULL OR sample_flag IS NOT
NULL)` primero `NOT VALID` y después con `VALIDATE CONSTRAINT`; y lo mismo con `CHECK (recorded_at >= '1996-01-01')`.

**Objetivo:** el resultado, el tiempo y el bloqueo de cada paso, y qué dice la primera sobre los datos.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-14)

### 🟡 Ejercicio 15 — La autopsia

Corre `ten_am.py`.

**Objetivo:** las cuatro filas de la medición, y qué cambia entre cada una.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-15)

## 🟠 Difícil — diagnosticar (16–21)

### 🟠 Ejercicio 16 — El árbol de esperas

Escribe una consulta que muestre, para cada sesión que espera, la cadena entera hasta la sesión que no espera a nadie.

**Objetivo:** la consulta, probada con la cola de `ddl_queue.race`.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-16)

### 🟠 Ejercicio 17 — El *deadlock* en el registro

Configura `log_lock_waits` y busca en el registro del servidor las consultas del *deadlock* de `deadlock.race`.

**Objetivo:** las líneas del registro, y qué agregan al mensaje del cliente.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-17)

### 🟠 Ejercicio 18 — `SKIP LOCKED` en MySQL

Escribe en MySQL la toma de muestras de la Fase 15 con el estado en la fila y `SKIP LOCKED`, y córrela con `lab race`.

**Objetivo:** dos técnicos con muestras distintas, sin esperar.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-18)

### 🟠 Ejercicio 19 — El 1205 bien manejado

Escribe en Python el manejo correcto de un 1205: qué se deshace, qué se reintenta y cuántas veces.

**Objetivo:** el código, probado con `lock_wait_timeout_mysql.race` como escenario.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-19)

### 🟠 Ejercicio 20 — Un formulario optimista de verdad

Escribe en Python el formulario de hemograma optimista: abre, muestra, espera, guarda o avisa con el valor nuevo.

**Objetivo:** el código, con las dos ramas probadas.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-20)

### 🟠 Ejercicio 21 — El `ALTER` en lotes

Agrega `loaded_at` a `staging.result_ddl` sin reescribir la tabla en un solo bloqueo: la columna sin valor y después llenada en
lotes.

**Objetivo:** el tiempo con `ACCESS EXCLUSIVE` y el de cada lote, y la espera de una lectura durante los lotes.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-21)

## 🔴 Muy difícil — decidir (22–26)

### 🔴 Ejercicio 22 — Oracle

Resuelve en tu máquina la apuesta 🪞🔒 de la sección 6.

**Objetivo:** el resultado explicado con la documentación de Oracle, sin publicar ningún número.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-22)

### 🔴 Ejercicio 23 — La regla del DDL de Alameda

Escribe el procedimiento que sigue cualquiera que cambie el esquema de la base nueva: qué revisa antes, con qué límites corre, y
qué cambios no se hacen así.

**Objetivo:** el procedimiento, con la medición que sostiene cada paso.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-23)

### 🔴 Ejercicio 24 — Los límites por rol

Decide qué `lock_timeout`, `statement_timeout` e `idle_in_transaction_session_timeout` lleva cada rol de Alameda (la caja, el
laboratorio, la exportación, el que cambia el esquema).

**Objetivo:** la tabla de valores, con el porqué de cada uno.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-24)

### 🔴 Ejercicio 25 — "Nos fuimos a Mongo"

Escribe la respuesta, de una página, a un equipo que propone migrar porque un `ALTER TABLE` bloqueó producción.

**Objetivo:** la respuesta, con las mediciones de esta fase y lo que Mongo sí resuelve.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-25)

### 🔴 Ejercicio 26 — Bloqueo pesimista u optimista

Para cada escritura de Alameda que este bloque midió (el folio, la muestra, el hemograma, el contador, la marca de llamado), elige
bloqueo pesimista, optimista o ninguno.

**Objetivo:** la tabla, con el criterio y la medición de cada elección.

[Solución](soluciones/18-bloqueos-deadlocks-y-ddl.md#ejercicio-26)

---

## 📚 15. Referencias

**Documentación oficial**

- **Bloqueos explícitos en Postgres 18** — https://www.postgresql.org/docs/18/explicit-locking.html — los modos de tabla, su
  matriz de conflictos y los *deadlocks*.
- **`ALTER TABLE`** — https://www.postgresql.org/docs/18/sql-altertable.html — qué formas reescriben la tabla y qué bloqueo toma
  cada una.
- **`CREATE INDEX` y `CONCURRENTLY`** — https://www.postgresql.org/docs/18/sql-createindex.html
- **`lock_timeout` y `deadlock_timeout`** — https://www.postgresql.org/docs/18/runtime-config-client.html y
  https://www.postgresql.org/docs/18/runtime-config-locks.html
- **Bloqueos de InnoDB y *deadlocks*** — https://dev.mysql.com/doc/refman/9.7/en/innodb-locking.html y
  https://dev.mysql.com/doc/refman/9.7/en/innodb-deadlocks.html
- **DDL en línea de MySQL 9.7** — https://dev.mysql.com/doc/refman/9.7/en/innodb-online-ddl-operations.html
- **El *metadata lock*** — https://dev.mysql.com/doc/refman/9.7/en/metadata-locking.html
- **`ORA-00060`** — https://docs.oracle.com/en/error-help/db/ora-00060/

**Papers y libros**

- **Martin Kleppmann y Chris Riccomini, *Designing Data-Intensive Applications*, 2.ª ed., O'Reilly, 2026** — los capítulos de
  transacciones y de evolución de esquemas.
- **Darl Kuhn y Thomas Kyte, *Expert Oracle Database Architecture*, 4.ª ed., Apress, 2021** — el capítulo de bloqueos, para la
  apuesta de Oracle. Cubre Oracle 21c, no 23ai.

**Orden de lectura sugerido:** la página de bloqueos explícitos de Postgres antes de la sección 5.3; la de `ALTER TABLE` antes de
la 5.4; la del *metadata lock* antes de la sección 6.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 14/10/2026.

---

## 🏁 16. Resultado de la fase

```text
EL ALMUERZO
  FOR UPDATE              b espera todo el almuerzo, y después pisa la corrección de a
  lock_timeout · NOWAIT   55P03 al segundo · 55P03 en el acto
  optimista               UPDATE 0 para el que llega tarde; nadie espera
DEADLOCK
  postgres                40P01 después de deadlock_timeout (1 s), para el que esperaba antes
  mysql                   1213 en el acto · 1205 deshace solo la sentencia
LA COLA DEL DDL
  ADD COLUMN constante    2 ms de trabajo · 30 de 30 lecturas detenidas mientras la exportación siguió abierta
  reescrituras            volátil 11,2 s · integer a bigint 10,2 s
  con lock_timeout        0 de 30 lecturas detenidas más de 1 s
```

### 💀 Boss del Bloque III — Una tarde de julio

> *"Julio de 2015, la primera tarde de la factura electrónica: dos cajas sacaron el mismo número y la caja quedó trabada con
> cuarenta pacientes en la sala. Lo arreglé con `UltimoNumero` y bajó a uno por mes, y en la pandemia volvió. En la pandemia,
> además, dos técnicos procesaron la misma PCR y otra se nos venció, y el formulario de hemogramas lo sigue dejando abierto alguien a la hora
> del almuerzo desde que existe. Quiero una tarde de julio que salga bien con el sistema nuevo: tres cajas, cuatro técnicos y el
> formulario, a la vez. Y no me digas que el problema es la base: decime qué comando muestra cada cosa, qué cambiaste, y cómo sé
> que no vuelve. Si sale mal, el que se queda once semanas seguidas soy yo, otra vez."*
>
> — **Matías Ledesma**, el de sistemas del laboratorio

**El sistema roto.** `src/18-bloqueos-deadlocks-y-ddl/boss/` trae la tarde entera. `01_july.sql` arma el estado de partida en
`staging` (la numeración de 2015, la planilla de pendientes sin restricción y los hemogramas del día); `tills.py` es el código de la
tarde, como está, y el único archivo que se arregla; `afternoon.py` corre la tarde y la mide, y no se edita. Tres cajas emiten 450
comprobantes contra el organismo simulado de la [Fase 16](16-el-folio-sin-huecos.md), cuatro técnicos toman 200 muestras y cargan su
hemograma, y al segundo alguien abre el formulario de hemogramas y se va diez segundos a almorzar. Con el código de partida, la
tarde termina así:

```text
  comprobantes autorizados: 450 de 450 · rechazos 10016: 73
  muestras tomadas: 58 distintas · tomadas dos veces o más: 53
  la espera más larga: 10.00 s, en load_hemogram
  la transacción más larga: 10.0 s ( SELECT h.specimen_id, h.hematocrit FROM staging.july_hemogr)
  el formulario: guardado · su corrección no está en la base
```

Los rechazos cambian entre corridas (entre 46 y 102 en cinco); los cinco criterios, no.

**Lo que se entrega:**

1. **El diagnóstico de cada síntoma, con su comando**: el que muestra los rechazos, las muestras dobles, quién espera a quién, la
   transacción que retiene, y la corrección perdida (Fases 15 a 18).
2. **El arreglo mínimo** en `tills.py` (las firmas no cambian) y, si hace falta, en la base: una restricción, un índice, un ajuste.
   El formulario tiene que seguir abriendo los hemogramas del día y guardando su corrección, o avisar que alguien la cambió antes;
   perderla en silencio no vale. El organismo es el de la Fase 16, sin tocar.
3. **La medición de que no vuelve**: `afternoon.py` con los cinco criterios en verde, dos corridas seguidas.

**Criterios de aceptación** (los imprime `afternoon.py`):

- ningún rechazo 10016, y los 450 comprobantes autorizados;
- ninguna muestra tomada dos veces, y las 200 tomadas;
- ninguna caja ni técnico esperó más de 2 s;
- ninguna transacción estuvo abierta más de 2 s;
- el formulario guardó su corrección o avisó del conflicto, y nadie vio un error.

La solución de referencia no se publica: es un encargo, no un ejercicio.

> 🏆 **"Un martes", opcional.** Si vas armando la base nueva de Alameda bloque a bloque, el Bloque III te deja cómo escribe: el folio
> se numera al autorizar, la planilla se toma con `SKIP LOCKED` y el estado en la fila, los formularios guardan con versión, las
> marcas son eventos, y el DDL corre con `lock_timeout`. La facturación de un martes ya puede correr en tres cajas; el Bloque IV
> trae lo que pasa cuando alguien propone guardar todo eso como documentos.

> **La señal de que quedó bien:** *"Ante una espera, encuentro al culpable en dos consultas; mis bloqueos no abarcan a un humano;
> y no corro un `ALTER` sin saber qué bloqueo toma, qué hay abierto y cuánto voy a esperar."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-18-bloqueos-deadlocks-y-ddl -m "F18 cerrada: el formulario del almuerzo, los deadlocks en dos motores, la cola detrás del ALTER, lo que reescribe cada cambio, y el boss III"
> ```
>
> Commits de la fase con prefijo `f18:`, los de ejercicio `f18 ej26: …`.
