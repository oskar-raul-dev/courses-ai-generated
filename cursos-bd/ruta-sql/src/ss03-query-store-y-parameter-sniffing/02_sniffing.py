"""ss03 · §4 y §5. La consulta por sede de la Fase 13 como procedimiento, en dos órdenes y dos niveles de
compatibilidad: 170 (SQL Server 2025, el de una base nueva) y 100 (2008 R2, el que conserva una base restaurada).

Para cada corrida se vacía la caché de planes de ss03, se ejecuta el procedimiento cinco veces con la primera sede
y una con la otra, y se muestra la **estructura** del plan que quedó en la caché para el procedimiento, y las
variantes que haya registrado Query Store. Es la parte que se publica de un plan de SQL Server (apéndice a09).
Con --private agrega, para ti, las lecturas lógicas de la última ejecución de cada sede.

    uv run --extra sqlserver python ss03-query-store-y-parameter-sniffing/02_sniffing.py [--private]   (desde src/)
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from lab.engines import sqlserver  # noqa: E402

PRIVATE = "--private" in sys.argv
DESDE = "2026-09-01"


def rows(cur, sql, params=()):
    cur.execute(sql, params)
    out = cur.fetchall() if cur.description else []
    while cur.nextset():
        pass
    return out


def cached_plan(cur) -> str | None:
    """El plan del procedimiento en la caché (estimado: sin estadísticas de ejecución)."""
    found = rows(cur, "SELECT qp.query_plan FROM sys.dm_exec_procedure_stats AS ps "
                      "CROSS APPLY sys.dm_exec_query_plan(ps.plan_handle) AS qp "
                      "WHERE ps.database_id = DB_ID() AND ps.object_id = OBJECT_ID('dbo.resultados_por_sede')")
    return found[0][0] if found else None


def variants(cur) -> list[tuple]:
    """Las variantes de Query Store (*Parameter Sensitive Plan*): una consulta despachadora y una por rango."""
    return rows(cur, "SELECT v.query_variant_query_id, v.parent_query_id, v.dispatcher_plan_id "
                     "FROM sys.query_store_query_variant AS v ORDER BY 1")


def reads(cur, sede: str) -> int:
    rows(cur, "SET STATISTICS XML ON")
    cur.execute("EXEC dbo.resultados_por_sede @sede = ?, @desde = ?", (sede, DESDE))
    xml = None
    while True:
        if cur.description:
            for r in cur.fetchall():
                if isinstance(r[0], str) and r[0].lstrip().startswith("<ShowPlanXML"):
                    xml = r[0]
        if not cur.nextset():
            break
    rows(cur, "SET STATISTICS XML OFF")
    import re
    return sum(int(x) for x in re.findall(r'ActualLogicalReads="(\d+)"', xml or ""))


def run(level: int, first: str, then: str) -> None:
    conn = sqlserver.connect("ss03")
    cur = conn.cursor()
    rows(cur, f"ALTER DATABASE ss03 SET COMPATIBILITY_LEVEL = {level}")
    rows(cur, "ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE")
    rows(cur, "ALTER DATABASE ss03 SET QUERY_STORE CLEAR")
    for _ in range(5):
        rows(cur, "EXEC dbo.resultados_por_sede @sede = ?, @desde = ?", (first, DESDE))
    rows(cur, "EXEC dbo.resultados_por_sede @sede = ?, @desde = ?", (then, DESDE))
    rows(cur, "EXEC sp_query_store_flush_db")
    print(f"== nivel {level} · cinco veces la sede {first}, después la {then}")
    plan = cached_plan(cur)
    print("plan del procedimiento en la caché:")
    print("\n".join("  " + line for line in sqlserver.plan_lines(plan)) if plan else "  (ninguno)")
    v = variants(cur)
    print(f"variantes en Query Store: {len(v)}" + ("" if not v else " (una despachadora y sus planes por rango)"))
    if PRIVATE:
        print(f"🔒 PRIVADO · lecturas lógicas: {first} {reads(cur, first)} · {then} {reads(cur, then)}")
    conn.close()


if __name__ == "__main__":
    for level in (170, 100):
        run(level, "C", "V")
        run(level, "V", "C")
    conn = sqlserver.connect("ss03")
    rows(conn.cursor(), "ALTER DATABASE ss03 SET COMPATIBILITY_LEVEL = 170")
    conn.close()
