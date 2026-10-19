"""ss02 ej19 · la toma de muestra en SNAPSHOT, con reintento del 3960 y del 1205. Cuatro hilos, cien tomas."""
import random
import sys
import threading
import time
sys.path.insert(0, "/src")
from lab.engines import sqlserver

RETRY = ("3960", "1205")


def take(conn, technician: str) -> int:
    """Toma la primera muestra libre y devuelve cuántos intentos hicieron falta."""
    for attempt in range(1, 21):
        cur = conn.cursor()
        try:
            cur.execute("SET TRANSACTION ISOLATION LEVEL SNAPSHOT; BEGIN TRAN;")
            cur.execute("SELECT TOP (1) specimen_id FROM dbo.specimen AS s WHERE NOT EXISTS "
                        "(SELECT 1 FROM dbo.specimen_take AS t WHERE t.specimen_id = s.specimen_id) "
                        "ORDER BY collected_at, specimen_id")
            specimen = cur.fetchone()[0]
            # La toma marca la muestra: así dos tomas de la misma muestra chocan en la misma fila (3960).
            cur.execute("UPDATE dbo.specimen SET site_code = site_code WHERE specimen_id = ?", (specimen,))
            cur.execute("INSERT INTO dbo.specimen_take (specimen_id, technician) VALUES (?, ?)", (specimen, technician))
            cur.execute("COMMIT")
            return attempt
        except Exception as exc:
            c2 = conn.cursor()
            c2.execute("SELECT @@ERROR, @@TRANCOUNT")
            code, open_tx = c2.fetchone()
            if open_tx:
                c2.execute("ROLLBACK")
            if str(code) not in RETRY and not any(r in str(exc) for r in ("update conflict", "deadlock")):
                raise
            # La espera aleatoria de la Fase 15: base 2 ms, que se duplica, con tope. Sin ella, los cuatro chocan siempre.
            time.sleep(random.uniform(0, 0.002 * 2 ** min(attempt, 6)))
    raise RuntimeError("veinte intentos sin tomar")


def worker(name: str, n: int, tries: list) -> None:
    conn = sqlserver.connect("ss02")
    for _ in range(n):
        tries.append(take(conn, name))
    conn.close()


admin = sqlserver.connect("ss02")
admin.cursor().execute("TRUNCATE TABLE dbo.specimen_take")
tries: list = []
threads = [threading.Thread(target=worker, args=(f"tecnico_{i}", 25, tries)) for i in range(4)]
for t in threads: t.start()
for t in threads: t.join()
cur = admin.cursor()
cur.execute("SELECT COUNT(*), COUNT(DISTINCT specimen_id) FROM dbo.specimen_take")
total, distinct = cur.fetchone()
print(f"🔒 PRIVADO · tomas {total} · muestras distintas {distinct} · duplicadas {total - distinct} · "
      f"intentos {sum(tries)} para {len(tries)} tomas")
admin.cursor().execute("TRUNCATE TABLE dbo.specimen_take")
