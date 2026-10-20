\pset footer off
CREATE TEMP TABLE t (a TIMESTAMPTZ, b TIMESTAMP);
INSERT INTO t VALUES ('2026-08-30 20:00:00-05', '2026-08-30 20:00:00-05');
SET TIME ZONE 'America/Panama'; SELECT * FROM t;
SET TIME ZONE 'UTC';            SELECT * FROM t;
SET TIME ZONE 'Asia/Tokyo';     SELECT * FROM t;
SELECT '2026-08-30 20:00:00-05'::timestamptz = '2026-08-31 01:00:00+00'::timestamptz AS iguales;
SET TIME ZONE 'UTC';
-- Santiago, abril: 23:30 del sábado 4 existe dos veces
SELECT '2026-04-04 23:30:00'::timestamp AT TIME ZONE 'America/Santiago' AS abril_2330;
SELECT ts AT TIME ZONE 'America/Santiago' AS pared_santiago, ts FROM (VALUES ('2026-04-05 02:30:00+00'::timestamptz), ('2026-04-05 03:30:00+00'::timestamptz)) v(ts);
-- Santiago, septiembre: 00:30 del domingo 6 no existe
SELECT '2026-09-06 00:30:00'::timestamp AT TIME ZONE 'America/Santiago' AS sept_0030;
SELECT ts AT TIME ZONE 'America/Santiago' AS pared, ts FROM (VALUES ('2026-09-06 03:59:00+00'::timestamptz), ('2026-09-06 04:00:00+00'::timestamptz)) v(ts);
-- Asunción
SELECT tz, '2025-07-01 12:00:00+00'::timestamptz AT TIME ZONE tz AS julio_2025 FROM (VALUES ('America/Asuncion'),('America/Santiago'),('America/Panama')) v(tz);
