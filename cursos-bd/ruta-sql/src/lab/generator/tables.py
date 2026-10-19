"""Los escritores de la caja: un CSV por tabla de ALAMEDA, más lo que Matías puso al lado.

Los CSV siguen una sola convención, la que declara el `LEEME.txt`: separador coma, fin de línea
CRLF, texto entre comillas, y **NULL como campo vacío sin comillas** (`""` es una cadena vacía, que
no es lo mismo). Las fechas, como las exporta `bcp`: `2004-03-15 00:00:00.000`.
"""

import csv
import datetime as dt
import math
import os
import random

from . import names as N
from . import schema as S
from . import world as W
from . import xlsx


class Box:
    """El directorio de un perfil de la caja y los conteos de lo que se escribió."""

    def __init__(self, root: str, seed: int):
        self.root, self.seed, self.counts = root, seed, {}

    def rng(self, name: str) -> random.Random:
        return random.Random(f"{self.seed}/{name}")

    def path(self, rel: str) -> str:
        full = os.path.join(self.root, rel)
        os.makedirs(os.path.dirname(full), exist_ok=True)
        return full

    def table(self, name: str):
        return TableWriter(self, S.TABLES[name])

    def csv(self, rel: str, header: list[str], encoding: str = "utf-8"):
        return TableWriter(self, None, rel, header, encoding)


class TableWriter:
    def __init__(self, box: Box, table: S.Table | None, rel: str = "", header=None, encoding="utf-8"):
        self.box, self.key = box, table.name if table else rel
        rel = table.file if table else rel
        header = [c.name for c in table.exported_columns] if table else header
        self.fh = open(box.path(rel), "w", newline="", encoding=table.encoding if table else encoding)
        self.w = csv.writer(self.fh, quoting=csv.QUOTE_STRINGS, lineterminator="\r\n")
        self.w.writerow(header)
        self.n = 0

    def row(self, *values):
        self.w.writerow(values)
        self.n += 1

    def __enter__(self):
        return self

    def __exit__(self, *_):
        self.fh.close()
        self.box.counts[self.key] = self.n


def ts(d: dt.date | dt.datetime | None) -> str | None:
    if d is None:
        return None
    if isinstance(d, dt.datetime):
        return d.strftime("%Y-%m-%d %H:%M:%S.") + f"{d.microsecond // 1000:03d}"
    return d.strftime("%Y-%m-%d") + " 00:00:00.000"


def money(x: float) -> str:
    return f"{x:.4f}"


# --- Catálogos ---------------------------------------------------------------------------------

def practice_catalog() -> list[dict]:
    """Las prácticas con sus tres códigos. Los números son sintéticos, con la forma de los reales."""
    rng = random.Random("catalogo-de-practicas")     # no depende de la semilla: es el nomenclador
    rows = [(code, desc, ub) for code, desc, _a, ub in N.PRACTICES]
    rows += [(f"X{i:02d}", f"{name} (tabla ancha)", rng.randrange(4, 30)) for i, name in enumerate(N.WIDE_OTHERS)]
    out = []
    for i, (code, desc, ub) in enumerate(rows):
        inos = None if code == "COVPCR" else str(401 + 3 * i)
        nbu = None if code == "COVPCR" else f"66{i + 1:04d}"
        nbu2012 = f"66{i + 501:04d}" if (code == "COVPCR" or rng.random() < 0.15) else nbu
        out.append(dict(code=code, inos=inos, nbu=nbu, nbu2012=nbu2012,
                        desc=desc.replace(" (tabla ancha)", ""), ub=ub))
    return out


PRACTICES = practice_catalog()
PRACTICE_BY_CODE = {p["code"]: p for p in PRACTICES}
ANALYTE = {a[0]: a for a in N.ANALYTES}
PRACTICE_ANALYTES = {code: analytes for code, _d, analytes, _u in N.PRACTICES}
# El año en que cada pagador adoptó el NBU, y el NBU 2012 (los que lo adoptaron).
NBU_ADOPTION = {"APROSS": 2006, "PAMI": 2008, "OSDE": 2007, "SANCOR": 2007, "SWISS": 2009, "GALENO": 2009,
                "OSECAC": 2011, "UOM": 2012, "OSPRERA": 2010, "DASPU": 2006, "PARTICULAR": 2006}
NBU2012_ADOPTION = {"APROSS": 2013, "OSDE": 2014, "SANCOR": 2014, "SWISS": 2015, "PARTICULAR": 2013}
PAYER_IDS = {code: i for i, code in enumerate(N.PAYERS, start=1)}


def written_code(practice: str, payer: str, date: dt.date) -> tuple[str, str]:
    p = PRACTICE_BY_CODE[practice]
    if p["inos"] and date.year < NBU_ADOPTION.get(payer, 2008):
        return p["inos"], "INOS"
    if p["nbu"] and date.year < NBU2012_ADOPTION.get(payer, 2099):
        return p["nbu"], "NBU"
    return p["nbu2012"], "NBU2012"


