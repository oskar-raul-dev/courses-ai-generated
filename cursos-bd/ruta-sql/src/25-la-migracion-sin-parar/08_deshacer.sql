-- postgres
-- Fase 25 · la vuelta atrás de la fase entera, en el orden inverso: lo que escribió el día de convivencia
-- (en legacy y en el modelo), el slot, y los resultados y analitos que trajo la migración de las anchas.
-- Deja la cantidad de lo facturado (03_cantidad.sql), que es un arreglo y no una tanda.
-- Se puede correr las veces que haga falta; después se repite desde 01_anchas.sql.

SELECT pg_drop_replication_slot(slot_name) FROM pg_replication_slots WHERE slot_name = 'f25_legacy';

-- El día de convivencia: el lunes 12/10/2026, que la caja no tiene.
CREATE TEMP TABLE dia AS SELECT "IdProtocolo" FROM legacy."Protocolos" WHERE "Fecha" >= '2026-10-12';
DELETE FROM alameda.result WHERE lab_order_id IN (SELECT "IdProtocolo" FROM dia);
DELETE FROM alameda.billed_practice WHERE legacy_order_practice_id IN (
    SELECT "Id" FROM legacy."ProtocoloPracticas" WHERE "IdProtocolo" IN (SELECT "IdProtocolo" FROM dia));
DELETE FROM alameda.lab_order WHERE lab_order_id IN (SELECT "IdProtocolo" FROM dia);
DELETE FROM legacy."ResultadoItem" WHERE "IdProtocolo" IN (SELECT "IdProtocolo" FROM dia);
DELETE FROM legacy."ProtocoloPracticas" WHERE "IdProtocolo" IN (SELECT "IdProtocolo" FROM dia);
DELETE FROM legacy."Protocolos" WHERE "IdProtocolo" IN (SELECT "IdProtocolo" FROM dia);
DELETE FROM staging.rejection WHERE phase = '25';

-- La migración de las anchas: por el mapa, que es lo que la hace reversible.
DO $$ BEGIN
    IF to_regclass('staging.wide_result') IS NOT NULL THEN
        DELETE FROM alameda.result WHERE result_id IN (SELECT result_id FROM staging.wide_result);
        DELETE FROM alameda.analyte WHERE analyte_code IN (SELECT analyte_code FROM staging.wide_column WHERE NOT typed)
          AND NOT EXISTS (SELECT 1 FROM alameda.result AS r WHERE r.analyte_code = analyte.analyte_code);
    END IF;
END $$;
DROP TABLE IF EXISTS staging.wide_column, staging.wide_cell, staging.wide_result, staging.wide_unmapped,
                     staging.f25_cdc_position, staging.f25_cdc_log;
DROP SEQUENCE IF EXISTS staging.wide_result_id_seq;

SELECT (SELECT count(*) FROM alameda.result) AS "Resultados", (SELECT count(*) FROM alameda.analyte) AS "Analitos",
       (SELECT count(*) FROM legacy."Protocolos" WHERE "Fecha" >= '2026-10-12') AS "Protocolos del día";
