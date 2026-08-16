# 🔬 Análisis de los diez modelos
## Ruta NoSQL Lite — ¿alguno se puede sacrificar?

> **Qué es este documento:** la defensa —o la condena— de cada una de las diez familias del
> temario, escrita para contestar una pregunta concreta: **¿se puede acortar el curso
> quitando modelos, empezando por los que huelen a IA?** De cada familia dice qué enseña que
> ninguna otra enseña, cuánto te la vas a encontrar en el trabajo, en qué nichos vive de
> verdad y con qué lenguajes se toca.
> **Fecha:** 14 de septiembre de 2026
> **Precedencia:** por debajo de [`alcance-del-proyecto.md`](alcance-del-proyecto.md) y de la
> [guía de estilo](guia-de-estilo-y-convenciones.md). No redefine el temario: lo evalúa. Si
> alguna de sus recomendaciones se adopta, se cambia primero
> [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md) y este documento después.
>
> ⚠️ **Declaración de honestidad, porque este curso la exige.** En este documento **no hay
> una sola medición**. Todo lo que dice sobre adopción, tracción y madurez de ecosistema es
> **lectura de mercado y juicio de autor**, no dato ejecutado, y va declarado como tal aquí
> para no tener que repetirlo en cada párrafo. Las mediciones del curso viven en
> `bitacora-de-medicion.md` y ninguna de ellas sale de aquí.

---

## 1. 🧭 La pregunta que origina este documento

252 horas son cinco meses, y la tentación evidente de acortarlas es quitar familias. La
sospecha razonable es que sobre alguna de las "modernas" —vectorial, la que suena a IA— y
que el curso quede igual de útil con nueve minicursos, o con ocho.

La respuesta corta es que **no sobra ninguna, y vectorial es justamente la peor candidata
de las diez**. La respuesta larga es este documento, y termina con algo mejor que un
recorte: **las palancas que bajan el curso un 17 % sin quitar una sola familia** (§4).

### 1.1 El criterio con el que se juzga cada familia

Tres filtros, y hay que pasar los tres para quedarse:

1. **¿Responde una pregunta del instrumento que ninguna otra responde?** Las cinco preguntas
   de §5 del alcance son la columna vertebral del curso. Una familia que no aporta una
   respuesta propia a ninguna de ellas es decoración, por interesante que sea el producto.
2. **¿Produce una comparación falsable contra Postgres que enseñe algo?** Si la línea base
   gana siempre y sin matices, el minicurso se resuelve en un párrafo del veredicto final.
   Si gana el motor siempre y sin matices, es propaganda.
3. **¿El lector se lo va a encontrar?** Heredado, propuesto en una reunión, o metido en el
   stack por alguien que se fue. La adopción de mercado importa, pero **encontrárselo importa
   más que elegirlo**: la mitad del valor del curso es poder desmontar una propuesta.

Ese tercer filtro tiene una consecuencia incómoda que conviene decir ya: hay familias que
entran **no porque las vayas a usar, sino porque las vas a tener que rechazar con
argumento**. Grafos es el caso puro, y es además la familia donde el curso pierde su
apuesta en público. Quitarla por baja adopción sería quitar el mejor episodio de la ruta.

---

## 2. 📋 Las diez fichas

### 🍃 2.1 Documental — MongoDB contra Postgres JSONB

**Pregunta del instrumento:** la 3, **unidad de lectura**. ¿Lees el agregado entero o
rebanadas de muchos agregados? Y de rebote la 1, porque es la familia donde más gente
disuelve la frontera transaccional sin enterarse.

**Qué enseña que ninguna otra enseña.** Embeber contra referenciar, que es la decisión de
modelado más repetida de toda la industria, y la lección que la sostiene: **el esquema no
desapareció, se mudó al código y dejó de estar documentado**. Es también donde se aprende a
leer un `explain` de verdad —examinados contra devueltos— antes de necesitarlo en motores
más raros.

**Refrescamiento profesional.** Máximo, y por frecuencia de encuentro más que por elección:
es el default del mundo y el peor entendido de los diez. Aunque nunca elijas Mongo, vas a
heredar uno. Y desde que JSONB existe, la decisión "documento o tabla" aparece **dentro** de
Postgres, así que la lección se usa sin cambiar de motor.