def ub_value(year: int, month: int) -> float:
    """Valor de la unidad bioquímica en pesos: anclas aproximadas de la inflación, interpoladas."""
    anchors = [(2002.7, 1.2), (2006, 2.0), (2010, 4.0), (2014, 9.0), (2016, 18.0), (2018, 32.0), (2019, 55.0),
               (2020, 85.0), (2021, 130.0), (2022, 260.0), (2023, 700.0), (2024, 2100.0), (2025, 3000.0),
               (2026, 3600.0)]
    t = year + (month - 1) / 12
    if t < anchors[0][0]:
        return anchors[0][1]                          # antes de la primera ancla, su valor (septiembre de 2002)
    for (t0, v0), (t1, v1) in zip(anchors, anchors[1:]):
        if t0 <= t <= t1:
            return v0 * math.exp(math.log(v1 / v0) * (t - t0) / (t1 - t0))
    return anchors[-1][1]


# --- Pacientes y la verdad sobre las personas -----------------------------------------------------

def age_text(rng: random.Random, birth: dt.date | None, at: dt.date) -> str | None:
    if birth is None or birth > at:
        return None if rng.random() < 0.5 else ""
    years = (at - birth).days // 365
    if years == 0:
        return f"{max(1, (at - birth).days // 30)} meses"
    return rng.choice([f"{years} años", str(years), f"{years}a", str(years)])


def write_patients(box: Box, w: dict) -> None:
    rng = box.rng("Pacientes")
    with box.table("Pacientes") as t, \
            box.csv("truth/patient_record.csv", ["legacy_patient_id", "person_id", "dirt"]) as tr, \
            box.csv("truth/parser_case.csv", ["legacy_patient_id", "expected_dni", "expected_payer"]) as tp:
        for r in w["rows"]:
            p = r.person
            phone = p.phone
            if rng.random() < W.PHONE_NOTE_SHARE:
                phone += rng.choice([" (VECINA DE ENFRENTE)", " SOLO TARDE", " (HIJA)", " / 15-6" +
                                     str(rng.randrange(100_000, 999_999)), " NO ANDA"])
            payer_col = r.payer_written if rng.random() < 0.9 else None
            member = p.member_number if (p.member_number and rng.random() < 0.85) else None
            t.row(r.patient_id, r.name, r.dni, ts(r.birth_written), age_text(rng, r.birth_written, r.since),
                  p.sex if rng.random() < 0.97 else None, phone, p.address if rng.random() < 0.8 else None,
                  payer_col, member, r.site, ts(r.since))
            tr.row(r.patient_id, p.person_id, "{" + ",".join(r.dirt) + "}")
            if "dni_in_name" in r.dirt or "payer_in_name" in r.dirt:
                tp.row(r.patient_id, r.expected_dni, r.expected_payer)


def write_people(box: Box, w: dict) -> None:
    header = ["person_id", "sex", "birth_date", "document_type", "document_country", "document_number",
              "later_dni", "mother_person_id", "payer_code"]
    with box.csv("truth/person.csv", header) as t:
        for p in w["people"]:
            t.row(p.person_id, p.sex, p.birth.isoformat(), p.doc_type, p.doc_country or None,
                  p.doc_number or None, p.dni_later or None, p.mother_id, p.payer)
    with box.csv("truth/planted_case.csv", ["case_code", "person_id", "note"]) as t:
        t.row("boss-1-lady", w["lady"].person_id, "la señora que es tres pacientes: libreta, DNI y la fila del nieto")
        t.row("boss-1-grandson", w["grandson"].person_id, "el nieto recién nacido, cargado con el DNI de la abuela")


# --- Protocolos, prácticas y resultados -----------------------------------------------------------

def write_protocols(box: Box, w: dict) -> None:
    rng = box.rng("Protocolos")
    doctors = w["doctors"]
    with box.table("Protocolos") as t, box.csv("truth/order_payer.csv", [
            "legacy_protocol_id", "person_id", "payer_code", "written_as"]) as tt:
        for pr in w["protocols"]:
            payer_id = PAYER_IDS[pr.payer] if pr.date >= W.PAYER_TABLE_START else None
            copay = None
            if pr.payer == "PARTICULAR":
                copay = sum(PRACTICE_BY_CODE[c]["ub"] for c in pr.practices) * W_UB(pr.date)
            elif rng.random() < 0.3:
                copay = round(rng.uniform(0.05, 0.3) * 20 * W_UB(pr.date), 2)
            state = "ENTREGADO" if (W.TODAY - pr.date).days > 3 else rng.choice(["EN PROCESO", "ENTREGADO"])
            doctor = rng.randrange(1, doctors + 1) if rng.random() < 0.93 else None
            t.row(pr.protocol_id, pr.number, pr.patient.patient_id, ts(pr.date), pr.site, pr.payer_written,
                  payer_id, doctor, None if copay is None else money(copay), state)
            tt.row(pr.protocol_id, pr.person_id, pr.payer, pr.payer_written)


