# 🏛️ Fase 18 — Columnar ancha: lo que cobra el trato, y si Cóndor lo necesita

> **Curso:** Ruta NoSQL Lite · Fase 18 de 26 · Bloque IV — Cuando el dato no cabe en un nodo · **10 h**
> **Familia:** columnar ancha · **Motor:** Apache Cassandra 5.0.9 `cassandra@sha256:8819d1b7877e…`, heap fijado
> en 512 MB; un nodo, y el anillo de tres de la Fase 17 para el *hot spot*
> **Línea base:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…` con particionado declarativo **bien
> jugado**: por mes, con un índice por consulta, y una segunda copia partida por hash del vuelo (base `series_base`)
> **Entorno de ejecución:** TypeScript (`cassandra-driver` 4.10.0 y `pg`)
> **Volumen:** la ampliación ×10 de `reading-5m` (`datasetSha256` `8dc486dea089…`), **50 M** lecturas, para la
> apuesta; las 5 M reales y una partición sintética a 1 Hz para lo que se rompe
> **Depende de:** Fase 17 · **Habilita:** Fase 19
> **Apéndices de apoyo:** [`a02`](a02-compose-de-la-ruta.md), [`a03`](a03-clis-de-los-motores.md),
> [`a04`](a04-el-arnes-de-medida.md), [`a09`](a09-catalogo-de-errores.md), [`a10`](a10-licencias-y-riesgo.md)
> **Fecha de verificación ejecutada:** 11/10/2026, en macOS arm64
> **Objetivo:** poner a Cassandra contra Postgres particionado bien jugado en una tarjeta de cinco medidas sobre
> 50 M, medir lo que el trato de la familia cobra —*hot spot*, compactación, tombstones, `ALLOW FILTERING`— y
> encontrar el tamaño al que una partición sin cota deja de poder leerse.

---

## 🧭 1. Dónde estamos

La [Fase 17](17-columnar-levantar-y-modelar.md) modeló las lecturas de vuelo por consulta y dejó un
antecedente incómodo para esta: **en la consulta 1, Postgres particionado iguala la forma de Cassandra**. Tres
particiones y 9666 filas leídas para 9666 devueltas en los dos, a 5 y a 50 M. La diferencia estaba en la
consulta que no sigue la clave de partición de Postgres —un vuelo completo, 61 particiones contra una—, y en
algo que un nodo no deja ver: **dónde vive cada partición** cuando hay varios.

Esta fase pone a Cassandra contra el rival que de verdad tiene. No es *"¿Cassandra o una base relacional?"*:
es *"¿el contrato que Lucía Arango está por firmar necesita repartir las lecturas entre máquinas, o le alcanza
un Postgres particionado bien hecho?"*. Para contestarlo hacen falta una apuesta con número y la factura
completa del trato: compactar, borrar, no poder preguntar otra cosa, y la partition key que no acota el
crecimiento.

---

## 🎯 2. Objetivos de esta fase

1. Cargar las mismas **50 M** lecturas en los dos motores, cada uno con todo lo que necesita para contestar
   las tres consultas, y medir los bytes que cada contenedor escribió al disco para hacerlo.
2. Resolver la apuesta con una **tarjeta de cinco medidas** de forma, y decir cuáles gana Postgres sin
   repartir nada.
3. Provocar un ***hot spot*** en el anillo de tres nodos con una partition key mal elegida, y ver a qué nodo
   le tocó cada escritura.
4. Medir lo que cobra la compactación con la estrategia por defecto y con la de ventanas de tiempo, y lo que
   cobran los **tombstones**, hasta el umbral que hace fallar la lectura.
5. Empujar la consulta con `ALLOW FILTERING` de la Fase 17 hasta que deja de contestar, y llevar una
   **partición sin cota** hasta que se rompe.

> 🧰 **Miniproyecto de esta familia:** [Nodo Sur — tres consumidores que consultan el mismo tráfico de formas
> incompatibles](h-mini-08-columnar-nodo-sur.md). Opcional, fuera de las horas del curso, y no entra a la
> bitácora.

---

## 🪞 3. La apuesta

> 🪞 **Apuesta antes de ejecutar.** Creo que **el particionado declarativo de Postgres cubre este caso hasta el
> volumen al que llega Cóndor, y Cassandra solo empieza a ganar más allá.** Como este curso no mide velocidad,
> "cubre" se lee así: sobre las mismas 50 M lecturas, en una tarjeta de cinco medidas —filas leídas para cada
> una de las tres consultas de la Fase 17, disco que ocupa todo lo que las contesta, y bytes escritos al disco
> para cargarlo—, **Postgres queda a 1,25× o menos de Cassandra en al menos cuatro**. El "más allá" no se
> mide en una máquina de 8 GB: se declara como aritmética, en la sección 4.4.

Escrita en el temario el 30/09/2026 y traducida a la tarjeta el 10/10/2026, antes de ejecutar las cargas, con
una condición dicha antes: Postgres juega **bien**, es decir, con un índice por consulta y con la misma
herramienta que usa Cassandra para la consulta 2, una segunda copia de los datos partida de otra forma.
**Resultado, en la sección 4.3: ganada, cuatro de cinco**, y la única que pierde Postgres es el disco.

---

## 📐 4. La medición contra la línea base

### 4.1 Las mismas 50 M, cargadas por los dos

Cada motor carga **todo lo que necesita para contestar las tres consultas** de la Fase 17. En Cassandra, las
tres tablas de consulta sobre los 50 M. En Postgres, dos tablas particionadas: `reading_part`, por mes, con el
índice `(aircraft, ts)` de la consulta 1 y uno parcial `(ts) WHERE egt_c >= 720` para la 3; y
`reading_part_flight`, **una segunda copia partida por hash del vuelo** en 16 particiones, con su índice
`(flight_id, ts)`, para la 2. Es la idea de Cassandra —duplicar para tener otra forma de partir— hecha en
Postgres. Desde `src/`, con `base` y `columnar` arriba y nada más cargando:

```bash
node 18-columnar-romper-y-medir/baseline.ts            # Postgres, configuración de fábrica
node 18-columnar-romper-y-medir/baseline.ts --tuned    # Postgres, configurado para ingesta
node 18-columnar-romper-y-medir/load.ts                # Cassandra: las tres tablas, 100 M de filas
```

La medida nueva es **cuántos bytes escribió cada contenedor al disco**, leídos del `io.stat` de su cgroup
(`lab/harness/io.ts`, [`a04`](a04-el-arnes-de-medida.md)): suma con la misma regla el WAL, las páginas, el
*commitlog* y las compactaciones. En Cassandra, la medida termina cuando **no queda ninguna compactación
pendiente**, no con la última confirmación.

```text
postgres: 100000000 filas en 2 tablas (61 + 16 particiones, 3 índices) · cargadas en 453 s
  escrito al disco 70255 MiB · de eso, WAL 34505 MiB · en disco al final 14810 MiB
    WAL                                34505 MiB
    páginas de tablas e índices        19869 MiB
    páginas escritas por VACUUM         9068 MiB
    segmentos de WAL nuevos (ceros)      432 MiB
  amplificación: 4.74 bytes escritos por byte que queda
