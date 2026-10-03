-- WITH RECURSIVE con corte de ciclos (a07): la trazabilidad como grafo. Desde una pieza, las
-- aeronaves donde se instaló; desde cada aeronave, las piezas que recibió; y así, hasta :depth
-- saltos. Pieza → aeronave → pieza vuelve sobre sí mismo todo el tiempo: CYCLE corta el camino
-- que regresa a un nodo ya visitado.
--
-- Bien escrito quiere decir dos cosas: las aristas en una tabla con índice por su origen (un OR
-- dentro del JOIN impide usar índices y cada salto recorre la tabla entera), y CYCLE.
DROP TABLE IF EXISTS trace_edge;
CREATE TABLE trace_edge AS
  SELECT DISTINCT 'part:' || m.serial_number AS src, 'aircraft:' || wo.aircraft AS dst
  FROM work_order_movement m JOIN work_order wo USING (work_order_id) WHERE m.kind = 'installed'
  UNION
  SELECT DISTINCT 'aircraft:' || wo.aircraft, 'part:' || m.serial_number
  FROM work_order_movement m JOIN work_order wo USING (work_order_id) WHERE m.kind = 'installed';
CREATE INDEX trace_edge_src ON trace_edge (src);
ANALYZE trace_edge;
