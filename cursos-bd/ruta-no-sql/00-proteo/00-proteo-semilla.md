# 🍃 Proyecto Proteo — Semilla del curso (Documental)

## 🎯 Motivación

Hay una clase de dominio en la que la unidad natural de lectura y de escritura
es **un agregado autocontenido**: una entidad que casi siempre se lee entera,
se escribe entera, y rara vez necesita cruzarse con otras para responder la
pregunta que la aplicación realmente hace. Una ficha de producto, un perfil de
usuario con forma variable, un documento de contenido con secciones anidadas.
El patrón de acceso dominante no es "combiná estas cinco entidades normalizadas
para reconstruir una vista", sino "traeme *esta cosa* completa, tal como es".

El modelo relacional puede resolver esto —puede resolver casi todo— pero no fue
diseñado para hacerlo bien cuando la forma del agregado es **heterogénea y
evoluciona sin coordinación central**. Cuando cada categoría de producto tiene
su propio conjunto de atributos, y aparecen categorías nuevas sin avisar, el
relacional honesto te deja dos caminos, ambos incómodos: una tabla por
categoría (migración de esquema cada vez que nace una categoría), o el patrón
**Entity-Attribute-Value** —una tabla `atributo/tipo/valor` que simula columnas
dinámicas— que convierte cada lectura de un producto completo en una unión de
una docena de filas que el motor nunca fue optimizado para tratar como una sola
entidad. El costo no es de expresividad: SQL con JSONB, GIN y funciones de
ventana es asombrosamente capaz. El costo es de **alineación**: cada modelo
especializado codifica, en su estructura física, una suposición sobre el patrón
de acceso. El documental codifica "lo que se lee junto, se guarda junto".
Cuando tu dominio realmente tiene esa forma, esa alineación se paga sola.

Para un ingeniero senior que viene de años de bases relacionales, dominar este
modelo suma tres cosas concretas al criterio. Primero, **un proyecto que antes
dolía deja de doler**: catálogos con atributos variables, sistemas de contenido,
snapshots inmutables, dejan de exigir migraciones de pánico. Segundo, deja de
cometer el error de arquitectura inverso —el que este curso disecciona— que es
transcribir un esquema relacional al documento o, peor, simular documentos en
SQL con EAV. Tercero, y más importante, aprende a **decir que no**: a reconocer
cuándo un dominio *no* vota documento (cuando las invariantes cruzan agregados,
cuando todo son muchos-a-muchos, cuando la contabilidad exige ACID multi-fila),
y a defender esa decisión con números en la mano en lugar de una preferencia.
La herramienta correcta agregada al cinturón vale tanto como saber cuándo
dejarla en el cinturón.

---

## 🏗️ El dominio: catálogo de marketplace multi-vertical + PIM

Proteo es el backend de un **marketplace con cuatro verticales deliberadamente
heterogéneas**, cada una con su propia forma de atributos. No es un catálogo de
juguete con `nombre`, `precio` y `descripción`: es un catálogo donde la forma
del producto **depende de qué producto es**, y donde el negocio agrega
categorías y atributos como parte de su operación normal, no como un evento
excepcional. A ese componente que gobierna la forma y los atributos de cada
producto se lo llama, en la industria, un **PIM** (Product Information
Management): el sistema que custodia "qué campos tiene un producto de esta
categoría y cómo se validan".

| Vertical | Atributos distintivos (ejemplos) |
|---|---|
| 📱 Electrónica | `ram`, `cpu`, `ports` (array), `warrantyMonths`, `voltage` |
| 👕 Moda | `size`, `color`, `material`, `careInstructions` (array), `season` |
| 📚 Libros | `isbn`, `authors` (array), `language`, `publisher`, `pageCount` |
| 🥫 Alimentos | `netWeightGrams`, `expiryDate`, `nutrition` (subdoc), `allergens` (array) |

La heterogeneidad **no es un accidente del modelado: es el requisito del
producto.** Un producto de moda y uno de electrónica no comparten casi ningún
atributo, y una vertical nueva (digamos, "hogar y jardín") debe poder entrar en
producción sin un `ALTER TABLE`, sin una migración coordinada entre equipos, sin
una ventana de mantenimiento. Ese requisito —**evolución de forma sin
coordinación central**— es exactamente la forma que el modelo documental
codifica de fábrica y que el relacional tiene que simular con capas.

