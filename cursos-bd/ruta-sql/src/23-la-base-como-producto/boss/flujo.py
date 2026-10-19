"""💀 Boss V · Las 9:40 · PUNTO DE PARTIDA. Cuatro funciones que el arnés llama; tienen fallas que no se dicen.

El portal recibe los resultados por mensaje; la exportación es incremental; la notificación obligatoria tiene
que salir dentro de las doce horas del registro. La fuente es `staging.b5_source`.
"""

import datetime as dt

import psycopg


def exportar(conn: psycopg.Connection) -> int:
    """Un ciclo de exportación: manda lo nuevo y avanza la marca. Devuelve cuántas filas exportó."""
    wm = conn.execute("SELECT mark FROM staging.b5_watermark WHERE name = 'portal'").fetchone()[0]
    filas = conn.execute("SELECT result_id, recorded_at FROM staging.b5_source WHERE recorded_at > %s ORDER BY recorded_at",
                         (wm,)).fetchall()
    for rid, _ in filas:
        conn.execute("INSERT INTO staging.b5_exported VALUES (%s) ON CONFLICT DO NOTHING", (rid,))
    if filas:
        conn.execute("UPDATE staging.b5_watermark SET mark = %s WHERE name = 'portal'", (max(f[1] for f in filas),))
    return len(filas)


def entregar(conn: psycopg.Connection, message_id: str, version: int, payload: str) -> None:
    """Aplica un mensaje en el destino. El transporte puede repetirlo y desordenarlo."""
    conn.execute("INSERT INTO staging.b5_destination (message_id, version, payload) VALUES (%s, %s, %s)",
                 (message_id, version, payload))


def registrar_resultado(conn: psycopg.Connection, result_id: int, lab_order_id: int, analyte: str, valor: str,
                        registrado: dt.datetime) -> None:
    """Carga un resultado en la fuente. Si es detectable, hay que notificarlo dentro de las doce horas."""
    conn.execute("INSERT INTO staging.b5_source VALUES (%s, %s, %s, %s, %s)", (result_id, lab_order_id, analyte, valor, registrado))


def cerrar_dia(conn: psycopg.Connection, dia: dt.date) -> None:
    """El proceso nocturno: notifica los detectables del día. Corre a las 9:40 del día siguiente."""
    a_las_940 = dt.datetime.combine(dia + dt.timedelta(days=1), dt.time(9, 40))
    conn.execute("""INSERT INTO staging.b5_notification (result_id, notified_at)
                    SELECT result_id, %s FROM staging.b5_source
                    WHERE value_text = 'DETECTABLE' AND recorded_at::date = %s""", (a_las_940, dia))
