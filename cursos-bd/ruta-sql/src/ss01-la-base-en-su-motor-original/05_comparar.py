"""ss01 · §7. La apuesta: el T-SQL de Matías, corrido en su motor, da lo mismo que su port de la Fase 04.

Para cada paciente, tres lecturas del nombre:
  · la de 2016 en SQL Server: dbo.fn_ExtraerDNI y dbo.fn_ExtraerFecha, tal cual (04_parser_2016.sh);
  · la de 2016 portada a Postgres en la Fase 04: staging.extract_dni_2016 y staging.extract_birth_date_2016;
  · la de 2026, el VBA de ModParser portado a Python (lab/generator/rubens_parser.py).

Postgres contra Python es la tabla de la Fase 04, y se publica. SQL Server contra cualquiera de las dos es
un resultado de SQL Server, y la salida lo marca: lo ves tú, en tu máquina, y no se publica (apéndice a09).

    uv run --extra sqlserver python ss01-la-base-en-su-motor-original/05_comparar.py      (desde src/)
"""

import datetime as dt
import sys
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from lab.engines import postgres, sqlserver  # noqa: E402
from lab.generator import rubens_parser  # noqa: E402


def main() -> None:
    with postgres.connect() as pg:
        port = {r[0]: (r[1] or "", r[2]) for r in pg.execute(
            'SELECT "IdPaciente", staging.extract_dni_2016("Nombre"), staging.extract_birth_date_2016("Nombre") '
            'FROM legacy."Pacientes"')}
        names = dict(pg.execute('SELECT "IdPaciente", "Nombre" FROM legacy."Pacientes"').fetchall())
    ms = sqlserver.connect()
    cur = ms.cursor()
    cur.execute("SELECT IdPaciente, dbo.fn_ExtraerDNI(Nombre), dbo.fn_ExtraerFecha(Nombre) FROM dbo.Pacientes")
    native = {r[0]: (r[1] or "", r[2]) for r in cur.fetchall()}
    ms.close()

    vba = {}
    for pid, name in names.items():
        parsed = rubens_parser.parse_name(name or "")
        fecha = dt.datetime.strptime(parsed["fecha"], "%d/%m/%Y").date() if parsed["fecha"] else None
        vba[pid] = (parsed["dni"], fecha)

    print(f"pacientes: Postgres {len(port)} · SQL Server {len(native)}")
    print("── publicable: el port de 2016 en Postgres contra la versión de 2026 (la Fase 04)")
    _diff("port 2016 (Postgres) contra 2026 (Python)", port, vba, names)
    print("── 🔒 PRIVADO: SQL Server. No lo publiques (apéndice a09)")
    _diff("2016 en SQL Server contra su port en Postgres", native, port, names)
    _diff("2016 en SQL Server contra 2026 (Python)", native, vba, names)


def _diff(title: str, a: dict, b: dict, names: dict) -> None:
    dni = [k for k in a if k in b and a[k][0] != b[k][0]]
    date = [k for k in a if k in b and a[k][1] != b[k][1]]
    kinds = Counter((b[k][0] or "").split(" ")[0] or "(vacío)" for k in dni)
    print(f"{title}: DNI distinto {len(dni)} {dict(kinds)} · fecha distinta {len(date)}")
    for k in date[:3]:
        print(f"    {names[k]!r}: {a[k][1]} · {b[k][1]}")


if __name__ == "__main__":
    main()