Alrededor del catálogo, el dominio tiene suficiente riqueza para tensionar el
modelo en ambas direcciones (donde gana y donde no): **reseñas** que crecen sin
techo por producto (¿embeber o referenciar?), **inventario** por almacén y
variante (arrays que respiran, decrementos concurrentes), **pedidos** que deben
congelar el producto tal como estaba al comprar (inmutabilidad por diseño), y
**búsqueda facetada** que en algún punto deja de ser trabajo para el motor
principal. Cada uno de esos frentes es una fase, y cada fase mide.

### El marco de 5 preguntas, aplicado ANTES de modelar

La disciplina del curso es no empezar por el motor sino por el patrón de acceso.
Cinco preguntas, respondidas antes de escribir una sola colección o tabla:

| Pregunta | Veredicto para Proteo |
|---|---|
| ¿Qué se lee junto? | La ficha completa del producto, casi siempre entera — localidad natural perfecta. |
| ¿Quién custodia la forma / las invariantes? | La forma es distinta por categoría y cambia seguido; las invariantes de un producto viven dentro del producto (validación por categoría). |
| ¿Cuánto se une en caliente? | Muy poco en el camino de lectura caliente: el documento **es** la página del producto. Los cruces (co-ocurrencia, facetas) son analíticos, no del request de detalle. |
| ¿Dónde viven las invariantes? | Mayormente intra-agregado (un producto válido). Las que cruzan agregados (stock, pedidos) son pocas y se tratan explícitamente. |
| ¿Qué pide la operación? | Lectura masiva de fichas, escritura moderada, y **evolución constante de atributos** como requisito de primera clase. |

**Veredicto: vota documento 5-0** para el catálogo. Con una honestidad que el
curso no esconde: el mismo sistema tiene una esquina —pagos y contabilidad— que
vota relacional con la misma claridad, y esa esquina se defiende en la última
fase. El veredicto no es "Mongo para todo": es "documento para el catálogo,
relacional para el libro mayor", sostenido con mediciones.

### ⚰️ El villano: EAV, el crimen inverso

Si el curso legacy tenía un villano que transcribía tablas a Mongo, Proteo tiene
el villano **simétrico y relacional**: **EAV (Entity-Attribute-Value)**, la
tabla `atributo / tipo / valor` con la que el mundo relacional simula columnas
dinámicas para no rendirse ante la heterogeneidad. EAV es la respuesta que un
equipo relacional da cuando el negocio pide "atributos flexibles por categoría"
y nadie quiere `ALTER TABLE` por cada vertical: en lugar de columnas, filas;
en lugar de una fila por producto, una fila por *cada atributo* de *cada*
producto, con el valor guardado como texto (o repartido en `valueText`,
`valueInt`, `valueDate`…) y el tipo en otra columna.

El olor de EAV no es el idioma ni la sintaxis: es **estructural**. Una ficha de
producto se reconstruye con una docena de `JOIN`/pivot; una consulta con dos
filtros de atributo se vuelve un rompecabezas de auto-joins; la integridad de
tipos se pierde (todo es texto hasta que alguien lo castea mal); y "dame los
productos donde `ram >= 16` y `warrantyMonths >= 24`" se convierte en el tipo de
query que nadie quiere mantener. El curso lo construye de verdad en PostgreSQL,
lo mide de punta a punta (fase final: **la autopsia inversa**), y muestra los
números antes/después de convertirlo a documento. No se caricaturiza: se le da
su mejor versión (con JSONB como refutación seria, no como hombre de paja) y aun
así se mide dónde cede.

---

## 📐 Stack (2026, estable y moderno)

Todo lo de abajo es lo **último estable** disponible en 2026, priorizando open
source de acceso libre en entorno de desarrollo y **todo contenerizado**
(Docker/Podman). Las versiones se fijan al *major* estable; los *minor/patch* se
toman al día del `docker compose up`.

| Componente | Versión / elección | Rol |
|---|---|---|
| **MongoDB** | **8.0** (serie de soporte estándar, 30 meses) | Motor documental principal: catálogo, snapshots de pedido, inventario. |
| **Couchbase Server** | **8.0** | Segundo rival **documental** (C++, N1QL/SQL++, memoria-first). El "documento vs documento". |
| **PostgreSQL** | **18** | Rival relacional permanente: EAV y JSONB en el arnés; motor de pagos/contabilidad en el veredicto final. |
| **Node.js** | **24 LTS** ("Krypton", soporte hasta abr-2028) | Runtime del backend y del arnés `vs.ts`. |
| **TypeScript** | **5.x** (última estable) | Tipado en todo el backend y en los scripts de benchmark. |
| **Express** | **5.x** | API HTTP que sirve la ficha del producto y las operaciones. |
| **Zod** | última estable | Validación de aplicación (paralela al `$jsonSchema` del motor). |
| **Redis / Valkey** | última estable | Carrito con TTL y caché derivada (Fase del carrito y Change Streams). |
| **Meilisearch** | **1.48.x** (rama estable) | Motor de búsqueda ligero: el "cuándo el documento no basta". |
| **mongosh + Compass** | últimas | Shell y GUI para inspección y `explain()`. |
| **Docker / Podman + Compose** | últimas | Todo el laboratorio contenerizado; un `up` levanta los cuatro motores. |

