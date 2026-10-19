"""Fase 20 · soluciones ejecutables de los ejercicios 1–16. Corre después de 01–03 y de la carga de Mongo.

Las pruebas que escriben usan una colección `protocolos_prueba` y tablas `staging.ex20_*`, que se borran al final.
Los ejercicios 17–26 tienen rúbrica en el solucionario y no se ejecutan aquí.

    uv run --with pymongo python 20-la-propuesta-de-florencia/05_ejercicios.py
"""

import datetime as dt
import json
import statistics
import time

import psycopg
from pymongo import MongoClient
from pymongo.errors import WriteError

from lab import config

M = MongoClient("mongodb://127.0.0.1:27027")["alameda"]
PROT = M["protocolos"]
PG = psycopg.connect(**config.POSTGRES, autocommit=True)


def explain_docs(pipeline):
    exp = M.command("explain", {"aggregate": "protocolos", "pipeline": pipeline, "cursor": {}},
                    verbosity="executionStats")
    stage = exp["stages"][0]
    if "$cursor" in stage:
        return stage["$cursor"]["executionStats"]["totalDocsExamined"]
    return exp["executionStats"]["totalDocsExamined"]


def ex(n, title):
    print(f"\n### Ejercicio {n} — {title}")


ORDER = PG.execute("SELECT min(lab_order_id) FROM staging.f20_order").fetchone()[0]

# 1. Un protocolo como documento: los campos del informe de la muestra.
ex(1, "un protocolo como documento")
doc = PROT.find_one({"_id": ORDER})
print("campos de primer nivel:", sorted(doc.keys()))
print("resultados:", len(doc["results"]), "· campos del primer resultado:", len(doc["results"][0]))

# 2. El validador rechaza un documento sin `payer`.
ex(2, "el validador de forma")
try:
    PROT.insert_one({"_id": -1, "ordered_on": dt.datetime(2025, 1, 1), "site": "A",
                     "patient": {"id": 1, "sex": "F"}, "results": []})
    print("aceptado (inesperado)")
except WriteError as e:
    print("rechazado:", e.details.get("errmsg", str(e))[:160])

# 3. Protocolos por obra social, en Mongo y en Postgres.
ex(3, "protocolos por pagador")
mongo_counts = {r["_id"]: r["n"] for r in PROT.aggregate([{"$group": {"_id": "$payer.code", "n": {"$sum": 1}}}])}
pg_counts = dict(PG.execute("SELECT payer_code, count(*) FROM staging.f20_order GROUP BY 1").fetchall())
print("mongo:", dict(sorted(mongo_counts.items())))
print("postgres coincide:", mongo_counts == pg_counts)

# 4. El índice sobre payer.code existe y el plan lo usa.
ex(4, "índice simple sobre payer.code")
print("índices:", [i["name"] for i in PROT.list_indexes()])
plan = PROT.find({"payer.code": "PAMI"}).explain()
stats = plan["executionStats"]
print("PAMI: documentos devueltos", stats["nReturned"], "· examinados", stats["totalDocsExamined"])

# 5. Lectura de un informe, cinco veces, mediana (ver 04_medir.py para la tabla completa).
ex(5, "lectura de un informe")
samples = []
for _ in range(5):
    t0 = time.perf_counter()
    PROT.find_one({"_id": ORDER})
    samples.append((time.perf_counter() - t0) * 1000)
print(f"mediana M: {statistics.median(samples):.2f} ms")

# 6. Tamaño de un documento: BSON en Mongo y jsonb en Postgres.
ex(6, "tamaño de un documento")
bson = M.command("collStats", "protocolos")["avgObjSize"]
jsonb = PG.execute("SELECT round(avg(pg_column_size(doc))) FROM staging.f20_doc_jsonb").fetchone()[0]
print(f"BSON medio en Mongo: {bson} bytes · jsonb medio en Postgres: {int(jsonb)} bytes")
print("La diferencia es de codificación binaria; no se desarma aquí.")