def W_UB(date: dt.date) -> float:
    return ub_value(date.year, date.month)


def write_protocol_practices(box: Box, w: dict) -> None:
    rng = box.rng("ProtocoloPracticas")
    with box.table("ProtocoloPracticas") as t:
        for pr in w["protocols"]:
            for code in pr.practices:
                written, catalog = written_code(code, pr.payer, pr.date)
                t.row(t.n + 1, pr.protocol_id, written, catalog, 1 if rng.random() < 0.98 else 2)


# Qué equipo midió cada determinación: depende de la disciplina, y cada equipo se reemplaza en algún
# momento. El estilo es su configuración regional, que decide si exporta con coma o con punto.
DISCIPLINE = {
    "HB": "hematology", "HTO": "hematology", "GR": "hematology", "GB": "hematology", "PLAQ": "hematology",
    "VSG": "hematology", "TP": "coagulation", "KPTT": "coagulation",
    "TSH": "immunology", "T4L": "immunology", "FERR": "immunology", "B12": "immunology", "PSA": "immunology",
    "COL": "chemistry_b", "HDL": "chemistry_b", "LDL": "chemistry_b", "TG": "chemistry_b",   # el perfil lipídico
}
EQUIPMENT = {   # (desde el año, equipo, estilo)
    "hematology": [(2008, "SYSMEX XT-1800i", "dot"), (2015, "SYSMEX XN-1000", "dot")],
    "coagulation": [(2008, "ACL 7000", "dot"), (2016, "ACL TOP 300", "dot")],
    "immunology": [(2008, "ARCHITECT i1000SR", "comma"), (2017, "ARCHITECT ci4100", "comma")],
    "chemistry_a": [(2008, "METROLAB 2300", "comma"), (2014, "COBAS c311", "comma")],
    "chemistry_b": [(2008, "ADVIA 1650", "dot"), (2013, "ADVIA 1800", "dot")],
}


def equipment_for(code: str, year: int) -> tuple[str, str]:
    """El equipo vigente ese año para la disciplina de la determinación (química A si no figura)."""
    name, style = "", ""
    for since, n, st in EQUIPMENT[DISCIPLINE.get(code, "chemistry_a")]:
        if year >= since:
            name, style = n, st
    return name, style


def _value(rng: random.Random, code: str, chronic_lady: bool) -> float:
    _c, _n, _u, low, high, dec, _r = ANALYTE[code]
    if chronic_lady and code == "GLU":
        v = rng.gauss(158, 28)
    elif chronic_lady and code == "HBA1C":
        v = rng.gauss(7.6, 0.7)
    else:
        v = rng.uniform(low, high)
    return round(max(low * 0.6, v), dec)


def _fmt(value: float, dec: int, comma: bool) -> str:
    text = f"{value:.{dec}f}"
    return text.replace(".", ",") if comma else text


def _deleted_protocols(box: Box, w: dict) -> dict[int, int]:
    """Los protocolos que la recepción borró y volvió a cargar entre 2008 y la migración de 2011 ("si
    sale repetido, bórralo y cárgalo de nuevo"). Access no exigía integridad referencial, así que sus
    resultados quedaron apuntando a un IdProtocolo que ya no existe: los huérfanos por los que en 2011
    las claves foráneas se crearon WITH NOCHECK. Flujo aparte: no cambia ningún otro valor de la tabla."""
    rng = box.rng("ResultadoItem/borrados")
    used = {pr.protocol_id for pr in w["protocols"]}
    lady = w["lady"].person_id
    deleted: dict[int, int] = {}
    for pr in w["protocols"]:
        if W.EAV_START <= pr.date < W.UPSIZING and pr.person_id != lady and rng.random() < 0.005:
            ghost = 0
            while ghost == 0 or ghost in used:
                ghost = rng.randrange(-2**31, 2**31)
            used.add(ghost)
            deleted[pr.protocol_id] = ghost
    return deleted


