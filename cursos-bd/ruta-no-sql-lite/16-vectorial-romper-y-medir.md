# 🧬 Fase 16 — Vectorial: un millón de reportes, Qdrant contra `pgvector`, y dónde de verdad se separan

> **Curso:** Ruta NoSQL Lite · Fase 16 de 25 · Bloque III — Preguntas que no sabes escribir en SQL · **10 h**
> **Familia:** vectorial · **Motor:** Qdrant 1.19.1 `qdrant/qdrant@sha256:12364fe851b9…`
> **Línea base:** PostgreSQL 18.6 con pgvector 0.8.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…` (HNSW)
> **Entorno de ejecución:** Python para los embeddings y la carga, TypeScript para la medición
> **Volumen:** `pirep-1m` (`datasetSha256` `d8a956d0c85a…`): un millón de vectores de 384 dimensiones,
> los mismos bytes en los dos motores (`pirep-e5-passage.f32`, `3a97c8b28f60…`)
> **Depende de:** Fase 15 · **Habilita:** Fase 17 (en el orden canónico)
> **Apéndices de apoyo:** [`a02`](a02-compose-de-la-ruta.md), [`a04`](a04-el-arnes-de-medida.md),
> [`a07`](a07-postgres-linea-base.md), [`a09`](a09-catalogo-de-errores.md)
> **Fecha de verificación ejecutada:** 30/09/2026, en macOS arm64
> **Objetivo:** medir Qdrant contra un `pgvector` bien jugado sobre el mismo millón, en recall y no en
> velocidad, y encontrar la pregunta exacta en la que dejan de ser intercambiables.

---

## 🧭 1. Dónde estamos

La [Fase 15](15-vectorial-levantar-y-modelar.md) dejó dos cosas: una búsqueda que encuentra *"golpeteo
al extender"* cuando se pide *"ruido metálico al bajar tren"*, y una forma de medir cuánto sirve lo que
devuelve. También dejó una sospecha: con 10 000 reportes, el índice de Qdrant ni siquiera existía.
Esta fase sube al millón, donde el índice ya es obligatorio, y pone al lado al rival que el curso
considera **el más serio de las diez familias**: `pgvector`, que convierte el parecido en una columna
más de Postgres.

Es, de las diez, la familia más defendible, porque no hay equivalente relacional para *"parecido"*.
Pero con `pgvector` sí lo hay, y la pregunta cambia: ya no es *"¿necesito vectores?"* sino *"¿necesito
otro motor para ellos?"*. Esta fase la contesta con **recall**, la métrica propia de la familia, y con
su trampa a la vista: se puede ser rapidísimo devolviendo basura.

Hay dos apuestas escritas antes de medir, y las dos se publican con su resultado. El boss del Bloque
III, que cruza esta familia con la de grafos, va al final y se publica junto con las Fases 13 y 14.

---

## 🎯 2. Objetivos de esta fase

1. Cargar el mismo millón de vectores en Qdrant y en `pgvector`, con los mismos parámetros de HNSW, y
   medir lo que cuesta: tiempo de embeber, de cargar y de indexar.
2. Medir el **recall@10 del índice** contra `ef` en los dos motores, con la búsqueda exacta como
   referencia, y las páginas que toca Postgres en cada consulta.
3. Encontrar la consulta donde se separan: el **parecido con filtro**, y lo que hace `pgvector` cuando el
   filtro no es selectivo.
4. Medir la memoria de verdad —no la de `docker stats`— y llevar el índice hasta que no cabe.
5. Resolver las dos apuestas y escribir cuándo no usar un motor vectorial dedicado.

> 🧰 **Miniproyecto de esta familia:** [Cumbre Roja — el perfil de taza que solo recuerda una
> catadora](h-mini-07-vectorial-cumbre-roja.md). Opcional, fuera de las horas del curso, y no entra a la
> bitácora.

---

## 🪞 3. La apuesta

> 🪞 **Apuesta antes de ejecutar.** Creo que **`pgvector` con HNSW —m 16, `ef_construction` 100, los
> mismos de Qdrant— aguanta un millón de vectores con recall comparable**, es decir, con un recall@10 del
> índice a no más de 0,02 del de Qdrant con el mismo `ef`, **y me ahorra el motor aparte**.
>
> 🪞 **Y una segunda.** Creo que **olvidar los prefijos `query:` y `passage:` —en la consulta, o en los
> dos lados— baja el acierto de tipo de avería en los diez primeros en al menos dos puntos
> porcentuales**, medido con búsqueda exacta sobre el millón.

Escritas el 30/09/2026, antes de cargar el millón y de ejecutar `measure.ts`. **Resultado, en la sección
4.6: la primera se pierde en su letra y se gana en su fondo; la segunda se pierde entera.**

---

## 📐 4. La medición contra la línea base

### 4.1 Los mismos bytes, dos veces

Los vectores se calculan **una sola vez**, con la ingesta de la Fase 15, y se guardan en un archivo con
su hash. Qdrant los carga con `ingest.py`; `pgvector`, con `load_pgvector.py`, que comprueba el hash
antes de escribir una fila y escribe cada número con nueve cifras significativas, lo justo para que el
float32 vuelva exacto al parsearlo.

```bash
cd src
uv run python 15-vectorial-levantar-y-modelar/ingest.py --dataset lab/data/pirep-1m
uv run python 16-vectorial-romper-y-medir/load_pgvector.py --dataset lab/data/pirep-1m
node 16-vectorial-romper-y-medir/measure.ts
```

La comprobación de que son los mismos datos es una medición más: la búsqueda exacta de Postgres, sin
índice, devuelve **exactamente los mismos parecidos** que la búsqueda exacta de Qdrant (coincidencia
1,000 en 10 consultas). Desde ahí, las diferencias son de los índices, no de los datos.

| Paso | Qdrant | `pgvector` |
|---|---|---|
| embeber el millón (una vez, CPU, compartido) | 1662 s, 602 reportes por segundo | los mismos vectores |
| cargar | 1000 peticiones de 1000 puntos | `COPY`, 157 s |
| construir el HNSW (m 16, 100) | en segundo plano; carga más índice, **628–715 s** | `CREATE INDEX`, **299 s** con `maintenance_work_mem` de 2 GB |
| en disco | 1998 MiB | tabla 1563 MiB + índice 1680 MiB |

Los tiempos son contexto, con la máquina de la [bitácora](bitacora-de-medicion.md). El de Qdrant es el
rango de dos cargas que corrieron solas (715 s y 628 s); una tercera coincidió un rato con otra carga y
su tiempo (822 s) no se publica. Lo que sí es estructural es el orden: **embeber cuesta más que
indexar en los dos**, y es lo que se repite entero el día que cambias de modelo (sección 6).

Construir el índice de Postgres no salió a la primera. Con el `/dev/shm` de 64 MB que Docker da por
defecto, la construcción en paralelo falló:

```text
psycopg.errors.DiskFull: could not resize shared memory segment "/PostgreSQL.1712005010" to 2144374272 bytes: No space left on device
```

Postgres construye el índice con varios procesos que comparten el grafo en memoria compartida, y el
contenedor no tenía sitio. El `compose.yaml` del curso lleva desde entonces `shm_size`
([`a02`](a02-compose-de-la-ruta.md)), y el mensaje está en [`a09`](a09-catalogo-de-errores.md) como
E-35. Y aun con 2 GB, Postgres avisó al final:

```text
NOTICE: hnsw graph no longer fits into maintenance_work_mem after 966262 tuples
```

Los últimos 33 738 vectores se insertaron con el grafo ya en disco, que es más lento. Con el valor por
defecto, 64 MB, es el punto de rotura de la sección 5.

### 4.2 Recall contra `ef`, en los dos

Cien reportes repartidos por todo el dataset, embebidos con `query: `, contra el millón. La referencia
es la búsqueda exacta, y aquí **recall es el recall del índice**: qué parte de los diez vecinos exactos
devuelve el índice aproximado. Un detalle de método, porque el 15 % de `pirep-1m` son duplicados
exactos: dos puntos con el mismo vector son igual de correctos, así que cuenta como acierto todo
resultado tan parecido como el décimo exacto.

> 📐 **Medición — recall@10 del índice contra `ef`** · `pirep-1m`, 100 consultas · m 16,
> `ef_construction` 100 en los dos · verificado el 30/09/2026
>
> | `ef` | Qdrant | `pgvector` | páginas de 8 kB por consulta en Postgres |
> |---|---|---|---|
> | 10 | 0,925 | 0,901 | 357 |
> | 20 | 0,956 | 0,916 | 464 |
> | 40 | 0,985 | 0,946 | 679 |
> | 80 | 0,997 | 0,984 | 1107 |
> | 160 | 0,997 | 0,999 | 1809 |
> | 320 | 1,000 | 1,000 | 2995 |
>
> Reproducir: `node 16-vectorial-romper-y-medir/measure.ts --only apuesta`

Con `ef` bajo, **Qdrant acierta más**: 0,985 contra 0,946 con `ef` 40, el valor por defecto de
`pgvector`. Desde 80 están a 0,013, y desde 160 empatan. La explicación más probable está en la sección
6.5 de la Fase 15: Qdrant guardó el millón en **4 segmentos, cada uno con su HNSW**, y busca en los
cuatro, así que con el mismo `ef` explora más candidatos que el índice único de `pgvector`. No se midió
cuántos; el ejercicio 12 lo busca.

La columna de páginas es lo que Postgres deja ver y Qdrant no: **cada consulta toca de 357 a casi 3000
páginas** según `ef`. Es el costo de subir el recall, en la unidad estructural de siempre, y crece casi
en línea recta con `ef`. Las consultas por segundo también se midieron, una a una y en esta máquina:
`pgvector` respondió más rápido en todos los `ef` (con 40, 86 contra 61 por segundo). Son contexto, y
con más ruido del que parece —Qdrant hizo 52 por segundo con `ef` 10 y 88 con 20—, así que no entran
en ninguna conclusión.

### 4.3 El parecido con filtro: donde se separan

La consulta útil de Freddy nunca es *"lo más parecido de toda la flota"*: es *"lo más parecido **de este
capítulo ATA**"* o *"**de esta aeronave**"*. `measure.ts` prueba dos filtros, uno muy selectivo y otro
que no lo es:

```text
filtro aircraft = HK-9326 (285 de 1000000 reportes) · 20 consultas
   Qdrant, filtro de payload:                    recall@10 1.000
   pgvector, WHERE + HNSW, por defecto:           recall@10 1.000 · 0 de 20 devolvieron menos de 10 · plan: Limit → Sort
