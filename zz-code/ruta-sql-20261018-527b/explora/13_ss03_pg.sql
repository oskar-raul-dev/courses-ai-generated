-- postgres · ss03, ejercicios 7, 13 y 19
SELECT p."Sede", count(DISTINCT p."IdProtocolo") AS protocolos, count(r."IdItem") AS resultados
FROM legacy."Protocolos" AS p LEFT JOIN legacy."ResultadoItem" AS r USING ("IdProtocolo")
WHERE p."Fecha" >= '2026-09-01' GROUP BY 1 ORDER BY 1;
SELECT count(*) AS protocolos_e, max("Fecha") AS ultimo_e,
       (SELECT count(*) FROM legacy."Protocolos" WHERE "Fecha" > (SELECT max("Fecha") FROM legacy."Protocolos" WHERE "Sede" = 'E')) AS posteriores
FROM legacy."Protocolos" WHERE "Sede" = 'E';
