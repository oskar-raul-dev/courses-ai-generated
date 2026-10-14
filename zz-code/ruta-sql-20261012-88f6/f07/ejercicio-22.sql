CREATE INDEX IF NOT EXISTS result_item_current_lab_order_id_idx ON staging.result_item_current (lab_order_id);
SELECT c.analyte_code, h.value_text AS decia, h.recorded_by AS lo_cargo, h.replaced_by AS lo_cambio,
       upper(h.system_during) AS cuando, c.value_text AS dice_hoy
FROM staging.result_item_current AS c
JOIN staging.result_item_history AS h USING (result_item_id)
WHERE c.lab_order_id = 11232670
ORDER BY upper(h.system_during);
SELECT count(*) resultados_del_protocolo FROM staging.result_item_current WHERE lab_order_id = 11232670;
