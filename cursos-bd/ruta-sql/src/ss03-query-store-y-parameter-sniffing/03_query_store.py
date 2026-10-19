"""ss03 · §5.2 y §5.3. Query Store: los dos planes de la consulta por sede, uno forzado, y una pista sin tocar el código.

1. Se vacía la caché y Query Store, y se compila el procedimiento dos veces: primero para la sede V y, con la caché
   vaciada otra vez, para la C. Query Store guarda los dos planes de la misma consulta.
2. Se fuerza el plan que se compiló para V (sp_query_store_force_plan), se vacía la caché y se ejecuta para C: el
   plan que queda en la caché tiene que ser el forzado.
3. Se quita el forzado y se agrega una pista de Query Store (sp_query_store_set_hints) con OPTION (RECOMPILE).
4. Se deja todo como estaba: sin forzados, sin pistas, nivel 170.

Lo que imprime es estructura (operadores, objetos, qué plan está forzado): se publica. Con --private agrega, para ti,
las lecturas lógicas medias de cada plan según Query Store, que no se publican (apéndice a09).

    uv run --extra sqlserver python ss03-query-store-y-parameter-sniffing/03_query_store.py [--private]   (desde src/)
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from lab.engines import sqlserver  # noqa: E402

PRIVATE = "--private" in sys.argv
DESDE = "2026-09-01"
QUERY = ("SELECT q.query_id FROM sys.query_store_query AS q "
         "WHERE q.object_id = OBJECT_ID('dbo.resultados_por_sede')")


def rows(cur, sql, params=()):
    cur.execute(sql, params)
    out = [tuple(r) for r in cur.fetchall()] if cur.description else []
    while cur.nextset():
        pass
    return out


def run(cur, sede):
    rows(cur, "EXEC dbo.resultados_por_sede @sede = ?, @desde = ?", (sede, DESDE))


def shape(xml: str) -> str:
    """Una línea por plan: el método de join y el acceso a ResultadoItem, que es lo que cambia entre los dos."""
    lines = [l.strip() for l in sqlserver.plan_lines(xml)]
    join = "hash join" if "Hash Match (Inner Join)" in lines else "nested loops"
    access = next((l for l in lines if "ResultadoItem" in l), "?")
    return f"{join} · {access}"


def plans(cur) -> list[tuple]:
    return rows(cur, "SELECT p.plan_id, p.is_forced_plan, CAST(p.query_plan AS nvarchar(max)) FROM sys.query_store_plan AS p "
                     f"WHERE p.query_id IN ({QUERY}) ORDER BY p.plan_id")


def cached(cur) -> str:
    found = rows(cur, "SELECT qp.query_plan FROM sys.dm_exec_procedure_stats AS ps "
                      "CROSS APPLY sys.dm_exec_query_plan(ps.plan_handle) AS qp "
                      "WHERE ps.database_id = DB_ID() AND ps.object_id = OBJECT_ID('dbo.resultados_por_sede')")
    return shape(found[0][0]) if found else "(nada en la caché)"


def main() -> None:
    conn = sqlserver.connect("ss03")
    cur = conn.cursor()
    rows(cur, "ALTER DATABASE ss03 SET COMPATIBILITY_LEVEL = 170")
    rows(cur, "ALTER DATABASE ss03 SET QUERY_STORE CLEAR")
    rows(cur, "ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE")
    run(cur, "V")
    rows(cur, "ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE")
    run(cur, "C")
    rows(cur, "EXEC sp_query_store_flush_db")
    query_id = rows(cur, QUERY)[0][0]
    print(f"== 1. Query Store guardó la consulta {query_id} con estos planes:")
    found = plans(cur)
    for plan_id, forced, xml in found:
        print(f"  plan {plan_id}: {shape(xml)}{' · FORZADO' if forced else ''}")
    nested = next(p for p in found if shape(p[2]).startswith("nested"))[0]

    print(f"== 2. se fuerza el plan {nested} (el que se compiló para V) y se ejecuta para C con la caché vacía")
    rows(cur, "EXEC sp_query_store_force_plan @query_id = ?, @plan_id = ?", (query_id, nested))
    rows(cur, "ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE")
    run(cur, "C")
    print(f"  plan en la caché para C: {cached(cur)}")
    for plan_id, forced, _ in plans(cur):
        print(f"  plan {plan_id}: is_forced_plan = {int(bool(forced))}")
    if PRIVATE:
        rows(cur, "EXEC sp_query_store_flush_db")
        for plan_id, reads, n in rows(cur, "SELECT plan_id, AVG(avg_logical_io_reads), SUM(count_executions) "
                                         "FROM sys.query_store_runtime_stats WHERE plan_id IN (SELECT plan_id FROM "
                                         f"sys.query_store_plan WHERE query_id = {query_id}) GROUP BY plan_id"):
            print(f"  🔒 PRIVADO · plan {plan_id}: {n} ejecuciones, lecturas lógicas medias {reads:.0f}")

    print("== 3. sin forzar, con una pista de Query Store: OPTION (RECOMPILE), sin tocar el procedimiento")
    rows(cur, "EXEC sp_query_store_unforce_plan @query_id = ?, @plan_id = ?", (query_id, nested))
    rows(cur, "EXEC sp_query_store_set_hints @query_id = ?, @query_hints = N'OPTION (RECOMPILE)'", (query_id,))
    print("  pistas:", rows(cur, "SELECT query_id, query_hint_text, source_desc FROM sys.query_store_query_hints"))
    rows(cur, "ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE")
    run(cur, "C")
    run(cur, "V")
    print(f"  plan en la caché: {cached(cur)}")

    rows(cur, "EXEC sp_query_store_clear_hints @query_id = ?", (query_id,))
    rows(cur, "ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE")
    print("== 4. sin forzados ni pistas:", rows(cur, "SELECT COUNT(*) FROM sys.query_store_plan WHERE is_forced_plan = 1")[0][0],
          "forzados ·", rows(cur, "SELECT COUNT(*) FROM sys.query_store_query_hints")[0][0], "pistas")
    conn.close()


if __name__ == "__main__":
    main()