# 7. Protocolos sin resultados.
ex(7, "arreglos vacíos")
vacios = PG.execute("SELECT count(*) FROM staging.f20_doc_jsonb WHERE jsonb_array_length(doc->'results') = 0").fetchone()[0]
print("protocolos sin resultados:", vacios)
if vacios:
    print("forma en jsonb: 'results': []  (el COALESCE de 03_jsonb.sql lo deja así)")
else:
    print("ningún protocolo de la muestra tiene resultados vacíos; el COALESCE de 03_jsonb.sql queda como defensa")

# 8. Una corrección con $push, comprobada.
ex(8, "agregar una corrección")
rid = doc["results"][0]["result_id"]
PROT.update_one({"_id": ORDER, "results.result_id": rid},
                {"$push": {"results.$.corrections": {"changed_at": dt.datetime(2025, 1, 20), "by": "bio_norma",
                                                     "old_value": "x", "reason": "ejercicio 8"}}})
after = next(e for e in PROT.find_one({"_id": ORDER})["results"] if e["result_id"] == rid)
print("correcciones del resultado:", [c["reason"] for c in after["corrections"]][-1:])

# 9. El cruce con $match antes y después de $unwind: los documentos examinados.
ex(9, "el $match antes y después del $unwind")
after_unwind = [{"$unwind": "$results"}, {"$match": {"results.analyte": "GLU"}}, {"$count": "n"}]
before_unwind = [{"$match": {"results.analyte": "GLU"}}, {"$unwind": "$results"},
                 {"$match": {"results.analyte": "GLU"}}, {"$count": "n"}]
print("filtro después del unwind: documentos examinados", explain_docs(after_unwind))
print("filtro antes del unwind:   documentos examinados", explain_docs(before_unwind))

# 10. Un multikey sobre results.analyte: ¿lo usa cada pipeline?
ex(10, "el multikey según la posición del $match")
PROT.create_index([("results.analyte", 1)], name="ix_ex10")
print("con índice, filtro después:", explain_docs(after_unwind), "· con índice, filtro antes:", explain_docs(before_unwind))
PROT.drop_index("ix_ex10")

# 11. La auditoría con y sin el índice multikey de correcciones.
ex(11, "auditoría con y sin índice multikey")
pipe = [{"$match": {"results.corrections.changed_at": {"$gte": dt.datetime(2025, 1, 10), "$lt": dt.datetime(2025, 1, 17)}}},
        {"$unwind": "$results"}, {"$unwind": "$results.corrections"},
        {"$match": {"results.corrections.changed_at": {"$gte": dt.datetime(2025, 1, 10), "$lt": dt.datetime(2025, 1, 17)}}},
        {"$count": "n"}]
print("sin índice:", explain_docs(pipe))
PROT.create_index([("results.corrections.changed_at", 1)], name="ix_ex11")
print("con índice:", explain_docs(pipe))
PROT.drop_index("ix_ex11")

# 12. La corrección de O2 en Postgres, con y sin transacción explícita (cinco corridas, mediana).
ex(12, "transacción explícita en la corrección")
RID = PG.execute("SELECT result_id FROM staging.f20_result WHERE lab_order_id = %s LIMIT 1", (ORDER,)).fetchone()[0]


def sin_tx():
    PG.execute("UPDATE staging.f20_result SET value_numeric = value_numeric + 0.1 WHERE result_id = %s", (RID,))
    PG.execute("UPDATE staging.f20_result SET value_numeric = value_numeric - 0.1 WHERE result_id = %s", (RID,))


def con_tx():
    with PG.transaction():
        PG.execute("UPDATE staging.f20_result SET value_numeric = value_numeric + 0.1 WHERE result_id = %s", (RID,))
        PG.execute("UPDATE staging.f20_result SET value_numeric = value_numeric - 0.1 WHERE result_id = %s", (RID,))


for name, fn in (("autocommit, dos sentencias", sin_tx), ("transacción explícita", con_tx)):
    fn()
    s = []
    for _ in range(5):
        t0 = time.perf_counter()
        fn()
        s.append((time.perf_counter() - t0) * 1000)
    print(f"{name}: mediana {statistics.median(s):.2f} ms")
