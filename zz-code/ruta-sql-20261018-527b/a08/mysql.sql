USE legacy;
SELECT IdPaciente FROM Pacientes WHERE similarity(Nombre, 'RAMIREZ NELIDA') > 0.5;
