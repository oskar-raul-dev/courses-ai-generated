# 🗺️ Propuesta de fases y alcance
## Ruta NoSQL Lite — 26 fases, 6 bloques, 252 horas

> **Qué es este documento:** el temario. Qué fases hay, qué entra en cada una, cuántas
> horas y cuántos ejercicios. Es la fuente de verdad de la estructura del curso.
> **Precedencia:** por encima están [`alcance-del-proyecto.md`](alcance-del-proyecto.md) y
> [`guia-de-estilo-y-convenciones.md`](guia-de-estilo-y-convenciones.md). Por debajo, las
> plantillas y los prompts, que se actualizan después y nunca al revés.
> **Fecha:** 10 de septiembre de 2026

---

## ⏱️ 1. Reparto horario

**252 h ÷ 12 h semanales ≈ 21 semanas ≈ 5 meses.** A 10 h semanales, 25 semanas ≈ 6 meses.

Las horas de **apéndices no cuentan** dentro de las 252: son consulta bajo demanda. Los
**boss tampoco**: el de bloque y el global son opcionales y viven fuera del calendario.

| Bloque | Fases | Familias | Horas |
|---|---|---|---|
| **0 · El instrumento** | F00–F02 | — | 12 h |
| **I · Los dos que ya usas** | F03–F06 | documental, clave-valor | 40 h |
| **II · Leer de otra forma** | F07–F12 | analítico embebido, series temporales, búsqueda | 60 h |
| **III · Preguntas que no sabes escribir en SQL** | F13–F16 | grafos, vectorial | 40 h |
| **IV · Cuando el dato no cabe en un nodo** | F17–F22 | columnar ancha, offline-first, NewSQL | 60 h |
| **V · El árbitro** | F23–F25 | capstone políglota | 40 h |
| | **26 fases** | **10 familias** | **252 h** |

Cada minicurso de familia son **20 h en dos fases de 10 h**: la A levanta y modela, la B
rompe, mide y decide. El reparto es deliberadamente parejo —ninguna familia vale el doble
que otra a este nivel de profundidad—, y la calibración fina se hace con el número de
ejercicios, no con las horas.

### 1.1 Orden de aprendizaje contra orden de publicación

El orden de las fases es el **óptimo para aprender**. El de publicación es otro y el
README declara los dos: documental abre por ambos criterios, y **vectorial se adelanta al
tercer puesto** —por el arrastre de RAG y por su conexión con `tutorial-rag/`— aunque
pedagógicamente le tocara mucho más tarde.

El curso puede permitírselo porque los minicursos son casi independientes. **La única
atadura al orden canónico es el boss global**, y por eso es opcional.

---

## 🧱 2. La forma de un minicurso

Las dos fases de cada familia tienen un contrato fijo, y conviene tenerlo delante al leer
el resto del documento porque el detalle por fase solo dice **qué cambia**:

**Fase A — Levantar y modelar (10 h).** Motor arriba desde la receta de `a01`/`a02`; el
📖 diccionario de la familia y el 🩻 de lo que funciona igual que en relacional; el dominio
de flota modelado a la manera de la familia; el 🪞 *"tu instinto relacional dice… y esta
vez se equivoca"* con su medición; y la ⚰️ **situación 3** —modelaste bien la familia pero
como si fuera relacional— con números antes y después.

**Fase B — Romper, medir y decidir (10 h).** La 🪞 apuesta falsable escrita antes de
ejecutar; la 📐 medición contra Postgres; el 💥 punto de rotura con su mensaje literal; el
🚑 *"salir de aquí"* —índice, modelo, motor o arquitectura, en ese orden de coste—; las
cinco preguntas respondidas para esta familia; y el ⚖️ veredicto honesto.

---

## 🧭 3. Bloque 0 — El instrumento (12 h)

Sin este bloque, el curso son diez tutoriales de producto puestos en fila. Con él, es una
tesis con diez comprobaciones.

### 📜 F00 — La decisión que se hereda (4 h)

Las ⚰️ autopsias como gancho, y la tesis entera antes de tocar un contenedor.

**Qué entra:** las cinco autopsias del curso, con la estructura de §2.1 de la guía
—decisión, mejor argumento de quien la tomó, factura a los dos años, coste de salida—:
*"elegimos Mongo porque no queríamos joins"*, *"elegimos Cassandra porque escala"*,
*"metimos el JSON completo y listo"*, *Redis como almacén primario*, *Elasticsearch como
fuente de verdad*. Las dos situaciones —hype y zona de confort— presentadas como la misma
decisión tomada por el mismo motivo malo. Y el aviso de que **casi siempre gana Postgres**,
dicho en la primera fase y no al final.

