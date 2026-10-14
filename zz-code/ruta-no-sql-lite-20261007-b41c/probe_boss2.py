# Sondeo del boss II: magnitudes de las tres definiciones para las aeronaves con grabador en 2026.
import duckdb
c = duckdb.connect('lab/data/analitico/condor.duckdb', read_only=True)
c.execute("SET TimeZone='UTC'")
print(c.sql("""
WITH a AS (SELECT registration, model, operator_id FROM aircraft WHERE has_flight_recorder)
SELECT a.registration, a.model, a.operator_id,
  (SELECT count(*)/60.0 FROM reading r WHERE r.aircraft=a.registration AND year(r.ts)=2026) AS h_year,
  (SELECT count(*)/60.0 FROM reading r WHERE r.aircraft=a.registration AND r.ts >= '2026-01-01' AND r.ts < '2026-10-01') AS h_utc,
  (SELECT count(*)/60.0 FROM reading r WHERE r.aircraft=a.registration AND r.ts - INTERVAL 5 HOUR >= '2026-01-01' AND r.ts - INTERVAL 5 HOUR < '2026-10-01') AS h_bog,
  (SELECT sum(labor_cost_usd+parts_cost_usd) FROM work_order w WHERE w.aircraft=a.registration AND w.opened_at >= '2026-01-01' AND w.opened_at < '2026-10-01') AS cost_usd,
  (SELECT count(*) FROM work_order w WHERE w.aircraft=a.registration AND w.opened_at >= '2026-01-01' AND w.opened_at < '2026-10-01') AS n_wo
FROM a ORDER BY 1"""))
