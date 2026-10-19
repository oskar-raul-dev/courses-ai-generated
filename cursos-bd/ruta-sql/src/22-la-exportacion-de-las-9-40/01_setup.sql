-- Fase 22 · las tablas de la exportación, la cola y la bandeja, en staging (Postgres). Se corre una vez.
-- El día de referencia es el de mayor volumen de 2025 en la caja: 26/12/2025, con 6.651 resultados.
-- La verdad de ese día es truth.result_value (los mismos IDs que alameda.result, comprobado en la preparación).

-- 1. La fuente: los resultados del día, como los carga el sistema. Los escritores de la prueba la llenan de a lotes.
DROP TABLE IF EXISTS staging.f22_result;
CREATE TABLE staging.f22_result (
  result_id    integer PRIMARY KEY,
  lab_order_id integer NOT NULL,
  analyte_code varchar(20),
  value_numeric numeric,
  recorded_at  timestamp NOT NULL
);
CREATE INDEX f22_result_recorded ON staging.f22_result (recorded_at);

-- 2. La verdad del día, para contar contra ella (no se modifica).
DROP TABLE IF EXISTS staging.f22_expected;
CREATE TABLE staging.f22_expected AS
SELECT legacy_result_item_id AS result_id FROM truth.result_value tv
JOIN alameda.result r ON r.result_id = tv.legacy_result_item_id
WHERE r.recorded_at >= '2025-12-26' AND r.recorded_at < '2025-12-27';
ALTER TABLE staging.f22_expected ADD PRIMARY KEY (result_id);

-- 3. La marca de agua del exportador y lo que ya se envió (auditoría de exportación).
DROP TABLE IF EXISTS staging.f22_watermark;
CREATE TABLE staging.f22_watermark (name text PRIMARY KEY, mark timestamp NOT NULL);
DROP TABLE IF EXISTS staging.f22_exported;
CREATE TABLE staging.f22_exported (result_id integer PRIMARY KEY, exported_at timestamptz NOT NULL DEFAULT now());

-- 4. El outbox: el mensaje se escribe en la misma transacción que el cambio de negocio.
DROP TABLE IF EXISTS staging.f22_outbox;
CREATE TABLE staging.f22_outbox (
  outbox_id bigserial PRIMARY KEY,
  message_id text NOT NULL UNIQUE,
  payload jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  sent_at timestamptz
);

-- 5. La cola: los mensajes pendientes de procesar, con sus intentos.
DROP TABLE IF EXISTS staging.f22_queue;
CREATE TABLE staging.f22_queue (
  queue_id bigserial PRIMARY KEY,
  message_id text NOT NULL UNIQUE,
  payload jsonb NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  attempts integer NOT NULL DEFAULT 0,
  done_by text
);
CREATE INDEX f22_queue_pending ON staging.f22_queue (queue_id) WHERE status = 'pending';

-- 6. El destino: lo que recibe el sistema de afuera. La bandeja de entrada tiene la clave única del identificador
--    del mensaje: la idempotencia la hace cumplir el motor, no el código del consumidor.
DROP TABLE IF EXISTS staging.f22_inbox;
CREATE TABLE staging.f22_inbox (
  message_id text PRIMARY KEY,
  version integer NOT NULL DEFAULT 1,
  payload jsonb NOT NULL,
  received_at timestamptz NOT NULL DEFAULT now()
);
DROP TABLE IF EXISTS staging.f22_destination;
CREATE TABLE staging.f22_destination (message_id text NOT NULL, received_at timestamptz NOT NULL DEFAULT now());

-- 7. Los descartes: el mensaje veneno, después de tres intentos.
DROP TABLE IF EXISTS staging.f22_dead;
CREATE TABLE staging.f22_dead (queue_id bigint PRIMARY KEY, message_id text, payload jsonb, reason text, moved_at timestamptz DEFAULT now());

SELECT (SELECT count(*) FROM staging.f22_expected) AS verdad_del_dia;
