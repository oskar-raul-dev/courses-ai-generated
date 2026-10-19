"""ss03 · los ejercicios 2, 4, 10, 11, 12, 17 y 🔥1, para el solucionario (salida privada salvo la estructura)."""
import re, sys
sys.path.insert(0, "/src")
from lab.engines import sqlserver

def rows(cur, sql, params=()):
    cur.execute(sql, params)
    out = [tuple(r) for r in cur.fetchall()] if cur.description else []
    while cur.nextset():
        if cur.description: out += [tuple(r) for r in cur.fetchall()]
    return out

def cached_xml(cur, proc="resultados_por_sede"):
    f = rows(cur, "SELECT qp.query_plan FROM sys.dm_exec_procedure_stats ps CROSS APPLY sys.dm_exec_query_plan(ps.plan_handle) qp "
                  f"WHERE ps.database_id = DB_ID() AND ps.object_id = OBJECT_ID('dbo.{proc}')")
    return f[0][0] if f else ""

def shape(xml):
    lines = [l.strip() for l in sqlserver.plan_lines(xml)] if xml else []
    return ("hash join" if "Hash Match (Inner Join)" in lines else "nested loops") + " · " + next((l for l in lines if "ResultadoItem" in l), "?")

c = sqlserver.connect("ss03"); cur = c.cursor()
print("ej2", rows(cur, "SELECT DB_NAME(), actual_state_desc, query_capture_mode_desc, max_storage_size_mb FROM sys.database_query_store_options"))
a = sqlserver.connect("ALAMEDA"); print("ej2 ALAMEDA", rows(a.cursor(), "SELECT DB_NAME(), actual_state_desc, query_capture_mode_desc, max_storage_size_mb FROM sys.database_query_store_options")); a.close()
rows(cur, "ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE")
rows(cur, "EXEC dbo.resultados_por_sede @sede = N'C', @desde = '2026-09-01'")
x = cached_xml(cur)
print("ej4", re.findall(r'<ColumnReference Column="(@\w+)" ParameterDataType="[^"]+" ParameterCompiledValue="([^"]+)"', x))
print("ej10 nivel 170 CE", re.findall(r'CardinalityEstimationModelVersion="(\d+)"', x))
rows(cur, "ALTER DATABASE ss03 SET COMPATIBILITY_LEVEL = 100"); rows(cur, "ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE")
rows(cur, "EXEC dbo.resultados_por_sede @sede = N'C', @desde = '2026-09-01'")
print("ej10 nivel 100 CE", re.findall(r'CardinalityEstimationModelVersion="(\d+)"', cached_xml(cur)), shape(cached_xml(cur)))
rows(cur, "ALTER DATABASE ss03 SET COMPATIBILITY_LEVEL = 170")
rows(cur, "ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = ON"); rows(cur, "ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE")
rows(cur, "EXEC dbo.resultados_por_sede @sede = N'C', @desde = '2026-09-01'")
print("ej11 170 + legacy CE", re.findall(r'CardinalityEstimationModelVersion="(\d+)"', cached_xml(cur)), shape(cached_xml(cur)))
rows(cur, "ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF")
# ej12: plan de V en la caché, UPDATE STATISTICS, el central
rows(cur, "ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE")
rows(cur, "EXEC dbo.resultados_por_sede @sede = N'V', @desde = '2026-09-01'")
before = shape(cached_xml(cur))
rows(cur, "UPDATE STATISTICS dbo.Protocolos WITH FULLSCAN")
rows(cur, "EXEC dbo.resultados_por_sede @sede = N'C', @desde = '2026-09-01'")
print("ej12 antes", before, "· después de UPDATE STATISTICS y C:", shape(cached_xml(cur)))
# 🔥1: OPPO
rows(cur, "CREATE OR ALTER PROCEDURE dbo.resultados_opcional @sede nchar(1) = NULL, @desde date AS "
          "SELECT r.CodDeterminacion, COUNT(*) AS resultados FROM dbo.Protocolos AS p JOIN dbo.ResultadoItem AS r ON r.IdProtocolo = p.IdProtocolo "
          "WHERE (p.Sede = @sede OR @sede IS NULL) AND p.Fecha >= @desde GROUP BY r.CodDeterminacion")
rows(cur, "ALTER DATABASE ss03 SET QUERY_STORE CLEAR"); rows(cur, "ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE")
rows(cur, "EXEC dbo.resultados_opcional @sede = N'V', @desde = '2026-09-01'")
rows(cur, "EXEC dbo.resultados_opcional @sede = NULL, @desde = '2026-09-01'")
rows(cur, "EXEC sp_query_store_flush_db")
print("🔥1 OPPO config", rows(cur, "SELECT name, value FROM sys.database_scoped_configurations WHERE name LIKE '%OPTIONAL%' OR name LIKE '%PARAMETER_SENS%'"))
print("🔥1 variantes", rows(cur, "SELECT COUNT(*) FROM sys.query_store_query_variant"),
      "planes", rows(cur, "SELECT plan_id, plan_type_desc FROM sys.query_store_plan"))
c.close()
