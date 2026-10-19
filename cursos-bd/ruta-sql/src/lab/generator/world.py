"""El mundo detrás de la caja: las personas reales, las filas de `Pacientes` que la recepción cargó
para cada una, y los protocolos con sus prácticas.

Cada parte usa su propio flujo aleatorio, derivado de la semilla y de un nombre fijo
(`random.Random(f"{seed}/people")`). Por eso agregar una tabla nueva al generador no cambia ni un
byte de las que ya existían.
"""

import bisect
import datetime as dt
import random
from dataclasses import dataclass, field

from . import names as N

TODAY = dt.date(2026, 10, 10)          # el día en que Matías armó la caja
PROFILES = {"s": 20_000, "m": 200_000, "l": 1_000_000}   # personas distintas, antes de duplicar

# Proporciones de la historia (§4), o propuestas por el curso donde la historia no dice nada (D30).
DUPLICATE_SHARE = 0.175                # 15–20 % de las filas repiten a una persona
FUTURE_BIRTH_SHARE = 4_000 / 1_900_000  # "unos 4.000 pacientes nacieron en el futuro"
DNI_IN_NAME_SHARE = 0.109              # propuesto (D30): "PEREZ PEDRO DNI 23456789"
PAYER_IN_NAME_SHARE = 0.05             # propuesto: "GONZALEZ MARIA OSDE 210"
PHONE_NOTE_SHARE = 0.10                # propuesto: "4251234 (VECINA DE ENFRENTE)"
PARSER_FAIL_SHARE = 0.07               # variantes que el parser no entiende; con los RN da ≈ 10 % (D35)

# Protocolos por día a lo largo de la historia: de 25 en 1996 a 3.000 en 2026.
VOLUME = {1996: 25, 1997: 25, 1999: 40, 2003: 70, 2005: 100, 2009: 180, 2011: 300, 2015: 380,
          2019: 400, 2020: 1500, 2021: 1800, 2022: 2000, 2023: 2600, 2024: 2800, 2025: 3000, 2026: 3000}

REPLICATION_START = dt.date(2004, 3, 15)   # los autonuméricos pasan a aleatorios (historia §3, 2004)
NEGATIVE_WEEK_END = dt.date(2004, 3, 21)   # la semana de los números negativos en los informes
UPSIZING = dt.date(2011, 6, 1)             # el asistente pasa los datos a SQL Server Express
IDENTITY_SEED = 10_000_001                 # IDENTITY(10000001,1), "para que no se mezclen"
EAV_START = dt.date(2008, 4, 1)            # ImportarEquipos y ResultadoItem (historia §3, 2008)
PAYER_TABLE_START = dt.date(2012, 1, 1)    # desde 2012 existe ObrasSociales
COVID = (dt.date(2020, 3, 20), dt.date(2022, 12, 31))


@dataclass
class Person:
    person_id: int
    sex: str
    birth: dt.date
    first: str
    last: str
    doc_type: str                 # DNI, LC, LE, PAS, OTRO, NONE
    doc_country: str
    doc_number: str
    payer: str
    member_number: str
    phone: str
    address: str
    mother_id: int | None = None
    dni_later: str = ""           # el DNI que tramitó después (libreta → mismo número; extranjero → rango alto)


@dataclass
class PatientRow:
    patient_id: int
    person: Person
    kind: str                     # original, same_dni_other_name, same_name_empty_dni, newborn_mother_dni,
                                  # passport_in_dni, libreta_and_dni, other_site
    site: str
    since: dt.date
    name: str = ""
    dni: str | None = None
    birth_written: dt.date | None = None
    dirt: list[str] = field(default_factory=list)
    expected_dni: str = ""        # el documento de la persona de esta fila, si su número está escrito en el nombre
    expected_payer: str = ""
    payer_written: str = ""


@dataclass
class Protocol:
    protocol_id: int
    number: str
    patient: PatientRow
    person_id: int
    date: dt.date
    site: str
    payer: str
    payer_written: str | None
    practices: tuple[str, ...]