cassandra: 100485390 filas en 3 tablas · confirmadas en 2584 s · sin compactaciones pendientes a los 2596 s
  escrito al disco 70530 MiB · de eso, compactaciones 45653 MiB · en disco al final 3227 MiB
  amplificación: 21.86 bytes escritos por byte que queda
reintentos: 0 por write timeout · 0 por otros motivos
```

**Escriben lo mismo, por caminos opuestos.** Postgres escribe el WAL, las páginas, y VACUUM las reescribe para
marcarlas visibles. Cassandra escribe el *commitlog*, el volcado, y **reescribe al compactar**: 45 653 MiB para
3227 que quedan. Por byte que queda, Cassandra escribe casi cinco veces más; por lectura cargada, lo mismo.

Dos advertencias. Con 512 MB de heap, la memtable se vuelca cada ~22 MiB, y las SSTables de 1,4 MiB pasan por
muchos niveles de compactación; con un heap de producción serían menos, y **eso no se midió aquí**. Y la
configuración de ingesta de Postgres (`max_wal_size` 16 GB, WAL comprimido) bajó el WAL a **25,0 GB** pero
subió el total a **74 159 MiB**: Postgres llena con ceros cada segmento de WAL nuevo (`wal_init_zero`), y con
tanto margen dejó de reciclar los viejos. Fueron 15 376 MiB de ceros. La tarjeta usa la mejor de las dos.

### 4.2 Las tres consultas, con todo puesto

```bash
node 18-columnar-romper-y-medir/scorecard.ts
```

> 📐 **Medición — las tres preguntas sobre 50 M, Postgres bien jugado** · ampliación ×10 de `reading-5m`
> (`8dc486dea089…`) · Cassandra 5.0.9, un nodo · PostgreSQL 18.6 con dos tablas particionadas · segunda de dos
> pasadas · verificado el 11/10/2026
>
> | Pregunta | Devueltas | Cassandra: particiones · SSTables · filas vivas leídas | Postgres: particiones · examinadas · páginas |
> |---|---|---|---|
> | 1 · `HC-2157`, 60 días | 9666 | 3 · 3 · 9666 | 3 · 9666 · 161 |
> | 2 · el vuelo `FL-00002996` completo | 65 | 1 · 1 · 65 | **1** · 65 · 4 |
> | 3 · excedencias de la flota el 19/09/2026 | 780 | 1 · 3 · 780 | 1 · 780 · 176 |
>
> Reproducir: `node 18-columnar-romper-y-medir/scorecard.ts` (desde `src/`).

Con la segunda copia, **la consulta 2 de Postgres toca una partición, no 61**, y las tres consultas leen
exactamente lo que devuelven en los dos motores. **La forma de una consulta la decide cómo
están partidos los datos, no el motor**.

### 4.3 La tarjeta y el resultado de la apuesta

```text
la tarjeta (Cassandra / Postgres; la apuesta pide Postgres ≤ 1,25× en cuatro de cinco)
  filas leídas · 1 · HC-2157, 60 días              9666 ·     9666 filas  → 1.00× ✓ 3 / 3 part.
  filas leídas · 2 · vuelo FL-00002996               65 ·       65 filas  → 1.00× ✓ 1 / 1 part.
  filas leídas · 3 · excedencias, 2026-09-19        780 ·      780 filas  → 1.00× ✓ 1 / 1 part.
  disco de lo que contesta las tres                3227 ·    14810 MiB    → 4.59× ✗
  escrito al disco para cargarlo                  70530 ·    70255 MiB    → 1.00× ✓ (la otra configuración: 74159 MiB)
  Postgres llega en 4 de 5
