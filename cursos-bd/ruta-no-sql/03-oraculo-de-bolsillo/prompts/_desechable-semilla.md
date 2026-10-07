# 🧬 Proyecto Oráculo de Bolsillo — Semilla del curso (Vectorial)

## 🎯 Motivación

El patrón de acceso que este curso enseña no es "buscar un registro por su
clave" ni "filtrar filas por un rango": es **encontrar los `k` elementos más
parecidos a uno dado, cuando el parecido vive en cientos o miles de
dimensiones**. Ese "parecido" es geométrico —distancia en un espacio de
embeddings— y no se reduce a una comparación de igualdad ni a un `LIKE` sobre
texto. Es el corazón de la búsqueda semántica, de los sistemas RAG que
alimentan asistentes con modelos de lenguaje, de la recomendación por
similitud de contenido y de la deduplicación de casi-idénticos.

El motor relacional puede resolverlo —de hecho, con la extensión adecuada lo
resuelve bien hasta un punto sorprendentemente alto— pero no fue **diseñado**
para hacerlo. Sus índices clásicos (B-tree, hash) codifican, en su estructura
física, la suposición de que los datos son ordenables en una o pocas
dimensiones: un B-tree te da rangos y prefijos baratos porque el orden total
existe y el árbol lo explota. En un espacio de 1.536 dimensiones esa suposición
se rompe: no hay un "orden" útil, la noción de vecindad deja de ser lineal, y
la maldición de la dimensionalidad hace que un escaneo exacto sea, a partir de
cierto volumen, la única opción honesta que un índice tradicional puede
ofrecer. Los índices especializados de este modelo —HNSW (un grafo navegable de
mundo pequeño) e IVF (particionado por celdas de Voronoi)— atacan el problema
por **aproximación**: renuncian a la garantía de encontrar el vecino exacto a
cambio de encontrar uno casi seguramente correcto en tiempo sublineal. Ese
compromiso —*recall* contra latencia, ajustable por parámetro— es una
primitiva nativa de este modelo que el motor relacional convencional
simplemente no expone.

Para un ingeniero senior que viene de años de SQL, dominar este modelo abre
proyectos que antes quedaban fuera de alcance o se resolvían mal: búsqueda por
significado en lugar de por palabra exacta, memoria de largo plazo para
agentes, RAG con recuperación medible. Y —tanto o más importante— apaga un
error de arquitectura que se paga caro en 2026: **montar un motor vectorial
dedicado, con su backup propio, su guardia propia y su curva de aprendizaje
propia, para un corpus que la extensión vectorial de una base que ya operas
resolvería de sobra**. La herramienta correcta que este curso suma a tu
criterio no es "un motor vectorial": es **saber en qué punto exacto —volumen,
latencia exigida, complejidad de filtrado— deja de alcanzar la solución barata
y empieza a justificarse la cara**. Y saberlo con números propios, no con el
benchmark de marketing de nadie.

---

## 🏗️ El dominio: un sistema RAG con citas verificables sobre documentos propios

**Oráculo de Bolsillo** es un sistema de preguntas y respuestas sobre un
corpus de documentos que aporta la propia persona usuaria (manuales, papers,
notas, un wiki interno, contratos, lo que sea). La persona pregunta en lenguaje
natural; el sistema recupera los fragmentos más relevantes de *sus* documentos,
se los pasa a un modelo de lenguaje como contexto, y devuelve una respuesta
**acompañada de citas verificables**: cada afirmación de la respuesta apunta al
fragmento exacto —documento, página o sección— que la sustenta.

Ese requisito de la cita verificable no es decorativo: es **la línea que separa
un RAG serio de un generador de texto que alucina con apariencia de
fundamento**. Y es también lo que fuerza el modelo de acceso vectorial de forma
natural, porque la pregunta operativa central del sistema es exactamente la que
el modelo resuelve: *"dado el embedding de esta pregunta, ¿cuáles son los `k`
fragmentos semánticamente más cercanos en el corpus, y de qué fuente exacta
proviene cada uno?"*.

### Por qué el dominio exhibe el patrón vectorial sin forzarlo

La unidad de trabajo del sistema es el **chunk**: un fragmento de documento
(unos cientos de tokens) con su texto, su embedding y su procedencia. La
pregunta del usuario también se convierte en un embedding. Responder es, en
esencia, un problema de vecindad en el espacio de embeddings: no hay clave por
la que buscar, no hay campo por el que ordenar, no hay JOIN que dé la
respuesta. Lo único que da la respuesta es la distancia. Un dominio donde la
consulta dominante es "lo más parecido a esto" es un dominio que pide un índice
de similitud, no un B-tree.

Al mismo tiempo, el sistema tiene una cara profundamente relacional que el
curso **no** esconde: los documentos, sus versiones, los permisos de acceso,
el registro de qué se citó en qué respuesta, la auditoría. Esa mitad vive
cómoda en tablas. El sistema real es un híbrido, y parte de la lección es
**dónde poner la costura** entre lo vectorial y lo relacional.

### Anatomía de un chunk (la entidad central)

| Campo | Tipo | Rol |
|---|---|---|
| `id` | uuid | identidad del fragmento |
| `documentId` | uuid | a qué documento pertenece (FK relacional) |
| `content` | text | el texto del fragmento (lo que se cita) |
| `embedding` | vector(N) | la representación semántica; el eje de búsqueda |
| `page` / `section` | int / text | procedencia fina, para la cita verificable |
| `tokenCount` | int | control de presupuesto de contexto |
| `chunkIndex` | int | orden dentro del documento |
| `createdAt` | timestamptz | versionado e invalidación de caché |

