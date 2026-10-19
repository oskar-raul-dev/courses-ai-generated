"""Fase 20 · las cinco operaciones de la ficha, en los tres diseños, con el mismo perfil de datos.

  R  relacional con proyección: el modelo de F03–F08 (lab_order, result, correction) armado con json_agg al leer.
  J  documento jsonb en Postgres (03_jsonb.sql), con los mismos índices que Mongo.
  M  documento en MongoDB (02_cargar_mongo.py), la propuesta de Florencia.

Cada operación se corre una vez de calentamiento y cinco veces; se reporta la mediana. Lo que se mide además:
bloques leídos en Postgres (EXPLAIN BUFFERS) y documentos examinados en Mongo (executionStats), donde aplica.
Las operaciones de escritura van al final: corrigen un resultado y dejan una corrección más en la historia.

Uso (desde ruta-sql/src, con POSTGRES_PORT y el perfil mongo levantados):
    uv run --with pymongo python 20-la-propuesta-de-florencia/04_medir.py
"""

import datetime as dt
import json
import statistics
import time

import psycopg
from pymongo import MongoClient

from lab import config

RUNS = 5
MONGO = MongoClient("mongodb://127.0.0.1:27027")
DB = MONGO["alameda"]
PROT = DB["protocolos"]
PG = psycopg.connect(**config.POSTGRES, autocommit=True)


def timed(fn):
    fn()  # calentamiento
    samples = []
    out = None
    for _ in range(RUNS):
        t0 = time.perf_counter()
        out = fn()
        samples.append((time.perf_counter() - t0) * 1000)
    return statistics.median(samples), out


def blocks(sql, params=()):
    row = PG.execute("EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) " + sql, params).fetchone()[0]
    plan = row[0]["Plan"]

    def walk(n):
        total = n.get("Shared Hit Blocks", 0) + n.get("Shared Read Blocks", 0)
        return total + sum(walk(c) for c in n.get("Plans", []))
    return walk(plan)


def mongo_docs(pipeline):
    exp = DB.command("explain", {"aggregate": "protocolos", "pipeline": pipeline, "cursor": {}},
                     verbosity="executionStats")
    stage = exp["stages"][0]
    if "$cursor" in stage:
        return stage["$cursor"]["executionStats"]["totalDocsExamined"]
    return exp["executionStats"]["totalDocsExamined"]


# --- Los datos de las operaciones: el mismo protocolo, la misma obra social, el mismo mes ---------------------

ORDER = PG.execute("SELECT min(lab_order_id) FROM staging.f20_order").fetchone()[0]
RESULT = PG.execute("SELECT min(result_id) FROM staging.f20_result WHERE lab_order_id = %s", (ORDER,)).fetchone()[0]
PAYER = "PAMI"
JAN = (dt.datetime(2025, 1, 1), dt.datetime(2025, 2, 1))
WEEK = (dt.datetime(2025, 1, 10), dt.datetime(2025, 1, 17))
ANALYTE = "GLU"
THRESHOLD = 126

rows = []


def row(op, design, median_ms, cost):
    rows.append((op, design, round(median_ms, 2), cost))
    print(f"{op:<28} {design:<4} {round(median_ms, 2):>9} ms   {cost}")


# --- O1 · Leer el informe completo de un protocolo ----------------------------------------------------------

sql_r1 = """
SELECT json_build_object('id', o.lab_order_id, 'results', json_agg(json_build_object(
         'analyte', r.analyte_code, 'value', r.value_numeric,
         'corrections', (SELECT json_agg(json_build_object('at', k.changed_at, 'by', k.changed_by)) FROM staging.f20_correction k WHERE k.result_id = r.result_id))))
FROM staging.f20_order o JOIN staging.f20_result r USING (lab_order_id)
WHERE o.lab_order_id = %s GROUP BY o.lab_order_id"""

ms, _ = timed(lambda: PG.execute(sql_r1, (ORDER,)).fetchone())
row("O1 leer el informe", "R", ms, f"{blocks(sql_r1, (ORDER,))} bloques")

ms, _ = timed(lambda: PG.execute("SELECT doc FROM staging.f20_doc_jsonb WHERE lab_order_id = %s", (ORDER,)).fetchone())
row("O1 leer el informe", "J", ms, f"{blocks('SELECT doc FROM staging.f20_doc_jsonb WHERE lab_order_id = %s', (ORDER,))} bloques")

