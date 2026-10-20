-- be-05: "No puedo crear inspecciones nuevas: dice que el id ya existe".
-- Reproduce el estado en que quedó la base de producción tras un sembrador anterior
-- al de be03, que no reajustaba esta secuencia: filas con id explícito (500…504) y
-- la secuencia apuntando al primero de ellos.
SELECT setval('inspections_id_seq', (SELECT min(id) FROM inspections), false);

-- Comprobación (el siguiente id que dará la secuencia ya existe):
--   SELECT last_value, is_called FROM inspections_id_seq;   -- 500, f
--   SELECT min(id), max(id) FROM inspections;
