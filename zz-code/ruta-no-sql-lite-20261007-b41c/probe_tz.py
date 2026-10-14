# Sondeo: la zona horaria de la sesión cambia el corte de la ventana sin avisar.
import duckdb
c = duckdb.connect('lab/data/analitico/condor.duckdb', read_only=True)
print(c.sql("SELECT current_setting('TimeZone')"))
print(c.sql("SELECT count(*) FILTER (WHERE ts >= TIMESTAMP '2026-10-01') naive, count(*) FILTER (WHERE ts > TIMESTAMPTZ '2026-09-30 23:59:59+00') con_tz FROM reading"))
c.execute("SET TimeZone='UTC'")
print(c.sql("SELECT count(*) FILTER (WHERE ts > TIMESTAMPTZ '2026-09-30 23:59:59+00') con_tz_utc FROM reading"))
try:
    c.sql("SELECT avg(egt_c) FROM read_json('lab/data/reading-5m/reading.ndjson')").fetchall()
except Exception as e:
    print(repr(e))
print(c.sql("SELECT registration, model, operator_id FROM aircraft WHERE registration='HK-5178'"))
print(c.sql("SELECT min(ts), max(ts), count(*) FROM reading WHERE aircraft='HK-5178'"))