```

> 🪞 **Resultado: ganada.** Postgres particionado bien jugado queda a 1,25× o menos en **cuatro de cinco**:
> empata las tres consultas (1,00×) y los bytes escritos para cargar (1,00×). Pierde **el disco: 4,59×**,
> 14 810 MiB contra 3227. Y la pérdida no es de modelo: es la compresión por bloques de las SSTables (ratio
> 0,50) contra filas sin comprimir y tres índices.

Ganar así deja una pregunta más útil: **¿qué compra Cassandra, si sobre una máquina no compra lecturas ni
escrituras?** Lo que esta tarjeta no ve: que cualquier nodo acepte escrituras sin un primario, y que añadir un
nodo reparta lo que hay. Postgres particionado reparte entre tablas, no entre máquinas. La sección 4.4 dice
cuándo importa eso, y las 4.5 a 4.8 cobran la factura.

### 4.4 El "más allá", como aritmética

Las 50 M de la apuesta son cinco años de 170 aeronaves a una lectura por minuto: más que la flota de Cóndor
con el registro de hoy. El contrato que Lucía negocia no cabe en una máquina de 8 GB, así que va como
**aritmética declarada**:

| | Postgres (dos copias, sin comprimir) | Cassandra (dos copias, ratio 0,50) |
|---|---|---|
| una fila por segundo con 1000 parámetros enteros, en cada copia | ~4 KB | ~2 KB |
| 140 aeronaves × 6 h de vuelo al día | 3 024 000 filas al día | 3 024 000 filas al día |
| volumen al día | ~24 GB | ~12 GB × 3 réplicas |
| volumen al año | **~8,8 TB en un nodo** | ~4,4 TB × 3, repartidos entre los nodos |
| escritura sostenida, en vuelo | ~140 filas/s · ~5 MB/s con la amplificación de la sección 4.1 | lo mismo, repartido |

**El ritmo de escritura no es el problema**: ciento cuarenta filas por segundo las absorbe cualquier Postgres.
Lo que empuja hacia la familia es **el volumen acumulado en una máquina**: casi 9 TB el primer año y 44 TB a los
cinco, con su VACUUM, su respaldo y una réplica que, a un supuesto de 200 MB/s, tarda unas 12 horas en
reconstruirse por cada año guardado. Ese es el "más allá", y empieza con el contrato, no antes.

### 4.5 Lo que la tarjeta no ve: el *hot spot*

Una partition key mal elegida no se nota en un nodo; se nota en un anillo. `hotspot.sh` carga el último mes de
la flota en el anillo de la Fase 17, en dos tablas: la de la consulta 1, partida por `(aircraft, month)`, y otra
partida **solo por `month`**, la que alguien escribe para *"ver la flota del mes de una vez"*. Con RF 1, cada
partición vive en un solo nodo, como en un anillo con más nodos que réplicas.

```bash
docker compose -f lab/compose.anillo.yaml up -d --wait     # con el laboratorio detenido
18-columnar-romper-y-medir/hotspot.sh
docker compose -f lab/compose.anillo.yaml down -v
```

```text
== 2026-09: 111863 lecturas de 17 aeronaves
== filas por nodo
  c1 · por (aeronave, mes)   64999 · por mes       0
  c2 · por (aeronave, mes)   32500 · por mes  111863
  c3 · por (aeronave, mes)   14364 · por mes       0
```

Partida por mes, **un nodo recibió las 111 863 escrituras y los otros dos, ninguna**, y así será mientras dure
el mes. Añadir nodos no ayuda: una partición no se divide. La clave buena tampoco reparte parejo, **58, 29 y
13 %**: con 17 particiones, el hash no tiene con qué promediar. Con 140 aeronaves o un bucket horario se
empareja. Las filas por nodo salen de `nodetool getendpoints`; el contador *"Local write count"* cuenta
mutaciones, y `COPY` agrupa varias filas en una.

### 4.6 La compactación: la estrategia por defecto contra la de series

La compactación es la mayor parte de lo que escribe Cassandra, y se elige por tabla. `compaction.ts` carga las
5 M lecturas en dos tablas iguales salvo la estrategia, en orden de tiempo, con la marca de cada lectura (`USING
TIMESTAMP`, como si llegaran en vivo), y vuelca la memtable cada semana de datos:

```bash
node 18-columnar-romper-y-medir/compaction.ts
```

```text
reading_stcs · 296 volcados · 98 compactaciones que reescribieron 2422 MiB · escrito al disco 3278 MiB · en disco 100 MiB · 2 SSTables
  consulta 1 (3 meses)      devueltas 9666 · particiones 3 · sstables 3
  el último mes de HC-2157  devueltas 4832 · particiones 1 · sstables 1
reading_twcs · 296 volcados · 112 compactaciones que reescribieron 167 MiB · escrito al disco 965 MiB · en disco 100 MiB · 62 SSTables
  consulta 1 (3 meses)      devueltas 9666 · particiones 3 · sstables 5
  el último mes de HC-2157  devueltas 4832 · particiones 1 · sstables 2
