# F18 · los experimentos de las soluciones.
import sys, threading, time
from lab.race import Race, connect

def ej09():
    r = Race("postgres")
    for l, sql in [("a1", "BEGIN"), ("b1", "BEGIN"),
                   ("a2", "UPDATE staging.hemogram SET notes = 'a' WHERE hemogram_id = 1"),
                   ("b2", "UPDATE staging.hemogram SET notes = 'b' WHERE hemogram_id = 1"),
                   ("a3", "UPDATE staging.hemogram SET notes = 'a' WHERE hemogram_id = 2"),
                   ("a4", "ROLLBACK"),
                   ("b3", "UPDATE staging.hemogram SET notes = 'b' WHERE hemogram_id = 2"), ("b4", "ROLLBACK")]:
        r.step(l, sql)
    r.run("a1 b1 a2 b2 a3 a4 b3 b4".split())

def ej10():
    r = Race("postgres")
    for l, sql in [("a1", "BEGIN"), ("b1", "BEGIN"),
                   ("a2", "SELECT hematocrit FROM staging.hemogram WHERE hemogram_id = 1 FOR SHARE"),
                   ("b2", "SELECT hematocrit FROM staging.hemogram WHERE hemogram_id = 1 FOR SHARE"),
                   ("a3", "UPDATE staging.hemogram SET notes = 'a' WHERE hemogram_id = 1"),
                   ("b3", "UPDATE staging.hemogram SET notes = 'b' WHERE hemogram_id = 1"),
                   ("a4", "ROLLBACK"), ("b4", "ROLLBACK")]:
        r.step(l, sql)
    r.run("a1 b1 a2 b2 a3 b3 a4 b4".split())

def ej14():
    conn = connect("postgres")
    conn.execute("ALTER TABLE staging.result_ddl DROP CONSTRAINT IF EXISTS result_ddl_has_value")
    t0 = time.monotonic()
    conn.execute("ALTER TABLE staging.result_ddl ADD CONSTRAINT result_ddl_has_value "
                 "CHECK (value_text IS NOT NULL OR value_numeric IS NOT NULL OR sample_flag IS NOT NULL) NOT VALID")
    print(f"ej14 · ADD CONSTRAINT … NOT VALID: {(time.monotonic() - t0) * 1000:.0f} ms")
    done = {}
    def validate():
        c = connect("postgres"); t = time.monotonic()
        try:
            c.execute("ALTER TABLE staging.result_ddl VALIDATE CONSTRAINT result_ddl_has_value"); done["ok"] = True
        except Exception as e:
            done["error"] = str(e).splitlines()[0]
        done["s"] = time.monotonic() - t; c.close()
    th = threading.Thread(target=validate); th.start(); time.sleep(0.5)
    mode = conn.execute("SELECT mode FROM pg_locks WHERE relation = 'staging.result_ddl'::regclass AND granted "
                        "AND pid <> pg_backend_pid()").fetchall()
    w = connect("postgres"); t0 = time.monotonic()
    w.execute("UPDATE staging.result_ddl SET value_text = value_text WHERE result_id = 2"); waited = time.monotonic() - t0
    th.join(); w.close()
    print(f"ej14 · VALIDATE CONSTRAINT: {done.get('s', 0):.1f} s · {done.get('error', 'válida')} · bloqueo {[m[0] for m in mode]} · "
          f"una escritura durante la validación esperó {waited * 1000:.0f} ms")
    conn.execute("ALTER TABLE staging.result_ddl DROP CONSTRAINT IF EXISTS result_ddl_has_value")

def ej14b():
    """La misma medición con una restricción que los datos sí cumplen."""
    conn = connect("postgres")
    conn.execute("ALTER TABLE staging.result_ddl DROP CONSTRAINT IF EXISTS result_ddl_since_1996")
    t0 = time.monotonic()
    conn.execute("ALTER TABLE staging.result_ddl ADD CONSTRAINT result_ddl_since_1996 CHECK (recorded_at >= '1996-01-01') NOT VALID")
    print(f"ej14b · ADD CONSTRAINT … NOT VALID: {(time.monotonic() - t0) * 1000:.0f} ms")
    done = {}
    def validate():
        c = connect("postgres"); t = time.monotonic()
        c.execute("ALTER TABLE staging.result_ddl VALIDATE CONSTRAINT result_ddl_since_1996"); done["s"] = time.monotonic() - t; c.close()
    th = threading.Thread(target=validate); th.start(); time.sleep(0.3)
    mode = conn.execute("SELECT mode FROM pg_locks WHERE relation = 'staging.result_ddl'::regclass AND granted "
                        "AND pid <> pg_backend_pid()").fetchall()
    w = connect("postgres"); t0 = time.monotonic()
    w.execute("UPDATE staging.result_ddl SET value_text = value_text WHERE result_id = 2"); waited = time.monotonic() - t0
    th.join(); w.close()
    print(f"ej14b · VALIDATE CONSTRAINT: {done['s']:.1f} s · bloqueo {[m[0] for m in mode]} · una escritura durante la validación esperó {waited * 1000:.0f} ms")
    conn.execute("ALTER TABLE staging.result_ddl DROP CONSTRAINT result_ddl_since_1996")

