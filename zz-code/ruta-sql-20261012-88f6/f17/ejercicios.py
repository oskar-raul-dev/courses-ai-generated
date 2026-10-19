# F17 · los experimentos de las soluciones.
import sys, time
sys.path.insert(0, "/src/17-mvcc-y-su-factura")
from lab.race import Race, connect
from mvcc import size, vacuum, export_open, show

def fresh(admin, extra=""):
    admin.execute("DROP TABLE IF EXISTS staging.mvcc_counter")
    admin.execute(f"CREATE TABLE staging.mvcc_counter (point_of_sale integer PRIMARY KEY, last_number integer NOT NULL) {extra}")
    admin.execute("INSERT INTO staging.mvcc_counter SELECT g, 247581 FROM generate_series(1, 6) g")

def bump(admin, n=10_000):
    for _ in range(n):
        admin.execute("UPDATE staging.mvcc_counter SET last_number = last_number + 1 WHERE point_of_sale = 1")

def ej01():
    admin = connect("postgres"); fresh(admin)
    for i in range(4):
        print("ej01 ·", admin.execute("SELECT ctid, xmin, xmax, last_number FROM staging.mvcc_counter WHERE point_of_sale = 1").fetchone())
        if i < 3: admin.execute("UPDATE staging.mvcc_counter SET last_number = last_number + 1 WHERE point_of_sale = 1")

def ej02():
    admin = connect("postgres"); fresh(admin)
    sel = "SELECT xmin, last_number FROM staging.mvcc_counter WHERE point_of_sale = 1"
    r = Race("postgres"); r.isolation = "REPEATABLE READ"
    r.step("a1", "BEGIN ISOLATION LEVEL {isolation}").step("a2", sel)
    r.step("b1", "UPDATE staging.mvcc_counter SET last_number = last_number + 1 WHERE point_of_sale = 1")
    r.step("a3", sel).step("a4", "COMMIT").step("b2", sel)
    r.run("a1 a2 b1 a3 a4 b2".split())

def ej08():
    admin = connect("postgres"); fresh(admin); e = export_open(); bump(admin); e.execute("COMMIT"); e.close()
    vacuum(admin, "staging.mvcc_counter"); show("ej08 · antes de VACUUM FULL", size(admin, "staging.mvcc_counter"))
    admin.execute("VACUUM FULL staging.mvcc_counter"); show("ej08 · después de VACUUM FULL", size(admin, "staging.mvcc_counter"))

def stats(admin):
    admin.execute("SELECT pg_stat_force_next_flush()"); admin.execute("SELECT pg_stat_clear_snapshot()")
    return admin.execute("SELECT n_tup_upd, n_tup_hot_upd FROM pg_stat_user_tables WHERE relid = 'staging.mvcc_counter'::regclass").fetchone()

def ej09():
    admin = connect("postgres"); fresh(admin); admin.execute("CREATE INDEX mvcc_counter_last_idx ON staging.mvcc_counter (last_number)")
    bump(admin); u = stats(admin)
    idx = admin.execute("SELECT pg_relation_size('staging.mvcc_counter_last_idx') / 8192").fetchone()[0]
    show(f"ej09 · con índice: {u[0]} actualizaciones, {u[1]} HOT · tabla", size(admin, "staging.mvcc_counter")); print(f"ej09 · índice {idx} páginas")

def ej10():
    admin = connect("postgres"); fresh(admin, "WITH (fillfactor = 50)"); e = export_open(); bump(admin)
    show("ej10 · fillfactor 50, exportación abierta", size(admin, "staging.mvcc_counter")); e.execute("COMMIT"); e.close()

def ej11():
    admin = connect("postgres")
    admin.execute("DROP TABLE IF EXISTS staging.result_day2")
    admin.execute("CREATE TABLE staging.result_day2 AS SELECT * FROM alameda.result WHERE recorded_at::date = '2024-01-07'")
    admin.execute("ALTER TABLE staging.result_day2 ADD PRIMARY KEY (result_id)"); admin.execute("VACUUM ANALYZE staging.result_day2")
    n = admin.execute("SELECT count(*) FROM staging.result_day2").fetchone()[0]
    print(f"ej11 · {n} filas: umbral = 0,2 × {n} + 50 = {0.2 * n + 50:.0f}")
    admin.execute("UPDATE staging.result_day2 SET value_text = value_text WHERE result_id IN (SELECT result_id FROM staging.result_day2 ORDER BY result_id LIMIT 3000)")
    t0 = time.monotonic()
    while time.monotonic() - t0 < 180:
        row = admin.execute("SELECT n_dead_tup, last_autovacuum FROM pg_stat_user_tables WHERE relid = 'staging.result_day2'::regclass").fetchone()
        if row[1]: break
        time.sleep(5)
    print(f"ej11 · a los {time.monotonic() - t0:.0f} s: n_dead_tup {row[0]}, last_autovacuum {row[1]}")
    admin.execute("DROP TABLE staging.result_day2")