**Qué NO entra:** ningún motor, ningún contenedor, ninguna medición. Esta fase se lee.

**La precisión que marca la casa:** Mongo **sí** tiene transacciones multi-documento desde
la 4.0. La autopsia honesta no es *"no había transacciones"*, es *"las había, exigían
réplica, y nadie las usó porque eligieron Mongo justamente para no pensar en eso"*. Y de
paso regala la primera entrada del catálogo de errores:
`Transaction numbers are only allowed on a replica set member or mongos`.

**Ejercicios: 12** (fase de criterio, exención declarada). De lectura y decisión: se
entregan esquemas y decisiones reales y se pide diagnosticar qué falló y por qué.

### 🚚 F01 — El dominio de flota y el arnés (5 h)

**Qué entra:** el dominio completo con sus nueve entidades; el generador de datos en
TypeScript con semilla determinista y los tres volúmenes (10 k, 1 M, rotura); el
`compose.yaml` maestro con perfiles por familia; Postgres arriba como línea base; y **cómo
se mide la forma** —viajes, examinados contra devueltos, particiones tocadas, fan-out,
amplificación— con el primer `EXPLAIN ANALYZE` del curso.

**Qué NO entra:** ningún motor NoSQL todavía. Solo Postgres y el arnés.

**Prueba de fuego:** el lector ejecuta el generador, carga 1 M de filas en Postgres, corre
la consulta de referencia y obtiene **el mismo número de filas examinadas que el
documento**. Si no coincide, el arnés está mal y el curso entero se cae.

**Ejercicios: 22.**

### ❓ F02 — Las cinco preguntas (3 h)

**Qué entra:** el instrumento de decisión completo —frontera transaccional, estabilidad de
las consultas, unidad de lectura, saltos de la relación típica, exactitud contra
parecido—, cada una con el modo de fallo que predice. Y el cierre que casi nadie escribe:
**"ya elegiste mal, ¿ahora qué?"**, el triaje de migración con 400 GB en producción y sin
poder parar el negocio — qué se migra primero, qué se deja, cómo se convive con dos bases
durante meses y cómo se mide que la migración va bien.

**Qué NO entra:** las respuestas por familia. Cada minicurso trae las suyas.

**Ejercicios: 12** (fase de criterio, exención declarada).

---

## 🍃🔑 4. Bloque I — Los dos que ya usas (40 h)

Documental y clave-valor: el default de todo el mundo y el modelo de acceso más puro. Es
donde viven las autopsias de la situación 1, y es el bloque que **solo por sí mismo ya es
un curso defendible**.

### 🍃 F03 — Documental: levantar y modelar (10 h) · MongoDB

**Qué entra:** la ficha de vehículo, que es polimórfica de verdad —dos vehículos del mismo
modelo no tienen los mismos campos—; embeber contra referenciar y la pregunta que lo
decide (unidad de lectura); índices sobre campos anidados y sobre arrays, con lo que eso
cuesta; el límite de 16 MB por documento y qué crece sin cota en este dominio; y el
`$lookup` con lo que de verdad hace por dentro.

**🪞 El instinto que falla:** *"normalizo, que para eso aprendí"*. La ficha referenciada
en cuatro colecciones necesita 3 + N viajes para una lectura que la embebida resuelve en
uno. Se mide.

**⚰️ La situación 3:** Mongo modelado con referencias por todas partes y el join escrito en
el código de la aplicación. Ahí se disolvió la frontera transaccional, y nadie lo anotó.

**Ejercicios: 26.**

### 🍃 F04 — Documental: romper, medir y decidir (10 h)

**🪞 Apuesta:** *"Postgres con JSONB y un índice GIN aguanta la misma consulta polimórfica
con un factor de degradación menor que 2× frente a Mongo"*. Se escribe antes.

**Qué entra:** la medición contra JSONB en las tres consultas del dominio; el documento que
crece sin cota —el historial embebido dentro del vehículo— y qué pasa al pasar de los 16
MB; las transacciones multi-documento, la exigencia de replica set y el error literal que
produce el standalone; y la actualización de un array anidado, que es donde el modelo
documental empieza a doler.