def ej18():
    """La toma de muestras de la Fase 15 en MySQL, con SKIP LOCKED y el estado en la fila."""
    admin = connect("mysql")
    with admin.cursor() as c:
        c.execute("ALTER TABLE staging.specimen ADD COLUMN taken_by varchar(30)") if not _has_col(admin) else None
        c.execute("UPDATE staging.specimen SET taken_by = NULL WHERE taken_by IS NOT NULL")
    def take(who):
        def step(conn):
            with conn.cursor() as c:
                c.execute("SELECT specimen_id FROM staging.specimen WHERE taken_by IS NULL ORDER BY collected_at, specimen_id "
                          "LIMIT 1 FOR UPDATE SKIP LOCKED")
                row = c.fetchone()
                if row is None:
                    return "ninguna muestra libre: todas saltadas"
                sid = row[0]
                c.execute("UPDATE staging.specimen SET taken_by = %s WHERE specimen_id = %s", (who, sid))
            return sid
        return step
    for with_index in (False, True):
        with admin.cursor() as c:
            c.execute("UPDATE staging.specimen SET taken_by = NULL WHERE taken_by IS NOT NULL")
            c.execute("SELECT count(*) FROM information_schema.statistics WHERE table_schema = 'staging' "
                      "AND table_name = 'specimen' AND index_name = 'specimen_pending_idx'")
            exists = c.fetchone()[0] > 0
            if with_index and not exists:
                c.execute("CREATE INDEX specimen_pending_idx ON staging.specimen (taken_by, collected_at, specimen_id)")
            if not with_index and exists:
                c.execute("DROP INDEX specimen_pending_idx ON staging.specimen")
        print(f"ej18 · {'con' if with_index else 'sin'} índice (taken_by, collected_at, specimen_id)")
        r = Race("mysql", checks=["SELECT specimen_id, taken_by FROM staging.specimen WHERE taken_by IS NOT NULL ORDER BY specimen_id"])
        r.step("a1", "START TRANSACTION").step("b1", "START TRANSACTION")
        r.step("a2", take("tecnico_a")).step("b2", take("tecnico_b")).step("a3", "COMMIT").step("b3", "COMMIT")
        r.run("a1 b1 a2 b2 a3 b3".split())

def _has_col(conn):
    with conn.cursor() as c:
        c.execute("SELECT count(*) FROM information_schema.columns WHERE table_schema = 'staging' AND table_name = 'specimen' AND column_name = 'taken_by'")
        return c.fetchone()[0] > 0

def ej16():
    TREE = """
    WITH RECURSIVE waits AS (
        SELECT pid, unnest(pg_blocking_pids(pid)) AS blocker FROM pg_stat_activity WHERE cardinality(pg_blocking_pids(pid)) > 0
    ), chain AS (
        SELECT pid, blocker, ARRAY[pid, blocker] AS path FROM waits
        UNION ALL
        SELECT c.pid, w.blocker, c.path || w.blocker FROM chain c JOIN waits w ON w.pid = c.blocker
        WHERE NOT w.blocker = ANY (c.path)
    )
    SELECT pid, path FROM chain c WHERE NOT EXISTS (SELECT 1 FROM waits w WHERE w.pid = c.blocker) ORDER BY pid"""
    r = Race.from_file("/src/18-bloqueos-deadlocks-y-ddl/ddl_queue.race")
    r.step("d1", lambda conn: conn.execute(TREE).fetchall())
    r.run("a1 a2 b1 c1 d1 a3".split())

