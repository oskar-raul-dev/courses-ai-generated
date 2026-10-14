# 🧪 ruta-no-sql-lite-20261010-b0dc · cómo correr estas pruebas

> **Curso:** ruta-no-sql-lite · **Tanda:** T5 · **Creado:** 2026-10-10
> **Propósito:** pruebas y mediciones de la Tanda 5 (Bloque IV: columnar, offline-first, NewSQL).
> Se llena **mientras se prueba**: cada script nuevo entra aquí en la misma sesión. Las reglas, en
> `zz-code/README.md` § "El README de cada directorio". Si una sección no aplica, se dice por qué.

## 1. 🎯 Qué se prueba y para qué

- **`anillo/sondeo.sh`** → paso 1 de F17 (y F18): ¿cabe un anillo de tres nodos de Cassandra en la VM
  de Docker Desktop, y `QUORUM` falla como se espera con dos nodos caídos? Decide si F17 enseña quórum
  ejecutado o solo descrito.
- **F17, el código del lector** (vive en `cursos-bd/ruta-no-sql-lite/src/17-columnar-levantar-y-modelar/`, no
  aquí; regla D-09): `schema.cql`, `load.ts`, `baseline.ts`, `measure.ts`, `backfill.ts`, `batch.ts`,
  `entity.ts`, `quorum.sh`, más `lab/harness/cassandra-trace.ts` y `lab/compose.anillo.yaml`. Aquí quedan sus
  logs (`salidas/f17-*.log`), que alimentan M-41–M-45 de la bitácora y E-57–E-59 de `a09`.

- **F18–F20**: el código del lector vive en `src/18-…`, `src/19-…` y `src/20-…`; aquí quedan sus logs
  (`salidas/f18-*`, `f19-*`, `f20-*`, con `f20-apuesta.txt`, la predicción con su hora).
- **F21**: código en `src/21-newsql-levantar-y-modelar/`; aquí, `f21-global.sh` y `f21-global-2.sh` (las corridas de
  `newsql-global`, una base por demo; vale la segunda pasada), `f21-follower.ts` y `salidas/f21-*`.
- **F22**: código en `src/22-newsql-romper-y-medir/` y `src/lab/compose.replica.yaml`; aquí, `f22-contention.sh` (la
  escalera de contención), `f22-global.sh` (latencia de la copia), `f22-outage.sh` y `f22-outage-intento.ts` (la región
  caída, que no se pudo provocar), `f22-boss.sh` (las tres roturas del boss IV, en secuencia), `boss-iv/` (la solución
  privada, D-05) y `salidas/f22-*`, con `f22-apuesta.txt` escrita antes de medir.

## 2. 🛠️ Prerrequisitos

- Docker Desktop 29.8.0 en macOS arm64, VM con 7,75 GiB (`docker info` → MemTotal 8319770624) y 8 CPU.
- Imagen `cassandra@sha256:8819d1b7877e…` (5.0.9), la misma del servicio `columnar` del laboratorio.
- Laboratorio `condor-lab` **detenido** (el sondeo no lo toca, pero la RAM tiene que estar libre).

## 3. 🧭 Reglas antes de correr

```bash
mkdir -p salidas
docker ps -aq --no-trunc > salidas/contenedores-antes.txt
docker images -q --no-trunc | sort -u > salidas/imagenes-antes.txt
docker volume ls -q > salidas/volumenes-antes.txt
docker network ls -q > salidas/redes-antes.txt
```

Contenedores y volúmenes con la etiqueta `curso=ruta-no-sql-lite`; proyecto compose
`condor-anillo-sondeo`, distinto de `condor-lab`; **sin puertos publicados** (se entra con
`docker compose exec`). No se cambia nada de la máquina.

## 4. ▶️ Cómo se corre

**F17**, desde `cursos-bd/ruta-no-sql-lite/src/`, con `L=../../../zz-code/ruta-no-sql-lite-20261010-b0dc/salidas`:

```bash
cd lab && docker compose --profile base --profile columnar up -d --wait && cd ..
docker compose -f lab/compose.yaml exec -T columnar cqlsh < 17-columnar-levantar-y-modelar/schema.cql
node 17-columnar-levantar-y-modelar/load.ts            | tee $L/f17-load-5m.log     # sola: si Postgres carga a la vez, E-57
node 17-columnar-levantar-y-modelar/load.ts --only-x10 | tee $L/f17-load-x10.log    # ~20 min
node 17-columnar-levantar-y-modelar/baseline.ts        | tee $L/f17-baseline.log
node 10-series-romper-y-medir/partition.ts             | tee $L/f17-partition-50m.log
docker compose -f lab/compose.yaml exec -T columnar nodetool flush condor
docker compose -f lab/compose.yaml exec -T columnar nodetool tablestats condor > $L/f17-tablestats.log
node 17-columnar-levantar-y-modelar/measure.ts         | tee $L/f17-measure-5m.log
node 17-columnar-levantar-y-modelar/measure.ts --x10   | tee $L/f17-measure-x10.log
node 17-columnar-levantar-y-modelar/backfill.ts        | tee $L/f17-backfill.log
node 17-columnar-levantar-y-modelar/batch.ts           | tee $L/f17-batch.log
node 17-columnar-levantar-y-modelar/entity.ts          | tee $L/f17-entity.log
# el anillo, con el laboratorio detenido
(cd lab && docker compose --profile base --profile columnar stop)
docker compose -f lab/compose.anillo.yaml up -d --wait
17-columnar-levantar-y-modelar/quorum.sh               | tee $L/f17-quorum.log
docker compose -f lab/compose.anillo.yaml down -v
```

El sondeo previo del anillo:

```bash
# desde este directorio
./anillo/sondeo.sh 2>&1 | tee salidas/anillo-sondeo.log
```

Levanta `c1`→`c2`→`c3` en serie (cada uno espera al anterior sano), imprime el tiempo total de
arranque, `nodetool status`, la memoria de cada nodo tras 20 s de reposo, y luego: keyspace con RF 3,
escritura y lectura en `QUORUM`; para `c3` y lee en `QUORUM` (debe funcionar); para `c2` y lee en
`QUORUM` (debe fallar) y en `ONE` (debe funcionar). Termina con `docker compose down -v`.

**F21–F22**: los guiones `f21-*.sh` y `f22-*.sh` de este directorio, cada uno con su orden de pasos en la cabecera.
`newsql-global` va solo y recreado (`--force-recreate`) en cada corrida: en 8 GB, con una base y `GOMEMLIMIT=3GiB`.

## 5. 📏 Cómo se mide

Memoria con `docker stats --no-stream` (uso del cgroup), una corrida, tras 20 s de reposo con el anillo
sano y sin datos. El arranque es contexto, no argumento (H3 de la verificación de laboratorio).

## 6. 🧮 Los intermedios que amasan la salida

Ninguno: las cifras se leen tal cual del log (`arranque_total_s=`, líneas `condor-anillo-sondeo-cN-1`).

## 7. ✅ Qué se espera ver

**10/10/2026:** arranque en serie 206 s; nodos en 1,261 / 1,131 / 1,133 GiB (≈3,5 GiB el anillo);
`QUORUM` responde con un nodo caído y falla con dos con
`Cannot achieve consistency level QUORUM … 'required_replicas': 2, 'alive_replicas': 1`; `ONE` responde.

**F17, 10/10/2026** (las cifras publicadas están en M-41–M-45 de la bitácora del curso):
`f17-load-5m.log` 10 048 539 filas en 248 s; `f17-load-x10.log` 50 M en 1206 s con 13 reintentos
(`f17-load-5m-timeout.log` y `f17-load-x10-timeout.log` son los dos E-57); `f17-measure-5m.log` y
`f17-measure-x10.log` (consulta 1: 3 particiones y 9666 filas en los dos motores; consulta 2: 1 contra 61);
`f17-backfill.log` (5 M leídas, 62 486 escritas); `f17-batch.log` (200 000 en `system.batches` con registro);
`f17-entity.log` (10 000 / 1 000 000 / 5 000 000 leídas); `f17-quorum.log` (matriz y lectura vieja 700);
`f17-snapshots.log` (875,44 MiB tras `TRUNCATE`); `f17-anillo-arranque.log` (207 s, 1,22/1,16/1,14 GiB);
`f17-diagrama.svg` (el Mermaid dibujado con `mmdc` 12.0.0).

## 8. 📂 Salidas

`salidas/anillo-sondeo.log` (se regenera corriendo el script) y el inventario previo.

## 9. 🧹 Limpieza

El script termina con `docker compose down -v`. Comprobación contra el inventario:

```bash
diff <(docker ps -aq --no-trunc) salidas/contenedores-antes.txt
diff <(docker volume ls -q) salidas/volumenes-antes.txt
diff <(docker network ls -q) salidas/redes-antes.txt
```

El 10/10/2026 los tres salieron iguales.

**F22** deja el proyecto `condor-replica` (primario y réplica, con sus volúmenes y tres redes) detenido; se borra con
`docker compose -f lab/compose.replica.yaml down -v` desde `src/`. `newsql-global` no tiene volumen.

## 10. 🚫 Qué se dejó fuera

Nada: no hay binarios ni dependencias propias.
