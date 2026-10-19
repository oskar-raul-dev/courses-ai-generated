# 🪟 SQL Server 04 — Clustered, `NEWSEQUENTIALID` y tablas temporales: la clave que ordena la tabla, y la historia que guarda el motor

> **Curso:** Ruta SQL · Track SQL Server · ss04 de ss05 · **8 h** · opcional
> **Motor:** SQL Server 2025 CU9 (17.0.5005.3), Enterprise Developer, `mcr.microsoft.com/mssql/server@sha256:2b5b58162112…` · emulado en Apple Silicon
> **Entorno de ejecución:** SQL (T-SQL) + Python
> **Requisito del camino base:** Fases 07 y 10 · **Requisito del track:** [ss01](ss01-la-base-en-su-motor-original.md) (la caja cargada y su `sqlcmd.sh`)
> **El dolor de Alameda:** las 66 claves primarias agrupadas que nadie eligió ([ss01](ss01-la-base-en-su-motor-original.md)), y la pregunta de Norma: *"¿quién cambió este resultado, cuándo, y qué decía antes?"* ([historia](00-historia-de-alameda.md), §5)
> **Fecha de verificación ejecutada:** 18/10/2026
> **Objetivo:** decidir la clave de una tabla agrupada en SQL Server sabiendo cómo ordena el motor un `uniqueidentifier`, y contestar la pregunta de Norma con una tabla versionada por el sistema, sabiendo lo que no guarda.

---

## 🧭 1. Dónde estamos

