# angular-8-legacy-for-backend-devs-20261006-8291

- **Curso:** angular-8-legacy-for-backend-devs
- **Tanda:** rescate posterior al cierre
- **Creado:** 2026-10-06
- **Propósito:** rescatar de las transcripciones de las sesiones el código de prueba de la producción del curso, con instrucciones para replicarlo
- **Estado:** archivado
- **Cómo regenerar lo que limpiar.py borra:** nada de aquí lo necesita; `salidas/` se rehace corriendo los scripts

## Qué hay

- `README.md`: qué se probó, de qué sesión salió, cómo se corre hoy y qué no se pudo rescatar.
- `rescatar.sh`: rehace desde cero las carpetas generadas de este directorio; es un envoltorio de `../regenerar-rescates.py --dir <este directorio>`, que lee las sesiones y opciones de `../rescates.tsv`.
- `sondas-labcore.sh`: las sondas de LabCore del 09/09 (Mongo 4.0 standalone, Java 8, driver 3.8.2 contra Mongo 4.0–8.0) con las reglas de hoy; validado, sin correr.
- `01-` a `07-`: comandos, bitácora y verificaciones de siete sesiones (08/09–11/09); en `02-`, los archivos de las sondas; en `03-`, los auditores de anclas y secciones.

## Qué sirvió

- Nada se extrajo al curso: lo que estas pruebas decidieron ya está publicado. Se archiva como registro de cómo se verificó.
- No se ejecutó nada al rescatar.
