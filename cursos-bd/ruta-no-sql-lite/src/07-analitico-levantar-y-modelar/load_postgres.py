# Carga en Postgres (base `analitico`, perfil base) lo mismo que tiene DuckDB: aircraft y work_order
# leídas de condor.duckdb, las lecturas desde reading.csv con su hash comprobado, y la ampliación ×10
# hecha dentro del motor con generate_series, igual que la de build.py.
#
#   uv run python 07-analitico-levantar-y-modelar/load_postgres.py [--copies 10]   (desde src/)
import argparse
import hashlib
import os
import time
from pathlib import Path

import duckdb
import psycopg

parser = argparse.ArgumentParser()
parser.add_argument("--copies", type=int, default=10)
args = parser.parse_args()

out = Path("lab/data/analitico")
csv = out / "reading.csv"
expected = (out / "reading.csv.sha256").read_text().split()[0]
h = hashlib.sha256()
with csv.open("rb") as f:
    for chunk in iter(lambda: f.read(1 << 20), b""):
        h.update(chunk)
if h.hexdigest() != expected:
    raise SystemExit("reading.csv no coincide con su hash: vuelve a correr build.py")

port = int(os.environ.get("BASE_PORT", 15432))
dsn = f"host=localhost port={port} user=postgres password=condor"
with psycopg.connect(dsn + " dbname=postgres", autocommit=True) as admin:
    admin.execute("DROP DATABASE IF EXISTS analitico")
    admin.execute("CREATE DATABASE analitico")

duck = duckdb.connect(str(out / "condor.duckdb"), read_only=True)
with psycopg.connect(dsn + " dbname=analitico", autocommit=True) as pg:
    pg.execute("SET TimeZone = 'UTC'")
    pg.execute("""
        CREATE TABLE aircraft (registration text PRIMARY KEY, model text, kind text, operator_id text,
            country text, has_flight_recorder boolean, continuous_wing_contract boolean);
        CREATE TABLE work_order (work_order_id text PRIMARY KEY, aircraft text, hangar_id text, type text,
            opened_at timestamp, closed_at timestamp, labor_hours integer,
            labor_cost_usd numeric(12, 2), parts_cost_usd numeric(12, 2));
        -- timestamp sin zona, como en DuckDB: todo el dataset está en UTC
        CREATE TABLE reading (aircraft text, flight_id text, ts timestamp, altitude_ft integer,
            ias_kt integer, egt_c integer, n1_pct integer, oil_press_psi integer, oil_temp_c integer,
            fuel_flow_pph integer);
    """)
    started = time.time()
    for table in ("aircraft", "work_order"):
        rows = duck.sql(f"SELECT * FROM {table}").fetchall()
        with pg.cursor().copy(f"COPY {table} FROM STDIN") as copy:
            for row in rows:
                copy.write_row(row)
    with pg.cursor().copy("COPY reading FROM STDIN (FORMAT csv)") as copy, csv.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            copy.write(chunk)
    print(f"cargado: {time.time() - started:.1f} s")

    started = time.time()
    pg.execute(f"""
        CREATE TABLE reading_x10 AS
        SELECT CASE WHEN k = 0 THEN aircraft ELSE aircraft || '~' || k END AS aircraft,
               CASE WHEN k = 0 THEN flight_id ELSE flight_id || '~' || k END AS flight_id,
               ts, altitude_ft, ias_kt, egt_c, n1_pct, oil_press_psi, oil_temp_c, fuel_flow_pph
        FROM generate_series(0, {args.copies - 1}) AS k, reading
        ORDER BY k, aircraft, ts
    """)
    print(f"ampliado ×{args.copies}: {time.time() - started:.1f} s")
    # VACUUM deja el mapa de visibilidad al día: sin él no hay index-only scan que medir
    pg.execute("VACUUM ANALYZE")
    for t in ("aircraft", "work_order", "reading", "reading_x10"):
        n, size = pg.execute(f"SELECT count(*), pg_size_pretty(pg_table_size('{t}')) FROM {t}").fetchone()
        print(f"  {t:12} {n:>10} filas · {size}")
