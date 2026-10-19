-- postgres
-- El punto de partida del boss del Bloque I, con el modelo de `uv run lab load --profile m --model`.
-- Es lo que ve Norma cuando busca a su paciente: tres pacientes, y en cada uno un pedazo de su historia.
SELECT p.patient_id, p.full_name, p.birth_date, p.merged_into_patient_id,
       string_agg(DISTINCT d.document_type || ' ' || d.number, ', ') AS documents,
       count(DISTINCT o.lab_order_id) AS lab_orders,
       min(o.ordered_on) AS first_order, max(o.ordered_on) AS last_order
FROM alameda.patient AS p
LEFT JOIN alameda.identity_document AS d ON d.patient_id = p.patient_id
LEFT JOIN alameda.lab_order AS o ON o.patient_id = p.patient_id
WHERE p.full_name LIKE 'AGUERO%' AND p.birth_date = '1941-06-03'
   OR p.patient_id IN (SELECT patient_id FROM alameda.patient WHERE full_name = 'BUSTOS' AND birth_date = '2019-08-14')
GROUP BY p.patient_id, p.full_name, p.birth_date, p.merged_into_patient_id
ORDER BY p.patient_id;

-- Y la evolución de su glucemia, como la arma hoy el informe: solo el modelo nuevo, desde 2008.
SELECT o.patient_id, o.ordered_on, r.value_numeric, r.qualifier, r.sample_flag
FROM alameda.result AS r
JOIN alameda.lab_order AS o USING (lab_order_id)
JOIN alameda.patient AS p ON p.patient_id = o.patient_id
WHERE r.analyte_code = 'GLU' AND p.full_name LIKE 'AGUERO%' AND p.birth_date = '1941-06-03'
ORDER BY o.ordered_on
LIMIT 12;