filtro ata_chapter = 22 (83500 de 1000000, sin índice B-tree) · 20 consultas · plan: Limit → Index Scan pirep_embedding_hnsw_passage
   Qdrant, filtro de payload:                    recall@10 0.995
   pgvector, WHERE + HNSW, por defecto:           recall@10 0.100 · 18 de 20 devolvieron menos de 10 (1.0 filas de media)
   pgvector, hnsw.iterative_scan = relaxed_order: recall@10 0.510 · 0 de 20 devolvieron menos de 10
```

**Con la aeronave, empate perfecto, y no por el HNSW.** El planificador vio que el índice B-tree de
`aircraft` deja 285 filas, las leyó y **las ordenó por distancia**: una búsqueda exacta, sin tocar el
índice vectorial. Es Postgres haciendo bien su trabajo.

**Con el capítulo ATA 22 —el 8,35 % de los reportes—, `pgvector` se rompe.** El planificador eligió el
HNSW, que busca los 40 candidatos más parecidos (`ef_search` por defecto) y **después** aplica el
`WHERE`: de esos 40, casi ninguno es del capítulo 22, y la consulta **devuelve 1 fila de media en vez
de 10**, sin error. 18 de 20 consultas volvieron cortas. Qdrant filtra **dentro** del grafo, y acierta
0,995.

`pgvector` 0.8 trae la respuesta a esto: el recorrido iterativo, que sigue buscando hasta llenar el
`LIMIT`. Y aquí va la línea base bien jugada, probada entera:

| `pgvector`, capítulo 22 | recall@10 | consultas cortas |
|---|---|---|
| por defecto | 0,100 | 18 de 20 |
| `iterative_scan = relaxed_order` | 0,510 | 0 |
| `relaxed_order`, `max_scan_tuples` 500 000 | 0,510 | 0 |
| `iterative_scan = strict_order` | 0,260 | 0 |
| con índice B-tree en `ata_chapter`, lo que elige el planificador | 0,100 | — (sigue eligiendo el HNSW) |
| B-tree, camino exacto forzado (`enable_indexscan = off`) | **1,000** | 0: examina **83 500 filas y 70 823 páginas** |

El recorrido iterativo **llena el `LIMIT`, pero con los que encuentra antes, no con los más
parecidos**: diez resultados que parecen una respuesta y aciertan la mitad. `strict_order` acertó menos
que `relaxed_order` en estas consultas, y subir `max_scan_tuples` no cambió nada; no se investigó por
qué. La única forma de acertar en Postgres fue **renunciar al índice vectorial**: filtrar con el B-tree y
ordenar las 83 500 filas que quedan, a 70 823 páginas por consulta.

Esta es la diferencia de fondo entre los dos motores, y no aparece en la sección 4.2: **Qdrant trata el
filtro como parte de la búsqueda; `pgvector` lo trata como un `WHERE` después de la búsqueda**, y con
filtros de selectividad media —ni el 0,03 % de una aeronave ni el 100 %— eso significa devolver poco o
devolver mal.

### 4.4 La memoria de verdad

Un millón de vectores de 384 float32 son **1465 MiB** antes de cualquier índice. Lo que ocupa cada motor,
leído del cgroup del contenedor y no de `docker stats`, con los dos cargados y consultados:

```text
memoria · 1 M × 384 float32 = 1465 MiB crudos
   vectorial: memory.current 1978 MiB (anónima 355, archivos 1580, de ellos mapeados 1506) · docker stats dice 410.8MiB
   base: memory.current 3436 MiB (anónima 19, archivos 3366, de ellos mapeados 198) · docker stats dice 249MiB
   Qdrant en disco: 1998 MiB · Postgres: tabla 1563 MiB, HNSW 1680 MiB
