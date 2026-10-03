-- Esquema relacional de referencia de Cóndor MRO (Fase 01).
-- Es la línea base contra la que se mide todo el curso, y va bien jugada: lo que los diez
-- registros tienen en común va en columnas, lo que cambia según el tipo de aeronave o de pieza
-- va en JSONB, y los índices son los que un senior pondría para las consultas conocidas.
-- snake_case, como es idiomático en Postgres (a08).

-- la librería está precargada en el laboratorio (a02), pero la vista no existe hasta crear la
-- extensión: sin esto, consultar pg_stat_statements da "relation does not exist"
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

DROP TABLE IF EXISTS reading, pirep, work_order_movement, work_order_technician, work_order,
  assembly, part, part_catalog, aircraft, supplier, technician, hangar CASCADE;

CREATE TABLE hangar (
  hangar_id text PRIMARY KEY,
  name      text NOT NULL,
  city      text NOT NULL,
  country   text NOT NULL,
  pits      int  NOT NULL
);

CREATE TABLE technician (
  technician_id text PRIMARY KEY,
  name          text NOT NULL,
  hangar_id     text NOT NULL REFERENCES hangar,
  license_type  text NOT NULL,
  can_sign      boolean NOT NULL,
  itinerant     boolean NOT NULL
);

CREATE TABLE supplier (
  supplier_id           text PRIMARY KEY,
  name                  text NOT NULL,
  kind                  text NOT NULL CHECK (kind IN ('repairShop', 'partsSupplier')),
  capability            text,
  country               text NOT NULL,
  agreement_valid_until date
);

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
  -- lo polimórfico: un helicóptero y un turbohélice no comparten estos campos
  options                  jsonb NOT NULL
);

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
);

CREATE TABLE part (
  serial_number       text PRIMARY KEY,
  part_number         text NOT NULL REFERENCES part_catalog,
  category            text NOT NULL,
  lot_number          text NOT NULL,
  manufactured_on     date NOT NULL,
  hours_since_new     int  NOT NULL,
  cycles_since_new    int  NOT NULL,
  -- lo polimórfico: calibración en un instrumento, recauchados en una llanta, ciclos en un motor
  details             jsonb NOT NULL,
  status              text NOT NULL,
  aircraft            text REFERENCES aircraft,
  position            text,
  hangar_id           text REFERENCES hangar,
  supplier_id         text REFERENCES supplier,
  sent_to_supplier_on date
);

CREATE TABLE assembly (
  assembly_id  text PRIMARY KEY,
  kind         text NOT NULL,
  aircraft     text NOT NULL REFERENCES aircraft,
  position     text NOT NULL,
  part_serials text[] NOT NULL
);

CREATE TABLE pirep (
  pirep_id    text PRIMARY KEY,
  aircraft    text NOT NULL REFERENCES aircraft,
  reported_at timestamptz NOT NULL,
  ata_chapter int NOT NULL,
  text        text NOT NULL
);

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
  tasks          text[] NOT NULL
);

-- quién trabajó en cada orden: muchos a muchos
CREATE TABLE work_order_technician (
  work_order_id text NOT NULL REFERENCES work_order,
  technician_id text NOT NULL REFERENCES technician,
  PRIMARY KEY (work_order_id, technician_id)
);

-- lo que una orden retiró o instaló: de aquí sale la trazabilidad de cada pieza (F13)
CREATE TABLE work_order_movement (
  work_order_id text NOT NULL REFERENCES work_order,
  kind          text NOT NULL CHECK (kind IN ('removed', 'installed')),
  serial_number text NOT NULL REFERENCES part,
  part_number   text NOT NULL REFERENCES part_catalog,
  position      text NOT NULL,
  disposition   text,
  supplier_id   text REFERENCES supplier,
  reason        text,
  PRIMARY KEY (work_order_id, kind, serial_number)
);

CREATE TABLE reading (
  aircraft      text NOT NULL REFERENCES aircraft,
  ts            timestamptz NOT NULL,
  flight_id     text NOT NULL,
  altitude_ft   int NOT NULL,
  ias_kt        int NOT NULL,
  egt_c         int NOT NULL,
  n1_pct        int NOT NULL,
  oil_press_psi int NOT NULL,
  oil_temp_c    int NOT NULL,
  fuel_flow_pph int NOT NULL,
  PRIMARY KEY (aircraft, ts)
);