ms, _ = timed(lambda: PROT.find_one({"_id": ORDER}))
row("O1 leer el informe", "M", ms, "1 documento")

# --- O3 · Presentación a la obra social: los resultados de un pagador en un mes ----------------------------

sql_r3 = """
SELECT r.analyte_code, count(*) FROM staging.f20_order o JOIN staging.f20_result r USING (lab_order_id)
WHERE o.payer_code = %s AND o.ordered_on >= %s AND o.ordered_on < %s GROUP BY 1"""
ms, _ = timed(lambda: PG.execute(sql_r3, (PAYER, *JAN)).fetchall())
row("O3 presentación", "R", ms, f"{blocks(sql_r3, (PAYER, *JAN))} bloques")

sql_j3 = """
SELECT e->>'analyte', count(*) FROM staging.f20_doc_jsonb d, jsonb_array_elements(d.doc->'results') e
WHERE d.doc->'payer'->>'code' = %s AND (d.doc->>'ordered_on')::timestamp >= %s AND (d.doc->>'ordered_on')::timestamp < %s
GROUP BY 1"""
ms, _ = timed(lambda: PG.execute(sql_j3, (PAYER, *JAN)).fetchall())
row("O3 presentación", "J", ms, f"{blocks(sql_j3, (PAYER, *JAN))} bloques")

pipe3 = [{"$match": {"payer.code": PAYER, "ordered_on": {"$gte": JAN[0], "$lt": JAN[1]}}},
         {"$unwind": "$results"}, {"$group": {"_id": "$results.analyte", "n": {"$sum": 1}}}]
ms, _ = timed(lambda: list(PROT.aggregate(pipe3)))
row("O3 presentación", "M", ms, f"{mongo_docs(pipe3)} documentos examinados")

# --- O4 · Cruce epidemiológico ad hoc: glucemia por encima de 126, por sexo -------------------------------

sql_r4 = """
SELECT o.sex, count(*) FILTER (WHERE r.value_numeric >= %s) AS altas, count(*) AS total
FROM staging.f20_order o JOIN staging.f20_result r USING (lab_order_id)
WHERE r.analyte_code = %s GROUP BY o.sex"""
ms, _ = timed(lambda: PG.execute(sql_r4, (THRESHOLD, ANALYTE)).fetchall())
row("O4 cruce ad hoc", "R", ms, f"{blocks(sql_r4, (THRESHOLD, ANALYTE))} bloques")

sql_j4 = """
SELECT d.doc->'patient'->>'sex', count(*) FILTER (WHERE (e->>'value')::numeric >= %s), count(*)
FROM staging.f20_doc_jsonb d, jsonb_array_elements(d.doc->'results') e
WHERE e->>'analyte' = %s GROUP BY 1"""
ms, _ = timed(lambda: PG.execute(sql_j4, (THRESHOLD, ANALYTE)).fetchall())
row("O4 cruce ad hoc", "J", ms, f"{blocks(sql_j4, (THRESHOLD, ANALYTE))} bloques")

pipe4 = [{"$match": {"results.analyte": ANALYTE}}, {"$unwind": "$results"}, {"$match": {"results.analyte": ANALYTE}},
         {"$group": {"_id": "$patient.sex", "altas": {"$sum": {"$cond": [{"$gte": ["$results.value", THRESHOLD]}, 1, 0]}},
                     "total": {"$sum": 1}}}]
ms, _ = timed(lambda: list(PROT.aggregate(pipe4)))
row("O4 cruce ad hoc", "M", ms, f"{mongo_docs(pipe4)} documentos examinados (sin índice multikey)")

# --- O5 · Auditoría: quién corrigió qué en una semana ----------------------------------------------------------

sql_r5 = """
SELECT changed_by, count(*) FROM staging.f20_correction WHERE changed_at >= %s AND changed_at < %s GROUP BY 1"""
ms, _ = timed(lambda: PG.execute(sql_r5, WEEK).fetchall())
row("O5 auditoría", "R", ms, f"{blocks(sql_r5, WEEK)} bloques")

