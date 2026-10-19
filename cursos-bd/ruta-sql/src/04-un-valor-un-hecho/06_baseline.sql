-- postgres
-- Cuántas filas tiene cada tabla de origen y cuántas debería rechazar cada regla según la verdad.
TRUNCATE staging.rule_baseline;
INSERT INTO staging.rule_baseline (rule, source_rows, truth_rows) VALUES
    ('obras_sociales.sin_sigla', (SELECT count(*) FROM legacy."ObrasSociales"), NULL),
    ('protocolos.obra_social_sin_resolver', (SELECT count(*) FROM legacy."Protocolos" WHERE "Fecha" < '2012-01-01'),
     (SELECT count(*) FROM legacy."Protocolos" AS p JOIN truth.order_payer AS op ON op.legacy_protocol_id = p."IdProtocolo"
      WHERE p."Fecha" < '2012-01-01' AND coalesce(op.written_as, '') = '')),
    ('pacientes.documento_en_nombre', (SELECT count(*) FROM legacy."Pacientes"),
     (SELECT count(*) FROM truth.patient_record WHERE 'dni_in_name' = ANY (dirt))),
    ('pacientes.nacimiento_posterior_al_alta', (SELECT count(*) FROM legacy."Pacientes"),
     (SELECT count(*) FROM truth.patient_record WHERE 'future_birth' = ANY (dirt))),
    ('pacientes.dni_con_formato_invalido', (SELECT count(*) FROM legacy."Pacientes"),
     (SELECT count(*) FROM truth.patient_record WHERE 'passport_in_dni' = ANY (dirt))),
    ('resultados.protocolo_inexistente', (SELECT count(*) FROM legacy."ResultadoItem"), NULL);
