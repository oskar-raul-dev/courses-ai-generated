"""Fase 22 · el outbox frente a la doble escritura, y las correcciones fuera de orden con número de versión.

  A  doble escritura: el cambio de negocio se confirma, y después se envía el mensaje. Si el proceso cae entre los dos
     pasos (2 % de las veces), el mensaje se pierde. Mil operaciones.
  B  outbox: el cambio de negocio y su fila en `staging.f22_outbox` se confirman en la misma transacción. Un relevador
     envía lo pendiente; si cae después de enviar y antes de marcar, reenvía. El destino es idempotente, así que el
     reenvío no se aplica dos veces. Mil operaciones, misma caída.
  C  correcciones fuera de orden: 100 resultados con 5 versiones cada uno, que llegan barajadas. Se aplican dos
     formas: la última que llega gana (ingenua) y la que compara el número de versión (`ON CONFLICT ... WHERE`).
     Se cuenta cuántos resultados quedan con una versión que no es la máxima.

Uso (desde ruta-sql/src, con POSTGRES_PORT):  uv run python 22-la-exportacion-de-las-9-40/06_outbox_versiones.py
"""

import random

import psycopg
from psycopg.types.json import Jsonb

from lab import config

OPERACIONES = 1000
CAIDA = 0.02


def preparar(admin: psycopg.Connection) -> None:
    admin.execute("CREATE TABLE IF NOT EXISTS staging.f22_negocio (result_id integer PRIMARY KEY, lab_order_id integer, analyte_code text, value_numeric numeric, recorded_at timestamp)")
    admin.execute("TRUNCATE staging.f22_inbox, staging.f22_destination, staging.f22_outbox, staging.f22_negocio RESTART IDENTITY")


def doble_escritura(conn: psycopg.Connection, rnd: random.Random) -> tuple[int, int]:
    """Devuelve (mensajes enviados, mensajes perdidos)."""
    enviados = perdidos = 0
    for i in range(OPERACIONES):
        mid = f"dw-{i}"
        conn.execute("INSERT INTO staging.f22_negocio (result_id, lab_order_id, analyte_code, value_numeric, recorded_at) "
                     "VALUES (%s, 0, 'X', 1, now()) ON CONFLICT (result_id) DO NOTHING", (5_000_000 + i,))
        if rnd.random() < CAIDA:
            perdidos += 1  # el proceso cae aquí: el cambio está y el mensaje no sale
            continue
        conn.execute("INSERT INTO staging.f22_destination (message_id) VALUES (%s)", (mid,))
        enviados += 1
    return enviados, perdidos


def outbox(conn: psycopg.Connection, admin: psycopg.Connection, rnd: random.Random) -> dict:
    for i in range(OPERACIONES):
        with conn.transaction():
            conn.execute("INSERT INTO staging.f22_negocio (result_id, lab_order_id, analyte_code, value_numeric, recorded_at) "
                         "VALUES (%s, 0, 'X', 1, now()) ON CONFLICT (result_id) DO NOTHING", (6_000_000 + i,))
            conn.execute("INSERT INTO staging.f22_outbox (message_id, payload) VALUES (%s, '{}')", (f"ob-{i}",))
    reenvios = 0
    while True:
        pendientes = conn.execute("SELECT outbox_id, message_id FROM staging.f22_outbox WHERE sent_at IS NULL "
                                  "ORDER BY outbox_id LIMIT 50").fetchall()
        if not pendientes:
            break
        for oid, mid in pendientes:
            # el destino es idempotente: la clave única del identificador evita que el reenvío cuente dos veces
            admin.execute("INSERT INTO staging.f22_inbox (message_id, payload) VALUES (%s, '{}') ON CONFLICT (message_id) DO NOTHING",
                          (mid,))
            if rnd.random() < CAIDA:
                reenvios += 1
                continue  # cae después de enviar y antes de marcar: queda pendiente y se reenvía
            conn.execute("UPDATE staging.f22_outbox SET sent_at = now() WHERE outbox_id = %s", (oid,))
    return {"reenvios": reenvios}


def versiones(admin: psycopg.Connection, rnd: random.Random, con_version: bool) -> int:
    admin.execute("TRUNCATE staging.f22_inbox")
    mensajes = [(f"r-{r}", v, f"valor-{v}") for r in range(100) for v in range(1, 6)]
    rnd.shuffle(mensajes)  # llegan fuera de orden
    for mid, v, valor in mensajes:
        if con_version:
            admin.execute("""INSERT INTO staging.f22_inbox (message_id, version, payload) VALUES (%s, %s, %s)
                             ON CONFLICT (message_id) DO UPDATE SET version = excluded.version, payload = excluded.payload
                             WHERE excluded.version > staging.f22_inbox.version""",
                          (mid, v, Jsonb({"valor": valor})))
        else:
            admin.execute("""INSERT INTO staging.f22_inbox (message_id, version, payload) VALUES (%s, %s, %s)
                             ON CONFLICT (message_id) DO UPDATE SET version = excluded.version, payload = excluded.payload""",
                          (mid, v, Jsonb({"valor": valor})))
    return admin.execute("SELECT count(*) FROM staging.f22_inbox WHERE version <> 5").fetchone()[0]


def main() -> None:
    admin = psycopg.connect(**config.POSTGRES, autocommit=True)
    rnd = random.Random(1996)
    preparar(admin)
    conn = psycopg.connect(**config.POSTGRES, autocommit=True)

    enviados, perdidos = doble_escritura(conn, rnd)
    cambios = conn.execute("SELECT count(*) FROM staging.f22_negocio").fetchone()[0]
    print("A · doble escritura: "
          f"{OPERACIONES} cambios confirmados · {enviados} mensajes enviados · {perdidos} mensajes perdidos · "
          f"cambios sin mensaje: {cambios - enviados}")

    preparar(admin)
    res = outbox(conn, admin, rnd)
    recibidos = conn.execute("SELECT count(DISTINCT message_id) FROM staging.f22_inbox").fetchone()[0]
    crudos = conn.execute("SELECT count(*) FROM staging.f22_outbox WHERE sent_at IS NOT NULL").fetchone()[0]
    print("B · outbox: "
          f"{OPERACIONES} cambios confirmados con su mensaje · {crudos} marcados como enviados · "
          f"reenvíos tras caída: {res['reenvios']} · mensajes en el destino idempotente: {recibidos} de {OPERACIONES}")

    desacuerdos = {}
    for nombre, con in (("ingenua", False), ("con versión", True)):
        mal = versiones(admin, rnd, con)
        desacuerdos[nombre] = mal
    print(f"C · correcciones fuera de orden (100 resultados, 5 versiones): "
          f"la última que llega gana: {desacuerdos['ingenua']} resultados con una versión que no es la 5 · "
          f"con número de versión: {desacuerdos['con versión']}")
    conn.close()
    admin.close()


if __name__ == "__main__":
    main()