El `embedding` es el ciudadano nuevo. Todo lo demás lo sabes leer desde SQL. La
dimensión `N` depende del modelo de embeddings elegido (ver decisiones
pendientes); el curso la trata como parámetro, no como constante mágica.

### El marco de 5 preguntas, aplicado ANTES de modelar

| Pregunta | Respuesta en Oráculo de Bolsillo |
|---|---|
| **¿Qué se lee junto?** | El fragmento y su procedencia: texto + de dónde salió, para poder citar. Se lee por *similitud*, no por clave. |
| **¿Quién custodia la forma / las invariantes?** | La forma del `chunk` la fija la app en la ingesta; las invariantes duras (un chunk pertenece a un documento que existe; un documento tiene un dueño) son **relacionales** y viven en Postgres. |
| **¿Cuánto se une en caliente?** | Poco en el camino de búsqueda: primero se recupera por vecindad, luego se hidrata la procedencia. El JOIN pesado (permisos, versiones) queda fuera del *hot path* de similitud. |
| **¿Dónde viven las invariantes?** | En lo relacional (integridad referencial documento↔chunk, permisos). El índice vectorial es un **derivado reconstruible**, no la fuente de verdad. |
| **¿Qué pide la operación?** | Lectura por similitud con baja latencia (`p95` de la consulta ANN); escritura por lotes en la ingesta; evolución del corpus (re-embedding cuando cambia el modelo). |

**Veredicto honesto:** este dominio **no vota "vectorial 5-0"**. Vota algo más
interesante y más fiel a la realidad de 2026: **la búsqueda por similitud pide
un índice vectorial, pero no pide —todavía— un motor vectorial dedicado**. La
mitad de invariantes es relacional y el volumen de un corpus personal o de
equipo (miles a cientos de miles de chunks) cabe holgado en la extensión
vectorial de Postgres. El curso arranca deliberadamente ahí y sube la apuesta
solo cuando el cronómetro lo exige. El veredicto no es "usa vectorial"; es
"usa el índice vectorial más barato que cumpla tu SLA, y sabé medir cuándo deja
de cumplirlo".

### El villano del curso: el motor dedicado prematuro

El anti-patrón que este curso disecciona con autopsia medida es **montar
Qdrant, Weaviate o Pinecone para un corpus de 10.000 documentos que pgvector
resuelve de sobra**. Es el fanboyismo vectorial: el equipo que lee que "los
motores dedicados escalan a miles de millones de vectores" y concluye que su
wiki interno de 10k chunks necesita uno, sumando una superficie operativa
entera —otro servicio que respaldar, monitorear, actualizar y aprender— para
resolver un problema que la base que ya opera resolvía con una extensión y tres
líneas de SQL.

La autopsia del curso no lo afirma: lo **mide**. Corre la misma búsqueda contra
pgvector y contra el motor dedicado sobre el mismo corpus, con el mismo arnés,
y muestra en qué régimen de volumen y latencia el dedicado empieza a ganar de
verdad —y en cuál es puro costo operativo sin retorno. El villano tiene un
gemelo simétrico que el curso también nombra: **quedarse en pgvector cuando el
volumen o el filtrado ya piden a gritos un motor dedicado**, por pereza o por
orgullo relacional. El villano transversal de la ruta es el mismo de siempre:
usar el motor donde no toca, en cualquiera de las dos direcciones.

---

## 📐 Stack (2026, estable y moderno)

Todas las versiones fijadas abajo se verificaron como la última línea estable
a agosto de 2026; aun así, **confírmalas antes de arrancar la Fase 0** (las
líneas de parche se mueven semana a semana).

| Componente | Versión / elección | Rol |
|---|---|---|
| **PostgreSQL** | 18.6 | Base relacional y **primer motor vectorial** vía extensión. Custodia invariantes, documentos, permisos, auditoría. |
| **pgvector** | 0.8.x (tag 0.8.6) | Extensión vectorial de Postgres. El punto de partida obligado: HNSW e IVFFlat, `halfvec`, iterative scans para filtrado. |
| **Qdrant** | 1.19.x | Rival dedicado #1. Rust, Apache-2.0, ACORN para filtrado, cuantización binaria. Entra cuando el benchmark lo pide. |
| **Weaviate** | 1.37.x | Rival dedicado #2. Go, BSD-3, búsqueda híbrida nativa, módulos de vectorización. Contraste de filosofía frente a Qdrant. |
| **Pinecone** | API gestionada (serverless) | Referencia *managed*: qué cuesta y qué conviene NO operar tú. Se documenta y se mide contra latencia/costo, no se auto-hospeda. |
| **Node.js** | 24 LTS ("Krypton") | Runtime del servicio de API y del arnés. LTS activa hasta 2028. |
| **TypeScript** | 5.x (última estable) | Tipado del servicio, del cliente de cada motor y de `vs.ts`. |
| **Express** | 5.x | Capa HTTP del servicio de Q&A. Mínima y conocida. |
| **Python** | 3.13.x | Solo para el pipeline de **embeddings e ingesta** (donde el ecosistema de ML es más maduro). Verificar patch. |
| **Docker / Podman** | última estable | Todo contenerizado: cada motor es un servicio levantable con un comando. |
| **Modelo de embeddings** | a decidir (ver pendientes) | Convierte texto en vector. Local (p.ej. familia `bge`/`e5` vía `sentence-transformers`) o API. Decisión de Fase 0. |