**💥 Punto de rotura:** el documento que no cabe. Volumen exacto, mensaje literal
(`BSONObjectTooLarge`), y qué se cambia para salir.

**⚖️ Veredicto:** cuándo NO usar documental — cuando la frontera transaccional cruza
agregados, cuando la unidad de lectura son rebanadas y no el agregado entero, y cuando tus
documentos tienen todos las mismas claves, que es la señal de que tienes una tabla cara.

**Ejercicios: 28.**

### 🔑 F05 — Clave-valor: levantar y modelar (10 h) · Valkey

**Qué entra:** sesiones del terminal del taller, rate limiting por técnico, el candado de
la orden de trabajo abierta, y una cola de trabajos pendientes; las estructuras que no son
strings —hash, set ordenado, stream— y cuándo cada una; TTL y expiración como parte del
modelo y no como limpieza; y **el modelo de acceso más puro que existe**: si no sabes la
clave, no hay consulta.

**🪞 El instinto que falla:** *"le pongo un índice secundario"*. No hay. Lo que hay es
escribir la segunda estructura tú mismo y mantenerla coherente a mano.

**⚰️ La situación 3:** Redis/Valkey usado como almacén primario. El día que se reinicia sin
persistencia configurada, o el día que la memoria se acaba.

**Ejercicios: 24.**

### 🔑 F06 — Clave-valor: romper, medir y decidir (10 h)

**🪞 Apuesta:** *"una tabla `UNLOGGED` de Postgres con la sesión indexada por clave llega a
menos de 3× la latencia de Valkey y me ahorra un componente entero"*.

**Qué entra:** la medición contra la tabla `UNLOGGED`; qué pasa cuando la memoria se llena
—`maxmemory`, las políticas de evicción y el error literal
`OOM command not allowed when used memory > 'maxmemory'`—; persistencia RDB contra AOF y
qué se pierde exactamente en cada una; y el coste operativo real de tener un componente
más en el diagrama.

**💥 Punto de rotura:** el dataset que no cabe en RAM, y la evicción silenciosa que se
lleva por delante datos que alguien creía persistentes.

**⚖️ Veredicto:** clave-valor es un **efecto, no una causa**. Se usa al lado de la fuente
de verdad, nunca en su lugar.

**Ejercicios: 26.**

> 💀 **Boss del Bloque I — "La avería duplicada".** Te entregan el sistema: catálogo en
> Mongo, sesiones y candados en Valkey. Una avería entró dos veces hace tres meses y nadie
> sabe cuándo ni por qué. Hay que reproducir la carrera, encontrar **qué frontera
> transaccional se disolvió** entre los dos motores y entregar un informe con la medición
> y el arreglo mínimo. Entregable: informe con comandos reproducibles.

---

## 🦆⏱️🔍 5. Bloque II — Leer de otra forma (60 h)

Tres familias que cambian **qué se lee y en qué orden**. El bloque abre con el contraste
más nítido que hay —por filas contra por columnas— y con el argumento más incómodo para la
etiqueta "NoSQL": **DuckDB habla SQL**.

### 🦆 F07 — Analítico embebido: levantar y modelar (10 h) · DuckDB

**Qué entra:** el tablero de costes por modelo, taller y trimestre; almacenamiento por
columnas contra por filas, con el diagrama y la aritmética; Parquet como formato de
intercambio; agregaciones sobre millones de filas sin servidor ni proceso aparte; y el
pivote —esa tabla ancha de `CASE WHEN` que todo el mundo ha escrito— hecho como se debe.

**🪞 El instinto que falla:** *"si habla SQL, es lo mismo que Postgres"*. No lo es, y el
número lo dice: agregar tres columnas sobre 200 millones de filas lee tres columnas aquí y
doscientos millones de filas allá. **La etiqueta no decide nada; el modelo de acceso sí.**
Es la tesis del curso demostrada con un contraejemplo que rompe la etiqueta.

**⚰️ La situación 3:** DuckDB tratado como base transaccional de una aplicación con varios
escritores concurrentes.

**Ejercicios: 24.** Entorno: **Python** (§9 del alcance).

### 🦆 F08 — Analítico embebido: romper, medir y decidir (10 h)

**🪞 Apuesta:** *"el `ALTER TABLE` de una métrica nueva sobre la tabla ancha de Postgres
cuesta un orden de magnitud más que añadir la columna en el modelo columnar"*.