def _year_weights(since_year: int) -> tuple[list[int], list[float]]:
    years, cum, total = [], [], 0.0
    known = sorted(VOLUME)
    for y in range(since_year, TODAY.year + 1):
        lo = max(k for k in known if k <= y)
        hi = min((k for k in known if k >= y), default=lo)
        per_day = VOLUME[lo] if hi == lo else VOLUME[lo] + (VOLUME[hi] - VOLUME[lo]) * (y - lo) / (hi - lo)
        days = 283 if y == TODAY.year else 365
        total += per_day * days
        years.append(y)
        cum.append(total)
    return years, cum


_WEIGHTS_CACHE: dict[int, tuple[list[int], list[float]]] = {}


def random_visit(rng: random.Random, since: dt.date) -> dt.date:
    """Una fecha entre `since` y TODAY, más probable donde el laboratorio atendía más."""
    if since.year not in _WEIGHTS_CACHE:
        _WEIGHTS_CACHE[since.year] = _year_weights(since.year)
    years, cum = _WEIGHTS_CACHE[since.year]
    y = years[bisect.bisect_left(cum, rng.random() * cum[-1])]
    start = since if y == since.year else dt.date(y, 1, 1)
    end = TODAY if y == TODAY.year else dt.date(y, 12, 31)
    return start + dt.timedelta(days=rng.randrange(0, (end - start).days + 1))


def dni_for_birth(rng: random.Random, year: int) -> int:
    """Un número de DNI plausible para quien nació ese año: la numeración crece con la edad."""
    base = 2_000_000 + (year - 1925) * 240_000 if year < 1950 else 8_000_000 + (year - 1950) * 690_000
    return max(1_000_000, min(69_999_999, int(base + rng.gauss(0, 900_000))))


def _free_number(taken: set[str], number: int) -> str:
    """El primer número libre desde `number`: un DNI no se repite entre personas. No consume azar, así
    que el resto de la caja sale igual."""
    while str(number) in taken:
        number += 1
    taken.add(str(number))
    return str(number)


def _birth_year(rng: random.Random) -> int:
    age = min(101, max(0, int(rng.triangular(0, 95, 48))))
    return TODAY.year - age


def make_people(seed: int, count: int) -> list[Person]:
    rng = random.Random(f"{seed}/people")
    people: list[Person] = []
    women_by_year: dict[int, list[int]] = {}
    taken = {PLANTED_PERSON["doc_number"]}            # la numeración nacional, una sola para todos
    for pid in range(1, count + 1):
        sex = "F" if rng.random() < 0.53 else "M"
        year = _birth_year(rng)
        birth = dt.date(year, 1, 1) + dt.timedelta(days=rng.randrange(0, 365))
        if birth > TODAY:
            birth = TODAY - dt.timedelta(days=rng.randrange(1, 200))
        foreign = rng.random() < 0.04
        first = rng.choice(N.FIRST_FEMALE if sex == "F" else N.FIRST_MALE)
        if rng.random() < 0.45:
            first += " " + rng.choice(N.FIRST_FEMALE if sex == "F" else N.FIRST_MALE)
        last = rng.choice(N.LAST_FOREIGN if foreign else N.LAST)
        if foreign or rng.random() < 0.08:
            last += " " + rng.choice(N.LAST_FOREIGN if foreign else N.LAST)
        if sex == "F" and year < 1960 and rng.random() < 0.15:
            last += " DE " + rng.choice(N.LAST)
        if foreign:
            country = rng.choice(["BOL", "BOL", "PER", "PRY", "CHL", "VEN"])
            doc = ("PAS", country, rng.choice("ABCEPX") + str(rng.randrange(1_000_000, 9_999_999)))
            dni_later = _free_number(taken, rng.randrange(92_000_000, 96_000_000)) if rng.random() < 0.5 else ""
        elif year < 1968 and rng.random() < 0.3:
            number = _free_number(taken, dni_for_birth(rng, year))
            doc = ("LC" if sex == "F" else "LE", "ARG", number)
            dni_later = number                        # al pasar a DNI se conservó el número
        elif rng.random() < 0.0004:
            doc, dni_later = ("OTRO", "", f"{rng.randrange(1000, 9999)}/{rng.randrange(19, 26)}"), ""
        else:
            doc, dni_later = ("DNI", "ARG", _free_number(taken, dni_for_birth(rng, year))), ""
        payer = rng.choices(list(N.PAYER_WEIGHTS), weights=list(N.PAYER_WEIGHTS.values()))[0]
        if year < TODAY.year - 66 and rng.random() < 0.6:
            payer = "PAMI"
        member = "" if payer == "PARTICULAR" else _member_number(rng, payer, doc[2])
        phone = f"{rng.choice(['4', '4', '15-'])}{rng.randrange(100_000, 999_999)}"
        address = f"{rng.choice(N.STREETS)} {rng.randrange(10, 4900)}"
        people.append(Person(pid, sex, birth, first, last, *doc, payer, member, phone, address,
                             dni_later=dni_later))
        if sex == "F":
            women_by_year.setdefault(year, []).append(pid)
    for person in people:
        y = person.birth.year
        if y >= 1990 and rng.random() < 0.55:
            candidates = [p for yy in range(y - 40, y - 17) for p in women_by_year.get(yy, ())]
            if candidates:
                person.mother_id = rng.choice(candidates)
    return people