### Por qué Postgres + pgvector como punto de partida, no como accesorio

La doctrina del curso es **no sumar un motor nuevo hasta que los números lo
exijan**. Postgres 18 con pgvector no es la rueda de auxilio: es el titular de
las primeras fases. Resuelve la búsqueda por similitud con HNSW, permite
combinar el filtro por metadatos y la vecindad en una sola consulta SQL (algo
que los dedicados hacen con más ceremonia), y —esto es decisivo— mantiene la
integridad referencial documento↔chunk en el mismo lugar donde vive la
respuesta. Un solo motor que respaldar, monitorear y operar. El curso migra a
un dedicado **solo** cuando su propio `vs.ts` demuestra que el volumen o la
latencia lo justifican.

### Por qué Qdrant y Weaviate como rivales dedicados (y no otros)

Se eligieron dos dedicados con filosofías distintas para que el "vs" no sea
"Postgres contra un dedicado" sino también "dedicado contra dedicado". **Qdrant**
(Rust, memoria-first, ACORN para filtrado con recall alto, cuantización
agresiva) representa la vía del rendimiento crudo y el control fino.
**Weaviate** (Go, híbrido léxico+vectorial nativo, módulos que vectorizan en la
ingesta) representa la vía de la plataforma integrada, donde la búsqueda
híbrida y la vectorización vienen de fábrica. Contrastar ambos enseña que
"motor vectorial dedicado" no es una categoría homogénea.

### Por qué Pinecone como referencia gestionada (documentada, no operada)

Pinecone entra para que el curso discuta explícitamente el eje que ningún motor
auto-hospedado ilumina: **el costo y la conveniencia de no operar la
infraestructura**. No se auto-hospeda (no se puede); se documenta su modelo
serverless y se mide su latencia y su costo por consulta como una opción real
que un equipo evaluaría. Es la respuesta medida a "¿y si no quiero operar
nada?".

### Por qué TypeScript en el servicio y Python en la ingesta

El servicio de Q&A y el arnés `vs.ts` van en **TypeScript sobre Node 24 LTS**:
es multiplataforma (Linux / macOS / Windows vía WSL), la audiencia lo tiene a
mano, y los clientes oficiales de los cuatro motores existen y están cuidados.
El pipeline de **embeddings e ingesta** va en **Python 3.13**, no por dogma
sino porque ahí el ecosistema de modelos de embeddings (`sentence-transformers`
y compañía) es el más maduro y el que menos fricción da. La costura entre
ambos es un contrato de datos simple (el `chunk` serializado), no un
acoplamiento. Ambos mundos corren contenerizados.

### Tooling transversal

Además de `scripts/vs.ts` (ver §siguiente), el curso incluye un **generador de
corpus sintético parametrizable** (número de documentos, tamaño de chunk,
dimensión del embedding, distribución temática) para poder correr los duelos a
distintas escalas sin depender de un dataset concreto, y una **capa de
validación** del contrato del `chunk` compartida entre el ingesta Python y el
servicio TypeScript.

---

## ⚖️ El método del "vs": un arnés, no anécdotas

`scripts/vs.ts` es el juez del curso. Toma un conjunto de consultas semánticas
(embeddings de preguntas reales sobre el corpus), las ejecuta **contra cada
motor en juego con la misma configuración de recall objetivo**, cronometra cada
una (latencia `p50`/`p95`/`p99`), mide el **recall real** contra un
*ground truth* de fuerza bruta, registra el costo de construcción del índice y
el uso de memoria, y **acumula todo en `BENCHMARKS.md`** con fecha, versión de
motor y parámetros. Nada de "Qdrant es más rápido": una tabla con números
reproducibles o no entra.

Regla dura: **ningún "X gana a Y" aparece en el curso sin una corrida de
`vs.ts` que lo respalde**, sobre el mismo corpus, con el mismo hardware, con
los parámetros a la vista. Los benchmarks publicados por los vendedores —de
cualquier bando— se citan solo para desmontarlos con medición propia.

Los duelos concretos que atraviesan el curso:

- **pgvector HNSW vs pgvector IVFFlat** — el primer "vs" es interno: elegir
  índice dentro de la propia extensión antes de mirar afuera.
- **pgvector vs Qdrant** — el duelo central del villano: ¿en qué volumen y con
  qué exigencia de latencia el dedicado empieza a ganar?
- **Qdrant vs Weaviate** — dedicado contra dedicado: rendimiento crudo vs
  plataforma híbrida integrada.
- **pgvector/Qdrant vs búsqueda híbrida (Weaviate)** — ¿cuánto aporta combinar
  señal léxica y vectorial frente a vectorial pura?
- **Auto-hospedado vs Pinecone (managed)** — el eje costo-operación: latencia y
  precio por consulta contra cero operación propia.

---

## 🌳 Estructura de fases

