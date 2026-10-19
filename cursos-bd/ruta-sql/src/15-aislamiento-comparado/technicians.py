"""Fase 15 · cuatro técnicos toman muestras de la planilla a la vez, de cinco maneras (Postgres).

    uv run python 15-aislamiento-comparado/technicians.py [--technicians 4] [--takes 100]

Esto no es lab race: son hilos de verdad, sin orden fijo, para medir cuánto pasa con carga. Cada
técnico repite "miro la primera muestra libre y la tomo". Al final se cuenta cuántas tomas quedaron,
cuántas muestras se tomaron dos veces, cuántos errores vio la aplicación y cuántos reintentos hubo.

  read-committed   el código de 2020: miro y tomo, en READ COMMITTED
  serializable     lo mismo en SERIALIZABLE, sin bucle de reintento (la rotura)
  retry            SERIALIZABLE con el bucle de reintento
  unique           READ COMMITTED con una restricción UNIQUE: el que llega segundo prueba la siguiente
  skip-locked      READ COMMITTED, la muestra se bloquea con FOR UPDATE SKIP LOCKED antes de tomarla,
                   pero la toma se sigue anotando en otra tabla
  skip-locked-row  lo mismo, con la toma anotada en la fila que se bloquea (specimen.taken_by)
"""

import argparse
import threading
import time

import psycopg

from lab.race import connect

NEXT_FREE = """
    SELECT specimen_id FROM staging.specimen s
    WHERE NOT EXISTS (SELECT 1 FROM staging.specimen_take t WHERE t.specimen_id = s.specimen_id)
    ORDER BY collected_at, specimen_id LIMIT 1"""
NEXT_FREE_LOCKED = NEXT_FREE + " FOR UPDATE SKIP LOCKED"
TAKE = "INSERT INTO staging.specimen_take (specimen_id, technician) VALUES (%s, %s)"
SERIALIZATION_FAILURE = ("40001", "40P01")


def take_once(conn, mode: str, who: str) -> None:
    """Una toma: una transacción. Levanta la excepción del motor tal cual."""
    level = "SERIALIZABLE" if mode in ("serializable", "retry") else "READ COMMITTED"
    with conn.transaction():
        conn.execute(f"SET TRANSACTION ISOLATION LEVEL {level}")
        if mode == "unique":
            # El que llega segundo no falla: la restricción lo manda a probar la siguiente.
            row = conn.execute(f"""
                INSERT INTO staging.specimen_take (specimen_id, technician)
                SELECT specimen_id, %s FROM ({NEXT_FREE}) AS free
                ON CONFLICT (specimen_id) DO NOTHING RETURNING specimen_id""", (who,)).fetchone()
            if row is None:
                raise Retry()
            return
        if mode == "skip-locked-row":
            # El estado vive en la fila bloqueada: al conseguir el bloqueo, Postgres vuelve a evaluar
            # taken_by IS NULL sobre la versión confirmada, y la muestra que otro tomó ya no califica.
            specimen = conn.execute("""
                UPDATE staging.specimen SET taken_by = %s
                WHERE specimen_id = (SELECT specimen_id FROM staging.specimen WHERE taken_by IS NULL
                                     ORDER BY collected_at, specimen_id LIMIT 1 FOR UPDATE SKIP LOCKED)
                RETURNING specimen_id""", (who,)).fetchone()[0]
            conn.execute(TAKE, (specimen, who))
            return
        sql = NEXT_FREE_LOCKED if mode == "skip-locked" else NEXT_FREE
        specimen = conn.execute(sql).fetchone()[0]
        conn.execute(TAKE, (specimen, who))


class Retry(Exception):
    pass


def technician(mode: str, who: str, takes: int, stats: dict, lock: threading.Lock) -> None:
    conn = connect("postgres")
    done = errors = retries = 0
    while done < takes:
        try:
            take_once(conn, mode, who)
            done += 1
        except Retry:
            retries += 1
        except psycopg.Error as exc:
            if mode == "retry" and exc.sqlstate in SERIALIZATION_FAILURE:
                retries += 1            # el bucle de reintento: la misma toma, otra vez, desde el principio
                continue
            errors += 1                 # sin bucle: el técnico ve el error y esa toma se pierde
            done += 1
    conn.close()
    with lock:
        stats["errors"] += errors
        stats["retries"] += retries


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("--technicians", type=int, default=4)
    p.add_argument("--takes", type=int, default=100)
    p.add_argument("--modes", default="read-committed,serializable,retry,unique,skip-locked,skip-locked-row")
    a = p.parse_args()
    admin = connect("postgres")
    print(f"{a.technicians} técnicos × {a.takes} tomas cada uno")
    print("| modo | tomas | muestras distintas | tomadas dos veces o más | errores que vio el técnico | reintentos | segundos |")
    print("|---|---|---|---|---|---|---|")
    for mode in a.modes.split(","):
        admin.execute("TRUNCATE staging.specimen_take")
        admin.execute("UPDATE staging.specimen SET taken_by = NULL WHERE taken_by IS NOT NULL")
        admin.execute("DROP INDEX IF EXISTS staging.specimen_take_unique")
        if mode == "unique":
            admin.execute("CREATE UNIQUE INDEX specimen_take_unique ON staging.specimen_take (specimen_id)")
        stats, lock = {"errors": 0, "retries": 0}, threading.Lock()
        threads = [threading.Thread(target=technician, args=(mode, f"tecnico_{i}", a.takes, stats, lock))
                   for i in range(a.technicians)]
        started = time.monotonic()
        for t in threads:
            t.start()
        for t in threads:
            t.join()
        seconds = time.monotonic() - started
        takes, distinct, twice = admin.execute("""
            SELECT count(*), count(DISTINCT specimen_id),
                   (SELECT count(*) FROM (SELECT specimen_id FROM staging.specimen_take
                                          GROUP BY specimen_id HAVING count(*) > 1) d)
            FROM staging.specimen_take""").fetchone()
        print(f"| {mode} | {takes} | {distinct} | {twice} | {stats['errors']} | {stats['retries']} | {seconds:.1f} |")
    admin.execute("TRUNCATE staging.specimen_take")
    admin.execute("UPDATE staging.specimen SET taken_by = NULL WHERE taken_by IS NOT NULL")
    admin.execute("DROP INDEX IF EXISTS staging.specimen_take_unique")
    admin.close()


if __name__ == "__main__":
    main()
