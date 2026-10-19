# F15 · los mensajes completos (con DETAIL y HINT) de los dos 40001, para a08.
import psycopg
from lab.race import connect
def diag(e):
    d = e.diag
    return f"ERROR:  {d.message_primary}\nDETAIL:  {d.message_detail}\nHINT:  {d.message_hint}"
a, b, m = connect("postgres"), connect("postgres"), connect("postgres")
m.execute("TRUNCATE staging.specimen_take")
for c in (a, b): c.execute("BEGIN ISOLATION LEVEL SERIALIZABLE")
for c in (a, b): c.execute("SELECT count(*) FROM staging.specimen_take WHERE specimen_id = 11231555").fetchone()
a.execute("INSERT INTO staging.specimen_take VALUES (11231555, 'tecnico_a')")
b.execute("INSERT INTO staging.specimen_take VALUES (11231555, 'tecnico_b')")
a.execute("COMMIT")
try: b.execute("COMMIT")
except psycopg.Error as e: print(diag(e)); b.execute("ROLLBACK")
m.execute("TRUNCATE staging.specimen_take"); m.execute("UPDATE staging.debtor SET balance = 28 WHERE debtor_id = 1")
for c in (a, b): c.execute("BEGIN ISOLATION LEVEL REPEATABLE READ"); c.execute("SELECT balance FROM staging.debtor WHERE debtor_id = 1").fetchone()
a.execute("UPDATE staging.debtor SET balance = 18 WHERE debtor_id = 1")
import threading
t = threading.Thread(target=lambda: None)
def bupd():
    try: b.execute("UPDATE staging.debtor SET balance = 23 WHERE debtor_id = 1")
    except psycopg.Error as e: print(diag(e))
t = threading.Thread(target=bupd); t.start()
import time; time.sleep(0.5); a.execute("COMMIT"); t.join(); b.execute("ROLLBACK")
m.execute("UPDATE staging.debtor SET balance = 28 WHERE debtor_id = 1")
