-- postgres
-- El área de carga y la tabla de rechazos del Bloque I. Cada fase agrega sus reglas; ninguna borra las
-- de otra. Se publica la vista: regla, filas rechazadas, porcentaje de legacy y lo que dice la verdad.
CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.rejection (
    rejection_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    phase        text NOT NULL,                  -- la fase que escribió la regla: '04', '05'…
    rule         text NOT NULL,                  -- tabla.regla, en snake_case
    source_table text NOT NULL,                  -- la tabla de legacy de donde vino la fila
    source_key   text NOT NULL,                  -- su clave en legacy, como texto
    value        text,                           -- el valor que violó la regla, tal cual
    detail       text,
    rejected_at  timestamptz NOT NULL DEFAULT now()
);

-- Cuántas filas de legacy tiene cada tabla de origen, y cuántas debería rechazar cada regla según el
-- generador (NULL si la verdad no sabe nada de esa regla).
CREATE TABLE IF NOT EXISTS staging.rule_baseline (
    rule         text PRIMARY KEY,
    source_rows  bigint NOT NULL,
    truth_rows   bigint
);

CREATE OR REPLACE VIEW staging.rejection_report AS
SELECT r.rule AS "Regla",
       count(*) AS "Filas rechazadas",
       round(100.0 * count(*) / b.source_rows, 2) AS "% de legacy",
       b.truth_rows AS "Contra la verdad"
FROM staging.rejection AS r
JOIN staging.rule_baseline AS b ON b.rule = r.rule
GROUP BY r.rule, b.source_rows, b.truth_rows
ORDER BY r.rule;

-- Volver a correr la fase empieza de cero: sus rechazos se recalculan, los de otras fases no se tocan.
DELETE FROM staging.rejection WHERE phase = '04';
