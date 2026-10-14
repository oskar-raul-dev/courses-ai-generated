-- La línea base de la Fase 09 (perfil base, base series_base): la misma serie en una tabla normal,
-- con el índice que pondría cualquiera que conoce sus consultas. El particionado declarativo es la
-- apuesta de la Fase 10.
CREATE TABLE reading (
    aircraft text NOT NULL, flight_id text NOT NULL, ts timestamp NOT NULL,
    altitude_ft integer, ias_kt integer, egt_c integer, n1_pct integer,
    oil_press_psi integer, oil_temp_c integer, fuel_flow_pph integer
);
CREATE INDEX ON reading (aircraft, ts);
CREATE INDEX ON reading (ts);
CREATE TABLE reading_x10 (LIKE reading INCLUDING DEFAULTS);
CREATE INDEX ON reading_x10 (aircraft, ts);
CREATE INDEX ON reading_x10 (ts);
