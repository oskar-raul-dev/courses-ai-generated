# Sondeo: bytes por columna en DuckDB (pragma_storage_info) y bytes leídos según el perfilador.
import duckdb, json
c = duckdb.connect('lab/data/analitico/condor.duckdb', read_only=True)
print(c.sql("SELECT * FROM pragma_storage_info('reading_x10') LIMIT 3"))
print(c.sql("""SELECT column_name, count(*) segs, count(DISTINCT block_id) blks, sum(count) n, string_agg(DISTINCT compression, ',') comp
  FROM pragma_storage_info('reading_x10') WHERE segment_type <> 'VALIDITY' GROUP BY column_name ORDER BY column_name"""))
print(c.sql("SELECT count(DISTINCT row_group_id) FROM pragma_storage_info('reading_x10')"))
def bytes_read(q):
    j = json.loads(c.sql("EXPLAIN (ANALYZE, FORMAT json) " + q).fetchall()[0][1])
    return j["total_bytes_read"], j["cumulative_rows_scanned"]
for q in ["SELECT count(*) FROM reading_x10",
          "SELECT avg(egt_c) FROM reading_x10",
          "SELECT aircraft, avg(egt_c), avg(fuel_flow_pph) FROM reading_x10 GROUP BY aircraft",
          "SELECT * FROM reading_x10 WHERE egt_c = -1",
          "SELECT avg(egt_c) FROM reading_x10 WHERE aircraft = 'HK-4207'",
          ]:
    for i in range(2):
        print(bytes_read(q), q)
