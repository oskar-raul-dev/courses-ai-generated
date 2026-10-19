-- Fase 16 · el contador y los comprobantes en MySQL (staging).
CREATE DATABASE IF NOT EXISTS staging;
DROP TABLE IF EXISTS staging.invoice, staging.invoice_counter;
CREATE TABLE staging.invoice_counter (
    point_of_sale int     NOT NULL,
    kind          char(1) NOT NULL,
    last_number   int     NOT NULL,
    PRIMARY KEY (point_of_sale, kind)
);
CREATE TABLE staging.invoice (
    invoice_id    int     NOT NULL AUTO_INCREMENT PRIMARY KEY,
    point_of_sale int     NOT NULL,
    kind          char(1) NOT NULL,
    number        int,
    till          varchar(20) NOT NULL
);
INSERT INTO staging.invoice_counter VALUES (1, 'B', 247581);
