# Depuración: qué muestra el catálogo de MySQL mientras un INSERT espera en SERIALIZABLE.
import threading, time
from lab.race import connect
a, b, m = connect("mysql"), connect("mysql"), connect("mysql")
for c in (a, b):
    with c.cursor() as cur:
        cur.execute("SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE")
        cur.execute("START TRANSACTION")
        cur.execute("SELECT specimen_id FROM staging.specimen s WHERE NOT EXISTS (SELECT 1 FROM staging.specimen_take t "
                    "WHERE t.specimen_id = s.specimen_id) ORDER BY collected_at, specimen_id LIMIT 1")
        print(cur.fetchall())
def ins():
    try:
        with a.cursor() as cur:
            cur.execute("INSERT INTO staging.specimen_take (specimen_id, technician) VALUES (11231555, 'tecnico_a')")
        print("a insertó")
    except Exception as e:
        print("a:", e)
t = threading.Thread(target=ins); t.start(); time.sleep(1)
with m.cursor() as cur:
    print("thread ids", a.thread_id(), b.thread_id())
    cur.execute("SELECT trx_mysql_thread_id, trx_state, left(trx_query,40) FROM information_schema.innodb_trx")
    print(cur.fetchall())
    cur.execute("SELECT REQUESTING_THREAD_ID, BLOCKING_THREAD_ID FROM performance_schema.data_lock_waits")
    print(cur.fetchall())
    cur.execute("SELECT id, state, left(info,40) FROM information_schema.processlist WHERE command <> 'Sleep'")
    print(cur.fetchall())
b.rollback(); t.join(); a.rollback()
