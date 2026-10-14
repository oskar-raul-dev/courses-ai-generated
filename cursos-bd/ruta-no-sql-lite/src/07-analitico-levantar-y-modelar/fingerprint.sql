-- La huella de la ampliación: si DuckDB y Postgres devuelven la misma fila, las dos tablas tienen
-- los mismos datos. Corre igual en los dos motores.
SELECT count(*) AS readings, count(DISTINCT aircraft) AS aircraft, count(DISTINCT flight_id) AS flights,
       min(ts) AS first_ts, max(ts) AS last_ts,
       sum(altitude_ft) AS altitude, sum(ias_kt) AS ias, sum(egt_c) AS egt, sum(n1_pct) AS n1,
       sum(oil_press_psi) AS oil_press, sum(oil_temp_c) AS oil_temp, sum(fuel_flow_pph) AS fuel_flow
FROM reading_x10;