**Qué entra:** la medición en columnas leídas contra filas leídas —la derrota estructural
de Postgres, que no depende de hardware ni de versión—; el `EXPLAIN` de DuckDB y qué
mirar; el dataset que no cabe en memoria y el spilling a disco; y la concurrencia de
escritura, que es donde esta familia deja de servir.

**💥 Punto de rotura:** dos procesos escribiendo el mismo archivo.

**⚖️ Veredicto:** analítico embebido cuando el dataset cabe en una máquina, cambia poco y
los lectores son decenas. Nunca como base de la aplicación.

**Ejercicios: 26.**

### ⏱️ F09 — Series temporales: levantar y modelar (10 h) · TimescaleDB

**Qué entra:** la telemetría a bordo —una lectura por sensor y por minuto y por vehículo—;
hypertables y particionado por tiempo; los roll-ups continuos de minuto a hora a día; las
políticas de retención y de compresión como **parte del modelo**, no como mantenimiento; y
por qué una restricción —los datos llegan en orden y no se actualizan— **se convierte en
rendimiento**.

**🪞 El instinto que falla:** *"una tabla con índice en la fecha ya es una serie temporal"*.
Lo es hasta que la tabla tiene mil millones de filas y hay que borrar el año pasado: un
`DELETE` contra un `DROP` de partición no se parecen en nada.

**⚰️ La situación 3:** series temporales que se actualizan. Cada corrección retroactiva
rompe la compresión y multiplica el coste.

**Ejercicios: 26.**

### ⏱️ F10 — Series temporales: romper, medir y decidir (10 h)

**🪞 Apuesta:** *"el particionado declarativo de Postgres a secas llega al 80 % del
rendimiento de Timescale y me ahorra una extensión"*. El rival aquí **es** Postgres, y ese
es justamente el punto.

**Qué entra:** medición de compresión —tamaño en disco antes y después— y de consultas por
rango; la cardinalidad que mata: qué pasa cuando cada vehículo × sensor es una serie
distinta; el backfill de datos históricos contra una hypertable comprimida; y el coste de
la retención mal configurada.

**💥 Punto de rotura:** la explosión de cardinalidad.

**⚖️ Veredicto:** series temporales cuando los datos llegan ordenados, no se actualizan y
se consultan por rango. Si alguna de las tres no se cumple, no es tu familia.

**Ejercicios: 26.**

### 🔍 F11 — Búsqueda: levantar y modelar (10 h) · OpenSearch

**Qué entra:** el catálogo de repuestos con sinónimos, equivalencias y tolerancia a
errores de tecleo; el índice invertido por dentro —analizadores, tokens, stemming— con el
diagrama; facetas y agregaciones; y el `mapping`, que es un esquema aunque se llame de
otra forma.

**🪞 El instinto que falla:** *"un `LIKE '%junta%'` ya busca"*. Busca, y escanea la tabla
entera, y no encuentra "juntas" ni "junta tórica" ni "junta torica" sin tilde.

**⚰️ La situación 3:** el motor de búsqueda como **fuente de verdad**. El día que se
reindexa y algo no estaba en ningún otro sitio.

**Ejercicios: 26.**

### 🔍 F12 — Búsqueda: romper, medir y decidir (10 h)

**🪞 Apuesta:** *"el full-text de Postgres con `tsvector` y un índice GIN cubre el 90 % de
este catálogo y nadie notará la diferencia"*.

**Qué entra:** la medición contra Postgres FTS en relevancia, en tolerancia a errores y en
facetas; el reindexado completo y cuánto dura con 1 M de documentos; el clúster que se
pone en solo-lectura por disco lleno, con su error literal
(`cluster_block_exception … read-only-allow-delete`); y la consistencia: cuánto tarda en
verse un documento recién escrito.

**💥 Punto de rotura:** el disco lleno y el índice en solo-lectura.

**⚖️ Veredicto:** búsqueda es **un índice, no una fuente de verdad**. Siempre al lado, y
siempre reconstruible desde otro sitio.

**Ejercicios: 28.**

> 💀 **Boss del Bloque II — "El tablero que nadie puede reconstruir".** El tablero de
> costes sale de DuckDB, las métricas de Timescale y el buscador de OpenSearch, y los tres
> discrepan en la misma cifra. Encuentra de dónde sale cada número, cuál es el correcto y
> **por qué los otros dos no lo son**. Entregable: un informe de reconciliación con la
> medición de cada camino.

---

