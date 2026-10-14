# El tablero de DuckDB del boss del Bloque II, como lo dejó quien lo armó: el costo por hora volada del
# Twin Otter en lo que va de 2026, sobre la base de la Fase 07.
#
#   uv run python 12-busqueda-romper-y-medir/boss/tablero_duckdb.py   (desde src/)
import duckdb

con = duckdb.connect("lab/data/analitico/condor.duckdb", read_only=True)
con.execute("SET TimeZone = 'UTC'")
row = con.sql("""
    WITH fleet AS (SELECT registration FROM aircraft WHERE model = 'DHC-6-300 Twin Otter' AND has_flight_recorder),
    hours AS (SELECT count(*) / 60.0 AS h FROM reading WHERE aircraft IN (SELECT registration FROM fleet) AND year(ts) = 2026),
    cost AS (SELECT sum(labor_cost_usd + parts_cost_usd) AS c FROM work_order
             WHERE aircraft IN (SELECT registration FROM fleet) AND year(opened_at) = 2026)
    SELECT round(c, 2), round(h, 1), round(c / h, 2) FROM hours, cost
""").fetchone()
print(f"DuckDB     · Twin Otter, 2026 · costo {row[0]} USD · horas {row[1]} · {row[2]} USD por hora volada")
