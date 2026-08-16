# 🎯 Buscafino — Alcance del proyecto

> Deriva de `06-buscafino-semilla.md`. Ante cualquier conflicto, gana la
> semilla. Este documento no repite la deliberación completa (motivación,
> marco de 5 preguntas, stack): la asume y se concentra en trazar el
> perímetro exacto del curso — qué entra, qué no, contra qué se mide en el
> mundo real, y cuándo la respuesta correcta es *no construir esto*.

---

## 1. Qué construye el curso

Buscafino es **un servicio de búsqueda facetada reutilizable** que se
enchufa delante de un catálogo de marketplace ya existente. No es el
marketplace: es la pieza que responde "¿qué es más relevante para estas
palabras, en qué orden, y cuántos hay de cada tipo si filtro por marca,
precio o categoría?" — recalculado en cada consulta.

Concretamente, al terminar el curso existe:

- Un **sistema transaccional mínimo pero real** en PostgreSQL (tabla de
  productos + tabla de outbox) que actúa como fuente de verdad del catálogo.
- Un **índice de búsqueda derivado** en Meilisearch, reconstruible por
  completo desde Postgres en cualquier momento, con relevancia ajustable
  (pesos por campo, señales de negocio como popularidad o frescura),
  facetas nativas (marca, categoría, precio, color, valoración) y
  tolerancia a errores (typos, prefijos, fonética básica).
- Un **mecanismo de sincronización** que mantiene el índice al día frente a
  las escrituras del transaccional, primero a mano (patrón outbox) y luego
  con CDC (Debezium) como ampliación.
- Un **procedimiento de reconstrucción sin downtime** (alias/swap) que
  demuestra en vivo que el índice se puede tirar y regenerar sin cortar el
  servicio.
- Un **arnés de comparación (`scripts/vs.ts`)** y sus dos artefactos
  acumulativos (`INSTINTOS.md`, `BENCHMARKS.md`) que sostienen con números
  cada afirmación "X es más rápido/mejor que Y" hecha durante el curso,
  incluida la comparación de control contra PostgreSQL+GIN+`pg_trgm` y el
  contraste entre motores ligeros (Meilisearch, Typesense) e industriales
  (Elasticsearch, OpenSearch).
- La **autopsia medida del villano** — el índice que se cree fuente de
  verdad — y el veredicto honesto de cuándo un motor de búsqueda dedicado
  se justifica y cuándo Postgres ya basta.

El resultado pedagógico no es "saber usar Meilisearch": es el criterio para
decidir, con evidencia propia, cuándo la búsqueda de un producto necesita un
motor dedicado y cuándo es sobre-ingeniería disfrazada de buena práctica.

## 2. Qué queda fuera por ahora

El curso traza líneas deliberadas para no diluirse. Quedan explícitamente
fuera de alcance:

- **El marketplace completo.** No hay carrito, pagos, checkout ni gestión de
  pedidos. El transaccional es el mínimo necesario para que el mantra del
  índice derivado tenga una fuente de verdad real detrás — no un catálogo de
  negocio funcional.
- **Recomendaciones y personalización.** "Productos similares" o ranking
  personalizado por historial de usuario son un problema de otro modelo
  (vectorial / grafo de co-ocurrencia, ver Fase 8 de Proteo) y no entran
  aquí salvo mención de frontera.
