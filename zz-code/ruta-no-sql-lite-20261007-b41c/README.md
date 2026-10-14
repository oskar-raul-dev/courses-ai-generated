# 🧪 ruta-no-sql-lite-20261007-b41c · cómo correr estas pruebas

> **Curso:** ruta-no-sql-lite · **Tanda:** Tandas 3 y 4 (F07–F14) · **Creado:** 2026-10-07
> **Propósito:** pruebas y mediciones de los Bloques II y III: DuckDB, TimescaleDB, OpenSearch y Neo4j contra Postgres
> Se llena **mientras se prueba**. Variable usada abajo: `CURSO=cursos-bd/ruta-no-sql-lite` (desde la
> raíz del repositorio). Los scripts definitivos viven en `$CURSO/src/<fase>/`; aquí quedan los
> sondeos que los decidieron y las salidas.

## 1. 🎯 Qué se prueba y para qué

| Prueba | Fase | Alimenta |
|---|---|---|
| `probe_duckdb.py` — tipos que infiere `read_json` y lecturas fuera de la ventana | F07 §6.3, a05 | defecto del generador (70 386 / 70 108) |
| `probe_profile.py`, `probe_storage.py`, `probe_bytes.py` — qué expone el perfilador | F07 §6.6, a04 | M-16; frío contra caliente; `count` sin medir |
| `probe_parquet.py` — pie del Parquet y bytes que no cuenta el perfilador | F07 §6.5 | tamaños por columna |
| `probe_writers.py` — conflictos de escritura | F07 §8 | M-17, E-38 |
| `probe_tz.py` — zona horaria de sesión, error de columna | F07 §9 | E-39, pista del boss II |
| `comandos-a03-duckdb.sh` | a03 | sección DuckDB, E-40 |
| `$CURSO/src/07-analitico-levantar-y-modelar/*` | F07 | M-15, M-16, M-17 |
| `probe_alter_duckdb.py`, `probe_spill.py`, `probe_spill2.py` | F08 §4.1, §4.4 | forma de medir bytes escritos y volcado |
| `$CURSO/src/08-analitico-romper-y-medir/*` | F08 | M-18, M-19, M-20, E-41–E-43 |
| `$CURSO/src/09-series-levantar-y-modelar/*` | F09 | M-21–M-24, E-44 |
| `comandos-a03-timescale.sh` | a03 | sección TimescaleDB |
| `$CURSO/src/10-series-romper-y-medir/*`, `comandos-f10-limpieza.sh` | F10 | M-25–M-27, E-45, E-46 |
| `$CURSO/src/11-busqueda-levantar-y-modelar/*`, `comandos-f11-*.sh`, `comandos-a03-opensearch.sh` | F11, a03 | M-28–M-30, E-47–E-50 |
| `$CURSO/src/12-busqueda-romper-y-medir/*`, `comandos-f12.sh` | F12 | M-31–M-33, E-51, E-52 |
| `$CURSO/src/12-busqueda-romper-y-medir/boss/*`, `probe_boss2.py`, `boss2_solucion.ts`, `boss2-solucion-privada.md` | boss II | las tres cifras y su solución privada (no se publica) |
| `$CURSO/src/lab/check/verificar-lab.sh` | a02 | persistencia de las diez familias en `condor-lab-check` |
| `revision_urls.py`, `revision_redirects.py` | revisión T0–T3 | estado de cada URL externa |
| `$CURSO/src/13-grafos-levantar-y-modelar/*`, `comandos-f13-a03.sh` | F13, a03 | M-34–M-36, E-53, E-54 |
| `probe_f14.ts`, `probe_f14_union.ts` — `CYCLE` contra `UNION` antes de fijar la apuesta | F14 §3, §4.3 | la condición de la apuesta 8 |
| `$CURSO/src/14-grafos-romper-y-medir/*`, `comandos-f14-cache.sh` | F14 | M-37–M-40, E-55, E-56, corrección de a07 |
| `$CURSO/src/16-vectorial-romper-y-medir/boss/setup.ts`, `boss3_solucion.ts` | boss III | el estado que pide el encargo y su solución privada (no se publica) |

## 2. 🛠️ Prerrequisitos

macOS arm64, Docker Desktop 29.8.0 (VM 7,75 GiB), Node 24.21.0, Python 3.13.4 con `uv` 0.11.14 y el
`uv.lock` del curso (DuckDB 1.5.6, psycopg 3.3.6). Perfil `base` del compose del curso arriba
(`condor-lab-base-1`, PostgreSQL 18.6). Dataset `reading-5m` generado (`datasetSha256 8dc486dea089…`). Para T4: perfiles `grafos` (Neo4j 2026.09.0) y
`vectorial` (Qdrant con la colección `pirep` de 1 M), y `workOrder-1m` (`11a67c65fb22…`) y `pirep-1m`
(`d8a956d0c85a…`) generados.

## 3. 🧭 Reglas antes de correr

Inventario inicial en `salidas/inventario-docker-inicial.log`. Solo se usa el laboratorio del curso
(proyecto compose `condor-lab`, puertos de `a02`); no se crean contenedores nuevos para F07. La base
`analitico` de Postgres la crea y la borra `load_postgres.py`.

