# ✍️ Guía de estilo, tono y convenciones — Proyecto Telaraña
## Curso #4 de la Ruta NoSQL (modelo de Grafo)

Esta guía es la fuente de verdad editorial de Telaraña. Cualquier chat que
produzca un `.md` de este curso la sigue. Deriva de la
`GUIA-DE-ESTILO-Y-CONVENCIONES.md` legacy de la ruta, adaptada al modelo de
grafo: mismo tono, mismo esqueleto de fase, mismo criterio de idioma, con el
villano, el diccionario de traducción y los recuadros propios de Telaraña.

> 🧭 **Regla de una línea que rige todo el código:** el **código en inglés**
> (Cypher, TypeScript, SQL); todo lo demás —narrativa, comentarios, textos de
> salida del arnés— **en español**. Detalle completo en §4.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien sepa decidir, con números en la
mano, cuándo un recorrido necesita un grafo y cuándo no.** No enseñamos Cypher
"bonito" ni Neo4j "de moda". Enseñamos a modelar, recorrer, medir y decidir.
Si un párrafo no ayuda a modelar una relación, escribir un recorrido, medir su
costo o defender un veredicto, sobra.

El norte compartido de todo el curso es una sola señal de éxito: **saber
señalar, con la curva de la Fase 4 en la mano, el punto exacto de profundidad
donde el grafo empieza a ganar** — y saber que por debajo de ese punto,
Postgres sigue siendo la opción correcta. Todo lo que se escribe sirve a esa
promesa.

---

## 2. Tono

El tono es **cálido, informal y directo** — de colega senior a colega senior,
con humor cuando cae bien. No es un manual acartonado: es alguien que ya se
quemó modelando un catálogo entero en Neo4j por error, explicándotelo con
confianza y sin solemnidad.

- **Segunda persona, cercana, sin voseo.** Se usa siempre "tú", nunca "vos"
  ni sus conjugaciones ("tenés", "sabés", "modelá"): "modela la arista antes
  de escribir el primer `MATCH`", "si el recorrido de tres saltos te tienta a
  usar grafo, primero mide". El registro es español neutro, no rioplatense ni
  de ninguna otra variedad regional marcada.
- **Humor seco permitido.** Un 😉, un chiste sobre "media hora modelando un
  grafo para un catálogo de dos niveles que un `JOIN` resolvía en un
  milisegundo", un 🪦 para jubilar una consulta. El humor desdramatiza la
  fricción de recalibrar un instinto, no rellena.
- **Honesto sobre lo feo.** Cuando algo es un sobre-diseño (y en grafo es
  fácil caer en eso), se dice con gracia: "este modelo es precioso en el
  diagrama y carísimo de operar para lo que resuelve". No se finge que un
  motor de grafo es gratis de mantener. El villano del curso —grafo donde
  bastaba un `JOIN`— se nombra sin piedad.
- **Orientado a la duda real.** Anticipa "¿y por qué esto es una arista y no
  una propiedad?" y la responde, muchas veces con una **nota de época** (📝)
  sobre por qué el modelo relacional no tiene una primitiva cómoda para esto.
- **Cercanía sin condescendencia.** El lector es senior de SQL. No le
  expliques qué es un índice, un `JOIN` o un plan de ejecución: **lo sabe**.
  Lo nuevo es cómo cambia (o no) al pasar a un motor de grafo.

