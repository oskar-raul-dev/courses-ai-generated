# 🗺️ NoSQL 2026 — Fundamentos y motivación

> **Documento suplementario de `01-ruta-nosql.md`.** Este documento no
> repite el índice de cursos (eso vive en el documento maestro): profundiza
> el **por qué** de cada modelo — la motivación, dónde gana de verdad frente
> a lo relacional, y el alcance de proyecto y stack que le corresponde. Es
> el punto de partida recomendado para arrancar una conversación nueva sobre
> cualquier curso de la ruta, sin tener que reconstruir la deliberación.

---

## 1. Introducción y motivación

Durante quince años, la conversación sobre bases de datos no relacionales
estuvo secuestrada por una pregunta mal planteada: **"SQL o NoSQL, ¿cuál es
mejor?"**. Es una pregunta sin respuesta porque compara una **arquitectura
completa y madura de 50 años** (el modelo relacional, con su álgebra, su
optimizador, sus garantías ACID) contra **una etiqueta de marketing** que en
2009 agrupó, bajo un mismo nombre, media docena de arquitecturas que no
tienen casi nada en común entre sí: un almacén de documentos, un grafo, una
tabla ancha column-family y un caché en memoria fueron todos "NoSQL" por
igual — como si "no ser un mamífero" fuera una clasificación biológica útil.

Esa etiqueta produjo una década de decisiones tomadas por moda en vez de por
análisis. Sistemas enteros de gestión de tickets, facturación o inventario
—dominios profundamente relacionales, con invariantes cruzadas y muchos-a-
muchos por todas partes— se construyeron en bases documentales porque "NoSQL
escalaba" o porque un líder técnico quería estar en la conversación
correcta. El resultado, quince años después, es el legacy que miles de
desarrolladores heredan hoy: sistemas que nunca debieron tener la forma que
tienen, operados por gente que no participó en la decisión original y que
tiene que **diagnosticar primero y arreglar después**.

Esta ruta nace de esa experiencia real — no de un ejercicio académico. El
primer curso de la ruta demostró, con mediciones y no con opiniones, que un
sistema tipo Jira construido en MongoDB por decisión de un líder que "quería
NoSQL" es, en rigor, un caso que **vota relacional 5 a 0**. Ese hallazgo no
es una crítica a MongoDB: es la prueba de que el problema nunca fue el
motor, fue la ausencia de un método para elegirlo.

**La motivación de esta ruta es construir ese método**, familia por familia,
y aplicarlo primero en la dirección contraria: encontrar, para cada modelo
no relacional, el dominio real donde **sí** gana — con la misma exigencia de
evidencia que se usó para diagnosticar cuando perdía. Un ingeniero que solo
sabe demoler malas decisiones ajenas es medio ingeniero. El otro medio es
saber tomar la decisión correcta desde el principio, y defenderla con
números cuando alguien —con buena o mala intención— la cuestione.

Y hay una segunda motivación, más pragmática: el panorama de 2026 ya no es
el de 2013. Categorías completas que no existían hace una década —búsqueda
vectorial para RAG, analítica embebida sin servidor, sincronización
offline-first como requisito de producto— son hoy parte estándar del kit de
un backend senior. No conocerlas no es un vacío teórico: es una limitación
profesional concreta, medible en qué proyectos se pueden o no abordar.

---

## 2. Objetivos de la ruta

1. **Sustituir "¿qué base es mejor?" por "¿qué modelo de acceso tiene mi
   dominio?"** — el único marco de decisión que sobrevive al cambio de
   producto, de versión y de moda.

2. **Construir criterio transferible, no memoria de sintaxis.** Cada curso
   enseña un modelo de acceso (clave-valor, columnar, vectorial, de grafo,
   wide-column, de búsqueda, sincronizado, temporal, distribuido con ACID) a
   través de un producto concreto — pero el objetivo es que el criterio
   sobreviva aunque el producto elegido desaparezca o sea reemplazado por
   otro. Redis puede dejar de existir; el modelo clave-valor con TTL y
   estructuras en memoria, no.

