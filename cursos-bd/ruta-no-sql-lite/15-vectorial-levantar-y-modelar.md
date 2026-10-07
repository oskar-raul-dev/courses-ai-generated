# 🧬 Fase 15 — Vectorial: "esto ya lo vimos", modelado como parecido y no como respuesta

> **Curso:** Ruta NoSQL Lite · Fase 15 de 25 · Bloque III — Preguntas que no sabes escribir en SQL · **10 h**
> **Familia:** vectorial · **Motor:** Qdrant 1.19.1 `qdrant/qdrant@sha256:12364fe851b9…`
> **Línea base:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…` (`ILIKE` e índice B-tree aquí;
> `pgvector`, en la Fase 16)
> **Entorno de ejecución:** Python para los embeddings y la ingesta, TypeScript para la consulta
> **Volumen:** `pirep-10k` (`datasetSha256` `75d3b6802f56…`); el millón es de la Fase 16
> **Depende de:** Fase 02 (en el orden canónico, Fase 14) · **Habilita:** Fase 16
> **Apéndices de apoyo:** [`a01`](a01-laboratorio-contenerizado.md), [`a02`](a02-compose-de-la-ruta.md),
> [`a05`](a05-el-dominio-de-flota.md), [`a06`](a06-lenguajes-y-drivers.md), [`a09`](a09-catalogo-de-errores.md)
> **Fecha de verificación ejecutada:** 30/09/2026, en macOS arm64
> **Objetivo:** que *"ruido metálico al bajar tren"* encuentre *"golpeteo al extender"*, medir **cuánto**
> lo encuentra contra una verdad conocida, y saber en qué preguntas el vector no debe ni acercarse.

---

## 🧭 1. Dónde estamos

El Bloque III reúne dos familias que contestan preguntas **que no sabes escribir en SQL**: el camino
de profundidad desconocida (grafos, Fases 13 y 14) y el parecido (vectorial, esta fase y la
siguiente). El curso publica vectorial antes que grafos, a propósito, y lo puede hacer porque los
minicursos son casi independientes: para esta fase basta con el Bloque 0. Si vienes del orden
canónico, llegas con grafos ya hechos; si no, no te falta nada hasta el boss del bloque, que cruza
las dos familias y vive al final de la Fase 16.

El dolor es el de Freddy Manrique. Los reportes de piloto son tres líneas escritas con prisa, con
jerga y con faltas —*"ruido metálico al bajar tren, intermitente"*—, y Freddy sabe que eso ya pasó en
otra aeronave hace dos años. Pero esa memoria está en Freddy, no en el sistema: buscar "ruido
metálico" no encuentra "golpeteo al extender". Ninguna familia vista hasta aquí lo resuelve, porque
todas buscan **lo que es igual**. Esta busca **lo que se parece**.

Y eso cambia algo más grande que el motor: **cómo se sabe si el resultado está bien**. Hasta ahora,
una consulta devolvía la respuesta o fallaba. Aquí siempre devuelve algo, y hay que medir cuánto de
eso sirve. Por eso esta fase trae su propia verdad de referencia: el generador anota el tipo de
avería de cada reporte en `pirep-labels.ndjson` ([`a05`](a05-el-dominio-de-flota.md)), el motor nunca
la ve, y el curso la usa para evaluar.

Esta fase no compara Qdrant con `pgvector`: esa es la apuesta de la
[Fase 16](16-vectorial-romper-y-medir.md). Aquí Postgres aparece con lo que ya tiene sin extensiones
—`ILIKE` y un índice B-tree— para medir lo que el instinto espera del vector.

---

## 🎯 2. Objetivos de esta fase

1. Embeber los 10 000 reportes de `pirep-10k` con `multilingual-e5-small` en Python, guardar los
   vectores en un archivo con su hash y cargarlos en Qdrant: **10 peticiones de 1000**.
2. Buscar *"ruido metálico al bajar tren"* desde TypeScript y obtener **10 de 10** del tipo de avería
   correcto, en **1 viaje**.
3. Medir el 🪞 contra `ILIKE`: qué parte de los **1258** reportes de ese tipo encuentra cada forma, y
   por qué el vector **no es un `LIKE` mejor**, sino otra cosa.
4. Explicar coseno contra producto interno, los dos parámetros de HNSW que importan, y descubrir por
   qué con 10 000 puntos **Qdrant no había construido el índice**.
5. Filtrar por payload —aeronave, capítulo ATA— y reproducir la situación 3: buscar por parecido lo
   que es exacto encuentra **4 de 186**.

---

## 🚫 3. Qué NO entra todavía

- **Qdrant contra `pgvector`**, el millón de vectores, la memoria y el costo de construir el índice.
  Es la [Fase 16](16-vectorial-romper-y-medir.md).
- **La apuesta de los prefijos `query:` y `passage:`.** Se mide en la Fase 16, sobre el millón. Aquí
  se usan como pide el modelo, y se explica por qué.
- **Cuantización, vectores en disco y el índice que no cabe en RAM.** El punto de rotura de la Fase 16.
- **El boss del Bloque III**, *"Freddy ya vio esto"*: cruza grafos y vectores, y va al final de la
  Fase 16.
- **Entrenar o ajustar un modelo, elegir entre modelos, RAG.** Nada de eso entra: el modelo es una caja
  cerrada y fijada (`a06` fija el modelo y su revisión). El recorrido completo de RAG es materia del curso
  *Tutorial RAG*, del mismo autor.
- **La búsqueda de texto completo de Postgres** (`tsvector`) y la de OpenSearch: son la familia de
  búsqueda, Fases 11 y 12.

---

## 🏗️ 4. Levantar el motor

La receta está en [`a02`](a02-compose-de-la-ruta.md): la imagen fijada, el puerto HTTP en 16333 y el
volumen que la imagen no declara. El entorno de Python y la revisión fijada del modelo, en
[`a06`](a06-lenguajes-y-drivers.md). Desde `src/`:

```bash
cd lab && docker compose --profile vectorial --profile base up -d --wait && cd ..
node lab/generator/src/generate.ts --focus pirep --volume 10k
uv run python 15-vectorial-levantar-y-modelar/ingest.py --dataset lab/data/pirep-10k
```

```text
dataset pirep-10k (75d3b6802f56…) · 10000 reportes
vectores: 10000 embebidos en 17.5 s (572 por segundo, CPU) → pirep-e5-passage.f32
   10000 × 384 float32 = 14.6 MiB en disco
