# 🪟 SQL Server 03 — Query Store y *parameter sniffing*: el plan que eligió la primera sede, y cómo se cambia sin tocar el código

> **Curso:** Ruta SQL · Track SQL Server · ss03 de ss05 · **8 h** · opcional
> **Motor:** SQL Server 2025 CU9 (17.0.5005.3), Enterprise Developer, `mcr.microsoft.com/mssql/server@sha256:2b5b58162112…` · emulado en Apple Silicon
> **Entorno de ejecución:** SQL (T-SQL) + Python
> **Requisito del camino base:** Fase 13 · **Requisito del track:** [ss01](ss01-la-base-en-su-motor-original.md) (la caja cargada y su `sqlcmd.sh`)
> **El dolor de Alameda:** la consulta por sede que anda bien en los centros y se arrastra en el central ([historia](00-historia-de-alameda.md), 2009 en adelante), y el *hint* de 2012 de la pantalla de cada sede
> **Fecha de verificación ejecutada:** 18/10/2026
> **Objetivo:** reproducir el *parameter sniffing* de la consulta por sede de la Fase 13, leerlo en Query Store, y elegir entre forzar un plan, una pista de Query Store y una opción en el código, sabiendo cómo se rompe cada una.

---

## 🧭 1. Dónde estamos

