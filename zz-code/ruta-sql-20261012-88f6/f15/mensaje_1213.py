# F15 · el 1213 tal como lo levanta PyMySQL.
import threading, time
from lab.race import connect
a, b = connect("mysql"), connect("mysql")
for c in (a, b):
    cur = c.cursor(); cur.execute("SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE"); cur.execute("START TRANSACTION")
    cur.execute("SELECT balance FROM staging.debtor WHERE debtor_id = 1")
t = threading.Thread(target=lambda: a.cursor().execute("UPDATE staging.debtor SET balance = 18 WHERE debtor_id = 1")); t.start(); time.sleep(0.5)
try:
    b.cursor().execute("UPDATE staging.debtor SET balance = 23 WHERE debtor_id = 1")
except Exception as e:
    print(f"{type(e).__module__}.{type(e).__name__}: {e}")
t.join(); a.rollback(); b.rollback()
