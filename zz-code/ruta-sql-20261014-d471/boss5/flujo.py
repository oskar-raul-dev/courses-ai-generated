"""💀 Boss V · Las 9:40 · SOLUCIÓN (D42: no se publica). Pasa los cinco criterios de arnes.py."""

import datetime as dt

import psycopg

VENTANA = dt.timedelta(hours=1)  # mayor que la demora de confirmación medida en F22


def exportar(conn: psycopg.Connection) -> int:
    # Ventana de retroceso: relee desde la marca menos una hora; lo ya enviado se descarta por clave.
    wm = conn.execute("SELECT mark FROM staging.b5_watermark WHERE name = 'portal'").fetchone()[0]
    filas = conn.execute("""SELECT s.result_id, s.recorded_at FROM staging.b5_source s
                            WHERE s.recorded_at > %s
                              AND NOT EXISTS (SELECT 1 FROM staging.b5_exported x WHERE x.result_id = s.result_id)
                            ORDER BY s.recorded_at""", (wm - VENTANA,)).fetchall()
    for rid, _ in filas:
        conn.execute("INSERT INTO staging.b5_exported VALUES (%s) ON CONFLICT DO NOTHING", (rid,))
    if filas:
        conn.execute("UPDATE staging.b5_watermark SET mark = greatest(mark, %s) WHERE name = 'portal'", (max(f[1] for f in filas),))
    return len(filas)


def entregar(conn: psycopg.Connection, message_id: str, version: int, payload: str) -> None:
    # Idempotente y ordenado por versión: el motor descarta el repetido y la versión vieja.
    conn.execute("""INSERT INTO staging.b5_destination (message_id, version, payload) VALUES (%s, %s, %s)
                    ON CONFLICT (message_id) DO UPDATE SET version = excluded.version, payload = excluded.payload
                    WHERE excluded.version > staging.b5_destination.version""", (message_id, version, payload))


def _registrar(conn, result_id, lab_order_id, analyte, valor, registrado):
    conn.execute("INSERT INTO staging.b5_source VALUES (%s, %s, %s, %s, %s)", (result_id, lab_order_id, analyte, valor, registrado))
    if valor == "DETECTABLE":
        # Outbox: la notificación pendiente se confirma con el resultado, no a la noche siguiente.
        conn.execute("INSERT INTO staging.b5_outbox (result_id, created_at) VALUES (%s, %s)", (result_id, registrado))


def registrar_resultado(conn: psycopg.Connection, result_id: int, lab_order_id: int, analyte: str, valor: str,
                        registrado: dt.datetime) -> None:
    # El resultado y su notificación pendiente van en la misma transacción. Si quien llama ya tiene una
    # transacción abierta, se respeta: confirmará los dos juntos.
    if conn.autocommit:
        with conn.transaction():
            _registrar(conn, result_id, lab_order_id, analyte, valor, registrado)
    else:
        _registrar(conn, result_id, lab_order_id, analyte, valor, registrado)


def relevar(conn: psycopg.Connection) -> int:
    """El relevador del outbox. Corre continuamente; aquí se simula que envía en el instante en que la fila existe."""
    pendientes = conn.execute("SELECT outbox_id, result_id, created_at FROM staging.b5_outbox WHERE sent_at IS NULL").fetchall()
    for oid, rid, creado in pendientes:
        conn.execute("INSERT INTO staging.b5_notification (result_id, notified_at) VALUES (%s, %s)", (rid, creado))
        conn.execute("UPDATE staging.b5_outbox SET sent_at = %s WHERE outbox_id = %s", (creado, oid))
    return len(pendientes)


def cerrar_dia(conn: psycopg.Connection, dia: dt.date) -> None:
    # El cierre ya no notifica: solo se asegura de que el relevador no dejó nada pendiente.
    relevar(conn)
