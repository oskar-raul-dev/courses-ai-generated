# 🪟 SQL Server 02 — Pesimista contra RCSI: el lector que espera, la base que guarda versiones, y lo que cada una le cobra a Alameda

> **Curso:** Ruta SQL · Track SQL Server · ss02 de ss05 · **8 h** · opcional
> **Motor:** SQL Server 2025 CU9 (17.0.5005.3), Enterprise Developer, `mcr.microsoft.com/mssql/server@sha256:2b5b58162112…` · emulado en Apple Silicon
> **Entorno de ejecución:** SQL (T-SQL) + Python, con `lab race`
> **Requisito del camino base:** Fase 18 · **Requisito del track:** [ss01](ss01-la-base-en-su-motor-original.md) (la caja cargada y su `sqlcmd.sh`)
> **El dolor de Alameda:** el formulario abierto a la hora del almuerzo ([historia](00-historia-de-alameda.md), 2005), que desde 2011 también frena a quien solo quiere leer
> **Fecha de verificación ejecutada:** 18/10/2026
> **Objetivo:** reproducir con `lab race` las anomalías de la Fase 15 y los bloqueos de la Fase 18 en el motor original, decidir entre `READ COMMITTED` con bloqueos, RCSI y `SNAPSHOT` para cada caso de Alameda, y saber qué cuesta el *version store*.

---

## 🧭 1. Dónde estamos

La [Fase 15](15-aislamiento-comparado.md) comparó niveles de aislamiento entre Postgres y MySQL, y la
[Fase 18](18-bloqueos-deadlocks-y-ddl.md) persiguió las esperas. Las dos terminaban con una línea para SQL Server en la tabla de
traducción: `READ COMMITTED` con bloqueos, `SNAPSHOT` si la base lo permite, `1205` y `3960` como errores. Esta fase llena esa línea.

En 2005 el problema era Access: el archivo compartido bloqueaba el registro que un formulario editaba, y *"alguien deja el
formulario de hemograma abierto a la hora del almuerzo y nadie más puede cargar"*. En 2011 los datos pasaron a SQL Server, y el
problema cambió de forma sin desaparecer. Cualquier transacción que deje una fila modificada sin confirmar frena, además, a quien
solo quiere **leerla**: el reporte de Matías, la consulta de la recepcionista, el proceso que arma la exportación de las 9:40. En
Postgres eso no pasa nunca, porque Postgres guarda versiones de fila desde siempre. SQL Server también puede, desde 2005, pero
viene apagado.

