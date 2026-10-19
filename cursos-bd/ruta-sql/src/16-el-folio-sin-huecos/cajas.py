"""Fase 16 · tres cajas emiten comprobantes a la vez contra el web service simulado, con cada diseño.

    uv run python 16-el-folio-sin-huecos/cajas.py --design counter --invoices 10000
    uv run python 16-el-folio-sin-huecos/cajas.py --design counter --hold 0.005 --invoices 1000

Hilos de verdad, sin orden fijo. Cada caja repite: arma el comprobante (`--hold` segundos de trabajo),
pide el número, lo autoriza en el organismo (`--latency`) y guarda el CAE. Diseños:

  dmax             el máximo más uno, sin transacción (2004); ante un 10016, vuelve a calcular
  ultimo_numero    UPDATE y SELECT del contador, sin transacción (2015); ante un 10016, se pone al día
                   con el último autorizado del organismo
  counter          la fila contador, reservada al principio y confirmada al final: el número queda
                   tomado mientras se arma el comprobante y mientras responde el organismo
  at_authorization el comprobante se guarda sin número; el número se toma en una transacción corta que
                   solo autoriza (sección 5.5)
  advisory         un advisory lock por punto de venta y el máximo más uno, en la misma transacción

Al final cuenta, contra el organismo: autorizados, números repetidos en la caja, comprobantes sin CAE,
huecos en lo autorizado y rechazos 10016; y la espera media por el número.
"""

import argparse
import statistics
import sys
import threading
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from fiscal import FiscalService, Rejected  # noqa: E402
from lab.race import connect  # noqa: E402

POS, KIND, START = 1, "B", 247581
TAKE = ("UPDATE staging.invoice_counter SET last_number = last_number + 1 "
        "WHERE point_of_sale = %s AND kind = %s RETURNING last_number")


