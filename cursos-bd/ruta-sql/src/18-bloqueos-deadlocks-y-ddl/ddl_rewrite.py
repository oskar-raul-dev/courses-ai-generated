"""Fase 18 · qué ALTER reescribe la tabla, y cuánto tiempo la deja cerrada (Postgres, sobre staging.result_ddl).

    uv run python 18-bloqueos-deadlocks-y-ddl/ddl_rewrite.py

Cada ALTER toma ACCESS EXCLUSIVE durante todo lo que tarda. Si cambia el `relfilenode`, reescribió la tabla entera. Al final,
CREATE INDEX contra CREATE INDEX CONCURRENTLY, con una escritura que llega mientras se construye.
"""

import threading
import time

from lab.race import connect

ALTERS = [
    ("agregar una columna sin valor por defecto", "ALTER TABLE staging.result_ddl ADD COLUMN reviewed_by text",
     "ALTER TABLE staging.result_ddl DROP COLUMN reviewed_by"),
    ("agregar una columna con un valor constante", "ALTER TABLE staging.result_ddl ADD COLUMN is_final boolean NOT NULL DEFAULT false",
     "ALTER TABLE staging.result_ddl DROP COLUMN is_final"),
    ("agregar una columna con un valor volátil", "ALTER TABLE staging.result_ddl ADD COLUMN loaded_at timestamptz DEFAULT clock_timestamp()",
     "ALTER TABLE staging.result_ddl DROP COLUMN loaded_at"),
    ("agrandar un varchar", "ALTER TABLE staging.result_ddl ALTER COLUMN value_text TYPE varchar(100)",
     "ALTER TABLE staging.result_ddl ALTER COLUMN value_text TYPE varchar(50)"),
    ("integer a bigint en la clave", "ALTER TABLE staging.result_ddl ALTER COLUMN result_id TYPE bigint",
     "ALTER TABLE staging.result_ddl ALTER COLUMN result_id TYPE integer"),
]


def filenode(conn):
    return conn.execute("SELECT pg_relation_filenode('staging.result_ddl')").fetchone()[0]


def main():
    conn = connect("postgres")
    print("| ALTER | reescribe la tabla | tiempo con ACCESS EXCLUSIVE |")
    print("|---|---|---|")
    for name, sql, undo in ALTERS:
        before = filenode(conn)
        t0 = time.monotonic()
        conn.execute(sql)
        seconds = time.monotonic() - t0
        rewrote = filenode(conn) != before
        print(f"| {name} | {'sí' if rewrote else 'no'} | {seconds * 1000:,.0f} ms |")
        conn.execute(undo)
    conn.execute("VACUUM staging.result_ddl")

    # Un índice nuevo mientras la caja sigue escribiendo: ¿espera la escritura?
    for concurrently in (False, True):
        conn.execute("DROP INDEX IF EXISTS staging.result_ddl_recorded_at_idx")
        build = connect("postgres")
        sql = f"CREATE INDEX {'CONCURRENTLY ' if concurrently else ''}result_ddl_recorded_at_idx ON staging.result_ddl (recorded_at)"
        timing = {}

        def run():
            t0 = time.monotonic()
            build.execute(sql)
            timing["build"] = time.monotonic() - t0

        t = threading.Thread(target=run)
        t.start()
        time.sleep(1.0)                                    # la escritura llega con el índice a medio construir
        writer = connect("postgres")
        t0 = time.monotonic()
        writer.execute("UPDATE staging.result_ddl SET value_text = value_text WHERE result_id = 1")
        waited = time.monotonic() - t0
        t.join()
        writer.close()
        build.close()
        print(f"CREATE INDEX{' CONCURRENTLY' if concurrently else ''}: {timing['build']:.1f} s · "
              f"una escritura que llegó al segundo esperó {waited * 1000:,.0f} ms")
    conn.execute("DROP INDEX IF EXISTS staging.result_ddl_recorded_at_idx")
    conn.close()


if __name__ == "__main__":
    main()
