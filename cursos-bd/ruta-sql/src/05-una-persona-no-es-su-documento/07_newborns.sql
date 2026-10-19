-- postgres
-- La madre del recién nacido. El número que la recepción le cargó al RN es el de la madre: se busca la
-- paciente sobreviviente que tiene ese DNI, que es mujer y que nació al menos doce años antes. Si hay
-- exactamente una, se enlaza; si no, el recién nacido queda sin madre conocida, que también es válido.
WITH candidate AS (
    SELECT n.patient_id AS newborn_id, d.patient_id AS mother_id
    FROM staging.document_candidate AS r
    JOIN alameda.patient AS n ON n.patient_id = r.patient_id
    JOIN alameda.identity_document AS d ON d.document_type IN ('DNI', 'LE', 'LC') AND d.number = r.number
    JOIN alameda.patient AS m ON m.patient_id = d.patient_id
    WHERE r.document_type = 'RN'
      AND m.sex = 'F'
      AND m.birth_date <= n.birth_date - interval '12 years'
),
unique_mother AS (
    SELECT newborn_id, min(mother_id) AS mother_id
    FROM candidate GROUP BY newborn_id HAVING count(DISTINCT mother_id) = 1
)
UPDATE alameda.patient AS p SET mother_patient_id = u.mother_id
FROM unique_mother AS u
WHERE p.patient_id = u.newborn_id;
