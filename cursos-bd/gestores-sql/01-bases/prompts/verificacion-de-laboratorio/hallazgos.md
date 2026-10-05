# 🔬 Hallazgos de la verificación de laboratorio (P8)

> **Qué es esto:** el registro de lo que salió al ejecutar de verdad las herramientas del curso
> —versiones, comportamientos, errores con su mensaje literal y las decisiones que obligan—. Es la
> fuente de la que beben `a01`–`a04`, `a09`, `aca-01` y `aca-02`, y de la que P10 traslada a la guía
> y a las propuestas.
> **Cómo se reproduce:** `Dockerfile`, `compose.yaml` y `requirements.txt` de esta carpeta levantan
> `mdm-lab`; cada comprobación está en `comprobaciones/`, con el comando para correrla en el
> hallazgo que la usa.
> **Dónde corrió:** todo dentro de contenedores (regla 9 del plan), en macOS arm64 con Docker
> Desktop 29.8.0 (kernel de la VM `7.0.12-linuxkit`). Lo que no se puede contenerizar —las recetas
> nativas de macOS y Windows— se consultó en el registro de cada gestor y queda **pendiente de
> Oskar** (§H11).
> **Fecha:** 03/10/2026, salvo donde se diga otra.

---

## 📊 Las versiones fijadas · 03/10/2026

Lo que usa la producción del camino base, y lo que el curso le pide al lector. **El
`requirements.txt` de esta carpeta es el modelo del `src/requirements.txt` de `a02`.**

| Pieza | En `mdm-lab` | Lo que el curso exige | De dónde sale el mínimo |
|---|---|---|---|
| Imagen base | `python:3.14.8-slim-trixie` (índice `sha256:89fb7d3da200…`) | — | — |
| Python | 3.14.8 | **3.10** | `Requires-Python: >=3.10` de Faker 40.40.0; corrido en `python:3.10-slim` (H9) |
| SQLite (CLI) | 3.46.1 (Debian 13) | **3.37.0**, la que introdujo `STRICT` | ver nota de abajo |
| SQLite del módulo `sqlite3` de Python | 3.46.1 | la misma | es la que usa `radb` (H3) |
| `radb` | 3.0.5 | 3.0.5 | la última en PyPI; sin cambios desde el 23/08/2023 |
| SQLAlchemy | **2.0.54** | **`>=2.0,<2.1`** | H2: la 2.1 rompe los tipos de `radb` |
| `antlr4-python3-runtime` | 4.13.2 | 4.13.2 | dependencia de `radb` |
| Faker | 40.40.0 | 40.40.0, fijada | H9: otra versión da otros datos |

> 📝 **El 3.37.0 como mínimo** sale de la documentación de SQLite (`STRICT` llegó en la 3.37.0, de
> noviembre de 2021), no de una prueba con esa versión: ninguna distribución verificada trae una
> anterior (H10). Lo que sí se comprobó es que todas las verificadas la superan.

---

## H1 · `mdm-lab`: el laboratorio de producción · 03/10/2026

**Qué es.** Una imagen `mdm-lab:p8` construida desde el `Dockerfile` de esta carpeta, con SQLite y
`sqlite3-tools` de Debian (para `sqlite3_analyzer`), `git`, y un `venv` en `/opt/venv` con el
`requirements.txt`. El repositorio entero se monta en `/curso`, y el directorio de trabajo es
`/curso/cursos-bd/gestores-sql/01-bases`. Red `mdm-net`, sin puertos publicados.

```bash
cd cursos-bd/gestores-sql/01-bases/prompts/verificacion-de-laboratorio
docker compose up -d --build lab
docker exec mdm-lab radb --help
```

**Lo que trae el `venv`**, de `pip freeze`: `antlr4-python3-runtime==4.13.2`, `Faker==40.40.0`,
`greenlet==3.5.6`, `radb==3.0.5`, `SQLAlchemy==2.0.54`, `typing_extensions==4.16.0`. `greenlet` lo
arrastra SQLAlchemy solo en algunas arquitecturas; no hace falta fijarlo.

---

## H2 · SQLAlchemy 2.1 rompe los tipos de `radb` · 03/10/2026

**Qué pasó.** Con `pip install radb` a secas, pip resuelve SQLAlchemy 2.1.3 (la dependencia declarada
es `SQLAlchemy>=2.0`), y `radb` tipa las columnas `REAL` como `unknown`:

```text
database relations:
  part(part_id:number, name:string, color:string, weight:unknown, city:string)
```

**La causa.** `radb` traduce el tipo de cada columna preguntando si es subclase de
`sqlalchemy.types.Numeric`. En SQLAlchemy 2.1, `Float` (y con ella `REAL`) dejó de heredar de
`Numeric`: su MRO pasa por `NumericCommon`. Con la 2.0.54 vuelve a ser `weight:number`.

**Por qué importa aunque "funcione".** El sistema de tipos de `radb` trata `unknown` como comodín, así
que `\select_{weight > 15} part` sigue respondiendo bien. Pero el esquema que ve el lector miente, y
`\project_{color, weight * 2}` mezcla un `unknown` con un `number` sin que nada avise.

**Decisión.** `requirements.txt` fija `SQLAlchemy==2.0.54`, y `a03` explica en una línea por qué el
curso no deja que pip elija.

---

## H3 · `radb` funciona sobre tablas `STRICT` · 03/10/2026

**La pregunta que podía parar la tanda** (guía §17): sí funciona. `radb` lee el esquema con el
inspector de SQLAlchemy, y una tabla `STRICT` no le cambia nada. **No hace falta crear las bases en
dos variantes**, y la guía §6 no se reescribe por esto.

**Cómo ve `radb` cada tipo de una tabla `STRICT`**, que solo admite `INT`, `INTEGER`, `REAL`, `TEXT`,
`BLOB` y `ANY`:

| Tipo `STRICT` | Tipo en `radb` | Observación |
|---|---|---|
| `INTEGER`, `INT` | `number` | |
| `REAL` | `number` | **solo con SQLAlchemy 2.0** (H2) |
| `TEXT` | `string` | |
| `BLOB` | `unknown` | |
| `ANY` | `number` | **engañoso**: SQLAlchemy le aplica la regla de afinidad de SQLite |

**Consecuencias para `a04`:**

- **Las fechas van en `TEXT` con formato ISO 8601** (`2026-03-01`). `STRICT` rechaza `DATE` con
  `Error: in prepare, unknown datatype for t.d: "DATE"`, y `radb` las ve como `string`, que comparan
  bien porque el formato ISO ordena igual como texto que como fecha.
- **Las bases del curso no usan `ANY` ni `BLOB`.**

**El error de tipo de `STRICT`**, literal, para el ejercicio de `a01`:

```text
Runtime error near line 29: cannot store TEXT value in INTEGER column supplier.status (19)
```

Y la conversión que sí hace: `'25'` en una columna `INTEGER` se guarda como el entero 25
(`typeof(status)` devuelve `integer`).

Reproducir: `comprobaciones/supply-mini.sql` (la base de prueba) y `sqlite-comportamiento.sql`.

---

## H4 · `radb`: invocación, configuración y sintaxis · 03/10/2026

**Invocación.** La base va como argumento posicional, y el archivo de consultas con `-i`:

```bash
radb supply.db -i 07/division-red-parts.ra
```

`radb supply.db < archivo.ra` también funciona, pero mezcla en la salida el *prompt* `ra>` de cada
sentencia. **El curso usa `-i`**, y el ejemplo de la guía §6 se corrige (P10). Opciones de `--help`:
`-c/--configfile`, `-p/--password`, `-i/--inputfile`, `-o/--outputfile`, `-e/--echo`,
`-v/--verbose` y `-d/--debug`.

**Configuración.** Sin archivo, cada ejecución empieza con este aviso por la salida de error, que no
es un error:

```text
WARNING: unable to read configuration file /root/.radb.ini; resorting to system defaults
```

El archivo es `~/.radb.ini` (o el que diga `-c`), y con esto basta para no tener que pasar la base:

```ini
[DEFAULT]
db.database = /ruta/a/supply.db
```

**La sintaxis**, sacada de la gramática de la 3.0.5 y probada operador por operador
(`comprobaciones/radb-operadores.ra`):

