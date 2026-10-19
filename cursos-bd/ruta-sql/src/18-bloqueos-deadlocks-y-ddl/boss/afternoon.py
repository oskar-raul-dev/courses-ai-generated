"""💀 Boss del Bloque III · la tarde de julio, corrida y medida. No se edita: se arregla `tills.py` (y la base, si hace falta).

    uv run python 18-bloqueos-deadlocks-y-ddl/boss/afternoon.py

Antes de cada corrida: `boss/01_july.sql`. Tres cajas emiten 450 comprobantes contra el organismo simulado (30 ms de ida y
vuelta, 20 ms para armar cada uno), cuatro técnicos toman 200 muestras y cargan su hemograma (0,2 s de trabajo con cada una),
y al segundo alguien abre el formulario de hemogramas y se va 10 s a almorzar. Un hilo mira cada 100 ms la transacción abierta
más vieja de la base. Al final, los cinco criterios del encargo.
"""

import sys
import threading
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent.parent / "16-el-folio-sin-huecos"))

import tills  # noqa: E402
from fiscal import FiscalService, Rejected  # noqa: E402
from lab.race import connect  # noqa: E402

TILLS, INVOICES, TECHNICIANS, TAKES, LUNCH = 3, 450, 4, 200, 10.0


def main():
    ws = FiscalService(latency=0.030)
    ws.reset()
    stats = {"rejected": 0, "errors": [], "waits": [], "form": None}
    lock = threading.Lock()

    def timed(fn, *args):
        t0 = time.monotonic()
        try:
            return fn(*args)
        finally:
            with lock:
                stats["waits"].append((time.monotonic() - t0, fn.__name__))

    def till(name, n):
        conn = connect("postgres")
        for _ in range(n):
            time.sleep(0.020)                                  # armar el comprobante
            while True:
                try:
                    timed(tills.issue_invoice, conn, ws, name)
                    break
                except Rejected:
                    with lock:
                        stats["rejected"] += 1
                except Exception as exc:                       # lo que el arreglo deje pasar, se cuenta
                    with lock:
                        stats["errors"].append(f"{name}: {type(exc).__name__}")
                    conn.rollback() if not conn.autocommit else None
        conn.close()

    def technician(name, n):
        conn = connect("postgres")
        for _ in range(n):
            time.sleep(0.2)                                    # procesar la muestra anterior
            try:
                sid = timed(tills.take_specimen, conn, name)
                timed(tills.load_hemogram, conn, name, sid)
            except Exception as exc:
                with lock:
                    stats["errors"].append(f"{name}: {type(exc).__name__}")
        conn.close()

    def form():
        time.sleep(1.0)
        conn = connect("postgres")
        try:
            stats["form"] = tills.lunch_form(conn, LUNCH)
        except Exception as exc:
            stats["form"] = f"{type(exc).__name__}: {str(exc).splitlines()[0]}"
        conn.close()

    running = [True]

    def sampler():
        """Cada 100 ms, la transacción abierta más vieja de la base (la que retiene el horizonte: Fase 17)."""
        conn = connect("postgres")
        while running[0]:
            row = conn.execute("""
                SELECT extract(epoch FROM now() - xact_start), left(regexp_replace(query, '\\s+', ' ', 'g'), 60) FROM pg_stat_activity
                WHERE datname = current_database() AND backend_type = 'client backend' AND xact_start IS NOT NULL
                  AND pid <> pg_backend_pid() ORDER BY xact_start LIMIT 1""").fetchone()
            if row and (stats.get("oldest") is None or row[0] > stats["oldest"][0]):
                stats["oldest"] = (float(row[0]), row[1])
            time.sleep(0.1)
        conn.close()

    watch = threading.Thread(target=sampler)
    watch.start()
    threads = [threading.Thread(target=till, args=(f"caja_{i + 1}", INVOICES // TILLS)) for i in range(TILLS)]
    threads += [threading.Thread(target=technician, args=(f"tecnico_{i + 1}", TAKES // TECHNICIANS)) for i in range(TECHNICIANS)]
    threads.append(threading.Thread(target=form))
    started = time.monotonic()
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    seconds = time.monotonic() - started
    running[0] = False
    watch.join()

    admin = connect("postgres")
    authorized = admin.execute("SELECT count(*) FROM fiscal.authorized").fetchone()[0]
    twice = admin.execute("SELECT count(*) FROM (SELECT specimen_id FROM staging.july_specimen_take "
                          "GROUP BY 1 HAVING count(*) > 1) d").fetchone()[0]
    taken = admin.execute("SELECT count(DISTINCT specimen_id) FROM staging.july_specimen_take").fetchone()[0]
    pages = admin.execute("SELECT pg_relation_size('staging.july_counter') / 8192").fetchone()[0]
    kept = admin.execute("SELECT count(*) FROM staging.july_hemogram WHERE loaded_by = 'formulario'").fetchone()[0]
    worst = max(stats["waits"])
    admin.close()
    ws.close()
    ok = lambda b: "✅" if b else "❌"
    print(f"La tarde de julio · {seconds:.1f} s")
    print(f"  comprobantes autorizados: {authorized} de {INVOICES} · rechazos 10016: {stats['rejected']}")
    print(f"  muestras tomadas: {taken} distintas · tomadas dos veces o más: {twice}")
    print(f"  la espera más larga: {worst[0]:.2f} s, en {worst[1]}")
    oldest = stats.get("oldest") or (0.0, "")
    print(f"  la transacción más larga: {oldest[0]:.1f} s ({oldest[1]})")
    print(f"  el contador terminó en {pages} página(s)")
    print(f"  el formulario: {stats['form']} · su corrección {'está' if kept else 'no está'} en la base")
    if stats["errors"]:
        print(f"  errores que vio alguien: {len(stats['errors'])} (el primero: {stats['errors'][0]})")
    print("Criterios del encargo:")
    print(f"  {ok(stats['rejected'] == 0 and authorized == INVOICES)} 1. ningún rechazo 10016, y los {INVOICES} autorizados")
    print(f"  {ok(twice == 0 and taken == TAKES)} 2. ninguna muestra tomada dos veces, y las {TAKES} tomadas")
    print(f"  {ok(worst[0] <= 2.0)} 3. ninguna caja ni técnico esperó más de 2 s")
    print(f"  {ok(oldest[0] <= 2.0)} 4. ninguna transacción estuvo abierta más de 2 s")
    form_ok = (stats["form"] == "guardado" and kept == 1) or stats["form"] == "conflicto"
    print(f"  {ok(form_ok and not stats['errors'])} 5. el formulario guardó su corrección o avisó del conflicto, y nadie vio un error")


if __name__ == "__main__":
    main()
