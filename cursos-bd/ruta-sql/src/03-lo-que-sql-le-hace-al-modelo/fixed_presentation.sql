-- postgres
-- La misma presentación, sin perder ni duplicar en silencio: cada práctica una vez, el precio con
-- un criterio declarado (el menor de los repetidos) y las que no tienen precio a la vista.
SELECT count(*) AS practicas,
       count(pr."Valor") AS con_precio,
       sum(pr."Valor") AS total
FROM legacy."Protocolos" AS p
JOIN legacy."ProtocoloPracticas" AS pp ON pp."IdProtocolo" = p."IdProtocolo"
LEFT JOIN (SELECT "CodPractica", min("Valor") AS "Valor"
           FROM legacy."Precios_2009_12"
           GROUP BY "CodPractica") AS pr
       ON pr."CodPractica" = pp."CodigoPractica"
WHERE p."Fecha" >= '2009-12-01' AND p."Fecha" < '2010-01-01'
  AND p."ObraSocial" IN ('PAMI', 'Pami', 'pami', 'P.A.M.I.', 'INSSJP');

-- Y lo que ninguna de las dos puede ver: los protocolos del mes sin obra social escrita, que alguien
-- tiene que revisar a mano antes de presentar.
SELECT count(*) FILTER (WHERE p."ObraSocial" IS NULL) AS nulos,
       count(*) FILTER (WHERE p."ObraSocial" = '') AS vacios
FROM legacy."Protocolos" AS p
WHERE p."Fecha" >= '2009-12-01' AND p."Fecha" < '2010-01-01';
