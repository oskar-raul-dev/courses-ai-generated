-- Ejercicio 25 · la planilla del sistema nuevo, probada dentro de una transacción que se deshace.
BEGIN;
CREATE TABLE alameda.specimen (
    specimen_id   integer     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    lab_order_id  integer     NOT NULL REFERENCES alameda.lab_order,
    collected_at  timestamp   NOT NULL,
    taken_by      text,
    taken_at      timestamp,
    CHECK ((taken_by IS NULL) = (taken_at IS NULL))
);
-- La cola: solo las pendientes, en el orden en que se toman.
CREATE INDEX specimen_pending_idx ON alameda.specimen (collected_at, specimen_id) WHERE taken_by IS NULL;
INSERT INTO alameda.specimen (lab_order_id, collected_at)
SELECT lab_order_id, ordered_on FROM alameda.lab_order WHERE ordered_on >= '2026-10-07' ORDER BY lab_order_id;
EXPLAIN (COSTS OFF)
UPDATE alameda.specimen SET taken_by = 'tecnico_a', taken_at = localtimestamp
WHERE specimen_id = (SELECT specimen_id FROM alameda.specimen WHERE taken_by IS NULL
                     ORDER BY collected_at, specimen_id LIMIT 1 FOR UPDATE SKIP LOCKED)
RETURNING specimen_id;
SELECT count(*) AS pending FROM alameda.specimen WHERE taken_by IS NULL;
ROLLBACK;