## 🕸️🧬 6. Bloque III — Preguntas que no sabes escribir en SQL (40 h)

Dos familias que no compiten en rendimiento sino en **expresividad**: hay preguntas que en
relacional no es que salgan caras, es que no se escriben.

### 🕸️ F13 — Grafos: levantar y modelar (10 h) · Neo4j

**Qué entra:** el despiece —qué pieza va dentro de qué conjunto— y el *"si cambio esta
pieza, ¿qué más cae?"*; nodos, relaciones y propiedades, y por qué la relación es
ciudadana de primera; Cypher lo justo para el dominio; y la cardinalidad de travesía, que
es la medida que importa aquí.

**🪞 El instinto que falla:** *"eso es una tabla de adyacencia con un `JOIN` recursivo"*.
Lo es, hasta que la profundidad es desconocida de antemano.

**⚰️ La situación 3:** el grafo modelado como tablas —nodos genéricos con un campo "tipo" y
relaciones sin propiedades— que es exactamente perder lo único que el grafo te daba. Y el
producto cartesiano de Cypher, con su aviso literal.

**Ejercicios: 24.**

### 🕸️ F14 — Grafos: romper, medir y decidir (10 h)

**🪞 Apuesta, y es la que el curso espera perder en público:** *"el grafo gana a
`WITH RECURSIVE` a partir del cuarto salto"*. Se mide. **Postgres aguanta.** Se reconoce la
derrota, se publica el número, y *ahí* se sube la apuesta: lo que rompe no es descender un
árbol, es **buscar un patrón** — ciclos, caminos entre dos nodos cualesquiera, anillos,
profundidad variable y desconocida. Ese es el punto donde el grafo no es más cómodo, sino
que lo otro **no se puede escribir**.

**Qué entra:** la medición de travesía por profundidad contra `WITH RECURSIVE`; la consulta
de patrón, que es el argumento real; el grafo que no cabe en memoria; y el coste operativo
de mantener un motor más por una consulta al mes.

**💥 Punto de rotura:** la consulta sin límite de profundidad sobre un grafo con ciclos.

**⚖️ Veredicto:** el más honesto del curso. **Uno o dos saltos no justifican un grafo**, y
meter Neo4j para bajar cuatro niveles de un árbol de categorías es el anti-patrón que este
mismo curso declara.

> 💡 Este es probablemente el episodio de mayor confianza de toda la ruta, por la misma
> razón que lo fue el Dockerfile que no construía en el curso de Docker: **admitir que tu
> instinto falló vale más que diez mediciones favorables**, y te inmuniza contra la
> acusación de estar vendiendo motores.

**Ejercicios: 28.**

### 🧬 F15 — Vectorial: levantar y modelar (10 h) · Qdrant

**Qué entra:** *"¿qué avería se parece a esta?"* sobre los partes de avería en prosa, con
faltas y jerga de taller; qué es un embedding y qué no —sin entrenar nada—; distancia
coseno contra producto interno; el índice HNSW y sus dos parámetros que importan; y el
filtrado con metadatos, que es donde esta familia se vuelve útil de verdad.

**🪞 El instinto que falla:** *"esto es buscar con `LIKE` pero mejor"*. No: **es la primera
familia del curso que no devuelve la respuesta correcta, devuelve las parecidas**, y eso
cambia cómo se evalúa el resultado.

**⚰️ La situación 3:** vectorial usado para búsqueda exacta, donde un índice de toda la
vida gana por goleada y encima acierta.

**Ejercicios: 24.** Entorno: **Python** para los embeddings, TypeScript para el arnés.

### 🧬 F16 — Vectorial: romper, medir y decidir (10 h)

**🪞 Apuesta:** *"`pgvector` con HNSW aguanta 1 M de vectores con recall comparable, y me
ahorra el motor aparte"*. Es, de las diez, la familia **más defendible** — pero eso no
significa que el motor dedicado gane siempre.

**Qué entra:** la medición contra `pgvector` en recall contra velocidad —la métrica propia
de esta familia, y la trampa: se puede ser rapidísimo devolviendo basura—; el coste de
construir el índice; la memoria que ocupan 1 M de vectores y por qué; y la actualización
de embeddings cuando cambias de modelo, que es una reindexación completa.

**💥 Punto de rotura:** el índice que no cabe en RAM y el recall que se desploma al bajar
los parámetros para que quepa.

