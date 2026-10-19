"""ss02 · §5.4. Dónde guarda SQL Server las versiones de fila, y cuándo las suelta.

Una lectura SNAPSHOT queda abierta mientras otra sesión corrige los 29.241 hemogramas tres veces (la media hora
cargada de la Fase 17, en chico). Se mira el *version store* de tempdb antes, con la lectura abierta y después de
cerrarla, y el tamaño de la tabla. Cada corrección suma uno a `version`: una versión nueva de cada fila sin tocar los datos.

Todo lo que imprime es un resultado de SQL Server: es para ti, y no se publica (apéndice a09).

    uv run --extra sqlserver python ss02-pesimista-contra-rcsi/03_version_store.py      (desde src/, después de 02_snapshot.sql)
"""

import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from lab.engines import sqlserver  # noqa: E402

STORE = ("SELECT COALESCE(SUM(reserved_space_kb), 0) FROM sys.dm_tran_version_store_space_usage "
         "WHERE database_id = DB_ID('ss02')")
TABLE = ("SELECT SUM(used_page_count) * 8 FROM sys.dm_db_partition_stats "
         "WHERE object_id = OBJECT_ID('dbo.hemogram')")


def one(cur, sql):
    cur.execute(sql)
    return cur.fetchone()[0]


def main() -> None:
    watch = sqlserver.connect("ss02")
    w = watch.cursor()
    reader = sqlserver.connect("ss02")
    r = reader.cursor()
    writer = sqlserver.connect("ss02")
    x = writer.cursor()
    print("🔒 PRIVADO: resultados de SQL Server. No los publiques (apéndice a09).")
    print(f"antes                 version store {one(w, STORE)} KB · hemogram {one(w, TABLE)} KB")
    r.execute("SET TRANSACTION ISOLATION LEVEL SNAPSHOT; BEGIN TRAN;")
    first = one(r, "SELECT COUNT(*) FROM dbo.hemogram WHERE hematocrit IS NOT NULL")
    for i in range(3):
        x.execute("UPDATE dbo.hemogram SET version = version + 1")      # una corrección de cada fila, sin tocar datos
    time.sleep(1)
    print(f"con la lectura abierta version store {one(w, STORE)} KB · hemogram {one(w, TABLE)} KB")
    again = one(r, "SELECT COUNT(*) FROM dbo.hemogram WHERE hematocrit IS NOT NULL")
    print(f"la lectura ve la misma foto: {first == again}")
    r.execute("COMMIT")
    for _ in range(30):                     # el limpiador del version store corre cada minuto, más o menos
        time.sleep(5)
        size = one(w, STORE)
        if size == 0:
            break
    print(f"cerrada la lectura    version store {size} KB · hemogram {one(w, TABLE)} KB")
    x.execute("UPDATE dbo.hemogram SET version = 1")
    for c in (watch, reader, writer):
        c.close()


if __name__ == "__main__":
    main()
