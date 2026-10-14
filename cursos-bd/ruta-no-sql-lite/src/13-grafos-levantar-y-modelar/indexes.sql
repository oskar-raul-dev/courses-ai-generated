-- La línea base bien jugada para la trazabilidad (perfil base): además de los índices de la Fase 01,
-- el lote de la pieza y la orden de cada movimiento, que la directiva cruza.
--   docker compose -f lab/compose.yaml exec -T base psql -U postgres < 13-grafos-levantar-y-modelar/indexes.sql
CREATE INDEX IF NOT EXISTS part_lot_number ON part (lot_number);
CREATE INDEX IF NOT EXISTS work_order_movement_work_order ON work_order_movement (work_order_id, kind);
ANALYZE part, work_order_movement;
