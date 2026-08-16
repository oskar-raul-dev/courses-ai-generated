# 🗺️ Ruta NoSQL — Lista maestra

> **Documento de contexto.** Índice de referencia de la ruta de tutoriales
> NoSQL post-legacy. Úsalo para arrancar cualquier conversación nueva sin
> repetir la deliberación completa.

## 🎯 Principio que ordena la ruta

Cada tutorial enseña **un modelo de acceso**, no un producto. Los productos
rotan (licencias, forks, hype); los modelos de acceso duran décadas. Por eso
cada curso incluye un **"vs" de productos medido con arnés propio**
(`scripts/vs.ts`), nunca una comparación anecdótica — y cierra con el mismo
⚖️ veredicto honesto: *cuándo NO usar lo que acabas de aprender.*

El primer curso de la ruta (MongoDB, legacy Vue 2 — mesa de soporte) ya
demostró el caso donde Mongo **no** debió elegirse. Esta ruta completa el
mapa: para cada familia, un caso donde **sí** vota esa familia, medido contra
sus rivales reales.

---

## 📐 El esqueleto compartido (no negociable en ningún curso)

- 🪞 **Instinto falsable y medido** — predicción, cronómetro, veredicto escrito
- 🩻 **Esto SÍ viaja igual** — lo que la experiencia previa conserva intacto
- ⚰️ **Anti-patrón transversal con autopsia** — números antes/después
- 📖 **Diccionario de traducción** desde el paradigma que el estudiante ya domina
- ⚖️ **Veredicto honesto** — árbol de decisión de cuándo NO usar esta familia
- 📓 **`INSTINTOS.md`** acumulativo por curso
- 📊 **`BENCHMARKS.md`** — todo "vs" medido con el mismo arnés, nunca narrado
- 🧪 **30–40 ejercicios** graduados 🟢🟡🟠🔴 por fase
- **El anti-patrón recurrente de toda la ruta:** usar el motor donde no toca
  (Redis como base primaria, Neo4j para dos saltos, vectorial dedicado para
  10k documentos, Cassandra para un CRUD). El fanboy es el villano transversal.

---

## 🗂️ La lista maestra

| # | Familia | Nombre con gancho | Vs. de productos | Proyecto | Productizable |
|---|---|---|---|---|---|
| 0 | 🍃 Documental | **Proteo** | MongoDB vs **Couchbase** vs Postgres/JSONB | Catálogo multi-vertical + PIM | ✅ Fuerte |
| 1 | 🔑 Clave-valor | **Portalón** | Redis vs Dragonfly vs Valkey | Gateway: rate limit, sesiones, colas, leaderboard | ✅ Fuerte |
| 2 | 🦆 Analítico embebido | **Cristalería** | DuckDB vs pandas/Polars vs SQLite | Pipeline analítico sin servidor, dashboard WASM | ✅ Media-fuerte |
| 3 | 🧬 Vectorial | **Oráculo de Bolsillo** | pgvector vs Qdrant vs Weaviate vs Pinecone | RAG con citas verificables | ✅ Muy fuerte |
| 4 | 🕸️ Grafos | **Telaraña** | Neo4j vs Amazon Neptune vs Memgraph | Detección de fraude en anillos | ✅ Fuerte |
| 5 | 🏛️ Columnar ancha | **Centinela de Flota** | Cassandra vs ScyllaDB vs Bigtable | Telemetría IoT con roll-ups | ✅ Media (necesita vertical propio) |
| 6 | 🔍 Búsqueda | **Buscafino** | Elasticsearch vs OpenSearch vs Meilisearch/Typesense | Búsqueda facetada como servicio | ✅ Fuerte |
| 7 | 📴 Offline-first | **Bitácora de Campo** | CouchDB+PouchDB vs Firebase/Firestore vs ElectricSQL | Inspecciones de campo con sync | ✅ Muy fuerte |
| 8 | ⏱️ Series temporales | **El Vigía** | InfluxDB vs TimescaleDB vs Mongo Time Series | Monitoreo de infraestructura | ⚠️ Débil como SaaS horizontal — necesita vertical nicho |
| 9 | ⚡ NewSQL / distribuido ACID | **Libro Mayor** | CockroachDB vs TiDB vs YugabyteDB | Ledger transaccional cross-región | ⚠️ Media — infraestructura interna, no producto B2C |
| 10 | ⚖️ Políglota (capstone) | **El Árbitro** | — (el "vs" es arquitectónico) | Sistema con 3+ motores y su factura completa | ⚠️ No es producto — es demostración pedagógica |

**Total: 11 tutoriales, 0 repetido de la ruta legacy.**

---

## 🏆 Orden de prioridad si hay que elegir por dónde empezar

**Por mercado + diferenciador técnico defendible:**
Oráculo de Bolsillo (3) > Bitácora de Campo (7) > Proteo (0) > Portalón (1) > Telaraña (4)

**Por progresión pedagógica (recalibra el instinto más rápido):**
Portalón (1) → Cristalería (2) → Oráculo de Bolsillo (3) → Telaraña (4) → Centinela de Flota (5) → Buscafino (6) → Bitácora de Campo (7) → El Vigía (8) → Libro Mayor (9) → El Árbitro (10)

---

## 🎯 La promesa de la ruta completa

> "Me presentan un dominio y no pregunto qué base usar: pregunto qué se lee
> junto, qué se cruza en caliente, dónde viven las invariantes y quién va a
> operar esto un martes a las 3 am. Conozco diez familias, sé qué error
> comete cada una por gravedad, sé decir 'esto es Postgres, no necesitas nada
> más' sin que me duela el ego — y sé decir 'esto sí necesita Mongo/Neo4j/lo
> que sea' con números en la mano, no con una bandera."

---

## 📌 Notas de continuidad

- **Proteo** es el primer curso a redactar tras esta lista (ya con dominio,
  fases y stack decididos en conversación previa: MongoDB 8.0, Node 22 + TS,
  Express 5, PostgreSQL 16, Redis/Valkey, Meilisearch — 13 fases, ~400
  ejercicios).
- **CouchDB ≠ Couchbase**: motores, licencias y nichos distintos desde 2011.
  CouchDB (Erlang, Apache, offline-first) → curso 7. Couchbase (C++, N1QL,
  memoria-first, operacional) → rival de Mongo en el curso 0.
- El curso 10 (El Árbitro) debe presentarse explícitamente como cierre de
  ruta, no como "producto #11" — su valor es mostrar la factura de mezclar
  motores sin criterio.
