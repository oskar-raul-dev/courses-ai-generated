"""💀 Boss III · la solución de referencia de tills.py (no se publica: D42). Mismas firmas que el punto de partida."""

import time

POS, KIND = 1, "B"


def issue_invoice(conn, ws, till):
    """El número se toma al autorizar, en una transacción corta: contador, organismo, comprobante, juntos (Fase 16)."""
    from fiscal import Timeout
    with conn.transaction():
        number = conn.execute("UPDATE staging.july_counter SET last_number = last_number + 1 "
                              "WHERE point_of_sale = %s AND kind = %s RETURNING last_number", (POS, KIND)).fetchone()[0]
        try:
            cae = ws.request_cae(POS, KIND, number)
        except Timeout:
            cae = ws.query(POS, KIND, number)        # FECompConsultar antes de deshacer (Fase 16, sección 5.6)
            if cae is None:
                raise
        conn.execute("INSERT INTO staging.july_invoice (number, cae, till) VALUES (%s, %s, %s)", (number, cae, till))
    return number


def take_specimen(conn, technician):
    """La muestra se toma bloqueando su fila y anotando el estado en ella (Fase 15); la toma queda registrada aparte."""
    with conn.transaction():
        sid = conn.execute("""
            UPDATE staging.july_specimen SET taken_by = %s
            WHERE specimen_id = (SELECT specimen_id FROM staging.july_specimen WHERE taken_by IS NULL
                                 ORDER BY collected_at, specimen_id LIMIT 1 FOR UPDATE SKIP LOCKED)
            RETURNING specimen_id""", (technician,)).fetchone()[0]
        conn.execute("INSERT INTO staging.july_specimen_take (specimen_id, technician) VALUES (%s, %s)", (sid, technician))
    return sid


def load_hemogram(conn, technician, sid):
    conn.execute("UPDATE staging.july_hemogram SET hematocrit = '41', loaded_by = %s, version = version + 1 "
                 "WHERE specimen_id = %s", (technician, sid))


def lunch_form(conn, minutes_away):
    """El formulario lee sin bloquear nada, y guarda solo si nadie cambió la fila desde que la leyó (Fase 18)."""
    rows = conn.execute("""
        SELECT h.specimen_id, h.hematocrit, h.version FROM staging.july_hemogram h JOIN staging.july_specimen s USING (specimen_id)
        ORDER BY s.collected_at, s.specimen_id""").fetchall()
    target, version = next((sid, v) for sid, value, v in rows if value is None)
    time.sleep(minutes_away)                                   # el almuerzo, sin nada tomado
    saved = conn.execute("UPDATE staging.july_hemogram SET hematocrit = '40', loaded_by = 'formulario', version = version + 1 "
                         "WHERE specimen_id = %s AND version = %s", (target, version)).rowcount
    return "guardado" if saved else "conflicto"
