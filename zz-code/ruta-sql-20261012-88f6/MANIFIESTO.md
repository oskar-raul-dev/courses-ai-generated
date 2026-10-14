# ruta-sql-20261012-88f6

- **Curso:** ruta-sql
- **Tanda:** T0 a T4
- **Creado:** 2026-10-12
- **Propósito:** el laboratorio de la Ruta SQL: generador, carga en tres motores, medición y todo lo
  que ejecutan `a01`, `a02`, `a04`, `a05`, `a06` y `a08`.
- **Estado:** vigente hasta T5 (la caja de M y los scripts de carga siguen en uso)
- **Cómo regenerar lo que limpiar.py borra:** `python3 -I generar.py s 1996 salidas/caja` (y `m`);
  `uv-venv`, `uv-cache` y `m2` se rehacen solos al correr `lab-en-contenedor.sh` y los `docker run`
  de Maven.

## Qué hay

- `generar.py` · genera una caja con el generador del curso (`src/lab/generator/`).
- `proporciones.py` · proporciones de la caja contra la historia y D30.
- `lab.sh` · el CLI del curso en el host (up/down/ps), con `compose.pruebas.yaml`.
- `lab-en-contenedor.sh` · el CLI del curso (`uv run --locked lab`) en el contenedor de uv.
- `compose.pruebas.yaml` · override con puertos aleatorios en `127.0.0.1`.
- `capturas-a01.sh`, `captura-a01-ej5.sh` · las capturas literales de `a01`, con el proyecto real.
- `comparar-tsql.sh` · `fn_ExtraerDNI` (SQL Server) contra el port de Python.
- `a06/` · los scripts de transacciones, versiones, Latin-1 y el Java de un archivo.
- `f01/contar_todo.py` · las 419 tablas de `legacy` contra sus CSV (F01, ejercicio 19).
- `salidas/fuentes/` · los textos de licencia de `a09`, descargados el 12/10/2026.
- `f03/oracle-vacio.sql` · la cadena vacía en Oracle (F03).
- `f04/comparar_parsers.py`, `f04/ej23_precios.sql` · el parser de 2016 contra el de 2026, y el ejercicio 23 (F04).
- `rehacer-modelo.sh` · rehace `staging` y `alameda` con los scripts de las fases (lo que después hizo `lab load --model`).
- `f06/` a `f08/` · las mediciones y los ejercicios de F06, F07 y F08.
- `boss1/` · la solución de referencia del boss del Bloque I (D42), con `NOTAS.md`. No viaja al repositorio público.
- `f05/medir.sql` · todas las mediciones de F05 contra `truth`; `f05/fonetica.sql`, `f05/daitch.sql`, `f05/ejercicios*.sql` · la fonética y las soluciones nuevas.
- `comandos-inventario.sh`, `comandos-versiones.sh`, `tags.sh` · inventario y versiones, de P8.
- `salidas/` · cajas, entornos y las salidas crudas de cada prueba.

## Qué sirvió

- `a01`, `a02`, `a04`, `a05`, `a06` y sus solucionarios; 13 entradas de `a08`.
- T2: `a09`, F00, F01, F02 y sus solucionarios, `a03` y cuatro entradas más de `a08`; el `fire_test` del manifiesto en el generador.
- El generador corregido (equipo por disciplina, volumen por año sin doble sesgo), `lab.loaded`
  (una fila por carga entera), el binlog apagado en la carga de MySQL, `max_wal_size` quitado del
  compose, `measure` con el perfil de `lab.loaded`, y `requires-python` acotado a 3.13: todo en
  `src/`.
- T3: F03, F04, F05 y sus solucionarios; M-04 a M-09 de la bitácora, tres instintos, E-18 a E-23 de `a08`.
  En el generador: los huérfanos de `ResultadoItem`, la fecha de nacimiento dentro de `Nombre` y la
  numeración nacional única (`_free_number`), los tres sin mover conteos.
- T4: F06, F07, F08, sus solucionarios y el boss I; M-10 a M-13, instintos 6 a 8, E-24 a E-28; `lab load --model`
  (D41); en el generador, `ub_value()` antes de septiembre de 2002, sin mover conteos.
