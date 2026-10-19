"""Fase 20 · carga los 50.000 protocolos de la muestra en MongoDB, como documentos (la propuesta de Florencia).

Un documento por protocolo. Los resultados van embebidos (acotados: unos 10 o 20 por protocolo) y cada resultado
lleva sus correcciones embebidas (acotadas: como mucho una por resultado en esta muestra). El paciente va como
resumen (id, sexo, nacimiento), porque la lectura del informe lo pide junto y porque su historia vive en `patient`.
El validador `$jsonSchema` pone la forma; lo que no pone (que el analito exista en el nomenclador) queda fuera.

Uso (desde ruta-sql/src, con el perfil mongo levantado):
    uv run --with pymongo python 20-la-propuesta-de-florencia/02_cargar_mongo.py
"""

import datetime as dt
from collections import defaultdict

import psycopg
from pymongo import MongoClient

from lab import config

MONGO_URL = "mongodb://127.0.0.1:27027"
DB = "alameda"
COLL = "protocolos"

SCHEMA = {
    "bsonType": "object",
    "required": ["_id", "ordered_on", "site", "payer", "patient", "results"],
    "properties": {
        "ordered_on": {"bsonType": "date"},
        "payer": {"bsonType": "object", "required": ["code"]},
        "patient": {"bsonType": "object", "required": ["id", "sex"]},
        "results": {
            "bsonType": "array",
            "items": {
                "bsonType": "object",
                "required": ["analyte", "recorded_at"],
                "properties": {
                    "analyte": {"bsonType": "string"},
                    "value": {"bsonType": ["double", "int", "decimal", "null"]},
                    "corrections": {"bsonType": "array"},
                },
            },
        },
    },
}


def dates(d):
    return dt.datetime(d.year, d.month, d.day) if d else None


def main() -> None:
    client = MongoClient(MONGO_URL)
    db = client[DB]
    db.drop_collection(COLL)
    db.create_collection(COLL, validator={"$jsonSchema": SCHEMA})

    with psycopg.connect(**config.POSTGRES) as pg:
        corrections = defaultdict(list)
        with pg.cursor() as cur:
            cur.execute("""SELECT result_id, changed_at, changed_by, old_value, reason
                           FROM staging.f20_correction ORDER BY correction_id""")
            for result_id, changed_at, by, old, reason in cur:
                corrections[result_id].append({"changed_at": changed_at, "by": by, "old_value": old, "reason": reason})

        with pg.cursor() as cur:
            cur.execute("SELECT lab_order_id, ordered_on, site_code, payer_code, patient_id, sex, birth_date FROM staging.f20_order")
            orders = {r[0]: {"_id": r[0], "ordered_on": dates(r[1]), "site": r[2].strip(), "payer": {"code": r[3]},
                             "patient": {"id": r[4], "sex": (r[5] or "").strip() or None, "birth_date": dates(r[6])},
                             "results": []} for r in cur}

        with pg.cursor() as cur:
            cur.execute("""SELECT result_id, lab_order_id, analyte_code, analyte_name, unit, reference_range,
                                  value_numeric, qualifier, value_text, sample_flag, recorded_at
                           FROM staging.f20_result ORDER BY result_id""")
            for rid, oid, code, name, unit, rng, num, qual, text, flag, rec in cur:
                item = {"result_id": rid, "analyte": code, "name": name, "unit": unit, "range": rng,
                        "value": float(num) if num is not None else None, "qualifier": qual, "text": text,
                        "flag": flag, "recorded_at": rec}
                if rid in corrections:
                    item["corrections"] = corrections[rid]
                orders[oid]["results"].append(item)

    coll = db[COLL]
    batch = []
    for doc in orders.values():
        batch.append(doc)
        if len(batch) == 2000:
            coll.insert_many(batch, ordered=False)
            batch = []
    if batch:
        coll.insert_many(batch, ordered=False)

    coll.create_index("payer.code")
    print(f"protocolos: {coll.estimated_document_count()}")
    print(f"tamaño medio del documento (bytes): {db.command('collStats', COLL)['avgObjSize']}")


if __name__ == "__main__":
    main()
