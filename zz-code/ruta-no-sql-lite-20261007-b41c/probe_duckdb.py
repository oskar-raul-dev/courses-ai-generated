# Sondeo: cómo lee DuckDB el NDJSON de reading-5m y qué tipos infiere.
import duckdb, sys, time
DS = sys.argv[1]
con = duckdb.connect()
t = time.time()
print(con.sql(f"DESCRIBE SELECT * FROM read_json('{DS}/reading.ndjson')"))
print(con.sql(f"DESCRIBE SELECT * FROM read_json('{DS}/workOrder.ndjson')"))
print(con.sql(f"SELECT count(*), min(ts), max(ts), count(*) FILTER (WHERE ts > TIMESTAMPTZ '2026-09-30 23:59:59+00') FROM read_json('{DS}/reading.ndjson')"))
print(time.time()-t)
