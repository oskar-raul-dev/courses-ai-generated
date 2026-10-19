"""MySQL: las tablas de la caja que pide cada fase, en la base `legacy`, y la medición de la forma.

Dos cosas que la carga hace a propósito y que el apéndice a05 explica: MySQL no distingue en un CSV
el campo vacío sin comillas (NULL en la caja) de `""` (cadena vacía), así que en las columnas de
texto los dos llegan como `''`; y en las demás columnas el vacío se convierte en NULL con `NULLIF`,
porque si no el modo estricto rechaza la fila.
"""

import time

import pymysql

from .. import config
from ..generator import schema
from . import caja_path, check

TEXT = ("nvarchar",)


def my_type(tsql: str) -> str:
    base, _, size = tsql.partition("(")
    size = size.rstrip(")")
    return {"int": "int", "bigint": "bigint", "datetime": "datetime(3)", "money": "decimal(19,4)",
            "bit": "tinyint(1)", "decimal": f"decimal({size})",
            "nvarchar": "longtext" if size == "max" else f"varchar({size})"}[base]


def connect(**kw):
    return pymysql.connect(**config.MYSQL, **kw)


def _q(name: str) -> str:
    return "`" + name.replace("`", "``") + "`"


def load(profile: str, man: dict, tables: list[schema.Table], log=print) -> None:
    started = time.time()
    conn = connect(autocommit=True)
    try:
        with conn.cursor() as cur:
            # La carga de la caja no va al binlog: no es un cambio que alguien tenga que replicar, y
            # cada carga de M le sumaría más de un gigabyte, que MySQL guarda 30 días.
            cur.execute("SET SESSION sql_log_bin = 0")
            cur.execute("CREATE DATABASE IF NOT EXISTS legacy CHARACTER SET utf8mb4")
            for t in tables:
                cols = t.exported_columns
                ddl = ", ".join(f"{_q(c.name)} {my_type(c.tsql)}" for c in cols)
                if t.primary_key:
                    ddl += f", PRIMARY KEY ({_q(t.primary_key)})"
                cur.execute(f"DROP TABLE IF EXISTS legacy.{_q(t.name)}")
                cur.execute(f"CREATE TABLE legacy.{_q(t.name)} ({ddl})")
                variables = ", ".join(f"@v{i}" for i in range(len(cols)))
                sets = ", ".join(f"{_q(c.name)} = @v{i}" if c.tsql.startswith(TEXT)
                                 else f"{_q(c.name)} = NULLIF(@v{i}, '')" for i, c in enumerate(cols))
                charset = "latin1" if t.encoding == "latin-1" else "utf8mb4"
                n = cur.execute(
                    f"LOAD DATA INFILE '{caja_path(profile, t)}' INTO TABLE legacy.{_q(t.name)} "
                    f"CHARACTER SET {charset} FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '' "
                    f"LINES TERMINATED BY '\\r\\n' IGNORE 1 LINES ({variables}) SET {sets}")
                check(t, n, man)
            cur.execute("CREATE DATABASE IF NOT EXISTS lab")
            cur.execute("CREATE TABLE IF NOT EXISTS lab.loaded (profile varchar(1), seed int, sha256 char(64), "
                        "tables text, loaded_at datetime DEFAULT CURRENT_TIMESTAMP)")
            cur.execute("INSERT INTO lab.loaded (profile, seed, sha256, tables) VALUES (%s, %s, %s, %s)",
                        (profile, man["seed"], man["sha256"], ",".join(t.name for t in tables)))
    finally:
        conn.close()
    log(f"  mysql: {len(tables)} tablas en {time.time() - started:.0f} s")


HANDLERS = ("Handler_read_first", "Handler_read_key", "Handler_read_next", "Handler_read_rnd_next")


def measure(query: str) -> dict:
    conn = connect(autocommit=True)
    try:
        with conn.cursor() as cur:
            cur.execute("FLUSH STATUS")
            cur.execute(f"EXPLAIN ANALYZE {query}")
            tree = cur.fetchone()[0]
            cur.execute("SHOW SESSION STATUS LIKE 'Handler_read%'")
            handlers = {k: int(v) for k, v in cur.fetchall() if k in HANDLERS}
    finally:
        conn.close()
    return {"plan": tree.splitlines(), "handlers": handlers, "examined": sum(handlers.values())}