def write_results(box: Box, w: dict) -> None:
    rng = box.rng("ResultadoItem")
    lady = w["lady"].person_id
    deleted = _deleted_protocols(box, w)
    item = 0
    with box.table("ResultadoItem") as t, box.csv("truth/result_value.csv", [
            "legacy_result_item_id", "value_numeric", "qualifier", "value_text", "state"]) as tv:
        for pr in w["protocols"]:
            if pr.date < W.EAV_START:
                continue
            when = dt.datetime.combine(pr.date, dt.time(8)) + dt.timedelta(minutes=rng.randrange(60, 600))
            for practice in pr.practices:
                for code in PRACTICE_ANALYTES[practice]:
                    item += 1
                    _c, _n, unit, low, high, dec, ref = ANALYTE[code]
                    equipment, style = equipment_for(code, pr.date.year)
                    if code in N.QUALITATIVE:
                        text = rng.choice(N.QUALITATIVE[code])
                        t.row(item, deleted.get(pr.protocol_id, pr.protocol_id), code, text, unit or None, ref,
                              "COBAS 6800", ts(when))
                        tv.row(item, None, None, text, "qualitative")
                        continue
                    roll = rng.random()
                    if roll < 0.03:
                        limit = round(low * 0.5, dec) or round(low * 0.5, 2)
                        text = rng.choice(["< ", "<"]) + _fmt(limit, max(dec, 1), style == "comma")
                        value, qual, state = limit, "<", "below"
                    elif roll < 0.05:
                        limit = int(high * 5)
                        text, value, qual, state = f">{limit}", limit, ">", "above"
                    elif roll < 0.07:
                        text = "HEMOLIZADA" if rng.random() < 0.8 else rng.choice(["REPETIR", "MUESTRA INSUFICIENTE"])
                        value, qual, state = None, None, "hemolyzed"
                    elif roll < 0.10:
                        text, value, qual, state = "", None, None, "empty"
                    else:
                        value = _value(rng, code, pr.person_id == lady)
                        text, qual, state = _fmt(value, dec, style == "comma"), None, style
                    t.row(item, deleted.get(pr.protocol_id, pr.protocol_id), code, text, unit or None, ref,
                          equipment, ts(when))
                    tv.row(item, value, qual, None, state)


WIDE_PARAMS = {"Hemoglobina": "HB", "Hematocrito": "HTO", "GlobRojos": "GR", "GlobBlancos": "GB",
               "Plaquetas": "PLAQ", "Glucemia": "GLU", "Urea": "UREA", "Creatinina": "CREA", "Uricemia": "URIC",
               "Colesterol": "COL", "ColTotal": "COL", "HDL": "HDL", "LDL": "LDL", "Trigliceridos": "TG",
               "TSH": "TSH", "T4Libre": "T4L", "Sodio": "NA", "Potasio": "K", "Cloro": "CL", "GOT": "GOT",
               "GPT": "GPT", "FAL": "FAL", "BilTotal": "BT", "TiempoProt": "TP", "KPTT": "KPTT", "VSG1h": "VSG",
               "HbA1c": "HBA1C", "PCR": "PCR", "Ferritina": "FERR", "B12": "B12", "PSATotal": "PSA",
               "Calcio": "CA", "Magnesio": "MG"}
# Qué prácticas caen en qué tabla ancha: la química suelta se anotaba toda en Quimica.
PRACTICE_TO_WIDE = {"HEMOG": "Hemograma", "GLU": "Quimica", "UREA": "Quimica", "CREA": "Quimica",
                    "URIC": "Quimica", "LIPID": "Lipidograma", "TIROI": "Tiroideo", "IONOG": "Ionograma",
                    "HEPAT": "Hepatograma", "COAG": "Coagulograma", "VSG": "Eritrosedimentacion",
                    "HBA1C": "HemoglobinaGlicosilada", "PCR": "ProteinaCReactiva", "FERR": "Ferritina",
                    "B12": "VitaminaB12", "PSA": "PSA", "CALC": "Calcemia", "MAGN": "Magnesemia"}
QUIMICA_PARAM_PRACTICE = {"Glucemia": "GLU", "Urea": "UREA", "Creatinina": "CREA", "Uricemia": "URIC"}


def write_wide(box: Box, w: dict) -> None:
    """Las 71 tablas anchas, para los protocolos anteriores a ImportarEquipos (2008)."""
    rng = box.rng("tablas-anchas")
    lady = w["lady"].person_id
    wide = [t for t in S.TABLES.values() if t.group == "wide"]
    writers = {t.name: box.table(t.name) for t in wide}
    others = [t.name for t in wide if t.name in N.WIDE_OTHERS]
    try:
        for pr in w["protocols"]:
            if pr.date >= W.EAV_START:
                break
            targets: dict[str, set[str]] = {}
            for practice in pr.practices:
                table = PRACTICE_TO_WIDE.get(practice)
                if table:
                    targets.setdefault(table, set()).add(practice)
            if rng.random() < 0.12:
                targets["Orina"] = set()
            if rng.random() < 0.08:
                targets[rng.choice(others)] = set()
            for table, practices in targets.items():
                _wide_row(rng, writers[table], S.TABLES[table], pr, practices, pr.person_id == lady)
    finally:
        for wr in writers.values():
            wr.__exit__()


