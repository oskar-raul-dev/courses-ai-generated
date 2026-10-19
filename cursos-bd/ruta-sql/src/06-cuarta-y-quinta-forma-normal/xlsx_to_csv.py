"""Una planilla de la caja a CSV por la salida estándar, con la biblioteca estándar y nada más.

Uso: python3 -I xlsx_to_csv.py lab/caja/m/planillas/convenios_2026.xlsx > convenios.csv

Lee la primera hoja tal como la escribe el generador (texto en línea y números, sin estilos). Una
planilla de Excel de verdad usa además una tabla de textos compartidos, y por eso también se lee.
"""

import csv
import re
import sys
import xml.etree.ElementTree as ET
import zipfile

NS = {"m": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}


def column_index(ref: str) -> int:
    letters = re.match(r"[A-Z]+", ref).group(0)
    n = 0
    for ch in letters:
        n = n * 26 + ord(ch) - 64
    return n - 1


def rows(path: str):
    with zipfile.ZipFile(path) as z:
        shared = []
        if "xl/sharedStrings.xml" in z.namelist():
            root = ET.fromstring(z.read("xl/sharedStrings.xml"))
            shared = ["".join(t.text or "" for t in si.iter(f"{{{NS['m']}}}t")) for si in root.findall("m:si", NS)]
        sheet = ET.fromstring(z.read("xl/worksheets/sheet1.xml"))
    for row in sheet.iter(f"{{{NS['m']}}}row"):
        values = {}
        for c in row.findall("m:c", NS):
            kind = c.get("t")
            if kind == "inlineStr":
                value = "".join(t.text or "" for t in c.iter(f"{{{NS['m']}}}t"))
            elif kind == "s":
                value = shared[int(c.find("m:v", NS).text)]
            else:
                v = c.find("m:v", NS)
                value = v.text if v is not None else ""
            values[column_index(c.get("r"))] = value
        yield [values.get(i, "") for i in range(max(values) + 1)] if values else []


if __name__ == "__main__":
    writer = csv.writer(sys.stdout, lineterminator="\n")
    for r in rows(sys.argv[1]):
        writer.writerow(r)
