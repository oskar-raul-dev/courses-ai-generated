# P8: qué pasa si se copia solo el .db mientras el -wal tiene cambios sin volcar.
import os, shutil, sqlite3, subprocess

os.chdir("/tmp")
for f in ("w.db", "w.db-wal", "w.db-shm", "copy.db", "copy.db-wal", "copy.db-shm"):
    if os.path.exists(f):
        os.remove(f)

conn = sqlite3.connect("w.db")
conn.execute("PRAGMA journal_mode = WAL")
conn.execute("PRAGMA wal_autocheckpoint = 0")   # que nada se vuelque solo
conn.execute("CREATE TABLE supplier (supplier_id INTEGER PRIMARY KEY, name TEXT) STRICT")
conn.executemany("INSERT INTO supplier VALUES (?, ?)", [(i, f"s{i}") for i in range(1, 501)])
conn.commit()                                     # confirmado, pero solo en el -wal

for f in ("w.db", "w.db-wal", "w.db-shm"):
    print(f, os.path.getsize(f), "bytes")

shutil.copy("w.db", "copy.db")                    # la copia mal hecha: solo el .db
for sql in ("PRAGMA integrity_check;", "SELECT COUNT(*) FROM supplier;", ".tables"):
    r = subprocess.run(["sqlite3", "copy.db", sql], capture_output=True, text=True)
    print(f"copy.db  {sql:34} -> {r.stdout.strip()!r} {r.stderr.strip()!r}")

conn.close()                                      # al cerrar, SQLite vuelca y borra el -wal
print("tras cerrar:", sorted(f for f in os.listdir(".") if f.startswith("w.db")))
r = subprocess.run(["sqlite3", "w.db", "SELECT COUNT(*) FROM supplier;"], capture_output=True, text=True)
print("w.db     SELECT COUNT(*)                        ->", r.stdout.strip())

# Variante: la tabla ya estaba volcada y solo las filas nuevas viven en el -wal.
for f in ("w.db", "copy.db"):
    if os.path.exists(f):
        os.remove(f)
conn = sqlite3.connect("w.db")
conn.execute("PRAGMA journal_mode = WAL")
conn.execute("PRAGMA wal_autocheckpoint = 0")
conn.execute("CREATE TABLE supplier (supplier_id INTEGER PRIMARY KEY, name TEXT) STRICT")
conn.executemany("INSERT INTO supplier VALUES (?, ?)", [(i, f"s{i}") for i in range(1, 101)])
conn.commit()
conn.execute("PRAGMA wal_checkpoint(TRUNCATE)")   # 100 filas, ya en el .db
conn.executemany("INSERT INTO supplier VALUES (?, ?)", [(i, f"s{i}") for i in range(101, 501)])
conn.commit()                                     # 400 más, solo en el -wal
shutil.copy("w.db", "copy.db")
for sql in ("PRAGMA integrity_check;", "SELECT COUNT(*) FROM supplier;"):
    r = subprocess.run(["sqlite3", "copy.db", sql], capture_output=True, text=True)
    print(f"variante copy.db  {sql:34} -> {r.stdout.strip()!r} {r.stderr.strip()!r}")
conn.close()