3. **Medir, nunca narrar.** Todo "esta base es mejor para X" que aparezca en
   la ruta debe estar respaldado por un benchmark ejecutado con el mismo
   arnés, sobre el mismo dominio, con los números a la vista. La ruta
   rechaza explícitamente los benchmarks de marketing de cualquiera de los
   dos bandos.

4. **Entender el costo de operar, no solo el de modelar.** Cada familia
   nueva que se adopta en un sistema real es una superficie operativa
   adicional: backups propios, guardia propia, curva de aprendizaje propia.
   La ruta obliga a nombrar ese costo en cada curso, para que la decisión
   final sea arquitectónica y no solo técnica.

5. **Producir criterio productizable, no solo académico.** Cada proyecto de
   la ruta se valida contra un mercado real existente (herramientas y
   empresas que resuelven ese mismo problema hoy), de modo que el
   aprendizaje quede anclado a una necesidad de negocio verificable y no a
   un ejercicio de laboratorio sin contraparte en el mundo real.

6. **Vacunar contra el fanboyismo en ambas direcciones.** Tan dañino es
   quien defiende lo relacional por costumbre sin medir, como quien adopta
   la base de moda sin medir. El villano recurrente de toda la ruta es
   siempre el mismo personaje: quien usa un motor donde no toca, en
   cualquiera de los dos sentidos.

---

## 3. Resumen de los modelos a estudiar y por qué importan

La ruta cubre nueve modelos de acceso genuinamente distintos, más un caso
fronterizo (NewSQL, que no es NoSQL pero completa el mapa del debate) y un
curso de cierre que no enseña un modelo nuevo sino el **costo de combinar
varios**.

| Modelo | En una frase |
|---|---|
| 🍃 Documental | agrupa por agregado: lo que se lee junto, se guarda junto |
| 🔑 Clave-valor | acceso O(1) por clave, en memoria, con expiración nativa |
| 🦆 Analítico embebido | analítica columnar sin servidor, sobre archivos, en tu propio proceso |
| 🧬 Vectorial | similitud semántica por distancia en espacios de alta dimensión |
| 🕸️ Grafo | la relación es un ciudadano de primera clase, no un JOIN |
| 🏛️ Wide-column | escritura masiva distribuida, modelada por consulta, no por entidad |
| 🔍 Búsqueda | relevancia, texto libre y facetas a escala, como problema de primera clase |
| 📴 Offline-first | el conflicto de sincronización como parte del modelo, no como excepción |
| ⏱️ Series temporales | el tiempo como eje de partición y compresión nativos |
| ⚡ NewSQL (frontera) | ACID transaccional con escalado horizontal — la promesa que originó el debate |

Cada uno de estos modelos resuelve **un problema que el modelo relacional
puede resolver, pero no fue diseñado para resolver bien**: no porque le
falte expresividad (SQL con extensiones modernas —JSONB, GIN, recursión,
window functions— es asombrosamente capaz), sino porque cada modelo
especializado codifica, en su estructura física, una suposición sobre el
patrón de acceso que el motor relacional debe simular con capas adicionales.
Un índice vectorial en Postgres funciona; un índice HNSW nativo, diseñado
desde el disco hacia arriba para ese propósito, escala mejor cuando el
volumen y la latencia exigida lo justifican. La ruta enseña exactamente
dónde está esa frontera, para cada modelo, con evidencia.

---

## 4. Los modelos, uno por uno

### 🍃 Documental

**Dónde se aplica en la realidad**
Catálogos de producto con atributos heterogéneos por categoría (electrónica,
moda, libros, alimentos, cada uno con su propio conjunto de campos), sistemas
de gestión de contenido, perfiles de usuario con forma variable, y en general
cualquier dominio donde la unidad natural de lectura y escritura es un
**agregado autocontenido** que rara vez necesita combinarse con otros para
responder una consulta.