**⚖️ Veredicto:** vectorial cuando necesitas parecido y no exactitud. Para palabras clave,
la búsqueda exacta existe, es más barata y acierta más.

**Ejercicios: 26.**

> 💀 **Boss del Bloque III — "El técnico que ya vio esta avería".** Dado un parte de avería
> nuevo, hay que devolver las cinco intervenciones históricas más parecidas **y** las
> piezas que el despiece dice que podrían estar implicadas. Cruza grafo y vectores, y hay
> que justificar con medición por qué cada motor hace la mitad que hace.

---

## 🏛️📴⚡ 7. Bloque IV — Cuando el dato no cabe en un nodo (60 h)

El bloque más difícil, y va al final por eso: necesita todo lo anterior. Aquí la
restricción ya no es el modelado, es la **distribución**.

### 🏛️ F17 — Columnar ancha: levantar y modelar (10 h) · Cassandra

**Qué entra:** la telemetría cuando ya no cabe en un nodo; **modelar por consulta y no por
entidad**, que es el cambio de paradigma más grande del curso; partition key contra
clustering key y qué decide cada una; desnormalizar a propósito y mantener N tablas de lo
mismo; y el modelo de consistencia ajustable con quórum.

**🪞 El instinto que falla:** *"primero modelo el dominio y luego escribo las consultas"*.
Aquí es al revés, literalmente: **cada consulta nueva es una tabla nueva más un backfill**.
Eso no es un defecto, es el trato.

**⚰️ La situación 3:** Cassandra modelada por entidades, con `ALLOW FILTERING` puesto para
que la consulta "funcione". Funciona en la laptop con 10 k filas y se cae en producción.

**Ejercicios: 28.**

### 🏛️ F18 — Columnar ancha: romper, medir y decidir (10 h)

**🪞 Apuesta:** *"el particionado declarativo de Postgres cubre este caso hasta el volumen
al que llega esta empresa, y Cassandra solo empieza a ganar más allá"*.

**Qué entra:** la medición de particiones tocadas por consulta; el **hot spot** por
partition key mal elegida, provocado a propósito y medido; la amplificación de escritura y
las compactaciones; los tombstones y por qué borrar es lo más caro que puedes hacer aquí;
y `ALLOW FILTERING` con su mensaje literal y lo que de verdad cuesta.

**💥 Punto de rotura:** la partición que crece sin cota y el nodo que se cae por ella.

**⚖️ Veredicto:** columnar ancha cuando tienes escrituras masivas, consultas conocidas de
antemano y datos que no se actualizan. Si no conoces tus consultas, esta familia es una
trampa cara.

**Ejercicios: 28.**

### 📴 F19 — Offline-first: levantar y modelar (10 h) · CouchDB + PouchDB

**Qué entra:** la app del técnico en un taller sin cobertura; replicación bidireccional;
la revisión de documento como historia y no como versión; **conflictos: detectarlos,
resolverlos y decidir quién gana**; y qué es un CRDT y cuándo te ahorra escribir la
resolución a mano.

**🪞 El instinto que falla:** *"sincronizo cuando vuelva la conexión y ya"*. El conflicto no
es un caso de error: es el caso normal, y hay que diseñarlo.

**⚰️ La situación 3:** resolución de conflictos por "el último que escribe gana", que en
este dominio significa perder silenciosamente el trabajo del técnico que estuvo sin
cobertura toda la mañana.

**Ejercicios: 24.**

### 📴 F20 — Offline-first: romper, medir y decidir (10 h)

**🪞 Apuesta:** *"tres días desconectado con cien órdenes editadas sincronizan sin
intervención manual"*.

**Qué entra:** la medición del volumen de sincronización y del tamaño del historial de
revisiones; el conflicto masivo, provocado a propósito con dos clientes editando lo mismo;
la compactación de la base y qué se pierde; y el límite: qué tamaño de base local es
razonable en el terminal del taller.

**💥 Punto de rotura:** la sincronización que no converge.

**⚖️ Veredicto:** offline-first cuando tus usuarios trabajan de verdad sin conexión. Es la
familia con **el mayor coste de complejidad por unidad de beneficio** de todo el curso, y
hay que decirlo.

**Ejercicios: 24.**

### ⚡ F21 — NewSQL: levantar y modelar (10 h) · CockroachDB