## 4. ▶️ Cómo se corre

```bash
cd $CURSO/src
node lab/generator/src/generate.ts --focus reading --volume 5m
uv run python 07-analitico-levantar-y-modelar/build.py           # → salidas/build.log
uv run python 07-analitico-levantar-y-modelar/load_postgres.py   # → salidas/load_postgres.log
uv run python 07-analitico-levantar-y-modelar/measure.py         # → salidas/measure-duckdb.log
node 07-analitico-levantar-y-modelar/measure.ts                  # → salidas/measure-pg-sin-indices.log
docker compose -f lab/compose.yaml exec -T base psql -U postgres -d analitico < 07-analitico-levantar-y-modelar/indexes.sql
node 07-analitico-levantar-y-modelar/measure.ts --indexes [--no-seqscan]
uv run python 07-analitico-levantar-y-modelar/measure.py --table reading ; node 07-analitico-levantar-y-modelar/measure.ts --table reading
for i in 1 2 3; do uv run python 07-analitico-levantar-y-modelar/writers.py; done   # → salidas/writers.log
node 08-analitico-romper-y-medir/alter.ts                      # → salidas/alter-pg.log
for i in 1 2; do uv run python 08-analitico-romper-y-medir/alter.py; done   # → salidas/alter-duckdb.log
uv run python 08-analitico-romper-y-medir/explain.py           # → salidas/explain-duckdb.log
uv run python 08-analitico-romper-y-medir/spill.py ; node 08-analitico-romper-y-medir/spill.ts   # → salidas/spill-*.log
uv run python 08-analitico-romper-y-medir/two_processes.py     # → salidas/two-processes.log
node 09-series-levantar-y-modelar/load.ts                      # → salidas/load-series.log (19 min)
node 09-series-levantar-y-modelar/measure.ts                   # → salidas/measure-series.log
docker compose -f lab/compose.yaml exec -T series psql -U postgres -d condor < 09-series-levantar-y-modelar/rollups.sql   # → salidas/rollups.log
node 09-series-levantar-y-modelar/rollups.ts                   # → salidas/rollups-measure.log
node 09-series-levantar-y-modelar/compress_update.ts           # → salidas/compress-update*.log (la 1.ª corrida falló en E-44 sin deshacer; ver §5)
node 09-series-levantar-y-modelar/chunk_interval.ts            # → salidas/chunk-interval.log
node 09-series-levantar-y-modelar/retention.ts                 # → salidas/retention.log (DESTRUCTIVO, al final)
# F10 (después de volver a correr 09-…/load.ts y rollups.sql)
docker compose -f lab/compose.yaml exec -T series psql -U postgres -d condor < 10-series-romper-y-medir/compress.sql
node 10-series-romper-y-medir/partition.ts ; node 10-series-romper-y-medir/backfill.ts
node 10-series-romper-y-medir/scorecard.ts --with-retention      # DESTRUCTIVO al final
node 10-series-romper-y-medir/cardinality.ts --segmentby ; node 10-series-romper-y-medir/cardinality.ts --chunks --intervals "7 days,1 day,6 hours"
# F11 (perfil series detenido)
node 11-busqueda-levantar-y-modelar/load.ts ; node 11-busqueda-levantar-y-modelar/load.ts --dataset lab/data/partCatalog-1m
node 11-busqueda-levantar-y-modelar/search.ts ; node 11-busqueda-levantar-y-modelar/facets.ts ; node 11-busqueda-levantar-y-modelar/source-of-truth.ts
# F12
docker compose -f lab/compose.yaml exec -T base psql -U postgres -d busqueda_base < 12-busqueda-romper-y-medir/fts.sql
node 12-busqueda-romper-y-medir/battery.ts ; node 12-busqueda-romper-y-medir/facets-fts.ts ; node 12-busqueda-romper-y-medir/reindex-alias.ts
node 12-busqueda-romper-y-medir/visibility.ts ; node 12-busqueda-romper-y-medir/visibility-pg.ts ; node 12-busqueda-romper-y-medir/disk-full.ts
node 12-busqueda-romper-y-medir/boss/setup.ts ; uv run python 12-busqueda-romper-y-medir/boss/tablero_duckdb.py ; node 12-busqueda-romper-y-medir/boss/tableros.ts
# verificación del compose (laboratorio detenido antes): cd lab && ./check/verificar-lab.sh
# F13 (perfiles base y grafos)
docker compose -f lab/compose.yaml exec -T base psql -U postgres < 13-grafos-levantar-y-modelar/indexes.sql
node 13-grafos-levantar-y-modelar/load.ts --dataset lab/data/workOrder-1m       # → salidas/load-neo4j-1m.log
node 13-grafos-levantar-y-modelar/measure.ts ; node 13-grafos-levantar-y-modelar/generic.ts
# F14
docker compose -f lab/compose.yaml exec -T base psql -U postgres < 14-grafos-romper-y-medir/edges.sql
node 14-grafos-romper-y-medir/ladder.ts       # → salidas/ladder.log (unos diez minutos)
node 14-grafos-romper-y-medir/shortest.ts     # → salidas/shortest.log
node 14-grafos-romper-y-medir/unbounded.ts    # → salidas/unbounded.log
sh ../../../zz-code/ruta-no-sql-lite-20261007-b41c/comandos-f14-cache.sh   # → salidas/cache.log (recrea grafos dos veces)
# boss III (reemplaza el grafo de workOrder-1m)
node 13-grafos-levantar-y-modelar/load.ts --dataset lab/data/pirep-1m           # → salidas/load-neo4j-pirep-1m.log
node 16-vectorial-romper-y-medir/boss/setup.ts                                  # → salidas/boss3-setup.log
node ../../../zz-code/ruta-no-sql-lite-20261007-b41c/boss3_solucion.ts         # → salidas/boss3-solucion.log (privado; desde src/)
uv run python ../../../zz-code/ruta-no-sql-lite-20261007-b41c/probe_<x>.py          # sondeos
```