**Por qué supera a lo relacional en esos escenarios**
El motivo no es de rendimiento puro: es de **alineación entre estructura de
datos y estructura de acceso**. Cuando una categoría de producto necesita un
atributo nuevo, un documento lo incorpora sin ceremonia; el equivalente
relacional honesto —una tabla por categoría, o el patrón Entity-Attribute-
Value que simula columnas dinámicas con una tabla `atributo/tipo/valor`— o
bien exige una migración de esquema por cada categoría nueva, o bien convierte
cada lectura de un producto completo en una unión de una docena de filas que
el motor relacional nunca fue optimizado para tratar como una sola entidad.
El documento no es "más flexible" en abstracto: es más flexible **en el
sentido preciso que este dominio necesita**, que es evolución de forma sin
coordinación central.

**Idea base del proyecto propuesto — Proteo**
Un catálogo de marketplace con verticales deliberadamente heterogéneas
(electrónica, moda, libros, alimentos), donde la heterogeneidad no es un
accidente del modelado sino el requisito explícito del producto. El curso
construye, en paralelo y desde la Fase 0, la misma solución en un motor
documental y en PostgreSQL con EAV y JSONB, midiendo cada capítulo con un
arnés de benchmark común, para que el veredicto final —documento gana el
catálogo, relacional gana la contabilidad y los pagos— quede sostenido por
números y no por preferencia.

**Tecnologías y por qué**
MongoDB como motor documental principal, por ser el estándar de facto de la
categoría y el que más terreno de comparación ofrece frente a lo relacional.
PostgreSQL con JSONB como el rival directo obligatorio, porque es la
refutación más seria que existe hoy al argumento "necesito un documento": si
Postgres con JSONB iguala el caso de uso, la elección de un motor documental
dedicado debe justificarse con algo más que "es más cómodo". Couchbase se
suma como segundo rival documental —memoria-first, con N1QL como lenguaje de
consulta tipo SQL sobre JSON— para que el curso no compare solamente
documento contra relacional, sino también documento contra documento, algo
que ningún curso anterior de la ruta cubre.

---

### 🔑 Clave-valor

**Dónde se aplica en la realidad**
Caché de aplicación, gestión de sesiones de usuario, limitación de tasa de
peticiones (rate limiting), colas de trabajo ligeras, contadores en tiempo
real, tableros de clasificación (leaderboards) de juegos y aplicaciones
sociales, y como capa de coordinación distribuida (locks, semáforos) delante
de un sistema más pesado.

**Por qué supera a lo relacional en esos escenarios**
Aquí la ventaja es física, no conceptual: los datos viven **en memoria**, la
estructura de acceso es una tabla hash o variantes de ella (sin índices B-
tree, sin optimizador de consultas, sin parser SQL de por medio), y el motor
ofrece estructuras de datos nativas —listas, conjuntos ordenados, mapas,
flujos— que un modelo relacional puede representar pero nunca con la misma
velocidad de acceso directo por clave. Cuando la pregunta es "¿cuál es el
valor asociado a esta clave, ahora mismo, en microsegundos?", cualquier capa
relacional de por medio —por bien indexada que esté— es trabajo de más. La
expiración nativa por clave (TTL) es, además, una primitiva que lo relacional
no tiene de fábrica y que este dominio necesita constantemente.

**Idea base del proyecto propuesto — Portalón**
Una puerta de entrada (gateway) de API que resuelve, con el mismo motor
clave-valor, cuatro problemas que normalmente se atacan por separado: límite
de peticiones por IP y por usuario, sesiones de autenticación con expiración,
una cola de trabajos diferidos, y un tablero de clasificación en vivo para
una funcionalidad de producto (por ejemplo, gamificación de soporte). El
objetivo pedagógico es que el estudiante vea las estructuras de datos nativas
del motor (no solo `SET`/`GET`) resolver, cada una, un problema distinto del
mismo sistema.

