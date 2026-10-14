"""Proporciones de la caja generada contra la historia (§4) y contra D30, leyendo los CSV y truth/.

Uso: python3 -I proporciones.py salidas/caja/s
"""
import csv
import sys
from collections import Counter

root = sys.argv[1]


def rows(rel, enc="utf-8"):
    with open(f"{root}/{rel}", newline="", encoding=enc) as fh:
        yield from csv.DictReader(fh)


patients = list(rows("tablas/Pacientes.csv", "latin-1"))
truth = {r["legacy_patient_id"]: r for r in rows("truth/patient_record.csv")}
n = len(patients)
persons = Counter(t["person_id"] for t in truth.values())
repeats = sum(c - 1 for c in persons.values())
dirt = Counter(d for t in truth.values() for d in t["dirt"].strip("{}").split(",") if d)
future = sum(1 for p in patients if p["FechaNac"] and p["FechaNac"][:10] > "2026-10-10")
empty_dni = sum(1 for p in patients if not p["DNI"])
dni_counts = Counter(p["DNI"].replace(".", "") for p in patients if p["DNI"])
shared = sum(c for c in dni_counts.values() if c > 1)
print(f"filas de Pacientes: {n} · personas: {len(persons)}")
print(f"filas que repiten a una persona: {repeats} ({repeats / n:.1%})  [historia: 15–20 %]")
print(f"nacidos en el futuro: {future} ({future / n:.2%})  [historia: 4.000 de 1,9 M = 0,21 %]")
print(f"documento dentro de Nombre: {dirt['dni_in_name']} ({dirt['dni_in_name'] / n:.1%})  [D30: 10,9 %]")
print(f"DNI vacío: {empty_dni / n:.1%} · DNI compartido por más de una fila: {shared / n:.1%}")
print("suciedad por tipo:", dict(dirt.most_common()))
states = Counter(r["state"] for r in rows("truth/result_value.csv"))
total = sum(states.values())
print("resultados:", {k: f"{v / total:.1%}" for k, v in states.most_common()},
      "[D30: coma 45 · punto 45 · < 3 · > 2 · HEMOLIZADA 2 · vacío 3]")
