"""PostgreSQL: la caja entera en `legacy`, la verdad en `truth`, y la medición de la forma."""

import json
import time

import psycopg
from psycopg import sql

from .. import config
from ..generator import schema
from . import LoadError, caja_path, check

TRUTH = {
    "person": "person_id integer PRIMARY KEY, sex char(1), birth_date date, document_type text, "
              "document_country text, document_number text, later_dni text, mother_person_id integer, payer_code text",
    "patient_record": "legacy_patient_id integer PRIMARY KEY, person_id integer NOT NULL, dirt text[] NOT NULL",
    "parser_case": "legacy_patient_id integer PRIMARY KEY, expected_dni text, expected_payer text",
    "order_payer": "legacy_protocol_id integer PRIMARY KEY, person_id integer NOT NULL, payer_code text, written_as text",
    "result_value": "legacy_result_item_id integer PRIMARY KEY, value_numeric numeric, qualifier text, "
                    "value_text text, state text NOT NULL",
    "planted_case": "case_code text PRIMARY KEY, person_id integer NOT NULL, note text",
    "antibiogram": "culture_id integer NOT NULL, person_id integer NOT NULL, culture_date date NOT NULL, "
                   "germ text NOT NULL, antibiotic text NOT NULL, sensitivity char(1) NOT NULL",
}


def pg_type(tsql: str) -> str:
    base, _, size = tsql.partition("(")
    size = size.rstrip(")")
    return {"int": "integer", "bigint": "bigint", "datetime": "timestamp(3)", "money": "numeric(19,4)",
            "bit": "boolean", "decimal": f"numeric({size})",
            "nvarchar": "text" if size == "max" else f"varchar({size})"}[base]


def connect(**kw) -> psycopg.Connection:
    return psycopg.connect(**config.POSTGRES, **kw)


def load(profile: str, man: dict, tables: list[schema.Table], log=print) -> None:
    whole = len(tables) == len(schema.TABLES)
    started = time.time()
    with connect(autocommit=True) as conn:
        if whole:
            conn.execute("DROP SCHEMA IF EXISTS legacy CASCADE")
        conn.execute("CREATE SCHEMA IF NOT EXISTS legacy")
        for t in tables:
            ident = sql.Identifier("legacy", t.name)
            cols = sql.SQL(", ").join(sql.SQL("{} {}").format(sql.Identifier(c.name), sql.SQL(pg_type(c.tsql)))
                                      for c in t.exported_columns)
            conn.execute(sql.SQL("DROP TABLE IF EXISTS {}").format(ident))
            conn.execute(sql.SQL("CREATE TABLE {} ({})").format(ident, cols))
            encoding = sql.SQL(", ENCODING 'LATIN1'") if t.encoding == "latin-1" else sql.SQL("")
            cur = conn.execute(sql.SQL("COPY {} FROM {} WITH (FORMAT csv, HEADER true{})").format(
                ident, sql.Literal(caja_path(profile, t)), encoding))
            check(t, cur.rowcount, man)
            if t.primary_key:
                conn.execute(sql.SQL("ALTER TABLE {} ADD PRIMARY KEY ({})").format(ident, sql.Identifier(t.primary_key)))
        log(f"  legacy: {len(tables)} tablas ({time.time() - started:.0f} s)")
        if whole:
            _load_truth(conn, profile, man)
            log(f"  truth: {len(TRUTH)} tablas ({time.time() - started:.0f} s)")
        conn.execute("CREATE SCHEMA IF NOT EXISTS lab")
        conn.execute("CREATE TABLE IF NOT EXISTS lab.loaded (profile text, seed integer, sha256 text, "
                     "tables integer, loaded_at timestamptz DEFAULT now())")
        if whole:
            conn.execute("DELETE FROM lab.loaded")     # la caja entera reemplaza a la anterior
        conn.execute("INSERT INTO lab.loaded (profile, seed, sha256, tables) VALUES (%s, %s, %s, %s)",
                     (profile, man["seed"], man["sha256"], len(tables)))
        conn.execute("ANALYZE")
    log(f"  postgres: listo en {time.time() - started:.0f} s")


def _load_truth(conn, profile: str, man: dict) -> None:
    conn.execute("DROP SCHEMA IF EXISTS truth CASCADE")
    conn.execute("CREATE SCHEMA truth")
    for name, ddl in TRUTH.items():
        conn.execute(f"CREATE TABLE truth.{name} ({ddl})")
        cur = conn.execute(sql.SQL("COPY {} FROM {} WITH (FORMAT csv, HEADER true)").format(
            sql.Identifier("truth", name), sql.Literal(f"/caja/{profile}/truth/{name}.csv")))
        expected = man["rows"].get(f"truth/{name}.csv")
        if expected is not None and cur.rowcount != expected:
            raise LoadError(f"truth.{name}: {cur.rowcount} filas, el generador escribió {expected}")


# --- La medición ---------------------------------------------------------------------------------

def measure(query: str) -> dict:
    with connect(autocommit=True) as conn:
        row = conn.execute(f"EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) {query}").fetchone()[0]
    plan = row[0] if isinstance(row, list) else json.loads(row)[0]
    root = plan["Plan"]
    lines, leaves = [], []
    _walk(root, 0, lines, leaves)
    return {
        "rows": root["Actual Rows"] * root.get("Actual Loops", 1),
        "estimated_rows": root["Plan Rows"],
        "shared_hit": root.get("Shared Hit Blocks", 0),
        "shared_read": root.get("Shared Read Blocks", 0),
        "examined": sum(leaves),
        "plan": lines,
        "time_ms": plan.get("Execution Time"),
    }


def _walk(node: dict, depth: int, lines: list[str], leaves: list[int]) -> None:
    rel = f" on {node['Relation Name']}" if "Relation Name" in node else ""
    idx = f" using {node['Index Name']}" if "Index Name" in node else ""
    loops = node.get("Actual Loops", 1)
    actual = node.get("Actual Rows", 0) * loops
    removed = node.get("Rows Removed by Filter", 0) * loops
    buffers = node.get("Shared Hit Blocks", 0) + node.get("Shared Read Blocks", 0)
    real = int(actual) if float(actual).is_integer() else round(actual, 1)
    gone = int(removed) if float(removed).is_integer() else round(removed, 1)
    lines.append(f"{'  ' * depth}{node['Node Type']}{rel}{idx} · estimadas {node['Plan Rows']} · "
                 f"reales {real}{f' · descartadas {gone}' if removed else ''} · bloques {buffers}")
    children = node.get("Plans", [])
    if not children:
        leaves.append(actual + removed)
    for child in children:
        _walk(child, depth + 1, lines, leaves)
