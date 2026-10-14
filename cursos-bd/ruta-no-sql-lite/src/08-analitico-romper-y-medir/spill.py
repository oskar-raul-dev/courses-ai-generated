# El dato que no cabe en memoria, del lado de DuckDB: dos consultas sobre las 50 M lecturas con el
# límite de memoria cada vez más bajo, midiendo lo que vuelca al directorio temporal y la memoria que
# usó, según su perfilador. Al final, sin directorio temporal, y con un solo hilo.
#
#   uv run python 08-analitico-romper-y-medir/spill.py   (desde src/)
import json
import shutil
from pathlib import Path

import duckdb

TMP = Path("lab/data/analitico/spill.tmp")
QUERIES = {
    # 624 860 vuelos: muchos grupos, pero cada uno pequeño
    "group-by-flight": "SELECT flight_id, avg(egt_c), max(ts) FROM reading_x10 GROUP BY flight_id",
    # ordenar 50 M filas de tres columnas: hay que tenerlas todas antes de devolver la primera
    "order-by-egt": "SELECT aircraft, ts, egt_c FROM reading_x10 ORDER BY egt_c, ts",
}
RUNS = [("4GB", 8, True), ("512MB", 8, True), ("256MB", 8, True), ("128MB", 8, True), ("128MB", 1, True), ("512MB", 8, False)]

print(f"DuckDB {duckdb.__version__} · reading_x10, 50 M")
for limit, threads, temp in RUNS:
    for name, sql in QUERIES.items():
        shutil.rmtree(TMP, ignore_errors=True)
        with duckdb.connect("lab/data/analitico/condor.duckdb", read_only=True) as con:
            con.execute(f"SET memory_limit = '{limit}'")
            con.execute(f"SET threads = {threads}")
            # sin directorio temporal, DuckDB no tiene dónde volcar
            con.execute(f"SET temp_directory = '{TMP if temp else ''}'")
            label = f"{limit:>6} · {threads} hilos · {'con' if temp else 'sin'} temporal · {name:16}"
            try:
                p = json.loads(con.sql(f"EXPLAIN (ANALYZE, FORMAT json) {sql}").fetchall()[0][1])
                print(f"  {label} volcado {p['system_peak_temp_dir_size'] / 2**20:7.1f} MiB · "
                      f"memoria {p['system_peak_buffer_memory'] / 2**20:7.1f} MiB · {p['latency']:.1f} s")
            except duckdb.OutOfMemoryException as e:
                print(f"  {label} {str(e).splitlines()[0]}")
shutil.rmtree(TMP, ignore_errors=True)
