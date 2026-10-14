-- El esquema de la Fase 01 pensado para tres autoridades (sección 6.4). La base se crea con
--   CREATE DATABASE condor PRIMARY REGION "us-east1" REGIONS "us-west1", "europe-west1"
-- y en el laboratorio cada región hace de un país: us-east1 = Colombia, us-west1 = Ecuador,
-- europe-west1 = Perú. Las columnas y las claves son las de la Fase 01; lo que cambia es dónde vive
-- cada fila, y eso se declara en tres decisiones:
--   1 · lo que se lee en todas partes y casi no cambia (hangares, técnicos, proveedores, catálogo) es GLOBAL;
--   2 · lo que pertenece al expediente de una aeronave vive en el país de su autoridad (REGIONAL BY ROW),
--       y por eso cada tabla del expediente lleva la columna authority: la región no se puede calcular
--       con un join;
--   3 · la pieza física es de Cóndor, no de la autoridad, y vive en la región primaria (REGIONAL BY TABLE).

DROP TABLE IF EXISTS reading, pirep, work_order_movement, work_order_technician, work_order,
  assembly, part, part_catalog, aircraft, supplier, technician, hangar CASCADE;

CREATE TABLE hangar (
  hangar_id text PRIMARY KEY,
  name      text NOT NULL,
  city      text NOT NULL,
  country   text NOT NULL,
  pits      int  NOT NULL
) LOCALITY GLOBAL;

CREATE TABLE technician (
  technician_id text PRIMARY KEY,
  name          text NOT NULL,
  hangar_id     text NOT NULL REFERENCES hangar,
  license_type  text NOT NULL,
  can_sign      boolean NOT NULL,
  itinerant     boolean NOT NULL
) LOCALITY GLOBAL;

CREATE TABLE supplier (
  supplier_id           text PRIMARY KEY,
  name                  text NOT NULL,
  kind                  text NOT NULL CHECK (kind IN ('repairShop', 'partsSupplier')),
  capability            text,
  country               text NOT NULL,
  agreement_valid_until date
) LOCALITY GLOBAL;

CREATE TABLE part_catalog (
  part_number           text PRIMARY KEY,
  description           text NOT NULL,
  category              text NOT NULL,
  ata_chapter           int  NOT NULL,
  serialized            boolean NOT NULL,
  compatible_models     text[] NOT NULL,
  alternates            text[] NOT NULL,
  supplier_ids          text[] NOT NULL,
  supplier_part_numbers text[] NOT NULL,
  unit_cost_usd         numeric(12, 2) NOT NULL
) LOCALITY GLOBAL;

-- el país de la autoridad decide la región: la misma expresión en cada tabla del expediente
CREATE TABLE aircraft (
  registration             text PRIMARY KEY,
  model                    text NOT NULL,
  kind                     text NOT NULL,
  engines                  int  NOT NULL,
  operator_id              text NOT NULL,
  country                  text NOT NULL,
  year_of_manufacture      int  NOT NULL,
  base_hangar_id           text NOT NULL REFERENCES hangar,
  has_flight_recorder      boolean NOT NULL,
  continuous_wing_contract boolean NOT NULL,
  in_fleet_from            date NOT NULL,
  left_fleet_on            date,
  options                  jsonb NOT NULL,
  crdb_region crdb_internal_region NOT VISIBLE NOT NULL AS (
    CASE country WHEN 'EC' THEN 'us-west1' WHEN 'PE' THEN 'europe-west1' ELSE 'us-east1' END) STORED
) LOCALITY REGIONAL BY ROW;

CREATE TABLE part (
  serial_number       text PRIMARY KEY,
  part_number         text NOT NULL REFERENCES part_catalog,
  category            text NOT NULL,
  lot_number          text NOT NULL,
  manufactured_on     date NOT NULL,
  hours_since_new     int  NOT NULL,
  cycles_since_new    int  NOT NULL,
  details             jsonb NOT NULL,
  status              text NOT NULL,
  aircraft            text REFERENCES aircraft,
  position            text,
  hangar_id           text REFERENCES hangar,
  supplier_id         text REFERENCES supplier,
  sent_to_supplier_on date
) LOCALITY REGIONAL BY TABLE IN PRIMARY REGION;

