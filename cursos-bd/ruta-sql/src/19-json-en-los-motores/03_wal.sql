-- Fase 19 · la rotura: cuántos bytes de WAL escribe corregir UN antibiótico, según la forma.
-- La historia de un paciente es el documento grande (hasta cinco cultivos); el cultivo, el mediano; la fila larga, la chica.
-- Se hace un CHECKPOINT y una corrección de calentamiento antes de medir, para que la primera escritura de página
-- (la imagen completa de la página) no cuente en la medida.

DROP TABLE IF EXISTS staging.patient_doc;
CREATE TABLE staging.patient_doc AS
SELECT person_id,
       jsonb_agg(jsonb_build_object('culture', culture_id, 'date', culture_date, 'germ', germ,
                                    'antibiogram', antibiogram) ORDER BY culture_date, culture_id) AS history
FROM staging.culture_doc
GROUP BY person_id;
ALTER TABLE staging.patient_doc ADD PRIMARY KEY (person_id);
VACUUM ANALYZE staging.patient_doc;

SELECT 'historia de 4977' AS what, pg_column_size(history) AS bytes FROM staging.patient_doc WHERE person_id = 4977
UNION ALL
SELECT 'cultivo de 4977 (el primero)', pg_column_size(antibiogram) FROM staging.culture_doc
WHERE culture_id = (SELECT min(culture_id) FROM staging.culture_doc WHERE person_id = 4977);

CHECKPOINT;

-- Cada forma se corre cuatro veces seguidas y se reporta la última: las tres primeras absorben la imagen
-- completa de página que sigue al CHECKPOINT. El valor alterna entre S y R para que siempre cambie algo.
DO $$
DECLARE
  pid  integer := 4977;
  cid  integer;
  b0   pg_lsn;
  b1   pg_lsn;
  v    text := 'S';
  i    integer;
BEGIN
  SELECT min(culture_id) INTO cid FROM staging.culture_doc WHERE person_id = pid;

  FOR i IN 1..4 LOOP
    v := CASE WHEN v = 'S' THEN 'R' ELSE 'S' END;
    SELECT pg_current_wal_insert_lsn() INTO b0;
    UPDATE staging.antibiogram_long SET sensitivity = v::char(1) WHERE culture_id = cid AND antibiotic = 'CIPROFLOXACINA';
    SELECT pg_current_wal_insert_lsn() INTO b1;
    RAISE NOTICE 'fila larga, corrida %: % bytes de WAL', i, pg_wal_lsn_diff(b1, b0);
  END LOOP;

  FOR i IN 1..4 LOOP
    v := CASE WHEN v = 'S' THEN 'R' ELSE 'S' END;
    SELECT pg_current_wal_insert_lsn() INTO b0;
    UPDATE staging.culture_doc SET antibiogram = jsonb_set(antibiogram, '{CIPROFLOXACINA}', to_jsonb(v)) WHERE culture_id = cid;
    SELECT pg_current_wal_insert_lsn() INTO b1;
    RAISE NOTICE 'documento del cultivo, corrida %: % bytes de WAL', i, pg_wal_lsn_diff(b1, b0);
  END LOOP;

  FOR i IN 1..4 LOOP
    v := CASE WHEN v = 'S' THEN 'R' ELSE 'S' END;
    SELECT pg_current_wal_insert_lsn() INTO b0;
    UPDATE staging.patient_doc SET history = jsonb_set(history, '{0,antibiogram,CIPROFLOXACINA}', to_jsonb(v)) WHERE person_id = pid;
    SELECT pg_current_wal_insert_lsn() INTO b1;
    RAISE NOTICE 'historia del paciente, corrida %: % bytes de WAL', i, pg_wal_lsn_diff(b1, b0);
  END LOOP;
END $$;
