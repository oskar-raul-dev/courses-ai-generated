-- +goose Up
-- El esquema central de ClearingHouse, COMPARTIDO por las dos implementaciones del
-- duelo (Fase 16): el gemelo lo aplica con Flyway (V1__…) y la versión Go con
-- goose (la anotación de arriba es un comentario para Flyway). Un solo SQL: nada de
-- que una implementación tenga un índice que la otra no.

CREATE TABLE stores (
    id        TEXT PRIMARY KEY,
    name      TEXT NOT NULL,
    currency  TEXT NOT NULL CHECK (currency ~ '^[A-Z]{3}$'),
    -- La zona de la tienda decide qué es "el día 11" (Fase 09, §6.10).
    time_zone TEXT NOT NULL
);

CREATE TABLE movements (
    id           TEXT PRIMARY KEY,           -- store_id || '-' || external_ref
    store_id     TEXT NOT NULL REFERENCES stores(id),
    external_ref TEXT NOT NULL,              -- la clave de idempotencia del agente
    type         TEXT NOT NULL,
    amount_minor BIGINT NOT NULL,            -- unidades mínimas, nunca float
    currency     TEXT NOT NULL,
    occurred_at  TIMESTAMPTZ NOT NULL,
    received_at  TIMESTAMPTZ NOT NULL,
    status       TEXT NOT NULL DEFAULT 'received',
    CONSTRAINT movements_currency_valid CHECK (currency ~ '^[A-Z]{3}$'),
    CONSTRAINT movements_type_valid CHECK (type IN ('sale','refund','void','withdrawal','deposit')),
    CONSTRAINT movements_status_valid CHECK (status IN ('received','matched','unmatched','disputed','settled')),
    CONSTRAINT movements_ref_uniq UNIQUE (store_id, external_ref)
);

CREATE INDEX movements_store_occurred ON movements (store_id, occurred_at);

-- batches y ledger_entries: los de la Fase 13, sin cambios.
CREATE TABLE batches (
    id              TEXT PRIMARY KEY,
    period_day      DATE        NOT NULL,
    status          TEXT        NOT NULL,
    checkpoint      TEXT        NOT NULL DEFAULT '',
    total_expected  BIGINT      NOT NULL DEFAULT 0,
    processed       BIGINT      NOT NULL DEFAULT 0,
    failed          BIGINT      NOT NULL DEFAULT 0,
    chunks_done     INTEGER     NOT NULL DEFAULT 0,
    started_at      TIMESTAMPTZ NOT NULL,
    updated_at      TIMESTAMPTZ NOT NULL,
    finished_at     TIMESTAMPTZ,
    last_error      TEXT        NOT NULL DEFAULT '',
    holder          TEXT,
    lease_expires   TIMESTAMPTZ,
    CONSTRAINT batches_status_valid CHECK (
        status IN ('pending','running','completed','failed','cancelled')
    )
);

CREATE UNIQUE INDEX batches_day_uniq ON batches (period_day)
    WHERE status IN ('pending','running','completed');

CREATE TABLE ledger_entries (
    id           BIGSERIAL PRIMARY KEY,
    batch_id     TEXT        NOT NULL REFERENCES batches(id),
    movement_id  TEXT        NOT NULL,
    account      TEXT        NOT NULL,
    amount_minor BIGINT      NOT NULL,
    currency     TEXT        NOT NULL,
    created_at   TIMESTAMPTZ NOT NULL
);

CREATE UNIQUE INDEX ledger_entries_movement_uniq ON ledger_entries (movement_id, account);
