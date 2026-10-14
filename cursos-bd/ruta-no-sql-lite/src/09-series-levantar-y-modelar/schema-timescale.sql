-- La serie de lecturas en TimescaleDB (perfil series, base condor). Mismas columnas y tipos que la
-- tabla de la Fase 07; lo que cambia es que se parte por tiempo.
CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE TABLE reading (
    aircraft text NOT NULL, flight_id text NOT NULL, ts timestamp NOT NULL,
    altitude_ft integer, ias_kt integer, egt_c integer, n1_pct integer,
    oil_press_psi integer, oil_temp_c integer, fuel_flow_pph integer
);
-- un chunk por semana: la tabla se parte sola por ts, y cada chunk es una tabla de Postgres
SELECT create_hypertable('reading', by_range('ts', INTERVAL '7 days'));
CREATE INDEX ON reading (aircraft, ts DESC);
-- la ampliación ×10, con la misma forma que en las Fases 07 y 08
CREATE TABLE reading_x10 (LIKE reading INCLUDING DEFAULTS);
SELECT create_hypertable('reading_x10', by_range('ts', INTERVAL '7 days'));
CREATE INDEX ON reading_x10 (aircraft, ts DESC);