qdrant: colección pirep con 10000 puntos en 10 peticiones de 1000 (1.6 s) · 4 segmentos · vectores en HNSW: 0 (listo a los 1.7 s)
```

La ingesta hace dos cosas separadas, y la separación es una decisión. **Primero embebe** y escribe
los vectores en `pirep-e5-passage.f32`, junto al dataset, con un manifiesto que guarda el modelo, la
revisión, el prefijo y el hash. **Después carga** Qdrant desde ese archivo. Así, la Fase 16 carga
`pgvector` con **exactamente los mismos bytes**, y si el archivo ya existe y su hash coincide, no se
vuelve a embeber. Se embebe en CPU, a unos 570 reportes por segundo en esta máquina: la GPU del Mac
(`mps`) fue un 40 % más rápida en una prueba, pero no se verificó que dé los mismos bytes.

Fíjate en la última cifra de la salida: **vectores en HNSW: 0**. La sección 6.5 cuenta por qué, y es
lo primero que conviene saber de este motor.

La comparación de las secciones 7 y 8 necesita los mismos reportes en Postgres:

```bash
node 01-el-dominio-de-flota-y-el-arnes/load.ts --dataset lab/data/pirep-10k
psql -f 01-el-dominio-de-flota-y-el-arnes/indexes.sql   # con PGHOST=localhost PGPORT=15432…
```

---

## 📖 5. El diccionario de la familia

| Relacional | Vectorial (Qdrant) | Dónde se rompe el paralelo |
|---|---|---|
| tabla | colección | todos los puntos tienen un vector de la misma dimensión: 384 aquí |
| fila | punto: id, vector y payload | el vector no lo escribe nadie: lo calcula un modelo |
| columna | campo del payload | se filtra por él, no se busca por parecido |
| `WHERE` exacto | filtro de payload | existe y es exacto, y es la mitad útil de la familia (sección 6.6) |
| `ORDER BY … LIMIT k` | los k vecinos más cercanos | **siempre devuelve k**, aunque ninguno sirva |
| índice B-tree | índice HNSW | aproximado: puede devolver otra cosa, y no avisa |
| `EXPLAIN` | no hay plan: `indexed_vectors_count` y el parámetro `exact` | la búsqueda exacta es la referencia contra la que se mide el índice |
| la respuesta correcta | la verdad de referencia, fuera del motor | sin ella no se puede decir si el resultado está bien |

Y de vuelta: en Postgres, un punto es una fila con una columna `vector(384)` de `pgvector`; los k
vecinos son `ORDER BY embedding <=> $1 LIMIT k`; el filtro de payload es un `WHERE` normal en la misma
consulta; y HNSW es `CREATE INDEX … USING hnsw`. La Fase 16 mide esa traducción. El diccionario
completo está en [`a08`](a08-diccionario-y-glosario.md).

> 🩻 **Esto sí funciona igual.** Una consulta sigue siendo un viaje, y cargar en lotes sigue siendo lo
> que baja los viajes de la carga: 10 peticiones para 10 000 puntos. Un índice sigue teniendo un costo
> de construcción y de memoria. Y un filtro exacto sobre una columna indexada sigue siendo exacto:
> Qdrant lo resuelve con un índice de payload como lo resolvería un B-tree.

---

## 🧩 6. Modelar Cóndor a la manera vectorial

### 6.1 Qué es un embedding, y qué no

Un embedding es **una lista de números que un modelo calcula a partir de un texto**, con una
propiedad: textos que el modelo considera parecidos quedan cerca. `multilingual-e5-small` produce 384
números por texto. Nadie los elige ni los entiende uno a uno; lo único que importa es la distancia
entre dos listas.

Lo que **no** es: no es un resumen, no es una clasificación y no sabe nada de aviación. El modelo
aprendió de mucho texto general que "golpeteo" y "ruido" se usan en contextos parecidos, y por eso los
acerca. Si mañana Cóndor escribe sus reportes con una jerga que el modelo nunca vio, el modelo no lo
sabrá, y el curso no lo arregla: **no se entrena nada** (es una decisión del curso). Se usa un modelo
fijado en una revisión concreta, `614241f6…`, porque cambiar de modelo cambia todos los vectores, y la
Fase 16 mide cuánto cuesta eso.

Una consecuencia práctica, verificada en [`a06`](a06-lenguajes-y-drivers.md): **el mismo modelo en
Python y en TypeScript da el mismo vector** (coseno 1,000000). Por eso la ingesta puede ir en Python,
donde vive el ecosistema de embeddings, y la consulta en TypeScript, como el resto del curso.

### 6.2 Los prefijos que pide el modelo

La familia e5 fue entrenada con dos prefijos: `passage: ` delante de lo que se guarda y `query: `
delante de lo que se busca. La ingesta embebe `passage: <texto del reporte>`, y la consulta,
`query: ruido metalico al bajar tren`. **Olvidarlos no da error**: da vectores algo distintos. Si eso
empeora la búsqueda, y cuánto, es una apuesta de la Fase 16, escrita antes de medir. En la sesión de
verificación, con cinco reportes, el orden de los resultados no cambió ([`a06`](a06-lenguajes-y-drivers.md)).

### 6.3 El punto: vector, payload e id

En Qdrant, cada reporte es un **punto**: un id numérico, el vector y un **payload** con lo que no es
vector —`pirepId`, `aircraft`, `ataChapter`, `reportedAt` y el texto—. El payload no participa del
parecido; sirve para filtrar y para mostrar.

El diseño tiene una decisión que conviene ver: **el tipo de avería no está en el payload**. Es la
verdad de referencia, y si estuviera dentro, cualquier medición podría hacer trampa filtrando por
ella. Vive en `pirep-labels.ndjson`, y solo los scripts de evaluación la leen.

### 6.4 Buscar: coseno, producto interno y el viaje

La consulta de Freddy, desde `search.ts`:

```typescript
const [q] = await embed(["query: ruido metalico al bajar tren"]);
const { points } = await client.query("pirep", { query: q, limit: 10, with_payload: true });
```

```text
"ruido metalico al bajar tren" · 1 viaje · 10 de 10 son gear-metallic-noise
   0.912  gear-metallic-noise    ruido metalico al bajar tren de aterrizaje, intermitente a 5000 ft, segundo uvelo con lo mismo
   0.911  gear-metallic-noise    ruido raro en extension de tren de aterrizaje, como metal con metal. Favor revisar
   0.911  gear-metallic-noise    tripulacion informa ruido metalico al bajar tren de aterrizaje, intermitente, desde hace 4 dias. Favor revisar
   0.906  gear-metallic-noise    sonido metálico al bajar tren, a artos
   …
   0.902  gear-metallic-noise    post vuelo ruido raro en extension de tren de aterrizaje, como metal con metal
