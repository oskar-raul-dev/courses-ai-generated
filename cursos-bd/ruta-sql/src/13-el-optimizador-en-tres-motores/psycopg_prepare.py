"""La consulta por sede desde Python, como la correría una aplicación: psycopg 3 la manda sin preparar las primeras
cinco veces, la prepara en el servidor en la sexta (prepare_threshold = 5), y desde ahí es una sentencia preparada
de Postgres, con sus cinco planes personalizados y la comparación con el genérico. El día empieza en el central.

Uso, desde src/: uv run python 13-el-optimizador-en-tres-motores/psycopg_prepare.py
"""

import time

import psycopg

from lab import config

QUERY = """
    SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id)
    WHERE o.site_code = %s AND o.ordered_on >= '2026-09-01' GROUP BY r.analyte_code
"""
# la consulta de control también se prepara sola; se cuenta solo la de la sede
STATEMENTS = """
    SELECT count(*), coalesce(sum(generic_plans), 0), coalesce(sum(custom_plans), 0)
    FROM pg_prepared_statements WHERE from_sql = false AND statement NOT LIKE '%%pg_prepared_statements%%'
"""


def main() -> None:
    with psycopg.connect(**config.POSTGRES, autocommit=True) as conn, conn.cursor() as cur:
        print(f"prepare_threshold = {conn.prepare_threshold}")
        for run, site in enumerate(["C"] * 10 + ["V"] * 3, start=1):
            start = time.perf_counter()
            cur.execute(QUERY, (site,))
            cur.fetchall()
            ms = (time.perf_counter() - start) * 1000
            with conn.cursor() as check:
                prepared, generic, custom = check.execute(STATEMENTS).fetchone()
            print(f"{run:2} {site} {ms:7.1f} ms  preparadas={prepared} genéricos={generic} personalizados={custom}")


if __name__ == "__main__":
    main()
