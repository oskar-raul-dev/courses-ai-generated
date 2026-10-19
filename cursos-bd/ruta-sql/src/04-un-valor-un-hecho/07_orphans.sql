-- postgres
-- Los resultados sin protocolo pasan a la tabla de rechazos, y recién entonces la clave se valida.
-- NOT VALID ya protegía las filas nuevas; VALIDATE certifica las viejas.
ALTER TABLE staging.result_item DROP CONSTRAINT IF EXISTS result_item_lab_order_id_fkey;
ALTER TABLE staging.result_item
    ADD CONSTRAINT result_item_lab_order_id_fkey FOREIGN KEY (lab_order_id)
    REFERENCES staging.lab_order (lab_order_id) NOT VALID;

INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
SELECT '04', 'resultados.protocolo_inexistente', 'ResultadoItem', ri.result_item_id::text, ri.lab_order_id::text, NULL
FROM staging.result_item AS ri
WHERE NOT EXISTS (SELECT 1 FROM staging.lab_order AS o WHERE o.lab_order_id = ri.lab_order_id);

DELETE FROM staging.result_item AS ri
WHERE NOT EXISTS (SELECT 1 FROM staging.lab_order AS o WHERE o.lab_order_id = ri.lab_order_id);

ALTER TABLE staging.result_item VALIDATE CONSTRAINT result_item_lab_order_id_fkey;