**Tecnologías y por qué**
Redis como referencia histórica e incumbente del modelo. Dragonfly como
alternativa moderna multi-hilo que promete compatibilidad de protocolo con
mejor aprovechamiento de máquinas multi-núcleo — el curso lo mide, no lo
asume. Valkey se incluye por una razón que trasciende lo técnico: es el fork
de la Linux Foundation nacido tras el cambio de licencia de Redis en 2024, y
entender ese episodio es tan parte de "aprender la familia clave-valor" como
entender `EXPIRE`. Elegir un motor hoy es también elegir una gobernanza.

---

### 🦆 Analítico embebido (columnar sin servidor)

**Dónde se aplica en la realidad**
Análisis exploratorio de datos sobre archivos (CSV, Parquet, JSON) sin
levantar infraestructura, reemplazo de flujos de trabajo basados en pandas
cuando el volumen de datos supera la memoria disponible cómodamente,
analítica embebida dentro de una aplicación o de un panel de control sin
depender de un almacén de datos externo, y procesamiento de datos en el
navegador para dashboards que no requieren backend.

**Por qué supera a lo relacional (y a las herramientas de análisis
convencionales) en esos escenarios**
La comparación relevante aquí no es tanto "documental contra relacional"
como "columnar contra por-filas". Un motor relacional transaccional
convencional almacena físicamente cada fila completa de forma contigua,
porque está optimizado para operaciones que tocan pocas filas pero muchas
columnas a la vez (el patrón de una transacción). Una consulta analítica hace
exactamente lo contrario: toca pocas columnas pero de muchísimas filas
(un `AVG` sobre una columna de precios en diez millones de registros). Un
motor columnar almacena cada columna de forma contigua y la procesa en lotes
vectorizados, evitando leer del disco cualquier columna que la consulta no
pidió. La diferencia no es una optimización incremental: es una decisión de
formato físico que hace que el mismo hardware resuelva la misma pregunta
analítica órdenes de magnitud más rápido, sin necesidad de un clúster.

**Idea base del proyecto propuesto — Cristalería**
Un pipeline de analítica que lee datasets públicos reales directamente en su
formato de origen (Parquet, CSV) sin proceso de carga previo (sin ETL),
ejecuta agregaciones y cruces que en herramientas convencionales exigirían
horas de procesamiento por lotes, y termina publicando un panel de control
que corre enteramente en el navegador, sin servidor de por medio, gracias a
la compilación a WebAssembly del propio motor.

**Tecnologías y por qué**
DuckDB como motor central del curso, por ser el estándar emergente de esta
categoría y el que mejor demuestra la propuesta de valor: cero servidor,
consulta directa de archivos remotos, integración nativa con los formatos de
la industria de datos. Se compara explícitamente contra pandas y Polars —no
como bases de datos, sino como la alternativa real que un equipo de datos
consideraría— para que el estudiante entienda cuándo escribir SQL sobre
archivos gana frente a escribir código de manipulación de dataframes.

---

### 🧬 Vectorial

**Dónde se aplica en la realidad**
Búsqueda semántica (encontrar documentos por significado, no por coincidencia
de palabras), sistemas de generación aumentada por recuperación (RAG) para
asistentes basados en modelos de lenguaje, motores de recomendación por
similitud de contenido, detección de duplicados y de contenido casi idéntico,
y memoria de largo plazo para agentes de inteligencia artificial.

**Por qué supera a lo relacional en esos escenarios**
El problema que resuelve este modelo —encontrar los k elementos más cercanos
a un punto dado en un espacio de cientos o miles de dimensiones— no tiene una
solución eficiente con los índices clásicos de un motor relacional (B-tree,
hash), porque esos índices están diseñados para igualdad y rangos en una o
pocas dimensiones ordenables, no para distancia en espacios de alta
dimensión donde la noción misma de "orden" deja de ser útil. Los índices
especializados de este modelo (HNSW, IVF) resuelven esa búsqueda por
aproximación, sacrificando exactitud perfecta por velocidad práctica —un
compromiso (recall contra latencia) que el motor relacional convencional
simplemente no ofrece como primitiva nativa.