def _wide_row(rng, writer, table: S.Table, pr, practices, lady) -> None:
    values = []
    for col in table.exported_columns:
        name = col.name
        if name == "Id":
            values.append(writer.n + 1)
        elif name == "IdProtocolo":
            values.append(pr.protocol_id)
        elif name == "Fecha":
            values.append(ts(pr.date))
        elif name in WIDE_PARAMS and (table.name != "Quimica" or QUIMICA_PARAM_PRACTICE.get(name) in practices):
            code = WIDE_PARAMS[name]
            dec = ANALYTE[code][5]
            v = _value(rng, code, lady)
            values.append(_fmt(v, dec, rng.random() < 0.85) if rng.random() < 0.96 else rng.choice(["-", "", "VER OBS"]))
        elif name.startswith("Otro"):
            values.append(None if rng.random() < 0.9 else rng.choice(["NEG", "1,2", "VER", "S/D"]))
        elif name == "Obs":
            values.append(None if rng.random() < 0.85 else rng.choice(
                ["REPETIR", "LLAMAR AL MEDICO", "MUESTRA LIPEMICA", "ver hoja", "CONTROL"]))
        elif table.name in N.WIDE_OTHERS:
            values.append(_other_value(rng, name))
        else:
            values.append(None)
    writer.row(*values)


def _other_value(rng, name: str) -> str | None:
    pools = {"Color": ["AMARILLO", "AMBAR", "AMARILLO CLARO"], "Aspecto": ["LIMPIDO", "LIG. TURBIO", "TURBIO"],
             "Densidad": ["1010", "1015", "1020", "1025", "1.020"], "pH": ["5", "5,5", "6", "6.5", "7"],
             "Proteinas": ["NEG", "VESTIGIOS", "+", "++"], "Glucosa": ["NEG", "NEG", "+"],
             "Sedimento": ["ESCASAS CELULAS", "LEUCOCITOS 2-4/CPO", "S/P"], "Resultado": ["NEGATIVO", "POSITIVO", "NO REACTIVO", "REACTIVO", "1/32"],
             "Grupo": ["0", "A", "B", "AB"], "Factor": ["POSITIVO", "NEGATIVO", "+", "-"]}
    if rng.random() < 0.05:
        return None
    if name in pools:
        return rng.choice(pools[name])
    return rng.choice(["NEGATIVO", "NORMAL", "S/P", str(rng.randrange(1, 300)), "VER INFORME"])


# --- Catálogos, precios y el resto del núcleo --------------------------------------------------------

def write_catalogs(box: Box, w: dict) -> None:
    rng = box.rng("catalogos")
    with box.table("Practicas") as t:
        for i, p in enumerate(PRACTICES, start=1):
            t.row(i, p["inos"], p["nbu"], p["nbu2012"], p["desc"].upper(), f"{p['ub']:.2f}")
    with box.table("EquivalenciasCodigos") as t:
        for p in PRACTICES:
            if p["inos"] and rng.random() < 0.7:
                t.row(p["inos"], p["nbu"], p["nbu2012"] if rng.random() < 0.6 else None)
    with box.table("Determinaciones") as t:
        for code, name, unit, *_rest, ref in N.ANALYTES:
            owner = next(c for c, _d, a, _u in N.PRACTICES if code in a)
            t.row(code, name, unit or None, ref, PRACTICE_BY_CODE[owner]["nbu2012"])
    extra = [("IOSFA", "Obra Social de las Fuerzas Armadas"), ("OSPE", "Obra Social de Petroleros"),
             ("MEDIFE", "Medifé"), ("OMINT", "OMINT"), ("ACA", "ACA Salud"), ("PREVENCION", "Prevención Salud"),
             ("OSPJN", "Obra Social del Poder Judicial"), ("OSDEPYM", "OSDEPYM"), ("UP", "Unión Personal"),
             ("JERARQUICOS", "Jerárquicos Salud"), ("FEDERADA", "Federada Salud"), ("OSMATA", "OSMATA"),
             (None, "OBRA SOCIAL SIN SIGLA (VER)")]
    with box.table("ObrasSociales") as t:
        for code, i in PAYER_IDS.items():
            t.row(i, code, N.PAYER_NAMES[code], f"30-{rng.randrange(50_000_000, 71_000_000)}-{rng.randrange(0, 10)}"
                  if code != "PARTICULAR" else None, 1)
        for j, (sigla, name) in enumerate(extra, start=len(PAYER_IDS) + 1):
            t.row(j, sigla, name, None, 1 if rng.random() < 0.6 else 0)
    with box.table("Sedes") as t:
        for code, name, year, _w in N.SITES:
            t.row(code, name, f"{rng.choice(N.STREETS)} {rng.randrange(100, 3000)}", ts(dt.date(year, 3, 1)))
        code, name, year = N.DRIVE_THRU
        t.row(code, name, "ESTACIONAMIENTO CLINICA MEDITERRANEA", ts(dt.date(year, 4, 6)))
    with box.table("Medicos") as t:
        for i in range(1, w["doctors"] + 1):
            sex = rng.random() < 0.55
            first = rng.choice(N.FIRST_FEMALE if sex else N.FIRST_MALE)
            t.row(i, f"{'DRA.' if sex else 'DR.'} {rng.choice(N.LAST)} {first}", f"MP {rng.randrange(8000, 42000)}",
                  rng.choice(["CLINICA MEDICA", "GINECOLOGIA", "PEDIATRIA", "CARDIOLOGIA", "ENDOCRINOLOGIA",
                              "MEDICINA GENERAL", None]), f"0351-4{rng.randrange(100000, 999999)}")