def ej19():
    """El 1205 bien manejado: deshacer todo, esperar y reintentar con tope."""
    import pymysql
    admin = connect("mysql")
    with admin.cursor() as c:
        c.execute("DROP TABLE IF EXISTS staging.payment"); c.execute("CREATE TABLE staging.payment (debtor_id int NOT NULL, amount decimal(12,2) NOT NULL)")
    holder = connect("mysql")
    def hold():
        with holder.cursor() as c:
            c.execute("START TRANSACTION"); c.execute("SELECT balance FROM staging.debtor WHERE debtor_id = 1 FOR UPDATE")
        time.sleep(2.5); holder.rollback()
    t = threading.Thread(target=hold); t.start(); time.sleep(0.2)
    conn = connect("mysql")
    with conn.cursor() as c: c.execute("SET SESSION innodb_lock_wait_timeout = 1")
    for attempt in range(1, 6):
        try:
            with conn.cursor() as c:
                c.execute("START TRANSACTION")
                c.execute("INSERT INTO staging.payment VALUES (1, 10.00)")
                c.execute("UPDATE staging.debtor SET balance = balance - 10 WHERE debtor_id = 1")
                c.execute("COMMIT")
            print(f"ej19 · intento {attempt}: confirmado"); break
        except pymysql.err.OperationalError as e:
            conn.rollback()                                   # el 1205 dejó la transacción abierta: se deshace entera
            print(f"ej19 · intento {attempt}: {e.args[0]} {e.args[1]} → ROLLBACK y reintento")
            time.sleep(0.5)
    t.join()
    with admin.cursor() as c:
        c.execute("SELECT count(*) FROM staging.payment"); print("ej19 · pagos:", c.fetchone()[0])
        c.execute("UPDATE staging.debtor SET balance = balance + 10 WHERE debtor_id = 1")

def ej20():
    """El formulario optimista: guarda, o avisa con el valor nuevo."""
    def form(conn, hid, new_value, other=None):
        value, version = conn.execute("SELECT hematocrit, version FROM staging.hemogram WHERE hemogram_id = %s", (hid,)).fetchone()
        if other: other()                                   # mientras el usuario mira la pantalla
        saved = conn.execute("UPDATE staging.hemogram SET hematocrit = %s, version = version + 1 "
                             "WHERE hemogram_id = %s AND version = %s", (new_value, hid, version)).rowcount
        if saved:
            return f"guardado {new_value} (la versión {version} pasó a {version + 1})"
        now = conn.execute("SELECT hematocrit, version FROM staging.hemogram WHERE hemogram_id = %s", (hid,)).fetchone()
        return f"conflicto: abriste {value} (versión {version}); ahora dice {now[0]} (versión {now[1]}). No se guardó {new_value}."
    a, b = connect("postgres"), connect("postgres")
    a.execute("UPDATE staging.hemogram SET hematocrit = '41', version = 1 WHERE hemogram_id = 1")
    print("ej20 · solo:", form(a, 1, "40"))
    print("ej20 · con otro en el medio:", form(a, 1, "39", other=lambda: b.execute(
        "UPDATE staging.hemogram SET hematocrit = '42', version = version + 1 WHERE hemogram_id = 1")))

def ej21():
    conn = connect("postgres")
    conn.execute("ALTER TABLE staging.result_ddl DROP COLUMN IF EXISTS loaded_at")
    t0 = time.monotonic(); conn.execute("ALTER TABLE staging.result_ddl ADD COLUMN loaded_at timestamptz")
    print(f"ej21 · ADD COLUMN sin valor: {(time.monotonic() - t0) * 1000:.0f} ms")
    t0 = time.monotonic(); conn.execute("ALTER TABLE staging.result_ddl ALTER COLUMN loaded_at SET DEFAULT clock_timestamp()")
    print(f"ej21 · SET DEFAULT para las filas nuevas: {(time.monotonic() - t0) * 1000:.0f} ms")
    hi = conn.execute("SELECT max(result_id) FROM staging.result_ddl").fetchone()[0]
    reader_waits, stop = [], [False]
    def reader():
        c = connect("postgres")
        while not stop[0]:
            t = time.monotonic(); c.execute("SELECT value_text FROM staging.result_ddl WHERE result_id = 7").fetchone()
            reader_waits.append(time.monotonic() - t); time.sleep(0.05)
        c.close()
    th = threading.Thread(target=reader); th.start()
    batch, times, lo = 500_000, [], 0
    while lo <= hi:
        t = time.monotonic()
        conn.execute("UPDATE staging.result_ddl SET loaded_at = recorded_at WHERE result_id > %s AND result_id <= %s AND loaded_at IS NULL",
                     (lo, lo + batch))
        times.append(time.monotonic() - t); lo += batch
    stop[0] = True; th.join()
    print(f"ej21 · {len(times)} lotes de {batch:,} ids · el más largo {max(times):.1f} s · total {sum(times):.0f} s · "
          f"la lectura más lenta durante los lotes {max(reader_waits) * 1000:.0f} ms en {len(reader_waits)} lecturas")
    conn.execute("ALTER TABLE staging.result_ddl DROP COLUMN loaded_at"); conn.execute("VACUUM staging.result_ddl")

for f in sys.argv[1:]:
    globals()[f]()