```

Dos lecturas. **La primera es de método, y vale para todo el curso: `docker stats` miente para los
dos.** Resta la caché de archivos, y los dos motores viven de ella: Qdrant **mapea** los vectores desde
disco (1506 MiB mapeados, aunque la colección tenga `on_disk: false`), y Postgres lee tabla e índice a
través de la caché del sistema operativo, porque su `shared_buffers` es de 128 MB. `docker stats` dijo
410 MiB y 249 MiB; el contenedor ocupaba 1978 MiB y 3436 MiB.

**La segunda es el reparto.** Qdrant ocupa unos 2 GB en disco para vectores e índice. Postgres guarda
los vectores **dos veces**: en la tabla (1563 MiB, cada fila con su vector de 1536 bytes) y dentro del
HNSW (1680 MiB), porque el índice de `pgvector` copia el vector en cada nodo del grafo. Es un 62 % más
en disco para lo mismo.

### 4.5 La apuesta de los prefijos

Quinientos reportes como consulta, con búsqueda exacta para que el índice no influya, sin contar el
propio reporte, y el acierto de tipo de avería en los diez primeros —el segundo sentido de "recall" en
este curso, y el que mide si el resultado **sirve**—:

```text
prefijos · 500 reportes como consulta, búsqueda exacta, acierto de tipo en los diez primeros (sin el propio)
   passage: en la colección, query: en la consulta   99.86 %
   passage: en la colección, consulta sin prefijo     99.94 %
   sin prefijo en ningún lado                          99.98 %
