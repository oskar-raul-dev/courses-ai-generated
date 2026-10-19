"""Los protocolos de alameda.lab_order (Postgres) en tres tablas de MySQL que solo difieren en la clave
primaria: bigint, UUIDv4 y UUIDv7, con un índice secundario por paciente. Se insertan en el orden en que
llegaron los protocolos, como los insertaría la aplicación.

Uso, desde src/: uv run python 10-identificadores/mysql_keys.py
"""

import os
import time
import uuid

import psycopg
import pymysql

from lab import config

BATCH = 5000
TABLES = {
    "order_bigint": "order_id bigint NOT NULL",
    "order_uuid4": "order_id binary(16) NOT NULL",
    "order_uuid7": "order_id binary(16) NOT NULL",
}


def uuid7(ms: int) -> bytes:
    """UUIDv7 de la RFC 9562: 48 bits de milisegundos, la versión, la variante y azar. Python 3.13 no lo trae."""
    raw = bytearray(ms.to_bytes(6, "big") + os.urandom(10))
    raw[6] = (raw[6] & 0x0F) | 0x70
    raw[8] = (raw[8] & 0x3F) | 0x80
    return bytes(raw)


def main() -> None:
    pg = psycopg.connect(**config.POSTGRES)
    my = pymysql.connect(host=config.MYSQL["host"], port=config.MYSQL["port"], user="root",
                         password=config.PASSWORD, autocommit=False)
    with my.cursor() as cur:
        cur.execute("CREATE DATABASE IF NOT EXISTS staging")
        for name, key in TABLES.items():
            cur.execute(f"DROP TABLE IF EXISTS staging.{name}")
            cur.execute(f"CREATE TABLE staging.{name} ({key}, patient_id int NOT NULL, ordered_on date NOT NULL, "
                        f"site_code char(1) NOT NULL, PRIMARY KEY (order_id), KEY {name}_patient_id_idx (patient_id))")
    rows = pg.execute("SELECT lab_order_id, patient_id, ordered_on, site_code FROM alameda.lab_order "
                      "ORDER BY ordered_on, lab_order_id").fetchall()
    for name in TABLES:
        started = time.time()
        with my.cursor() as cur:
            for i in range(0, len(rows), BATCH):
                batch = []
                for n, (order_id, patient_id, ordered_on, site) in enumerate(rows[i:i + BATCH], start=i + 1):
                    ms = int(time.mktime(ordered_on.timetuple()) * 1000) + n % 86_400_000
                    key = {"order_bigint": n, "order_uuid4": uuid.uuid4().bytes, "order_uuid7": uuid7(ms)}[name]
                    batch.append((key, patient_id, ordered_on, site))
                cur.executemany(f"INSERT INTO staging.{name} VALUES (%s, %s, %s, %s)", batch)
                my.commit()
        print(f"{name}: {len(rows)} filas en {time.time() - started:.0f} s")
    with my.cursor() as cur:
        cur.execute("ANALYZE TABLE " + ", ".join(f"staging.{n}" for n in TABLES))
        cur.fetchall()
        cur.execute("SELECT table_name, index_name, stat_value, round(stat_value * @@innodb_page_size / 1048576, 1) "
                    "FROM mysql.innodb_index_stats WHERE database_name = 'staging' AND table_name LIKE 'order_%' "
                    "AND stat_name = 'size' ORDER BY table_name, index_name")
        for table, index, pages, mb in cur.fetchall():
            print(f"{table:13} {index:28} {pages:>7} páginas {mb:>7} MB")


if __name__ == "__main__":
    main()
