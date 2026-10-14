# Sondeo: cuándo vuelca DuckDB a disco con memory_limit bajo, y qué pasa sin directorio temporal.
import duckdb, json, sys
Q = {"groupby": "SELECT flight_id, avg(egt_c), max(ts) FROM reading_x10 GROUP BY flight_id",
     "orderby": "SELECT * FROM reading_x10 ORDER BY egt_c, ts, aircraft LIMIT -1 OFFSET 49999999",
     "orderby2": "SELECT aircraft, ts, egt_c FROM reading_x10 ORDER BY egt_c, ts"}
for lim in ["4GB", "512MB", "256MB", "128MB"]:
    for name, q in Q.items():
        c = duckdb.connect("lab/data/analitico/condor.duckdb", read_only=True)
        c.execute(f"SET memory_limit='{lim}'"); c.execute("SET threads=8")
        c.execute("SET temp_directory='../../../zz-code/ruta-no-sql-lite-20261007-b41c/salidas/duck_tmp'")
        try:
            j = json.loads(c.sql("EXPLAIN (ANALYZE, FORMAT json) " + q).fetchall()[0][1])
            print(lim, name, "temp", j.get("system_peak_temp_dir_size"), "buffer", j.get("system_peak_buffer_memory"), round(j["latency"],2))
        except Exception as e:
            print(lim, name, repr(e)[:400])
        c.close()
