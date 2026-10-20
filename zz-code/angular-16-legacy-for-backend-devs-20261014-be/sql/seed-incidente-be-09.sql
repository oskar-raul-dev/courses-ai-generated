-- be-09: "Una inspección de 2023 no se puede reimprimir".
-- El volumen sintético (volume.php --violations=88) ya deja 88 inspecciones
-- huérfanas en un rango de tres semanas de 2023. Este guion sólo FIJA una de
-- ellas con el id que el ticket nombra, para que el enunciado sea reproducible.

UPDATE inspections
   SET id = 3117
 WHERE id = (
   SELECT i.id FROM inspections i
   LEFT JOIN templates t ON t.template_id = i.template_id AND t.version = i.template_version
   WHERE t.template_id IS NULL AND i.status = 'approved'
   ORDER BY i.started_at
   LIMIT 1
 );

-- Comprobación (debe devolver 88, y la 3117 entre ellas):
--   SELECT count(*) FROM inspections i
--   LEFT JOIN templates t ON t.template_id = i.template_id AND t.version = i.template_version
--   WHERE t.template_id IS NULL;
