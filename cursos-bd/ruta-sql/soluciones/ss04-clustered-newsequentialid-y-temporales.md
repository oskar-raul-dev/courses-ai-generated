# ✅ Soluciones — SQL Server 04: Clustered, `NEWSEQUENTIALID` y tablas temporales

> **Curso:** Ruta SQL · Solucionario de [ss04](../ss04-clustered-newsequentialid-y-temporales.md)
> **Ejercicios:** 20 · **Perfil:** M (los 1.327.622 protocolos y los 5.568 resultados del 9 de octubre de 2026) · **Motores:** SQL Server
> 2025 CU9 `mcr.microsoft.com/mssql/server@sha256:2b5b58162112…` (emulado), y Postgres `pgvector/pgvector@sha256:2358fcba361e…`
> **Fecha de verificación ejecutada:** 18/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

> 🔒 **Lo que este solucionario no trae.** Páginas, fragmentación, tamaños y tiempos de SQL Server. Trae los mensajes, la estructura, el
> comportamiento documentado (con el ejemplo de la propia documentación donde lo hay) y lo de Postgres
> ([`a09`](../a09-licencias-publicacion-y-riesgo.md#-qué-sí-se-publica-de-oracle-y-de-sql-server)).

Los `.py` se corren desde `src/`; los `.sql`, desde `src/ss04-clustered-newsequentialid-y-temporales/` con
`../ss01-la-base-en-su-motor-original/sqlcmd.sh`.

---

## 🟢 Fácil (1–6)

### Ejercicio 1

La salida de la sección 4: cinco tablas con 1.327.622 filas, que son los protocolos de la caja. La clave la genera **el motor** en
`order_int` (`IDENTITY`), `order_newid` (`DEFAULT NEWID()`) y `order_newseq` (`DEFAULT NEWSEQUENTIALID()`), y **la aplicación** en
`order_uuid4_app` y `order_uuid7_app`, que reciben el valor por la copia masiva. En las tres primeras, `01_claves.py` no manda la columna
de la clave (`column_mappings` sin `order_id`), y el motor completa el `DEFAULT` o la identidad.

### Ejercicio 2

```sql
-- sqlserver
CREATE TABLE #g (etiqueta varchar(10), g uniqueidentifier);
INSERT INTO #g VALUES ('byte 0',  '01000000-0000-0000-0000-000000000000'),
                      ('byte 8',  '00000000-0000-0000-0100-000000000000'),
                      ('byte 15', '00000000-0000-0000-0000-000000000001');
SELECT etiqueta, g FROM #g ORDER BY g;
```

**Predicción, con la sección 5.2:** primero el que tiene distinto el byte 0, que es el menos significativo; después el del byte 8; al
final el del byte 15, que es parte de los seis que se comparan primero. Es el comportamiento que la documentación de `SqlGuid` muestra con
su propio ejemplo: tres GUID que ordenados como `Guid` salen `1…3E`, `2…1E`, `3…2E` y ordenados como `SqlGuid` salen `2…1E`, `3…2E`,
`1…3E`, según el último grupo. Leído como texto, el orden de SQL Server parece al azar; leído como bytes de derecha a izquierda, es
perfectamente creciente.

### Ejercicio 3

```text
SELECT NEWSEQUENTIALID():
Msg 302 … The newsequentialid() built-in function can only be used in a DEFAULT expression for a column of type 'uniqueidentifier' in a
CREATE TABLE or ALTER TABLE statement. It cannot be combined with other operators to form a complex scalar expression.

DEFAULT CONVERT(nvarchar(36), NEWSEQUENTIALID()):
The newsequentialid() built-in function can only be used in a DEFAULT expression for a column of type 'uniqueidentifier' …
Msg 1750 … Could not create constraint or index. See previous errors.

DEFAULT CAST(NEWSEQUENTIALID() AS uniqueidentifier):
(se crea sin error; el catálogo la guarda como (CONVERT([uniqueidentifier],newsequentialid())))
```

La documentación lo anticipa en dos frases: *"`NEWSEQUENTIALID` can't be referenced in queries"* y *"it can't be combined with other
scalar operators"*. El tercero pasa porque convertir un `uniqueidentifier` a `uniqueidentifier` no cambia el tipo de la columna, y el
motor lo acepta: la regla de fondo, la del mensaje, es la del tipo (*"for a column of type 'uniqueidentifier'"*). No conviene contar con
eso: es un borde que la documentación no promete.

### Ejercicio 4

```sql
-- sqlserver · con FOR SYSTEM_TIME
SELECT Valor, ModificadoPor, ValidoDesde, ValidoHasta
FROM dbo.resultado FOR SYSTEM_TIME ALL WHERE IdItem = 12123358 ORDER BY ValidoDesde;

-- sin FOR SYSTEM_TIME: lo mismo, a mano
SELECT Valor, ModificadoPor, ValidoDesde, ValidoHasta FROM dbo.resultado WHERE IdItem = 12123358
UNION ALL
SELECT Valor, ModificadoPor, ValidoDesde, ValidoHasta FROM dbo.resultado_historia WHERE IdItem = 12123358
ORDER BY ValidoDesde;
```

Las tres versiones (`165` de `carga-legacy`, `156` de `lucia2`, `165` de `norma`), cada una con su período. La documentación dice que `ALL`
*"Returns the union of rows that belong to the current and the history table"*, y la segunda consulta es esa unión. La diferencia:
`FOR SYSTEM_TIME` descarta las versiones de duración cero, las de varios `UPDATE` de la misma fila en una transacción, y la unión a mano
las muestra.

### Ejercicio 5

Con la tabla de la documentación delante (`AS OF`: `ValidFrom <= t AND ValidTo > t`; `CONTAINED IN`: `ValidFrom >= desde AND ValidTo <=
hasta`; `FROM … TO` y `BETWEEN … AND`: las versiones que se tocan con el intervalo):

```sql
DECLARE @d datetime2(3), @h datetime2(3);
SELECT @d = ValidoDesde, @h = ValidoHasta FROM dbo.resultado_historia WHERE IdItem = 12123358 AND ModificadoPor = N'lucia2';
SELECT Valor FROM dbo.resultado FOR SYSTEM_TIME CONTAINED IN (@d, @h) WHERE IdItem = 12123358;
```

`CONTAINED IN` con los dos extremos del período de Lucía devuelve solo su versión: es la única que **empezó y terminó** dentro del
intervalo. `AS OF @d` también devuelve solo la de Lucía, porque en `@d` empezó la suya y terminó la de la carga (el extremo superior es
abierto). `FROM @d TO @h` y `BETWEEN @d AND @h` devuelven además la de Norma con `BETWEEN`, que incluye las que empiezan exactamente en el
extremo superior.

### Ejercicio 6

```sql
-- postgres
SELECT count(*) FILTER (WHERE "FechaCarga" >= '2026-10-09' AND "FechaCarga" < '2026-10-10') AS del_9,
       max("Valor") FILTER (WHERE "IdItem" = 12123358) AS glucemia
FROM legacy."ResultadoItem" WHERE "FechaCarga" >= '2026-10-01';
```

```text
 del_9 | glucemia
-------+----------
  5568 | 165
```

Los mismos 5.568 resultados de la Fase 07 y de `dbo.resultado`, y la glucemia 12123358 en `165`: el valor de la caja, del que parten las
dos versiones de la historia.

---

## 🟡 Intermedio (7–12)

### Ejercicio 7

**Predicción:** tres versiones nuevas. La documentación: *"When you run any data modification queries on a temporal table, the Database
Engine adds a row to the history table, even if no column values change."* La salida es la del comportamiento documentado: dos versiones
antes, cinco después. Dos maneras de evitarlas:

```sql
-- en la aplicación (o en el procedimiento): no escribir lo que no cambió
UPDATE dbo.resultado SET Valor = @nuevo, ModificadoPor = @quien
WHERE IdItem = @id AND Valor IS DISTINCT FROM @nuevo;      -- IS DISTINCT FROM existe en T-SQL desde 2022

-- en el motor: un INSTEAD OF UPDATE que solo deja pasar las filas que cambian
CREATE OR ALTER TRIGGER dbo.resultado_solo_cambios ON dbo.resultado INSTEAD OF UPDATE AS
UPDATE r SET Valor = i.Valor, ModificadoPor = i.ModificadoPor
FROM dbo.resultado AS r JOIN inserted AS i ON i.IdItem = r.IdItem
WHERE r.Valor IS DISTINCT FROM i.Valor;
```

Prefiero el `WHERE` en el código que escribe: es visible, y no hay un disparador que decida a escondidas qué se guarda en una auditoría.
El disparador tiene una ventaja que importa si los que escriben son varios (el frontal, un proceso, una API): nadie se lo puede saltear.

### Ejercicio 8

```text
Valor ModificadoPor
157   norma            ← el UPDATE de prueba, sin ModificadoPor
165   norma            ← la versión anterior, la de Norma
```

La historia le atribuye el cambio a Norma, porque `ModificadoPor` conservó el valor de la versión anterior: un `UPDATE` que no lo nombra
no lo cambia. Una salida en el motor:

```sql
CREATE OR ALTER TRIGGER dbo.resultado_exige_quien ON dbo.resultado AFTER UPDATE AS
IF EXISTS (SELECT 1 FROM inserted AS i JOIN deleted AS d ON d.IdItem = i.IdItem
           WHERE i.ModificadoPor = d.ModificadoPor AND i.ModificadoPor <> CAST(SESSION_CONTEXT(N'usuario') AS nvarchar(50)))
    THROW 50001, N'ModificadoPor tiene que ser el usuario de la sesión', 1;
```

O, más simple, que el disparador lo escriba siempre desde `SESSION_CONTEXT`, como hacía el de la Fase 07 con `application_name`. Al
terminar, `norma` deja la glucemia en `165` otra vez.

### Ejercicio 9

```sql
ALTER TABLE dbo.resultado SET (SYSTEM_VERSIONING = OFF);
GO                                   -- en su propio lote: compilado junto al INSERT, este falla con el Msg 13559
INSERT INTO dbo.resultado_historia (IdItem, IdProtocolo, CodDeterminacion, Valor, ModificadoPor, ValidoDesde, ValidoHasta)
SELECT IdItem, IdProtocolo, CodDeterminacion, N'160', N'equipo-legacy', '2026-10-09 10:00', '2026-10-10 08:00'
FROM dbo.resultado WHERE IdItem = 12123358;
GO
ALTER TABLE dbo.resultado SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.resultado_historia, DATA_CONSISTENCY_CHECK = ON));
```

Con un período que termina en el futuro, el chequeo de consistencia no deja volver a encender el versionado:

```text
Msg 13543, Level 16, State 1, Server a07be756749e, Line 1
Setting SYSTEM_VERSIONING to ON failed because history table 'ss04.dbo.resultado_historia' contains invalid records with end of period
set to a value in the future.
```

Y si el `ALTER … OFF` va en el mismo lote que el `INSERT`, el lote se compila con el versionado todavía encendido:

```text
Msg 13559, Level 16, State 1, Server a07be756749e, Line 3
Cannot insert rows in a temporal history table 'ss04.dbo.resultado_historia'.
```

Con el período cerrado antes del de la fila actual, el versionado vuelve a encenderse, y `FOR SYSTEM_TIME ALL` muestra la versión
traída (`160`, de `equipo-legacy`) primera, antes de la de la carga, y todas las demás detrás: ocho, si antes corriste los ejercicios 7 y 8.
Es la única forma de traer a una tabla temporal la historia que había antes de encenderla, y la que permite reescribirla: apagar, editar,
encender. Por eso la tabla temporal no prueba nada contra quien tiene ese permiso.

### Ejercicio 10

`@local` es el instante en que Lucía guardó, en hora de Córdoba (UTC−3): tres horas antes, en la escala UTC de los períodos. `AS OF
@local` pregunta por un momento anterior a la carga de la tabla, y la fila no tenía ninguna versión: NULL. `AS OF @utc`, con la hora
convertida, cae dentro del período de Lucía: `156`. La vista:

```sql
CREATE OR ALTER VIEW dbo.resultado_historia_cordoba AS
SELECT IdItem, Valor, ModificadoPor,
       CAST((ValidoDesde AT TIME ZONE 'UTC') AT TIME ZONE 'Argentina Standard Time' AS datetime2(3)) AS desde_cordoba,
       CASE WHEN ValidoHasta = '9999-12-31 23:59:59.999' THEN NULL
            ELSE CAST((ValidoHasta AT TIME ZONE 'UTC') AT TIME ZONE 'Argentina Standard Time' AS datetime2(3)) END AS hasta_cordoba
FROM dbo.resultado FOR SYSTEM_TIME ALL;
```

El primer `AT TIME ZONE 'UTC'` le dice al motor en qué zona está el `datetime2` (que no lo sabe), y el segundo lo convierte. Sin el
`CASE`, la conversión del `9999-12-31` se sale del rango del tipo.

### Ejercicio 11

```sql
CREATE TABLE dbo.order_dos_claves (
    order_id        int IDENTITY(1,1) NOT NULL CONSTRAINT order_dos_claves_pk PRIMARY KEY CLUSTERED,
    public_id       uniqueidentifier  NOT NULL CONSTRAINT order_dos_claves_public UNIQUE NONCLUSTERED,
    legacy_order_id int NOT NULL, patient_id int NULL, ordered_on datetime NULL, site_code nvarchar(1) NULL);
```

```text
lab measure --engine sqlserver -c "SELECT order_id, ordered_on FROM dbo.order_dos_claves WHERE public_id = '…'"
  Nested Loops (Inner Join)
    Index Seek on order_dos_claves.order_dos_claves_public
    Clustered Index Seek on order_dos_claves.order_dos_claves_pk
```

La búsqueda por el identificador público es un `Index Seek` en el índice único y una búsqueda en la clave agrupada para el resto de la
fila: dos árboles en lugar de uno, por cada protocolo que pide el portal. A cambio, la tabla sigue ordenada por el entero, y el índice
único es el único que se fragmenta. Para el portal, que busca de a un protocolo, es un precio chico.

### Ejercicio 12

```sql
-- postgres
CREATE TEMP TABLE v7 AS SELECT n, uuidv7() AS id FROM generate_series(1, 1000) AS n;
SELECT count(*) FILTER (WHERE id < prev) AS fuera_de_orden
FROM (SELECT id, lag(id) OVER (ORDER BY n) AS prev FROM v7) AS t;
```

```text
 fuera_de_orden
----------------
              0
```

En Postgres 18.6, mil `uuidv7()` seguidos están en el orden en que se generaron: el tipo `uuid` se compara de izquierda a derecha, y el
tiempo va primero. El mismo valor, pasado a SQL Server, es el mismo número con otra regla de orden: los 48 bits del tiempo quedan en los
bytes que SQL Server compara al final, y los primeros que compara, del 10 al 15, son azar. La propiedad no viaja con el valor; es de la
combinación del valor y del tipo.

---

## 🟠 Difícil (13–17)

### Ejercicio 13

**Solución.** Se resuelve con `01_claves.py --private`. Lo que hay que explicar: si `order_uuid7_app` tiene una fragmentación y un llenado
de página parecidos a los de `order_uuid4_app`, y muy distintos de los de `order_newseq`, la sección 5.2 es la explicación. Las inserciones
del v7 llegan en orden de tiempo, y el tiempo está en los bytes 0 a 5, que SQL Server compara al final: el índice las recibe en el orden de
sus bytes 10 a 15, que son azar. No publiques los números.

### Ejercicio 14

```python
def uuid_sqlserver_ordenado(ms: int) -> uuid.UUID:
    """Azar en los bytes 0–9 (con versión y variante donde las pide la RFC) y el tiempo en los bytes 10–15."""
    raw = bytearray(os.urandom(10) + ms.to_bytes(6, "big"))
    raw[6] = (raw[6] & 0x0F) | 0x80       # versión 8: "a medida", que es lo que es
    raw[8] = (raw[8] & 0x3F) | 0x80       # variante RFC
    return uuid.UUID(bytes=bytes(raw))
```

Con el tiempo en los bytes 10 a 15, un valor generado después es mayor para SQL Server, y la carga se parece a la de `order_newseq`.
Se pierde lo que el v7 estándar da: que el orden sea el mismo en cualquier motor y en cualquier lenguaje, y que el tiempo se pueda leer
desde el principio del texto. Es un UUID de versión 8 (la RFC 9562 la deja para formatos propios), ordenado para un solo motor. En una
migración a Postgres, la misma columna vuelve a entrar al azar. No publiques los números de la comparación.

**Rúbrica.** La función pone el tiempo en los bytes 10 a 15 y respeta versión y variante; la carga se compara con `order_newseq`; la
respuesta dice qué se pierde. Queda invalidada si llama UUIDv7 a lo que no es.

### Ejercicio 15

**Predicción, con la documentación de índices:** en SQL Server, cada fila de un índice no agrupado guarda, además de su clave
(`patient_id`), **la clave agrupada** de la fila, que es el puntero con que llega a ella. Con `order_int`, ese puntero son 4 bytes; con un
`uniqueidentifier`, 16. El índice por paciente de cualquier tabla con clave UUID tiene que ser más grande, aunque la columna `patient_id`
sea la misma. En Postgres no pasa: el índice apunta a la ubicación física de la fila (el `ctid`, 6 bytes) con cualquier clave, y M-16 midió
el índice por paciente igual en los tres casos. En InnoDB pasa lo mismo que en SQL Server, y M-16 lo midió: de 37,6 a 54,6 MB. Compara el
tuyo con `--private`; no publiques los números.

### Ejercicio 16

**Solución.** Se resuelve con `02_reinicio.sql`, el reinicio y `02_reinicio_despues.sql`. Para explicarlo, compara el valor mayor de la
primera tanda con el menor de la segunda **por grupos**: el grupo de los bytes 8 y 9 (el cuarto del texto, `8ACD-` en la tanda 1) es la
secuencia de reloj de `UuidCreateSequential`, que la documentación de Windows dice que cambia en un reinicio, y SQL Server lo compara antes
que los bytes 0 a 7. Si el reinicio lo hizo **subir**, todo lo nuevo queda después de lo viejo aunque el resto del valor baje; si lo hizo
bajar, todo queda antes. La documentación de `NEWSEQUENTIALID` habla de Windows y el laboratorio corre en Linux: la apuesta es si se comporta
igual. No publiques el conteo.

### Ejercicio 17

```sql
ALTER TABLE dbo.resultado SET (SYSTEM_VERSIONING = ON (HISTORY_RETENTION_PERIOD = 6 MONTHS));
SELECT name, history_retention_period, history_retention_period_unit_desc FROM sys.tables WHERE name = 'resultado';
SELECT is_temporal_history_retention_enabled FROM sys.databases WHERE name = 'ss04';
```

```text
resultado 6 MONTH
1
```

La documentación de la retención dice que una tarea en segundo plano borra de la historia las versiones cuyo fin de período es anterior
al plazo, y que la opción de la base (`TEMPORAL_HISTORY_RETENTION`) tiene que estar encendida, como está. **El párrafo para Norma:** un
resultado firmado es un documento médico, y la pregunta *"qué decía antes"* se puede hacer años después, en una auditoría o en un juicio.
Seis meses es un plazo de espacio, no de auditoría. El plazo lo fija la normativa que Norma conoce, y la base lo cumple con la retención
en `INFINITE` y una política de archivo de la historia vieja, no borrándola. Al terminar, `HISTORY_RETENTION_PERIOD = INFINITE`.

---

## 🔴 Muy difícil (18–20) — rúbrica

### Ejercicio 18

*La clave del portal.*

**Rúbrica (sobre 5 puntos):** 1 punto por la columna `public_id uniqueidentifier` con índice único no agrupado y la clave agrupada que
queda como está; 1 por quién la genera (la aplicación con un v4, porque no tiene que ser ordenable ni adivinable; nunca
`NEWSEQUENTIALID()`); 1 por la migración en pasos de *expand*: agregar la columna `NULL`, llenarla en tandas, crear el índice
`WITH (ONLINE = ON)` si la edición lo permite (Standard no: es de Enterprise) o en una ventana, y después `NOT NULL`; 1 por el `DEFAULT
NEWID()` para lo que se inserta durante la migración; 1 por explicar con la sección 5.2 por qué no se cambia la clave agrupada.

### Ejercicio 19

*Tabla temporal o disparador.*

**Rúbrica (sobre 5 puntos):** 1 punto por criterio bien comparado. **Quién:** el disparador lo toma de la sesión siempre; la tabla temporal
depende de cada `UPDATE`. **Versiones repetidas:** el disparador puede comparar; la temporal versiona siempre. **Historia de antes:** el
disparador acepta el período que le des; la temporal exige apagarla. **Zona horaria:** las dos se pueden escribir en UTC, pero solo el
disparador puede usar `datetimeoffset`. **Quién puede reescribir:** en las dos, quien tenga permisos sobre la tabla o sobre el versionado;
ninguna es una prueba. La elección razonable para este mes es la tabla temporal **con** el disparador del ejercicio 8 que escribe el quién,
y la razón es que nadie puede olvidarse de llamar al versionado.

### Ejercicio 20

*Lo bitemporal en SQL Server.*

**Rúbrica (sobre 4 puntos):** 1 punto por la tabla temporal para el tiempo de sistema; 1 por el período de aplicación en dos columnas
(`VigenteDesde`, `VigenteHasta`) con su `CHECK`; 1 por la no superposición, que sin `WITHOUT OVERLAPS` va en un disparador o en un
procedimiento con bloqueo (`WITH (UPDLOCK, HOLDLOCK)` sobre las filas del mismo resultado), con la advertencia de la Fase 07 sobre MySQL:
sin bloqueo, dos sesiones pasan; 1 por la consulta que pregunta las dos cosas a la vez (`FOR SYSTEM_TIME AS OF` y el rango de vigencia).

---

## 🔥 Opcionales

### Ejercicio 🔥 1

```sql
CREATE TABLE dbo.resultado_ledger (IdItem int NOT NULL PRIMARY KEY, Valor nvarchar(50) NULL)
WITH (SYSTEM_VERSIONING = ON, LEDGER = ON);
INSERT INTO dbo.resultado_ledger VALUES (12123358, N'165');
UPDATE dbo.resultado_ledger SET Valor = N'156' WHERE IdItem = 12123358;
SELECT name, ledger_type_desc FROM sys.tables WHERE name LIKE 'resultado_ledger%' OR name LIKE 'MSSQL_LedgerHistoryFor%';
EXECUTE sys.sp_generate_database_ledger_digest;
```

```text
MSSQL_LedgerHistoryFor_…  HISTORY_TABLE
resultado_ledger          UPDATABLE_LEDGER_TABLE
{"database_name":"ss04","block_id":0,"hash":"0x…","last_transaction_commit_time":"…","digest_time":"…"}
```

**Rúbrica.** Lo que guarda que la tabla temporal no: la documentación de *ledger* dice que cada fila lleva el identificador de la
transacción que la escribió y que las transacciones se encadenan en bloques con un *hash*; el resumen (*digest*) que devuelve
`sp_generate_database_ledger_digest` se guarda **fuera** de la base, y `sys.sp_verify_database_ledger` con ese resumen detecta si alguien
cambió la historia, incluido un DBA. Lo que cuesta: las tablas *ledger* no se pueden volver tablas comunes, lo que se borra de ellas queda
registrado, y el resumen hay que guardarlo en un lugar que el DBA no controle. Para la pregunta de Norma alcanza la temporal; para probarla
ante un tercero, *ledger*.