sql_j5 = """
SELECT c->>'by', count(*) FROM staging.f20_doc_jsonb d, jsonb_array_elements(d.doc->'results') e,
     jsonb_array_elements(coalesce(e->'corrections', '[]'::jsonb)) c
WHERE (c->>'changed_at')::timestamp >= %s AND (c->>'changed_at')::timestamp < %s GROUP BY 1"""
ms, _ = timed(lambda: PG.execute(sql_j5, WEEK).fetchall())
row("O5 auditoría", "J", ms, f"{blocks(sql_j5, WEEK)} bloques")

pipe5 = [{"$match": {"results.corrections.changed_at": {"$gte": WEEK[0], "$lt": WEEK[1]}}},
         {"$unwind": "$results"}, {"$unwind": "$results.corrections"},
         {"$match": {"results.corrections.changed_at": {"$gte": WEEK[0], "$lt": WEEK[1]}}},
         {"$group": {"_id": "$results.corrections.by", "n": {"$sum": 1}}}]
ms, _ = timed(lambda: list(PROT.aggregate(pipe5)))
row("O5 auditoría", "M", ms, f"{mongo_docs(pipe5)} documentos examinados (sin índice multikey)")

# --- O5 con índice multikey: lo que Mongo gana, y lo que cuesta ------------------------------------------------

PROT.create_index([("results.corrections.changed_at", 1)], name="ix_corr_changed")
ms, _ = timed(lambda: list(PROT.aggregate(pipe5)))
row("O5 auditoría", "M+ix", ms, f"{mongo_docs(pipe5)} documentos examinados (con índice multikey)")
PROT.drop_index("ix_corr_changed")

PROT.create_index([("results.analyte", 1)], name="ix_analyte")
ms, _ = timed(lambda: list(PROT.aggregate(pipe4)))
row("O4 cruce ad hoc", "M+ix", ms, f"{mongo_docs(pipe4)} documentos examinados (con índice multikey)")
PROT.drop_index("ix_analyte")

# --- O2 · Corregir un resultado (escritura: va al final) -------------------------------------------------------
# Una corrección nueva por corrida, sobre el mismo resultado. Los tres diseños dejan la misma historia.

def correct_r():
    with PG.transaction():
        PG.execute("UPDATE staging.f20_result SET value_numeric = value_numeric + 0.1 WHERE result_id = %s", (RESULT,))
        PG.execute("""INSERT INTO staging.f20_correction (correction_id, result_id, lab_order_id, analyte_code, changed_at, changed_by, old_value, reason)
                      SELECT coalesce(max(correction_id), 0) + 1, %s, %s, 'GLU', now(), 'bio_norma', 'x', 'prueba de F20'
                      FROM staging.f20_correction""", (RESULT, ORDER))


ms, _ = timed(correct_r)
row("O2 corregir resultado", "R", ms, "2 sentencias en una transacción")


def correct_j():
    doc = PG.execute("SELECT doc FROM staging.f20_doc_jsonb WHERE lab_order_id = %s", (ORDER,)).fetchone()[0]
    i = next(k for k, e in enumerate(doc["results"]) if e["result_id"] == RESULT)
    e = doc["results"][i]
    e["value"] = (e.get("value") or 0) + 0.1
    e.setdefault("corrections", []).append({"changed_at": dt.datetime.now().isoformat(), "by": "bio_norma",
                                            "old_value": "x", "reason": "prueba de F20"})
    PG.execute("UPDATE staging.f20_doc_jsonb SET doc = %s WHERE lab_order_id = %s", (json.dumps(doc), ORDER))


ms, _ = timed(correct_j)
row("O2 corregir resultado", "J", ms, "leer, modificar, reescribir el documento")


def correct_m():
    PROT.update_one({"_id": ORDER, "results.result_id": RESULT},
                    {"$inc": {"results.$.value": 0.1},
                     "$push": {"results.$.corrections": {"changed_at": dt.datetime.now(), "by": "bio_norma",
                                                         "old_value": "x", "reason": "prueba de F20"}}})


ms, _ = timed(correct_m)
row("O2 corregir resultado", "M", ms, "1 actualización con operador posicional")

print("\nCorrecciones acumuladas en el resultado de la prueba:",
      PG.execute("SELECT count(*) FROM staging.f20_correction WHERE result_id = %s", (RESULT,)).fetchone()[0],
      "en R;", len(next(e for e in PROT.find_one({"_id": ORDER})["results"] if e["result_id"] == RESULT).get("corrections", [])),
      "en M")
