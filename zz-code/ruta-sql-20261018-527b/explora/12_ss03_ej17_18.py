import sys; sys.path.insert(0, "/src")
from lab.engines import sqlserver
def rows(cur, sql, params=()):
    cur.execute(sql, params); out = [tuple(r) for r in cur.fetchall()] if cur.description else []
    while cur.nextset():
        if cur.description: out += [tuple(r) for r in cur.fetchall()]
    return out
c = sqlserver.connect("ss03"); cur = c.cursor()
# ej17: cien mil protocolos más del central, con IdProtocolo nuevo, y estadísticas
rows(cur, "INSERT INTO dbo.Protocolos (IdProtocolo, Sede, Fecha) SELECT TOP (100000) 2000000000 + ROW_NUMBER() OVER (ORDER BY IdProtocolo), N'C', Fecha FROM dbo.Protocolos WHERE Sede = N'C' ORDER BY IdProtocolo")
rows(cur, "INSERT INTO dbo.Protocolos (IdProtocolo, Sede, Fecha) SELECT TOP (100000) 2100000000 + ROW_NUMBER() OVER (ORDER BY IdProtocolo), N'C', Fecha FROM dbo.Protocolos WHERE Sede = N'C' ORDER BY IdProtocolo")
rows(cur, "UPDATE STATISTICS dbo.Protocolos WITH FULLSCAN")
print("ej17 sedes", rows(cur, "SELECT Sede, COUNT(*) FROM dbo.Protocolos GROUP BY Sede ORDER BY Sede"))
rows(cur, "ALTER DATABASE ss03 SET QUERY_STORE CLEAR"); rows(cur, "ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE")
for s in ("C", "V", "C", "V"):
    rows(cur, "EXEC dbo.resultados_por_sede @sede = ?, @desde = '2026-09-01'", (s,))
rows(cur, "EXEC sp_query_store_flush_db")
print("ej17 variantes", rows(cur, "SELECT COUNT(*) FROM sys.query_store_query_variant"), rows(cur, "SELECT plan_id, plan_type_desc FROM sys.query_store_plan"))
rows(cur, "DELETE FROM dbo.Protocolos WHERE IdProtocolo >= 2000000000"); rows(cur, "UPDATE STATISTICS dbo.Protocolos WITH FULLSCAN")
# ej18: el ajuste automático
rows(cur, "ALTER DATABASE ss03 SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON)")
print("ej18 opciones", rows(cur, "SELECT name, desired_state_desc, actual_state_desc, reason_desc FROM sys.database_automatic_tuning_options"))
rows(cur, "ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE")
for _ in range(20): rows(cur, "EXEC dbo.resultados_por_sede @sede = N'C', @desde = '2026-09-01'")
rows(cur, "ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE")
rows(cur, "EXEC dbo.resultados_por_sede @sede = N'V', @desde = '2026-09-01'")
for _ in range(20): rows(cur, "EXEC dbo.resultados_por_sede @sede = N'C', @desde = '2026-09-01'")
print("ej18 recomendaciones", rows(cur, "SELECT COUNT(*) FROM sys.dm_db_tuning_recommendations"))
rows(cur, "ALTER DATABASE ss03 SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = OFF)")
rows(cur, "ALTER DATABASE ss03 SET QUERY_STORE CLEAR"); rows(cur, "ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE")
print("estado final", rows(cur, "SELECT COUNT(*) FROM dbo.Protocolos"), rows(cur, "SELECT compatibility_level FROM sys.databases WHERE name='ss03'"))
