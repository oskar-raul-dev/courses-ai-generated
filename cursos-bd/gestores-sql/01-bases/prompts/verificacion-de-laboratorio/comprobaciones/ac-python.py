# P8 bloque A.C.: lmdb (¿trae LMDB incluido?) y ZODB, en un venv limpio.
import os, tempfile, lmdb, ZODB, ZODB.FileStorage, transaction, persistent
from importlib.metadata import version

d = tempfile.mkdtemp()
env = lmdb.open(os.path.join(d, "school.lmdb"), max_dbs=2, map_size=10 * 2**20)
enrollment = env.open_db(b"enrollment", dupsort=True)
with env.begin(write=True) as txn:
    for sid, sec in [(b"s1", b"7A"), (b"s1", b"8B"), (b"s2", b"7A")]:
        txn.put(sid, sec, db=enrollment)
with env.begin() as txn:
    cur = txn.cursor(db=enrollment)
    cur.set_key(b"s1")
    print("lmdb", version("lmdb"), "· LMDB C", ".".join(map(str, lmdb.version())),
          "· dupsort s1 ->", list(cur.iternext_dup()))

class Student(persistent.Persistent):
    def __init__(self, name): self.name, self.sections = name, []

db = ZODB.DB(ZODB.FileStorage.FileStorage(os.path.join(d, "school.fs")))
with db.transaction() as conn:
    conn.root.students = {"s1": Student("Ana")}
    conn.root.students["s1"].sections.append("7A")
with db.transaction() as conn:
    print("ZODB", version("ZODB"), "· persistent", version("persistent"),
          "· s1 ->", conn.root.students["s1"].name, conn.root.students["s1"].sections)
db.close()