def _member_number(rng: random.Random, payer: str, doc_number: str) -> str:
    if payer == "PAMI":
        return f"{rng.randrange(10**11, 10**12)}/{rng.randrange(0, 4):02d}"
    if payer == "APROSS":
        return doc_number + f"/{rng.randrange(0, 5):02d}"
    return str(rng.randrange(10**7, 10**10))


# --- La señora del boss I (D40): la misma con cualquier semilla ---------------------------------

PLANTED_PERSON = dict(sex="F", birth=dt.date(1941, 6, 3), first="ELVIRA ROSA", last="AGÜERO DE BUSTOS",
                      doc_type="LC", doc_country="ARG", doc_number="4563218", payer="PAMI",
                      member_number="150418273615/00", phone="4712345 (HIJA)", address="AV. COLON 3125",
                      dni_later="4563218")
PLANTED_GRANDSON = dict(sex="M", birth=dt.date(2019, 8, 14), first="TOMAS", last="BUSTOS",
                        doc_type="NONE", doc_country="", doc_number="", payer="PAMI", member_number="",
                        phone="4712345 (HIJA)", address="AV. COLON 3125")


def plant(people: list[Person]) -> tuple[Person, Person]:
    lady = Person(len(people) + 1, **PLANTED_PERSON)
    grandson = Person(len(people) + 2, **PLANTED_GRANDSON)
    people += [lady, grandson]
    return lady, grandson


# --- Las filas de Pacientes ---------------------------------------------------------------------

def _name(person: Person) -> str:
    return f"{person.last} {person.first}"


def _payer_text(rng: random.Random, payer: str) -> str:
    return rng.choice(N.PAYERS[payer])


def _write_number(rng: random.Random, number: str, birth: dt.date | None = None) -> tuple[str, bool]:
    """Cómo escribe la recepción un documento dentro del nombre, y si el parser lo va a entender."""
    if rng.random() < PARSER_FAIL_SHARE:
        style = rng.choice(["glued", "spaced", "colon", "phone_first", "typo"])
        if style == "glued":
            return f"DNI{number}", False
        if style == "spaced" and len(number) == 8:
            return f"DNI {number[:2]} {number[2:5]} {number[5:]}", False
        if style == "colon":
            return f"DNI:{number}", False
        if style == "phone_first":
            return f"TEL {rng.randrange(4_000_000, 4_999_999)} DNI {number}", False
        return f"DNI {number[:-1]}", False                 # se comió un dígito
    style = rng.random()
    if style < 0.55:
        return f"DNI {number}", True
    if style < 0.72 and number.isdigit():
        return f"DNI {int(number):,}".replace(",", "."), True
    if style < 0.87:
        return number, True
    if style < 0.93:
        return f"D.N.I. {number}", True
    # "APELLIDO NOMBRE espacio DNI espacio NÚMERO espacio FECHA": la de nacimiento, con el año en dos
    # cifras, como la escribía la recepción. Las tres tiradas se hacen igual, para no mover el resto.
    day, month, year = rng.randrange(1, 29), rng.randrange(1, 13), rng.randrange(30, 100)
    if birth is not None:
        day, month, year = birth.day, birth.month, birth.year % 100
    return f"DNI {number} {day:02d}/{month:02d}/{year:02d}", True


