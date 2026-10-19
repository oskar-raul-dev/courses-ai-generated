# ✅ Soluciones — SQL Server 03: Query Store y *parameter sniffing*

> **Curso:** Ruta SQL · Solucionario de [ss03](../ss03-query-store-y-parameter-sniffing.md)
> **Ejercicios:** 22 · **Perfil:** M (la base `ss03`: los protocolos desde 2025 y sus resultados) · **Motores:** SQL Server 2025 CU9
> `mcr.microsoft.com/mssql/server@sha256:2b5b58162112…` (emulado), y Postgres `pgvector/pgvector@sha256:2358fcba361e…` para el contraste
> **Fecha de verificación ejecutada:** 18/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

> 🔒 **Lo que este solucionario no trae.** Las lecturas, los tiempos y los conteos de ejecución de SQL Server. Trae la estructura de los
> planes, los atributos del XML que dicen cómo se compilaron, los mensajes y el estado de Query Store, y todo lo de Postgres
> ([`a09`](../a09-licencias-publicacion-y-riesgo.md#-qué-sí-se-publica-de-oracle-y-de-sql-server)).

Los scripts se corren desde `src/` (los `.py`) o desde `src/ss03-query-store-y-parameter-sniffing/` (los `.sql`), después de
`01_setup.sql`.

---

## 🟢 Fácil (1–7)

### Ejercicio 1

La salida de la sección 4. El operador de acceso a `ResultadoItem` es lo que separa los dos planes: **`Index Scan`** sobre
`IX_ResultadoItem_IdProtocolo` cuando el plan se compiló para el central (lee el índice entero y lo cruza por *hash* con los protocolos de
la sede), e **`Index Seek`** sobre el mismo índice cuando se compiló para V (busca los resultados de cada protocolo, uno por uno, dentro
de un *nested loops*). Es el mismo índice con dos usos opuestos.

### Ejercicio 2

```sql
SELECT DB_NAME() AS base, actual_state_desc, query_capture_mode_desc, max_storage_size_mb FROM sys.database_query_store_options;
```

```text
ss03     READ_WRITE  ALL   1000
ALAMEDA  READ_WRITE  AUTO  1000
```

Encendido en las dos, con 1.000 MB reservados. `ALAMEDA` lo tiene sin que el script de SSMS lo pida porque la base se creó en SQL Server
2025, y la documentación dice que desde 2022 Query Store viene encendido en toda base nueva. La de `ss03` está en `ALL` porque
`01_setup.sql` la cambió. La base real de Alameda, creada en 2008 R2, probablemente lo tenga **apagado**: Query Store no existía, y una
base restaurada conserva sus opciones. Es otra pregunta para Verónica.

### Ejercicio 3

```sql
SELECT q.query_id, p.plan_id, p.is_forced_plan, p.query_plan
FROM sys.query_store_query AS q JOIN sys.query_store_plan AS p ON p.query_id = q.query_id
WHERE q.object_id = OBJECT_ID('dbo.resultados_por_sede')
ORDER BY p.plan_id;
```

`query_plan` es el XML del plan, y `sqlserver.plan_lines(xml)` lo reduce a operadores y objetos. La consulta del procedimiento es una sola
(`query_id` 1 en una base recién limpiada) con dos planes, el del *nested loops* y el del *hash join*, como imprime `03_query_store.py`.
Query Store identifica la consulta por su texto y su contexto, no por el plan: por eso dos planes distintos son de la misma consulta, y
por eso se puede forzar uno.

### Ejercicio 4

En el XML del plan de la caché, cada parámetro trae el valor con que se compiló:

```text
<ColumnReference Column="@desde" … ParameterCompiledValue="'2026-09-01'" />
<ColumnReference Column="@sede" … ParameterCompiledValue="N'C'" />
```

`ParameterCompiledValue` es la evidencia del *sniffing*: el plan que usa el centro V dice, adentro, que se compiló para `N'C'`. En el plan
real de una ejecución (`SET STATISTICS XML ON`) aparece además `ParameterRuntimeValue`, el valor de esa ejecución, y la diferencia entre
los dos es el diagnóstico en una línea.

### Ejercicio 5

- `resultados_por_sede`: sin opciones, cada sede compila su plan (aquí cada `SHOWPLAN` compila de nuevo); en producción, el primero se
  queda.
- `OPTIMIZE FOR (@sede = N'C')`: el plan se compila siempre como si la sede fuera el central, cualquiera sea el valor: las dos reciben el
  *hash join*.
- `OPTIMIZE FOR UNKNOWN`: se estima con la densidad de `Sede`, el promedio de todas las sedes en toda la tabla, sin mirar el valor; es el
  plan genérico de Postgres, y aquí también elige el *hash join*.
- `OPTION (RECOMPILE)`: se compila en cada ejecución con el valor real; cada sede recibe el suyo, y cada ejecución paga una compilación.

### Ejercicio 6

```text
Msg 308, Level 16, State 1, Server a07be756749e, Line 1
Index 'protocol_hint_fecha_idx' on table 'dbo.protocol_hint' (specified in the FROM clause) does not exist.
```

El *hint* de tabla **hace fallar la consulta**: nadie puede ignorar un error. El plan forzado del mismo script hace lo contrario: la
consulta corre con otro plan, y el fallo queda en `last_force_failure_reason_desc = NO_INDEX` de `sys.query_store_plan`, donde solo lo ve
quien lo busca. Es la misma diferencia que la Fase 13 encontró en MySQL entre `FORCE INDEX` (error 1176) y el *optimizer hint* (un aviso).

### Ejercicio 7

```sql
-- postgres
SELECT p."Sede", count(DISTINCT p."IdProtocolo") AS protocolos, count(r."IdItem") AS resultados
FROM legacy."Protocolos" AS p LEFT JOIN legacy."ResultadoItem" AS r USING ("IdProtocolo")
WHERE p."Fecha" >= '2026-09-01' GROUP BY 1 ORDER BY 1;
```

```text
 Sede | protocolos | resultados
------+------------+------------
 A    |       2823 |      29570
 C    |      10255 |     109434
 J    |       2674 |      28204
 R    |       2784 |      29919
 V    |       2626 |      28044
```

El central tiene 3,9 veces los protocolos de V y 3,9 veces sus resultados: unos once resultados por protocolo en todas las sedes. La
proporción que decide el plan es la de los protocolos de la sede contra el total de resultados que hay que tocar. El *hash join* recorre
los 3,66 millones de resultados de `ss03` igual para cualquier sede; el *nested loops* toca solo los de la sede, y paga una búsqueda por
protocolo.

---

## 🟡 Intermedio (8–13)

### Ejercicio 8

```sql
-- sqlserver, con el plan_id del hash join que dio 03_query_store.py
EXEC sp_query_store_force_plan @query_id = 1, @plan_id = 2;
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
EXEC dbo.resultados_por_sede @sede = N'V', @desde = '2026-09-01';
-- el plan de la caché (ejercicio 4) tiene Hash Match (Inner Join) e Index Scan sobre ResultadoItem
EXEC sp_query_store_unforce_plan @query_id = 1, @plan_id = 2;
```

V compila con la caché vacía, y el optimizador, que para V elige el *nested loops*, usa el *hash join* forzado. Forzar no es "preferir":
el plan se usa aunque el optimizador habría elegido otro, mientras se pueda aplicar.

### Ejercicio 9

```sql
EXEC sp_query_store_set_hints @query_id = 1, @query_hints = N'OPTION (OPTIMIZE FOR (@sede = N''V''))';
```

El central compila como si fuera V: el *nested loops* con `Index Seek`. La pista puede nombrar `@sede` porque Query Store la aplica a la
**sentencia** del procedimiento, que es donde existe el parámetro; es lo mismo que escribir la opción al final del `SELECT`, sin
escribirla. `sp_query_store_clear_hints @query_id = 1` la quita.

### Ejercicio 10

```text
nivel 170: CardinalityEstimationModelVersion="170"
nivel 100: CardinalityEstimationModelVersion="70"
```

El estimador de nivel 100 es el de antes de 2014 (el "70" es de SQL Server 7.0, de donde viene). En las corridas de esta verificación,
dos seguidas dieron en nivel 100 el mismo *sniffing* que en nivel 170: el plan depende del orden. La primera corrida, recién creada la
base, había dado el *nested loops* para el central en los dos órdenes, y no se repitió después de reconstruir el índice de
`ResultadoItem`.

**Rúbrica.** Una respuesta correcta da los dos valores del atributo, dice cuántas corridas hizo y qué dio cada una, y si alguna vez el
nivel 100 dio el mismo plan en los dos órdenes, busca la diferencia en el estado de las estadísticas (`STATS_DATE`, el
`modification_counter` de `sys.dm_db_stats_properties`) entre esa corrida y las otras. Queda invalidada si afirma que un nivel "es mejor"
para esta consulta sin medir.

### Ejercicio 11

**Predicción y resultado (estructura):** con `LEGACY_CARDINALITY_ESTIMATION = ON` en nivel 170, el plan dice
`CardinalityEstimationModelVersion="70"` y el central recibe el *hash join*, como en nivel 100. Lo que se gana respecto de bajar el nivel:
el resto del comportamiento de 170 que no es del estimador sigue disponible (lo que la documentación del nivel de compatibilidad lista
para cada nivel), y solo cambia la estimación. Lo que se pierde: las correcciones del estimador nuevo para toda la base, no solo
para esta consulta. Si el problema es una consulta, la pista `USE HINT ('FORCE_LEGACY_CARDINALITY_ESTIMATION')` en Query Store es más
precisa.

### Ejercicio 12

```text
antes: nested loops · Index Seek on ResultadoItem.IX_ResultadoItem_IdProtocolo
después de UPDATE STATISTICS dbo.Protocolos y una ejecución para C: hash join · Index Scan on ResultadoItem.IX_ResultadoItem_IdProtocolo
```

Actualizar las estadísticas de una tabla invalida los planes que la usan, y la siguiente ejecución recompila con **su** valor. Si el
mantenimiento nocturno actualiza estadísticas a las 3 y la primera ejecución del día es la del central a las 7, el plan del día es el del
central; si un día la primera es la de un centro, el plan del día es otro. Es la causa de los reportes que "a veces" andan lentos: el
motor no cambió de opinión, cambió quién llegó primero.

### Ejercicio 13

```sql
-- postgres
SELECT count(*) AS protocolos_e, max("Fecha") AS ultimo_e,
       (SELECT count(*) FROM legacy."Protocolos"
         WHERE "Fecha" > (SELECT max("Fecha") FROM legacy."Protocolos" WHERE "Sede" = 'E')) AS posteriores
FROM legacy."Protocolos" WHERE "Sede" = 'E';
```

```text
 protocolos_e |      ultimo_e       | posteriores
--------------+---------------------+-------------
        80918 | 2022-12-31 00:00:00 |      690909
```

Hay 690.909 protocolos posteriores al último de `E`: el *hint* por fecha tiene que recorrerlos todos, hacia atrás, antes de encontrar el
primero de `E`, y después unos pocos más para llegar a 50. Las 691.136 entradas de MySQL en la Fase 13 son esas 690.909 más las del 31 de
diciembre de 2022 que recorre hasta juntar 50. La cuenta sale de la caja, sin medir ningún motor.

---

## 🟠 Difícil (14–19)

### Ejercicio 14

**Solución.** Se resuelve con `02_sniffing.py --private`. Lo que hay que explicar con la estructura: con el plan del central, V paga
recorrer el índice entero de `ResultadoItem` (`Index Scan`), que es lo mismo para cualquier sede, así que sus lecturas tienen que parecerse
a las del central; con su propio plan, paga solo las búsquedas de sus 2.626 protocolos. Si la relación entre las dos cifras de V es mayor
que tres, la apuesta se ganó. Y la otra mitad: con el plan de V, el central hace 10.255 búsquedas, y puede leer más que con su *hash
join*. No publiques los números.

### Ejercicio 15

**Estructura (se publica):**

```text
con el hint                                    sin el hint
Top                                            Top
  Nested Loops (Inner Join)                      Index Seek on protocol_hint.protocol_hint_sede_fecha_idx   (hacia atrás)
    Index Scan on protocol_hint.protocol_hint_fecha_idx   (hacia atrás)
    Clustered Index Seek on protocol_hint.PK_protocol_hint
```

Con el *hint*, el motor recorre el índice por fecha desde el final y, por cada entrada, va a la clave agrupada a leer la sede, porque el
índice por fecha no la tiene; descarta las que no son `E` hasta juntar 50. Sin el *hint*, un solo `Index Seek` en `(Sede, Fecha)` va al
final de las de `E` y lee 50. La predicción para las lecturas es del orden de las 690.909 entradas del ejercicio 13 más una búsqueda en la
clave por cada una, contra unas pocas páginas sin el *hint*. Compáralo en tu máquina con `--private`; no publiques los números.

### Ejercicio 16

**Solución.** `06_psp.sql` enciende una sesión de eventos con `parameter_sensitive_plan_optimization_skipped_reason` y
`query_with_parameter_sensitivity`, ejecuta el procedimiento y lee el `ring_buffer`. La lista completa de motivos posibles sale de
`sys.dm_xe_map_values` (`psp_skipped_reason_enum`). Si el motivo no es de sesgo, la documentación da otras condiciones que lo frenan:
PSP solo trabaja con predicados de **igualdad** (aquí hay uno, `Sede = @sede`, y uno de rango, `Fecha >= @desde`); no opera sobre
consultas con `RECOMPILE`; se apaga si el *sniffing* está apagado (`PARAMETER_SNIFFING = OFF` o la pista
`DISABLE_PARAMETER_SNIFFING`); y la consulta tiene que ser cacheable. No publiques el motivo; explícalo con la documentación.

### Ejercicio 17

**Solución de referencia.** Doscientos mil protocolos más del central (dos `INSERT … SELECT TOP (100000)` con `IdProtocolo` desde
2.000.000.000, para no chocar con la identidad) dejan al central con unas nueve veces los protocolos de un centro. Después de `UPDATE
STATISTICS … WITH FULLSCAN`, la prueba es si `sys.query_store_query_variant` tiene filas y si `sys.query_store_plan` muestra planes con
`plan_type_desc` de *dispatcher* o de variante. Al terminar, `DELETE FROM dbo.Protocolos WHERE IdProtocolo >= 2000000000` y estadísticas
otra vez.

**Rúbrica.** Una respuesta correcta cuenta qué encontró sin publicar números de SQL Server, y si no hay variantes, lo explica con el
motivo del evento del ejercicio 16 en lugar de concluir que PSP "no funciona".

### Ejercicio 18

**Solución.** `ALTER DATABASE ss03 SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON)`, y `sys.database_automatic_tuning_options` confirma
`desired_state_desc` y `actual_state_desc` en `ON`. La regresión se provoca con muchas ejecuciones del central con su plan, la caché
vaciada, una ejecución de V (que deja su plan) y muchas del central con el plan de V. `sys.dm_db_tuning_recommendations` es donde aparece
la recomendación, con su detalle en JSON. En el laboratorio puede no aparecer: la página de ajuste automático explica que compara el plan
nuevo con el anterior por su uso de CPU, con suficientes ejecuciones de cada uno, y una regresión que se nota en lecturas puede no
notarse en CPU con estos tamaños. Al terminar, la opción se apaga. Y una advertencia para Alameda: la tabla de ediciones de SQL Server 2025 marca *Automatic tuning*
solo para Enterprise. En la Standard de 2026 no existe, y el laboratorio lo tiene porque es Enterprise Developer.

**Rúbrica.** Enciende y apaga la opción, provoca la regresión, consulta la vista, y explica con la documentación por qué hay o no hay
recomendación.

### Ejercicio 19

```sql
-- postgres, como superusuario
CREATE ROLE ss03_reporte LOGIN BYPASSRLS;   -- BYPASSRLS: alameda.result tiene la seguridad por fila de la Fase 23
GRANT USAGE ON SCHEMA staging, alameda TO ss03_reporte;
GRANT SELECT ON staging.order_site, alameda.result TO ss03_reporte;
ALTER ROLE ss03_reporte SET plan_cache_mode = force_custom_plan;
-- y, conectado como ss03_reporte: cinco EXECUTE by_site('C') y un EXPLAIN (ANALYZE, BUFFERS) EXECUTE by_site('V')
```

```text
 current_user |  plan_cache_mode
 ss03_reporte | force_custom_plan
…
 ->  Nested Loop (actual rows=14022.00 loops=2)
       ->  Parallel Bitmap Heap Scan on order_site o …
       ->  Index Scan using result_lab_order_id_idx on result r (actual rows=10.68 loops=2626)
   Buffers: shared hit=9257 read=1609
 generic_plans | custom_plans
             0 |            6
```

La sede V recibe su *nested loop* en la sexta ejecución, con 10.866 bloques, los mismos 10.865 de la Fase 13 con su plan propio, y cero
planes genéricos. El alcance es distinto del de la pista de Query Store: `ALTER ROLE … SET` vale para **todas** las consultas de ese rol, y
desde su próxima conexión; la pista vale para **una** consulta, para cualquiera que la ejecute, desde la próxima compilación. Postgres
apunta al usuario, SQL Server a la consulta. Sin `BYPASSRLS`, el rol no ve ninguna fila de `alameda.result` (el plan dice `One-Time
Filter: false`): la política de la Fase 23 no lo conoce. Al terminar, `REVOKE` y `DROP ROLE`.

---

## 🔴 Muy difícil (20–22) — rúbrica

### Ejercicio 20

*Subir el nivel de ALAMEDA.*

**Rúbrica (sobre 5 puntos):** 1 punto por encender Query Store primero, en `READ_WRITE` y con espacio suficiente, si la base vieja lo
tiene apagado; 1 por el período de captura con el nivel viejo, que cubra al menos un cierre de mes y un martes de facturación; 1 por el
cambio de nivel en una ventana, y la comparación por consulta (*Regressed queries* en SSMS, o `sys.query_store_runtime_stats` antes y
después); 1 por qué se hace con cada regresión (forzar el plan viejo, con fecha de revisión, o una pista
`FORCE_LEGACY_CARDINALITY_ESTIMATION` para esa consulta); 1 por la vuelta atrás: el nivel se baja con un `ALTER`, y los forzados quedan.

### Ejercicio 21

*La política de planes forzados.*

**Rúbrica (sobre 4 puntos):** 1 punto por el orden de preferencia (el índice o la consulta correctos primero; la pista después; el plan
forzado al final); 1 por la medición y la fecha de revisión de cada forzado, en un lugar que se versiona; 1 por la alerta sobre
`force_failure_count > 0` y `last_force_failure_reason_desc`; 1 por lo que pasa al migrar: los forzados y las pistas **no migran**, y cada
uno es una pregunta sobre una consulta que en Postgres va a necesitar su propia respuesta.

### Ejercicio 22

*Lo que Postgres no tiene.*

**Rúbrica (sobre 4 puntos):** 1 punto por lo que se pierde (el historial de planes en el motor, el forzado sin desplegar, las pistas por
consulta, la corrección automática); 1 por lo que lo reemplaza (`pg_stat_statements` para el costo, `auto_explain` para los planes en el
registro, `pg_store_plans` y `pg_hint_plan` como extensiones, con lo que cuesta operarlas); 1 por lo que no hace falta: Postgres planifica
cinco veces con el valor antes de considerar un genérico, y en la Fase 13 la sede V solo heredó el plan del central cuando las cinco
primeras eran del central (M-21); 1 por la conclusión honesta: para Alameda, con pocas consultas sensibles y bien conocidas, la pérdida es
chica y se cubre con `plan_cache_mode` por rol; para una base con miles de consultas de un ORM, Query Store es una razón seria para
quedarse.

---

## 🔥 Opcionales

### Ejercicio 🔥 1

**Rúbrica.** La variante con `WHERE (p.Sede = @sede OR @sede IS NULL)`, la página *optional parameter optimization* de la documentación
(OPPO, nivel 170, la configuración `OPTIONAL_PARAMETER_OPTIMIZATION` de la base, que `sys.database_scoped_configurations` muestra
encendida), y dos ejecuciones, una con sede y otra con NULL. La respuesta dice si `sys.query_store_query_variant` registra variantes y qué
`plan_type_desc` tienen los planes, sin publicar números. La documentación describe OPPO como construido sobre la misma infraestructura de
varios planes que PSP.
