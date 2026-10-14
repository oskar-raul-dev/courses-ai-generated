"""Un PDF de 70 MB contra max_allowed_packet de MySQL 9.7 (64 MB por defecto)."""
import os
import pymysql
from lab import config

conn = pymysql.connect(host=config.MYSQL["host"], port=config.MYSQL["port"], user="root",
                       password=config.PASSWORD, database="staging")
with conn.cursor() as cur:
    cur.execute("SELECT @@max_allowed_packet")
    print("max_allowed_packet:", cur.fetchone()[0])
    cur.execute("DROP TABLE IF EXISTS report_pdf")
    cur.execute("CREATE TABLE report_pdf (lab_order_id int PRIMARY KEY, pdf longblob NOT NULL)")
    for mb in (10, 70):
        try:
            cur.execute("INSERT INTO report_pdf VALUES (%s, %s)", (mb, os.urandom(mb * 1024 * 1024)))
            conn.commit()
            print(f"{mb} MB: guardado")
        except Exception as exc:
            print(f"{mb} MB: {type(exc).__name__}: {exc}")
            break
