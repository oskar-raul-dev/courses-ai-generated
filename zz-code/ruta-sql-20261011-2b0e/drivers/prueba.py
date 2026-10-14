# /// script
# requires-python = ">=3.13"
# dependencies = ["psycopg[binary]", "mysql-connector-python", "PyMySQL", "oracledb"]
# ///
"""P8: how each Python driver handles autocommit and transactions, and LOAD DATA LOCAL for MySQL.

Runs inside the uv container on the test lab's network. Prints one block per driver.
"""

import importlib.metadata as md
import os
import time

PG = "host=postgres dbname=alameda user=postgres password=lab"
CSV = "/caja/s/Protocolos.csv"


def show(title, **values):
    print(f"[{title}] " + " · ".join(f"{k}={v}" for k, v in values.items()))


def other_session_sees(count_fn):
    """Return whether a second connection sees the uncommitted row."""
    return count_fn() > 0


def test_psycopg():
    import psycopg
    with psycopg.connect(PG) as c1, psycopg.connect(PG, autocommit=True) as c2:
        c2.execute("DROP TABLE IF EXISTS p8_tx; CREATE TABLE p8_tx (id int)")
        c1.execute("INSERT INTO p8_tx VALUES (1)")
        seen = c2.execute("SELECT count(*) FROM p8_tx").fetchone()[0]
        status = c1.info.transaction_status.name
        c1.rollback()
        show("psycopg", version=md.version("psycopg"), default_autocommit=c1.autocommit,
             after_insert_status=status, other_session_sees_uncommitted=bool(seen))


def test_mysql_connector():
    import mysql.connector
    kw = dict(host="mysql", user="root", password="lab", database="alameda")
    c1, c2 = mysql.connector.connect(**kw), mysql.connector.connect(**kw, autocommit=True)
    cur2 = c2.cursor()
    cur2.execute("DROP TABLE IF EXISTS p8_tx"); cur2.execute("CREATE TABLE p8_tx (id int)")
    cur1 = c1.cursor()
    cur1.execute("INSERT INTO p8_tx VALUES (1)")
    cur2.execute("SELECT count(*) FROM p8_tx"); seen = cur2.fetchone()[0]
    c1.rollback()
    load = "ok"
    try:
        c3 = mysql.connector.connect(**kw, allow_local_infile=True, autocommit=True)
        cur3 = c3.cursor()
        cur3.execute("DROP TABLE IF EXISTS p8_load"); cur3.execute("CREATE TABLE p8_load (a int, b varchar(20), c int, d date, e char(1), f varchar(40))")
        t = time.time()
        cur3.execute(f"LOAD DATA LOCAL INFILE '{CSV}' INTO TABLE p8_load FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\\r\\n' IGNORE 1 LINES")
        load = f"{cur3.rowcount} rows in {time.time() - t:.1f}s"
    except Exception as exc:  # noqa: BLE001 - we want the literal message
        load = f"{type(exc).__name__}: {exc}"
    show("mysql-connector", version=md.version("mysql-connector-python"), default_autocommit=c1.autocommit,
         other_session_sees_uncommitted=bool(seen), load_data_local=load)


def test_pymysql():
    import pymysql
    kw = dict(host="mysql", user="root", password="lab", database="alameda")
    c1, c2 = pymysql.connect(**kw), pymysql.connect(**kw, autocommit=True)
    with c2.cursor() as cur2, c1.cursor() as cur1:
        cur2.execute("DROP TABLE IF EXISTS p8_tx"); cur2.execute("CREATE TABLE p8_tx (id int)")
        cur1.execute("INSERT INTO p8_tx VALUES (1)")
        cur2.execute("SELECT count(*) FROM p8_tx"); seen = cur2.fetchone()[0]
    c1.rollback()
    load = "ok"
    try:
        c3 = pymysql.connect(**kw, local_infile=True, autocommit=True)
        with c3.cursor() as cur3:
            cur3.execute("DROP TABLE IF EXISTS p8_load"); cur3.execute("CREATE TABLE p8_load (a int, b varchar(20), c int, d date, e char(1), f varchar(40))")
            t = time.time()
            n = cur3.execute(f"LOAD DATA LOCAL INFILE '{CSV}' INTO TABLE p8_load FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\\r\\n' IGNORE 1 LINES")
            load = f"{n} rows in {time.time() - t:.1f}s"
    except Exception as exc:  # noqa: BLE001
        load = f"{type(exc).__name__}: {exc}"
    show("PyMySQL", version=md.version("PyMySQL"), default_autocommit=c1.get_autocommit(),
         other_session_sees_uncommitted=bool(seen), load_data_local=load)


def test_oracledb():
    import oracledb
    dsn = "oracle:1521/FREEPDB1"
    c1 = oracledb.connect(user="alameda", password="lab", dsn=dsn)
    c2 = oracledb.connect(user="alameda", password="lab", dsn=dsn)
    cur2 = c2.cursor()
    try:
        cur2.execute("DROP TABLE p8_tx PURGE")
    except oracledb.DatabaseError:
        pass
    cur2.execute("CREATE TABLE p8_tx (id NUMBER)")
    c1.cursor().execute("INSERT INTO p8_tx VALUES (1)")
    cur2.execute("SELECT COUNT(*) FROM p8_tx"); seen = cur2.fetchone()[0]
    c1.rollback()
    cur2.execute("DROP TABLE p8_tx PURGE")
    show("oracledb", version=md.version("oracledb"), thin=c1.thin, default_autocommit=c1.autocommit,
         other_session_sees_uncommitted=bool(seen), ddl_commits_implicitly="yes (Oracle)")


for test in (test_psycopg, test_mysql_connector, test_pymysql, test_oracledb):
    try:
        test()
    except Exception as exc:  # noqa: BLE001
        print(f"[{test.__name__}] FAILED {type(exc).__name__}: {exc}")
print("python", os.sys.version.split()[0])
