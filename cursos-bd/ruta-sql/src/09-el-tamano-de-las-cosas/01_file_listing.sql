-- postgres
-- Las órdenes escaneadas y los PDF que la caja no trae: su listado, con el tamaño de cada archivo.
-- El terabyte no se genera; se razona desde aquí.
DROP TABLE IF EXISTS staging.file_listing;
CREATE TABLE staging.file_listing (
    file_path    text PRIMARY KEY,
    file_type    varchar(20) NOT NULL,
    lab_order_id integer NOT NULL,
    bytes        bigint NOT NULL,
    created_on   timestamp NOT NULL
);
-- El CSV está en la caja montada en el servidor, como el resto de legacy (a05).
COPY staging.file_listing FROM '/caja/m/archivos/listado.csv' WITH (FORMAT csv, HEADER true);
ANALYZE staging.file_listing;