**Nichos donde vive.** Catálogos de producto y PIM, gestores de contenido, perfiles de
usuario, payloads de auditoría y eventos, e integraciones donde el tercero manda un JSON que
tú no controlas.

**Stacks.** Node/TypeScript es su casa histórica —el ecosistema MEAN/MERN, Mongoose como ODM
de facto— y sigue siendo donde más se escribe. Después Python (PyMongo y su versión
asíncrona), Java con Spring Data, C# y Go. El documental **dentro** de Postgres se toca desde
cualquier cliente SQL, que es parte de su gracia.

**Veredicto: intocable.** Abre el curso por los dos criterios y es la mitad del Bloque I, que
es la entrega mínima defendible de la ruta.

### 🔑 2.2 Clave-valor — Valkey contra una tabla `UNLOGGED`

**Pregunta del instrumento:** la 3 llevada al extremo. Si no sabes la clave, no hay consulta.
Es el modelo de acceso más puro que existe y por eso es el mejor sitio para entender qué
significa "modelo de acceso".

**Qué enseña que ninguna otra enseña.** Que una restricción puede ser una función y no una
carencia. El TTL como **parte del modelo** y no como tarea de limpieza. Y la que más duele:
aquí no hay índice secundario — hay una segunda estructura que escribes tú y mantienes
coherente a mano, con todo lo que eso implica el día que se desincroniza.

**Refrescamiento profesional.** Máximo. Redis está en casi todas las arquitecturas que vas a
tocar y casi nadie ha pensado qué pasa el día que la memoria se acaba y la evicción se lleva
por delante algo que alguien creía persistente. Y hay una razón extra, de esas que no son
técnicas y deciden igual: **la licencia movió el suelo** y el ecosistema se partió. Saber por
qué el curso usa Valkey es parte del refresco.

**Nichos donde vive.** Sesiones, rate limiting, caché, colas de trabajo, candados
distribuidos, leaderboards, banderas de funcionalidad, claves de idempotencia y difusión a
WebSockets.

**Stacks.** Todos, literalmente. Node (`ioredis`, `node-redis`), Python (`redis-py`), Java
(Lettuce, Jedis, Spring Data), Go, .NET, Rust. Y **Lua del lado del servidor** para lo que
tiene que ser atómico, que es el pedazo que casi nadie ha escrito nunca y que este curso sí
toca.

**Veredicto: intocable.**

### 🦆 2.3 Analítico embebido — DuckDB contra Postgres

**Pregunta del instrumento:** la 3 en su forma más nítida. ¿Lees filas enteras o rebanadas de
columnas? El contraste por filas contra por columnas es la aritmética más limpia del curso.

**Qué enseña que ninguna otra enseña.** **Que la etiqueta no decide nada.** DuckDB habla SQL,
así que rompe el marco "NoSQL" desde dentro y demuestra la tesis del curso con un
contraejemplo en vez de con un argumento: lo que cambia el resultado no es el lenguaje ni la
etiqueta ni el producto, es el modelo de acceso. Es la fase con **más apalancamiento
pedagógico por hora** de toda la ruta.

**Refrescamiento profesional.** El que más ha subido de los diez. Cambia un reflejo caro
—"esto necesita un warehouse"— por una pregunta barata: ¿cuánto ocupa de verdad el dato? Un
proceso sustituye a un clúster en muchísimos más casos de los que la industria admite.

**Nichos donde vive.** Análisis exploratorio local, tableros embebidos, ETL que cabe en una
máquina, lectura directa de Parquet en almacenamiento de objetos, notebooks, sustituir pandas
por SQL sobre datos que no caben en memoria, y ejecución en la propia pestaña del navegador.

**Stacks.** Python manda con diferencia, por el ecosistema de Arrow, pandas y Polars, más
`dbt-duckdb` para quien viene de transformación. Después la CLI de SQL a secas, que es como
se usa la mitad de las veces. También R, Java, Node y la compilación a WebAssembly.

**Veredicto: intocable — y si algo hubiera que ampliar, sería esto.** Es la familia que
convierte el curso en una tesis en vez de en un catálogo.

### ⏱️ 2.4 Series temporales — TimescaleDB contra Postgres particionado

