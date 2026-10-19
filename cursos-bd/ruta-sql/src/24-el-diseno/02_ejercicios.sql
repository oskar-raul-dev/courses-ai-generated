-- postgres
-- Fase 24 · ejercicios 1 a 3: el catálogo del modelo. Solo lee. Las respuestas no dependen de si ya
-- corriste la Fase 25 o el 🏆 "Un martes" (que agregan tablas y filas, pero no cambian esto).

\echo '== Ejercicio 1: lo que protege a alameda.result'
SELECT k.contype AS tipo, k.conname, pg_get_constraintdef(k.oid) AS definicion
FROM pg_constraint AS k
WHERE k.conrelid = 'alameda.result'::regclass AND k.conname NOT LIKE '%_not_null'
ORDER BY 1, 2;
SELECT polname, polcmd, pg_get_expr(polqual, polrelid) AS usando
FROM pg_policy WHERE polrelid = 'alameda.result'::regclass ORDER BY 1;

\echo '== Ejercicio 2: las reglas de alameda.patient'
SELECT k.conname, pg_get_constraintdef(k.oid) AS definicion
FROM pg_constraint AS k
WHERE k.conrelid = 'alameda.patient'::regclass AND k.contype IN ('c', 'u') AND k.conname NOT LIKE '%_not_null'
ORDER BY 1;
SELECT tgname, pg_get_triggerdef(oid) AS definicion FROM pg_trigger
WHERE tgrelid = 'alameda.patient'::regclass AND NOT tgisinternal;

\echo '== Ejercicio 3: la cola de rechazos de las Fases 04 a 07'
SELECT phase AS fase, rule AS regla, count(*) AS filas
FROM staging.rejection WHERE phase IN ('04', '05', '07')
GROUP BY 1, 2 ORDER BY 3 DESC LIMIT 5;
