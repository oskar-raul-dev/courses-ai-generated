"""Fase 17 · la misma fila contador en MySQL: la versión vieja va al undo, no a la tabla.

    uv run python 17-mvcc-y-su-factura/mysql_history.py

Con y sin una lectura abierta (`START TRANSACTION WITH CONSISTENT SNAPSHOT`), 10.000 actualizaciones de una fila. Mide
el tamaño de la tabla, la *history list length* (lo que el purge todavía no pudo borrar) y el tamaño de los undo.
"""

import time

from lab.race import connect


def q(conn, sql, args=None):
    with conn.cursor() as cur:
        cur.execute(sql, args)
        return cur.fetchall()


def state(conn):
    table = q(conn, "SELECT FILE_SIZE FROM information_schema.INNODB_TABLESPACES WHERE NAME = 'staging/mvcc_counter'")[0][0]
    history = q(conn, "SELECT `COUNT` FROM information_schema.INNODB_METRICS WHERE NAME = 'trx_rseg_history_len'")[0][0]
    undo = q(conn, "SELECT sum(FILE_SIZE) FROM information_schema.INNODB_TABLESPACES WHERE SPACE_TYPE = 'Undo'")[0][0]
    return f"tabla {table // 1024:>6} KB · history list length {history:>6} · undo {int(undo) // 1024 // 1024:>4} MB"


def main():
    admin = connect("mysql")
    for with_reader in (False, True):
        q(admin, "DROP TABLE IF EXISTS staging.mvcc_counter")
        q(admin, "CREATE TABLE staging.mvcc_counter (point_of_sale int PRIMARY KEY, last_number int NOT NULL)")
        q(admin, "INSERT INTO staging.mvcc_counter VALUES (1, 247581), (2, 69186), (3, 61895)")
        time.sleep(2)                                    # que el purge se ponga al día antes de empezar
        reader = None
        if with_reader:
            reader = connect("mysql")
            q(reader, "START TRANSACTION WITH CONSISTENT SNAPSHOT")
            q(reader, "SELECT count(*) FROM staging.mvcc_counter")
        print(f"\n10.000 UPDATE de una fila · lectura {'ABIERTA' if reader else 'cerrada'}")
        print("  antes:    " + state(admin))
        for _ in range(10_000):
            q(admin, "UPDATE staging.mvcc_counter SET last_number = last_number + 1 WHERE point_of_sale = 1")
        print("  después:  " + state(admin))
        if reader:
            print("  la lectura todavía ve: " + str(q(reader, "SELECT last_number FROM staging.mvcc_counter WHERE point_of_sale = 1")[0][0]))
            q(reader, "COMMIT")
            reader.close()
        time.sleep(5)
        print("  5 s después de cerrar la lectura: " + state(admin))
    admin.close()


if __name__ == "__main__":
    main()
