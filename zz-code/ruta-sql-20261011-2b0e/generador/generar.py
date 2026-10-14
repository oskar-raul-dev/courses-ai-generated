#!/usr/bin/env python3
"""Prototype of the Ruta SQL box generator (P8). Standard library only.

Writes a subset of "la caja" (Pacientes, Protocolos, ResultadoItem) as CSV, with the dirt of the
story in its proportions, plus the generator's truth in truth/. Same seed, same bytes.

Usage: generar.py --profile s|m|l [--seed 1979] [--out DIR]
"""

import argparse
import csv
import datetime
import hashlib
import os
import random
import time

PROFILES = {"s": 20_000, "m": 200_000, "l": 1_000_000}  # distinct people, before duplicates

# Proportions taken from the story (00-historia-de-alameda.md §4), or proposed where it is silent.
DUPLICATE_SHARE = 0.175        # 15-20 % of patient rows are another row of the same person
FUTURE_BIRTH_SHARE = 4_000 / 1_900_000   # "unos 4.000 pacientes nacieron en el futuro"
DNI_IN_NAME_SHARE = 0.12       # proposed: "PEREZ PEDRO DNI 23456789"
PAYER_IN_NAME_SHARE = 0.06     # proposed: "GOMEZ ANA OSDE"
KIN_IN_NAME_SHARE = 0.02       # proposed: "LOPEZ JUAN HIJO"
PROTOCOLS_PER_PERSON = 6       # mean; 140 M items / 1.9 M patients ≈ 74 items per patient
ITEMS_PER_PROTOCOL = 12.3

FIRST = ["JUAN", "MARIA", "CARLOS", "ANA", "JOSE", "LAURA", "LUIS", "SILVIA", "JORGE", "NORMA",
         "PEDRO", "GRACIELA", "MIGUEL", "PATRICIA", "DANIEL", "MONICA", "RAUL", "SUSANA", "HUGO",
         "MARTA", "PABLO", "CLAUDIA", "DIEGO", "ROSA", "SERGIO", "ALICIA", "MARCELO", "BEATRIZ",
         "OSCAR", "LILIANA", "MATIAS", "FLORENCIA", "AGUSTIN", "CAMILA", "LUCAS", "VALENTINA"]
LAST = ["GONZALEZ", "RODRIGUEZ", "GOMEZ", "FERNANDEZ", "LOPEZ", "DIAZ", "MARTINEZ", "PEREZ",
        "GARCIA", "SANCHEZ", "ROMERO", "SOSA", "ALVAREZ", "TORRES", "RUIZ", "RAMIREZ", "FLORES",
        "BENITEZ", "ACOSTA", "MEDINA", "HERRERA", "SUAREZ", "AGUIRRE", "GIMENEZ", "GUTIERREZ",
        "PEREYRA", "ROJAS", "MOLINA", "CASTRO", "ORTIZ", "SILVA", "NUÑEZ", "LUNA", "JUAREZ",
        "CABRERA", "RIOS", "FERREYRA", "GODOY", "MORALES", "PEÑA", "VERA", "CÓRDOBA", "MÉNDEZ"]
PAYERS = {"OSDE": ["OSDE", "Osde", "O.S.D.E", "osde 210"],
          "PAMI": ["PAMI", "Pami", "P.A.M.I.", "INSSJP"],
          "APROSS": ["APROSS", "Apross", "IPAM", "A.P.R.O.S.S."],
          "SANCOR": ["SANCOR SALUD", "Sancor", "SANCOR"],
          "PARTICULAR": ["PARTICULAR", "Particular", "PART."]}
SITES = ["C", "N", "S", "V"]  # central, norte, sur, Villa Allende
# (code, unit, low, high, decimals); results are numeric analytes only in the prototype
ANALYTES = [("GLU", "mg/dL", 70, 140, 0), ("UREA", "mg/dL", 15, 60, 0), ("CREA", "mg/dL", 0.5, 1.6, 2),
            ("COL", "mg/dL", 120, 280, 0), ("HDL", "mg/dL", 30, 80, 0), ("TG", "mg/dL", 50, 350, 0),
            ("HB", "g/dL", 10, 17, 1), ("HTO", "%", 32, 52, 1), ("GB", "/mm3", 3500, 13000, 0),
            ("PLAQ", "/mm3", 120000, 450000, 0), ("TSH", "uUI/mL", 0.3, 6, 2), ("K", "mEq/L", 3.2, 5.6, 1),
            ("NA", "mEq/L", 132, 148, 0), ("GOT", "U/L", 8, 80, 0), ("GPT", "U/L", 6, 90, 0),
            ("PCR", "mg/L", 0.1, 40, 1), ("VSG", "mm/h", 2, 60, 0), ("FAL", "U/L", 40, 300, 0)]


