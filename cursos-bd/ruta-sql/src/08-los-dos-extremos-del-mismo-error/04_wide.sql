-- postgres
-- La tabla ancha, como las 71 de antes de 2008 pero con todas las determinaciones: una fila por
-- protocolo y una columna de texto por determinación.
DROP TABLE IF EXISTS staging.result_wide;
DO $$
DECLARE cols text; sel text;
BEGIN
    SELECT string_agg(format('%I varchar(50)', lower(analyte_code)), ', ' ORDER BY analyte_code),
           string_agg(format('max(value) FILTER (WHERE analyte_code = %L)', analyte_code), ', ' ORDER BY analyte_code)
      INTO cols, sel
    FROM alameda.analyte;
    EXECUTE format('CREATE TABLE staging.result_wide (lab_order_id integer PRIMARY KEY, %s)', cols);
    EXECUTE format('INSERT INTO staging.result_wide SELECT lab_order_id, %s FROM staging.result_eav GROUP BY lab_order_id', sel);
END
$$;
ANALYZE staging.result_wide;
