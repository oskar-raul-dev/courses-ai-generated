-- postgres
-- Tres formas de guardar el PDF de un informe, con 2.000 informes de octubre de 2026 y bytes al azar del
-- tamaño que dice el listado (un PDF ya está comprimido: el azar se le parece). La caja no trae los PDF.
-- un objeto grande no se borra con la fila que guarda su OID: antes de rehacer la tabla, se borran los suyos
DO $$
BEGIN
    IF to_regclass('staging.report_pdf_lo') IS NOT NULL THEN
        PERFORM lo_unlink(pdf_oid) FROM staging.report_pdf_lo;
    END IF;
END
$$;
DROP TABLE IF EXISTS staging.report_pdf_bytea, staging.report_pdf_lo, staging.report_file;

-- 1. En la fila, como el varbinary(max) de 2013: Postgres lo manda a TOAST, fuera de la página.
CREATE TABLE staging.report_pdf_bytea (
    lab_order_id integer PRIMARY KEY,
    created_on   date NOT NULL,
    pdf          bytea NOT NULL
);
INSERT INTO staging.report_pdf_bytea
SELECT f.lab_order_id, f.created_on::date,
       (SELECT decode(string_agg(md5(f.lab_order_id::text || '/' || g), ''), 'hex')
        FROM generate_series(1, (f.bytes / 16)::int) AS g)
FROM (SELECT * FROM staging.file_listing WHERE file_type = 'INFORME_PDF' AND created_on >= '2026-10-01'
      ORDER BY lab_order_id LIMIT 2000) AS f;

-- 2. Como objeto grande: la fila guarda un OID, y los bytes van a pg_largeobject.
CREATE TABLE staging.report_pdf_lo (
    lab_order_id integer PRIMARY KEY,
    created_on   date NOT NULL,
    pdf_oid      oid NOT NULL
);
INSERT INTO staging.report_pdf_lo SELECT lab_order_id, created_on, lo_from_bytea(0, pdf) FROM staging.report_pdf_bytea;

-- 3. Fuera de la base: la ruta, el tamaño y el hash, que es lo que prueba que el archivo es el que era.
CREATE TABLE staging.report_file (
    lab_order_id integer PRIMARY KEY,
    created_on   date NOT NULL,
    file_path    text NOT NULL,
    bytes        integer NOT NULL,
    sha256       bytea NOT NULL,
    CONSTRAINT report_file_sha256_check CHECK (length(sha256) = 32)
);
INSERT INTO staging.report_file
SELECT lab_order_id, created_on, 'informes/' || extract(year FROM created_on) || '/' || lab_order_id || '.pdf',
       length(pdf), sha256(pdf)
FROM staging.report_pdf_bytea;
ANALYZE staging.report_pdf_bytea, staging.report_pdf_lo, staging.report_file;
