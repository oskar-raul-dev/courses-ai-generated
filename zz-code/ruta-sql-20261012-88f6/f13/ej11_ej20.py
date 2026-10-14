"""Ejercicios 11 y 20 de la Fase 13: una conexión que no prepara nunca, y dos conexiones con contadores propios."""

import time

import psycopg

from lab import config

QUERY = """
    SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id)
    WHERE o.site_code = %s AND o.ordered_on >= '2026-09-01' GROUP BY r.analyte_code
"""
COUNTERS = """
    SELECT count(*), coalesce(sum(generic_plans), 0), coalesce(sum(custom_plans), 0)
    FROM pg_prepared_statements WHERE from_sql = false AND statement NOT LIKE '%%pg_prepared_statements%%'
"""


def run(conn, site):
    start = time.perf_counter()
    conn.execute(QUERY, (site,)).fetchall()
    return (time.perf_counter() - start) * 1000


def counters(conn):
    return conn.execute(COUNTERS, prepare=False).fetchone()


print("== ej11: prepare_threshold = None")
with psycopg.connect(**config.POSTGRES, autocommit=True) as conn:
    conn.prepare_threshold = None
    for _ in range(10):
        run(conn, "C")
    times = [run(conn, "V") for _ in range(3)]
    print("V:", ", ".join(f"{t:.1f} ms" for t in times), "| preparadas, genéricos, personalizados =", counters(conn))

print("== ej20: dos conexiones")
with psycopg.connect(**config.POSTGRES, autocommit=True) as early, \
        psycopg.connect(**config.POSTGRES, autocommit=True) as late:
    for _ in range(10):
        run(early, "C")
    for _ in range(10):
        run(late, "V")
    print("la del central, V:", f"{run(early, 'V'):.1f} ms", counters(early))
    print("la de los centros, V:", f"{run(late, 'V'):.1f} ms", counters(late))
