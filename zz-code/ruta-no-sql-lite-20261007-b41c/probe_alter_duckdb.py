# Sondeo: qué escribe DuckDB al añadir una métrica nueva, de tres formas.
import duckdb, json, os, time
DB = "lab/data/analitico/alter-probe.duckdb"
for f in (DB, DB + ".wal"):
    if os.path.exists(f): os.remove(f)
c = duckdb.connect(DB)
c.execute("ATTACH 'lab/data/analitico/condor.duckdb' AS src (READ_ONLY)")
c.execute("CREATE TABLE r AS SELECT * FROM src.reading_x10"); c.execute("CHECKPOINT")
print("base", os.path.getsize(DB) / 2**20)
def prof(sql):
    j = json.loads(c.sql("EXPLAIN (ANALYZE, FORMAT json) " + sql).fetchall()[0][1]) if not sql.startswith("ALTER") else None
    return j
for sql in ["ALTER TABLE r ADD COLUMN m0 INTEGER DEFAULT 0",
            "ALTER TABLE r ADD COLUMN m1 INTEGER",
            "UPDATE r SET m1 = 765 - egt_c",
            "ALTER TABLE r ADD COLUMN m2 INTEGER GENERATED ALWAYS AS (765 - egt_c) VIRTUAL"]:
    t = time.time()
    try:
        if sql.startswith("UPDATE"):
            j = json.loads(c.sql("EXPLAIN (ANALYZE, FORMAT json) " + sql).fetchall()[0][1])
            print("written", j.get("total_bytes_written"), j.get("total_bytes_read"))
        else:
            c.execute(sql)
        w = os.path.getsize(DB + ".wal") if os.path.exists(DB + ".wal") else 0
        c.execute("CHECKPOINT")
        print(f"{sql[:60]:60} {time.time()-t:6.1f}s wal_antes_ckpt {w/2**20:8.1f} MiB archivo {os.path.getsize(DB)/2**20:8.1f} MiB")
    except Exception as e:
        print(sql[:60], repr(e)[:300])
