-- 💀 Boss V · Las 9:40 · SOLUCIÓN (D42: no se publica). Las tablas del flujo y la vista del portal.
-- El arnés corre este archivo antes de cada evaluación, así que tiene que ser repetible.

DROP TABLE IF EXISTS staging.b5_source, staging.b5_exported, staging.b5_watermark, staging.b5_destination,
                     staging.b5_notification, staging.b5_outbox CASCADE;

-- Los resultados del día, tal como los carga el laboratorio.
CREATE TABLE staging.b5_source (result_id integer PRIMARY KEY, lab_order_id integer NOT NULL, analyte_code text,
                                value_text text, recorded_at timestamp NOT NULL);
CREATE TABLE staging.b5_watermark (name text PRIMARY KEY, mark timestamp NOT NULL);
CREATE TABLE staging.b5_exported (result_id integer PRIMARY KEY);

-- El portal recibe los resultados por mensaje: identificador, versión y contenido.
-- La clave del identificador hace cumplir la idempotencia en el motor.
CREATE TABLE staging.b5_destination (message_id text PRIMARY KEY, version integer NOT NULL, payload text);

-- La notificación obligatoria: un registro por resultado detectable.
CREATE TABLE staging.b5_notification (result_id integer, notified_at timestamp NOT NULL);
CREATE TABLE staging.b5_outbox (outbox_id bigserial PRIMARY KEY, result_id integer, created_at timestamp NOT NULL, sent_at timestamp);

-- La vista del portal, sobre el modelo, para PostgREST.
DROP VIEW IF EXISTS api.resultados_boss;
-- security_invoker: la vista se lee con el rol del token, y las políticas de RLS se aplican.
CREATE VIEW api.resultados_boss WITH (security_invoker = true) AS
SELECT o.lab_order_id, o.patient_id, r.result_id, r.analyte_code, r.value_numeric
FROM alameda.result r JOIN alameda.lab_order o ON o.lab_order_id = r.lab_order_id;
GRANT SELECT ON api.resultados_boss TO paciente;
NOTIFY pgrst, 'reload schema';
