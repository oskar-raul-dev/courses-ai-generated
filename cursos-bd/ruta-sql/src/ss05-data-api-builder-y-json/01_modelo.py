"""ss05 · §4. El modelo que la Fase 23 publicó con PostgREST, copiado de Postgres a una base de SQL Server (ss05),
con los mismos nombres: alameda.lab_order, alameda.result, alameda.analyte y alameda.referral. Y los antibiogramas de la
Fase 19 como documentos, en staging.culture_doc, con el tipo json de SQL Server 2025.

Lee de Postgres por cursor de servidor y escribe por la copia masiva de TDS, de a 50.000 filas. Cada tabla se cuenta en
los dos motores al terminar: los conteos son del modelo, y se publican.

    uv run --extra sqlserver python ss05-data-api-builder-y-json/01_modelo.py      (desde src/, con lab up base sqlserver)
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from lab.engines import postgres, sqlserver  # noqa: E402

BATCH = 50_000
DDL = {
    "alameda.analyte": "analyte_code nvarchar(10) NOT NULL PRIMARY KEY, name nvarchar(100) NOT NULL, unit nvarchar(20) NULL",
    "alameda.lab_order": "lab_order_id int NOT NULL PRIMARY KEY, patient_id int NOT NULL, ordered_on date NOT NULL, "
                         "site_code nchar(1) NOT NULL, payer_code nvarchar(20) NULL",
    "alameda.referral": "lab_order_id int NOT NULL PRIMARY KEY, physician_id int NULL",
    "alameda.result": "result_id int NOT NULL PRIMARY KEY, lab_order_id int NOT NULL, analyte_code nvarchar(10) NOT NULL, "
                      "value_numeric decimal(14,4) NULL, qualifier nchar(1) NULL, value_text nvarchar(50) NULL, "
                      "recorded_at datetime2(3) NOT NULL",
    "staging.culture_doc": "culture_id int NOT NULL PRIMARY KEY, person_id int NOT NULL, culture_date date NOT NULL, "
                           "germ nvarchar(100) NOT NULL, antibiogram json NOT NULL",
}
SOURCE = {
    "alameda.analyte": "SELECT analyte_code, name, unit FROM alameda.analyte",
    "alameda.lab_order": "SELECT lab_order_id, patient_id, ordered_on, site_code, payer_code FROM alameda.lab_order",
    "alameda.referral": "SELECT lab_order_id, physician_id FROM alameda.referral",
    "alameda.result": "SELECT result_id, lab_order_id, analyte_code, value_numeric, qualifier, value_text, recorded_at "
                      "FROM alameda.result",
    "staging.culture_doc": "SELECT culture_id, person_id, culture_date, germ, antibiogram::text FROM staging.culture_doc",
}
INDEXES = [
    "CREATE INDEX lab_order_patient_id_idx ON alameda.lab_order (patient_id)",
    "CREATE INDEX result_lab_order_id_idx ON alameda.result (lab_order_id)",
    "CREATE INDEX referral_physician_id_idx ON alameda.referral (physician_id)",
]


def main() -> None:
    master = sqlserver.connect("master")
    cur = master.cursor()
    cur.execute("IF DB_ID('ss05') IS NOT NULL BEGIN ALTER DATABASE ss05 SET SINGLE_USER WITH ROLLBACK IMMEDIATE; "
                "DROP DATABASE ss05; END")
    cur.execute("CREATE DATABASE ss05")
    cur.execute("ALTER DATABASE ss05 SET RECOVERY SIMPLE")
    master.close()
    ms = sqlserver.connect("ss05")
    out = ms.cursor()
    out.execute("CREATE SCHEMA alameda")
    out.execute("CREATE SCHEMA staging")
    with postgres.connect() as pg:
        for table, ddl in DDL.items():
            out.execute(f"CREATE TABLE {table} ({ddl})")
            with pg.cursor(name=f"copy_{table.replace('.', '_')}") as src:
                src.itersize = BATCH
                src.execute(SOURCE[table])
                while True:
                    rows = src.fetchmany(BATCH)
                    if not rows:
                        break
                    out.bulkcopy(table, [tuple(r) for r in rows], timeout=0, table_lock=True)
            expected = pg.execute(f"SELECT count(*) FROM {table}").fetchone()[0]
            out.execute(f"SELECT COUNT_BIG(*) FROM {table}")
            loaded = out.fetchone()[0]
            print(f"{table:22} Postgres {expected:>10} · SQL Server {loaded:>10}{'' if expected == loaded else '  ✗ DISTINTO'}")
    for sql in INDEXES:
        out.execute(sql)
    ms.close()


if __name__ == "__main__":
    main()