**Idea base del proyecto propuesto — Oráculo de Bolsillo**
Un sistema de preguntas y respuestas sobre un conjunto de documentos propios
del usuario, donde cada respuesta debe venir acompañada de una cita
verificable a la fuente exacta que la sustenta —el requisito que distingue un
sistema RAG serio de uno que simplemente alucina con apariencia de fundamento.
El curso empieza deliberadamente **sin** un motor vectorial dedicado, usando
la extensión vectorial de Postgres, y solo migra a un motor especializado
cuando el propio benchmark del curso demuestre que el volumen o la latencia
lo justifican.

**Tecnologías y por qué**
pgvector como punto de partida obligado —la doctrina de la ruta es no sumar
un motor nuevo hasta que los números lo exijan—, Qdrant y Weaviate como
motores vectoriales dedicados que se evalúan cuando el caso lo pide, y
Pinecone como referencia del modelo gestionado (managed) para que el curso
también discuta el costo y la conveniencia de no operar la infraestructura
propia.

---

### 🕸️ Grafo

**Dónde se aplica en la realidad**
Detección de fraude mediante identificación de anillos de cuentas
relacionadas, motores de recomendación basados en relaciones sociales o de
comportamiento, gestión de identidades y permisos jerárquicos complejos,
análisis de redes de colaboración, y cualquier problema formulable como "el
camino más corto entre A y B" o "la comunidad a la que pertenece este nodo".

**Por qué supera a lo relacional en esos escenarios**
Este es el modelo que rompe de manera más radical los hábitos mentales de
quien viene de lo relacional, porque ataca directamente el punto más débil
de SQL: los recorridos de profundidad variable. Una consulta como "encuentra
todas las personas conectadas a esta persona en cuatro saltos o menos, a
través de cualquier tipo de relación" se expresa en SQL mediante consultas
recursivas (CTE recursivos) que crecen en complejidad y en costo de manera
poco manejable a medida que aumenta la profundidad del recorrido, porque cada
salto es, en esencia, un JOIN adicional sobre un conjunto de resultados que
no se conoce de antemano. Un motor de grafo almacena la relación misma como
una estructura física de primera clase —un puntero indexado entre dos
nodos—, de modo que atravesar una relación es una operación de costo
prácticamente constante, sin importar cuántos saltos de profundidad se
necesiten. La ventaja no aparece en un JOIN de dos tablas (ahí SQL gana sin
esfuerzo): aparece exactamente cuando la profundidad del recorrido es
variable y alta.

**Idea base del proyecto propuesto — Telaraña**
Un sistema de detección de fraude sobre un conjunto sintético de
transacciones financieras, donde el objetivo es identificar anillos de
cuentas que se transfieren dinero entre sí de forma circular o que comparten
señales indirectas de identidad (mismo dispositivo, misma dirección, mismo
patrón horario) sin estar conectadas de forma obvia y directa.

**Tecnologías y por qué**
Neo4j como referencia de la categoría y motor donde el lenguaje de consulta
(Cypher) fue diseñado desde el origen para expresar patrones de grafo de
forma legible. Amazon Neptune como representante del modelo gestionado en la
nube. Memgraph como alternativa orientada a grafos en memoria y procesamiento
en tiempo real, para contrastar el enfoque de persistencia en disco de Neo4j
contra un motor pensado para streaming de eventos sobre el grafo.

---

### 🏛️ Columnar ancha (wide-column)

**Dónde se aplica en la realidad**
Ingesta masiva de eventos de sensores (Internet de las Cosas), sistemas de
mensajería y series de actividad a escala de miles de millones de escrituras
por día, plataformas que necesitan escribir en múltiples centros de datos
geográficamente distribuidos con disponibilidad garantizada por encima de
consistencia inmediata, y en general cualquier sistema donde el volumen de
escritura hace que la coordinación central de un único motor relacional deje
de ser viable.