| # | Fase | Núcleo | "Vs" de la fase |
|---|---|---|---|
| 0 | Laboratorio y generador | Lab contenerizado, generador de corpus, nace `vs.ts` | — (se monta el juez) |
| 1 | Embeddings y el espacio | Qué es un embedding, distancias, dimensión, ingesta | Coseno vs L2 vs producto interno |
| 2 | pgvector, la vía barata | Chunk en Postgres, búsqueda exacta, primer RAG | Exacto (seq scan) vs índice |
| 3 | HNSW vs IVFFlat | Índices ANN dentro de pgvector, recall vs latencia | HNSW vs IVFFlat en pgvector |
| 4 | RAG con citas verificables | Recuperar → citar → generar; procedencia fina | Recuperación con/sin re-ranking |
| 5 | Filtrado y la costura híbrida | Filtro por metadatos + vecindad; dónde va la costura | Filtro-luego-ANN vs ANN-luego-filtro |
| 6 | El techo de pgvector | Escalar el corpus hasta que duela; medir el punto | pgvector a 10k / 100k / 1M chunks |
| 7 | Entra Qdrant | Primer motor dedicado; portar el corpus y el arnés | pgvector vs Qdrant, mismo corpus |
| 8 | Entra Weaviate y lo híbrido | Segundo dedicado; búsqueda híbrida nativa | Qdrant vs Weaviate; híbrido vs puro |
| 9 | Pinecone y el costo de no operar | Managed serverless; latencia y costo medidos | Auto-hospedado vs Pinecone |
| 10 | Producción del RAG | Re-embedding, versionado, invalidación, evaluación | Estrategias de re-indexado |
| 11 | ⚰️ Autopsia y ⚖️ veredicto | El villano bajo el bisturí; árbol de decisión | Recopilación de todos los duelos |

Once fases (0–11): entra en el rango pedido y da margen para que el villano se
construya despacio (fases 6–7 miden su fracaso) y se ejecute la autopsia al
final con datos acumulados de todo el curso.

### Fase 0 — Laboratorio contenerizado y generador de datos

Levanta el entorno completo con un comando: Postgres 18 + pgvector, y los
servicios de Qdrant y Weaviate ya declarados (aunque no se usen hasta más
tarde) para que estén listos. Se escribe el **generador de corpus sintético** y
nace el esqueleto de `scripts/vs.ts`. No se mide nada todavía: se monta el juez
y la mesa. 📖 Aquí abre el **diccionario de traducción** SQL→vectorial con sus
primeras entradas.

### Fase 1 — Embeddings y el espacio de alta dimensión

Qué es un embedding, por qué la distancia captura significado, qué es la
dimensión y por qué "más dimensiones" no es gratis. Se construye el pipeline de
ingesta (Python): documento → chunks → embeddings → filas. 🪞 Primer instinto
falsable: *"un índice sobre el vector me dará rangos baratos como un B-tree"*
—predicción, medición, veredicto—. 🩻 "Esto SÍ viaja igual": la selectividad,
el concepto de índice como estructura que evita el escaneo completo, el
`EXPLAIN`, siguen valiendo exactamente lo que valían en SQL.

### Fase 2 — pgvector, la vía barata primero

Se guarda el `chunk` con su `embedding` en Postgres y se hace la primera
búsqueda por similitud **sin índice** (exacta, fuerza bruta) para tener un
*ground truth* y sentir el costo. Primer RAG de punta a punta, todavía
lento pero correcto. 📖 Se amplía el diccionario con los operadores de
distancia (`<->`, `<=>`, `<#>`).

### Fase 3 — HNSW vs IVFFlat dentro de pgvector

El primer "vs" es **interno**: antes de mirar afuera, elegir bien el índice que
la extensión ya ofrece. Se construyen ambos, se mide recall contra latencia
contra costo de construcción con `vs.ts`, y se aprende a leer el compromiso.
🪞 Instinto: *"el índice aproximado me da siempre el mismo resultado que el
exacto"* —y no—. ⭐ Fase central: aquí se internaliza que recall es un dial, no
un booleano.

### Fase 4 — RAG con citas verificables

El requisito que define el producto: cada afirmación de la respuesta apunta a
su fragmento de origen. Se implementa recuperar → (re-rank opcional) → construir
contexto → generar → **atribuir**. Se discute cómo evitar la alucinación con
apariencia de fundamento. El "vs" mide el efecto del re-ranking sobre la
calidad de la recuperación.

### Fase 5 — Filtrado y la costura híbrida

Búsquedas que combinan "parecido a esto" **y** "que cumpla estos metadatos"
(este documento, este rango de fechas, este permiso). Aquí aparece el problema
clásico —el filtro que mata el recall— y las estrategias para resolverlo. 🪞
Instinto: *"filtro primero con un WHERE y busco vecindad después, como un
índice compuesto"* —y por qué ANN-con-filtro no funciona así—. Se decide **dónde
va la costura** entre lo relacional y lo vectorial.

### Fase 6 — El techo de pgvector (medir el punto de quiebre)

Se escala el corpus deliberadamente: 10k → 100k → 1M chunks, midiendo en cada
escalón la latencia `p95` y el recall de pgvector. El objetivo pedagógico es
**encontrar con números el punto donde la vía barata deja de cumplir el SLA**
—o demostrar que, para el corpus objetivo del producto, ese punto no se
alcanza—. ⚰️ Aquí empieza la autopsia del villano: se establece la evidencia de
cuándo el dedicado NO hace falta.

### Fase 7 — Entra Qdrant

Recién ahora, con la evidencia de la Fase 6 en la mano, entra el primer motor
dedicado. Se porta el corpus y se adapta `vs.ts` para que hable con Qdrant. El
duelo central: **pgvector vs Qdrant sobre el mismo corpus, mismo hardware,
mismo recall objetivo**. Se responde con números en qué régimen gana cada uno.
📖 El diccionario suma la jerga de Qdrant (collections, payload, points).

