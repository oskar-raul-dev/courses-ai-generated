# 📎 Apéndice a07 — Postgres como línea base

> **Curso:** Ruta NoSQL Lite · Consulta rápida · **3 h**
> **Usado por:** todas las fases B · **Versiones cubiertas:** PostgreSQL 18.6
> `pgvector/pgvector@sha256:2ba9ca5f2e7d…` y pgvector 0.8.6
> **Fecha de verificación ejecutada:** 29/09/2026, en macOS arm64, sobre `workOrder-1m` cargado con la
> [Fase 01](01-el-dominio-de-flota-y-el-arnes.md)

**Cuando el curso mide contra Postgres, Postgres va con su mejor configuración razonable**, no con
la de fábrica. Ganarle a una línea base mal puesta no demuestra nada, y el lector que sabe lo nota
en tres segundos. Y el corolario para quien escribe una fase: si no sabes cuál es la mejor forma
relacional de resolver algo, **todavía no puedes escribir esa comparación**.

**Esto no se lee de corrido.** Es el apéndice que sostiene el *"casi siempre gana Postgres"*: una
sección por cada cosa que hace que Postgres no necesite otro motor, con su mejor configuración y
su medición sobre los datos de Cóndor. Los scripts están en `src/a07-postgres-linea-base/`.

**Qué queda fuera:** administración, replicación y tuning de producción. Leer un plan campo por
campo está en la [Fase 01](01-el-dominio-de-flota-y-el-arnes.md) §4.4, y qué números extrae el arnés,
en [`a04`](a04-el-arnes-de-medida.md).

---

## Índice