### Por qué MongoDB 8.0 como motor principal

Es el estándar de facto del modelo documental y el que más terreno de
comparación ofrece frente a lo relacional (es *el* motor que el senior relacional
va a encontrar cuando alguien "eligió NoSQL"). Se fija **8.0** —la serie con
soporte estándar de 30 meses— y no la rama rápida más nueva, porque el curso se
opera on-prem/contenedor y queremos una base reproducible por 2–3 años, no la
punta de lanza de Atlas. Todo lo que el curso enseña (aggregation, `$jsonSchema`,
Change Streams, `$inc` atómico, `findOneAndUpdate` con precondición) es estable
y de primera clase en 8.0.

### Por qué Couchbase (y por qué NO CouchDB)

El "vs" del curso no puede ser solo documento-contra-relacional: eso deja sin
responder la pregunta más incómoda, "¿y contra otro documental?". **Couchbase**
entra como segundo rival documental porque es genuinamente distinto de Mongo en
lo que importa: arquitectura **memoria-first**, y **N1QL/SQL++**, un lenguaje de
consulta tipo SQL sobre JSON que resulta desconcertantemente familiar para el
lector relacional. Medir Mongo contra Couchbase obliga a separar "ventaja del
modelo documental" de "ventaja de *este* motor documental".

> ⚠️ **Couchbase ≠ CouchDB. No son el mismo producto ni parientes cercanos.**
> **Couchbase** (C++, N1QL/SQL++, memoria-first, operacional) es el rival de
> este curso. **CouchDB** (Erlang, Apache, protocolo de replicación
> offline-first) es otra familia entera y pertenece a un curso distinto de la
> ruta. Confundirlos es el error clásico por el nombre; acá no se comete.

### Por qué PostgreSQL 18 como rival relacional

Porque es la **refutación más seria** que existe al argumento "necesito un
documento". Postgres con **JSONB + GIN** puede guardar y consultar documentos
razonablemente bien; si iguala el caso de uso, elegir un motor documental
dedicado hay que justificarlo con algo más que "es más cómodo". El curso le da a
Postgres sus dos mejores armas —EAV bien hecho *y* JSONB con índices GIN— y mide
honestamente dónde empata (lectura de blob por id), dónde pierde (categoría
nueva sin migración) y dónde **gana** (agregaciones ACID, el libro mayor).
Postgres 18 además trae mejoras de I/O y de índices que lo vuelven un rival más
duro, no un maniquí.

### Por qué TypeScript + Node 24 LTS

Multiplataforma real (Linux, macOS, Windows vía WSL), el ecosistema con los
drivers de primera clase para los cuatro motores, y tipado estático que hace del
código del arnés y del backend algo legible y verificable. Node **24** es el
Active LTS del momento (soporte hasta 2028): estabilidad para un curso de vida
larga sin renunciar a `require(ESM)` y las mejoras recientes del runtime. Se
elige TS sobre Python aquí —a diferencia de lo que pediría un curso analítico o
vectorial— porque el dominio es un **backend transaccional de aplicación**, no
un pipeline de datos: el driver de Mongo, Express y el tooling de benchmark
viven cómodos y de forma idiomática en Node.

### Validación en capas (la lección que se aplica desde el día 0)

- **Zod** en la aplicación (TypeScript, developer experience, mensajes claros).
- **`$jsonSchema`** en el motor (la última línea, la que ningún cliente puede
  esquivar). En Mongo, un `$jsonSchema` **polimórfico** (`oneOf` por categoría)
  es lo que hace que "heterogéneo" no signifique "sin reglas".

La regla es la misma que rige todo el código del curso: **identificadores,
colecciones, campos, endpoints, constantes y enums en inglés; comentarios de
código y textos de interfaz en español.** El producto pedagógico se lee en
español; el vocabulario que el equipo mantiene (`product`, `category`, `review`,
`assignee`→ aquí `sku`, `warehouseId`, `expiryDate`) va en inglés, como en un
sistema real.

