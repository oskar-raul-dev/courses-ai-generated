"""El arnés no se cree a sí mismo: las filas de cada tabla de legacy contra las del CSV de la caja."""
import csv
import sys
from pathlib import Path

import psycopg
from psycopg import sql

from lab import config
from lab.generator import schema

caja = Path(sys.argv[1]) / "tablas"
distintas = 0
with psycopg.connect(**config.POSTGRES) as conn:
    for t in schema.TABLES.values():
        encoding = "latin-1" if t.encoding == "latin-1" else "utf-8"
        with open(caja / f"{t.name}.csv", encoding=encoding, newline="") as fh:
            en_csv = sum(1 for _ in csv.reader(fh)) - 1          # menos el encabezado
        en_base = conn.execute(sql.SQL("SELECT count(*) FROM {}").format(
            sql.Identifier("legacy", t.name))).fetchone()[0]
        if en_csv != en_base:
            distintas += 1
            print(f"{t.name}: CSV {en_csv} · base {en_base}")
print(f"{len(schema.TABLES)} tablas comparadas, {distintas} distintas")
