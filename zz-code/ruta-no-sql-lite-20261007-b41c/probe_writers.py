# Sondeo: varios escritores en el mismo proceso sobre un archivo DuckDB, actualizando contadores.
import duckdb, threading, os, sys, collections
DB = sys.argv[1]
for f in (DB, DB + ".wal"):
    if os.path.exists(f): os.remove(f)
con = duckdb.connect(DB)
con.execute("CREATE TABLE aircraft_hours (registration VARCHAR PRIMARY KEY, flight_minutes BIGINT)")
con.execute("INSERT INTO aircraft_hours SELECT 'HK-' || i, 0 FROM range(4000, 4017) t(i)")
errors = collections.Counter(); ok = collections.Counter()
def worker(w):
    cur = con.cursor()
    for i in range(2000):
        reg = f"HK-{4000 + (i * 7 + w) % 17}"
        try:
            cur.execute("UPDATE aircraft_hours SET flight_minutes = flight_minutes + 1 WHERE registration = ?", [reg])
            ok[w] += 1
        except Exception as e:
            errors[str(e).split("\n")[0][:160]] += 1
ts = [threading.Thread(target=worker, args=(w,)) for w in range(4)]
[t.start() for t in ts]; [t.join() for t in ts]
print("ok", sum(ok.values()), "errores", sum(errors.values()))
for k, v in errors.most_common(): print(v, k)
print("total minutos", con.sql("SELECT sum(flight_minutes) FROM aircraft_hours").fetchone())