**Por qué supera a lo relacional en esos escenarios**
La diferencia de fondo es de filosofía de modelado, no solo de escala: en
este modelo, **se diseña una tabla por cada patrón de consulta**, aceptando
la duplicación de datos entre tablas como el precio necesario de que toda
lectura relevante pueda resolverse sin unir nada en el momento de la consulta
—porque a la escala de escritura para la que este modelo se diseñó, un JOIN
en tiempo de lectura sobre datos distribuidos en cientos de nodos es
sencillamente inviable. El modelo relacional normaliza primero y optimiza
después; este modelo desnormaliza por diseño, desde el primer día, guiado
exclusivamente por las preguntas que la aplicación va a hacer. Es también el
modelo que mejor ilustra que "escalar" en NoSQL casi siempre significa
renunciar a la flexibilidad de consulta ad-hoc a cambio de rendimiento
predecible en las consultas que sí se anticiparon.

**Idea base del proyecto propuesto — Centinela de Flota**
Un sistema de ingesta de telemetría para una flota de dispositivos o
vehículos, con agregaciones progresivas (roll-ups por minuto, hora y día) que
permiten consultar tendencias sin tener que recorrer los datos crudos, y con
un volumen de escritura simulado deliberadamente alto para que el estudiante
sienta la diferencia frente a un motor relacional bajo la misma carga.

**Tecnologías y por qué**
Cassandra como referencia histórica y más extendida del modelo, ScyllaDB
como reimplementación moderna en C++ compatible con el protocolo de
Cassandra pero con mejor aprovechamiento de hardware, y Bigtable como
referencia conceptual del modelo gestionado en la nube (sin operarlo
directamente, para entender su diseño sin el costo de una cuenta cloud
dedicada al curso).

---

### 🔍 Búsqueda de texto

**Dónde se aplica en la realidad**
Buscadores de comercio electrónico con filtros combinados (facetas),
buscadores de contenido editorial o documental con relevancia ajustada,
autocompletado tolerante a errores tipográficos, y cualquier sistema donde
la pregunta del usuario no es "dame el registro con este identificador exacto"
sino "dame lo más relevante para estas palabras, en este orden de
importancia".

**Por qué supera a lo relacional en esos escenarios**
La búsqueda de texto completo existe en los motores relacionales modernos
(índices GIN sobre `tsvector` en Postgres, por ejemplo) y para volúmenes
moderados es una solución perfectamente razonable. La ventaja de un motor
especializado aparece en tres frentes que el relacional no resuelve con la
misma naturalidad: el cálculo de **relevancia** como problema de primera
clase (con decenas de señales combinables —frecuencia de término, proximidad,
popularidad del documento— en vez de una coincidencia binaria), el cómputo de
**facetas** (conteos agregados por cada filtro disponible, recalculados en
cada búsqueda, sobre índices invertidos diseñados exactamente para eso), y la
**tolerancia a errores** (búsqueda difusa, fonética, de prefijos) como
funcionalidad nativa en vez de una extensión añadida. El patrón arquitectónico
que este modelo enseña, y que se repite en toda la ruta, es que este motor
casi nunca es la fuente de verdad: es un **índice derivado**, reconstruible
en cualquier momento a partir del sistema transaccional real.

**Idea base del proyecto propuesto — Buscafino**
Un servicio de búsqueda facetada reutilizable, con relevancia ajustable y
autocompletado tolerante a errores, sobre un corpus de datos realista (por
ejemplo, un catálogo de productos o un archivo documental), pensado y medido
explícitamente como alternativa más ligera y económica a las soluciones de
búsqueda gestionadas dominantes del mercado.

**Tecnologías y por qué**
Elasticsearch y OpenSearch como referencias del estándar de la industria (el
segundo, como fork abierto tras el cambio de licencia del primero — otro
episodio de gobernanza que la ruta no elude). Meilisearch y Typesense como
representantes de una generación más reciente de motores de búsqueda,
diseñados para ser mucho más simples de operar a cambio de un conjunto de
funcionalidades más acotado — el contraste que permite discutir cuándo la
potencia completa de Elastic se justifica y cuándo es sobre-ingeniería.

