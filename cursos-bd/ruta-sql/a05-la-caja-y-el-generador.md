# 📎 Apéndice a05 — La caja y el generador: Alameda en CSV, con su suciedad y su verdad

> **Curso:** Ruta SQL · Consulta rápida · **3 h**
> **Usado por:** todas las fases · **Versiones cubiertas:** el generador de `src/lab/generator/` con la
> semilla 1996, Python 3.13 y los motores de [`a02`](a02-compose-de-la-ruta.md)
> **Fecha de verificación ejecutada:** 12/10/2026, con los perfiles S y M generados y cargados

**Esto no se lee de corrido.** Se entra por el índice buscando algo concreto y se sale. Este apéndice
explica de dónde sale cada fila que el curso consulta: la caja que Matías le deja al arquitecto nuevo,
el generador que la fabrica, sus tres tamaños, y **la verdad**, que es lo que el generador sabe y la
caja no dice, y lo que permite medir si una limpieza acertó.

**Qué queda fuera:** quién escribió cada tabla y por qué, que es la
[historia de Alameda](00-historia-de-alameda.md); cómo se diseña el modelo nuevo y cómo se cargan sus
tablas, que escribe cada fase; y los clientes de cada motor, que están en
[`a03`](a03-clis-de-los-motores.md).

---

## Índice