**Qué entra:** el libro de órdenes de trabajo con talleres en tres regiones; **la síntesis
del curso**: SQL y ACID sobre un sistema distribuido, y qué cuesta eso exactamente; rangos,
réplicas y consenso sin misticismo; localidad de datos y por qué la geografía aparece en
el esquema; y el reloj, que es el problema de fondo de todo esto.

**🪞 El instinto que falla:** *"si habla SQL y es ACID, es Postgres con más nodos"*. Lo es,
hasta que una transacción cruza regiones y la latencia de la luz aparece en tu `COMMIT`.

**⚰️ La situación 3:** NewSQL con el esquema copiado tal cual de Postgres, sin pensar la
localidad, y cada transacción cruzando el Atlántico dos veces.

**Ejercicios: 26.**

### ⚡ F22 — NewSQL: romper, medir y decidir (10 h)

**🪞 Apuesta:** *"un Postgres de un nodo con réplica de lectura resuelve este caso a una
fracción del coste y de la latencia"*. Casi siempre es verdad, y esa es la lección.

**Qué entra:** la medición de latencia de commit por localidad —el único sitio del curso
donde el tiempo **sí** es el argumento, porque es física y no hardware—; la contención
sobre la misma fila desde dos regiones; el reintento de transacción, que aquí es parte del
modelo de programación; y el coste operativo y económico real.

**💥 Punto de rotura:** la transacción distribuida con contención alta.

**⚖️ Veredicto:** NewSQL cuando necesitas ACID de verdad sobre varias regiones. Si una
región basta, Postgres es más simple, más barato y más rápido.

**Ejercicios: 26.**

> 💀 **Boss del Bloque IV — "El taller de la montaña".** Un taller sin cobertura fiable,
> telemetría que sigue llegando y órdenes que se firman en tres regiones. Diseña el reparto
> —qué vive en el terminal, qué en la columnar, qué en el libro distribuido—, **provoca las
> tres roturas** del bloque y entrega el informe con las mediciones y las decisiones.

---

## ⚖️ 8. Bloque V — El árbitro: el capstone políglota (40 h)

No es un ejercicio final ni es opcional: es **la conclusión que el curso lleva prometiendo
cinco meses**. La forma honesta de casi toda situación 2 no es reemplazar, es añadir un
motor al lado **y pagar la factura de tenerlo**.

### ⚖️ F23 — El diseño: qué motor para qué parte (12 h)

**Qué entra:** el sistema de flota completo, pasado por las cinco preguntas parte por
parte; la decisión de qué motores entran de verdad y cuáles se descartan **con su razón
escrita**; dónde está la fuente de verdad, que es la decisión que ordena todas las demás; y
el diagrama del sistema con sus fronteras.

**🧠 La regla que ordena el bloque:** todo motor que no sea la fuente de verdad tiene que
ser **reconstruible desde ella**. Si no lo es, no es un índice: es una segunda verdad, y
tarde o temprano se contradice con la primera.

**Ejercicios: 22.**

### ⚖️ F24 — La costura: consistencia entre motores (14 h)

**Qué entra:** cómo se propaga una escritura de la fuente de verdad a los demás motores
—dual write y por qué casi siempre está mal, contra outbox y CDC—; la ventana de
inconsistencia, **medida**; la reconstrucción completa de un índice y cuánto dura; y qué
se hace cuando un motor secundario está caído.

**💥 Punto de rotura:** el dual write con un fallo parcial. Se provoca, se mide la
divergencia y se cuenta cuánto cuesta detectarla.

**Ejercicios: 26.**

### ⚖️ F25 — La factura y el veredicto final (14 h)

**Qué entra:** el coste operativo real de cinco motores —despliegue, monitoreo, backup,
actualizaciones, gente que sepa de cada uno—; el ⚖️ **árbol de veredicto honesto** completo
del curso, con las diez familias y sus "cuándo NO"; y el cierre que la ruta debe: **cuándo
todo esto era innecesario y bastaba con Postgres**, dicho con los números propios
acumulados durante cinco meses.

**La señal de que el curso quedó bien:** el lector es capaz de entrar a un design review y
**descartar motores con argumento**, no de proponerlos todos.

**Ejercicios: 24.**

> 🏆 **El boss global "El Taller" cierra aquí.** Quien lo haya seguido desde el Bloque I
> tiene el sistema entero funcionando y medido. Quien no, no ha perdido nada del curso: es
> opcional por diseño y el capstone se hace igual sin él.

---

## 📊 9. Resumen de fases