| Operador | En `radb` | Nota |
|---|---|---|
| σ | `\select_{cond} R` | `and`, `or`, `not`, `like`, `is null`, `is not null`, `=`, `<>`, `<`, `<=`, `>`, `>=` |
| π | `\project_{a, b} R` | **elimina duplicados** (genera `SELECT DISTINCT`) |
| ρ | `\rename_{x, y, z} R` · `\rename_{s: *} R` | la segunda forma solo cambia el prefijo de la relación |
| ⋈ natural | `R \join S` | por los atributos de igual nombre |
| ⋈ con condición | `R \join_{cond} S` | |
| × | `R \cross S` | |
| ∪ ∩ − | `\union`, `\intersect`, `\diff` | exigen mismo número de atributos y tipos compatibles por posición |
| γ | `\aggr_{grupo: f(a), g(b)} R` | `count`, `sum`, `avg`, `min`, `max`; **no admite `count(*)`** |
| vista | `nombre :- expresión;` | se lista con `\list;` |
| SQL directo | `\sqlexec_{SELECT …};` | |
| comentarios | `// línea` · `/* bloque */` | **no** `--` |

Toda sentencia termina en `;`. Los atributos calculados y los agregados salen con nombre `_`
(`(color:string, _:number, _:number)`), y una proyección puede devolver dos atributos con el mismo
nombre (`(name:string, name:string)`) sin quejarse.

> ⚠️ **No tiene** ÷, ⟕ ⟖ ⟗, ⋉ ni ▷, como decía la decisión D15, y **sí tiene agregación** (`\aggr`),
> como ya contaba la ficha de F08.

**El comentario `--` de SQL rompe un archivo `.ra`.** La guía §5 pedía abrir los bloques de `radb`
con la línea `-- radb`; copiado tal cual a un archivo, da:

```text
ERROR: line 1:0 mismatched input '-' expecting {<EOF>, <ID>, '\rename', '\project', '\select', '\aggr', '(', '\list', '\clear', '\save', '\source', '\help', '\quit', '\sqlexec'}
```

**Decisión:** la primera línea es `// radb`, que sí es un comentario de `radb` y corre. P10 corrige la
guía y la plantilla. La expresión sin paréntesis de la plantilla
(`\project_{name} \select_{city = 'Paris'} supplier;`) corre bien: no hacen falta.

**Cómo se comporta un archivo con errores.** Un error de **sintaxis** en cualquier línea hace que no
se ejecute **nada** del archivo, porque se analiza entero antes de correr. Un error **semántico**
corta la ejecución en esa sentencia: las anteriores ya salieron, las siguientes no corren.

**Los mensajes de error más comunes**, literales (`comprobaciones/radb-errores.ra`):

```text
ERROR: in city = 1:
function "EQ" cannot be applied to (string, number); correct signature(s):
    EQ(number, number) -> boolean
    EQ(string, string) -> boolean
    EQ(date, date) -> boolean
    EQ(datetime, datetime) -> boolean
context: \select_{city = 1} supplier

ERROR: in colour:
invalid attribute reference
context: \select_{colour = 'Red'} part

ERROR: in suppliers:
relation suppliers does not exist

ERROR: in (\project_{city} supplier) \union (\project_{supplier_id} supplier):
input attributes at position 0 have different types: supplier.city:string vs. supplier.supplier_id:number

ERROR: in (\project_{name} supplier) \union part:
input relations to a set operation do not have the same number of attributes

ERROR: line 2:0 missing ';' at '<EOF>'

ERROR: line 12:20 extraneous input '*' expecting {'not', <STRING>, <NUMBER>, <ID>, '(', ')'}
```

El último es el de `\aggr_{color: count(*)} part`.

---

## H5 · `radb` y `NULL`; el SQL que genera · 03/10/2026

**`NULL` se imprime como `None`** (es el `str()` de Python): `5, Adams, None, Athens`.

**σ sigue la lógica de tres valores de SQL**: `\select_{status <> 20} supplier` no devuelve a Adams,
cuyo `status` es `NULL`. Para encontrarlo hace falta `\select_{status is null} supplier`.

**Los operadores de conjunto tratan dos `NULL` como iguales**, porque se traducen a `UNION`,
`INTERSECT` y `EXCEPT` de SQL (`comprobaciones/radb-sql-y-null.ra`):

```text
π status (supplier) − π status (σ city='Athens' (supplier))   →  10, 20, 30   (el NULL se restó)
π status (σ city='Athens' (supplier)) ∩ π status (supplier)   →  None         (el NULL coincidió)
π status (supplier) ∪ π status (supplier)                     →  None, 10, 20, 30
```

Es material directo de F11: σ dice que `NULL = NULL` es desconocido, y − e ∩ dicen que son iguales.

