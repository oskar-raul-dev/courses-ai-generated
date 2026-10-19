-- postgres
-- La misma tabla de protocolos con tres claves primarias: bigint con identity, UUIDv4 (gen_random_uuid) y
-- UUIDv7 (uuidv7, nuevo en Postgres 18), corrido a la fecha del protocolo con su argumento de desplazamiento.
-- Se insertan en el orden de llegada, y se mide el WAL de cada carga y el tamaño de cada índice.
DROP TABLE IF EXISTS staging.order_bigint, staging.order_uuid4, staging.order_uuid7;
CREATE TABLE staging.order_bigint (order_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id integer NOT NULL, ordered_on date NOT NULL, site_code char(1) NOT NULL);
CREATE TABLE staging.order_uuid4 (order_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id integer NOT NULL, ordered_on date NOT NULL, site_code char(1) NOT NULL);
CREATE TABLE staging.order_uuid7 (order_id uuid PRIMARY KEY,
    patient_id integer NOT NULL, ordered_on date NOT NULL, site_code char(1) NOT NULL);
CREATE INDEX order_bigint_patient_id_idx ON staging.order_bigint (patient_id);
CREATE INDEX order_uuid4_patient_id_idx ON staging.order_uuid4 (patient_id);
CREATE INDEX order_uuid7_patient_id_idx ON staging.order_uuid7 (patient_id);