CREATE TABLE assembly (
  assembly_id  text PRIMARY KEY,
  kind         text NOT NULL,
  aircraft     text NOT NULL REFERENCES aircraft,
  position     text NOT NULL,
  part_serials text[] NOT NULL,
  authority    text NOT NULL,
  crdb_region crdb_internal_region NOT VISIBLE NOT NULL AS (
    CASE authority WHEN 'EC' THEN 'us-west1' WHEN 'PE' THEN 'europe-west1' ELSE 'us-east1' END) STORED
) LOCALITY REGIONAL BY ROW;

CREATE TABLE pirep (
  pirep_id    text PRIMARY KEY,
  aircraft    text NOT NULL REFERENCES aircraft,
  reported_at timestamptz NOT NULL,
  ata_chapter int NOT NULL,
  text        text NOT NULL,
  authority   text NOT NULL,
  crdb_region crdb_internal_region NOT VISIBLE NOT NULL AS (
    CASE authority WHEN 'EC' THEN 'us-west1' WHEN 'PE' THEN 'europe-west1' ELSE 'us-east1' END) STORED
) LOCALITY REGIONAL BY ROW;

CREATE TABLE work_order (
  work_order_id  text PRIMARY KEY,
  aircraft       text NOT NULL REFERENCES aircraft,
  hangar_id      text NOT NULL REFERENCES hangar,
  type           text NOT NULL,
  opened_at      timestamptz NOT NULL,
  closed_at      timestamptz NOT NULL,
  pirep_id       text REFERENCES pirep,
  released_by    text NOT NULL REFERENCES technician,
  labor_hours    int NOT NULL,
  labor_cost_usd numeric(12, 2) NOT NULL,
  parts_cost_usd numeric(12, 2) NOT NULL,
  tasks          text[] NOT NULL,
  authority      text NOT NULL,
  crdb_region crdb_internal_region NOT VISIBLE NOT NULL AS (
    CASE authority WHEN 'EC' THEN 'us-west1' WHEN 'PE' THEN 'europe-west1' ELSE 'us-east1' END) STORED
) LOCALITY REGIONAL BY ROW;

CREATE TABLE work_order_technician (
  work_order_id text NOT NULL REFERENCES work_order,
  technician_id text NOT NULL REFERENCES technician,
  authority     text NOT NULL,
  crdb_region crdb_internal_region NOT VISIBLE NOT NULL AS (
    CASE authority WHEN 'EC' THEN 'us-west1' WHEN 'PE' THEN 'europe-west1' ELSE 'us-east1' END) STORED,
  PRIMARY KEY (work_order_id, technician_id)
) LOCALITY REGIONAL BY ROW;

CREATE TABLE work_order_movement (
  work_order_id text NOT NULL REFERENCES work_order,
  kind          text NOT NULL CHECK (kind IN ('removed', 'installed')),
  serial_number text NOT NULL REFERENCES part,
  part_number   text NOT NULL REFERENCES part_catalog,
  position      text NOT NULL,
  disposition   text,
  supplier_id   text REFERENCES supplier,
  reason        text,
  authority     text NOT NULL,
  crdb_region crdb_internal_region NOT VISIBLE NOT NULL AS (
    CASE authority WHEN 'EC' THEN 'us-west1' WHEN 'PE' THEN 'europe-west1' ELSE 'us-east1' END) STORED,
  PRIMARY KEY (work_order_id, kind, serial_number)
) LOCALITY REGIONAL BY ROW;

-- los índices de la Fase 01, los mismos: en una tabla REGIONAL BY ROW cada índice se parte por región
CREATE INDEX work_order_aircraft_opened_at ON work_order (aircraft, opened_at);
CREATE INDEX work_order_movement_serial ON work_order_movement (serial_number);
CREATE INDEX part_aircraft ON part (aircraft) WHERE aircraft IS NOT NULL;
CREATE INDEX part_part_number ON part (part_number);
CREATE INDEX assembly_aircraft ON assembly (aircraft);
CREATE INDEX pirep_aircraft_reported_at ON pirep (aircraft, reported_at);
