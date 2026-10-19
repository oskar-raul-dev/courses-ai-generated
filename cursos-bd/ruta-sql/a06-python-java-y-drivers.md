# 📎 Apéndice a06 — Python, Java y los drivers: en qué transacción estás

> **Curso:** Ruta SQL · Consulta rápida · **2 h**
> **Usado por:** todas las fases, y sobre todo el Bloque III · **Versiones cubiertas:** uv 0.11.14,
> Python 3.13, psycopg 3.3.6, PyMySQL 1.2.3 y python-oracledb 26.0.1 (las fija `src/uv.lock`); Java
> 25 con Maven 3.10.0 y el driver JDBC de Postgres 42.7.14
> **Fecha de verificación ejecutada:** 12/10/2026. Todo se ejecutó con `uv` dentro de un contenedor,
> en la red del laboratorio; en tu máquina, con `uv` instalado, los comandos son los mismos.

**Esto no se lee de corrido.** Se entra por el índice buscando algo concreto y se sale. Resuelve dos
cosas: tener el entorno de Python del curso funcionando en un comando, y **saber en qué transacción
está tu código**, que en cada driver se responde distinto y que el Bloque III da por sabido.

**Qué queda fuera:** los ORM (si una fase necesita mostrar lo que genera uno, lo muestra como SQL),
los *pools* de conexiones y el Java más allá de un archivo suelto. Cómo se conecta cada CLI está en
[`a03`](a03-clis-de-los-motores.md); el laboratorio, en [`a01`](a01-laboratorio-contenerizado.md).

---

## Índice

