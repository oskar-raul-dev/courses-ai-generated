# La apuesta de la Fase 08, del lado de DuckDB: la misma métrica nueva (765 − egt_c) sobre las mismas
# 50 M lecturas, en una copia de reading_x10 dentro de un archivo aparte. Se mide lo que crece el
# archivo después de un CHECKPOINT (el perfilador no cuenta bytes escritos) y lo que queda en el WAL.
#
#   uv run python 08-analitico-romper-y-medir/alter.py   (desde src/, con condor.duckdb de la Fase 07)
import os
import time
from pathlib import Path

import duckdb

DB = Path("lab/data/analitico/alter.duckdb")
WAL = Path(f"{DB}.wal")
FORMS = {
    "constant": ["ALTER TABLE reading_alter ADD COLUMN egt_margin_c INTEGER DEFAULT 0"],
    "update": ["ALTER TABLE reading_alter ADD COLUMN egt_margin_c INTEGER",
               "UPDATE reading_alter SET egt_margin_c = 765 - egt_c"],
    # DuckDB solo tiene columnas generadas virtuales, y solo al crear la tabla
    "virtual": ["ALTER TABLE reading_alter ADD COLUMN egt_margin_c INTEGER GENERATED ALWAYS AS (765 - egt_c) VIRTUAL"],
}

print(f"DuckDB {duckdb.__version__} · copia de reading_x10 por forma")
for name, statements in FORMS.items():
    for f in (DB, WAL):
        f.unlink(missing_ok=True)
    con = duckdb.connect(str(DB))
    con.execute("ATTACH 'lab/data/analitico/condor.duckdb' AS src (READ_ONLY)")
    con.execute("CREATE TABLE reading_alter AS SELECT * FROM src.reading_x10")
    con.execute("CHECKPOINT")
    before = DB.stat().st_size
    started = time.time()
    try:
        for sql in statements:
            con.execute(sql)
        wal = WAL.stat().st_size if WAL.exists() else 0
        con.execute("CHECKPOINT")
        after = DB.stat().st_size
        print(f"  {name:9} WAL antes del checkpoint {wal / 2**20:6.1f} MiB · archivo {before / 2**20:7.1f} → "
              f"{after / 2**20:7.1f} MiB (+{(after - before) / 2**20:.1f}) · {time.time() - started:.1f} s")
    except duckdb.Error as e:
        print(f"  {name:9} {type(e).__name__}: {e}")
    con.close()
for f in (DB, WAL):
    f.unlink(missing_ok=True)
