# 📓 Bitácora de medición

> **Curso:** Ruta NoSQL Lite · documento vivo
> **Qué es:** todas las mediciones publicadas del curso, en orden de ejecución, con los cinco datos
> de toda medición —qué se midió, volumen con su hash, motor y digest, máquina si hay tiempos, y el
> comando exacto— (la ficha de [`a04`](a04-el-arnes-de-medida.md)). No hay un archivo de latencias,
> porque este curso **mide la forma y no la velocidad**.

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
| analítico embebido | F07–F08 | — |
| series temporales | F09–F10 | — |
| búsqueda | F11–F12 | — |
| grafos | F13–F14 | — |
| vectorial | F15–F16 | [M-11](#m-11--like-contra-vectores-y-la-búsqueda-exacta-hecha-por-parecido) · [M-12](#m-12--qdrant-contra-pgvector-sobre-el-mismo-millón) · [M-13](#m-13--el-parecido-con-filtro) · [M-14](#m-14--el-índice-que-no-cabe) |
| columnar ancha | F17–F18 | — |
| offline-first | F19–F20 | — |
| NewSQL | F21–F22 | — |
| políglota | F23–F25 | — |

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