## 5. 📏 Cómo se mide

DuckDB: `EXPLAIN (ANALYZE, FORMAT json)`, campos `total_bytes_read` y `cumulative_rows_scanned`, **una
conexión nueva por consulta** (en caliente lee 0). Postgres: `lab/harness/explain.ts`, páginas = hit +
read del nodo raíz; 2 workers por Gather. Una corrida por consulta: las cifras estructurales no varían
salvo `total_bytes_read` de la consulta de tres columnas (213 123 072 a 213 385 216 bytes en tres
corridas; se publica 203,2 MiB). Tiempos: una corrida, solo contexto. `writers.py`: tres corridas, se
publican las tres. F09: `compress_update.ts` se corrió dos veces; la primera aplicó la corrección de
una aeronave en los dos motores y murió en E-44 sin deshacerla, y se deshizo a mano con el `UPDATE … - 3`
de `salidas/`; la segunda, con la versión que deshace al final, es la publicada (la huella se comprobó
idéntica después). `rollups.ts` midió 0 la primera vez por contar los chunks de otra hypertable. F10: `cardinality.ts --chunks`
la primera vez murió en el `DROP TABLE` de 7573 chunks (E-45) y la tabla se borró con
`comandos-f10-limpieza.sh`; la versión publicada lo maneja. F11: `search.ts` se corrió antes de
`alternateOf` (1 de 2 en los números) y después; `source-of-truth.ts` falló dos veces (E-49 y E-50) antes de
la versión con tarea asíncrona; el índice duplicado se borró. F12: la batería es una corrida; `ts_rank(…, 1)`,
una consulta aparte después (en `comandos-f12.sh`). Facetas: `doc_count_error_upper_bound` lo da el motor. F13–F14: Neo4j con `lab/harness/neo4j-profile.ts` (suma de *db hits*
de `PROFILE`); los *db hits* varían un poco entre cargas (219 423–220 020). F14: la escalera es una corrida;
`statement_timeout` de 120 s en cada consulta de Postgres. La caché de Neo4j se midió con `io.stat` y
`memory.stat` del cgroup tras vaciar la caché de la VM con un contenedor privilegiado de un solo uso (la
imagen de base, por digest; un primer intento con un digest de alpine inventado falló con `invalid checksum
digest length` y no descargó nada). `generic.ts` falló una vez por E-53 al borrar; la versión publicada borra
en tandas.

## 6. 🧮 Los intermedios que amasan la salida

Bytes → MiB dividiendo entre 2^20 en los propios scripts. Páginas × 8192 → MiB en `measure.ts`. Ratios
de la fase calculados a mano: 4439 / 203,2 = 21,8; 1884,5 / 203,2 = 9,3; 4439 MiB / 50 M = 93 B por
fila; 577,2 MiB / 50 M = 12,1 B; ×4 para 200 M (aritmética, no medición). Pérdidas de `writers.py`:
8000 / 7597 = 1,053 y 8000 / 7728 = 1,035.

## 7. ✅ Qué se espera ver

Las cifras de M-15 a M-40, las tres del boss II y el estado del boss III de la bitácora del curso
(07/10/2026), y la salida de `boss3-solucion.log`.

## 8. 📂 Salidas

`salidas/*.log` (una por comando de §4), `salidas/diagramas/` (el Mermaid de F07 dibujado con
`zz-instrucciones/herramientas/exportar-diagramas.py`). Se regeneran corriendo §4.

## 9. 🧹 Limpieza

`DROP TABLE stint_edge, part_stint` en `postgres` del perfil `base` (F13–F14), `DROP DATABASE analitico` en el perfil `base` y `rm -r $CURSO/src/lab/data/analitico` (se regeneran con
§4). El laboratorio `condor-lab` se detiene con `docker compose -f $CURSO/src/lab/compose.yaml stop`.

## 10. 🚫 Qué se dejó fuera

Los datos: `reading-5m` (899 MB) y `analitico/` (1,1 GB) viven en `$CURSO/src/lab/data/`, ignorado por
git, y se regeneran con §4.
