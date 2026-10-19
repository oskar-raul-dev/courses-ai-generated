-- postgres
-- Dos tiempos para un precio: cuándo vale (valid_during) y cuándo lo supo la base (recorded_during).
-- Una corrección retroactiva no borra lo que se sabía: cierra su período de registro y agrega la
-- versión nueva. Así se puede contestar "¿qué precio se le facturó a OSDE en abril, con lo que se
-- sabía en abril?" y "¿cuál era el precio correcto?".
DROP TABLE IF EXISTS staging.agreement_price_bitemporal;
CREATE TABLE staging.agreement_price_bitemporal (
    payer_code      varchar(20) NOT NULL,
    practice_id     integer NOT NULL,
    valid_during    daterange NOT NULL,
    recorded_during tstzrange NOT NULL,
    amount          numeric(19, 4) NOT NULL,
    CONSTRAINT agreement_price_bitemporal_excl
        EXCLUDE USING gist (payer_code WITH =, practice_id WITH =, valid_during WITH &&, recorded_during WITH &&)
);
