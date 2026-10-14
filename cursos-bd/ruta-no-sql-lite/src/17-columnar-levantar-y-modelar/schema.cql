-- Fase 17: las lecturas de vuelo de Cóndor modeladas por consulta. Una tabla por pregunta, con los
-- mismos datos repetidos a propósito. Un nodo: replicación 1 (el anillo de la sección 7 usa 3).
DROP KEYSPACE IF EXISTS condor;
CREATE KEYSPACE condor WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

-- consulta 1: una aeronave en un rango de fechas. La partición es aeronave × mes: con una lectura por
-- minuto, un mes de una aeronave son unas 5000 filas; la aeronave sola sería una partición sin cota
CREATE TABLE condor.reading_by_aircraft_month (
    aircraft text, month text, ts timestamp, flight_id text,
    altitude_ft int, ias_kt int, egt_c int, n1_pct int, oil_press_psi int, oil_temp_c int, fuel_flow_pph int,
    PRIMARY KEY ((aircraft, month), ts)
) WITH CLUSTERING ORDER BY (ts ASC);

-- consulta 2: un vuelo completo, en orden. La partición es el vuelo
CREATE TABLE condor.reading_by_flight (
    flight_id text, ts timestamp, aircraft text,
    altitude_ft int, ias_kt int, egt_c int, n1_pct int, oil_press_psi int, oil_temp_c int, fuel_flow_pph int,
    PRIMARY KEY ((flight_id), ts)
) WITH CLUSTERING ORDER BY (ts ASC);

-- consulta 3: las excedencias de EGT de toda la flota en un día. Solo entran las lecturas sobre el
-- umbral: el filtro lo aplica quien escribe, no quien lee
CREATE TABLE condor.egt_exceedance_by_day (
    day date, aircraft text, ts timestamp, flight_id text, egt_c int,
    PRIMARY KEY ((day), aircraft, ts)
);

-- la misma consulta 1 sobre las 50 M lecturas ampliadas ×10, para medir contra el Postgres
-- particionado de la Fase 10
CREATE TABLE condor.reading_x10_by_aircraft_month (
    aircraft text, month text, ts timestamp, flight_id text,
    altitude_ft int, ias_kt int, egt_c int, n1_pct int, oil_press_psi int, oil_temp_c int, fuel_flow_pph int,
    PRIMARY KEY ((aircraft, month), ts)
) WITH CLUSTERING ORDER BY (ts ASC);
