"""🏆 "Un martes" · el punto de partida: la planilla de los martes, pasada a SQL tal como estaba.

El arnés llama a `presentar(conn, desde)` con una conexión del rol `facturacion` (que no ve legacy), para la
semana que empieza el lunes `desde`, y la vuelve a llamar después del corte. Lo que hace hoy:

  · toma lo facturado de la semana, de todas las obras sociales menos PARTICULAR;
  · le pone el precio vigente hoy, una unidad por práctica, y lo suma;
  · rehace la presentación cada vez que se la llama.

Contra la planilla de Matías no está tan mal, y contra lo que la obra social paga está bastante mal.
"""

import datetime as dt


def presentar(conn, desde: dt.date) -> None:
    hasta = desde + dt.timedelta(days=7)
    with conn.transaction():
        conn.execute("DELETE FROM alameda.presentation_line WHERE week_start = %s", (desde,))
        conn.execute("DELETE FROM alameda.presentation WHERE week_start = %s", (desde,))
        conn.execute("""
            INSERT INTO alameda.presentation (payer_code, week_start, gross, copay, net)
            SELECT b.payer_code, %(desde)s, sum(p.amount), 0, sum(p.amount)
            FROM alameda.billed_practice AS b
            JOIN alameda.agreement_price AS p
              ON p.payer_code = b.payer_code AND p.practice_id = b.practice_id AND p.valid_during @> current_date
            WHERE lower(b.billed_during) >= %(desde)s AND lower(b.billed_during) < %(hasta)s
              AND b.payer_code <> 'PARTICULAR'
            GROUP BY b.payer_code""", dict(desde=desde, hasta=hasta))
        conn.execute("""
            INSERT INTO alameda.presentation_line
            SELECT b.payer_code, %(desde)s, b.legacy_order_practice_id, 0, b.practice_id, lower(b.billed_during),
                   1, p.amount, p.amount
            FROM alameda.billed_practice AS b
            JOIN alameda.agreement_price AS p
              ON p.payer_code = b.payer_code AND p.practice_id = b.practice_id AND p.valid_during @> current_date
            WHERE lower(b.billed_during) >= %(desde)s AND lower(b.billed_during) < %(hasta)s
              AND b.payer_code <> 'PARTICULAR'""", dict(desde=desde, hasta=hasta))