### Fase 8 — Entra Weaviate y la búsqueda híbrida

Segundo dedicado, filosofía distinta: se mide **Qdrant vs Weaviate** y, sobre
todo, **híbrido (léxico + vectorial) vs vectorial puro**. ¿Cuánto aporta de
verdad combinar BM25 con similitud? Se mide, no se asume. 🩻 "Esto SÍ viaja
igual": la señal léxica de BM25 es la vieja búsqueda de texto que el lector ya
conoce; no todo es nuevo.

### Fase 9 — Pinecone y el costo de no operar

Se documenta y se mide la opción **managed**: latencia y costo por consulta
contra la solución auto-hospedada. El "vs" no es solo de rendimiento sino de
**superficie operativa**: qué te ahorras y qué pagas por no operar nada.

### Fase 10 — Producción del RAG

Lo que separa un demo de un sistema: **re-embedding cuando cambia el modelo**,
versionado del corpus, invalidación de índices, y —crucial— **evaluación de
calidad de recuperación** (recall@k, MRR, nDCG sobre un set etiquetado). Un RAG
sin métrica de recuperación es fe, no ingeniería. El "vs" compara estrategias
de re-indexado (rebuild total vs incremental).

### Fase 11 — ⚰️ Autopsia del villano y ⚖️ veredicto honesto

Se pone al villano —el motor dedicado prematuro— sobre la mesa con todos los
números acumulados: se muestra el régimen donde fue puro costo y el régimen
donde se justificó. Se construye el **árbol de decisión** de cuándo NO usar un
motor vectorial dedicado (y, simétricamente, cuándo NO quedarse en pgvector).
Cierra `INSTINTOS.md` con el veredicto de cada instinto falsado en el curso.

### Apéndices

- **A) Arranque de motores vía contenedores.** Comandos para levantar Postgres
  18 + pgvector, Qdrant 1.19 y Weaviate 1.37 con un solo `up`, y cómo dar de
  alta credenciales de Pinecone.
- **B) `docker-compose` / `Containerfile` de trabajo.** El fichero real del
  laboratorio, comentado, con volúmenes persistentes y puertos (ojo con el
  6334 de Qdrant).
- **C) Guía rápida de MQL vectorial por motor.** Chuleta lado a lado: la misma
  búsqueda de vecindad en pgvector (SQL), Qdrant, Weaviate y Pinecone.
- **D) Generador de corpus sintético.** Parámetros, distribuciones temáticas,
  cómo fijar semilla para reproducibilidad.
- **E) Troubleshooting de setup.** Dimensiones que no coinciden, índice que no
  se usa (falta `ANALYZE`/parámetros de sesión), OOM al construir HNSW, el
  puerto gRPC de Qdrant, la migración de versión que no salta escalones.

---

## 📓 Artefactos acumulativos

**`INSTINTOS.md`** — un registro vivo de los instintos relacionales que el
curso pone a prueba. Cada entrada tiene la misma forma: el instinto redactado
tal como lo diría el lector ("un índice sobre el vector me da rangos baratos"),
la **predicción** que ese instinto implica, la **medición** que la confronta, y
el **veredicto escrito** (confirmado / recalibrado / falsado). Crece fase a
fase: la Fase 1 abre con el instinto del índice-como-B-tree; la 3, con el
aproximado-igual-al-exacto; la 5, con el filtro-primero; y así. En la Fase 11 se
relee entero como mapa de la recalibración completa.

**`BENCHMARKS.md`** — el libro de resultados. Todo "vs" del curso vive aquí,
generado por `scripts/vs.ts`, nunca escrito a mano. Cada tabla lleva fecha,
versión exacta de cada motor, hardware, parámetros de índice, corpus y su
tamaño, y las métricas (latencia `p50`/`p95`/`p99`, recall real, costo de
construcción, memoria). Crece con cada duelo: la Fase 3 deja la primera tabla
(HNSW vs IVFFlat); la 6, la curva de escalado de pgvector; la 7, el duelo
pgvector vs Qdrant; y la 11 las consolida en el veredicto. La regla es
inviolable: si un número no salió de una corrida reproducible de `vs.ts`, no
entra.

---

## 📚 Referencias por fase (semilla)

> ⚠️ **Todas las URLs, títulos e IDs de video de abajo deben verificarse antes
> de citarlos en el curso.** No se inventan números de página, DOIs ni
> identificadores de video. Cuando un enlace apunte a una versión distinta de
> la fijada en el stack, se advierte explícitamente.

**Fase 0 — Laboratorio y generador**
- Docker / Compose: https://docs.docker.com/compose/ · Podman: https://docs.podman.io
- pgvector (repo e instalación): https://github.com/pgvector/pgvector
- *Orden sugerido:* Compose → imagen de pgvector → levantar y verificar la extensión.

**Fase 1 — Embeddings y el espacio**
- pgvector, tipos y operadores: https://github.com/pgvector/pgvector#querying
- `sentence-transformers` (embeddings locales): https://www.sbert.net
- Video de apoyo (verificar): buscar una introducción reciente a "vector embeddings explained".
- *Orden sugerido:* qué es un embedding (conceptual) → distancias → ingesta práctica.