**El SQL generado se ve con `-d`** (`--debug`), en una línea `DEBUG: SQL generated:` seguida de una
cadena de CTE. `-v` muestra el árbol validado, no el SQL. Ejemplo literal, para F10:

```text
DEBUG: SQL generated:
WITH rat0(a0, a1, a2, a3) AS (SELECT * FROM supplier),
     rat1(a0) AS (SELECT DISTINCT rat0.a0 FROM rat0),
     rat2(a0, a1, a2) AS (SELECT * FROM shipment),
     rat3(a0) AS (SELECT DISTINCT rat2.a0 FROM rat2),
     rat4(a0) AS (SELECT * FROM rat1 EXCEPT SELECT * FROM rat3)
SELECT * FROM rat4
```

`-d` también imprime muchas líneas `DEBUG:` vacías; para el curso conviene filtrar con
`grep -A20 'SQL generated'`.

---

## H6 · SQLite 3.46.1: lo que citan las fichas · 03/10/2026

Todo con `comprobaciones/sqlite-comportamiento.sql` sobre `supply-mini.sql`:

```bash
docker exec mdm-lab sh -c 'cd /tmp && rm -f s.db && sqlite3 s.db < /curso/…/supply-mini.sql \
  && sqlite3 s.db < /curso/…/sqlite-comportamiento.sql'
```

| Qué | Resultado | Para |
|---|---|---|
| `PRAGMA foreign_keys` por defecto | **`0`**: la fila huérfana `(99, 1, 10)` entra sin error | F05 |
| con `PRAGMA foreign_keys = ON` | `Runtime error near line 8: FOREIGN KEY constraint failed (19)` | F05 |
| `INTERSECT ALL` y `EXCEPT ALL` | **no existen**: `Parse error near line 11: near "ALL": syntax error` | F10, F11 |
| `UPDATE` sobre una vista | **ninguna vista es actualizable**: `Parse error near line 15: cannot modify paris_supplier because it is a view` | F12 |
| `INSTEAD OF UPDATE` sobre la vista | funciona: el `UPDATE` llega a `supplier` | F12, F36 |
| `WITH CHECK OPTION` | **no existe**: `Parse error near line 23: near "WITH": syntax error` | F12 |
| `FOR EACH STATEMENT` | **no existe**: `Parse error near line 25: near "STATEMENT": syntax error`; solo hay triggers de fila | F36 |
| `dbstat` | disponible en la CLI y en el módulo `sqlite3` de Python | F21, F24 |

`UNION ALL` sí existe. La consecuencia para F11: el contraste entre conjuntos y multiconjuntos se hace
con `UNION` frente a `UNION ALL` en SQLite, y `INTERSECT ALL`/`EXCEPT ALL` se muestran como lo que el
estándar define y SQLite no implementa (PostgreSQL sí, en el 🔥 de `a09`).

---

## H7 · Copiar solo el `.db` con el `-wal` pendiente · 03/10/2026

**El síntoma es el silencio**, y por eso es grave. Con la base en modo WAL, el
`wal_autocheckpoint` desactivado y una conexión abierta, se copió solo el `.db`
(`comprobaciones/copia-con-wal.py`):

```text
w.db 4096 bytes
w.db-wal 24752 bytes
w.db-shm 32768 bytes
copy.db  PRAGMA integrity_check;            -> 'ok' ''
copy.db  SELECT COUNT(*) FROM supplier;     -> '' 'Error: in prepare, no such table: supplier'
copy.db  .tables                            -> '' ''
tras cerrar: ['w.db']
w.db     SELECT COUNT(*)                        -> 500
```

La tabla entera, con sus 500 filas confirmadas, vivía en el `-wal`. **La copia pasa
`integrity_check`**: está sana, solo que es de antes.

**La variante que más se parece a la vida real** —la tabla ya volcada con 100 filas, 400 más
confirmadas solo en el `-wal`— es peor, porque ni siquiera falla:

```text
variante copy.db  PRAGMA integrity_check;            -> 'ok' ''
variante copy.db  SELECT COUNT(*) FROM supplier;     -> '100' ''
```

**Para `a01`:** `integrity_check` no detecta una copia vieja; detecta una copia rota. El ejercicio del
síntoma se escribe con la variante. Y al cerrar la última conexión, SQLite vuelca el `-wal` y lo
borra: por eso "copiar con la base cerrada" es seguro.

