-- postgres
-- Fase 25 · la reconciliación que no cerró: lo facturado del modelo (Fase 07) contra ProtocoloPracticas.
-- La Fase 07 trajo una fila por práctica y se olvidó de la cantidad. Se arregla con expand: la columna
-- nueva con su valor por defecto (no reescribe la tabla), el relleno desde legacy y la restricción.

-- Antes: cuántas unidades hay en legacy y cuántas cuenta el modelo, desde 2025.
SELECT sum(x."Cantidad") AS "Unidades en legacy",
       count(*) AS "Filas en legacy",
       (SELECT count(*) FROM alameda.billed_practice) AS "Filas en el modelo",
       count(*) FILTER (WHERE x."Cantidad" <> 1) AS "Prácticas con cantidad distinta de 1"
FROM legacy."ProtocoloPracticas" AS x
JOIN legacy."Protocolos" AS o USING ("IdProtocolo")
WHERE o."Fecha" >= '2025-01-01';

ALTER TABLE alameda.billed_practice ADD COLUMN IF NOT EXISTS quantity integer NOT NULL DEFAULT 1;
UPDATE alameda.billed_practice AS b SET quantity = x."Cantidad"
FROM legacy."ProtocoloPracticas" AS x
WHERE x."Id" = b.legacy_order_practice_id AND x."Cantidad" IS DISTINCT FROM b.quantity;
ALTER TABLE alameda.billed_practice DROP CONSTRAINT IF EXISTS billed_practice_quantity_check;
ALTER TABLE alameda.billed_practice ADD CONSTRAINT billed_practice_quantity_check CHECK (quantity > 0);

-- Después: cada práctica de legacy desde 2025 tiene un destino, y se cuenta en una sola pasada (cuatro
-- subconsultas con hash joins en paralelo llenaron los 64 MB de /dev/shm del contenedor: a08).
WITH src AS (
    SELECT x."Id", x."Cantidad",
           b.quantity,
           EXISTS (SELECT 1 FROM staging.rejection AS r
                   WHERE r.rule = 'facturacion.practica_sin_precio_vigente' AND r.source_key = x."Id"::text) AS rechazada
    FROM legacy."ProtocoloPracticas" AS x
    JOIN legacy."Protocolos" AS o USING ("IdProtocolo")
    LEFT JOIN alameda.billed_practice AS b ON b.legacy_order_practice_id = x."Id"
    WHERE o."Fecha" >= '2025-01-01')
SELECT CASE WHEN quantity IS NOT NULL THEN 'en el modelo'
            WHEN rechazada THEN 'rechazada: sin precio vigente'
            ELSE 'sin destino' END AS "Destino",
       count(*) AS "Prácticas",
       sum("Cantidad") AS "Unidades en legacy",
       sum(quantity) AS "Unidades en el modelo",
       count(*) FILTER (WHERE quantity IS DISTINCT FROM "Cantidad" AND quantity IS NOT NULL) AS "Cantidad distinta"
FROM src GROUP BY 1 ORDER BY 1;
