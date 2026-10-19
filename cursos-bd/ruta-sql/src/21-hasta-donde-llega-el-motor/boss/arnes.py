"""💀 Boss IV · el arnés: cinco criterios. Corre desde ruta-sql/src con el laboratorio arriba y la fase 20 cargada.

    uv run python 21-hasta-donde-llega-el-motor/boss/arnes.py [ruta/al/informe.py]

Por defecto evalúa `informe.py` de este directorio. Sale con código 0 solo si pasan los cinco criterios.
"""

import importlib.util
from decimal import Decimal
import pathlib
import statistics
import sys
import time

import psycopg

from lab import config

ruta = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path(__file__).with_name("informe.py")
spec = importlib.util.spec_from_file_location("informe", ruta)
informe = importlib.util.module_from_spec(spec)
spec.loader.exec_module(informe)

PG = psycopg.connect(**config.POSTGRES, autocommit=True)
resultados = {}


def criterio(n, nombre, fn):
    try:
        ok, detalle = fn()
    except Exception as e:  # un criterio que falla por excepción también cuenta como rojo
        ok, detalle = False, f"excepción: {type(e).__name__}: {str(e)[:100]}"
    resultados[n] = ok
    print(f"{'✅' if ok else '❌'} C{n} · {nombre}: {detalle}")


def c1():
    ids = informe.buscar_paciente("RODRIGES CAMILA")
    return (1 in ids), f"con el error de tipeo 'RODRIGES CAMILA' aparecen {len(ids)} pacientes; el 1 (RODRIGUEZ CAMILA) {'sí' if 1 in ids else 'no'}"


def c2():
    tiempos = []
    for _ in range(5):
        t0 = time.perf_counter()
        informe.buscar_paciente("PEREZ")
        tiempos.append((time.perf_counter() - t0) * 1000)
    mediana = statistics.median(tiempos)
    return mediana < 10, f"mediana {mediana:.1f} ms sobre 5 búsquedas de 'PEREZ' (límite: 10 ms)"


def c3():
    orden = PG.execute("SELECT lab_order_id FROM staging.f20_order ORDER BY lab_order_id LIMIT 1").fetchone()[0]
    doc = informe.leer_informe(orden)
    fuente = dict(PG.execute("SELECT result_id, value_numeric FROM staging.f20_result WHERE lab_order_id = %s", (orden,)).fetchall())
    # La fuente guarda numeric con 4 decimales; el documento, un número JSON. Se compara a 4 decimales:
    # un documento que se escribió desde float (9,699999999999996) tiene el mismo valor que la fuente (9,7000).
    en_doc = {e["result_id"]: (Decimal(str(e["value"])).quantize(Decimal("0.0001")) if e.get("value") is not None else None)
              for e in doc["results"]}
    iguales = all(en_doc.get(k) == (v.quantize(Decimal("0.0001")) if v is not None else None) for k, v in fuente.items())
    return iguales and len(en_doc) == len(fuente), f"{len(fuente)} resultados en la fuente, {len(en_doc)} en el documento, {'iguales' if iguales else 'distintos'}"


def _resultado_de_prueba():
    return PG.execute("SELECT result_id, lab_order_id FROM staging.f20_result ORDER BY result_id LIMIT 1").fetchone()


def c4():
    rid, oid = _resultado_de_prueba()
    antes = PG.execute("SELECT count(*) FROM staging.f20_correction WHERE result_id = %s", (rid,)).fetchone()[0]
    informe.corregir(rid, 123.4, "bio_prueba", "boss IV, C4")
    fuente = PG.execute("SELECT value_numeric FROM staging.f20_result WHERE result_id = %s", (rid,)).fetchone()[0]
    despues = PG.execute("SELECT count(*) FROM staging.f20_correction WHERE result_id = %s", (rid,)).fetchone()[0]
    doc = informe.leer_informe(oid)
    en_doc = next(e for e in doc["results"] if e["result_id"] == rid)
    doc_val = Decimal(str(en_doc["value"])).quantize(Decimal("0.0001"))
    ok = Decimal(fuente).quantize(Decimal("0.0001")) == Decimal("123.4000") and despues == antes + 1 \
        and doc_val == Decimal("123.4000") and len(en_doc.get("corrections", [])) >= 1
    return ok, f"fuente {fuente}, auditoría {antes}→{despues}, documento {doc_val}"


def c5():
    rid, _ = _resultado_de_prueba()
    antes = PG.execute("SELECT value_numeric FROM staging.f20_result WHERE result_id = %s", (rid,)).fetchone()[0]
    try:
        informe.corregir(rid, 999.9, None, "boss IV, C5: sin usuario")
        fallo = False
    except Exception:
        fallo = True
    despues = PG.execute("SELECT value_numeric FROM staging.f20_result WHERE result_id = %s", (rid,)).fetchone()[0]
    ok = fallo and despues == antes
    return ok, f"la corrección inválida {'falló' if fallo else 'no falló'}; la fuente {'quedó igual' if despues == antes else 'cambió a ' + str(despues)}"


criterio(1, "la búsqueda tolera un error de tipeo", c1)
criterio(2, "la búsqueda responde en menos de 10 ms", c2)
criterio(3, "el informe leído es igual a la fuente", c3)
criterio(4, "una corrección deja fuente, auditoría y documento de acuerdo", c4)
criterio(5, "una corrección inválida no cambia nada", c5)

pasan = sum(resultados.values())
print(f"\n{pasan} de 5 criterios pasan.")
sys.exit(0 if pasan == 5 else 1)
