-- el recorrido, sobre trace_edge (ver recursive.sql)
WITH RECURSIVE trace(node, depth) AS (
  SELECT 'part:' || :'serial', 0
  UNION ALL
  SELECT e.dst, t.depth + 1 FROM trace t JOIN trace_edge e ON e.src = t.node WHERE t.depth < :depth
) CYCLE node SET is_cycle USING path
SELECT depth, count(DISTINCT node) AS nodos, count(*) AS filas, count(*) FILTER (WHERE is_cycle) AS ciclos_cortados
FROM trace GROUP BY depth ORDER BY depth;