def make_patient_rows(seed: int, people: list[Person], lady: Person, grandson: Person) -> list[PatientRow]:
    rng = random.Random(f"{seed}/patients")
    by_id = {p.person_id: p for p in people}
    regular = [p for p in people if p is not lady and p is not grandson]
    sites = [s for s, *_ in N.SITES]
    site_weights = [w for *_, w in N.SITES]
    rows: list[PatientRow] = []

    def first_visit(person: Person) -> dt.date:
        since = max(person.birth, dt.date(1997, 3, 1))
        return random_visit(rng, since)

    for person in regular:
        rows.append(PatientRow(0, person, "original", rng.choices(sites, site_weights)[0], first_visit(person)))
    extra = int(len(regular) * DUPLICATE_SHARE / (1 - DUPLICATE_SHARE))
    kinds = ["same_dni_other_name", "same_name_empty_dni", "newborn_mother_dni", "passport_in_dni",
             "libreta_and_dni", "other_site"]
    babies = [p for p in regular if p.mother_id and p.birth.year >= 1997]
    for _ in range(extra):
        kind = rng.choices(kinds, weights=[30, 24, 14, 6, 16, 18])[0]
        person = rng.choice(regular)
        if kind == "newborn_mother_dni":
            person = rng.choice(babies)
        elif kind == "passport_in_dni" and person.doc_type != "PAS":
            kind = "same_dni_other_name"
        elif kind == "libreta_and_dni" and person.doc_type not in ("LC", "LE"):
            kind = "same_dni_other_name"
        rows.append(PatientRow(0, person, kind, rng.choices(sites, site_weights)[0], first_visit(person)))
    # La señora: libreta en 1999, DNI con el mismo número en 2009, y el nieto con su DNI en 2019.
    rows.append(PatientRow(0, lady, "planted_libreta", "C", dt.date(1999, 4, 12)))
    rows.append(PatientRow(0, lady, "planted_dni", "V", dt.date(2009, 9, 2)))
    rows.append(PatientRow(0, grandson, "planted_newborn", "V", dt.date(2019, 8, 16)))
    rows.sort(key=lambda r: (r.since, rng.random()))
    for i, row in enumerate(rows, start=1):
        row.patient_id = i
        _dirty_row(rng, row, by_id)
    return rows


