-- postgres
-- La consulta de la primera versión de src/25-…/03_cantidad.sql que llenó /dev/shm (E-69). Solo lee.
SELECT (SELECT sum(x."Cantidad") FROM legacy."ProtocoloPracticas" AS x
          JOIN legacy."Protocolos" AS o USING ("IdProtocolo") WHERE o."Fecha" >= '2025-01-01') AS "Unidades en legacy",
       (SELECT sum(quantity) FROM alameda.billed_practice) AS "Unidades en el modelo",
       (SELECT sum(x."Cantidad") FROM staging.rejection AS r
          JOIN legacy."ProtocoloPracticas" AS x ON x."Id" = r.source_key::integer
         WHERE r.rule = 'facturacion.practica_sin_precio_vigente') AS "Unidades rechazadas",
       (SELECT sum(x."Cantidad") FROM legacy."ProtocoloPracticas" AS x
          JOIN legacy."Protocolos" AS o USING ("IdProtocolo") WHERE o."Fecha" >= '2025-01-01')
     - (SELECT sum(quantity) FROM alameda.billed_practice)
     - (SELECT sum(x."Cantidad") FROM staging.rejection AS r
          JOIN legacy."ProtocoloPracticas" AS x ON x."Id" = r.source_key::integer
         WHERE r.rule = 'facturacion.practica_sin_precio_vigente') AS "Sin destino";
