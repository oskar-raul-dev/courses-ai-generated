"""Fase 18 · el ALTER TABLE de las diez de la mañana, con la exportación de la noche todavía abierta (Postgres).

    uv run python 18-bloqueos-deadlocks-y-ddl/ten_am.py

La exportación tiene leída `staging.result_ddl` desde antes. A las "diez", alguien agrega una columna con un valor volátil (la
tabla se reescribe). Desde ese momento, cada 100 ms llega una lectura de un resultado, como las pantallas del laboratorio. A los
3 s la exportación termina. Se mide cuánto esperó cada lectura. Después, lo mismo con `lock_timeout = '1s'` y un reintento
en el ALTER, y con un ALTER que no reescribe.
"""

import threading
import time

from lab.race import connect

READ = "SELECT value_text FROM staging.result_ddl WHERE result_id = %s"


def scenario(alter: str, lock_timeout: str | None, label: str) -> None:
    export = connect("postgres")
    export.execute("BEGIN ISOLATION LEVEL REPEATABLE READ")
    export.execute("SELECT count(*) FROM staging.result_ddl WHERE result_id < 1000").fetchone()
    result = {}

    def run_alter():
        conn = connect("postgres")
        if lock_timeout:
            conn.execute(f"SET lock_timeout = '{lock_timeout}'")
        t0, attempts = time.monotonic(), 0
        while True:
            attempts += 1
            try:
                conn.execute(alter)
                break
            except Exception:                         # 55P03: se rinde, deja pasar a la cola, y reintenta
                time.sleep(0.5)
        result["alter"] = (time.monotonic() - t0, attempts)
        conn.close()

    waits = []

    def reader(i):
        conn = connect("postgres")
        t0 = time.monotonic()
        conn.execute(READ, (i + 1,)).fetchone()
        waits.append(time.monotonic() - t0)
        conn.close()

    t = threading.Thread(target=run_alter)
    t.start()
    time.sleep(0.2)                                    # el ALTER ya está en la cola
    readers = []
    started = time.monotonic()
    while time.monotonic() - started < 3.0:
        r = threading.Thread(target=reader, args=(len(readers),))
        r.start()
        readers.append(r)
        time.sleep(0.1)
    export.execute("COMMIT")                           # 3 s después, la exportación termina
    export.close()
    for r in readers:
        r.join()
    t.join()
    waits.sort()
    over = sum(1 for w in waits if w > 1.0)
    print(f"| {label} | {len(waits)} | {over} | {waits[len(waits) // 2]:.2f} s | {waits[-1]:.2f} s | "
          f"{result['alter'][0]:.1f} s en {result['alter'][1]} intento(s) |")


def main():
    conn = connect("postgres")
    conn.execute("ALTER TABLE staging.result_ddl DROP COLUMN IF EXISTS loaded_at")
    conn.execute("ALTER TABLE staging.result_ddl DROP COLUMN IF EXISTS is_final")
    print("| ALTER | lecturas | esperaron más de 1 s | mediana | la peor | el ALTER |")
    print("|---|---|---|---|---|---|")
    scenario("ALTER TABLE staging.result_ddl ADD COLUMN is_final boolean NOT NULL DEFAULT false", None,
             "constante, sin lock_timeout (la apuesta)")
    conn.execute("ALTER TABLE staging.result_ddl DROP COLUMN IF EXISTS is_final")
    scenario("ALTER TABLE staging.result_ddl ADD COLUMN loaded_at timestamptz DEFAULT clock_timestamp()", None,
             "volátil, sin lock_timeout (las diez de la mañana)")
    conn.execute("ALTER TABLE staging.result_ddl DROP COLUMN IF EXISTS loaded_at")
    scenario("ALTER TABLE staging.result_ddl ADD COLUMN loaded_at timestamptz DEFAULT clock_timestamp()", "1s",
             "volátil, lock_timeout 1 s y reintento")
    conn.execute("ALTER TABLE staging.result_ddl DROP COLUMN IF EXISTS loaded_at")
    scenario("ALTER TABLE staging.result_ddl ADD COLUMN is_final boolean NOT NULL DEFAULT false", "1s",
             "constante, lock_timeout 1 s y reintento")
    conn.execute("ALTER TABLE staging.result_ddl DROP COLUMN IF EXISTS is_final")
    conn.close()


if __name__ == "__main__":
    main()