La [Fase 10](10-identificadores.md) midió lo que cuesta una clave UUID en un motor que **agrupa** la tabla por su clave primaria: en
InnoDB, el índice primario del perfil M pasó de 48,6 MB con `bigint` a 93,8 MB con UUIDv4, y a 59,6 MB con UUIDv7
([M-16](bitacora-de-medicion.md#m-16--f10--uuidv4-y-uuidv7-como-clave-primaria-en-innodb)). La conclusión de la fase fue que, si hace
falta un UUID, el v7, que empieza por el tiempo, se inserta casi en orden y fragmenta casi como un entero.

SQL Server también agrupa: [ss01](ss01-la-base-en-su-motor-original.md) encontró en el catálogo de Alameda 66 claves primarias, las 66
`CLUSTERED`, porque es lo que escribe SSMS si nadie dice otra cosa. Y SQL Server tiene un tipo propio para los UUID, `uniqueidentifier`,
con dos funciones: `NEWID()`, al azar, y `NEWSEQUENTIALID()`, creciente. Esta fase repite la medición de la Fase 10 en este motor, y
encuentra que **la conclusión no se traslada**.

La segunda mitad es la pregunta de Norma. La [Fase 07](07-el-tiempo-en-el-modelo.md) la contestó en Postgres con una tabla de historia,
un rango con `WITHOUT OVERLAPS` y un disparador. SQL Server tiene desde 2016 **tablas versionadas por el sistema** (*temporal tables*):
el motor guarda cada versión de cada fila y la consulta se escribe con `FOR SYSTEM_TIME`. Es menos código. Esta fase mide lo que se
gana y lo que no guarda.

> 📝 **La regla del track.** De las tablas de esta fase se publica la estructura (qué clave, cuántas filas, que son de la caja); el tamaño
> de cada índice y su fragmentación van como apuesta, con `--private` para verlos ([`a09`](a09-licencias-publicacion-y-riesgo.md#-sql-server-la-cláusula-tal-cual)).

---

## 🎯 2. Objetivos de esta fase

1. Cargar los 1.327.622 protocolos de la caja en cinco tablas agrupadas que solo difieren en la clave, y predecir con la documentación
   cuáles se fragmentan.
2. Explicar cómo compara SQL Server dos `uniqueidentifier`, y por qué eso cambia la recomendación de la Fase 10 sobre el UUIDv7.
3. Usar `NEWSEQUENTIALID()` sabiendo sus tres límites: solo como `DEFAULT`, adivinable, y creciente solo hasta el próximo reinicio.
4. Contestar la pregunta de Norma con una tabla versionada por el sistema y `FOR SYSTEM_TIME`, y escribir lo que la tabla no guarda.
5. Romper una tabla temporal tres veces: con su historia, con su reloj y con su borrado.

---

## 🚫 3. Qué NO entra todavía

- **El tipo `json` y la API sobre estas tablas** → [ss05](ss05-data-api-builder-y-json.md).
- **Las tablas temporales con un período de aplicación** (lo bitemporal de la Fase 07): SQL Server no tiene un período de aplicación con
  restricción, como `WITHOUT OVERLAPS`; se nombra en la sección 6.
- **El *ledger* de SQL Server** (tablas a prueba de manipulación): es otra garantía, la de que nadie reescribió la historia; se nombra en
  el veredicto.
- **Particionar la tabla de historia**: fuera del curso.

---

## 🏚️ 4. El dolor, en la caja

`01_claves.py` lee los protocolos de `ALAMEDA` en el orden en que llegaron y los inserta de a 5.000, por la copia masiva de TDS, en
cinco tablas de una base aparte (`ss04`) con un índice secundario por paciente, como hizo la Fase 10 con InnoDB:

```text
order_int                         int IDENTITY(1,1) · 1327622 filas
order_newid                        uniqueidentifier · 1327622 filas
order_newseq                       uniqueidentifier · 1327622 filas
order_uuid4_app                    uniqueidentifier · 1327622 filas
order_uuid7_app                    uniqueidentifier · 1327622 filas
```

Las dos primeras uniqueidentifier tienen la clave por `DEFAULT` (`NEWID()` y `NEWSEQUENTIALID()`); las dos últimas la reciben de la
aplicación, generada en Python con el mismo `uuid7()` de la Fase 10. Lo que el motor hizo con cada una (cuántas páginas ocupa cada
índice agrupado y cuán fragmentado quedó) lo imprime `--private`. La predicción, con lo que dice la documentación, es la sección 5 y la
apuesta de la sección 7.

> 🏚️ **De la caja:** las 66 claves agrupadas de `ALAMEDA` son enteros: `IDENTITY` las que se agregaron en 2011 y los `IdProtocolo` de
> 1997. Ninguna es un `uniqueidentifier`. La pregunta de esta fase no es por la base de 2026, sino por la que se diseñe si Alameda se
> queda en SQL Server: el portal y la app quieren identificadores que no se adivinen, y la tentación es un UUID en la clave agrupada.

---

## 🧩 5. Lo que ordena la tabla

### 5.1 La clave agrupada

Una tabla con índice agrupado **es** el índice: las filas viven en las hojas del árbol, en el orden de la clave. Insertar una clave mayor
que todas agrega al final, en la última página; insertar una al azar cae en una página llena del medio, que se parte en dos (*page
split*), y cada mitad queda a medio llenar. Es el mismo mecanismo de InnoDB en la Fase 10, y por eso la medición se repite. Hay una
diferencia que suma: cada índice secundario de SQL Server guarda **la clave agrupada** como puntero a la fila, así que una clave de 16
bytes agranda también el índice por paciente.

> 🩻 **Esto sí funciona igual.** En InnoDB y en SQL Server, un entero creciente llena las páginas de a una y una clave al azar las parte.
> La recomendación de fondo de la Fase 10 (una clave interna corta y creciente, y el identificador externo aparte) vale igual en los dos.

### 5.2 Cómo compara SQL Server dos `uniqueidentifier`

Aquí la Fase 10 deja de valer. Un `uniqueidentifier` no se ordena como se lee. La documentación de .NET sobre `SqlGuid` lo dice en una
línea: el tipo implementa la comparación *"using SQL Server behavior, in the last six bytes of a value are most significant"*, y el blog del equipo de SQL
Server de 2006 que la acompaña detalla el orden: los bytes 10 a 15 primero, después el 8 y el 9, después el 6 y el 7, el 4 y el 5, y al
final del 0 al 3.

Un UUIDv7 pone los 48 bits del tiempo **al principio**, en los bytes 0 a 5. Para SQL Server, eso es lo **último** que mira, y lo primero
que mira, los bytes 10 a 15, es azar. Si la documentación tiene razón, un UUIDv7 generado por la aplicación entra en un índice agrupado
de SQL Server en un orden tan aleatorio como el de un UUIDv4, y la recomendación de la Fase 10 se invierte en este motor. Es la apuesta
de la sección 7.

`NEWSEQUENTIALID()` no tiene ese problema porque lo genera el propio SQL Server, con los bytes ya acomodados a su forma de comparar:
la documentación dice que *"is a wrapper over the Windows UuidCreateSequential function, with some byte shuffling applied"*. El valor que
devuelve no parece creciente si se lo lee como texto, y lo es para el índice.

### 5.3 `NEWSEQUENTIALID()` y sus tres límites

La función resuelve la fragmentación y trae tres condiciones, las tres en su página de la documentación.

**Solo como `DEFAULT`.** *"`NEWSEQUENTIALID` can't be referenced in queries."* Fuera de un `DEFAULT`:

```text
Msg 302, Level 16, State 1, Server a07be756749e, Line 2
The newsequentialid() built-in function can only be used in a DEFAULT expression for a column of type 'uniqueidentifier' in a CREATE
TABLE or ALTER TABLE statement. It cannot be combined with other operators to form a complex scalar expression.
```

La aplicación no conoce la clave hasta después del `INSERT` (`OUTPUT inserted.order_id`), que es justo lo que un UUID quería evitar.

**Adivinable.** *"If privacy is a concern, don't use this function. It's possible to guess the value of the next generated GUID."* Para
un identificador que se publica en una URL del portal, como el protocolo que la [Fase 23](23-la-base-como-producto.md) expuso por la API,
es la peor propiedad posible.

**Creciente hasta el próximo reinicio.** *"Creates a GUID that is greater than any GUID previously generated by this function on a
specified computer since Windows was started. After Windows restarts, the GUID can start again from a lower range."* Un reinicio del
servidor puede volver a insertar por el medio del índice. `02_reinicio.sql` inserta mil filas, se reinicia el contenedor, y
`02_reinicio_despues.sql` inserta mil más y cuenta cuántas quedaron ordenadas antes de las primeras. La documentación habla de Windows, y
el laboratorio corre en Linux: es la segunda apuesta.

### 5.4 La pregunta de Norma, con el motor

`03_temporales.sql` crea `dbo.resultado` con los 5.568 resultados del 9 de octubre de 2026, los mismos de la Fase 07, como tabla
versionada por el sistema:

```sql
-- sqlserver
CREATE TABLE dbo.resultado (
    IdItem           int          NOT NULL CONSTRAINT resultado_pk PRIMARY KEY CLUSTERED,
    IdProtocolo      int          NOT NULL,
    CodDeterminacion nvarchar(10) NOT NULL,
    Valor            nvarchar(50) NULL,
    ModificadoPor    nvarchar(50) NOT NULL CONSTRAINT resultado_modificado_por DEFAULT N'carga-legacy',
    ValidoDesde      datetime2(3) GENERATED ALWAYS AS ROW START NOT NULL,
    ValidoHasta      datetime2(3) GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidoDesde, ValidoHasta)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.resultado_historia));
```

Después repite la escena de la Fase 07: Lucía corrige la glucemia 12123358 de `165` a `156`, y Norma la vuelve a dejar como estaba. La
pregunta, como consulta, sin ninguna tabla escrita a mano y sin disparador:

```sql
SELECT Valor AS decia, ModificadoPor AS lo_escribio, ValidoDesde AS desde, ValidoHasta AS hasta
FROM dbo.resultado FOR SYSTEM_TIME ALL WHERE IdItem = 12123358 ORDER BY ValidoDesde;
```

`FOR SYSTEM_TIME ALL` es la unión de la tabla actual y la de historia, que el motor llena solo: cada `UPDATE` cierra la versión anterior
y la mueve a `dbo.resultado_historia` con su período. La documentación define también `AS OF` (lo que valía en un instante), `FROM … TO`,
`BETWEEN` y `CONTAINED IN`. La forma de la respuesta es la de la Fase 07: tres versiones, `165` de la carga, `156` de Lucía y `165` de
Norma, cada una con su período.

Hay tres cosas que la tabla temporal **no** hace, y las tres son la diferencia con la Fase 07:

- **No guarda quién.** El período dice cuándo, la fila dice qué, y nadie dice quién: `ModificadoPor` es una columna común que cada `UPDATE`
  tiene que escribir. Aquí la escribe desde el contexto de la sesión (`sp_set_session_context`, `SESSION_CONTEXT(N'usuario')`). Si un
  `UPDATE` se olvida, la historia atribuye el cambio a quien escribió antes. El disparador de la Fase 07 lo tomaba siempre de la sesión.
- **Versiona aunque no cambie nada.** La documentación: *"the Database Engine adds a row to the history table, even if no column values
  change"*. El disparador de la Fase 07 solo guardaba si `value_text IS DISTINCT FROM` el anterior; un frontal que guarda el formulario
  entero cada vez llena la historia de versiones iguales.
- **No escribe el pasado.** El período lo pone el motor, con la hora de la transacción. Los 5.568 resultados empiezan su historia **el día
  que se encendió el versionado**, no en su `FechaCarga`; la Fase 07 usaba la `FechaCarga` como inicio. Para traer la historia de antes hay
  que apagar el versionado, llenar la tabla de historia a mano y volver a encenderlo con su chequeo de consistencia.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

**La clave UUID.** En Postgres, un índice B-tree sobre `uuid` compara los 16 bytes de izquierda a derecha, como se leen: el UUIDv7 entra en
orden, y la Fase 10 lo midió en el índice primario (28 MB con `bigint`, 54 con v4 y 40 con v7, en M-16). Además, en Postgres la tabla no
está agrupada por la clave: un UUID al azar parte las páginas **del índice**, no las de la tabla, y el índice por paciente queda igual con
cualquier clave (M-16). En SQL Server las dos cosas cambian: la tabla es el índice, y el orden del tipo hace que el v7 no ayude. La
decisión que cambia es dónde se genera el UUID: en Postgres, en la aplicación con v7 o en el motor con `uuidv7()` (Postgres 18); en SQL
Server, `NEWSEQUENTIALID()` en el motor, con sus límites, o una clave agrupada entera con el UUID como columna aparte.

**La historia.** Postgres 18 no tiene tablas versionadas por el sistema: la Fase 07 lo hizo con un rango, `WITHOUT OVERLAPS` y un
disparador, en unas cuarenta líneas que dicen exactamente qué se guarda. SQL Server lo hace en una cláusula, y lo que guarda lo decide el
motor. Gana en código y en que nadie puede olvidarse de llamar al disparador; pierde en el quién, en las versiones repetidas y en el
pasado. Ninguno de los dos tiene, en el motor, la tabla **bitemporal** completa (período de sistema y período de aplicación con su
restricción); la Fase 07 la armó a mano en Postgres, y en SQL Server se arma igual, con una tabla temporal más un rango propio.

**La hora.** Los períodos de SQL Server van en UTC (*"in the UTC time zone"*, dice la documentación de cada `INSERT`, `UPDATE` y `DELETE`)
en una columna `datetime2` que **no dice** que es UTC. La Fase 07 guardó el período como `tstzrange`, con zona: la consulta con una hora
local se convierte sola. Es la rotura de la sección 8.

| | Postgres (publicado) | SQL Server |
|---|---|---|
| índice primario, `bigint` / v4 / v7 | 28 / 54 / 40 MB (M-16) | 🪞🔒 (primera apuesta) |
| el v7 entra en orden | sí: se compara de izquierda a derecha | no, según la documentación (los bytes 10 a 15 primero) |
| la historia de un resultado | tabla + rango + disparador (Fase 07) | `SYSTEM_VERSIONING` + `FOR SYSTEM_TIME` |
| quién | `application_name`, en el disparador | una columna que escribe cada `UPDATE` |
| el período | `tstzrange`, con zona | dos `datetime2` en UTC, sin zona |

---

## 🪞 7. Tu instinto dice… y la apuesta

*"Si la Fase 10 midió que el UUIDv7 fragmenta casi como un entero en InnoDB, también lo hace en SQL Server: los dos agrupan por la
clave."* Es el instinto más razonable de esta fase. Es el mismo mecanismo y la misma clave, y la conclusión de la Fase 10 salió de una
medición.

> 🪞🔒 **Apuesta sin resolver: SQL Server.** Hipótesis: con 1.327.622 protocolos insertados de a 5.000 en el orden en que llegaron, el
> índice agrupado de `order_uuid7_app` queda **tan fragmentado y tan grande como el de `order_uuid4_app`** (páginas llenas a menos del
> 75 %, fragmentación de más del 90 %), y solo `order_newseq` se parece a `order_int`. Condiciones: la base `ss04`, perfil M. Resuélvela:
> `uv run --extra sqlserver python ss04-clustered-newsequentialid-y-temporales/01_claves.py --private` desde `src/`, las líneas `🔒
> PRIVADO`. El mecanismo, en la documentación de `SqlGuid` y en el blog del equipo de SQL Server (en las referencias). 📝 No publicamos el
> resultado: la licencia de SQL Server Developer no permite divulgar resultados de pruebas sin permiso de Microsoft
> ([`a09`](a09-licencias-publicacion-y-riesgo.md#-sql-server-la-cláusula-tal-cual)).

> 🪞🔒 **Apuesta sin resolver: SQL Server.** Hipótesis: en el contenedor Linux del laboratorio, después de reiniciar SQL Server, las mil
> filas nuevas de `dbo.seq_restart` quedan ordenadas **antes** de las mil anteriores, como advierte la documentación para Windows.
> Resuélvela: `02_reinicio.sql`, `docker compose -f ../lab/compose.yaml restart sqlserver` y `02_reinicio_despues.sql`, desde
> `src/ss04-clustered-newsequentialid-y-temporales/`.

**Resultado:** sin publicar. Si la primera se gana, la recomendación de la Fase 10 se invierte en SQL Server: el UUID que la aplicación
genera no va en la clave agrupada, y la decisión es `NEWSEQUENTIALID()` (con sus límites) o un entero agrupado con el UUID aparte.

---

## 💥 8. El punto de rotura

`04_temporales_roturas.sql` rompe la tabla temporal de tres maneras, y las tres dan un mensaje que se publica.

**La historia de antes.** Para traer el resultado de 2019 con su período verdadero:

```text
Msg 13536, Level 16, State 1, Server a07be756749e, Line 2
Cannot insert an explicit value into a GENERATED ALWAYS column in table 'ss04.dbo.resultado'. Use INSERT with a column list to exclude
the GENERATED ALWAYS column, or insert a DEFAULT into GENERATED ALWAYS column.
```

Y la historia no se corrige a mano mientras el versionado está encendido:

```text
Msg 13561, Level 16, State 1, Server a07be756749e, Line 2
Cannot update rows in a temporal history table 'ss04.dbo.resultado_historia'.
```

**El reloj.** Norma pregunta qué decía la glucemia en el momento en que Lucía guardó, con la hora de Córdoba. El servidor del laboratorio
corre en UTC, y el de Alameda, en un Windows en hora argentina, devolvería la hora local en `SYSDATETIME()`. El período, en los dos, está
en UTC. Un `FOR SYSTEM_TIME AS OF` con la hora local pregunta por un instante **tres horas antes**, cuando la fila todavía no existía en la
tabla, y no encuentra nada. La salida se convierte con `AT TIME ZONE`:

```sql
DECLARE @utc datetime2(3) = CAST((@local AT TIME ZONE 'Argentina Standard Time') AT TIME ZONE 'UTC' AS datetime2(3));
SELECT Valor FROM dbo.resultado FOR SYSTEM_TIME AS OF @utc WHERE IdItem = 12123358;
```

El nombre de la zona es el de Windows (`'Argentina Standard Time'`) también en Linux. Un reporte que muestra los períodos tal cual se
equivoca en tres horas sin que nada falle.

**El borrado.** Con el versionado encendido, la tabla no se vacía ni se borra:

```text
Msg 13545, Level 16, State 1, Server a07be756749e, Line 1
Truncate failed on table 'ss04.dbo.resultado' because it is not a supported operation on system-versioned tables.
Msg 13552, Level 16, State 1, Server a07be756749e, Line 2
Drop table operation failed on table 'ss04.dbo.resultado' because it is not a supported operation on system-versioned temporal tables.
```

Es lo que se quiere de una auditoría, y obliga a un paso explícito (`ALTER TABLE … SET (SYSTEM_VERSIONING = OFF)`) para cualquier
mantenimiento. Ese mismo paso es el que deja reescribir la historia: una tabla temporal protege contra el error, no contra quien tiene
permisos para apagarla. Los cinco mensajes van a [`a08`](a08-catalogo-de-errores.md) como E-88 a E-92.

---

## ⚰️ 9. Autopsia: la clave agrupada que nadie eligió

**La decisión, 2011:** el asistente de Access y después SSMS escribieron `PRIMARY KEY CLUSTERED` en las 66 tablas con clave, porque es
lo que escriben si nadie dice otra cosa. Nadie lo decidió. Nadie tuvo que decidirlo, tampoco: las claves eran enteros.

**Por qué era razonable.** Para una clave `IDENTITY` creciente, agrupar por la clave es la mejor opción de SQL Server: las filas nuevas
van al final, las páginas se llenan enteras y la búsqueda por clave es un solo árbol. Es la opción por defecto porque es la correcta para
la clave más común.

**Qué pasa después.** Pasa cuando cambia la clave. Si el portal y la app piden que el protocolo no se adivine, y alguien cambia la clave
de `Protocolos` por un `uniqueidentifier`, el `CLUSTERED` que nadie eligió sigue ahí, y ahora ordena la tabla de 1,3 millones de
protocolos por un valor al azar. Y si ese alguien leyó la Fase 10 y eligió UUIDv7 para evitarlo, la sección 5.2 dice que en este motor no
lo evita. La decisión por defecto era buena para la clave de 2011, y nadie la revisó al cambiar la clave porque nadie sabía que era una
decisión.

**Cuánto cuesta salir.** Separar las dos cosas: la clave agrupada sigue siendo el entero (`IdProtocolo`), y el identificador que se
publica es una columna `uniqueidentifier` con su índice único no agrupado, generada por la aplicación con el algoritmo que quiera. Es la
misma recomendación de la Fase 10 (una clave interna y otra externa), y en SQL Server deja de ser una preferencia: es la que no depende
del orden del tipo.

**Qué pregunta lo habría cambiado.** *¿Por qué valor está ordenada físicamente esta tabla, y quién lo eligió?*

**Antes y después, con números (Postgres e InnoDB, Fase 10):** el índice primario con UUIDv4 ocupa 1,93 veces el de `bigint` en
InnoDB (93,8 contra 48,6 MB) y 1,93 en Postgres (54 contra 28 MB). En SQL Server, el mismo antes y después queda para tu máquina.

---

## 📖 10. Traducción

| SQL Server | Postgres | Lo que cambia |
|---|---|---|
| `PRIMARY KEY CLUSTERED` | clave primaria sobre un *heap* | la tabla es el índice, o no |
| `uniqueidentifier` | `uuid` | el orden: bytes 10–15 primero, o de izquierda a derecha |
| `NEWID()` | `gen_random_uuid()` | — |
| `NEWSEQUENTIALID()` (solo `DEFAULT`) | `uuidv7()` (Postgres 18, en cualquier expresión) | adivinable y con reinicio, contra estándar |
| `OUTPUT inserted.id` | `RETURNING id` | — |
| `SYSTEM_VERSIONING = ON` | tabla de historia + disparador (Fase 07) | el motor contra cuarenta líneas tuyas |
| `FOR SYSTEM_TIME AS OF t` | `WHERE system_during @> t` sobre la unión | — |
| `GENERATED ALWAYS AS ROW START/END` (UTC, sin zona) | `tstzrange` (con zona) | la hora |
| `SESSION_CONTEXT(N'usuario')` | `current_setting('application_name')` | quién, en los dos lo pone la sesión |
| `AT TIME ZONE 'Argentina Standard Time'` | `AT TIME ZONE 'America/Argentina/Cordoba'` | nombres de Windows contra IANA |

Más en [`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**No pongas un `uniqueidentifier` como clave agrupada si lo genera la aplicación.** Ni v4 ni v7: por lo que dice la documentación sobre el
orden del tipo, los dos entran al azar. Si hace falta un UUID, va en una columna con índice único no agrupado.

**No uses `NEWSEQUENTIALID()` para lo que se publica.** Se adivina, y la documentación lo dice con esas palabras. Sirve para una clave
interna que quiera ser única entre servidores; para eso, un entero suele alcanzar.

**No uses una tabla temporal como auditoría sin la columna del quién y sin una política para su historia.** Contesta cuándo y qué; quién
lo contesta tu código. Y la historia crece con cada `UPDATE`, cambie o no algo: `HISTORY_RETENTION_PERIOD` le pone un límite, y un límite
en una auditoría de resultados firmados es una decisión de Norma, no del DBA.

**No la uses si lo que hay que probar es que nadie reescribió la historia.** Quien puede apagar el versionado puede editarla. Para eso SQL
Server tiene las tablas *ledger*, con su propia factura, y Postgres no tiene equivalente en el motor.

**Las cinco preguntas:** el **acceso** decide la clave agrupada (casi todo es por protocolo y por fecha: un entero creciente sirve a los
dos); la **consistencia** de la historia la da el motor, la del quién no; la **escala** es la de la tabla de historia, que nunca achica;
la **evolución** de una tabla temporal pide apagar el versionado para casi cualquier cambio de esquema; la **operación** suma la zona
horaria a todo reporte que muestre un período.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **La clave UUID que fragmenta:** ninguno → 🩺 `avg_fragmentation_in_percent` y `avg_page_space_used_in_percent` en
  `sys.dm_db_index_physical_stats` → clave agrupada entera y el UUID aparte.
- **`NEWSEQUENTIALID()` en una consulta:** `Msg 302 … can only be used in a DEFAULT expression` → se llamó fuera de un `DEFAULT` →
  `DEFAULT` y `OUTPUT inserted`. E-88.
- **El período a mano:** `Msg 13536 Cannot insert an explicit value into a GENERATED ALWAYS column` → `SYSTEM_VERSIONING = OFF`, llenar
  la historia y encenderlo otra vez. E-89.
- **La historia a mano:** `Msg 13561 Cannot update rows in a temporal history table` → lo mismo, y preguntarse por qué. E-90.
- **Vaciar o borrar:** `Msg 13545 Truncate failed …` y `Msg 13552 Drop table operation failed …` → `ALTER TABLE … SET
  (SYSTEM_VERSIONING = OFF)` primero. E-91 y E-92.
- **El `AS OF` que no encuentra nada:** ninguno → 🩺 compara la hora de la consulta con `SYSUTCDATETIME()` → `AT TIME ZONE`.

---

## 📋 13. Checklist de validación

```text
[ ] 01_claves.py cargó 1.327.622 protocolos en cada una de las cinco tablas de ss04
[ ] resolviste las dos apuestas de la sección 7 en tu máquina, sin publicar los números
[ ] puedes explicar con la documentación por qué un UUIDv7 de la aplicación no entra en orden en SQL Server
[ ] 03_temporales.sql da las tres versiones de la glucemia 12123358 con FOR SYSTEM_TIME ALL
[ ] sabes qué columna dice quién cambió cada versión, y quién la escribe
[ ] 04_temporales_roturas.sql da los mensajes de la sección 8, y la consulta con AT TIME ZONE encuentra la versión de Lucía
[ ] dejaste ss04 como la quieras para ss05 (dbo.resultado sigue versionada)
```

---

## 🧪 14. Ejercicios (20)

## 🟢 Fácil — la clave y la historia (1–6)

### 🟢 Ejercicio 1 — Las cinco tablas

Corre `01_claves.py` sin `--private`.

**Objetivo:** las cinco tablas con 1.327.622 filas cada una, y para cada una, quién genera la clave: el motor o la aplicación.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-1)

### 🟢 Ejercicio 2 — El orden del tipo

Inserta en una tabla temporal (`#g`) tres `uniqueidentifier` que solo difieren en un byte: el primero, el octavo y el último, y ordénalos.

**Pregunta:** antes de correrlo, ¿en qué orden salen? Explícalo con el orden de comparación de la sección 5.2.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-2)

### 🟢 Ejercicio 3 — `NEWSEQUENTIALID()` fuera de lugar

Llama a `NEWSEQUENTIALID()` en un `SELECT`, en un `DEFAULT` que la convierta a texto (`CONVERT(nvarchar(36), NEWSEQUENTIALID())`) y en
uno que la convierta a su propio tipo (`CAST(NEWSEQUENTIALID() AS uniqueidentifier)`).

**Objetivo:** el resultado de cada intento, la frase de la documentación que los anticipa, y por qué el tercero no se comporta como el
segundo.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-3)

### 🟢 Ejercicio 4 — La pregunta de Norma

Corre `03_temporales.sql`.

**Objetivo:** las tres versiones de la glucemia 12123358 con `FOR SYSTEM_TIME ALL`, y la misma respuesta escrita como una unión de
`dbo.resultado` y `dbo.resultado_historia`, sin `FOR SYSTEM_TIME`.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-4)

### 🟢 Ejercicio 5 — Las cinco subcláusulas

Con `dbo.resultado`, escribe una consulta con `AS OF`, `FROM … TO`, `BETWEEN … AND` y `CONTAINED IN` para la glucemia 12123358.

**Pregunta:** ¿cuál de las cuatro devuelve la versión de Lucía y nada más? Explícalo con la tabla de la documentación.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-5)

### 🟢 Ejercicio 6 — `legacy` en Postgres: los resultados del 9 de octubre

En `legacy` de Postgres, cuenta los resultados con `FechaCarga` del 9 de octubre de 2026 y busca la glucemia 12123358.

**Objetivo:** los 5.568 de la sección 5.4 y el valor `165`, que es el punto de partida de las dos fases.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-6)

## 🟡 Intermedio — lo que el motor no guarda (7–12)

### 🟡 Ejercicio 7 — El `UPDATE` que no cambia nada

Haz `UPDATE dbo.resultado SET Valor = Valor WHERE IdItem = 12123358` tres veces.

**Pregunta:** antes de correrlo, ¿cuántas versiones nuevas aparecen en la historia? Escribe un disparador `INSTEAD OF UPDATE` o un
`WHERE` en la aplicación que evite las repetidas, y di cuál prefieres.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-7)

### 🟡 Ejercicio 8 — El quién olvidado

Haz un `UPDATE` de la glucemia sin escribir `ModificadoPor`.

**Objetivo:** mostrar a quién le atribuye la historia el cambio, y escribir una restricción o un disparador que lo impida.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-8)

