-- postgres
-- 🏆 "Un martes" · deshace la solución de referencia (01_setup.sql de este directorio) y deja el modelo
-- como lo tiene un lector que llega a la Fase 26 sin resolver el boss. Lo de 00_base.sql (el aumento de
-- octubre, las tablas de la presentación, el rol facturacion) y el día de convivencia de la Fase 25 se
-- quedan: los dejan los scripts publicados. Agregado el 18/10/2026 (T13).

REVOKE SELECT ON staging.rejection FROM facturacion;
DROP INDEX IF EXISTS alameda.billed_practice_lab_order_id_idx, alameda.billed_practice_billed_during_idx;
ALTER TABLE alameda.billed_practice DROP COLUMN IF EXISTS lab_order_id;
ALTER TABLE alameda.lab_order DROP COLUMN IF EXISTS copay;

-- Las dos funciones del aplicador, como las publica src/25-la-migracion-sin-parar/04_cdc_setup.sql.
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
