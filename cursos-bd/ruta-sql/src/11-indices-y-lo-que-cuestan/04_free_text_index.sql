-- postgres
-- La rotura: un índice B-tree sobre observaciones de texto libre. En la caja, Obs tiene hasta 255
-- caracteres; en el modelo nuevo, una observación es text, y la recepción pega ahí lo que sea. Una nota
-- de 3 kB que no se comprime (un informe pegado, con números de todo tipo) basta.
DROP TABLE IF EXISTS staging.order_note;
CREATE TABLE staging.order_note (lab_order_id integer PRIMARY KEY, note text);
INSERT INTO staging.order_note
SELECT lab_order_id, 'OBS ' || lab_order_id FROM alameda.lab_order WHERE ordered_on = '2025-03-03';
INSERT INTO staging.order_note
SELECT -1, (SELECT string_agg(md5(g::text), ' ') FROM generate_series(1, 90) AS g);
-- ERROR: index row size … exceeds btree version 4 maximum 2704 for index "order_note_note_idx"
CREATE INDEX order_note_note_idx ON staging.order_note (note);
