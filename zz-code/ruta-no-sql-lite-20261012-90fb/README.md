# 🧪 ruta-no-sql-lite-20261012-90fb · cómo correr estas pruebas

> **Curso:** ruta-no-sql-lite · **Tanda:** T6 · **Creado:** 2026-10-12
> **Propósito:** comprobaciones de reconstrucción del capstone (F23), las costuras de F24, la factura de F25 y la solución privada del boss V
> Se llena **mientras se prueba**: cada script nuevo entra aquí en la misma sesión. Las reglas, en
> `zz-code/README.md` § "El README de cada directorio". Si una sección no aplica, se dice por qué.

## 1. 🎯 Qué se prueba y para qué

- **F23**: el código del lector vive en `cursos-bd/ruta-no-sql-lite/src/23-poliglota-el-diseno/` (regla D-09):
  `inventory.ts`, `rebuild_duckdb.py`, `rebuild-couch.ts` y `readings.ts`. Alimentan M-72–M-75 de la bitácora del curso
  y la sección 6.4 de la fase: si cada motor que entra se rearma desde su fuente, y cuánto del inventario de piezas se
  proyecta desde las órdenes.
- **F24**: el código del lector vive en `src/24-poliglota-la-costura/` (`setup`, `relay`, `watch`, `run`, `race`,
  `rebuild`, `back`, más `common.ts`), con `src/lab/compose.costura.yaml` y `src/lab/generator/src/diverge.ts`. Alimentan
  M-76–M-80: la ventana de tres costuras con y sin CouchDB caído, la carrera de dos procesos, la reconstrucción del
  millón y la vuelta desde la tableta.
- **F25**: `src/25-poliglota-la-factura/factura.ts` (M-81) y `boss/setup.ts`. **Aquí**, privado: `boss-v/` con
  `reconcile.ts`, `seam.ts` y `solucion-privada.md` (no se publica, D-05); `boss-v/node_modules` es un enlace simbólico
  a los del curso, no una instalación.
- **Aquí**: `f23-proyeccion-por-cierre.sql` y `f23-proyeccion-por-apertura.sql`, la misma proyección con los dos
  órdenes posibles de los movimientos (el error de la sección 9 de la fase), y los logs de todo en `salidas/`.

## 2. 🛠️ Prerrequisitos

- Docker Desktop 29.8.0 en macOS arm64, VM con 7,75 GiB; Node 24.21.0; `uv` con Python 3.13 y `duckdb==1.5.6`.
- El laboratorio `condor-lab` con lo que dejaron las fases anteriores: `workOrder-1m` en la base `postgres` y
  `workOrder-10k` en `expediente` (perfil `base`); `analitico` y `src/lab/data/analitico/condor.duckdb` (F07);
  `work_order_1m` (F20) y `work_order` (F19) en CouchDB (perfil `offline`); `reading` en TimescaleDB (F09, perfil
  `series`).

## 3. 🧭 Reglas antes de correr

```bash
mkdir -p salidas
docker ps -aq --no-trunc > salidas/contenedores-antes.txt
docker volume ls -q > salidas/volumenes-antes.txt
docker network ls -q > salidas/redes-antes.txt
```

No se crea ningún contenedor ni volumen: se usan los del proyecto `condor-lab`, con los puertos desplazados de `a02`. No
se instala nada (DuckDB no tiene la extensión de Postgres; el rearmado va por `COPY … TO STDOUT`).

## 4. ▶️ Cómo se corre

Desde `cursos-bd/ruta-no-sql-lite/src/`, con `Z=../../../zz-code/ruta-no-sql-lite-20261012-90fb`:

```bash
cd lab && docker compose --profile base --profile offline --profile series up -d --wait && cd ..
node 23-poliglota-el-diseno/inventory.ts                                                  > $Z/salidas/f23-inventory-1m.log
node 23-poliglota-el-diseno/inventory.ts --db expediente --dataset lab/data/workOrder-10k > $Z/salidas/f23-inventory-10k.log
uv run python 23-poliglota-el-diseno/rebuild_duckdb.py                                    > $Z/salidas/f23-rebuild-duckdb.log
node 23-poliglota-el-diseno/rebuild-couch.ts --db expediente --couch work_order           > $Z/salidas/f23-rebuild-couch-10k.log
node 23-poliglota-el-diseno/rebuild-couch.ts                                              > $Z/salidas/f23-rebuild-couch-1m.log   # ~150 s
node 23-poliglota-el-diseno/readings.ts                                                   > $Z/salidas/f23-readings.log
for v in cierre apertura; do
  docker compose -f lab/compose.yaml exec -T base psql -U postgres -d postgres < $Z/f23-proyeccion-por-$v.sql > $Z/salidas/f23-proyeccion-por-$v.log
done
```

