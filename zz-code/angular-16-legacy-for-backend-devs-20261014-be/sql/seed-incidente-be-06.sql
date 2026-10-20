-- be-06: "El informe falla y no hemos desplegado nada".
-- El guion NO rompe nada: instala el informe tal como estaba y deja el sistema
-- exactamente como el día que funcionaba. Lo que rompe es el .env (§5).
--
-- El informe vive en código (server/app/Reports/ExpiredCertificatesReport.php),
-- así que aquí sólo se siembran los datos que hacen que se ejecute con sentido:
-- certificados vencidos suficientes para que el informe tenga filas.

UPDATE certificates
   SET valid_until = now() - interval '40 days'
 WHERE id IN (SELECT id FROM certificates ORDER BY issued_at LIMIT 3);

-- Comprobación (con la semilla del db.json devuelve 2: sólo hay dos certificados):
--   SELECT count(*) FROM certificates WHERE valid_until < now();
