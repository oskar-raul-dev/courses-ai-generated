-- Esquema mínimo de la verificación P7 (no es el de la Fase 3).
CREATE TABLE stock (
  segment_id TEXT PRIMARY KEY,
  remaining  INTEGER NOT NULL
);
INSERT INTO stock VALUES ('esclusa-de-oro', 1000);

CREATE TABLE spin_log (
  id              BIGSERIAL PRIMARY KEY,
  player_id       TEXT NOT NULL,
  key             TEXT NOT NULL,
  landed_segment  TEXT NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- La clave de idempotencia (UNIQUE) NO va aquí: la pone correr-giro.sh solo en el modo
-- transaccional. El giro ingenuo de 2019 no tiene restricción de clave.