F24, con `base` y `offline` levantados con `lab/compose.costura.yaml` sumado (y `series` detenido):

```bash
for m in dual outbox cdc; do
  node 24-poliglota-la-costura/run.ts --mode $m                  > $Z/salidas/f24-run-$m.log         # ~75 s cada una
  node 24-poliglota-la-costura/run.ts --mode $m --outage 20:30   > $Z/salidas/f24-run-$m-caida.log
  node 24-poliglota-la-costura/race.ts --mode $m 2>&1 | grep -v "^base" > $Z/salidas/f24-race-$m.log   # dual ~2 min
done
node 24-poliglota-la-costura/rebuild.ts                                       > $Z/salidas/f24-rebuild-1m.log   # 132 s
node 23-poliglota-el-diseno/rebuild-couch.ts --couch work_order_1m_v2         > $Z/salidas/f24-rebuild-1m-compare.log
node 24-poliglota-la-costura/back.ts                                          > $Z/salidas/f24-back.log
node 24-poliglota-la-costura/setup.ts --drop      # y DROP DATABASE costura_vuelta; DELETE de costura y work_order_1m_v2 en CouchDB
```

E-81 y E-83 se provocaron a propósito: `base` levantado con el compose de siempre con el slot vivo, y `setup.ts` sin el
override. `diverge.ts`, desde `src/lab/generator/`: `node src/diverge.ts | tail -1`, dos veces, el mismo hash.

F25, con `base`, `documental`, `offline` y `series` arriba:

```bash
node 25-poliglota-la-factura/boss/setup.ts
node 25-poliglota-la-factura/factura.ts > $Z/salidas/f25-factura.log 2>&1     # ~20 min: pg_dump 253 s, pg_restore 768 s
cd $Z/boss-v && node reconcile.ts --src ../../../cursos-bd/ruta-no-sql-lite/src > ../salidas/f25-boss-v-reconcile.log
node seam.ts > ../salidas/f25-boss-v-seam.log
```

`f25-factura-j4-falla.log` es la primera corrida, con `pg_restore -j 4` también para los índices (E-35). La primera
versión de `seam.ts` escribió en `camilo.component` y su limpieza falló (`pg` no acepta varias sentencias con
parámetros): se repuso `expediente` a mano (trigger, tabla y −1 hora a las 2000 piezas, comprobado contra el dataset)
y se recargó Camilo con `boss/setup.ts`.

El diagrama de F23, desde la raíz del curso: el bloque `mermaid` de la sección 6.6 a `salidas/f23-diagrama.mmd` y
`mmdc -i salidas/f23-diagrama.mmd -o salidas/f23-diagrama.png -s 2` (mmdc 12.0.0). El de F24, igual, desde la sección
6.1 a `salidas/f24-diagrama.mmd`.

## 5. 📏 Cómo se mide

No hay tiempos publicados: se compara igualdad. `inventory.ts` proyecta con `DISTINCT ON` el último movimiento por
apertura de la orden y clasifica cada pieza; `rebuild-couch.ts` recorre Postgres con un cursor en páginas de 10 000 y
pide a CouchDB las mismas claves (`POST _all_docs`; hasta F24 pedía por rango y contaba ausentes de más si faltaban
documentos: los logs `f23-rebuild-couch-*` son de la versión corregida, con los mismos resultados), y compara campo por campo con las piezas ordenadas por número de
serie; `rebuild_duckdb.py` compara la huella de cada tabla y el resultado de `cost_per_hour.sql`; `readings.ts`
compara la huella por aeronave. Una corrida de cada uno.

## 6. 🧮 Los intermedios que amasan la salida

