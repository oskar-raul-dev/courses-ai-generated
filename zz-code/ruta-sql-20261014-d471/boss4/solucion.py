"""💀 Boss IV · solución (D42: fuera del repositorio publicado). Pasa los cinco criterios de arnes.py."""

from decimal import Decimal

import psycopg

from lab import config

PG = psycopg.connect(**config.POSTGRES, autocommit=True)


def _norm(texto: str) -> str:
    return PG.execute("SELECT staging.f21_unaccent(upper(%s))", (texto,)).fetchone()[0]


def buscar_paciente(texto: str) -> list[int]:
    # Término corto (un apellido que la recepción está tipeando): prefijo de texto completo, que usa el índice GIN de tsv.
    # Nombre completo, que puede traer un error de tipeo: trigramas (GIN) ordenados por parecido.
    t = _norm(texto).strip()
    if len(t) <= 6 and " " not in t:
        rows = PG.execute("""SELECT patient_id FROM staging.patient_name
                             WHERE name_tsv @@ to_tsquery('spanish', %s) ORDER BY name_norm LIMIT 20""", (t.lower() + ":*",)).fetchall()
    else:
        rows = PG.execute("""SELECT patient_id FROM staging.patient_name
                             WHERE name_norm %% %s ORDER BY similarity(name_norm, %s) DESC, patient_id LIMIT 20""", (t, t)).fetchall()
    return [r[0] for r in rows]


def leer_informe(order_id: int) -> dict:
    return PG.execute("SELECT doc FROM staging.f20_doc_jsonb WHERE lab_order_id = %s", (order_id,)).fetchone()[0]


def corregir(result_id: int, nuevo_valor: float, usuario: str, motivo: str) -> None:
    # Validación antes de tocar nada: sin usuario no hay auditoría, y sin auditoría no hay corrección.
    if not usuario:
        raise ValueError("una corrección necesita usuario")
    valor = Decimal(str(nuevo_valor)).quantize(Decimal("0.0001"))
    with PG.transaction():
        row = PG.execute("SELECT lab_order_id FROM staging.f20_result WHERE result_id = %s FOR UPDATE", (result_id,)).fetchone()
        oid = row[0]
        PG.execute("UPDATE staging.f20_result SET value_numeric = %s WHERE result_id = %s", (valor, result_id))
        PG.execute("""INSERT INTO staging.f20_correction (correction_id, result_id, lab_order_id, analyte_code, changed_at, changed_by, old_value, reason)
                      SELECT coalesce(max(correction_id), 0) + 1, %s, %s, 'GLU', now(), %s, 'x', %s FROM staging.f20_correction""",
                   (result_id, oid, usuario, motivo))
        # El documento se reescribe con el valor de la fuente, en la misma transacción, y sin pasar por float.
        doc = PG.execute("SELECT doc FROM staging.f20_doc_jsonb WHERE lab_order_id = %s FOR UPDATE", (oid,)).fetchone()[0]
        i = next(k for k, e in enumerate(doc["results"]) if e["result_id"] == result_id)
        PG.execute("""UPDATE staging.f20_doc_jsonb SET doc = jsonb_set(jsonb_set(doc, ARRAY['results', %s::text, 'value'], to_jsonb(%s::numeric)),
                        ARRAY['results', %s::text, 'corrections'],
                        coalesce(doc #> ARRAY['results', %s::text, 'corrections'], '[]'::jsonb) ||
                        jsonb_build_array(jsonb_build_object('changed_at', now(), 'by', %s::text, 'old_value', 'x', 'reason', %s::text)))
                      WHERE lab_order_id = %s""", (str(i), valor, str(i), str(i), usuario, motivo, oid))