### 🟡 Ejercicio 9 — La historia de antes

Trae a `dbo.resultado_historia` una versión anterior de la glucemia, con período desde el 9 hasta el 10 de octubre de 2026 a las 8 UTC.

**Objetivo:** la secuencia de comandos (apagar el versionado, insertar, encenderlo con `DATA_CONSISTENCY_CHECK = ON`), y el mensaje si el
período se superpone con el de la fila actual.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-9)

### 🟡 Ejercicio 10 — La hora de Córdoba

Corre la tercera parte de `04_temporales_roturas.sql`.

**Objetivo:** explicar por qué `AS OF` con la hora local devuelve NULL y con la UTC devuelve `156`, y escribir una vista que muestre los
períodos en hora de Córdoba.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-10)

### 🟡 Ejercicio 11 — La clave externa aparte

Crea `dbo.order_dos_claves` con `order_id int IDENTITY` agrupado y `public_id uniqueidentifier` con índice único no agrupado, y carga los
protocolos con un UUIDv4 de la aplicación en `public_id`.

**Objetivo:** la estructura de la tabla y de sus dos índices, y la consulta que busca por `public_id` (con `lab measure --engine
sqlserver`, la estructura del plan).

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-11)

### 🟡 Ejercicio 12 — `uuidv7()` en Postgres

