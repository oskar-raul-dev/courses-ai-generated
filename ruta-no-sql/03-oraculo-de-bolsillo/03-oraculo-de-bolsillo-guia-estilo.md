# ✍️ Guía de estilo, tono y convenciones
## Curso Oráculo de Bolsillo (Vectorial) — Ruta NoSQL

Esta guía es la fuente de verdad editorial del curso. Deriva de
`GUIA-DE-ESTILO-Y-CONVENCIONES.md` (guía legacy de la ruta) adaptada al
modelo vectorial: mismo principio rector, mismo tono, mismo esqueleto de
plantilla de fase, distinto villano, distinto diccionario y distintos
recuadros propios.

> 🧭 **Regla de una línea que rige todo el código:** el **código en
> inglés**; toda narrativa, comentarios y textos de interfaz **en
> español**. Detalle completo en §4.

> 🗣️ **Regla de tratamiento:** el curso se dirige al lector de **"tú"**, sin
> voseo. Nunca "vos tomás", "vos medís" — siempre "tú tomas", "tú mides". Es
> la misma convención de toda la ruta; se reafirma acá porque el modelo
> vectorial invita a mucha instrucción imperativa directa ("mide el
> recall", "corre el arnés") donde el voseo se cuela con facilidad si no se
> vigila.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien decida, con números propios,
si necesita un motor vectorial dedicado.** No enseñamos pgvector ni Qdrant
"de moda". Enseñamos a medir, comparar y decidir. Si un párrafo no ayuda a
razonar sobre esa decisión —o a construir el sistema que la pone a prueba—,
sobra.

El norte del curso es una sola señal de éxito: **ninguna afirmación
comparativa aparece sin una fila de `BENCHMARKS.md` que la respalde.** Todo
lo que escribimos sirve a esa promesa. Un "Qdrant es más rápido" sin número
propio es, para este curso, una frase que no se escribe.

---

## 2. Tono

El tono es **cálido, informal y directo** — de colega senior a colega
senior, con humor cuando cae bien. No es un manual acartonado: es alguien
que ya corrió estos duelos de motores y te explica con confianza, sin
solemnidad y sin marketing.

- **Segunda persona, cercana, sin voseo.** "Corre `vs.ts` antes de creerte
  el benchmark del vendedor", "si el filtro te vació el HNSW, primero
  mide". Nunca "corré", "medí", "creételo".
- **Humor seco permitido.** Un 😉, un chiste sobre "media hora convenciendo
  al equipo de migrar a Qdrant para 8.000 documentos", un 🪦 para jubilar un
  benchmark de marketing. El humor desdramatiza la ansiedad de "todos migran
  a un vector store, ¿yo también debería?"; no rellena.
- **Honesto sobre el hype.** El modelo vectorial es, en 2026, el más
  sujeto a marketing agresivo de toda la ruta. Cuando un vendedor promete
  "escala a miles de millones de vectores" sin mencionar el costo
  operativo, se dice con gracia y se mide en su contra.
- **Orientado a la duda real.** Anticipa "¿y por qué no uso directamente
  Qdrant desde el día uno?" y la responde con la doctrina del curso
  (§6), no con una promesa de que "ya vas a entender".
- **Cercanía sin condescendencia.** El lector es senior y viene de SQL: no
  le expliques qué es un índice, un `EXPLAIN` o la selectividad — **lo
  sabe**. Lo nuevo es cómo esos conceptos se comportan (o dejan de
  comportarse) cuando la distancia reemplaza a la igualdad y al rango.

Evitar: promesas vacías ("vas a dominar el RAG perfecto"), motivación de
coach, solemnidad de manual corporativo, y explicar lo obvio del mundo SQL
del lector. El humor es condimento, no plato principal.

> 🧠 **Matiz propio del curso (el eje central).** El lector no llega en
> blanco: llega con años de instinto relacional sobre índices, JOINs y
> planes de ejecución. El tono reconoce esos instintos y los interpela de
> frente con dos micro-secciones recurrentes (§7.4): 🪞 *"tu instinto SQL
> dice… y esta vez se equivoca"* y 🩻 *"esto sí viaja igual"*. Nunca se
> ridiculiza el instinto: se lo honra y se lo recalibra — el índice
> vectorial es *aproximado*, y esa sola palabra rompe más instintos de
> golpe que cualquier otro modelo de la ruta.

---

## 3. Idioma y forma (narrativa)

- **Español claro y técnico** para todo lo que **no** es código (títulos,
  explicaciones, ejercicios, referencias).
- **Sin voseo, en ningún documento del curso** — ni en la narrativa, ni en
  los enunciados de ejercicio, ni en los callouts. Se revisa como parte del
  checklist de cierre (§14).
- Los términos del stack se dejan en inglés cuando son el nombre real:
  *embedding*, *chunk*, *recall*, *latency*, *ground truth*, *collection*,
  *payload*, *point*, *namespace*, *reranking*, *quantization*, *sharding*.
  No se traducen forzadamente (nadie dice "incrustación" en un equipo real
  de 2026; sí dice "embedding").
- Markdown siempre.
- Encabezados con emoji **con moderación** — uno por sección de plantilla.
- **Prosa antes que listas.** Se prefiere explicar razonando en párrafos.
  Las listas se usan cuando son de verdad una lista (pasos, ítems
  paralelos).
- **Tablas solo para comparar, decidir o mapear.** "Cuándo usar pgvector
  vs. un dedicado", matrices de decisión, mapeos SQL↔vectorial (§7.4), y
  las tablas de resultados de `vs.ts` (que en el cuerpo de la fase se citan
  o resumen, pero **viven** en `BENCHMARKS.md`). No para narrar.

---

## 4. Idioma del código fuente (código en inglés, curso en español)

Normativa para **todo** fragmento de código del curso: servicio TypeScript,
pipeline Python, `scripts/vs.ts`, ejercicios resueltos y apéndices.

### 4.1 Regla general

| Capa | Idioma | Ejemplo |
|---|---|---|
| **Código fuente** (identificadores) | 🇬🇧 Inglés | `function embedQuery(text: string) {}`, `const topK = 5` |
| **Endpoints y rutas** | 🇬🇧 Inglés | `/ask`, `/documents/:id/chunks`, `/health` |
| **Constantes y enums internos** | 🇬🇧 Inglés | `distanceMetric: 'cosine'`, `INDEX_TYPE`, `MAX_CONTEXT_TOKENS` |
| **Tablas y columnas de Postgres** | 🇬🇧 Inglés | `chunks`, `documents`, `{ documentId, content, embedding, page }` |
| **Colecciones y payloads de Qdrant/Weaviate** | 🇬🇧 Inglés | `collection('chunks')`, `payload: { documentId, section }` |
| **Nombres de archivo, módulo, servicio** | 🇬🇧 Inglés | `chunkIngestion.py`, `similaritySearchService.ts`, `vs.ts` |
| **Comentarios de código** | 🇪🇸 Español | `// el filtro va antes del ANN solo si el metadato es muy selectivo` |
| **Textos de interfaz (CLI/API)** | 🇪🇸 Español | `"No se encontraron fragmentos relevantes"`, mensajes de error legibles |
| **Narrativa del tutorial** | 🇪🇸 Español | Todo el texto fuera de bloques de código |

> 📝 **Por qué esta regla.** El código de un sistema RAG real mantenido por
> un equipo técnico está en inglés, con comentarios en español, igual que
> acá. Escribir el pedagógico así hace que el vocabulario de
> identificadores sea el mismo que la persona va a encontrar operando
> pgvector, Qdrant, Weaviate o Pinecone en producción — los cuatro exponen
> su propia jerga en inglés (`payload`, `point`, `namespace`) y traducirla
> forzadamente al español confundiría más de lo que aclara.

### 4.2 Diccionario del dominio (Oráculo de Bolsillo)

| Español (narrativa, UI) | Inglés (código) | Nota |
|---|---|---|
| fragmento | `chunk` | unidad de trabajo central |
| incrustación / embedding | `embedding` | se usa "embedding" también en narrativa; es el nombre real |
| documento | `document` | |
| pregunta | `query` | la pregunta ya convertida a embedding, en el código |
| vecino más cercano | `nearestNeighbor` / `neighbor` | |
| similitud / parecido | `similarity` | |
| distancia | `distance` | ojo: mayor similitud = menor distancia (coseno/L2) |
| recuperación | `retrieval` | |
| cita / procedencia | `citation` / `provenance` | |
| corpus | `corpus` | se usa igual en ambos idiomas |
| escaneo exacto / fuerza bruta | `exactScan` / `bruteForce` | ground truth de recall |
| exhaustividad (métrica) | `recall` | se usa "recall" también en narrativa; no se traduce como "exhaustividad" salvo la primera vez que se define |
| corte / tamaño del resultado | `topK` | |

Los nombres de servicios, módulos y funciones se arman combinando estos
términos con verbos técnicos habituales (`embed`, `search`, `ingest`,
`rerank`, `cite`, `evaluate`) — p. ej. `embedChunk`, `searchNearest`,
`buildCitation`, `evaluateRecall`.

### 4.3 Convenciones de nombrado

- **Funciones y variables:** `camelCase` en inglés — `searchNearestChunks`,
  `isAboveRecallThreshold`, `embeddingDimension`.
- **Constantes de configuración:** `SCREAMING_SNAKE_CASE` —
  `DEFAULT_TOP_K`, `HNSW_EF_SEARCH`, `MAX_CONTEXT_TOKENS`.
- **Endpoints REST:** sustantivo o verbo de dominio, inglés — `/ask`,
  `/ingest`, `/chunks/:id`.
- **Tablas Postgres / colecciones vectoriales:** sustantivo plural, inglés
  — `chunks`, `documents`; en Qdrant/Weaviate, `collection('chunks')`.
- **Módulos del servicio:** `<dominio>.<capa>.ts` — `chunks.repository.ts`,
  `retrieval.service.ts`, `citation.builder.ts`.
- **Scripts del arnés:** `vs.ts` es el nombre fijo del juez; los adaptadores
  por motor viven como `vs.pgvector.ts`, `vs.qdrant.ts`, `vs.weaviate.ts`,
  `vs.pinecone.ts`.

### 4.4 Lo que nunca cambia

- **Comentarios de código:** 100% español, explicando el porqué.
- **Textos de interfaz:** 100% español.
- **Narrativa del tutorial:** 100% español.
- **Nombres propios del dominio en la narrativa:** "fragmento", "corpus",
  "cita" siguen siendo las palabras con que *hablas* del sistema, aunque el
  código diga `chunk`, `corpus`, `citation`. Excepción explícita: "embedding"
  y "recall" se usan igual en ambos idiomas por ser el término real que el
  lector va a encontrar en cualquier documentación del modelo.

---

## 5. Orientación a la práctica

Cada concepto se ancla en el dominio de Oráculo de Bolsillo y en código que
corre contra un motor real.

- **Nada de teoría suelta.** Si se explica HNSW, se explica sobre el corpus
  del laboratorio, con su recall medido — no con un diagrama abstracto de
  grafo sin números al lado.
- **Código ejecutable y coherente.** Todo fragmento corre con las versiones
  fijadas del stack (Postgres 18.6, pgvector 0.8.x, Qdrant 1.19.x, Weaviate
  1.37.x, Node 24 LTS, Python 3.13.x) y no contradice fases anteriores.
- **Código mínimo.** El fragmento más pequeño que muestra el punto, pero
  ejecutable.
- **Comentarios que explican el porqué, no el qué, siempre en español.**
  `// filtramos por metadato ANTES del ANN solo si reduce el corpus a <5%: si no, vacía el grafo HNSW` sí; `// declara la variable` no.
- **Distinguir capas.** Siempre queda claro si un comportamiento vive en el
  pipeline de ingesta (Python), en el servicio de consulta (TypeScript), en
  la extensión de Postgres, o en el motor dedicado. Es la distinción que
  salva a quien depura un recall que se desplomó.

---

## 6. La doctrina del curso: barato primero, medido siempre

Esta sección reemplaza el "manejo del código legacy" de la guía original,
porque el eje de este curso no es leer código heredado sino **resistir la
tentación de adoptar infraestructura antes de necesitarla**.

- **No se adopta un motor dedicado por adelantado.** Aunque Qdrant y
  Weaviate estén declarados en el `docker-compose` desde la Fase 0, no se
  usan de verdad hasta que la Fase 6 mide el techo de pgvector con
  `vs.ts`. Escribir una fase que "adelanta" Qdrant porque es más
  interesante rompe la doctrina del curso.
- **Ninguna comparación se narra: se mide.** Si una fase necesita decir
  "X es más rápido que Y", esa frase va acompañada de la tabla de
  `BENCHMARKS.md` que la generó, con fecha, versión de motor, hardware y
  parámetros. Sin eso, la frase no se escribe.
- **El instinto SQL se recalibra, no se descarta.** Donde el paradigma
  relacional sigue valiendo (selectividad, `EXPLAIN`, costo de escritura
  del índice), se lo dice explícitamente con 🩻. Donde deja de valer
  (exactitud garantizada, filtro-antes-que-índice), se lo dice con 🪞
  **antes** de que el lector se golpee con el resultado.
- **El costo operativo se nombra siempre que se nombra una ganancia de
  rendimiento.** "Qdrant gana 3× en latencia a 1M chunks" es media frase;
  la otra media —qué servicio nuevo hay que operar, qué se sincroniza
  contra la fuente relacional— es obligatoria en la misma sección.

---

## 7. Marcadores y callouts (vocabulario visual del curso)

### 7.1 Marcadores de estado

- 🔥 **Opcional / ampliación.** Ejercicios o secciones (las codas Java/C++)
  que exceden el alcance base.
- ⭐ **Fase o pieza central.** Fases 3 (HNSW vs IVFFlat) y 6 (el techo de
  pgvector) — donde se juega la doctrina del curso.
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** Fácil / intermedio / difícil / muy
  difícil (ver §9: diversidad de nivel obligatoria en cada fase).

### 7.2 Callouts en blockquote (emoji-tipo)

- 📝 **Nota de contexto.** Por qué existe una decisión de stack o de
  versión. Ej.: "en 2026 la mayoría de los motores dedicados ya soportan
  cuantización binaria de fábrica; por eso Qdrant la trae desde la Fase 7."
- 📚 **Referencia rápida inline.** Un enlace útil justo donde surge la
  duda, sin esperar a la sección de referencias del capítulo.
- ⚠️ **Advertencia.** Algo que rompe si se ignora (dimensión que no
  coincide entre modelo de embeddings e índice, puerto gRPC de Qdrant,
  `ANALYZE` faltante en pgvector).
- 💡 **Truco o atajo** que ahorra tiempo real.

### 7.3 Secciones narrativas recurrentes (comunes)

- **Detalles con intención.** Lista corta que destila las decisiones
  deliberadas de un bloque ("recuperamos con `topK = 20` y recién después
  aplicamos rerank a 5, porque el rerank es caro y el ANN es barato").
- **El patrón a memorizar.** Una o dos frases que extraen la lección
  transferible de la fase.
- **Prueba de fuego.** Verificación manual concreta incrustada en el flujo:
  "apaga el índice HNSW, repite la consulta, compará el `EXPLAIN` — el
  seq scan aparece exactamente donde lo esperabas."
- **La señal de que quedó bien.** En el cierre, un criterio en forma de
  cita: "si mañana el corpus se triplica, sé exactamente en qué línea de
  `BENCHMARKS.md` mirar antes de decidir nada."

### 7.4 Secciones propias del curso (SQL → Vectorial)

Estas cuatro son la columna vertebral pedagógica y aparecen cuando el
contenido lo pide (heredadas del esqueleto no negociable de la ruta):

- **📖 Diccionario de traducción SQL → Vectorial.** Lado a lado, la
  operación relacional y su equivalente en el modelo vectorial. Ej.:
  `SELECT * FROM chunks ORDER BY (embedding <=> $1) LIMIT 5` ↔ "los 5
  vecinos más cercanos por distancia coseno". Es tabla (§3), no prosa. Vive
  también, acumulado, en el diccionario de traducción del curso.
- **🪞 "Tu instinto SQL dice… y esta vez se equivoca."** Nombra la trampa
  **antes** de caer en ella: "un índice sobre el vector me da rangos
  baratos como un B-tree", "el aproximado me da siempre el mismo resultado
  que el exacto", "filtro primero con un `WHERE` y busco después, como un
  índice compuesto". Honra el instinto y lo recalibra con la medición al
  lado.
- **🩻 "Esto sí viaja igual."** Lo reconfortante: la selectividad,
  `EXPLAIN`, la idea de índice como atajo, el costo de escritura del
  índice, el N+1 — siguen valiendo lo que valían en SQL. Baja la ansiedad
  del lector.
- **⚰️ Caso de estudio: el villano.** El motor dedicado prematuro (o su
  gemelo, quedarse en pgvector cuando ya no alcanza) bajo autopsia medida.
  Es el hilo que cose las fases 6 a 11.

---

## 8. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden
(idéntica a la de la ruta; §4 de la semilla confirma que se adopta tal
cual, con los recuadros del §7.4 insertados donde el modelo lo pide):

1. **🎯 Propósito** — qué resuelve esta fase; puede abrir con la situación
   heredada ("hasta ahora recuperabas por fuerza bruta y funcionaba, pero
   dolía…").
2. **✅ Qué queda listo al terminar** — checklist verificable.
3. **🚫 Qué queda fuera por ahora** — qué se difiere y a qué fase (p. ej.
   "el filtrado combinado con vecindad se difiere a la Fase 5").
4. **🧠 Conceptos mínimos** — solo lo necesario, anclado al dominio. Aquí
   viven la 📖 tabla de traducción y los recuadros 🪞/🩻 cuando la fase los
   necesita.
5. **💻 Implementación y código comentado** — el grueso; código ejecutable
   con comentarios de porqué, identificadores en inglés (§4). Aquí caben
   **Detalles con intención**, **El patrón a memorizar** y **Prueba de
   fuego**.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente
   (dimensión que no coincide, índice que no se usa, recall que se
   desploma) y cómo depurarlo.
7. **🧪 Ejercicios progresivos** — 20 a 40, ver §9.
8. **📚 Referencias** — ver §10. **Van al final de cada capítulo/fase, sin
   excepción**, nunca dispersas dentro del cuerpo salvo el 📚 inline puntual
   de §7.2.
9. **🚀 Cierre y conexión con la siguiente fase** — qué sigue y por qué.
   Aquí va **La señal de que quedó bien**.

Los apéndices no siguen esta plantilla: usan índice de salto rápido +
secciones cortas + tabla "cuándo usar qué" + 5-10 ejercicios cortos.

---

## 9. Ejercicios

- **Cantidad: 20 a 40 por fase**, con distribución equilibrada sugerida
  para ~30: ~8 🟢, ~9 🟡, ~7 🟠, ~4–6 🔴, más los 🔥 opcionales aparte.
- **Diversidad de nivel obligatoria en cada fase — no negociable.** Ninguna
  fase se cierra con ejercicios concentrados en un solo nivel de
  dificultad. Cada tanda cubre los cuatro niveles y, dentro de cada nivel,
  varía el *tipo* de ejercicio (construir, medir, diagnosticar, comparar) —
  no solo su dificultad numérica. Antes de cerrar una fase, revisar que
  haya al menos: dos ejercicios de **construcción** por nivel, uno de
  **medición** con `vs.ts`, y —a partir de 🟠— al menos uno de
  **diagnóstico** (bug entregado, hay que reproducir y localizar).
- **Numeración continua con encabezado de rango por dificultad:**
  ```
  ## 🧪 Ejercicios (30)

  **🟢 Fácil (1–8)**
  1. ...
  **🟡 Intermedio (9–17)**
  9. ...
  **🟠 Difícil (18–24)**
  18. ...
  **🔴 Muy difícil (25–30)**
  25. ...
  **🔥 Opcionales**
  - 🔥 ...
  ```
  El título lleva el conteo total: `## 🧪 Ejercicios (30)`.
- **Progresión real.** Los 🟢 calientan (guardar chunks, buscar los 5 más
  cercanos); los 🔴 exigen integrar varias fases o depurar algo esquivo
  (reproducir y arreglar un filtro que hunde el recall, y demostrarlo con
  `vs.ts`).
- **Accionables y verificables.** "Consigue que `searchNearest` devuelva
  recall@10 ≥ 0.95 contra el ground truth de fuerza bruta" — no "reflexiona
  sobre la aproximación".
- **Enganchados al dominio.** Usan chunks, corpus, citas, recall, latencia
  — nunca ejemplos abstractos de vectores sin contexto de documento.
- **Cuando un ejercicio nombra código, usa el identificador en inglés
  vigente** ("agrega el método `embedChunk`", "corre `vs.pgvector.ts`"),
  aunque el enunciado esté en español.
- Los 🔥 son opcionales y se listan aparte, sin numeración continua.

En apéndices bastan 5-10 ejercicios cortos de consulta.

---

## 10. Bibliografía y referencias

**Regla:** documentación oficial de las versiones fijadas del stack
**primero**; luego papers fundacionales cuando apliquen (HNSW, RAG); luego
blogs, videos y tutoriales. Siempre se advierte cuando un enlace apunta a
una versión distinta de la fijada.

### 10.1 Formato y ubicación

- **Las referencias van al final de cada capítulo (cada fase), en la
  sección 8 de la plantilla — nunca en un archivo aparte ni pospuestas al
  final del curso.** Esto es explícito y distinto de dejarlas "sueltas":
  cada fase es autocontenida en sus fuentes.
- **URLs completas y clicables**, no solo el dominio.
- **Secciones separadas** dentro de "Referencias": Documentación oficial
  (con URL completa y nota de versión), Papers cuando apliquen, Video/apoyo
  (con URL completa), y **Orden de lectura sugerido** (una línea que
  encadena qué leer primero).

### 10.2 Fuentes oficiales por tema (usar URL completa al citar)

- **PostgreSQL 18:** https://www.postgresql.org/docs/18/
- **pgvector:** https://github.com/pgvector/pgvector
- **Qdrant 1.19:** https://qdrant.tech/documentation/
- **Weaviate 1.37:** https://docs.weaviate.io
- **Pinecone:** https://docs.pinecone.io
- **sentence-transformers:** https://www.sbert.net
- **MDN** para JS base: https://developer.mozilla.org

### 10.3 Advertencias

- **Sobre citas:** cuando se mencione un paper, video o post específico,
  hay que dejar claro que URLs, títulos y DOIs pueden estar desactualizados
  o ser inexactos; el lector debe verificarlos. No se inventan números de
  página, DOIs ni IDs de video.
- **No usar en el código principal** motores o versiones fuera de las
  fijadas en el stack de la semilla (p. ej. una versión de pgvector
  anterior a 0.8, o un cliente de Qdrant/Weaviate no oficial). Las
  alternativas aparecen solo como comparación o en las codas 🔥.
- **Los benchmarks publicados por vendedores** (de cualquier motor) se
  citan únicamente para desmontarlos con medición propia — nunca se
  reproducen como verdad sin la corrida local de `vs.ts` al lado.

---

## 11. Sobre el dominio (ficticio, sin NDA)

Oráculo de Bolsillo es un dominio **enteramente ficticio**: un sistema de
Q&A sobre documentos inventado para este curso. No hay confidencialidad que
preservar ni sistema real que disfrazar.

- Los ejemplos pueden ser todo lo concretos que convenga; no hace falta
  "generalizar ante la duda" — se puede usar como corpus de ejemplo un
  manual técnico ficticio, notas internas ficticias, etc.
- El vocabulario del dominio (chunk, corpus, cita, recall) es estable y se
  fija en el diccionario de traducción del curso (§4.2); no compite con
  ningún vocabulario "real" que haya que evitar.
- La regla de idioma del código (§4) es una convención de calidad, no una
  cuestión de NDA: se traduce el vocabulario del dominio pedagógico
  ("fragmento" → `chunk`) por consistencia y realismo con lo que el lector
  va a encontrar en cualquier motor vectorial real, no por confidencialidad.

---

## 12. Coherencia entre documentos

- **No contradecir fases anteriores.** Un fragmento de la Fase 7 no puede
  asumir un `chunk` con forma distinta de la fijada en la Fase 0; la
  anatomía del `chunk` (semilla, §Anatomía) es el contrato que no se
  rompe.
- **No reescribir decisiones aprobadas** sin señalar explícitamente la
  incompatibilidad y por qué.
- **Fuentes de verdad, en orden:** (1) instrucciones del proyecto de la
  Ruta NoSQL, (2) `03-oraculo-de-bolsillo-semilla.md`, (3)
  `RUTA-NOSQL-FUNDAMENTOS.md`, (4) entregables aprobados de fases
  anteriores del curso, (5) decisiones explícitas del chat actual.
- **`scripts/vs.ts` es la costura entre fases.** Cada motor nuevo que entra
  (Fase 7, 8, 9) le agrega un adaptador sin romper los anteriores; si el
  contrato de entrada/salida del arnés cambia, se documenta el cambio y se
  revisan las fases previas que lo invocan.
- Nombres de archivos, módulos, servicios, tablas y colecciones se
  mantienen estables entre fases (en inglés, §4). Si algo se renombra, se
  documenta el cambio.

---

## 13. Autopsias y duelos medidos

Cada autopsia del villano (⚰️, típicamente en las Fases 6 y 11) sigue esta
estructura de ocho puntos, adaptada del post-mortem de incidentes de la
ruta:

1. Hipótesis del duelo (qué se espera medir y por qué).
2. Configuración exacta (motor, versión, parámetros de índice, hardware,
   tamaño de corpus).
3. Corrida de `vs.ts` y evidencia observable (la tabla cruda).
4. Lectura del resultado (qué régimen ganó y por qué, en términos del
   modelo, no de anécdota).
5. Costo operativo del lado ganador, siempre nombrado (§6).
6. Régimen donde el resultado se invierte, si lo hay.
7. Qué instinto de `INSTINTOS.md` queda confirmado, recalibrado o falsado.
8. Veredicto **sin culpabilización**: se analiza el sistema y la decisión
   de arquitectura, no a quien la tomó.

El tono de la autopsia es sereno y analítico. El humor cálido del resto del
curso baja un punto acá: una autopsia es seria, aunque no acartonada.

---

## 14. Checklist rápido antes de dar por cerrado un `.md`

- [ ] Sigue la plantilla de 9 secciones (o el formato de apéndice).
- [ ] Tono cálido e informal, segunda persona **sin voseo**, humor con
      moderación.
- [ ] Todo el código corre con las versiones fijadas del stack (§stack de
      la semilla).
- [ ] **Identificadores, endpoints, tablas/colecciones, constantes y enums
      del código en inglés (§4).**
- [ ] **Comentarios de código y textos de interfaz en español (§4.4).**
- [ ] No contradice ninguna fase anterior; respeta la anatomía del `chunk`.
- [ ] Distingue capas (ingesta Python / servicio TypeScript / Postgres /
      motor dedicado) donde importa.
- [ ] Usa el vocabulario de callouts (📝 📚 ⚠️ 💡) y los recuadros 📖 🪞 🩻
      ⚰️ donde aporten.
- [ ] Marca 🔥 lo opcional (codas Java/C++, ejercicios fuera del alcance
      base).
- [ ] Ninguna afirmación comparativa aparece sin remitir a una fila de
      `BENCHMARKS.md`.
- [ ] Tiene 20-40 ejercicios numerados con rangos 🟢🟡🟠🔴 equilibrados **y
      con diversidad de tipo dentro de cada nivel** (o 5-10 en apéndices).
- [ ] **Referencias al final del capítulo** (sección 8 de la plantilla),
      con URL completa, secciones (oficial / papers / video / orden de
      lectura), y advertencia de versión.
- [ ] Explica el *porqué* de cada decisión relevante.
- [ ] Incluye "La señal de que quedó bien" en el cierre.
