-- postgres
-- La variante no cíclica de la regla (D39): los mismos convenios, menos los que una obra social
-- excluye en una sede aunque cubra la práctica y la sede la haga. Se elige con la semilla 1996 y un
-- hash, sin random(): la misma tabla en cada corrida y en cada máquina.
DROP TABLE IF EXISTS staging.agreement_noncyclic;
CREATE TABLE staging.agreement_noncyclic AS
SELECT payer, practice, site
FROM staging.agreement_raw
WHERE ('x' || substr(md5('1996/' || payer || '/' || practice || '/' || site), 1, 7))::bit(28)::int % 10 <> 0;