---

## ⚖️ El método del "vs": un arnés, no anécdotas

Desde la Fase 0 se monta **`scripts/vs.ts`**: un harness que ejecuta **la misma
consulta semántica** contra los motores en juego, la corre varias veces
(descartando el warm-up), cronometra percentiles (p50/p95), verifica que los
resultados sean equivalentes, y **acumula todo en `BENCHMARKS.md`** con fecha,
versión de motor, tamaño de dataset y hardware. Ningún "vs" del curso se narra
sin haber pasado por el arnés primero. Cuando el texto diga "Mongo gana acá", al
lado va la tabla con los números que lo respaldan —o el matiz de que empata, o
la confesión de que pierde.

Los tres duelos que atraviesan el curso, derivados de los rivales:

1. **Mongo vs PostgreSQL (EAV *y* JSONB)** — documento vs relacional, el eje
   principal. Escritura y lectura de fichas, costo de categoría nueva, facetas.
2. **Mongo vs Couchbase** — documento vs documento (memoria-first, N1QL/SQL++).
   Latencia de lectura por clave, agregación, footprint de memoria.
3. **Mongo vs Meilisearch** — cuándo el documento deja de bastar para *buscar*
   (relevancia, tolerancia a errores, facetas a escala).

---

## 🌳 Estructura de fases

Trece fases. La Fase 0 monta el laboratorio contenerizado y el generador de
datos y hace nacer `vs.ts`; la última cierra con la ⚰️ autopsia del villano y el
⚖️ veredicto honesto de cuándo NO usar documental. El resto recorre el dominio
tensionando el modelo donde gana y —sin trampa— donde no.

| # | Fase | Núcleo | "Vs" de la fase |
|---|---|---|---|
| **0** | 🧪 El laboratorio de varios motores | Compose con Mongo + Postgres + Couchbase + Redis + Meilisearch. Generador que produce el **mismo dataset semántico** en todas las formas. Nace `scripts/vs.ts`. | — (montaje) |
| **1** | ⚖️ El marco, para decidir | Las 5 preguntas aplicadas ANTES de modelar. Se construye el EAV en SQL y se **siente el dolor en vivo**. | EAV vs JSONB vs documento (escritura y lectura de ficha) |
| **2** | 🧬 Heterogeneidad como feature | Catálogo de 4 verticales en documentos; `$jsonSchema` **polimórfico** (`oneOf` por categoría). | EAV vs JSONB+GIN vs documento — costo de **categoría nueva sin migración** |
| **3** | 📄 La página del producto: localidad como ventaja | El `findOne` que sirve la ficha completa de un tiro. | Aquí JSONB **empata** en lectura de blob — primer "vs" honesto donde Mongo no gana |
| **4** | ⭐ Reseñas: embeber, referenciar o "depende del tamaño" | Bucket pattern para miles de reseñas; computed pattern para el promedio. | Agregación SQL (`AVG`/`COUNT`) vs patrones de documento — costo de escribir una reseña |
| **5** | 📦 Inventario multi-almacén: arrays que respiran | Stock por almacén/variante como array de subdocumentos; `$inc` atómico. | Tabla puente `warehouse_stock` — decremento concurrente en ambos |
| **6** | 🕰️ Historial de precios y el pedido como fotografía | El documento de orden **congela** el producto tal como estaba al comprar (inmutable por diseño). | Patrón SCD Type 2 de SQL (legítimo, más ceremonioso) |
| **7** | 🔍 Búsqueda y facetas: cuándo el documento no basta | `$facet` de aggregation resolviendo filtros con conteos. | SQL+GIN vs Mongo `$facet` vs **Meilisearch** — se instala "índice derivado, nunca fuente de verdad" |
| **8** | 🕸️ "Quienes compraron X también compraron Y" | Co-ocurrencia con aggregation. | Por qué esto es agregación y no grafo — puente honesto a un futuro modelo de grafo |
| **9** | 🛒 El carrito: el key-value en su hábitat | Redis con TTL para el carrito vivo. | Redis vs carrito-como-colección-Mongo — latencia y durabilidad; diseño híbrido |
| **10** | 🔄 Change Streams: mantener sincronizados los derivados | Mongo alimentando Meilisearch y la caché de Redis en tiempo real, sin polling ni outbox manual. | — (técnica nueva; se mide latencia de propagación) |
| **11** | ⚰️ La autopsia inversa | El catálogo **EAV completo** medido de punta a punta (ficha = N joins; categoría nueva = migración de pánico). Conversión a documento con números antes/después. | El ritual del villano, en espejo |
| **12** | ⚖️ El veredicto con las dos manos | Documento gana el catálogo; **pagos/contabilidad siguen votando relacional** (ACID real, auditoría). Sistema final políglota defendido con criterio. | Documento vs relacional en su propio terreno (el libro mayor) |