- [`uv` y el `uv.lock`](#-uv-y-el-uvlock)
- [Los tres drivers](#-los-tres-drivers)
- [Tres preguntas a cada driver](#️-tres-preguntas-a-cada-driver)
- [La transacción que nadie cerró](#-la-transacción-que-nadie-cerró)
- [Leer la caja desde Python](#-leer-la-caja-desde-python)
- [Java 25: un archivo y un driver](#-java-25-un-archivo-y-un-driver)
- [Cuándo usar qué](#-cuándo-usar-qué)
- [Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-6)

---

## 📦 `uv` y el `uv.lock`

El proyecto de Python del curso es `src/`: su `pyproject.toml` declara las tres dependencias y el
comando `lab`, y su `uv.lock` fija la versión exacta de todo lo que se instala. **No hay
`requirements.txt` ni entorno que activar a mano.**

```toml
[project]
name = "alameda-lab"
requires-python = ">=3.13,<3.14"   # el hash de la caja depende de la versión de random (a05)
dependencies = [
    "psycopg[binary]>=3.3.6",
    "pymysql>=1.2.3",
    "oracledb>=26.0.1",
]

[project.scripts]
lab = "lab.cli:main"
```

**Instalar `uv`** es lo único que pide el curso en tu máquina: `brew install uv` en macOS, o el
instalador de su documentación en Linux y en WSL2. `uv` baja Python 3.13 por su cuenta si no lo
tienes. Lo demás pasa solo, desde `src/`:

```bash
uv run --locked lab --help        # crea .venv/, instala lo del uv.lock y ejecuta
uv run python mi_script.py        # cualquier script, con el mismo entorno y el paquete lab importable
```

`--locked` hace que `uv` falle si el `uv.lock` no coincide con el `pyproject.toml`, en lugar de
resolver de nuevo: es la garantía de que tienes las versiones del curso. El `.venv/` queda en `src/` y
git lo ignora.

---

## 🔌 Los tres drivers

| Motor | Driver | Por qué este |
|---|---|---|
| Postgres | **psycopg 3** (`psycopg[binary]`) | el oficial de facto; la versión 3 habla el protocolo moderno y trae el binario sin compilar nada |
| MySQL | **PyMySQL** | Python puro, licencia MIT y sin dependencia de Oracle |
| Oracle | **python-oracledb**, en modo *thin* | el oficial de Oracle; en modo *thin* **no necesita Instant Client** |

**Por qué PyMySQL y no el conector oficial.** Se probaron los dos con la misma secuencia de
transacciones y con `LOAD DATA LOCAL`, y se comportan igual en todo lo que el curso usa. Ganó
PyMySQL por ser Python puro y por no depender del dueño de MySQL, que es lo que discute [`a09`](a09-licencias-publicacion-y-riesgo.md)
cuando habla del riesgo a cinco años. `mysql-connector-python` sigue siendo una opción
válida, y cambiar de uno al otro es cambiar el `connect`.

Cómo se conecta el curso a cada motor, con los valores de `src/lab/config.py` (que lee
`src/lab/.env`, como Compose):

```python
from lab import config
import oracledb, psycopg, pymysql

pg = psycopg.connect(**config.POSTGRES)                     # 127.0.0.1:25432, base alameda
my = pymysql.connect(**config.MYSQL, database="legacy")     # 127.0.0.1:23306
o = config.ORACLE
ora = oracledb.connect(user="alameda", password=o["password"],
                       dsn=f"{o['host']}:{o['port']}/{o['service']}")   # servicio FREEPDB1
```

---

## ⚖️ Tres preguntas a cada driver

Las tres preguntas que hay que poder contestar antes del Bloque III, y el script que las contesta en
los tres motores. Guárdalo en `src/` y córrelo con `uv run python tres_preguntas.py`:

```python
"""Tres preguntas a cada driver: ¿autocommit?, ¿un CREATE TABLE confirma lo pendiente?, ¿qué hace `with`?"""
import oracledb
import psycopg
import pymysql

from lab import config

INSERT = "INSERT INTO payer VALUES ('PAMI', 'INSTITUTO NACIONAL DE SERVICIOS SOCIALES')"


def connect(engine):
    if engine == "postgres":
        return psycopg.connect(**config.POSTGRES, options="-c search_path=alameda")
    if engine == "mysql":
        return pymysql.connect(**config.MYSQL, database="alameda")
    o = config.ORACLE
    return oracledb.connect(user="alameda", password=o["password"], dsn=f"{o['host']}:{o['port']}/{o['service']}")


def prepare():
    """El esquema del modelo nuevo, si todavía no existe (en MySQL, la base `alameda`)."""
    with psycopg.connect(**config.POSTGRES, autocommit=True) as conn:
        conn.execute("CREATE SCHEMA IF NOT EXISTS alameda")
    conn = pymysql.connect(**config.MYSQL)
    conn.cursor().execute("CREATE DATABASE IF NOT EXISTS alameda")
    conn.close()


def reset(engine):
    """payer vacía y sin la tabla site; se ejecuta confirmando cada sentencia."""
    conn = connect(engine)
    cur = conn.cursor()
    for sql in ("DROP TABLE site", "DROP TABLE payer",
                "CREATE TABLE payer (payer_code varchar(10) PRIMARY KEY, name varchar(100))"):
        try:
            cur.execute(sql)
            conn.commit()
        except Exception:
            conn.rollback()
    conn.close()


def count(engine):
    conn = connect(engine)
    cur = conn.cursor()
    cur.execute("SELECT count(*) FROM payer")
    n = cur.fetchone()[0]
    conn.close()
    return n


def autocommit(conn):
    return conn.get_autocommit() if isinstance(conn, pymysql.Connection) else conn.autocommit


prepare()
for engine in ("postgres", "mysql", "oracle"):
    reset(engine)
    conn = connect(engine)
    cur = conn.cursor()
    cur.execute(INSERT)
    print(f"{engine}: autocommit={autocommit(conn)}; sin commit, otra sesión ve {count(engine)} fila(s)")
    cur.execute("CREATE TABLE site (site_code char(1) PRIMARY KEY)")
    conn.rollback()
    print(f"{engine}: tras CREATE TABLE y rollback, payer tiene {count(engine)} fila(s)")
    conn.close()

    reset(engine)
    with connect(engine) as conn:
        conn.cursor().execute(INSERT)
    print(f"{engine}: al salir de `with connect()` sin commit, payer tiene {count(engine)} fila(s)")
```

```text
postgres: autocommit=False; sin commit, otra sesión ve 0 fila(s)
postgres: tras CREATE TABLE y rollback, payer tiene 0 fila(s)
postgres: al salir de `with connect()` sin commit, payer tiene 1 fila(s)
mysql: autocommit=False; sin commit, otra sesión ve 0 fila(s)
mysql: tras CREATE TABLE y rollback, payer tiene 1 fila(s)
mysql: al salir de `with connect()` sin commit, payer tiene 0 fila(s)
oracle: autocommit=False; sin commit, otra sesión ve 0 fila(s)
oracle: tras CREATE TABLE y rollback, payer tiene 1 fila(s)
oracle: al salir de `with connect()` sin commit, payer tiene 0 fila(s)
```

**Primera pregunta: los tres arrancan sin *autocommit*.** Es lo que pide la especificación de Python
para drivers de bases de datos (PEP 249): la primera sentencia abre una transacción, y nada se ve
desde otra sesión hasta el `commit`.

> 🩻 **Esto sí funciona igual** en los tres drivers de Python: sin `commit` explícito, lo que hiciste
> no existe para nadie más.

**Segunda pregunta: un `CREATE TABLE` confirma lo pendiente en MySQL y en Oracle, y en Postgres no.**
MySQL y Oracle hacen un *commit* implícito antes de cada sentencia de DDL, así que el `INSERT` quedó
confirmado aunque después llegara el `rollback`. En Postgres el DDL es transaccional: el `rollback`
deshizo la tabla nueva **y** el `INSERT`.

> 🪞 **Tu instinto dice que `rollback` deshace todo lo que hiciste desde el último `commit`.** En MySQL
> y en Oracle, un `CREATE`, un `ALTER` o un `DROP` en el medio ya confirmó todo lo anterior, sin
> avisar. Una migración que falla a la mitad deja la base a la mitad.

**Tercera pregunta: `with connect()` hace tres cosas distintas.** En psycopg 3, salir del bloque sin
error **confirma** y cierra. En PyMySQL, **cierra sin confirmar**, y lo pendiente se pierde. En
python-oracledb, también cierra sin confirmar: Oracle deshace lo pendiente de una sesión que se
cierra. Mismo código, tres resultados.

> ⚠️ **No uses `with connect()` como frontera de transacción** si tu código tiene que correr en más de
> un motor. Llama a `commit()` explícitamente, o usa la construcción del driver pensada para eso
> (`with conn.transaction():` en psycopg 3).

---

## ⏳ La transacción que nadie cerró

Sin *autocommit*, **un `SELECT` también abre una transacción**, y queda abierta hasta que alguien
haga `commit`, `rollback` o cierre la conexión. Desde Postgres se ve así:

```python
import psycopg

from lab import config

work = psycopg.connect(**config.POSTGRES, application_name="recepcion")
work.execute("SELECT count(*) FROM legacy.\"Pacientes\" WHERE \"Sede\" = 'V'")
print("estado de la conexión:", work.info.transaction_status.name)
with psycopg.connect(**config.POSTGRES, autocommit=True) as watcher:
    row = watcher.execute("SELECT state, now() - xact_start > interval '0' FROM pg_stat_activity "
                          "WHERE application_name = 'recepcion'").fetchone()
    print("pg_stat_activity:", row)
work.close()
```

```text
estado de la conexión: INTRANS
pg_stat_activity: ('idle in transaction', True)
```

`idle in transaction` es una sesión que no hace nada y sostiene una transacción. En Postgres impide
que `VACUUM` limpie lo que esa transacción todavía podría ver; en los tres motores, si la transacción
tomó algún bloqueo, lo retiene. Cuánto cuesta lo mide el Bloque III; aquí basta con reconocerla.

---

## 🔤 Leer la caja desde Python

`Pacientes.csv` está en Latin-1 ([`a05`](a05-la-caja-y-el-generador.md#-el-formato-de-los-csv)), y
Python abre los archivos en UTF-8 si no le dices otra cosa:

```text
utf-8: 'utf-8' codec can't decode byte 0xf1 in position 764: invalid continuation byte
latin-1: 242427 filas, 32675 con Ñ
```

`0xF1` es la `ñ` en Latin-1. **Se arregla diciendo la codificación**, `open(path, encoding="latin-1",
newline="")`, y no con `errors="ignore"`, que borra las eñes en silencio y deja `MUOZ` donde decía
`MUÑOZ`. El `newline=""` es para el módulo `csv`, que necesita ver los CRLF tal cual.

---

## ☕ Java 25: un archivo y un driver

El curso usa Java en dos sitios: el boss del puente y el [Access de museo](a10-el-access-de-museo.md). Para los dos alcanza con
esto: **Java 25 ejecuta un archivo suelto sin proyecto**, con `void main()` y la clase `IO`, y Maven
baja el driver JDBC. Ninguno de los dos tiene que estar instalado en tu máquina: corren en la imagen
de Maven con Java 25 que fija [`a02`](a02-compose-de-la-ruta.md#-las-versiones-del-curso).

```java
// ContarEnPostgres.java · JDBC mínimo: el driver en el classpath, la consulta y su resultado.
import java.sql.DriverManager;

void main() throws Exception {
    var url = "jdbc:postgresql://postgres:5432/alameda";
    try (var conn = DriverManager.getConnection(url, "postgres", "lab");
         var st = conn.createStatement();
         var rs = st.executeQuery("SELECT count(*) FROM legacy.\"Pacientes\" WHERE \"Nombre\" LIKE '%Ñ%'")) {
        rs.next();
        IO.println("autocommit por defecto: " + conn.getAutoCommit());
        IO.println("filas con Ñ en legacy.\"Pacientes\": " + rs.getLong(1));
    }
}
```

Desde la carpeta del archivo, en la red del laboratorio (por eso el host es `postgres` y el puerto
`5432`, los de adentro):

```bash
docker run --rm --network alameda-lab_default -v "$PWD":/w -w /w maven:3.10.0-eclipse-temurin-25-noble \
  sh -c 'mvn -q dependency:copy -Dartifact=org.postgresql:postgresql:42.7.14 -DoutputDirectory=lib \
         && java -cp lib/postgresql-42.7.14.jar ContarEnPostgres.java'
```

```text
autocommit por defecto: true
filas con Ñ en legacy."Pacientes": 21559
```

> 🪞 **JDBC arranca con *autocommit* encendido; los drivers de Python, apagado.** El mismo `UPDATE`
> seguido de una excepción queda confirmado en Java y deshecho en Python. Si el servicio del puente
> hace dos escrituras que van juntas, `conn.setAutoCommit(false)` es la primera línea, no un detalle.

---

## 🧭 Cuándo usar qué

| Situación | Haz esto | Por qué |
|---|---|---|
| Correr cualquier cosa del curso | `uv run --locked …` desde `src/` | las versiones del `uv.lock`, sin activar nada |
| Saber qué versión de un driver tienes | `importlib.metadata.version("pymysql")` | `__version__` puede mentir (ver Advertencias) |
| Dos escrituras que van juntas | `commit()` explícito, o `with conn.transaction():` en psycopg | `with connect()` cambia de significado según el driver |
| Una migración de esquema en MySQL u Oracle | una sentencia de DDL por paso, y un plan para el paso que falla | cada DDL confirma todo lo anterior |
| Una sesión `idle in transaction` | `commit` o `rollback` en el código que la abrió | también un `SELECT` abre transacción |
| Leer `Pacientes.csv` o `Medicos.csv` | `encoding="latin-1"` | están en Latin-1 a propósito |
| Java contra la base | `setAutoCommit(false)` antes de la primera escritura | JDBC confirma cada sentencia por defecto |

---

## ⚠️ Advertencias

- **`pymysql.__version__` miente.** Devuelve `2.2.8`, la versión de `mysqlclient` con la que PyMySQL
  dice ser compatible, no la suya. La real está en `pymysql.VERSION`, `(1, 2, 3, 'final')`, o en
  `importlib.metadata.version("pymysql")`, `1.2.3`.
- **El *thin* de python-oracledb no hace todo.** Algunas funciones avanzadas piden el modo *thick* con
  Instant Client. El curso no usa ninguna; si una fase la necesitara, lo diría en su encabezado.
- **Los ejemplos se conectan como superusuario** (`postgres`, `root`, `system`) porque es un
  laboratorio. La [Fase 23](23-la-base-como-producto.md) trata los permisos en serio, con roles y seguridad por fila.

---

## 📚 Referencias

> ⚠️ Las URL y sus contenidos cambian. Este apéndice se verificó el 12/10/2026.

- **`uv`, proyectos y `uv.lock`** — https://docs.astral.sh/uv/concepts/projects/ — `uv run`, `--locked`
  y cómo instala Python.
- **PEP 249, la API de bases de datos de Python** — https://peps.python.org/pep-0249/ — por qué los
  drivers arrancan sin *autocommit*.
- **Transacciones en psycopg 3** — https://www.psycopg.org/psycopg3/docs/basic/transactions.html — qué
  hace `with connect()` y `conn.transaction()`.
- **PyMySQL** — https://pymysql.readthedocs.io/ — la conexión y sus opciones.
- **python-oracledb, modos *thin* y *thick*** — https://python-oracledb.readthedocs.io/en/latest/user_guide/initialization.html
  — qué funciona sin Instant Client.
- **Sentencias que confirman implícitamente en MySQL 9.7** — https://dev.mysql.com/doc/refman/9.7/en/implicit-commit.html
  — la lista completa.
- **JEP 512, archivos compactos y `main` de instancia** — https://openjdk.org/jeps/512 — el `void
  main()` de Java 25.
- **El driver JDBC de Postgres** — https://jdbc.postgresql.org/ — versiones y opciones de conexión.

**Orden sugerido:** `uv` el primer día; las tres preguntas antes de la [Fase 15](15-aislamiento-comparado.md); Java solo cuando
llegues al [boss del puente](23-la-base-como-producto.md#-16b-boss-del-puente--el-puente).

---

## 🧪 Ejercicios (6)

## 🟢 Fácil — el entorno (1–2)

### 🟢 Ejercicio 1 — Las versiones que corre tu entorno

Imprime la versión de Python y la de los tres drivers con `importlib.metadata`, y compáralas con el
`uv.lock`. Imprime también `pymysql.__version__`.

**Objetivo:** que las cuatro versiones coincidan con el `uv.lock`, y explicar por qué
`pymysql.__version__` no.

[Solución](soluciones/a06-python-java-y-drivers.md#ejercicio-1)

### 🟢 Ejercicio 2 — Un `SELECT` que abre una transacción

Con psycopg, abre una conexión, ejecuta solo un `SELECT` y, sin cerrarla, mira su estado desde otra
conexión en `pg_stat_activity`.

**Objetivo:** ver `INTRANS` en el driver e `idle in transaction` en el motor, sin haber escrito nada.

[Solución](soluciones/a06-python-java-y-drivers.md#ejercicio-2)

## 🟡 Intermedio — lo que no se ve (3–4)

### 🟡 Ejercicio 3 — El DDL que confirma

Corre `tres_preguntas.py`. Después cambia el `CREATE TABLE` por un `ALTER TABLE` que le agregue a
`payer` la columna `active boolean`, y predice el resultado en los tres motores antes de correrlo de
nuevo. Ojo: la sintaxis no es la misma en los tres.

**Pregunta:** ¿en qué motores sobrevive el `INSERT` al `rollback`, y qué le pasa a una migración de
cinco pasos que falla en el tercero en cada uno?

[Solución](soluciones/a06-python-java-y-drivers.md#ejercicio-3)

### 🟡 Ejercicio 4 — `with` en tres drivers

Modifica la parte de `with connect()` del script para que el `INSERT` quede confirmado en los tres
motores, sin cambiar de driver y sin ramas por motor.

**Objetivo:** las tres líneas de `with` del script con `1 fila(s)`.

[Solución](soluciones/a06-python-java-y-drivers.md#ejercicio-4)

## 🟠 Difícil — los bordes (5–6)

### 🟠 Ejercicio 5 — La eñe que desaparece

Lee `src/lab/caja/m/tablas/Pacientes.csv` con `encoding="utf-8"`, después con `errors="ignore"` y
después con `encoding="latin-1"`, y cuenta en cada caso las filas que contienen `Ñ`.

**Objetivo:** el error literal de la primera lectura, los dos conteos, y una explicación de por qué
`errors="ignore"` es peor que el error.

[Solución](soluciones/a06-python-java-y-drivers.md#ejercicio-5)

### 🟠 Ejercicio 6 — JDBC y el *autocommit*

Ejecuta `ContarEnPostgres.java` con la imagen de Maven. Después agrégale un `UPDATE` a una tabla de
prueba seguido de una excepción, y comprueba si el cambio quedó.

**Pregunta:** ¿qué devuelve `getAutoCommit()`, qué pasó con el `UPDATE`, y qué línea agregarías para
que se comporte como los drivers de Python?

[Solución](soluciones/a06-python-java-y-drivers.md#ejercicio-6)

---

> 🏷️ **Este apéndice no lleva tag propio.** El entorno que describe vive en `src/pyproject.toml` y
> `src/uv.lock`, que se commitean con `a05`; lo que salga de leerlo se commitea con el prefijo de la
> fase desde la que se llegó.