**Pregunta del instrumento:** la 2 —consultas conocidas y estables— más una propia que el
curso instala aquí: **¿tus datos llegan ordenados y no se actualizan nunca?**

**Qué enseña que ninguna otra enseña.** Que **una restricción se convierte en rendimiento**:
si aceptas que los datos llegan en orden y no se corrigen, te ganas compresión, retención por
`DROP` de partición y roll-ups baratos. Y la cardinalidad como disciplina explícita, que es
el modo de fallo que tumba estos sistemas y que nadie ve venir.

**Refrescamiento profesional.** Alto en IoT, observabilidad, energía y datos de mercado. Tiene
además una propiedad que ninguna otra familia del curso comparte: como es una **extensión de
Postgres**, casi todo lo que aprendes sigue sirviendo aunque nunca la instales, porque el
particionado declarativo y la compresión son conversaciones que vas a tener igual.

**Nichos donde vive.** Telemetría industrial y vehicular, métricas de infraestructura y de
negocio, series financieras, medición energética, sensores.

**Stacks.** Cualquier cliente de Postgres, que es la mitad de su argumento comercial. La
ingesta suele escribirse en Go, Python, Java o Rust por volumen, y Grafana es la capa de
visualización de facto.

**Veredicto: no sacrificable** — pero es la mitad de la única redundancia real del temario,
y esa sí se puede comprimir (§4.2).

### 🔍 2.5 Búsqueda — OpenSearch contra Postgres FTS

**Pregunta del instrumento:** la 5, **exactitud contra parecido**, en su versión léxica. Y la
2, porque un `mapping` es un compromiso con tus consultas futuras aunque no se llame esquema.

**Qué enseña que ninguna otra enseña.** El índice invertido por dentro —analizadores, tokens,
stemming, sinónimos— y la regla que más gente rompe en producción: **un índice de búsqueda no
es una fuente de verdad**. Siempre al lado, siempre reconstruible desde otro sitio. El día que
se reindexa y algo no estaba en ningún otro lugar, esa lección vale el curso entero.

**Refrescamiento profesional.** Altísimo por frecuencia: todo producto con catálogo termina,
tarde o temprano, en una reunión que empieza con *"la búsqueda es mala"*. Y la decisión real
casi nunca es qué motor, sino **si hace falta un motor**, que es exactamente lo que el
minicurso mide contra `tsvector`.

**Nichos donde vive.** E-commerce y catálogos, logs y observabilidad, búsqueda documental
interna, el buscador de cualquier SaaS, y últimamente la mitad léxica de las arquitecturas de
búsqueda híbrida.

**Stacks.** Es JSON sobre HTTP, así que se toca desde cualquier lenguaje. El ecosistema
histórico y las entrañas son JVM; los clientes más usados en la práctica son los de Python y
JavaScript; la ingesta suele venir de Logstash, Fluent Bit o Vector.

**Veredicto: intocable.**

### 🕸️ 2.6 Grafos — Neo4j contra `WITH RECURSIVE`

**Pregunta del instrumento:** la 4, **cuántos saltos tiene tu relación típica** — y el matiz
que la vuelve útil: ¿conoces la profundidad de antemano?

**Qué enseña que ninguna otra enseña.** La diferencia entre **descender un árbol** —que
Postgres aguanta mucho más de lo que el instinto dice— y **buscar un patrón** de profundidad
desconocida: ciclos, anillos, caminos entre dos nodos cualesquiera, identidad indirecta. Lo
primero sale caro en SQL; lo segundo **no se escribe**. Esa distinción es el contenido de más
valor del curso y no está bien explicada en casi ningún sitio.

Y algo que no es contenido sino estructura: **es la familia donde el curso pierde su apuesta
en público.** La pérdida está declarada de antemano en `formato-bitacora-de-medicion.md` §3.3
y es lo que inmuniza a la ruta contra la acusación de estar vendiendo motores. Quitar grafos
por baja adopción sería quitar el episodio que más credibilidad produce.

**Refrescamiento profesional.** Adopción directa baja, **valor de criterio altísimo**. Es, con
diferencia, la familia que más se propone mal: alguien ve una jerarquía de cuatro niveles y
pide Neo4j. Saber decir que no —con el número delante— se amortiza en una sola reunión.