def till(name, design, n, hold, ws, stats, lock):
    conn = connect("postgres")
    waits, rejected = [], 0
    for _ in range(n):
        while True:
            time.sleep(hold) if design != "counter" else None      # armar el comprobante, fuera del número
            try:
                if design == "dmax":
                    t0 = time.monotonic()
                    number = conn.execute("SELECT coalesce(max(number), %s) + 1 FROM staging.invoice WHERE cae IS NOT NULL",
                                          (START,)).fetchone()[0]
                    waits.append(time.monotonic() - t0)
                    ws.request_cae(POS, KIND, number)
                    conn.execute("INSERT INTO staging.invoice (point_of_sale, kind, number, cae, till) VALUES (%s, %s, %s, 'x', %s)",
                                 (POS, KIND, number, name))
                elif design == "ultimo_numero":
                    t0 = time.monotonic()
                    conn.execute("UPDATE staging.invoice_counter SET last_number = last_number + 1 WHERE point_of_sale = %s AND kind = %s",
                                 (POS, KIND))
                    number = conn.execute("SELECT last_number FROM staging.invoice_counter WHERE point_of_sale = %s AND kind = %s",
                                          (POS, KIND)).fetchone()[0]
                    waits.append(time.monotonic() - t0)
                    try:
                        ws.request_cae(POS, KIND, number)
                    except Rejected:
                        # Ponerse al día: lo que hizo la caja de 2015 después de cada rechazo.
                        last = ws.last_authorized(POS, KIND)
                        conn.execute("UPDATE staging.invoice_counter SET last_number = %s WHERE point_of_sale = %s AND kind = %s",
                                     (last, POS, KIND))
                        raise
                    conn.execute("INSERT INTO staging.invoice (point_of_sale, kind, number, cae, till) VALUES (%s, %s, %s, 'x', %s)",
                                 (POS, KIND, number, name))
                elif design in ("counter", "advisory"):
                    with conn.transaction():
                        t0 = time.monotonic()
                        if design == "counter":
                            number = conn.execute(TAKE, (POS, KIND)).fetchone()[0]
                        else:
                            conn.execute("SELECT pg_advisory_xact_lock(%s)", (POS,))
                            number = conn.execute("SELECT coalesce(max(number), %s) + 1 FROM staging.invoice "
                                                  "WHERE point_of_sale = %s AND kind = %s", (START, POS, KIND)).fetchone()[0]
                        waits.append(time.monotonic() - t0)
                        if design == "counter":
                            time.sleep(hold)                               # armar el comprobante con el número tomado
                        cae = ws.request_cae(POS, KIND, number)
                        conn.execute("INSERT INTO staging.invoice (point_of_sale, kind, number, cae, till) VALUES (%s, %s, %s, %s, %s)",
                                     (POS, KIND, number, cae, name))
                else:  # at_authorization
                    invoice = conn.execute("INSERT INTO staging.invoice (point_of_sale, kind, till) VALUES (%s, %s, %s) "
                                           "RETURNING invoice_id", (POS, KIND, name)).fetchone()[0]
                    with conn.transaction():
                        t0 = time.monotonic()
                        number = conn.execute(TAKE, (POS, KIND)).fetchone()[0]
                        waits.append(time.monotonic() - t0)
                        cae = ws.request_cae(POS, KIND, number)
                        conn.execute("UPDATE staging.invoice SET number = %s, cae = %s WHERE invoice_id = %s", (number, cae, invoice))
                break
            except Rejected:
                rejected += 1
    conn.close()
    with lock:
        stats["waits"] += waits
        stats["rejected"] += rejected


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("--design", default="counter",
                   choices=("dmax", "ultimo_numero", "counter", "at_authorization", "advisory"))
    p.add_argument("--tills", type=int, default=3)
    p.add_argument("--invoices", type=int, default=3000, help="en total, repartidos entre las cajas")
    p.add_argument("--hold", type=float, default=0.0, help="segundos que tarda armar un comprobante")
    p.add_argument("--latency", type=float, default=0.001, help="segundos de ida y vuelta al organismo")
    a = p.parse_args()
    ws = FiscalService(latency=a.latency)
    ws.reset()
    admin = connect("postgres")
    admin.execute("TRUNCATE staging.invoice")
    admin.execute("DELETE FROM staging.invoice_counter")
    admin.execute("INSERT INTO staging.invoice_counter VALUES (%s, %s, %s)", (POS, KIND, START))
    admin.execute("CREATE INDEX IF NOT EXISTS invoice_number_idx ON staging.invoice (point_of_sale, kind, number)")
    stats, lock = {"waits": [], "rejected": 0}, threading.Lock()
    share = [a.invoices // a.tills + (1 if i < a.invoices % a.tills else 0) for i in range(a.tills)]
    threads = [threading.Thread(target=till, args=(f"caja_{i + 1}", a.design, share[i], a.hold, ws, stats, lock))
               for i in range(a.tills)]
    started = time.monotonic()
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    seconds = time.monotonic() - started
    rows, distinct, without_cae = admin.execute(
        "SELECT count(*), count(DISTINCT number), count(*) FILTER (WHERE cae IS NULL) FROM staging.invoice").fetchone()
    authorized, lo, hi = admin.execute(
        "SELECT count(*), min(number), max(number) FROM fiscal.authorized WHERE point_of_sale = %s AND kind = %s",
        (POS, KIND)).fetchone()
    gaps = (hi - lo + 1 - authorized) if authorized else 0
    waits = sorted(stats["waits"])
    print(f"| {a.design} | {a.tills} | {a.hold * 1000:.0f} ms | {a.latency * 1000:.0f} ms | {authorized} | {rows - distinct} | "
          f"{without_cae} | {gaps} | {stats['rejected']} | {statistics.mean(waits) * 1000:.1f} ms | "
          f"{waits[int(len(waits) * 0.99)] * 1000:.1f} ms | {seconds:.1f} s |")
    admin.close()
    ws.close()


if __name__ == "__main__":
    main()
