\echo == e1
\dt legacy.Pac*
\echo == e2
SELECT "DNI"::numeric FROM legacy."Pacientes" WHERE "IdPaciente" = 2;
\echo == e4
BEGIN;
CREATE TABLE lab.a08_id (id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, nombre text);
INSERT INTO lab.a08_id (id, nombre) VALUES (1, 'RAMIREZ NELIDA');
ROLLBACK;
\echo == e5
BEGIN;
CREATE UNIQUE INDEX a08_dni_unico ON legacy."Pacientes" ("DNI");
ROLLBACK;
