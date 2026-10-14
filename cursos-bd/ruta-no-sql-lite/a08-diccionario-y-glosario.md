# 📎 Apéndice a08 — Diccionario de traducción y glosario

> **Curso:** Ruta NoSQL Lite · Consulta rápida · **2 h**
> **Usado por:** todas las fases A · **Versiones cubiertas:** no aplica
> **Fecha de verificación ejecutada:** no aplica. **Estado:** cerrado el 12/10/2026, con las diez familias y el
> capstone

**Esto no se lee de corrido.** Es el diccionario **en las dos direcciones**: de relacional a cada
familia y de vuelta. Cada familia tiene su sección, escrita en su fase A; al final, lo que se consulta cruzando
familias: qué reemplaza a un `JOIN` y qué palabras se quedan en inglés.

**Qué queda fuera:** la sintaxis de cada motor, que está en [`a03`](a03-clis-de-los-motores.md).

---

## Índice

- [Las convenciones de nombrado](#️-las-convenciones-de-nombrado)
- [Documental](#-documental): qué reemplaza al `JOIN`, qué es un índice y qué es una transacción — ✅ Fase 03
- [Clave-valor](#-clave-valor): sin consultas, qué hace de índice y qué es atómico — ✅ Fase 05
- [Analítico embebido](#-analítico-embebido): el mismo SQL, otra forma de leer — ✅ Fase 07
- [Series temporales](#️-series-temporales): partir por tiempo, resumir y borrar por chunks — ✅ Fase 09
- [Búsqueda](#-búsqueda): términos en vez de caracteres, y un mapping que es un esquema — ✅ Fase 11
- [Grafos](#️-grafos): la relación como dato, con propiedades — ✅ Fase 13
- [Vectorial](#-vectorial): parecido en vez de igualdad, y el filtro que decide el motor — ✅ Fases 15–16
- [Columnar ancha](#️-columnar-ancha): una tabla por pregunta, y la partition key como dirección — ✅ Fase 17
- [Offline-first](#-offline-first): la base en la tableta, la revisión como historia y el conflicto como caso normal — ✅ Fase 19
- [NewSQL](#-newsql): el mismo SQL en rangos con consenso, y la región como columna — ✅ Fase 21
- [Políglota](#️-políglota): fuente de verdad, dato derivado y la segunda verdad — ✅ Fase 23; la costura, la ventana y la bandeja de entrada — ✅ Fase 24; la factura — ✅ Fase 25
- [Qué reemplaza a un `JOIN`, familia por familia](#-qué-reemplaza-a-un-join-familia-por-familia) — ✅ las diez
- Qué significa "índice" en cada familia — ✅ las diez y el capstone, en el párrafo *"Qué significa 'índice' aquí"* de cada sección
- Partición, sharding y particionado declarativo — ✅ particionado y chunks, en [Series temporales](#️-series-temporales) (Fases 09–10); sharding por partition key, en [Columnar ancha](#️-columnar-ancha) (Fase 17)
- Consistencia eventual, sin misticismo — ✅ quórums y lectura vieja, en [Columnar ancha](#️-columnar-ancha) (Fase 17); dos ramas válidas y una ganadora determinista, en [Offline-first](#-offline-first) (Fase 19); consenso y el reloj, en [NewSQL](#-newsql) (Fase 21)
- Qué es una transacción en cada familia — ✅ documental, clave-valor y analítico (control optimista, sin candados de fila), en sus secciones; distribuida y serializable, con su reintento y su contención, en [NewSQL](#-newsql) (Fases 21 y 22)
- [Glosario: qué se queda en inglés y por qué](#-glosario-qué-se-queda-en-inglés-y-por-qué) — ✅ el curso entero
- [Ejercicios](#-ejercicios-6)

---

## 🏷️ Las convenciones de nombrado

**Los nombres del dominio son los mismos en todo el curso y van en inglés**: `aircraft`, `part`,
`partCatalog`, `assembly`, `workOrder`, `reading`, `pirep`, `technician`, `hangar` y `supplier`.
Qué es cada una está en [`00-historia-de-condor.md`](00-historia-de-condor.md) §6.

**Pero no se escriben igual en todos los motores, y es a propósito:**

| Dónde | Convención | Ejemplo |
|---|---|---|
| MongoDB, Valkey, OpenSearch, Neo4j, Qdrant, CouchDB, y el dataset canónico de [`a05`](a05-el-dominio-de-flota.md) | `camelCase` | `workOrder`, `partNumber`, `openedAt` |
| PostgreSQL, TimescaleDB, DuckDB, Cassandra y CockroachDB | `snake_case` | `work_order`, `part_number`, `opened_at` |

**La incoherencia es deliberada:** cada familia se escribe como se escribe en su ecosistema. Un
modelo documental con nombres en `snake_case` o una tabla SQL con identificadores entre comillas
para conservar mayúsculas serían traducciones, y el curso enseña a pensar en cada modelo, no a
traducir el relacional a todos. **El cargador de cada fase hace la conversión** al pasar del
dataset canónico al motor.

---

## 🍃 Documental

**De relacional a documental**, y de vuelta: la tabla va en las dos direcciones, como pide el
repositorio.

| Relacional | Documental | Y de vuelta: lo que documental hace y SQL resuelve distinto |
|---|---|---|
| tabla | colección | una colección admite documentos con claves distintas: en SQL, JSONB |
| fila | documento, con arrays y subdocumentos | un array embebido: en SQL, una tabla hija o un array/JSONB |
| clave primaria | `_id` | — |
| `JOIN` | embeber (al escribir) o `$lookup` (al leer, bucle anidado) | embeber: en SQL, `json_agg` en la consulta o JSONB guardado |
| índice B-tree | índice, también sobre campos anidados; *multikey* sobre arrays | un índice multikey: en SQL, GIN sobre un array o una tabla hija indexada |
| `NULL` | el campo **no existe**, o existe con `null` | `$exists: false` no tiene equivalente directo: en SQL todo es `NULL` |
| transacción | atómica por documento siempre; multi-documento solo en replica set | una transacción por documento: en SQL, una fila con todo dentro |
| `EXPLAIN ANALYZE` | `explain("executionStats")` | `totalDocsExamined` ≈ filas examinadas |
| esquema | validación opcional con `$jsonSchema` | `CHECK` y tipos en SQL; en documental, en el código |

**Qué significa "índice" aquí:** un B-tree, como en SQL, pero sobre una ruta (`details.tboHours`) o sobre
todas las rutas (comodín `$**`). Sobre un array, una entrada por elemento. Nunca dos arrays en el mismo
índice compuesto ([`a09`](a09-catalogo-de-errores.md) E-20). Medido en las
[Fases 03](03-documental-levantar-y-modelar.md) y [04](04-documental-romper-y-medir.md).

## 🔑 Clave-valor

| Relacional | Clave-valor (Valkey) | Y de vuelta: lo que clave-valor hace y SQL resuelve distinto |
|---|---|---|
| tabla | prefijo de clave (`session:`) | un prefijo: en SQL, una tabla de verdad, con esquema |
| fila | el valor de una clave: string, hash, set, sorted set, stream | un hash: en SQL, una fila buscada por clave primaria |
| clave primaria | la clave | — |
| índice secundario | otra estructura escrita y mantenida a mano | un set a mano: en SQL, `CREATE INDEX`, que se mantiene solo |
| `WHERE` | no existe; `SCAN MATCH` filtra por el nombre de la clave | `SCAN`: en SQL, un `Seq Scan` |
| `UNIQUE` + `INSERT` | `SET … NX`: quien pierde recibe `null` | `SET NX`: en SQL, `INSERT … ON CONFLICT DO NOTHING RETURNING` |
| `expires_at` + `DELETE` periódico | TTL (`EXPIRE`, `PX`), sin consulta | un TTL: en SQL, una columna y un proceso que borra |
| `SELECT … FOR UPDATE` / candado consultivo | `SET NX PX` con token, y Lua para soltarlo | un candado con TTL: en SQL, `pg_try_advisory_lock`, atado a la conexión |
| tabla-cola con `SKIP LOCKED` | sorted set con `ZPOPMIN`; stream con grupo de consumidores | `ZPOPMIN`: en SQL, `DELETE … RETURNING` sobre la fila más antigua con `SKIP LOCKED` |
| transacción | un comando, `MULTI`/`EXEC` o un script Lua: atómicos, **sin rollback** | un script Lua: en SQL, una función o una transacción |
| `EXPLAIN` | no existe: la complejidad de cada comando y `INFO commandstats` | — |
| tabla `UNLOGGED` | una instancia con la persistencia por defecto | la diferencia está en qué se pierde en una caída ([Fase 06](06-clave-valor-romper-y-medir.md)) |

**Qué significa "índice" aquí:** nada que el motor mantenga. Un "índice" es una segunda estructura
—un set por técnico, un sorted set por fecha— que tu código escribe junto a la primera, y que nada
limpia cuando la primera vence por TTL. Medido en la [Fase 05](05-clave-valor-levantar-y-modelar.md):
202 viajes sin él, 2 con él, y 1000 entradas fantasma tras vencer 1000 sesiones.

**Qué significa "transacción" aquí:** la frontera es **un comando**. `MULTI`/`EXEC` y los scripts Lua
ejecutan varios sin que otro cliente se cuele, pero no deshacen nada si uno falla. Un pipeline no es
una transacción.

## 🦆 Analítico embebido

| Relacional (Postgres) | Analítico embebido (DuckDB) | Y de vuelta: lo que DuckDB hace y Postgres resuelve distinto |
|---|---|---|
| servidor y conexión por red | biblioteca dentro del proceso; la base es un archivo | un solo proceso escribe; en Postgres, cualquier cliente |
| tabla en páginas de 8 kB, fila tras fila | grupos de 122 880 filas, cada columna en sus bloques | leer una columna en Postgres trae la fila entera |
| BRIN, creado a mano | mínimo y máximo por columna y grupo, siempre | `CREATE INDEX … USING brin`, columna por columna |
| índice cubriente | no hace falta: se leen solo las columnas nombradas | un índice por consulta conocida, que se mantiene en cada escritura |
| `COPY … FROM` | `read_json`, `read_csv`, `read_parquet`: el archivo es una tabla | una extensión de tablas externas |
| `CASE WHEN` o `FILTER` por columna | `PIVOT … ON` | las columnas se escriben a mano |
| `EXPLAIN (ANALYZE, BUFFERS)` | `EXPLAIN ANALYZE` y el perfilador JSON (`total_bytes_read`) | páginas en vez de bytes |
| candado de fila, el segundo espera | control optimista, el segundo falla | `TransactionContext Error: Conflict on update!` (E-38) |

**Qué significa "índice" aquí:** casi nada que crees tú. El mínimo y el máximo de cada columna en cada
grupo de filas se guardan siempre y dejan saltar grupos enteros; el orden en que se cargó la tabla
decide cuánto sirven. DuckDB tiene índices ART para claves, pero no son la herramienta de esta familia.

**Una palabra que el curso usa con cuidado:** *columnar* aquí es **analítico por columnas**, no la
*columnar ancha* de Cassandra (Fases 17–18), que guarda filas agrupadas por partición. El nombre se
parece; el modelo de acceso es el contrario.

---

## ⏱️ Series temporales

| Relacional (Postgres) | Series temporales (TimescaleDB) | Y de vuelta: lo que Timescale hace y Postgres resuelve distinto |
|---|---|---|
| tabla | hypertable | una tabla con particiones de rango por `ts` (Fase 10) |
| partición | chunk, creado al insertar | `CREATE TABLE … PARTITION OF … FOR VALUES FROM … TO …`, creada a mano o por un job |
| `DELETE … WHERE ts < …` | `drop_chunks`, política de retención | `DROP TABLE` de la partición vieja |
| vista materializada | agregado continuo, refrescado por ventanas | `REFRESH MATERIALIZED VIEW`, siempre entero |
| `date_trunc` | `time_bucket` | `date_bin` en Postgres 14+ |
| tabla sin comprimir | chunk comprimido por columnas (*columnstore*) | TOAST comprime valores, no columnas |

**Qué significa "índice" aquí:** el mismo B-tree de Postgres, pero uno por chunk; y, por encima, el chunk
mismo, que descarta por tiempo antes de mirar ningún índice. En un chunk comprimido, `segmentby` hace de
índice: agrupa los lotes por esa columna.

---

## 🔍 Búsqueda

| Relacional (Postgres) | Búsqueda (OpenSearch) | Y de vuelta: lo que el buscador hace y Postgres resuelve distinto |
|---|---|---|
| tabla e índice | índice (los dos a la vez) | la tabla de Postgres más su índice GIN de `tsvector` (Fase 12) |
| `CREATE TABLE` | `mapping`, que es un esquema | un campo no cambia de tipo sin un índice nuevo |
| `LIKE '%x%'` | `match` sobre un campo analizado | `to_tsvector … @@ to_tsquery …` |
| `=` | `term` sobre `keyword` | `=` |
| índice de expresión | analizador | `to_tsvector('spanish', unaccent(…))` |
| `GROUP BY` | agregación `terms`, aproximada | exacto siempre |
| tupla muerta | documento borrado en un segmento | `VACUUM` contra fusión de segmentos |

**Qué significa "índice" aquí:** un índice invertido, de término a lista de documentos. Lo que no produzca
los mismos términos al indexar y al buscar no se encuentra, aunque el texto se parezca.

**Palabras que se quedan en inglés:** *mapping*, *analyzer* (analizador, en el texto), *token*, *posting
list*, *shard* (fragmento, en el texto) y *refresh*.

---

## 🕸️ Grafos

| Relacional (Postgres) | Grafos (Neo4j) | Y de vuelta: lo que el grafo hace y Postgres resuelve distinto |
|---|---|---|
| fila de una tabla | nodo con label | el label es una etiqueta: un nodo puede tener varias |
| clave foránea | relación con tipo y dirección | la relación es un dato con propiedades; en SQL, una tabla intermedia |
| tabla intermedia con columnas | relación con propiedades (`:INSTALLED {from, to}`) | hay que decidir crearla (`part_stint`, Fase 13) |
| `JOIN` | recorrer una relación | seguir punteros del nodo, no buscar en un índice |
| `WITH RECURSIVE` | patrón de longitud variable | Fase 14 |
| `EXPLAIN (ANALYZE, BUFFERS)` | `PROFILE` | *db hits* en vez de páginas |

**Qué significa "índice" aquí:** el índice encuentra el **primer** nodo; a partir de ahí se recorre. Sin
índice en la propiedad del primer nodo, la consulta empieza leyendo todo el label.

**Palabras que se quedan en inglés:** *label*, *db hits*, *index-free adjacency*.

---

## 🧬 Vectorial

| Relacional | Vectorial (Qdrant) | Y de vuelta: lo que vectorial hace y SQL resuelve distinto |
|---|---|---|
| tabla | colección, con una dimensión fija | una colección: en SQL, una tabla con una columna `vector(384)` de `pgvector` |
| fila | punto: id, vector y payload | el vector: una columna más, en la misma transacción que la fila |
| columna | campo del payload | se filtra por ella, no se busca por parecido |
| `WHERE` | filtro de payload, aplicado **dentro** de la búsqueda | en `pgvector`, un `WHERE` aplicado **después** del HNSW: puede devolver menos de k (Fase 16) |
| `ORDER BY … LIMIT k` | los k vecinos más parecidos, siempre k | `ORDER BY embedding <=> $1 LIMIT k` |
| índice B-tree | HNSW: aproximado | `CREATE INDEX … USING hnsw`; la búsqueda exacta es no usarlo |
| `EXPLAIN` | no hay plan; `indexed_vectors_count` y `exact: true` | en `pgvector`, el plan y las páginas por consulta |
| la respuesta | los parecidos, ordenados | no hay equivalente relacional para "parecido" sin `pgvector` |

**Qué significa "índice" aquí:** un grafo de vecinos (HNSW) que se recorre saltando hacia la consulta, sin
mirar todos los puntos, y que **puede devolver otra cosa sin avisar**. Se mide contra la búsqueda exacta,
con `ef` como mando. En Qdrant, además, un segmento por debajo de `indexing_threshold` no tiene índice.

**Dos palabras que el curso separa:** *recall del índice* (lo que devuelve el índice frente a la
búsqueda exacta) y *acierto* (lo que devuelve frente a la verdad de referencia). Se quedan en inglés
*embedding*, *recall* y *payload*, porque son los nombres que aparecen en la documentación y en los
mensajes de error.

---

## 🏛️ Columnar ancha

| Relacional | Columnar ancha (Cassandra) | Y de vuelta: lo que Cassandra hace y SQL resuelve distinto |
|---|---|---|
| base de datos | keyspace, con su factor de replicación | la replicación es del servidor, no del esquema |
| tabla | tabla diseñada para **una** consulta | una tabla sirve a todas las consultas que el planificador sepa armar |
| clave primaria | partition key + clustering key | particionado por la partition key y un índice cubriente en la clustering key |
| partición de una tabla particionada | partición: las filas con la misma partition key, en los mismos nodos | el planificador poda particiones a partir de un rango; aquí hay que nombrarlas |
| `JOIN` | no existe: el dato se escribe ya junto, en cada tabla que lo necesita | se calcula al leer |
| índice secundario | otra tabla con otra partition key (o un índice secundario, que existe y casi nunca es la respuesta) | `CREATE INDEX` |
| `INSERT` y `UPDATE` | *upsert*, sin leer lo que había | `INSERT … ON CONFLICT DO UPDATE` |
| transacción | `BATCH` con registro: todo se aplica tarde o temprano, sin aislamiento | `BEGIN … COMMIT` |
| `EXPLAIN (ANALYZE, BUFFERS)` | `TRACING ON`: particiones, SSTables, filas vivas leídas | las páginas por consulta |

**Qué significa "índice" aquí:** la partition key **es** el índice, y además la dirección: su hash dice en qué
nodos vive la partición. Dentro de la partición, la clustering key mantiene las filas ordenadas. Una consulta
que no da la partition key entera no tiene por dónde empezar, y Cassandra se lo dice (E-59 en
[`a09`](a09-catalogo-de-errores.md)).

**Sharding, particionado y partición.** El *particionado declarativo* de Postgres parte una tabla en trozos en
la **misma** máquina, y el planificador decide cuáles leer. El *sharding* reparte los trozos entre máquinas.
En Cassandra son lo mismo: la partition key decide el trozo y el nodo a la vez, y no hay planificador que
decida por ti ([Fase 17](17-columnar-levantar-y-modelar.md), sección 6.2).

**Consistencia eventual, sin misticismo.** Cada partición vive en tantos nodos como diga el factor de
replicación (RF). Cada operación elige cuántas réplicas tienen que contestar: `ONE`, `QUORUM`, `ALL`. Si las
que escriben más las que leen superan a RF, la lectura ve la última escritura confirmada; si no, puede leer
un valor viejo, y la [Fase 17](17-columnar-levantar-y-modelar.md) lo provoca. "Eventual" quiere decir que la réplica atrasada se pone al día —por
*hints*, por reparación al leer o por reparación programada—, no que no se sepa cuándo ni cómo.

**Lo que cobra el trato** ([Fase 18](18-columnar-romper-y-medir.md)). La **compactación** reescribe las
SSTables para juntarlas: es la otra mitad de cada escritura, y se elige por tabla —*SizeTiered* por defecto,
*TimeWindow* para series—. El **tombstone** es la marca que deja un borrado: se lee hasta que una compactación
la purga, y no antes de `gc_grace_seconds`; en Postgres, lo más parecido es la tupla muerta, que VACUUM limpia
sin esperar. El ***hot spot*** es la partición que concentra las escrituras, típicamente la del periodo en curso
cuando la partition key es solo el tiempo; en Postgres no hay equivalente, porque todo cae en la misma máquina.

**Se quedan en inglés** *partition key*, *clustering key*, *keyspace*, *SSTable*, *memtable*, *tombstone*,
*hints* y *backfill*, porque son los nombres de la documentación, de `nodetool` y de los mensajes de error.

---

## 📴 Offline-first

| Relacional | Offline-first (CouchDB y PouchDB) | Y de vuelta: lo que CouchDB hace y SQL resuelve distinto |
|---|---|---|
| fila | documento JSON con `_id`: la unidad de replicación y de conflicto | la fila no se replica sola: la replicación lógica manda cambios de tablas |
| columna de versión | `_rev`, `N-hash`: el número cuenta guardados de esa rama, el hash los distingue | `UPDATE … WHERE version = $1`, con un número que dos escritores pueden repetir |
| bloqueo optimista | `PUT` con el `_rev` leído; si no es la hoja, 409 | lo mismo, en un servidor |
| réplica | otra base que acepta escrituras y replica en los dos sentidos | réplicas de solo lectura, o un líder |
| WAL y *slot* de replicación | `_changes` y el *checkpoint* en `_local/` | la réplica sigue el WAL desde su posición |
| error de serialización | conflicto: dos hojas, una ganadora elegida sin preguntar | el segundo que escribe recibe el error |
| `UNIQUE`, `CHECK` | nada: la regla es de la app o de la fusión | la restricción rechaza al segundo que llega |
| `MERGE`, `ON CONFLICT` | tu resolución, o un CRDT | se decide en el momento de escribir |

**Qué significa "índice" aquí:** el `_id` y el registro de cambios; para replicar un subconjunto, un `selector` que
el servidor evalúa sobre `_changes`. Las consultas por otros campos existen (Mango y vistas), pero esta familia
se elige por lo que pasa sin red, no por cómo consulta.

**Consistencia eventual, versión offline.** En columnar ancha, las réplicas de una partición discrepan un rato y
un mecanismo las pone al día. Aquí pueden discrepar **para siempre**, porque cada una aceptó escrituras que la
otra no vio: el documento queda con dos hojas. CouchDB elige una ganadora determinista —la rama más larga, y
si empatan, el `_rev` mayor como texto—, así que todas las réplicas **muestran la misma**, pero la otra sigue ahí
hasta que alguien la resuelva ([Fase 19](19-offline-levantar-y-modelar.md), sección 6.4). Converger no es lo
mismo que decidir.

**Revisión e historia.** La replicación transfiere la hoja y los identificadores de sus antepasados, no los
cuerpos intermedios: el servidor sabe **de dónde viene** un documento, pero no puede mostrar cómo era. Una
revisión vieja no es una versión.

**CRDT** (*conflict-free replicated data type*): un tipo con una fusión que no depende del orden ni de las
repeticiones. **OR-Set** es el conjunto cuyas bajas entierran etiquetas y no valores; **G-Counter**, el contador
por réplica que solo sube; **MV-Register**, el registro que, si dos escrituras no se vieron, conserva las dos.

**Se quedan en inglés** *offline-first*, *local-first*, *checkpoint*, *selector*, CRDT y los nombres de sus tipos,
porque son los de la documentación y la literatura.

---

## ⚡ NewSQL

| Relacional | NewSQL (CockroachDB) | Y de vuelta: lo que CockroachDB hace y Postgres resuelve distinto |
|---|---|---|
| tabla | tabla partida en **rangos** de hasta 512 MiB; varias tablas chicas comparten uno | una tabla es un archivo (o varios) en una máquina |
| réplica física | tres réplicas **votantes** por rango, que acuerdan con Raft, y réplicas **no votantes** para leer | una réplica sigue el WAL del primario |
| primario | **leaseholder**: el que atiende las lecturas y ordena las escrituras de su rango | un primario para toda la base |
| `COMMIT` | confirmado cuando la mayoría de los votantes del rango lo tiene | confirmado cuando el WAL está en disco (y en la réplica síncrona, si la hay) |
| `READ COMMITTED` por defecto | `SERIALIZABLE` por defecto; `READ COMMITTED` existe y se pide | `SERIALIZABLE` existe y se pide |
| servidor en un país | región de la base, `LOCALITY` por tabla, `PLACEMENT RESTRICTED` | la residencia la decide dónde está la máquina |
| tabla particionada | `REGIONAL BY ROW`: una partición por región, con la región como columna (`crdb_region`) | particiones en la misma máquina |
| `EXPLAIN (ANALYZE, BUFFERS)` | `EXPLAIN ANALYZE`: filas leídas del almacén, nodos y regiones | bloques de 8 kB |

**Qué significa "índice" aquí:** lo mismo que en Postgres, con una diferencia que cuesta: en una tabla
`REGIONAL BY ROW`, **cada índice también se parte por región**. Una consulta que no dice en qué región está lo que
busca recorre las tres particiones; una clave única cuya región no se puede deducir de ella obliga a comprobar la
unicidad en las otras regiones al insertar ([Fase 21](21-newsql-levantar-y-modelar.md), sección 6.4).

**Qué es una transacción aquí:** la de Postgres, distribuida. Cada escritura deja un *intent* —una escritura
provisional— en su rango, y el `COMMIT` cambia el estado de un registro de transacción que vive en el rango de la
primera escritura. Una transacción que escribe en rangos de tres regiones necesita que los votantes de cada uno
confirmen. Con `SERIALIZABLE`, una transacción que no se puede ordenar con las
demás recibe un `40001` y **se reintenta entera** (E-71 en [`a09`](a09-catalogo-de-errores.md)). Cuando varias
regiones escriben la misma fila, el que está lejos llega tarde a cada escritura (`WriteTooOldError`, E-75) y pierde
una y otra vez: en la [Fase 22](22-newsql-romper-y-medir.md), segundos de espera contra milisegundos al lado de la
fila.

**Consistencia, sin misticismo.** A diferencia de columnar ancha y offline-first, aquí no hay consistencia
eventual en las réplicas votantes: una escritura confirmada la ve cualquier lectura posterior, desde cualquier
región. El precio es que **los relojes de los nodos no coinciden**, y el motor lo sabe: cada lectura tiene un
intervalo de incertidumbre de 500 ms, y un valor escrito dentro de él puede reiniciar la transacción (E-72). Las
lecturas que aceptan ser un poco viejas (`AS OF SYSTEM TIME`) se sirven de la réplica más cercana, sin esa
espera ni ese riesgo.

**Localidad, en tres palabras.** `GLOBAL`: la tabla se lee local en todas las regiones y se escribe caro.
`REGIONAL BY TABLE`: la tabla entera vive en una región. `REGIONAL BY ROW`: cada fila vive en la región que dice
su columna `crdb_region`. Con la ubicación por defecto, una fila regional tiene además **copias no votantes en
las otras regiones**. Las quitan `PLACEMENT RESTRICTED` (que la documentación mantiene solo por compatibilidad) y
las **super regiones**, que confinan los datos a un grupo de regiones; con una región sola, las dos son
incompatibles con sobrevivir a la caída de esa región (E-74).

**Se quedan en inglés** *leaseholder*, *range*, Raft, *intent*, *gateway* y los nombres de las localidades
(`REGIONAL BY ROW`, `GLOBAL`), porque son los de la documentación, de `SHOW RANGES` y de los mensajes de error.

## ⚖️ Políglota

| Relacional | Varios motores | Y de vuelta: lo que Postgres ya hacía solo |
|---|---|---|
| la tabla donde se hace el `INSERT` | **fuente de verdad**: el único lugar donde nace un hecho, una por entidad | todo nacía en la misma base |
| índice, vista materializada, columna generada | **dato derivado**: una copia en otra forma, en otro motor | el motor lo mantenía al día en la misma transacción |
| `REINDEX` | **reconstrucción**: armar el derivado otra vez desde la fuente | se rearmaba sin salir del servidor |
| una fila de movimiento | **hecho**: algo que pasó, con fecha, que no se edita | el historial que se guardaba, o no |
| una columna que se actualiza | **estado** o **proyección**: el resultado de aplicar los hechos | si se actualizaba sin hecho, nadie lo notaba |
| un dato que no cumple una restricción | **segunda verdad**: un dato que vive solo en el derivado | la restricción lo rechazaba |
| la transacción | **costura**: cómo llega un hecho de la fuente a cada derivado (*outbox*, CDC; Fase 24) | el `COMMIT` lo cubría todo |
| `COMMIT` de dos tablas | **doble escritura**: la aplicación escribe un motor y después el otro | una transacción cubría las dos; aquí, el segundo falla o llega en otro orden |
| un trigger que llena una tabla de log | ***outbox***: la fila "esto cambió", en la transacción del cambio, que un relevo lleva al derivado | el log quedaba en la base, y nadie tenía que llevarlo |
| la réplica que lee el WAL | **CDC**: un proceso que lee el WAL por un slot lógico y lo traduce | la réplica hablaba el mismo protocolo |
| el retraso de la réplica | **ventana de inconsistencia**: del `COMMIT` a que el derivado lo muestra | se medía con `pg_stat_replication`; aquí, con un reloj ([`a04`](a04-el-arnes-de-medida.md)) |
| `ON CONFLICT DO NOTHING` | **idempotencia**: entregar dos veces deja lo mismo que una | lo mismo, y es lo que permite reintentar |
| una tabla de staging | **bandeja de entrada**: lo que llega de un derivado, guardado entero y con su versión como clave | lo que llegaba ya tenía el esquema de la base |
| el respaldo de la base | **respaldo** de la fuente, contra **rearmado** de un derivado | había una sola base que respaldar |
| cuánto tarda en volver | **tiempo de recuperación**: el del motor más lento que la pantalla necesita | era el de una sola restauración |
| el DBA | **la factura que no se mide**: vigilar, actualizar y alguien que sepa, por motor ([Fase 25](25-poliglota-la-factura.md)) | un equipo, una herramienta |

**Qué significa "índice" aquí:** cualquier motor que no sea la fuente de una entidad. La prueba es que se pueda tirar y
rearmar desde ella sin perder nada; si no se puede, ya no es un índice ([Fase 23](23-poliglota-el-diseno.md), sección
6.4, y la huella en [`a04`](a04-el-arnes-de-medida.md)).

**Qué es una transacción aquí:** la de cada motor, y ninguna entre ellos. Lo que tiene que cambiar junto se escribe en
un solo motor, y los demás lo reciben después; cuánto después es la ventana de inconsistencia.

**Saldo inicial**: el estado del día en que empieza el sistema, guardado como un hecho más, para que la proyección
tenga desde dónde partir.

**Eco**: lo que la costura de ida escribió en el derivado y la de vuelta trae otra vez a la fuente. Se filtra con una
marca de origen ([Fase 24](24-poliglota-la-costura.md), sección 6.6).

**Ficha de innovación**: lo que una empresa gasta cada vez que adopta una tecnología nueva; tiene pocas (McKinley,
2015). Postgres ya la gastó; cada motor nuevo gasta otra.

**Relevo**: el proceso que lleva lo pendiente del *outbox* o del slot al derivado, y solo después lo da por entregado.

**Se quedan en inglés** *outbox*, CDC (*change data capture*) y *dual write* cuando se cita la literatura; en el texto
se dice **doble escritura**.

---

## 🔗 Qué reemplaza a un `JOIN`, familia por familia

La pregunta que más se hace al llegar a cada familia, contestada para las diez. La columna de la derecha es la que
importa: lo que se paga por no tener un `JOIN` en el servidor.

| Familia | Qué hace en lugar del `JOIN` | Lo que cuesta |
|---|---|---|
| documental | embeber al escribir, o `$lookup` al leer | embebido: duplicar y mantener; `$lookup`: un bucle anidado ([Fase 03](03-documental-levantar-y-modelar.md)) |
| clave-valor | no hay: dos lecturas en el cliente, o una clave que ya guarda lo junto | un viaje más, o un valor que se mantiene a mano |
| analítico embebido | el mismo `JOIN` de SQL | ninguno en la sintaxis; un solo proceso escribe |
| series temporales | el mismo `JOIN`, porque es Postgres | ninguno; cada *chunk* es una tabla más en el plan |
| búsqueda | no hay: el documento se indexa ya junto | reindexar cuando cambia lo que se juntó |
| grafos | recorrer la relación | nada, si la pregunta es un camino; un producto cartesiano si el patrón no está conectado ([Fase 13](13-grafos-levantar-y-modelar.md), E-54) |
| vectorial | no hay: el *payload* lleva lo que hace falta para filtrar | copiar al *payload* lo que vive en otra tabla |
| columnar ancha | no hay: una tabla por pregunta, escrita ya junta | una escritura por tabla, y un *backfill* por pregunta nueva |
| offline-first | no hay: lo que se junta va dentro del documento que viaja | lo mismo que embeber, más los conflictos |
| NewSQL | el mismo `JOIN` | cruzar regiones: cada fila remota es un viaje entre países ([Fase 22](22-newsql-romper-y-medir.md)) |

Y de vuelta: en cada familia sin `JOIN`, la frase *"se escribe ya junto"* es una **desnormalización**, y lo que
Postgres haría con un `JOIN` en la lectura se paga en la escritura.

---

## 🔤 Glosario: qué se queda en inglés y por qué

**La regla:** un término se queda en inglés cuando es el nombre que aparece en la documentación, en la CLI o en los
mensajes de error del motor, porque traducirlo deja al lector sin nada que buscar. Lo demás va en español. Cuando
el término tiene una traducción establecida, el texto usa la traducción y la primera aparición lleva el original.

| Familia | Se quedan en inglés |
|---|---|
| todas | los nombres del dominio (`aircraft`, `workOrder`…), *driver*, *healthcheck*, *digest* |
| búsqueda | *mapping*, *token*, *posting list*, *refresh*; *analyzer* y *shard* van como analizador y fragmento |
| grafos | *label*, *db hits*, *index-free adjacency* |
| vectorial | *embedding*, *recall*, *payload* |
| columnar ancha | *partition key*, *clustering key*, *keyspace*, *SSTable*, *memtable*, *tombstone*, *hints*, *backfill* |
| offline-first | *offline-first*, *local-first*, *checkpoint*, *selector*, CRDT y sus tipos |
| NewSQL | *leaseholder*, *range*, Raft, *intent*, *gateway*, `REGIONAL BY ROW`, `GLOBAL` |
| políglota | *outbox*, CDC, *dual write* al citar la literatura (en el texto, doble escritura) |

---

## 🧪 Ejercicios (6)

De traducción: dada una consulta SQL de Cóndor, escribir su equivalente en tres familias y decir cuál no tiene
equivalente honesto.

### 🟢 Ejercicio 1 — Las órdenes de una aeronave

`SELECT … FROM work_order WHERE aircraft = $1 ORDER BY opened_at DESC LIMIT 20`, en documental, columnar ancha y
clave-valor.

**Objetivo:** las tres, y cuál necesita una estructura que mantienes tú.

### 🟢 Ejercicio 2 — El costo por hora

El costo por hora volada de la [Fase 07](07-analitico-levantar-y-modelar.md), en analítico embebido, series y
documental.

**Objetivo:** las tres, y en cuál deja de ser una consulta y pasa a ser un programa.

### 🟡 Ejercicio 3 — La orden con sus piezas

La orden con sus movimientos y el número de parte de cada pieza (un `JOIN` de tres tablas), en documental, búsqueda
y offline-first.

**Objetivo:** dónde vive cada pieza en cada una, y qué hay que reescribir cuando cambia un número de parte.

### 🟡 Ejercicio 4 — El lote de la directiva

`WITH RECURSIVE` sobre los movimientos, en grafos, documental y columnar ancha.

**Objetivo:** las tres, y cuál no tiene equivalente honesto.

### 🟠 Ejercicio 5 — "Esto ya lo vimos"

La búsqueda por parecido de la [Fase 15](15-vectorial-levantar-y-modelar.md) con un filtro de aeronave, en vectorial,
búsqueda y Postgres con `pgvector`.

**Objetivo:** dónde se aplica el filtro en cada una, y en cuál puede devolver menos de k.

### 🔴 Ejercicio 6 — La firma de Bogotá

La transacción de la inspección mayor de `HC-2157`, en NewSQL, documental y offline-first.

**Objetivo:** qué queda atómico en cada una, y en cuál la firma deja de ser una transacción.

---

> 🏷️ **Este apéndice no lleva tag propio.** Cada sección se commitea con el prefijo de la fase que
> la escribió.
