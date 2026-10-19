# Ejercicio 19 · los SIReadLock de la muestra en SERIALIZABLE, mirados antes de los COMMIT.
from lab.race import Race
def locks(conn):
    rows = conn.execute("""
        SELECT a.application_name, l.pid = pg_backend_pid() AS yo, l.locktype, l.relation::regclass, l.page, l.tuple, l.mode, l.granted
        FROM pg_locks l LEFT JOIN pg_stat_activity a USING (pid)
        WHERE l.mode = 'SIReadLock' ORDER BY l.pid, l.locktype, l.relation::regclass::text""").fetchall()
    return "\n      " + "\n      ".join(f"pid {r[0] or '?'} {r[2]} {r[3]} página {r[4]} tupla {r[5]} {r[6]} {r[7]}" for r in rows)
race = Race.from_file("/src/15-aislamiento-comparado/write_skew.race")
race.isolation = "SERIALIZABLE"
race.step("a0", "SET application_name = 'a'").step("b0", "SET application_name = 'b'")
race.step("c1", locks)
race.run("a0 b0 a1 b1 a2 b2 a3 b3 c1 a4 b4".split())
