# ✅ Soluciones — Apéndice a02: El `compose.yaml` de la ruta

> **Curso:** Ruta SQL · Solucionario del [Apéndice a02](../a02-compose-de-la-ruta.md)
> **Ejercicios:** 6 · **Perfil:** M donde hay datos · **Motores:** los de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso)
> **Fecha de verificación ejecutada:** 12/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

---

## 🟢 Fácil (1–2)

### Ejercicio 1

**Enunciado (resumen):** obtener el digest de la imagen con la que corre Postgres y compararlo con el
del `compose.yaml`.

**Solución.** El contenedor sabe de qué imagen salió, y la imagen, de qué digest:

```bash
docker image inspect "$(docker inspect alameda-lab-postgres-1 --format '{{.Image}}')" --format '{{join .RepoDigests "\n"}}'
grep -n "image: pgvector" src/lab/compose.yaml
```

```text
pgvector/pgvector@sha256:2358fcba361ed2233a5ed81b5fe4ca779ccb304120ce531a3bf51c0ed7e2bc11
14:    image: pgvector/pgvector@sha256:2358fcba361ed2233a5ed81b5fe4ca779ccb304120ce531a3bf51c0ed7e2bc11
```

Coinciden. Si un día no, el contenedor salió de otra imagen: un `up` anterior al cambio del
`compose.yaml`, o un override tuyo. `uv run lab up` lo recrea con la del archivo.