En Postgres 18, crea una tabla con `id uuid DEFAULT uuidv7()` e inserta mil filas.

**Objetivo:** comprobar que el orden de `id` coincide con el de inserción, y explicar por qué la misma propiedad no sobrevive al pasar ese
valor a un `uniqueidentifier` de SQL Server.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-12)

## 🟠 Difícil — medir y decidir (13–17)

### 🟠 Ejercicio 13 — La primera apuesta

Corre `01_claves.py --private`.

**Objetivo:** resolver la apuesta, y explicar la fila de `order_uuid7_app` con el orden de comparación del tipo. No publiques los números.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-13)

### 🟠 Ejercicio 14 — Un UUIDv7 que SQL Server ordene

Escribe en Python una función que genere un UUID con el tiempo en los bytes que SQL Server compara primero, y repite la carga de
`order_uuid7_app` con ella.

**Objetivo:** la función, la carga, y la comparación de la fragmentación con `order_newseq`. Di qué se pierde respecto del UUIDv7 estándar.
No publiques los números.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-14)

### 🟠 Ejercicio 15 — El índice por paciente

Compara el tamaño del índice por paciente de `order_int` con el de cualquiera de las tablas con `uniqueidentifier`.

**Pregunta:** antes de mirarlo, ¿por qué tendría que ser más grande en las de `uniqueidentifier`, si la columna `patient_id` es la misma?
Contesta con lo que guarda un índice no agrupado en SQL Server.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-15)

