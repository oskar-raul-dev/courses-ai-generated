-- postgres
-- Lo que filtra cada identificador. El número secuencial: el volumen de una sede en una semana. El MD5 del
-- número: nada que no se pueda revertir, con un diccionario de todos los números posibles. El UUIDv7: la
-- fecha y la hora en que se creó.
WITH s AS (SELECT substring("NroProtocolo" from 3)::int AS n, "Fecha"::date AS d
           FROM legacy."Protocolos" WHERE "NroProtocolo" LIKE 'C-%')
SELECT (SELECT min(n) FROM s WHERE d = '2025-03-10') - (SELECT min(n) FROM s WHERE d = '2025-03-03') AS diferencia_de_numeros,
       (SELECT count(*) FROM s WHERE d >= '2025-03-03' AND d < '2025-03-10') AS protocolos_de_la_semana;

-- las URL del portal de 2018, con el MD5 del número, y el diccionario de seis sedes por 700.000 números
DROP TABLE IF EXISTS staging.portal_url, staging.md5_dictionary;
CREATE TABLE staging.portal_url AS
SELECT md5("NroProtocolo") AS hash FROM legacy."Protocolos" WHERE "Fecha" >= '2018-01-01' AND "Fecha" < '2019-01-01';
CREATE TABLE staging.md5_dictionary AS
SELECT p || lpad(n::text, 7, '0') AS nro, md5(p || lpad(n::text, 7, '0')) AS hash
FROM unnest(ARRAY['C-', 'A-', 'V-', 'J-', 'R-', 'E-']) AS p CROSS JOIN generate_series(1, 700000) AS n;
CREATE INDEX md5_dictionary_hash_idx ON staging.md5_dictionary (hash);
SELECT count(*) AS urls_2018, count(d.nro) AS revertidas
FROM staging.portal_url AS u LEFT JOIN staging.md5_dictionary AS d USING (hash);

SELECT order_id, uuid_extract_version(order_id) AS version, uuid_extract_timestamp(order_id), ordered_on
FROM staging.order_uuid7 ORDER BY order_id DESC LIMIT 2;