```

**Diez de diez del tipo correcto, en un viaje**, y con lo que la familia promete: *"sonido metálico"*,
*"como metal con metal"*, faltas de teclado incluidas (*"uvelo"*, *"a artos"*). La columna del tipo de
avería la añade el script desde la verdad de referencia; el motor no la conoce.

La colección usa **distancia coseno**, que mide el ángulo entre dos vectores y no su largo. El
**producto interno** suma los productos de cada par de números, y sí depende del largo. Con vectores
**normalizados** —de largo 1, que es lo que la ingesta pide con `normalize_embeddings=True`— son el
mismo número:

```text
coseno según Qdrant 0.911832 · producto interno a mano 0.911832 · normas 1.000000 y 1.000000
```

Así que la elección solo importa cuando los vectores no están normalizados: ahí el producto interno
premia a los vectores largos, y un texto largo puede ganar por largo y no por parecido. **Normaliza
al embeber y la pregunta desaparece.**

### 6.5 HNSW: el índice que no existía

HNSW es un grafo de varias capas: cada punto se une a unos pocos vecinos, y una búsqueda salta de
vecino en vecino acercándose a la consulta, sin mirar todos los puntos. Tiene dos parámetros que
importan de verdad:

- **`m`**, cuántos vecinos guarda cada punto (16 aquí). Más vecinos, más memoria y mejor recall.
- **`ef`**, cuántos candidatos explora la búsqueda. Al construir es `ef_construct` (100 aquí), y al
  consultar, `hnsw_ef`: el mando que cambia recall por trabajo en cada consulta.

Y aquí la sorpresa de la sección 4: **con 10 000 reportes, Qdrant no había construido el índice.**

```text
vectores en HNSW: 0    ·    optimizers_config.indexing_threshold: 10000 (kB)
```

Qdrant guarda los puntos en segmentos, y **no indexa un segmento que pese menos de
`indexing_threshold`**, 10 000 kB por defecto. Los 10 000 vectores se repartieron en 4 segmentos de
unos 3,7 MB cada uno, todos por debajo, así que cada consulta fue una **búsqueda exacta**: recorrer los
2500 vectores de cada segmento. A este tamaño es lo correcto —recorrer es barato y acierta siempre—,
pero significa que **todo lo que hayas medido de "HNSW" con pocos datos no medía HNSW**.

Para ver el índice con 10 000 puntos, `ingest.py --force-index` baja los dos umbrales a 10 kB, el
mínimo que Qdrant acepta (con 1 responde `must be 10 or larger`, entrada E-33 en
[`a09`](a09-catalogo-de-errores.md)):

```text
qdrant: colección pirep_hnsw con 10000 puntos en 10 peticiones de 1000 (1.7 s) · 4 segmentos · vectores en HNSW: 10000 (listo a los 5.2 s)
```

Y con el índice construido, `search.ts` toma 100 reportes como consulta y compara los diez primeros de
HNSW con los diez de la búsqueda exacta (`params: { exact: true }`):

> 📐 **Medición — el recall del índice según `hnsw_ef`** · `pirep-10k`, 100 consultas, `m` 16,
> `ef_construct` 100 · `qdrant/qdrant@sha256:12364fe851b9…` · verificado el 30/09/2026
>
> | `hnsw_ef` | recall@10 del índice |
> |---|---|
> | 4 | 0,983 |
> | 10 | 0,983 |
> | 32 | 1,000 |
> | 128 | 1,000 |
>
> Reproducir: `uv run python 15-vectorial-levantar-y-modelar/ingest.py --force-index --collection
> pirep_hnsw` y `node 15-vectorial-levantar-y-modelar/search.ts --collection pirep_hnsw`

Aquí **recall** tiene un sentido preciso, y el curso lo va a usar en dos sentidos distintos, así que
conviene fijarlo: **el recall del índice** es qué parte de los diez vecinos exactos devuelve el índice
aproximado. No dice nada de si esos vecinos son del tipo de avería correcto. `ef` 4 y 10 dan lo
mismo porque Qdrant nunca explora menos candidatos que los que le pides devolver (10). A 10 000 puntos
el índice casi no pierde nada; con un millón, es la [Fase 16](16-vectorial-romper-y-medir.md).

### 6.6 El filtro de payload: donde la familia se vuelve útil

Freddy no quiere los parecidos de toda la flota: quiere los de **esta aeronave**, o los del **capítulo
ATA 32**, el tren de aterrizaje. El filtro de payload es exacto, y se combina con la búsqueda en la
misma consulta:

```typescript
await client.query("pirep", { query: q, limit: 10, filter: { must: [{ key: "aircraft", match: { value: "HK-5278" } }] } });
```

```text
filtro aircraft = HK-5278 (79 reportes de esa aeronave): 10 resultados, 6 gear-metallic-noise
filtro ataChapter = 32: 10 de 10 del capítulo 32
```

Con el filtro por aeronave, **6 de 10** son del tipo buscado, y eso no es porque falten: esa aeronave
tiene **11** reportes de ruido de tren entre sus 79. `search.ts` busca dónde quedaron los otros cinco:

```text
   HK-5278 tiene 11 gear-metallic-noise; puestos entre sus 79: 1, 2, 3, 4, 5, 6, 11, 17, 25, 29, 43
   #17  0.839  PIC reporta golpeteo al extender tren de aterrizaje der, se repite en final corta, desde hace 3 dias. se anota en libro
   #29  0.826  LG IZQ SUENA AL DESPLEGAR, TRIPULACION REPORTA GOLPE SECO. SE ANOTA EN LIBRO
   #43  0.821  golpeteo al extender LG derecho, se repite en final corta tramo EJA-TRB
