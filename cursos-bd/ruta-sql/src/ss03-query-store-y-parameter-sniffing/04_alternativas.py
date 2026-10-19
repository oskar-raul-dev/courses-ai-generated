"""ss03 · §5.4. Las salidas que se escriben en el código: OPTIMIZE FOR un valor, OPTIMIZE FOR UNKNOWN y RECOMPILE.

Crea tres variantes del procedimiento y muestra, para cada una y para cada sede, la **estructura** del plan que
compila (el plan estimado de SHOWPLAN_XML: la consulta no se ejecuta). Se publica: son operadores y objetos.

    uv run --extra sqlserver python ss03-query-store-y-parameter-sniffing/04_alternativas.py      (desde src/)
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from lab.engines import sqlserver  # noqa: E402

BODY = ("SELECT r.CodDeterminacion, COUNT(*) AS resultados "
        "FROM dbo.Protocolos AS p JOIN dbo.ResultadoItem AS r ON r.IdProtocolo = p.IdProtocolo "
        "WHERE p.Sede = @sede AND p.Fecha >= @desde GROUP BY r.CodDeterminacion")
VARIANTS = {
    "resultados_por_sede": "",
    "resultados_optimize_for_c": " OPTION (OPTIMIZE FOR (@sede = N'C'))",
    "resultados_optimize_for_unknown": " OPTION (OPTIMIZE FOR UNKNOWN)",
    "resultados_recompile": " OPTION (RECOMPILE)",
}


def estimated(cur, proc: str, sede: str) -> list[str]:
    cur.execute("SET SHOWPLAN_XML ON")
    cur.execute(f"EXEC dbo.{proc} @sede = N'{sede}', @desde = '2026-09-01'")
    xml = None
    while True:
        if cur.description:
            for r in cur.fetchall():
                if isinstance(r[0], str) and "<ShowPlanXML" in r[0] and "Protocolos" in r[0]:
                    xml = r[0]
        if not cur.nextset():
            break
    cur.execute("SET SHOWPLAN_XML OFF")
    return sqlserver.plan_lines(xml) if xml else ["(sin plan)"]


def main() -> None:
    conn = sqlserver.connect("ss03")
    cur = conn.cursor()
    for name, option in VARIANTS.items():
        if option:
            cur.execute(f"CREATE OR ALTER PROCEDURE dbo.{name} @sede nchar(1), @desde date AS {BODY}{option}")
    cur.execute("ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE")
    for name in VARIANTS:
        for sede in ("C", "V"):
            lines = [l.strip() for l in estimated(cur, name, sede)]
            join = "hash join" if "Hash Match (Inner Join)" in lines else "nested loops"
            access = next((l for l in lines if "ResultadoItem" in l), "?")
            print(f"{name:34} sede {sede}: {join:12} · {access}")
    conn.close()


if __name__ == "__main__":
    main()
