-- be-08: "El certificado sale vigente y el informe lo cuenta como vencido".
-- La franja peligrosa son las cinco horas en las que un valor sin zona ya pasó si se
-- lee en UTC y todavía no si se lee en Bogotá. El vencimiento se pone dos horas por
-- delante de la hora de Bogotá, escrito sin zona: cae dentro de la franja a cualquier
-- hora del día, porque se mueve el dato en vez de esperar al reloj.
-- La semilla del db.json no trae el CERT-2024-0087 del ticket: se crea (o se ajusta,
-- si ya existe) sobre la inspección 502, que está aprobada.
INSERT INTO certificates (id, inspection_id, issued_at, valid_until, status, revoked_at)
VALUES ('CERT-2024-0087', 502, current_date - interval '1 year',
        (now() AT TIME ZONE 'America/Bogota') + interval '2 hours', 'valid', NULL)
ON CONFLICT (id) DO UPDATE SET valid_until = EXCLUDED.valid_until;

-- Comprobación: la respuesta a "¿está vencido?" tiene que DIFERIR según la zona
-- (UTC: t; Bogotá: f), y el informe de vencidos tiene que contar uno más que sin el guion.
--   SET TimeZone='UTC';             SELECT valid_until < now() FROM certificates WHERE id='CERT-2024-0087';
--   SET TimeZone='America/Bogota';  SELECT valid_until < now() FROM certificates WHERE id='CERT-2024-0087';
