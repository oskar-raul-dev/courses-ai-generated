# 📎 Apéndice a08 — Diccionario de traducción y glosario

> **Curso:** Ruta NoSQL Lite · Consulta rápida · **2 h**
> **Usado por:** todas las fases A · **Versiones cubiertas:** no aplica
> **Fecha de verificación ejecutada:** no aplica. **Estado:** esqueleto; crece con el curso y se
> cierra al final (Tanda 6)

**Esto no se lee de corrido.** Es el diccionario **en las dos direcciones**: de relacional a cada
familia y de vuelta. Cada familia añade su sección cuando llega su fase A.

**Qué queda fuera:** la sintaxis de cada motor, que está en [`a03`](a03-clis-de-los-motores.md).

---

## Índice

- [Las convenciones de nombrado](#-las-convenciones-de-nombrado)
- [Documental](#-documental): qué reemplaza al `JOIN`, qué es un índice y qué es una transacción — ✅ Fase 03
- [Clave-valor](#-clave-valor): sin consultas, qué hace de índice y qué es atómico — ✅ Fase 05
- [Vectorial](#-vectorial): parecido en vez de igualdad, y el filtro que decide el motor — ✅ Fases 15–16
- Qué reemplaza a un `JOIN` en el resto de los modelos — 🚧 crece con cada familia
- Qué significa "índice" en cada familia — ✅ documental, clave-valor y vectorial, al final de cada sección; 🚧 crece con cada familia
- Partición, sharding y particionado declarativo — 🚧 Fases 09 y 17
- Consistencia eventual, sin misticismo — 🚧 Fases 17 y 19
- Qué es una transacción en cada familia — ✅ documental y clave-valor, en sus secciones; 🚧 Fases 20 y 22
- Glosario: qué términos se quedan en inglés y por qué — 🚧 crece con el curso

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

> 🏷️ **Este apéndice no lleva tag propio.** Cada sección se commitea con el prefijo de la fase que
> la escribió.