def ej12():
    admin = connect("postgres"); fresh(admin)
    e = connect("postgres"); e.execute("BEGIN ISOLATION LEVEL READ COMMITTED"); e.execute("SELECT count(*) FROM alameda.result WHERE result_id < 1000").fetchone()
    print("ej12 · backend_xmin de la exportación en READ COMMITTED, ociosa:",
          admin.execute("SELECT backend_xmin, state FROM pg_stat_activity WHERE pid = %s", (e.info.backend_pid,)).fetchone())
    bump(admin); show("ej12 · contador", size(admin, "staging.mvcc_counter")); e.execute("COMMIT"); e.close()

def ej13():
    admin = connect("postgres"); fresh(admin)
    e = connect("postgres"); e.execute("SET idle_in_transaction_session_timeout = '5s'")
    e.execute("BEGIN ISOLATION LEVEL REPEATABLE READ"); e.execute("SELECT count(*) FROM alameda.result WHERE result_id < 1000").fetchone()
    time.sleep(7)
    try:
        e.execute("SELECT 1")
    except Exception as exc:
        print("ej13 · la exportación:", type(exc).__name__, str(exc).strip().splitlines()[0])
    bump(admin); show("ej13 · contador después", size(admin, "staging.mvcc_counter"))

def ej15():
    admin = connect("postgres"); fresh(admin); e = export_open()
    for i in range(3):
        bump(admin); vacuum(admin, "staging.mvcc_counter"); show(f"ej15 · tanda {i + 1}", size(admin, "staging.mvcc_counter"))
    e.execute("COMMIT"); e.close()

def ej17():
    """La autopsia sin el índice parcial: la lista recorre la tabla."""
    admin = connect("postgres")
    period = "called_on >= '2020-03-01' AND called_on < '2021-01-01'"
    for with_export in (False, True):
        admin.execute("DROP TABLE IF EXISTS staging.para_llamar")
        admin.execute("""CREATE TABLE staging.para_llamar AS SELECT "ID" AS id, "Fecha" AS called_on, "Nombre" AS name,
                         "Telefono" AS phone, false AS called FROM legacy."ParaLlamar" """)
        admin.execute("ALTER TABLE staging.para_llamar ADD PRIMARY KEY (id)"); admin.execute("VACUUM ANALYZE staging.para_llamar")
        ids = [r[0] for r in admin.execute(f"SELECT id FROM staging.para_llamar WHERE {period}").fetchall()]
        e = export_open() if with_export else None
        for rid in ids: admin.execute("UPDATE staging.para_llamar SET called = true WHERE id = %s", (rid,))
        for k in (1, 2):
            plan = admin.execute(f"EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.para_llamar WHERE NOT called AND {period}").fetchall()
            print(f"ej17 · exportación {'abierta' if e else 'cerrada'}, lectura {k}:", " | ".join(l.strip() for (l,) in plan if "Buffers" in l or "Scan" in l))
        if e: e.execute("COMMIT"); e.close()

def ej18():
    admin = connect("postgres")
    e = export_open()
    q = """SELECT count(*) FROM staging.para_llamar p WHERE p.called_on >= '2020-03-01' AND p.called_on < '2021-01-01'
           AND NOT EXISTS (SELECT 1 FROM staging.call_made c WHERE c.id = p.id AND c.attempt = 1)"""
    for (line,) in admin.execute("EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) " + q).fetchall():
        print("ej18 ·", line)
    e.execute("COMMIT"); e.close()

def ej19():
    admin = connect("postgres"); fresh(admin)
    e = export_open("alameda.result")          # lee solo alameda.result
    bump(admin); show("ej19 · contador, con la exportación leyendo solo result", size(admin, "staging.mvcc_counter"))
    e.execute("COMMIT"); e.close()

for f in sys.argv[1:]:
    globals()[f]()