### Fase 0 — El laboratorio de varios motores
Levanta todo el entorno con un `docker compose up`: Mongo 8, Postgres 18,
Couchbase 8, Redis/Valkey y Meilisearch, más un contenedor de herramientas con
Node 24 + TS. Se escribe el **generador de datos** que produce el mismo catálogo
semántico en las cuatro formas (documento Mongo, documento Couchbase, EAV
Postgres, JSONB Postgres) para que todo "vs" compare peras con peras. Nace
`scripts/vs.ts` con su primer duelo trivial (un `findOne`/`SELECT` por id) para
validar el arnés. Aquí se inaugura `INSTINTOS.md` con la primera predicción.

### Fase 1 — El marco, para decidir
Las 5 preguntas, aplicadas en vivo. Se construye el **EAV real** en Postgres y
se escribe la query que reconstruye una ficha completa: el lector *siente* los
joins. 🪞 Primer recuadro de instinto ("una tabla flexible de atributos es la
forma normal de hacer esto en SQL… y esta vez te va a costar caro"). Se mide
escritura y lectura de ficha EAV vs JSONB vs documento. 📖 Primera entrada del
diccionario de traducción.

### Fase 2 — Heterogeneidad como feature
El catálogo de las 4 verticales, modelado en documentos, con `$jsonSchema`
**polimórfico** (`oneOf` por `category`) para que "flexible" no sea "sin reglas".
🩻 "Esto sí viaja igual": un esquema **sigue existiendo**, solo que vive en el
motor y en Zod, no en `CREATE TABLE`. El "vs" estrella: **cuánto cuesta agregar
una vertical nueva** en cada forma (documento: cero migración; EAV: cero
migración pero query infernal; tabla-por-categoría: `ALTER`/DDL; JSONB: índice
GIN nuevo).

### Fase 3 — La página del producto: localidad como ventaja
El camino caliente: `findOne` que devuelve la ficha entera. 🩻 Índices,
selectividad, `explain()` y el N+1 **siguen valiendo lo que valían en SQL**. Y
el "vs" **honesto**: leer un blob por id es justo donde **JSONB empata** —Mongo
no gana todo, y decirlo construye credibilidad. Se mide p50/p95 de la lectura de
detalle en los tres.

### Fase 4 — Reseñas: embeber, referenciar o "depende del tamaño"
La decisión de modelado más citada del modelo documental, medida en vez de
recitada. **Bucket pattern** para miles de reseñas por producto, **computed
pattern** para el promedio y el conteo. 🪞 "Embebé todo" es un instinto tan
peligroso como "normalizá todo": el techo del documento (16 MB) y el costo de
reescribir un doc grande al agregar una reseña se miden. "Vs": `AVG`/`COUNT`
relacional contra mantener el agregado en el documento.

### Fase 5 — Inventario multi-almacén: arrays que respiran
Stock por almacén y variante como **array de subdocumentos**, con `$inc`
atómico y actualización posicional. El foco es la **concurrencia**:
`findOneAndUpdate` con precondición en el filtro para que dos decrementos
simultáneos no vendan de más. 🪞 "Un `UPDATE ... WHERE qty > 0` con transacción"
es el instinto SQL; acá el candado vive en el filtro del documento. "Vs":
decremento concurrente contra la tabla puente `warehouse_stock`.

### Fase 6 — Historial de precios y el pedido como fotografía
El pedido **congela** el producto tal como estaba al comprar: precio, título,
atributos, todo copiado dentro de la orden (inmutable por diseño). 🪞 El
instinto SQL dice "referenciá el `productId` y listo"; pero entonces cambiar el
precio del producto reescribiría la historia de las órdenes. "Vs": el patrón
**SCD Type 2** relacional (legítimo, correcto, y más ceremonioso) contra el
snapshot embebido.

### Fase 7 — Búsqueda y facetas: cuándo el documento no basta
`$facet` de aggregation calculando filtros con conteos en una pasada. Y el punto
donde el motor principal cede: para relevancia, tolerancia a errores y facetas a
escala entra **Meilisearch**. Se instala la doctrina transversal: **el índice de
búsqueda es un derivado reconstruible, nunca la fuente de verdad**. "Vs" a tres
bandas: SQL+GIN vs Mongo `$facet` vs Meilisearch.

### Fase 8 — "Quienes compraron X también compraron Y"
Co-ocurrencia con aggregation sobre las órdenes. 🪞 El instinto moderno dice
"esto es un grafo"; se mide y se muestra que a esta escala y profundidad **es
agregación**, no grafo — y se deja el puente honesto hacia cuándo *sí* sería
grafo. Un ejercicio de humildad simétrico: no todo lo que parece relación
necesita un motor de relaciones.

### Fase 9 — El carrito: el key-value en su hábitat
El carrito vivo en **Redis con TTL**: expira solo, no ensucia el catálogo. 🩻 El
TTL nativo es una primitiva que ni el relacional ni el documental te dan gratis.
"Vs": carrito-en-Redis contra carrito-como-colección-Mongo — latencia,
durabilidad y el diseño **híbrido** (Redis para lo efímero, Mongo para lo que
persiste al confirmar). Introduce la idea de que "documental" no significa
"documental para todo".

### Fase 10 — Change Streams: mantener sincronizados los derivados
Mongo emitiendo cambios que alimentan Meilisearch y la caché de Redis en tiempo
real, **sin polling ni outbox manual**. La deuda técnica del "índice derivado"
de la Fase 7 se **paga** aquí: el derivado se mantiene fresco de forma reactiva.
Se mide la latencia de propagación cambio→índice.

### Fase 11 — La autopsia inversa ⚰️
El villano en la mesa de disección. El catálogo **EAV completo** en Postgres,
medido de punta a punta: la ficha que necesita N joins, la query de dos filtros
de atributo, la categoría nueva que exige migración. Conversión a documento con
**números antes/después** en `BENCHMARKS.md`. Es el espejo del ritual: no se
demuele por gusto, se demuele con cronómetro.

### Fase 12 — El veredicto con las dos manos ⚖️
La honestidad final. Documento **gana el catálogo** 5-0; **pagos y contabilidad
siguen votando relacional** (ACID multi-fila real, auditoría, libro mayor que no
puede perder una transacción). El sistema final es **políglota** —Mongo +
Postgres + Redis + Meilisearch— y cada motor está donde su patrón de acceso lo
pide. El árbol de decisión de "cuándo NO usar documental" se escribe acá, con
las mediciones de las 12 fases como respaldo.

### Apéndices

- **A) Arranque de motores por contenedores.** `docker compose up` comentado
  motor por motor; healthchecks; cómo entrar a `mongosh`, `psql`, `cbq` (shell
  de Couchbase) y la UI de Meilisearch.
