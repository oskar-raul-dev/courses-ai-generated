# Depuración: el Monitor de lab.race contra una espera real en MySQL.
import time
from lab.race import Session, Monitor
m = Monitor("mysql")
a, b = Session("mysql", "a"), Session("mysql", "b")
def go(s, label, sql):
    s.send(label, sql)
    for _ in range(400):
        out = s.finished()
        if out: return out
        if m.waiting(s.backend): return "BLOQUEADA"
        time.sleep(0.005)
    return "nada"
for s in (a, b):
    print(go(s, "x", "SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE"))
    print(go(s, "y", "START TRANSACTION"))
    print(go(s, "z", "SELECT specimen_id FROM staging.specimen s WHERE NOT EXISTS (SELECT 1 FROM staging.specimen_take t WHERE t.specimen_id = s.specimen_id) ORDER BY collected_at, specimen_id LIMIT 1"))
print(go(a, "w", "INSERT INTO staging.specimen_take (specimen_id, technician) VALUES (11231555, 'tecnico_a')"))
with m.conn.cursor() as cur:
    cur.execute("SELECT trx_mysql_thread_id, trx_state FROM information_schema.innodb_trx"); print(cur.fetchall(), a.backend)
    cur.execute("SELECT @@transaction_isolation, @@autocommit"); print(cur.fetchall())
b.close(); time.sleep(0.5); print(a.finished()); a.close()