```

*SizeTiered* (STCS), la de fábrica, junta SSTables de tamaño parecido sin mirar su época: **cada lectura de 2021
se reescribió una y otra vez**, 2422 MiB para dejar 100. *TimeWindow* (TWCS) junta solo dentro de una ventana de
30 días y **no vuelve a tocar una ventana cerrada**: 167 MiB, **14,5 veces menos**. Paga al leer: la consulta 1
abre cinco SSTables en vez de tres, porque sesenta días cruzan ventanas.

Es la estrategia para las lecturas de Cóndor, con dos condiciones: **los datos llegan en orden** (una lectura
tardía reabre una ventana cerrada), y **cuenta la marca de escritura, no la columna `ts`**: cargar la historia
sin `USING TIMESTAMP` la mete toda en la ventana de hoy (ejercicio 18).

### 4.7 Borrar: el tombstone

En Cassandra, **borrar es escribir**: un `DELETE` escribe una marca, el *tombstone*, que las lecturas leen y
saltan hasta que una compactación la purga, y no antes de `gc_grace_seconds` (diez días), para que una réplica
caída alcance a enterarse. `tombstones.ts` lo mide sobre una copia de la partición de `HC-2157` en octubre de
2025, y `deletes-pg.ts` hace lo mismo en Postgres:

```bash
node 18-columnar-romper-y-medir/tombstones.ts
node 18-columnar-romper-y-medir/deletes-pg.ts
```

```text
la partición copiada                 devueltas  5040 · filas vivas leídas  5040 · tombstones leídos      0 · sstables 1 · en disco 73 KiB
5040 DELETE, uno por fila            devueltas     0 · filas vivas leídas     0 · tombstones leídos   5040 · sstables 2 · en disco 126 KiB
compactada (gc_grace_seconds 10 días) devueltas     0 · filas vivas leídas     0 · tombstones leídos   5040 · sstables 1 · en disco 53 KiB
un DELETE del rango del mes          devueltas     0 · filas vivas leídas     0 · tombstones leídos      2 · sstables 2 · en disco 78 KiB
fila por fila, gc_grace 0, compactada devueltas     0 · filas vivas leídas     0 · tombstones leídos      0 · sstables 0 · en disco 0 KiB
```

Borrar fila por fila **hizo crecer la partición** de 73 a 126 KiB, y la consulta lee **5040 marcas para
devolver cero**. Compactar dentro del plazo quita los datos y deja las marcas: 53 KiB de nada. Borrar **el
rango de una vez** deja una marca con dos bordes. Solo con `gc_grace_seconds` en 0 la partición queda vacía, y
eso en un anillo tiene su riesgo (sección 9). Postgres, con el mismo borrado:

```text
la partición copiada           devueltas  5040 · examinadas  5040 · páginas   64 · tuplas muertas     0 · en disco 696 KiB
5040 DELETE (WAL 502 KiB)      devueltas     0 · examinadas     0 · páginas   64 · tuplas muertas  5040 · en disco 696 KiB
después de VACUUM              devueltas     0 · examinadas     0 · páginas    0 · tuplas muertas     0 · en disco 200 KiB
```

🩻 **Esto sí funciona igual**: Postgres también deja marcas —5040 tuplas muertas, 64 páginas para devolver
nada—. La diferencia es **cuándo se limpian**: VACUUM, en cuanto ninguna transacción las ve; Cassandra, a los
diez días. Por eso aquí **el modelo se diseña para no borrar fila por fila**: la partición, el rango, o un TTL.
Y pasado `tombstone_failure_threshold` (100 000), la lectura no se degrada: **se cancela**.

```text
    999 marcas · devueltas 0
   1001 marcas · devueltas 0 · aviso: Read 0 live rows and 1001 tombstone cells for query SELECT egt_c FROM condor.reading_tomb WHERE … (see tombstone_warn_threshold)
  99999 marcas · devueltas 0 · aviso: Read 0 live rows and 99999 tombstone cells for query SELECT egt_c FROM condor.reading_tomb WHERE … (see tombstone_warn_threshold)
 100001 marcas · ResponseError: Server failure during read query at consistency LOCAL_ONE (1 responses were required but only 0 replicas responded, 1 failed)
```

A 100 001, la partición **deja de poder leerse**, con un mensaje que no dice por qué; el porqué está en el log
del nodo (E-60).

### 4.8 `ALLOW FILTERING`, hasta que deja de contestar

`filtering.ts` hace crecer la tabla por entidad de la Fase 17 de 5 M en 5 M, con copias que la consulta no pide,
y la repite después de cada una:

```bash
node 18-columnar-romper-y-medir/filtering.ts
```

```text
  5000000 filas · devueltas 9666 · páginas 2 · filas vivas leídas 5000000 · 9278 ms en la traza
 10000000 filas · falla a los 5.0 s · ResponseError: Server failure during read query at consistency LOCAL_ONE (1 responses were required but only 0 replicas responded, 1 failed)
