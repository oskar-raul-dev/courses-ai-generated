"""ss04 ej14 · un UUID con los 48 bits del tiempo en los bytes 10–15, los que SQL Server compara primero."""
import os, sys, time, uuid
sys.path.insert(0, "/src")
from lab.engines import sqlserver

def uuid_sqlserver_ordenado(ms: int) -> uuid.UUID:
    """Azar en los bytes 0–9 (con versión y variante donde las pide la RFC) y el tiempo en los bytes 10–15."""
    raw = bytearray(os.urandom(10) + ms.to_bytes(6, "big"))
    raw[6] = (raw[6] & 0x0F) | 0x80       # versión 8: "a medida", que es lo que es
    raw[8] = (raw[8] & 0x3F) | 0x80       # variante RFC
    return uuid.UUID(bytes=bytes(raw))

src = sqlserver.connect("ALAMEDA").cursor()
src.execute("SELECT IdProtocolo, IdPaciente, Fecha, Sede FROM dbo.Protocolos ORDER BY Fecha, IdProtocolo")
rows = [tuple(r) for r in src.fetchall()]
conn = sqlserver.connect("ss04"); cur = conn.cursor()
cur.execute("DROP TABLE IF EXISTS dbo.order_uuid8_sql")
cur.execute("CREATE TABLE dbo.order_uuid8_sql (order_id uniqueidentifier NOT NULL, legacy_order_id int NOT NULL, patient_id int NULL, "
            "ordered_on datetime NULL, site_code nvarchar(1) NULL, CONSTRAINT order_uuid8_sql_pk PRIMARY KEY CLUSTERED (order_id))")
for i in range(0, len(rows), 5000):
    data = []
    for n, (oid, pid, fecha, sede) in enumerate(rows[i:i + 5000], start=i + 1):
        ms = int(time.mktime(fecha.timetuple()) * 1000) + n % 86_400_000 if fecha else n
        data.append((uuid_sqlserver_ordenado(ms), oid, pid, fecha, sede))
    cur.bulkcopy("dbo.order_uuid8_sql", data, column_mappings=["order_id", "legacy_order_id", "patient_id", "ordered_on", "site_code"], timeout=0)
cur.execute("SELECT i.name, s.page_count, CAST(s.avg_fragmentation_in_percent AS decimal(5,1)), CAST(s.avg_page_space_used_in_percent AS decimal(5,1)) "
            "FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') s JOIN sys.indexes i ON i.object_id = s.object_id AND i.index_id = s.index_id "
            "WHERE s.index_level = 0 AND OBJECT_NAME(s.object_id) IN ('order_uuid8_sql', 'order_newseq') AND i.type = 1")
print("🔒 PRIVADO", [tuple(r) for r in cur.fetchall()])
