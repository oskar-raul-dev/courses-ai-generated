SET application_name = 'lucia2';
UPDATE staging.result_item_current SET value_text = '156' WHERE result_item_id = 12123358;
SELECT pg_sleep(1);
SET application_name = 'norma';
UPDATE staging.result_item_current SET value_text = '165' WHERE result_item_id = 12123358;
RESET application_name;
-- la pregunta de Norma, como consulta
SELECT h.value_text AS decia, h.recorded_by AS lo_cargo, h.replaced_by AS lo_cambio,
       upper(h.system_during) AS cuando
FROM staging.result_item_history AS h
WHERE h.result_item_id = 12123358
UNION ALL
SELECT c.value_text, c.recorded_by, NULL, NULL FROM staging.result_item_current AS c WHERE c.result_item_id = 12123358
ORDER BY cuando NULLS LAST;
-- y el valor que tenía el resultado en un momento dado
SELECT coalesce((SELECT h.value_text FROM staging.result_item_history h WHERE h.result_item_id = 12123358 AND h.system_during @> timestamptz '2026-10-10 12:00+00'),
                (SELECT c.value_text FROM staging.result_item_current c WHERE c.result_item_id = 12123358 AND c.recorded_at <= timestamptz '2026-10-10 12:00+00')) AS valor_el_10_al_mediodia;
