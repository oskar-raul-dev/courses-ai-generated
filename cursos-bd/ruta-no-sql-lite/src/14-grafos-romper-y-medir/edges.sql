-- Las aristas de la trazabilidad para WITH RECURSIVE (perfil base), las mismas que recorre el grafo:
-- una por estadía, en los dos sentidos (pieza → aeronave y aeronave → pieza). Sale de part_stint, la tabla
-- de estadías de la Fase 13; si no existe, se crea aquí con la misma definición.
--   docker compose -f lab/compose.yaml exec -T base psql -U postgres < 14-grafos-romper-y-medir/edges.sql
CREATE TABLE IF NOT EXISTS part_stint AS
WITH stints AS (
  SELECT serial_number, aircraft,
         CASE WHEN kind = 'installed' THEN opened_at END AS from_ts,
         CASE WHEN kind = 'removed' THEN opened_at WHEN next_kind = 'removed' THEN next_at END AS to_ts
  FROM (SELECT m.serial_number, m.kind, wo.aircraft, wo.opened_at,
               lead(m.kind) OVER w AS next_kind, lead(wo.opened_at) OVER w AS next_at, lag(m.kind) OVER w AS prev_kind
        FROM work_order_movement m JOIN work_order wo USING (work_order_id)
        WINDOW w AS (PARTITION BY m.serial_number ORDER BY wo.opened_at, m.kind DESC)) x
  WHERE kind = 'installed' OR prev_kind IS DISTINCT FROM 'installed'
  UNION ALL
  SELECT p.serial_number, p.aircraft, NULL, NULL FROM part p
  WHERE p.aircraft IS NOT NULL AND NOT EXISTS (SELECT 1 FROM work_order_movement m WHERE m.serial_number = p.serial_number))
SELECT * FROM stints;
DROP TABLE IF EXISTS stint_edge;
CREATE TABLE stint_edge AS
  SELECT DISTINCT 'part:' || serial_number AS src, 'aircraft:' || aircraft AS dst FROM part_stint
  UNION
  SELECT DISTINCT 'aircraft:' || aircraft, 'part:' || serial_number FROM part_stint;
CREATE INDEX stint_edge_src ON stint_edge (src);
ANALYZE stint_edge;
SELECT count(*) AS aristas, pg_size_pretty(pg_total_relation_size('stint_edge')) AS tamano FROM stint_edge;