def fmt_number(value, decimals, comma):
    text = f"{value:.{decimals}f}"
    return text.replace(".", ",") if comma else text


def dirty_value(rng, analyte):
    """Return (text as the instrument wrote it, intended numeric value or None, state)."""
    code, _unit, low, high, dec = analyte
    value = round(rng.uniform(low * 0.8, high * 1.2), dec)
    roll = rng.random()
    if roll < 0.45:
        return fmt_number(value, dec, True), value, "comma"
    if roll < 0.90:
        return fmt_number(value, dec, False), value, "dot"
    if roll < 0.93:
        limit = fmt_number(low * 0.5, dec, rng.random() < 0.5)
        return rng.choice(["< ", "<"]) + limit, None, "below_limit"
    if roll < 0.95:
        return ">" + str(int(high * 5)), None, "above_limit"
    if roll < 0.97:
        return rng.choice(["HEMOLIZADA", "NO SE PROCESA", "MUESTRA INSUFICIENTE"]), None, "not_processed"
    return "", None, "empty"


def make_people(rng, count):
    people = []
    for pid in range(1, count + 1):
        birth = datetime.date(1930, 1, 1) + datetime.timedelta(days=rng.randrange(0, 34_000))
        people.append({
            "person_id": pid,
            "first": rng.choice(FIRST) + (" " + rng.choice(FIRST) if rng.random() < 0.3 else ""),
            "last": rng.choice(LAST),
            "dni": str(rng.randrange(5_000_000, 55_000_000)),
            "birth": birth,
            "sex": rng.choice("FM"),
            "payer": rng.choice(list(PAYERS)),
        })
    return people


