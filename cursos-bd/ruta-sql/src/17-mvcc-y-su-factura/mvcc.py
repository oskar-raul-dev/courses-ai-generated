"""Fase 17 · lo que cuesta una lectura larga mientras otros escriben (Postgres).

    uv run python 17-mvcc-y-su-factura/mvcc.py counter      la fila contador de la Fase 16, con y sin la exportación abierta
    uv run python 17-mvcc-y-su-factura/mvcc.py results      la apuesta: la media hora más cargada de la caja, corregida
    uv run python 17-mvcc-y-su-factura/mvcc.py para_llamar  la autopsia: ParaLlamar marcada fila por fila

"La exportación" es una conexión que abre una transacción `REPEATABLE READ`, lee, y no termina: retiene su foto, y con ella
el horizonte de `xmin` de toda la base. Cada medición se hace dos veces: sin la exportación y con ella abierta.
"""

import sys

from lab.race import connect


def size(conn, table):
    """Páginas de la tabla, y lo que pgstattuple encuentra adentro."""
    pages = conn.execute(f"SELECT pg_relation_size('{table}') / 8192").fetchone()[0]
    live, dead, free = conn.execute(
        f"SELECT tuple_count, dead_tuple_count, round(free_percent::numeric, 1) FROM pgstattuple('{table}')").fetchone()
    return {"pages": pages, "live": live, "dead": dead, "free": free}


def vacuum(conn, table):
    """VACUUM VERBOSE: las dos líneas que dicen qué pudo borrar y qué no."""
    notices = []
    conn.add_notice_handler(lambda d: notices.append(d.message_primary))
    conn.execute(f"VACUUM (VERBOSE) {table}")
    conn._notice_handlers.clear()
    text = "\n".join(notices)
    keep = [line.strip() for line in text.splitlines()
            if line.strip().startswith(("tuples:", "removable cutoff:", "pages:"))]
    return keep


def export_open(table="alameda.result"):
    """La exportación de las 22:00: una foto que no se suelta."""
    conn = connect("postgres")
    conn.execute("BEGIN ISOLATION LEVEL REPEATABLE READ")
    conn.execute(f"SELECT count(*) FROM {table} WHERE result_id < 1000").fetchone()
    return conn


def show(label, s):
    print(f"  {label:<38} {s['pages']:>6} páginas · {s['live']:>8} vivas · {s['dead']:>7} muertas · {s['free']:>5} % libre")


def counter():
    admin = connect("postgres")
    for with_export in (False, True):
        admin.execute("DROP TABLE IF EXISTS staging.mvcc_counter")
        admin.execute("CREATE TABLE staging.mvcc_counter (point_of_sale integer PRIMARY KEY, last_number integer NOT NULL)")
        admin.execute("INSERT INTO staging.mvcc_counter SELECT g, 247581 FROM generate_series(1, 6) g")
        export = export_open() if with_export else None
        print(f"\nla fila contador, 10.000 comprobantes del punto de venta 1 · exportación {'ABIERTA' if export else 'cerrada'}")
        show("antes", size(admin, "staging.mvcc_counter"))
        for _ in range(10_000):
            admin.execute("UPDATE staging.mvcc_counter SET last_number = last_number + 1 WHERE point_of_sale = 1")
        show("después de 10.000 UPDATE", size(admin, "staging.mvcc_counter"))
        admin.execute("SELECT pg_stat_force_next_flush()")    # las estadísticas de esta sesión, ya volcadas
        admin.execute("SELECT pg_stat_clear_snapshot()")
        hot = admin.execute("SELECT n_tup_upd, n_tup_hot_upd FROM pg_stat_user_tables "
                            "WHERE relid = 'staging.mvcc_counter'::regclass").fetchone()
        print(f"  actualizaciones: {hot[0]}, de ellas HOT: {hot[1]}")
        for line in vacuum(admin, "staging.mvcc_counter"):
            print("  VACUUM ·", line)
        show("después del VACUUM", size(admin, "staging.mvcc_counter"))
        if export:
            export.execute("COMMIT")
            export.close()
            for line in vacuum(admin, "staging.mvcc_counter"):
                print("  VACUUM con la exportación cerrada ·", line)
            show("después de ese VACUUM", size(admin, "staging.mvcc_counter"))
    admin.close()