```

Sin prefijos, **el acierto no baja: sube una décima**. La apuesta se pierde, y conviene decir además
por qué el resultado dice menos de lo que parece: **la métrica está saturada**. A un millón, cada
reporte tiene cientos de hermanos casi idénticos —el mismo arquetipo, la misma plantilla, otra falta de
teclado—, y los diez vecinos de cualquier consulta son de su tipo casi siempre, con prefijos o sin
ellos. Lo que este corpus sintético no puede medir es si los prefijos importan **cuando la consulta no
se parece a ningún reporte**, que es el caso de Freddy escribiendo con sus palabras. El ejercicio 20 lo
intenta con consultas escritas a mano.

### 4.6 El resultado de las dos apuestas

> 🪞 **Resultado de la primera.** **Perdida en su letra**: con el mismo `ef` bajo, `pgvector` queda a
> 0,024–0,040 de Qdrant (con 40, 0,946 contra 0,985), más de los 0,02 que apostaba. **Ganada en su
> fondo**: desde `ef` 80 están a 0,013, desde 160 empatan, y la búsqueda sin filtro no justifica un motor
> aparte. Pero la apuesta decía *"me ahorra el motor"*, y la sección 4.3 encontró dónde no: **el parecido
> con un filtro de selectividad media**, donde `pgvector` acierta 0,10 por defecto y 0,51 con el recorrido
> iterativo, y Qdrant 0,995.
>
> 🪞 **Resultado de la segunda.** **Perdida entera**: sin prefijos, el acierto de tipo fue 99,98 % contra
> 99,86 % con ellos. Con una salvedad declarada: en este corpus, la métrica está saturada.

La primera es el resultado más útil de la familia. **Para "lo más parecido de todo", `pgvector` alcanza**,
con `ef_search` subido a 80 o más y sabiendo que cada consulta toca unas mil páginas. **Para "lo más
parecido que además cumpla esto", depende de cuánto filtra el filtro**, y ese es un dato de tu dominio
que hay que medir antes de elegir.

### 4.7 Lo que la apuesta no midió

**La concurrencia**: todo, una consulta a la vez. **Las escrituras mientras se busca**: el millón se cargó
y después se consultó. **Otro modelo**: todo es e5-small, 384 dimensiones; con 1024 dimensiones, la
memoria y las páginas se multiplican por algo menos de tres, y eso tampoco se midió. Y **la latencia**,
por diseño.

---

## 💥 5. El punto de rotura

El punto de rotura que la familia promete es *"el índice que no cabe en RAM, y el recall que se
desploma al bajar los parámetros para que quepa"*. Se midió en los dos motores, y ninguno se rompió como
el enunciado esperaba.

### 5.1 Qdrant: bajar la memoria hasta que muere

`rotura.py` carga el millón en un Qdrant desechable, aparte del laboratorio, en tres configuraciones, y
a cada una le baja el límite de memoria del contenedor —1 GB, 512 MB, 256 MB— hasta que deja de servir.
Mide el recall@10 con `ef` 128 contra la búsqueda exacta, y los **fallos de página mayores** por consulta
(`pgmajfault` del cgroup): cada uno es una lectura de disco que la memoria no pudo evitar.

> 💥 **Rotura — la memoria del contenedor** · `pirep-1m`, 100 consultas, `ef` 128 ·
> `qdrant/qdrant@sha256:12364fe851b9…` · verificado el 30/09/2026
>
> | Configuración | Sin límite | 1 GB | 512 MB | 256 MB |
> |---|---|---|---|---|
> | todo en RAM (la de fábrica) | 2120 MiB · recall 0,964 · 1882 fallos | sirve · 4479 fallos | sirve · 5445 fallos | **OOMKilled**, exit 137 |
> | vectores e índice en disco (`on_disk`) | 1443 MiB · recall 1,000 · 2566 fallos | sirve · 1471 | sirve · 2166 | **OOMKilled** |
> | cuantización int8 en RAM (`always_ram`) | 866 MiB · recall 0,907 · 92 fallos | sirve · **0** | **OOMKilled** | — |
>
> Reproducir: `uv run python 16-vectorial-romper-y-medir/rotura.py` (unos 45 minutos)

**"Todo en RAM" no está todo en RAM.** Con la configuración de fábrica, de sus 2120 MiB solo 464 son
memoria anónima; el resto son los vectores **mapeados desde disco**. Por eso, al bajar el límite a 1 GB y
a 512 MB, Qdrant **no muere**: el sistema operativo desaloja páginas de vectores y las vuelve a leer
cuando hacen falta. El recall no cambia —0,964 en los tres—; lo que cambia es el trabajo: **de 1882 a
5445 lecturas de disco por consulta**. El índice que no cabe no se rompe: **se vuelve disco**. Muere
cuando lo que no se puede desalojar —el grafo y las estructuras propias, unos 270–300 MiB— deja de
caber, a 256 MB, con el `Exited (137)` y `OOMKilled=true` de siempre ([`a09`](a09-catalogo-de-errores.md)
E-05).

**La cuantización, que se vende para que quepa, muere antes.** Con int8 y `always_ram`, Qdrant guarda una
copia de cada vector en un byte por dimensión **en memoria anónima**: 799 MiB que no se pueden desalojar.
Con 1 GB sirve sin una sola lectura de disco; con 512 MB, el proceso muere. Y paga en recall: **0,907**,
el más bajo de las tres, y reordenar con los vectores completos no lo cambió (0,907 también). La
cuantización no es "que quepa en menos memoria": es **cambiar memoria que se puede desalojar por memoria
que no**, a cambio de no leer de disco.

Dos declaraciones. La **cuantización binaria** no terminó de cargar: el cliente agotó su espera de 600 s
en una de las peticiones, y no se repitió; queda sin medir, en el ejercicio 22. Y la diferencia de recall
entre *todo en RAM* (0,964) y *en disco* (1,000), con los mismos parámetros de HNSW, **no se investigó**:
los dos se construyeron por separado y su grafo no es el mismo.

### 5.2 `pgvector`: construir con lo que trae de fábrica

`load_pgvector.py` reconstruye el mismo índice con el `maintenance_work_mem` que trae Postgres de
fábrica, 64 MB, y después prueba la salida de `pgvector` para ocupar menos: un HNSW sobre `halfvec`,
dos bytes por dimensión en lugar de cuatro.

> 💥 **Rotura — construir con poca memoria** · `pirep-1m`, m 16, `ef_construction` 100 ·
> `pgvector/pgvector@sha256:2ba9ca5f2e7d…` · verificado el 30/09/2026
>
> | Índice | `maintenance_work_mem` | Construcción | Tamaño | Aviso |
> |---|---|---|---|---|
> | `vector`, float32 | 2 GB | 299 s | 1680 MB | a las 966 262 tuplas |
> | `vector`, float32 | **64 MB, el de fábrica** | **2246 s** | 1680 MB | **a las 28 356 tuplas** |
> | `halfvec` | 2 GB | 181 s | **957 MB** | ninguno |
>
> Reproducir: `uv run python 16-vectorial-romper-y-medir/load_pgvector.py --maintenance-work-mem 64MB` y
> `… --skip-load --halfvec`

```text
NOTICE: hnsw graph no longer fits into maintenance_work_mem after 28356 tuples
```

**Con la memoria de fábrica, el índice sale igual pero tarda 7,5 veces más**: el grafo deja de caber a
las 28 356 tuplas —el 2,8 % del millón—, y las 971 644 restantes se insertan con el grafo en disco. No
hay error, y el índice resultante ocupa lo mismo. Es el "índice que no cabe" de Postgres: **no se rompe
al consultar, se rompe al construir**, y la factura es tiempo de mantenimiento, que es lo que se paga
cada vez que cambias de modelo.

**`halfvec` es la cuantización de `pgvector`, y aquí no costó recall.** El índice ocupa 957 MB, un 43 %
menos, se construyó en 181 s sin avisar, y su recall@10 contra la búsqueda exacta sobre los float32 fue
**0,980 con `ef` 40, 0,992 con 80 y 0,999 con 160**: más que el índice float32 con el mismo `ef` (0,946
con 40). No se investigó por qué; son dos grafos construidos por separado, y uno más pequeño cabe entero
en memoria mientras se construye. Lo que sí se puede afirmar es que **con e5-small, la media precisión no
empeoró el recall en este corpus**.

Reproducir el recall: `node 16-vectorial-romper-y-medir/measure.ts --only halfvec`.

### 5.3 Lo que se cambia para salir

En Qdrant, **la memoria decide la latencia antes que el recall**: vectores en disco es la salida barata,
y el precio se cuenta en lecturas de disco por consulta, no en aciertos. La cuantización sirve cuando lo
que sobra es memoria y lo que falta es disco rápido, y hay que medir el recall que se pierde. En
Postgres, el índice que no cabe en `shared_buffers` ya es la situación normal —128 MB contra 1680 MiB—, y
lo que hay que decidir es la memoria al construir y si `halfvec` alcanza.


---

## 🚑 6. Salir de aquí

Cuando un sistema vectorial ya duele, la escalera se sube en orden de costo:

1. **Parámetros.** Subir `ef` de consulta es gratis en código y caro en páginas: de 0,946 a 0,999 de
   recall en `pgvector` cuesta pasar de 679 a 1809 páginas por consulta. Antes de cambiar de motor, mide
   el recall con el `ef` que tienes.
2. **Modelo de datos.** Si el filtro es la consulta, el filtro va primero: un índice B-tree y el camino
   exacto cuando el filtro deja pocas filas, índices parciales por valor cuando el filtro tiene pocos
   valores, o una tabla por partición. En Qdrant, índices de payload creados antes de cargar.
3. **Motor.** Si la consulta central es parecido con filtros de selectividad media, la sección 4.3 dice
   que un motor que filtra dentro del grafo acierta donde `pgvector` no. Si es parecido sin filtro, la
   sección 4.2 dice que `pgvector` alcanza.
4. **Arquitectura.** El motor vectorial al lado de la fuente de verdad, alimentado desde ella y
   reconstruible, porque **cambiar de modelo es reconstruir todo**: con los números de esta fase, 1662 s
   de embeber más 628–715 s de Qdrant, o más 157 s de `COPY` y 299 s de índice en Postgres. Unos cuarenta minutos para un
   millón de reportes en esta máquina, y cualquier vector guardado fuera del índice queda inválido
   ([Fase 24](24-poliglota-la-costura.md)).

---

## ❓ 7. Las cinco preguntas, respondidas para vectorial

1. **Frontera transaccional.** Ajena a la familia: el vector se deriva del texto, y la verdad es el
   texto. En `pgvector` el vector vive en la misma transacción que la fila, y esa es su ventaja de fondo;
   en Qdrant, es otra escritura en otro sistema.
2. **Consultas conocidas.** A medias: el parecido no necesita saber qué se va a buscar, pero **los
   filtros sí**, y la sección 4.3 muestra que el filtro decide el motor.
3. **Unidad de lectura.** Los k más parecidos, siempre k. Nunca un conjunto con borde.
4. **Saltos.** Ninguno. *"Los parecidos de los parecidos"* no es una consulta de esta familia: es el
   boss del bloque, con grafos.
5. **Exactitud o parecido.** **Es la pregunta de esta familia.** Parecido, y solo parecido: una matrícula
   buscada por vector encontró 4 de 186 en la Fase 15.

---

## ⚖️ 8. Veredicto honesto: cuándo NO usar esto

> ⚖️ **No uses un motor vectorial para lo exacto**: matrículas, números de parte, códigos. La búsqueda
> exacta existe, es más barata y acierta más (Fase 15: 4 de 186 contra 186 de 186). **No uses un motor
> vectorial dedicado si tu consulta es "lo más parecido de todo"** y ya tienes Postgres: `pgvector`, con
> `ef_search` de 80 o más, llega a 0,984–1,000 de recall sobre un millón, con la misma transacción que el
> resto de la fila y sin un servicio más. **Y no confíes en ningún número de recall sin la búsqueda exacta
> al lado**: Qdrant no tenía índice con 10 000 puntos, `pgvector` devolvió 1 fila de 10 sin avisar, y
> `docker stats` informó una quinta parte de la memoria real.
>
> **Úsalo** cuando la consulta central es **parecido con filtros que no son ni muy selectivos ni
> inexistentes**: *"lo más parecido de este capítulo, de esta flota, de este año"*. Ahí, con un millón de
> reportes, Qdrant acertó **0,995** y `pgvector` **0,10** por defecto, **0,51** con su mejor recorrido
> iterativo, y **1,000** solo renunciando al índice y examinando 83 500 filas por consulta.

Para Cóndor, el veredicto es el de Freddy: sus consultas son *"lo más parecido de esta aeronave"* —el
B-tree de Postgres las resuelve exactas— y *"lo más parecido de este sistema"* —el capítulo ATA, donde
`pgvector` falla—. **Si la segunda es la pantalla de todos los días, Qdrant se gana su sitio.** Si es la
de una vez al mes, `pgvector` con el camino exacto forzado alcanza, y es un motor menos.

---

## ⚠️ 9. Errores comunes y diagnóstico

**El índice de Postgres no se construye en un contenedor** (E-35 en [`a09`](a09-catalogo-de-errores.md)):
`could not resize shared memory segment "/PostgreSQL.…" to 2144374272 bytes: No space left on device`.
🩺 `df -h /dev/shm` dentro del contenedor: si dice 64M, es el tamaño por defecto de Docker. Sube
`shm_size`, o baja `max_parallel_maintenance_workers` a 0 para construir sin paralelismo.

**El grafo que no cabe al construir** (E-36): `NOTICE: hnsw graph no longer fits into
maintenance_work_mem after 966262 tuples`. 🩺 Es un aviso, no un error: el índice se termina, más
despacio. Sube `maintenance_work_mem` para la sesión que construye (sección 5).

**La consulta filtrada que devuelve menos de lo pedido.** No hay mensaje: pides 10 y vuelven 1 o 2. 🩺
`EXPLAIN` de la consulta: si el plan es `Index Scan` sobre el HNSW con el filtro encima, el filtro se
aplica después de buscar. Prueba `hnsw.iterative_scan`, y mide el recall contra la búsqueda exacta
filtrada: llenar el `LIMIT` no es acertar (sección 4.3).

**Un lote demasiado grande para la API** (E-37): `JSON payload (40013689 bytes) is larger than allowed
(limit: 33554432 bytes).` 🩺 El mensaje da los dos tamaños: 5000 vectores de 384 números en JSON pasan
de 32 MiB. Lotes de 1000, o gRPC.

**La memoria que no cuadra.** 🩺 `cat /sys/fs/cgroup/memory.stat` dentro del contenedor, y mira `anon`,
`file` y `file_mapped`. `docker stats` resta la caché, y los dos motores viven de ella.

**Un recall que no cambia con `ef`.** 🩺 En Qdrant, `indexed_vectors_count`: si es 0, no hay índice
(Fase 15, sección 6.5). Y recuerda que Qdrant nunca explora menos candidatos que el `limit`.

---

## 📋 10. Checklist de validación

```text
[ ] Los dos motores cargaron pirep-e5-passage.f32 (3a97c8b28f60…), y la búsqueda exacta de Postgres coincide con la de Qdrant
[ ] recall@10 del índice con ef 40: Qdrant 0,985, pgvector 0,946; con ef 160, 0,997 y 0,999
[ ] Sé cuántas páginas toca pgvector por consulta con ef 40 (679) y con ef 160 (1809)
[ ] El filtro por aeronave empata porque el planificador usa el B-tree y ordena exacto
[ ] Con el capítulo 22, pgvector devuelve 1 fila de media, y 0,51 de recall con iterative_scan
[ ] Sé por qué docker stats no sirve para medir la memoria de estos dos motores
[ ] Postgres guarda los vectores dos veces: tabla 1563 MiB, índice 1680 MiB
[ ] La apuesta de los prefijos se perdió, y sé por qué la métrica está saturada
[ ] Reproduje el punto de rotura de la sección 5
[ ] Las dos apuestas están escritas antes de la medición, con su resultado
[ ] M-12 a M-14 están en la bitácora, las apuestas 3 y 4 en su tabla, E-35 a E-37 en a09
```

---

## 🧪 11. Ejercicios (26)

Salvo donde se indique, con `pirep-1m` cargado en los dos motores. El código está en
`src/16-vectorial-romper-y-medir/`. Cargar el millón lleva unos cuarenta minutos la primera vez: los
vectores se calculan una vez y se reutilizan.

### 🟢 Fácil — reproducir (1–7)

#### 🟢 Ejercicio 1 — Los mismos bytes

Comprueba el hash de `pirep-e5-passage.f32` contra su manifiesto, y el primer vector de la tabla de
Postgres contra el primero del archivo.

**Objetivo:** que los 384 números coincidan exactos, y explicar por qué hacen falta nueve cifras.

#### 🟢 Ejercicio 2 — La tabla de `ef`

Ejecuta `measure.ts --only apuesta`.

**Objetivo:** reproducir la tabla de la sección 4.2 dentro de ±0,01, y decir qué columna no esperas que
coincida en otra máquina.

#### 🟢 Ejercicio 3 — Las páginas

Con `EXPLAIN (ANALYZE, BUFFERS)`, pide una consulta con `ef_search` 40 y otra con 160.

**Objetivo:** las páginas de cada una, y cuántas son `hit` y cuántas `read`.

#### 🟢 Ejercicio 4 — El filtro que vuelve corto

Busca lo más parecido a *"luz de tren no enciende"* con `WHERE ata_chapter = 22`.

**Objetivo:** cuántas filas devuelve, y el plan que lo explica.

#### 🟢 Ejercicio 5 — La memoria del cgroup

Lee `memory.stat` de los dos contenedores y compáralo con `docker stats`.

**Pregunta:** ¿cuánto de cada uno es caché de archivos, y qué pasaría si el sistema necesitara esa
memoria?

#### 🟢 Ejercicio 6 — Los segmentos

Lee `GET /collections/pirep` con el millón cargado.

**Objetivo:** cuántos segmentos hay, cuántos vectores indexados, y qué dice `on_disk`.

#### 🟢 Ejercicio 7 — El aviso del grafo

Reconstruye el índice de `pgvector` con `maintenance_work_mem` de 1 GB.

**Objetivo:** después de cuántas tuplas avisa, y cuánto tarda comparado con 2 GB.

### 🟡 Intermedio — medir de otra forma (8–14)

#### 🟡 Ejercicio 8 — Un filtro de cada selectividad

Repite la consulta filtrada con cinco capítulos ATA de distinto tamaño.

**Objetivo:** una curva de recall de `pgvector` contra la selectividad del filtro, y el punto donde el
planificador deja de usar el HNSW.

#### 🟡 Ejercicio 9 — Índices parciales

Crea un HNSW parcial `WHERE ata_chapter = 22` y repite la consulta filtrada.

**Objetivo:** recall, tamaño del índice, y cuántos índices necesitarías para cubrir todos los capítulos.

#### 🟡 Ejercicio 10 — `ef_search` con filtro

Con `iterative_scan = relaxed_order`, sube `ef_search` a 200 y a 1000.

**Pregunta:** ¿mejora el recall filtrado? ¿Cuántas páginas cuesta?

#### 🟡 Ejercicio 11 — Qdrant sin índice de payload

Crea una colección sin el índice de `ataChapter` y repite la consulta filtrada.

**Objetivo:** el recall, y lo que dice la documentación sobre cómo filtra Qdrant sin ese índice.

#### 🟡 Ejercicio 12 — Un segmento

Crea una colección de Qdrant con `default_segment_number` 1 y repite la tabla de `ef`.

**Pregunta:** ¿se acerca Qdrant a `pgvector` con el mismo `ef`? Confirma o descarta la explicación de la
sección 4.2.

#### 🟡 Ejercicio 13 — Los duplicados

Cuenta cuántas de las 100 consultas tienen duplicados exactos entre sus diez vecinos.

**Objetivo:** calcular el recall **sin** la regla de empates, y ver cuánto cambia.

#### 🟡 Ejercicio 14 — El tamaño de una fila

Con `pg_column_size`, mide una fila de `pirep_embedding`.

**Objetivo:** explicar los 1563 MiB de la tabla con esa cifra y el número de filas por página.

### 🟠 Difícil — diagnosticar y decidir (15–21)

#### 🟠 Ejercicio 15 — La consulta de Freddy, de verdad

Escribe diez consultas como las escribiría Freddy, con sus palabras, y anota a mano qué tipo de avería
esperas.

**Objetivo:** acierto de tipo en los diez primeros en los dos motores y en las tres variantes de
prefijo.

#### 🟠 Ejercicio 16 — Reconstruir por cambio de modelo

Cronometra la reconstrucción completa: embeber, cargar e indexar, en los dos motores.

**Pregunta:** ¿cuánto tiempo estaría la búsqueda sin servir, y cómo lo evitarías con dos colecciones?

#### 🟠 Ejercicio 17 — Escribir mientras se busca

Inserta 10 000 reportes nuevos en los dos motores mientras otro proceso consulta.

**Objetivo:** el recall durante la carga, y cuándo aparecen los nuevos en los resultados de cada motor.

#### 🟠 Ejercicio 18 — `halfvec` con filtro

Repite la consulta filtrada del capítulo 22 con el índice `halfvec`.

**Pregunta:** ¿la media precisión empeora el problema del filtro, o es independiente?

#### 🟠 Ejercicio 19 — La cuantización en Qdrant, con filtro

Repite la consulta filtrada contra la colección `pirep_int8`.

**Objetivo:** el recall, con y sin reordenar con los vectores completos.

#### 🟠 Ejercicio 20 — Los prefijos sin saturar

Usa como consultas frases que no sean reportes —las del ejercicio 15— y repite la apuesta de los
prefijos.

**Objetivo:** publicar el resultado aunque contradiga la sección 4.5.

#### 🟠 Ejercicio 21 — La autopsia del filtro

Un equipo migró su búsqueda filtrada de Qdrant a `pgvector` *"porque la sección 4.2 dice que empatan"*.

**Objetivo:** los cinco pasos de la Fase 00, con la factura calculada con los números de la sección 4.3.

### 🔴 Muy difícil — autopsias y romper (22–26)

#### 🔴 Ejercicio 22 — La cuantización binaria

Añade la variante `binary` a `rotura.py` y consigue que cargue: lotes más pequeños, más espera, o gRPC.

**Objetivo:** su memoria, su recall con y sin reordenar, y el límite al que muere. ¿Mejora a int8 en
algo, con e5-small de 384 dimensiones?

#### 🔴 Ejercicio 23 — Híbrido en una consulta

Escribe en Postgres una consulta que combine `ILIKE` sobre un código, el filtro por capítulo y el orden
por parecido.

**Objetivo:** el plan, las páginas, y si puedes hacerlo en Qdrant en una sola petición.

#### 🔴 Ejercicio 24 — La apuesta del filtro

Escribe una apuesta nueva, antes de medir, sobre la selectividad a la que `pgvector` empieza a fallar.

**Objetivo:** medirla con el ejercicio 8 y publicarla se gane o se pierda.

#### 🔴 Ejercicio 25 — 1024 dimensiones

Estima con los números de esta fase la memoria y las páginas por consulta con un modelo de 1024
dimensiones.

**Objetivo:** la estimación escrita antes, y si puedes, medirla con un subconjunto.

#### 🔴 Ejercicio 26 — El veredicto de Cóndor

Con los números de las Fases 15 y 16, decide si Cóndor necesita Qdrant.

**Objetivo:** una página con la decisión, las consultas de Freddy clasificadas por selectividad, y la
factura operativa al lado.

---

## 📚 12. Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación de estos productos cubre la última versión.
> Esta fase se verificó con Qdrant 1.19.1 y pgvector 0.8.6 sobre PostgreSQL 18.6.

- **pgvector** — https://github.com/pgvector/pgvector — HNSW, `ef_search`, `halfvec`, el recorrido
  iterativo y los índices parciales, en su README.
- **Filtrado en Qdrant** — https://qdrant.tech/documentation/concepts/filtering/ y
  https://qdrant.tech/articles/vector-search-filtering/ — cómo filtra dentro del grafo.
- **Cuantización en Qdrant** — https://qdrant.tech/documentation/guides/quantization/
- **Almacenamiento en Qdrant** — https://qdrant.tech/documentation/concepts/storage/ — memoria, mmap y
  `on_disk`.
- **ANN-Benchmarks** — https://ann-benchmarks.com/ — recall contra velocidad para muchos índices, con
  otra metodología: útil para situar los números de esta fase, no para compararlos.
- **Malkov y Yashunin** — https://arxiv.org/abs/1603.09320 — HNSW.

**Orden sugerido:** el README de `pgvector` antes de la sección 4.3; filtrado y almacenamiento de Qdrant
durante la 4; cuantización antes de la 5.

---

## 🏁 13. Resultado de la fase

Mediste Qdrant contra `pgvector` sobre el mismo millón, y el resultado tiene dos mitades. **Sin filtro,
empatan** desde `ef` 80, y `pgvector` te ahorra un motor. **Con un filtro de selectividad media, no**:
0,995 contra 0,10. Perdiste las dos apuestas en su letra, y la primera te dejó la pregunta que decide
esta familia: *¿cuánto filtra tu filtro?*

> **La señal de que quedó bien:** *"Puedo decir, para cada consulta de parecido de Cóndor, si
> `pgvector` la resuelve o no, con el recall medido contra la búsqueda exacta y la selectividad de su
> filtro."*

> 🏷️ **Tag:** `fase-16-vectorial-romper-y-medir` · prefijo de commit `f16:`

---

### 💀 Boss del Bloque III — "Freddy ya vio esto"

> 🚧 **Se publica con las Fases 13 y 14.** Lo pide Hernán Peñaloza, y cruza esta familia con la de
> grafos: las cinco intervenciones más parecidas a un reporte nuevo **y** las piezas que la trazabilidad
> dice que podrían estar implicadas. Necesita las dos familias escritas y medidas, y por eso llega
> después, en este mismo lugar.