def write_prices(box: Box, w: dict) -> None:
    rng = box.rng("precios")
    for y, m in S.price_months():
        with box.table(f"Precios_{y}_{m:02d}") as t:
            ub = ub_value(y, m)
            for p in PRACTICES:
                if p["code"] == "COVPCR" and y < 2020:
                    continue
                if rng.random() < 0.02:
                    continue                                     # el mes en que alguien la borró
                code = p["inos"] if y < 2006 else (p["nbu"] or p["nbu2012"])
                t.row(code, p["desc"].upper(), money(round(p["ub"] * ub, 2)))
                if rng.random() < 0.01:
                    t.row(code, p["desc"].upper(), money(round(p["ub"] * ub * 1.1, 2)))   # pegada dos veces
    with box.table("Precios") as t:
        for p in PRACTICES:
            for payer, pid in PAYER_IDS.items():
                start = dt.date(2025, rng.randrange(1, 3), 1)
                base = p["ub"] * ub_value(2025, 1) * rng.uniform(0.85, 1.25)
                d = start
                while d.year == 2025 or d <= dt.date(2026, 9, 1):
                    t.row(t.n + 1, p["nbu2012"], pid, money(round(base, 2)), ts(d))
                    if rng.random() < 0.03:                      # dos vigencias el mismo día: ¿cuál vale?
                        t.row(t.n + 1, p["nbu2012"], pid, money(round(base * 1.04, 2)), ts(d))
                    d = (d.replace(day=1) + dt.timedelta(days=rng.randrange(60, 130))).replace(day=1)
                    base *= rng.uniform(1.04, 1.12)


def write_cash(box: Box, w: dict) -> None:
    """Recibos, deudores, folios fiscales y su rechazo, y la tabla de los que hay que llamar."""
    rng = box.rng("caja")
    pv = {code: i for i, (code, *_r) in enumerate(N.SITES + [N.DRIVE_THRU + (0,)], start=1)}
    receipts = []
    with box.table("Recibos") as t:
        for pr in w["protocols"]:
            if pr.payer == "PARTICULAR" and pr.date < dt.date(2015, 7, 1):
                amount = sum(PRACTICE_BY_CODE[c]["ub"] for c in pr.practices) * W_UB(pr.date)
                text = rng.choice([f"$ {amount:.2f}".replace(".", ","), f"{amount:.2f}", str(round(amount)),
                                   f"{amount:.1f}".replace(".", ",")])
                t.row(t.n + 1, ts(pr.date), pr.patient.name, "ANALISIS " + " ".join(pr.practices), text)
                receipts.append((t.n, pr, text))
    with box.table("Deudores") as t:
        for rid, pr, text in receipts:
            if rng.random() < 0.15:
                t.row(t.n + 1, rid, ts(pr.date), pr.patient.name, "ANALISIS", text,
                      rng.choice([text, "0", "", "PAGO PARCIAL"]))
    last: dict[tuple[int, str], int] = {}
    with box.table("Comprobantes") as t, box.table("ComprobantesRechazados") as tr:
        for pr in w["protocols"]:
            if pr.date < dt.date(2015, 7, 1) or (pr.payer != "PARTICULAR" and rng.random() < 0.6):
                continue
            key = (pv[pr.site], "A" if rng.random() < 0.03 else "B")
            n = last.get(key, 0)
            reject = 0.02 if pr.date < dt.date(2015, 8, 1) else 0.0015
            if n and rng.random() < reject:
                when = dt.datetime.combine(pr.date, dt.time(15)) + dt.timedelta(minutes=rng.randrange(0, 180))
                tr.row(tr.n + 1, ts(when), key[0], key[1], n,
                       "10016", f"comp. {n} no coincide con el próximo a autorizar")
            n += 1
            last[key] = n
            amount = sum(PRACTICE_BY_CODE[c]["ub"] for c in pr.practices) * W_UB(pr.date) * rng.uniform(0.1, 1)
            t.row(t.n + 1, key[0], key[1], n, ts(pr.date), pr.protocol_id, pr.patient.patient_id,
                  money(round(amount, 2)), str(rng.randrange(10**13, 10**14)))
    with box.table("UltimoNumero") as t:
        for (point, kind), n in sorted(last.items()):
            t.row(point, kind, n)
    with box.table("ParaLlamar") as t:
        for pr in w["protocols"]:
            age = (pr.date - pr.patient.person.birth).days // 365
            if (pr.date.year < 2013 and rng.random() < 0.3) or (age >= 70 and rng.random() < 0.5):
                two = (rng.random() < 0.3) if pr.date.year >= 2020 else None
                t.row(t.n + 1, ts(pr.date), pr.patient.name, pr.patient.person.phone, pr.protocol_id,
                      1 if rng.random() < 0.95 else 0, None if two is None else int(two))


