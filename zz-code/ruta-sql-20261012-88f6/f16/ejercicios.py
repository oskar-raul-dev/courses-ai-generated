# F16 · los experimentos de las soluciones 11, 14, 16, 17, 18, 19, 20 y 21.
import sys, threading, time, statistics
sys.path.insert(0, "/src/16-el-folio-sin-huecos")
from fiscal import FiscalService, Rejected, Timeout
from lab.race import Race, connect
import races

POS, KIND, START = 1, "B", 247581
TAKE = "UPDATE staging.invoice_counter SET last_number = last_number + 1 WHERE point_of_sale = %s AND kind = %s RETURNING last_number"

def reset(admin, ws, positions=(1,)):
    ws.reset(); admin.execute("TRUNCATE staging.invoice"); admin.execute("DELETE FROM staging.invoice_counter")
    for p in positions:
        last = admin.execute("SELECT last_number FROM fiscal.start WHERE point_of_sale = %s AND kind = 'B'", (p,)).fetchone()[0]
        admin.execute("INSERT INTO staging.invoice_counter VALUES (%s, 'B', %s)", (p, last))

def ej14():
    """Tres cajas, cada una con su punto de venta (1, 2 y 3), fila contador, 10 ms de armado con el número tomado."""
    ws = FiscalService(latency=0.001); admin = connect("postgres"); reset(admin, ws, (1, 2, 3))
    waits, lock = [], threading.Lock()
    def till(pos):
        conn = connect("postgres"); w = []
        for _ in range(500):
            with conn.transaction():
                t0 = time.monotonic(); n = conn.execute(TAKE, (pos, KIND)).fetchone()[0]; w.append(time.monotonic() - t0)
                time.sleep(0.010); cae = ws.request_cae(pos, KIND, n)
                conn.execute("INSERT INTO staging.invoice (point_of_sale, kind, number, cae, till) VALUES (%s, %s, %s, %s, 'x')", (pos, KIND, n, cae))
        with lock: waits.extend(w)
        conn.close()
    ts = [threading.Thread(target=till, args=(p,)) for p in (1, 2, 3)]; t0 = time.monotonic()
    [t.start() for t in ts]; [t.join() for t in ts]
    print(f"ej14 · 3 puntos de venta, 1.500 comprobantes: espera media {statistics.mean(waits)*1000:.2f} ms, total {time.monotonic()-t0:.1f} s")
    print("      autorizados por punto de venta:", admin.execute("SELECT string_agg(point_of_sale || ':' || n, ' ') FROM (SELECT point_of_sale, count(*) n FROM fiscal.authorized GROUP BY 1 ORDER BY 1) x").fetchone()[0])
    admin.close(); ws.close()

def ej16():
    """El comprobante que se armó primero puede recibir el número mayor (número al autorizar)."""
    ins = "INSERT INTO staging.invoice (point_of_sale, kind, till) VALUES (1, 'B', '%s') RETURNING invoice_id"
    def auth(who):
        def step(conn):
            with conn.transaction():
                n = conn.execute(TAKE, (POS, KIND)).fetchone()[0]
                cae = races.ws.request_cae(POS, KIND, n)
                conn.execute("UPDATE staging.invoice SET number = %s, cae = %s WHERE till = %s", (n, cae, who))
            return f"autorizado {n}"
        return step
    races.race([("a1", ins % "a"), ("b1", ins % "b"), ("b2", auth("b")), ("a2", auth("a"))], "a1 b1 b2 a2")

def ej17():
    """La reconciliación al abrir la caja, en sus tres casos."""
    ws = FiscalService(); admin = connect("postgres")
    def open_till():
        local = admin.execute("SELECT last_number FROM staging.invoice_counter WHERE point_of_sale = 1 AND kind = 'B'").fetchone()[0]
        remote = ws.last_authorized(POS, KIND)
        if local == remote:
            return f"caja {local} = organismo {remote}: abre"
        if remote > local:
            # El organismo autorizó números que la caja no registró (respuestas perdidas): se traen y se adelanta el contador.
            got = [(n, ws.query(POS, KIND, n)) for n in range(local + 1, remote + 1)]
            admin.execute("UPDATE staging.invoice_counter SET last_number = %s WHERE point_of_sale = 1 AND kind = 'B'", (remote,))
            return f"caja {local} < organismo {remote}: recupera {len(got)} CAE ({', '.join(str(n) for n, _ in got)}) y adelanta el contador"
        return f"caja {local} > organismo {remote}: la caja tomó números que el organismo no autorizó; no abre hasta revisarlos"
    for case in ("iguales", "organismo adelante", "caja adelante"):
        reset(admin, ws)
        if case == "organismo adelante":
            ws.request_cae(POS, KIND, START + 1); ws.request_cae(POS, KIND, START + 2)
        if case == "caja adelante":
            admin.execute("UPDATE staging.invoice_counter SET last_number = last_number + 1")
        print(f"ej17 · {case}: {open_till()}")
    admin.close(); ws.close()