```

(Recortada a tres de los cinco.) **El *"golpeteo al extender"* que prometía la familia existe, y quedó en
los puestos 17 y 43**, por debajo de reportes de luz de tren, de frenos y de radio que comparten
palabras con la consulta: *"tren"*, *"aterrizaje"*, *"ruido"*. La búsqueda encuentra el parecido, pero
lo ordena mezclado con lo que se parece por otras razones. Es lo que la sección 7 mide sobre el corpus
entero: **el vector ordena, no separa**.

La ingesta crea un **índice de payload** para `aircraft` (keyword) y para `ataChapter` (entero). Sin
él, Qdrant filtra leyendo los payloads; con él, sabe qué puntos cumplen antes de buscar. Es la misma
idea que un B-tree, y es lo que hace del filtro algo barato. Cuánto cambia con un millón, y cómo lo
hace `pgvector` con un `WHERE`, es la Fase 16.

### 6.7 Cargar es modelar, otra vez

Igual que en la Fase 03, el cargador guarda todas las decisiones:

- **El archivo de vectores es el contrato.** El orden es el de `pirep.ndjson`, el formato es float32
  little-endian, y el manifiesto lleva el hash. La Fase 16 lo carga en `pgvector` sin volver a embeber.
- **Embeber es lo caro; cargar, no.** 17,5 s para embeber 10 000 reportes contra 1,6 s para cargarlos.
  A un millón, embeber son unos treinta minutos en esta máquina.
- **El payload es lo que se va a filtrar y mostrar.** Nada más: la verdad de referencia se queda fuera.
- **Los índices de payload se crean al crear la colección**, antes de que alguien necesite filtrar.

> 🧠 **El patrón a memorizar.** En vectorial no se modela la entidad ni la pregunta: se modela **qué
> significa "parecido"**, y eso lo decide un modelo que no controlas. Lo que sí controlas es el resto:
> qué va en el payload para filtrar, qué índice se construye y con qué parámetros, y contra qué verdad
> vas a medir que el resultado sirve.

---

## 🪞 7. Tu instinto relacional dice… y esta vez se equivoca

> 🪞 **"Esto es buscar con `LIKE`, pero mejor."** Un `LIKE` que entiende sinónimos y faltas de ortografía.

Es un instinto razonable: los dos reciben un texto y devuelven reportes. Si el vector encuentra
*"golpeteo al extender"* cuando buscas *"ruido metálico"*, parece un `LIKE` con superpoderes.

`compare.ts` pone las dos formas contra la verdad de referencia. Hay **1258** reportes del tipo
*gear-metallic-noise* en `pirep-10k`, y cada forma dice cuántos devuelve, cuántos son de ese tipo y qué
parte de los 1258 encuentra:

| Forma | Devuelve | Del tipo correcto | Encuentra de los 1258 |
|---|---|---|---|
| `ILIKE '%ruido metalico al bajar tren%'` | 19 | 19 | 1,5 % |
| `ILIKE '%ruido metalico%'` | 31 | 31 | 2,5 % |
| `ILIKE '%ruido%'` | 188 | 98 | 7,8 % |
| `ILIKE '%tren%'` | 1901 | 931 | 74,0 % |
| vectores, los 10 más parecidos | 10 | **10** | 0,8 % |
| vectores, los 100 más parecidos | 100 | **100** | 7,9 % |
| vectores, los 1258 más parecidos | 1258 | 728 | 57,9 % |
| búsqueda de *"arepas"* | `ILIKE`: **0** | vectores: **10** | — |

Hay dos lecturas, y las dos rompen el instinto.

**La primera: el vector no devuelve un conjunto, devuelve un orden.** `ILIKE` contesta *"estos son los
que cumplen"*, y lo que cumple, cumple. El vector contesta *"estos son los más parecidos, de más a
menos"*, y el número de resultados lo pones tú. Arriba del todo es impecable: 100 de 100. Pero si le
pides tantos como reportes hay del tipo, solo **728 de 1258** son correctos: el vector no sabe dónde
acaban los reportes de tren y empiezan los de frenos, que también hablan de tren y de aterrizaje.
Ningún número de la tabla es *"la respuesta"*.

**La segunda: siempre devuelve algo.** *"Receta de arepas con queso"* devolvió diez reportes, con
similitudes entre 0,833 y 0,839, que no están lejos de las de la búsqueda buena (0,90–0,91). El motor
no sabe decir *"no hay nada parecido"*, y un umbral fijo tampoco lo arregla: las similitudes de e5 se
agolpan entre 0,8 y 0,9 ([`a06`](a06-lenguajes-y-drivers.md)).

**El instinto no se equivoca en que el vector entiende lo que `LIKE` no: se equivoca en creer que
devuelve la respuesta correcta.** Es la primera familia del curso que devuelve las parecidas, y
por eso se evalúa distinto: contra una verdad de referencia, con una métrica que dice cuánto sirve lo
que volvió. La pregunta del instrumento que lo habría anticipado es la 5, **¿exactitud o parecido?**
Este instinto entra en [`INSTINTOS.md`](INSTINTOS.md) con la medición M-11.

---

## ⚰️ 8. La situación 3: elegiste bien la familia y la modelaste como relacional

**La decisión, con su mejor argumento.** *"Ya tenemos los reportes en Qdrant. La pantalla de la
aeronave necesita sus reportes, así que buscamos por la matrícula: el vector la entiende, y nos
ahorramos otra consulta a Postgres."*

**Por qué era razonable.** Qdrant ya estaba, los reportes también, y la búsqueda devuelve cosas que se
parecen a la matrícula. En una demo con tres reportes, funciona.

**Qué pasó después, con número.** La aeronave con más reportes de `pirep-10k`, `HC-1499`, tiene 186:

```text
los reportes de HC-1499 (186):
   Postgres, índice pirep_aircraft_reported_at: examina 186 → devuelve 186 · Bitmap Heap Scan on pirep
   vectores, "HC-1499", los 186 más parecidos: 4 son de HC-1499
   vectores, "reportes de la aeronave HC-1499", los 186 más parecidos: 8 son de HC-1499
   Qdrant con filtro de payload (índice keyword sobre aircraft): 186