---

## H8 · `dbstat` y `sqlite3_analyzer` · 03/10/2026

**Los dos están disponibles en `mdm-lab`**, y la ventana a la página de F21 y F24 puede usarlos.

- `dbstat`: Debian compila SQLite con `SQLITE_ENABLE_DBSTAT_VTAB`, y el módulo de Python lo ve
  (`SELECT COUNT(*) FROM dbstat` → `(5,)`).
- `sqlite3_analyzer` 3.46.1 viene en el paquete **`sqlite3-tools`**, no en `sqlite3`. Su salida
  empieza así:

```text
/** Disk-Space Utilization Report For s.db

Page size in bytes................................ 4096
Pages in the whole file (measured)................ 5
```

> ⚠️ **Sin verificar para el lector:** si el `sqlite3` de Homebrew, el de los paquetes de Windows y el
> del módulo de Python del instalador de python.org traen `dbstat`, y si `sqlite3_analyzer` viene en
> los paquetes de Fedora, Arch, `brew`, `winget`, Chocolatey y Scoop. F21 y F24 lo dicen así, o
> Oskar lo comprueba (H11).

---

## H9 · Faker: misma semilla, mismos datos · 03/10/2026

**Idéntico en arm64 y en amd64.** `comprobaciones/faker-semilla.py` genera mil alumnos con
`Faker(["es_MX", "es_CO", "es_CL", "es_AR"])` y `Faker.seed(2026)`, más mil notas con
`random.seed(2026)`, y saca un SHA-256 del resultado. Salió el mismo en cinco entornos:

| Entorno | Arquitectura | Python | SHA-256 |
|---|---|---|---|
| `mdm-lab` | aarch64 | 3.14.8 | `4a8301fc6523…8156` |
| `python:3.14.8-slim-trixie`, emulado | x86_64 | 3.14.8 | `4a8301fc6523…8156` |
| Fedora 44 | aarch64 | 3.14.7 | `4a8301fc6523…8156` |
| Arch, emulado | x86_64 | 3.14.7 | `4a8301fc6523…8156` |
| `python:3.10-slim` | aarch64 | 3.10.22 | `4a8301fc6523…8156` |

**Con Faker 30.0.0 los datos cambian** (`Indira` en lugar de `Adela`, otro SHA-256: `957d4c26ac12…`).
Es la prueba de la advertencia de `a02`: la versión de Faker va fijada.

> ⚠️ **Trampa para `a04`:** `fake.date_of_birth(minimum_age=…, maximum_age=…)` calcula el rango
> **desde la fecha de hoy** (`datetime.now()` en su código). Con la misma semilla, el mismo
> generador da fechas distintas el año que viene. **El generador usa `date_between` con fechas
> fijas**, nunca `date_of_birth`, `date_this_year` ni nada relativo a hoy.

> 📝 Faker escribe `Garica` como apellido en algún *locale* en español; es un dato del proveedor, no
> un error del curso. Si aparece en un ejemplo de `a04`, se deja.

---

## H10 · Las recetas Linux · 03/10/2026

Corridas en contenedores efímeros con `comprobaciones/receta-debian.sh` y `receta-fedora-arch.sh`,
como las escribiría el lector (`apt`, `dnf`, `pacman`, sin backports ni repositorios extra):

| Distribución | Comando | SQLite | Python | `venv` | `radb` + Faker |
|---|---|---|---|---|---|
| Debian 13 (trixie) | `apt install sqlite3 python3 python3-venv` | 3.46.1 | 3.13.5 | necesita `python3-venv` | ✅ |
| Ubuntu 24.04.5 LTS | `apt install sqlite3 python3 python3-venv` | 3.45.1 | 3.12.3 | necesita `python3-venv` | ✅ |
| Ubuntu 26.04.1 LTS | `apt install sqlite3 python3 python3-venv` | 3.46.1 | 3.14.4 | necesita `python3-venv` | ✅ |
| Fedora 44 | `dnf install sqlite python3` | 3.51.2 | 3.14.7 | incluido | ✅ |
| Arch | `pacman -S sqlite python` | 3.53.4 | 3.14.7 | incluido | ✅ |

**Todas superan la 3.37.0**: ninguna distribución vigente obliga al binario de sqlite.org. **En
Debian y Ubuntu, `python3 -m venv` falla sin `python3-venv`**, con este mensaje (el número de versión
cambia con la distribución):

