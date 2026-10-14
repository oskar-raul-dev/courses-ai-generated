# ¿Se reconstruye el tablero desde la fuente de verdad? La Fase 07 cargó Postgres (base `analitico`) desde
# DuckDB; aquí la dirección se invierte: se arma una base de DuckDB nueva solo con lo que Postgres tiene, y se
# compara con condor.duckdb, la que salió del dataset. Si la huella de cada tabla y el costo por hora coinciden
# fila por fila, el tablero es un índice; si no, es otra verdad.
#
#   uv run python 23-poliglota-el-diseno/rebuild_duckdb.py   (desde src/, con base arriba y build.py ya corrido)
import os
import time
from pathlib import Path

import duckdb
import psycopg

out = Path("lab/data/analitico")
rebuilt = out / "condor-rebuilt.duckdb"
rebuilt.unlink(missing_ok=True)
port = int(os.environ.get("BASE_PORT", 15432))

# los tipos, declarados: los mismos que build.py le dio a DuckDB
TABLES = {
    "aircraft": [("registration", "VARCHAR"), ("model", "VARCHAR"), ("kind", "VARCHAR"), ("operator_id", "VARCHAR"),
                 ("country", "VARCHAR"), ("has_flight_recorder", "BOOLEAN"), ("continuous_wing_contract", "BOOLEAN")],
    "work_order": [("work_order_id", "VARCHAR"), ("aircraft", "VARCHAR"), ("hangar_id", "VARCHAR"), ("type", "VARCHAR"),
                   ("opened_at", "TIMESTAMP"), ("closed_at", "TIMESTAMP"), ("labor_hours", "INTEGER"),
                   ("labor_cost_usd", "DECIMAL(12, 2)"), ("parts_cost_usd", "DECIMAL(12, 2)")],
    "reading": [("aircraft", "VARCHAR"), ("flight_id", "VARCHAR"), ("ts", "TIMESTAMP"), ("altitude_ft", "INTEGER"),
                ("ias_kt", "INTEGER"), ("egt_c", "INTEGER"), ("n1_pct", "INTEGER"), ("oil_press_psi", "INTEGER"),
                ("oil_temp_c", "INTEGER"), ("fuel_flow_pph", "INTEGER")],
}

started = time.time()
duck = duckdb.connect(str(rebuilt))
duck.execute("SET TimeZone = 'UTC'")
with psycopg.connect(f"host=localhost port={port} user=postgres password=condor dbname=analitico") as pg:
    pg.execute("SET TimeZone = 'UTC'")
    for table, columns in TABLES.items():
        csv = out / f"rebuild-{table}.csv"
        with pg.cursor().copy(f"COPY {table} TO STDOUT (FORMAT csv)") as copy, csv.open("wb") as f:
            for chunk in copy:
                f.write(chunk)
        spec = ", ".join(f"'{name}': '{kind}'" for name, kind in columns)
        duck.execute(f"CREATE TABLE {table} AS SELECT * FROM read_csv('{csv}', header = false, columns = {{{spec}}})")
        csv.unlink()
print(f"reconstruida desde Postgres en {time.time() - started:.1f} s")

# la huella de cada tabla: conteo y sumas de todo lo que se puede sumar, en las dos bases
FINGERPRINT = {
    "aircraft": "count(*), count(DISTINCT registration), string_agg(registration || model || operator_id || country "
                "|| has_flight_recorder || continuous_wing_contract, ',' ORDER BY registration)",
    "work_order": "count(*), min(opened_at), max(closed_at), sum(labor_hours), sum(labor_cost_usd), sum(parts_cost_usd), "
                  "count(DISTINCT aircraft), count(DISTINCT hangar_id || type)",
    "reading": "count(*), count(DISTINCT flight_id), min(ts), max(ts), sum(altitude_ft), sum(ias_kt), sum(egt_c), "
               "sum(n1_pct), sum(oil_press_psi), sum(oil_temp_c), sum(fuel_flow_pph)",
}
original = duckdb.connect(str(out / "condor.duckdb"), read_only=True)
for db in (original, duck):
    db.execute("SET TimeZone = 'UTC'")
for table, expr in FINGERPRINT.items():
    a = original.sql(f"SELECT {expr} FROM {table}").fetchone()
    b = duck.sql(f"SELECT {expr} FROM {table}").fetchone()
    print(f"  {table:10} {'igual' if a == b else 'DISTINTA'} · {a[0]} filas")

query = Path("07-analitico-levantar-y-modelar/cost_per_hour.sql").read_text()
a = original.sql(query).fetchall()
b = duck.sql(query).fetchall()
diff = sum(1 for x, y in zip(a, b) if x != y) + abs(len(a) - len(b))
print(f"  costo por hora: {len(a)} filas en la original, {len(b)} en la reconstruida, {diff} distintas")