[← Volver al ejercicio](../a02-compose-de-la-ruta.md#-ejercicio-1--el-digest-que-corre)

### Ejercicio 2

**Enunciado (resumen):** comprobar `wal_level` y `shared_preload_libraries`, y ver una consulta propia
en `pg_stat_statements`.

**Solución.**

```sql
-- postgres
SHOW wal_level;
SHOW shared_preload_libraries;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT pg_stat_statements_reset() IS NOT NULL;
SELECT count(*) FROM legacy."Pacientes" WHERE "Nombre" LIKE '%DNI%';   -- dos veces
SELECT count(*) FROM legacy."Pacientes" WHERE "Nombre" LIKE '%DNI%';
SELECT calls, rows, query FROM pg_stat_statements WHERE query LIKE 'SELECT count(*) FROM legacy%';
```

```text
 wal_level
-----------
 logical
(1 row)

 shared_preload_libraries
--------------------------
 pg_stat_statements
(1 row)

 calls | rows |                             query
-------+------+----------------------------------------------------------------
     2 |    2 | SELECT count(*) FROM legacy."Pacientes" WHERE "Nombre" LIKE $1
(1 row)
```

(Entre medio, los dos conteos devolvieron 18936 en M.)

`pg_stat_statements` agrupa por la forma de la consulta, no por su texto: el `'%DNI%'` aparece como
`$1`, y por eso dos ejecuciones con otro patrón sumarían en la misma fila. El `reset` es para que
`calls` no cuente ejecuciones anteriores.

[← Volver al ejercicio](../a02-compose-de-la-ruta.md#-ejercicio-2--lo-que-postgres-trae-encendido)

## 🟡 Intermedio (3–4)

### Ejercicio 3

**Enunciado (resumen):** un `compose.override.yaml` que baje la memoria de `mysql` a 1 GB, comprobado
con `docker compose config` y con `git check-ignore`.

**Solución.** `src/lab/compose.override.yaml`:

```yaml
# Mis ajustes locales: el compose del curso no se toca.
services:
  mysql:
    mem_limit: 1g
```

```text
$ docker compose config mysql | grep -E 'image|mem_limit'
    image: mysql@sha256:e2bde46db6563855d7177adb5f0b57b9dc663f5a20927a90f4259d3312068497
    mem_limit: "1073741824"

$ git check-ignore -v lab/compose.override.yaml
cursos-bd/ruta-sql/src/.gitignore:13:lab/compose.override.yaml	lab/compose.override.yaml
```

El `git check-ignore` se ejecutó desde `src/`; la salida dice qué línea de qué `.gitignore` lo ignora.
`docker compose config` muestra la memoria en bytes: 1 GiB son 1.073.741.824.

[← Volver al ejercicio](../a02-compose-de-la-ruta.md#-ejercicio-3--tu-override)

### Ejercicio 4

**Enunciado (resumen):** medir el arranque y la memoria en reposo de cada servicio del camino base, y
explicar la mayor diferencia con la tabla del apéndice.

**Solución.** Por servicio, con la imagen ya descargada y un volumen nuevo:

```bash
uv run lab down -v
time uv run lab up oracle          # lo mismo con base, contraste, mongo y sqlserver
sleep 60; docker stats --no-stream --format '{{.Name}}\t{{.MemUsage}}'
uv run lab down -v
```

En la máquina de verificación salió la tabla del apéndice: 3, 9 y 16 s para Postgres, MySQL y
Oracle; 93 MiB, 544 MiB y 2,03 GiB. Lo que más se aparta en otra máquina suele ser Oracle, por dos
razones: su arranque escribe la base inicial en el volumen, así que depende del disco, y su memoria
oscila (recién creado ronda los 2 GiB y baja después).

> ⚠️ **Error típico:** medir con la imagen sin descargar. Entonces mides la red, no el arranque, y
> Oracle son 6 GB.

[← Volver al ejercicio](../a02-compose-de-la-ruta.md#-ejercicio-4--tu-tabla-de-arranque)

## 🟠 Difícil (5–6)

### Ejercicio 5

**Enunciado (resumen):** cambiar el `command` de `mysql` a `--secure-file-priv=/caja`, predecir y
reproducir el fallo, y defender la opción del curso.

**Solución de referencia.** Un override de una sola vez:

```yaml
services:
  mysql:
    command: ["--secure-file-priv=/caja", "--innodb-buffer-pool-size=512M"]
```

Con un volumen nuevo, `up --wait` termina en `exited (1)`, y el log lo explica:

```text
2026-10-12 22:10:38+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 9.7.2-1.el9 started.
chown: changing ownership of '/caja': Read-only file system
chown: changing ownership of '/caja/s': Read-only file system
chown: changing ownership of '/caja/s/esquema': Read-only file system
chown: changing ownership of '/caja/s/esquema/ALAMEDA.sql': Read-only file system
```

Fueron 899 líneas iguales, una por archivo, y `docker inspect` dio `exit=1 oom=false`. El
*entrypoint* de la imagen intenta que el usuario `mysql` sea dueño del directorio de
`--secure-file-priv`, y la caja está montada en solo lectura.

Las dos salidas posibles, y por qué el curso eligió la segunda: **montar la caja con escritura**
haría que el `chown` cambiara el dueño de tus archivos en el disco, y dejaría a cualquier carga con
permiso de modificar el original del que miden todos; **`--secure-file-priv=` vacío** deja leer
cualquier directorio, que en un MySQL que solo escucha en `127.0.0.1` no expone nada.

**Rúbrica.** Una respuesta correcta tiene que:
- predecir que el contenedor no arranca, o al menos que falla algo del montaje;
- citar la línea del `chown` y nombrar el solo lectura como la causa;
- comparar las dos salidas por lo que arriesgan, no por la comodidad.

Y queda invalidada si:
- propone montar la caja con escritura sin decir qué le pasa a la caja;
- deja `--secure-file-priv=` vacío en un servidor que escucha fuera de `127.0.0.1`.

[← Volver al ejercicio](../a02-compose-de-la-ruta.md#-ejercicio-5--mysql-y-la-caja-de-solo-lectura)

### Ejercicio 6

**Enunciado (resumen):** resolver hoy los digests de `mysql:9.7.2` y `pgvector/pgvector:0.8.7-pg18`,
compararlos y decir qué harías antes de reemplazar uno.

**Solución de referencia.**

```text
$ docker buildx imagetools inspect mysql:9.7.2
Name:      docker.io/library/mysql:9.7.2
MediaType: application/vnd.oci.image.index.v1+json
Digest:    sha256:e2bde46db6563855d7177adb5f0b57b9dc663f5a20927a90f4259d3312068497

$ docker buildx imagetools inspect pgvector/pgvector:0.8.7-pg18
Name:      docker.io/pgvector/pgvector:0.8.7-pg18
MediaType: application/vnd.oci.image.index.v1+json
Digest:    sha256:2358fcba361ed2233a5ed81b5fe4ca779ccb304120ce531a3bf51c0ed7e2bc11
```

El 12/10/2026, los dos coinciden con el `compose.yaml`. Si uno no coincide, el tag se movió a otra
imagen con la **misma versión del motor**, casi siempre por un parche del sistema operativo de la
imagen. Antes de reemplazarlo: levantar la imagen nueva con un volumen nuevo, correr `uv run lab load`
en S y en M, y repetir una medición publicada para comprobar que la forma no cambió. Recién entonces se
cambia el digest y la fecha del comentario.

**Rúbrica.** Una respuesta correcta tiene que:
- comparar el `Digest` del índice (el de la primera línea), no el de una plataforma;
- distinguir "se movió el tag" de "cambió la versión";
- pedir al menos una carga y una medición antes del reemplazo.

Y queda invalidada si:
- reemplaza el digest por un tag para "no tener que actualizarlo".

[← Volver al ejercicio](../a02-compose-de-la-ruta.md#-ejercicio-6--se-movió-el-tag)
