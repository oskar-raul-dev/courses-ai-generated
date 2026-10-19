-- postgres
-- 🏆 "Un martes" · la solución de referencia (no se publica, D42). Lo que la base nueva no tenía y la
-- facturación necesita, con expand: columnas nuevas, relleno desde legacy (esto corre como superusuario,
-- una vez, como una tanda de migración) y el aplicador del CDC que las mantiene al día.

-- 1. El coseguro, en el protocolo.
ALTER TABLE alameda.lab_order ADD COLUMN IF NOT EXISTS copay numeric(19, 2) NOT NULL DEFAULT 0;
UPDATE alameda.lab_order AS o SET copay = p."Coseguro"
FROM legacy."Protocolos" AS p
WHERE p."IdProtocolo" = o.lab_order_id AND p."Coseguro" IS NOT NULL AND p."Coseguro" <> o.copay
  AND o.ordered_on >= '2025-01-01';

-- 2. El protocolo de cada práctica facturada: la Fase 07 trajo la práctica sin su protocolo.
ALTER TABLE alameda.billed_practice ADD COLUMN IF NOT EXISTS lab_order_id integer REFERENCES alameda.lab_order (lab_order_id);
UPDATE alameda.billed_practice AS b SET lab_order_id = x."IdProtocolo"
FROM legacy."ProtocoloPracticas" AS x
WHERE x."Id" = b.legacy_order_practice_id AND b.lab_order_id IS DISTINCT FROM x."IdProtocolo";
CREATE INDEX IF NOT EXISTS billed_practice_lab_order_id_idx ON alameda.billed_practice (lab_order_id);
CREATE INDEX IF NOT EXISTS billed_practice_billed_during_idx ON alameda.billed_practice USING gist (billed_during);

-- 3. El aplicador: las mismas funciones de la Fase 25, más las dos columnas.
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
    INSERT INTO alameda.lab_order (lab_order_id, patient_id, ordered_on, site_code, payer_code, copay)
    SELECT (f->>'IdProtocolo')::integer, v_patient, (f->>'Fecha')::date, f->>'Sede',
           coalesce((SELECT payer_code FROM alameda.payer WHERE payer_id = (f->>'IdObraSocial')::integer),
                    (SELECT payer_code FROM staging.payer_alias WHERE written_as = f->>'ObraSocial')),
           coalesce((f->>'Coseguro')::numeric, 0)
    ON CONFLICT (lab_order_id) DO UPDATE
        SET patient_id = excluded.patient_id, ordered_on = excluded.ordered_on,
            site_code = excluded.site_code, payer_code = excluded.payer_code, copay = excluded.copay;
END $$;

CREATE OR REPLACE FUNCTION staging.f25_apply_practice(f jsonb)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE v_id integer := (f->>'Id')::integer; v_order integer := (f->>'IdProtocolo')::integer;
        v_payer text; v_date date; v_practice integer;
BEGIN
    SELECT payer_code, ordered_on INTO v_payer, v_date FROM alameda.lab_order WHERE lab_order_id = v_order;
    SELECT practice_id INTO v_practice FROM alameda.practice_code
    WHERE nomenclator_code = f->>'Nomenclador' AND code = f->>'CodigoPractica';
    IF v_date IS NULL OR v_date < '2025-01-01' THEN
        RETURN;
    END IF;
    IF v_practice IS NULL OR v_payer IS NULL THEN
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
    INSERT INTO alameda.billed_practice (legacy_order_practice_id, payer_code, practice_id, billed_during, quantity,
                                         lab_order_id)
    VALUES (v_id, v_payer, v_practice, daterange(v_date, v_date + 1), coalesce((f->>'Cantidad')::integer, 1), v_order)
    ON CONFLICT (legacy_order_practice_id) DO UPDATE
        SET payer_code = excluded.payer_code, practice_id = excluded.practice_id,
            billed_during = excluded.billed_during, quantity = excluded.quantity, lab_order_id = excluded.lab_order_id;
END $$;

-- 4. Facturación lee la cola de rechazos: lo que no tiene precio vigente no es facturable, pero es plata
--    que alguien tiene que negociar, y la presentación lo lista.
GRANT SELECT ON staging.rejection TO facturacion;