**Fase 2 — pgvector, la vía barata**
- pgvector, búsqueda exacta: https://github.com/pgvector/pgvector#getting-started
- PostgreSQL 18, `EXPLAIN`: https://www.postgresql.org/docs/18/sql-explain.html
- *Orden sugerido:* guardar vectores → búsqueda exacta → leer el plan.

**Fase 3 — HNSW vs IVFFlat**
- pgvector, índices: https://github.com/pgvector/pgvector#indexing
- Paper HNSW (Malkov & Yashunin, verificar DOI): "Efficient and robust approximate nearest neighbor search using HNSW graphs".
- *Orden sugerido:* IVFFlat (intuición de celdas) → HNSW (intuición de grafo) → medir el compromiso.

**Fase 4 — RAG con citas verificables**
- Documentación del proveedor de LLM que se use (verificar).
- Concepto RAG (paper original de Lewis et al., verificar): "Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks".
- *Orden sugerido:* recuperar → construir contexto → generar → atribuir.

**Fase 5 — Filtrado híbrido**
- pgvector, filtrado e iterative scans: https://github.com/pgvector/pgvector#filtering
- Qdrant, filtrado y ACORN (verificar): https://qdrant.tech/documentation/concepts/filtering/
- *Orden sugerido:* el problema del filtro que mata el recall → estrategias → dónde va la costura.

**Fase 6 — El techo de pgvector**
- pgvector, rendimiento y tuning: https://github.com/pgvector/pgvector#performance
- *Orden sugerido:* medir a 10k → escalar → encontrar el punto de quiebre.

**Fase 7 — Qdrant**
- Qdrant, documentación: https://qdrant.tech/documentation/
- Cliente JS/TS de Qdrant (verificar): https://github.com/qdrant/qdrant-js
- *Orden sugerido:* conceptos (collection/point/payload) → portar corpus → duelo.

**Fase 8 — Weaviate e híbrido**
- Weaviate, documentación: https://docs.weaviate.io
- Weaviate, búsqueda híbrida: https://docs.weaviate.io/weaviate/search/hybrid
- *Orden sugerido:* modelo de datos → híbrido → medir contra vectorial puro.

**Fase 9 — Pinecone**
- Pinecone, documentación: https://docs.pinecone.io
- *Orden sugerido:* modelo serverless → latencia → costo por consulta.

**Fase 10 — Producción**
- Métricas de recuperación (recall@k, MRR, nDCG) — fuente académica a verificar.
- *Orden sugerido:* evaluación → re-embedding → versionado e invalidación.

**Fase 11 — Autopsia y veredicto**
- Relectura de `BENCHMARKS.md` propio (la mejor referencia del curso es la
  medición acumulada).

**Común**
- MDN para JS base: https://developer.mozilla.org
- PostgreSQL 18 (manual): https://www.postgresql.org/docs/18/

---

## 🧪 Nota sobre ejercicios

Cada fase lleva entre **20 y 40 ejercicios** graduados 🟢🟡🟠🔴, con
**progresión real** (los 🟢 calientan; los 🔴 exigen integrar varias fases o
depurar algo esquivo) y **anclados al dominio** (chunks, corpus, citas,
recall, latencia — nunca ejemplos abstractos). Al menos un puñado por fase son
de **diagnóstico**: se entrega un bug (un índice que no se usa, un recall que
se desplomó tras un filtro, una dimensión que no cuadra) y se pide reproducir y
localizar, no solo construir.

Distribución sugerida para ~30 por fase: ~8 🟢, ~9 🟡, ~7 🟠, ~4–6 🔴, más los
🔥 opcionales listados aparte. Ejemplos de sabor por nivel: 🟢 "guarda 100
chunks y busca los 5 más cercanos a una pregunta"; 🟡 "mide recall@10 de tu
HNSW contra la fuerza bruta"; 🟠 "encuentra el punto de corpus donde pgvector
supera tu SLA de `p95`"; 🔴 "reproduce y arregla el filtro que hunde el recall
en la Fase 5, y demuéstralo con `vs.ts`".

---

## 🧩 Decisiones pendientes de confirmar antes de redactar la Fase 0

- [ ] **Dataset semilla.** ¿Corpus sintético del generador (por defecto,
  reproducible y sin dependencias) o un dataset público real (p.ej. un dump de
  documentación técnica)? *Propuesta por defecto:* generador sintético para los
  duelos + un corpus real pequeño para el RAG de la Fase 4, para que las citas
  se sientan reales.
- [ ] **Modelo de embeddings.** ¿Local (`bge`/`e5` vía `sentence-transformers`,
  sin coste ni red) o vía API? *Propuesta por defecto:* local para
  reproducibilidad y cero coste; dimensión fijada por el modelo elegido y
  tratada como parámetro.
- [ ] **Dimensión del vector.** Depende del modelo. *Propuesta:* fijar una
  dimensión moderada (p.ej. 768 o 1024) para que HNSW no sea caro de construir
  en el laboratorio; documentar cómo cambiaría con otra.
- [ ] **Cuándo entra cada rival.** Qdrant en Fase 7, Weaviate en Fase 8,
  Pinecone en Fase 9 (todos *declarados* en el Compose desde Fase 0). ¿Se
  adelanta alguno? *Propuesta:* mantener el orden; el retraso es pedagógico
  (primero se demuestra que no hacían falta).
