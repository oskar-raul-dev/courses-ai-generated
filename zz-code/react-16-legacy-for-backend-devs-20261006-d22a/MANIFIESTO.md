# react-16-legacy-for-backend-devs-20261006-d22a

- **Curso:** react-16-legacy-for-backend-devs
- **Tanda:** rescate posterior al cierre
- **Creado:** 2026-10-06
- **Propósito:** rescatar de las transcripciones de las sesiones el código de prueba de la producción del curso, con instrucciones para replicarlo
- **Estado:** archivado
- **Cómo regenerar lo que limpiar.py borra:** nada de aquí lo necesita; `salidas/` se rehace corriendo los scripts

## Qué hay

- `README.md`: qué se probó, de qué sesión salió, cómo se corre hoy y qué no se pudo rescatar.
- `rescatar.sh`: rehace desde cero las carpetas generadas de este directorio; es un envoltorio de `../regenerar-rescates.py --dir <este directorio>`, que lee las sesiones y opciones de `../rescates.tsv`.
- `01-` a `04-`: comandos y verificaciones del corpus de cuatro sesiones (08/09–06/10). No hay corridas del código del curso: se ejecutó sin registro y la revalidación está en el plan desechable V0–V13 del curso.

## Qué sirvió

- Nada se extrajo al curso: lo que estas pruebas decidieron ya está publicado. Se archiva como registro de cómo se verificó.
- No se ejecutó nada al rescatar.
