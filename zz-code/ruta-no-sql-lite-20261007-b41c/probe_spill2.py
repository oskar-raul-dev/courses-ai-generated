# Sondeo: sin directorio temporal, y con un hilo a 128 MB.
import duckdb, json
Q = "SELECT aircraft, ts, egt_c FROM reading_x10 ORDER BY egt_c, ts"
for lim, threads, tmp in [("512MB", 8, ""), ("128MB", 1, "../../../zz-code/ruta-no-sql-lite-20261007-b41c/salidas/duck_tmp"), ("128MB", 8, "../../../zz-code/ruta-no-sql-lite-20261007-b41c/salidas/duck_tmp")]:
    c = duckdb.connect("lab/data/analitico/condor.duckdb", read_only=True)
    c.execute(f"SET memory_limit='{lim}'"); c.execute(f"SET threads={threads}"); c.execute(f"SET temp_directory='{tmp}'")
    try:
        j = json.loads(c.sql("EXPLAIN (ANALYZE, FORMAT json) " + Q).fetchall()[0][1])
        print(lim, threads, repr(tmp)[:5], "temp", j.get("system_peak_temp_dir_size"), "buffer", j.get("system_peak_buffer_memory"), round(j["latency"],2))
    except Exception as e:
        print(lim, threads, repr(tmp)[:5], str(e).splitlines()[0])
    c.close()
