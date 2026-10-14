\echo == ej2
SELECT "IdProtocolo", "NroProtocolo", "Fecha"::date, "Sede" FROM legacy."Protocolos" WHERE "NroProtocolo" !~ '^([A-Z]-)?[0-9]{6,7}$' ORDER BY "Fecha";
\echo == ej10
WITH s AS (SELECT substring("NroProtocolo" from 3)::int n, "Fecha"::date d FROM legacy."Protocolos" WHERE "NroProtocolo" LIKE 'C-%' AND "Fecha" >= '2025-03-03' AND "Fecha" < '2025-03-10')
SELECT count(*) protocolos, count(DISTINCT n) numeros_distintos, max(n) - min(n) + 1 rango FROM s;
\echo == ej18
DROP SEQUENCE IF EXISTS staging.hilo_seq;
CREATE SEQUENCE staging.hilo_seq INCREMENT BY 50;
SELECT nextval('staging.hilo_seq') AS primera_sesion;
SELECT nextval('staging.hilo_seq') AS segunda_sesion;
\echo == ej19 el diccionario para el perfil S
\timing on
SELECT count(*) FROM (SELECT md5(p || lpad(n::text, 7, '0')) FROM unnest(ARRAY['C-','A-','V-','J-','R-','E-']) AS p CROSS JOIN generate_series(1, 70000) AS n) x;
\timing off