- [JSONB con GIN, y cuándo `jsonb_path_ops` cambia el resultado](#-jsonb-con-gin)
- [Full-text: `tsvector`, diccionario y ranking](#-full-text)
- [`pgvector`: HNSW e IVFFlat](#-pgvector)
- [`WITH RECURSIVE` bien escrito, con corte de ciclos](#-with-recursive-bien-escrito)
- [Particionado declarativo por rango](#️-particionado-declarativo-por-rango)
- [Tablas `UNLOGGED`](#-tablas-unlogged)
- [`EXPLAIN ANALYZE` ejecuta la sentencia](#️-explain-analyze-ejecuta-la-sentencia)
- [Cuándo usar qué](#-cuándo-usar-qué) · [Referencias](#-referencias) · [Ejercicios](#-ejercicios-8)

---

## 🧩 JSONB con GIN

**Para qué:** lo que no tiene los mismos campos en todos los registros —`part.details`, que es
calibración en un instrumento y ciclos en un motor—, consultado sin salir de Postgres. Es el rival
de Mongo en las Fases 03 y 04.

Las piezas de motor con un TBO de 6000 horas, sobre 740 741 piezas:

```sql
SELECT count(*) FROM part WHERE details @> '{"tboHours": 6000}';   -- 20 733
```

| Configuración | Filas examinadas | Tamaño del índice |
|---|---|---|
| sin índice | ≈ 740 742 (`Parallel Seq Scan`, `loops=3`) | — |
| `USING gin (details)` (`jsonb_ops`) | 20 733 | 5200 kB |
| `USING gin (details jsonb_path_ops)` | 20 733 | 4064 kB |

**`jsonb_path_ops` es más pequeño y sirve para `@>`, pero no para todo.** No indexa las claves por
separado, así que no puede contestar *"¿tiene esta clave?"*. Con `details ? 'retreadCount'`,
`jsonb_ops` usa el índice (`Bitmap Index Scan … rows=104226`) y `jsonb_path_ops` vuelve al
recorrido completo (`Parallel Seq Scan`, `Rows Removed by Filter: 212172` por proceso). **Elige el
operador de clase según las consultas, no según el tamaño.**

> ⚠️ **`->>` no usa el índice GIN.** `details->>'tboHours' = '6000'` pregunta lo mismo en palabras y
> recorre la tabla entera (`Parallel Seq Scan`), aunque el GIN esté ahí. El GIN sirve a `@>`, `?`,
> `?|` y `?&`. Si la consulta tiene que ser `->>`, el índice es otro: uno de expresión sobre
> `(details->>'tboHours')`.

---

## 🔎 Full-text

**Para qué:** buscar en el catálogo *"juntas toricas del tren"* y encontrar *"junta tórica del
tren"*. Es el rival de OpenSearch en las Fases 11 y 12.

```sql
ALTER TABLE part_catalog
  ADD COLUMN search tsvector GENERATED ALWAYS AS (to_tsvector('spanish', description)) STORED;
CREATE INDEX part_catalog_search ON part_catalog USING gin (search);

SELECT part_number, description, ts_rank(search, q) AS rank
FROM part_catalog, plainto_tsquery('spanish', 'juntas toricas del tren') q
WHERE search @@ q ORDER BY rank DESC LIMIT 5;
```

**El diccionario hace el trabajo.** `to_tsvector('spanish', 'juntas tóricas del tren')` da
`'junt':1 'toric':2 'tren':4`: plurales fuera, tildes fuera y *"del"* descartada como palabra
vacía. Sobre 1 481 481 referencias:

| Búsqueda | Resultados |
|---|---|
| `plainto_tsquery('spanish', 'junta tórica')` | 107 464 |
| `plainto_tsquery('spanish', 'juntas toricas')` | 107 464 |
| `plainto_tsquery('spanish', 'junta torica')` | 107 464 |
| `description LIKE '%junta torica%'` | **0** |

El índice GIN ocupa 7320 kB, y la consulta con ranking examina las 15 267 que contienen las tres
palabras.

> 📝 **`unaccent` no hizo falta, y es un resultado.** Se esperaba necesitarla para *"torica"* sin
> tilde. El diccionario `spanish` de Postgres 18 ya reduce a la misma raíz, con o sin tilde,
> *tórica*, *hélice*, *cámara*, *hidráulica* y *altímetro*. Con una configuración que añadía
> `unaccent`, **ningún resultado del catálogo cambió**. Un efecto secundario que conviene conocer:
> *"cámara"* se reduce a `cam`, una raíz tan corta que puede coincidir con otras palabras.

---

## 🧬 `pgvector`

**Para qué:** *"esto ya lo vimos"*, el parecido entre reportes de piloto. Es el rival de Qdrant en
las Fases 15 y 16.

```sql
CREATE EXTENSION vector;
CREATE TABLE pirep_embedding (pirep_id text PRIMARY KEY REFERENCES pirep, embedding vector(384));
CREATE INDEX ON pirep_embedding USING hnsw (embedding vector_cosine_ops);
SELECT pirep_id FROM pirep_embedding ORDER BY embedding <=> $1 LIMIT 10;
```

Los vectores salen de `intfloat/multilingual-e5-small`, en la revisión fijada en
[`a06`](a06-lenguajes-y-drivers.md), con `uv run python a07-postgres-linea-base/embed_pireps.py`. Con 2000
pireps y la consulta *"ruido metálico al bajar tren"*, los diez más parecidos según cada índice,
comparados con la búsqueda exacta (sin índice):

| Índice | Aciertos en los 10 primeros |
|---|---|
| exacta, sin índice | 10 (la referencia) |
| HNSW, parámetros por defecto | 10 |
| IVFFlat, `lists = 20`, `ivfflat.probes = 1` | **8** |
| IVFFlat, `lists = 20`, `ivfflat.probes = 5` | 10 |

**Un índice aproximado puede devolver otra cosa, y no avisa.** IVFFlat con una sola sonda perdió
dos de los diez sin ningún error. Lo que encontró la búsqueda, por cierto, es justo lo que
promete la familia: *"sonido metalico al bajar tren de aterrizaje"*, *"se escucha clanc duro cuando
baja el tren"*. **Recall contra velocidad** es la métrica propia de vectorial, y se mide en la
Fase 16 sobre el corpus completo.

---

## 🔁 `WITH RECURSIVE` bien escrito

**Para qué:** recorrer relaciones de profundidad variable. Es el rival de Neo4j en las Fases 13 y
14, y la línea base de la apuesta que el curso espera perder.

La trazabilidad como grafo: de una pieza a las aeronaves donde se instaló, de cada aeronave a las
piezas que recibió, y así sucesivamente. Pieza → aeronave → pieza vuelve sobre sí mismo todo el
tiempo, y `CYCLE` (Postgres 14 o posterior) corta el camino que regresa a un nodo ya visitado:

```sql
WITH RECURSIVE trace(node, depth) AS (
  SELECT 'part:' || :'serial', 0
  UNION ALL
  SELECT e.dst, t.depth + 1 FROM trace t JOIN trace_edge e ON e.src = t.node WHERE t.depth < :depth
) CYCLE node SET is_cycle USING path
SELECT depth, count(DISTINCT node), count(*), count(*) FILTER (WHERE is_cycle) FROM trace GROUP BY depth;
```

**"Bien escrito" son dos cosas, y la primera costó una medición entender.** Las aristas van en una
tabla con índice por su origen (`trace_edge`, en `recursive.sql`). La primera versión de este
ejemplo resolvía las dos direcciones con un `OR` dentro del `JOIN` —`ON t.node = 'part:' || … OR
t.node = 'aircraft:' || …`—: un `OR` así impide usar índices, y cada salto recorría 1,2 millones de
movimientos. **A profundidad 3 no terminó en cinco minutos. Bien escrita, tarda menos de un
segundo.**

Desde la pieza que pasó por más aeronaves (`SN-0391969`, 18 aeronaves), sobre `workOrder-1m`:

| Profundidad | Nodos | Filas del CTE | Ciclos cortados |
|---|---|---|---|
| 1 | 18 | 18 | 0 |
| 2 | 4 101 | 4 240 | 18 |
| 3 | 766 | 15 934 | 4 222 |
| 4 | 85 981 | 2 984 904 | 11 964 |

**`WITH RECURSIVE` enumera caminos, no nodos.** A profundidad 4 genera casi tres millones de filas
para llegar a 86 000 nodos, y sin `CYCLE` son 4 095 207. Hasta dónde aguanta esto contra un motor de
grafos es la pregunta de la Fase 14.

---

## 🗓️ Particionado declarativo por rango

**Para qué:** datos que llegan ordenados en el tiempo, se consultan por rango y se borran por
antigüedad. Es el rival de TimescaleDB en las Fases 09 y 10.

```sql
CREATE TABLE reading_p (LIKE reading INCLUDING DEFAULTS) PARTITION BY RANGE (ts);
CREATE TABLE reading_p_202503 PARTITION OF reading_p
  FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');   -- una por mes: 60 (partition.sql)
```

Las lecturas de marzo de 2025, sobre las 200 000 lecturas del dataset:

| Tabla | Cómo accede | Filas examinadas | Bloques |
|---|---|---|---|
| `reading`, sin particionar | `Index Only Scan` por la clave `(aircraft, ts)`, `Index Searches: 701` | 2 811 | 2 380 |
| `reading_p`, 60 particiones | `Seq Scan` **solo** de `reading_p_202503` | 2 811 | 31 |

Dos lecturas. El planificador **descarta las 59 particiones** que no pueden tener filas (*partition
pruning*). Y la tabla sin particionar no hace un recorrido completo, gracias a una novedad de
Postgres 18, el *skip scan*: usa el índice `(aircraft, ts)` aunque la consulta no filtre por
aeronave, bajando por él una vez por cada una (`Index Searches: 701`). Las filas examinadas son
las mismas; **los bloques no**. Es uno de los casos donde el cociente de filas no cuenta toda la
historia.

**Borrar un mes** es donde el particionado cambia de categoría: `DELETE … WHERE ts` examina y borra
fila por fila, y `ALTER TABLE reading_p DETACH PARTITION reading_p_202203; DROP TABLE
reading_p_202203;` quita el mes entero **sin examinar ninguna fila**.

---

## 💨 Tablas `UNLOGGED`

**Para qué:** datos que se pueden perder: sesiones, cachés, candados. Es el rival de Valkey en las
Fases 05 y 06.

```sql
CREATE UNLOGGED TABLE session_unlogged (
  session_id text PRIMARY KEY, technician_id text NOT NULL, terminal text NOT NULL, expires_at timestamptz NOT NULL
);
```

Una tabla `UNLOGGED` no escribe en el WAL, y eso tiene un precio exacto, verificado el 29/09/2026
con 100 000 sesiones en una tabla normal y en una `UNLOGGED`:

| Qué pasó | Tabla normal | `UNLOGGED` |
|---|---|---|
| antes | 100 000 | 100 000 |
| `docker kill --signal=KILL` y arranque | 100 000 | **0** |
| apagado limpio (`docker compose stop`) y arranque | 100 000 | 100 000 |

El log del arranque tras la caída lo dice: `database system was not properly shut down; automatic
recovery in progress`. **La recuperación vacía toda tabla `UNLOGGED`**. Un apagado limpio, en
cambio, la conserva. El matiz importa: *"UNLOGGED pierde los datos"* es cierto solo ante una caída.

---

## ⚠️ `EXPLAIN ANALYZE` ejecuta la sentencia

`EXPLAIN ANALYZE` no simula: **ejecuta**. Con un `INSERT`, `UPDATE` o `DELETE`, los cambios son
reales. En la verificación de este apéndice, un `EXPLAIN ANALYZE DELETE FROM reading WHERE ts …`
borró de verdad 178 lecturas, y hubo que recargar la base. La forma segura:

```sql
BEGIN;
EXPLAIN (ANALYZE) DELETE FROM session_logged WHERE technician_id = 'T-001';
ROLLBACK;   -- las 111 filas siguen ahí
```

---

## 🧭 Cuándo usar qué

| Situación | Lo mejor razonable en Postgres | Contra qué familia compite |
|---|---|---|
| Campos que cambian según el tipo | JSONB con GIN (`jsonb_ops` si preguntas por claves) | documental (F03–F04) |
| Datos que se pueden perder | `UNLOGGED`, sabiendo que una caída los vacía | clave-valor (F05–F06) |
| Agregar pocas columnas de muchas filas | columnas bien tipadas, índices; o una vista materializada | analítico embebido (F07–F08) |
| Series por rango y borrado por antigüedad | particionado por rango | series temporales (F09–F10) |
| Buscar texto con tolerancia | `tsvector` con el diccionario del idioma y GIN | búsqueda (F11–F12) |
| Recorrer relaciones | `WITH RECURSIVE` con aristas indexadas y `CYCLE` | grafos (F13–F14) |
| Parecido | `pgvector` con HNSW | vectorial (F15–F16) |

---

## 📚 Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación suele cubrir solo la última versión. Este
> apéndice se verificó con PostgreSQL 18.6 y pgvector 0.8.6.

- **Indexación de JSONB** — https://www.postgresql.org/docs/current/datatype-json.html#JSON-INDEXING —
  `jsonb_ops` contra `jsonb_path_ops`.
- **Búsqueda de texto** — https://www.postgresql.org/docs/current/textsearch.html — configuraciones,
  diccionarios y ranking.
- **pgvector** — https://github.com/pgvector/pgvector — HNSW, IVFFlat y sus parámetros.
- **WITH RECURSIVE y CYCLE** — https://www.postgresql.org/docs/current/queries-with.html
- **Particionado** — https://www.postgresql.org/docs/current/ddl-partitioning.html
- **UNLOGGED** — https://www.postgresql.org/docs/current/sql-createtable.html — la cláusula y lo que
  pasa tras una caída.
- **Notas de la versión 18** — https://www.postgresql.org/docs/release/18.0/ — el *skip scan* y los
  cambios de `EXPLAIN`.

---

## 🧪 Ejercicios (8)

### 🟢 Ejercicio 1 — El GIN que no se usa

Con el índice GIN sobre `part.details`, compara `details @> '{"tboHours": 6000}'` con
`details->>'tboHours' = '6000'`.

**Objetivo:** ver en el plan que la segunda recorre la tabla, y crear el índice que sí le sirve.

### 🟢 Ejercicio 2 — Tu propia raíz

Pasa cinco palabras del catálogo por `to_tsvector('spanish', …)`.

**Pregunta:** ¿encuentras alguna donde la raíz sea tan corta que choque con otra palabra, como
*cámara* y `cam`?

### 🟡 Ejercicio 3 — `jsonb_path_ops` a prueba

Con `jsonb_path_ops`, busca las llantas que tienen la clave `retreadCount`, y reescribe la consulta
para que use el índice.

**Pista:** en este dominio, qué piezas tienen esa clave lo decide otra columna de `part`. Y si la
consulta tiene que ser por la clave, ¿qué operador de clase la resuelve por índice?

### 🟡 Ejercicio 4 — IVFFlat, a mano

Con 2000 pireps, prueba `ivfflat.probes` de 1 a 5 y anota los aciertos en los 10 primeros.

**Pregunta:** ¿desde qué valor coincide con la búsqueda exacta? ¿Se mantiene con otra consulta?

### 🟡 Ejercicio 5 — El `OR` que no escala

Escribe el recorrido de trazabilidad con el `OR` dentro del `JOIN` y compara su plan, a profundidad
2, con el de `trace_edge`.

**Objetivo:** encontrar en el plan el nodo que recorre la tabla entera en cada salto.

### 🟠 Ejercicio 6 — Caminos contra nodos

A profundidad 3, cuenta nodos y filas con `CYCLE` y sin él.

**Pregunta:** ¿por qué crece más la cuenta de filas que la de nodos, y qué dice eso de lo que hace
`WITH RECURSIVE` por dentro?

### 🟠 Ejercicio 7 — El mes que se borra

Mide, sobre una copia de `reading` sin particionar, las filas examinadas por un `DELETE` de un mes
(dentro de `BEGIN` y `ROLLBACK`), y compáralas con el `DETACH` más `DROP` de la partición.

**Objetivo:** explicar por qué uno depende del número de filas y el otro no.

### 🔴 Ejercicio 8 — La caída

Repite la prueba de `UNLOGGED` con una tabla tuya, pero apaga Postgres con `pg_ctl stop -m
immediate` desde dentro del contenedor, en lugar de `docker kill`.

**Pregunta:** ¿se vacía también? ¿Qué te dice eso sobre qué cuenta como caída?

---

> 🏷️ **Este apéndice no lleva tag propio.** Los scripts de `src/a07-postgres-linea-base/` se
> commitean con el prefijo de la fase desde la que se llegó; la primera es la Fase 04.
