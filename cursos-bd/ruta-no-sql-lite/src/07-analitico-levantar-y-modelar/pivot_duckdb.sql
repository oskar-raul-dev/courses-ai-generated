-- El costo por hora volada de cada modelo, año por año, como columnas: el pivote hecho por el motor.
-- Solo DuckDB: PIVOT no es SQL estándar (en Postgres, ver pivot_postgres.sql).
WITH hours AS (
    SELECT aircraft, year(ts) AS yr, count(*) / 60.0 AS flight_hours
    FROM reading WHERE ts < TIMESTAMP '2026-10-01' GROUP BY ALL
), cost AS (
    SELECT aircraft, year(opened_at) AS yr, sum(labor_cost_usd + parts_cost_usd) AS cost_usd
    FROM work_order WHERE opened_at < TIMESTAMP '2026-10-01' GROUP BY ALL
), per_year AS (
    SELECT a.model, h.yr, sum(c.cost_usd) / sum(h.flight_hours) AS usd_per_hour
    FROM hours h
    JOIN aircraft a ON a.registration = h.aircraft
    LEFT JOIN cost c ON c.aircraft = h.aircraft AND c.yr = h.yr
    GROUP BY ALL
)
PIVOT per_year ON yr USING round(first(usd_per_hour)) ORDER BY model;
