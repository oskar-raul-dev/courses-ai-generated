-- Índices de la línea base, separados del esquema a propósito: la Fase 01 mide la consulta de
-- referencia antes y después de crearlos. Son los que pide un senior para las consultas que
-- el curso conoce de antemano; cada fase B puede añadir los suyos y lo declara.

-- las órdenes de una aeronave en un rango de fechas: la consulta de referencia
CREATE INDEX IF NOT EXISTS work_order_aircraft_opened_at ON work_order (aircraft, opened_at);
-- la historia de una pieza: por dónde pasó un número de serie
CREATE INDEX IF NOT EXISTS work_order_movement_serial ON work_order_movement (serial_number);
-- qué hay instalado en una aeronave, y qué hay de un número de parte
CREATE INDEX IF NOT EXISTS part_aircraft ON part (aircraft) WHERE aircraft IS NOT NULL;
CREATE INDEX IF NOT EXISTS part_part_number ON part (part_number);
-- los conjuntos de una aeronave: la ficha completa los lee (añadido en la Fase 04, que midió la
-- ficha sin él recorriendo todos los conjuntos)
CREATE INDEX IF NOT EXISTS assembly_aircraft ON assembly (aircraft);
-- los reportes de una aeronave en el tiempo
CREATE INDEX IF NOT EXISTS pirep_aircraft_reported_at ON pirep (aircraft, reported_at);

ANALYZE;