---

### 📴 Offline-first (sincronización)

**Dónde se aplica en la realidad**
Aplicaciones de trabajo de campo sin cobertura de red garantizada
(inspecciones, censos, ventas en terreno), aplicaciones móviles que deben
seguir siendo funcionales sin conexión y sincronizar al recuperarla,
herramientas colaborativas de edición local, y cualquier sistema distribuido
entre dispositivos que no pueden asumir una conexión constante al servidor
central.

**Por qué supera a lo relacional en esos escenarios**
La pregunta aquí no es de rendimiento sino de **modelo de consistencia bajo
desconexión**, un problema que el modelo relacional clásico —diseñado
alrededor de un único nodo autoritativo que arbitra cada transacción en el
momento en que ocurre— no contempla como caso normal de operación. Este
modelo trata el **conflicto de escritura concurrente sin coordinación previa**
como un evento esperado y de primera clase, no como una anomalía: cada nodo
puede escribir localmente sin preguntarle a nadie, y el protocolo de
sincronización se encarga de detectar y —según la estrategia elegida—
resolver automáticamente o exponer explícitamente los conflictos que
resulten cuando los nodos vuelven a verse. Es el único modelo de toda la ruta
donde la pregunta "¿qué pasa cuando dos personas editaron lo mismo sin
verse?" no es un caso límite a mitigar, sino el problema central que el
motor está diseñado para resolver.

**Idea base del proyecto propuesto — Bitácora de Campo**
Una aplicación de inspecciones que debe funcionar completamente sin señal de
red durante el trabajo de campo, almacenando localmente cada inspección
realizada, y sincronizar de forma bidireccional con el servidor central en
cuanto el dispositivo recupera cobertura, incluyendo el caso donde dos
inspectores modificaron el mismo registro mientras ambos estaban
desconectados.

**Tecnologías y por qué**
CouchDB junto con PouchDB (su contraparte para el cliente) como referencia
histórica y fundacional del modelo, con un protocolo de replicación diseñado
desde el origen para este propósito exacto. Firebase/Firestore como
representante del modelo gestionado y de mayor adopción comercial en
aplicaciones móviles. ElectricSQL como representante de una tendencia más
reciente que trae sincronización local-first a una base de datos relacional
convencional (Postgres), lo cual permite al curso preguntar si este modelo
seguirá necesitando un motor documental dedicado en el futuro o si la
sincronización terminará siendo una capacidad añadida a cualquier motor.

---

### ⏱️ Series temporales

**Dónde se aplica en la realidad**
Monitoreo de infraestructura y métricas de sistemas, sensores industriales y
de Internet de las Cosas, datos financieros de mercado, y cualquier dominio
donde cada registro lleva un timestamp y las consultas dominantes son sobre
ventanas de tiempo, tendencias y agregaciones temporales.

**Por qué supera a lo relacional en esos escenarios**
Los datos de series temporales tienen dos propiedades físicas que un motor
especializado explota y un motor relacional genérico no: son
**overwhelmingly de solo-escritura-y-lectura-por-rango** (casi nunca se
actualiza un dato histórico) y son **extremadamente comprimibles** cuando se
almacenan en el orden correcto, porque valores consecutivos en el tiempo
suelen ser similares entre sí. Un motor de series temporales particiona los
datos por tiempo de forma nativa (lo que permite descartar rangos completos
en una consulta sin siquiera abrirlos), aplica compresión especializada por
columna sobre esa cercanía temporal, y ofrece funciones de downsampling y
retención escalonada (conservar el detalle completo de la última semana, pero
solo promedios horarios de hace un año) como configuración de primera clase
en vez de un proceso de mantenimiento artesanal que alguien tiene que
programar y operar aparte.