def results():
    """La apuesta: la exportación abierta mientras se corrige la media hora más cargada de la caja."""
    admin = connect("postgres")
    peak = admin.execute("""
        SELECT date_trunc('hour', recorded_at) + (extract(minute FROM recorded_at)::int / 30) * interval '30 min' AS half, count(*)
        FROM alameda.result GROUP BY 1 ORDER BY 2 DESC LIMIT 1""").fetchone()
    print(f"la media hora más cargada: {peak[0]} con {peak[1]} resultados")
    day = peak[0].date()
    admin.execute("DROP TABLE IF EXISTS staging.result_day")
    admin.execute(f"CREATE TABLE staging.result_day AS SELECT * FROM alameda.result WHERE recorded_at::date = '{day}'")
    admin.execute("ALTER TABLE staging.result_day ADD PRIMARY KEY (result_id)")
    admin.execute("VACUUM ANALYZE staging.result_day")
    # La tabla entera, en una copia: el modelo de las otras fases no se toca.
    admin.execute("DROP TABLE IF EXISTS staging.result_copy")
    admin.execute("CREATE TABLE staging.result_copy AS SELECT * FROM alameda.result")
    admin.execute("ALTER TABLE staging.result_copy ADD PRIMARY KEY (result_id)")
    admin.execute("VACUUM ANALYZE staging.result_copy")
    for table in ("staging.result_day", "staging.result_copy"):
        export = export_open()
        before = size(admin, table)
        # Cada resultado de esa media hora, corregido una vez, de a uno, como en el formulario.
        ids = [r[0] for r in admin.execute(
            f"SELECT result_id FROM {table} WHERE recorded_at >= %s AND recorded_at < %s + interval '30 min'",
            (peak[0], peak[0])).fetchall()]
        for rid in ids:
            admin.execute(f"UPDATE {table} SET value_text = value_text WHERE result_id = %s", (rid,))
        after = size(admin, table)
        print(f"\n{table}: {len(ids)} correcciones con la exportación abierta")
        show("antes", before)
        show("después", after)
        print(f"  crecimiento: {after['pages'] / before['pages']:.4f} veces")
        export.execute("COMMIT")
        export.close()
        for line in vacuum(admin, table):
            print("  VACUUM ·", line)
        show("después del VACUUM", size(admin, table))
    admin.execute("DROP TABLE staging.result_copy")
    admin.close()


def para_llamar():
    """La autopsia: las marcas Llamado y LlamadoDos de 2020, de a una, contra anotar cada llamada en una tabla aparte."""
    admin = connect("postgres")
    period = "called_on >= '2020-03-01' AND called_on < '2021-01-01'"
    pending = f"SELECT count(*) FROM staging.para_llamar WHERE NOT called AND {period}"
    for with_export in (False, True):
        admin.execute("DROP TABLE IF EXISTS staging.para_llamar, staging.call_made")
        admin.execute("""CREATE TABLE staging.para_llamar AS
                         SELECT "ID" AS id, "Fecha" AS called_on, "Nombre" AS name, "Telefono" AS phone, "IdProtocolo" AS lab_order_id,
                                false AS called, false AS called_twice
                         FROM legacy."ParaLlamar" """)
        admin.execute("ALTER TABLE staging.para_llamar ADD PRIMARY KEY (id)")
        # La lista de pendientes: un índice parcial, como lo haría alguien que sabe de índices.
        admin.execute("CREATE INDEX para_llamar_pending_idx ON staging.para_llamar (called_on) WHERE NOT called")
        admin.execute("CREATE TABLE staging.call_made (id integer NOT NULL, attempt smallint NOT NULL, "
                      "called_at timestamptz NOT NULL DEFAULT now())")
        admin.execute("VACUUM ANALYZE staging.para_llamar")
        marks = admin.execute(f"""SELECT "ID", "LlamadoDos" FROM legacy."ParaLlamar"
                                  WHERE "Fecha" >= '2020-03-01' AND "Fecha" < '2021-01-01' ORDER BY "ID" """).fetchall()
        export = export_open() if with_export else None
        print(f"\nParaLlamar 2020: {len(marks)} llamadas y {sum(1 for _, t in marks if t)} segundas · "
              f"exportación {'ABIERTA' if export else 'cerrada'}")

        def wal(fn):
            start = admin.execute("SELECT pg_current_wal_insert_lsn()").fetchone()[0]
            fn()
            return admin.execute("SELECT pg_current_wal_insert_lsn() - %s::pg_lsn", (start,)).fetchone()[0]

        def by_update():                                    # cada llamada, una transacción, como el formulario
            for rid, twice in marks:
                admin.execute("UPDATE staging.para_llamar SET called = true WHERE id = %s", (rid,))
            for rid, twice in marks:
                if twice:
                    admin.execute("UPDATE staging.para_llamar SET called_twice = true WHERE id = %s", (rid,))

        def by_insert():
            for rid, twice in marks:
                admin.execute("INSERT INTO staging.call_made (id, attempt) VALUES (%s, 1)", (rid,))
            for rid, twice in marks:
                if twice:
                    admin.execute("INSERT INTO staging.call_made (id, attempt) VALUES (%s, 2)", (rid,))

        n = len(marks) + sum(1 for _, t in marks if t)
        w_upd = wal(by_update)
        w_ins = wal(by_insert)
        print(f"  marcar con UPDATE:  {w_upd:>9} bytes de WAL · {w_upd / n:6.0f} por llamada")
        print(f"  anotar con INSERT:  {w_ins:>9} bytes de WAL · {w_ins / n:6.0f} por llamada")
        show("para_llamar después de marcar", size(admin, "staging.para_llamar"))
        show("call_made después de anotar", size(admin, "staging.call_made"))
        for attempt in (1, 2):
            plan = admin.execute(f"EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) {pending}").fetchall()
            buffers = [line for (line,) in plan if "Buffers" in line][0].strip()
            heap = [line for (line,) in plan if "Heap Fetches" in line]
            print(f"  la lista de pendientes, lectura {attempt}: {buffers}" + (f" · {heap[0].strip()}" if heap else ""))
        if export:
            export.execute("COMMIT")
            export.close()
    admin.close()


if __name__ == "__main__":
    {"counter": counter, "results": results, "para_llamar": para_llamar}[sys.argv[1]]()