La [Fase 13](13-el-optimizador-en-tres-motores.md) midió en Postgres lo que pasa cuando un plan se reutiliza para un valor que no le
corresponde. Postgres planifica cada ejecución preparada con su valor las cinco primeras veces, y desde la sexta puede quedarse con un
plan genérico que no mira el valor. En la consulta por sede, si la conexión empezaba el día con el central, la sede V heredaba su *hash
join* y leía 8,1 veces más bloques ([M-21](bitacora-de-medicion.md#m-21--f13--el-plan-genérico-de-la-consulta-por-sede)).

SQL Server hace algo más simple y más brusco. Un procedimiento se compila **en su primera ejecución**, con los valores que trae esa
ejecución (*parameter sniffing*), y ese plan queda en la caché para todas las que siguen, con cualquier valor. No hay cinco planes
personalizados antes: la primera sede del día decide. A cambio, desde 2016 tiene algo que Postgres no tiene: **Query Store**, que
guarda cada plan que la consulta usó, con sus estadísticas, y deja **forzar** uno sin tocar el código.

Las sedes no cambiaron: septiembre de 2026 tiene 10.255 protocolos en el central y 2.626 en el centro V. `01_setup.sql` arma una base
aparte, `ss03`, con los 343.123 protocolos desde 2025 y sus 3.659.431 resultados, copiados de `ALAMEDA` con dos índices que la base de
Alameda no tiene: `(Sede, Fecha)` en los protocolos y `IdProtocolo` en los resultados. Aparte, porque esta fase cambia índices,
Query Store y el nivel de compatibilidad.

> 📝 **La regla del track.** De un plan de SQL Server se publica la **estructura**: los operadores y los objetos, del plan compilado,
> sin filas, costos ni lecturas ([`a09`](a09-licencias-publicacion-y-riesgo.md#-qué-sí-se-publica-de-oracle-y-de-sql-server)). Lo que
> cada plan cuesta va como apuesta, con el comando para resolverla. Los scripts de esta fase imprimen la estructura y esconden lo
> demás detrás de `--private`.

---

## 🎯 2. Objetivos de esta fase

1. Reproducir el *sniffing* de la consulta por sede: el plan que queda en la caché depende de qué sede corrió primero.
2. Encontrar la consulta y sus planes en Query Store, forzar uno y comprobar que se usa aunque la caché esté vacía.
3. Cambiar el plan sin tocar el procedimiento con una pista de Query Store, y comparar las tres salidas del código: `OPTIMIZE FOR`,
   `OPTIMIZE FOR UNKNOWN` y `RECOMPILE`.
4. Leer en el plan con qué estimador se compiló en el nivel 170 y en el 100 que conserva una base restaurada desde 2008 R2, y explicar
   qué es la optimización PSP de 2022.
5. Romper un plan forzado y un *hint* de índice borrando el índice que usan, y leer lo que dice cada uno.

---

## 🚫 3. Qué NO entra todavía

- **El *version store* y las esperas de un reporte** → [ss02](ss02-pesimista-contra-rcsi.md).
- **La clave agrupada de `ResultadoItem` como decisión de diseño** → [ss04](ss04-clustered-newsequentialid-y-temporales.md).
- **El ajuste automático (*automatic plan correction*)**, que fuerza planes por su cuenta: se nombra en la sección 6; el laboratorio
  no tiene historia suficiente para que se active.
- **Las estadísticas y el estimador de cardinalidad en detalle**: la [Fase 12](12-estadisticas-y-cardinalidad.md) los hizo en
  Postgres; aquí solo se usa la diferencia entre el estimador viejo y el nuevo.

---

## 🏚️ 4. El dolor, en la caja

La consulta de la Fase 13, escrita como la escribiría un reporte, en un procedimiento con la sede como parámetro:

```sql
-- sqlserver
CREATE OR ALTER PROCEDURE dbo.resultados_por_sede @sede nchar(1), @desde date AS
SELECT r.CodDeterminacion, COUNT(*) AS resultados
FROM dbo.Protocolos AS p JOIN dbo.ResultadoItem AS r ON r.IdProtocolo = p.IdProtocolo
WHERE p.Sede = @sede AND p.Fecha >= @desde
GROUP BY r.CodDeterminacion;
```

`02_sniffing.py` vacía la caché de planes de `ss03`, ejecuta el procedimiento cinco veces para una sede y una para la otra, y muestra el
plan que quedó en la caché. Dos corridas, que solo difieren en qué sede va primero, en el nivel de compatibilidad de una base nueva de
SQL Server 2025 (170):

```text
== nivel 170 · cinco veces la sede C, después la V
plan del procedimiento en la caché:
  Parallelism (Gather Streams)
    Compute Scalar
      Hash Match (Aggregate)
        Hash Match (Inner Join)
          Parallelism (Distribute Streams)
            Nested Loops (Inner Join)
              Compute Scalar
                Constant Scan
              Index Seek on Protocolos.IX_Protocolos_Sede_Fecha
          Index Scan on ResultadoItem.IX_ResultadoItem_IdProtocolo

== nivel 170 · cinco veces la sede V, después la C
plan del procedimiento en la caché:
  Compute Scalar
    Stream Aggregate (Aggregate)
      Sort
        Parallelism (Gather Streams)
          Hash Match (Partial Aggregate)
            Nested Loops (Inner Join)
              Parallelism (Distribute Streams)
                Nested Loops (Inner Join)
                  Compute Scalar
                    Constant Scan
                  Index Seek on Protocolos.IX_Protocolos_Sede_Fecha
              Index Seek on ResultadoItem.IX_ResultadoItem_IdProtocolo
```

Es la misma consulta, con los mismos datos y los mismos índices, y dos planes distintos. Si el día empieza en el central, el plan es
un *hash join* que **recorre entero** el índice de `ResultadoItem` (`Index Scan`), y la sede V lo hereda. Si empieza en V, es un *nested
loops* que **busca** los resultados de cada protocolo (`Index Seek`), y el central lo hereda. Es la misma bifurcación de la Fase 13, con
los mismos dos métodos, y con una diferencia que importa: en Postgres, la sede V heredaba el plan del central recién en la sexta
ejecución, y solo si las cinco primeras eran del central. Aquí lo hereda en la segunda.

> 🏚️ **De la historia:** desde 2009 hay un laboratorio central y cuatro centros de extracción, y el central concentra casi la mitad de
> los protocolos. Una consulta que se escribió y se probó en un centro chico no tiene por qué comportarse igual en el central. En SQL
> Server, además, depende de **quién la usó primero** después del último reinicio, de la última estadística actualizada o del último
> `ALTER` sobre la tabla: cualquier cosa que vacíe la caché.

---

## 🧩 5. Lo que el motor recuerda

### 5.1 *Parameter sniffing*

La guía de arquitectura del procesamiento de consultas de Microsoft lo describe así: al compilar un procedimiento o una consulta
parametrizada, el optimizador **mira los valores** de los parámetros de esa ejecución y estima con ellos, como si fueran constantes.
El plan resultante se guarda en la caché y se reutiliza mientras no haya un motivo para recompilar. Para la mayoría de las consultas es
exactamente lo que conviene: compilar cuesta, y la mayoría de los valores se parecen. Para una consulta cuyo mejor plan depende del
valor, la primera ejecución fija el plan de todas.

> 🩻 **Esto sí funciona igual.** Los dos métodos de join, el criterio con que el optimizador elige (el costo estimado a partir de las
> estadísticas) y la tensión entre planificar cada vez y reutilizar son los de la Fase 13. Cambian **cuándo** se reutiliza y **qué
> herramienta** hay para corregirlo.

### 5.2 Query Store: el historial de planes

Query Store es una opción de la base, y la documentación dice que desde SQL Server 2022 *"is now enabled by default for all newly
created databases"*. En `ss03` viene encendido, con el modo de captura `AUTO`, que deja afuera las consultas baratas o poco frecuentes;
`01_setup.sql` lo pasa a `ALL` para que el laboratorio capture todo. Guarda, por cada consulta, **cada plan que usó**, con estadísticas de
ejecución por intervalo, en tablas de la propia base: sobrevive a un reinicio, que vacía la caché.

`03_query_store.py` compila el procedimiento una vez para V y, con la caché vaciada, otra para C. Query Store guarda los dos planes de la
misma consulta:

```text
== 1. Query Store guardó la consulta 1 con estos planes:
  plan 1: nested loops · Index Seek on ResultadoItem.IX_ResultadoItem_IdProtocolo
  plan 2: hash join · Index Scan on ResultadoItem.IX_ResultadoItem_IdProtocolo
== 2. se fuerza el plan 1 (el que se compiló para V) y se ejecuta para C con la caché vacía
  plan en la caché para C: nested loops · Index Seek on ResultadoItem.IX_ResultadoItem_IdProtocolo
  plan 1: is_forced_plan = 1
  plan 2: is_forced_plan = 0
```

`sp_query_store_force_plan` le dice al optimizador que, para esa consulta, use ese plan. La caché se vació y el central volvió a
compilar, y el optimizador, que por su cuenta habría elegido el *hash join*, usó el *nested loops* forzado. El procedimiento no cambió
una letra. Es la herramienta que la Fase 13 no tenía en ningún motor del camino base: Oracle tiene las *SQL plan baselines*, con otra
mecánica, y Postgres no tiene nada en el motor.

### 5.3 Las pistas de Query Store

Desde SQL Server 2022, Query Store también guarda **pistas**: una opción de consulta (`OPTION (RECOMPILE)`, `OPTION (MAXDOP 1)`, un
`USE HINT`) que se aplica a una consulta identificada por su `query_id`, sin tocar su texto. Es la salida para el código que no se puede
cambiar: el SQL que arma un ORM, o el procedimiento de un proveedor.

```sql
EXEC sp_query_store_set_hints @query_id = 1, @query_hints = N'OPTION (RECOMPILE)';
EXEC sp_query_store_clear_hints @query_id = 1;
```

`03_query_store.py` quita el forzado, pone esa pista y ejecuta para C y para V. `sys.query_store_query_hints` muestra la pista con su
origen (`User`). Con `RECOMPILE`, la sentencia se compila en cada ejecución con el valor que trae: no hay *sniffing* que heredar, y se
paga una compilación por ejecución.

### 5.4 Las salidas que se escriben en el código

Antes de Query Store, la corrección se escribía en el procedimiento. `04_alternativas.py` crea tres variantes y muestra la estructura del
plan estimado de cada una para cada sede (la consulta no se ejecuta):

```text
resultados_por_sede                sede C: hash join    · Index Scan on ResultadoItem.IX_ResultadoItem_IdProtocolo
resultados_por_sede                sede V: nested loops · Index Seek on ResultadoItem.IX_ResultadoItem_IdProtocolo
resultados_optimize_for_c          sede C: hash join    · Index Scan on ResultadoItem.IX_ResultadoItem_IdProtocolo
resultados_optimize_for_c          sede V: hash join    · Index Scan on ResultadoItem.IX_ResultadoItem_IdProtocolo
resultados_optimize_for_unknown    sede C: hash join    · Index Scan on ResultadoItem.IX_ResultadoItem_IdProtocolo
resultados_optimize_for_unknown    sede V: hash join    · Index Scan on ResultadoItem.IX_ResultadoItem_IdProtocolo
resultados_recompile               sede C: hash join    · Index Scan on ResultadoItem.IX_ResultadoItem_IdProtocolo
resultados_recompile               sede V: nested loops · Index Seek on ResultadoItem.IX_ResultadoItem_IdProtocolo
```

`OPTIMIZE FOR (@sede = N'C')` compila siempre como si la sede fuera el central: el plan deja de depender de quién llega primero, y
todas las sedes reciben el del central. `OPTIMIZE FOR UNKNOWN` estima con la densidad de la columna, el promedio de todas las sedes en
toda la tabla, que es lo que hace el plan genérico de Postgres; aquí elige también el *hash join*. `OPTION (RECOMPILE)` le da a cada
sede su plan, y cobra una compilación cada vez. Ninguna es gratis: las dos primeras eligen **un** plan para todos los valores, y la
tercera paga en CPU lo que ahorra en lecturas.

### 5.5 El nivel de compatibilidad y PSP

La misma corrida de `02_sniffing.py` con la base en nivel **100**, el de SQL Server 2008 R2, que es el que conserva una base de 2011
restaurada en un servidor nuevo sin cambiarlo ([ss01](ss01-la-base-en-su-motor-original.md), ejercicio 11). El XML de cada plan dice
con qué estimador de cardinalidad se compiló: `CardinalityEstimationModelVersion="170"` en nivel 170 y `"70"` en nivel 100, el
estimador de antes de 2014. Con el viejo, el *sniffing* es el mismo: cinco veces el central y después V deja en la caché el *hash join*
con `Index Scan`; cinco veces V y después el central deja el *nested loops* con `Index Seek`. Dos corridas seguidas lo dieron igual.

> ⚠️ **Una corrida que no se repitió.** La primera vez que corrió `02_sniffing.py`, recién creada la base, el nivel 100 dejó el *nested
> loops* para el central **en los dos órdenes**. Después de reconstruir el índice de `ResultadoItem` (sección 8), ya no. La estructura
> de un plan se publica, y esta se publica como lo que fue: una observación que no se reprodujo, que sugiere que con el estimador viejo
> esta consulta está cerca del borde entre los dos métodos. El ejercicio 10 lo pide.

Que el nivel cambie el estimador es lo que hace riesgoso subirlo: la documentación dice que desde el nivel 130 las correcciones que
afectan planes van **solo** a los niveles nuevos, y recomienda subirlo con Query Store encendido y forzar el plan viejo de lo que empeore.

El nivel 160 trajo además la **optimización PSP** (*Parameter Sensitive Plan*): para una consulta con un predicado de igualdad cuyo
histograma muestra un sesgo fuerte, el motor compila un *dispatcher* que elige entre hasta tres variantes del plan según la cardinalidad
del valor. Es la respuesta del motor al *sniffing*. En `ss03`, Query Store no registró variantes (`sys.query_store_query_variant` vacía):
cuatro a uno entre el central y un centro no le alcanzó, o algo más lo frenó. La documentación no publica el umbral (*"The internal
threshold isn't documented"*) y ofrece un evento extendido que dice por qué se saltó una consulta; `06_psp.sql` lo enciende. Es la
segunda apuesta.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

**Cuándo se reutiliza.** Postgres planifica cinco veces con el valor antes de considerar un genérico, y lo adopta solo si no es más
caro que el promedio de los cinco; además, `plan_cache_mode = force_custom_plan` lo apaga para una sesión. SQL Server reutiliza desde
la segunda. La consecuencia de diseño es que en SQL Server una consulta sensible al valor **siempre** necesita una decisión explícita
(una de las de la sección 5), y en Postgres solo si el genérico gana.

**Quién guarda la historia.** En Postgres, `pg_stat_statements` guarda cuánto costó cada consulta, sin sus planes, y ninguna vista del
motor dice qué plan usó la consulta ayer. Para eso hacen falta extensiones (`auto_explain` en el registro, o `pg_store_plans`), y para
fijar un plan, `pg_hint_plan`, que la Fase 13 dejó como ejercicio opcional. En SQL Server está todo en la base, desde 2016, y encendido
desde 2022. La decisión cambia: en SQL Server se puede corregir un plan **en producción, sin desplegar código**, y deshacerlo con otro
procedimiento. Es la mejor herramienta de este motor para el problema de esta fase.

**Quién decide por ti.** SQL Server 2017 agregó el ajuste automático (*automatic plan correction*): con `AUTOMATIC_TUNING
(FORCE_LAST_GOOD_PLAN = ON)`, el motor detecta una regresión de plan en Query Store y fuerza el último bueno solo. Viene apagado en SQL
Server, encendido en Azure SQL Database, y la tabla de ediciones de 2025 lo marca **solo para Enterprise**: la Standard de Alameda no lo
tiene, y el laboratorio sí, porque es Enterprise Developer. Postgres no tiene nada parecido, y la Fase 13 mostró por qué un motor que no fija planes
tampoco los fija mal.

| | Postgres (publicado, M-21) | SQL Server |
|---|---|---|
| qué plan recibe V si el día empezó en el central | el del central desde la sexta ejecución, si las cinco eran del central | el del central desde la segunda (sección 4) |
| el método heredado | *hash join* | *hash join* con `Index Scan` (estructura) |
| cuánto le cuesta a V | 87.945 contra 10.865 bloques (8,1 veces) | 🪞🔒 (primera apuesta) |
| corregirlo sin tocar el código | `plan_cache_mode` por sesión o por rol | forzar el plan o una pista en Query Store |

---

## 🪞 7. Tu instinto dice… y la apuesta

*"Si el reporte del centro V anda lento, es que le falta un índice o hay que actualizar estadísticas."* Es el instinto razonable de
cualquier desarrollador, y la mitad de las veces acierta. La otra mitad, el índice está, las estadísticas están al día, y el plan es el
correcto **para otra sede**.

> 🪞🔒 **Apuesta sin resolver: SQL Server.** Hipótesis: en nivel 170, con el plan del central en la caché (`Index Scan` de
> `ResultadoItem`), la sede V lee **al menos tres veces** las lecturas lógicas que lee con su propio plan (`Index Seek`). Y al revés, con
> el plan de V en la caché, el central lee más que con el suyo. Condiciones: la base `ss03` de `01_setup.sql`, perfil M. Resuélvela:
> `uv run --extra sqlserver python ss03-query-store-y-parameter-sniffing/02_sniffing.py --private` desde `src/`, las líneas `🔒
> PRIVADO`. El mecanismo, en la guía de arquitectura del procesamiento de consultas (en las referencias). 📝 No publicamos el resultado:
> la licencia de SQL Server Developer no permite divulgar resultados de pruebas sin permiso de Microsoft
> ([`a09`](a09-licencias-publicacion-y-riesgo.md#-sql-server-la-cláusula-tal-cual)).

> 🪞🔒 **Apuesta sin resolver: SQL Server.** Hipótesis: PSP no arma variantes para `dbo.resultados_por_sede` porque el sesgo de `Sede`
> (cuatro a uno) no llega a su umbral, y el evento `parameter_sensitive_plan_optimization_skipped_reason` lo dice con un motivo de sesgo.
> Resuélvela: `../ss01-la-base-en-su-motor-original/sqlcmd.sh < 06_psp.sql`, y la lista de motivos posibles con `SELECT map_value FROM
> sys.dm_xe_map_values WHERE name = 'psp_skipped_reason_enum'`.

**Resultado:** sin publicar. Lo que sí está publicado es la estructura, y la estructura ya decide: **qué sede llegó primero elige entre
recorrer `ResultadoItem` entero o buscar en él**, y eso, con 3,7 millones de resultados, no es una diferencia de detalle.

---

## 💥 8. El punto de rotura

Un plan forzado es una promesa sobre objetos que pueden cambiar. `05_roturas.sql` fuerza el plan que busca en
`IX_ResultadoItem_IdProtocolo`, borra el índice, vacía la caché y ejecuta para el central. La consulta **corre**, con el plan que el
optimizador elige sin el índice, y Query Store lo registra en el plan forzado:

```text
plan_id is_forced_plan force_failure_count last_force_failure_reason_desc
1       1              1                   NO_INDEX
```

Nadie recibe un error. El plan sigue marcado como forzado, el contador de fallos sube en cada compilación, y el motivo queda en una
columna que alguien tiene que mirar. Es el mismo comportamiento que la Fase 13 encontró en el *optimizer hint* de MySQL, que deja un
aviso y sigue. La salida es mirar `force_failure_count` después de cualquier cambio de índices, y quitar el forzado
(`sp_query_store_unforce_plan`) en cuanto falle: un plan forzado que no se puede aplicar es peor que ninguno, porque parece que hay
alguien a cargo.

El script deja el índice de vuelta y el plan sin forzar.

---

## ⚰️ 9. Autopsia: el *hint* que sobrevivió a la sede que cerró, en su motor

**1. La decisión.** La de la Fase 13: *"Que la lista de últimos protocolos use el índice por fecha."* En 2012 el único índice útil de la
pantalla de cada sede era el de la fecha, el motor a veces elegía otro camino, y un *hint* lo fijó. En SQL Server, el *hint* es una
pista de tabla: `FROM Protocolos WITH (INDEX (…fecha…))`.

**2. Por qué era razonable.** Para una sede activa, recorrer el índice por fecha hacia atrás encuentra sus 50 protocolos enseguida. En
2012 todas las sedes estaban activas.

**3. Qué pasó después.** La sede `E` cerró: su último protocolo es del 31/12/2022, y tiene 80.918. Para encontrar sus 50, el índice por
fecha hay que recorrerlo desde octubre de 2026 hasta 2022. `05_roturas.sql` arma `dbo.protocol_hint` con los 1.327.622 protocolos de la
caja y los dos índices, y corre la consulta con el *hint*; `lab measure --engine sqlserver` muestra su plan. En MySQL la Fase 13 midió
691.136 entradas leídas para 50 protocolos con el *hint*, contra 50 sin él. En SQL Server queda como tercera apuesta (ejercicio 15). Y
cuando el índice que el *hint* nombra deja de existir, SQL Server no hace como el *optimizer hint* de MySQL ni como el plan forzado de la
sección 8. La consulta falla:

```text
Msg 308, Level 16, State 1, Server a07be756749e, Line 1
Index 'protocol_hint_fecha_idx' on table 'dbo.protocol_hint' (specified in the FROM clause) does not exist.
```

**4. Cuánto cuesta salir.** Borrar el *hint*: una línea, en cada lugar del código donde esté. Encontrarlos: buscar `WITH (INDEX` en
todo el SQL que manda el frontal y los reportes. Con Query Store, hay una salida que no toca el código: quitar el *hint* del texto es
inevitable, pero mientras tanto se puede forzar el plan bueno para la consulta tal cual está.

**5. Qué lo habría cambiado.** El índice compuesto `(Sede, Fecha)`, que es lo que faltaba en 2012. Con él, el optimizador encuentra los
50 de cualquier sede en un salto, sin *hint*.

**Antes y después, con números (MySQL, Fase 13):** 691.136 entradas y 619 ms con el *hint*, contra 50 entradas y 1,1 ms sin él. En SQL
Server, la estructura se publica: con el *hint*, un `Index Scan` **hacia atrás** del índice por fecha y, por cada entrada, un
`Clustered Index Seek` para leer la sede y descartarla si no es `E`; sin él, un solo `Index Seek` hacia atrás en `(Sede, Fecha)`. Los
números quedan para tu máquina.

---

## 📖 10. Traducción

| SQL Server | Postgres | Lo que cambia |
|---|---|---|
| *parameter sniffing* en la primera ejecución | cinco planes personalizados y después, quizá, el genérico | desde cuándo se hereda |
| `OPTION (RECOMPILE)` | `plan_cache_mode = force_custom_plan` | en SQL Server es por sentencia |
| `OPTIMIZE FOR UNKNOWN` | el plan genérico | los dos estiman con el promedio |
| `OPTIMIZE FOR (@p = valor)` | — | no hay forma de fijar el valor de estimación |
| Query Store (`sys.query_store_*`) | `pg_stat_statements` sin planes; `pg_store_plans` (extensión) | la historia de planes, en el motor |
| `sp_query_store_force_plan` | `pg_hint_plan` (extensión) | forzar sin tocar el código |
| `sp_query_store_set_hints` | `ALTER ROLE … SET plan_cache_mode` | pistas por consulta contra por rol |
| `WITH (INDEX (i))` | — (sin `pg_hint_plan`) | Msg 308 si el índice no existe |
| nivel de compatibilidad | — | el optimizador de otra versión, por base |
| PSP (nivel 160 y más) | — | hasta tres planes por consulta, según el valor |

Más en [`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**No fuerces un plan sin una fecha para revisarlo.** Un plan forzado es un *hint* que no se ve en el código: sobrevive a los cambios
de datos y de índices igual que el de 2012, y falla en silencio (sección 8). Cada forzado va con la medición que lo justificó y una
alerta sobre `force_failure_count`.

**No uses `OPTIMIZE FOR` un valor** si los valores cambian con el tiempo. El central de hoy no es el de 2030, y la sede que hoy es chica
puede ser la próxima en crecer.

**No pongas `RECOMPILE` en lo que corre cientos de veces por segundo.** Compilar cuesta CPU, y una pantalla muy usada lo multiplica.
Para el reporte por sede, que corre unas pocas veces por día, `RECOMPILE` es la salida más simple y más correcta.

**No subas el nivel de compatibilidad sin Query Store encendido.** Cambia planes de consultas que nadie revisó. Primero Query Store,
después el nivel, después las regresiones, una por una.

**Las cinco preguntas:** el **acceso** es una consulta con un parámetro cuyo mejor plan depende del valor; la **consistencia** no está
en juego, solo el costo; la **escala** convierte un plan heredado en el problema de la tabla más grande; la **evolución** es lo que
envejece a cada corrección escrita (*hint*, `OPTIMIZE FOR`, plan forzado); la **operación** gana con Query Store una herramienta de
producción, y una cosa más que mirar.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **El reporte lento solo a veces:** ninguno → 🩺 en Query Store, más de un plan para la misma consulta
  (`sys.query_store_plan` por `query_id`) → elegir una de las salidas de la sección 5.
- **El *hint* sobre un índice borrado:** `Msg 308 … (specified in the FROM clause) does not exist` → el índice se borró o se renombró →
  quitar el *hint*. E-85.
- **El plan forzado que no se aplica:** ninguno → 🩺 `last_force_failure_reason_desc` (`NO_INDEX`, `NO_PLAN`…) en
  `sys.query_store_plan` → quitar el forzado. E-86.
- **`QUOTED_IDENTIFIER` en `sqlcmd`:** `Msg 1934 SELECT failed because the following SET options have incorrect settings:
  'QUOTED_IDENTIFIER'` al usar los métodos de `xml` → `sqlcmd` abre la sesión con la opción apagada → `SET QUOTED_IDENTIFIER ON`, o
  `sqlcmd -I`. Es la razón por la que el script de SSMS la fija en cada lote. E-87.
- **Query Store no guarda la consulta:** ninguno → 🩺 `query_capture_mode_desc` es `AUTO` y la consulta es barata → `ALL` en el
  laboratorio, `AUTO` o `CUSTOM` en producción.

---

## 📋 13. Checklist de validación

```text
[ ] 01_setup.sql creó ss03 con 343.123 protocolos y 3.659.431 resultados, en nivel 170 y con Query Store
[ ] 02_sniffing.py muestra en nivel 170 dos planes distintos según la primera sede
[ ] 03_query_store.py muestra los dos planes de la consulta 1, fuerza el del seek y lo ve en la caché
[ ] 04_alternativas.py da la tabla de la sección 5.4
[ ] 05_roturas.sql da el Msg 308 y el NO_INDEX, y deja el índice de vuelta y nada forzado
[ ] resolviste las dos apuestas de la sección 7 en tu máquina, sin publicar el resultado
[ ] ss03 quedó en nivel 170, sin forzados y sin pistas
```

---

## 🧪 14. Ejercicios (22)

## 🟢 Fácil — leer lo que el motor recuerda (1–7)

### 🟢 Ejercicio 1 — Los dos órdenes

Corre `02_sniffing.py` sin `--private`.

**Objetivo:** la salida coincide con la sección 4 en nivel 170, y nombras el operador de acceso a `ResultadoItem` en cada plan.

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-1)

### 🟢 Ejercicio 2 — El estado de Query Store

Consulta `sys.database_query_store_options` en `ss03` y en `ALAMEDA`.

**Pregunta:** ¿está encendido en las dos, con qué modo de captura y cuánto espacio tiene reservado? ¿Por qué `ALAMEDA` lo tiene, si el
script de SSMS no lo pide?

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-2)

### 🟢 Ejercicio 3 — La consulta y sus planes

Después de `03_query_store.py`, busca la consulta del procedimiento en `sys.query_store_query` y sus planes en `sys.query_store_plan`.

**Objetivo:** una consulta que dé, por plan, su `plan_id`, si está forzado y la estructura (con `lab measure` o con `sqlserver.plan_lines`
sobre `query_plan`).

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-3)

### 🟢 Ejercicio 4 — El plan de la caché

Ejecuta el procedimiento una vez para el central, con la caché vacía, y busca su plan en `sys.dm_exec_procedure_stats` y
`sys.dm_exec_query_plan`.

**Pregunta:** ¿qué atributo del XML del plan dice con qué valor de `@sede` se compiló?

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-4)

### 🟢 Ejercicio 5 — Las tres variantes

Corre `04_alternativas.py`.

**Objetivo:** explicar en una frase cada una de las cuatro filas que cambian entre sedes o no, con el mecanismo de la opción.

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-5)

### 🟢 Ejercicio 6 — El *hint* que ya no tiene índice

Corre `05_roturas.sql`.

**Objetivo:** copiar el Msg 308 y decir en qué se diferencia de lo que hizo el plan forzado en el mismo script.

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-6)

### 🟢 Ejercicio 7 — Las sedes en Postgres

En `legacy` de Postgres, cuenta los protocolos por sede desde el 1 de septiembre de 2026 y los resultados de cada sede en ese período.

**Objetivo:** la tabla de la sección 1 (10.255 en el central, 2.626 en V) y la proporción de resultados, que es la que decide el plan.

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-7)

## 🟡 Intermedio — corregir (8–13)

### 🟡 Ejercicio 8 — Forzar el otro plan

Fuerza el plan del *hash join* y ejecuta para V con la caché vacía.

**Objetivo:** comprobar en la caché que V usa el plan forzado, y dejarlo sin forzar al terminar.

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-8)

### 🟡 Ejercicio 9 — Una pista distinta

Pon como pista de Query Store `OPTION (OPTIMIZE FOR (@sede = N'V'))` en lugar de `RECOMPILE`.

**Objetivo:** el plan del central con esa pista, y por qué una pista de Query Store puede usar el nombre del parámetro del procedimiento.

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-9)

### 🟡 Ejercicio 10 — El nivel 100

Corre `02_sniffing.py` tres veces seguidas, y una vez más justo después de `01_setup.sql`.

**Objetivo:** el valor de `CardinalityEstimationModelVersion` en el XML del plan de cada nivel, y si en tu máquina el nivel 100 da el
mismo plan en los dos órdenes alguna vez. Si pasa, di qué cambió entre esa corrida y las otras.

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-10)

### 🟡 Ejercicio 11 — `LEGACY_CARDINALITY_ESTIMATION`

En nivel 170, enciende `ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = ON`.

**Pregunta:** antes de correr `02_sniffing.py`, ¿qué plan esperas para el central? Después, ¿qué ganaste y qué perdiste respecto de
bajar el nivel a 100?

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-11)

### 🟡 Ejercicio 12 — Lo que vacía la caché

Con el plan de V en la caché, actualiza las estadísticas de `dbo.Protocolos` (`UPDATE STATISTICS dbo.Protocolos`) y ejecuta para el
central.

**Pregunta:** ¿qué plan queda en la caché, y por qué un mantenimiento nocturno de estadísticas puede cambiar qué sede "elige" el plan del
día siguiente?

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-12)

### 🟡 Ejercicio 13 — `legacy` en Postgres: la sede que cerró

En `legacy` de Postgres, cuenta los protocolos de la sede `E` y su última fecha, y cuántos protocolos de todas las sedes hay después de
esa fecha.

**Objetivo:** ese último número es lo que el *hint* por fecha tiene que recorrer antes de encontrar el primero de `E`, y lo comparas con
las 691.136 entradas de la Fase 13.

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-13)

## 🟠 Difícil — medir lo que no se publica (14–19)

### 🟠 Ejercicio 14 — La primera apuesta

Corre `02_sniffing.py --private`.

**Objetivo:** resolver la apuesta de las lecturas de V con el plan del central, y explicar el resultado con la estructura de los dos
planes. No publiques los números.

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-14)

### 🟠 Ejercicio 15 — El *hint* de 2012 en su motor

Antes de borrar el índice en `05_roturas.sql`, mide con `lab measure --engine sqlserver --private` la consulta de la sede `E` con el
*hint* y sin él.

**Objetivo:** la estructura de los dos planes (se publica) y la comparación de lecturas (no se publica), contra las 691.136 entradas de
MySQL.

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-15)

### 🟠 Ejercicio 16 — La segunda apuesta

Corre `06_psp.sql`.

**Objetivo:** resolver la apuesta de PSP y, si el motivo no es el sesgo, explicar qué otra condición de la documentación lo frena. No
publiques el motivo.

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-16)

### 🟠 Ejercicio 17 — PSP con más sesgo

Agrega a `dbo.Protocolos` de `ss03` doscientos mil protocolos del central (copias con `IdProtocolo` nuevo), actualiza estadísticas y repite
`06_psp.sql` y `02_sniffing.py`.

**Pregunta:** ¿aparecen variantes en `sys.query_store_query_variant`? Si aparecen, ¿qué plan tiene cada una?

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-17)

### 🟠 Ejercicio 18 — El ajuste automático

Enciende `AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON)` en `ss03` y provoca una regresión: el plan de V en la caché, muchas ejecuciones
del central.

**Objetivo:** encontrar en `sys.dm_db_tuning_recommendations` si el motor la detectó y qué propone, y explicar por qué en el laboratorio
puede no detectarla.

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-18)

### 🟠 Ejercicio 19 — El genérico de Postgres, de nuevo

Repite en Postgres la sesión que empieza en el central (`01_generic_plans.sql` de la Fase 13) con `plan_cache_mode = force_custom_plan`
para el rol del reporte (`ALTER ROLE … SET`).

**Objetivo:** la sede V con su plan propio en la sexta ejecución, y la comparación con la pista de Query Store de la sección 5.3: qué
alcance tiene cada una.

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-19)

## 🔴 Muy difícil — la política de Alameda (20–22)

### 🔴 Ejercicio 20 — Subir el nivel de ALAMEDA

La base de 2026 probablemente está en nivel 100.

**Objetivo:** el plan para llevarla a 170, paso por paso, con Query Store como red: qué se mide antes, cuánto tiempo, qué se hace con
cada regresión y cómo se vuelve atrás.

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-20)

### 🔴 Ejercicio 21 — La política de planes forzados

Escribe la política de Alameda para fijar planes: cuándo se fuerza, cuándo se pone una pista, cuándo se cambia el código, y quién revisa.

**Objetivo:** una página, con la alerta sobre `force_failure_count`, la fecha de revisión y la medición que justifica cada forzado, y
qué pasa con todo eso al migrar a Postgres.

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-21)

### 🔴 Ejercicio 22 — Lo que Postgres no tiene

Alameda migra a Postgres, y el equipo de Verónica pregunta qué pierde sin Query Store.

**Objetivo:** una respuesta honesta en tres partes: qué se pierde, qué lo reemplaza en Postgres (con extensiones y sin ellas) y qué no
hace falta, con la medición de la Fase 13 que lo sostiene.

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio-22)

## 🔥 Opcionales

### 🔥 Ejercicio 🔥 1 — *Optional parameter plan optimization*

SQL Server 2025 agregó en nivel 170 una optimización para los predicados opcionales (`WHERE (@sede IS NULL OR Sede = @sede)`).

**Objetivo:** escribir esa variante del procedimiento, buscar en la documentación qué hace la optimización y comprobar en Query Store si
aparecen variantes para `@sede` NULL y no NULL.

[Solución](soluciones/ss03-query-store-y-parameter-sniffing.md#ejercicio--1)

---

## 📚 15. Referencias

**Documentación oficial de SQL Server 2025**

- **Guía de arquitectura del procesamiento de consultas** (*parameter sensitivity*, reutilización de planes) — https://learn.microsoft.com/en-us/sql/relational-databases/query-processing-architecture-guide?view=sql-server-ver17
- **Query Store** — https://learn.microsoft.com/en-us/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store?view=sql-server-ver17
- **Pistas de Query Store** — https://learn.microsoft.com/en-us/sql/relational-databases/performance/query-store-hints?view=sql-server-ver17
- **`sp_query_store_force_plan`** — https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-query-store-force-plan-transact-sql?view=sql-server-ver17
- **Optimización PSP** — https://learn.microsoft.com/en-us/sql/relational-databases/performance/parameter-sensitive-plan-optimization?view=sql-server-ver17
- **Pistas de consulta** (`OPTIMIZE FOR`, `RECOMPILE`, `USE HINT`) — https://learn.microsoft.com/en-us/sql/t-sql/queries/hints-transact-sql-query?view=sql-server-ver17
- **Nivel de compatibilidad** — https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-compatibility-level?view=sql-server-ver17
- **Ajuste automático** — https://learn.microsoft.com/en-us/sql/relational-databases/automatic-tuning/automatic-tuning?view=sql-server-ver17

**Postgres, para el contraste:** `plan_cache_mode` — https://www.postgresql.org/docs/18/runtime-config-query.html ·
`pg_stat_statements` — https://www.postgresql.org/docs/18/pgstatstatements.html

**Libros:** Grant Fritchey, *SQL Server 2022 Query Performance Tuning*, 6.ª ed., Apress, 2022 — los capítulos de *parameter sniffing*
y de Query Store, con el proceso de subir el nivel de compatibilidad.

**Orden de lectura sugerido:** la sección de *parameter sensitivity* de la guía antes de la sección 4; la página de Query Store antes
de la 5.2; la de PSP después de la 5.5; Fritchey cuando vayas a tocar el nivel de una base de producción.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 18/10/2026, en la versión 17.x (SQL Server 2025) de la documentación.

---

## 🏁 16. Resultado de la fase

```text
QUERY STORE Y PARAMETER SNIFFING · ss03 (343.123 protocolos · 3.659.431 resultados) · SQL Server 2025 CU9 · 18/10/2026
  nivel 170   el plan de la caché depende de la primera sede: hash join + Index Scan (C) o nested loops + Index Seek (V)
  nivel 100   el mismo sniffing, con el estimador de antes de 2014 (CardinalityEstimationModelVersion 70)
  Query Store dos planes para la consulta 1 · el forzado se aplica con la caché vacía · una pista sin tocar el código
  el código   OPTIMIZE FOR C y UNKNOWN: un plan para todos · RECOMPILE: el suyo para cada sede
  roturas     Msg 308 (el hint sin índice) · NO_INDEX (el plan forzado que no se aplica, en silencio)
  costo       🪞🔒 · PSP 🪞🔒
```

> **La señal de que quedó bien:** *"Para cada consulta de Alameda con un parámetro sesgado sé qué plan queda según quién llegue
> primero, dónde lo veo, cómo lo fijo sin tocar el código y qué columna miro para saber si mi corrección dejó de funcionar."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a ss-fase-03-query-store-y-parameter-sniffing -m "ss03 cerrada: el sniffing de la consulta por sede en dos niveles, Query Store con un plan forzado y una pista, las tres salidas del código y sus dos roturas"
> ```
>
> Commits de la fase con prefijo `ss03:`, los de ejercicio `ss03 ej14: …`.
