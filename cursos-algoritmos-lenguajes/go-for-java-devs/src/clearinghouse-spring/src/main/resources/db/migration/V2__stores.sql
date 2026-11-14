-- +goose Up
-- Datos de referencia: las tiendas del banco de pruebas, con zonas distintas a
-- propósito (un "día 11" no cubre el mismo intervalo UTC en Bogotá y en Santiago).
INSERT INTO stores (id, name, currency, time_zone) VALUES
    ('ST-001', 'ST-001', 'COP', 'America/Bogota'),
    ('ST-002', 'ST-002', 'COP', 'America/Mexico_City'),
    ('ST-003', 'ST-003', 'COP', 'America/Lima'),
    ('ST-004', 'ST-004', 'COP', 'America/Santiago'),
    ('ST-005', 'ST-005', 'COP', 'America/Bogota');
