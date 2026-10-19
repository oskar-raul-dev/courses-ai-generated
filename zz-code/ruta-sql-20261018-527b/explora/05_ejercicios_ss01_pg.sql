-- postgres · ss01, lo publicable de los ejercicios 5, 9, 12 y 17
SELECT count(*) FILTER (WHERE upper("Nombre") LIKE 'PEÑA %') AS empieza_pena_con_enie,
       count(*) FILTER (WHERE upper("Nombre") LIKE 'PENA %') AS empieza_pena_sin_enie,
       count(*) FILTER (WHERE "Nombre" LIKE 'peña %') AS en_minusculas_tal_cual,
       count(*) FILTER (WHERE "Nombre" ~ ' $') AS con_espacio_final
FROM legacy."Pacientes";
SELECT count(*) AS con_fecha_de_dos_cifras,
       count(*) FILTER (WHERE (regexp_match("Nombre", '(?:^| )\d{1,2}/\d{1,2}/(\d{2})(?: |$)'))[1]::int BETWEEN 30 AND 49) AS anio_30_a_49
FROM legacy."Pacientes" WHERE "Nombre" ~ '(?:^| )\d{1,2}/\d{1,2}/\d{2}(?: |$)';
SELECT count("FechaNac") AS con_fecha, count(*) FILTER (WHERE extract(day FROM "FechaNac") <= 12) AS dia_1_a_12,
       round(100.0 * count(*) FILTER (WHERE extract(day FROM "FechaNac") <= 12) / count("FechaNac"), 1) AS pct
FROM legacy."Pacientes";
SELECT count(*) FILTER (WHERE "Edad" LIKE '%ñ%') AS edades_con_enie FROM legacy."Pacientes";