- [Generar y cargar, en dos comandos](#-generar-y-cargar-en-dos-comandos)
- [Qué trae la caja](#️-qué-trae-la-caja)
- [Los tres perfiles](#-los-tres-perfiles)
- [El formato de los CSV](#-el-formato-de-los-csv)
- [La suciedad, con sus proporciones](#-la-suciedad-con-sus-proporciones)
- [La verdad del generador](#-la-verdad-del-generador)
- [`lab load` en cada motor](#-lab-load-en-cada-motor)
- [Cómo está hecho el generador](#️-cómo-está-hecho-el-generador)
- [Cuándo usar qué](#-cuándo-usar-qué)
- [Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-6)

---

## 🚀 Generar y cargar, en dos comandos

Desde `src/`, con el laboratorio arriba ([`a01`](a01-laboratorio-contenerizado.md)):

```text
$ uv run lab generate --profile s
Generando el perfil s con la semilla 1996 en …/src/lab/caja/s …
mundo: 20002 personas, 24245 filas de Pacientes, 132065 protocolos (2 s)
  write_people (2 s)
  …
  write_spreadsheets (16 s)
Listo en 17 s: 20002 personas, 24245 filas de Pacientes, 132065 protocolos, 1201086 filas de ResultadoItem.
SHA-256 de la caja: 49cfb8db41947b05ec06c81d0948fbe872f1d57d14d8ba9d293f46e687453fab

$ uv run lab load
Cargando el perfil s (caja 49cfb8db4194, semilla 1996) en postgres …
  legacy: 419 tablas (4 s)
  truth: 6 tablas (6 s)
  postgres: listo en 8 s
```

**Si tu hash no es ese, tu caja no es la del curso**, y ningún número de las fases te va a coincidir.
`lab load` usa S y Postgres por defecto; M se pide con `--profile m` cuando una fase mide.

---

## 🏚️ Qué trae la caja

Lo que Matías copió un sábado a la noche, con su `LEEME.txt` en la raíz. Cada pieza existe por una
razón de la [historia](00-historia-de-alameda.md), y el generador reproduce también la razón: los
nombres de tabla con espacios, los dos juegos de caracteres, las 280 tablas de precios.

```text
src/lab/caja/s/
├── LEEME.txt            la nota de Matías, en Windows-1252 y con CRLF
├── MANIFIESTO.json      semilla, conteos, la prueba de fuego de la Fase 01 y un SHA-256 por archivo
├── tablas/              las 419 tablas de ALAMEDA, una por archivo, como las saca bcp
├── esquema/ALAMEDA.sql  el script de SQL Server: 419 CREATE TABLE, 66 con clave primaria
├── vba/                 ModParser.bas, ModImportarEquipos.bas y ModFolio.bas, del Access
├── tsql/                fn_ExtraerDNI.sql, la copia del parser que Matías hizo en 2016
├── planillas/           seis .xlsx: padrones de obras sociales, el NBU, convenios, COVID
├── turnos/Turnos.csv    el .accdb de turnos de 2008, exportado a CSV
├── archivos/listado.csv las órdenes escaneadas y los PDF que no vinieron: solo su listado
└── truth/               la verdad del generador; no es parte de la caja (ver abajo)
```

🏚️ **Las 419 tablas, por grupo:** 21 del núcleo (`Pacientes`, `Protocolos`, `ResultadoItem`,
`ObrasSociales`, `Comprobantes`…), 71 tablas anchas por práctica anteriores al EAV de 2008
(`Hemograma`, `Quimica`, `Orina`…), 280 `Precios_AAAA_MM` de 2002 a 2025, y 47 que nadie sabe para
qué están (`Copia de Pacientes`, `Errores de pegado`, `Hoja1$`, `Consulta1_resultado`). **353 no
tienen clave primaria**, y las claves foráneas que hay se crearon `WITH NOCHECK`.

Todo es sintético. **Ningún nombre, DNI o número de afiliado es de una persona real**: los nombres
salen de listas de nombres y apellidos comunes, los DNI de un rango plausible para el año de
nacimiento, y los códigos de práctica tienen la forma de los del nomenclador, no sus valores.

---

## 📏 Los tres perfiles

| Perfil | Personas | Filas de `Pacientes` | `Protocolos` | `ResultadoItem` | CSV | Generación |
|---|---|---|---|---|---|---|
| `s` | 20.002 | 24.245 | 132.065 | 1.201.086 | 214 MB | 17 s |
| `m` | 200.002 | 242.427 | 1.327.622 | 12.134.453 | 2,2 GB | 156 s |
| `l` | ≈ 1 M | ≈ 1,2 M | ≈ 6,6 M | ≈ 61 M | ≈ 11 GB | sin generar |

**S es el de todos los días**: carga en 6 s y alcanza para ver cualquier forma. **M es el de las
mediciones publicadas**, y entra con los tres motores en una máquina de 16 GB
([`a02`](a02-compose-de-la-ruta.md#-la-tabla-de-ram)). **L es opcional y nunca lo pide una fase.**
No lo generé: sus cifras salen de multiplicar M por cinco, que es la proporción de personas, y la
caja ocuparía unos 11 GB antes de cargarla. Los hashes de los dos perfiles generados:

```text
s  49cfb8db41947b05ec06c81d0948fbe872f1d57d14d8ba9d293f46e687453fab  (antes de D46)
m  258082ddb7fad956a9435f21de79986e1d2759045c889dc3e7fa47822e5f2e3a
```

> 📝 **Cambio de la caja M (14/10/2026, D46).** Se agregó `truth/antibiogram.csv` (469.863 filas, 60.001 cultivos), con su
> propio flujo aleatorio. Los 439 archivos que ya existían conservan su hash: se comprobó archivo por archivo contra el
> manifiesto anterior, cuyo hash de caja era `3e59292e9918ee259e44c49c928d0b024686019fe070cc9fdca40a97fb2dd465`. Solo cambió
> el hash de la caja entera, que suma el archivo nuevo. La caja `s` gana el mismo archivo, así que su hash de la lista
> de arriba queda sin recalcular hasta que se regenere.

> 📐 **Medición de dimensionamiento** · 12/10/2026 · macOS 26.7.1, Apple M1 Pro · Python 3.13 ·
> reproducir: `time uv run lab generate --profile m`. Los tiempos son contexto: el generador usa un
> solo núcleo.

---

## 📄 El formato de los CSV

Los CSV imitan la salida de `bcp` de SQL Server que describe el `LEEME.txt`, con todo lo que eso
trae:

```text
"IdPaciente","Nombre","DNI","FechaNac","Edad","Sexo","Telefono","Direccion","ObraSocial","NroAfiliado","Sede","FechaAlta"
290,"MEDINA GUSTAVO","21505290",,"","M","4956908",,"A.P.R.O.S.S.",,"J","2003-07-10 00:00:00.000"
```

- **NULL y texto vacío no son lo mismo.** Un campo vacío y sin comillas es NULL (`FechaNac`,
  `Direccion`); `""` es un texto vacío (`Edad`). Postgres los distingue al cargar. MySQL no (ver
  [Advertencias](#️-advertencias)).
- **Fechas con milisegundos** (`2003-07-10 00:00:00.000`), como las escribe `datetime`.
- **Fin de línea CRLF**, porque salieron de Windows.
- **Dos juegos de caracteres, a propósito.** `Pacientes.csv` y `Medicos.csv` están en Latin-1; todo lo
  demás, en UTF-8. Los `.bas` y el `LEEME.txt` están en Windows-1252. `lab load` lo sabe y se lo dice
  a cada motor (`ENCODING 'LATIN1'`, `CHARACTER SET latin1`, `CHARACTERSET WE8ISO8859P1`); tu código
  tiene que saberlo también, y [`a06`](a06-python-java-y-drivers.md) muestra qué pasa si no.

---

## 🧪 La suciedad, con sus proporciones

El generador produce la suciedad que cuenta la historia, con las proporciones que da la historia y,
donde la historia no da cifra, con la que fijó el curso. Medido sobre M:

| Suciedad | Lo que se pidió | En M |
|---|---|---|
| Filas de `Pacientes` que repiten a una persona | 15–20 % (historia, según Matías) | 17,5 % |
| Nacidos en el futuro | 4.000 de 1,9 M, el 0,21 % (historia) | 442, el 0,18 % |
| Documento escrito dentro de `Nombre` | 10,9 % | 10,5 % |
| `ExtraerDNI()` acierta el documento | "el 90 % de los casos" (historia) | 90,1 % (23.048 de 25.575) |
| `DNI` vacío · `DNI` compartido por más de una fila | sin cifra | 10,2 % · 22,8 % |
| Resultados con coma · con punto | 45 % · 45 % | 44,5 % · 44,3 % |
| `< x` · `> x` · `HEMOLIZADA` y similares · vacío | 3 % · 2 % · 2 % · 3 % | 3,0 % · 2,0 % · 2,0 % · 3,0 % |
| Resultados de protocolos borrados (2008–2011), sin su protocolo | los huérfanos por los que en 2011 las claves foráneas se crearon `WITH NOCHECK` (historia) | 2.150 filas de 198 protocolos |

Las desviaciones son las del azar sobre 242.427 filas y 12 millones de resultados: el curso publica
lo que dio la caja, no lo que se pidió. La coma o el punto los decide el **equipo** que midió, como en
la historia: cada analizador exporta con su configuración regional, y cada uno se reemplaza en su año
(`SYSMEX XT-1800i` hasta 2014, `SYSMEX XN-1000` después).

El generador planta también los casos que los boss necesitan, con nombre y apellido. Están en la
verdad, y conviene no buscarlos antes de tiempo.

---

## 🔎 La verdad del generador

El generador sabe lo que la caja no dice: qué filas son la misma persona, qué documento quiso
escribir la recepcionista, qué valor midió el equipo. Lo deja en `truth/`, y `lab load` lo carga en
Postgres, en el esquema **`truth`**. **No es parte de la caja**: Matías no la tenía. Existe para que
una limpieza o una deduplicación se midan contra algo.

| Tabla | Una fila por | Qué dice |
|---|---|---|
| `truth.person` | persona real | sexo, nacimiento, tipo, país y número de documento, el DNI que tuvo después (`later_dni`), la madre y la obra social |
| `truth.patient_record` | fila de `legacy."Pacientes"` | de qué persona es (`person_id`) y qué suciedad tiene (`dirt`, un arreglo) |
| `truth.parser_case` | fila con un documento o una obra social escritos en `Nombre` | el documento (`expected_dni`) y la obra social (`expected_payer`) que se quisieron escribir |
| `truth.order_payer` | fila de `legacy."Protocolos"` | la persona, la obra social real y cómo se escribió en el protocolo |
| `truth.result_value` | fila de `legacy."ResultadoItem"` | el valor numérico, el calificador (`<`, `>`), el texto cualitativo y el estado |
| `truth.planted_case` | caso plantado | la persona y una nota |
| `truth.antibiogram` | cultivo de microbiología, un antibiótico | el cultivo (`culture_id`), la persona, la fecha, el germen y el antibiótico, y la sensibilidad (`S`, `I` o `R`). Verdad estructurada que la caja no trae en forma estructurada: su columna `Urocultivo.Antibiograma` es texto libre (D46) |

Los valores de `dirt` son `dni_in_name`, `name_variant`, `payer_in_name`, `empty_dni`, `other_site`,
`newborn_mother_dni`, `passport_in_dni`, `libreta_and_dni`, `future_birth` y `newborn_other_dni`.
Los de `state`, en `result_value`: `dot`, `comma`, `below`, `above`, `hemolyzed`, `empty` y
`qualitative`.

🩺 **Cómo se usa: se cruza por la clave de `legacy`.** Cuántas filas repiten a una persona:

```sql
-- postgres
SELECT count(*) AS filas,
       count(DISTINCT person_id) AS personas,
       round(100.0 * (count(*) - count(DISTINCT person_id)) / count(*), 1) AS pct_repiten
FROM truth.patient_record;
```

```text
 filas  | personas | pct_repiten
--------+----------+-------------
 242427 |   200002 |        17.5
```

Y qué quiso decir cada `Valor`, al lado de lo que quedó escrito:

```sql
-- postgres
SELECT ri."IdItem", ri."CodDeterminacion", ri."Valor", ri."Equipo", r.value_numeric, r.qualifier, r.state
FROM legacy."ResultadoItem" AS ri
JOIN truth.result_value AS r ON r.legacy_result_item_id = ri."IdItem"
WHERE ri."IdItem" IN (1, 4, 29, 35, 43, 62)
ORDER BY ri."IdItem";
```

```text
 IdItem | CodDeterminacion |   Valor    |      Equipo       | value_numeric | qualifier |   state
--------+------------------+------------+-------------------+---------------+-----------+-----------
      1 | TP               | 13.1       | ACL 7000          |          13.1 |           | dot
      4 | HB               | <4.0       | SYSMEX XT-1800i   |           4.0 | <         | below
     29 | GB               | HEMOLIZADA | SYSMEX XT-1800i   |               |           | hemolyzed
     35 | CREA             | 0,45       | METROLAB 2300     |          0.45 |           | comma
     43 | GB               | >80000     | SYSMEX XT-1800i   |         80000 | >         | above
     62 | T4L              |            | ARCHITECT i1000SR |               |           | empty
```

Esa salida es de M, el 12/10/2026. La regla para usar la verdad: **una fase mide contra `truth`, pero
su solución nunca la lee.** Si tu limpieza consulta `truth` para decidir, no limpió nada.

---

## 📥 `lab load` en cada motor

**Postgres recibe la caja entera** en el esquema `legacy`, con los nombres originales entre comillas
(`legacy."Pacientes"`), más `truth`. **MySQL y Oracle reciben solo las tablas que pide cada fase**,
con `--tables`:

```bash
uv run lab load --profile m --engine mysql --tables Pacientes,Protocolos,ResultadoItem,Practicas
```

Cada motor carga leyendo el CSV desde la caja montada en `/caja`, sin pasarlo por el driver: `COPY` en
Postgres, `LOAD DATA INFILE` en MySQL, tablas externas e `INSERT /*+ APPEND */` en Oracle. **Después
de cada tabla grande, `lab load` compara las filas cargadas con las que escribió el generador** (están
en `MANIFIESTO.json`) y se detiene si no coinciden. Las tablas que tenían clave primaria en SQL Server
la tienen también aquí; las otras 353, no.

| Carga del perfil M | Tiempo en esta máquina |
|---|---|
| Postgres: las 419 tablas y `truth` | 46–51 s |
| MySQL: `Pacientes`, `Protocolos`, `ResultadoItem` y `Practicas` | 37–38 s |
| Oracle: las mismas cuatro | 🔒 no se publica ([`a09`](a09-licencias-publicacion-y-riesgo.md)); `--private` te lo muestra a ti |

**Con `--model`, Postgres recibe además el modelo del Bloque I.** `uv run lab load --profile m --model`
borra los esquemas `staging` y `alameda` y corre en orden los scripts de `src/04-…` a `src/08-…`, con la
planilla de convenios que pide la [Fase 06](06-cuarta-y-quinta-forma-normal.md). Es el punto de partida del
Bloque II: en esta máquina, entre 257 y 274 s después de la carga de la caja.

Qué caja está cargada lo dice `lab.loaded`, en Postgres y en MySQL:

```sql
-- postgres
SELECT profile, seed, left(sha256, 12) AS caja, tables FROM lab.loaded;
```

```text
 profile | seed |     caja     | tables
---------+------+--------------+--------
 m       | 1996 | 3e59292e9918 |    419
```

Los errores que vas a ver, con su salida: `✗ No existe la caja del perfil l …` con la sugerencia
`Genérala con: uv run lab generate --profile l`; `En MySQL y Oracle la caja se carga por tablas:
--tables Pacientes,Protocolos,…` si olvidas `--tables`; y `✗ La caja no tiene estas tablas: Turnos` si
pides una que no está en `tablas/`.

---

## ⚙️ Cómo está hecho el generador

Es Python de biblioteca estándar, en `src/lab/generator/`. Lo que importa saber para leerlo:

- **`world.py` arma el mundo**: las personas reales, las filas de `Pacientes` que la recepción cargó
  para cada una (con su suciedad) y los protocolos. El volumen por año sigue la historia: 25 pacientes
  por día en 1996, unos 180 en 2009, 400 antes del COVID y 3.000 hoy.
- **`tables.py` escribe la caja** a partir de ese mundo, tabla por tabla; `schema.py` declara las 419
  tablas con sus tipos de SQL Server, y de ahí salen `ALAMEDA.sql` y los `CREATE TABLE` de `lab load`.
- **`rubens_parser.py` es un port fiel de `ExtraerDNI()`**: el generador lo corre sobre cada fila y
  anota en el manifiesto cuántas acierta. Es el 90 % de la historia, medido y no supuesto.
- **Cada tabla tiene su propio flujo aleatorio**, derivado de la semilla y de un nombre fijo
  (`random.Random(f"{seed}/{name}")`). Cambiar cómo se generan los protocolos no cambia ni un byte de
  `Pacientes` ni de las 280 tablas de precios: al corregir el generador el 12/10/2026, 354 de los 439
  archivos de S quedaron idénticos.

**Determinismo:** misma semilla, mismos bytes. El `MANIFIESTO.json` guarda un SHA-256 por archivo, y
el de la caja es el SHA-256 de esa lista ordenada. Verificado con Python 3.13.4 en macOS y 3.13.13 en
Linux: el mismo hash.

---

## 🧭 Cuándo usar qué

| Situación | Haz esto | Por qué |
|---|---|---|
| Empiezas | `uv run lab generate` y `uv run lab load` | S en Postgres, en menos de medio minuto |
| Una fase mide | `--profile m` en los dos comandos | los números publicados son de M |
| Una fase usa MySQL u Oracle | `lab load --engine … --tables …` con las tablas de la fase | cargar las 419 no aporta nada |
| Quieres saber si tu caja es la del curso | compara el hash con el de la tabla de perfiles | si no coincide, ningún número va a coincidir |
| Quieres medir una limpieza | crúzala con `truth` por la clave de `legacy` | es lo único que sabe la respuesta |
| Quieres la forma de una consulta sobre la caja | `uv run lab measure`, que lee de `lab.loaded` qué caja está cargada ([`a04`](a04-el-arnes-de-forma.md#-uv-run-lab-measure-y-su-salida)) | bloques y filas examinadas, con el hash de la caja en la primera línea |
| Te falta disco | borra `src/lab/caja/m` | se regenera idéntica |

---

## ⚠️ Advertencias

- **MySQL no distingue NULL de texto vacío al cargar la caja.** En una columna de texto, `LOAD DATA`
  convierte el campo vacío sin comillas en `''`, igual que `""`. En M, `legacy."Pacientes".Edad` tiene
  1.417 NULL y 1.481 textos vacíos en Postgres, y 0 NULL y 2.898 vacíos en MySQL. Si una fase cuenta
  NULL en MySQL, los cuenta sobre una copia que los perdió. **Oracle va al revés:** la documentación
  dice que trata un texto de largo cero como NULL.
- **Para la intercalación de fábrica de MySQL, `Ñ` es `N`.** `utf8mb4_0900_ai_ci` no distingue acentos,
  y `LIKE '%Ñ%'` encuentra también los `MUNOZ`. Es el ejercicio 3.
- **El hash depende de la versión de Python.** El módulo `random` solo garantiza la secuencia de
  `random()` entre versiones, no la de `choice`, `gauss` o `randrange`. El proyecto pide Python 3.13
  por eso; con otra versión, compara el hash antes de comparar un número.
- **`truth` no viaja a MySQL ni a Oracle.** Las mediciones contra la verdad se hacen en Postgres.

---

## 📚 Referencias

> ⚠️ Las URL y sus contenidos cambian. Este apéndice se verificó el 12/10/2026.

- **`bcp` de SQL Server** — https://learn.microsoft.com/en-us/sql/tools/bcp-utility — el formato
  del que salió la caja.
- **`COPY` en Postgres 18** — https://www.postgresql.org/docs/18/sql-copy.html — `FORMAT csv`,
  `HEADER` y `ENCODING`.
- **`LOAD DATA` en MySQL 9.7** — https://dev.mysql.com/doc/refman/9.7/en/load-data.html — cómo trata
  los campos vacíos y `FIELDS ESCAPED BY`.
- **Tablas externas en Oracle** — https://docs.oracle.com/en/database/oracle/oracle-database/23/sutil/oracle_loader-access-driver.html
  — el *driver* `ORACLE_LOADER`, con el que `lab load` lee la caja.
- **Los NULL en Oracle** — https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/Nulls.html
  — por qué un texto vacío es NULL.
- **`random` en Python 3.13** — https://docs.python.org/3.13/library/random.html — qué se garantiza
  entre versiones con la misma semilla.

**Orden sugerido:** los dos comandos el primer día; la suciedad y la verdad antes de la [Fase 01](01-la-caja-y-el-arnes.md); el
formato de los CSV la primera vez que una carga no te dé lo que esperabas.

---

## 🧪 Ejercicios (6)

## 🟢 Fácil — la caja tal cual (1–2)

### 🟢 Ejercicio 1 — Tu caja es la del curso

Genera el perfil S y compara su hash con el de la tabla de perfiles. Después borra
`src/lab/caja/s`, vuelve a generarla y compara otra vez.

**Objetivo:** el mismo hash en las tres corridas, carácter por carácter.

[Solución](soluciones/a05-la-caja-y-el-generador.md#ejercicio-1)

### 🟢 Ejercicio 2 — Lo que cargó Postgres contra lo que escribió el generador

Con M cargado en Postgres, consulta `lab.loaded` y cuenta las filas de `legacy."Pacientes"`,
`legacy."Protocolos"` y `legacy."ResultadoItem"`.

**Objetivo:** que el hash de `lab.loaded` y los tres conteos coincidan con los de
`src/lab/caja/m/MANIFIESTO.json`.

[Solución](soluciones/a05-la-caja-y-el-generador.md#ejercicio-2)

## 🟡 Intermedio — los motores no leen igual (3–4)

### 🟡 Ejercicio 3 — La Ñ en dos motores

Con `Pacientes` de M en Postgres y en MySQL, cuenta las filas cuyo `Nombre` contiene `Ñ`. En MySQL,
repite con `LIKE BINARY`.

**Pregunta:** ¿qué devuelve cada uno, y cuál es la respuesta correcta? ¿Qué buscaría mal una
recepcionista que escribe `MUÑOZ` en un buscador hecho sobre MySQL?

[Solución](soluciones/a05-la-caja-y-el-generador.md#ejercicio-3)

### 🟡 Ejercicio 4 — NULL contra texto vacío

Cuenta en los dos motores cuántas filas de `Pacientes` tienen `Edad` en NULL y cuántas en `''`.
Busca en el CSV una fila de cada caso.

**Objetivo:** explicar la diferencia con las dos filas del CSV a la vista, y decir qué consulta de
MySQL daría un número equivocado por eso.

[Solución](soluciones/a05-la-caja-y-el-generador.md#ejercicio-4)

## 🟠 Difícil — medir contra la verdad (5)

### 🟠 Ejercicio 5 — Medir una limpieza

Escribe una expresión regular que extraiga el DNI escrito en `Nombre` cuando viene después de `DNI`,
`LC` o `LE`, y mídela contra `truth.parser_case`: cuántos extrae, cuántos acierta y cuántos de los
esperados encuentra. Predice antes la precisión y la cobertura.

**Objetivo:** precisión y cobertura con un decimal, y tres filas que tu expresión no encuentra, con la
razón de cada una.

[Solución](soluciones/a05-la-caja-y-el-generador.md#ejercicio-5)

## 🔴 Muy difícil — la caja miente (6)

### 🔴 Ejercicio 6 — Los números de protocolo repetidos

`NroProtocolo` es el número que se imprime en el sobre del paciente. Encuentra cuántos números se
repiten en `legacy."Protocolos"` de M, cuántas filas los llevan y cómo se reparten por año. Lee
`vba/ModFolio.bas` y la [historia](00-historia-de-alameda.md) de 2005.

**Pregunta:** ¿desde cuándo pasa, a qué ritmo, y qué lo explica? ¿Se puede declarar `UNIQUE` hoy sobre
`NroProtocolo`, y qué harías con las filas que lo impiden?

[Solución](soluciones/a05-la-caja-y-el-generador.md#ejercicio-6)

---

> 🏷️ **Este apéndice deja archivos en el repositorio:** `src/lab/generator/`. La caja generada no se
> versiona: se regenera. El commit que lo cierra se etiqueta `apendice-a05-la-caja`.
