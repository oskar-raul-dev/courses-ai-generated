"""ExtraerDNI en VBA (el port de Python del generador, versión 2026) contra fn_ExtraerDNI en T-SQL
(el port a PL/pgSQL de la Fase 04, versión 2016), fila por fila, y lo mismo para la fecha."""
import collections

import psycopg

from lab import config
from lab.generator.rubens_parser import extract_dni, parse_name

with psycopg.connect(**config.POSTGRES) as conn:
    rows = conn.execute("""
        SELECT "Nombre", staging.extract_dni_2016("Nombre"), staging.extract_birth_date_2016("Nombre")
        FROM legacy."Pacientes" WHERE "Nombre" IS NOT NULL""").fetchall()

dni_diff = collections.Counter()
date_diff = []
for name, dni_2016, date_2016 in rows:
    if extract_dni(name) != dni_2016:
        dni_diff["OTRO" if " OTRO " in f" {name} " else "otra causa"] += 1
    vba = parse_name(name)["fecha"]
    tsql = date_2016.strftime("%d/%m/%Y") if date_2016 else ""
    if vba != tsql:
        date_diff.append((name, vba, tsql))
print(f"nombres: {len(rows)}")
print(f"DNI distinto entre 2026 y 2016: {sum(dni_diff.values())} {dict(dni_diff)}")
print(f"fecha distinta entre 2026 y 2016: {len(date_diff)}")
for name, vba, tsql in date_diff[:3]:
    print(f"  {name!r}: VBA {vba} · T-SQL {tsql}")
