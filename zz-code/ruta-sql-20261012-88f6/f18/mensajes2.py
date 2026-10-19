# F18 · mensajes completos de lock_timeout, NOWAIT y VALIDATE CONSTRAINT, para a08.
import psycopg
from lab.race import connect
def diag(e):
    d = e.diag
    return "\n".join(x for x in (f"ERROR:  {d.message_primary}", d.message_detail and f"DETAIL:  {d.message_detail}",
                                 d.message_hint and f"HINT:  {d.message_hint}", d.context and f"CONTEXT:  {d.context.strip()}") if x)
a, b = connect("postgres"), connect("postgres")
a.execute("BEGIN"); a.execute("SELECT 1 FROM staging.hemogram WHERE hemogram_id = 1 FOR UPDATE")
b.execute("SET lock_timeout = '1s'")
for sql in ("UPDATE staging.hemogram SET hematocrit = '42' WHERE hemogram_id = 1",
            "SELECT 1 FROM staging.hemogram WHERE hemogram_id = 1 FOR UPDATE NOWAIT"):
    try: b.execute(sql)
    except psycopg.Error as e: print(e.sqlstate); print(diag(e)); print("---")
a.execute("ROLLBACK")
a.execute("ALTER TABLE staging.result_ddl DROP CONSTRAINT IF EXISTS result_ddl_has_value")
a.execute("ALTER TABLE staging.result_ddl ADD CONSTRAINT result_ddl_has_value CHECK (value_text IS NOT NULL OR value_numeric IS NOT NULL OR sample_flag IS NOT NULL) NOT VALID")
try: a.execute("ALTER TABLE staging.result_ddl VALIDATE CONSTRAINT result_ddl_has_value")
except psycopg.Error as e: print(e.sqlstate); print(diag(e))
a.execute("ALTER TABLE staging.result_ddl DROP CONSTRAINT IF EXISTS result_ddl_has_value")
print(a.execute("SELECT count(*) FROM staging.result_ddl WHERE value_text IS NULL AND value_numeric IS NULL AND sample_flag IS NULL").fetchone())