- **Búsqueda semántica por embeddings.** Buscafino cubre relevancia léxica,
  facetas y tolerancia a errores — el terreno clásico de un motor de
  búsqueda invertido. La búsqueda por similitud semántica es el modelo
  vectorial (Oráculo de Bolsillo, curso #3) y se menciona solo como
  contraste conceptual, no se implementa.
- **Multi-tenancy e infraestructura de producción a gran escala** (sharding
  real entre regiones, alta disponibilidad multi-datacenter). El curso opera
  en un laboratorio local con Docker Compose; la escala se discute en la
  Fase 10 de forma conceptual y medida donde el laboratorio lo permite, no
  desplegada.
- **CouchDB y la sincronización offline-first.** Aunque comparten la letra
  "Couch", **CouchDB no es Couchbase y ninguno de los dos aparece aquí**:
  CouchDB es el motor del curso #7 (offline-first); Couchbase es rival
  documental del curso #0 (Proteo). Buscafino no toca ninguno de los dos.
- **Analyzers lingüísticos avanzados y NLP propio.** El curso usa la
  tokenización y los diccionarios que cada motor trae de fábrica (incluido
  el soporte multi-idioma nativo de la Fase 10); no se entrena ni ajusta un
  pipeline de NLP propio.

## 3. Contra qué mercado real se valida (productizable ✅ fuerte)

Buscafino no es un ejercicio de laboratorio sin contraparte comercial: es la
forma exacta de una categoría de producto viva. **Algolia** es la referencia
comercial dominante de "búsqueda como servicio" gestionado; **Elasticsearch
y OpenSearch** son el estándar histórico self-hosted de nivel industrial; y
**Meilisearch y Typesense** son la generación reciente de alternativas
ligeras y económicas, posicionadas explícitamente como sustitutos más
simples de operar. Cualquier equipo de producto que decide "compramos
Algolia, montamos Elasticsearch, o probamos Meilisearch" está resolviendo el
mismo problema que resuelve este curso — con la diferencia de que el
estudiante que lo termina tiene números propios, medidos contra su propio
corpus, en lugar del benchmark de marketing de un proveedor.

La validación de mercado tiene cuatro capas:

| Capa | Referencia real |
|---|---|
| Gestionado / comercial | Algolia, Elastic Cloud, Amazon OpenSearch Service |
| Self-hosted industrial | Elasticsearch, OpenSearch |
| Self-hosted ligero | Meilisearch, Typesense |
| Control "ya lo tengo" | PostgreSQL + `tsvector`/GIN + `pg_trgm` |

Un ingeniero que termina Buscafino puede sentarse en cualquiera de esas
cuatro conversaciones de compra o construcción con criterio propio, no con
la opinión del último artículo que leyó.

## 4. Árbol de decisión: cuándo NO usar un motor de búsqueda dedicado

El curso entrega, como parte del veredicto de cierre (Fase 11), un árbol de
decisión explícito. Se reproduce aquí en su forma mínima porque es el
resumen ejecutivo del alcance completo: si la respuesta correcta para un
caso dado es "no", ese caso queda fuera de lo que Buscafino recomienda
construir, aunque el curso lo haya enseñado.

| Pregunta | Si la respuesta es… | Entonces… |
|---|---|---|
| ¿El volumen de documentos y de consultas por segundo es moderado (miles a pocos cientos de miles de filas, tráfico bajo)? | Sí | **Postgres + GIN + `tsvector` + `pg_trgm` basta.** No sumes un motor dedicado; el curso lo mide en la Fase 1 y en la autopsia final. |
| ¿La relevancia necesaria es "coincide o no coincide", sin señales de negocio combinadas (popularidad, frescura, boost por campo)? | Sí | Postgres basta. La relevancia multi-señal ajustable es la razón de peso para un motor dedicado; si no la necesitas, no pagues su costo operativo. |
| ¿Las facetas son pocas y estables (una o dos, que casi no cambian)? | Sí | Un `GROUP BY` bien indexado en Postgres es sostenible. Las facetas nativas ganan cuando son muchas, combinadas y de alta cardinalidad. |
| ¿La tolerancia a errores puede vivir con `pg_trgm` (typos simples, sin autocompletado a velocidad de tecleo)? | Sí | Postgres basta. La typo-tolerance nativa y el autocompletado con p95/p99 bajo ráfaga son el terreno donde un motor dedicado se nota. |
| ¿Alguna de las anteriores es "no" a escala creciente, y el equipo puede operar un servicio adicional? | No a alguna | **Motor dedicado justificado.** Empieza por un motor ligero (Meilisearch/Typesense); solo sube a Elasticsearch/OpenSearch si necesitas analyzers avanzados, multi-idioma profundo o agregaciones que los ligeros no cubren (Fase 10). |
| ¿El equipo está a punto de escribir datos de negocio que **solo** existen en el índice de búsqueda (sin espejo en un transaccional)? | Sí | **Alto. Ese es el villano del curso.** El motor de búsqueda nunca es la fuente de verdad; si esa pregunta se responde "sí", el diseño está roto antes de medir nada. |

La última fila es la más importante del árbol y no es negociable: es el
patrón "índice derivado, nunca fuente de verdad" que atraviesa todo el
curso. Cualquier alcance de proyecto real que se inspire en Buscafino hereda
esa restricción como primer principio de diseño, no como una opción más del
árbol.

## 5. Frontera con el resto de la ruta

- **Proteo (curso #0)** ya toca búsqueda de forma tangencial en su Fase 7
  ("Búsqueda y facetas: cuándo el documento no basta"), donde se instala por
  primera vez la frase "índice derivado, nunca fuente de verdad" en el
  contexto de un catálogo documental en MongoDB. Buscafino retoma esa frase
  y la convierte en el eje completo de un curso propio, mucho más profundo
  en relevancia, facetas y tolerancia a errores.
- **El Árbitro (curso #10)** usa Meilisearch como una de las piezas de su
  sistema políglota de cierre, pero no enseña el modelo de búsqueda desde
  cero: asume lo que Buscafino ya instaló y se concentra en el costo de
  operar la pieza dentro de un sistema mayor.
- Ninguna semilla de otro curso debe reintroducir el modelo de búsqueda como
  si fuera nuevo; si aparece, debe citar a Buscafino como el lugar donde se
  enseña en profundidad.
