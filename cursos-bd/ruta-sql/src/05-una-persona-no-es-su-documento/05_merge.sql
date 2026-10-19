-- postgres
-- La fusión automática del primer nivel. Los pares se agrupan (si A es B y B es C, los tres son uno), y
-- en cada grupo sobrevive el paciente más antiguo. Los demás quedan con su fila, marcados.
DROP TABLE IF EXISTS pg_temp.cluster;
CREATE TEMP TABLE cluster AS
SELECT legacy_patient_id AS member, legacy_patient_id AS root
FROM alameda.patient;
ALTER TABLE cluster ADD PRIMARY KEY (member);

-- Cada vuelta baja la raíz de cada miembro al mínimo de su vecindario; termina cuando nada cambia.
DO $$
DECLARE changed bigint;
BEGIN
    LOOP
        UPDATE cluster AS c SET root = n.root
        FROM (SELECT x.member, min(y.root) AS root
              FROM staging.match_review AS m
              JOIN cluster AS x ON x.member IN (m.patient_a, m.patient_b)
              JOIN cluster AS y ON y.member IN (m.patient_a, m.patient_b)
              WHERE m.tier = 'automatic' OR m.decision = 'same_person'
              GROUP BY x.member) AS n
        WHERE c.member = n.member AND n.root < c.root;
        GET DIAGNOSTICS changed = ROW_COUNT;
        EXIT WHEN changed = 0;
    END LOOP;
END
$$;

INSERT INTO alameda.patient_merge (kept_patient_id, merged_patient_id, reason, merged_by)
SELECT k.patient_id, m.patient_id, 'f05: mismo documento, misma fecha, nombre >= 0.8', 'matcher-f05'
FROM cluster AS c
JOIN alameda.patient AS k ON k.legacy_patient_id = c.root
JOIN alameda.patient AS m ON m.legacy_patient_id = c.member
WHERE c.member <> c.root
  AND m.merged_into_patient_id IS NULL;

UPDATE alameda.patient AS p
SET merged_into_patient_id = g.kept_patient_id, merged_at = g.merged_at, merged_by = g.merged_by
FROM alameda.patient_merge AS g
WHERE g.merged_patient_id = p.patient_id AND p.merged_into_patient_id IS NULL;
