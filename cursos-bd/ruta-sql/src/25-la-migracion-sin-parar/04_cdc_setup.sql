-- postgres
-- Fase 25 · la convivencia: el frontal Access sigue escribiendo en legacy, y cada cambio confirmado
-- llega al modelo por decodificación lógica (Fase 22, test_decoding). En el laboratorio, legacy vive en
-- el mismo Postgres; en Alameda vive en SQL Server, y su CDC es otro (track, ss01). La forma es la misma.
--
-- Antes: 01_anchas.sql y 03_cantidad.sql. Deja: el rol del frontal, el slot, la posición aplicada y las
-- funciones que aplican cada cambio. Corre otra vez sin romper nada: rehace el slot desde ahora.

-- El frontal escribe con su propio rol: el corte de la sección 5.5 le quita la escritura a ese rol.
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'access_frontend') THEN
        CREATE ROLE access_frontend LOGIN PASSWORD 'frontal-de-laboratorio';
    END IF;
END $$;
GRANT USAGE ON SCHEMA legacy TO access_frontend;
GRANT SELECT, INSERT, UPDATE, DELETE ON legacy."Protocolos", legacy."ProtocoloPracticas", legacy."ResultadoItem"
    TO access_frontend;
GRANT SELECT ON legacy."Pacientes", legacy."Determinaciones" TO access_frontend;

-- La posición: el último LSN aplicado, escrito en la misma transacción que los cambios. Si el aplicador
-- se cae entre confirmar y avanzar el slot, al volver relee esos cambios y los saltea.
CREATE TABLE IF NOT EXISTS staging.f25_cdc_position (
    slot_name   text PRIMARY KEY,
    applied_lsn pg_lsn NOT NULL,
    applied_at  timestamptz NOT NULL DEFAULT clock_timestamp()
);
-- Una fila por transacción de legacy aplicada: cuándo confirmó allá y cuándo acá. Es la medida de atraso.
CREATE TABLE IF NOT EXISTS staging.f25_cdc_log (
    xid          bigint NOT NULL,
    commit_lsn   pg_lsn PRIMARY KEY,
    committed_at timestamptz NOT NULL,
    applied_at   timestamptz NOT NULL DEFAULT clock_timestamp(),
    changes      integer NOT NULL
);

-- Un día de convivencia anterior (el lunes 12/10/2026, que la caja no tiene) se borra antes de crear el
-- slot, en legacy y en el modelo, para que la corrida nueva se reconcilie sola.
SELECT pg_drop_replication_slot(slot_name) FROM pg_replication_slots WHERE slot_name = 'f25_legacy';
CREATE TEMP TABLE dia AS SELECT "IdProtocolo" FROM legacy."Protocolos" WHERE "Fecha" >= '2026-10-12';
DELETE FROM alameda.result WHERE lab_order_id IN (SELECT "IdProtocolo" FROM dia);
DELETE FROM alameda.billed_practice WHERE legacy_order_practice_id IN (
    SELECT "Id" FROM legacy."ProtocoloPracticas" WHERE "IdProtocolo" IN (SELECT "IdProtocolo" FROM dia));
DELETE FROM alameda.lab_order WHERE lab_order_id IN (SELECT "IdProtocolo" FROM dia);
DELETE FROM legacy."ResultadoItem" WHERE "IdProtocolo" IN (SELECT "IdProtocolo" FROM dia);
DELETE FROM legacy."ProtocoloPracticas" WHERE "IdProtocolo" IN (SELECT "IdProtocolo" FROM dia);
DELETE FROM legacy."Protocolos" WHERE "IdProtocolo" IN (SELECT "IdProtocolo" FROM dia);
DELETE FROM staging.rejection WHERE phase = '25' AND (rule LIKE 'cdc.%' OR detail = 'llegó por CDC');
SELECT 'slot' AS "Creado", slot_name FROM pg_create_logical_replication_slot('f25_legacy', 'test_decoding');
INSERT INTO staging.f25_cdc_position VALUES ('f25_legacy', '0/0')
ON CONFLICT (slot_name) DO UPDATE SET applied_lsn = '0/0', applied_at = clock_timestamp();
TRUNCATE staging.f25_cdc_log;
-- El frontal vuelve a escribir (el corte de 07_corte.py le quita la escritura, y una corrida anterior
-- puede haberlo dejado así).
GRANT INSERT, UPDATE, DELETE ON legacy."Protocolos", legacy."ProtocoloPracticas", legacy."ResultadoItem"
    TO access_frontend;