**Idea base del proyecto propuesto — El Vigía**
Un sistema de monitoreo de métricas de infraestructura con política de
retención escalonada (resolución completa reciente, agregada a medida que
envejece) y downsampling automático, comparado explícitamente contra el
patrón de "cubo" (bucket pattern) que un motor documental sin soporte nativo
de series temporales obliga a construir a mano.

**Tecnologías y por qué**
InfluxDB como referencia dedicada de la categoría. TimescaleDB como
extensión de PostgreSQL que trae las capacidades de series temporales al
mundo relacional —la comparación más honesta posible contra "no necesitas un
motor nuevo, extiende el que ya tienes"—. Las colecciones de series
temporales nativas de MongoDB (disponibles desde la versión 5) como
referencia de que incluso los motores documentales generalistas terminaron
incorporando soporte de primera clase para este patrón de acceso, evidencia
adicional de que los modelos convergen con el tiempo.

---

### ⚡ NewSQL — el caso fronterizo

**Dónde se aplica en la realidad**
Sistemas financieros y de pagos que necesitan garantías transaccionales
completas (ACID) pero también escalado horizontal geográfico —el caso que,
históricamente, obligó a muchos equipos a elegir entre consistencia fuerte en
un solo nodo relacional o escalado horizontal sin transacciones completas en
un motor NoSQL.

**Por qué se incluye en una ruta NoSQL sin ser NoSQL**
No es un modelo no relacional: es, en rigor, la respuesta de la comunidad
relacional al desafío de escalado horizontal que motivó buena parte del
movimiento NoSQL en primer lugar. Se incluye aquí porque completa el mapa del
debate: demuestra que la disyuntiva original —"o tienes ACID en un solo nodo,
o escalas horizontalmente sin ACID completo"— ya no es una ley física
inevitable, sino una limitación de implementaciones concretas que la
siguiente generación de motores relacionales distribuidos superó. Entender
esta familia evita que el estudiante cierre el debate con una conclusión
desactualizada.

**Idea base del proyecto propuesto — Libro Mayor**
Un sistema de contabilidad de cuentas (ledger) con transacciones que
requieren consistencia fuerte incluso cuando los datos están distribuidos
entre regiones geográficas distintas — el caso de uso donde la promesa
específica de esta familia (ACID con escalado horizontal) se pone a prueba
de verdad.

**Tecnologías y por qué**
CockroachDB, TiDB y YugabyteDB como las tres implementaciones más
consolidadas de la categoría, comparadas en cómo cada una resuelve el
consenso distribuido y la latencia de las transacciones entre regiones.

---

## 5. El cierre de la ruta: persistencia políglota

El curso final de la ruta —**El Árbitro**— no enseña un modelo nuevo: enseña
la **factura** de haber aprendido los nueve anteriores. Su tesis es que, en
un sistema real de suficiente escala, la pregunta casi nunca es "¿qué motor
elijo?" sino "¿qué combinación de motores elijo, y estoy dispuesto a pagar el
costo operativo de esa combinación?". Cada motor adicional que un sistema
adopta implica una superficie operativa propia y completa: backups,
monitoreo, guardia, curva de aprendizaje del equipo, y un problema nuevo de
consistencia entre motores que antes no existía. El objetivo de este curso de
cierre es que la persistencia políglota deje de ser una palabra de moda para
convertirse en una decisión tomada con el mismo rigor —y el mismo respeto por
el costo— que cualquier otra decisión de arquitectura de la ruta.

---

## 6. Cómo continuar desde aquí

Este documento, junto con `01-ruta-nosql.md`, contiene todo el contexto
necesario para arrancar la redacción de cualquiera de los cursos de la ruta
en una conversación nueva, sin depender del historial de esta. Para
continuar: indicar qué curso de la lista se va a desarrollar primero, y
comenzar por su Fase 0 siguiendo el mismo esqueleto pedagógico común descrito
en el documento maestro (instinto falsable medido, lo que viaja intacto,
anti-patrón transversal con autopsia, diccionario de traducción, veredicto
honesto, `INSTINTOS.md` y `BENCHMARKS.md` acumulativos).