def write_misc(box: Box, w: dict) -> None:
    rng = box.rng("varios")
    with box.table("Usuarios") as t:
        fixed = [("ruben", "RUBEN BERTOLOTTI", "ADMINISTRACION"), ("matias", "MATIAS LEDESMA", "SISTEMAS"),
                 ("norma", "NORMA CASTELLANI", "DIRECCION TECNICA")]
        for user, name, sector in fixed:
            t.row(user, name, sector, rng.choice(["1234", "alameda", "norma1996", "matias2008"]))
        for i in range(1, 43):
            first = rng.choice(N.FIRST_FEMALE + N.FIRST_MALE)
            t.row(f"{first.lower()}{i}", f"{first} {rng.choice(N.LAST)}",
                  rng.choice(["RECEPCION", "LABORATORIO", "CAJA", "EXTRACCION"]), rng.choice(["1234", "alameda", ""]))
    with box.table("MIG_LIS_PACIENTES") as t:
        for r in w["rows"]:
            if r.since < dt.date(2012, 6, 1) and rng.random() < 0.25:
                parts = r.name.split()
                t.row(900_000 + t.n, parts[0], " ".join(parts[1:3]) or None, r.dni,
                      r.birth_written.strftime("%d/%m/%Y") if r.birth_written else None, r.patient_id)
    with box.table("Configuracion") as t:
        for key, value in [("Version", "4.7.2"), ("RutaEquipos", "\\\\SERVIDOR\\equipos\\entrada"),
                           ("UltimaExportacionPortal", "2026-10-09 09:40"), ("PuntoVentaCentral", "1"),
                           ("ModoMantenimiento", "NO"), ("MailSistemas", "sistemas@alameda.com.ar")]:
            t.row(key, value)
    with box.table("Feriados") as t:
        for y in range(2004, 2027):
            for md, name in [((1, 1), "AÑO NUEVO"), ((3, 24), "DIA DE LA MEMORIA"), ((4, 2), "MALVINAS"),
                             ((5, 1), "DIA DEL TRABAJADOR"), ((5, 25), "REVOLUCION DE MAYO"),
                             ((6, 20), "DIA DE LA BANDERA"), ((7, 9), "DIA DE LA INDEPENDENCIA"),
                             ((12, 8), "INMACULADA CONCEPCION"), ((12, 25), "NAVIDAD")]:
                t.row(ts(dt.date(y, *md)), name)
    for table in (t for t in S.TABLES.values() if t.group == "unknown"):
        with box.table(table.name) as t:
            n = 0 if rng.random() < 0.25 else rng.randrange(1, 400)
            for _ in range(n):
                values = [_unknown_value(rng, c, w) for c in table.exported_columns]
                if values == [None]:
                    values = ["-"]                        # una línea vacía no es una fila en CSV
                t.row(*values)


def _unknown_value(rng, col: S.Column, w: dict):
    if rng.random() < 0.1:
        return None
    if col.tsql.startswith("int"):
        return rng.randrange(1, 200_000)
    if col.tsql.startswith("datetime"):
        return ts(dt.date(rng.randrange(2005, 2026), rng.randrange(1, 13), rng.randrange(1, 29)))
    if col.tsql.startswith("money"):
        return money(rng.uniform(100, 90_000))
    if col.tsql == "bit":
        return rng.randrange(0, 2)
    if col.name in ("Nombre", "Paciente"):
        return rng.choice(w["rows"]).name
    if col.name in ("DNI", "Documento"):
        return rng.choice(w["rows"]).dni
    if col.name == "Sede":
        return rng.choice("CAVJR")
    return rng.choice(["VER", "OK", "PENDIENTE", "COPIA", "NO BORRAR", "x", "PRUEBA MATIAS", "-", "1"])


# --- Lo que no es una tabla de ALAMEDA ---------------------------------------------------------------

def write_appointments(box: Box, w: dict) -> None:
    """El .accdb de turnos exportado a CSV: los exámenes solicitados, separados por punto y coma."""
    rng = box.rng("turnos")
    with box.csv("turnos/Turnos.csv", ["IdTurno", "Fecha", "Hora", "Paciente", "Telefono",
                                       "ExamenesSolicitados", "Estado", "Observaciones"]) as t:
        for pr in w["protocols"]:
            if pr.site == "C" and pr.date.year >= 2008 and rng.random() < 0.3:
                exams = ";".join(PRACTICE_BY_CODE[c]["code"] for c in pr.practices)
                t.row(t.n + 1, pr.date.strftime("%d/%m/%Y"), f"{rng.randrange(7, 11):02d}:{rng.choice(['00', '15', '30', '45'])}",
                      pr.patient.name, pr.patient.person.phone, exams,
                      rng.choice(["ATENDIDO", "ATENDIDO", "ATENDIDO", "AUSENTE", "REPROGRAMADO"]),
                      None if rng.random() < 0.9 else rng.choice(["AYUNO 12 HS", "TRAE ORDEN", "LLAMAR ANTES"]))


