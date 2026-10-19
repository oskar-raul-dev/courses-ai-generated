# a04 · ¿innodb_trx muestra una espera que empezó mientras se la consultaba seguido?
# El monitor consulta desde antes del bloqueo, cada 5 ms o cada 200 ms, durante 2 s.
import threading, time
from lab.race import connect
def trial(interval):
    a, b, m = connect("mysql"), connect("mysql"), connect("mysql")
    with b.cursor() as c:
        c.execute("START TRANSACTION"); c.execute("SELECT balance FROM staging.debtor WHERE debtor_id = 1 FOR UPDATE")
    seen, n, end = 0, 0, time.monotonic() + 2
    t = threading.Timer(0.3, lambda: a.cursor().execute("UPDATE staging.debtor SET balance = balance WHERE debtor_id = 1"))
    with m.cursor() as c:
        t.start()
        while time.monotonic() < end:
            c.execute("SELECT count(*) FROM information_schema.innodb_trx WHERE trx_state = 'LOCK WAIT'")
            seen += c.fetchone()[0] > 0; n += 1; time.sleep(interval)
    b.rollback(); t.join(); time.sleep(0.2); a.close(); b.close(); m.close()
    print(f"cada {interval*1000:.0f} ms: {n} consultas en 2 s, la espera empezó a los 0,3 s; {seen} la vieron")
trial(0.005); trial(0.2)