def patient_row(rng, person, kind, mother=None):
    name = f"{person['last']} {person['first']}"
    dni, birth = person["dni"], person["birth"]
    if kind == "same_dni_other_name":
        name = f"{person['last']} {person['first'].split()[0]}"  # second name dropped
    elif kind == "same_name_empty_dni":
        dni = ""
    elif kind == "newborn_mother_dni":
        dni = mother["dni"]
        name = f"{mother['last']} RN"
    elif kind == "passport":
        dni = rng.choice("ABCPX") + rng.choice("ABCDEF") + str(rng.randrange(100_000, 999_999))
    payer_text = rng.choice(PAYERS[person["payer"]])
    roll = rng.random()
    if roll < DNI_IN_NAME_SHARE and dni:
        name = f"{name} DNI {dni}"
    elif roll < DNI_IN_NAME_SHARE + PAYER_IN_NAME_SHARE:
        name = f"{name} {payer_text}"
    elif roll < DNI_IN_NAME_SHARE + PAYER_IN_NAME_SHARE + KIN_IN_NAME_SHARE:
        name = f"{name} {rng.choice(['HIJO', 'HIJA', 'ESPOSA', 'TITULAR'])}"
    future = rng.random() < FUTURE_BIRTH_SHARE
    if future:
        birth = birth.replace(year=birth.year + 100) if birth.year < 1970 else birth.replace(year=2030)
    phone = f"351{rng.randrange(4_000_000, 7_000_000)}"
    if rng.random() < 0.1:
        phone += rng.choice([" (VECINA)", " llamar tarde", " / 15-" + str(rng.randrange(100000, 999999))])
    return name, dni, birth, payer_text, phone, future


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--profile", choices=PROFILES, default="s")
    parser.add_argument("--seed", type=int, default=1979)
    parser.add_argument("--out", default="caja")
    args = parser.parse_args()
    rng = random.Random(args.seed)
    out = os.path.join(args.out, args.profile)
    os.makedirs(os.path.join(out, "truth"), exist_ok=True)
    started = time.time()

    people = make_people(rng, PROFILES[args.profile])
    rows = [(p, "original", None) for p in people]
    # newborns (15 % of the extra rows) are new people, so they do not count as repeats
    extra = int(len(people) * DUPLICATE_SHARE / (0.85 - DUPLICATE_SHARE))
    for _ in range(extra):
        person = rng.choice(people)
        kind = rng.choices(["same_dni_other_name", "same_name_empty_dni", "newborn_mother_dni", "passport"],
                           weights=[40, 30, 15, 15])[0]
        if kind == "newborn_mother_dni":
            baby = dict(person, person_id=len(people) + 1, first="RN", sex=rng.choice("FM"),
                        birth=datetime.date(2000, 1, 1) + datetime.timedelta(days=rng.randrange(0, 9000)))
            people.append(baby)
            rows.append((baby, kind, person))
        else:
            rows.append((person, kind, None))
    rng.shuffle(rows)

    patient_ids = []
    with open(os.path.join(out, "Pacientes.csv"), "w", newline="", encoding="latin-1") as fp, \
         open(os.path.join(out, "truth", "patient_person.csv"), "w", newline="", encoding="utf-8") as ft:
        w, wt = csv.writer(fp), csv.writer(ft)
        w.writerow(["IdPaciente", "Nombre", "DNI", "FechaNac", "Sexo", "Telefono", "ObraSocial", "NroAfiliado"])
        wt.writerow(["patient_id", "person_id", "dirt_kind", "born_in_future"])
        for pid, (person, kind, mother) in enumerate(rows, start=1):
            name, dni, birth, payer_text, phone, future = patient_row(rng, person, kind, mother)
            w.writerow([pid, name, dni, birth.isoformat(), person["sex"], phone, payer_text,
                        str(rng.randrange(10**8, 10**9)) if person["payer"] != "PARTICULAR" else ""])
            wt.writerow([pid, person["person_id"], kind, int(future)])
            patient_ids.append(pid)

    protocol_id = item_id = 0
    with open(os.path.join(out, "Protocolos.csv"), "w", newline="", encoding="utf-8") as fpr, \
         open(os.path.join(out, "ResultadoItem.csv"), "w", newline="", encoding="utf-8") as fi, \
         open(os.path.join(out, "truth", "result_value.csv"), "w", newline="", encoding="utf-8") as fv:
        wp, wi, wv = csv.writer(fpr), csv.writer(fi), csv.writer(fv)
        wp.writerow(["IdProtocolo", "NroProtocolo", "IdPaciente", "Fecha", "Sede", "ObraSocialTexto"])
        wi.writerow(["IdItem", "IdProtocolo", "CodAnalito", "Valor", "Unidad"])
        wv.writerow(["item_id", "intended_value", "state"])
        for pid in patient_ids:
            for _ in range(max(1, int(rng.expovariate(1 / PROTOCOLS_PER_PERSON)))):
                protocol_id += 1
                day = datetime.date(2004, 1, 1) + datetime.timedelta(days=rng.randrange(0, 8000))
                site = rng.choice(SITES)
                payer = rng.choice(sum(PAYERS.values(), [])) if day.year < 2012 else ""
                wp.writerow([protocol_id, f"{site}-{protocol_id:08d}", pid, day.isoformat(), site, payer])
                for analyte in rng.sample(ANALYTES, min(len(ANALYTES), max(1, int(rng.gauss(ITEMS_PER_PROTOCOL, 3))))):
                    item_id += 1
                    text, value, state = dirty_value(rng, analyte)
                    wi.writerow([item_id, protocol_id, analyte[0], text, analyte[1]])
                    wv.writerow([item_id, "" if value is None else value, state])

    digest = hashlib.sha256()
    for name in sorted(["Pacientes.csv", "Protocolos.csv", "ResultadoItem.csv",
                        "truth/patient_person.csv", "truth/result_value.csv"]):
        with open(os.path.join(out, name), "rb") as fh:
            for block in iter(lambda: fh.read(1 << 20), b""):
                digest.update(block)
    print(f"profile={args.profile} seed={args.seed} people={len(people)} patients={len(patient_ids)} "
          f"protocols={protocol_id} items={item_id} seconds={time.time() - started:.1f} sha256={digest.hexdigest()}")


if __name__ == "__main__":
    main()
