"""Fase 22 · la cola dentro de Postgres: SKIP LOCKED, entrega al menos una vez, idempotencia y descartes.

Tres pruebas sobre los 6.651 resultados del 26/12/2025, cada una con cuatro consumidores en hilos:

  A  cola con SKIP LOCKED y procesamiento transaccional: cada mensaje toma su fila, escribe en el destino y marca
     `done` en la misma transacción. Diez corridas: duplicados en el destino.
  B  entrega al menos una vez: el envío al sistema de afuera es fuera de la transacción, y el consumidor se cae
     con probabilidad 2 % después de enviar y antes de marcar. El destino no tiene clave: duplicados. Después, el
     mismo escenario con el destino idempotente (la clave única del identificador en la bandeja de entrada).
  C  mensaje veneno: 5 mensajes que siempre fallan. Después de tres intentos, van a la tabla de descartes.

La verdad es `staging.f22_expected`. "Duplicado" es un identificador que el destino recibe más de una vez.

Uso (desde ruta-sql/src, con POSTGRES_PORT):  uv run python 22-la-exportacion-de-las-9-40/03_colas.py
"""

import random
import threading
import time

import psycopg
from psycopg.types.json import Jsonb

from lab import config

CONSUMIDORES = 4
RUNS = 10
FALLA_ENVIO = 0.02
VENENOS = 5
MAX_INTENTOS = 3


def preparar(admin: psycopg.Connection, venenos: int = 0) -> None:
    admin.execute("TRUNCATE staging.f22_queue, staging.f22_destination, staging.f22_inbox, staging.f22_dead RESTART IDENTITY")
    admin.execute("""INSERT INTO staging.f22_queue (message_id, payload)
                     SELECT 'res-' || r.result_id,
                            jsonb_build_object('result_id', r.result_id, 'analyte', r.analyte_code,
                                               'value', r.value_numeric, 'veneno', false)
                     FROM staging.f22_expected e JOIN alameda.result r ON r.result_id = e.result_id
                     ORDER BY r.result_id""")
    if venenos:
        admin.execute("""INSERT INTO staging.f22_queue (message_id, payload)
                         SELECT 'veneno-' || g, jsonb_build_object('veneno', true, 'motivo', 'formato inválido')
                         FROM generate_series(1, %s) g""", (venenos,))


def consumir(nombre: str, modo: str, rnd: random.Random, resultado: dict) -> None:
    """modo: 'transaccional' (A), 'al_menos_una_vez' (B: el destino no tiene clave) o 'idempotente' (B: con clave)."""
    conn = psycopg.connect(**config.POSTGRES, autocommit=False)
    envio = psycopg.connect(**config.POSTGRES, autocommit=True)  # el sistema de afuera: fuera de la transacción
    procesados = 0
    while True:
        fila = conn.execute("""SELECT queue_id, message_id, payload FROM staging.f22_queue
                               WHERE status = 'pending' ORDER BY queue_id
                               FOR UPDATE SKIP LOCKED LIMIT 1""").fetchone()
        if fila is None:
            conn.commit()
            break
        qid, mid, payload = fila
        if payload.get("veneno"):
            # Un mensaje que no se puede procesar: se cuenta el intento; a los tres, va a descartes.
            intentos = conn.execute("UPDATE staging.f22_queue SET attempts = attempts + 1 WHERE queue_id = %s RETURNING attempts",
                                    (qid,)).fetchone()[0]
            if intentos >= MAX_INTENTOS:
                conn.execute("""INSERT INTO staging.f22_dead (queue_id, message_id, payload, reason)
                                SELECT queue_id, message_id, payload, 'formato inválido tras 3 intentos'
                                FROM staging.f22_queue WHERE queue_id = %s""", (qid,))
                conn.execute("DELETE FROM staging.f22_queue WHERE queue_id = %s", (qid,))
            conn.commit()
            continue
        time.sleep(rnd.uniform(0.0002, 0.001))  # trabajo del mensaje
        if modo == "transaccional":
            conn.execute("INSERT INTO staging.f22_destination (message_id) VALUES (%s)", (mid,))
            conn.execute("UPDATE staging.f22_queue SET status = 'done', done_by = %s WHERE queue_id = %s", (nombre, qid))
            conn.commit()
        else:
            if modo == "al_menos_una_vez":
                envio.execute("INSERT INTO staging.f22_destination (message_id) VALUES (%s)", (mid,))
            else:  # idempotente: la clave única del identificador la hace cumplir el motor
                cur = envio.execute("INSERT INTO staging.f22_inbox (message_id, payload) VALUES (%s, %s) ON CONFLICT (message_id) DO NOTHING",
                                    (mid, Jsonb(payload)))
                if cur.rowcount == 0:
                    resultado["rechazados"] = resultado.get("rechazados", 0) + 1
            if rnd.random() < FALLA_ENVIO:
                # el consumidor se cae después de enviar: el reclamo se revierte y el mensaje vuelve a estar pendiente
                conn.rollback()
                resultado["caidas"] = resultado.get("caidas", 0) + 1
                continue
            conn.execute("UPDATE staging.f22_queue SET status = 'done', done_by = %s WHERE queue_id = %s", (nombre, qid))
            conn.commit()
        procesados += 1
    conn.close()
    envio.close()
    resultado.setdefault("procesados", {})[nombre] = procesados


