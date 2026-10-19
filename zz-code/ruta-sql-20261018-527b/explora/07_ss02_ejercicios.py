"""ss02 · ejercicios 3, 12, 13 y 21, corridos para escribir el solucionario (salida privada)."""
import sys
sys.path.insert(0, "/src")
from lab.engines import sqlserver

def q(c, sql, params=()):
    cur = c.cursor(); cur.execute(sql, params)
    out = []
    while True:
        if cur.description: out.append([tuple(r) for r in cur.fetchall()])
        if not cur.nextset(): break
    return out

adm = sqlserver.connect("ss02")
q(adm, "ALTER DATABASE ss02 SET READ_COMMITTED_SNAPSHOT OFF WITH ROLLBACK IMMEDIATE")
a = sqlserver.connect("ss02"); b = sqlserver.connect("ss02"); w = sqlserver.connect("ss02")
# ej 3: a corrige y no confirma; el culpable, desde otra sesión
spid_a = q(a, "SELECT @@SPID")[0][0][0]
q(a, "BEGIN TRAN; UPDATE dbo.hemogram SET hematocrit = N'40' WHERE hemogram_id = 1;")
print("ej3", q(w, "SELECT s.session_id, s.status, ib.event_info FROM sys.dm_exec_sessions AS s "
                 "CROSS APPLY sys.dm_exec_input_buffer(s.session_id, NULL) AS ib WHERE s.session_id = ?", (spid_a,)))
q(a, "ROLLBACK")
# ej 12: serializable, a lee y b lee; los bloqueos de rango
q(adm, "TRUNCATE TABLE dbo.specimen_take")
for c in (a, b):
    q(c, "SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; BEGIN TRAN; SELECT TOP (1) specimen_id FROM dbo.specimen AS s "
         "WHERE NOT EXISTS (SELECT 1 FROM dbo.specimen_take AS t WHERE t.specimen_id = s.specimen_id) ORDER BY collected_at, specimen_id;")
print("ej12", q(w, "SELECT request_session_id, resource_type, request_mode, request_status, COUNT(*) FROM sys.dm_tran_locks "
                  "WHERE resource_database_id = DB_ID('ss02') AND request_session_id <> @@SPID AND resource_type IN ('KEY','OBJECT','PAGE') "
                  "GROUP BY request_session_id, resource_type, request_mode, request_status ORDER BY 1, 2, 3"))
for c in (a, b): q(c, "ROLLBACK; SET TRANSACTION ISOLATION LEVEL READ COMMITTED;")
# ej 13: UNIQUE
q(adm, "ALTER TABLE dbo.specimen_take ADD CONSTRAINT specimen_take_once UNIQUE (specimen_id)")
q(a, "INSERT INTO dbo.specimen_take (specimen_id, technician) VALUES (11231555, N'tecnico_a')")
try:
    q(b, "INSERT INTO dbo.specimen_take (specimen_id, technician) VALUES (11231555, N'tecnico_b')")
except Exception as e:
    print("ej13", str(e).split("[SQL Server]")[-1])
q(adm, "TRUNCATE TABLE dbo.specimen_take; ALTER TABLE dbo.specimen_take DROP CONSTRAINT specimen_take_once")
# ej 21: XACT_ABORT, sentencia por sentencia como una aplicación
for mode in ("OFF", "ON"):
    q(adm, "UPDATE dbo.debtor SET balance = 28.00 WHERE debtor_id IN (1, 2)")
    log = []
    for sql in (f"SET XACT_ABORT {mode}", "BEGIN TRAN", "UPDATE dbo.debtor SET balance = 10 WHERE debtor_id = 1",
                "UPDATE dbo.debtor SET balance = 1/0 WHERE debtor_id = 2", "UPDATE dbo.debtor SET balance = 30 WHERE debtor_id = 2",
                "IF @@TRANCOUNT > 0 COMMIT"):
        try:
            q(a, sql); log.append("ok")
        except Exception as e:
            log.append(str(e).split("[SQL Server]")[-1][:80])
        log.append(f"tc={q(a, 'SELECT @@TRANCOUNT')[0][0][0]}")
    print("ej21", mode, log, q(w, "SELECT debtor_id, balance FROM dbo.debtor WHERE debtor_id IN (1,2) ORDER BY 1"))
q(a, "SET XACT_ABORT OFF")
q(adm, "UPDATE dbo.debtor SET balance = 28.00 WHERE debtor_id = 1")
