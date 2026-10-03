# DuckDB embebido: versión, lectura por columnas visible en el plan, y el punto de rotura de F08
# (dos procesos escribiendo el mismo archivo), con su mensaje literal.
# Uso: python duckdb_check.py <directorio-temporal>
import multiprocessing as mp
import os
import sys

import duckdb


def writer(path, n):
    # segundo proceso: intenta abrir el mismo archivo para escribir mientras el primero lo tiene
    try:
        c = duckdb.connect(path)
        c.execute("INSERT INTO work_order SELECT * FROM work_order LIMIT 1")
        print(f"proceso {n}: escribió sin error")
    except Exception as e:
        print(f"proceso {n}: {type(e).__name__}: {e}")


def main():
    path = os.path.join(sys.argv[1], "condor.duckdb")
    if os.path.exists(path):
        os.remove(path)

    print("duckdb", duckdb.__version__)

    con = duckdb.connect(path)
    con.execute("""
        CREATE TABLE work_order AS
        SELECT i AS id,
               'HK-' || (4000 + i % 140) AS aircraft,
               i % 8 AS operator_id,
               (i % 97) * 1.5 AS labor_hours,
               (i % 13) * 120.0 AS parts_cost,
               repeat('inspeccion de tren sin novedad ', 4) AS notes
        FROM range(2000000) t(i)
    """)
    # el plan muestra qué columnas se leen: 3 de 6
    plan = con.execute("""
        EXPLAIN ANALYZE
        SELECT operator_id, sum(labor_hours + parts_cost) FROM work_order GROUP BY operator_id
    """).fetchall()
    print("\n".join(row[1] for row in plan))

    p = mp.Process(target=writer, args=(path, 2))
    p.start()
    p.join()
    con.close()


if __name__ == "__main__":
    main()