- [ ] **Pinecone: ¿se implementa de verdad o se documenta como diseño?**
  *Propuesta por defecto:* implementación mínima real contra su free/serverless
  tier si es viable sin coste; si no, se documenta y se mide con datos
  publicados marcados como no reproducibles localmente.
- [ ] **Proveedor de LLM para la generación del RAG.** ¿Cuál, y se abstrae tras
  una interfaz para poder cambiarlo? *Propuesta:* abstraer siempre; el curso no
  depende de un proveedor concreto.
- [ ] **Formato exacto de fase.** ¿Se adopta la plantilla de 9 secciones de la
  guía de estilo tal cual, o se ajusta para el modelo vectorial? *Propuesta:*
  adoptarla, añadiendo los recuadros 🪞/🩻/⚰️/📖 donde el modelo lo pida.
- [ ] **Hardware de referencia para `BENCHMARKS.md`.** Fijar una máquina base
  (o un perfil de contenedor con límites de CPU/RAM) para que los números sean
  comparables entre fases.
- [ ] **Codas opcionales 🔥 Java y C++.** Existen como ampliación fuera del
  alcance base (ver §Consideraciones adicionales). ¿Se redactan completas desde
  el inicio, se dejan como apéndice al final del curso, o se sueltan sus
  ejercicios enganchados a la fase correspondiente (la de Java junto a la 7, la
  de C++ junto a la 3)? *Propuesta por defecto:* apéndice único "🔥 Fuera del
  ecosistema" al final, para no distraer el hilo principal, con punteros desde
  las fases 3 y 7.

---

## 💭 Consideraciones adicionales

### La nota especial del curso: empezar SIN motor dedicado

Este es el rasgo que define la pedagogía de Oráculo de Bolsillo y conviene
protegerlo de la tentación de "ir directo a lo interesante". El curso arranca
deliberadamente en pgvector y **solo migra a un motor especializado cuando su
propio benchmark demuestra que el volumen o la latencia lo justifican** (Fases
6→7). Esto no es un rodeo: es la lección central. Un curso que empezara con
Qdrant enseñaría a usar Qdrant; este enseña a **decidir** si Qdrant hace falta.
La secuencia "mide primero, migra después" es el antídoto contra el villano y
debe respetarse en la redacción de cada fase.

### Costo operativo del modelo (lo que se paga por adoptar un dedicado)

Cada motor vectorial dedicado que un sistema real adopta es una superficie
operativa completa: backups propios, monitoreo propio, guardia propia, curva de
aprendizaje del equipo, y un problema nuevo —la **consistencia entre el índice
vectorial y la fuente de verdad relacional**, que antes no existía porque
vivían en la misma base—. El curso obliga a nombrar ese costo en cada duelo:
"Qdrant gana 3× en latencia a 1M chunks" es media frase; la otra media es "a
cambio de un servicio más que operar y de re-sincronizar el índice cuando el
corpus cambia".

### Límites de la analogía con SQL

El lector viene de SQL y el curso honra ese instinto, pero hay tres puntos
donde la analogía se rompe y conviene señalarlos sin piedad: (1) el índice
vectorial es **aproximado** —no hay garantía de exactitud como en un B-tree—;
(2) el filtrado combinado con vecindad **no** se comporta como un índice
compuesto —filtrar primero puede vaciar el grafo HNSW de candidatos—; (3) el
índice vectorial casi nunca es la **fuente de verdad**, es un derivado
reconstruible, cosa que un índice relacional también es pero que aquí tiene
consecuencias operativas mayores (re-embedding, drift del modelo). 🩻 Lo que
**sí** viaja igual —selectividad, `EXPLAIN`, la idea de índice como atajo, el
coste de escritura del índice, el N+1— se reafirma para bajar la ansiedad.

### Validación contra un mercado real ({PRODUCTIZABLE}: ✅ Muy fuerte)

El proyecto se valida contra un mercado que existe y crece: RAG sobre
documentos propios es hoy una categoría de producto con múltiples actores
(asistentes de documentación, Q&A sobre bases de conocimiento internas,
buscadores semánticos empresariales). El diferenciador técnico defendible del
proyecto —**citas verificables**— es exactamente la característica que separa
un RAG confiable de uno que alucina, y es lo que un cliente empresarial exige.
Que el curso enseñe a construirlo **empezando por la opción barata y midiendo
cuándo escalar** es, además, justo el criterio que un equipo de producto real
necesita para no quemar presupuesto en infraestructura prematura. El
aprendizaje queda anclado a una necesidad de negocio verificable, no a un
ejercicio de laboratorio.

### Riesgos de la redacción

Dos riesgos a vigilar al escribir las fases: **(1)** que la parte de embeddings
y LLM se coma el curso y lo convierta en "un tutorial de RAG" en vez de "un
curso sobre el modelo de acceso vectorial" —el foco es el índice de similitud y
su decisión de arquitectura, el LLM es contexto—; y **(2)** que los duelos se
narren en vez de medirse, la tentación eterna. Cada afirmación comparativa
remite a una tabla de `BENCHMARKS.md` o no se escribe.

### 🔥 Coda opcional — Rehacerlo en Java

> 🔥 **Ampliación fuera del alcance base.** El curso se escribe en TypeScript
> (servicio) y Python (ingesta). Esta coda es para quien, ya terminada una
> fase, quiera **rehacer la misma pieza en Java** y sentir en carne propia la
> fricción de salir del ecosistema natural del stack. No es una vía alternativa
> del curso: es un laboratorio de criterio. El objetivo no es "Java es peor" ni
> "Java es mejor", es **nombrar con precisión dónde el ecosistema cobra peaje**.

