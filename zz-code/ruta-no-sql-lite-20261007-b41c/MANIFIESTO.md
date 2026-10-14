# ruta-no-sql-lite-20261007-b41c

- **Curso:** ruta-no-sql-lite
- **Tanda:** Tandas 3 y 4 (F07–F14)
- **Creado:** 2026-10-07
- **Propósito:** pruebas y mediciones de los Bloques II y III: DuckDB, TimescaleDB, OpenSearch y Neo4j contra Postgres
- **Estado:** archivado (12/10/2026, cierre de T8; guarda la solución privada de su boss)
- **Cómo regenerar lo que limpiar.py borra:** no hay dependencias propias; las del curso, con `uv sync` y `npm ci` en `src/`

## Qué hay

- `probe_*.py`: sondeos de F07 (DuckDB); `probe_f14*.ts`: `CYCLE` contra `UNION` (F14). `comandos-*.sh`: pasos sueltos de a03, F10–F14.
- `salidas/`: logs de cada medición e inventario de Docker.

## Qué sirvió

- F07–F12: los scripts definitivos se escribieron directamente en `src/07-…` a `src/12-…/boss/`.
- `verificar-lab.sh` adaptado a `src/lab/check/`.
- La solución del boss II, privada, se queda aquí (`boss2-solucion-privada.md`): no se publica.
- F13–F14: los scripts definitivos en `src/13-…` y `src/14-…`; el estado del boss III en `src/16-…/boss/setup.ts`.
- La solución del boss III, privada, también se queda aquí (`boss3_solucion.ts` y `salidas/boss3-solucion.log`).
