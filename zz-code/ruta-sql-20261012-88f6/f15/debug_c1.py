import time
from lab.race import Session, Monitor
m = Monitor("mysql"); c = Session("mysql", "c")
LOCKS = "SELECT count(*) FROM performance_schema.data_locks"
def show(conn):
    with conn.cursor() as cur:
        cur.execute(LOCKS); return cur.fetchall()
t0 = time.monotonic(); c.send("c1", show)
while True:
    out = c.finished()
    if out: print("terminó", round(time.monotonic()-t0, 3), out.text); break
    w = m.waiting(c.backend)
    if w:
        with m.conn.cursor() as cur:
            cur.execute("SELECT * FROM performance_schema.metadata_locks ml JOIN performance_schema.threads t ON t.THREAD_ID = ml.OWNER_THREAD_ID WHERE t.PROCESSLIST_ID = %s", (c.backend,))
            print("waiting!", cur.fetchall()[:3])
    time.sleep(0.005)
