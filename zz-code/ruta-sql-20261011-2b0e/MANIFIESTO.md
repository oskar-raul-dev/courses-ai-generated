# ruta-sql-20261011-2b0e

- **Curso:** ruta-sql
- **Tanda:** P8, P9 y P11
- **Creado:** 2026-10-11
- **Propósito:** verificación de laboratorio de la Ruta SQL: versiones, digests, RAM, emulación, drivers, prototipo del generador y funciones de Postgres; fuentes de P9
- **Estado:** vigente hasta T1 (el generador y el `compose.yaml` de prueba son el punto de partida de `a02` y `a05`)
- **Cómo regenerar lo que limpiar.py borra:** `salidas/` se rehace corriendo el README §4 (la caja, con `./comandos-generador.sh s` y `m`)

## Qué hay

- `lab/` — el `compose.yaml` de prueba (proyecto `ruta-sql-p8`) y los scripts que miden arranque y RAM.
- `generador/` — el prototipo del generador de la caja y el medidor de proporciones.
- `carga/` — la carga de la caja en Postgres, MySQL y Oracle.
- `funciones/` — las funciones de Postgres 18, Oracle 26ai Free y SQL Server 2025 que el curso usa.
- `drivers/` — la prueba de los cuatro drivers de Python.
- `java/` — Java 25 con un archivo suelto.
- `p11/` — el traslado a `prompts/`, como reemplazos exactos.
- `comandos-*.sh`, `tags.sh`, `texto-de-html.py`, `imagenes.txt`, `podman-rosetta.conf` — versiones, descargas, Podman, URL, inventario y limpieza.
- `salidas/` — lo efímero (1,1 GB): la caja, logs, TSV y licencias descargadas.

## Qué sirvió

- `cursos-bd/ruta-sql/prompts/verificacion-de-laboratorio/hallazgos.md` (H1–H13, F1–F2), y su traslado a alcance, guía, propuestas, contrato, prompts y README de `prompts/`.
- La exclusión de `00-convencion-de-git-y-tags.md` en `cursos-bd/ruta-sql/prompts/verificar-corpus.py`.
- Para T1: `lab/compose.yaml` → `src/lab/compose.yaml` (`a02`); `generador/` → `src/lab/generator/` (`a05`); `carga/` → `lab load` (`a05`).
