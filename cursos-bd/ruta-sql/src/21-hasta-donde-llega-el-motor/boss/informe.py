"""💀 Boss IV · El informe en la app. PUNTO DE PARTIDA, con tres fallas a propósito.

Hay que arreglar las tres funciones para que `arnes.py` pase los cinco criterios. El documento del informe y
la fuente relacional tienen que contar lo mismo, y la auditoría tiene que quedar en la misma transacción.

Fallas conocidas en este punto de partida (no se dicen cuáles son):
  - la búsqueda usa solo texto completo, sin tolerar errores de tipeo;
  - la corrección toca la fuente y no el documento;
  - la corrección no es atómica: si falla la auditoría, la fuente ya cambió.
"""

import psycopg

from lab import config

PG = psycopg.connect(**config.POSTGRES, autocommit=True)


def buscar_paciente(texto: str) -> list[int]:
    """IDs de pacientes cuyo nombre se parece a `texto` (sin acentos, mayúsculas, errores de tipeo)."""
    rows = PG.execute("""SELECT patient_id FROM staging.patient_name
                         WHERE name_tsv @@ to_tsquery('spanish', regexp_replace(staging.f21_unaccent(upper(%s)), '\\s+', ' & ', 'g'))
                         ORDER BY patient_id LIMIT 20""", (texto,)).fetchall()
    return [r[0] for r in rows]


def leer_informe(order_id: int) -> dict:
    """El informe del protocolo, leído del documento."""
    return PG.execute("SELECT doc FROM staging.f20_doc_jsonb WHERE lab_order_id = %s", (order_id,)).fetchone()[0]


def corregir(result_id: int, nuevo_valor: float, usuario: str, motivo: str) -> None:
    """Corrige un resultado: la fuente, la auditoría y el documento tienen que quedar de acuerdo, o nada cambia."""
    PG.execute("UPDATE staging.f20_result SET value_numeric = %s WHERE result_id = %s", (nuevo_valor, result_id))
    order_id = PG.execute("SELECT lab_order_id FROM staging.f20_result WHERE result_id = %s", (result_id,)).fetchone()[0]
    PG.execute("""INSERT INTO staging.f20_correction (correction_id, result_id, lab_order_id, analyte_code, changed_at, changed_by, old_value, reason)
                  SELECT coalesce(max(correction_id), 0) + 1, %s, %s, 'GLU', now(), %s, 'x', %s FROM staging.f20_correction""",
               (result_id, order_id, usuario, motivo))
