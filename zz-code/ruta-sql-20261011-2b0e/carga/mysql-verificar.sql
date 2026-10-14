SELECT COUNT(*) FROM legacy.`Pacientes`;
SELECT COUNT(*) FROM legacy.`Pacientes` WHERE `Nombre` LIKE '%Ñ%';
SELECT `Nombre`, HEX(`Nombre`) FROM legacy.`Pacientes` WHERE `Nombre` LIKE 'NU%EZ%' LIMIT 2;