def write_files_listing(box: Box, w: dict) -> None:
    """En lugar del terabyte de imágenes y PDF, el listado con el nombre y el tamaño de cada archivo."""
    rng = box.rng("archivos")
    with box.csv("archivos/listado.csv", ["Archivo", "Tipo", "IdProtocolo", "Bytes", "Fecha"]) as t:
        for pr in w["protocols"]:
            if pr.date >= dt.date(2006, 3, 1) and pr.payer != "PARTICULAR" and rng.random() < 0.92:
                if pr.date < W.UPSIZING:
                    size, ext = int(rng.gauss(2_400_000, 400_000)), "bmp"     # OLE de Access, sin comprimir
                else:
                    size, ext = int(rng.gauss(310_000, 90_000)), "jpg"
                t.row(f"ordenes/{pr.date:%Y}/{pr.protocol_id}.{ext}", "ORDEN_ESCANEADA", pr.protocol_id,
                      max(40_000, size), ts(pr.date))
            if pr.date >= dt.date(2013, 5, 1):
                t.row(f"informes/{pr.date:%Y}/{pr.protocol_id}.pdf", "INFORME_PDF", pr.protocol_id,
                      max(20_000, int(rng.gauss(95_000, 30_000))), ts(pr.date))


def write_spreadsheets(box: Box, w: dict) -> None:
    rng = box.rng("planillas")
    people = w["people"]
    for payer in ("PAMI", "APROSS", "OSDE"):
        rows = []
        for p in people:
            if p.payer == payer and p.member_number and rng.random() < 0.93:
                doc_type = "DNI" if p.doc_type in ("DNI", "LC", "LE") and rng.random() < 0.8 else p.doc_type
                rows.append([p.member_number, p.last, p.first, doc_type, p.dni_later or p.doc_number,
                             p.birth.strftime("%d/%m/%Y"), rng.choice(["A", "B", "210", "310", "GENERAL"])])
        box.counts[f"planillas/padron_{payer.lower()}.xlsx"] = xlsx.write(
            box.path(f"planillas/padron_{payer.lower()}.xlsx"), "Padron",
            ["NroAfiliado", "Apellido", "Nombre", "TipoDoc", "NroDoc", "FechaNac", "Plan"], rows)
    box.counts["planillas/nbu.xlsx"] = xlsx.write(
        box.path("planillas/nbu.xlsx"), "NBU 2012", ["Codigo", "Practica", "UB"],
        [[p["nbu2012"], p["desc"].upper(), p["ub"]] for p in PRACTICES])
    # Convenios: la regla es cíclica (D39). Si un pagador cubre una práctica, la sede hace esa práctica
    # y la sede atiende a ese pagador, entonces el convenio existe para los tres.
    sites = [s for s, *_ in N.SITES]
    covers = {(pa, pr["code"]) for pa in N.PAYERS if pa != "PARTICULAR" for pr in PRACTICES if rng.random() < 0.75}
    offers = {(pr["code"], s) for pr in PRACTICES for s in sites if s == "C" or rng.random() < 0.55}
    accepts = {(pa, s) for pa in N.PAYERS if pa != "PARTICULAR" for s in sites if s == "C" or rng.random() < 0.7}
    rows = sorted([pa, PRACTICE_BY_CODE[pr]["nbu2012"], s] for (pa, pr) in covers for (pr2, s) in offers
                  if pr2 == pr and (pa, s) in accepts)
    box.counts["planillas/convenios_2026.xlsx"] = xlsx.write(
        box.path("planillas/convenios_2026.xlsx"), "Convenios", ["ObraSocial", "Practica", "Sede"], rows)
    covid = [[pr.date.strftime("%d/%m/%Y"), pr.patient.name, pr.patient.dni,
              (pr.date - pr.patient.person.birth).days // 365, rng.choice(["NEGATIVO"] * 3 + ["POSITIVO"]),
              pr.patient.person.address, pr.site]
             for pr in w["protocols"] if pr.practices == ("COVPCR",)]
    box.counts["planillas/notificacion_covid.xlsx"] = xlsx.write(
        box.path("planillas/notificacion_covid.xlsx"), "Hoja1",
        ["Fecha", "Apellido y Nombre", "DNI", "Edad", "Resultado", "Domicilio", "Sede"], covid)
