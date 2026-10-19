# F18 · los mensajes completos (con DETAIL y HINT) del deadlock y de lock_timeout, para a08.
import threading, time, psycopg
from lab.race import connect
def diag(e):
    d = e.diag
    return "\n".join(x for x in (f"ERROR:  {d.message_primary}", d.message_detail and f"DETAIL:  {d.message_detail}",
                                 d.message_hint and f"HINT:  {d.message_hint}", d.context and f"CONTEXT:  {d.context}") if x)
a, b = connect("postgres"), connect("postgres")
for c in (a, b): c.execute("BEGIN")
a.execute("UPDATE staging.hemogram SET notes = 'a' WHERE hemogram_id = 1")
b.execute("UPDATE staging.hemogram SET notes = 'b' WHERE hemogram_id = 2")
out = []
def a2():
    try: a.execute("UPDATE staging.hemogram SET notes = 'a' WHERE hemogram_id = 2")
    except psycopg.Error as e: out.append(diag(e))
t = threading.Thread(target=a2); t.start(); time.sleep(0.3)
try: b.execute("UPDATE staging.hemogram SET notes = 'b' WHERE hemogram_id = 1")
except psycopg.Error as e: out.append(diag(e))
t.join(); print("\n---\n".join(out)); a.execute("ROLLBACK"); b.execute("ROLLBACK")
