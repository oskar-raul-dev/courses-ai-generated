-- postgres
-- 💀 Boss II · El portal de 2018 · el sistema roto de partida.
-- El portal tal como quedó después de la corrección de la agencia: cada informe se abre con
-- ver.php?h=<md5 del número de protocolo>, y la página del médico derivante lista sus protocolos con OFFSET y un
-- count(*) para "página 1 de N", sobre una tabla sin más índice que la clave. Este script lo arma en staging y
-- muestra lo que hay que arreglar. No lo arregla. Se corre con psql.
DROP TABLE IF EXISTS staging.portal_2018;
CREATE TABLE staging.portal_2018 AS
SELECT p."IdProtocolo" AS lab_order_id, p."NroProtocolo" AS visible_number, md5(p."NroProtocolo") AS url_hash,
       p."IdMedico" AS doctor_id, p."Fecha"::date AS ordered_on, p."Sede" AS site_code, pa."Nombre" AS patient_name
FROM legacy."Protocolos" p LEFT JOIN legacy."Pacientes" pa ON pa."IdPaciente" = p."IdPaciente";
ALTER TABLE staging.portal_2018 ADD PRIMARY KEY (lab_order_id);
ANALYZE staging.portal_2018;

\echo == 1. un informe, por su enlace
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF)
SELECT * FROM staging.portal_2018 WHERE url_hash = md5('C-0118696');

\echo == 2. el script del estudiante, con MD5: los cien protocolos que siguen a uno conocido
SELECT count(*) AS informes_alcanzados
FROM generate_series(118697, 118796) n
JOIN staging.portal_2018 p ON p.url_hash = md5('C-' || lpad(n::text, 7, '0'));

\echo == 3. la página del médico derivante 144: la primera y la última, con su count(*)
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF)
SELECT lab_order_id, visible_number, ordered_on, patient_name FROM staging.portal_2018
WHERE doctor_id = 144 ORDER BY ordered_on DESC OFFSET 0 LIMIT 20;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF)
SELECT lab_order_id, visible_number, ordered_on, patient_name FROM staging.portal_2018
WHERE doctor_id = 144 ORDER BY ordered_on DESC OFFSET 1100 LIMIT 20;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF)
SELECT count(*) FROM staging.portal_2018 WHERE doctor_id = 144;
