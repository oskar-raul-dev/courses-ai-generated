-- La preparación de bea-05: el stock de la Esclusa de Oro con UNA unidad, y la bitácora.
DROP TABLE IF EXISTS demo_requests, demo_spins, demo_stock, demo_players;
CREATE TABLE demo_stock (
    id         BIGSERIAL PRIMARY KEY,
    wheel_id   BIGINT  NOT NULL,
    segment_id TEXT    NOT NULL,
    remaining  INTEGER NOT NULL,
    UNIQUE (wheel_id, segment_id)
);
INSERT INTO demo_stock (wheel_id, segment_id, remaining)
VALUES (1, 'esclusa-de-oro', 1), (1, 'avatar-raro', 5);
CREATE TABLE demo_spins (
    id              BIGSERIAL PRIMARY KEY,
    idempotency_key TEXT   NOT NULL UNIQUE,
    player_id       BIGINT NOT NULL,
    delivered_prize TEXT   NOT NULL
);
CREATE TABLE demo_players (id BIGINT PRIMARY KEY, free_spins INTEGER NOT NULL);
INSERT INTO demo_players VALUES (42, 1);
CREATE TABLE demo_requests (
    idempotency_key TEXT PRIMARY KEY,
    player_id       BIGINT NOT NULL REFERENCES demo_players(id)
);
