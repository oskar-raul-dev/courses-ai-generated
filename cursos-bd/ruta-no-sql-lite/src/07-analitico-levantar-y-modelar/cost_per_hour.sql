-- El costo por hora volada por modelo y por operador: el precio de venta de Ala Continua.
-- Horas: un minuto por lectura, solo aeronaves con grabador. Costos: mano de obra más partes de
-- las órdenes. Las dos cosas dentro de la ventana del dataset (hasta el 30/09/2026 incluido).
-- SQL estándar: corre igual en DuckDB y en Postgres.
WITH hours AS (
    SELECT aircraft, count(*) / 60.0 AS flight_hours
    FROM reading
    WHERE ts < TIMESTAMP '2026-10-01'
    GROUP BY aircraft
), cost AS (
    SELECT aircraft, sum(labor_cost_usd + parts_cost_usd) AS cost_usd
    FROM work_order
    WHERE opened_at < TIMESTAMP '2026-10-01'
    GROUP BY aircraft
)
SELECT a.model, a.operator_id, count(*) AS aircraft,
       round(sum(h.flight_hours)) AS flight_hours,
       round(sum(c.cost_usd)) AS cost_usd,
       round(sum(c.cost_usd) / sum(h.flight_hours), 2) AS usd_per_hour
FROM aircraft a
JOIN hours h ON h.aircraft = a.registration
LEFT JOIN cost c ON c.aircraft = a.registration
GROUP BY a.model, a.operator_id
ORDER BY a.model, a.operator_id;