print("Con autocommit, dos sentencias pueden dejar la historia a medias si la segunda falla. La transacción no cambia el tiempo de forma medible y garantiza las dos juntas.")

# 13. WAL de corregir un resultado en un documento de cinco resultados (jsonb).
ex(13, "WAL de una corrección en jsonb")
PG.execute("CHECKPOINT")
doc5 = PG.execute("SELECT lab_order_id, doc FROM staging.f20_doc_jsonb WHERE jsonb_array_length(doc->'results') >= 5 LIMIT 1").fetchone()
PG.execute("CREATE TABLE IF NOT EXISTS staging.ex20_doc AS SELECT * FROM staging.f20_doc_jsonb WHERE false")
PG.execute("DELETE FROM staging.ex20_doc")
PG.execute("INSERT INTO staging.ex20_doc SELECT * FROM staging.f20_doc_jsonb WHERE lab_order_id = %s", (doc5[0],))
PG.execute("ALTER TABLE staging.ex20_doc ADD PRIMARY KEY (lab_order_id)")
PG.execute("CHECKPOINT")
for i in range(4):
    before = PG.execute("SELECT pg_current_wal_insert_lsn()").fetchone()[0]
    PG.execute("UPDATE staging.ex20_doc SET doc = jsonb_set(doc, '{results,0,value}', to_jsonb((%s)::numeric)) WHERE lab_order_id = %s",
               (str(10 + i), doc5[0]))
    after = PG.execute("SELECT pg_current_wal_insert_lsn()").fetchone()[0]
    wal = PG.execute("SELECT pg_wal_lsn_diff(%s, %s)", (after, before)).fetchone()[0]
    print(f"corrida {i + 1}: {int(wal)} bytes de WAL")
PG.execute("DROP TABLE staging.ex20_doc")

# 14. Prosa: el resumen del paciente que envejece. Se responde en el solucionario.
ex(14, "el resumen que envejece (prosa)")
print("Ver solucionario: la respuesta es una lista de documentos, no un número.")

# 15. O3 con y sin el índice de pagador.
ex(15, "O3 con y sin índice de pagador")
sql_o3 = """SELECT r.analyte_code, count(*) FROM staging.f20_order o JOIN staging.f20_result r USING (lab_order_id)
            WHERE o.payer_code = 'PAMI' AND o.ordered_on >= '2025-01-01' AND o.ordered_on < '2025-02-01' GROUP BY 1"""
PG.execute("DROP INDEX IF EXISTS staging.f20_order_payer")
t0 = time.perf_counter(); PG.execute(sql_o3).fetchall(); print(f"R sin índice: {(time.perf_counter() - t0) * 1000:.2f} ms")
PG.execute("CREATE INDEX f20_order_payer ON staging.f20_order (payer_code, ordered_on)")
t0 = time.perf_counter(); PG.execute(sql_o3).fetchall(); print(f"R con índice: {(time.perf_counter() - t0) * 1000:.2f} ms")
for idx in PROT.list_indexes():
    if idx["key"] == {"payer.code": 1}:
        PROT.drop_index(idx["name"])
def docs_de_find():
    st = PROT.find({"payer.code": "PAMI"}).explain()["executionStats"]
    return st["nReturned"], st["totalDocsExamined"]


print("M sin índice de payer (devueltos, examinados):", docs_de_find())
PROT.create_index([("payer.code", 1)], name="payer.code_1")
print("M con índice de payer (devueltos, examinados):", docs_de_find())

# 16. El validador acepta un analito que no existe en el nomenclador.
ex(16, "el validador que no valida la existencia")
PROT.insert_one({"_id": -2, "ordered_on": dt.datetime(2025, 1, 1), "site": "A", "payer": {"code": "PAMI"},
                 "patient": {"id": 1, "sex": "F"}, "results": [{"analyte": "ANALITO_INEXISTENTE", "recorded_at": dt.datetime(2025, 1, 1)}]})
print("aceptado: el validador solo mira la forma, no el nomenclador")
PROT.delete_one({"_id": -2})

# Limpieza
PG.execute("DROP TABLE IF EXISTS staging.ex20_doc")
print("\nLimpieza hecha.")