def correr(modo: str, admin: psycopg.Connection, venenos: int = 0, seed: int = 0) -> dict:
    preparar(admin, venenos)
    resultado: dict = {}
    hilos = [threading.Thread(target=consumir, args=(f"c{i}", modo, random.Random(seed * 10 + i), resultado))
             for i in range(CONSUMIDORES)]
    t0 = time.perf_counter()
    for h in hilos:
        h.start()
    for h in hilos:
        h.join()
    resultado["segundos"] = time.perf_counter() - t0
    return resultado


def duplicados(admin: psycopg.Connection, tabla: str) -> int:
    return admin.execute(f"""SELECT count(*) FROM (SELECT message_id FROM {tabla}
                             GROUP BY message_id HAVING count(*) > 1) x""").fetchone()[0]


def main() -> None:
    admin = psycopg.connect(**config.POSTGRES, autocommit=True)
    verdad = admin.execute("SELECT count(*) FROM staging.f22_expected").fetchone()[0]
    print(f"verdad del día: {verdad} resultados · {CONSUMIDORES} consumidores · SKIP LOCKED")

    print("\nA · procesamiento transaccional (diez corridas)")
    dup_a, seg_a, falt_a = [], [], []
    for i in range(RUNS):
        r = correr("transaccional", admin, seed=i)
        d = duplicados(admin, "staging.f22_destination")
        f = verdad - admin.execute("SELECT count(DISTINCT message_id) FROM staging.f22_destination").fetchone()[0]
        dup_a.append(d); seg_a.append(r["segundos"]); falt_a.append(f)
        print(f"  corrida {i + 1:2d}: duplicados {d} · faltantes {f} · {r['segundos']:.2f} s")
    print(f"  total: corridas con duplicados {sum(1 for d in dup_a if d)} de {RUNS} · "
          f"faltantes en todas {sum(falt_a)} · mediana {sorted(seg_a)[RUNS // 2]:.2f} s")

    print("\nB · entrega al menos una vez: un consumidor se cae 2 % de las veces después de enviar")
    r = correr("al_menos_una_vez", admin, seed=77)
    d = duplicados(admin, "staging.f22_destination")
    print(f"  destino sin clave: duplicados {d} · caídas {r.get('caidas', 0)} · "
          f"mensajes distintos recibidos {admin.execute('SELECT count(DISTINCT message_id) FROM staging.f22_destination').fetchone()[0]}")
    r = correr("idempotente", admin, seed=77)
    d = duplicados(admin, "staging.f22_inbox")
    recibidos = admin.execute("SELECT count(*) FROM staging.f22_inbox").fetchone()[0]
    print(f"  bandeja idempotente: duplicados {d} · caídas {r.get('caidas', 0)} · mensajes en la bandeja {recibidos} de {verdad}")

    print(f"\nC · mensaje veneno: {VENENOS} mensajes que siempre fallan, con {MAX_INTENTOS} intentos")
    correr("transaccional", admin, venenos=VENENOS, seed=5)
    descartes = admin.execute("SELECT count(*) FROM staging.f22_dead").fetchone()[0]
    pendientes = admin.execute("SELECT count(*) FROM staging.f22_queue WHERE status = 'pending'").fetchone()[0]
    procesados = admin.execute("SELECT count(DISTINCT message_id) FROM staging.f22_destination").fetchone()[0]
    print(f"  en descartes: {descartes} · pendientes en cola: {pendientes} · resultados procesados: {procesados} de {verdad}")
    admin.close()


if __name__ == "__main__":
    main()
