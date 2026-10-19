# 🧪 ruta-sql-20261018-527b · cómo correr estas pruebas

> **Curso:** ruta-sql · **Tanda:** T13 (el track de SQL Server), y las tres correcciones previas · **Creado:** 2026-10-18
> **Propósito:** ejecutar todo lo que publican ss01–ss05 y ssa-01, separar lo publicable de lo privado de SQL Server, y medir el
> `shm_size` de Postgres (M-58).

## 1. 🎯 Qué se prueba y para qué

| Prueba | Documento | Entrada |
|---|---|---|
| `shm/` (matriz de `work_mem` × `/dev/shm`) | `a02`, `a08` E-69 | M-58 |
| `../ruta-sql-20261015-80f7/martes-solucion/99_deshacer.sql` y `arnes-tras-deshacer.txt` | F26 (estado del lab) | — |
| `explora/01`–`06` y los scripts de `src/ss01-…` | ss01 | M-59–M-61, E-73–E-78 |
| `explora/07`–`10` y las carreras de `src/ss02-…` | ss02 | M-62–M-65, E-79–E-84 |
| `explora/11`–`14` y `src/ss03-…` | ss03 | M-66–M-68, E-85–E-87 |
| `explora/15`–`19` y `src/ss04-…` | ss04 | M-69–M-71, E-88–E-94 |
| `explora/20`, `22`–`27` y `src/ss05-…` | ss05 | M-72–M-74, E-95–E-101 |
| `explora/21` y la prueba de `TZ` | ssa-01 | — |

## 2. 🛠️ Prerrequisitos

El laboratorio del curso con `LAB_CAJA` apuntando a `zz-code/ruta-sql-20261014-d471/salidas/caja-t9` (la caja M), Docker Desktop (SQL
Server y DAB son `amd64`, emulados), y la imagen `ruta-sql-uv-mssql:t13` (`imagen-uv/Dockerfile`: la de uv del curso más `libltdl7`,
`libkrb5-3` y `libgssapi-krb5-2`, que el ODBC de `mssql-python` necesita, E-76). `herramientas/vivos.py` agrega entradas a `a08` y a la
bitácora con sus enlaces de índice.

## 3. 🧭 Reglas antes de correr

Todo lleva `curso=ruta-sql`. Los contenedores temporales se crean con un nombre propio y se borran con `docker rm -f -v <nombre>`.
**Nunca `prune`**: el 18/10/2026 un `docker volume prune -f --filter label!=nada` borró 15 volúmenes anónimos, 14 ajenos
(`salidas/INCIDENTE-volumenes-borrados-por-prune.txt`). `sqlcmd.sh` de este directorio lleva `-b` (corta en el primer error); el de
`src/ss01-…/sqlcmd.sh`, no.

## 4. ▶️ Cómo se corre

```bash
./correr-src.sh python ss05-data-api-builder-y-json/03_api.py      # cualquier script de src/, con el extra sqlserver
./correr-src.sh lab load --engine sqlserver --profile m --private   # la caja en SQL Server
UV_CMD=lock ./correr-src.sh                                        # rehace src/uv.lock
./psql.sh < explora/05_ejercicios_ss01_pg.sql                      # Postgres
../../cursos-bd/ruta-sql/src/ss01-la-base-en-su-motor-original/sqlcmd.sh < explora/21_ssa01.sql
shm/matriz.sh                                                      # M-58, con el /dev/shm que tenga Postgres
```

Los `explora/*.py` se corren con `./correr-src.sh python /sesion/explora/<archivo>`.

## 5. 📏 Cómo se mide

Macbook M1 Pro, Docker Desktop 4.92.0 con motor 29.8.0, VM de 7,75 GiB; SQL Server 2025 CU9 y DAB 2.1.5 emulados con Rosetta. Lo de
SQL Server se mide con `SET STATISTICS IO/XML`, `sys.dm_db_index_physical_stats`, `sys.dm_tran_version_store_space_usage` y Query
Store, y queda en `salidas/privado/`; **no se publica** (a09). Lo de Postgres va con `EXPLAIN (ANALYZE, BUFFERS)` y `pg_relation_size`.

## 6. 🧮 Los intermedios que amasan la salida

Ninguno: las cifras publicadas son las líneas de `salidas/*.txt` tal cual (conteos de la caja, mensajes, estructura de planes y medidas
de Postgres).

## 6b. ▶️ T14

`a10/corre.sh` rehace el ciclo del museo; las pruebas del `.bas` corren con `docker run --rm -v "$PWD":/w -w /w
ruta-sql-libreoffice:a10 python3 run_bas_tests.py [locale] [año]` desde `src/a10-el-access-de-museo/`. Los ejercicios de `a03`,
`a04`, `a07` y `a08` tienen sus scripts en la carpeta de cada apéndice; los de MySQL y Oracle se corrieron levantando un motor a
la vez, porque otra carga de la máquina dejó la VM de Docker sin memoria (SQL Server, MySQL y Artemis murieron por OOM a las
21:57–22:49 del 18/10, hora de Córdoba). `a08/lock_timeout.race` es el escenario del ejercicio 7.

## 6c. ▶️ T16 y E9

`t16/estado.sh <url>` devuelve el código HTTP de una URL con un agente de navegador; `t16/urls.txt` es la lista que se
extrajo de los `.md` publicados, y `t16/urls-estado.txt`, el resultado del 18/10/2026. El laboratorio se borró desde
`cursos-bd/ruta-sql/src/lab/` con `docker compose --profile '*' down -v`, después de guardar el inventario en
`t16/inventario-antes-de-borrar.txt`.

## 7. ✅ Qué se espera ver

`salidas/ss05-03_api-2.txt` (las seis líneas de ss05), `salidas/shm-matriz-*.txt` (M-58), `salidas/ss02-ej16-pg.txt` (M-65),
`salidas/ss03-ej19-pg.txt` (M-68), `salidas/ss03-04_alternativas.txt` y `ss03-02_sniffing-repeticion.txt` (las estructuras de ss03).

## 8. 📂 Salidas

`salidas/` lo publicable; `salidas/privado/` los resultados de SQL Server (no se publican); `salidas/uv-cache` y `uv-venv`,
regenerables; `salidas/uv.lock.antes`, el lock antes del extra.

## 9. 🧹 Limpieza

Al cerrar el curso (T16): las bases `ss01_pruebas`, `ss02`–`ss05` en SQL Server (`DROP DATABASE`), las imágenes
`ruta-sql-uv-mssql:t13` y `ruta-sql-libreoffice:a10` (`docker rmi`; las dos llevan `curso=ruta-sql`), y los contenedores y volúmenes
del curso por su etiqueta, contra el inventario. En Oracle quedó cargado `LEGACY` con las cuatro tablas de M (T14, para `a03` y
`a07`).

## 10. 🚫 Qué se dejó fuera

`salidas/uv-cache` y `uv-venv` (se regeneran con `correr-src.sh`), y la imagen derivada (se regenera con `docker build -t
ruta-sql-uv-mssql:t13 imagen-uv`).