el tramo IQT-LQM: ILIKE encuentra 7 · vectores, los 10 más parecidos a "tramo IQT-LQM": 3 lo contienen
```

**Cuatro de 186.** La matrícula no está en el texto de los reportes: está en una columna. El vector
compara el parecido de *"HC-1499"* con frases de averías, y lo que devuelve es ruido con buena cara.
Incluso cuando el dato sí está en el texto —el tramo `IQT-LQM`, en 7 reportes—, el vector encuentra 3
en sus diez primeros: un código es un identificador, y los identificadores no se parecen, **son o no
son**.

**Cuánto costó salir.** Nada, y esa es la lección: el mismo Qdrant lo resuelve bien con **un filtro de
payload**, que devuelve los 186 exactos, y Postgres con el índice que ya tenía, examinando 186 filas
para devolver 186. El costo fue el de no darse cuenta: una pantalla que muestra 186 reportes, de los
que 182 son de otras aeronaves, parece funcionar hasta que alguien firma con ella.

**La pregunta que lo habría evitado es la 5: ¿exactitud o parecido?** Una matrícula, un número de
parte, un tramo, un número de serie: todo eso pide exactitud, y para la exactitud hay un índice de
toda la vida que gana por goleada y encima acierta.

**Antes y después, con números:**

| | Cómo | Devuelve de `HC-1499` |
|---|---|---|
| antes: vectores, *"HC-1499"* | los 186 más parecidos | **4 de 186** |
| después: filtro de payload en Qdrant | `aircraft = HC-1499`, índice keyword | 186 de 186 |
| después: Postgres | índice B-tree, 186 examinadas | 186 de 186 |

---

## ⚠️ 9. Errores comunes y diagnóstico

**Un vector de otra dimensión** (E-32 en [`a09`](a09-catalogo-de-errores.md)). Desde el cliente de
TypeScript, el error solo dice `Error: Bad Request`; el mensaje útil está en `e.data.status.error`:
`Wrong input: Vector dimension error: expected dim: 384, got 3`. 🩺 Mira siempre `e.data`, no solo
`e.message`. Casi siempre es otro modelo, o el vector de otra colección.

**Un umbral por debajo del mínimo** (E-33): `Validation error in JSON body:
[hnsw_config.full_scan_threshold: value 1 invalid, must be 10 or larger]`, con un `422`. 🩺 El mensaje
nombra el campo y el mínimo.

**Una colección que no existe** (E-34): `Not found: Collection \`pireps\` doesn't exist!`, con
`Error: Not Found` en el `e.message` del cliente. 🩺 `GET /collections` lista las que hay.

