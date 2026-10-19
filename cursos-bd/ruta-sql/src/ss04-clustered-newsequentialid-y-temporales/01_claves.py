"""ss04 · §4 y §5.1. Los 1.327.622 protocolos de la caja en cinco tablas de SQL Server que solo difieren en la clave
primaria agrupada: int IDENTITY, uniqueidentifier con NEWID() y con NEWSEQUENTIALID() por defecto, y UUIDv4 y
UUIDv7 generados por la aplicación. Se insertan en el orden en que llegaron los protocolos, de a 5.000, como los
insertaría la aplicación, por la copia masiva de TDS. Es la medición de la Fase 10 (M-16), en este motor.

Imprime la estructura de cada tabla (qué clave tiene y cuántas filas): se publica. Con --private agrega, para ti, las
páginas y la fragmentación de cada índice agrupado (sys.dm_db_index_physical_stats), que no se publican (a09).

    uv run --extra sqlserver python ss04-clustered-newsequentialid-y-temporales/01_claves.py [--private]   (desde src/)
"""

import os
import sys
import time
import uuid
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from lab.engines import sqlserver  # noqa: E402

PRIVATE = "--private" in sys.argv
BATCH = 5000
TABLES = {
    "order_int":       ("order_id int IDENTITY(1,1) NOT NULL", "int"),
    "order_newid":     ("order_id uniqueidentifier NOT NULL DEFAULT NEWID()", "default"),
    "order_newseq":    ("order_id uniqueidentifier NOT NULL DEFAULT NEWSEQUENTIALID()", "default"),
    "order_uuid4_app": ("order_id uniqueidentifier NOT NULL", "uuid4"),
    "order_uuid7_app": ("order_id uniqueidentifier NOT NULL", "uuid7"),
}


def uuid7(ms: int) -> uuid.UUID:
    """UUIDv7 de la RFC 9562: 48 bits de milisegundos, la versión, la variante y azar (el de la Fase 10)."""
    raw = bytearray(ms.to_bytes(6, "big") + os.urandom(10))
    raw[6] = (raw[6] & 0x0F) | 0x70
    raw[8] = (raw[8] & 0x3F) | 0x80
    return uuid.UUID(bytes=bytes(raw))


def main() -> None:
    conn = sqlserver.connect("master")
    cur = conn.cursor()
    cur.execute("IF DB_ID('ss04') IS NULL CREATE DATABASE ss04")
    cur.execute("ALTER DATABASE ss04 SET RECOVERY SIMPLE")
    conn.close()
    src = sqlserver.connect("ALAMEDA").cursor()
    src.execute("SELECT IdProtocolo, IdPaciente, Fecha, Sede FROM dbo.Protocolos ORDER BY Fecha, IdProtocolo")
    rows = [tuple(r) for r in src.fetchall()]
    conn = sqlserver.connect("ss04")
    cur = conn.cursor()
    for name, (key, kind) in TABLES.items():
        cur.execute(f"DROP TABLE IF EXISTS dbo.{name}")
        cur.execute(f"CREATE TABLE dbo.{name} ({key}, legacy_order_id int NOT NULL, patient_id int NULL, "
                    f"ordered_on datetime NULL, site_code nvarchar(1) NULL, CONSTRAINT {name}_pk PRIMARY KEY CLUSTERED (order_id))")
        cur.execute(f"CREATE INDEX {name}_patient_id_idx ON dbo.{name} (patient_id)")
        started = time.time()
        for i in range(0, len(rows), BATCH):
            chunk = rows[i:i + BATCH]
            if kind in ("int", "default"):
                data = chunk
                cols = ["legacy_order_id", "patient_id", "ordered_on", "site_code"]
            else:
                data = []
                for n, (oid, pid, fecha, sede) in enumerate(chunk, start=i + 1):
                    ms = int(time.mktime(fecha.timetuple()) * 1000) + n % 86_400_000 if fecha else n
                    data.append((uuid.uuid4() if kind == "uuid4" else uuid7(ms), oid, pid, fecha, sede))
                cols = ["order_id", "legacy_order_id", "patient_id", "ordered_on", "site_code"]
            cur.bulkcopy(f"dbo.{name}", data, column_mappings=cols, timeout=0)
        elapsed = f" en {time.time() - started:.0f} s" if PRIVATE else ""
        cur.execute(f"SELECT COUNT(*) FROM dbo.{name}")
        print(f"{name:16} {key.split(' NOT NULL')[0][9:]:>34} · {cur.fetchone()[0]} filas{elapsed}")
    if PRIVATE:
        print("🔒 PRIVADO: páginas y fragmentación de cada índice. No lo publiques (apéndice a09).")
        cur.execute("SELECT OBJECT_NAME(s.object_id), i.name, s.page_count, CAST(s.avg_fragmentation_in_percent AS decimal(5,1)), "
                    "CAST(s.avg_page_space_used_in_percent AS decimal(5,1)) "
                    "FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') AS s "
                    "JOIN sys.indexes AS i ON i.object_id = s.object_id AND i.index_id = s.index_id "
                    "WHERE s.index_level = 0 ORDER BY 1, 2")
        for t, idx, pages, frag, used in cur.fetchall():
            print(f"  {t:16} {idx:28} páginas {pages:>7} · fragmentación {frag:>5} % · página llena {used:>5} %")
    conn.close()


if __name__ == "__main__":
    main()