**Nichos donde vive.** Fraude y prevención de lavado, resolución de identidad y de entidades,
redes sociales y de colaboración, linaje de datos y gobierno, topologías de red y de
infraestructura, listas de materiales y trazabilidad, recomendación, y ahora la variante de
recuperación aumentada sobre grafo.

**Stacks.** Cypher es el lenguaje, y va camino de estandarizarse como GQL. Drivers en Java
—que es la casa del motor—, Python, JavaScript, .NET y Go. Memgraph habla el mismo Cypher
desde C++, y Apache AGE lo mete dentro de Postgres, que es un dato útil para el veredicto.

**Veredicto: intocable.** Si se cae grafos, se cae el mejor momento de la ruta.

### 🧬 2.7 Vectorial — Qdrant contra `pgvector`

Esta es la familia que originó la pregunta de este documento, así que va con más espacio.

**Pregunta del instrumento:** la 5, **exactitud contra parecido** — y es **la única de las
diez que la responde por el lado del parecido semántico**. Búsqueda la responde por el lado
léxico: encuentra "junta tórica" cuando escribes "junta torica". Vectorial encuentra "fuga en
el retén" cuando escribes "gotea aceite por abajo". No son la misma pregunta y no se cubren
la una a la otra. **Si vectorial se cae, la quinta pregunta del instrumento se queda con
medio minicurso.**

**La aclaración que deshace el malentendido: esto no es un tema de IA, es un modelo de
acceso.** El alcance ya lo deja fuera explícitamente en §11 —entrenar modelos de embeddings
es otro curso— y el diseño lo respeta: el modelo entra como **caja cerrada y fijada**, no se
entrena nada, no hay ingeniería de prompts, y no hay un modelo de lenguaje en el camino
crítico de ninguna medición. Lo que se enseña es un **índice de vecinos aproximados** y su
compromiso. La confusión es de etiqueta, igual que la de DuckDB, y las dos se deshacen igual:
mirando el modelo de acceso en vez del nombre.

**Qué enseña que ninguna otra enseña.** Es la primera familia del curso que **no devuelve la
respuesta correcta: devuelve las parecidas**. Eso obliga a una métrica que no aparece en
ninguna otra fase —**recall contra velocidad**— y trae con ella la trampa más transferible de
la ruta: *se puede ser rapidísimo devolviendo basura*. Quien entiende ese compromiso lo
reconoce después en cachés, en muestreos, en índices aproximados y en cualquier sistema que
cambie exactitud por latencia.

**Refrescamiento profesional.** El de **mayor tracción de mercado hoy** y el que más
probablemente te van a pedir que evalúes este año. Y el veredicto honesto del curso
—*"`pgvector` alcanza en la mayoría de los casos y te ahorra un motor entero"*— es
precisamente lo que el mercado no está diciendo en voz alta. Una familia donde la voz
mayoritaria empuja en una dirección y la medición empuja en otra es, para un curso que mide,
la mejor materia prima que hay.

**Nichos donde vive.** Recuperación aumentada sobre documentación propia, búsqueda semántica
en catálogos y bases de conocimiento, deduplicación y resolución de entidades, recomendación
por similitud, detección de duplicados y de plagio, búsqueda multimodal, y clasificación por
vecinos más cercanos sin entrenar nada.

**Stacks.** Python es la lengua franca del lado de los embeddings, y por eso el curso admite
Python justo aquí. Pero los motores exponen REST y gRPC, así que **el lado de consulta se
escribe en TypeScript, Go o Java sin fricción**, y `pgvector` se toca desde cualquier cliente
de Postgres. Conviene decirlo en la fase: el mito de que "esto es de Python" se cae en cuanto
separas ingesta de consulta.

**Veredicto: no sacrificable, y la peor candidata de las diez al recorte.** Quitarla ahorra
20 horas, deja la quinta pregunta coja, y le arranca al curso la familia por la que más gente
va a llegar a él. Además rompe la decisión 14 del alcance —publicar vectorial en tercer lugar
por arrastre y por su conexión con `tutorial-rag/`—, que es la única jugada de tracción que
tiene la ruta.