**El índice que no está.** No da error: `indexed_vectors_count: 0` en `GET /collections/<nombre>`. 🩺 Si
es 0 con pocos datos, los segmentos no llegan a `indexing_threshold` y toda búsqueda es exacta (sección
6.5). No es un fallo, pero invalida cualquier medición "del índice" que hayas hecho.

**Resultados que no sirven, sin error.** 🩺 Mide contra una verdad de referencia, aunque sean veinte
casos anotados a mano. Si la consulta es una matrícula, un código o un número de serie, no es una
consulta de parecido (sección 8). Y si olvidaste el prefijo `query: `, tampoco da error: la Fase 16
mide si importa.

---

## 📋 10. Checklist de validación

```text
[ ] ingest.py verificó pirep-10k (75d3b6802f56…), escribió pirep-e5-passage.f32 con su manifiesto y cargó 10 000 puntos en 10 peticiones
[ ] La segunda ejecución de ingest.py no volvió a embeber: el hash coincidía
[ ] "ruido metalico al bajar tren" devuelve 10 de 10 gear-metallic-noise en 1 viaje
[ ] Sé por qué el coseno y el producto interno dan lo mismo aquí, y cuándo no
[ ] La colección pirep tiene 0 vectores en HNSW, y sé por qué
[ ] Con --force-index, el recall@10 del índice es 0,983 con ef 4 y 1,000 con ef 32
[ ] Distingo recall del índice y acierto de tipo de avería
[ ] Filtrando por HK-5278, los 11 reportes de ruido de tren quedan en los puestos 1–6, 11, 17, 25, 29 y 43
[ ] compare.ts: los 1258 más parecidos aciertan 728; "arepas" devuelve 0 con ILIKE y 10 con vectores
[ ] La situación 3: 4 de 186 por parecido, 186 de 186 con filtro de payload o con el índice de Postgres
[ ] El 🪞 de esta fase está en INSTINTOS.md, M-11 en la bitácora, E-32 a E-34 en a09
```

---

## 🧪 11. Ejercicios (24)

Salvo donde se indique, contra `pirep-10k` cargado en Qdrant por `ingest.py` y en Postgres por la Fase
01. El código de la fase está en `src/15-vectorial-levantar-y-modelar/`.

### 🟢 Fácil — el punto y la consulta (1–7)

#### 🟢 Ejercicio 1 — Tu ingesta

