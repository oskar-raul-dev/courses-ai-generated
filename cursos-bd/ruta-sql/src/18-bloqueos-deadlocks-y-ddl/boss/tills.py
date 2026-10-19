"""💀 Boss del Bloque III · el código de la tarde, tal como está. Este es el archivo que se arregla.

Cuatro funciones, que `afternoon.py` llama desde muchos hilos a la vez, cada una con su propia conexión de psycopg en
`autocommit` (cada sentencia confirma sola salvo que la función abra una transacción):

  issue_invoice(conn, ws, till)            una caja emite un comprobante B del punto de venta 1 y lo autoriza
  take_specimen(conn, technician)          un técnico toma la próxima muestra libre y devuelve su número
  load_hemogram(conn, technician, sid)     el técnico carga el hematocrito de esa muestra
  lunch_form(conn, minutes_away)           alguien abre el formulario de hemogramas del día, se va, vuelve y corrige uno

Reglas del encargo: las firmas no cambian; el formulario tiene que seguir abriendo los hemogramas del día y guardando su
corrección (o avisar que alguien la cambió antes: perderla en silencio no vale); y el organismo es el de la Fase 16, sin tocar.
"""

import time

POS, KIND = 1, "B"


def issue_invoice(conn, ws, till):
    """2015: UltimoNumero. Primero se suma, después se lee. Si el organismo rechaza, se pone al día y se vuelve a pedir."""
    from fiscal import Rejected
    while True:
        conn.execute("UPDATE staging.july_counter SET last_number = last_number + 1 WHERE point_of_sale = %s AND kind = %s",
                     (POS, KIND))
        number = conn.execute("SELECT last_number FROM staging.july_counter WHERE point_of_sale = %s AND kind = %s",
                              (POS, KIND)).fetchone()[0]
        try:
            cae = ws.request_cae(POS, KIND, number)
        except Rejected:
            last = ws.last_authorized(POS, KIND)
            conn.execute("UPDATE staging.july_counter SET last_number = %s WHERE point_of_sale = %s AND kind = %s",
                         (last, POS, KIND))
            raise
        conn.execute("INSERT INTO staging.july_invoice (number, cae, till) VALUES (%s, %s, %s)", (number, cae, till))
        return number


def take_specimen(conn, technician):
    """La planilla: la primera muestra sin toma, y se anota la toma."""
    sid = conn.execute("""
        SELECT specimen_id FROM staging.july_specimen s
        WHERE NOT EXISTS (SELECT 1 FROM staging.july_specimen_take t WHERE t.specimen_id = s.specimen_id)
        ORDER BY collected_at, specimen_id LIMIT 1""").fetchone()[0]
    conn.execute("INSERT INTO staging.july_specimen_take (specimen_id, technician) VALUES (%s, %s)", (sid, technician))
    return sid


def load_hemogram(conn, technician, sid):
    conn.execute("UPDATE staging.july_hemogram SET hematocrit = '41', loaded_by = %s WHERE specimen_id = %s",
                 (technician, sid))


def lunch_form(conn, minutes_away):
    """El formulario abre los hemogramas del día para editar, con los registros bloqueados, como en Access, y corrige el
    primero que todavía está vacío. Devuelve "guardado" o, si alguien lo cambió antes, "conflicto"."""
    conn.execute("BEGIN")
    rows = conn.execute("""
        SELECT h.specimen_id, h.hematocrit FROM staging.july_hemogram h JOIN staging.july_specimen s USING (specimen_id)
        ORDER BY s.collected_at, s.specimen_id FOR UPDATE OF h""").fetchall()
    target = next(sid for sid, value in rows if value is None)
    time.sleep(minutes_away)                                   # el almuerzo
    conn.execute("UPDATE staging.july_hemogram SET hematocrit = '40', loaded_by = 'formulario' WHERE specimen_id = %s",
                 (target,))
    conn.execute("COMMIT")
    return "guardado"