> 📝 **La regla del track, otra vez.** De SQL Server no se publica ningún resultado: ni quién esperó, ni cuánto, ni cuánto ocupa el
> *version store* ([`a09`](a09-licencias-publicacion-y-riesgo.md#-sql-server-la-cláusula-tal-cual)). Cada carrera de SQL Server de
> esta fase va como apuesta, con la predicción que hace la documentación de Microsoft y el comando para verla en tu máquina. Las de
> Postgres se publican, con su salida. Los mensajes de error se publican siempre.

---

## 🎯 2. Objetivos de esta fase

1. Reproducir el formulario del almuerzo en SQL Server, ver al lector bloqueado en `sys.dm_exec_requests` y desbloquearlo con RCSI.
2. Correr las cuatro anomalías de la Fase 15 que cambian de motor a motor (lectura sucia, actualización perdida, *write skew*,
   *deadlock*) en los niveles de SQL Server, y predecir cada resultado con la documentación antes de correrlo.
3. Distinguir `READ_COMMITTED_SNAPSHOT` (cada sentencia ve lo último confirmado) de `SNAPSHOT` (toda la transacción ve una foto), y
   leer los errores 3960 y 1205.
4. Explicar dónde vive el *version store*, qué le agrega a cada fila y qué lo hace crecer, contra las versiones dentro de la tabla de
   Postgres que midió la [Fase 17](17-mvcc-y-su-factura.md).
5. Decidir qué opción enciende Alameda en su base de 2026, y qué cuesta encenderla.

---

## 🚫 3. Qué NO entra todavía

- **El plan de la consulta del reporte y por qué cambia según el parámetro** → [ss03](ss03-query-store-y-parameter-sniffing.md).
- **El *version store* de las tablas temporales**, que es otra cosa (la historia de cada fila, a propósito) →
  [ss04](ss04-clustered-newsequentialid-y-temporales.md).
- ***Optimized locking*** (SQL Server 2025, con ADR): se nombra en la sección 6 y se explora en el ejercicio 🔥 1, no se mide.
- **Los bloqueos del DDL**, que la Fase 18 midió en Postgres: en SQL Server son otra fase que el track no tiene.

---

## 🏚️ 4. El dolor, en la caja

`01_setup.sql` arma una base aparte, `ss02`, con tres tablas copiadas de `ALAMEDA`: los 29.241 hemogramas de 1997 a 2008 (los mismos
de la Fase 18), las 1.115 muestras `EN PROCESO` de la planilla de la Fase 15 y los 4.329 deudores de la caja. Va aparte porque las
opciones de versiones son **de toda la base**, y `ALAMEDA` tiene que quedar como la dejó el script de SSMS.

La escena, en Postgres, para tener el punto de partida con números. `lunch_form_reader_pg.race` corre sobre `staging.hemogram` de
la Fase 18: a corrige el hematocrito del hemograma 1 y no confirma (se fue a almorzar), b es el reporte que lo lee, c cuenta quién
espera un bloqueo:

```text
🏁 lab race · postgres · permutación a1 a2 b1 c1 a3
 a1  BEGIN
 a2  UPDATE 1
 b1  1 fila  (41)
 c1  1 fila  (0)
 a3  COMMIT
comprobación: 1 fila  (40, 1)
```

El reporte lee `41`, el último valor confirmado, sin esperar a nadie. Nadie espera un bloqueo (`0`). Cuando a confirma, el valor pasa
a `40`. Es MVCC haciendo lo que la Fase 17 explicó: el `UPDATE` de a escribió una versión nueva de la fila, y la vieja sigue ahí para
quien la necesite.

La misma escena en SQL Server es `lunch_form_reader.race`, con la base como la dejó SSMS:

```bash
uv run --extra sqlserver lab race -f ss02-pesimista-contra-rcsi/lunch_form_reader.race
```

La documentación de Microsoft dice qué tiene que pasar. En la guía de bloqueos y versiones de filas: *"When the
`READ_COMMITTED_SNAPSHOT` database option is set `OFF`, which is the default setting in SQL Server and Azure SQL Managed Instance,
`READ COMMITTED` isolation uses shared locks to prevent other transactions from modifying rows while the current transaction is running
a read operation."* Para leer la fila, b necesita un bloqueo compartido (`S`), y a tiene uno exclusivo (`X`) hasta que confirme. Si la
documentación tiene razón, b espera lo que dure el almuerzo, c lo ve en `sys.dm_exec_requests` con un `wait_type` de la familia
`LCK_M_S` y un `blocking_session_id` que apunta a a, y el reporte devuelve `40` recién cuando a confirma. Es la primera apuesta de la
sección 7.

> 🏚️ **De la historia:** en 2011, después de la migración, *"la respuesta oficial durante dos años fue 'la base está lenta'"*. Un
> lector que espera a un escritor no gasta CPU ni disco: no hace nada. Para quien mira el servidor, la base está tranquila; para la
> recepcionista, la pantalla está congelada.

---

## 🧩 5. Tres maneras de leer

### 5.1 `READ COMMITTED` con bloqueos: el nivel de fábrica

Es el nivel por defecto del motor y la base lo trae así. Cada lectura pide un bloqueo compartido sobre lo que lee y lo suelta al
terminar de leerlo, no al final de la transacción. Dos consecuencias. Un lector **espera** a cualquier escritor que tenga la fila
tomada, que es la escena de la sección 4. Y un escritor espera a un lector solo mientras el lector está leyendo esa fila, que suele
ser poco. Postgres no tiene este nivel: su `READ COMMITTED` siempre lee versiones.

> 🩻 **Esto sí funciona igual.** Dos escritores sobre la misma fila se esperan en los dos motores, con RCSI o sin él: lo que la Fase
> 18 mostró con `lunch_form.race` no cambia de motor. Las versiones de fila resuelven lectores contra escritores, nunca escritores
> contra escritores.

### 5.2 `READ_COMMITTED_SNAPSHOT`: el mismo nivel, otra implementación

Es una opción de la base, no un nivel nuevo:

```sql
ALTER DATABASE ss02 SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE;
```

Con RCSI encendido, **cada sentencia** de una transacción `READ COMMITTED` lee la última versión confirmada al empezar la sentencia,
sin pedir bloqueos compartidos. Es lo que hace Postgres. La aplicación no cambia una línea: el reporte sigue pidiendo `READ
COMMITTED`, y ahora no espera. `lunch_form_reader_rcsi.race` es la misma escena con la opción encendida; la documentación predice que b
lee `41` sin esperar y que c no encuentra a nadie bloqueado.

El `WITH ROLLBACK IMMEDIATE` no es decorativo. La documentación de `ALTER DATABASE` pide que no haya otras conexiones activas en la base
para cambiar la opción. Sin ese modificador, el `ALTER` espera a que se vayan todas, y en la base de un laboratorio con treinta PC no
se van solas. Con él, deshace las transacciones abiertas y las saca. En producción se hace en una ventana.

### 5.3 `SNAPSHOT`: la foto de toda la transacción

`ALLOW_SNAPSHOT_ISOLATION` es otra opción de la base, y habilita un nivel que la aplicación tiene que pedir:

```sql
ALTER DATABASE ss02 SET ALLOW_SNAPSHOT_ISOLATION ON;      -- 02_snapshot.sql
SET TRANSACTION ISOLATION LEVEL SNAPSHOT; BEGIN TRAN; …
```

Con `SNAPSHOT`, **toda la transacción** lee la foto del momento en que empezó, como el `REPEATABLE READ` de Postgres. Y si intenta
modificar una fila que otra transacción cambió y confirmó después de su foto, el motor la termina:

```text
✗ 3960 Snapshot isolation transaction aborted due to update conflict. You cannot use snapshot isolation to access table 'dbo.debtor'
directly or indirectly in database 'ss02' to update, delete, or insert the row that has been modified or deleted by another
transaction. Retry the transaction or change the isolation level for the update/delete statement.
```

Es el `40001 could not serialize access due to concurrent update` de Postgres en `REPEATABLE READ`, con más palabras. La guía de
Microsoft lo dice así: *"The update conflict is handled by the Database Engine and there's no way to disable the update conflict
detection."* Y agrega lo que separa a RCSI de `SNAPSHOT`: con RCSI no hay detección de conflictos. Un `UPDATE` en RCSI vuelve a leer la
fila de verdad, con bloqueo de actualización, antes de escribir.

| | Lee | Ve cambios ajenos en la transacción | Conflicto al escribir | Se enciende |
|---|---|---|---|---|
| `READ COMMITTED` (bloqueos) | la fila, con bloqueo `S` | sí | espera | de fábrica |
| `READ COMMITTED` con RCSI | la última versión confirmada, por sentencia | sí | espera; sin error | opción de la base |
| `SNAPSHOT` | la foto del inicio de la transacción | no | 3960 | opción de la base + nivel en la sesión |
| `SERIALIZABLE` | la fila, con bloqueos de rango | no | espera o 1205 | nivel en la sesión |

### 5.4 El *version store* y la marca de 14 bytes

Las versiones de fila tienen que vivir en algún lado. La guía lo dice en una frase: *"If accelerated database recovery (ADR) is
enabled on a database, the version store is created in that database. Otherwise, the version store is created in the `tempdb`
database."* ADR viene apagado en SQL Server (`02_snapshot.sql` muestra `is_accelerated_database_recovery_on = 0`), así que las
versiones de `ss02` van a `tempdb`, que es **de toda la instancia**: una lectura larga en una base hace crecer un archivo que comparten
todas.

Además, cada fila guarda la marca de su versión: *"Each database row might use up to 14 bytes at the end of the row for row versioning
information"*, agregados la primera vez que la fila se modifica con alguna opción de versiones encendida. Y la misma página advierte
lo que eso cuesta: *"Adding the row versioning information can cause index page splits"*. Una tabla de filas cortas puede crecer más
del 14 % que da el ejemplo de la documentación.

`03_version_store.py` abre una lectura `SNAPSHOT`, corrige tres veces los 29.241 hemogramas desde otra sesión y mira el *version store*
(`sys.dm_tran_version_store_space_usage`) y el tamaño de la tabla antes, con la lectura abierta y al cerrarla. Imprime todo bajo `🔒
PRIVADO`. Lo que hace con esos números es la tercera apuesta.

> 💡 **Dónde paga cada motor.** Postgres deja la versión vieja **en la tabla** y la limpia `VACUUM`; con una lectura abierta, la Fase
> 17 midió una fila contador que pasó de 1 a 45 páginas con 10.000 actualizaciones, y `VACUUM` no pudo devolver nada hasta que la
> lectura terminó ([M-31](bitacora-de-medicion.md#m-31--f17--la-lectura-abierta-y-la-media-hora-más-cargada-de-la-caja)). SQL Server
> con RCSI deja la versión vieja **en `tempdb`**, y la tabla paga solo la marca. La lectura larga cuesta lo mismo en los dos; cambia
> quién recibe la factura.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

Contra Postgres, cuatro cosas cambian una decisión. La **primera** es el nivel de fábrica: Postgres nunca hace esperar a un lector, y
SQL Server lo hace hasta que alguien enciende RCSI. Un sistema que nace en Postgres no tiene la pregunta; uno que migra **desde** SQL
Server tiene que buscar el código que contaba con que el lector esperara, y lo hay (sección 9).

La **segunda** es `SERIALIZABLE`. En Postgres es SSI: deja correr a todos y aborta con `40001` al que formaría un ciclo, como midió la
Fase 15 con el *write skew*. En SQL Server son **bloqueos de rango** sobre el índice: *"Key-range locks protect a range of rows
implicitly included in a record set being read by a Transact-SQL statement while using the `SERIALIZABLE` transaction isolation
level."* Las dos transacciones que miran la misma muestra libre se bloquean entre sí al insertar, y el motor elige una víctima. La
predicción es un 1205 en lugar de un 40001 (segunda apuesta).

La **tercera** es la lectura sucia. Postgres acepta `READ UNCOMMITTED` y lo trata como `READ COMMITTED`: no hay forma de leer lo que
otro no confirmó. SQL Server sí la tiene, y con una pista de tabla que se escribe en cualquier consulta: `WITH (NOLOCK)` es
`READUNCOMMITTED` para esa tabla. `dirty_read.race` corre la escena de la Fase 15 en ese nivel. La documentación de las pistas de tabla
dice que con `NOLOCK` se pueden leer cambios que después se deshacen; en Alameda, un saldo que una caja descontó y después anuló.

La **cuarta** es nueva en 2025: ***optimized locking***, que con ADR encendido hace que un `UPDATE` en RCSI elija las filas sobre la
última versión confirmada sin bloquearlas, y bloquee solo las que va a modificar. Cambia cuántas esperas hay entre escritores, no la
lógica de las anomalías. Postgres no tiene un equivalente porque nunca tuvo el problema de origen.

| Anomalía (Fase 15) | Postgres, publicado ([M-27](bitacora-de-medicion.md#m-27--f15--la-muestra-tomada-dos-veces-en-cuatro-niveles-y-dos-motores)) | SQL Server, apuesta 🔒 |
|---|---|---|
| lectura sucia, `READ UNCOMMITTED` | no pasa (es `READ COMMITTED`) | pasa |
| actualización perdida, `READ COMMITTED` | pasa (23,00 en vez de 13,00) | pasa: b espera a a y después escribe encima |
| actualización perdida, `REPEATABLE READ` | `40001` | 1205: los dos retienen `S` y piden `X` |
| actualización perdida, `SNAPSHOT` | — (es el `REPEATABLE READ` de arriba) | 3960 para b |
| *write skew*, foto de la transacción | pasa en `REPEATABLE READ` | pasa en `SNAPSHOT` |
| *write skew*, `SERIALIZABLE` | `40001` en el `COMMIT` de b | 1205 en el `INSERT` de uno |
| *deadlock* de la Fase 18 | `40P01 deadlock detected` | 1205 |

---

## 🪞 7. Tu instinto dice… y la apuesta

*"SQL Server es un motor serio; si el reporte lee mientras alguien corrige, lee lo confirmado y sigue, como en cualquier base
moderna."* Es el instinto de quien viene de Postgres, o de Oracle, y es razonable: es lo que hacen los dos desde siempre.

> 🪞🔒 **Apuesta sin resolver: SQL Server.** Hipótesis: con la base como la dejó SSMS, en `lunch_form_reader.race` el reporte (b)
> **espera** al formulario sin confirmar (a), c lo encuentra en `sys.dm_exec_requests` con un `wait_type` `LCK_M_S` y el
> `blocking_session_id` de a, y b devuelve `40` recién cuando a confirma. Con `lunch_form_reader_rcsi.race`, b lee `41` sin esperar y c
> no encuentra a nadie. Condiciones: la base `ss02` de `01_setup.sql`. Resuélvela: las dos carreras, con `uv run --extra sqlserver lab
> race -f …` desde `src/`. El mecanismo, en la guía de bloqueos y versiones de filas (en las referencias). 📝 No publicamos el resultado:
> la licencia de SQL Server Developer no permite divulgar resultados de pruebas sin permiso de Microsoft
> ([`a09`](a09-licencias-publicacion-y-riesgo.md#-sql-server-la-cláusula-tal-cual)).

> 🪞🔒 **Apuesta sin resolver: SQL Server.** Hipótesis: la columna de la derecha de la tabla de la sección 6, fila por fila. En
> particular, `write_skew.race --isolation serializable` termina con un 1205 en el `INSERT` de una de las dos y **una sola toma** (con
> `--patience 10`: el monitor de bloqueos puede tardar más que la paciencia de fábrica, E-102 en [`a08`](a08-catalogo-de-errores.md)), y
> `lost_update.race --isolation repeatable-read` termina con un 1205 en lugar de un error de serialización. Resuélvela: `write_skew.race`
> con `--isolation read-committed`, `snapshot` y `serializable`; `lost_update.race` con `read-committed`, `repeatable-read` y
> `snapshot`; `dirty_read.race` y `deadlock.race` (`snapshot` necesita `02_snapshot.sql` antes).

> 🪞🔒 **Apuesta sin resolver: SQL Server.** Hipótesis: con la lectura `SNAPSHOT` abierta y los hemogramas corregidos tres veces, el
> *version store* de `ss02` en `tempdb` crece a varios megabytes y vuelve a cero en uno o dos minutos después de cerrar la lectura;
> `dbo.hemogram` **también crece**, por la marca de 14 bytes y por las páginas que se parten al agrandarse las filas, y no vuelve a su
> tamaño al cerrar la lectura. Resuélvela: `uv run --extra sqlserver python ss02-pesimista-contra-rcsi/03_version_store.py` desde
> `src/`, después de `02_snapshot.sql`.

**Resultado:** sin publicar. Lo que cambia la decisión según lo que veas: si la primera se gana, el "la base está lenta" de 2011 tenía
una parte que ningún índice iba a arreglar; si la tercera se gana, encender RCSI le agrega una factura de espacio a la tabla, una vez, y
otra a `tempdb`, que vuelve sola.

---

## 💥 8. El punto de rotura

El *deadlock* tiene un detalle que rompe aplicaciones que lo manejan bien en otros motores. En Postgres, la víctima de un `40P01`
queda con su transacción abortada: todo lo que mande hasta el `ROLLBACK` falla con `25P02 current transaction is aborted`, y la
aplicación sabe que tiene que deshacer. En SQL Server, el motor **deshace la transacción de la víctima** al elegirla. La sesión queda sin transacción abierta, y el `COMMIT` que la aplicación manda después no tiene nada que
confirmar:

```text
✗ 1205 Transaction (Process ID 76) was deadlocked on lock resources with another process and has been chosen as the deadlock victim.
Rerun the transaction.
✗ 3902 The COMMIT TRANSACTION request has no corresponding BEGIN TRANSACTION.
```

Son los dos mensajes de la víctima en `write_skew.race --isolation serializable`, el del `INSERT` y el del `COMMIT` que sigue; cuál de
las dos sesiones resulta víctima no se publica. La guía lo dice así: el motor *"terminates the current batch being executed for the
thread, rolls back the transaction of the deadlock victim, and returns error 1205 to the application"*.
Una aplicación que atrapa el 1205, lo registra y sigue con el `COMMIT` recibe un 3902, y si además el código siguiente estaba dentro de
la misma "transacción" en la cabeza de quien lo escribió, **corre en modo *autocommit***: cada sentencia se confirma sola, fuera de toda
transacción. Las carreras de esta fase escriben `IF @@TRANCOUNT > 0 COMMIT` por eso.

**Qué hay que cambiar para salir:** tratar el 1205 como el 40001 de Postgres, una transacción que hay que **reintentar entera**
desde el `BEGIN TRAN`. Y después de cualquier error, preguntar `@@TRANCOUNT` (o `XACT_STATE()`) antes de seguir. `SET XACT_ABORT ON`
hace que cualquier error de una sentencia deshaga la transacción entera, que es el comportamiento que un desarrollador de Postgres
espera. Los dos mensajes van a [`a08`](a08-catalogo-de-errores.md) como E-79 y E-80.

---

## ⚰️ 9. Autopsia: el reporte que contaba con esperar

**La decisión, en la voz de Matías, 2016:** *"El cierre de caja del día lo saca un reporte a las 20. Si una caja está cobrando todavía,
el reporte espera a que termine, y el número sale bien. No hace falta nada más."*

**Por qué era razonable.** Con `READ COMMITTED` de bloqueos, el reporte no puede leer un cobro a medio hacer: lo espera. La espera
**era** la consistencia del cierre, y funcionó años sin que nadie la escribiera. Encender RCSI parece pura mejora: nadie espera.

**Qué pasa después.** Con RCSI, el mismo reporte no espera: lee lo último confirmado, sentencia por sentencia. Si el cierre suma los
cobros en una sentencia y los recibos en otra, y una caja confirma entre las dos, el cierre puede sumar un cobro sin su recibo. Es la
anomalía de solo lectura de la Fase 15 (`read_only.race`), que en `READ COMMITTED` de Postgres también pasa, y que en el SQL Server de
Alameda **no podía pasar** mientras el reporte esperaba. Encender RCSI sin revisar los reportes que contaban con la espera cambia sus
resultados, y no da ningún error.

**Cuánto cuesta salir.** Cada reporte que necesite una foto consistente de varias tablas pide `SNAPSHOT` (si la base lo permite) o se
escribe como una sola sentencia. Es un cambio por reporte, y la lista de reportes la tiene Matías en la cabeza.

**Qué pregunta lo habría cambiado.** *¿Qué parte de lo que este código da por cierto es una espera que nadie escribió?*

**Antes y después, con números (Postgres, Fase 15):** en `READ COMMITTED`, el informe de cierre ve el lote cerrado antes del último
cobro; en `REPEATABLE READ`, lo ve entero. En SQL Server, el mismo par es RCSI contra `SNAPSHOT`, y el ejercicio 18 lo pide.

---

## 📖 10. Traducción

| SQL Server | Postgres | Lo que cambia |
|---|---|---|
| `READ COMMITTED` (RCSI apagado) | no existe | el lector espera al escritor |
| `READ COMMITTED` con RCSI | `READ COMMITTED` | igual: foto por sentencia |
| `SNAPSHOT` | `REPEATABLE READ` | 3960 contra `40001` |
| `SERIALIZABLE` (rangos) | `SERIALIZABLE` (SSI) | espera y 1205 contra `40001` al confirmar |
| `READ UNCOMMITTED`, `WITH (NOLOCK)` | (se lee como `READ COMMITTED`) | la lectura sucia existe |
| `sys.dm_exec_requests.blocking_session_id` | `pg_blocking_pids(pid)` | — |
| `KILL spid` | `pg_terminate_backend(pid)` | no hay "cancelar la sentencia" de otro |
| *version store* en `tempdb` (o PVS con ADR) | versiones en la tabla y `VACUUM` | quién paga el espacio |
| 1205 (víctima, transacción deshecha) | `40P01` (transacción abortada) | después del error: 3902 contra `25P02` |
| `SET XACT_ABORT ON` | el comportamiento de fábrica | un error deshace la transacción |

Más en [`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**No enciendas RCSI en la base de Alameda sin la lista de reportes.** Es el cambio con mejor relación costo-beneficio de este motor
para una base con lectores y escritores mezclados, y también el que cambia resultados en silencio (sección 9). Primero la lista, después
la opción, en una ventana con `ROLLBACK IMMEDIATE`.

**No uses `SNAPSHOT` para lo que escribe sin un bucle de reintento.** El 3960 no se apaga, y una aplicación que no lo espera falla
justo cuando hay concurrencia.

**No uses `SERIALIZABLE` de SQL Server como el de Postgres.** Con bloqueos de rango, el costo es espera para todos, no un reintento
para uno. Para la muestra de la planilla, la respuesta de la Fase 15 (una restricción `UNIQUE`) sigue siendo la mejor en los dos
motores.

**No escribas `NOLOCK` para que un reporte "no moleste".** Si molesta, RCSI resuelve lo mismo leyendo lo confirmado.

**Las cinco preguntas:** el **acceso** que importa es el de lectores contra escritores sobre las mismas filas; la **consistencia** la
elige cada transacción, y la de fábrica de SQL Server la compra con esperas; la **escala** convierte cada espera en una cola; la
**evolución** de la opción es de toda la base, con un costo de espacio una vez; la **operación** suma `tempdb` a lo que hay que mirar.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **El reporte congelado sin CPU:** ninguno; la sesión espera → 🩺 `SELECT session_id, blocking_session_id, wait_type FROM
  sys.dm_exec_requests WHERE blocking_session_id <> 0` → buscar la transacción abierta del `blocking_session_id`, y decidir RCSI.
- **Víctima de *deadlock*:** `1205 … chosen as the deadlock victim` → dos transacciones que piden lo mismo en orden contrario, o dos
  lecturas que retienen `S` y después quieren escribir → reintentar la transacción entera. E-79.
- **El `COMMIT` después del 1205:** `3902 The COMMIT TRANSACTION request has no corresponding BEGIN TRANSACTION` → el motor ya deshizo
  la transacción → 🩺 `SELECT @@TRANCOUNT` da 0 → `IF @@TRANCOUNT > 0` o `XACT_STATE()`. E-80.
- **Conflicto en `SNAPSHOT`:** `3960 Snapshot isolation transaction aborted due to update conflict` → otra transacción cambió y confirmó
  la fila después de la foto → reintentar. E-81.
- **`SNAPSHOT` sin la opción de la base:** `3952 Snapshot isolation transaction failed accessing database '…' because snapshot
  isolation is not allowed in this database. Use ALTER DATABASE to allow snapshot isolation.` → falta `ALLOW_SNAPSHOT_ISOLATION ON`
  (`02_snapshot.sql`). E-82.

---

## 📋 13. Checklist de validación

```text
[ ] 01_setup.sql creó ss02 con 29.241 hemogramas, 1.115 muestras y 4.329 deudores
[ ] lunch_form_reader_pg.race da la salida de la sección 4 en tu Postgres
[ ] resolviste las tres apuestas de la sección 7 y sabes qué pasó en cada fila de la tabla de la sección 6, sin publicarlo
[ ] reconoces 1205, 3902, 3960 y 3952 por su mensaje, y sabes cuál deshace la transacción
[ ] puedes explicar dónde vive el version store de ss02 y por qué
[ ] escribiste la lista de reportes de Alameda que contaban con esperar, aunque sea con tres
[ ] dejaste ss02 con RCSI y SNAPSHOT como te los pide el ejercicio siguiente, y ALAMEDA sin tocar
```

---

## 🧪 14. Ejercicios (22)

## 🟢 Fácil — ver quién espera (1–7)

### 🟢 Ejercicio 1 — El almuerzo en Postgres

Corre `lunch_form_reader_pg.race`.

**Objetivo:** la salida coincide con la de la sección 4, y explicas por qué c cuenta cero esperas.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-1)

### 🟢 Ejercicio 2 — El almuerzo en SQL Server

Antes de correr `lunch_form_reader.race`, escribe qué va a mostrar c1.

**Objetivo:** resolver la primera apuesta en tu máquina y nombrar las tres columnas de `sys.dm_exec_requests` que identifican la
espera. No publiques la salida.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-2)

### 🟢 Ejercicio 3 — El culpable

Con la escena del ejercicio 2 en pausa (a sin confirmar), busca qué sentencia corrió por última vez la sesión que bloquea.

**Objetivo:** una consulta que una `sys.dm_exec_requests` (o `sys.dm_exec_sessions`) con `sys.dm_exec_sql_text` o
`sys.dm_exec_input_buffer`, y que dé el texto de a aunque a no esté ejecutando nada.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-3)

### 🟢 Ejercicio 4 — Las dos opciones de la base

Corre la primera consulta de `02_snapshot.sql` sobre `ss02` y sobre `ALAMEDA`.

**Pregunta:** ¿qué valen `is_read_committed_snapshot_on` y `snapshot_isolation_state_desc` en cada una, y cuál de las dos opciones
cambia lo que significa `READ COMMITTED`?

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-4)

### 🟢 Ejercicio 5 — RCSI sin cambiar una línea

Corre `lunch_form_reader_rcsi.race`.

**Objetivo:** explicar por qué el reporte no cambió ni una sentencia y aun así se comporta distinto, con la frase de la guía de
Microsoft que lo dice.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-5)

### 🟢 Ejercicio 6 — Los mensajes

Corre `deadlock.race` y `lost_update.race --isolation snapshot`.

**Objetivo:** copiar los dos mensajes de error y decir, para cada uno, si la sesión queda con la transacción abierta o no.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-6)

### 🟢 Ejercicio 7 — `SNAPSHOT` sin permiso

En una base nueva, sin `ALLOW_SNAPSHOT_ISOLATION`, abre una transacción `SNAPSHOT` y lee una tabla.

**Objetivo:** el mensaje literal del error, y la línea de `02_snapshot.sql` que lo evita.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-7)

## 🟡 Intermedio — las anomalías en el motor original (8–14)

### 🟡 Ejercicio 8 — La lectura sucia

Antes de correr `dirty_read.race`, predice qué lee b y cuál es el saldo al final.

**Objetivo:** resolver la predicción, y escribir la misma lectura con `WITH (NOLOCK)` en lugar del nivel de la sesión.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-8)

### 🟡 Ejercicio 9 — La actualización perdida, tres veces

Corre `lost_update.race` con `read-committed`, `repeatable-read` y `snapshot`.

**Objetivo:** una tabla de tres filas (nivel, qué pasó, saldo final) en tu cuaderno, contra la fila de Postgres de M-27. No la
publiques.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-9)

### 🟡 Ejercicio 10 — El saldo que sí da 13

Reescribe `lost_update.race` para que, en `READ COMMITTED` con bloqueos, el saldo final sea 13,00.

**Objetivo:** dos versiones: una con `UPDATE … SET balance = balance - 10` y otra que lee con `WITH (UPDLOCK)` antes de calcular, y
por qué las dos funcionan.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-10)

### 🟡 Ejercicio 11 — *Write skew* en `SNAPSHOT`

Corre `write_skew.race --isolation snapshot`.

**Pregunta:** antes de correrlo, ¿cuántas tomas quedan, y por qué el 3960 no salva esta vez? Compáralo con el `REPEATABLE READ` de
Postgres en M-27.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-11)

### 🟡 Ejercicio 12 — `SERIALIZABLE` con rangos

Corre `write_skew.race --isolation serializable` y, con la escena en pausa después de `a3`, mira `sys.dm_tran_locks` de las dos
sesiones.

**Objetivo:** nombrar el modo de bloqueo que retiene cada una sobre el índice de `specimen_take` y explicar con él por qué el
`INSERT` del otro espera.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-12)

### 🟡 Ejercicio 13 — La restricción de la Fase 15

Agrega `UNIQUE (specimen_id)` a `dbo.specimen_take` y corre `write_skew.race --isolation read-committed`.

**Objetivo:** el mensaje del error que recibe la segunda toma, y por qué es la mejor salida en los dos motores.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-13)

### 🟡 Ejercicio 14 — `legacy` en Postgres: el cierre de caja

En `legacy` de Postgres, busca en `Comprobantes` el día de 2026 con más comprobantes y cuántos emitió cada punto de venta ese día.
`CajaDiaria` no sirve: la caja la trae vacía.

**Objetivo:** la consulta, y una estimación razonada de cuántos cobros podrían estar a medio confirmar en el momento del cierre, para
dimensionar la anomalía de la sección 9. La caja no guarda la hora del cobro: dilo, y di qué dato pedirías.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-14)

## 🟠 Difícil — el costo de las versiones (15–19)

### 🟠 Ejercicio 15 — La tercera apuesta

Corre `03_version_store.py`.

**Objetivo:** resolver la apuesta, y explicar el tamaño de `dbo.hemogram` después de cerrar la lectura con la documentación de la marca
de 14 bytes. No publiques los números.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-15)

### 🟠 Ejercicio 16 — La misma lectura en Postgres

Reproduce `03_version_store.py` en Postgres: una transacción `REPEATABLE READ` abierta sobre `staging.hemogram` mientras otra corrige
los 29.241 hemogramas tres veces.

**Objetivo:** el tamaño de la tabla antes, con la lectura abierta y después de un `VACUUM` posterior al cierre, y la comparación de
dónde quedó la factura en cada motor.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-16)

### 🟠 Ejercicio 17 — ADR y el *version store* en la base

Enciende ADR en `ss02` (`ALTER DATABASE ss02 SET ACCELERATED_DATABASE_RECOVERY = ON`) y repite el ejercicio 15.

**Pregunta:** antes de correrlo, ¿qué vista te da ahora el tamaño de las versiones, y por qué `sys.dm_tran_version_store_space_usage`
deja de servir?

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-17)

### 🟠 Ejercicio 18 — El cierre de caja con RCSI

Escribe una carrera de dos sesiones: a cobra (un `INSERT` en recibos y un `UPDATE` en el saldo, en una transacción), b es el cierre que
suma las dos cosas en dos sentencias.

**Objetivo:** predecir y comprobar qué ve b en `READ COMMITTED` con bloqueos, con RCSI y con `SNAPSHOT`, y decir cuál es correcto para
el cierre.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-18)

### 🟠 Ejercicio 19 — El reintento

Escribe en Python, con `mssql-python`, la toma de muestra de la Fase 15 en `SNAPSHOT` con un bucle que reintente el 3960 y el 1205.

**Objetivo:** con cuatro hilos y cien tomas, cero tomas perdidas y cero duplicadas, contadas en `dbo.specimen_take`. No publiques los
reintentos ni los tiempos.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-19)

## 🔴 Muy difícil — decidir para Alameda (20–22)

### 🔴 Ejercicio 20 — Encender RCSI en ALAMEDA

Escribe el plan para encender RCSI en la base de 2026: qué se revisa antes, en qué ventana, con qué comando, qué se mira después y cómo
se vuelve atrás.

**Objetivo:** un plan de una página que Verónica pueda aprobar, con la lista de lo que cambia de comportamiento (al menos tres casos de
esta fase) y el costo en `tempdb` como pregunta medible, no como número.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-20)

### 🔴 Ejercicio 21 — `XACT_ABORT`

Un procedimiento de Matías hace tres `UPDATE` en una transacción, y el segundo falla por una restricción.

**Objetivo:** demostrar qué queda confirmado con `SET XACT_ABORT OFF` (el de fábrica) y con `ON`, y escribir la regla para el código
nuevo, con su equivalente en Postgres.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-21)

### 🔴 Ejercicio 22 — La tabla de traducción completa

La tabla de traducción de la Fase 15 tiene una columna `Access / T-SQL` que se escribió sin correr nada en SQL Server.

**Objetivo:** revisarla fila por fila contra lo que viste en esta fase, y decir qué fila corregirías y por qué, con la documentación.
No publiques resultados de SQL Server en tu respuesta.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio-22)

## 🔥 Opcionales

### 🔥 Ejercicio 🔥 1 — *Optimized locking*

Enciende ADR y `OPTIMIZED_LOCKING` en `ss02` y repite `lost_update.race` y `deadlock.race` en `READ COMMITTED` con RCSI.

**Objetivo:** decir qué cambió y qué no, con la página de *optimized locking* de la documentación, y si cambiaría el plan del
ejercicio 20.

[Solución](soluciones/ss02-pesimista-contra-rcsi.md#ejercicio--1)

---

## 📚 15. Referencias

**Documentación oficial de SQL Server 2025**

- **Guía de bloqueos y versiones de filas** — https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-transaction-locking-and-row-versioning-guide?view=sql-server-ver17
- **`SET TRANSACTION ISOLATION LEVEL`** — https://learn.microsoft.com/en-us/sql/t-sql/statements/set-transaction-isolation-level-transact-sql?view=sql-server-ver17
- **Opciones de `ALTER DATABASE SET`** (`READ_COMMITTED_SNAPSHOT`, `ALLOW_SNAPSHOT_ISOLATION`) — https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-set-options?view=sql-server-ver17
- **Pistas de tabla** (`NOLOCK`, `UPDLOCK`, `READPAST`) — https://learn.microsoft.com/en-us/sql/t-sql/queries/hints-transact-sql-table?view=sql-server-ver17
- **Guía de *deadlocks*** — https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-deadlocks-guide?view=sql-server-ver17
- **`SET XACT_ABORT`** — https://learn.microsoft.com/en-us/sql/t-sql/statements/set-xact-abort-transact-sql?view=sql-server-ver17
- ***Optimized locking*** — https://learn.microsoft.com/en-us/sql/relational-databases/performance/optimized-locking?view=sql-server-ver17
- **ADR** — https://learn.microsoft.com/en-us/sql/relational-databases/accelerated-database-recovery-concepts?view=sql-server-ver17

**Postgres, para el contraste:** *Transaction Isolation* — https://www.postgresql.org/docs/18/transaction-iso.html

**Libros:** Kalen Delaney, *SQL Server Concurrency: Locking, Blocking and Row Versioning*, Simple Talk Publishing (Redgate), 2012 —
sigue siendo la explicación más clara de los bloqueos de rango y del *version store*, aunque es anterior a ADR y a *optimized
locking*.

**Orden de lectura sugerido:** la guía de bloqueos y versiones, secciones de niveles y de versiones, antes de la sección 5; la de
*deadlocks* antes de la 8; Delaney cuando vayas a encender RCSI en una base que no es de laboratorio.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 18/10/2026, en la versión 17.x (SQL Server 2025) de la documentación.

---

## 🏁 16. Resultado de la fase

```text
PESIMISTA CONTRA RCSI · ss02 (29.241 hemogramas · 1.115 muestras · 4.329 deudores) · SQL Server 2025 CU9 · 18/10/2026
  el formulario del almuerzo   Postgres: el lector no espera (publicado) · SQL Server: 🪞🔒 con y sin RCSI
  las anomalías de la Fase 15  lectura sucia, actualización perdida, write skew, deadlock: 🪞🔒 en cada nivel
  los errores                  1205 · 3902 después del 1205 · 3960 · 3952
  el version store             en tempdb (ADR apagado) · 14 bytes por fila · 🪞🔒 cuánto y cuándo vuelve
LA DECISIÓN
  RCSI, sí, después de la lista de reportes que contaban con esperar · SNAPSHOT para las fotos de varias tablas
```

> **La señal de que quedó bien:** *"Para cada lectura de Alameda sé si hoy espera a un escritor, qué vería con RCSI y si eso le
> cambia el resultado. Y ninguna de esas tres respuestas la saqué de un número de SQL Server publicado."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a ss-fase-02-pesimista-contra-rcsi -m "ss02 cerrada: lab race en SQL Server, el lector que espera y RCSI, las anomalías de la Fase 15 en cada nivel, el version store y la decisión de encender RCSI"
> ```
>
> Commits de la fase con prefijo `ss02:`, los de ejercicio `ss02 ej19: …`.
