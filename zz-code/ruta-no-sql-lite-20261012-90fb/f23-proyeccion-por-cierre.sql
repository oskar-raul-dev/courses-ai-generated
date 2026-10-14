\timing on
WITH last AS (
  SELECT DISTINCT ON (m.serial_number) m.serial_number, m.kind, m.disposition, m.position, m.supplier_id,
         w.aircraft, w.hangar_id, w.closed_at
  FROM work_order_movement m JOIN work_order w USING (work_order_id)
  ORDER BY m.serial_number, w.closed_at DESC, (m.kind = 'installed') DESC
)
SELECT p.status,
       CASE WHEN l.serial_number IS NULL THEN 'sin movimientos'
            WHEN l.kind='installed' THEN 'instalada'
            ELSE 'retirada:'||l.disposition END AS derivado,
       count(*) AS piezas,
       count(*) FILTER (WHERE l.kind='installed' AND p.aircraft = l.aircraft AND p.position = l.position) AS coincide_aeronave,
       count(*) FILTER (WHERE l.disposition='store' AND p.hangar_id = l.hangar_id) AS coincide_hangar,
       count(*) FILTER (WHERE l.disposition='repairShop' AND p.supplier_id = l.supplier_id) AS coincide_taller
FROM part p LEFT JOIN last l USING (serial_number)
GROUP BY 1,2 ORDER BY 1,2;