Ejecuta `ingest.py` dos veces seguidas.

**Objetivo:** la primera embebe y la segunda no. Encuentra en el manifiesto de vectores el campo que lo
decide y explica qué pasaría si cambias un byte del archivo.

#### 🟢 Ejercicio 2 — Un punto por dentro

Pide un punto por su id con `GET /collections/pirep/points/0`, con y sin `with_vector`.

**Objetivo:** identificar el payload y comprobar que el vector tiene 384 números y norma 1.

#### 🟢 Ejercicio 3 — Tres consultas de Freddy

Busca *"olor a quemado en cabina"*, *"luz de tren no enciende"* y *"se desconecta el autopiloto"*.

**Objetivo:** cuántos de los diez primeros son del tipo correcto en cada una, según `pirep-labels.ndjson`.

#### 🟢 Ejercicio 4 — La consulta sin sentido

Busca tres frases que no tengan nada que ver con aviación.

**Pregunta:** ¿qué similitudes devuelven? ¿Podrías fijar un umbral que separe lo bueno de lo absurdo?

#### 🟢 Ejercicio 5 — El índice que no existe

Lee `GET /collections/pirep` y `GET /collections/pirep_hnsw`.

**Objetivo:** encontrar `indexed_vectors_count`, `segments_count` e `indexing_threshold`, y explicar la
diferencia entre las dos.

#### 🟢 Ejercicio 6 — Filtrar

Repite la consulta de Freddy filtrando por el capítulo ATA 32 y después por el 21.

**Pregunta:** ¿qué devuelve el filtro por el 21, si ningún reporte de ruido de tren es de ese capítulo?

#### 🟢 Ejercicio 7 — Coseno a mano

Con dos vectores del archivo `.f32`, calcula el coseno y el producto interno en Python.

**Objetivo:** obtener el mismo número, y cambiarlo multiplicando uno de los vectores por 2.

### 🟡 Intermedio — medir lo que vuelve (8–14)

#### 🟡 Ejercicio 8 — El acierto de los diez tipos

Usa como consulta un reporte de cada uno de los diez tipos de avería.

**Objetivo:** el acierto de tipo en los diez primeros por tipo. ¿Cuál es el peor, y con qué tipo se
confunde?

#### 🟡 Ejercicio 9 — `ef` a mano

Con `pirep_hnsw`, mide el recall@10 del índice con `hnsw_ef` de 1 a 10.

**Pregunta:** ¿por qué no cambia hasta que pasa de 10? Pide `limit` 3 y repite.

#### 🟡 Ejercicio 10 — `m`

Crea una colección con `m` 4 y otra con `m` 32, las dos con `--force-index`.

**Objetivo:** recall@10 del índice con `ef` 10 en las dos, y el tiempo que tardó en construirse cada
una.

#### 🟡 Ejercicio 11 — Sin índice de payload

Crea una colección sin los índices de payload y filtra por aeronave.

**Objetivo:** comprobar si el resultado cambia (no debería) y buscar en la documentación qué cambia por
dentro.

#### 🟡 Ejercicio 12 — `LIKE` con faltas

Busca con `ILIKE` las formas de *"metálico"* que aparecen en el corpus: con tilde, sin tilde y con
letras cambiadas.

**Objetivo:** cuántas variantes existen, y cuántos reportes más encuentra `ILIKE` si las pones todas.

#### 🟡 Ejercicio 13 — El orden como respuesta

Para la consulta de Freddy, calcula el acierto de tipo en los primeros 10, 50, 100, 500 y 1258.

**Objetivo:** una curva. ¿Dónde empieza a caer, y qué te dice eso sobre cuántos resultados mostrar?

#### 🟡 Ejercicio 14 — El tramo

Busca los reportes del tramo `VVC-MIT` con `ILIKE`, con vectores y con un filtro.

**Pregunta:** ¿por qué el filtro de payload no sirve aquí, y qué tendría que cambiar en la ingesta para
que sirviera?

### 🟠 Difícil — cuando el parecido engaña (15–20)

#### 🟠 Ejercicio 15 — Las mayúsculas

El 30 % de los reportes está en mayúsculas. Busca la consulta de Freddy en mayúsculas.

**Objetivo:** el acierto de tipo en los diez primeros, y cuántos de ellos están en mayúsculas.

#### 🟠 Ejercicio 16 — Los duplicados

Encuentra reportes con el mismo texto exacto en `pirep-10k`.

**Pregunta:** ¿qué similitud tienen entre ellos? ¿Cómo afectarían a una medición de recall si fueran el
15 % del corpus, como en `pirep-1m`?

#### 🟠 Ejercicio 17 — Parecido sin tipo

Encuentra dos reportes de tipos distintos con una similitud mayor que la de dos del mismo tipo.

**Objetivo:** los cuatro textos y sus similitudes, y una explicación de qué los acerca.

#### 🟠 Ejercicio 18 — La pantalla de la aeronave

Diseña la consulta de la pantalla de Freddy: los reportes de esta aeronave, y para cada uno, los tres
más parecidos de toda la flota.

