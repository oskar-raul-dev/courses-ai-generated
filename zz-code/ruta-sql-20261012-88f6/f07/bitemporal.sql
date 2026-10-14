TRUNCATE staging.agreement_price_bitemporal;
-- lo que la base supo el 1 de marzo: el precio de OSDE para la HbA1c desde marzo, sin fin
INSERT INTO staging.agreement_price_bitemporal VALUES
    ('OSDE', 7, '[2025-03-01,)', '[2025-03-01 09:00-03,)', 21000);
-- el 12 de mayo OSDE avisa que desde el 1 de abril vale 23.100: se cierra lo que se sabía y se agrega lo nuevo
UPDATE staging.agreement_price_bitemporal SET recorded_during = tstzrange(lower(recorded_during), '2025-05-12 10:00-03')
WHERE payer_code = 'OSDE' AND practice_id = 7 AND upper_inf(recorded_during);
INSERT INTO staging.agreement_price_bitemporal VALUES
    ('OSDE', 7, '[2025-03-01,2025-04-01)', '[2025-05-12 10:00-03,)', 21000),
    ('OSDE', 7, '[2025-04-01,)', '[2025-05-12 10:00-03,)', 23100);
-- una corrección que se superpone con lo vigente: la exclusión la rechaza
INSERT INTO staging.agreement_price_bitemporal VALUES ('OSDE', 7, '[2025-04-15,)', '[2025-06-01 10:00-03,)', 24000);
\echo == el precio del 20 de abril, con lo que se sabía el 30 de abril y con lo que se sabe hoy
SELECT 'lo que se sabía el 30/04' AS segun, amount FROM staging.agreement_price_bitemporal
WHERE payer_code = 'OSDE' AND practice_id = 7 AND valid_during @> date '2025-04-20' AND recorded_during @> timestamptz '2025-04-30 12:00-03'
UNION ALL
SELECT 'lo que se sabe hoy', amount FROM staging.agreement_price_bitemporal
WHERE payer_code = 'OSDE' AND practice_id = 7 AND valid_during @> date '2025-04-20' AND recorded_during @> now();
SELECT * FROM staging.agreement_price_bitemporal ORDER BY lower(recorded_during), lower(valid_during);