### 🏛️ 2.8 Columnar ancha — Cassandra contra Postgres particionado

**Pregunta del instrumento:** la 2, **¿conoces tus consultas de antemano?**, en su forma más
brutal y menos negociable.

**Qué enseña que ninguna otra enseña.** **Modelar por consulta y no por entidad**, que es el
cambio de paradigma más grande de todo el curso: aquí una consulta nueva es una tabla nueva
más un backfill, y eso no es un defecto del motor, es el trato. Con él vienen cuatro cosas
que no aparecen en ninguna otra fase: desnormalizar a propósito y mantener N copias, el hot
spot por partition key mal elegida, la amplificación de escritura, y que **borrar puede ser
lo más caro que hagas**.

**Refrescamiento profesional.** Aquí hay que ser honesto en las dos direcciones. La adopción
nueva de Cassandra bajó, y presentarla como la tecnología del momento sería mentir. Pero el
parque instalado es enorme, y sobre todo: **el modelo mental se transfiere casi intacto a
DynamoDB, Bigtable, HBase y ScyllaDB**, que es donde sí está el mercado. Se estudia Cassandra
y se sale sabiendo diseñar una clave de partición en DynamoDB — y eso vale la pena decirlo en
la fase, no dejarlo implícito.

**Nichos donde vive.** Telemetría e IoT a escala, mensajería y feeds, tracking de eventos,
registros de llamadas y de red en telecomunicaciones, y cualquier régimen de escritura donde
la coordinación central deja de ser viable.

**Stacks.** La casa es la JVM: Java y Scala, con Spark como compañero habitual para procesar.
Drivers en Python, Go, Node y C#. ScyllaDB habla el mismo CQL desde C++, y DynamoDB es el
mismo modelo de acceso con otra API y otra factura.

**Veredicto: no sacrificable** — es donde vive la pregunta 2, y sin ella el instrumento pierde
la pata que más caro sale ignorar después de la frontera transaccional.

### 📴 2.9 Offline-first — CouchDB + PouchDB

**Pregunta del instrumento:** ninguna de las cinco, directamente. Añade una sexta implícita
que el curso no ha escrito todavía y quizá debería: **¿quién escribe cuando nadie puede
coordinarse?**

**Qué enseña que ninguna otra enseña.** **El conflicto como caso normal y no como error.** Es
el único punto del curso donde se diseña la convergencia en vez de suponerla, y la lección
viaja lejísimos: a cualquier caché con escritura, a la replicación, a la edición
colaborativa, al móvil, al edge. Quien ha resuelto un conflicto de replicación a mano una vez
entiende para siempre qué significa "consistencia eventual" sin misticismo.

**Refrescamiento profesional.** Es la familia de **menor encuentro directo** de las diez, y
hay que decirlo sin adornos: montar CouchDB no es un movimiento común en 2026. Pero tiene la
paradoja más interesante del temario: el **concepto está en alza** mientras el producto está
de nicho. El movimiento local-first —CRDTs, sincronización sobre Postgres, los motores de
edición colaborativa— resucitó exactamente estas ideas con otros nombres, y quien entiende el
árbol de revisiones y la resolución de conflictos entra en esa conversación sin traductor.

**Nichos donde vive.** Aplicaciones de campo —inspección, auditoría, agro, salud rural,
logística—, retail con conectividad intermitente, aplicaciones colaborativas, móvil en
mercados con red mala, y edge.

**Stacks.** JavaScript y TypeScript de punta a punta: el cliente local vive en el navegador,
en React Native y en Electron, y es el único sitio del curso donde el mismo lenguaje está en
los dos lados de la sincronización. Kotlin y Swift para móvil nativo con otras piezas del
mismo modelo, y Rust detrás de varias implementaciones de CRDT.

**Veredicto: la candidata más defendible al recorte de las diez — y aun así no la quitaría
entera.** La comprimiría a una fase (§4.1). Es la única familia que enseña convergencia, y
el curso se quedaría sin una idea que no está en ningún otro sitio de la ruta.

### ⚡ 2.10 NewSQL — CockroachDB contra Postgres de un nodo

**Pregunta del instrumento:** la 1, **la frontera transaccional**, que es la que más caro sale
ignorar — llevada a su caso extremo: ¿y si la frontera cruza un océano?

