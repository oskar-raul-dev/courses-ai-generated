"""Oracle: las tablas de la caja que pide cada fase, en el esquema `LEGACY`, por tablas externas.

Regla del curso: de Oracle no se publica ningún número. Por eso este módulo no muestra tiempos de
carga, y `measure` devuelve solo la **estructura** del plan, salvo que tú pidas `--private` para
resolver una apuesta en tu máquina.
"""

import time

import oracledb

from .. import config
from ..generator import schema
from . import check


def ora_type(tsql: str) -> str:
    base, _, size = tsql.partition("(")
    size = size.rstrip(")")
    return {"int": "NUMBER(10)", "bigint": "NUMBER(19)", "datetime": "TIMESTAMP(3)", "money": "NUMBER(19,4)",
            "bit": "NUMBER(1)", "decimal": f"NUMBER({size})",
            "nvarchar": "CLOB" if size == "max" else f"VARCHAR2({size} CHAR)"}[base]


def _convert(col: schema.Column) -> str:
    ident = f'"{col.name}"'
    base = col.tsql.partition("(")[0]
    if base == "datetime":
        return f"TO_TIMESTAMP({ident}, 'YYYY-MM-DD HH24:MI:SS.FF3')"
    if base in ("int", "bigint", "money", "decimal", "bit"):
        return f"TO_NUMBER({ident})"
    return ident


def connect():
    o = config.ORACLE
    return oracledb.connect(user=o["user"], password=o["password"], dsn=f"{o['host']}:{o['port']}/{o['service']}")


def _execute_ignoring(cur, statement: str, *codes: int) -> None:
    try:
        cur.execute(statement)
    except oracledb.DatabaseError as exc:
        if exc.args[0].code not in codes:
            raise


def load(profile: str, man: dict, tables: list[schema.Table], log=print, private=False) -> None:
    started = time.time()
    directory = f"CAJA_{profile.upper()}_TABLAS"        # una tabla externa no acepta rutas (KUP-04076)
    with connect() as conn, conn.cursor() as cur:
        cur.execute("ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,'")
        _execute_ignoring(cur, f"CREATE USER legacy IDENTIFIED BY \"{config.PASSWORD}\" QUOTA UNLIMITED ON USERS", 1920)
        cur.execute("GRANT CREATE SESSION, CREATE TABLE TO legacy")
        cur.execute(f"CREATE OR REPLACE DIRECTORY {directory} AS '/caja/{profile}/tablas'")
        for i, t in enumerate(tables):
            cols = t.exported_columns
            ext = f"LAB_EXT_{i}"
            charset = "WE8ISO8859P1" if t.encoding == "latin-1" else "AL32UTF8"
            fields = ", ".join(f'"{c.name}" CHAR(4000)' for c in cols)
            ext_cols = ", ".join(f'"{c.name}" VARCHAR2(4000)' for c in cols)
            _execute_ignoring(cur, f"DROP TABLE {ext} PURGE", 942)
            cur.execute(
                f"CREATE TABLE {ext} ({ext_cols}) ORGANIZATION EXTERNAL (TYPE ORACLE_LOADER DEFAULT DIRECTORY "
                f"{directory} ACCESS PARAMETERS (RECORDS DELIMITED BY '\\r\\n' CHARACTERSET {charset} SKIP 1 "
                f"NOBADFILE NOLOGFILE NODISCARDFILE FIELDS CSV WITH EMBEDDED TERMINATED BY ',' "
                f"OPTIONALLY ENCLOSED BY '\"' MISSING FIELD VALUES ARE NULL ({fields})) "
                f"LOCATION ('{t.name}.csv')) REJECT LIMIT 0")
            _execute_ignoring(cur, f'DROP TABLE legacy."{t.name}" PURGE', 942)
            ddl = ", ".join(f'"{c.name}" {ora_type(c.tsql)}' for c in cols)
            cur.execute(f'CREATE TABLE legacy."{t.name}" ({ddl})')
            cur.execute(f'INSERT /*+ APPEND */ INTO legacy."{t.name}" SELECT '
                        f'{", ".join(_convert(c) for c in cols)} FROM {ext}')
            loaded = cur.rowcount
            conn.commit()
            check(t, loaded, man)
            if t.primary_key:
                cur.execute(f'ALTER TABLE legacy."{t.name}" ADD PRIMARY KEY ("{t.primary_key}")')
            cur.execute(f"DROP TABLE {ext} PURGE")
            # Sin comillas dobles, DBMS_STATS pasa el nombre a mayúsculas y no encuentra "Pacientes".
            cur.execute("BEGIN DBMS_STATS.GATHER_TABLE_STATS('LEGACY', :t); END;", t=f'"{t.name}"')
    elapsed = f" en {time.time() - started:.0f} s" if private else " (🔒 el tiempo de Oracle no se muestra)"
    log(f"  oracle: {len(tables)} tablas{elapsed}")


def measure(query: str, private: bool = False) -> dict:
    with connect() as conn, conn.cursor() as cur:
        if private:
            cur.execute("ALTER SESSION SET statistics_level = ALL")
            cur.execute(query)
            cur.fetchall()
            cur.execute("SELECT plan_table_output FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(format => 'ALLSTATS LAST'))")
        else:
            cur.execute("EXPLAIN PLAN FOR " + query)
            cur.execute("SELECT plan_table_output FROM TABLE(DBMS_XPLAN.DISPLAY(format => 'BASIC +PREDICATE'))")
        return {"plan": [r[0] for r in cur.fetchall()], "private": private}