```

**A 10 M deja de contestar**: el nodo **cancela toda lectura local que pasa de 5 s**. El `debug.log` lo dice: a
5 M, *"2 operations were slow"*, con páginas de 4352 y 4873 ms; a 10 M, *"1 operations timed out … total time
5003 msec, timeout 5000 msec"*. Es la consulta que a 10 k tardaba 22 ms. Y el mensaje del cliente es **idéntico
al de los tombstones**: solo el log del nodo dice cuál fue (E-61).

---

## 💥 5. El punto de rotura

La partición sin cota es la tabla de la consulta 1 **sin el mes**: `PRIMARY KEY ((aircraft), ts)`.
`unbounded.ts` la hace crecer a una lectura por segundo y en cada escalón pide la última hora, la EGT máxima de
la historia, y la historia entera de una vez para exportarla.

```bash
node 18-columnar-romper-y-medir/unbounded.ts     # con columnar arriba y nada más cargando
```

> 💥 **Rotura — la partición sin cota** · Cassandra 5.0.9, un nodo, heap de 512 MB · una aeronave a 1 Hz ·
> verificado el 11/10/2026, dos corridas
>
> ```text
> == 1000000 filas (12 días a 1 Hz) · partición de 18 MiB en 3 SSTables
>   la última hora                     devueltas 3600 · sstables 1 · 5 ms en la traza · 0.0 s
>   la EGT máxima de toda la historia  max 739 · 1.3 s
>   la historia entera en una página   devueltas 1000000 · 3.2 s
> == 2000000 filas (23 días a 1 Hz) · partición de 35 MiB en 3 SSTables
>   la última hora                     devueltas 3600 · sstables 1 · 6 ms en la traza · 0.0 s
>   la EGT máxima de toda la historia  max 739 · 2.1 s
>   la historia entera en una página   falla a los 120.0 s · OperationTimedOutError: The host 127.0.0.1:19042 did not reply before timeout 120000 ms
> == 5000000 filas (58 días a 1 Hz) · partición de 88 MiB en 3 SSTables
>   la EGT máxima de toda la historia  falla a los 5.0 s · ResponseError: Server timeout during read query at consistency LOCAL_ONE (0 replica(s) responded over 1 required)
>   la historia entera en una página   falla a los 3.0 s · ResponseError: Server failure during read query at consistency LOCAL_ONE (1 responses were required but only 0 replicas responded, 1 failed)
> == 10000000 filas (116 días a 1 Hz) · partición de 177 MiB en 7 SSTables
>   la última hora                     devueltas 3600 · sstables 1 · 5 ms en la traza · 0.0 s
>   la EGT máxima de toda la historia  falla a los 5.0 s · ResponseError: Server timeout during read query …
> ```

**A 2 M filas —23 días, 35 MiB— leer la partición de una vez agota el heap** (`OutOfMemory error letting the
JVM handle the error`). A 5 M, la EGT máxima ya no termina en los 5 s del nodo. **La última hora sigue en 5 ms a
cualquier tamaño**, y por eso la partición sin cota engaña: la consulta de todos los días nunca se entera.

Y el nodo **no se cae: queda peor**. El JVM sobrevive al error matando el hilo que lo recibió. En la primera
corrida, tras cuatro errores de memoria y una pausa de recolección de **84 s**, el bucle de eventos del
transporte nativo murió y el nodo empezó a cerrar cada conexión nueva (*"Force-closing a channel whose
registration task was not accepted by an event loop"*). En la segunda, eso pasó **a los 2 M**, en el acto. En
las dos, `nodetool info` seguía diciendo `Native Transport active: true`, y Docker lo dio por sano **14
minutos** más, hasta agotar los 60 reintentos de su *healthcheck*. Solo se arregla reiniciándolo (E-60 a E-63
en [`a09`](a09-catalogo-de-errores.md)). El *guardrail* `partition_size_warn_threshold` no lo habría evitado:
según su configuración, **solo escribe en el log**.

**Lo que hay que cambiar para salir:** un bucket en la partition key —a 1 Hz, un día son 86 400 filas, unos
1,5 MiB—, y paginar siempre. El driver pagina de a 5000 si nadie le pide otra cosa.

---

## 🚑 6. Salir de aquí

Cuando columnar ancha ya duele, en orden de costo:

1. **Configuración.** TWCS en las tablas de series (sección 4.6), paginación siempre en el driver, y los
   umbrales de lectura de Cassandra 5 (`read_thresholds_enabled`, `local_read_size_fail_threshold`), que
   cancelan una lectura demasiado grande en vez de dejar que agote el heap. **Los umbrales no se probaron en
   esta fase**: la sección 5 corrió con la configuración de fábrica, que los trae apagados.
2. **Modelo.** Un bucket de tiempo en toda partition key que crece con el tiempo —el día, a 1 Hz—, otro
   componente en la que concentra escrituras (sección 4.5), borrar por rango o con TTL en vez de fila por fila
   (sección 4.7), y una tabla por consulta en vez de `ALLOW FILTERING`. Cada uno cuesta una tabla nueva y su
   backfill: la Fase 17 midió uno, 5 M de filas leídas para escribir 62 486.
3. **Motor.** Si el volumen cabe en una máquina, **Postgres particionado contesta lo mismo** (sección 4.3,
   cuatro de cinco); si las consultas son exploratorias, son de la familia analítica (Fases 07 y 08).
4. **Arquitectura.** Si el volumen no cabe, más nodos: es para lo que existe la familia. ScyllaDB habla el
   mismo CQL y el modelado no cambia, pero su licencia es otra ([`a10`](a10-licencias-y-riesgo.md)).

---

## ❓ 7. Las cinco preguntas, respondidas para columnar ancha

1. **Frontera transaccional.** Una partición, y ni eso como en Postgres: cada escritura es un *upsert* sin
   aislamiento, y un lote con registro es atómico tarde o temprano, no aislado (Fase 17).
2. **Consultas conocidas.** **Es la pregunta de esta familia.** Si las conoces y son estables, una tabla por
   consulta lee exactamente lo que devuelve. Si no, cada consulta nueva es una tabla y un backfill, o un
   `ALLOW FILTERING` que deja de contestar a 10 M de filas (sección 4.8).
3. **Unidad de lectura.** Una partición, o un trozo contiguo de ella. Con un límite que la familia no impone
   y hay que diseñar: la partición sin cota de la sección 5.
4. **Saltos.** Ninguno. No hay `JOIN`, y el dato se guarda ya junto.
5. **Exactitud o parecido.** Exactitud, al nivel de consistencia que elijas: con `ONE`, la Fase 17 leyó un
   valor que ya no existía.

---

## ⚖️ 8. Veredicto honesto: cuándo NO usar esto

> ⚖️ **No la uses si el volumen cabe en una máquina.** Sobre 50 M lecturas, Postgres particionado bien jugado
> lee lo mismo en las tres consultas y escribe lo mismo para cargarlas (cuatro de cinco medidas); solo ocupa
> más disco, **4,59×**. **No la uses si no conoces tus consultas**: la consulta que no tiene tabla deja de
> contestar a **10 M** filas. **No la uses si tus datos se corrigen o se borran de a uno**: cada borrado es una
> marca que se lee diez días, y a **100 001** marcas la partición no se puede leer. **Y no la uses sin acotar
> la partición**: a **2 M** filas, leerla de una vez agotó el heap y el nodo terminó rechazando conexiones.
>
> **Úsala** cuando las escrituras son masivas y no se corrigen, las consultas se conocen antes que los datos, y
> **el volumen ya no cabe en un nodo**: ahí ninguna medida de esta fase la hace perder, porque lo que compra
> es repartir.

**Si no conoces tus consultas, esta familia es una trampa cara.**

Para Cóndor: **hoy no**. Treinta aeronaves a una lectura por minuto caben en Postgres particionado con años de
margen, y la tarjeta lo dice con números. **Con el contrato a 1 Hz y mil parámetros**, las lecturas de vuelo
—y solo ellas— pasan a esta familia: casi 9 TB al año en una máquina (sección 4.4). Las órdenes, las piezas y
la historia de la flota se quedan donde están. El miniproyecto de Nodo Sur está del otro lado de esa línea, con
cientos de millones de filas al día, y por eso allí la familia gana sin discusión.

**ScyllaDB** es la alternativa natural: el mismo CQL y mucha menos memoria (90 MiB contra 1,04 GiB en reposo).
El curso la descartó por su licencia, *source-available* desde la 2025.1 ([`a10`](a10-licencias-y-riesgo.md)).

---

## ⚠️ 9. Errores comunes y diagnóstico

**Demasiados tombstones en una partición** (E-60 en [`a09`](a09-catalogo-de-errores.md)). El cliente recibe un
mensaje genérico:

```text
ResponseError: Server failure during read query at consistency LOCAL_ONE (1 responses were required but only 0 replicas responded, 1 failed)
```

🩺 El motivo está en el log del nodo: `Scanned over 100001 tombstones during query '…'; query aborted`. Desde
1001 marcas, el driver ya traía un aviso en `info.warnings`. Salir: borrar por rango o con TTL.

**Una lectura cancelada a los 5 s** (E-61). **El mismo mensaje del cliente**, con otra causa: el nodo cancela
toda lectura local que pasa de su tiempo. 🩺 En el `debug.log`, `operations timed out … total time 5003 msec,
timeout 5000 msec`, y antes, como aviso, `operations were slow`. Salir: la tabla que contesta esa consulta.
Subir el tiempo mueve el borde, no lo quita.

**Un agregado o una lectura grande que no termina** (E-62):

```text
ResponseError: Server timeout during read query at consistency LOCAL_ONE (0 replica(s) responded over 1 required)
```

🩺 Sobre una sola partición, quiere decir que es demasiado grande para leerla entera. Salir: el bucket de la
sección 5.

**El nodo vivo que no acepta clientes** (E-63). El driver dice `Socket was closed` o `NoHostAvailableError`, y
`cqlsh`, `Unable to connect to any servers`; mientras tanto, `nodetool info` dice `Native Transport active: true`.
🩺 En el log, un `OutOfMemory error letting the JVM handle the error` y después `Force-closing a channel …` con
cada conexión. Salir: reiniciar el nodo, y borrar a mano el volcado de heap de 593 MiB que deja en
`/var/log/cassandra`.

**TWCS que compacta como STCS.** Sin mensaje. 🩺 `nodetool tablestats` muestra pocas SSTables enormes en una tabla
de ventanas. Los datos se escribieron con la marca de tiempo de la carga, no la de la lectura: falta `USING
TIMESTAMP`.

**`gc_grace_seconds` en 0 para ahorrar disco.** Sin mensaje: la documentación advierte que, con una réplica
caída más que ese plazo, una fila borrada puede volver. **No se provocó aquí** (ejercicio 26).

---

## 📋 10. Checklist de validación

```text
[ ] Las dos cargas de 50 M: ~70 GB escritos cada una; 3227 MiB en Cassandra contra 14 810 en Postgres
[ ] Sé de dónde salen los 45 653 MiB de compactación, y por qué el heap de 512 MB los infla
[ ] La tarjeta: 4 de 5, y la única que pierde Postgres es el disco (4,59×)
[ ] Con la segunda copia por hash, la consulta 2 de Postgres toca 1 partición
[ ] El hot spot: por mes, un nodo con las 111 863 filas; por (aeronave, mes), 58/29/13 %
[ ] STCS reescribe 2422 MiB y TWCS 167 para los mismos 100 MiB
[ ] Borré una partición fila por fila y la lectura leyó 5040 tombstones; a 100 001 se cancela
[ ] ALLOW FILTERING deja de contestar a 10 M filas, cancelada a los 5 s
[ ] La partición sin cota agota el heap a 2 M filas, y sé por qué nodetool dice que el nodo está bien
[ ] M-46 a M-52 en la bitácora, la apuesta 9 en su tabla, E-60 a E-63 en a09
```

---

## 🧪 11. Ejercicios (28)

Desde `src/`, con los perfiles `base` y `columnar` arriba y las cargas de la sección 4.1 hechas. Los ejercicios del
anillo piden detener antes el laboratorio, y los de la sección 5 terminan con el nodo reiniciado.

### 🟢 Fácil — reproducir (1–7)

#### 🟢 Ejercicio 1 — La tarjeta

Corre `scorecard.ts`.

**Objetivo:** las cinco filas, y cuál esperas que cambie en otra máquina.

#### 🟢 Ejercicio 2 — Los bytes de tu carga

Lee el `io.stat` del contenedor `columnar` antes y después de cargar `reading-1m` en una tabla nueva.

**Objetivo:** cuántos MiB escribió el disco, y cuántos quedaron según `tablestats`.

#### 🟢 Ejercicio 3 — La consulta 2 en las dos copias

Pide el vuelo `FL-00002996` a `reading_part` y a `reading_part_flight` con `EXPLAIN (ANALYZE, BUFFERS)`.

**Objetivo:** particiones y páginas de cada una.

#### 🟢 Ejercicio 4 — Las SSTables de cada estrategia

Corre `compaction.ts` y lista las SSTables de las dos tablas con `nodetool tablestats`.

**Pregunta:** ¿por qué TWCS tiene 62?

#### 🟢 Ejercicio 5 — Un tombstone en la traza

Borra una sola lectura de `reading_by_aircraft_month` y lee su partición con `TRACING ON`.

**Objetivo:** la línea de la traza que cuenta la marca.

#### 🟢 Ejercicio 6 — El aviso que nadie lee

Repite el umbral de `tombstones.ts` con 1500 marcas desde `cqlsh`.

**Pregunta:** ¿dónde aparece el aviso en `cqlsh`, y dónde en el driver?

#### 🟢 Ejercicio 7 — El log de la cancelación

Busca en el `debug.log` del nodo las líneas `operations were slow` de la sección 4.8.

**Objetivo:** el tiempo de cada página de la consulta a 5 M.

### 🟡 Intermedio — medir de otra forma (8–14)

#### 🟡 Ejercicio 8 — Postgres sin la segunda copia

Calcula la tarjeta sin `reading_part_flight`: la consulta 2 sobre `reading_part`, con un índice `(flight_id, ts)`.

**Objetivo:** las cinco filas otra vez, y si la apuesta se sigue ganando.

#### 🟡 Ejercicio 9 — `wal_init_zero`

Repite `baseline.ts --tuned` con `wal_init_zero = off`.

**Objetivo:** el total escrito, y cuánto bajó frente a 74 159 MiB.

#### 🟡 Ejercicio 10 — Índices después de cargar

Repite `baseline.ts` creando los tres índices al final.

**Pregunta:** ¿cuánto bajan los bytes escritos, y por qué una ingesta continua no puede hacerlo?

#### 🟡 Ejercicio 11 — Compactación con más heap

Sube el heap de `columnar` a 1 GB, si tu máquina lo permite, y repite `load.ts`.

**Objetivo:** los MiB de compactación contra 45 653, y el tamaño de las SSTables recién volcadas.

#### 🟡 Ejercicio 12 — Ventanas de 7 días

Repite `compaction.ts` con TWCS de 7 días.

**Objetivo:** SSTables, MiB reescritos y SSTables que abre la consulta 1.

#### 🟡 Ejercicio 13 — El TTL

Escribe la partición de `tombstones.ts` con `USING TTL 60` y léela pasado el minuto.

**Pregunta:** ¿cuántos tombstones lee la consulta, y cuándo desaparecen?

#### 🟡 Ejercicio 14 — El hot spot con RF 3

Repite `hotspot.sh` con `replication_factor` 3.

**Pregunta:** ¿por qué desaparece el hot spot, y por qué volvería con seis nodos?

### 🟠 Difícil — diagnosticar y decidir (15–21)

#### 🟠 Ejercicio 15 — El bucket que arregla la partición por mes

Rediseña `hot.by_month` para que la flota del mes se reparta sin cambiar la consulta más que en sus claves.

**Objetivo:** el `CREATE TABLE`, las filas por nodo, y cuántas particiones nombra la consulta.

#### 🟠 Ejercicio 16 — Predecir el borde de `ALLOW FILTERING`

Antes de medir, predice a cuántas filas deja de contestar la consulta de la sección 4.8 si devolviera la mitad.

**Objetivo:** tu número escrito antes, y medirlo con otra aeronave.

#### 🟠 Ejercicio 17 — La partición acotada

Repite `unbounded.ts` con `PRIMARY KEY ((aircraft, day), ts)`.

**Objetivo:** que ninguna lectura falle a 10 M filas, y cómo se escribe ahora la EGT máxima de la historia.

#### 🟠 Ejercicio 18 — TWCS sin `USING TIMESTAMP`

Quita `USING TIMESTAMP` de `compaction.ts`.

**Objetivo:** SSTables y MiB reescritos, comparados con STCS.

#### 🟠 Ejercicio 19 — Los umbrales de lectura

Activa `read_thresholds_enabled` y `local_read_size_fail_threshold` en `columnar` y repite la sección 5.

**Pregunta:** ¿qué mensaje recibe ahora el cliente a 2 M, y queda vivo el nodo?

#### 🟠 Ejercicio 20 — Un healthcheck que sí avisa

Diseña un healthcheck para el servicio `columnar` que marque el nodo de la sección 5 como enfermo en menos de un
minuto, sin romper el arranque de un minuto.

**Objetivo:** el bloque del compose, y el tiempo hasta `unhealthy` contra 14 minutos.

#### 🟠 Ejercicio 21 — Borrar los datos de un suscriptor

Un operador pide borrar las lecturas de una aeronave de los últimos 90 días en las tres tablas.

**Objetivo:** los `DELETE` que escribirías en cada tabla, y cuántas marcas deja cada uno.

### 🔴 Muy difícil — romper y autopsias (22–28)

#### 🔴 Ejercicio 22 — La autopsia de la partición por aeronave

Un equipo eligió `((aircraft), ts)` *"porque la consulta siempre es por aeronave"*.

**Objetivo:** los cinco pasos de la Fase 00, con la sección 5 como factura, incluido el nodo que nadie vio caer.

#### 🔴 Ejercicio 23 — La apuesta, al revés

Escribe una apuesta nueva, antes de medir, en la que Cassandra le gane a Postgres en una máquina.

**Objetivo:** la medida que elegiste, la tarjeta, y publicarla se gane o se pierda.

#### 🔴 Ejercicio 24 — El cruce

Con los bytes por lectura de la sección 4.1, calcula a cuántas aeronaves a 1 Hz el volumen de un año pasa de 2 TB
en un Postgres.

**Objetivo:** la cuenta declarada, y qué supuesto la mueve más.

#### 🔴 Ejercicio 25 — Seis nodos

Con lo que cabe en tu máquina, arma un anillo de cuatro nodos con RF 3 y repite el hot spot.

**Objetivo:** las filas por nodo, y si el reparto se parece al de RF 1.

#### 🔴 Ejercicio 26 — Tombstones en un anillo

En el anillo, borra con un nodo caído, baja `gc_grace_seconds` a 60, compacta y devuelve el nodo.

**Pregunta:** ¿vuelve la fila borrada? Documenta lo que ves, salga o no.

#### 🔴 Ejercicio 27 — El veredicto de Nodo Sur, con números de Cóndor

Sin mirar el miniproyecto, escribe el veredicto de una empresa con cientos de millones de filas al día y tres
consumidores.

**Objetivo:** una página, con la sección 4.4 como regla para decidir qué consulta se va.

#### 🔴 Ejercicio 28 — Tu predicción de la Fase 17

Saca la predicción que escribiste en el ejercicio 28 de la Fase 17 y compárala con la sección 4.

**Objetivo:** en qué acertaste, en qué no, y qué medida te faltaba.

### 🔥 Opcionales

- **Leveled compaction (LCS)** contra STCS y TWCS con la misma carga.
- **Unified compaction (UCS)**, la estrategia nueva de Cassandra 5, sobre `compaction.ts`.

---

## 📚 12. Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación cubre la última versión. Esta fase se verificó con
> Apache Cassandra 5.0.9 y PostgreSQL 18.6.

- **Compactación en Cassandra** — https://cassandra.apache.org/doc/latest/cassandra/managing/operating/compaction/index.html
  — STCS, TWCS, LCS y UCS.
- **TWCS** — https://cassandra.apache.org/doc/latest/cassandra/managing/operating/compaction/twcs.html — ventanas
  y datos que llegan tarde.
- **Tombstones** — https://cassandra.apache.org/doc/latest/cassandra/managing/operating/compaction/tombstones.html
  — `gc_grace_seconds` y por qué existe.
- **PostgreSQL 18, WAL** — https://www.postgresql.org/docs/18/runtime-config-wal.html — `max_wal_size`,
  `wal_compression` y `wal_init_zero`.
- **PostgreSQL 18, particionado** — https://www.postgresql.org/docs/18/ddl-partitioning.html — rango y hash.
- **Kleppmann, *Designing Data-Intensive Applications*** (O'Reilly, 2017) — capítulo 3, árboles LSM contra
  B-trees y amplificación de escritura; capítulo 6, particiones calientes.
- **Carpenter y Hewitt, *Cassandra: The Definitive Guide*** (O'Reilly, 3.ª ed., 2020) — capítulos de
  compactación y de modelado con buckets.
- **ScyllaDB**, la licencia, en [`a10`](a10-licencias-y-riesgo.md).

**Orden sugerido:** Kleppmann, capítulo 3, antes de la sección 4.1; compactación y TWCS antes de la 4.6;
tombstones antes de la 4.7.

---

## 🏁 13. Resultado de la fase

```text
la tarjeta sobre 50 M          Postgres llega en 4 de 5; pierde el disco (4,59×)
escrito al disco para cargar   Cassandra 70 530 MiB · Postgres 70 255 MiB
hot spot (partición por mes)   un nodo, 111 863 filas; los otros dos, ninguna
compactación                   STCS 2422 MiB · TWCS 167 MiB, para 100 MiB
tombstones                     5040 marcas para devolver 0; a 100 001, la lectura se cancela
ALLOW FILTERING                deja de contestar a 10 M filas
partición sin cota             heap agotado a 2 M filas (35 MiB); nodo vivo que no acepta clientes
```

Pusiste a Cassandra contra el rival que tiene y **ganaste la apuesta**: sobre una máquina, Postgres particionado
bien jugado lee lo mismo y escribe lo mismo, y solo ocupa más disco. Lo que Cassandra compra no se ve en un nodo,
y lo que cobra sí: compactaciones que reescriben catorce veces lo guardado, borrados que se leen diez días,
consultas sin tabla que dejan de contestar y particiones que, sin cota, dejan un nodo vivo e inútil.

> **La señal de que quedó bien:** *"Puedo decir a qué volumen le toca a Cóndor esta familia, con la cuenta en la
> mano, y qué partition key no dejaría pasar en una revisión."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-18-columnar-romper-y-medir -m "F18 cerrada: apuesta 9 ganada (Postgres particionado bien jugado llega en 4 de 5 sobre 50 M; pierde el disco, 4,59×); escriben lo mismo (~70 GB); hot spot por mes, un nodo con todo; STCS 2422 MiB contra TWCS 167; tombstones, cancelación a 100 001; ALLOW FILTERING muere a 10 M; partición sin cota agota el heap a 2 M y deja un nodo zombi"
> ```
>
> Commits de la fase con prefijo `f18:`, los de ejercicio `f18 ej9: …`.
