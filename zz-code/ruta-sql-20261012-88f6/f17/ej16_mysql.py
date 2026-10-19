# Ejercicio 16 · cuánto tarda la foto vieja en MySQL: la lectura abierta contra una nueva, tras 10.000 y 100.000 cambios.
import time
from lab.race import connect
def q(c, sql):
    with c.cursor() as cur: cur.execute(sql); return cur.fetchall()
admin = connect("mysql")
q(admin, "DROP TABLE IF EXISTS staging.mvcc_counter")
q(admin, "CREATE TABLE staging.mvcc_counter (point_of_sale int PRIMARY KEY, last_number int NOT NULL)")
q(admin, "INSERT INTO staging.mvcc_counter VALUES (1, 247581)")
reader = connect("mysql"); q(reader, "START TRANSACTION WITH CONSISTENT SNAPSHOT"); q(reader, "SELECT 1 FROM staging.mvcc_counter")
done = 0
for target in (10_000, 100_000):
    while done < target:
        q(admin, "UPDATE staging.mvcc_counter SET last_number = last_number + 1 WHERE point_of_sale = 1"); done += 1
    for who, c in (("la lectura abierta", reader), ("una lectura nueva", admin)):
        t0 = time.perf_counter(); v = q(c, "SELECT last_number FROM staging.mvcc_counter WHERE point_of_sale = 1")[0][0]
        print(f"ej16 · {target:>7} cambios · {who:<18} ve {v} en {(time.perf_counter() - t0) * 1000:.2f} ms")
q(reader, "COMMIT")