**Qué enseña que ninguna otra enseña.** **La síntesis del curso.** Que ACID y distribución no
son incompatibles, son *caras*; que la geografía aparece en tu esquema porque la velocidad de
la luz aparece en tu `COMMIT`; y que el reintento de transacción deja de ser manejo de errores
y pasa a ser **parte del modelo de programación**. Es además el único sitio de la ruta donde
el tiempo sí es el argumento, y por una razón declarada: es física, no hardware.

**Refrescamiento profesional.** Adopción directa baja, concepto en camino de volverse default
invisible: los proveedores están metiendo Postgres distribuido debajo de sus servicios
gestionados, y dentro de dos años mucha gente va a estar encima de uno sin haberlo elegido.
Y el veredicto de la familia —*"si te basta una región, Postgres es más simple, más barato y
más rápido"*— es probablemente **el que más dinero ahorra de todo el curso**.

**Nichos donde vive.** Pagos y libros contables, inventario global, multi-región con
residencia de datos regulada, SaaS que promete continuidad sin ventanas de mantenimiento, y
equipos que se están saliendo de un sharding manual que ya no aguantan.

**Stacks.** Habla el protocolo de Postgres, así que **cualquier cliente de Postgres sirve** —y
eso es medio argumento comercial de la familia—. El motor está escrito en Go; TiDB habla
MySQL en vez de Postgres; YugabyteDB reusa la capa de Postgres directamente. La lección de
localidad de datos es la misma en los tres.

**Veredicto: no sacrificable** — cierra el arco de la pregunta 1, que es la que abre el curso.
Comprimible a una fase si hace falta.

---

## 3. ⚖️ Tabla de veredictos

| Familia | Pregunta que responde | Encuentro en el trabajo | Valor de criterio | ¿Sacrificable? |
|---|---|---|---|---|
| 🍃 Documental | 3 · unidad de lectura | muy alto | alto | ❌ no |
| 🔑 Clave-valor | 3 · en su forma pura | muy alto | alto | ❌ no |
| 🦆 Analítico embebido | 3 · filas contra columnas | alto y subiendo | **máximo** | ❌ no |
| ⏱️ Series temporales | 2 · y el orden de llegada | medio-alto | alto | ⚠️ comprimible |
| 🔍 Búsqueda | 5 · por el lado léxico | muy alto | alto | ❌ no |
| 🕸️ Grafos | 4 · saltos y profundidad | bajo | **máximo** | ❌ no |
| 🧬 Vectorial | 5 · por el lado semántico | alto y subiendo | alto | ❌ **la peor candidata** |
| 🏛️ Columnar ancha | 2 · en su forma brutal | medio | alto | ⚠️ comprimible |
| 📴 Offline-first | la sexta implícita | bajo | medio-alto | ⚠️ **la más defendible** |
| ⚡ NewSQL | 1 · la frontera, al extremo | bajo | alto | ⚠️ comprimible |

Ninguna falla el primer filtro. Ninguna falla el segundo. Las tres que flaquean en el tercero
—grafos, offline-first y NewSQL— son justamente las de mayor valor de criterio, que es la
paradoja central de este curso y conviene no resolverla al revés: **el curso no enseña las
familias que vas a usar, enseña a decidir cuál usar, y para eso hacen falta también las que
vas a rechazar.**

---

## 4. ✂️ Si aun así hay que acortar: las palancas reales

La pregunta correcta no es *qué familia sobra* sino **cuánta profundidad por familia**. Las
252 horas no salen de tener diez modelos: salen de darle 20 horas a cada uno. Cuatro palancas,
en orden de lo que cuestan:

### 4.0 La que no cuesta nada: publicar por tandas

Ya está prevista en la decisión 14 del alcance y en el pendiente de
`propuesta-fases-y-alcance.md` §11. **El Bloque 0 más el Bloque I son 52 horas, cierran con su
boss y salen con criterio utilizable.** No acorta el curso; acorta el tiempo hasta el primer
entregable publicado, que es un problema distinto y probablemente el que de verdad importa.

### 4.1 Fase única para offline-first y NewSQL · **−20 h**

