-- El mismo pivote en Postgres: una columna por año, escrita a mano con FILTER. El año que no
-- escribas no aparece, y el año nuevo exige cambiar la consulta.
WITH hours AS (
    SELECT aircraft, extract(year FROM ts)::int AS yr, count(*) / 60.0 AS flight_hours
    FROM reading WHERE ts < TIMESTAMP '2026-10-01' GROUP BY 1, 2
), cost AS (
    SELECT aircraft, extract(year FROM opened_at)::int AS yr, sum(labor_cost_usd + parts_cost_usd) AS cost_usd
    FROM work_order WHERE opened_at < TIMESTAMP '2026-10-01' GROUP BY 1, 2
), per_year AS (
    SELECT a.model, h.yr, sum(c.cost_usd) / sum(h.flight_hours) AS usd_per_hour
    FROM hours h
    JOIN aircraft a ON a.registration = h.aircraft
    LEFT JOIN cost c ON c.aircraft = h.aircraft AND c.yr = h.yr
    GROUP BY 1, 2
)
SELECT model,
       round(max(usd_per_hour) FILTER (WHERE yr = 2021)) AS "2021",
       round(max(usd_per_hour) FILTER (WHERE yr = 2022)) AS "2022",
       round(max(usd_per_hour) FILTER (WHERE yr = 2023)) AS "2023",
       round(max(usd_per_hour) FILTER (WHERE yr = 2024)) AS "2024",
       round(max(usd_per_hour) FILTER (WHERE yr = 2025)) AS "2025",
       round(max(usd_per_hour) FILTER (WHERE yr = 2026)) AS "2026"
FROM per_year
GROUP BY model
ORDER BY model;