| # | Fase | Bloque | Horas | Ejercicios |
|---|---|---|---|---|
| 00 | La decisión que se hereda | 0 | 4 | 12 |
| 01 | El dominio de flota y el arnés | 0 | 5 | 22 |
| 02 | Las cinco preguntas | 0 | 3 | 12 |
| 03 | Documental: levantar y modelar | I | 10 | 26 |
| 04 | Documental: romper, medir y decidir | I | 10 | 28 |
| 05 | Clave-valor: levantar y modelar | I | 10 | 24 |
| 06 | Clave-valor: romper, medir y decidir | I | 10 | 26 |
| 07 | Analítico embebido: levantar y modelar | II | 10 | 24 |
| 08 | Analítico embebido: romper, medir y decidir | II | 10 | 26 |
| 09 | Series temporales: levantar y modelar | II | 10 | 26 |
| 10 | Series temporales: romper, medir y decidir | II | 10 | 26 |
| 11 | Búsqueda: levantar y modelar | II | 10 | 26 |
| 12 | Búsqueda: romper, medir y decidir | II | 10 | 28 |
| 13 | Grafos: levantar y modelar | III | 10 | 24 |
| 14 | Grafos: romper, medir y decidir | III | 10 | 28 |
| 15 | Vectorial: levantar y modelar | III | 10 | 24 |
| 16 | Vectorial: romper, medir y decidir | III | 10 | 26 |
| 17 | Columnar ancha: levantar y modelar | IV | 10 | 28 |
| 18 | Columnar ancha: romper, medir y decidir | IV | 10 | 28 |
| 19 | Offline-first: levantar y modelar | IV | 10 | 24 |
| 20 | Offline-first: romper, medir y decidir | IV | 10 | 24 |
| 21 | NewSQL: levantar y modelar | IV | 10 | 26 |
| 22 | NewSQL: romper, medir y decidir | IV | 10 | 26 |
| 23 | El diseño: qué motor para qué parte | V | 12 | 22 |
| 24 | La costura: consistencia entre motores | V | 14 | 26 |
| 25 | La factura y el veredicto final | V | 14 | 24 |
| | **Total** | | **252 h** | **636** |

Más **cinco boss de bloque** 💀 y el boss global 🏆, todos fuera del conteo.

---

## 📁 10. Convención de nombres

```
README.md
0-programa-del-curso.md
00-la-decision-que-se-hereda.md
01-el-dominio-de-flota-y-el-arnes.md
02-las-cinco-preguntas.md
03-documental-levantar-y-modelar.md
04-documental-romper-y-medir.md
05-clave-valor-levantar-y-modelar.md
06-clave-valor-romper-y-medir.md
07-analitico-levantar-y-modelar.md
08-analitico-romper-y-medir.md
09-series-levantar-y-modelar.md
10-series-romper-y-medir.md
11-busqueda-levantar-y-modelar.md
12-busqueda-romper-y-medir.md
13-grafos-levantar-y-modelar.md
14-grafos-romper-y-medir.md
15-vectorial-levantar-y-modelar.md
16-vectorial-romper-y-medir.md
17-columnar-levantar-y-modelar.md
18-columnar-romper-y-medir.md
19-offline-levantar-y-modelar.md
20-offline-romper-y-medir.md
21-newsql-levantar-y-modelar.md
22-newsql-romper-y-medir.md
23-poliglota-el-diseno.md
24-poliglota-la-costura.md
25-poliglota-la-factura.md
a01-laboratorio-contenerizado.md … a10-licencias-y-riesgo.md
INSTINTOS.md
bitacora-de-medicion.md
```

Dos dígitos en todo. Tags `fase-NN-<slug>`, prefijo de commit `fNN:`, ejercicios
`fNN ejM:`. Los boss de bloque llevan tag propio `boss-bloque-<N>`.

---

## 📌 11. Lo que esta propuesta deja pendiente

- **Las versiones y digests de los diez motores**, hasta la sesión de verificación de
  laboratorio. Viven en `a02` cuando se fijen.
- **Cassandra o ScyllaDB** en F17/F18: se decide midiendo cuál levanta con menos RAM en
  las tres plataformas.
- **El modelo de embeddings** de F15/F16, que condiciona `a06`.
- **Si el Bloque I se publica como entrega independiente** antes de tener el resto. La
  aritmética lo permite —son 40 h y cierran con su boss— y sería la forma barata de medir
  si hay audiencia antes de comprometer cinco meses.