- **B) `docker-compose.yml` / `Containerfile` de trabajo.** El archivo completo
  del laboratorio, versionado, con perfiles para levantar solo los motores que
  una fase necesita.
- **C) Guía rápida de MQL + aggregation** (y una mini-tabla MQL ↔ N1QL/SQL++ ↔
  SQL para el lector que salta entre motores en el arnés).
- **D) El generador de datos.** Cómo produce el mismo catálogo semántico en las
  cuatro formas; cómo escalar el volumen para que los benchmarks duelan.
- **E) Troubleshooting de setup.** Puertos ocupados, memoria de Couchbase,
  `replica set` de un nodo para Change Streams, TZ en fechas, y los errores
  típicos de primer arranque.

---

## 📓 Artefactos acumulativos

Dos archivos crecen fase a fase y son el contrapeso medido del curso:

**`INSTINTOS.md`** — el diario de instintos SQL puestos a prueba. Cada entrada
tiene la misma forma: el **instinto** relacional ("embebé todo", "esto es un
grafo", "una tabla de atributos flexible"), la **predicción falsable** que se
escribe *antes* de medir, el **resultado del cronómetro**, y el **veredicto**:
el instinto acertó, se equivocó, o "esta vez sí viaja igual". No se borra un
instinto equivocado: se deja con su autopsia, porque el error documentado enseña
más que el acierto. Nace en la Fase 0 y suma entradas en cada 🪞/🩻.

**`BENCHMARKS.md`** — la memoria de todos los "vs". Cada duelo ejecutado por
`vs.ts` deja una fila: consulta semántica, motores, dataset, versión, hardware,
p50/p95, y una línea de lectura ("JSONB empata en lectura por id; pierde 4× en
categoría nueva"). Es acumulativo y fechado: al final del curso es la evidencia
completa que sostiene el veredicto de la Fase 12. La regla es dura: **nada entra
a `BENCHMARKS.md` sin haber pasado por el arnés**; ninguna afirmación de
rendimiento vive solo en la prosa.

---

## 📚 Referencias por fase (semilla)

> ⚠️ **Verificar todo.** Las URLs, títulos de libros y videos de abajo son
> puntos de partida y **deben verificarse** antes de citarse en una fase: las
> rutas de documentación cambian de versión, los libros tienen ediciones nuevas,
> y los videos se borran. **No se inventan** números de página, DOIs ni IDs de
> video. Si al redactar una fase un enlace no resuelve, se busca el equivalente
> vigente y se marca la versión.

**Documentación oficial (URL completa, verificar versión al citar)**
- MongoDB 8.0 (manual): https://www.mongodb.com/docs/v8.0/
- MongoDB `$jsonSchema` / validación: https://www.mongodb.com/docs/manual/core/schema-validation/
- MongoDB aggregation (`$facet`, `$lookup`): https://www.mongodb.com/docs/manual/aggregation/
- MongoDB Change Streams: https://www.mongodb.com/docs/manual/changeStreams/
- Driver Node `mongodb` (última): https://www.mongodb.com/docs/drivers/node/current/
- PostgreSQL 18 (JSON/JSONB, GIN): https://www.postgresql.org/docs/18/datatype-json.html
- Couchbase Server 8.0 / N1QL (SQL++): https://docs.couchbase.com/server/current/
- Express 5: https://expressjs.com/en/5x/api.html
- Zod: https://zod.dev
- Redis (TTL/`EXPIRE`): https://redis.io/docs/latest/ · Valkey: https://valkey.io/docs/
- Meilisearch (facetas, tolerancia a errores): https://www.meilisearch.com/docs
- MDN (JS base, fechas, Intl): https://developer.mozilla.org

**Libros (cuando apliquen — verificar edición)**
- Un libro de referencia sobre patrones de modelado documental (p. ej. sobre
  *design patterns* de MongoDB) para las fases 4–6. Verificar título/edición.
- Un texto de fundamentos de bases de datos para anclar el marco de decisión de
  la Fase 1. Verificar título/edición.

**Video / apoyo (verificar existencia e ID; no se inventan IDs)**
- Charlas oficiales de MongoDB sobre schema design y bucket/computed patterns.
- Introducciones a N1QL/SQL++ de Couchbase para el lector que salta al arnés.

**Orden de lectura sugerido por fase**
- Fase 0–1: primero el manual de Mongo (modelo de datos) y la doc de JSONB de
  Postgres, en paralelo; después la guía del arnés.
- Fase 2–3: `$jsonSchema` y validación antes de modelar; luego aggregation.
- Fase 4–6: patrones de modelado (bucket, computed, snapshot) antes del código.
- Fase 7–10: Meilisearch y Change Streams juntos (el derivado y cómo se mantiene).
- Fase 11–12: releer el marco de la Fase 1 con los `BENCHMARKS.md` en la mano.

---

## 🧪 Nota sobre ejercicios

Cada fase lleva entre **20 y 40 ejercicios** graduados 🟢🟡🟠🔴, todos anclados
al dominio de Proteo (productos, verticales, reseñas, inventario, órdenes,
facetas), no a ejemplos abstractos. Una guía razonable de distribución para ~30:

| Nivel | Peso aprox. | Qué exige |
|---|---|---|
| 🟢 Fácil | ~8 | Calientan: una query, un `$jsonSchema` simple, un `$inc`. |
| 🟡 Intermedio | ~9 | Modelar una vertical, un bucket, un computed pattern. |
| 🟠 Difícil | ~7 | Cerrar una race condition en el stock, medir un `$facet`. |
| 🔴 Muy difícil | ~4-6 | Integrar varias fases; reproducir un N+1; convertir una porción de EAV midiendo antes/después. |
| 🔥 Opcionales | aparte | Ampliaciones fuera del alcance base (p. ej. N1QL avanzado). |

Al menos un puñado por fase son **de diagnóstico**: se entrega un bug (un
decremento que vende de más, un índice que no se usa, un `$jsonSchema` que
acepta basura) y se pide **reproducir y localizar**, no solo construir. Todo
ejercicio que nombre código usa el **identificador en inglés vigente** aunque el
enunciado esté en español.

---

## 🧩 Decisiones pendientes de confirmar antes de redactar la Fase 0

- [ ] **Dataset semilla:** ¿datos sintéticos generados por script (control total
      del volumen y la heterogeneidad) o un dataset público adaptado (más
      realista, menos controlable)? **Propuesta por defecto:** sintético
      generado, parametrizable por volumen, con semilla fija para
      reproducibilidad — es lo que el arnés necesita para comparar peras con
      peras. *(pendiente)*
- [ ] **¿Couchbase desde la Fase 0 o más tarde?** Montarlo siempre encarece el
      laboratorio (memoria); reservarlo retrasa el "documento vs documento".
      **Propuesta por defecto:** montado desde Fase 0 pero con perfil de Compose
      opcional, y su primer "vs" real en la Fase 3 (lectura por id). *(pendiente)*
- [ ] **Pagos/contabilidad de la Fase 12:** ¿mini-servicio Postgres real o
      diseño documentado? **Propuesta por defecto:** mini-servicio real mínimo
      (un ledger de dos tablas con una transacción ACID) para que el veredicto
      tenga números y no solo prosa. *(pendiente)*
- [ ] **Nombres definitivos de las 4 verticales y su forma de atributos**
      (los de la tabla del dominio son tentativos). *(pendiente)*
- [ ] **Formato de fase:** ¿se mantiene una plantilla de 9 secciones por fase o
      se ajusta por ser un curso moderno? **Propuesta por defecto:** conservar
      las 9 secciones para consistencia con el resto de la ruta. *(pendiente)*
- [ ] **Meilisearch vs Typesense** como motor de búsqueda de la Fase 7: la lista
      maestra fija Meilisearch; confirmar que no se cambia. *(pendiente)*
- [ ] **`replica set` de un nodo** para habilitar Change Streams en Fase 10:
      confirmar que el Compose lo levanta así desde el inicio para no reconfigurar
      a mitad de curso. *(pendiente)*

---

## 💭 Consideraciones adicionales

### Couchbase ≠ CouchDB (nota especial, no negociable)
Se reitera porque el error es tentador y caro: **Couchbase** es el rival
documental de *este* curso (C++, N1QL/SQL++, memoria-first, operacional).
**CouchDB** es una familia distinta (Erlang, Apache, replicación offline-first)
que pertenece a otro curso de la ruta. En ningún archivo del curso, en ningún
`docker-compose`, en ninguna referencia, se los mezcla. Si un texto de apoyo los
confunde, se corrige y se marca.

### El costo operativo del modelo (que el curso obliga a nombrar)
El modelo documental no es gratis en operación. La flexibilidad de esquema es
una espada de doble filo: sin `$jsonSchema` disciplinado, la heterogeneidad
degenera en caos ("cada documento con la forma que quiso el dev de turno"). El
techo de 16 MB por documento es real y hay que diseñarlo (por eso el bucket
pattern). Y un sistema políglota —el destino de la Fase 12— multiplica la
superficie operativa: cada motor suma sus propios backups, su guardia, su curva
de aprendizaje y un problema nuevo de consistencia entre motores. El curso
nombra ese costo en cada fase donde aparece; el veredicto final lo suma.

### Los límites de la analogía con SQL
El lector llega con diez años de instintos relacionales, y el curso los honra
sin idolatrarlos. Varios **viajan igual** (índices, selectividad, `explain()`,
el N+1 sigue siendo N+1) y el 🩻 lo celebra para bajar la ansiedad. Otros
**traicionan** (embeber no es normalizar al revés; una transacción
multi-documento no es moneda corriente; el `_id` no es un autoincremental) y el
🪞 los nombra *antes* de que el lector caiga. La analogía es un andamio, no una
verdad: en algún punto se retira y el modelo se sostiene solo.

### Cómo se valida contra un mercado real (productizable ✅ Fuerte)
Un catálogo multi-vertical con PIM no es un ejercicio de laboratorio: es un
producto que existe y se vende. Plataformas de e-commerce, sistemas PIM
comerciales y catálogos de marketplace resuelven hoy exactamente este problema
—atributos heterogéneos por categoría que evolucionan sin migración—, y varios
lo hacen sobre motores documentales por las razones que el curso mide. Eso ancla
el aprendizaje a una necesidad de negocio verificable: al terminar, el lector no
solo sabe modelar en documentos, sabe **defender con números** por qué un
catálogo así vive mejor en documento que en EAV, y por qué la contabilidad del
mismo sistema no.
