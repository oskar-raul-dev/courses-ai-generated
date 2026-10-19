# Ejercicio 18 · los bloqueos de la actualización perdida en SERIALIZABLE de MySQL, mirados en medio de la carrera.
from lab.race import Race
LOCKS = ("SELECT t.PROCESSLIST_ID AS conn, l.LOCK_TYPE, l.LOCK_MODE, l.LOCK_STATUS, l.LOCK_DATA "
         "FROM performance_schema.data_locks l JOIN performance_schema.threads t ON t.THREAD_ID = l.THREAD_ID "
         "WHERE l.OBJECT_NAME = 'debtor' AND l.LOCK_TYPE = 'RECORD' ORDER BY conn, l.LOCK_STATUS")
def show(conn):
    with conn.cursor() as cur:
        cur.execute(LOCKS)
        return "\n      " + "\n      ".join(" ".join(str(x) for x in r) for r in cur.fetchall())
race = Race.from_file("/src/15-aislamiento-comparado/lost_update_mysql.race")
race.isolation = "SERIALIZABLE"
race.step("c1", show).step("c2", show)
race.run("a1 a2 a3 b1 b2 b3 c1 a4 c2 b4 a5 b5".split())