```text
The virtual environment was not created successfully because ensurepip is not
available.  On Debian/Ubuntu systems, you need to install the python3-venv
package using the following command.

    apt install python3.13-venv

You may need to use sudo with that command.  After installing the python3-venv
package, recreate your virtual environment.
```

Arch no publica imagen para arm64; corrió con `--platform linux/amd64`, y bajo emulación `pacman`
falla con `error: error restricting syscalls via seccomp: 22!` si no se le pasa `--disable-sandbox`.
**Es un artefacto de la emulación**, no de la receta: el lector en Arch real no lo ve, y `a01` no lo
menciona.

---

## H11 · macOS y Windows: lo que publica cada gestor · 03/10/2026

**No se puede contenerizar** (plan §2.3). Lo que sigue se **consultó** en el registro de cada gestor
desde `mdm-lab` (`comprobaciones/paquetes-macos-windows.py`); **no se instaló nada**:

| Gestor | Paquete | Versión publicada | Nota |
|---|---|---|---|
| Homebrew | `sqlite` | 3.53.4 | **keg-only**: no reemplaza al `sqlite3` de macOS en el `PATH` |
| Homebrew | `python@3.14` | 3.14.8 | |
| winget | `SQLite.SQLite` | 3.53.4 | |
| winget | `Python.Python.3.14` | 3.14.7 | |
| Chocolatey | `sqlite` · `sqlite.shell` | 3.53.4 · 3.53.4 | dos paquetes; cuál trae la CLI sola está sin verificar |
| Chocolatey | `python` | 3.14.8 | |
| Scoop (`main`) | `sqlite` | 3.53.4 | |
| Scoop (`main`) | `python` | 3.14.8 | |

> ⚠️ **Lo que más pesa para `a01`:** como `sqlite` de Homebrew es *keg-only*, el lector de macOS que
> hace `brew install sqlite` y escribe `sqlite3` sigue usando **el que trae macOS**, cuya versión no
> se pudo verificar. La receta tiene que poner el de Homebrew en el `PATH` o llamarlo por su ruta.

**Pendiente de Oskar**, en su máquina y con `!` en la sesión para que quede en el registro:

```bash
! /usr/bin/sqlite3 --version                                       # el de macOS
! /usr/bin/sqlite3 :memory: "CREATE TABLE t (x INT) STRICT; SELECT 'strict ok';"
! /usr/bin/sqlite3 :memory: "SELECT COUNT(*) FROM dbstat;"
```

Y en Windows: los tres instaladores de SQLite, el lanzador `py`, la casilla del `PATH`, y **el mensaje
literal de la política de ejecución de PowerShell** al activar un `venv`. Mientras no se verifiquen,
`a01` y `a02` las declaran "no verificadas en esta plataforma", con esas palabras.

---

## H12 · Bloque A.C. · 03/10/2026

Parte que el plan permite cerrar antes de T14; quedó cerrada en esta misma sesión.

**`lmdb` y ZODB** (`comprobaciones/ac-python.py`, en un `venv` limpio dentro de `mdm-lab`):

```text
lmdb 3.0.0 · LMDB C 0.9.36 · dupsort s1 -> [b'7A', b'8B']
ZODB 6.3 · persistent 6.8 · s1 -> Ana ['7A']
```

- **`lmdb` trae LMDB incluido**: se instaló desde un wheel `manylinux…aarch64` sin ninguna biblioteca
  del sistema, y reporta LMDB 0.9.36. Los *sets* con `dupsort` funcionan como los describe AC07.
- ZODB 6.3 arrastra `persistent` 6.8 y `BTrees` 6.5.

**GnuCOBOL** (`comprobaciones/ac-cobol-y-c.sh`, en `debian:13`): `apt install gnucobol` instala
**GnuCOBOL 3.2.0**, con manejador de archivos indexados **BDB**. Un archivo `ORGANIZATION IS INDEXED`
escrito y leído por clave funciona (`LEIDO POR CLAVE: Beatriz`). Debian ofrece también `gnucobol4`
(4.0 *early*, de 2020): el curso usa la 3.2. Al compilar aparece
`Warning: program compiled against libxml 212 using older 209`, que es del empaquetado de Debian y no
afecta. Fedora 44 la publica como `gnucobol` 3.2; Homebrew como `gnucobol` 3.2; Chocolatey como
`gnucobol` 3.2.0.20240515. **No hay paquete en Scoop `main` ni en winget.**

