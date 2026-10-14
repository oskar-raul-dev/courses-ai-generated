# Sondeo: qué expone el perfilador de DuckDB 1.5.6 y pragma_storage_info.
import duckdb, json
c = duckdb.connect('lab/data/analitico/condor.duckdb', read_only=True)
c.execute("SET threads=8")
r = c.sql("EXPLAIN (ANALYZE, FORMAT json) SELECT aircraft, avg(egt_c), avg(fuel_flow_pph) FROM reading_x10 GROUP BY aircraft").fetchall()
j = json.loads(r[0][1])
print(json.dumps(j, indent=1)[:3000])
print(c.sql("SELECT column_name, count(*) segs, count(DISTINCT block_id) blocks, sum(count) rows, any_value(compression) FROM pragma_storage_info('reading_x10') GROUP BY column_name ORDER BY column_name"))
print(c.sql("SELECT * FROM pragma_storage_info('reading_x10') LIMIT 3"))
print(c.sql("SELECT count(DISTINCT row_group_id) FROM pragma_storage_info('reading_x10')"))
