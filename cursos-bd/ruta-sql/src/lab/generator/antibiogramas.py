"""Los antibiogramas del laboratorio de microbiología, como verdad estructurada (D46).

En la caja, el antibiograma es una columna de texto libre de `Urocultivo` (62 filas en M): así lo
guardó el sistema de 2011, y eso no se toca. Esta tabla es el mismo dato como lo tendría alguien
que lo modela desde cero: una fila por germen, antibiótico y sensibilidad, con S (sensible), I
(intermedio) o R (resistente). Va a `truth/antibiogram.csv` con su propio flujo aleatorio, así
que agregarla no cambia ni un byte de los archivos que ya estaban.

Las proporciones de resistencia son aproximadas y de uso común en los antibiogramas de
laboratorios generales (no son datos de ningún laboratorio real); el panel de cada germen es fijo.
"""

import datetime as dt

from .tables import Box

CULTURES_SHARE = 0.30       # cultivos por persona distinta: 60.000 en M
FIRST_DAY = dt.date(2002, 1, 1)
LAST_DAY = dt.date(2025, 12, 31)
INTERMEDIATE_SHARE = 0.05   # de lo que no sale R, una fracción sale I

# germen · peso de aparición · antibiótico → probabilidad de resistencia (R)
GERMS = [
    ("Escherichia coli", 0.55, {
        "AMPICILINA": 0.52, "AMOXICILINA-CLAVULANICO": 0.14, "CEFALOTINA": 0.18, "CEFTRIAXONA": 0.07,
        "CIPROFLOXACINA": 0.21, "GENTAMICINA": 0.06, "NITROFURANTOINA": 0.03,
        "TRIMETOPRIMA-SULFAMETOXAZOL": 0.31, "FOSFOMICINA": 0.02}),
    ("Klebsiella pneumoniae", 0.12, {
        "AMPICILINA": 0.98, "AMOXICILINA-CLAVULANICO": 0.22, "CEFALOTINA": 0.30, "CEFTRIAXONA": 0.19,
        "CIPROFLOXACINA": 0.17, "GENTAMICINA": 0.09, "TRIMETOPRIMA-SULFAMETOXAZOL": 0.26}),
    ("Proteus mirabilis", 0.06, {
        "AMPICILINA": 0.25, "CEFTRIAXONA": 0.05, "CIPROFLOXACINA": 0.10, "GENTAMICINA": 0.04,
        "NITROFURANTOINA": 0.97, "TRIMETOPRIMA-SULFAMETOXAZOL": 0.20}),
    ("Pseudomonas aeruginosa", 0.08, {
        "CIPROFLOXACINA": 0.28, "CEFTAZIDIMA": 0.22, "PIPERACILINA-TAZOBACTAM": 0.19,
        "GENTAMICINA": 0.24, "MEROPENEM": 0.12, "AMICACINA": 0.09}),
    ("Staphylococcus aureus", 0.10, {
        "OXACILINA": 0.34, "CLINDAMICINA": 0.21, "ERITROMICINA": 0.30, "GENTAMICINA": 0.08,
        "CIPROFLOXACINA": 0.24, "VANCOMICINA": 0.01, "TRIMETOPRIMA-SULFAMETOXAZOL": 0.06}),
    ("Enterococcus faecalis", 0.07, {
        "AMPICILINA": 0.04, "VANCOMICINA": 0.02, "NITROFURANTOINA": 0.03, "GENTAMICINA": 0.25,
        "CIPROFLOXACINA": 0.40}),
]


def write_antibiograms(box: Box, w: dict) -> None:
    rng = box.rng("antibiogramas")
    people = w["people"]
    cultures = round(len(people) * CULTURES_SHARE)
    span = (LAST_DAY - FIRST_DAY).days
    weights = [g[1] for g in GERMS]
    header = ["culture_id", "person_id", "culture_date", "germ", "antibiotic", "sensitivity"]
    with box.csv("truth/antibiogram.csv", header) as t:
        for culture_id in range(1, cultures + 1):
            person = people[rng.randrange(len(people))]
            day = (FIRST_DAY + dt.timedelta(days=rng.randrange(span))).isoformat()
            germ, _, panel = rng.choices(GERMS, weights)[0]
            for antibiotic, resist in panel.items():
                roll = rng.random()
                if roll < resist:
                    sensitivity = "R"
                elif roll < resist + (1 - resist) * INTERMEDIATE_SHARE:
                    sensitivity = "I"
                else:
                    sensitivity = "S"
                t.row(culture_id, person.person_id, day, germ, antibiotic, sensitivity)