-- El valor de la caja, leído como lo leyó la Fase 08: número con coma o punto, calificador, texto de
-- los cualitativos y bandera de la muestra.
CREATE OR REPLACE FUNCTION staging.f25_value(raw text, OUT value_numeric numeric, OUT qualifier char(1),
                                             OUT value_text text, OUT sample_flag text)
LANGUAGE sql IMMUTABLE AS $$
    SELECT CASE WHEN v ~ '^[<>]?[0-9]+([.,][0-9]+)?$' THEN replace(ltrim(v, '<>'), ',', '.')::numeric END,
           CASE WHEN v ~ '^[<>][0-9]' THEN left(v, 1) END,
           CASE WHEN v IN ('DETECTABLE', 'NO DETECTABLE') THEN v END,
           CASE WHEN v IN ('HEMOLIZADA', 'REPETIR', 'MUESTRA INSUFICIENTE') THEN v END
    FROM (SELECT regexp_replace(btrim(raw), '^([<>])\s+', '\1') AS v) AS x
$$;

-- Las tres funciones reciben la fila de legacy entera, como jsonb (cdc.py no elige columnas).
-- Un protocolo nuevo o corregido. El paciente tiene que existir en el modelo: uno que no existe es
-- trabajo de la Fase 05 (la bandeja de Norma), no del aplicador.
DROP FUNCTION IF EXISTS staging.f25_apply_protocol(integer, integer, timestamp, text, integer, text),
                        staging.f25_apply_practice(integer, integer, text, text, integer),
                        staging.f25_apply_result(integer, integer, text, text, timestamp);
CREATE OR REPLACE FUNCTION staging.f25_apply_protocol(f jsonb)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE v_patient integer;
BEGIN
    SELECT coalesce(merged_into_patient_id, patient_id) INTO v_patient
    FROM alameda.patient WHERE legacy_patient_id = (f->>'IdPaciente')::integer;
    IF v_patient IS NULL THEN
        INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
        VALUES ('25', 'cdc.paciente_desconocido', 'Protocolos', f->>'IdProtocolo', f->>'IdPaciente', NULL);
        RETURN;
    END IF;
    INSERT INTO alameda.lab_order (lab_order_id, patient_id, ordered_on, site_code, payer_code)
    SELECT (f->>'IdProtocolo')::integer, v_patient, (f->>'Fecha')::date, f->>'Sede',
           coalesce((SELECT payer_code FROM alameda.payer WHERE payer_id = (f->>'IdObraSocial')::integer),
                    (SELECT payer_code FROM staging.payer_alias WHERE written_as = f->>'ObraSocial'))
    ON CONFLICT (lab_order_id) DO UPDATE
        SET patient_id = excluded.patient_id, ordered_on = excluded.ordered_on,
            site_code = excluded.site_code, payer_code = excluded.payer_code;
END $$;

