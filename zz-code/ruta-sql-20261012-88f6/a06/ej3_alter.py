"""Tres preguntas a cada driver: ¿autocommit?, ¿un CREATE TABLE confirma lo pendiente?, ¿qué hace `with`?"""
import oracledb
import psycopg
import pymysql

from lab import config

INSERT = "INSERT INTO payer VALUES ('PAMI', 'INSTITUTO NACIONAL DE SERVICIOS SOCIALES')"


def connect(engine):
    if engine == "postgres":
        return psycopg.connect(**config.POSTGRES, options="-c search_path=alameda")
    if engine == "mysql":
        return pymysql.connect(**config.MYSQL, database="alameda")
    o = config.ORACLE
    return oracledb.connect(user="alameda", password=o["password"], dsn=f"{o['host']}:{o['port']}/{o['service']}")


def prepare():
    """El esquema del modelo nuevo, si todavía no existe (en MySQL, la base `alameda`)."""
    with psycopg.connect(**config.POSTGRES, autocommit=True) as conn:
        conn.execute("CREATE SCHEMA IF NOT EXISTS alameda")
    conn = pymysql.connect(**config.MYSQL)
    conn.cursor().execute("CREATE DATABASE IF NOT EXISTS alameda")
    conn.close()


def reset(engine):
    """payer vacía y sin la tabla site; se ejecuta confirmando cada sentencia."""
    conn = connect(engine)
    cur = conn.cursor()
    for sql in ("DROP TABLE site", "DROP TABLE payer",
                "CREATE TABLE payer (payer_code varchar(10) PRIMARY KEY, name varchar(100))"):
        try:
            cur.execute(sql)
            conn.commit()
        except Exception:
            conn.rollback()
    conn.close()


def count(engine):
    conn = connect(engine)
    cur = conn.cursor()
    cur.execute("SELECT count(*) FROM payer")
    n = cur.fetchone()[0]
    conn.close()
    return n


def autocommit(conn):
    return conn.get_autocommit() if isinstance(conn, pymysql.Connection) else conn.autocommit


prepare()
for engine in ("postgres", "mysql", "oracle"):
    reset(engine)
    conn = connect(engine)
    cur = conn.cursor()
    cur.execute(INSERT)
    print(f"{engine}: autocommit={autocommit(conn)}; sin commit, otra sesión ve {count(engine)} fila(s)")
    cur.execute("ALTER TABLE payer ADD active boolean" if engine == "oracle"      # Oracle no acepta COLUMN
                else "ALTER TABLE payer ADD COLUMN active boolean")
    conn.rollback()
    print(f"{engine}: tras ALTER TABLE y rollback, payer tiene {count(engine)} fila(s)")
    conn.close()

    reset(engine)
    with connect(engine) as conn:
        conn.cursor().execute(INSERT)
    print(f"{engine}: al salir de `with connect()` sin commit, payer tiene {count(engine)} fila(s)")
