# ruta-no-sql-lite-20261010-b0dc

- **Curso:** ruta-no-sql-lite
- **Tanda:** T5 (Bloque IV: F17–F22, boss IV, `h-mini-08`–`10`)
- **Creado:** 2026-10-10
- **Propósito:** pruebas y mediciones de la Tanda 5, empezando por el sondeo de RAM del paso 1 de F17
- **Estado:** archivado (12/10/2026, cierre de T8; guarda la solución privada de su boss)
- **Cómo regenerar lo que limpiar.py borra:** nada que regenerar por ahora (solo `salidas/` pequeñas)

## Qué hay

- `anillo/` — compose de tres nodos de Cassandra 5.0.9 (heap 512M) y `sondeo.sh`: arranque, memoria y
  `QUORUM` con nodos caídos. Se borra solo con sus volúmenes.
- `salidas/` — inventario previo de Docker, `anillo-sondeo.log`, los logs de F17 (`f17-*.log`, `f17-diagrama.*`) y
  los de F18 (`f18-*.log`, incluidos los extractos de `system.log` y `debug.log` del nodo), y los de F19
  (`f19-sync.log`, `f19-conflicts.log`, `f19-postgres.log`, `f19-diagrama.mmd` y `.png`), y los de F20
  (`f20-apuesta.txt`, la predicción con su hora, y `f20-bet.log`, `-load`, `-history`, `-massive`, `-tablet`, `-pingpong`),
  y los de F21 (`f21-load*.txt`, `-transactions`, `-skew`, `-ranges-newsql`, `-global-copia`, `-global-copia-rangos`,
  `-global-regional`, `-global-autoridad`, `-global-superregion` y su intento con OOM, `-global-final` (con `GOMEMLIMIT` de 3 GiB) y `-global-final-oom-4500`, `-follower`,
  `-placement` (la primera corrida, con el leaseholder de la copia en Perú), `-mem-*` y `f21-diagrama.mmd`/`.png`).
- `f21-global.sh` y `f21-global-2.sh` — las corridas de `newsql-global`, una base por demo recién creado; la segunda
  pasada es la que vale (placement esperando a los leaseholders y regions contando el quórum).
- `f21-follower.ts` — la lectura con `follower_read_timestamp()` desde Perú sobre la copia.
- `f22-*.sh`, `f22-outage-intento.ts` y `boss-iv/solucion-privada.md` — las corridas de F22, el intento de apagar Ecuador
  y la solución privada del boss IV; sus salidas son `salidas/f22-*` (con `f22-apuesta.txt`, escrita antes de medir).

## Qué sirvió

El sondeo del anillo se volvió `src/lab/compose.anillo.yaml` del curso (F17, sección 6.6, y `a02`). Los logs
`salidas/f17-*.log` son la fuente de M-41–M-45 y E-57–E-59; los `f18-*.log`, de M-46–M-52 y E-60–E-63; los `f19-*.log`, de M-53–M-55; los `f20-*`, de M-56–M-60; los `f21-*`, de M-61–M-65 y E-69–E-74; los `f22-*`, de M-66–M-71, E-75–E-79 y la apuesta 11.
