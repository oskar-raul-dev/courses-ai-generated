-- postgres
-- 🏆 "Un martes" · la base que pone el curso. La corre el arnés antes de cada evaluación, y no se edita: lo
-- tuyo va en 01_setup.sql y en flujo.py. Supuestos declarados (no están en la caja, D51):
--
--   · el aumento del 1 de octubre de 2026: un 4 % sobre el último precio de cada obra social y práctica.
--     La caja termina el 10/10 sin él; el martes llega, y parte la semana en dos precios;
--   · el tope mensual por afiliado de PAMI y APROSS: 12 unidades por mes calendario;
--   · las prácticas que se facturan juntas son las de la composición de la Fase 21: un componente no se
--     presenta si su panel está en el mismo protocolo.
--
-- Necesita la cantidad de lo facturado (Fase 25, 03_cantidad.sql) y el aplicador del CDC (Fase 25,
-- 04_cdc_setup.sql y cdc.py), que el arnés vuelve a preparar.

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'alameda'
                   AND table_name = 'billed_practice' AND column_name = 'quantity') THEN
        RAISE EXCEPTION 'falta alameda.billed_practice.quantity: corre 25-la-migracion-sin-parar/03_cantidad.sql';
    END IF;
    IF to_regclass('staging.practice_composition') IS NULL THEN
        RAISE EXCEPTION 'falta staging.practice_composition: corre 21-hasta-donde-llega-el-motor/03_recursion.sql';
    END IF;
END $$;

-- El aumento de octubre, en legacy (donde lo carga Matías) y en el modelo. En el modelo, cada rango abierto
-- se parte en una sola sentencia: la clave foránea con período de lo facturado (Fase 07) se comprueba al
-- final de la sentencia, y con dos sentencias vería el hueco entre la primera y la segunda.
INSERT INTO legacy."Precios" ("Id", "CodPractica", "IdObraSocial", "Valor", "VigenciaDesde")
SELECT (SELECT max("Id") FROM legacy."Precios") + row_number() OVER (ORDER BY p."IdObraSocial", p."CodPractica"),
       p."CodPractica", p."IdObraSocial", round(p."Valor" * 1.04, 2), timestamp '2026-10-01'
FROM (SELECT DISTINCT ON ("IdObraSocial", "CodPractica") * FROM legacy."Precios"
      WHERE "VigenciaDesde" < '2026-10-01' ORDER BY "IdObraSocial", "CodPractica", "VigenciaDesde" DESC, "Id" DESC) AS p
WHERE NOT EXISTS (SELECT 1 FROM legacy."Precios" WHERE "VigenciaDesde" = '2026-10-01');

WITH partido AS (
    UPDATE alameda.agreement_price SET valid_during = daterange(lower(valid_during), '2026-10-01')
    WHERE valid_during @> date '2026-10-01' AND lower(valid_during) < '2026-10-01'
    RETURNING payer_code, practice_id, amount)
INSERT INTO alameda.agreement_price (payer_code, practice_id, valid_during, amount)
SELECT payer_code, practice_id, daterange('2026-10-01', NULL), round(amount * 1.04, 2) FROM partido;

-- El tope mensual por afiliado.
DROP TABLE IF EXISTS staging.martes_cap;
CREATE TABLE staging.martes_cap (
    payer_code      varchar(20) PRIMARY KEY REFERENCES alameda.payer (payer_code),
    units_per_month integer NOT NULL CHECK (units_per_month > 0)
);
INSERT INTO staging.martes_cap VALUES ('PAMI', 12), ('APROSS', 12);

-- Lo que se presenta. Una presentación por obra social y semana; una vez emitida, no cambia.
DROP TABLE IF EXISTS alameda.presentation_excluded, alameda.presentation_line, alameda.presentation;
CREATE TABLE alameda.presentation (
    payer_code varchar(20) NOT NULL REFERENCES alameda.payer (payer_code),
    week_start date NOT NULL,
    issued_at  timestamptz NOT NULL DEFAULT clock_timestamp(),
    gross      numeric(19, 2) NOT NULL,          -- lo presentado, antes del coseguro
    copay      numeric(19, 2) NOT NULL,          -- el coseguro que ya pagó el paciente
    net        numeric(19, 2) NOT NULL,          -- lo que se le cobra a la obra social
    CONSTRAINT presentation_pkey PRIMARY KEY (payer_code, week_start),
    CONSTRAINT presentation_net_check CHECK (net = gross - copay AND net >= 0)
);
CREATE TABLE alameda.presentation_line (
    payer_code               varchar(20) NOT NULL,
    week_start               date NOT NULL,
    legacy_order_practice_id integer NOT NULL,
    lab_order_id             integer NOT NULL,
    practice_id              integer NOT NULL,
    practice_date            date NOT NULL,
    quantity                 integer NOT NULL,
    unit_amount              numeric(19, 4) NOT NULL,
    amount                   numeric(19, 2) NOT NULL,
    CONSTRAINT presentation_line_pkey PRIMARY KEY (legacy_order_practice_id),
    CONSTRAINT presentation_line_presentation_fkey FOREIGN KEY (payer_code, week_start)
        REFERENCES alameda.presentation (payer_code, week_start)
);
CREATE TABLE alameda.presentation_excluded (
    payer_code               varchar(20) NOT NULL,
    week_start               date NOT NULL,
    legacy_order_practice_id integer NOT NULL,
    reason                   text NOT NULL,
    CONSTRAINT presentation_excluded_pkey PRIMARY KEY (legacy_order_practice_id),
    CONSTRAINT presentation_excluded_reason_check
        CHECK (reason IN ('sin_precio', 'fuera_de_convenio', 'incluida_en_panel', 'excede_tope'))
);

-- Facturación corre con su propio rol, que no ve legacy: la presentación sale entera de la base nueva.
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'facturacion') THEN
        CREATE ROLE facturacion LOGIN PASSWORD 'facturacion-de-laboratorio';
    END IF;
END $$;
GRANT USAGE ON SCHEMA alameda, staging TO facturacion;
GRANT SELECT ON ALL TABLES IN SCHEMA alameda TO facturacion;
GRANT SELECT ON staging.martes_cap, staging.practice_composition TO facturacion;
GRANT INSERT, UPDATE, DELETE ON alameda.presentation, alameda.presentation_line, alameda.presentation_excluded
    TO facturacion;
REVOKE ALL ON SCHEMA legacy FROM facturacion;
-- La seguridad por fila de la Fase 23 también lo alcanza: sin una política propia, facturación no ve ningún
-- protocolo. Ve todos, y solo para leer.
DROP POLICY IF EXISTS facturacion_lee_todo ON alameda.lab_order;
CREATE POLICY facturacion_lee_todo ON alameda.lab_order FOR SELECT TO facturacion USING (true);
