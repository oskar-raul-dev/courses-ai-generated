-- 💀 Boss III · lo que la solución agrega a la base, después de boss/01_july.sql.
-- Una muestra, un técnico, escrito en la base: la red por si otro código toma muestras sin SKIP LOCKED.
ALTER TABLE staging.july_specimen_take ADD CONSTRAINT july_specimen_take_once UNIQUE (specimen_id);
-- Recomendado en producción, y no aplicado aquí porque cortaría las exportaciones de la Fase 17 en el mismo laboratorio:
--   ALTER ROLE <rol de la aplicación> SET idle_in_transaction_session_timeout = '30s';
--   ALTER ROLE <rol de la aplicación> SET lock_timeout = '2s';
