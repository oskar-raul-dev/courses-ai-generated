-- Los roll-ups de la serie, como parte del modelo (perfil series, base condor):
--   docker compose -f lab/compose.yaml exec -T series psql -U postgres -d condor < 09-series-levantar-y-modelar/rollups.sql
\timing on
-- por hora: el agregado continuo se materializa sobre la hypertable y se refresca por ventanas
CREATE MATERIALIZED VIEW reading_hourly WITH (timescaledb.continuous) AS
SELECT aircraft, time_bucket(INTERVAL '1 hour', ts) AS bucket,
       count(*) AS minutes, avg(egt_c) AS egt_avg, max(egt_c) AS egt_max, avg(fuel_flow_pph) AS fuel_avg
FROM reading_x10
GROUP BY aircraft, bucket
WITH NO DATA;

-- por día, construido sobre el de hora (agregado jerárquico): suma minutos, pondera el promedio
CREATE MATERIALIZED VIEW reading_daily WITH (timescaledb.continuous) AS
SELECT aircraft, time_bucket(INTERVAL '1 day', bucket) AS bucket,
       sum(minutes) AS minutes, sum(egt_avg * minutes) / sum(minutes) AS egt_avg, max(egt_max) AS egt_max
FROM reading_hourly
GROUP BY aircraft, time_bucket(INTERVAL '1 day', bucket)
WITH NO DATA;

-- la primera materialización, entera; después la hace la política sola
CALL refresh_continuous_aggregate('reading_hourly', NULL, NULL);
CALL refresh_continuous_aggregate('reading_daily', NULL, NULL);

-- las políticas: refrescar lo de los últimos tres días cada hora, y dejar fuera la última hora,
-- que todavía puede estar llegando
SELECT add_continuous_aggregate_policy('reading_hourly', start_offset => INTERVAL '3 days',
    end_offset => INTERVAL '1 hour', schedule_interval => INTERVAL '1 hour');
SELECT add_continuous_aggregate_policy('reading_daily', start_offset => INTERVAL '7 days',
    end_offset => INTERVAL '1 day', schedule_interval => INTERVAL '1 day');

SELECT view_name, materialization_hypertable_name FROM timescaledb_information.continuous_aggregates;
SELECT 'reading_hourly' AS view, count(*) FROM reading_hourly
UNION ALL SELECT 'reading_daily', count(*) FROM reading_daily;