def _dirty_row(rng: random.Random, row: PatientRow, by_id: dict[int, Person]) -> None:
    p = row.person
    name, dni, number_owner = _name(p), p.doc_number, p
    doc_label = p.doc_type if p.doc_type in ("LC", "LE") else "DNI"
    if row.kind == "planted_libreta":
        row.name, row.dni, row.birth_written = "AGUERO DE BUSTOS ELVIRA LC 4563218", "4563218", p.birth
        row.dirt, row.expected_dni = ["dni_in_name"], "4563218"
        row.payer_written = row.expected_payer = "PAMI"
        return
    if row.kind == "planted_dni":
        row.name, row.dni, row.birth_written = "AGÜERO ELVIRA ROSA", "4.563.218", p.birth
        row.dirt, row.payer_written, row.expected_payer = ["name_variant"], "Pami", "PAMI"
        return
    if row.kind == "planted_newborn":
        row.name, row.dni, row.birth_written = "RN BUSTOS DNI 4563218", "4563218", p.birth
        row.dirt, row.expected_dni = ["newborn_other_dni", "dni_in_name"], ""
        row.payer_written, row.expected_payer = "PAMI", "PAMI"
        return
    if row.kind == "same_dni_other_name":
        parts = p.first.split()
        name = f"{N.SPELLING.get(p.last.split()[0], p.last)} {parts[0]}" if rng.random() < 0.5 else \
            f"{p.last} {parts[0]}"
        row.dirt.append("name_variant")
    elif row.kind == "same_name_empty_dni":
        dni = None
        row.dirt.append("empty_dni")
    elif row.kind == "newborn_mother_dni":
        mother = by_id[p.mother_id]
        name, dni, number_owner = f"RN {p.last.split()[0]} {mother.last.split()[0]}", mother.doc_number, mother
        row.dirt.append("newborn_mother_dni")
    elif row.kind == "passport_in_dni":
        name = f"{p.last} {p.first} (PAS {p.doc_country})"
        row.dirt.append("passport_in_dni")
    elif row.kind == "libreta_and_dni":
        dni = p.dni_later or p.doc_number
        doc_label = "DNI"
        row.dirt.append("libreta_and_dni")
    elif row.kind == "other_site":
        row.dirt.append("other_site")
    if p.doc_type in ("NONE", "OTRO") and row.kind == "original":
        dni = "OTRO " + p.doc_number if p.doc_type == "OTRO" else None
    if p.doc_type == "PAS" and row.kind == "original" and p.dni_later and row.since.year >= 2013:
        dni = p.dni_later                                 # el extranjero que ya tramitó su DNI
    if dni and rng.random() < DNI_IN_NAME_SHARE and row.kind != "passport_in_dni":
        written, _ok = _write_number(rng, dni, p.birth)
        if doc_label != "DNI" and written.startswith("DNI "):
            written = doc_label + written[3:]
        name = f"{name} {written}"
        row.dirt.append("dni_in_name")
        row.expected_dni = "" if number_owner is not p else dni
        if rng.random() < 0.6:
            dni = None                                    # la recepción no llenó el campo DNI
    if p.doc_type == "PAS" and dni == p.doc_number and "passport_in_dni" not in row.dirt:
        row.dirt.append("passport_in_dni")
    if dni and dni.isdigit() and rng.random() < 0.18:
        dni = f"{int(dni):,}".replace(",", ".")
    row.payer_written = _payer_text(rng, p.payer)
    row.expected_payer = p.payer
    if p.payer != "PARTICULAR" and rng.random() < PAYER_IN_NAME_SHARE:
        name = f"{name} {row.payer_written}"
        row.dirt.append("payer_in_name")
    row.birth_written = p.birth
    if rng.random() < FUTURE_BIRTH_SHARE and p.birth.year < 1930 + 70:
        row.birth_written = p.birth.replace(year=p.birth.year + 100)   # el año de dos dígitos
        row.dirt.append("future_birth")
    elif rng.random() < 0.01:
        row.birth_written = None
    row.name, row.dni = name, dni


# --- Los protocolos ------------------------------------------------------------------------------

def _protocol_count(rng: random.Random) -> int:
    return 1 + int(rng.expovariate(1 / 4.6))


def _practices(rng: random.Random, date: dt.date, site: str, chronic: bool) -> tuple[str, ...]:
    if site == "E" or (COVID[0] <= date <= COVID[1] and rng.random() < 0.3):
        return ("COVPCR",)
    codes = [c for c, w in N.PRACTICE_WEIGHTS.items() if w]
    weights = [N.PRACTICE_WEIGHTS[c] for c in codes]
    k = min(len(codes), 2 + int(rng.expovariate(1 / 3.6)))
    chosen = set()
    if chronic:
        chosen.update(["GLU", "HBA1C"])
    while len(chosen) < k:
        chosen.add(rng.choices(codes, weights)[0])
    return tuple(sorted(chosen))


