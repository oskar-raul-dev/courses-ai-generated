"""Faithful Python port of Rubén's ModParser.bas (1998), plus the check he never had.

Usage:
    python3 parse_patients.py out/pacientes.csv out/pacientes_parseado.csv

The port reproduces the VBA behaviour on purpose, flaws included: the two-digit year
window, passports taken as DNI, the mother's DNI on newborns. The report at the end
flags what a modern constraint would have rejected.
"""

import csv
import re
import sys
from datetime import date

FIELDS = ["nombre", "dni", "fecha_nac", "direccion"]
DATE_RE = re.compile(r"^(\d{1,2})/(\d{1,2})/(\d{2}|\d{4})$")


def is_number(token: str) -> bool:
    """VBA EsNumero: only digits and dots."""
    return bool(token) and all(c.isdigit() or c == "." for c in token)


def to_date(token: str) -> date | None:
    """VBA EsFecha + CDate: d/m/yy or d/m/yyyy, with Windows' 1930-2029 two-digit window."""
    m = DATE_RE.match(token)
    if not m:
        return None
    d, mo, y = int(m[1]), int(m[2]), m[3]
    year = int(y) if len(y) == 4 else (2000 + int(y) if int(y) < 30 else 1900 + int(y))
    try:
        return date(year, mo, d)
    except ValueError:
        return None


def parse_name(raw: str) -> dict:
    """VBA ParsearNombre, line by line."""
    out = {"nombre": "", "dni": "", "fecha_nac": "", "direccion": ""}
    name_parts, addr_parts = [], []
    in_name = True
    tokens = raw.strip().split(" ")
    i = 0
    while i < len(tokens):
        t = tokens[i]
        if t == "":
            pass  # double space
        elif t == "DNI" and not out["dni"] and i < len(tokens) - 1:
            i += 1
            out["dni"] = tokens[i].replace(".", "")
            in_name = False
        elif "/" in t and to_date(t) and not out["fecha_nac"]:
            out["fecha_nac"] = to_date(t).strftime("%d/%m/%Y")
            in_name = False
        elif is_number(t) and not out["dni"] and len(t.replace(".", "")) >= 7:
            out["dni"] = t.replace(".", "")
            in_name = False
        elif in_name and not t[0].isdigit():
            name_parts.append(t)
        else:
            in_name = False
            addr_parts.append(t)
        i += 1
    out["nombre"] = " ".join(name_parts)
    out["direccion"] = " ".join(addr_parts)
    return out


def parse_patients(rows: list[dict]) -> int:
    """VBA ParsearPacientes: only rows without DNI; never overwrite fecha_nac or direccion."""
    count = 0
    for row in rows:
        if row["dni"]:
            continue
        p = parse_name(row["nombre"])
        if p["dni"]:
            row["nombre"] = p["nombre"]
            row["dni"] = p["dni"]
            if not row["fecha_nac"] and p["fecha_nac"]:
                row["fecha_nac"] = p["fecha_nac"]
            if not row["direccion"] and p["direccion"]:
                row["direccion"] = p["direccion"]
            count += 1
    return count


def suspicious(row: dict, today: date) -> list[str]:
    """What a CHECK constraint or a data-quality rule would have caught."""
    reasons = []
    if not re.fullmatch(r"\d{7,8}", row["dni"]):
        reasons.append(f"dni no es un DNI: {row['dni']!r}")
    birth = to_date(row["fecha_nac"]) if row["fecha_nac"] else None
    if birth and birth > today:
        reasons.append(f"nació en el futuro: {row['fecha_nac']}")
    elif birth and birth.year >= 2000 and row["dni"].isdigit() and int(row["dni"]) < 20_000_000:
        # Low DNI numbers belong to people born decades ago: the 1930-2029 window strikes again.
        reasons.append(f"DNI {row['dni']} no cuadra con nacer en {birth.year}")
    if re.search(r"\d|\bPASAP\b|\bTEL\b", row["nombre"]):
        reasons.append(f"nombre con datos adentro: {row['nombre']!r}")
    if row["nombre"].startswith("RN "):
        reasons.append("recién nacido con el DNI de la madre")
    if re.search(r"\bTEL\b", row["direccion"]):
        reasons.append(f"teléfono en la dirección: {row['direccion']!r}")
    return reasons


def main(src: str, dst: str) -> None:
    with open(src, newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))

    parsed = parse_patients(rows)

    with open(dst, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["id", *FIELDS], quoting=csv.QUOTE_NONNUMERIC)
        w.writeheader()
        w.writerows(rows)

    today = date.today()
    flagged = [(r, suspicious(r, today)) for r in rows]
    flagged = [(r, why) for r, why in flagged if why]

    print(f"{len(rows)} pacientes, {parsed} separados por el parser, {len(flagged)} sospechosos\n")
    for r, why in flagged:
        print(f"  id {r['id']:>3}  " + "; ".join(why))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])
