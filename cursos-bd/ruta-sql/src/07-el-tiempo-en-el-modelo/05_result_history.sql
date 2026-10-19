-- postgres
-- La pregunta de Norma: "¿quién cambió este resultado, cuándo, y qué decía antes?". Cada corrección de
-- un resultado guarda la versión anterior, con el período en que fue la vigente (tiempo de
-- transacción) y quién la reemplazó. Sobre los resultados del 9 de octubre de 2026; el modelo de
-- resultados completo es de la Fase 08.
DROP TABLE IF EXISTS staging.result_item_history, staging.result_item_current;
CREATE TABLE staging.result_item_current (
    result_item_id integer PRIMARY KEY,
    lab_order_id   integer NOT NULL,
    analyte_code   varchar(10) NOT NULL,
    value_text     varchar(50),
    recorded_at    timestamptz NOT NULL DEFAULT now(),
    recorded_by    text NOT NULL DEFAULT current_setting('application_name')
);
CREATE TABLE staging.result_item_history (
    result_item_id integer NOT NULL REFERENCES staging.result_item_current (result_item_id),
    value_text     varchar(50),
    recorded_by    text NOT NULL,
    replaced_by    text NOT NULL,
    system_during  tstzrange NOT NULL,              -- desde que se guardó hasta que se corrigió
    CONSTRAINT result_item_history_pkey PRIMARY KEY (result_item_id, system_during WITHOUT OVERLAPS)
);

CREATE OR REPLACE FUNCTION staging.result_item_keep_history() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.value_text IS DISTINCT FROM OLD.value_text THEN
        INSERT INTO staging.result_item_history (result_item_id, value_text, recorded_by, replaced_by, system_during)
        VALUES (OLD.result_item_id, OLD.value_text, OLD.recorded_by, current_setting('application_name'),
                tstzrange(OLD.recorded_at, clock_timestamp()));
        NEW.recorded_at := clock_timestamp();
        NEW.recorded_by := current_setting('application_name');
    END IF;
    RETURN NEW;
END
$$;
CREATE TRIGGER result_item_keep_history BEFORE UPDATE ON staging.result_item_current
    FOR EACH ROW EXECUTE FUNCTION staging.result_item_keep_history();

INSERT INTO staging.result_item_current (result_item_id, lab_order_id, analyte_code, value_text, recorded_at, recorded_by)
SELECT r."IdItem", r."IdProtocolo", r."CodDeterminacion", r."Valor", r."FechaCarga", 'carga-legacy'
FROM legacy."ResultadoItem" AS r
WHERE r."FechaCarga" >= '2026-10-09' AND r."FechaCarga" < '2026-10-10';
