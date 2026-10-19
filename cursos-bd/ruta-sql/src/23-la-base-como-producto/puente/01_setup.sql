-- 💀☕ Boss del puente · PUNTO DE PARTIDA: las tablas del lado del laboratorio y del lado del SIH. Tiene fallas.
-- El SIH real está en Oracle (historia §3); aquí su tabla vive en Postgres, en staging, y se declara.
DROP TABLE IF EXISTS staging.lab_oru, staging.lab_outbox, staging.sih_resultado, staging.sih_descartes CASCADE;
CREATE TABLE staging.lab_oru (result_id bigint NOT NULL, version integer NOT NULL, analyte text, value text,
                              created_at timestamptz NOT NULL DEFAULT now(), PRIMARY KEY (result_id, version));
CREATE TABLE staging.lab_outbox (outbox_id bigserial PRIMARY KEY, message_id text NOT NULL UNIQUE, payload text NOT NULL,
                                 created_at timestamptz NOT NULL DEFAULT now(), sent_at timestamptz);
CREATE TABLE staging.sih_resultado (result_id bigint NOT NULL, version integer NOT NULL, analyte text, value text,
                                    applied_at timestamptz NOT NULL DEFAULT now());
CREATE TABLE staging.sih_descartes (descarte_id bigserial PRIMARY KEY, payload text, reason text, attempts integer,
                                    moved_at timestamptz NOT NULL DEFAULT now());