Las dos familias de menor encuentro directo pasan de dos fases a una, fusionando *levantar y
modelar* con *romper, medir y decidir*. Se conservan la apuesta falsable, el punto de rotura
y el veredicto —que es lo que no se puede perder—, y se recorta el modelado extenso.

**Lo que cuesta:** son fases densas y comprimirlas se nota. Y rompe la simetría "dos fases por
familia", que es una decisión cerrada (§12.8 del alcance) y tendría que reabrirse ahí primero.

### 4.2 Fusionar series temporales y columnar ancha en un bloque de régimen de escritura · **−10 h**

**Es la única redundancia real del temario.** Las dos familias comparten la premisa —escritura
masiva, ordenada, que no se actualiza— y se diferencian en qué hacen con ella: una comprime y
retiene dentro de un nodo, la otra distribuye cuando el nodo se acabó. Contarlas juntas, en
tres fases en vez de cuatro, tiene además una ventaja pedagógica: **la transición entre las
dos es exactamente la pregunta que el bloque IV quiere instalar** —qué pasa cuando el dato
deja de caber— y hoy queda partida entre dos bloques distintos.

**Lo que cuesta:** una fase con dos motores arriba a la vez, con lo que eso implica en RAM y
en `a02`.

### 4.3 El capstone, de tres fases a dos · **−14 h**

F23 (el diseño) y F24 (la costura) son irrenunciables: son la conclusión que la ruta lleva
cinco meses prometiendo. F25 (la factura y el veredicto final) es un cierre magnífico y podría
vivir como fase de 14 horas fundida con F24, o como documento de cierre fuera del conteo.

**Lo que cuesta:** el veredicto final es la promesa editorial del curso. Comprimirlo es la
palanca que yo usaría **la última**.

### 4.4 La cuenta

| Escenario | Horas | Semanas a 12 h | Familias |
|---|---|---|---|
| Temario actual | 252 h | ≈ 21 | 10 |
| Con 4.1 | 232 h | ≈ 19 | 10 |
| Con 4.1 + 4.2 | 222 h | ≈ 18,5 | 10 |
| Con 4.1 + 4.2 + 4.3 | **208 h** | **≈ 17** | **10** |
| Quitando vectorial | 232 h | ≈ 19 | 9 y un instrumento cojo |

**Un 17 % menos sin perder una sola familia**, contra un 8 % perdiendo la de más tracción del
mercado. La aritmética es bastante clara sobre cuál de los dos caminos tomar.

### 4.5 Lo que no se toca en ningún escenario

- **El Bloque 0 entero.** Sin las autopsias, el dominio, el arnés y las cinco preguntas, esto
  son diez tutoriales de producto puestos en fila. Es lo primero que la gente propondría
  recortar y lo último que habría que recortar.
- **Documental y clave-valor con sus dos fases.** Son la entrega mínima defendible.
- **Analítico embebido.** Es la fase que demuestra la tesis.
- **La fase B de grafos.** Es donde el curso pierde su apuesta en público.
- **Las dos bases montadas en todas las mediciones.** Quitar Postgres de al lado para ahorrar
  tiempo convierte cada afirmación del curso en una opinión.

---

## 5. 📌 Pendientes que deja este documento

- **Si se adopta alguna palanca de §4**, hay que cambiar primero
  `propuesta-fases-y-alcance.md` y la decisión 8 y 13 de `alcance-del-proyecto.md` §12, y
  después las plantillas y los prompts. Nunca al revés.
- **La sexta pregunta implícita del instrumento** —*¿quién escribe cuando nadie puede
  coordinarse?*— hoy no está en las cinco de §5 del alcance y es la que justifica
  offline-first. O se declara como sexta pregunta, o se absorbe como matiz de la primera. Sin
  resolverlo, offline-first seguirá pareciendo la familia sobrante cuando no lo es.
- **La transferencia de columnar ancha a DynamoDB y Bigtable** debería quedar escrita dentro
  de F17/F18 y no solo aquí: es el argumento que sostiene la relevancia de esa familia y hoy
  no aparece en el temario.
- **La aclaración de que vectorial no es un tema de IA** merece un párrafo explícito en F15,
  y probablemente una línea en el README. Si la pregunta apareció una vez, va a volver a
  aparecer.