**Objetivo:** cuántos viajes cuesta, y cómo bajarlos con las consultas por lotes de Qdrant.

#### 🟠 Ejercicio 19 — Un umbral honesto

Con la verdad de referencia, busca la similitud que mejor separa *"del mismo tipo"* de *"de otro tipo"*
en 1000 pares.

**Objetivo:** el umbral, y qué parte de los pares clasifica mal. ¿Lo usarías en producción?

#### 🟠 Ejercicio 20 — La matrícula, bien

Reescribe la situación 3 en Qdrant con `scroll` y filtro de payload, sin vector.

**Objetivo:** los 186 reportes de `HC-1499` en el menor número de viajes, y compararlo con Postgres.

### 🔴 Muy difícil — decidir qué es parecido (21–24)

#### 🔴 Ejercicio 21 — Una verdad de referencia propia

Anota a mano 20 pares de reportes *"esto es lo mismo"* sin mirar el tipo de avería.

**Objetivo:** medir el vector contra tu verdad y contra la del generador. ¿Coinciden? ¿Cuál de las dos
se parece más a lo que haría Freddy?

#### 🔴 Ejercicio 22 — La autopsia inversa

Escribe la autopsia de un equipo que usó `ILIKE` para *"esto ya lo vimos"* durante tres años.

**Objetivo:** los cinco pasos de la Fase 00, con la factura calculada con los números de la sección 7.

#### 🔴 Ejercicio 23 — Híbrido

Combina en una sola pantalla un filtro exacto (aeronave o capítulo), un `ILIKE` para códigos y la
búsqueda por parecido.

**Objetivo:** el diseño, cuántos viajes cuesta y qué motor hace cada parte. (La Fase 16 lo mide con
`pgvector` en una sola consulta.)

#### 🔴 Ejercicio 24 — Qué no es de esta familia

Toma las preguntas de las diez pantallas de Cóndor que conoces por la historia.

**Objetivo:** una tabla que diga, para cada una, si es exactitud o parecido, con la razón. Ninguna fila
sin justificar.

---

## 📚 12. Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación de Qdrant cubre la última versión. Esta fase
> se verificó con Qdrant 1.19.1, qdrant-client 1.19.1, `@qdrant/js-client-rest` 1.19.0 y
> `intfloat/multilingual-e5-small` en la revisión `614241f6…`.

- **Colecciones, puntos y payload** — https://qdrant.tech/documentation/concepts/ — el modelo de datos.
- **Indexación** — https://qdrant.tech/documentation/concepts/indexing/ — HNSW, índices de payload y
  los umbrales de la sección 6.5.
- **Optimizador** — https://qdrant.tech/documentation/concepts/optimizer/ — segmentos e
  `indexing_threshold`.
- **Filtrado** — https://qdrant.tech/documentation/concepts/filtering/
- **Tarjeta del modelo e5** — https://huggingface.co/intfloat/multilingual-e5-small — los prefijos
  `query:` y `passage:`, en la voz de sus autores.
- **Yu. A. Malkov y D. A. Yashunin, *Efficient and robust approximate nearest neighbor search using
  Hierarchical Navigable Small World graphs*** — https://arxiv.org/abs/1603.09320 — el paper de HNSW.
- ***Tutorial RAG***, del mismo autor: qué se hace con esto después. Lectura sugerida, no
  requisito.

**Orden sugerido:** los conceptos antes de la sección 6; indexación y optimizador durante la 6.5; el
paper de HNSW antes de la Fase 16.

---

## 🏁 13. Resultado de la fase

Tienes los reportes de Cóndor en Qdrant, embebidos una vez y guardados con su hash, y una forma de
saber si la búsqueda sirve: **10 de 10** arriba del todo, **728 de 1258** si le pides el tipo entero,
y **10 resultados** para una receta de arepas. Sabes que tu índice no existía, y por qué. Y sabes
dónde no usar la familia: **4 de 186** buscando una matrícula por parecido.

```text
Qdrant, colección pirep (e5-small, 384 dimensiones, coseno)
├── punto: id · vector · payload { pirepId, aircraft, ataChapter, reportedAt, text }
├── índices de payload: aircraft (keyword) · ataChapter (entero)
├── HNSW m 16 · ef_construct 100      ← 0 vectores indexados con 10 000 puntos
└── fuera del motor: pirep-e5-passage.f32 (los vectores) · pirep-labels.ndjson (la verdad)
```

> **La señal de que quedó bien:** *"Puedo decir cuánto sirve lo que devuelve mi búsqueda por
> parecido, contra qué lo medí, y qué preguntas de Cóndor no le haría nunca."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-15-vectorial-levantar-y-modelar -m "F15 cerrada: 10k reportes embebidos y cargados; 10 de 10 en 1 viaje; HNSW sin construir bajo el umbral; LIKE contra vectores medido; situación 3, 4 de 186"
> ```
>
> Commits de la fase con prefijo `f15:`, los de ejercicio `f15 ej17: …`.