Java no es un extraño en este mundo: Elasticsearch, Cassandra y buena parte de
la infraestructura de datos corren sobre la JVM, y los cuatro motores del curso
tienen cliente Java oficial o de comunidad. La fricción, entonces, no es de
capacidad sino de **impedancia con el resto del sistema**: el pipeline de
embeddings vive en Python porque ahí está `sentence-transformers`, y desde Java
llegar a un modelo de embeddings local significa o bien cruzar a Python por un
subproceso o un servicio, o bien cargar el modelo vía ONNX Runtime / DJL —más
control, más ceremonia—. Ahí está la primera lección medible: el costo de la
costura entre lenguajes.

Ejercicios de la coda (numeración propia, todos 🔥):

- 🔥🟡 Reescribe el **cliente de Qdrant** de la Fase 7 en Java y corre la misma
  búsqueda. Mide la latencia extremo a extremo y compárala con la del cliente
  TS en `BENCHMARKS.md`. ¿La diferencia es del lenguaje, del cliente, o del
  arranque de la JVM? Sepáralo.
- 🔥🟠 Porta el **arnés `vs.ts`** a un `Vs.java` que hable con pgvector y
  Qdrant. Documenta qué te costó más: la concurrencia, el manejo de conexiones,
  o serializar el `chunk`. El instinto de "la JVM es más rápida" ¿sobrevive a
  medir el `p95` incluyendo el *warm-up* del JIT?
- 🔥🟠 Implementa el **pipeline de ingesta** en Java con DJL u ONNX Runtime en
  lugar de `sentence-transformers`. Verifica que los embeddings producidos son
  numéricamente equivalentes a los de Python (misma dimensión, misma
  normalización) — un `chunk` embebido en Java debe poder buscarse contra uno
  embebido en Python o el contrato está roto.
- 🔥🔴 Diagnóstico: te entregamos un servicio Java que devuelve recall más bajo
  que su gemelo Python sobre el mismo corpus. Reprodúcelo y localiza la causa
  (pista: revisa el orden de bytes / la normalización del vector antes de
  indexar, no el índice).

### 🔥 Coda opcional — Rehacerlo en C++

> 🔥 **Ampliación fuera del alcance base.** C++ está más lejos todavía del
> ecosistema del curso, y por eso enseña más sobre la frontera. Es el lenguaje
> en el que están escritos los motores mismos (Qdrant es Rust, pero FAISS,
> hnswlib y buena parte de las librerías ANN de referencia son C++), así que la
> coda invita a bajar un nivel: no consumir un índice vectorial, sino **tocar
> la implementación del índice**.

Aquí la fricción cambia de naturaleza. En Java el peaje era la costura con el
resto del sistema; en C++ el peaje es que **desaparece la red de seguridad**:
sin cliente HTTP cómodo, sin serialización JSON gratis, sin gestor de
dependencias unánime, con la memoria a tu cargo. A cambio, obtienes algo que
ningún otro punto del curso ofrece: ver el algoritmo HNSW por dentro, sin un
motor que te lo esconda. Es la coda que mejor cierra el círculo del curso,
porque después de medir HNSW como caja negra en la Fase 3, aquí lo abres.

Ejercicios de la coda (numeración propia, todos 🔥):

- 🔥🟠 Usa **hnswlib** (C++) directamente para construir un índice HNSW sobre el
  mismo corpus de la Fase 3 y corre la misma consulta. Compara recall y latencia
  contra el HNSW de pgvector en `BENCHMARKS.md`. ¿Cuánto de la latencia de
  pgvector era el índice y cuánto era Postgres alrededor?
- 🔥🔴 Implementa a mano una **búsqueda de fuerza bruta** (k-NN exacto) en C++
  con SIMD sobre los embeddings, y úsala como *ground truth* para medir el
  recall de los índices aproximados del curso. Compárala con la fuerza bruta de
  la Fase 2 en SQL: ¿cuánto más rápido es el exacto bien vectorizado, y cambia
  eso el punto de quiebre que encontraste en la Fase 6?
- 🔥🔴 Lee el código de **construcción del grafo HNSW** en hnswlib y explica, en
  tus palabras, qué hacen `M` y `efConstruction` — los mismos parámetros que en
  la Fase 3 ajustabas a ciegas desde SQL. La coda cierra cuando esos dos
  números dejan de ser mágicos.
- 🔥🔴 Diagnóstico: te damos un binario C++ que segfaultea al indexar corpus de
  más de cierto tamaño. Reprodúcelo, localiza el desbordamiento (pista: revisa
  la reserva del buffer del grafo frente al número real de elementos) y arréglalo.
  Esta es la fricción de C++ que Java y TS te ahorraban: nadie te avisa.

> ⚖️ **La lección transversal de ambas codas.** Rehacer una pieza fuera del
> ecosistema no se hace para migrar: se hace para **cuantificar lo que el
> ecosistema te regalaba**. Cuando termines cualquiera de las dos codas,
> `BENCHMARKS.md` tendrá una fila más y `INSTINTOS.md` un instinto menos sin
> falsar — probablemente el de "el lenguaje más rápido hace el sistema más
> rápido", que en un sistema dominado por I/O de red y por el índice ANN casi
> nunca sobrevive a la medición.
