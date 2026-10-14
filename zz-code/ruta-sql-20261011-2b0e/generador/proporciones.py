#!/usr/bin/env python3
"""Measures the dirt proportions of a generated box against the story. Usage: proporciones.py DIR"""
import collections, csv, os, re, sys
d = sys.argv[1]
with open(os.path.join(d, "truth", "patient_person.csv"), encoding="utf-8") as f:
    truth = list(csv.DictReader(f))
with open(os.path.join(d, "Pacientes.csv"), encoding="latin-1") as f:
    pats = list(csv.DictReader(f))
with open(os.path.join(d, "truth", "result_value.csv"), encoding="utf-8") as f:
    states = collections.Counter(r["state"] for r in csv.DictReader(f))
n = len(pats)
persons = collections.Counter(r["person_id"] for r in truth)
same_dni = collections.Counter(p["DNI"] for p in pats if p["DNI"])
print(f"patients={n} persons={len(persons)}")
print(f"rows that repeat a person: {sum(c-1 for c in persons.values())/n:.1%} (story: 15-20 %)")
print(f"dirt kinds: {dict(collections.Counter(r['dirt_kind'] for r in truth))}")
print(f"born in future: {sum(int(r['born_in_future']) for r in truth)/n:.3%} (story: 4.000/1,9 M = 0,211 %)")
print(f"DNI inside Nombre: {sum(bool(re.search(r'DNI \d', p['Nombre'])) for p in pats)/n:.1%}")
print(f"empty DNI: {sum(not p['DNI'] for p in pats)/n:.1%} · DNI shared by >1 row: {sum(c for c in same_dni.values() if c>1)/n:.1%}")
total = sum(states.values())
print("result states: " + ", ".join(f"{k}={v/total:.1%}" for k, v in states.most_common()))
