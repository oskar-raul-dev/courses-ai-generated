"""🏆 "Un martes" · la solución de referencia (no se publica, D42).

`presentar(conn, desde)` emite, una sola vez, la presentación de la semana que empieza el lunes `desde`:

  · lee todo en una transacción REPEATABLE READ: una foto de la base al momento de emitir (el corte);
  · si la semana ya tiene presentación, no hace nada: una presentación emitida no cambia, y lo que llegue
    después queda para la próxima;
  · por cada práctica facturada del mes (el tope es mensual), en orden de fecha y clave: sin convenio, fuera;
    componente de un panel del mismo protocolo, fuera; si es de una obra social con tope y se pasa de las
    unidades del afiliado en el mes, fuera; si no, se presenta con el precio vigente el día de la práctica por
    la cantidad;
  · las que no tienen precio vigente no están en lo facturado (la clave foránea con período no las deja):
    salen de la cola de rechazos, y se listan como excluidas;
  · el coseguro se descuenta por protocolo, sin pasar de lo presentado de ese protocolo.
"""

import datetime as dt
from collections import defaultdict
from decimal import Decimal

CENTAVO = Decimal("0.01")


def presentar(conn, desde: dt.date) -> None:
    hasta = desde + dt.timedelta(days=7)
    mes = desde.replace(day=1)
    with conn.transaction():
        conn.execute("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ")
        if conn.execute("SELECT 1 FROM alameda.presentation WHERE week_start = %s LIMIT 1", (desde,)).fetchone():
            return
        filas = conn.execute("""
            SELECT b.legacy_order_practice_id, b.lab_order_id, lower(b.billed_during), b.payer_code, b.practice_id,
                   b.quantity, o.copay, o.patient_id, p.amount,
                   EXISTS (SELECT 1 FROM alameda.agreement AS a WHERE a.payer_code = b.payer_code
                             AND a.practice_id = b.practice_id AND a.site_code = o.site_code),
                   EXISTS (SELECT 1 FROM staging.practice_composition AS k
                           JOIN alameda.billed_practice AS b2 ON b2.lab_order_id = b.lab_order_id
                                                             AND b2.practice_id = k.panel_id
                           WHERE k.component_id = b.practice_id)
            FROM alameda.billed_practice AS b
            JOIN alameda.lab_order AS o ON o.lab_order_id = b.lab_order_id
            JOIN alameda.agreement_price AS p ON p.payer_code = b.payer_code AND p.practice_id = b.practice_id
                                             AND p.valid_during @> lower(b.billed_during)
            WHERE b.billed_during && daterange(%(mes)s, %(hasta)s) AND b.payer_code <> 'PARTICULAR'
            ORDER BY lower(b.billed_during), b.legacy_order_practice_id""", dict(mes=mes, hasta=hasta)).fetchall()
        topes = dict(conn.execute("SELECT payer_code, units_per_month FROM staging.martes_cap").fetchall())

        lineas, excluidas, consumo = [], [], defaultdict(int)
        for lid, oid, dia, payer, practica, cant, cos, persona, precio, convenio, en_panel in filas:
            if not convenio:
                motivo = "fuera_de_convenio"
            elif en_panel:
                motivo = "incluida_en_panel"
            elif payer in topes and consumo[(persona, payer, dia.month)] + cant > topes[payer]:
                motivo = "excede_tope"
            else:
                motivo = None
                consumo[(persona, payer, dia.month)] += cant
            if dia < desde:
                continue                                    # solo cuenta para el tope
            if motivo:
                excluidas.append((payer, desde, lid, motivo))
            else:
                lineas.append(dict(payer=payer, lid=lid, oid=oid, practica=practica, dia=dia, cant=cant,
                                   precio=precio, importe=(precio * cant).quantize(CENTAVO), cos=Decimal(cos)))

        for lid, valor in conn.execute("""
                SELECT DISTINCT ON (source_key) source_key::integer, value FROM staging.rejection
                WHERE rule = 'facturacion.practica_sin_precio_vigente' AND source_table = 'ProtocoloPracticas'
                ORDER BY source_key, rejected_at DESC""").fetchall():
            payer, _, dia = valor.split(" ")
            if payer != "PARTICULAR" and desde <= dt.date.fromisoformat(dia) < hasta:
                excluidas.append((payer, desde, lid, "sin_precio"))

        bruto, por_protocolo, cos = defaultdict(Decimal), defaultdict(Decimal), {}
        for l in lineas:
            bruto[l["payer"]] += l["importe"]
            por_protocolo[(l["payer"], l["oid"])] += l["importe"]
            cos[l["oid"]] = l["cos"]
        copago = defaultdict(Decimal)
        for (payer, oid), b in por_protocolo.items():
            copago[payer] += min(cos[oid], b)

        with conn.cursor() as cur:
            cur.executemany("INSERT INTO alameda.presentation (payer_code, week_start, gross, copay, net) "
                            "VALUES (%s, %s, %s, %s, %s)",
                            [(p, desde, b, copago[p], b - copago[p]) for p, b in bruto.items()])
            cur.executemany("INSERT INTO alameda.presentation_line VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
                            [(l["payer"], desde, l["lid"], l["oid"], l["practica"], l["dia"], l["cant"], l["precio"],
                              l["importe"]) for l in lineas])
            cur.executemany("INSERT INTO alameda.presentation_excluded VALUES (%s, %s, %s, %s)", excluidas)
