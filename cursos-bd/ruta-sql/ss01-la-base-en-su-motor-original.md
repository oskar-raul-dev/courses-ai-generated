# 🪟 SQL Server 01 — La base en su motor original: la caja de vuelta en SQL Server, y el T-SQL de Matías tal cual

> **Curso:** Ruta SQL · Track SQL Server · ss01 de ss05 · **8 h** · opcional
> **Motor:** SQL Server 2025 CU9 (17.0.5005.3), Enterprise Developer, `mcr.microsoft.com/mssql/server@sha256:2b5b58162112…` · emulado en Apple Silicon
> **Entorno de ejecución:** SQL (T-SQL) + Python
> **Requisito del camino base:** Fase 04 · **Requisito de máquina:** en un Mac con Apple Silicon, **Docker Desktop**; en Podman la imagen no arranca ([`a01`](a01-laboratorio-contenerizado.md#-podman-al-lado), [`a08`](a08-catalogo-de-errores.md#e-06--sql-server-en-podman-con-libkrun) E-06 y E-07)
> **El dolor de Alameda:** la caja salió de SQL Server con `bcp` y no vuelve a entrar con `bcp` ([historia](00-historia-de-alameda.md), 2011 y 2016)
> **Fecha de verificación ejecutada:** 18/10/2026
> **Objetivo:** cargar la caja M en SQL Server sin perder nada de lo que distingue, correr el T-SQL de 2016 sin tocar una línea, y explicar con la documentación las dos ventanas de fecha que separan al frontal de los reportes.

---

## 🧭 1. Dónde estamos

Todo el curso leyó la base de Alameda en Postgres, cargada desde la caja. Pero la base de Matías no vive en Postgres. Vive en
**SQL Server**, desde que en 2011 el asistente de Access pasó las tablas a una instancia Express. En 2014 la base llegó al techo
de 10 GB de Express y pasó a Standard, donde sigue en 2026. Este track pone la caja de vuelta en su motor original, para ver dos
cosas que desde Postgres no se ven: lo que el motor de origen hacía por su cuenta y nadie escribió, y lo que de verdad cambia al
migrar.

Esta fase es la puerta del track. Carga la caja, lee lo que el script de SSMS dejó en el catálogo y corre el T-SQL de Matías tal
cual: las dos funciones de `tsql/fn_ExtraerDNI.sql` que la [Fase 04](04-un-valor-un-hecho.md) portó a PL/pgSQL para medir sus
dos diferencias con el VBA. Allá se midió una copia. Acá corre el original.

Vale para todo el track: **de SQL Server no se publica ningún número**. La licencia de Developer lo prohíbe sin permiso escrito de
Microsoft ([`a09`](a09-licencias-publicacion-y-riesgo.md#-sql-server-la-cláusula-tal-cual)). Se publican los mensajes de error, la
estructura de un plan, los conteos de la caja y el comportamiento documentado; el resto va como apuesta sin resolver, con el comando
para resolverla en tu máquina.

> 📝 **La edición del laboratorio no es la de Alameda.** `MSSQL_PID=Developer` levanta *Enterprise Developer*: en 2025 Microsoft
> partió Developer en dos, *Enterprise Developer* y *Standard Developer* ([`a02`](a02-compose-de-la-ruta.md)). Alameda tiene
> Standard. Nada de esta fase depende de la diferencia; donde otra fase del track dependa, lo dirá.

---

## 🎯 2. Objetivos de esta fase

1. Reproducir por qué la caja no vuelve a entrar con `bcp in` ni con `BULK INSERT`, con el mensaje literal de cada intento.
2. Cargar la caja M entera con `lab load --engine sqlserver` y comprobar contra Postgres que los NULL, los vacíos y las eñes
   llegaron como salieron.
3. Leer en el catálogo lo que el script de SSMS dejó y nadie decidió: la intercalación, las claves agrupadas, las identidades y
   las cuatro claves foráneas deshabilitadas.
4. Correr `fn_ExtraerDNI` y `fn_ExtraerFecha` sin tocar una línea, y escribir la apuesta que las compara con su port de la Fase 04.
5. Explicar con la documentación de Microsoft el corte de 2049 y la dependencia del idioma de sesión, y romper una carga con ella.

---

## 🚫 3. Qué NO entra todavía

- **Los bloqueos de `READ COMMITTED` y el formulario del almuerzo** → [ss02](ss02-pesimista-contra-rcsi.md).
- **Los planes de la consulta por sede y Query Store** → [ss03](ss03-query-store-y-parameter-sniffing.md).
- **La clave agrupada como decisión de diseño** (aquí solo se lee) → [ss04](ss04-clustered-newsequentialid-y-temporales.md).
- **Instalar SQL Server en Windows, SSMS y la autenticación integrada** → [ssa-01](ssa-01-que-cambia-en-windows.md).
- **Migrar Alameda a SQL Server**: no es la propuesta de nadie, y el comité de la [Fase 26](26-el-comite.md) no la discutió.

---

## 🏚️ 4. El dolor, en la caja

El LEEME de la caja lo dice en la segunda línea: *"todas las tablas de ALAMEDA, una por archivo, sacadas con bcp. Separador coma,
texto entre comillas. Los NULL quedan vacíos y sin comillas; un texto vacío queda `""` (no es lo mismo, ojo)."* Lo natural es
devolverlas con la misma herramienta. `01_bcp_in.sh` lo intenta con dos tablas, en una base de pruebas aparte:

```text
== bcp in de Sedes: texto (-c), separador coma, salteando el encabezado (-F 2)
SQLState = 22001, NativeError = 0
Error = [Microsoft][ODBC Driver 18 for SQL Server]String data, right truncation
…
#@ Row 1, Column 1: String data, right truncation @#
"C"	"Laboratorio Central"	"RIVADAVIA 521"	"1996-03-01 00:00:00.000"
== bcp in de Pacientes, conservando la identidad (-E)
SQLState = 22008, NativeError = 0
Error = [Microsoft][ODBC Driver 18 for SQL Server]Invalid date format
…
#@ Row 1, Column 4: Invalid date format @#
1	"RODRIGUEZ CAMILA"	"19056268"	"1968-06-17 00:00:00.000"	"28a"	…
```

`bcp` en modo texto no entiende comillas: la sede `C` llega como `"C"`, tres caracteres, a una columna `nvarchar(1)`, y la fecha
llega con sus comillas a una `datetime`. Una coma dentro de una dirección correría además las columnas siguientes. Con `bcp` pelado
esta caja no sale así: hace falta un archivo de formato o una consulta que ponga las comillas, y ninguno viaja con la caja.

El segundo intento es `BULK INSERT`, que desde SQL Server 2017 entiende CSV de verdad (`FORMAT = 'CSV'`, RFC 4180). Lee el
archivo del lado del servidor, que tiene la caja montada en `/caja`. `02_bulk_insert.sql` prueba cuatro cosas, y la primera
falla antes de leer una fila:

```text
Msg 16202, Level 15, State 3, Server a07be756749e, Line 3
Keyword or statement option 'CODEPAGE' is not supported on the 'Linux' platform.
```

En Windows, `CODEPAGE = '65001'` dice que el archivo es UTF-8. En Linux la documentación de `BULK INSERT` dice que la opción no se
admite (en 2019, solo `'RAW'`). Sin ella, `Sedes`, en UTF-8, entra con *Alta Córdoba* bien escrita. `Pacientes`, en Latin-1, no:

```text
Msg 4879, Level 16, State 1, Server a07be756749e, Line 2
Bulk load failed due to invalid column value in CSV data file /caja/m/tablas/Pacientes.csv in row 6, column 5.
Msg 7399, Level 16, State 1, Server a07be756749e, Line 2
The OLE DB provider "BULK" for linked server "(null)" reported an error. The provider did not give any information about the error.
```

La fila 6 es el paciente 5, y su columna 5 es la edad: `43 años`, con una eñe de un byte que no es UTF-8 válido.

La cuarta prueba carga `Protocolos`, en UTF-8, y entra entera. ¿Entró **igual**? En Postgres, `COPY … (FORMAT csv)` respeta la
diferencia que avisa el LEEME, y la caja M tiene **1.142.443 protocolos con `ObraSocial` NULL y 3.649 con la cadena vacía**. Qué hace `BULK INSERT` con esos 3.649 es la
primera apuesta del track (sección 7).

> 🏚️ **De la caja:** `ObraSocial` vacía no es lo mismo que sin obra social. La [Fase 03](03-lo-que-sql-le-hace-al-modelo.md)
> contó por separado los protocolos que la presentación de Rubén perdía con la obra social NULL y con `''`, y mostró que en Oracle
> la cadena vacía es NULL. Una carga que junta los dos casos cambia lo que esa consulta cuenta, sin avisar.

---

## 🧩 5. La base en su motor

### 5.1 Lo que el script de SSMS dejó

La caja trae `esquema/ALAMEDA.sql`, el script que genera el Management Studio con *Generar scripts*: 4.992 líneas, un
`CREATE TABLE` por tabla con sus `SET ANSI_NULLS ON` y `SET QUOTED_IDENTIFIER ON`, y al final las claves foráneas. `lab load
--engine sqlserver` lo corre tal cual, lote por lote, partiéndolo en sus líneas `GO` como hace `sqlcmd`. Después, `03_esquema.sql`
lee el catálogo:

```text
intercalacion                   nivel_de_compatibilidad
SQL_Latin1_General_CP1_CI_AS    170

tablas con_pk agrupadas con_identity
419    66     66        32

name                         tabla          referencia     is_disabled is_not_trusted
FK_Comprobantes_Protocolos   Comprobantes   Protocolos     1           1
FK_Protocolos_ObrasSociales  Protocolos     ObrasSociales  1           1
FK_Protocolos_Pacientes      Protocolos     Pacientes      1           1
FK_ResultadoItem_Protocolos  ResultadoItem  Protocolos     1           1
```

Son conteos del script, no del motor. Lo que el catálogo agrega es **qué significan**: cuatro cosas que nadie en Alameda decidió.

**La intercalación.** `SQL_Latin1_General_CP1_CI_AS` es la que SQL Server elige por defecto para el inglés de Estados Unidos.
`CI` es *case insensitive*: `'peña' = 'PEÑA'` es verdadero. `AS` es *accent sensitive*: `'PENA' = 'PEÑA'` es falso. Durante quince
años, cada `WHERE Nombre = …` de Matías ignoró las mayúsculas sin que nadie lo pidiera, y las identidades de 2011 que se llaman
`id`, `ID` e `Id` son, para este motor, el mismo nombre.

**Las 66 claves primarias son agrupadas.** `PRIMARY KEY CLUSTERED` es lo que SSMS escribe si nadie dice otra cosa: la tabla **es**
el índice de su clave, y las filas están guardadas en ese orden. En Postgres una tabla es un montón (*heap*) y la clave primaria es
un índice aparte. La [Fase 10](10-identificadores.md) midió lo que eso cambia con MySQL, que también agrupa por la clave, y
[ss04](ss04-clustered-newsequentialid-y-temporales.md) lo mide en este motor.

**Las cuatro claves foráneas de 2011 están deshabilitadas y no son de confianza.** El script dice `WITH NOCHECK ADD CONSTRAINT`
y, en el lote siguiente, `NOCHECK CONSTRAINT`. Lo primero crea la restricción sin mirar los huérfanos que ya había; lo segundo
la apaga. La documentación de `ALTER TABLE` es explícita: una restricción creada así queda marcada `is_not_trusted`, y **el
optimizador no la usa** para simplificar un plan. Alameda tiene desde 2011 cuatro claves foráneas que ni protegen ni ayudan. La
Fase 04 encontró los 2.150 resultados huérfanos que explican por qué se apagaron.

**El nivel de compatibilidad, 170.** Es el de SQL Server 2025, porque la base se creó en este motor. La base real de Alameda,
restaurada desde 2008 R2 y pasada por Standard, probablemente siga en un nivel viejo, y eso cambia qué optimizador corre. Es una
pregunta para Verónica (ejercicio 11), y [ss03](ss03-query-store-y-parameter-sniffing.md) la usa.

### 5.2 La carga que sí devuelve la caja

`lab load --engine sqlserver` no usa `bcp in` ni `BULK INSERT`. Lee cada CSV en Python, con el módulo `csv` y la codificación de
cada tabla, y lo manda al servidor por la **copia masiva de TDS**: el mismo protocolo que usa `bcp`, desde el *driver*. Así
resuelve los tres problemas de la sección 4: las comillas las entiende el lector de CSV, la Latin-1 se decodifica en el cliente, y
`""` se distingue del campo vacío con `csv.QUOTE_NOTNULL`, que desde Python 3.12 devuelve `None` solo para el vacío sin comillas.

```bash
uv run --extra sqlserver lab up sqlserver
uv run --extra sqlserver lab load --engine sqlserver --profile m
```

```text
Cargando el perfil m (caja 258082ddb7fa, semilla 1996) en sqlserver …
  sqlserver: 419 tablas (🔒 el tiempo de SQL Server no se muestra)
```

Cada tabla se cuenta contra el manifiesto del generador, como en los otros motores
([`a05`](a05-la-caja-y-el-generador.md#-lab-load-en-cada-motor)). `--private` muestra el tiempo, para ti.

El *driver* es **`mssql-python`**, el oficial de Microsoft (MIT, con el ODBC Driver 18 adentro bajo licencia de Microsoft), en un
extra del proyecto para que el camino base no lo instale. Está fijado en la 1.15.0 (11/09/2026): la 1.16.0 salió el 13/10/2026. En
Linux necesita tres bibliotecas del sistema que la *wheel* no trae (sección 12).

> 🩻 **Esto sí funciona igual.** El tipo de cada columna: `legacy` tradujo uno a uno los del script de SSMS en la Fase 01. Una
> consulta de la caja que no compare textos ni dependa del orden físico lee los mismos datos: **los conteos por tabla son
> idénticos, y los da el generador.**

### 5.3 El T-SQL de Matías, tal cual

`04_parser_2016.sh` corre `tsql/fn_ExtraerDNI.sql` con el `sqlcmd` del contenedor, sin tocar una línea, con su comentario de 2016:
*"Mismo comportamiento que el VBA a la fecha. Si se cambia el VBA hay que cambiar esto también"*. Crea `dbo.fn_ExtraerDNI` y
`dbo.fn_ExtraerFecha`, las que la Fase 04 portó a `staging.extract_dni_2016` y `staging.extract_birth_date_2016`. El port, contra la
versión de 2026, se publica:

```text
── publicable: el port de 2016 en Postgres contra la versión de 2026 (la Fase 04)
port 2016 (Postgres) contra 2026 (Python): DNI distinto 3 {'OTRO': 3} · fecha distinta 115
    'CORDOBA MONICA DNI 6659374 12/03/46': 2046-03-12 · 1946-03-12
    'HUANCA FLORES LAURA DNI A8069632 18/07/47': 2047-07-18 · 1947-07-18
    'MORALES NICOLAS MIGUEL DNI 5994305 19/04/36': 2036-04-19 · 1936-04-19
```

`05_comparar.py` hace eso mismo y dos comparaciones más, contra las funciones nativas, que salen bajo un encabezado `🔒
PRIVADO`. Esas dos son la apuesta de la sección 7.

Hay dos cosas del T-SQL que no se notan leyéndolo y que el port tuvo que imitar a mano. **`TRY_CONVERT` devuelve NULL** donde
`CONVERT` daría un error: una fecha imposible como `31/02/46` no corta el reporte, solo se pierde. Y **`LEN` no cuenta los
espacios finales**: `LEN(N'abc  ')` es 3, según la documentación. El port de la Fase 04 recorta el nombre con `btrim` al
entrar, y con eso ningún largo del bucle ve un espacio final. Un traductor automático de T-SQL a PL/pgSQL pierde este tipo de detalle.

### 5.4 Las dos ventanas de fecha

La diferencia de 115 fechas tiene una causa que Microsoft documenta. La opción de instancia `two digit year cutoff` vale **2049**
por defecto: un año de dos cifras del `00` al `49` es 20xx, y del `50` al `99` es 19xx. La documentación da el ejemplo exacto:
`49` es 2049 y `50` es 1950. VBA no lee esa opción: usa la regla de Windows, que corta en **2029**. Un `19/04/36` es 1936 en el
frontal y 2036 en el reporte, y por eso Morales nació un siglo después en los reportes de Matías.

`06_ventana.sql` muestra la opción y las cinco fechas de prueba con el estilo 3 (`dd/mm/aa`) que usa `fn_ExtraerFecha`:

```text
name                   minimum maximum config_value run_value
two digit year cutoff  1753    9999    2049         2049
```

La opción es de la **instancia**, avanzada, y se cambia con `sp_configure`. Llevarla a 2029 alinearía los reportes con el frontal y
cambiaría la lectura de toda otra base y aplicación de esa instancia. La documentación agrega una tercera ventana: **OLE Automation
corta en 2030**. Tres ventanas para el mismo `36`, y la recomendación de Microsoft es la única que las evita: *"always use four-digit
years in your data"*.

> 💡 **Una regla, tres sitios.** El año de dos cifras no es un dato: es un dato más una regla de interpretación, y la regla vive en
> Windows, en una opción de la instancia y en la configuración de OLE Automation. Cuando la Fase 04 guardó la fecha como `date`,
> eligió una regla una sola vez y la dejó escrita.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

Contra Postgres, que es el que publica números, cinco diferencias cambian una decisión. Los tipos, los conteos y la lógica de las
funciones se trasladan igual.

**La carga.** `COPY … (FORMAT csv, ENCODING 'LATIN1')` lee la caja del lado del servidor, con la codificación por tabla y la
diferencia entre `""` (cadena vacía) y el vacío sin comillas (NULL): es la carga de la [Fase 01](01-la-caja-y-el-arnes.md). En
SQL Server para Linux, la carga del servidor no lee Latin-1, y una carga fiel pasa por el cliente.

**La comparación de textos.** En Postgres `'peña' = 'PEÑA'` es falso; para ignorar mayúsculas hay que pedirlo (`ILIKE`, `lower()` o
una intercalación ICU no determinística). En SQL Server la base entera viene insensible. Quien porte el emparejamiento de la
[Fase 05](05-una-persona-no-es-su-documento.md) decide la intercalación antes que el algoritmo.

**El tiempo.** `datetime` redondea a `.000`, `.003` y `.007` segundos, la documentación desaconseja usarlo en trabajo nuevo, y lee
una cadena según el idioma de la sesión (sección 8). `timestamp(3)` guarda el milisegundo, y Postgres lee `2026-03-04` como 4 de
marzo con cualquier `DateStyle`.

**Las claves no validadas.** Postgres tiene `ADD CONSTRAINT … NOT VALID`: no mira lo que hay, **pero controla lo nuevo**, y
`VALIDATE CONSTRAINT` valida después sin bloquear escrituras. Las de Alameda, además, están apagadas.

**El nivel de compatibilidad.** Postgres no tiene: una base restaurada en una versión nueva usa el optimizador nuevo. SQL Server deja
elegir, base por base, con qué comportamiento compila, y así una base de 2011 puede seguir compilando como en 2011.

---

## 🪞 7. Tu instinto dice… y la apuesta

*"Si la caja salió de SQL Server con `bcp`, vuelve a entrar igual con la herramienta de carga del propio SQL Server. Y si el T-SQL
de Matías se portó línea a línea, el original y el port dan lo mismo."* Es razonable: es el mismo motor de un lado y del otro, y
la Fase 04 portó con cuidado.

Tres apuestas, escritas antes de correr nada en SQL Server y publicadas sin resolver.

> 🪞🔒 **Apuesta sin resolver: SQL Server.** Hipótesis: `BULK INSERT … WITH (FORMAT = 'CSV', KEEPNULLS)` sobre
> `Protocolos.csv` **no conserva los 3.649 `""`** de `ObraSocial` que Postgres sí conserva: llegan como NULL, y la columna tiene
> 1.146.092 NULL en lugar de 1.142.443. Condiciones: perfil M, `ss01_pruebas.dbo.Protocolos` creada por el script. Resuélvela:
> `./sqlcmd.sh < 02_bulk_insert.sql` desde `src/ss01-la-base-en-su-motor-original/`, la última consulta. El mecanismo, en la
> documentación de `BULK INSERT` (`KEEPNULLS` y `FORMAT = 'CSV'`, en las referencias). 📝 No publicamos el resultado: la licencia de
> SQL Server Developer no permite divulgar resultados de pruebas sin permiso de Microsoft
> ([`a09`](a09-licencias-publicacion-y-riesgo.md#-sql-server-la-cláusula-tal-cual)).

> 🪞🔒 **Apuesta sin resolver: SQL Server.** Hipótesis: `dbo.fn_ExtraerDNI` y `dbo.fn_ExtraerFecha`, corridas tal cual sobre los
> 242.427 pacientes de M, dan **exactamente** lo mismo que su port de la Fase 04: cero DNI y cero fechas distintas entre el original
> y el port, y por lo tanto las mismas 3 y 115 diferencias contra la versión de 2026. Condiciones: perfil M en los dos motores, las
> funciones creadas por `04_parser_2016.sh`. Resuélvela: `uv run --extra sqlserver python
> ss01-la-base-en-su-motor-original/05_comparar.py` desde `src/`, las dos líneas bajo `🔒 PRIVADO`.

> 🪞🔒 **Apuesta sin resolver: SQL Server.** Hipótesis: la documentación dice que un cambio de `two digit year cutoff` *"takes
> effect immediately without restarting the server"*. Después de `sp_configure 'two digit year cutoff', 2029; RECONFIGURE`, la
> **misma conexión** que hizo el cambio sigue leyendo `12/03/46` como 2046, y solo una conexión nueva lo lee como 1946.
> Resuélvela: `./sqlcmd.sh < 06_ventana.sql` (la tercera consulta) y después `./sqlcmd.sh < 06b_conexion_nueva.sql`, que además
> deja la opción como estaba.

**Resultado:** sin publicar, por la regla del track. Si la primera se gana, la carga por el cliente deja de ser una preferencia; si
la segunda se pierde, la tabla de rechazos del Bloque I tiene un error que nadie vio.

---

## 💥 8. El punto de rotura

Las fechas de la caja están escritas como las escribió `bcp`: `1968-06-17 00:00:00.000`, con guiones y sin la `T` de ISO 8601. La
documentación de `datetime` es precisa: solo dos formatos de cadena **no dependen** de `SET DATEFORMAT` ni de `SET LANGUAGE`, el ISO
8601 con la `T` (`2004-05-23T14:25:10`) y el que no tiene separadores (`20040523`). Cualquier otro se lee según el orden de fecha del
idioma de la sesión. El contenedor viene en `us_english`, con orden `mdy`. El servidor de Matías, con Windows en español, tenía
orden `dmy`.

`06_ventana.sql` lee la primera paciente de la caja con la sesión en español:

```text
Se cambió la configuración de idioma a Español.
Msg 242, Level 16, State 3, Server a07be756749e, Line 2
La conversión del tipo de datos varchar en datetime produjo un valor fuera de intervalo.
```

Con orden `dmy`, una cadena que empieza por el año se lee **año, día, mes**: `1968-06-17` es el día 6 del mes 17, y la carga se
corta en la primera fila. Esa es la buena noticia. La mala es para los días del 1 al 12, que sí existen como mes: según la misma
regla, `2026-03-04` se lee 3 de abril y sigue de largo. Un `INSERT … SELECT CAST(texto AS datetime)` desde una sesión en español
**cambiaría día y mes en silencio** en más de un tercio de las fechas. `datetime2` y `date` leen `aaaa-mm-dd` igual con cualquier
idioma, según su documentación; el script pone los dos tipos lado a lado para que lo compruebes.

**Qué hay que cambiar para salir:** no convertir fechas desde texto en el servidor. `lab load` manda cada fecha como un `datetime`
de Python, ya convertida, y el motor no interpreta nada. Si hay que convertir en T-SQL, se usa `CONVERT(datetime, texto, 121)`
con el estilo explícito, o `datetime2`. Los dos mensajes, el de `us_english` y el de español, quedan en
[`a08`](a08-catalogo-de-errores.md) como E-78.

---

## ⚰️ 9. Autopsia: copiar el parser en vez de compartirlo

**La decisión, en la voz de Matías, 2016:** *"Los reportes necesitan el DNI del nombre, y la función está en el Access. La copio a
T-SQL, con el mismo comportamiento que tiene hoy, y le pongo un comentario para acordarme."*

**Por qué era razonable.** El VBA no se puede llamar desde el motor, y la alternativa, que el frontal llamara a una función del
servidor, era tocar el formulario de pacientes, que nadie quería tocar.

**Qué pasó después.** El comentario decía *"si se cambia el VBA hay que cambiar esto también"*, y el VBA cambió en 2019 con el
parche de `OTRO`; el T-SQL no. La diferencia de ventana estuvo desde el primer día, porque no estaba en el código de nadie: estaba en
una opción de la instancia y en Windows. En M son **3 DNI y 115 fechas** (la Fase 04, en Postgres). En la base real, con unas ocho
veces más pacientes y si la proporción se mantiene, del orden de novecientas fechas de nacimiento que un reporte y una pantalla no
comparten, y cada una elige otro rango de referencia en el informe.

**Cuánto cuesta salir.** No hay que portar nada: hay que **dejar de tener dos**. La Fase 04 guardó el resultado una vez, en columnas
tipadas con su tabla de rechazos. El costo real es decidir cuál de las dos versiones tenía razón en cada una de las 115 filas, y eso
lo decide Norma, no el motor.

**Qué pregunta lo habría cambiado.** *¿Dónde vive la regla, y cuántas copias tiene?*

**Antes y después, con números (Postgres):** 3 DNI y 115 fechas distintas entre los dos parsers; después de la Fase 04, ninguna,
porque queda una columna y no dos parsers.

---

## 📖 10. Traducción

| SQL Server (T-SQL) | Postgres | Lo que cambia |
|---|---|---|
| `bcp in` / `BULK INSERT … FORMAT = 'CSV'` | `COPY … (FORMAT csv)` | la codificación y el `""` (secciones 4 y 7) |
| `SQL_Latin1_General_CP1_CI_AS` | intercalación determinística, sensible a mayúsculas | `=` encuentra cosas distintas |
| `PRIMARY KEY CLUSTERED` | clave primaria como índice aparte del *heap* | el orden físico ([ss04](ss04-clustered-newsequentialid-y-temporales.md)) |
| `WITH NOCHECK` + `NOCHECK CONSTRAINT` | `NOT VALID` (que sí controla lo nuevo) | en SQL Server, apagada del todo |
| `int IDENTITY(1,1)` | `integer GENERATED … AS IDENTITY` | `SET IDENTITY_INSERT` ↔ `OVERRIDING SYSTEM VALUE` |
| `datetime` | `timestamp(3)` | redondeo a 1/300 s e idioma de sesión |
| `TRY_CONVERT(date, t, 3)` | una función propia con `EXCEPTION` (Fase 04) | Postgres no tiene `TRY_` |
| `two digit year cutoff` | `to_date(t, 'DD/MM/YY')`: el año más cercano a 2020 | el corte es de la instancia, no de la llamada |
| `LEN(x)` (sin espacios finales) | `length(rtrim(x))` | `length` cuenta los espacios |
| `SUM(CASE WHEN EXISTS (…) …)` | se permite | en T-SQL es el Msg 130 (sección 12) |
| `GO` | no existe: es de `sqlcmd` y SSMS, no del motor | separa lotes, no sentencias |

El diccionario completo, en las dos direcciones, está en [`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**No hace falta este track para migrar Alameda.** El camino base leyó la caja entera en Postgres. Esta fase importa si vas a convivir
con SQL Server, y en la [Fase 25](25-la-migracion-sin-parar.md) se convive: legacy sigue viva.

**No cargues la caja con las herramientas del servidor en SQL Server para Linux** si tiene más de una codificación o distingue `""`
de NULL. La carga por el cliente es la que devuelve lo que salió.

**No cambies `two digit year cutoff` para arreglar 115 fechas.** Cambiaría la lectura de toda fecha de dos cifras de todas las bases
de la instancia. Las fechas se arreglan en los datos, una vez, con la decisión de Norma.

**Las cinco preguntas:** el **acceso** es por tabla entera; la **consistencia** que importa es la del archivo con la base, fila por
fila; la **escala** no cambia nada (todo aparece en la fila 6); la **evolución** pide que la regla de interpretación quede en un tipo
y no en una opción; la **operación** pide saber en qué sistema operativo y con qué idioma corre el servidor.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **`bcp in` con la caja:** `String data, right truncation` o `Invalid date format` → modo texto sin comillas → 🩺 el archivo de
  `-e` muestra cada campo con sus comillas → otra herramienta. E-73.
- **`CODEPAGE` en Linux:** `Msg 16202` → la opción no existe en Linux → 🩺 `@@VERSION` dice `on Linux` → el archivo, en UTF-8.
  E-74.
- **Latin-1 en `BULK INSERT`:** `Msg 4879 … in row 6, column 5`, más los 7399 y 7330 → un byte que no es UTF-8 válido → 🩺 `iconv
  -f utf-8 -t utf-8` falla en el mismo lugar → convertir o cargar por el cliente. E-75.
- **El *driver* no carga:** `DDBC Error: Failed to load the driver` → en Debian o Ubuntu faltan `libltdl7`, `libkrb5-3` y
  `libgssapi-krb5-2` → 🩺 `ldd` sobre `libmsodbcsql-18.6.so.2.1` dice `not found` → instalarlas. E-76.
- **Un agregado sobre una subconsulta:** `Msg 130` → `SUM(CASE WHEN EXISTS …)`, que Postgres acepta → una subconsulta por
  columna. E-77.
- **Fecha fuera de intervalo:** `Msg 242` → `aaaa-mm-dd` a `datetime` con idioma `dmy` → 🩺 `@@LANGUAGE` → estilo 121,
  `datetime2`, o convertir en el cliente. E-78.

---

## 📋 13. Checklist de validación

```text
[ ] uname -m dentro del contenedor dice x86_64 (y sabes por qué, si estás en un Mac)
[ ] 01_bcp_in.sh y 02_bulk_insert.sql dan los mensajes de la sección 4
[ ] lab load --engine sqlserver --profile m carga 419 tablas y ninguna difiere del manifiesto
[ ] Protocolos.ObraSocial tiene en SQL Server los mismos NULL y "" que en Postgres (1.142.443 y 3.649)
[ ] 03_esquema.sql muestra las cuatro claves foráneas con is_disabled = 1 e is_not_trusted = 1
[ ] fn_ExtraerDNI y fn_ExtraerFecha existen en ALAMEDA, creadas desde la caja sin editar
[ ] resolviste las tres apuestas de la sección 7 en tu máquina, y no publicaste el resultado
[ ] 06b_conexion_nueva.sql dejó two digit year cutoff en 2049 y las opciones avanzadas ocultas
```

---

## 🧪 14. Ejercicios (20)

## 🟢 Fácil — la caja en su motor (1–6)

### 🟢 Ejercicio 1 — La arquitectura que ve SQL Server

Corre `uname -m` dentro del contenedor (`docker compose -f lab/compose.yaml exec sqlserver uname -m`) y en tu máquina.

**Pregunta:** ¿qué arquitectura ve SQL Server, cuál tiene tu máquina, y qué dice la versión que devuelve `SELECT @@VERSION` sobre
el sistema operativo?

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-1)

### 🟢 Ejercicio 2 — Las comillas que se quedan

Corre `01_bcp_in.sh` y abre el archivo de errores de `Sedes` (`/tmp/sedes.err`, dentro del contenedor).

**Objetivo:** explicar, con la primera fila del archivo de errores, por qué el error es de truncamiento y no de formato.

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-2)

### 🟢 Ejercicio 3 — La carga entera

Carga la caja M con `lab load --engine sqlserver --profile m` y cuenta las tablas de `dbo` con `sys.tables`.

**Objetivo:** el conteo es 419, y `SELECT * FROM lab.loaded` dice el perfil, la semilla y el hash de tu caja, que tiene que
coincidir con el que imprime `lab load` en Postgres.

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-3)

### 🟢 Ejercicio 4 — NULL y vacío

Cuenta en SQL Server los `ObraSocial` NULL y los iguales a `N''` en `dbo.Protocolos`, y lo mismo en `legacy."Protocolos"` de
Postgres.

**Objetivo:** las dos cuentas coinciden con las de la sección 4 (1.142.443 y 3.649), y explicas qué parte de `lab load` lo hace
posible.

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-4)

### 🟢 Ejercicio 5 — La intercalación en una consulta

Busca en `dbo.Pacientes` los nombres que empiezan con `peña ` en minúsculas (`LIKE N'peña %'`), y después con `LIKE N'pena %'`.
La caja guarda los nombres en mayúsculas.

**Pregunta:** ¿qué encuentra cada una, qué parte de `SQL_Latin1_General_CP1_CI_AS` lo explica, y qué devuelve la primera en
`legacy."Pacientes"` de Postgres?

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-5)

### 🟢 Ejercicio 6 — El corte de la instancia

Corre la primera parte de `06_ventana.sql`.

**Pregunta:** ¿qué valor tiene `two digit year cutoff`, qué dice la documentación que significa, y en qué año cae `01/01/49`?

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-6)

## 🟡 Intermedio — leer lo que nadie decidió (7–12)

### 🟡 Ejercicio 7 — Las claves que el optimizador ignora

Con `03_esquema.sql` delante, lee en la documentación de `ALTER TABLE` qué significa `is_not_trusted`.

**Objetivo:** escribir la consulta en la que `FK_ResultadoItem_Protocolos`, si fuera de confianza, le permitiría al optimizador
quitar un join, y explicar por qué hoy no puede.

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-7)

### 🟡 Ejercicio 8 — Volver a confiar

Intenta habilitar y validar `FK_ResultadoItem_Protocolos` con `ALTER TABLE dbo.ResultadoItem WITH CHECK CHECK CONSTRAINT …`.

**Pregunta:** antes de correrlo, ¿falla o pasa, y con qué mensaje? Después de correrlo, ¿cuántos resultados huérfanos explican
el resultado, según la Fase 04?

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-8)

### 🟡 Ejercicio 9 — `LEN` y los espacios

Compara `LEN(N'PEÑA LAURA  ')` con `DATALENGTH(N'PEÑA LAURA  ') / 2`, y cuenta en `legacy."Pacientes"` los nombres con un espacio
al final.

**Objetivo:** explicar la diferencia con la documentación de `LEN`, decir qué hace el port de la Fase 04 para imitarla, y por qué
en la caja no se habría notado aunque no lo hiciera.

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-9)

### 🟡 Ejercicio 10 — `TRY_CONVERT` y la fecha imposible

Prueba `TRY_CONVERT(date, N'31/02/46', 3)` y `CONVERT(date, N'31/02/46', 3)`.

**Objetivo:** explicar qué hace `fn_ExtraerFecha` con un paciente cuyo nombre trae una fecha imposible, y por qué el reporte no
falla.

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-10)

### 🟡 Ejercicio 11 — El nivel de compatibilidad de verdad

La base del laboratorio está en 170 porque se creó aquí.

**Pregunta:** ¿qué nivel tendría la base real de Alameda si se creó en 2008 R2 y se restauró en una Standard más nueva sin cambiarlo?
¿Qué le preguntas a Verónica, y por qué [ss03](ss03-query-store-y-parameter-sniffing.md) necesita la respuesta?

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-11)

### 🟡 Ejercicio 12 — `legacy` en Postgres, sobre la caja

En Postgres, cuenta los `Pacientes` cuyo nombre trae una fecha de dos cifras con año entre `30` y `49`.

**Objetivo:** el conteo acota cuántas fechas pueden diferir entre el frontal y el reporte, y lo comparas con las 115 de la Fase 04.

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-12)

## 🟠 Difícil — cargar sin perder (13–17)

### 🟠 Ejercicio 13 — La primera apuesta

Antes de correr la última consulta de `02_bulk_insert.sql`, escribe qué esperas.

**Objetivo:** resolver la apuesta de `""` en tu máquina y explicar el resultado con la documentación de `KEEPNULLS` y del formato
CSV. No publiques el número.

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-13)

### 🟠 Ejercicio 14 — Latin-1 por el servidor

Sin cambiar `lab load`, carga `Pacientes` con `BULK INSERT` del lado del servidor.

**Objetivo:** una secuencia de comandos que lo logre (convertir el archivo fuera del contenedor, montarlo y cargarlo), y la
comprobación de que las 59.326 edades con eñe llegaron bien.

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-14)

### 🟠 Ejercicio 15 — La segunda apuesta

Corre `05_comparar.py`.

**Objetivo:** resolver la apuesta del parser y, si alguna fila difiere entre el original y el port, encontrar en el T-SQL la línea
que lo explica. No publiques el número.

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-15)

### 🟠 Ejercicio 16 — El idioma de una aplicación

Una aplicación se conecta con un usuario cuyo idioma por defecto es `Spanish` (`CREATE LOGIN … WITH DEFAULT_LANGUAGE = Spanish`).

**Pregunta:** antes de probarlo, ¿qué devuelve para ese usuario `SELECT CAST('2026-03-04 00:00:00.000' AS datetime)`? Pruébalo, y
explica por qué un reporte puede dar fechas distintas según quién lo corra.

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-16)

### 🟠 Ejercicio 17 — Las fechas que se dan vuelta

Con la caja en Postgres, cuenta cuántas `FechaNac` de `Pacientes` tienen día del 1 al 12.

**Objetivo:** ese es el número de fechas que una carga desde texto con una sesión `dmy` cambiaría en silencio, y escribes la
consulta de SQL Server que lo comprobaría sin publicar el resultado.

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-17)

## 🔴 Muy difícil — decidir con lo que el motor hace solo (18–20)

### 🔴 Ejercicio 18 — La tercera apuesta

Resuelve la apuesta del corte en la misma conexión.

**Objetivo:** explicar el resultado y escribir, para el equipo de Verónica, qué tendría que hacer quien cambie la opción en
producción para que todas las aplicaciones la vean, y qué riesgo corre.

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-18)

### 🔴 Ejercicio 19 — Una sola regla

Matías quiere que los reportes y el frontal dejen de discrepar sin esperar a la migración.

**Objetivo:** un diseño en SQL Server (una columna, una restricción, quién la llena y cuándo) que haga que los dos lean la misma fecha,
con lo que cuesta en el formulario de pacientes y en los reportes.

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-19)

### 🔴 Ejercicio 20 — Lo que el motor hacía por su cuenta

Haz un inventario de todo lo que SQL Server decidía por Alameda sin que nadie lo escribiera: lo de esta fase y lo que encuentres.

**Objetivo:** al menos seis comportamientos, cada uno con su fuente en la documentación, con lo que pasa al migrar a Postgres y con
la fase del curso que lo resuelve.

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio-20)

## 🔥 Opcionales

### 🔥 Ejercicio 🔥 1 — Standard Developer

Levanta un segundo contenedor con `MSSQL_PID=StandardDeveloper` (un `compose.override.yaml` con otro servicio y otro volumen),
carga `Pacientes` y compara `SERVERPROPERTY('Edition')`.

**Objetivo:** el laboratorio de Alameda con su edición real, y una lista de lo que ss02 a ss05 usan que la documentación marca como
solo de Enterprise.

[Solución](soluciones/ss01-la-base-en-su-motor-original.md#ejercicio--1)

---

## 📚 15. Referencias

**Documentación oficial de SQL Server 2025**

- **`BULK INSERT`** — https://learn.microsoft.com/en-us/sql/t-sql/statements/bulk-insert-transact-sql?view=sql-server-ver17
  (`CODEPAGE` en Linux, `FORMAT = 'CSV'`, `KEEPNULLS`).
- **La utilidad `bcp`** — https://learn.microsoft.com/en-us/sql/tools/bcp/bcp-utility?view=sql-server-ver17
- **`two digit year cutoff`** — https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/configure-the-two-digit-year-cutoff-server-configuration-option?view=sql-server-ver17
- **`datetime`** (redondeo, formatos y su dependencia del idioma) — https://learn.microsoft.com/en-us/sql/t-sql/data-types/datetime-transact-sql?view=sql-server-ver17
- **`ALTER TABLE`** (`WITH CHECK | WITH NOCHECK`) — https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-table-transact-sql?view=sql-server-ver17
- **`LEN`** — https://learn.microsoft.com/en-us/sql/t-sql/functions/len-transact-sql?view=sql-server-ver17
- **Intercalación y Unicode** — https://learn.microsoft.com/en-us/sql/relational-databases/collations/collation-and-unicode-support?view=sql-server-ver17
- **Variables de entorno de SQL Server en Linux** (`MSSQL_PID`) — https://learn.microsoft.com/en-us/sql/linux/configure/environment-variables?view=sql-server-ver17
- **`mssql-python`** — https://github.com/microsoft/mssql-python

**Postgres, para el contraste:** `COPY` — https://www.postgresql.org/docs/18/sql-copy.html · `ALTER TABLE … NOT VALID` —
https://www.postgresql.org/docs/18/sql-altertable.html

**Libros:** Itzik Ben-Gan, *T-SQL Fundamentals*, 4.ª ed., Microsoft Press, 2023 — los tipos de fecha y su conversión, y las
intercalaciones, en los primeros capítulos.

**Orden de lectura sugerido:** la página de `BULK INSERT` antes de la sección 4; la de `datetime` antes de la 8; Ben-Gan cuando
escribas tu primera conversión de fecha en T-SQL.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 18/10/2026, en la versión 17.x (SQL Server 2025) de la documentación.

---

## 🏁 16. Resultado de la fase

```text
LA CAJA EN SU MOTOR ORIGINAL · perfil M · SQL Server 2025 CU9 · 18/10/2026
  bcp in                          ✗ String data, right truncation · Invalid date format
  BULK INSERT, CODEPAGE           ✗ Msg 16202 (Linux)
  BULK INSERT, Latin-1            ✗ Msg 4879 en la fila 6
  lab load --engine sqlserver     ✓ 419 tablas, cada una contra el manifiesto; NULL y "" como en Postgres
EL CATÁLOGO
  SQL_Latin1_General_CP1_CI_AS · 66 PK agrupadas · 32 IDENTITY · 4 FK deshabilitadas y sin confianza
EL T-SQL DE 2016, TAL CUAL
  fn_ExtraerDNI · fn_ExtraerFecha · contra el port de la Fase 04: 🪞🔒
LAS VENTANAS
  SQL Server 2049 · Windows y VBA 2029 · OLE Automation 2030 · la sesión en español lee aaaa-dd-mm
```

> **La señal de que quedó bien:** *"Puedo decir, para cada cosa que la base de Alameda hacía sola —comparar sin mayúsculas, leer
> un año de dos cifras, apagar una clave—, dónde estaba escrita esa decisión, y la base nueva la tiene escrita en el esquema."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a ss-fase-01-la-base-en-su-motor-original -m "ss01 cerrada: la caja cargada en SQL Server sin perder NULL ni Latin-1, el catálogo de SSMS leído, el T-SQL de 2016 corrido tal cual y las ventanas de fecha"
> ```
>
> Commits de la fase con prefijo `ss01:`, los de ejercicio `ss01 ej14: …`.