### 🟠 Ejercicio 16 — La segunda apuesta

Corre `02_reinicio.sql`, reinicia el contenedor y corre `02_reinicio_despues.sql`.

**Objetivo:** resolver la apuesta y explicar el resultado con la documentación y con los bytes de los valores que cambiaron. No publiques
el conteo.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-16)

### 🟠 Ejercicio 17 — La retención

Ponle a `dbo.resultado` una retención de historia de seis meses (`HISTORY_RETENTION_PERIOD`).

**Objetivo:** el comando, qué hace el motor con las versiones más viejas, y un párrafo para Norma: ¿cuánto tiempo hay que poder contestar
su pregunta sobre un resultado firmado?

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-17)

## 🔴 Muy difícil — Alameda (18–20)

### 🔴 Ejercicio 18 — La clave del portal

El portal quiere protocolos con identificador no adivinable, y Alameda se queda en SQL Server un año más.

**Objetivo:** el diseño (qué columna, qué tipo, qué índice, quién la genera), la migración de `Protocolos` sin parar el laboratorio, y por
qué no se cambia la clave agrupada.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-18)

### 🔴 Ejercicio 19 — Tabla temporal o disparador

Matías tiene que contestar la pregunta de Norma en SQL Server este mes.

**Objetivo:** comparar la tabla temporal de esta fase con el disparador de la Fase 07 portado a T-SQL, en cinco criterios (quién, versiones
repetidas, historia de antes, zona horaria, quién puede reescribir), y elegir uno con su razón.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-19)

