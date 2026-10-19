-- postgres
-- Fase 25 · las tres reconciliaciones de la migración de las anchas. Cada una tiene que cerrar en cero,
-- o decir dónde no cierra. Antes: 01_anchas.sql.

-- R1 · Conteos, por tabla de origen. Toda celda con valor es un resultado o un rechazo, y todo resultado
--      nuevo viene de una celda: la diferencia tiene que ser cero en las dos direcciones.
SELECT c.source_table AS "Tabla",
       count(*) AS "Celdas",
       count(r.result_id) AS "Resultados",
       count(*) FILTER (WHERE x.rejection_id IS NOT NULL) AS "Rechazos",
       count(*) - count(r.result_id) - count(*) FILTER (WHERE x.rejection_id IS NOT NULL) AS "Diferencia"
FROM staging.wide_cell AS c
LEFT JOIN staging.wide_result AS r USING (source_table, lab_order_id, source_column)
LEFT JOIN staging.rejection AS x
       ON x.phase = '25' AND x.source_table = c.source_table AND x.source_key = c.lab_order_id || '.' || c.source_column
GROUP BY ROLLUP (c.source_table)
ORDER BY c.source_table NULLS FIRST
LIMIT 6;

SELECT count(*) AS "Resultados nuevos sin celda de origen"
FROM staging.wide_result AS r
WHERE NOT EXISTS (SELECT 1 FROM staging.wide_cell AS c
                  WHERE (c.source_table, c.lab_order_id, c.source_column) = (r.source_table, r.lab_order_id, r.source_column));

-- R2 · Sumas de control, por columna de origen. La suma del número leído de la celda contra la suma de
--      value_numeric en el destino, y una huella de los textos. Una columna corrida, un decimal perdido
--      o un texto cortado cambian la suma o la huella.
WITH src AS (
    SELECT c.source_table, c.source_column,
           sum(replace(regexp_replace(btrim(c.raw_value), '^[<>]\s*', ''), ',', '.')::numeric) FILTER (WHERE w.typed) AS total,
           md5(string_agg(c.lab_order_id || '|' || btrim(c.raw_value), ',' ORDER BY c.lab_order_id) FILTER (WHERE NOT w.typed)) AS huella
    FROM staging.wide_cell AS c
    JOIN staging.wide_column AS w USING (source_table, source_column)
    JOIN staging.wide_result AS r USING (source_table, lab_order_id, source_column)
    GROUP BY 1, 2),
dst AS (
    SELECT r.source_table, r.source_column,
           sum(t.value_numeric) AS total,
           md5(string_agg(t.lab_order_id || '|' || t.value_text, ',' ORDER BY t.lab_order_id) FILTER (WHERE t.value_text IS NOT NULL)) AS huella
    FROM staging.wide_result AS r
    JOIN alameda.result AS t USING (result_id)
    GROUP BY 1, 2)
SELECT count(*) AS "Columnas",
       count(*) FILTER (WHERE s.total IS DISTINCT FROM d.total) AS "Sumas distintas",
       count(*) FILTER (WHERE s.huella IS DISTINCT FROM d.huella) AS "Huellas distintas",
       sum(s.total) AS "Suma de control"
FROM src AS s JOIN dst AS d USING (source_table, source_column);

-- R3 · La verdad del generador. Cada resultado migrado cuelga de un protocolo, y la verdad sabe de qué
--      persona es cada protocolo. El modelo llega a la persona por el paciente que sobrevivió a las
--      fusiones de la Fase 05. Si no coinciden, la historia de alguien quedó en la ficha de otro.
WITH m AS (
    SELECT r.result_id, tp.person_id AS persona_modelo, top.person_id AS persona_verdad
    FROM staging.wide_result AS r
    JOIN alameda.lab_order AS o USING (lab_order_id)
    JOIN alameda.patient AS p ON p.patient_id = o.patient_id
    JOIN truth.patient_record AS tp ON tp.legacy_patient_id = p.legacy_patient_id
    JOIN truth.order_payer AS top ON top.legacy_protocol_id = r.lab_order_id)
SELECT count(*) AS "Resultados migrados con verdad",
       count(*) FILTER (WHERE persona_modelo <> persona_verdad) AS "En la persona equivocada",
       count(DISTINCT persona_verdad) FILTER (WHERE persona_modelo <> persona_verdad) AS "Personas afectadas",
       round(100.0 * count(*) FILTER (WHERE persona_modelo <> persona_verdad) / count(*), 3) AS "%"
FROM m;

-- La señora que es tres pacientes (boss I): cuántos de sus resultados ve el modelo antes y después.
SELECT count(*) FILTER (WHERE t.result_id NOT IN (SELECT result_id FROM staging.wide_result)) AS "Desde 2008",
       count(*) FILTER (WHERE t.result_id IN (SELECT result_id FROM staging.wide_result)) AS "Antes de 2008, migrados",
       min(o.ordered_on) AS "Primer protocolo"
FROM truth.planted_case AS c
JOIN truth.patient_record AS tp ON tp.person_id = c.person_id
JOIN alameda.patient AS p ON p.legacy_patient_id = tp.legacy_patient_id
JOIN alameda.lab_order AS o ON o.patient_id = coalesce(p.merged_into_patient_id, p.patient_id)
JOIN alameda.result AS t ON t.lab_order_id = o.lab_order_id
WHERE c.case_code = 'boss-1-lady';

-- Lo que la migración no tocó: los resultados de la caja siguen siendo los mismos.
SELECT count(*) AS "Resultados de ResultadoItem" FROM alameda.result
WHERE result_id <= (SELECT max("IdItem") FROM legacy."ResultadoItem");
