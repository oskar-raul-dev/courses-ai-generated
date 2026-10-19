"""Port fiel de `ParsearNombre` y `ExtraerOS` del `vba/ModParser.bas` de la caja (versión de 2026).

Reproduce el comportamiento del VBA a propósito, defectos incluidos: la ventana de años de Windows
(del 00 al 29 es 20xx), el pasaporte guardado como DNI y el DNI de la madre en el recién nacido.
`a05` lo usa para medir cuánto acierta el parser contra la verdad del generador.
"""

import re
from datetime import date

DATE_RE = re.compile(r"^(\d{1,2})/(\d{1,2})/(\d{2}|\d{4})$")
KNOWN_PAYERS = ["OSDE", "PAMI", "APROSS", "IPAM", "SANCOR", "SWISS", "GALENO", "OSECAC", "UOM", "OSPRERA",
                "DASPU", "PARTICULAR"]


def is_number(token: str) -> bool:
    """VBA EsNumero: solo dígitos y puntos."""
    return bool(token) and all(c.isdigit() or c == "." for c in token)


def to_date(token: str) -> date | None:
    """VBA EsFecha + CDate: d/m/aa o d/m/aaaa, con la ventana de Windows 1930–2029."""
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
    """VBA ParsearNombre, línea por línea."""
    out = {"nombre": "", "dni": "", "fecha": "", "direccion": ""}
    name, address = [], []
    in_name = True
    tokens = raw.strip().split(" ")
    i = 0
    while i < len(tokens):
        t = tokens[i]
        u = t.upper()
        last = len(tokens) - 1
        if t == "":
            pass
        elif u in ("DNI", "LE", "LC") and not out["dni"] and i < last:
            i += 1
            out["dni"] = tokens[i].replace(".", "")
            in_name = False
        elif u in ("P", "PASAP") and not out["dni"] and i + 1 < last:
            name.append(f"({tokens[i + 1]})")
            out["dni"] = tokens[i + 2]
            i += 2
            in_name = False
        elif u == "OTRO" and not out["dni"] and i < last:
            i += 1
            out["dni"] = "OTRO " + tokens[i]
            in_name = False
        elif u == "RN" and i == 0:
            name = ["RN"]
        elif "/" in t and to_date(t) and not out["fecha"]:
            out["fecha"] = to_date(t).strftime("%d/%m/%Y")
            in_name = False
        elif is_number(t) and not out["dni"] and len(t.replace(".", "")) >= 7:
            out["dni"] = t.replace(".", "")
            in_name = False
        elif in_name and not t[0].isdigit():
            name.append(t)
        else:
            in_name = False
            address.append(t)
        i += 1
    out["nombre"] = " ".join(name)
    out["direccion"] = " ".join(address)
    return out


def extract_dni(raw: str) -> str:
    return parse_name(raw)["dni"]


def extract_payer(raw: str) -> str:
    """VBA ExtraerOS: la primera sigla conocida que aparece como palabra, sin puntos."""
    text = " " + raw.replace(".", "").upper() + " "
    for code in KNOWN_PAYERS:
        if f" {code} " in text:
            return code
    return ""
