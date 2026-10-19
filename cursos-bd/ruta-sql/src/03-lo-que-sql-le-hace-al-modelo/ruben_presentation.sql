-- postgres
-- La presentación de diciembre de 2009 a PAMI, como la escribiría Rubén: las prácticas del mes de
-- los protocolos con la obra social escrita de alguna de las formas conocidas, con su precio del mes.
SELECT count(*) AS filas,
       count(DISTINCT pp."Id") AS practicas,
       sum(pr."Valor") AS total
FROM legacy."Protocolos" AS p
JOIN legacy."ProtocoloPracticas" AS pp ON pp."IdProtocolo" = p."IdProtocolo"
JOIN legacy."Precios_2009_12" AS pr ON pr."CodPractica" = pp."CodigoPractica"
WHERE p."Fecha" >= '2009-12-01' AND p."Fecha" < '2010-01-01'
  AND p."ObraSocial" IN ('PAMI', 'Pami', 'pami', 'P.A.M.I.', 'INSSJP');