def ej18():
    """La fila contador en SERIALIZABLE: la segunda caja falla en vez de esperar y seguir."""
    take = f"UPDATE staging.invoice_counter SET last_number = last_number + 1 WHERE point_of_sale = {POS} AND kind = '{KIND}' RETURNING last_number"
    races.race([("a1", "BEGIN ISOLATION LEVEL SERIALIZABLE"), ("a2", take),
                ("b1", "BEGIN ISOLATION LEVEL SERIALIZABLE"), ("b2", "SELECT 1"), ("b3", take),
                ("a3", "COMMIT"), ("b4", "ROLLBACK")], "a1 a2 b1 b2 b3 a3 b4")

def ej19():
    """La caja que muere con el número tomado: la conexión se corta, el servidor deshace, la siguiente sigue."""
    take = f"UPDATE staging.invoice_counter SET last_number = last_number + 1 WHERE point_of_sale = {POS} AND kind = '{KIND}' RETURNING last_number"
    races.race([("a1", "SET application_name = 'caja_a'"), ("a2", "BEGIN"), ("a3", take),
                ("b1", "BEGIN"), ("b2", take),
                ("c1", "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE application_name = 'caja_a'"),
                ("b3", "COMMIT")], "a1 a2 a3 b1 b2 c1 b3")

def ej20():
    """El organismo va un número adelante: la caja recibe 10016 aun con el diseño correcto, y se pone al día."""
    ws = FiscalService(); admin = connect("postgres"); reset(admin, ws)
    ws.request_cae(POS, KIND, START + 1)            # otro sistema autorizó el 247.582
    conn = connect("postgres")
    for attempt in range(3):
        try:
            with conn.transaction():
                n = conn.execute(TAKE, (POS, KIND)).fetchone()[0]
                cae = ws.request_cae(POS, KIND, n)
            print(f"ej20 · intento {attempt + 1}: autorizado {n}"); break
        except Rejected as e:
            remote = ws.last_authorized(POS, KIND)
            known = ws.query(POS, KIND, remote)
            admin.execute("UPDATE staging.invoice_counter SET last_number = %s WHERE point_of_sale = 1 AND kind = 'B'", (remote,))
            print(f"ej20 · intento {attempt + 1}: {e}; el organismo va en {remote} (CAE {known[:4]}…), el contador se pone al día")
    conn.close(); admin.close(); ws.close()

class BatchService(FiscalService):
    def request_cae_batch(self, pos, kind, numbers, reject_at=None):
        """Como el manual: si uno se rechaza, los siguientes no se procesan."""
        time.sleep(self.latency / 2); out = []
        with self.lock:
            for i, n in enumerate(numbers):
                if n != self._last(pos, kind) + 1 or (reject_at is not None and i == reject_at):
                    out += [(m, "rechazado" if j == 0 else "no procesado") for j, m in enumerate(numbers[i:])]; break
                self.conn.execute("INSERT INTO fiscal.authorized (point_of_sale, kind, number, cae) VALUES (%s, %s, %s, 'x')", (pos, kind, n))
                out.append((n, "autorizado"))
        time.sleep(self.latency / 2); return out

def ej21():
    ws = BatchService(latency=0.05); admin = connect("postgres")
    for size in (1, 10):
        reset(admin, ws); t0 = time.monotonic(); n = START
        for _ in range(100 // size):
            ws.request_cae_batch(POS, KIND, list(range(n + 1, n + 1 + size))); n += size
        print(f"ej21 · lotes de {size}: {(time.monotonic() - t0) / 100 * 1000:.1f} ms por comprobante")
    reset(admin, ws)
    res = ws.request_cae_batch(POS, KIND, list(range(START + 1, START + 11)), reject_at=4)
    print("ej21 · lote de 10 con el quinto rechazado:", " ".join(f"{n % 1000}:{r}" for n, r in res))
    admin.close(); ws.close()

for f in sys.argv[1:]:
    globals()[f]()
