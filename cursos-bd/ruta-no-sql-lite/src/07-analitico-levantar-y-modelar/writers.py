# La situación 3 de la familia: DuckDB usado como base de una aplicación con varios escritores. Cuatro
# hilos del mismo proceso registran aterrizajes —un minuto de vuelo cada uno— sobre 17 aeronaves.
#
#   uv run python 07-analitico-levantar-y-modelar/writers.py [--writers 4] [--landings 2000]   (desde src/)
#
# Tres formas de hacerlo:
#   counter   DuckDB: UPDATE de un contador por aeronave, como lo haría la aplicación
#   append    DuckDB: un INSERT por aterrizaje, y el total se calcula al leer
#   postgres  Postgres (base `analitico`): el mismo UPDATE del contador
# La base de DuckDB es un archivo aparte (lab/data/analitico/writers.duckdb) que se borra al empezar.
import argparse
import collections
import os
import threading
from pathlib import Path

import duckdb
import psycopg

parser = argparse.ArgumentParser()
parser.add_argument("--writers", type=int, default=4)
parser.add_argument("--landings", type=int, default=2000, help="aterrizajes por escritor")
args = parser.parse_args()

FLEET = [f"HK-{4000 + i}" for i in range(17)]
DB = Path("lab/data/analitico/writers.duckdb")
PG = f"host=localhost port={os.environ.get('BASE_PORT', 15432)} user=postgres password=condor dbname=analitico"


def aircraft_for(writer: int, i: int) -> str:
    # los escritores se cruzan sobre las mismas aeronaves, como los terminales de dos bases
    return FLEET[(i * 7 + writer) % len(FLEET)]


def run(mode: str) -> None:
    errors: collections.Counter[str] = collections.Counter()
    done = [0] * args.writers
    if mode == "postgres":
        with psycopg.connect(PG, autocommit=True) as pg:
            pg.execute("DROP TABLE IF EXISTS aircraft_minutes")
            pg.execute("CREATE TABLE aircraft_minutes (registration text PRIMARY KEY, flight_minutes bigint)")
            pg.execute("INSERT INTO aircraft_minutes SELECT unnest(%s::text[]), 0", [FLEET])
    else:
        for f in (DB, Path(f"{DB}.wal")):
            f.unlink(missing_ok=True)
        con = duckdb.connect(str(DB))
        con.execute("CREATE TABLE aircraft_minutes (registration VARCHAR PRIMARY KEY, flight_minutes BIGINT)")
        con.execute("INSERT INTO aircraft_minutes SELECT unnest(?), 0", [FLEET])
        con.execute("CREATE TABLE landing (registration VARCHAR, flight_minutes INTEGER)")

    def worker(w: int) -> None:
        # una conexión por escritor: en DuckDB, cursor() abre otra conexión a la misma base
        conn = psycopg.connect(PG, autocommit=True) if mode == "postgres" else con.cursor()
        for i in range(args.landings):
            reg = aircraft_for(w, i)
            try:
                if mode == "append":
                    conn.execute("INSERT INTO landing VALUES (?, 1)", [reg])
                elif mode == "counter":
                    conn.execute("UPDATE aircraft_minutes SET flight_minutes = flight_minutes + 1 WHERE registration = ?", [reg])
                else:
                    conn.execute("UPDATE aircraft_minutes SET flight_minutes = flight_minutes + 1 WHERE registration = %s", [reg])
                done[w] += 1
            except Exception as e:  # el error se cuenta, no se reintenta: eso hace la aplicación ingenua
                errors[str(e).splitlines()[0]] += 1
        conn.close()

    threads = [threading.Thread(target=worker, args=(w,)) for w in range(args.writers)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()

    if mode == "postgres":
        with psycopg.connect(PG) as pg:
            total = pg.execute("SELECT sum(flight_minutes) FROM aircraft_minutes").fetchone()[0]
    else:
        table = "landing" if mode == "append" else "aircraft_minutes"
        total = con.sql(f"SELECT coalesce(sum(flight_minutes), 0) FROM {table}").fetchone()[0]
        con.close()
    expected = args.writers * args.landings
    print(f"{mode:9} escrituras {expected} · fallidas {sum(errors.values()):5} · minutos registrados {total} de {expected}")
    for message, n in errors.most_common():
        print(f"          {n} × {message}")


for mode in ("counter", "append", "postgres"):
    run(mode)