**Harbour** (`comprobaciones/ac-harbour.sh`): **no está en Debian ni en Fedora.** La **3.2.0** se
publicó por fin el 07/07/2026 en GitHub (`harbour/core`, con fuente y binario para Windows con
MinGW64), y compila desde el fuente en `debian:13` en unos siete minutos. Dos trampas: el tarball **no
trae carpeta raíz**, y `make install` deja `libharbour.so.3.2` en `/usr/local/lib/harbour`, fuera de
la ruta del cargador (hace falta `ldconfig` con esa carpeta). Un `.dbf` con índice funciona:

```text
SEEK 2 -> .T. Beatriz
   1 Ana
   2 Beatriz
```

La salida trae secuencias de terminal porque el programa usa el GT de consola por defecto; para el
curso se compila con `-gtcgi` (sin verificar todavía). En Homebrew, `harbour` está en la **3.0.0** y
**marcada obsoleta**, con fecha de desactivación el 05/01/2027; en winget, `Harbour.Harbour` 3.0.0; en
Chocolatey no aparece. **Conclusión:** Harbour se instala desde el fuente o desde el binario de GitHub,
y sigue siendo 🔥 como dice `prompts-ac-fase.md`.

**GCC y ANSI C**: GCC 14.2.0 en Debian 13. Con `-std=c89 -pedantic -Wall -Wextra -Werror`, un
programa C89 compila sin advertencias, y uno con declaración en el `for` y comentario `//` falla con:

```text
c99.c:1:18: error: 'for' loop initial declarations are only allowed in C99 or C11 mode
c99.c:1:49: error: C++ style comments are not allowed in ISO C90
```

Esos son los *flags* de AC09 en GCC. **Visual C++ queda pendiente de Oskar en Windows** (plan §2.3):
MSVC no tiene modo C89, y qué *flags* usar (`/std:c11`, `/W4`, `/WX`) está sin verificar.

**YottaDB** (`comprobaciones/ac-yottadb.sh`): **existe imagen oficial multiarquitectura**.
`yottadb/yottadb:r2.06` (27/04/2026) publica `amd64` y `arm64`, y corre **nativa en macOS arm64, sin
emulación**, sobre Ubuntu 24.04.4:

```text
YottaDB release:         r2.06
Upstream base version:   GT.M V7.1-002
Platform:                Linux aarch64
```

**El paquete `yottadb` de Python 2.0.1 funciona dentro del contenedor en arm64**: PyPI solo publica
wheel para x86-64, pero también el fuente, y pip lo compila si el contenedor tiene `gcc`,
`python3-dev`, `python3-venv` y `libffi-dev`. El entorno de YottaDB hay que cargarlo antes con
`. /opt/yottadb/current/ydb_env_set` (y sin `set -u`, porque lee variables que pueden no existir):

```text
yottadb 2.0.1 · ^student(1) = Ana · hijos de ^student: ['1', '2']
```

**AC08 puede correr**: el caso de reserva del `.dbf` no hace falta por YottaDB.

---

## 📌 Lo que P8 deja abierto

- **macOS y Windows** (H11), pendientes de Oskar o declarados.
- **`a09`**: la memoria del PostgreSQL extra y que el volumen montado funcione igual en las tres
  plataformas se verifican en T12, al crear `mdm-pg`. En macOS arm64, el montaje de `/curso` de
  `mdm-lab` funciona (los `.ra` y `.sql` se leen del disco).
- **Podman**: no instalado en la máquina de producción; los equivalentes se escriben desde la
  documentación y se declaran no verificados (plan §2.3).
- **Harbour con `-gtcgi`**, al escribir AC01.
- **Imágenes base descargadas en P8**, sin la etiqueta `curso=01-bases` porque son de Docker Hub:
  `python:3.14.8-slim-trixie`, `python:3-slim`, `python:3.10-slim`, `debian:13`, `ubuntu:24.04`,
  `ubuntu:26.04`, `fedora:latest`, `archlinux:latest` y `yottadb/yottadb:r2.06`. Se borran solo con
  permiso de Oskar, en T17. (`python:3.14.7` ya estaba en la máquina y no es de este curso.)