### 🔴 Ejercicio 20 — Lo bitemporal en SQL Server

La Fase 07 armó en Postgres lo que se sabía cuándo (tiempo de sistema) y lo que valía cuándo (tiempo de aplicación).

**Objetivo:** el mismo modelo en SQL Server, con una tabla temporal para el tiempo de sistema y un rango propio para el de aplicación, y
cómo se impide la superposición de rangos sin `WITHOUT OVERLAPS`.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio-20)

## 🔥 Opcionales

### 🔥 Ejercicio 🔥 1 — *Ledger*

Crea una versión de `dbo.resultado` como tabla *ledger* actualizable (`LEDGER = ON`) y repite la corrección de Lucía y Norma.

**Objetivo:** qué guarda el motor que la tabla temporal no guarda, cómo se verifica (`sys.sp_verify_database_ledger`), y qué cuesta.

[Solución](soluciones/ss04-clustered-newsequentialid-y-temporales.md#ejercicio--1)

---

## 📚 15. Referencias

**Documentación oficial**

- **`NEWSEQUENTIALID`** — https://learn.microsoft.com/en-us/sql/t-sql/functions/newsequentialid-transact-sql?view=sql-server-ver17
- **Comparar `Guid` y `uniqueidentifier`** (`SqlGuid`) — https://learn.microsoft.com/en-us/dotnet/framework/data/adonet/sql/comparing-guid-and-uniqueidentifier-values
- **Cómo compara SQL Server los GUID** (blog del equipo, 2006) — https://learn.microsoft.com/en-us/archive/blogs/sqlprogrammability/how-are-guids-compared-in-sql-server-2005
- **Tablas temporales** — https://learn.microsoft.com/en-us/sql/relational-databases/tables/temporal/overview?view=sql-server-ver17
- **Consultar una tabla temporal** — https://learn.microsoft.com/en-us/sql/relational-databases/tables/temporal/query-data?view=sql-server-ver17
- **Retención de la historia** — https://learn.microsoft.com/en-us/sql/relational-databases/tables/temporal/manage-retention?view=sql-server-ver17
- **`AT TIME ZONE`** — https://learn.microsoft.com/en-us/sql/t-sql/queries/at-time-zone-transact-sql?view=sql-server-ver17
- **Ledger** — https://learn.microsoft.com/en-us/sql/relational-databases/security/ledger/ledger-overview?view=sql-server-ver17
- **Índices agrupados y no agrupados** — https://learn.microsoft.com/en-us/sql/relational-databases/indexes/clustered-and-nonclustered-indexes-described?view=sql-server-ver17

**Postgres, para el contraste:** `uuidv7()` — https://www.postgresql.org/docs/18/functions-uuid.html

**Libros y artículos:** Kimberly L. Tripp, *GUIDs as PRIMARY KEYs and/or the clustering key*, SQLskills, 2009 —
https://www.sqlskills.com/blogs/kimberly/guids-as-primary-keys-andor-the-clustering-key/ — el artículo que cualquier DBA de SQL Server
cita sobre esto, anterior a UUIDv7 · RFC 9562, *Universally Unique IDentifiers (UUIDs)*, IETF, 2024 — el
formato del v7.

**Orden de lectura sugerido:** la página de `SqlGuid` antes de la sección 5.2; la de tablas temporales antes de la 5.4; Tripp cuando
alguien proponga un UUID en una clave agrupada.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 18/10/2026; el blog de 2006 es un archivo de Microsoft, no la documentación
> vigente, y se usa solo para el orden de los bytes, que la página de `SqlGuid` confirma.

---

## 🏁 16. Resultado de la fase

```text
CLUSTERED, NEWSEQUENTIALID Y TEMPORALES · ss04 · SQL Server 2025 CU9 · 18/10/2026
LA CLAVE   cinco tablas de 1.327.622 protocolos: int, NEWID, NEWSEQUENTIALID, v4 y v7 de la aplicación
           el orden del tipo: bytes 10–15 primero (documentado) · fragmentación y tamaño: 🪞🔒
           NEWSEQUENTIALID: solo DEFAULT (Msg 302), adivinable, creciente hasta el reinicio (🪞🔒 en Linux)
LA HISTORIA la glucemia 12123358 en tres versiones con FOR SYSTEM_TIME ALL, sin disparador
           no guarda quién · versiona aunque no cambie nada · no escribe el pasado · períodos en UTC sin zona
           Msg 13536 · 13561 · 13545 · 13552
LA DECISIÓN entero agrupado y el UUID aparte · tabla temporal con la columna del quién y la hora convertida
```

> **La señal de que quedó bien:** *"Sé por qué valor está ordenada cada tabla agrupada de Alameda y por qué, y contesto la pregunta de
> Norma diciendo también lo que la respuesta no sabe."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a ss-fase-04-clustered-newsequentialid-y-temporales -m "ss04 cerrada: cinco claves agrupadas sobre la caja, el orden del uniqueidentifier y el UUIDv7, NEWSEQUENTIALID y sus límites, la pregunta de Norma con una tabla temporal y sus roturas"
> ```
>
> Commits de la fase con prefijo `ss04:`, los de ejercicio `ss04 ej14: …`.