Ninguno: las cifras de M-72–M-75 se leen tal cual de los logs. Las sumas de la fase (135 557 sin hecho, 78 743 con
rastro en `answers.json`, 329 144 piezas movidas, 41 %) son aritmética sobre el resumen de `f23-inventory-1m.log`:
59 829 + 56 814 + 18 913 + 1; 59 829 + 18 913 + 1; 740 741 − 411 597; 135 557 / 329 144. Las 1049 instaladas que
aparecen retiradas por cierre son 994 + 55 de `f23-proyeccion-por-cierre.log`.

## 7. ✅ Qué se espera ver

**12/10/2026:** inventario 1 M: reconstruible 193 587 (26,1 %), saldo inicial 411 597, intercambio 59 829, regreso del
taller 56 814, sustituto 18 913, el actuador de marzo 1; 10 k: 26,1 % y 55,4 %. DuckDB: tres tablas idénticas y 15
filas del costo por hora, 0 distintas, rearmado en 6,5 s. CouchDB: 1 000 000 de 1 000 000 iguales en 149 s; en
`work_order`, 9996 iguales y 4 distintas (las órdenes de Freddy de F19). TimescaleDB: 17 de 17 aeronaves. Por cierre,
4093 piezas desguazadas aparecen instaladas.

F24 (ventana con el reloj de la máquina: del `COMMIT` en `run.ts` a la primera aparición en `_changes` en `watch.ts`): sin
caída, p50/p99 de 5/14, 14/82 y 21/55 ms (doble escritura a 167/s; las otras a 200/s); con caída, 6761 perdidas en la
doble escritura (6762 errores contados), 0 en *outbox* (pico 6299 filas) y CDC (pico 8,7 MiB), al día en 9,9 s; carrera:
115 de 500, 0 y 0; reconstrucción: 1 000 000 en 132 s (7549/s, 582 MiB), comparada en 169 s; vuelta: 4 informes, 0 y 0
en la segunda y tercera pasada; 19, 18 y 7 hechos. `diverge.ts`: `59cf902287e9a729…`, 1794 discrepancias, todas listadas.

F25: `pg_dump` 253 s → 1890 MiB; `pg_restore` 768 s (datos 53, índices 715), mismas filas; TimescaleDB rearmado en
52 s; Mongo 0,1 / 0,4 s, 326 KiB; imágenes 620, 1344, 460 y 1195 MiB. Boss V: 1794 de 1794 clasificadas; costura por
trigger p50 18 ms, p99 108 ms.

## 8. 📂 Salidas

Los logs de la sección 4 y los diagramas (`f23-diagrama.*` y `f24-diagrama.*`). F24 deja `src/lab/data/camilo-10k/`
(ignorado, se regenera con `diverge.ts`). `rebuild_duckdb.py` deja además
`src/lab/data/analitico/condor-rebuilt.duckdb`, ignorado por git, que se puede borrar sin perder nada.

## 9. 🧹 Limpieza

```bash
(cd ../cursos-bd/ruta-no-sql-lite/src/lab && docker compose --profile base --profile offline --profile series stop)
diff <(docker ps -aq --no-trunc) salidas/contenedores-antes.txt
diff <(docker volume ls -q) salidas/volumenes-antes.txt
diff <(docker network ls -q) salidas/redes-antes.txt
```

El 12/10/2026, volúmenes y redes salieron iguales; contenedores, uno más: `condor-lab-series-1`, el servicio
`series` del laboratorio, que no tenía contenedor (su volumen sí) y lo creó el `up`. Queda detenido como los demás.
Al cerrar F24, `base` volvió al compose de siempre (`wal_level=replica`, sin slots) antes de detenerse. Cambiar el
comando de `base` hace que compose **recree** su contenedor: `condor-lab-base-1` tiene otro ID, con el mismo volumen. El
resto de las diferencias del `diff` general son de proyectos ajenos (`alameda-lab`, `fgapp-*`) que cambiaron durante
la tarde y que esta sesión no tocó; filtrado por `com.docker.compose.project=condor-lab`, volúmenes y red iguales. En F25 el `up` creó `condor-lab-documental-1`, que no tenía contenedor (su volumen sí, con los datos de F03–F04 y
ahora la base `camilo`); queda detenido como los demás.

## 10. 🚫 Qué se dejó fuera

Nada: no hay binarios ni dependencias propias.