-- Una práctica: entra a lo facturado si tiene precio vigente para su obra social ese día (la clave
-- foránea con período de la Fase 07 no deja otra cosa); si no, va a rechazos, como en la Fase 07.
CREATE OR REPLACE FUNCTION staging.f25_apply_practice(f jsonb)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE v_id integer := (f->>'Id')::integer; v_payer text; v_date date; v_practice integer;
BEGIN
    SELECT payer_code, ordered_on INTO v_payer, v_date FROM alameda.lab_order
    WHERE lab_order_id = (f->>'IdProtocolo')::integer;
    SELECT practice_id INTO v_practice FROM alameda.practice_code
    WHERE nomenclator_code = f->>'Nomenclador' AND code = f->>'CodigoPractica';
    IF v_date IS NULL OR v_date < '2025-01-01' THEN
        RETURN;                      -- lo facturado empieza en 2025, como en la Fase 07
    END IF;
    IF v_practice IS NULL OR v_payer IS NULL THEN
        -- La Fase 07 cargó con un JOIN, y en la caja no había ninguna así; por CDC puede llegar, y una
        -- práctica que se descarta sin rechazo es plata que nadie ve (lo encontró la primera corrida).
        INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
        VALUES ('25', CASE WHEN v_payer IS NULL THEN 'cdc.practica_sin_obra_social' ELSE 'cdc.practica_sin_codigo' END,
                'ProtocoloPracticas', v_id::text, (f->>'Nomenclador') || ' ' || (f->>'CodigoPractica'), NULL);
        RETURN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM alameda.agreement_price
                   WHERE payer_code = v_payer AND practice_id = v_practice AND valid_during @> v_date) THEN
        INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
        VALUES ('25', 'facturacion.practica_sin_precio_vigente', 'ProtocoloPracticas', v_id::text,
                v_payer || ' ' || v_practice || ' ' || v_date, 'llegó por CDC');
        DELETE FROM alameda.billed_practice WHERE legacy_order_practice_id = v_id;
        RETURN;
    END IF;
    INSERT INTO alameda.billed_practice (legacy_order_practice_id, payer_code, practice_id, billed_during, quantity)
    VALUES (v_id, v_payer, v_practice, daterange(v_date, v_date + 1), coalesce((f->>'Cantidad')::integer, 1))
    ON CONFLICT (legacy_order_practice_id) DO UPDATE
        SET payer_code = excluded.payer_code, practice_id = excluded.practice_id,
            billed_during = excluded.billed_during, quantity = excluded.quantity;
END $$;

-- Un resultado nuevo o corregido. La corrección pisa el valor, pero solo si la clave es del mismo
-- resultado: un ON CONFLICT DO UPDATE sin condición pisa en silencio cualquier fila que tenga esa clave,
-- y la primera corrida pisó así 3.321 resultados migrados de las anchas. Si la clave está ocupada por
-- otro protocolo u otro analito, va a rechazos y no se toca nada.
CREATE OR REPLACE FUNCTION staging.f25_apply_result(f jsonb)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE v_id integer := (f->>'IdItem')::integer; v_order integer := (f->>'IdProtocolo')::integer;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM alameda.lab_order WHERE lab_order_id = v_order) THEN
        INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
        VALUES ('25', 'cdc.protocolo_desconocido', 'ResultadoItem', v_id::text, f->>'Valor', NULL);
        RETURN;
    END IF;
    INSERT INTO alameda.result (result_id, lab_order_id, analyte_code, value_numeric, qualifier, value_text,
                                sample_flag, recorded_at)
    SELECT v_id, v_order, f->>'CodDeterminacion', v.value_numeric, v.qualifier, v.value_text, v.sample_flag,
           (f->>'FechaCarga')::timestamp
    FROM staging.f25_value(f->>'Valor') AS v
    ON CONFLICT (result_id) DO UPDATE
        SET value_numeric = excluded.value_numeric, qualifier = excluded.qualifier,
            value_text = excluded.value_text, sample_flag = excluded.sample_flag, recorded_at = excluded.recorded_at
        WHERE result.lab_order_id = excluded.lab_order_id AND result.analyte_code = excluded.analyte_code;
    IF NOT FOUND THEN
        INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
        VALUES ('25', 'cdc.clave_ocupada', 'ResultadoItem', v_id::text, f->>'Valor',
                'la clave ya es de otro resultado del modelo');
    END IF;
END $$;
