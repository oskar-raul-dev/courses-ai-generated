# ✅ Soluciones — SQL Server 01: La base en su motor original

> **Curso:** Ruta SQL · Solucionario de [ss01](../ss01-la-base-en-su-motor-original.md)
> **Ejercicios:** 20 · **Perfil:** M · **Motores:** SQL Server 2025 CU9 `mcr.microsoft.com/mssql/server@sha256:2b5b58162112…`
> (emulado), y Postgres `pgvector/pgvector@sha256:2358fcba361e…` para el contraste
> **Fecha de verificación ejecutada:** 18/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

> 🔒 **Lo que este solucionario no trae.** Ningún resultado de SQL Server: ni conteos sobre lo cargado, ni tiempos, ni lo que
> devuelven las tres apuestas. Trae los mensajes de error, el comportamiento que Microsoft documenta, los conteos de la caja y lo
> que se mide en Postgres. Donde la respuesta es un resultado de SQL Server, la solución dice qué consulta lo da y cómo se
> interpreta ([`a09`](../a09-licencias-publicacion-y-riesgo.md#-sql-server-la-cláusula-tal-cual)).

Todo se corre desde `src/ss01-la-base-en-su-motor-original/`, con el laboratorio arriba (`uv run --extra sqlserver lab up
sqlserver`) y la caja M cargada en los dos motores.

---

## 🟢 Fácil (1–6)

### Ejercicio 1

```bash
docker compose -f ../lab/compose.yaml exec sqlserver uname -m
./sqlcmd.sh -Q "SELECT @@VERSION"
```

```text
x86_64
Microsoft SQL Server 2025 (RTM-CU9) (KB5122048) - 17.0.5005.3 (X64)
	Enterprise Developer Edition (64-bit) on Linux (Ubuntu 24.04.4 LTS) <X64>
```

SQL Server ve `x86_64` aunque la máquina sea un Mac `arm64`: Docker Desktop traduce cada instrucción con Rosetta
([`a01`](../a01-laboratorio-contenerizado.md#-macos-arm64-y-la-tabla-de-emulación)). `@@VERSION` dice además `on Linux`, y eso
importa en esta fase: `CODEPAGE` no existe en Linux. Cualquier tiempo de este contenedor en un Mac mide la emulación, no el
motor; otra razón, además de la licencia, para no compararlos.

### Ejercicio 2

```text
#@ Row 1, Column 1: String data, right truncation @#
"C"	"Laboratorio Central"	"RIVADAVIA 521"	"1996-03-01 00:00:00.000"
```

El primer campo de la fila es `"C"`, con las comillas: tres caracteres para una columna `nvarchar(1)`. `bcp` en modo texto
(`-c`) separa por la coma y no reconoce comillas, así que las deja como parte del dato, y el primer dato que no entra es el de la
columna 1. Por eso el error es de **truncamiento**: el valor es demasiado largo, no tiene un formato inválido. En `Pacientes`,
cuya primera columna es un entero sin comillas, el primer choque es la fecha entrecomillada de la columna 4, y ahí sí es de
formato (`Invalid date format`).

### Ejercicio 3

```bash
uv run --extra sqlserver lab load --engine sqlserver --profile m       # desde src/
./sqlcmd.sh -Q "USE ALAMEDA; SELECT COUNT(*) FROM sys.tables WHERE schema_id = SCHEMA_ID('dbo'); SELECT profile, seed, sha256 FROM lab.loaded"
```

```text
419
m 1996 258082ddb7fad956a9435f21de79986e1d2759045c889dc3e7fa47822e5f2e3a
```

Las 419 tablas son las del script de SSMS, y el hash es el de la caja: el mismo que imprime `lab load` en Postgres
(`258082ddb7fa`). Si no coincide, tu caja no es la del curso
([`a05`](../a05-la-caja-y-el-generador.md#-generar-y-cargar-en-dos-comandos)).

### Ejercicio 4

```sql
-- postgres
SELECT count(*) FILTER (WHERE "ObraSocial" IS NULL) AS nulos, count(*) FILTER (WHERE "ObraSocial" = '') AS vacios
FROM legacy."Protocolos";
```

```text
 nulos   | vacios
---------+--------
 1142443 |   3649
```

En SQL Server, la misma cuenta sobre `dbo.Protocolos` cargada por `lab load` tiene que dar lo mismo: son los datos de la caja.
Lo hace posible `csv.QUOTE_NOTNULL` en el lector de `lab/engines/sqlserver.py`: con esa opción, el `csv` de Python devuelve
`None` para un campo vacío sin comillas y `''` para `""`, y la copia masiva manda cada uno como lo que es. Sin esa opción, el
lector devuelve `''` para los dos, y la diferencia se pierde del lado del cliente.

### Ejercicio 5

```sql
-- postgres
SELECT count(*) FILTER (WHERE upper("Nombre") LIKE 'PEÑA %') AS pena_con_enie,
       count(*) FILTER (WHERE upper("Nombre") LIKE 'PENA %') AS pena_sin_enie,
       count(*) FILTER (WHERE "Nombre" LIKE 'peña %') AS en_minusculas_tal_cual
FROM legacy."Pacientes";
```

```text
 pena_con_enie | pena_sin_enie | en_minusculas_tal_cual
---------------+---------------+------------------------
          3762 |           168 |                      0
```

En SQL Server, `LIKE N'peña %'` encuentra los nombres que empiezan con `PEÑA `, porque `CI` ignora las mayúsculas: tiene que
dar las 3.762 de la caja. `LIKE N'pena %'` encuentra **otros**: los 168 nombres que la recepción escribió `PENA` sin tilde, y no
los `PEÑA`, porque `AS` distingue los acentos. En Postgres, la primera devuelve 0 porque la comparación distingue mayúsculas y la
caja está en mayúsculas. Lo interesante es el 168: para la intercalación, `PEÑA` y `PENA` son apellidos distintos, y para Norma
son la misma persona mal escrita. Eso lo resolvió la [Fase 05](../05-una-persona-no-es-su-documento.md), no la intercalación.

### Ejercicio 6

```text
name                   minimum maximum config_value run_value
two digit year cutoff  1753    9999    2049         2049
```

Vale 2049, el valor por defecto. La documentación lo traduce: el período es 1950–2049, un año de dos cifras de `00` a `49` es
20xx y de `50` a `99` es 19xx. `01/01/49` es el 1 de enero de **2049**, el último año que cae en el siglo XXI.

---

## 🟡 Intermedio (7–12)

### Ejercicio 7

```sql
-- sqlserver
SELECT r.IdItem, r.Valor
FROM dbo.ResultadoItem AS r
JOIN dbo.Protocolos AS p ON p.IdProtocolo = r.IdProtocolo
WHERE r.CodDeterminacion = N'GLU';
```

La consulta no usa ninguna columna de `Protocolos`: el join solo sirve para exigir que el protocolo exista. Con una clave foránea
de confianza de `ResultadoItem.IdProtocolo` a `Protocolos`, el optimizador sabe que todo resultado con protocolo no nulo tiene su
protocolo, y puede **quitar el join** y dejar un filtro `IdProtocolo IS NOT NULL`. La documentación de `ALTER TABLE` dice que no
lo hace con esta: *"The query optimizer doesn't consider constraints that are defined `WITH NOCHECK`"*. Y no sería solo una
optimización perdida: con los 2.150 huérfanos de la caja, el plan sin join devolvería resultados que el plan con join no
devuelve. Por eso el optimizador no puede creerle a una restricción que nadie verificó. `lab measure --engine sqlserver` muestra
la estructura del plan (los dos operadores de acceso y el join); compáralo después del ejercicio 8, si lograras validarla.

### Ejercicio 8

```sql
-- sqlserver
BEGIN TRAN;
ALTER TABLE dbo.ResultadoItem WITH CHECK CHECK CONSTRAINT FK_ResultadoItem_Protocolos;
ROLLBACK;
```

```text
Msg 547, Level 16, State 1, Server a07be756749e, Line 3
The ALTER TABLE statement conflicted with the FOREIGN KEY constraint "FK_ResultadoItem_Protocolos". The conflict occurred in database "ALAMEDA", table "dbo.Protocolos", column 'IdProtocolo'.
```

Falla. `WITH CHECK CHECK CONSTRAINT` habilita la clave y la valida contra todas las filas, y hay resultados cuyo protocolo no
existe: los **2.150** que la [Fase 04](../04-un-valor-un-hecho.md) mandó a rechazos como `resultados.protocolo_inexistente`, de
198 protocolos borrados entre 2008 y 2011. La clave sigue `is_disabled = 1` e `is_not_trusted = 1`. Para validarla habría que
decidir qué hacer con esos resultados, que es la misma decisión que tomó la Fase 04.

### Ejercicio 9

```sql
-- sqlserver
SELECT LEN(N'PEÑA LAURA  ') AS len, DATALENGTH(N'PEÑA LAURA  ') / 2 AS caracteres;
```

La documentación de `LEN` dice que devuelve el número de caracteres **excluyendo los espacios finales**: da 10, y `DATALENGTH`
(bytes, dos por carácter en `nvarchar`) da 12 caracteres. En Postgres `length('PEÑA LAURA  ')` es 12.

```sql
-- postgres
SELECT count(*) FROM legacy."Pacientes" WHERE "Nombre" ~ ' $';
```

```text
 count
-------
     0
```

El port de la Fase 04 recorta el nombre con `btrim` al entrar (`rest := btrim(coalesce(raw, ''))`), y desde ahí ningún token ni
resto tiene espacios finales: cada `length` del bucle mide lo mismo que mediría `LEN`. En la caja no se habría notado aunque no
lo hiciera, porque ningún nombre termina en espacio. Eso no hace al port correcto por accidente: lo hace correcto para esta caja,
y el `btrim` es lo que lo hace correcto para cualquiera.

### Ejercicio 10

```text
con_try
-------
NULL

Msg 241, Level 16, State 1, Server a07be756749e, Line 2
Conversion failed when converting date and/or time from character string.
```

`CONVERT` falla con el 31 de febrero; `TRY_CONVERT` devuelve NULL. `fn_ExtraerFecha` usa `TRY_CONVERT`, así que un nombre con
una fecha imposible no corta el reporte: la función devuelve NULL, el paciente queda sin edad calculada, y nadie se entera de que
la fecha estaba mal. Es la misma decisión que la Fase 04 imitó con un bloque `EXCEPTION` que devuelve NULL, y la misma que la
tabla de rechazos corrigió: un valor que no se puede leer va a rechazos con su regla, no desaparece.

### Ejercicio 11

La documentación de `ALTER DATABASE … SET COMPATIBILITY_LEVEL` lo dice así: *"For databases attached or restored from any earlier
version of SQL Server, the database keeps its existing compatibility level, if it's at least minimum allowed for that instance"*.
Una base creada en SQL Server 2008 R2 tiene nivel **100**, y SQL Server 2025 admite de 100 a 170: restaurada sin cambiarlo, sigue
en 100. El optimizador compila con el comportamiento de 2008 R2, y desde el nivel 130 Microsoft agrega las mejoras de planes solo
a los niveles nuevos.

**Rúbrica (sobre 3 puntos):** 1 punto por el 100 y su fuente; 1 por la pregunta a Verónica, que es una consulta y no una opinión
(`SELECT name, compatibility_level FROM sys.databases`); 1 por el porqué de ss03: el *parameter sniffing* y sus mitigaciones
recientes dependen del nivel, así que el mismo problema tiene otras salidas según la respuesta.

### Ejercicio 12

```sql
-- postgres
SELECT count(*) AS con_fecha_de_dos_cifras,
       count(*) FILTER (WHERE (regexp_match("Nombre", '(?:^| )\d{1,2}/\d{1,2}/(\d{2})(?: |$)'))[1]::int BETWEEN 30 AND 49)
         AS anio_30_a_49
FROM legacy."Pacientes" WHERE "Nombre" ~ '(?:^| )\d{1,2}/\d{1,2}/\d{2}(?: |$)';
```

```text
 con_fecha_de_dos_cifras | anio_30_a_49
-------------------------+--------------
                    1612 |          115
```

De 1.612 nombres con fecha de dos cifras, 115 tienen el año entre `30` y `49`: la franja en la que Windows dice 19xx y SQL Server
dice 20xx. Son **exactamente** las 115 fechas distintas de la Fase 04. La cota es la diferencia entera: fuera de esa franja, las dos
ventanas coinciden, y por eso ni una fecha más difiere.

---

## 🟠 Difícil (13–17)

### Ejercicio 13

**Solución.** La consulta es la última de `02_bulk_insert.sql`, y la apuesta se resuelve comparando sus dos números con los de
Postgres (1.142.443 y 3.649). Lo que hay que explicar con la documentación: `KEEPNULLS` dice que un campo vacío recibe NULL en
lugar del valor por defecto de la columna, y `FORMAT = 'CSV'` remite a RFC 4180, que no define NULL. La pregunta es qué considera
`BULK INSERT` "campo vacío": si `""` cuenta como vacío, los 3.649 son NULL. Si tu resultado da 1.146.092 NULL y 0 vacías, la
apuesta se ganó y `BULK INSERT` no sirve para esta caja, aunque el archivo esté en UTF-8. No publiques los números.

### Ejercicio 14

**Solución de referencia.** El servidor solo lee UTF-8, así que la conversión va antes, fuera del contenedor, y el archivo
convertido se le acerca al servidor:

```bash
iconv -f latin1 -t utf-8 "$LAB_CAJA/m/tablas/Pacientes.csv" > Pacientes-utf8.csv
docker cp Pacientes-utf8.csv alameda-lab-sqlserver-1:/tmp/Pacientes-utf8.csv
./sqlcmd.sh -Q "USE ss01_pruebas; TRUNCATE TABLE dbo.Pacientes;
  BULK INSERT dbo.Pacientes FROM '/tmp/Pacientes-utf8.csv'
  WITH (FORMAT = 'CSV', FIRSTROW = 2, ROWTERMINATOR = '0x0d0a', KEEPNULLS, KEEPIDENTITY);
  SELECT COUNT(*) AS filas, SUM(CASE WHEN Edad LIKE N'%ñ%' THEN 1 ELSE 0 END) AS edades_con_enie FROM dbo.Pacientes;"
docker exec -u 0 alameda-lab-sqlserver-1 rm /tmp/Pacientes-utf8.csv
```

La comprobación tiene que dar los números de la caja: **242.427 filas y 59.326 edades con eñe**, las mismas que cuenta Postgres
(`count(*) FILTER (WHERE "Edad" LIKE '%ñ%')` sobre `legacy."Pacientes"`). El `rm` va con `-u 0` porque el archivo que copia
`docker cp` queda de `root` y el proceso de SQL Server corre como `mssql`.

**Rúbrica.** Una respuesta correcta tiene que:
- convertir antes de cargar, fuera del servidor, y decir por qué no se puede dentro (`CODEPAGE`, Msg 16202);
- comprobar la eñe contra el número de Postgres, no "a ojo";
- notar que esta carga sigue sin distinguir `""` de NULL en las columnas de texto (la apuesta del ejercicio 13).

Y queda invalidada si cambia `lab load` o escribe dentro de la caja.

### Ejercicio 15

**Solución.** La consulta es `05_comparar.py`, y la apuesta se resuelve con las dos líneas bajo `🔒 PRIVADO`. Si da cero
diferencias entre el original y el port, el port de la Fase 04 era fiel y las 3 y 115 diferencias contra 2026 son las de
siempre. Si alguna fila difiere, la búsqueda empieza por los tres lugares donde T-SQL y PL/pgSQL se separan sin que se note:
`LEN` y los espacios finales, `TRY_CONVERT(date, …, 3)` con un año de una cifra o un día sin cero adelante, y `CHARINDEX` con un
texto vacío. No publiques el número.

**Rúbrica.** Una respuesta correcta resuelve la apuesta en la máquina del lector, y para cada fila distinta, si la hay, da la
línea del T-SQL y la del port que la explican.

### Ejercicio 16

**Predicción:** el 3 de abril. Para un login con idioma `Spanish`, cada sesión empieza con el orden de fecha de ese idioma, `dmy`,
y la documentación de `datetime` dice que el formato `aaaa-mm-dd` sin `T` depende de ese orden: se lee como año, día, mes. Un
reporte que convierte texto a `datetime` da un 4 de marzo para el usuario en inglés y un 3 de abril para el de español, con la
misma consulta y los mismos datos.

```sql
-- sqlserver
CREATE LOGIN reportes_es WITH PASSWORD = 'Reportes-2026-pass', DEFAULT_LANGUAGE = Spanish, CHECK_POLICY = OFF;
-- y, conectado como reportes_es:
SELECT @@LANGUAGE AS idioma, CAST('2026-03-04 00:00:00.000' AS datetime) AS fecha;
-- al terminar, como sa:
DROP LOGIN reportes_es;
```

La salida la ves tú. Lo que se publica es el mecanismo, y se puede comprobar sin el resultado: `SELECT dateformat FROM
sys.syslanguages WHERE name = N'Español'` da `dmy`.

### Ejercicio 17

```sql
-- postgres
SELECT count("FechaNac") AS con_fecha,
       count(*) FILTER (WHERE extract(day FROM "FechaNac") <= 12) AS dia_1_a_12
FROM legacy."Pacientes";
```

```text
 con_fecha | dia_1_a_12
-----------+------------
    239971 |      95265
```

**95.265 de 239.971 fechas de nacimiento (39,7 %)** tienen el día entre 1 y 12: son las que una carga desde texto con una sesión
`dmy` daría vuelta en silencio, porque el día también es un mes válido. Las demás fallarían con el Msg 242. La consulta de SQL
Server que lo comprueba, sin publicar su resultado, carga la columna como texto y compara las dos lecturas:

```sql
-- sqlserver
SET LANGUAGE Spanish;
SELECT COUNT(*) AS dadas_vuelta
FROM dbo.Pacientes AS p
CROSS APPLY (SELECT CONVERT(varchar(23), p.FechaNac, 121) AS texto) AS t
WHERE TRY_CAST(t.texto AS datetime) IS NOT NULL AND TRY_CAST(t.texto AS datetime) <> p.FechaNac;
SET LANGUAGE us_english;
```

`CONVERT(…, 121)` escribe la fecha como la escribió `bcp`, y `TRY_CAST` la vuelve a leer con el idioma de la sesión.

---

## 🔴 Muy difícil (18–20) — rúbrica

### Ejercicio 18

*La tercera apuesta.*

**Rúbrica (sobre 4 puntos):** 1 punto por resolverla con las dos conexiones y sin publicar el resultado; 1 por explicar la
diferencia entre lo que dice la documentación ("immediately") y lo que ve cada conexión, como hipótesis que se verifica y no como
afirmación; 1 por la instrucción al equipo de Verónica: el cambio se hace en una ventana, y las aplicaciones con *pool* de
conexiones se reinician o se reciclan después, porque una conexión vieja del *pool* puede seguir leyendo el corte anterior; 1 por
el riesgo: cada base y cada aplicación de la instancia pasa a leer distinto todo año de dos cifras del `30` al `49`.

### Ejercicio 19

*Una sola regla.*

**Solución de referencia.** Una columna `FechaNacParseada date NULL` en `Pacientes`, llenada **una vez** por un proceso que lee el
nombre con la regla que Norma elija (la de VBA, que es la que vio cada recepcionista), con las 115 dudosas en una tabla de
revisión. Desde ese día, `fn_ExtraerFecha` deja de leer el nombre y devuelve la columna; el frontal la muestra en el formulario y
la escribe al dar de alta, con el año de cuatro cifras obligatorio en la máscara de entrada. Un `CHECK (FechaNacParseada <=
FechaAlta)` hace en el motor la validación que Rubén puso en el formulario en 2000.

**Rúbrica (sobre 4 puntos):** 1 punto por guardar el resultado en lugar de recalcularlo; 1 por quién decide las 115 (Norma, con
una tabla de revisión); 1 por el cambio en el frontal (sin él, el nombre sigue siendo la fuente); 1 por la restricción en el
motor.

### Ejercicio 20

*Lo que el motor hacía por su cuenta.*

**Rúbrica (sobre 5 puntos):** 1 punto cada dos comportamientos con su fuente, su efecto al migrar y su fase, hasta 4 puntos, y 1
por ordenarlos por riesgo. Los de esta fase son seis: la intercalación `CI_AS` (Fase 05), el corte de 2049 (Fase 04), el idioma de
la sesión al leer `datetime` (Fase 01, la carga), el redondeo de `datetime` a 1/300 s (Fase 07), `LEN` sin espacios finales (Fase
04) y las claves `NOCHECK` que el optimizador ignora (Fase 04). Valen también los que aparecen en el resto del track: `READ
COMMITTED` con bloqueos por defecto y RCSI apagado ([ss02](../ss02-pesimista-contra-rcsi.md)), Query Store encendido por defecto
en una base nueva ([ss03](../ss03-query-store-y-parameter-sniffing.md)), la clave primaria agrupada sin pedirla
([ss04](../ss04-clustered-newsequentialid-y-temporales.md)), y `SET ANSI_NULLS` y `QUOTED_IDENTIFIER`, que el script de SSMS fija
en cada lote porque cambian cómo se compara con NULL y qué significan las comillas dobles.

---

## 🔥 Opcionales

### Ejercicio 🔥 1

**Rúbrica.** Un `compose.override.yaml` con un servicio `sqlserver-standard`, la misma imagen, `MSSQL_PID: StandardDeveloper`,
otro volumen y otro puerto. `SELECT SERVERPROPERTY('Edition')` dice *Standard Developer Edition (64-bit)*. La lista sale de la
página *Editions and supported features of SQL Server 2025*: lo que el track toca y es de Enterprise (las operaciones de índice
en línea, por ejemplo) se marca con la fase que lo usa. Ojo con la memoria: dos instancias de SQL Server emuladas son 4 GB de
`mem_limit` ([`a02`](../a02-compose-de-la-ruta.md#-memoria-por-servicio)).
