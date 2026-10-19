# Ejercicio 16 · el bucle de reintento con espera aleatoria creciente y un tope de intentos, 8 técnicos.
import random, sys, threading, time
sys.path.insert(0, "/src/15-aislamiento-comparado")
import psycopg
from lab.race import connect
from technicians import take_once, SERIALIZATION_FAILURE

def with_retry(conn, who, attempts=10, base=0.002):
    for attempt in range(attempts):
        try:
            take_once(conn, "serializable", who)
            return attempt
        except psycopg.Error as exc:
            if exc.sqlstate not in SERIALIZATION_FAILURE:
                raise
            time.sleep(random.uniform(0, base * 2 ** attempt))   # espera aleatoria, cada vez más larga
    raise RuntimeError(f"{who}: {attempts} intentos sin poder tomar una muestra")

def run(n, takes, base):
    admin = connect("postgres"); admin.execute("TRUNCATE staging.specimen_take")
    retries, gaveup, lock = [0], [0], threading.Lock()
    def tech(i):
        conn = connect("postgres")
        for _ in range(takes):
            try:
                r = with_retry(conn, f"tecnico_{i}", base=base)
                with lock: retries[0] += r
            except RuntimeError:
                with lock: gaveup[0] += 1
        conn.close()
    t0 = time.monotonic(); ts = [threading.Thread(target=tech, args=(i,)) for i in range(n)]
    [t.start() for t in ts]; [t.join() for t in ts]
    takes_, distinct = admin.execute("SELECT count(*), count(DISTINCT specimen_id) FROM staging.specimen_take").fetchone()
    print(f"| {n} | {base*1000:.0f} ms | {takes_} | {distinct} | {retries[0]} | {gaveup[0]} | {time.monotonic()-t0:.1f} |")
    admin.execute("TRUNCATE staging.specimen_take"); admin.close()

print("| técnicos | espera base | tomas | distintas | reintentos | abandonadas | segundos |\n|---|---|---|---|---|---|---|")
for base in (0.0, 0.002, 0.01):
    run(8, 50, base)
