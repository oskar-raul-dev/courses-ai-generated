# El plan de DuckDB, leído del perfil JSON: un operador por línea, con las filas que produjo, las que
# recorrió y lo que dice de él (columnas proyectadas, filtros, grupos). Es lo mismo que dibuja
# EXPLAIN ANALYZE, en un formato que se puede comparar con el de Postgres.
#
#   uv run python 08-analitico-romper-y-medir/explain.py [archivo.sql]   (desde src/)
#   por defecto, la consulta de Lucía de la Fase 07 (cost_per_hour.sql)
import json
import sys

import duckdb

path = sys.argv[1] if len(sys.argv) > 1 else "07-analitico-levantar-y-modelar/cost_per_hour.sql"
sql = open(path).read().strip().rstrip(";")
# sin los comentarios de cabecera, que EXPLAIN no necesita
sql = "\n".join(l for l in sql.splitlines() if not l.lstrip().startswith("--"))

with duckdb.connect("lab/data/analitico/condor.duckdb", read_only=True) as con:
    profile = json.loads(con.sql(f"EXPLAIN (ANALYZE, FORMAT json) {sql}").fetchall()[0][1])


def show(node: dict, depth: int) -> None:
    info = node.get("extra_info", {})
    details = []
    for key in ("Table", "Projections", "Filters", "Groups", "Aggregates", "Join Type", "Conditions"):
        if key in info:
            value = info[key]
            details.append(f"{key}: {', '.join(value) if isinstance(value, list) else value}")
    scanned = node.get("operator_rows_scanned", 0)
    print(f"{'  ' * depth}{node['operator_name'].strip()} · filas {node['operator_cardinality']}"
          f"{f' · recorridas {scanned}' if scanned else ''}{' · ' + ' · '.join(details) if details else ''}")
    for child in node.get("children", []):
        show(child, depth + 1)


print(f"{path} · leídos {profile['total_bytes_read'] / 2**20:.1f} MiB")
for child in profile["children"][0]["children"]:  # debajo de EXPLAIN_ANALYZE
    show(child, 0)
