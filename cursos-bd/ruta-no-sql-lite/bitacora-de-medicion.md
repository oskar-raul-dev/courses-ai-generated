# 📓 Bitácora de medición

> **Curso:** Ruta NoSQL Lite · documento vivo
> **Qué es:** todas las mediciones publicadas del curso, en orden de ejecución, con los cinco datos
> de toda medición —qué se midió, volumen con su hash, motor y digest, máquina si hay tiempos, y el
> comando exacto— (la ficha de [`a04`](a04-el-arnes-de-medida.md)). No hay un archivo de latencias,
> porque este curso **mide la forma y no la velocidad**; la única latencia reportada como tal es la ventana de
> inconsistencia de la [Fase 24](24-poliglota-la-costura.md) (M-76, M-77), y se declara en [`a04`](a04-el-arnes-de-medida.md).
> **Estado:** completa el 12/10/2026: 81 mediciones (M-01 a M-81), de las 25 fases, y las once apuestas del curso
> en [su tabla](#-las-apuestas): seis ganadas (1, 2, 7, 9, 10 y 11), tres perdidas (4, 6 y 8) y dos a medias (3 y 5).

---

## 🖥️ Máquina de referencia

Apple M1 Pro, 8 núcleos, 32 GB de RAM, SSD, macOS 26.7 · Docker Desktop 29.8.0, VM con kernel
`7.0.12-linuxkit` y **7,75 GiB** asignados · Node 24.21.0 · Python 3.13.4.

> ⚠️ **Los tiempos de esta bitácora solo valen en esta máquina**, y ni siquiera ahí son
> argumento: son contexto. Lo que se compara entre máquinas es la forma —viajes, examinados
> contra devueltos, particiones tocadas, fan-out, amplificación—, que no depende del hardware.
> **Los datasets** son los de [`a05`](a05-el-dominio-de-flota.md), identificados por su
> `datasetSha256`.

---

## 🗂️ Índice por familia

| Familia | Fases | Entradas |
|---|---|---|
| línea base y arnés | F01 | [M-01](#m-01--órdenes-de-una-aeronave-en-un-trimestre-con-sus-movimientos) |
| documental | F03–F04 | [M-02](#m-02--la-ficha-completa-de-una-aeronave-de-cuatro-maneras) · [M-03](#m-03--lo-que-lookup-examina-por-dentro) · [M-04](#m-04--mongo-contra-jsonb-la-ficha-y-la-consulta-polimórfica) · [M-05](#m-05--el-punto-de-rotura-de-la-ficha-embebida) · [M-06](#m-06--conflictos-y-espacio-la-misma-información-en-los-dos-motores) |
| clave-valor | F05–F06 | [M-07](#m-07--sesiones-el-índice-escrito-a-mano-y-lo-que-deja-atrás-el-ttl) · [M-08](#m-08--valkey-como-almacén-primario-ante-un-sigkill) · [M-09](#m-09--la-sesión-en-valkey-y-en-una-tabla-unlogged) · [M-10](#m-10--la-memoria-llena-y-la-persistencia) |
| analítico embebido | F07–F08 | [M-15](#m-15--el-costo-por-hora-volada-el-mismo-sql-en-los-dos-motores) · [M-16](#m-16--tres-columnas-sobre-50-millones) · [M-17](#m-17--cuatro-escritores-sobre-duckdb) · [M-18](#m-18--una-métrica-nueva-sobre-50-millones) · [M-19](#m-19--volcar-a-disco) · [M-20](#m-20--el-segundo-proceso) |
| series temporales | F09–F10 | [M-21](#m-21--leer-por-tiempo) · [M-22](#m-22--el-roll-up-diario-y-lo-que-cuesta-mantenerlo) · [M-23](#m-23--borrar-el-primer-año) · [M-24](#m-24--corregir-la-historia-comprimida) · [M-25](#m-25--la-tarjeta-timescale-contra-postgres-particionado) · [M-26](#m-26--tamaño-por-año-y-backfill) · [M-27](#m-27--la-cardinalidad-y-los-chunks-diminutos) |
| búsqueda | F11–F12 | [M-28](#m-28--las-búsquedas-de-sandra) · [M-29](#m-29--facetas-una-petición-contra-cuatro-consultas) · [M-30](#m-30--el-buscador-como-fuente-de-verdad) · [M-31](#m-31--la-batería-de-la-apuesta) · [M-32](#m-32--facetas-reconstrucción-y-visibilidad) · [M-33](#m-33--el-disco-lleno) |
| grafos | F13–F14 | [M-34](#m-34--la-directiva-con-saltos-conocidos) · [M-35](#m-35--la-estadía-derivada-o-guardada) · [M-36](#m-36--el-grafo-genérico-y-el-producto-cartesiano) · [M-37](#m-37--la-escalera-de-saltos) · [M-38](#m-38--el-camino-más-corto-devuelto) · [M-39](#m-39--caminos-sin-límite) · [M-40](#m-40--la-travesía-con-menos-caché) |
| vectorial | F15–F16 | [M-11](#m-11--like-contra-vectores-y-la-búsqueda-exacta-hecha-por-parecido) · [M-12](#m-12--qdrant-contra-pgvector-sobre-el-mismo-millón) · [M-13](#m-13--el-parecido-con-filtro) · [M-14](#m-14--el-índice-que-no-cabe) |
| columnar ancha | F17–F18 | [M-41](#m-41--tres-preguntas-tres-tablas-y-postgres-particionado) · [M-42](#m-42--el-backfill-de-una-consulta-nueva) · [M-43](#m-43--lotes-con-y-sin-registro) · [M-44](#m-44--quórum-y-la-lectura-vieja-en-un-anillo-de-tres) · [M-45](#m-45--la-entidad-con-allow-filtering-en-tres-volúmenes) · [M-46](#m-46--cargar-50-m-los-bytes-que-llegan-al-disco) · [M-47](#m-47--la-tarjeta-cassandra-contra-postgres-particionado-bien-jugado) · [M-48](#m-48--el-hot-spot-de-la-partición-por-mes) · [M-49](#m-49--stcs-contra-twcs) · [M-50](#m-50--borrar-tombstones-y-tuplas-muertas) · [M-51](#m-51--allow-filtering-hasta-que-deja-de-contestar) · [M-52](#m-52--la-partición-sin-cota) |
| offline-first | F19–F20 | [M-53](#m-53--la-tableta-contra-el-servidor-lo-que-viaja) · [M-54](#m-54--el-viaje-de-freddy-cinco-maneras-de-terminarlo) · [M-55](#m-55--el-mismo-viaje-contra-postgres-como-servidor) · [M-56](#m-56--la-apuesta-cien-órdenes-tres-días) · [M-57](#m-57--el-historial-de-revisiones-de-una-orden) · [M-58](#m-58--el-conflicto-masivo-y-la-compactación) · [M-59](#m-59--la-primera-bajada-de-la-tableta-filtro-por-filtro) · [M-60](#m-60--la-sincronización-que-no-converge) |
| NewSQL | F21–F22 | [M-61](#m-61--el-mismo-esquema-y-las-mismas-sentencias-en-postgres-y-en-cockroachdb) · [M-62](#m-62--una-posición-una-pieza-cuatro-aislamientos) · [M-63](#m-63--dónde-viven-las-filas-del-operador-estatal) · [M-64](#m-64--qué-regiones-toca-cada-trabajo-del-expediente) · [M-65](#m-65--el-reinicio-por-incertidumbre-del-reloj) · [M-66](#m-66--la-física-del-demo-y-los-tres-trabajos-en-milisegundos) · [M-67](#m-67--la-apuesta-postgres-con-réplica-contra-cockroachdb) · [M-68](#m-68--el-enlace-cortado-lo-que-lee-la-réplica) · [M-69](#m-69--la-misma-fila-desde-tres-países) · [M-70](#m-70--la-misma-suma-en-postgres-sin-geografía) · [M-71](#m-71--las-horas-partidas-por-región) |
| políglota | F23–F25 | [M-72](#m-72--el-inventario-de-piezas-proyectado-desde-las-órdenes) · [M-73](#m-73--el-tablero-rearmado-desde-postgres) · [M-74](#m-74--el-servidor-de-las-tabletas-rearmado-desde-postgres) · [M-75](#m-75--las-lecturas-de-la-flota-contra-la-descarga) · [M-76](#m-76--la-ventana-de-inconsistencia-de-tres-costuras) · [M-77](#m-77--las-tres-costuras-con-couchdb-caído-30-s) · [M-78](#m-78--dos-procesos-la-misma-orden) · [M-79](#m-79--la-reconstrucción-completa-del-servidor-de-las-tabletas) · [M-80](#m-80--la-vuelta-de-las-cuatro-órdenes-de-freddy) · [M-81](#m-81--la-factura-respaldar-la-fuente-y-rearmar-los-derivados) |

---

## 📐 Mediciones

Las entradas llevan ID `M-NN` y van en orden de ejecución.

### M-01 — Órdenes de una aeronave en un trimestre, con sus movimientos

- **Fecha de ejecución:** 29/09/2026 · **Fase:** [01](01-el-dominio-de-flota-y-el-arnes.md) ·
  **Volumen:** `workOrder-1m` (`datasetSha256` `11a67c65fb22fdc9…`, generador 1.0.0)
- **Motor:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…`, esquema de referencia de la
  Fase 01; aeronave `HK-12372`, del 01/01/2025 al 01/04/2025

| | filas examinadas | devueltas | viajes |
|---|---|---|---|
| sin índices secundarios | 1 000 081 | 122 | 1 |
| con los índices de referencia | 145 | 122 | 1 |
| con índices, en N+1 | — | 122 | 66 |

Reproducir: `node 01-el-dominio-de-flota-y-el-arnes/reference-query.ts --dataset lab/data/workOrder-1m`
(desde `src/`). Verificado tres veces, dos con la base cargada desde cero: las filas y los viajes,
idénticos; los bloques sin índices, 23 937 y 23 938, que por eso no entran en la tabla.

**Interpretación:** es la calibración del instrumento, no una comparación. El índice compuesto
`(aircraft, opened_at)` baja el cociente examinadas/devueltas de 8197 a 1,2, y el N+1 multiplica por
66 los viajes sin que ninguna de sus consultas tenga un plan malo.

### M-02 — La ficha completa de una aeronave, de cuatro maneras

- **Fecha de ejecución:** 29/09/2026 · **Fase:** [03](03-documental-levantar-y-modelar.md) · **Volumen:** `part-1m`
  (`datasetSha256` `b0b7988921428c1f…`, generador 1.0.0)
- **Motor:** MongoDB 8.0.20 `mongo@sha256:098862b1339f…`; aeronave `HC-10265`, 22 piezas instaladas

| Forma | Viajes | Documentos examinados |
|---|---|---|
| embebida (`condor_doc`) | 1 | 1 |
| referenciada, N+1 | 25 | 50 |
| referenciada, con `$in` | 4 | 50 |
| referenciada, con `$lookup` | 1 | — |

Reproducir: `node 03-documental-levantar-y-modelar/measure.ts --dataset lab/data/part-1m`.

**Interpretación:** la unidad de lectura decide los viajes; los 25 no son del modelo relacional sino de
armar la ficha desde la aplicación.

### M-03 — Lo que `$lookup` examina por dentro

- **Fecha de ejecución:** 29/09/2026 · **Fase:** [03](03-documental-levantar-y-modelar.md) · **Volumen:** `part-1m`
  (`datasetSha256` `b0b7988921428c1f…`, generador 1.0.0)
- **Motor:** MongoDB 8.0.20; la etapa `$lookup` de piezas de la ficha de `HC-10265`

| `part.aircraft` | Documentos examinados | Recorridos completos |
|---|---|---|
| con índice | 22 | 0 |
| sin índice | 1 000 000 | 1 |

Reproducir: el mismo comando que M-02.

**Interpretación:** `$lookup` es un bucle anidado por documento de entrada; sin índice en el campo ajeno,
cada ficha recorre la colección entera.

### M-04 — Mongo contra JSONB: la ficha y la consulta polimórfica

- **Fecha de ejecución:** 29/09/2026 · **Fase:** [04](04-documental-romper-y-medir.md) · **Volumen:** `part-1m`
  (`datasetSha256` `b0b7988921428c1f…`, generador 1.0.0)
- **Motor:** MongoDB 8.0.20 · **Línea base:** PostgreSQL 18.6 con el esquema de referencia y un GIN
  `jsonb_path_ops` sobre `part.details`

| Consulta | Mongo | Postgres |
|---|---|---|
| Q1 ficha de `HC-10265` | 1 documento, 1 viaje | 50 filas, 1 viaje |
| Q2 `details.tboHours = 6000` | 27 865 docs (índice del campo) | 27 865 filas |
| Q3 `details.retreadCount = 3` | 1 000 000 sin índice nuevo · 28 127 con comodín | 28 127 filas (el mismo GIN) |
| índices para `details` | 4228 kB por clave · 11 364 kB el comodín | 5152 kB el GIN |

Reproducir: `node 04-documental-romper-y-medir/measure.ts --dataset lab/data/part-1m --only apuesta`.

**Interpretación:** en la consulta polimórfica, degradación de 1,00×: la apuesta se ganó. La ventaja de
Mongo medida es la unidad de lectura (1 contra 50), no el polimorfismo.

### M-05 — El punto de rotura de la ficha embebida

- **Fecha de ejecución:** 29/09/2026 · **Fase:** [04](04-documental-romper-y-medir.md) · **Volumen:** `part-1m`
  (`datasetSha256` `b0b7988921428c1f…`, generador 1.0.0)
- **Motor:** MongoDB 8.0.20; lecturas de vuelo de unos 175 bytes embebidas en una ficha

| Lecturas embebidas | Tamaño del documento | Resultado |
|---|---|---|
| 90 344 | 16 777 036 bytes | acepta |
| 90 345 | — | `Resulting document after update is larger than 16777216` (code 10334) |

Reproducir: `node 04-documental-romper-y-medir/measure.ts --dataset lab/data/part-1m --only rotura`.

**Interpretación:** con una lectura por minuto, una aeronave llena su ficha en unas 1500 horas de vuelo.
El límite no se configura: la salida es de modelo.

### M-06 — Conflictos y espacio: la misma información en los dos motores

- **Fecha de ejecución:** 29/09/2026 · **Fase:** [04](04-documental-romper-y-medir.md) · **Volumen:** `part-1m`
  (`datasetSha256` `b0b7988921428c1f…`, generador 1.0.0)
- **Motor:** MongoDB 8.0.20 · **Línea base:** PostgreSQL 18.6

| | Mongo | Postgres |
|---|---|---|
| dos transacciones, piezas distintas de la misma aeronave | `WriteConflict` (ficha embebida) | sin espera |
| dos transacciones, la misma pieza | — | espera (lock) |
| viajes de una transacción que mueve una pieza | 3 (2 `update` + `commitTransaction`) | — |
| 1 000 000 de piezas en disco | 83 MB (326 MB sin comprimir) + 48 MB de índices | 159 MB + 42 MB de índices |

Reproducir: `node 04-documental-romper-y-medir/extra.ts` y `measure.ts --only transacciones`.

**Interpretación:** la granularidad del conflicto la decide el modelo, no el motor. En espacio, la
compresión de WiredTiger deja a Mongo en la mitad.

### M-07 — Sesiones, el índice escrito a mano y lo que deja atrás el TTL

- **Fecha de ejecución:** 29/09/2026 · **Fase:** [05](05-clave-valor-levantar-y-modelar.md) · **Volumen:**
  `workOrder-1m` (`datasetSha256` `11a67c65fb22…`, generador 1.0.0), 100 000 sesiones sobre sus 908
  técnicos
- **Motor:** Valkey 9.1.2 `valkey/valkey@sha256:418652cfb58e…`, instancia limpia (`FLUSHALL SYNC` y
  `MEMORY PURGE`) antes de medir

| | Valor |
|---|---|
| viajes para cargar 100 000 sesiones (hash + TTL + `SADD` al índice, pipelines de 1000) | 100 |
| memoria por sesión, con su entrada en el índice | 206 bytes |
| sesiones de `T-002` sin índice: `SCAN` de 100 000 claves | 202 viajes → 111 |
| sesiones de `T-002` con el set a mano | 2 viajes → 111 |
| el set tras vencer 1000 sesiones por TTL | 1000 miembros, 0 existen |
| 100 lecturas: una a una · pipeline · `Promise.all` · autopipelining | 100 · 1 · 100 · 1 escrituras al socket |
| cola y registro de las 16 440 órdenes del último mes | ~112 bytes por orden (112 y 113 en dos corridas) |

Reproducir: `node 05-clave-valor-levantar-y-modelar/model.ts --dataset lab/data/workOrder-1m` y
`trips.ts` (desde `src/`).

**Interpretación:** sin la clave, cada pregunta es un recorrido de la instancia entera; con la segunda
estructura baja a 2 viajes, pero esa estructura no la mantiene nadie más que tu código, y el TTL no
pasa por tu código.

### M-08 — Valkey como almacén primario, ante un `SIGKILL`

- **Fecha de ejecución:** 29/09/2026 · **Fase:** [05](05-clave-valor-levantar-y-modelar.md) · **Volumen:**
  `workOrder-1m` (`datasetSha256` `11a67c65fb22…`)
- **Motor:** Valkey 9.1.2, configuración por defecto de la imagen: `save "3600 1 300 100 60 10000"`,
  `appendonly no`

| | Sobreviven |
|---|---|
| 1 000 000 de órdenes como hash (170,9 MB, cargadas en 6,4 s), `SIGKILL` a los 7 s | 0 de 1 000 000 |
| tras el guardado, 5000 órdenes nuevas y `SIGKILL` | 1 000 000 de 1 005 000 |

Reproducir: `node 05-clave-valor-levantar-y-modelar/primary-store.ts` (borra la instancia). `SIGKILL`
mata el proceso, no la máquina: la caída de la máquina no se midió.

**Interpretación:** con la persistencia por defecto se pierde todo lo escrito desde la última
instantánea, y el primer guardado tras una carga llega como pronto al minuto.

### M-09 — La sesión en Valkey y en una tabla `UNLOGGED`

- **Fecha de ejecución:** 29/09/2026 · **Fase:** [06](06-clave-valor-romper-y-medir.md) · **Volumen:**
  100 000 sesiones sintéticas, las mismas en los dos motores
- **Motor:** Valkey 9.1.2 · **Línea base:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…`,
  tabla `UNLOGGED` con clave primaria e índice sobre `expires_at`

| | Valkey | Postgres |
|---|---|---|
| viajes para leer una sesión | 1 | 1 |
| viajes para abrir una sesión con su vencimiento | 1 | 1 |
| bytes por sesión | 156 (RAM; 155 en otra corrida) | 116 (77 de tabla + 39 de índices, de relación) |
| vencimiento | TTL, sin consulta | `DELETE` por `Index Scan`, 1000 filas |
| tras un apagado limpio | conserva todo | conserva todo |
| tras `SIGKILL` | conserva su última instantánea: 100 000 de 101 000 | se vacía ([`a07`](a07-postgres-linea-base.md)) |
| reserva con `SET NX` / `INSERT … ON CONFLICT DO NOTHING` | 1 viaje, quien pierde recibe `null` | 1 viaje, quien pierde recibe 0 filas |
| candado `SET NX PX` / `pg_try_advisory_lock` | vence por TTL | se suelta al caer la conexión |

Reproducir: `node 06-clave-valor-romper-y-medir/measure.ts --only apuesta` y `extra.ts` (desde `src/`).
Una primera versión del script dio 91 bytes por sesión en Valkey, sin limpiar la instancia antes de
medir; no se publica.

**Interpretación:** en forma empatan, y en bytes gana Postgres, con la salvedad de que se comparan bytes
de RAM contra bytes de relación. Lo que los separa es el vencimiento sin proceso aparte y qué pierde
cada uno ante una caída, donde la `UNLOGGED` pierde más.

### M-10 — La memoria llena y la persistencia

- **Fecha de ejecución:** 29/09/2026 · **Fase:** [06](06-clave-valor-romper-y-medir.md) · **Volumen:**
  sesiones sintéticas
- **Motor:** Valkey 9.1.2 con `maxmemory 16mb`; persistencia, cada configuración en su propio contenedor

| | Resultado |
|---|---|
| `noeviction` | la escritura falla en torno a la sesión 100 000: `OOM command not allowed when used memory > 'maxmemory'.` |
| `allkeys-lru`, 200 000 sesiones escritas | quedan 99 814 claves (100 342 en otra corrida) · `evicted_keys` 100 187 · la reserva sin TTL desaparece · ningún error |
| `volatile-lru` | quedan 99 648 claves · la reserva sin TTL sobrevive · ningún error |
| RDB por defecto, 50 000 escritas y `SIGKILL` | sobreviven 0 |
| AOF `everysec`, lo mismo | sobreviven 50 000 |
| AOF `always`, lo mismo | sobreviven 50 000 |

Reproducir: `node 06-clave-valor-romper-y-medir/measure.ts --only memoria,persistencia`. El `SIGKILL`
no distingue `everysec` de `always`: esa diferencia solo aparece si cae la máquina, y no se midió.

**Interpretación:** la rotura con error es la buena; la de `allkeys-lru` borra la mitad de la instancia
sin avisar. Con AOF, la caída del proceso no pierde nada.

### M-11 — `LIKE` contra vectores, y la búsqueda exacta hecha por parecido

- **Fecha de ejecución:** 30/09/2026 · **Fase:** [15](15-vectorial-levantar-y-modelar.md) · **Volumen:**
  `pirep-10k` (`datasetSha256` `75d3b6802f56…`, generador 1.0.0), 1258 reportes de `gear-metallic-noise`
- **Motor:** Qdrant 1.19.1 `qdrant/qdrant@sha256:12364fe851b9…`, e5-small `614241f6…`, coseno ·
  **Línea base:** PostgreSQL 18.6 (`ILIKE` e índice B-tree)

| Forma | Devuelve | Del tipo correcto | Encuentra de los 1258 |
|---|---|---|---|
| `ILIKE '%ruido metalico al bajar tren%'` | 19 | 19 | 1,5 % |
| `ILIKE '%tren%'` | 1901 | 931 | 74,0 % |
| vectores, los 100 más parecidos | 100 | 100 | 7,9 % |
| vectores, los 1258 más parecidos | 1258 | 728 | 57,9 % |
| *"receta de arepas"* | `ILIKE` 0 · vectores 10 | — | — |
| reportes de `HC-1499` por parecido, los 186 primeros | 186 | 4 de esa aeronave | — |
| lo mismo con filtro de payload, o con el B-tree de Postgres | 186 | 186 | — |
| recall@10 del índice, `pirep_hnsw` forzado, `ef` 4 · 10 · 32 · 128 | — | 0,983 · 0,983 · 1,000 · 1,000 | — |

Reproducir: `node 15-vectorial-levantar-y-modelar/compare.ts` y `search.ts --collection pirep_hnsw`
(desde `src/`). Con 10 000 puntos, la colección por defecto tiene **0 vectores en HNSW**: están por debajo
de `indexing_threshold`.

**Interpretación:** el vector ordena, no separa: impecable arriba, 728 de 1258 si se le pide el tipo
entero, y siempre devuelve algo. Para lo exacto —una matrícula—, 4 de 186.

### M-12 — Qdrant contra `pgvector` sobre el mismo millón

- **Fecha de ejecución:** 30/09/2026 · **Fase:** [16](16-vectorial-romper-y-medir.md) · **Volumen:**
  `pirep-1m` (`datasetSha256` `d8a956d0c85a…`), vectores `pirep-e5-passage.f32` (`3a97c8b28f60…`),
  los mismos bytes en los dos
- **Motor:** Qdrant 1.19.1 · **Línea base:** PostgreSQL 18.6 con pgvector 0.8.6; HNSW m 16,
  `ef_construction` 100 en los dos

| `ef` | Qdrant | `pgvector` | páginas por consulta en Postgres |
|---|---|---|---|
| 10 | 0,925 | 0,901 | 357 |
| 40 | 0,985 | 0,946 | 679 |
| 80 | 0,997 | 0,984 | 1107 |
| 160 | 0,997 | 0,999 | 1809 |
| 320 | 1,000 | 1,000 | 2995 |

Recall@10 del índice contra la búsqueda exacta (que coincide en los dos motores), 100 consultas, con la
regla de empates de [`a04`](a04-el-arnes-de-medida.md). Embeber el millón: 1662 s en CPU. Construir:
Qdrant 628–715 s con la carga (dos cargas); `pgvector` 299 s con `maintenance_work_mem` de 2 GB. En disco: Qdrant
1998 MiB; Postgres 1563 MiB de tabla más 1680 MiB de índice. Memoria del cgroup con los dos cargados:
1978 y 3436 MiB (`docker stats`: 411 y 249). Prefijos, 500 consultas, búsqueda exacta, acierto de tipo:
99,86 % con `query:`/`passage:`, 99,94 % sin prefijo en la consulta, 99,98 % sin prefijos.

Reproducir: `node 16-vectorial-romper-y-medir/measure.ts --only apuesta,prefijos,memoria`.

**Interpretación:** sin filtro, empatan desde `ef` 80; con `ef` bajo, Qdrant acierta más (probablemente
por sus 4 segmentos, no medido). Postgres guarda los vectores dos veces. La métrica de prefijos está
saturada en este corpus.

### M-13 — El parecido con filtro

- **Fecha de ejecución:** 30/09/2026 · **Fase:** [16](16-vectorial-romper-y-medir.md) · **Volumen:** el de M-12
- **Motor:** Qdrant 1.19.1 · **Línea base:** pgvector 0.8.6

| Filtro | Qdrant | `pgvector` |
|---|---|---|
| `aircraft = HK-9326` (285 filas, con B-tree) | 1,000 | 1,000 (el planificador ordena exacto las 285) |
| `ata_chapter = 22` (83 500 filas), por defecto | 0,995 | **0,100**, 1 fila de media |
| lo mismo, `iterative_scan = relaxed_order` | — | 0,510 |
| lo mismo, `strict_order` | — | 0,260 |
| lo mismo, B-tree y camino exacto forzado | — | 1,000, examinando 83 500 filas y 70 823 páginas |

Recall@10 contra la búsqueda exacta filtrada, 20 consultas. Reproducir: `measure.ts --only filtro`.

**Interpretación:** Qdrant filtra dentro del grafo; `pgvector`, después. Con filtros de selectividad
media, `pgvector` devuelve poco o devuelve mal, y solo acierta renunciando al índice vectorial.

### M-14 — El índice que no cabe

- **Fecha de ejecución:** 30/09/2026 · **Fase:** [16](16-vectorial-romper-y-medir.md) · **Volumen:** el de M-12
- **Motor:** Qdrant 1.19.1 en un contenedor desechable, con límite de memoria · **Línea base:**
  pgvector 0.8.6

| Qdrant, recall@10 con `ef` 128 · fallos de página mayores por consulta | Sin límite | 1 GB | 512 MB | 256 MB |
|---|---|---|---|---|
| todo en RAM (de fábrica) | 0,964 · 1882 | 0,964 · 4479 | 0,964 · 5445 | OOMKilled |
| vectores e índice en disco | 1,000 · 2566 | 1,000 · 1471 | 1,000 · 2166 | OOMKilled |
| int8 en RAM | 0,907 · 92 | 0,907 · 0 | OOMKilled | — |

| `pgvector`, HNSW m 16 / 100 | Construcción | Tamaño | Aviso de `maintenance_work_mem` |
|---|---|---|---|
| float32, 2 GB | 299 s | 1680 MB | a las 966 262 tuplas |
| float32, 64 MB (de fábrica) | 2246 s | 1680 MB | a las 28 356 tuplas |
| `halfvec`, 2 GB | 181 s | 957 MB | ninguno; recall@10 0,980 · 0,992 · 0,999 con `ef` 40 · 80 · 160 |

Reproducir: `uv run python 16-vectorial-romper-y-medir/rotura.py` y `load_pgvector.py` con
`--maintenance-work-mem 64MB` y `--halfvec`. La cuantización binaria de Qdrant no terminó de cargar
(el cliente agotó su espera) y no se midió. `COPY` del millón: 157 s.

**Interpretación:** en Qdrant, el índice que no cabe se vuelve disco antes de romperse, y la
cuantización `always_ram` muere antes que los vectores en disco. En Postgres, el índice que no cabe se
paga al construir: 7,5 veces más tiempo con la memoria de fábrica.

### M-15 — El costo por hora volada: el mismo SQL en los dos motores

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [07](07-analitico-levantar-y-modelar.md) · **Volumen:**
  `reading-5m` (`datasetSha256` `8dc486dea089c12a…`, generador 1.0.0) y su ampliación ×10
- **Motor:** DuckDB 1.5.6 (Python 3.13) · **Línea base:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…`

| Comprobación | DuckDB | Postgres |
|---|---|---|
| `reading.csv` (las 5 M reales) | escrito, SHA-256 `0db9f6de9fe8…` | hash comprobado antes de `COPY` |
| huella de `reading_x10` (`fingerprint.sql`) | 50 000 000 · 170 aeronaves · 624 860 vuelos | idéntica, columna por columna |
| `cost_per_hour.sql` | 15 filas | las mismas 15 filas, al centavo |
| pivote por año | `PIVOT … ON yr` | `FILTER` por año, a mano: mismos valores |

Reproducir: `build.py`, `load_postgres.py`, y `fingerprint.sql` y `cost_per_hour.sql` en los dos
motores (desde `src/`). Tiempos de esta máquina: carga en DuckDB 2,0 s y ampliación 8,6 s; `COPY` 6,7 s y
ampliación 60,5 s en Postgres.

**Interpretación:** es la calibración de la familia: mismos datos y mismo SQL, mismo resultado. Todo lo
que difiera después es forma, no contenido.

### M-16 — Tres columnas sobre 50 millones

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [07](07-analitico-levantar-y-modelar.md) · **Volumen:**
  `reading_x10`, 50 M (ampliación sintética ×10 de `reading-5m`)
- **Motor:** DuckDB 1.5.6, 407 grupos de filas, una conexión nueva por consulta · **Línea base:**
  PostgreSQL 18.6, 568 192 páginas, 2 workers por `Gather`

| Consulta | DuckDB, leído | Postgres sin índices | Postgres con su mejor índice |
|---|---|---|---|
| diez columnas | 577,2 MiB | 4439 MiB | — |
| una columna | 101,8 MiB | 4439 MiB | 1885,9 MiB (cubriente, forzado) |
| tres columnas por aeronave | **203,2 MiB** | **4439 MiB** | 1884,5 MiB (cubriente, forzado; el planificador elige el secuencial) |
| `egt_c = -1` (no existe) | 0 filas, 0 MiB | 4439 MiB | 65 páginas, 0,5 MiB (BRIN, forzado) |
| una aeronave | 5 283 840 filas, 0,8 MiB | 4439 MiB | 1135 páginas, 8,9 MiB (cubriente, elegido) |

Reproducir: `uv run python 07-analitico-levantar-y-modelar/measure.py` y
`node 07-analitico-levantar-y-modelar/measure.ts [--indexes] [--no-seqscan]`. Índices de `indexes.sql`:
cubriente 1893 MB en 18,5 s; BRIN 200 kB y 128 kB. Con 5 M: DuckDB 59,5 · 5,5 · 14,0 MiB contra 443,9 MiB
de Postgres en todas. Contexto: la de tres columnas, 3,9 s en Postgres y 0,08–0,13 s en DuckDB.

**Interpretación:** 93 bytes por fila contra 12; para tres columnas, 21,8 veces menos lectura. El índice
cubriente reduce a la mitad lo que lee Postgres, para una sola consulta, y sigue leyendo 9,3 veces más.

### M-17 — Cuatro escritores sobre DuckDB

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [07](07-analitico-levantar-y-modelar.md) · **Volumen:**
  8000 aterrizajes sintéticos sobre 17 aeronaves (4 escritores × 2000)
- **Motor:** DuckDB 1.5.6, cuatro conexiones del mismo proceso · **Línea base:** PostgreSQL 18.6, cuatro
  conexiones

| Forma | Fallidas (3 corridas) | Minutos registrados de 8000 |
|---|---|---|
| contador con `UPDATE` en DuckDB | 272 · 403 · 382 | 7728 · 7597 · 7618 |
| `INSERT` por aterrizaje en DuckDB | 0 · 0 · 0 | 8000 |
| contador con `UPDATE` en Postgres | 0 · 0 · 0 | 8000 |

Reproducir: `uv run python 07-analitico-levantar-y-modelar/writers.py`.

**Interpretación:** sin candados de fila, el segundo escritor falla (`Conflict on update!`, E-38) y, sin
reintento, se pierde entre el 3,4 % y el 5 % de lo escrito. Insertar eventos no choca.

### M-18 — Una métrica nueva sobre 50 millones

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [08](08-analitico-romper-y-medir.md) · **Volumen:**
  `reading_x10`, 50 M (copia limpia por forma)
- **Motor:** DuckDB 1.5.6 (lo que crece el archivo tras `CHECKPOINT`) · **Línea base:** PostgreSQL 18.6
  (WAL por `pg_wal_lsn_diff` y `pg_relation_size`)

| El margen de EGT (`765 − egt_c`) | Postgres: WAL · tabla después | DuckDB: archivo |
|---|---|---|
| constante | 0,1 MiB · 4438,9 MiB | +0,8 MiB |
| columna + `UPDATE` | 13 992,4 MiB · 8877,8 MiB | +51,8 MiB |
| generada `STORED` | 5739,1 MiB · 4439,1 MiB | no existe |
| generada `VIRTUAL` | 0,0 MiB · 4439,2 MiB | error E-41 |

Reproducir: `node 08-analitico-romper-y-medir/alter.ts` y `uv run python 08-analitico-romper-y-medir/alter.py`.
DuckDB, dos corridas idénticas. Además, `cost_per_hour.sql` sobre las 5 M reales: DuckDB 23,8 MiB leídos,
Postgres 57 196 páginas (446,8 MiB) (`explain.py` y `EXPLAIN (ANALYZE, BUFFERS)`).

**Interpretación:** una métrica guardada cuesta en Postgres una versión nueva de cada fila; en DuckDB,
una columna. Una métrica calculable, Postgres 18 la añade gratis y DuckDB no puede añadirla.

### M-19 — Volcar a disco

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [08](08-analitico-romper-y-medir.md) · **Volumen:**
  `reading_x10`, 50 M
- **Motor:** DuckDB 1.5.6, 8 hilos salvo donde se dice · **Línea base:** PostgreSQL 18.6, 2 workers

| | `GROUP BY flight_id` | `ORDER BY egt_c, ts` (3 columnas) |
|---|---|---|
| DuckDB 4 GB / 512 MB / 256 MB | 0 / 0 / 0 | 0 / 921,0 / 1166,2 MiB |
| DuckDB 128 MB, 8 hilos / 1 hilo | 0 / 0 | E-42 / 1257,3 MiB |
| DuckDB 512 MB sin directorio temporal | 0 | E-43 |
| Postgres `work_mem` 4 MB / 1 GB | 3596,7 / 0 MiB | 5339,9 / 1777,3 MiB |

Reproducir: `uv run python 08-analitico-romper-y-medir/spill.py` y `node 08-analitico-romper-y-medir/spill.ts`.
Contexto: Postgres ordenó en 23,5 s con 4 MB y en 57,5 s con 1 GB; no se investigó por qué.

**Interpretación:** agrupar muchos grupos pequeños no vuelca en DuckDB ni con 128 MB; Postgres, con el
`work_mem` de fábrica, vuelca 3,5 GB. Ordenar todo vuelca en los dos, y en DuckDB el límite se reparte
entre hilos.

### M-20 — El segundo proceso

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [08](08-analitico-romper-y-medir.md) · **Volumen:** no
  aplica: un archivo con un escritor activo
- **Motor:** DuckDB 1.5.6 · **Línea base:** no aplica (Postgres atiende a cada proceso como una conexión)

| Segundo proceso | Con un escritor abierto | Sin escritor |
|---|---|---|
| para escribir | E-08, `Could not set lock on file` | — |
| solo para leer | **E-08 también** | abre y lee (dos a la vez) |

Reproducir: `uv run python 08-analitico-romper-y-medir/two_processes.py`.

**Interpretación:** el punto de rotura de la familia no tiene volumen: es el número de procesos, y con un
escritor abierto es uno.

### M-21 — Leer por tiempo

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [09](09-series-levantar-y-modelar.md) · **Volumen:**
  `reading_x10`, 50 M (ampliación ×10 de `reading-5m`, `8dc486dea089…`), huella igual a la de M-15
- **Motor:** TimescaleDB 2.30.1 sobre PostgreSQL 18.6 `timescale/timescaledb@sha256:9dede0e3ccc0…`, chunks
  de 7 días (271) · **Línea base:** PostgreSQL 18.6, tabla con índices `(aircraft, ts)` y `(ts)`

| Consulta | Timescale: examinadas · páginas · chunks | Postgres: examinadas · páginas |
|---|---|---|
| `HC-2157`, 60 días | 9666 · 218 · 10 | 9666 · 155 |
| la flota, un mes | 944 240 · 10 733 · 5 | 50 000 000 · 568 198 (elige el secuencial); con el índice de `ts` forzado, 839 270 · 11 040 |
| `HC-2157`, cinco años | 294 118 · 6482 · 261 | 294 118 · 4529 |

Reproducir: `node 09-series-levantar-y-modelar/measure.ts` y `chunk_interval.ts` (con 1 mes, sobre las 5 M:
64 chunks; 187 · 1685 · 5578 páginas contra 205 · 1075 · 6089 con 7 días). Carga: 5 M en 100 viajes por
motor (47,5 s); ×10 en 636,1 s (Timescale) y 474,3 s (Postgres).

**Interpretación:** para leer, una tabla bien indexada empata o gana; la hypertable descarta por
construcción lo que está fuera del rango, sin depender del planificador.

### M-22 — El roll-up diario y lo que cuesta mantenerlo

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [09](09-series-levantar-y-modelar.md) · **Volumen:** el de M-21
- **Motor:** agregados continuos `reading_hourly` (1 430 190 filas, 80,8 s) y `reading_daily` (287 080,
  3,2 s) · **Línea base:** vista materializada con índice (8,9 s)

| | Timescale | Postgres |
|---|---|---|
| tendencia de cinco años de `HC-2157` | 1826 filas · 263 páginas | 1826 · 28 páginas |
| refrescar tras un vuelo de 90 minutos | 2420 lecturas leídas | 50 000 090 lecturas leídas, 8,9 s |

Reproducir: `rollups.sql` y `node 09-series-levantar-y-modelar/rollups.ts` (lecturas leídas: deltas de
`seq_tup_read + idx_tup_fetch` en `pg_stat_user_tables`).

**Interpretación:** leer el resumen cuesta más en Timescale; mantenerlo, cuatro órdenes de magnitud menos.

### M-23 — Borrar el primer año

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [09](09-series-levantar-y-modelar.md) · **Volumen:** el
  de M-21, corte en el 01/10/2022 (8 823 630 lecturas antes del corte)
- **Motor:** `drop_chunks` sobre la hypertable ya comprimida · **Línea base:** `DELETE`

| | Postgres `DELETE` | Timescale `drop_chunks` |
|---|---|---|
| lo que se borra | 8 823 630 filas | 52 chunks (quedan 48 450 lecturas en el chunk del borde) |
| WAL | 1254,2 MiB | 3,1 MiB |
| tamaño después | 4589,7 → 4589,7 MiB (y tras `VACUUM`, igual) | 1448,7 → 1356,7 MiB (comprimido) |
| el roll-up diario | — | conserva los 54 750 días-aeronave |

Reproducir: `node 09-series-levantar-y-modelar/retention.ts` (destructivo: después, `load.ts` y `rollups.sql`).

**Interpretación:** borrar por tiempo en una tabla es reescribir filas; en una hypertable, tirar tablas.

### M-24 — Corregir la historia comprimida

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [09](09-series-levantar-y-modelar.md) · **Volumen:** el
  de M-21; 223 de 271 chunks comprimidos (`segmentby aircraft`, `orderby ts`): 7672 → 476 MiB
- **Motor:** TimescaleDB 2.30.1 · **Línea base:** la tabla normal

| +3 °C al EGT de marzo de 2025 | Timescale | Postgres |
|---|---|---|
| una aeronave | 5043 filas · 3,8 MiB de WAL · 5 chunks a medias | 5043 · 4,6 MiB |
| toda la flota | E-44: habría que descomprimir 919 810 filas (límite 100 000) | 839 270 · 393,4 MiB |
| toda la flota, sin límite | 839 270 · 654,3 MiB · chunks a medias | — |

Reproducir: `node 09-series-levantar-y-modelar/compress_update.ts` (deshace las correcciones al final).

**Interpretación:** corregir la serie comprimida descomprime lotes enteros, escribe un 66 % más que la
tabla normal y deja chunks a medio comprimir.

### M-25 — La tarjeta: Timescale contra Postgres particionado

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [10](10-series-romper-y-medir.md) · **Volumen:**
  `reading_x10`, 50 M (huella de M-15), recargado
- **Motor:** TimescaleDB 2.30.1, chunks de 7 días, 222 comprimidos (lo anterior a 2026), agregados
  continuos · **Línea base:** PostgreSQL 18.6, `reading_part`, 60 particiones mensuales más `DEFAULT`
  (701 080 lecturas), 7629 MB con índices

| Medida | Timescale | Postgres particionado | Postgres / Timescale |
|---|---|---|---|
| páginas · la flota, marzo de 2025 | 3970 (5 chunks) | 9611 (1 partición) | 2,42× ✗ |
| páginas · `HC-2157`, 60 días | 343 | 161 | 0,47× ✓ |
| tamaño de los cinco años | 1090,7 MiB | 7631,0 MiB | 7,00× ✗ |
| lecturas para mantener el diario | 2420 | 112 560 (resumen a mano); 50 000 090 (vista) | 46,51× ✗ |
| WAL de borrar el primer año | 3,5 MiB (52 chunks) | 0,5 MiB (12 particiones) | 0,13× ✓ |

Reproducir: `node 10-series-romper-y-medir/scorecard.ts --with-retention`, tras `09-…/load.ts`,
`rollups.sql`, `10-…/compress.sql` y `partition.ts`.

**Interpretación:** Postgres llega en 2 de 5. Gana la retención y la lectura de una serie; pierde lo que
dan la compresión por columnas y los agregados que saben qué cambió.

### M-26 — Tamaño por año y *backfill*

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [10](10-series-romper-y-medir.md) · **Volumen:** el de M-25
- **Motor:** TimescaleDB 2.30.1 · **Línea base:** `reading_part`

| Año | Timescale sin comprimir → comprimido | Postgres |
|---|---|---|
| 2023 | 1479 → 92 MiB | 1361 MiB |
| 2024 | 1633 → 102 MiB | 1512 MiB |
| 2025 | 1633 → 101 MiB | 1509 MiB |

*Backfill* de dos meses (9818 lecturas sobre marzo y abril de 2025, comprimidos): Timescale 3,0 MiB de WAL
y 9 chunks a medias (recomprimir, 2,1 MiB más); Postgres 2,3 MiB.

Reproducir: `size_by_year.sql`, `size_by_year_base.sql` y `node 10-series-romper-y-medir/backfill.ts`.

**Interpretación:** dieciséis veces menos disco por año comprimido; insertar tarde es barato, corregir no
(M-24).

### M-27 — La cardinalidad y los chunks diminutos

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [10](10-series-romper-y-medir.md) · **Volumen:** `reading`,
  5 M reales
- **Motor:** TimescaleDB 2.30.1, `max_locks_per_transaction` 128, `/dev/shm` de 64 MB · **Línea base:** no aplica

| | Resultado |
|---|---|
| `segmentby aircraft` | 600,9 → 70,6 MiB · 8490 lotes · 60 días de `HC-2157`: 163 páginas |
| `segmentby aircraft, flight_id` | 600,9 → 93,3 MiB · 63 021 lotes · 54 páginas |
| chunks de 7 días / 1 día | 271 / 1894 chunks · planificar cinco años: 14 / 117 ms |
| chunks de 6 horas | **7573 chunks**: el `INSERT` de una vez falla (E-45); la consulta de cinco años falla por `/dev/shm` (E-35); `DROP TABLE` falla (E-45) |

Reproducir: `node 10-series-romper-y-medir/cardinality.ts --segmentby` y `--chunks --intervals "7 days,1 day,6 hours"`.

**Interpretación:** planear crece con los chunks antes de leer una fila, y a unos miles de chunks el
modelo ya no se puede cargar, consultar ni borrar de una vez.

### M-28 — Las búsquedas de Sandra

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [11](11-busqueda-levantar-y-modelar.md) · **Volumen:**
  `partCatalog-1m` (`datasetSha256` `a28d39be0bdb131…`, generador 1.0.0)
- **Motor:** OpenSearch 3.8.0 `opensearchproject/opensearch@sha256:fafe3fc35870…`, un fragmento, mapping
  estricto, 170,0 MiB (200 viajes de `_bulk`) · **Línea base:** PostgreSQL 18.6, 313 MB, `LIKE`/`ILIKE`

| Búsqueda (verdad) | OpenSearch: devueltos · de la verdad | Postgres: examinadas · devueltas · de la verdad |
|---|---|---|
| juntas toricas tren (10 287) | 10 287 · 10 287 | `LIKE` literal 1 000 000 · 0 · 0; `ILIKE '%junta%'` 1 000 000 · 72 485 · 10 287 |
| oring del tren (10 287) | 10 287 · 10 287 | `ILIKE '%oring%'` 1 000 000 · 0 · 0 |
| `20-100013/05` (2) | 2 · 2 (sin `alternateOf`: 1 · 1) | `= ANY(supplier_part_numbers)` 1 000 000 · 1 · 1 |
| `2010001305` (2) | 2 · 2 | con subconsulta de alternos 1 000 004 · 2 · 2 |

Reproducir: `node 11-busqueda-levantar-y-modelar/load.ts --dataset lab/data/partCatalog-1m` y `search.ts`.
De 100 152 referencias con alterno, 100 048 tienen uno que no las nombra de vuelta.

**Interpretación:** el buscador encuentra lo que produce los mismos términos; `LIKE` compara caracteres y
lee el millón. El alterno inverso hubo que modelarlo al cargar.

### M-29 — Facetas: una petición contra cuatro consultas

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [11](11-busqueda-levantar-y-modelar.md) · **Volumen:** el de M-28
- **Motor:** OpenSearch 3.8.0 · **Línea base:** PostgreSQL 18.6, `GROUP BY` con `ILIKE`

| | OpenSearch | Postgres |
|---|---|---|
| viajes para cuatro facetas | 1 | 4 · 4 142 651 filas examinadas |
| proveedores, tres primeros | `size` 3: S-026, S-057, S-047 (**mal**; error máximo 3521) · `shard_size` 100: S-026, S-055, S-059 (error 0) | S-026 3592 · S-055 3554 · S-059 3541 |

Reproducir: `node 11-busqueda-levantar-y-modelar/facets.ts`.

**Interpretación:** las agregaciones `terms` son aproximadas y lo dicen en `doc_count_error_upper_bound`.

### M-30 — El buscador como fuente de verdad

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [11](11-busqueda-levantar-y-modelar.md) · **Volumen:** el de M-28
- **Motor:** OpenSearch 3.8.0 · **Línea base:** la tabla de Postgres como fuente

| 500 correcciones escritas solo en OpenSearch | Distintas de la fuente | Perdidas |
|---|---|---|
| reconstruir con `_reindex` (32,5 s) | 500 | 0 |
| reconstruir desde la fuente (37,0 s) | 0 | 500 |

Reproducir: `node 11-busqueda-levantar-y-modelar/source-of-truth.ts` (deshace las correcciones al final).

**Interpretación:** con el buscador como fuente, toda reconstrucción deja dos verdades o pierde datos.

### M-31 — La batería de la apuesta

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [12](12-busqueda-romper-y-medir.md) · **Volumen:**
  `partCatalog-1m` (`a28d39be0bdb131…`)
- **Motor:** OpenSearch 3.8.0, índice de M-28 · **Línea base:** PostgreSQL 18.6 con `fts.sql`: `es_unaccent`
  (`unaccent` + `spanish_stem`), GIN de 5256 kB, `ts_rewrite` para sinónimos, números normalizados (105 MB de
  índices); tabla con todo, 456 MB

| | Resultado |
|---|---|
| búsquedas cubiertas por Postgres (diez primeros con tantos aciertos como OpenSearch) | **19 de 20** |
| la que falla | *"helice tripala"*: 4 de 10 contra 10 de 10 (orden: `ts_rank` sin normalizar por largo; con `ts_rank(…, 1)`, 10 de 10, medido después) |
| filas examinadas por Postgres | 10 288 para 10 287 correctas; 4 o 5 para un número |

Reproducir: `fts.sql` y `node 12-busqueda-romper-y-medir/battery.ts`.

**Interpretación:** con el GIN, Postgres examina las filas con los términos, como el buscador; para las
búsquedas del almacén, alcanza.

### M-32 — Facetas, reconstrucción y visibilidad

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [12](12-busqueda-romper-y-medir.md) · **Volumen:** el de M-31
- **Motor:** OpenSearch 3.8.0 · **Línea base:** PostgreSQL 18.6 con `fts.sql`

| | OpenSearch | Postgres |
|---|---|---|
| cuatro facetas de *"juntas tóricas"* | 1 petición | 34 169 páginas (una consulta) o ~136 700 (cuatro) |
| reconstruir el millón desde la fuente | 36,3 s; por el alias, 174 de 174 búsquedas con 10 287; contra el índice nuevo, error y después 0 | — |
| lo recién escrito, visible | hasta ~1 s con `refresh_interval` 1 s (17–18 búsquedas ciegas); 30 s con 30 s (520–523); `GET` por id, al instante | 5 de 5 al instante, desde otra conexión |

Reproducir: `facets-fts.ts`, `reindex-alias.ts`, `visibility.ts` y `visibility-pg.ts` (desde `src/`).

**Interpretación:** el buscador gana en facetas y paga una ventana de visibilidad y una reconstrucción que
pide alias; Postgres ve el `COMMIT` y lee la fila para contar.

### M-33 — El disco lleno

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [12](12-busqueda-romper-y-medir.md) · **Volumen:** el de M-31
- **Motor:** OpenSearch 3.8.0, umbrales bajados a 1 %, 2 % y 3 % con el disco del nodo al 12,5 % · **Línea
  base:** no aplica

| | Resultado |
|---|---|
| bloqueo del índice | a los 28,4 s (intervalo de chequeo mínimo, 10 s) |
| escribir | `429 cluster_block_exception … read-only-allow-delete block` (E-51) |
| leer | sigue: 72 485 juntas |
| levantar el bloqueo | solo, 9,7 s después de devolver los umbrales |

Reproducir: `node 12-busqueda-romper-y-medir/disk-full.ts`.

**Interpretación:** el disco lleno no tumba el buscador: lo cierra a la escritura con un código que parece
un límite de tasa.

### M-34 — La directiva, con saltos conocidos

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [13](13-grafos-levantar-y-modelar.md) · **Volumen:**
  `workOrder-1m` (`datasetSha256` `11a67c65fb22fdc9…`), lote `LOT-2022-117` (713 piezas)
- **Motor:** Neo4j 2026.09.0 Community `neo4j@sha256:91fb0bf237c4…`: 1 131 932 nodos, 2 653 164 relaciones
  (704 viajes, 90,2 s), 673 010 estadías · **Línea base:** PostgreSQL 18.6, esquema de la Fase 01 con
  `13-…/indexes.sql`

| Pregunta | Resultado | Neo4j: *db hits* · filas máx. | Postgres: examinadas · páginas |
|---|---|---|---|
| dónde estuvo una pieza del lote | 351 (= `answers.json`) | 2655 · 713 | 1413 · 4626 |
| qué salió con ella en cada retiro | 350 (= `answers.json`) | 5952 · 713 | 1801 · 4222 |

Reproducir: `node 13-grafos-levantar-y-modelar/measure.ts`.

**Interpretación:** con uno o dos saltos conocidos, Postgres con sus índices no pierde.

### M-35 — La estadía, derivada o guardada

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [13](13-grafos-levantar-y-modelar.md) · **Volumen:** el de M-34
- **Motor:** Neo4j, `:INSTALLED {from, to}` · **Línea base:** Postgres derivando estadías con una ventana, y
  con `part_stint` (673 010 filas, 62 MB, 4,4 s)

| Piezas que compartieron aeronave con una del lote, al mismo tiempo | Resultado | Recorrido |
|---|---|---|
| Neo4j | 12 944 | 219 423–220 020 *db hits* · 93 601 filas máx. |
| Postgres, derivando estadías | 12 944 | 4 939 732 examinadas · 203 052 páginas |
| Postgres, con `part_stint` | 12 944 | 94 761 examinadas · 88 300 páginas |

**Interpretación:** lo que separa no son los saltos sino si la relación con propiedades está guardada.

### M-36 — El grafo genérico y el producto cartesiano

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [13](13-grafos-levantar-y-modelar.md) · **Volumen:** el de M-34
- **Motor:** Neo4j, modelo genérico `:Node {type}` y `:REL` sin propiedades (743 334 nodos, 669 271 relaciones)
  al lado del modelo de la familia · **Línea base:** no aplica

| La directiva de 2024 | Aeronaves | *db hits* | Primer operador |
|---|---|---|---|
| modelo de la familia | 22 | 3032 | `NodeIndexSeek` |
| modelo genérico | 351 (mal) | 2 831 085 | `NodeByLabelScan` |
| `MATCH (p:Part {lot}), (a:Aircraft)` | 1 848 809 filas | 1 850 236 | aviso `CartesianProduct` |

Reproducir: `node 13-grafos-levantar-y-modelar/generic.ts`.

**Interpretación:** el modelo genérico pierde la fecha de la relación y el índice del primer nodo.

### M-37 — La escalera de saltos

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [14](14-grafos-romper-y-medir.md) · **Volumen:** el de M-34
- **Motor:** Neo4j, `[:INSTALLED*1..d]` con `count(DISTINCT x)` · **Línea base:** PostgreSQL 18.6 con
  `WITH RECURSIVE` sobre `stint_edge` (1 338 542 aristas, 106 MB), en dos versiones; `statement_timeout` 120 s

| A 4 saltos | Nodos | Neo4j, *db hits* | `UNION`, filas · páginas | `UNION ALL` + `CYCLE`, filas · páginas |
|---|---|---|---|---|
| `SN-0391969` (la de `a07`) | 96 203 | 257 487 | 100 640 · 22 670 | 3 345 159 · 96 407 |
| `SN-0000255` (del lote) | 48 521 | 90 697 | 48 786 · 3082 | 187 705 · 5343 |
| `SN-0705472` (por hash) | 23 129 | 92 750 | 24 496 · 7238 | 1 257 897 · 35 450 |

A 6 saltos, la versión con `CYCLE` no termina en ninguna de las tres; la de `UNION` llega a 8 saltos en todas
(293 124 filas y 797 558 páginas en la peor). Reproducir: `node 14-grafos-romper-y-medir/ladder.ts`.

**Interpretación:** contra `UNION`, el grafo no gana a partir del cuarto salto; contra `UNION ALL` + `CYCLE`,
13× a cuatro saltos y la otra no termina a seis. La diferencia es enumerar nodos o caminos.

### M-38 — El camino más corto, devuelto

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [14](14-grafos-romper-y-medir.md) · **Volumen:** el de M-34
- **Motor:** Neo4j, `SHORTEST 1` · **Línea base:** Postgres, camino en arreglo, y niveles con `UNION` más
  vuelta atrás desde la aplicación

| De `SN-0000255` a `HC-10251` (5 saltos) | Recorrido | Viajes |
|---|---|---|
| Neo4j | 1061 *db hits* | 1 |
| Postgres, arreglo | 2 092 380 filas | 1 |
| Postgres, niveles + vuelta atrás | 1 746 991 filas | 8 |

Reproducir: `node 14-grafos-romper-y-medir/shortest.ts`.

**Interpretación:** devolver el camino es donde el grafo gana por órdenes de magnitud; en SQL deja de ser
una consulta.

### M-39 — Caminos sin límite

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [14](14-grafos-romper-y-medir.md) · **Volumen:** el de M-34
- **Motor:** Neo4j, heap 512 MB · **Línea base:** Postgres, `statement_timeout` 120 s

| Desde `SN-0391969`, sin límite de profundidad | Neo4j | Postgres |
|---|---|---|
| nodos alcanzables | 96 242 en 0,4 s | 96 242 en 0,6 s (`UNION`) |
| caminos | E-55 a los 3,6 s | E-56 a los 120 s (`UNION ALL` sin `CYCLE`) |

Reproducir: `node 14-grafos-romper-y-medir/unbounded.ts`.

**Interpretación:** pedir nodos termina en los dos; pedir caminos no termina en ninguno. Neo4j se rompe
rápido y con mensaje; Postgres, hasta que algo lo corta.

### M-40 — La travesía con menos caché

- **Fecha de ejecución:** 07/10/2026 · **Fase:** [14](14-grafos-romper-y-medir.md) · **Volumen:** el de M-34
- **Motor:** Neo4j, travesía de 8 saltos desde `SN-0391969` (96 242 nodos), caché de páginas de 256 y 64 MB;
  lectura de disco medida en `io.stat` del cgroup · **Línea base:** no aplica

| Caché | En frío: leído · fallos mayores | En caliente: leído · fallos mayores |
|---|---|---|
| 256 MB | 197,2 MiB · 28 | 7,5 MiB · 0 |
| 64 MB | 185,3 MiB · 25 | 25,7 MiB · 4 |

Reproducir: los pasos de `14-grafos-romper-y-medir/cache.ts`, con `compose.pagecache-64m.yaml` para 64 MB.

**Interpretación:** el grafo que no cabe en la caché no se rompe: se vuelve disco, 3,4 veces más en caliente.


### M-41 — Tres preguntas, tres tablas y Postgres particionado

- **Fecha de ejecución:** 10/10/2026 · **Fase:** [17](17-columnar-levantar-y-modelar.md) · **Volumen:** `reading-5m`
  (`datasetSha256` `8dc486dea089…`) y su ampliación ×10 a 50 M (170 matrículas, la de las Fases 07–10)
- **Motor:** Cassandra 5.0.9 `cassandra@sha256:8819d1b7877e…`, un nodo, heap 512 MB; una tabla por consulta (10 048 539
  filas para 5 M lecturas; 50 M en `reading_x10_by_aircraft_month`) · **Línea base:** PostgreSQL 18.6 particionado
  por mes (61 particiones) con un índice por consulta (`reading_part5`) y `reading_part` de la Fase 10 (50 M)

| Pregunta | Devueltas | Cassandra: particiones · SSTables · filas vivas | Postgres: particiones · examinadas · páginas |
|---|---|---|---|
| 1 · `HC-2157`, 60 días, 5 M | 9666 | 3 · 3 · 9666 | 3 · 9666 · 157 |
| 1 · la misma, 50 M | 9666 | 3 · 3 · 9666 | 3 · 9666 · 161 |
| 1 · `HC-2157~9`, 50 M | 9666 | 3 · 3 · 9666 | 3 · 9666 · 205 |
| 2 · vuelo `FL-00002996` | 65 | 1 · 1 · 65 | 61 · 65 · 184 |
| 3 · excedencias del 19/09/2026 | 78 | 1 · 2 · 78 | 1 · 78 · 19 |
| 3b · la 3 desde la tabla de la 1 | 78 | 17 · 18 · 3807 | — |

En disco: 5 M en dos tablas, 156,6 + 160,8 MiB (LZ4); Postgres, 447 MiB de tabla y 352 de índices. A 50 M,
1595 MiB contra 7629 MiB con índice. Carga: 248 s las tres tablas; 1206 s los 50 M con 13 reintentos por
*write timeout* (E-57). Reproducir: `node 17-columnar-levantar-y-modelar/measure.ts [--x10]`.

**Interpretación:** con una partición por consulta, Postgres particionado iguala la forma y ninguno crece con
×10; la diferencia está en la consulta que no sigue la clave de partición de Postgres (61 contra 1).

### M-42 — El backfill de una consulta nueva

- **Fecha de ejecución:** 10/10/2026 · **Fase:** [17](17-columnar-levantar-y-modelar.md) · **Volumen:** `reading-5m`
- **Motor:** Cassandra, `flights_by_aircraft` llenada desde `reading_by_flight` · **Línea base:** Postgres,
  `GROUP BY flight_id` sobre `reading_part5`

| Los últimos diez vuelos de `HC-2157` | Cassandra | Postgres |
|---|---|---|
| preparar | backfill: 5 000 000 filas leídas, 62 486 escritas, 19 s | nada |
| cada consulta | 1 partición · 10 filas vivas | 294 118 examinadas · 4630 páginas |

Reproducir: `node 17-columnar-levantar-y-modelar/backfill.ts`.

**Interpretación:** la consulta nueva cuesta un recorrido completo una vez, y una escritura más en cada carga
para siempre; Postgres no prepara nada y paga en cada consulta.

### M-43 — Lotes con y sin registro

- **Fecha de ejecución:** 10/10/2026 · **Fase:** [17](17-columnar-levantar-y-modelar.md) · **Volumen:** las
  primeras 100 000 lecturas de `reading-5m`, cada una en dos tablas
- **Motor:** Cassandra, un nodo; escrituras locales de `system.batches` por `nodetool tablestats` · **Línea
  base:** no aplica

| Forma | Escrituras | En `system.batches` | Tiempo (contexto) |
|---|---|---|---|
| sueltas | 200 000 | 0 | 4,3 s |
| `BATCH` sin registro | 200 000 | 0 | 3,2 s |
| `BATCH` con registro | 200 000 | 200 000 | 4,3 s |

Reproducir: `node 17-columnar-levantar-y-modelar/batch.ts`.

**Interpretación:** el lote con registro escribe dos filas de sistema por lote (el lote y su borrado); es el
precio de que todas sus escrituras se apliquen tarde o temprano.

### M-44 — Quórum y la lectura vieja en un anillo de tres

- **Fecha de ejecución:** 10/10/2026 · **Fase:** [17](17-columnar-levantar-y-modelar.md) · **Volumen:** dos filas
- **Motor:** tres nodos de Cassandra 5.0.9 (`lab/compose.anillo.yaml`, 207 s, 1,22 + 1,16 + 1,14 GiB),
  `replication_factor` 3 · **Línea base:** no aplica

| Nodos caídos | `ONE` | `QUORUM` | `ALL` |
|---|---|---|---|
| 0 | escribe y lee | escribe y lee | escribe y lee |
| 1 | escribe y lee | escribe y lee | falla |
| 2 | escribe y lee | falla (E-58) | falla |

Lectura vieja, con *hints* desactivados: `c3` caído, 700 → 745 escrito en `ONE`; al volver, dos lecturas en `ONE`
contestadas por otras réplicas (745), la tercera por `c3` (**700**); `QUORUM` repara al leer, y `c3` devuelve
745. Reproducir: `17-columnar-levantar-y-modelar/quorum.sh`.

**Interpretación:** W + R > RF es la condición para no leer un valor viejo; con `ONE` y `ONE`, la traza mostró
uno.

### M-45 — La entidad con `ALLOW FILTERING`, en tres volúmenes

- **Fecha de ejecución:** 10/10/2026 · **Fase:** [17](17-columnar-levantar-y-modelar.md) · **Volumen:**
  `reading-10k`, `reading-1m` y `reading-5m`, cada uno con su caso `egtTrend`
- **Motor:** Cassandra, `reading_entity` con clave `uuid` · **Línea base:** `reading_by_aircraft_month`

| Volumen | Filas vivas leídas | Devueltas | Traza del coordinador (contexto) |
|---|---|---|---|
| 10 k | 10 000 | 328 | 22 ms |
| 1 M | 1 000 000 | 11 012 | 2021 ms |
| 5 M | 5 000 000 | 9666 | 9430 ms |
| 5 M, tabla por consulta | 9666 | 9666 | 3 particiones |

Reproducir: `node 17-columnar-levantar-y-modelar/entity.ts`.

**Interpretación:** sin partition key que nombrar, la consulta lee la tabla entera; a 5 M, la página más lenta
ya tarda 4,9 s, y el nodo cancela la que pasa de 5 s (corregido el 11/10/2026 con la Fase 18, M-51: decía
"10 s de una lectura por rango").

### M-46 — Cargar 50 M: los bytes que llegan al disco

- **Fecha de ejecución:** 10–11/10/2026 · **Fase:** [18](18-columnar-romper-y-medir.md) · **Volumen:** ampliación
  ×10 de `reading-5m` (`8dc486dea089…`), 50 M lecturas, cargadas en todo lo que contesta las tres consultas
- **Motor:** Cassandra 5.0.9, un nodo, heap 512 MB, tres tablas (100 485 390 filas) · **Línea base:** PostgreSQL
  18.6, `reading_part` (61 particiones por mes, índices de las consultas 1 y 3) y `reading_part_flight` (16 por
  hash del vuelo, índice de la 2): 100 M filas
- **Medida:** bytes escritos por el contenedor, del `io.stat` de su cgroup (`lab/harness/io.ts`), hasta sin
  compactaciones pendientes o tras `CHECKPOINT`

| Carga | Escrito al disco | Desglose | En disco al final | Por byte que queda |
|---|---|---|---|---|
| Cassandra | 70 530 MiB | compactaciones 45 653 | 3227 MiB | 21,86 |
| Postgres, de fábrica | 70 255 MiB | WAL 34 505 · páginas 19 869 · VACUUM 9068 · ceros 432 | 14 810 MiB | 4,74 |
| Postgres, `max_wal_size` 16 GB y WAL lz4 | 74 159 MiB | WAL 24 970 · páginas 19 783 · ceros 15 376 · VACUUM 9077 | 14 810 MiB | 5,01 |

Tiempos (contexto): Cassandra 2584 s confirmadas, 0 reintentos; Postgres 453 y 461 s, dentro del servidor.
Reproducir: `node 18-columnar-romper-y-medir/load.ts` y `baseline.ts [--tuned]` (desde `src/`).

**Interpretación:** escriben lo mismo por lectura cargada; Cassandra lo gasta en compactar (inflado por el heap de
512 MB, no medido con otro), Postgres en WAL y VACUUM. Configurar Postgres para ingesta empeoró el total: llenar
con ceros los segmentos de WAL nuevos (`wal_init_zero`).

### M-47 — La tarjeta: Cassandra contra Postgres particionado bien jugado

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [18](18-columnar-romper-y-medir.md) · **Volumen:** el de M-46
- **Motor y línea base:** los de M-46 · segunda de dos pasadas

| Medida | Cassandra | Postgres | Postgres / Cassandra |
|---|---|---|---|
| filas leídas · 1 · `HC-2157`, 60 días (3 / 3 particiones) | 9666 | 9666 | 1,00 ✓ |
| filas leídas · 2 · vuelo `FL-00002996` (1 / 1) | 65 | 65 | 1,00 ✓ |
| filas leídas · 3 · excedencias del 19/09/2026 (1 / 1) | 780 | 780 | 1,00 ✓ |
| disco de lo que contesta las tres | 3227 MiB | 14 810 MiB | 4,59 ✗ |
| escrito al disco para cargarlo | 70 530 MiB | 70 255 MiB | 1,00 ✓ |

Reproducir: `node 18-columnar-romper-y-medir/scorecard.ts`.

**Interpretación:** apuesta 9 ganada, 4 de 5. Con una segunda copia partida por hash, la consulta 2 de Postgres
toca 1 partición y no 61 (M-41). Lo único que pierde es el disco: compresión por bloques contra filas e índices.

### M-48 — El *hot spot* de la partición por mes

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [18](18-columnar-romper-y-medir.md) · **Volumen:** septiembre de
  2026 de `reading-5m`, 111 863 lecturas de 17 aeronaves
- **Motor:** Cassandra 5.0.9, anillo de tres nodos (`lab/compose.anillo.yaml`), keyspace con RF 1 · **Línea
  base:** la misma carga con la partition key `(aircraft, month)`

| Nodo | Filas, partición `(aircraft, month)` | Filas, partición `(month)` |
|---|---|---|
| c1 | 64 999 | 0 |
| c2 | 32 500 | 111 863 |
| c3 | 14 364 | 0 |

Reproducir: `18-columnar-romper-y-medir/hotspot.sh`, con el anillo arriba.

**Interpretación:** partir solo por tiempo manda todas las escrituras del mes a un nodo; con 17 particiones, la
clave buena tampoco reparte parejo (58/29/13 %).

### M-49 — STCS contra TWCS

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [18](18-columnar-romper-y-medir.md) · **Volumen:** `reading-5m`
  en orden de tiempo, con `USING TIMESTAMP` y un volcado por semana de datos (296)
- **Motor:** Cassandra 5.0.9, un nodo · **Línea base:** la estrategia por defecto (STCS)

| Estrategia | Compactaciones · MiB reescritos | Escrito al disco | En disco · SSTables | SSTables de la consulta 1 |
|---|---|---|---|---|
| STCS | 98 · 2422 | 3278 MiB | 100 MiB · 2 | 3 |
| TWCS, ventanas de 30 días | 112 · 167 | 965 MiB | 100 MiB · 62 | 5 |

Reproducir: `node 18-columnar-romper-y-medir/compaction.ts`.

**Interpretación:** TWCS reescribe 14,5 veces menos porque no vuelve a una ventana cerrada, y paga dos SSTables
más en una consulta que cruza ventanas.

### M-50 — Borrar: tombstones y tuplas muertas

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [18](18-columnar-romper-y-medir.md) · **Volumen:** la partición de
  `HC-2157` de octubre de 2025, 5040 lecturas, copiada
- **Motor:** Cassandra 5.0.9, un nodo · **Línea base:** PostgreSQL 18.6, la misma partición con su índice

| Estado | Cassandra: tombstones leídos · en disco | Postgres: páginas · tuplas muertas · en disco |
|---|---|---|
| copiada | 0 · 73 KiB | 64 · 0 · 696 KiB |
| 5040 `DELETE`, uno por fila | 5040 · 126 KiB | 64 · 5040 · 696 KiB |
| compactada / tras VACUUM | 5040 · 53 KiB | 0 · 0 · 200 KiB |
| un `DELETE` del rango | 2 · 78 KiB | — |
| `gc_grace_seconds` 0, compactada | 0 · 0 KiB | — |

Umbral: avisos desde 1001 marcas; a 100 001, la lectura se cancela (E-60). Reproducir:
`node 18-columnar-romper-y-medir/tombstones.ts` y `deletes-pg.ts`.

**Interpretación:** los dos dejan marcas; Postgres las limpia con VACUUM y Cassandra espera diez días.

### M-51 — `ALLOW FILTERING` hasta que deja de contestar

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [18](18-columnar-romper-y-medir.md) · **Volumen:** `reading_entity`
  creciendo de 5 M en 5 M con la ampliación ×10; la consulta del caso `egtTrend` (9666 filas)
- **Motor:** Cassandra 5.0.9, un nodo, páginas de 5000 · **Línea base:** M-45

| Tabla | Resultado |
|---|---|
| 5 M | 9666 devueltas · 5 000 000 leídas · 9278 ms en la traza; páginas de 4352 y 4873 ms (`debug.log`) |
| 10 M | falla a los 5,0 s: el nodo cancela la lectura local (E-61) |

Reproducir: `node 18-columnar-romper-y-medir/filtering.ts`.

**Interpretación:** el límite que corta es el de 5 s por lectura local, no los 10 s del coordinador.

### M-52 — La partición sin cota

- **Fecha de ejecución:** 11/10/2026, dos corridas · **Fase:** [18](18-columnar-romper-y-medir.md) · **Volumen:**
  una aeronave sintética a 1 Hz, `PRIMARY KEY ((aircraft), ts)`
- **Motor:** Cassandra 5.0.9, un nodo, heap 512 MB · **Línea base:** ninguna; la salida es el bucket diario

| Filas · días · MiB | La última hora | EGT máxima de la historia | La historia en una página |
|---|---|---|---|
| 1 M · 12 · 18 | 3600 · 5 ms | 1,3 s | 1 000 000 en 3,2 s |
| 2 M · 23 · 35 | 3600 · 6 ms | 2,1 s | `OutOfMemoryError` en el nodo; el cliente espera 120 s |
| 5 M · 58 · 88 | — | timeout a los 5 s | falla a los 3 s (sin memoria) |
| 10 M · 116 · 177 | 3600 · 5 ms | timeout a los 5 s | timeout a los 5 s |

Después: pausa de recolección de 84 s y transporte nativo muerto, con `nodetool` diciendo que está activo; Docker
lo dio por sano 14 minutos más. En la segunda corrida, todo eso a los 2 M. Reproducir:
`node 18-columnar-romper-y-medir/unbounded.ts`.

**Interpretación:** la partición sin cota no tumba el nodo por su tamaño en disco sino porque convierte "leer la
partición" en una operación sin límite; la consulta de la última hora nunca se entera.

### M-53 — La tableta contra el servidor: lo que viaja

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [19](19-offline-levantar-y-modelar.md) · **Volumen:** `workOrder-10k`
  (`5a107518d726…`), las 10 000 órdenes en el servidor
- **Motor:** CouchDB 3.5.2 y PouchDB 9.0.0 en Node (LevelDB) · **Línea base:** ninguna honesta; Postgres no corre
  en la tableta

| Paso | Docs leídos · escritos | Peticiones | Subidos | Bajados |
|---|---|---|---|---|
| todo `work_order` | 10 000 · 10 000 | 504 | 665 KiB | 8977 KiB |
| las cuatro aeronaves del viaje (`selector`) | 1686 · 1686 | 89 | 113 KiB | 1520 KiB |
| otra vez, sin nada nuevo | 0 · 0 | 6 | 0 KiB | 2 KiB |
| primera subida: 19 guardados en 4 órdenes | 4 · 4 | 55 | 93 KiB | 6 KiB |
| una edición más, otra subida | 1 · 1 | 7 | 1 KiB | 1 KiB |

Historial de `WO-0009941`: en la tableta, 6 revisiones con cuerpo; en el servidor, 7 identificadores y 3 cuerpos
(la 1, nacida ahí, y las dos últimas). Una replicación persistente por `_replicator` de las cuatro aeronaves a
otra base: 1686 documentos, `completed`. Reproducir: `node 19-offline-levantar-y-modelar/sync.ts`.

**Interpretación:** el filtro y el *checkpoint* hacen barata la replicación de todos los días; la primera subida no
lo es, porque la tableta le pregunta al servidor (17 `_revs_diff`) por las 1686 órdenes que bajó de él. El
servidor recibe la hoja y la lista de antepasados, no los guardados intermedios.

### M-54 — El viaje de Freddy, cinco maneras de terminarlo

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [19](19-offline-levantar-y-modelar.md) · **Volumen:** las cuatro
  órdenes del viaje (`workOrder-10k`, reabiertas), 19 ediciones de Freddy y 7 de Jairo, los dos sin señal
- **Motor:** CouchDB 3.5.2 y dos tabletas PouchDB 9.0.0 · **Línea base:** ninguna; el contraste es M-55

| Forma · resolución | Conflictos | De Freddy | De Jairo | En disputa | Escondidas | Perdidas |
|---|---|---|---|---|---|---|
| orden por documento · ganadora de CouchDB | 2 | 19/19 | 1/7 | 0 | 6 | 0 |
| orden por documento · el último que escribe gana | 2 | 10/19 | 7/7 | 0 | 0 | 9 |
| orden por documento · fusión a mano | 2 | 18/19 | 7/7 | 2 | 0 | 1 |
| un documento por cosa · ganadora de CouchDB | 3 | 18/19 | 6/7 | 0 | 2 | 0 |
| orden como CRDT · fusión del CRDT | 2 | 19/19 | 7/7 | 2 | 0 | 0 |

En las cinco, las tres réplicas terminan con la misma ganadora; la fusión del CRDT da lo mismo en los dos
órdenes. Reproducir: `node 19-offline-levantar-y-modelar/conflicts.ts --detail`.

**Interpretación:** sin resolver, la ganadora es la rama más larga y la perdedora queda escondida; "el último que
escribe gana" borra el lunes de Freddy; la unión a mano reabre un pendiente cerrado; cortar el documento deja el
conflicto donde está el desacuerdo, y el CRDT no pierde nada pero no decide la bomba.

### M-55 — El mismo viaje contra Postgres como servidor

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [19](19-offline-levantar-y-modelar.md) · **Volumen:** las cuatro
  órdenes del viaje y las dos colas de M-54
- **Motor:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…`, esquema `offline` · **Línea base:** es el
  contraste de M-54, no una competencia

| Forma del servidor | Rechazados | De Freddy | De Jairo |
|---|---|---|---|
| documento con versión, un `UPDATE` por guardado | 7 de 19 guardados | 19/19 | 1/7 |
| documento con versión, una subida por orden | 2 de 4 órdenes | 10/19 | 7/7 |
| una fila por cosa, `UNIQUE (work_order_id, position)` | 1: la bomba de Freddy (E-66) | 18/19 | 7/7 |

Reproducir: `node 19-offline-levantar-y-modelar/postgres.ts`.

**Interpretación:** con un número de versión calculado en la tableta, el cuarto guardado de Freddy coincidió
con la versión que dejó Jairo y lo pisó sin error; la versión leída al salir rechaza bien, y deja nueve
ediciones para rehacer a mano; la restricción del dominio rechaza solo el desacuerdo real, al segundo que llega.

### M-56 — La apuesta: cien órdenes, tres días

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [20](20-offline-romper-y-medir.md) · **Volumen:** las últimas cien
  órdenes de Freddy en `workOrder-1m` (`11a67c65fb22…`), 87 aeronaves; 268 ediciones de Freddy sin señal y 284 de
  110 técnicos más, con señal
- **Motor:** CouchDB 3.5.2 y PouchDB 9.0.0 · **Línea base:** ninguna honesta; las formas de documento de la Fase 19

| Forma · resolución | Conflictos | Conservadas (Freddy · los demás) | Escondidas | Perdidas | Intervenciones manuales |
|---|---|---|---|---|---|
| orden como CRDT · fusión del CRDT | 89 | 552 (268 · 284) | 0 | 0 | 0 |
| orden por documento · ganadora de CouchDB | 89 | 347 (120 · 227) | 205 | 0 | 89 |
| orden por documento · el último que escribe gana | 89 | 310 (143 · 167) | 0 | 242 | 0 |

Sincronización del jueves: 100 documentos arriba, 89 abajo, 16 peticiones, 209 KiB (CRDT). Reproducir:
`node 20-offline-romper-y-medir/bet.ts`.

**Interpretación:** la apuesta se gana con la forma CRDT y 0 disputas, porque el generador nunca pone dos cambios
de pieza en la misma posición de una orden; la predicción (entre una y cinco disputas) se perdió. Con la forma de
siempre, el mismo viaje esconde el 37 % de las ediciones o pierde el 44 %.

### M-57 — El historial de revisiones de una orden

- **Fecha de ejecución:** 11/10/2026, dos corridas iguales · **Fase:** [20](20-offline-romper-y-medir.md) ·
  **Volumen:** una orden, de 1 a 2000 guardados en la tableta
- **Motor:** CouchDB 3.5.2 y PouchDB 9.0.0, `_revs_limit` por defecto · **Línea base:** no aplica

| Guardados | Historia (tableta · servidor) | Tableta → compactada | Subida | Servidor: vivos · archivo |
|---|---|---|---|---|
| 1 | 1 · 1 | 16 → 24 KiB | 7 peticiones, 0 KiB | 1 · 24 KiB |
| 100 | 100 · 100 | 568 → 272 KiB | 7, 4 KiB | 4 · 28 KiB |
| 1000 | 1000 · 1000 | 9700 → 9144 KiB | 7, 35 KiB | 38 · 60 KiB |
| 2000 | 1000 · 1000 | 12 864 → 2136 KiB | 7, 35 KiB | 38 · 60 KiB |

Reproducir: `node 20-offline-romper-y-medir/history.ts`.

**Interpretación:** la tableta guarda cada cuerpo hasta compactar, y LevelDB devuelve el espacio cuando quiere; la
subida lleva la lista de antepasados (35 KiB para una orden de cientos de bytes), y `_revs_limit` la corta en mil
en los dos lados.

### M-58 — El conflicto masivo y la compactación

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [20](20-offline-romper-y-medir.md) · **Volumen:** las cien órdenes
  de M-56, editadas por dos tabletas diez rondas sin resolver
- **Motor:** CouchDB 3.5.2 y PouchDB 9.0.0 · **Línea base:** no aplica

| Ronda | Hojas por documento | Hojas en total | Servidor: vivos · archivo |
|---|---|---|---|
| 1 | 2 | 200 | 114 · 232 KiB |
| 5 | 6 | 600 | 353 · 1188 KiB |
| 10 | 11 | 1100 | 667 · 3100 KiB |
| 10, compactado | 11 | 1100 | 634 · 2624 KiB |

La revisión 1 de cada orden: disponible antes de compactar, `not_found (missing)` después, en el servidor y en la
tableta (1668 → 1584 KiB). Reproducir: `node 20-offline-romper-y-medir/massive.ts`.

**Interpretación:** sin resolver, cada ronda suma una hoja por documento; compactar no toca las hojas y se lleva el
antepasado común que necesita una fusión a tres vías.
### M-59 — La primera bajada de la tableta, filtro por filtro

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [20](20-offline-romper-y-medir.md) · **Volumen:** `workOrder-1m` en
  `work_order_1m` (cargado en 175 s; 578 MiB vivos)
- **Motor:** CouchDB 3.5.2 y PouchDB 9.0.0, macOS arm64 (los segundos son contexto) · **Línea base:** no aplica

| Filtro | Órdenes | Peticiones | Bajados | Segundos | En la tableta |
|---|---|---|---|---|---|
| las 100 del viaje (`doc_ids`) | 100 | 9 | 0,1 MiB | 0 | 0,1 MiB |
| 87 aeronaves (`selector`) | 34 204 | 1721 | 30,1 MiB | 93 | 12,2 MiB |
| la base VVC (`selector`) | 150 785 | 7544 | 132,8 MiB | 90 | 53,5 MiB |
| todo | 1 000 000 | 50 004 | 881,6 MiB | 275 | 341,2 MiB |

Reproducir: `node 20-offline-romper-y-medir/load.ts` y `node 20-offline-romper-y-medir/tablet.ts`.

**Interpretación:** el cable crece con lo que baja (unas 50 peticiones y 0,9 MiB por mil órdenes); el reloj de un
`selector` no, porque recorre todo el registro de cambios del servidor. El millón cabe en 341 MiB: lo que llena una
tableta son los guardados sin compactar (M-57), no las órdenes.

### M-60 — La sincronización que no converge

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [20](20-offline-romper-y-medir.md) · **Volumen:** las cien órdenes
  de M-56, con sus 89 conflictos
- **Motor:** CouchDB 3.5.2 y PouchDB 9.0.0 · **Línea base:** no aplica

| Quién resuelve, con la misma fusión canónica | Conflictos por ronda | Hojas al final (cuerpos distintos) | Archivo del servidor |
|---|---|---|---|
| A · solo el servidor | 89 → 0 en 1 ronda | 1 (1) | 1740 KiB |
| B · servidor y tableta | 89 en las 10 rondas | 2 (**1**) | 8504 KiB |
| C · dos tabletas | 89 → 0 en 1 ronda | 1 (1) | 1496 KiB |
| D · servidor y tableta, firmando | 89 en las 10 rondas | 2 (2) | 8672 KiB |
| E · dos tabletas, firmando | 89 en las 10 rondas | 2 (2) | 3420 KiB |

El mismo `{"v":1}`: `1-2340a66d…` en una tableta, `1-7a7e4b29…` en el servidor. Reproducir:
`node 20-offline-romper-y-medir/pingpong.ts`.

**Interpretación:** los dos motores calculan el `_rev` del contenido con algoritmos distintos; dos réplicas de
motores distintos que resuelven lo mismo escriben dos hermanas iguales, y eso es un conflicto nuevo en cada ronda.
Sin mensaje de error.


### M-61 — El mismo esquema y las mismas sentencias, en Postgres y en CockroachDB

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [21](21-newsql-levantar-y-modelar.md) · **Volumen:** `workOrder-10k`
  sin lecturas, y la orden de escenario `WO-F21-0002`
- **Motor:** CockroachDB 26.3.2 de un nodo · **Línea base:** PostgreSQL 18.6, el esquema de la Fase 01 con sus índices

| Sentencia | Postgres: filas examinadas · bloques · claves foráneas | CockroachDB: filas del almacén · llamadas |
|---|---|---|
| la aeronave | 26 · 1 · 0 | 1 · 1 |
| sus órdenes (390) | 390 · 191 · 0 | 780 · 2 |
| técnicos de cada orden (390) | 15 238 · 286 · 0 | 780 · 2 |
| movimientos de piezas (512) | 13 086 · 356 · 0 | 902 · 2 |
| lo instalado hoy (21) | 21 · 21 · 0 | 42 · 2 |
| firmar la inspección mayor: 5 `INSERT` y 2 `UPDATE` | 18 comprobaciones de clave foránea, por disparador | `insert fast path` en los 5; 10 operadores por `UPDATE`, uno `constraint-check` |

El esquema entró con dos líneas menos (E-69). Aislamiento por defecto: `read committed` contra `serializable`.
Reproducir: `node 21-newsql-levantar-y-modelar/transactions.ts`.

**Interpretación:** CockroachDB cuenta la entrada del índice y la fila por separado (780 = 390 + 390); Postgres eligió
un *hash join* con recorrido completo sobre las tablas chicas. Dos planificadores, no dos modelos: en un nodo, todo
se lee de `n1`.

### M-62 — Una posición, una pieza: cuatro aislamientos

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [21](21-newsql-levantar-y-modelar.md) · **Volumen:** la llanta de nariz
  de `HC-2157` y dos llantas de almacén
- **Motor:** CockroachDB 26.3.2 de un nodo · **Línea base:** PostgreSQL 18.6

| Motor y aislamiento | Confirmó el Coca · Bogotá | Llantas en la nariz |
|---|---|---|
| Postgres `READ COMMITTED` | sí · sí | 2 |
| Postgres `SERIALIZABLE` | sí · no, `40001` al instalar | 1 |
| CockroachDB `SERIALIZABLE` | sí · no, `40001` (`RETRY_SERIALIZABLE`) al confirmar | 1 |
| CockroachDB `READ COMMITTED` | sí · sí | 2 |

Reproducir: `node 21-newsql-levantar-y-modelar/skew.ts`.

**Interpretación:** *write skew*: ningún bloqueo lo evita porque cada uno escribe una fila distinta. Lo rechaza el
`SERIALIZABLE` de los dos motores; la diferencia es el valor por defecto.

### M-63 — Dónde viven las filas del operador estatal

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [21](21-newsql-levantar-y-modelar.md) · **Volumen:** `workOrder-10k`
  sin lecturas; el expediente de `OP-EST` son 1990 filas
- **Motor:** CockroachDB 26.3.2, `cockroach demo --nodes=9 --global`, cada región haciendo de un país · **Línea
  base:** no aplica (un Postgres de un nodo vive en un país)

| Esquema | Rangos de la base | Filas de `OP-EST` con copia fuera de Ecuador |
|---|---|---|
| el de la Fase 01, copiado | 1, con un votante por región | 1990 |
| región por fila, ubicación por defecto | 47 | 1990 (dos copias no votantes) |
| región por fila, `PLACEMENT RESTRICTED` | 47 | 43, las piezas |
| la autoridad en la clave, `PLACEMENT RESTRICTED` | 62 | 43, las piezas |
| la autoridad en la clave, super región de Ecuador | — | 43, las piezas |

`PLACEMENT RESTRICTED` tardó 308–311 s en mover las réplicas (tres corridas), y la super región 309 s;
`SURVIVE REGION FAILURE` se rechaza con las dos (E-74). Una lectura con `follower_read_timestamp()` desde Perú, sobre la copia, la sirvió `n8` en Perú, con 4,2 s
de atraso. Reproducir: `node 21-newsql-levantar-y-modelar/placement.ts` (ver la fase para los argumentos).

**Interpretación:** `REGIONAL BY ROW` pone los votantes en el país, no todas las copias: pide cinco réplicas, una por
región. Las 43 que quedan fuera son de una decisión de diseño (la pieza es de Cóndor), no del motor.

### M-64 — Qué regiones toca cada trabajo del expediente

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [21](21-newsql-levantar-y-modelar.md) · **Volumen:** el de M-63, y
  las dos órdenes de escenario
- **Motor:** el de M-63 · **Línea base:** no aplica

Sentencias que salen de la región desde donde se escribe:

| Trabajo (desde) | Esquema copiado | Región por fila | La autoridad en la clave |
|---|---|---|---|
| el expediente (Ecuador) | 5 de 5 | 4 de 5 | 1 de 5 |
| la rutina del Coca (Ecuador) | 6 de 6, y las 6 con quórum fuera | 6 de 6 | 4 de 6, a Colombia |
| la inspección mayor (Colombia) | 0 de 7, y las 7 con quórum fuera | 6 de 7 | 6 de 7, cinco escriben en Ecuador |

Reproducir: `node 21-newsql-levantar-y-modelar/regions.ts --db … --schema …`.

**Interpretación:** con la región por fila y la clave de la Fase 01, cada `INSERT` comprueba la unicidad en las tres
regiones y cada consulta por aeronave recorre las tres particiones; con la autoridad en la clave, lo que sale es la
pieza (decisión de diseño) y una clave foránea que apunta a la matrícula sin el país.

### M-65 — El reinicio por incertidumbre del reloj

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [21](21-newsql-levantar-y-modelar.md) · **Volumen:** la orden
  `WO-0009965` y el actuador `SN-0001068`
- **Motor:** el de M-63, con la autoridad en la clave · **Línea base:** no aplica

| Vueltas | Reinicios | Escritura después de la lectora | Límite de incertidumbre |
|---|---|---|---|
| 5 | 5 de 5 | +3 a +6 ms | +500 ms, siempre |

Las corridas anteriores, con el esquema regional y con el de la autoridad, dieron también cinco de cinco. Reproducir:
`node 21-newsql-levantar-y-modelar/clock.ts --schema autoridad`.

**Interpretación:** una lectura que llega, en un nodo que no visitó, a un valor fechado dentro de su ventana no sabe
si es pasado o futuro; si lo que ya leyó también cambió, se reinicia. El laboratorio comparte un reloj: el desfase
real entre máquinas no se midió.


### M-66 — La física del demo y los tres trabajos, en milisegundos

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [22](22-newsql-romper-y-medir.md) · **Volumen:** `workOrder-10k`
  sin lecturas; el expediente de `HC-2157` y las órdenes `WO-F21-*`
- **Motor:** CockroachDB 26.3.2, `cockroach demo --nodes=9 --global` · **Línea base:** M-67

Latencia en el servidor (`SHOW LAST QUERY STATISTICS`), mediana de cinco tras una vuelta de calentamiento. Leer una
aeronave por su clave: Colombia–Ecuador 68 ms, Colombia–Perú 66 ms, Ecuador–Perú 149 ms, local menos de 1 ms.

| Trabajo (desde) | Esquema de la Fase 01, copiado | La autoridad en la clave, restringido |
|---|---|---|
| el expediente (Ecuador) | 650 ms | 167 ms |
| la rutina del Coca (Ecuador) | 1019 ms | 486 ms |
| la inspección de Bogotá (Colombia) | 124 ms | 565 ms |

Reproducir: `node 22-newsql-romper-y-medir/latency.ts --db … --schema copy|autoridad`.

**Interpretación:** cada sentencia cuesta sus viajes entre regiones. La copia es más rápida en Bogotá porque en esa
carga su leaseholder quedó en Colombia: escribe filas ecuatorianas en Colombia.

### M-67 — La apuesta: Postgres con réplica contra CockroachDB

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [22](22-newsql-romper-y-medir.md) · **Volumen:** el de M-66
- **Motor:** CockroachDB 26.3.2 (M-66) · **Línea base:** PostgreSQL 18.6, primario en Bogotá y réplica en Quito por
  *streaming* (`compose.replica.yaml`); su latencia, servidor más viajes a otro país por el RTT de M-66

| Trabajo | Postgres | CockroachDB (en un solo viaje) | Postgres / CockroachDB |
|---|---|---|---|
| el expediente desde Ecuador | 3,3 ms (réplica) | 167 ms (168) | 0,02 |
| la rutina del Coca | 1,0 + 67,7 = 68,8 ms | 486 ms (492) | 0,14 |
| la inspección de Bogotá | 1,1 ms | 565 ms (563) | 0,00 |

Nodos: 2 contra 9 (36 vCPU como mínimo de la guía de producción). La rutina del Coca mandada sentencia por sentencia
a Postgres: 8 viajes, 543 ms. Reproducir: `node 22-newsql-romper-y-medir/bet.ts`.

**Interpretación:** apuesta ganada en latencia (3 de 3) y en costo. El costo de CockroachDB está dentro del clúster,
no en los viajes del cliente. Postgres pierde la residencia: el primario guarda las firmas ecuatorianas en Colombia.

### M-68 — El enlace cortado: lo que lee la réplica

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [22](22-newsql-romper-y-medir.md) · **Volumen:** el de M-67
- **Motor:** PostgreSQL 18.6, primario y réplica · **Línea base:** no aplica

| Durante el corte (74 s) | |
|---|---|
| lecturas en Quito | 73, ninguna con la firma de Bogotá, ninguna con error |
| `pg_stat_wal_receiver` | `streaming` hasta 59 s después del corte |
| un cliente de Quito que va a escribir | `could not translate host name "primario"` |
| la firma en la réplica después de reponer | 4,2 s |

Reproducir: `node 22-newsql-romper-y-medir/partition.ts`.

**Interpretación:** la réplica no falla: responde con lo último que aplicó, y nadie se entera desde las lecturas.

### M-69 — La misma fila desde tres países

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [22](22-newsql-romper-y-medir.md) · **Volumen:** las horas del motor
  `SN-0005382` de `HC-2157`, una fila de Colombia
- **Motor:** el de M-66, `SERIALIZABLE`, `withRetry` · **Línea base:** M-70

| Forma · trabajadores | Confirmadas/s | Reintentos por confirmada | p50 Colombia | p50 Ecuador · Perú |
|---|---|---|---|---|
| leer-y-escribir · 3 | 26,9 | 0,11 | 33 ms | 7,2 s · 7,0 s |
| leer-y-escribir · 12 | 44,4 | 0,84 | 48 ms | 7,2 s · 8,1 s |
| leer-y-escribir · 48 | 29,3 | 4,32 (32 se rindieron) | 197 ms | 13,4 s · 11,3 s |
| atómica · 3 | 21,5 | 0 | 91 ms | 202 ms · 197 ms |
| atómica · 48 | 7,4 | 0 | 3,6 s | 9,7 s · 7,2 s |

Con dos regiones (Colombia y Ecuador), leer-y-escribir: máximo 30,9/s a 8, y 20,0/s con 4,31 reintentos a 32. Las
horas sumadas coincidieron con las confirmadas en todos los escalones. Reproducir:
`node 22-newsql-romper-y-medir/contention.ts --target global --kind rmw|atomic [--regions CO,EC]`.

**Interpretación:** la contención entre regiones castiga al lejano: el remoto llega tarde a cada escritura
(`WriteTooOldError`) y repite. La sentencia atómica reparte la espera, pero cada turno retiene la fila un viaje.

### M-70 — La misma suma en Postgres, sin geografía

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [22](22-newsql-romper-y-medir.md) · **Volumen:** el de M-69
- **Motor:** PostgreSQL 18.6, el primario de M-67, clientes en la misma máquina · **Línea base:** es la referencia

| Forma | Confirmadas/s | Horas sumadas a 48 trabajadores |
|---|---|---|
| leer-y-escribir, `SERIALIZABLE`, `withRetry` | ~200, hasta 1,71 reintentos | 4117 de 4117 |
| leer-y-escribir, `READ COMMITTED` | ~360–390 | **178 de 7832** |
| atómica, `READ COMMITTED` | ~820 | 16 393 de 16 393 |

La atómica en `SERIALIZABLE` sin reintento cayó con E-79. Reproducir:
`node 22-newsql-romper-y-medir/contention.ts --target primario --kind … --isolation …`.

**Interpretación:** sin geografía, la fila caliente aguanta un orden de magnitud más. El valor por defecto de
Postgres pierde las sumas que se leen antes de escribirse, sin un error.

### M-71 — Las horas partidas por región

- **Fecha de ejecución:** 11/10/2026 · **Fase:** [22](22-newsql-romper-y-medir.md) · **Volumen:** el de M-69, con las
  horas en `engine_hours_by_region`: una fila por país, la región en la clave
- **Motor:** el de M-66 · **Línea base:** M-69, la misma suma en una sola fila

| Trabajadores (tres regiones) | Confirmadas/s | Reintentos | p50 Colombia · Ecuador · Perú |
|---|---|---|---|
| 3 | 701,0 | 0 | 2 · 2 · 131 ms |
| 12 | 1920,3 | 0 | 3 · 3 · 262 ms |
| 48 | 1296,5 | 0 | 28 · 29 · 30 ms |

Horas sumadas iguales a las confirmadas en todos los escalones. Perú tardó en los primeros escalones mientras el
leaseholder de su fila recién creada llegaba a su región. Una primera corrida con la clave sin el país dejó una sola
fila y sumó 146 horas de 17 385 confirmadas: se descartó. Reproducir:
`node 22-newsql-romper-y-medir/contention.ts --target global --kind split`.

**Interpretación:** partir la fila por quien la escribe quita la contención entre regiones: cada país suma en su
casa. El costo se muda a la lectura, que suma tres filas.

### M-72 — El inventario de piezas, proyectado desde las órdenes

- **Fecha de ejecución:** 12/10/2026 · **Fase:** [23](23-poliglota-el-diseno.md) · **Volumen:** `workOrder-1m`
  (`11a67c65fb22…`), 740 741 piezas y 1 247 472 movimientos, y su `answers.json`
- **Motor:** PostgreSQL 18.6 · **Línea base:** es la referencia

El estado de cada pieza, proyectado desde su último movimiento (por apertura de la orden), contra lo que guarda `part`:

| Clase | Piezas | % |
|---|---|---|
| reconstruible desde las órdenes | 193 587 | 26,1 |
| saldo inicial: ninguna orden la movió | 411 597 | 55,6 |
| intercambio: el aliado devolvió otra | 59 829 | 8,1 |
| regreso del taller a un almacén | 56 814 | 7,7 |
| sustituto que entró por un intercambio | 18 913 | 2,6 |
| el actuador de marzo: al taller sin orden | 1 | 0,0 |

Lo instalado coincide entero: 47 152 de las 47 152 piezas instaladas con algún movimiento. Ordenando por el cierre de
la orden, 4093 piezas desguazadas aparecían instaladas. Con `workOrder-10k`, 26,1 % y 55,4 %. Reproducir:
`node 23-poliglota-el-diseno/inventory.ts [--db expediente --dataset lab/data/workOrder-10k]`.

**Interpretación:** 135 557 de las 329 144 piezas que se movieron (41 %) tienen un estado que ninguna orden explica;
78 743 tienen rastro solo en `answers.json`. El inventario es una segunda verdad dentro de la fuente.

### M-73 — El tablero, rearmado desde Postgres

- **Fecha de ejecución:** 12/10/2026 · **Fase:** [23](23-poliglota-el-diseno.md) · **Volumen:** `reading-5m`
  (`8dc486dea089…`) en la base `analitico`: 80 aeronaves, 30 822 órdenes, 5 M de lecturas
- **Motor:** DuckDB 1.5.6 · **Línea base:** `condor.duckdb`, construida por la Fase 07 desde el dataset

| Comparado | Resultado |
|---|---|
| huella de `aircraft`, `work_order` y `reading` | idénticas |
| el costo por hora volada (`cost_per_hour.sql`) | 15 filas en las dos, 0 distintas |

Rearmado con `COPY … TO STDOUT` y `read_csv` con los tipos declarados, en 6,5 s. Reproducir:
`uv run python 23-poliglota-el-diseno/rebuild_duckdb.py`.

**Interpretación:** Postgres tiene todo lo que el tablero necesita; la Fase 07 lo cargó en la otra dirección.

### M-74 — El servidor de las tabletas, rearmado desde Postgres

- **Fecha de ejecución:** 12/10/2026 · **Fase:** [23](23-poliglota-el-diseno.md) · **Volumen:** `workOrder-1m` en la
  base `postgres` y en `work_order_1m` (Fase 20); `workOrder-10k` en `expediente` y en `work_order` (Fase 19)
- **Motor:** Apache CouchDB 3.5.2 · **Línea base:** cada orden armada desde las cuatro tablas de Postgres

| Base de CouchDB | Órdenes | Iguales | Distintas |
|---|---|---|---|
| `work_order_1m` | 1 000 000 | 1 000 000 | 0 |
| `work_order` | 10 000 | 9996 | 4 |

Las cuatro distintas son las órdenes del viaje de Freddy en la Fase 19, reabiertas con la forma de la tableta y nunca
devueltas a Postgres. Se normaliza el orden de las piezas de cada orden, que Postgres no guarda. Reproducir:
`node 23-poliglota-el-diseno/rebuild-couch.ts [--db expediente --couch work_order]`.

**Interpretación:** ningún campo del millón vive solo en CouchDB; cuatro órdenes de la tableta viven solo ahí.

### M-75 — Las lecturas de la flota, contra la descarga

- **Fecha de ejecución:** 12/10/2026 · **Fase:** [23](23-poliglota-el-diseno.md) · **Volumen:** `reading-5m`
  (`8dc486dea089…`), 5 M de lecturas de 17 aeronaves
- **Motor:** TimescaleDB 2.30.1, la tabla `reading` de la Fase 09 · **Línea base:** el archivo `reading.ndjson`

Huella por aeronave —lecturas, primera y última, suma de los siete parámetros—: **17 de 17 iguales**. Reproducir:
`node 23-poliglota-el-diseno/readings.ts`.

**Interpretación:** las correcciones de la Fase 09 se deshicieron al terminar; la hypertable es un índice de la
descarga.

### M-76 — La ventana de inconsistencia de tres costuras

- **Fecha de ejecución:** 12/10/2026 · **Fase:** [24](24-poliglota-la-costura.md) · **Volumen:** la base `costura`
  (copia de `expediente`, `workOrder-10k`) y 12 000 órdenes nuevas, una cada 5 ms durante 60 s, desde un proceso
- **Motor:** PostgreSQL 18.6 con `wal_level=logical` y Apache CouchDB 3.5.2 · **Línea base:** no hay; se comparan
  las tres costuras entre sí

| Costura | Ritmo logrado | p50 | p99 | Máx. | No llegaron |
|---|---|---|---|---|---|
| doble escritura | 167/s | 5 ms | 14 ms | 78 ms | 0 |
| *outbox* (relevo cada 100 ms en vacío) | 200/s | 14 ms | 82 ms | 288 ms | 0 |
| CDC con `test_decoding` | 200/s | 21 ms | 55 ms | 149 ms | 0 |

Ventana: del `COMMIT` a la primera aparición en el `_changes` de CouchDB, con el reloj de la máquina en los dos
procesos ([`a04`](a04-el-arnes-de-medida.md)). Reproducir:
`node 24-poliglota-la-costura/run.ts --mode dual|outbox|cdc`.

**Interpretación:** con todo arriba, la doble escritura tiene la ventana más corta y le pasa la latencia de CouchDB a
quien escribe; las otras dos quedan acotadas por el intervalo del relevo. Ningún veredicto sale de estos milisegundos.

### M-77 — Las tres costuras con CouchDB caído 30 s

- **Fecha de ejecución:** 12/10/2026 · **Fase:** [24](24-poliglota-la-costura.md) · **Volumen:** el de M-76, con
  `docker stop` de CouchDB en el segundo 20 y `docker start` en el 50
- **Motor:** el de M-76 · **Línea base:** la comparación de la Fase 23 contra la base `costura` después de cada corrida

| Costura | No llegaron | Durante la caída: p50 · máx. | Al día tras volver CouchDB | Pendiente en el pico | Comparación final |
|---|---|---|---|---|---|
| doble escritura | 6761 (6762 errores contados) | — | nunca | — | 6761 ausentes, 3 s |
| *outbox* | 0 | 17,0 s · 31,6 s | 9,9 s | 6299 filas | 22 000 iguales |
| CDC | 0 | 16,9 s · 31,5 s | 9,9 s | 8,7 MiB de WAL | 22 000 iguales |

"Al día" incluye el arranque de CouchDB. Una de las 6762 que la aplicación dio por fallidas quedó guardada: apareció
35,9 s después de su `COMMIT`. Reproducir: `run.ts --mode dual|outbox|cdc --outage 20:30`.

**Interpretación:** con lo pendiente en la fuente, una caída es ventana; en la memoria de la aplicación, es pérdida.

### M-78 — Dos procesos, la misma orden

- **Fecha de ejecución:** 12/10/2026 · **Fase:** [24](24-poliglota-la-costura.md) · **Volumen:** 10 órdenes; 500
  rondas, cada una con dos `UPDATE` simultáneos de las horas de la misma orden desde dos conexiones
- **Motor:** el de M-76 · **Línea base:** el valor que quedó en Postgres

| Costura | Rondas con CouchDB en el valor que perdió en Postgres | Órdenes distintas al terminar |
|---|---|---|
| doble escritura, con reintento del `409` | 115 de 500 | 1 de 10 |
| *outbox* | 0 de 500 | 0 de 10 |
| CDC | 0 de 500 | 0 de 10 |

Una ronda cuenta como divergida si los motores siguen distintos un segundo después. Reproducir:
`node 24-poliglota-la-costura/race.ts --mode dual|outbox|cdc`.

**Interpretación:** la doble escritura diverge sin ninguna falla; los relevos leen el estado actual y no dependen del
orden de llegada.

### M-79 — La reconstrucción completa del servidor de las tabletas

- **Fecha de ejecución:** 12/10/2026 · **Fase:** [24](24-poliglota-la-costura.md) · **Volumen:** `workOrder-1m` en la
  base `postgres`
- **Motor:** Apache CouchDB 3.5.2, base nueva `work_order_1m_v2` · **Línea base:** las cuatro tablas de Postgres

| | |
|---|---|
| órdenes escritas, en `_bulk_docs` de 2000 | 1 000 000 en 132 s (7549/s) |
| tamaño de la base nueva | 582 MiB |
| comparación contra Postgres (`rebuild-couch.ts`) | 1 000 000 de 1 000 000 iguales, 169 s |

Se arma al lado de la vigente, no encima. La comparación de M-74, repetida el mismo día con la búsqueda por claves
que corrigió esta fase, dio otra vez 1 000 000 iguales en 149 s, y 9996 y 4 en `work_order`. Reproducir:
`node 24-poliglota-la-costura/rebuild.ts` y `node 23-poliglota-el-diseno/rebuild-couch.ts --couch work_order_1m_v2`.

**Interpretación:** rearmar el millón cuesta unos cinco minutos, escribir y comprobar, y no depende de cuánto duró
la caída.

### M-80 — La vuelta de las cuatro órdenes de Freddy

- **Fecha de ejecución:** 12/10/2026 · **Fase:** [24](24-poliglota-la-costura.md) · **Volumen:** la base `work_order`
  de CouchDB (Fase 19, 10 000 documentos) → `costura_vuelta`, copia de `expediente`
- **Motor:** el de M-76 · **Línea base:** lo que `expediente` tiene de esas cuatro órdenes

| Pasada | Cambios leídos | Ecos saltados | Informes nuevos |
|---|---|---|---|
| primera | 10 000 | 9996 | 4 |
| segunda, desde el punto guardado | 0 | — | 0 |
| tercera, sin punto | 10 000 | 9996 | 0 |

De los 44 hechos de los cuatro informes: 19 ya están en la fuente, 18 no tienen columna en el esquema de la Fase 01
y 7 la contradicen (cuatro órdenes abiertas que la fuente tiene cerradas, tres horas distintas). Reproducir:
`node 24-poliglota-la-costura/back.ts`.

**Interpretación:** la bandeja es idempotente; lo que falla es el esquema de la fuente, que no tiene dónde escribir
la mitad de lo que la tableta sabe.

### M-81 — La factura: respaldar la fuente y rearmar los derivados

- **Fecha de ejecución:** 12/10/2026 · **Fase:** [25](25-poliglota-la-factura.md) · **Volumen:** la base `postgres`
  (`workOrder-1m` y los vectores de `pirep-1m`, 5897 MiB), `reading-5m` en TimescaleDB y `camilo-10k` en MongoDB
- **Motor:** PostgreSQL 18.6, TimescaleDB 2.30.1, MongoDB 8.0.20 · **Línea base:** las filas de la base original

| Motor | Operación | Tiempo | Tamaño |
|---|---|---|---|
| PostgreSQL | `pg_dump -Fc` | 253 s | 1890 MiB |
| PostgreSQL | `pg_restore`: datos con `-j 4`, índices de a uno, `maintenance_work_mem` 2 GB | 768 s (53 + 715) | — |
| TimescaleDB | rearmar `reading` desde `reading-5m` en una hypertable nueva | 52 s | 5 M de lecturas |
| MongoDB | `mongodump --gzip` / `mongorestore` | 0,1 s / 0,4 s | 326 KiB |

La base restaurada tiene las mismas órdenes, movimientos, piezas y vectores; Mongo, los mismos 7407 componentes.
La primera restauración, con `-j 4` también para los índices, falló: los dos HNSW pidieron 2 GB de memoria compartida
a la vez (E-35). Imágenes: 620, 1344, 460 y 1195 MiB (`base`, `series`, `offline`, `documental`). Reproducir:
`node 25-poliglota-la-factura/factura.ts`.

**Interpretación:** lo que tarda en volver la fuente son sus índices, no sus datos; los derivados se rearman en
segundos o minutos y no necesitan respaldo propio.

---

## 🪞 Las apuestas

La página más citable del curso: cada apuesta falsable, escrita antes de ejecutar, con su
resultado, se gane o se pierda.

| # | Fase | La apuesta | Resultado | Medición |
|---|---|---|---|---|
| 1 | [04](04-documental-romper-y-medir.md) | JSONB con GIN aguanta la consulta polimórfica con menos de 2× de degradación frente a Mongo | **ganada**: 1,00× (y perdida a medias en la ficha: 1 documento contra 50 filas) | [M-04](#m-04--mongo-contra-jsonb-la-ficha-y-la-consulta-polimórfica) |
| 2 | [06](06-clave-valor-romper-y-medir.md) | Una tabla `UNLOGGED` resuelve cada operación de sesión en los mismos viajes que Valkey y ocupa menos de 3× su memoria; lo que las separa es qué se pierde al reiniciar | **ganada**: 1 contra 1 viajes, 0,74× los bytes; ante una caída pierde más la `UNLOGGED` | [M-09](#m-09--la-sesión-en-valkey-y-en-una-tabla-unlogged) |
| 3 | [16](16-vectorial-romper-y-medir.md) | `pgvector` con HNSW aguanta 1 M de vectores con recall a no más de 0,02 del de Qdrant con el mismo `ef`, y me ahorra el motor | **perdida en su letra** (0,946 contra 0,985 con `ef` 40), **ganada en su fondo** sin filtro (empate desde `ef` 80–160); con filtro de selectividad media, 0,10 contra 0,995 | [M-12](#m-12--qdrant-contra-pgvector-sobre-el-mismo-millón) · [M-13](#m-13--el-parecido-con-filtro) |
| 4 | [16](16-vectorial-romper-y-medir.md) | Olvidar los prefijos `query:`/`passage:` baja el acierto de tipo en al menos 2 puntos | **perdida**: 99,98 % sin prefijos contra 99,86 % con ellos; métrica saturada en este corpus | [M-12](#m-12--qdrant-contra-pgvector-sobre-el-mismo-millón) |
| 5 | [08](08-analitico-romper-y-medir.md) | El `ALTER TABLE` de una métrica nueva sobre la tabla ancha de Postgres cuesta un orden de magnitud más que añadirla en columnar | **ganada para la métrica guardada** (13 992 MiB de WAL contra 51,8 MiB); **perdida para la calculada** (Postgres 18 virtual, 0 bytes; DuckDB no puede añadirla) | [M-18](#m-18--una-métrica-nueva-sobre-50-millones) |
| 6 | [10](10-series-romper-y-medir.md) | El particionado declarativo de Postgres llega al 80 % de Timescale (≤ 1,25× en 4 de 5 medidas de forma) y ahorra la extensión | **perdida**: 2 de 5. Gana la retención (0,13×) y una serie (0,47×); pierde tamaño (7,0×), resumen (46,5×) y la flota (2,42×) | [M-25](#m-25--la-tarjeta-timescale-contra-postgres-particionado) |
| 7 | [12](12-busqueda-romper-y-medir.md) | El full-text de Postgres con `tsvector` y GIN cubre el 90 % de este catálogo (≥ 18 de 20 búsquedas) y nadie notará la diferencia | **ganada**: 19 de 20; la que falla es de orden (`ts_rank` sin normalizar). La diferencia está en lo que la batería no mide: facetas (1 petición contra 34 169 páginas) | [M-31](#m-31--la-batería-de-la-apuesta) |
| 8 | [14](14-grafos-romper-y-medir.md) | El grafo gana a `WITH RECURSIVE` a partir del cuarto salto por al menos 5× (*db hits* contra filas del CTE), desde tres piezas | **perdida**: contra `UNION`, 257 487 contra 100 640 y el grafo detrás en las tres piezas; ganada solo contra `UNION ALL` + `CYCLE` (13×). Donde sí gana es en devolver el camino: 1061 contra 1,7 M filas | [M-37](#m-37--la-escalera-de-saltos) · [M-38](#m-38--el-camino-más-corto-devuelto) |
| 9 | [18](18-columnar-romper-y-medir.md) | El particionado de Postgres cubre este caso hasta el volumen de Cóndor (≤ 1,25× en 4 de 5 medidas sobre 50 M), y Cassandra solo gana más allá | **ganada**: 4 de 5. Empata las tres consultas y los bytes escritos (1,00×); pierde el disco (4,59×). El "más allá", como aritmética: ~8,8 TB al año en un nodo con el contrato a 1 Hz | [M-46](#m-46--cargar-50-m-los-bytes-que-llegan-al-disco) · [M-47](#m-47--la-tarjeta-cassandra-contra-postgres-particionado-bien-jugado) |
| 10 | [20](20-offline-romper-y-medir.md) | Tres días desconectado con cien órdenes editadas sincronizan sin intervención manual (con la forma CRDT de la Fase 19) | **ganada**: 89 conflictos, 0 intervenciones, 552 ediciones conservadas. La predicción escrita antes, perderla con entre 1 y 5 disputas, falló: el generador nunca pone dos cambios en la misma posición. Con la forma de siempre, 205 escondidas o 242 perdidas | [M-56](#m-56--la-apuesta-cien-órdenes-tres-días) |
| 11 | [22](22-newsql-romper-y-medir.md) | Un Postgres de un nodo con réplica de lectura resuelve el expediente a una fracción del costo y de la latencia de CockroachDB (≤ 0,5× en 2 de 3 trabajos y ≤ 1/3 de los nodos) | **ganada**, y predicha: 0,02, 0,14 y 0,00× en los tres trabajos, 2 nodos contra 9. Pierde lo que la apuesta dejó fuera: la residencia, y la réplica sirve 73 lecturas viejas sin error durante un corte | [M-67](#m-67--la-apuesta-postgres-con-réplica-contra-cockroachdb) |