def make_protocols(seed: int, rows: list[PatientRow], lady: Person) -> list[Protocol]:
    rng = random.Random(f"{seed}/protocols")
    raw: list[tuple] = []
    lady_rows = {r.kind: r for r in rows if r.person is lady or r.kind == "planted_newborn"}
    regular = [r for r in rows if r.person is not lady and r.kind != "planted_newborn"]   # ordenadas por alta

    def visit(row: PatientRow, date: dt.date, chronic: bool) -> None:
        site = row.site if rng.random() < 0.8 else rng.choice([s for s, *_ in N.SITES])
        if COVID[0] <= date <= COVID[1] and rng.random() < 0.25:
            site = "E"
        site = _open_site(site, date)
        raw.append((date, rng.random(), row, row.person.person_id, site, _practices(rng, date, site, chronic)))

    # El primer protocolo de cada fila es el del día del alta. Los demás se reparten por fecha según
    # el volumen del laboratorio (VOLUME) y caen sobre una fila que ya existía ese día: así el total
    # por año sigue la historia, en lugar de amontonarse en los últimos años.
    chronic = [rng.random() < 0.06 for _ in regular]
    sinces = [r.since for r in regular]
    cumulative, total, extra = [], 0.0, 0
    for row, is_chronic in zip(regular, chronic):
        extra += _protocol_count(rng) + (6 if is_chronic else 0) - 1
        total += 4.0 if is_chronic else 1.0          # el crónico vuelve más seguido
        cumulative.append(total)
        visit(row, row.since, is_chronic)
    for _ in range(extra):
        date = random_visit(rng, sinces[0])
        k = bisect.bisect_right(sinces, date)        # las filas dadas de alta hasta ese día
        i = min(k - 1, bisect.bisect_left(cumulative, rng.random() * cumulative[k - 1]))
        visit(regular[i], date, chronic[i])
    # La señora, crónica desde 1999: control cada tres meses, y los de agosto de 2019 a enero de 2020 cargados
    # sobre la fila del nieto (con la semilla 1996, uno: el del 9 de noviembre de 2019).
    d = dt.date(1999, 4, 12)
    while d <= TODAY:
        if d < dt.date(2009, 9, 2):
            row = lady_rows["planted_libreta"]
        elif dt.date(2019, 8, 16) <= d < dt.date(2020, 2, 1):
            row = lady_rows["planted_newborn"]
        else:
            row = lady_rows["planted_dni"]
        practices = ("CREA", "GLU", "HBA1C") + (("LIPID",) if d.month in (4, 5, 6) else ())
        raw.append((d, 0.5, row, lady.person_id, row.site, practices))
        d += dt.timedelta(days=91 + rng.randrange(-10, 11))
    grandson_row = lady_rows["planted_newborn"]
    raw.append((dt.date(2019, 8, 16), 0.1, grandson_row, grandson_row.person.person_id, "V", ("HEMOG",)))
    raw.sort(key=lambda t: (t[0], t[1]))
    return _number(rng, raw)


def _open_site(site: str, date: dt.date) -> str:
    if site == "E":
        return "E" if COVID[0] <= date <= COVID[1] else "C"
    opened = {s: y for s, _n, y, _w in N.SITES}
    return site if date.year >= opened[site] else "C"


def _number(rng: random.Random, raw: list[tuple]) -> list[Protocol]:
    """IdProtocolo y NroProtocolo como los dejó la historia: secuencial, aleatorio por la
    replicación de Jet, IDENTITY desde 2011; y el número visible con prefijo de sede y DMax + 1."""
    out, used, seq, identity = [], set(), 0, IDENTITY_SEED
    per_site: dict[str, int] = {}
    last_number: dict[str, str] = {}
    for date, _tiebreak, row, person_id, site, practices in raw:
        if date < REPLICATION_START:
            seq += 1
            pid, number = seq, f"{seq:06d}"
        elif date < UPSIZING:
            pid = 0
            while pid == 0 or pid in used or IDENTITY_SEED <= pid < IDENTITY_SEED + 50_000_000:
                pid = rng.randrange(-2**31, 2**31)
            if date <= NEGATIVE_WEEK_END and rng.random() < 0.08:
                number = str(pid)                        # los que nadie renumeró
            else:
                number = None
        else:
            pid, identity = identity, identity + 1
            number = None
        used.add(pid)
        if number is None:
            if date.year >= 2005 and site in last_number and rng.random() < 0.003:
                number = last_number[site]               # DMax + 1 con dos recepcionistas a la vez
            else:
                per_site[site] = per_site.get(site, 0) + 1
                number = f"{site}-{per_site[site]:07d}"
            last_number[site] = number
        payer = row.person.payer
        if date < PAYER_TABLE_START or rng.random() < 0.07:
            written = None if rng.random() < 0.03 else ("" if rng.random() < 0.02 else row.payer_written)
        else:
            written = None
        out.append(Protocol(pid, number, row, person_id, date, site, payer, written, practices))
    return out
