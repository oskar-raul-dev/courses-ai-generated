# El punto de rotura de la familia: dos procesos sobre el mismo archivo de DuckDB. El primero abre la
# base para escribir y registra aterrizajes; el segundo intenta abrirla, primero para escribir y después
# solo para leer. Al final, los dos solo para leer.
#
#   uv run python 08-analitico-romper-y-medir/two_processes.py   (desde src/)
import multiprocessing as mp
import time
from pathlib import Path

import duckdb

DB = Path("lab/data/analitico/landing.duckdb")


def writer(ready, stop) -> None:
    con = duckdb.connect(str(DB))
    ready.set()
    while not stop.is_set():
        con.execute("INSERT INTO landing VALUES ('HK-4207', 1)")
        time.sleep(0.01)
    con.close()


def second(read_only: bool) -> str:
    try:
        con = duckdb.connect(str(DB), read_only=read_only)
        n = con.sql("SELECT count(*) FROM landing").fetchone()[0]
        con.close()
        return f"abrió y leyó {n} aterrizajes"
    except duckdb.Error as e:
        return f"{type(e).__name__}: {e}"


# la guarda es obligatoria: en macOS, multiprocessing arranca los hijos reimportando el script (a06)
if __name__ == "__main__":
    for f in (DB, Path(f"{DB}.wal")):
        f.unlink(missing_ok=True)
    with duckdb.connect(str(DB)) as con:
        con.execute("CREATE TABLE landing (registration VARCHAR, flight_minutes INTEGER)")
    print(f"DuckDB {duckdb.__version__} · {DB}")
    ready, stop = mp.Event(), mp.Event()
    p = mp.Process(target=writer, args=(ready, stop))
    p.start()
    ready.wait()
    with mp.Pool(1) as pool:
        print("  con un escritor abierto, otro proceso para escribir:", pool.apply(second, (False,)))
        print("  con un escritor abierto, otro proceso solo para leer:", pool.apply(second, (True,)))
    stop.set()
    p.join()
    with mp.Pool(2) as pool:
        for r in pool.map(second, [True, True]):
            print("  sin escritor, dos procesos solo para leer:", r)
    for f in (DB, Path(f"{DB}.wal")):
        f.unlink(missing_ok=True)
