-- postgres
-- Tres reglas sobre legacy."Pacientes": cada fila que las viola va a la tabla de rechazos, con su valor.

-- 1. El nombre es un nombre: ni un documento ni un número de siete u ocho cifras adentro. La P del
--    pasaporte va seguida del país en tres letras: sin eso, la P de P.A.M.I. también es un pasaporte.
INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
SELECT '04', 'pacientes.documento_en_nombre', 'Pacientes', p."IdPaciente"::text, p."Nombre",
       nullif(staging.extract_dni_2016(p."Nombre"), '')
FROM legacy."Pacientes" AS p
WHERE p."Nombre" ~ '[0-9]{7,8}|\m(DNI|LC|LE|OTRO)\M|\m(P|PASAP) [A-Z]{3}\M|D\.N\.I\.';

-- 2. Nadie nace después de que lo atienden.
INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
SELECT '04', 'pacientes.nacimiento_posterior_al_alta', 'Pacientes', p."IdPaciente"::text,
       p."FechaNac"::date::text, 'alta ' || p."FechaAlta"::date
FROM legacy."Pacientes" AS p
WHERE p."FechaNac" > p."FechaAlta";

-- 3. Un DNI son siete u ocho dígitos, con puntos o sin ellos.
INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
SELECT '04', 'pacientes.dni_con_formato_invalido', 'Pacientes', p."IdPaciente"::text, p."DNI", NULL
FROM legacy."Pacientes" AS p
WHERE p."DNI" IS NOT NULL AND replace(p."DNI", '.', '') !~ '^[0-9]{7,8}$';