Evitar: promesas vacías ("vas a dominar Cypher en una tarde"/"el grafo lo
resuelve todo"), motivación de coach, solemnidad de manual corporativo, y
explicar lo obvio del perfil SQL del lector. El humor es condimento, no plato
principal.

> 🧠 **Matiz propio de Telaraña (el eje del curso).** El lector no llega en
> blanco: llega con años de instinto relacional sobre JOINs y planes de
> ejecución. El tono reconoce esos instintos y los interpela de frente con
> dos micro-secciones recurrentes (§7.4): 🪞 *"tu instinto SQL dice… y esta
> vez se equivoca"* y 🩻 *"esto sí funciona igual"*. Nunca se ridiculiza el
> instinto relacional: se lo honra y se lo recalibra, un salto de profundidad
> a la vez.

---

## 3. Idioma y forma (narrativa)

- Español claro y técnico, sin voseo, para todo lo que **no** es código
  (títulos, explicaciones, ejercicios, referencias). Los términos del stack
  se dejan en inglés cuando son el nombre real del concepto o la API: *node*,
  *edge* (o "arista" en narrativa, ver §4.3), *traversal*, *pattern*,
  *shortest path*, *variable-length path*, *community detection*,
  *centrality*, *in-memory*. No se traducen forzadamente ni se inventa un
  término español donde el original ya es el estándar de la industria.
- Markdown siempre.
- Encabezados con emoji **con moderación** — uno por sección de plantilla.
  Los subtítulos internos pueden llevar emoji-tipo (§7) cuando aporta lectura
  rápida.
- **Prosa antes que listas.** Se prefiere explicar razonando en párrafos. Las
  listas se usan cuando son de verdad una lista (pasos, ítems paralelos).
- **Tablas solo para comparar, decidir o mapear.** "Cuándo usar grafo vs
  relacional", matrices de decisión, mapeos tipo de nodo/arista, y —muy
  importante en Telaraña— **tablas de traducción SQL ↔ Cypher** (§7.4). No
  para narrar.

---

## 4. Idioma del código fuente (código en inglés, curso en español)

Esta sección es normativa para **todo** fragmento de código del curso, sea en
el cuerpo de una fase, en un apéndice, en el arnés o en un ejercicio resuelto.

### 4.1 Regla general

| Capa | Idioma | Ejemplo |
|---|---|---|
| **Código fuente** (identificadores TS) | 🇬🇧 Inglés | `function detectRings(accountId: string) {}`, `const maxDepth = 5` |
| **Etiquetas de nodo y tipos de arista (Cypher)** | 🇬🇧 Inglés | `(:Account)`, `[:TRANSFERRED_TO]`, `(:Device)`, `[:USED_DEVICE]` |
| **Propiedades de nodos y aristas** | 🇬🇧 Inglés | `accountId`, `openedAt`, `amount`, `at`, `fingerprint` |
| **Tablas y columnas de Postgres (control)** | 🇬🇧 Inglés | `accounts`, `transfers`, `account_id`, `opened_at` |
| **Nombres de archivo, módulo, script del arnés** | 🇬🇧 Inglés | `vs.ts`, `ringDetector.ts`, `dataGenerator.ts` |
| **Comentarios de código** | 🇪🇸 Español | `// el ciclo se corta si el nodo ya está en el conjunto de visitados` |
| **Textos de salida del arnés (CLI, reportes)** | 🇪🇸 Español | `"Anillo detectado: 4 cuentas, profundidad 4"` |
| **Narrativa del tutorial** | 🇪🇸 Español | Todo el texto fuera de bloques de código |

> 📝 **Por qué esta regla.** Un motor de grafo en producción se opera en
> equipos que leen y escriben Cypher y TypeScript en inglés, con comentarios
> locales en el idioma del equipo. Escribir el pedagógico así hace que el
> vocabulario de etiquetas, tipos de relación y propiedades sea el mismo que
> el lector va a encontrar en cualquier base de Neo4j o Memgraph real —y el
> mismo que usa Postgres del otro lado, para que el diccionario de traducción
> (§7.4) mapee término a término sin fricción de idioma.

### 4.2 Qué se traduce y qué no (criterio rápido)

| Elemento | ¿Inglés? | Ejemplo |
|---|---|---|
| Etiquetas de nodo (`:Label`) | ✅ Sí | `(:Account)`, `(:Device)`, `(:Address)`, `(:Phone)` |
| Tipos de arista (`:TYPE`) | ✅ Sí | `[:TRANSFERRED_TO]`, `[:USED_DEVICE]`, `[:REGISTERED_AT]` |
| Propiedades de nodo/arista | ✅ Sí | `accountId`, `amount`, `txId`, `zip` |
| Nombres de función/variable en TypeScript | ✅ Sí | `function findShortestPath()`, `const visitedSet` |
| Colecciones de resultados/tipos TS | ✅ Sí | `interface RingResult { accounts: string[]; depth: number }` |
| Nombres de archivo/módulo/script | ✅ Sí | `ringDetector.ts`, `identitySignals.ts`, `vs.ts` |
| Comentarios `//`, `/* */` | ❌ No | `// esta consulta explota si no acotamos *1..k` |
| Mensajes de salida del arnés (lo que lee el lector en consola) | ❌ No | `"Profundidad 5: SQL tardó 40× más que Neo4j"` |
| Nombres del dominio en la narrativa | ❌ No | El texto sigue hablando de "cuenta", "transferencia", "anillo", "dispositivo" |

> ⚠️ **Caso mixto frecuente — resultados del arnés.** Los objetos que produce
> `vs.ts` usan keys en inglés (`{ engine, depthK, elapsedMs }`), pero el
> **texto** que se imprime en consola o se escribe en `BENCHMARKS.md` para
> el lector va en español: `{ engine: 'neo4j', depthK: 5, elapsedMs: 12,
> label: 'Neo4j a profundidad 5' }`. La clave es el dato que consume el
> código; el valor legible es lo que el lector interpreta.

### 4.3 Diccionario de traducción del dominio (Telaraña)

| Español (narrativa, UI del arnés) | Inglés (código Cypher/TS) |
|---|---|
| cuenta / cuentas | `Account` / `accounts` |
| dispositivo | `Device` |
| dirección | `Address` |
| teléfono | `Phone` |
| transferencia (arista) | `TRANSFERRED_TO` |
| usó el dispositivo (arista) | `USED_DEVICE` |
| declaró la dirección (arista) | `REGISTERED_AT` |
| declaró el teléfono (arista) | `HAS_PHONE` |
| anillo / ciclo de transferencias | `ring` / `cycle` |
| profundidad (del recorrido) | `depth` / `k` |
| conjunto de visitados | `visited` |
| camino más corto | `shortestPath` |
| identidad compartida / encubierta | `sharedIdentity` |
| vecindario (denso) | `neighborhood` |

> 📖 **Este diccionario es la base de la 📖 tabla de traducción SQL ↔ Cypher**
> que cada fase amplía con sus propios términos (§7.4). No se duplica: se
> extiende.

### 4.4 Convenciones de nombrado

- **Etiquetas de nodo:** `PascalCase` en singular — `Account`, `Device`,
  `Address`, `Phone`.
- **Tipos de arista:** `SCREAMING_SNAKE_CASE`, verbo o relación en mayúsculas
  — `TRANSFERRED_TO`, `USED_DEVICE`, `REGISTERED_AT`, `HAS_PHONE`.
- **Propiedades:** `camelCase` en inglés — `accountId`, `openedAt`, `txId`,
  `deviceId`.
- **Funciones y variables de TypeScript:** `camelCase` en inglés —
  `detectRings`, `findSharedDevices`, `maxDepth`, `visitedSet`.
- **Nombres de script/módulo del arnés:** `camelCase.ts` en inglés —
  `vs.ts`, `dataGenerator.ts`, `ringDetector.ts`, `identitySignals.ts`.
- **Tablas y columnas de Postgres:** `snake_case` en inglés — `accounts`,
  `transfers`, `account_id`, `opened_at`.
- **Parámetros de Cypher:** `$camelCase` en inglés — `$accountId`, `$maxDepth`.

### 4.5 Lo que nunca cambia

- **Comentarios de código:** 100% español, explicando el porqué (§5).
- **Textos de salida del arnés y reportes:** 100% español.
- **Narrativa del tutorial:** 100% español, sin voseo.
- **Nombres propios del dominio en la narrativa:** "cuenta", "transferencia",
  "anillo", "dispositivo", "dirección", "teléfono" siguen siendo las palabras
  con que *hablas* del sistema, aunque el código diga `Account`,
  `TRANSFERRED_TO`, `Device`.

---

## 5. Orientación a la práctica

Cada concepto se ancla en el dominio de fraude y en código que corre.

- **Nada de teoría suelta.** Si se explica `*1..k`, se explica sobre "todas
  las cuentas a distancia variable de esta", no en abstracto. Si se explica
  `PROFILE`, es sobre el `MATCH` de detección de anillos, no sobre un
  ejemplo de juguete sin relación con el curso.
- **Código ejecutable y coherente.** Todo fragmento de Cypher, SQL o
  TypeScript corre con las versiones fijadas en el stack de la semilla y no
  contradice fases anteriores. Nada de pseudocódigo que "se entiende".
- **Código mínimo.** El fragmento más pequeño que muestra el punto, pero
  ejecutable.
- **Comentarios que explican el porqué, no el qué, siempre en español.**
  `// cortamos el recorrido en visited para no reentrar en el ciclo` sí;
  `// suma uno a la profundidad` no.
- **Distinguir motor y capa.** Siempre queda claro si un comportamiento vive
  en Neo4j, en Memgraph, en Postgres o en el arnés TypeScript que orquesta la
  comparación. Es la distinción que hace legible cada "vs".

---

## 6. El método del "vs" en la escritura (nunca se narra sin medir)

Ningún párrafo del curso afirma que un motor "es más rápido" o "escala
mejor" sin apoyarse en una corrida real de `scripts/vs.ts` registrada en
`BENCHMARKS.md`. Al redactar una fase con un "vs":

- Se describe la consulta semántica que se compara (en palabras, antes que
  en código).
- Se muestra el código de cada lado (Cypher y su equivalente SQL o Cypher de
  otro motor).
- Se corre el arnés y se reporta el número real, con la profundidad `k`
  cuando aplica.
- Se interpreta el número: ¿dónde gana cada lado y por qué, en términos de
  cómo cada motor almacena la relación?

Frases prohibidas sin número al lado: "el grafo es mucho más rápido para
esto", "Postgres no puede con esto", "Memgraph vuela". Todas se reemplazan
por la cifra medida y su contexto (dataset, profundidad, repeticiones).

---

## 7. Marcadores y callouts (vocabulario visual de Telaraña)

Este vocabulario se usa igual en todos los documentos para que el lector lo
reconozca de un vistazo. Hereda el set base de la ruta y agrega los propios
del modelo de grafo.

### 7.1 Marcadores de estado

- 💸 **Deuda técnica intencional.** Un shortcut o simplificación que se deja
  a propósito y se paga después (§7.3). Ejemplo vivo: el generador siembra
  anillos con montos redondos en las primeras fases y se enriquece con
  montos ruidosos recién en la Fase 5, cuando el detector necesita ese
  realismo.
- 🔥 **Opcional / ampliación.** Ejercicios, secciones o el Apéndice F
  (Telaraña desde la JVM) que exceden el alcance base.
- ⭐ **Fase o pieza central.** La Fase 4 (profundidad variable, donde el
  grafo despega) es la ⭐ del curso.
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** Fácil / intermedio / difícil / muy
  difícil (§9).

### 7.2 Callouts en blockquote (emoji-tipo)

- 📝 **Nota de época o de diseño.** Contexto de por qué el modelo relacional
  no tiene una primitiva cómoda para esto, o por qué se fijó tal versión.
- 📚 **Referencia rápida inline.** Un enlace útil justo donde surge la duda,
  sin esperar a la sección de referencias del cierre de fase.
- 🪦 **Retiro / jubilación.** Cuando un enfoque cumple su función y se
  retira. Ej.: "🪦 Se jubila el `MATCH *1..3` fijo: desde acá el patrón es
  siempre de profundidad variable."
- ⚠️ **Advertencia.** Algo que rompe si se ignora (versión de Neo4j CalVer
  vs LTS, un `*1..k` sin cota que explota en memoria, Neptune y Couchbase
  confundidos con Couchbase/CouchDB de otros cursos de la ruta).
- 💡 **Truco o atajo** que ahorra tiempo real (un índice que falta y hace
  lento un recorrido, un `PROFILE` que revela el problema de un vistazo).

### 7.3 Secciones narrativas recurrentes (comunes a la ruta)

- **💸 Pago de deuda.** Dónde una deuda declarada antes se salda: qué era, de
  qué fase venía, qué cambió.
- **Detalles con intención.** Lista corta que destila las decisiones
  deliberadas de un bloque ("modelamos la transferencia como arista y no
  como nodo intermedio porque no necesita relacionarse con nada más que sus
  dos cuentas").
- **El patrón a memorizar.** Una o dos frases que extraen la lección
  transferible de la fase.
- **Prueba de fuego.** Verificación manual concreta incrustada en el flujo:
  "corre el arnés a `k=5`: si Neo4j no le gana a Postgres por al menos un
  orden de magnitud, algo en el índice está mal".
- **Mini-repaso.** Cuando una fase usa sintaxis nueva de Cypher que el
  lector no domina (patrones de camino, funciones de agregación de grafo),
  un repaso exprés en tabla antes del código, con su 📚.
- **La señal de que quedó bien.** En el cierre, un criterio en forma de
  cita: "si mañana te preguntan a qué profundidad conviene migrar este
  recorrido a grafo, respondes con un número de la curva de la Fase 4, no
  con una opinión."

### 7.4 Secciones propias de Telaraña (SQL → Cypher)

Estas cuatro son la columna vertebral del curso y aparecen cuando el
contenido lo pide:

- **📖 Tabla de traducción SQL ↔ Cypher.** Lado a lado, el CTE recursivo (o
  el `JOIN`) y su equivalente en Cypher. Ej.: `WITH RECURSIVE reachable
  AS (...)` ↔ `MATCH (a:Account)-[:TRANSFERRED_TO*1..5]->(b:Account)`. Es
  tabla (§3), no prosa.
- **🪞 "Tu instinto SQL dice… y esta vez se equivoca."** Nombra la trampa
  **antes** de caer en ella: pensar que un recorrido de 5 saltos costará
  "un poco más" que uno de 2, o que un `JOIN` de dos tablas se beneficia de
  migrar a grafo. Honra el instinto y lo recalibra con el número medido.
- **🩻 "Esto sí funciona igual."** Lo reconfortante: índices, selectividad,
  `PROFILE`/`EXPLAIN`, un filtro de un salto por propiedad, siguen valiendo
  exactamente lo que valían en SQL. Baja la ansiedad del lector antes de que
  el instinto se rompa en la fase siguiente.
- **⚰️ Caso de estudio: el anti-patrón.** El villano de Telaraña —grafo
  modelado para consultas que en el 90% de los casos son de un salto—: se
  mide, duele, se compara contra Postgres. Es el hilo que cierra el curso en
  la Fase 11.

---

## 8. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden:

1. **🎯 Propósito** — qué resuelve esta fase; puede abrir con la situación
   heredada ("hasta ahora modelamos el dominio en dos formas paralelas, pero
   ninguna consulta recorre todavía nada").
2. **✅ Qué queda listo al terminar** — checklist verificable.
3. **🚫 Qué queda fuera por ahora** — qué se difiere y a qué fase (usar
   `TELARANA-ALCANCE.md` como referencia para no prometer de más).
4. **🧠 Conceptos mínimos** — solo lo necesario, anclado al dominio de
   fraude. Aquí caben el **Mini-repaso** y las **Notas de época**. Aquí
   suelen vivir la 📖 tabla de traducción y los recuadros 🪞/🩻.
5. **💻 Implementación y código comentado** — el grueso; código ejecutable
   (Cypher, SQL, TypeScript) con comentarios de porqué, identificadores en
   inglés (§4). Aquí caben **Detalles con intención**, **El patrón a
   memorizar**, **Prueba de fuego** y **💸 Pago de deuda**.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente
   (recorrido sin cota que explota en memoria, ciclo sin control de
   visitados que cuelga en SQL) y cómo depurarlo.
7. **🧪 Ejercicios progresivos** — 20 a 40, graduados 🟢🟡🟠🔴 (§9).
8. **📚 Referencias del capítulo** — fuentes oficiales, libros y video si
   aplican, con advertencia de verificación (§10). **Toda fase cierra con
   esta sección antes del cierre narrativo**: ninguna fase se da por
   terminada sin su bloque de referencias propio, aunque repita fuentes
   comunes ya listadas en la semilla.
9. **🚀 Cierre y conexión con la siguiente fase** — qué sigue y por qué.
   Aquí va **La señal de que quedó bien**.

Los apéndices no siguen esta plantilla: usan índice de salto rápido +
secciones cortas + tabla "cuándo usar qué" + 5-10 ejercicios cortos + su
propio bloque breve de referencias si citan fuentes externas.

---

## 9. Ejercicios

- **Cantidad: 20 a 40 por fase**, salvo que la semilla justifique ajustarlo
  (ver nota de la semilla: sugerido ~30 para fases centrales).
- **Distribución equilibrada por nivel, con diversidad real de dificultad
  dentro de cada tramo** — no basta con etiquetar 🟢🟡🟠🔴; dentro de cada
  banda debe haber variación genuina (un 🟡 de "escribe un `MATCH` con un
  filtro" no es intercambiable con un 🟡 de "traduce esta consulta SQL a
  Cypher explicando la diferencia de costo"). Guía razonable para ~30: ~8 🟢,
  ~9 🟡, ~7 🟠, ~5-6 🔴, más los 🔥 aparte.
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
- **Progresión real.** Los 🟢 calientan (un `MATCH` simple, un filtro por
  propiedad); los 🔴 exigen integrar varias fases o depurar algo esquivo
  (medir un punto de quiebre, comparar grafo vs SQL a profundidad creciente,
  cerrar un ciclo sin control de visitados que cuelga).
- **Accionables y verificables.** "Detecta el anillo de profundidad 4 en el
  dataset semilla y verifica que coincide con el recall esperado" — no
  "reflexiona sobre los ciclos".
- **Al menos un puñado de diagnóstico por fase.** Se entrega un Cypher o un
  CTE que da resultado incorrecto o lento y se pide reproducir y localizar,
  no solo construir.
- **Enganchados al dominio.** Usan cuentas, transferencias, anillos,
  dispositivos, direcciones y teléfonos — nunca ejemplos abstractos tipo
  "nodo A, nodo B".
- **Cuando un ejercicio nombra código, usa el identificador en inglés
  vigente** ("escribe la función `detectRings`", "modela la etiqueta
  `Device`"), aunque el enunciado en sí esté en español, sin voseo.
- Los 🔥 son opcionales y se listan aparte, sin numeración continua.

En apéndices bastan 5-10 ejercicios cortos de consulta.

---

## 10. Bibliografía y referencias

**Regla:** documentación oficial vigente **primero**; luego libros; luego
blogs, videos y tutoriales. Siempre se advierte cuando un enlace apunta a
docs de una versión distinta a la fijada en el stack.

### 10.1 Formato

- **URLs completas y clicables**, no solo el dominio.
- **Cada fase cierra con su propio bloque de referencias** (sección 8 de la
  plantilla, §8), aunque repita fuentes comunes: Documentación oficial (con
  URL completa y nota de versión), Libros cuando apliquen, Video/apoyo
  (screencasts, charlas técnicas con URL completa), y **Orden de lectura
  sugerido** (una línea que encadena qué leer primero).

### 10.2 Fuentes oficiales por tema (usar URL completa al citar)

- **Neo4j (manual):** https://neo4j.com/docs/
- **Cypher (manual del lenguaje):** https://neo4j.com/docs/cypher-manual/current/
- **Neo4j Graph Data Science (GDS):** https://neo4j.com/docs/graph-data-science/current/
- **Memgraph (docs):** https://memgraph.com/docs
- **MAGE (algoritmos de Memgraph):** https://memgraph.com/docs/advanced-algorithms
- **Amazon Neptune (docs):** https://docs.aws.amazon.com/neptune/
- **PostgreSQL 18 — CTE recursivos:** https://www.postgresql.org/docs/18/queries-with.html
- **`neo4j-driver` (Node):** https://neo4j.com/docs/javascript-manual/current/
- **node-postgres (`pg`):** https://node-postgres.com/
- **Docker Compose:** https://docs.docker.com/compose/

### 10.3 Advertencias

- **Sobre citas:** cuando se mencione un artículo, libro, video o post
  específico, hay que dejar claro que URLs, títulos, números de página, DOIs
  e IDs de video pueden estar desactualizados o ser inexactos; el lector debe
  verificarlos antes de usarlos. No se inventan.
- **No usar en el código principal:** APIs de Neo4j anteriores a la línea
  CalVer vigente sin marcarlo, ni Cypher 3.x/4.x como referencia normativa
  (solo como nota histórica). No confundir **CouchDB** (curso 7 de la ruta,
  offline-first) con **Couchbase** (rival documental del curso 0): son
  motores distintos y esta guía no los menciona salvo para deslindarlos.

---

## 11. Sobre el dominio (sintético, sin datos reales)

El dominio de fraude de Telaraña es **enteramente sintético**: no hay cuentas,
transacciones ni personas reales, y no hay confidencialidad que preservar.
Esto simplifica dos cosas:

- Los ejemplos pueden ser todo lo concretos que convenga; no hace falta
  "generalizar ante la duda" ni anonimizar nada.
- El vocabulario del dominio (cuenta, transferencia, anillo, dispositivo,
  dirección, teléfono) es estable y se fija en el diccionario de este
  documento (§4.3); no compite con ningún vocabulario "real" que haya que
  evitar por NDA.

La regla de idioma del código (§4) es una convención de calidad y de
consistencia con producción, no una cuestión de confidencialidad.

---

## 12. Coherencia entre documentos

- **No contradecir fases anteriores.** Un fragmento de la Fase 7 no puede
  usar una etiqueta o tipo de arista distinta de la fijada en la Fase 1; el
  **esquema de grafo** (§dominio de la semilla) manda.
- **No reescribir decisiones aprobadas** sin señalar explícitamente la
  incompatibilidad y por qué.
- **Fuentes de verdad, en orden:** (1) instrucciones del proyecto de la Ruta
  NoSQL, (2) `RUTA-NOSQL.md` (lista maestra), (3) `RUTA-NOSQL-FUNDAMENTOS.md`,
  (4) `04-telarana-semilla.md`, (5) `TELARANA-ALCANCE.md`, (6) entregables
  aprobados de fases anteriores del curso, (7) decisiones explícitas del chat
  actual.
- Etiquetas de nodo, tipos de arista, propiedades, nombres de archivo y
  módulo se mantienen estables entre fases (en inglés, §4.4). Si algo se
  renombra, se documenta el cambio y se propaga a `BENCHMARKS.md` e
  `INSTINTOS.md`.

---

## 13. Checklist rápido antes de dar por cerrado un `.md`

- [ ] Sigue la plantilla de 9 secciones (o el formato de apéndice).
- [ ] Tono cálido e informal, segunda persona **sin voseo**, humor con
      moderación.
- [ ] Todo el código corre con las versiones fijadas en el stack de la
      semilla.
- [ ] **Etiquetas de nodo, tipos de arista, propiedades, nombres de archivo y
      script del código en inglés (§4).**
- [ ] **Comentarios de código y textos de salida del arnés en español (§4.5).**
- [ ] No contradice ninguna fase anterior ni el esquema de grafo fijado.
- [ ] Ningún "vs" se narra sin haber corrido `scripts/vs.ts` (§6).
- [ ] Usa el vocabulario de callouts (📝 🪦 📚 ⚠️ 💡) y los recuadros
      📖 🪞 🩻 ⚰️ donde aporten.
- [ ] Marca 💸 la deuda técnica (y la paga si corresponde) y 🔥 lo opcional.
- [ ] Tiene entre 20 y 40 ejercicios numerados con rangos 🟢🟡🟠🔴
      equilibrados **y con variación real de dificultad dentro de cada
      rango** (o 5-10 en apéndices).
- [ ] **Cierra con su propio bloque de referencias** (§10), con URL completa,
      nota de versión y advertencia de verificación — no solo remite a la
      semilla.
- [ ] Explica el *porqué* de cada decisión relevante.
- [ ] Incluye "La señal de que quedó bien" en el cierre.
