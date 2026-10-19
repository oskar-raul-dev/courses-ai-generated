"""ss02 ej16 · la lectura larga de 03_version_store.py, en Postgres (publicable)."""
import sys
sys.path.insert(0, "/src")
from lab.engines import postgres

SIZE = "SELECT pg_relation_size('staging.hemogram') / 1024"
with postgres.connect(autocommit=True) as w, postgres.connect() as r, postgres.connect(autocommit=True) as x:
    w.execute("VACUUM staging.hemogram")
    print("antes                  hemogram", w.execute(SIZE).fetchone()[0], "KB")
    r.execute("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ")
    first = r.execute("SELECT count(*) FROM staging.hemogram WHERE hematocrit IS NOT NULL").fetchone()[0]
    for i in range(3):
        x.execute("UPDATE staging.hemogram SET version = version + 1")
    print("con la lectura abierta hemogram", w.execute(SIZE).fetchone()[0], "KB")
    w.execute("VACUUM staging.hemogram")
    print("VACUUM con la lectura  hemogram", w.execute(SIZE).fetchone()[0], "KB",
          "· muertas", w.execute("SELECT n_dead_tup FROM pg_stat_user_tables WHERE relid = 'staging.hemogram'::regclass").fetchone()[0])
    again = r.execute("SELECT count(*) FROM staging.hemogram WHERE hematocrit IS NOT NULL").fetchone()[0]
    print("la lectura ve la misma foto:", first == again)
    r.commit()
    w.execute("VACUUM staging.hemogram")
    print("VACUUM al cerrarla     hemogram", w.execute(SIZE).fetchone()[0], "KB",
          "· muertas", w.execute("SELECT n_dead_tup FROM pg_stat_user_tables WHERE relid = 'staging.hemogram'::regclass").fetchone()[0])
    x.execute("UPDATE staging.hemogram SET version = 1")
    w.execute("VACUUM staging.hemogram")
