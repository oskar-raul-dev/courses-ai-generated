# ruta-sql-20261018-527b

- **Curso:** ruta-sql
- **Tanda:** T13 (el track de SQL Server) y las tres correcciones de antes; T14 (el museo y los apéndices que crecen); T15 (los README); T16 y E9 (el cierre)
- **Creado:** 2026-10-18
- **Propósito:** ejecutar el track de SQL Server y lo que publica, con lo privado aparte
- **Estado:** archivado (18/10/2026, T16): lo publicable está en el curso; quedan las corridas privadas de SQL Server, el incidente del `prune` y las pruebas de T14–T16
- **Cómo regenerar lo que limpiar.py borra:** `./correr-src.sh python -c pass` (rehace `salidas/uv-venv`) y `docker build -t ruta-sql-uv-mssql:t13 imagen-uv`

## Qué hay

- `correr-src.sh`, `psql.sh`, `sqlcmd.sh`: ayudantes de la sesión.
- `imagen-uv/`: la imagen de uv con las bibliotecas del ODBC.
- `shm/`: la consulta y la matriz de M-58.
- `explora/`: las pruebas de los ejercicios y de los hallazgos, por fase.
- `vivos/` y `herramientas/vivos.py`: las entradas de `a08` y de la bitácora, tal como se agregaron.
- `salidas/`: lo publicable; `salidas/privado/`: lo de SQL Server; `salidas/INCIDENTE-…`: los volúmenes que borró el `prune`.
- `a10/` (T14): `corre.sh` (Maven, Java y Python en contenedor), las corridas del ciclo, de las pruebas del `.bas`
  (`corrida-bas.txt`), de mdbtools, de los ejercicios y de la imagen de Maven de `a02`; `ej5/` es la solución del ejercicio 5
  (el parser sin configuración regional), con su corrida en las cuatro configuraciones.
- `a03/`, `a04/`, `a07/`, `a08/` (T14): los scripts y las salidas de los ejercicios de cada apéndice, por motor.
- `t15/puente-lib/` (T15): los tres jars que baja el `pom.xml` del boss del puente, para comprobar el comando que publica su README.
- `t16/` (T16 y E9): las URL del curso y su estado (`urls-estado.txt`, con `estado.sh`), el inventario de Docker antes de borrar el laboratorio, la vista previa de `limpiar.py`, la copia de `_desechable-propuesta-ruta.md` antes de borrarla y una copia del plan de producción al cerrar.

## Qué sirvió

`src/lab/engines/sqlserver.py`, los cambios de `cli.py`, `config.py`, `race.py`, `compose.yaml` y `pyproject.toml`, y `src/ss01-…` a
`src/ss05-…` en el curso; las mediciones M-58 a M-74 y los errores E-73 a E-101. En T14: `src/a10-el-access-de-museo/`
(con `Dockerfile.libreoffice`), los ejercicios de `a03`, `a04`, `a07`, `a08` y `a10`, M-75 a M-77 y E-102.
