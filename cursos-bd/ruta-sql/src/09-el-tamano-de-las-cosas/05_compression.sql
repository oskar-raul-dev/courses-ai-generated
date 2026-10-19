-- postgres
-- La compresión de TOAST: 200 "órdenes escaneadas" sintéticas de 2,4 MB, un fondo blanco con poco
-- contenido, como un mapa de bits de Access sin comprimir. Una tabla con pglz (el valor por defecto) y
-- otra con lz4. Cada tabla genera sus valores: un INSERT … SELECT copia el valor ya comprimido tal cual.
DROP TABLE IF EXISTS staging.scan_pglz, staging.scan_lz4;
CREATE TABLE staging.scan_pglz (lab_order_id integer PRIMARY KEY, scan bytea COMPRESSION pglz);
CREATE TABLE staging.scan_lz4 (lab_order_id integer PRIMARY KEY, scan bytea COMPRESSION lz4);
INSERT INTO staging.scan_pglz
SELECT g, decode(repeat(repeat('ff', 2000) || md5(g::text) || repeat('ff', 400), 400), 'hex')
FROM generate_series(1, 200) AS g;
INSERT INTO staging.scan_lz4
SELECT g, decode(repeat(repeat('ff', 2000) || md5(g::text) || repeat('ff', 400), 400), 'hex')
FROM generate_series(1, 200) AS g;
