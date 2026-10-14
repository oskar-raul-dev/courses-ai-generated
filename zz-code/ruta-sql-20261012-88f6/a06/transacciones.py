"""a06: autocommit, DDL dentro de una transacción y `with conn:` en los tres drivers.
Se corre con el entorno del curso: lab-en-contenedor.sh no sirve (llama a `lab`), así que
correr-a06.sh lo lanza con `uv run python`."""

import oracledb
import psycopg
import pymysql

PG = dict(host="postgres", port=5432, user="postgres", password="lab", dbname="alameda")
MY = dict(host="mysql", port=3306, user="root", password="lab", database="alameda")
ORA = dict(user="alameda", password="lab", dsn="oracle:1521/FREEPDB1")


def pg():
    return psycopg.connect(**PG)


def my():
    return pymysql.connect(**MY)


def ora():
    return oracledb.connect(**ORA)


def setup():
    with psycopg.connect(**PG, autocommit=True) as c:
        c.execute("CREATE SCHEMA IF NOT EXISTS alameda")
        c.execute("DROP TABLE IF EXISTS alameda.payer, alameda.site")
        c.execute("CREATE TABLE alameda.payer (payer_code varchar(10) PRIMARY KEY, name varchar(100))")
    c = pymysql.connect(**{k: v for k, v in MY.items() if k != "database"}, autocommit=True)
    with c.cursor() as cur:
        cur.execute("CREATE DATABASE IF NOT EXISTS alameda")
        cur.execute("DROP TABLE IF EXISTS alameda.payer, alameda.site")
        cur.execute("CREATE TABLE alameda.payer (payer_code varchar(10) PRIMARY KEY, name varchar(100))")
    c.close()
    with ora() as c, c.cursor() as cur:
        for t in ("payer", "site"):
            try:
                cur.execute(f"DROP TABLE {t} PURGE")
            except oracledb.DatabaseError:
                pass
        cur.execute("CREATE TABLE payer (payer_code varchar2(10) PRIMARY KEY, name varchar2(100))")


def count(engine):
    if engine == "postgres":
        with pg() as c:
            return c.execute("SELECT count(*) FROM alameda.payer").fetchone()[0]
    if engine == "mysql":
        c = my()
        with c.cursor() as cur:
            cur.execute("SELECT count(*) FROM payer")
            n = cur.fetchone()[0]
        c.close()
        return n
    with ora() as c, c.cursor() as cur:
        cur.execute("SELECT count(*) FROM payer")
        return cur.fetchone()[0]


def clean():
    with psycopg.connect(**PG, autocommit=True) as c:
        c.execute("DELETE FROM alameda.payer")
        c.execute("DROP TABLE IF EXISTS alameda.site")
    c = my()
    with c.cursor() as cur:
        cur.execute("DELETE FROM payer")
        cur.execute("DROP TABLE IF EXISTS site")
    c.commit(); c.close()
    with ora() as c, c.cursor() as cur:
        cur.execute("DELETE FROM payer")
        c.commit()
        try:
            cur.execute("DROP TABLE site PURGE")
        except oracledb.DatabaseError:
            pass


INSERT = {"postgres": "INSERT INTO alameda.payer VALUES ('PAMI', 'INSTITUTO NACIONAL DE SERVICIOS SOCIALES')",
          "mysql": "INSERT INTO payer VALUES ('PAMI', 'INSTITUTO NACIONAL DE SERVICIOS SOCIALES')",
          "oracle": "INSERT INTO payer VALUES ('PAMI', 'INSTITUTO NACIONAL DE SERVICIOS SOCIALES')"}
DDL = {"postgres": "CREATE TABLE alameda.site (site_code char(1) PRIMARY KEY)",
       "mysql": "CREATE TABLE site (site_code char(1) PRIMARY KEY)",
       "oracle": "CREATE TABLE site (site_code char(1) PRIMARY KEY)"}
OPEN = {"postgres": pg, "mysql": my, "oracle": ora}


def autocommit(engine, c):
    if engine == "postgres":
        return c.autocommit
    if engine == "mysql":
        return c.get_autocommit()
    return c.autocommit


def one(engine):
    print(f"── {engine}")
    # 1. autocommit por defecto, y la otra sesión
    c = OPEN[engine]()
    cur = c.cursor()
    print(f"  autocommit por defecto: {autocommit(engine, c)}")
    cur.execute(INSERT[engine])
    extra = f" · estado: {c.info.transaction_status.name}" if engine == "postgres" else ""
    print(f"  INSERT sin commit; la otra sesión cuenta {count(engine)}{extra}")
    # 2. un DDL en medio de la transacción, y rollback
    cur.execute(DDL[engine])
    c.rollback()
    print(f"  CREATE TABLE y rollback: payer tiene {count(engine)} fila(s)")
    c.close()
    clean()
    # 3. with conn: … sin commit explícito
    with OPEN[engine]() as c:
        c.cursor().execute(INSERT[engine])
    print(f"  `with conn:` sin commit: payer tiene {count(engine)} fila(s) al salir")
    clean()


if __name__ == "__main__":
    print(f"psycopg {psycopg.__version__} · PyMySQL {pymysql.__version__} · oracledb {oracledb.__version__} "
          f"(modo thin: {oracledb.is_thin_mode()})")
    setup()
    for e in ("postgres", "mysql", "oracle"):
        one(e)
