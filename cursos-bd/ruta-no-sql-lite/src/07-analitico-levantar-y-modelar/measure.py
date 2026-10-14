# Lo que lee DuckDB para contestar: filas recorridas y bytes leídos del archivo, según su propio
# perfilador. Cada consulta corre con una conexión nueva, en frío: con la misma conexión, la
# segunda vez lee 0 bytes porque los bloques ya están en su caché.
#
#   uv run python 07-analitico-levantar-y-modelar/measure.py [--table reading_x10]   (desde src/)
#
# Las mismas consultas, en Postgres: measure.ts.
import argparse
import json

import duckdb

parser = argparse.ArgumentParser()
parser.add_argument("--table", default="reading_x10")
args = parser.parse_args()
T = args.table

COLUMNS = ["aircraft", "flight_id", "ts", "altitude_ft", "ias_kt", "egt_c", "n1_pct", "oil_press_psi", "oil_temp_c", "fuel_flow_pph"]
QUERIES = {
    # las diez columnas: lo que cuesta leer la tabla entera (max y no count: DuckDB contesta un
    # count(columna) con las estadísticas del archivo, sin leerla)
    "all-columns": f"SELECT {', '.join(f'max({c})' for c in COLUMNS)} FROM {T}",
    # una columna
    "one-column": f"SELECT avg(egt_c) FROM {T}",
    # tres columnas: la consulta de la sección 6.6
    "three-columns": f"SELECT aircraft, avg(egt_c), avg(fuel_flow_pph) FROM {T} GROUP BY aircraft",
    # un valor que no existe: el mínimo y el máximo de cada grupo de filas lo descartan sin leerlo
    "egt-out-of-range": f"SELECT count(*) FROM {T} WHERE egt_c = -1",
    # una aeronave: la tabla está ordenada por matrícula, así que casi todos los grupos se saltan
    "one-aircraft": f"SELECT avg(egt_c) FROM {T} WHERE aircraft = 'HK-4207'",
}

db = "lab/data/analitico/condor.duckdb"
with duckdb.connect(db, read_only=True) as con:
    row_groups = con.sql(f"SELECT count(DISTINCT row_group_id) FROM pragma_storage_info('{T}')").fetchone()[0]
    rows = con.sql(f"SELECT count(*) FROM {T}").fetchone()[0]
print(f"{T}: {rows} filas en {row_groups} grupos de filas · DuckDB {duckdb.__version__}")

for name, sql in QUERIES.items():
    with duckdb.connect(db, read_only=True) as con:
        profile = json.loads(con.sql(f"EXPLAIN (ANALYZE, FORMAT json) {sql}").fetchall()[0][1])
    scanned = profile["cumulative_rows_scanned"]
    read = profile["total_bytes_read"]
    print(f"  {name:17} filas recorridas {scanned:>10} · leídos {read / 2**20:8.1f} MiB · {sql}")
