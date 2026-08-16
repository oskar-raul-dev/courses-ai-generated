# 🔍 Proyecto Buscafino — Semilla del curso (Búsqueda de texto)

## 🎯 Motivación

Hay un momento en la vida de casi todo sistema en el que alguien pega un
`WHERE title ILIKE '%zapato%'` en producción, funciona para la demo, y seis
meses después el equipo descubre que "buscar" nunca fue el problema que creían
resolver. Porque la búsqueda de texto libre no es un `WHERE` más caro: es un
patrón de acceso distinto, con una pregunta distinta en el centro. Un `WHERE`
responde *"¿qué filas cumplen exactamente esta condición?"*. Una búsqueda
responde *"¿qué documentos son **más relevantes** para estas palabras, en qué
orden, y cuántos hay de cada tipo si filtro por marca, por precio, por
categoría — recalculado en cada tecla que el usuario pulsa?"*. Son universos
de acceso diferentes, y confundirlos es el error que este curso desarma.

El modelo relacional puede hacer búsqueda de texto. Postgres con un índice
GIN sobre `tsvector` es, para volúmenes moderados, una solución perfectamente
sensata — y este curso la usa como control, en serio, midiéndola, no como
hombre de paja. Pero hay tres cosas que un motor de búsqueda dedicado trata
como problema de primera clase y que lo relacional resuelve con creciente
incomodidad a medida que suben el volumen y las expectativas del usuario. La
primera es la **relevancia** como cálculo con muchas señales combinables
—frecuencia de término, proximidad, frescura, popularidad del documento,
campos con peso distinto— en vez de una coincidencia binaria "matchea o no
matchea". La segunda son las **facetas**: los conteos agregados por cada
filtro disponible ("Marca: Nike (240), Adidas (180)…"), recalculados en cada
búsqueda sobre índices invertidos diseñados exactamente para eso, no
reconstruidos con un `GROUP BY` por faceta que multiplica el trabajo. La
tercera es la **tolerancia a errores**: búsqueda difusa, fonética, por
prefijos, autocompletado que perdona un dedo torpe — nativa, no un `pg_trgm`
pegado con cinta.

Lo que un ingeniero senior de bases relacionales gana al dominar este modelo
no es "otro almacén de datos". Es dejar de cometer un error de arquitectura
específico y caro: montar la experiencia de búsqueda de un producto sobre el
motor transaccional, y descubrir tarde que las consultas de búsqueda compiten
por los mismos recursos que las escrituras del negocio, que el ranking es
imposible de ajustar sin reescribir SQL, y que cada faceta nueva es otro
`GROUP BY` en el camino caliente. Dominar el modelo de búsqueda te habilita
proyectos que antes esquivabas —buscadores de e-commerce con facetas
combinadas, buscadores documentales con relevancia ajustable, autocompletado
tolerante a errores a escala— y, sobre todo, te da el criterio para saber
**cuándo tu Postgres ya basta y cuándo no**, con números en la mano en vez de
con fe. Ese criterio es el producto real de este curso.

Hay una idea que vas a leer tantas veces que terminará siendo instinto: el
motor de búsqueda **casi nunca es la fuente de verdad**. Es un **índice
derivado**, reconstruible en cualquier momento a partir del sistema
transaccional real. Todo el curso está construido alrededor de esa frase, y
el villano (más abajo) es precisamente quien la olvida.

---

## 🏗️ El dominio: un servicio de búsqueda facetada reutilizable

Buscafino es un **servicio de búsqueda** —una pieza que se enchufa delante de
un sistema que ya existe— con tres promesas: relevancia ajustable,
autocompletado tolerante a errores, y facetas que cuentan bien. Lo
construimos sobre un corpus realista y deliberadamente heterogéneo en su
texto: un **catálogo de productos de marketplace** (títulos, descripciones,
marcas, categorías, atributos, precios, stock), que es el caso donde la
búsqueda facetada se gana el pan todos los días. El corpus es concreto
porque un buscador se mide con datos concretos: sinónimos ("zapatilla" /
"tenis" / "championes"), errores típicos de tecleo, nombres de marca que la
gente escribe de diez formas, y descripciones largas donde la proximidad de
términos importa.

El punto pedagógico clave es que **Buscafino no posee sus datos**. Los
productos viven en una base transaccional —Postgres, el sistema de verdad— y
Buscafino mantiene un índice que refleja ese catálogo y se puede tirar y
reconstruir entero cuando haga falta. Esa separación no es un detalle de
implementación: es la lección central del modelo, y el dominio la exhibe de
forma natural porque un catálogo de productos **tiene** una fuente de verdad
obvia (el sistema de inventario/pedidos) que nadie en su sano juicio pondría
dentro del motor de búsqueda.

### Por qué este dominio exhibe el patrón de búsqueda de forma natural

Un catálogo de marketplace concentra, sin forzar nada, las tres señas de
identidad del modelo. **Relevancia:** cuando alguien escribe "auriculares
inalámbricos baratos", el orden de resultados no es alfabético ni por fecha —
es por una mezcla de coincidencia de términos, peso del campo (un match en el
título vale más que en la descripción), y señales de negocio (popularidad,
stock, margen). **Facetas:** la barra lateral de "Marca / Precio / Color /
Valoración" con sus conteos es literalmente el problema de facetas, y esos
conteos deben reflejar el resultado filtrado actual, recalculados por
consulta. **Tolerancia a errores:** los usuarios escriben mal, escriben a
medias, escriben en spanglish; el autocompletado y la búsqueda difusa no son
lujo, son la diferencia entre una venta y un rebote.

### El marco de 5 preguntas, aplicado ANTES de modelar

Antes de tocar un solo índice, pasamos el dominio por el mismo tamiz que
cualquier decisión de arquitectura seria. La tabla es el veredicto, no la
opinión.

| Pregunta | Veredicto para Buscafino |
|---|---|
| ¿Qué se lee junto? | El resultado de búsqueda: un puñado de documentos rankeados + los conteos de facetas de esa misma consulta. Todo se computa junto, en un solo golpe. |
| ¿Quién custodia la forma / las invariantes? | **Postgres, no Buscafino.** El motor de búsqueda es un espejo derivado; las invariantes de negocio (precio válido, stock ≥ 0, producto existe) viven en el transaccional. |
| ¿Cuánto se une en caliente? | Casi nada en el índice: el documento de búsqueda se **desnormaliza** al indexar (se aplanan marca, categoría, atributos) justo para no unir nada al consultar. |
| ¿Dónde viven las invariantes? | En el sistema de verdad (Postgres). El índice puede estar momentáneamente desincronizado y **eso es aceptable por diseño** — es un índice, no un libro mayor. |
| ¿Qué pide la operación? | Lectura dominante y latencia baja (búsqueda interactiva, autocompletado por tecla); escritura = reindexado incremental; evolución constante de ranking y facetas sin downtime. |

**Veredicto: vota búsqueda dedicada — pero con un asterisco honesto.** No es
un 5-0 como el de un catálogo documental. Para volumen moderado y relevancia
simple, **Postgres+GIN gana por operar menos** (un motor menos que cuidar), y
el curso lo demuestra midiendo. El voto se vuelve claro solo cuando entran en
juego relevancia multi-señal ajustable, facetas con conteos por consulta a
escala, y tolerancia a errores nativa. La honestidad de ese asterisco es
justamente lo que separa este curso de un folleto de Elastic.

### El villano del curso: el índice que se cree fuente de verdad

Cada curso de esta ruta tiene su anti-patrón, y el de Buscafino es
particularmente traicionero porque **funciona en la demo**. El villano es
tratar el motor de búsqueda como **fuente de verdad** en vez de como índice
derivado reconstruible: escribir primero (o solo) en Elasticsearch, guardar
ahí datos que no viven en ningún otro lado, aceptar pedidos de escritura que
el motor de búsqueda no está diseñado para garantizar. El síntoma llega el día
que el índice se corrompe, se queda sin espacio, o hay que cambiar el mapping:
si era la fuente de verdad, acabas de perder datos y no hay reconstrucción
posible. El curso lo bautiza y lo persigue hasta el final —lo llamaremos el
patrón **"source-of-truth-in-the-index"**— y en la fase de autopsia lo mide:
cuánto cuesta (en pérdida de datos, en tiempo de recuperación, en imposibilidad
de reindexar) haber puesto el negocio dentro del índice. El antídoto se instala
en la Fase 1 y se repite como mantra: **el índice se reconstruye desde el
transaccional en cualquier momento; si no puedes tirarlo y regenerarlo, lo
estás usando mal.**

---

## 📐 Stack (2026, estable y moderno)

Todo el stack es open source, contenerizado y multiplataforma (Linux, macOS,
Windows vía WSL2). Nada de nostalgia legacy: son las versiones estables
vigentes a mediados de 2026. Los rivales del "vs" **entran en el mismo
`docker-compose` desde la Fase 0**, porque la comparación se construye en
paralelo, no al final.

| Componente | Versión / elección | Rol |
|---|---|---|
| Meilisearch | **v1.43.x** | Motor de búsqueda principal del curso — Rust, developer-first, instant-search y typo-tolerance de fábrica |
| Elasticsearch | **9.5.x** | Rival de referencia "industrial" — Lucene, relevancia y facetas de máxima potencia, máximo peso operativo |
| OpenSearch | **3.6.x** | El fork Apache 2.0 de Elastic — mismo linaje Lucene, gobernanza abierta; el contraste de licencia importa tanto como el técnico |
| Typesense | **v30.x** | Rival "moderno ligero" — C++, foco en QPS alto y latencia baja; contrapunto directo a Meilisearch |
| PostgreSQL | **18.x** | Control relacional obligatorio (GIN + `tsvector` + `pg_trgm`) y fuente de verdad del corpus |
| Node.js | **24 LTS** | Runtime del servicio y del arnés |
| TypeScript | **6.0.x** | Tipado en todo el backend, incluido `scripts/vs.ts` |
| Express | **5.x** | API del servicio Buscafino (búsqueda, autocompletado, facetas) |
| Zod | última | Validación de aplicación de queries y payloads en la frontera de la API |
| Docker / Podman | última | Todo contenerizado; un `compose` levanta los cinco motores |

### Por qué Meilisearch como motor principal (y no Elasticsearch)

La decisión pedagógica pesa más que la de producción aquí. Meilisearch te pone
de cero a un buscador con relevancia decente, typo-tolerance y facetas en
menos de una hora, con una API REST que se lee sin manual. Eso deja el foco
del curso donde debe estar —en los **conceptos** del modelo (relevancia,
facetas, índice derivado)— y no en pelear tres días con mappings, analyzers y
JVM tuning antes de ver el primer resultado ordenado. Elasticsearch es más
potente y el curso lo respeta y lo mide, pero como motor de enseñanza tiene un
costo de arranque que se come el presupuesto de atención del estudiante. La
regla es: aprende el modelo en el motor que menos se interpone, luego contrasta
contra el que más potencia (y más peso) ofrece.

### Por qué estos cuatro motores de búsqueda (y no uno)

Porque el curso enseña un **modelo**, no un producto, y la única forma honesta
de mostrar la frontera del modelo es medir varios exponentes contra el mismo
arnés. Meilisearch y Typesense representan la generación "ligera de operar,
funcionalidad acotada"; su duelo directo (Rust vs C++, developer-UX vs QPS
crudo) enseña que "motor ligero" no es una sola cosa. Elasticsearch y
OpenSearch representan la potencia Lucene completa, y su presencia conjunta
obliga a hablar del **episodio de licencia** de 2021 (Elastic pasó de Apache
2.0 a licencias source-available; OpenSearch nació como fork Apache 2.0 de la
comunidad). Elegir motor en 2026 es también elegir gobernanza, y la ruta no
elude esa conversación. PostgreSQL cierra el cuadro como el recordatorio
permanente de que a veces **no necesitas ningún motor de búsqueda nuevo**.

### Por qué TypeScript + Node y no Python

El servicio es un backend de API interactivo, no un pipeline analítico: Node
24 LTS con Express 5 es el terreno natural, y TypeScript da el tipado que hace
mantenible tanto el servicio como el arnés `vs.ts`. Los cuatro motores de
búsqueda tienen SDKs de JS/TS de primera clase, así que el mismo lenguaje
sirve para el servicio, el generador de datos y el harness de benchmark sin
cambiar de contexto. (Si en alguna fase conviene un cliente de un motor que
brille más en otra lengua, se documenta como nota, no como cambio de stack.)

### Validación en capas y tooling transversal

**Zod** valida en la frontera de la API lo que entra (la query, los filtros de
faceta, los parámetros de paginación) antes de traducirlo al lenguaje de cada
motor — un buscador recibe input de usuario crudo y hostil, y esa frontera es
donde se sanea. El **generador de datos** produce el mismo corpus semántico
para los cinco motores, de modo que ninguna comparación se contamina por
datasets distintos. Y el **arnés `scripts/vs.ts`** (siguiente sección) es la
única boca autorizada para afirmar "X es más rápido/mejor que Y".

---

## ⚖️ El método del "vs": un arnés, no anécdotas

`scripts/vs.ts` es el juez del curso. Toma **la misma consulta semántica**
—por ejemplo, "auriculares inalámbricos" con faceta de marca y orden por
relevancia— la traduce al dialecto de cada motor en juego, la ejecuta N veces
contra cada uno sobre el **mismo corpus generado**, cronometra (p50, p95,
latencia de cola), registra la calidad del resultado donde sea medible
(¿aparece el documento esperado en el top-k? ¿los conteos de faceta cuadran?),
y **acumula todo en `BENCHMARKS.md`**. Ninguna afirmación comparativa del
curso existe fuera de ese archivo: si no está medido con `vs.ts`, no se dice.

Los duelos que atraviesan el curso, todos medidos:

1. **Meilisearch vs PostgreSQL+GIN** — el eje honesto: ¿cuándo el motor
   dedicado gana de verdad y cuándo Postgres ya basta? Se mide relevancia,
   facetas y typo-tolerance a volumen creciente.
2. **Meilisearch vs Typesense** — ligero vs ligero: developer-UX y relevancia
   por defecto contra QPS crudo y latencia de cola bajo carga.
3. **Elasticsearch vs OpenSearch** — potencia Lucene vs potencia Lucene: qué
   diverge de verdad entre el original y su fork, más allá de la licencia.
4. **Ligeros (Meili/Typesense) vs industriales (ES/OpenSearch)** — el duelo de
   generaciones: cuándo la potencia completa de Lucene se justifica y cuándo es
   sobre-ingeniería que pagas en operación.

---

## 🌳 Estructura de fases

Doce fases. La Fase 0 monta el laboratorio contenerizado y el generador de
datos y hace nacer `vs.ts`; la última hace la autopsia medida del villano y
entrega el veredicto honesto de cuándo NO usar un motor de búsqueda dedicado.
El número (12) se justifica solo: el modelo tiene tres pilares (relevancia,
facetas, tolerancia a errores) que merecen fase propia cada uno, más la
disciplina del índice derivado (indexado, sincronización, reconstrucción) que
es el corazón conceptual y necesita su propio espacio.

| # | Fase | Núcleo | "Vs" de la fase |
|---|---|---|---|
| **0** | 🧪 El laboratorio de cinco motores | `compose` con Meili + ES + OpenSearch + Typesense + Postgres. Generador de corpus semántico común. Nace `scripts/vs.ts` | — (montaje) |
| **1** | 🧭 El índice derivado: el mantra fundacional | Se define la fuente de verdad (Postgres) y el primer indexado full. Se instala "el índice se tira y se reconstruye" | Indexar full en Meili vs construir GIN en Postgres — tiempo de indexado |
| **2** | 🎯 Relevancia I: por qué el orden no es alfabético | Modelo de puntuación, campos con peso, `tsvector` con pesos vs ranking de Meili | Postgres `ts_rank` vs relevancia por defecto de Meili — calidad del top-k |
| **3** | 🎛️ Relevancia II: ajustar el ranking sin reescribir SQL | Ranking rules, boost por campo y por señal de negocio (frescura, popularidad) | Ajuste de ranking en Meili/ES vs reescribir la expresión `ts_rank` en SQL |
| **4** | 🧩 Facetas: contar bien lo filtrado | `facets` sobre índice invertido; conteos por consulta que reflejan el filtro actual | `GROUP BY` por faceta en Postgres vs facetas nativas — costo por faceta añadida |
| **5** | 🔀 Filtros combinados y navegación facetada | Filtros AND/OR sobre facetas, rangos de precio, sin perder los conteos | SQL con múltiples `WHERE`+`GROUP BY` vs `filter`+`facets` de un golpe |
| **6** | 🩹 Tolerancia a errores: typos, prefijos, fonética | Búsqueda difusa y autocompletado por prefijo tolerante a error | `pg_trgm` en Postgres vs typo-tolerance nativa — recall y latencia |
| **7** | ⌨️ Autocompletado a velocidad de tecleo | Sugerencias por tecla, latencia de cola como requisito de UX | Meili vs Typesense — p95/p99 bajo ráfaga de teclas |
| **8** | 🔁 Sincronización: mantener el espejo al día | Reindexado incremental desde Postgres; el patrón outbox / CDC; qué hacer ante desincronización | Reindex incremental vs full — costo y ventana de inconsistencia |
| **9** | 🧱 Reconstrucción y zero-downtime reindex | Tirar el índice y regenerarlo con alias/swap sin cortar el servicio | Swap de alias en ES/OpenSearch vs recrear índice en Meili — downtime observado |
| **10** | 🏋️ Los industriales a fondo: cuándo la potencia se justifica | Analyzers, multi-idioma, agregaciones complejas que los ligeros no cubren | ES/OpenSearch vs Meili/Typesense — capacidad vs peso operativo |
| **11** | ⚰️ La autopsia del villano y ⚖️ el veredicto | El índice-como-fuente-de-verdad medido de punta a punta (corrupción → pérdida; reindex imposible). Árbol de decisión de cuándo NO usar motor dedicado | El ritual de cierre, con números antes/después |

### Fase 0 — El laboratorio de cinco motores

Levanta el `docker-compose` con los cinco servicios y verifica que cada uno
responde. Construye el **generador de datos**: una función que produce el
mismo corpus semántico (N productos con títulos, descripciones, marcas,
categorías, atributos, precios) y lo carga tanto en Postgres (la fuente de
verdad) como, vía indexado, en los motores de búsqueda. Nace `scripts/vs.ts`
con su primera medición trivial (un `find` por id) para validar que el arnés
cronometra y escribe en `BENCHMARKS.md`. No se enseña búsqueda todavía: se
enseña que el laboratorio es reproducible.

### Fase 1 — El índice derivado: el mantra fundacional

Aquí se instala la idea que rige el curso. Postgres es la fuente de verdad;
todo lo demás es espejo. Se hace el primer **indexado full** desde Postgres
hacia Meilisearch y se construye el índice GIN en Postgres. 📖 Aparece el
diccionario de traducción inicial (SQL `LIKE`/`tsvector` ↔ query de motor).
🪞 Primer instinto falsable: *"indexar diez millones de docs será dolorosamente
lento en el motor dedicado"* → se mide contra construir el GIN, y el resultado
suele sorprender. El recuadro 🩻 "esto sí viaja igual" recuerda que el concepto
de índice, su costo de construcción y su necesidad de mantenimiento son
exactamente lo que ya sabías de SQL.

### Fase 2 — Relevancia I: por qué el orden no es alfabético

El primer pilar. Se explica que "relevancia" es una puntuación, no un boolean,
y que campos distintos pesan distinto (un término en el título vale más que en
la descripción). Se compara `ts_rank` con pesos de Postgres contra el ranking
por defecto de Meili, midiendo **calidad** del top-k con un set de consultas de
verdad esperada, no solo latencia. 🪞 Instinto a recalibrar: *"con un buen
`ORDER BY` reproduzco cualquier ranking"* — y esta vez el `ORDER BY` se queda
corto cuando las señales se multiplican.

### Fase 3 — Relevancia II: ajustar el ranking sin reescribir SQL

El segundo golpe al instinto. En Postgres, cambiar el ranking es reescribir la
expresión `ts_rank` y sus pesos, redeployar, rezar. En un motor dedicado, las
**ranking rules** y los boosts son configuración ajustable en caliente, y se
pueden incorporar señales de negocio (frescura, popularidad, stock) como
factores del score. Se mide el esfuerzo de iterar el ranking, no solo su
resultado — porque el costo de cambio es una propiedad arquitectónica real.

### Fase 4 — Facetas: contar bien lo filtrado

El tercer pilar. Las facetas son conteos agregados por filtro, recalculados
por consulta, sobre índices invertidos hechos para eso. Se implementa la barra
lateral de "Marca / Categoría / Precio" con sus conteos y se contrasta contra
el `GROUP BY` por faceta de Postgres. El "vs" mide el **costo marginal de cada
faceta añadida**: en el motor dedicado tiende a ser barato; en SQL, cada faceta
es otra agregación en el camino caliente. ⚰️ Primera aparición del olor del
villano si alguien propone "guardemos los conteos precalculados en el índice y
listo".

### Fase 5 — Filtros combinados y navegación facetada

Facetas de verdad: el usuario clica "Nike" y "menos de $50" y espera resultados
filtrados **con los conteos de las demás facetas recalculados** para ese
subconjunto. Se implementan filtros AND/OR y rangos, y se mide contra el SQL
equivalente (varios `WHERE` más varios `GROUP BY`) que en el motor dedicado es
un solo `filter`+`facets`.

### Fase 6 — Tolerancia a errores: typos, prefijos, fonética

La búsqueda difusa como funcionalidad nativa. Se compara la typo-tolerance de
fábrica de Meili/Typesense contra `pg_trgm` en Postgres, midiendo **recall**
(¿encuentra "auriculres" lo mismo que "auriculares"?) y latencia. 🩻 Recuadro:
la noción de distancia de edición y de índice trigram existe en ambos mundos;
lo que cambia es si viene armado o hay que ensamblarlo.

### Fase 7 — Autocompletado a velocidad de tecleo

El autocompletado impone un requisito que la búsqueda normal no: latencia de
cola bajísima, porque se dispara en cada tecla. Aquí el duelo estrella es
**Meilisearch vs Typesense**, midiendo p95/p99 bajo ráfagas de tecleo. Se
instala que "rápido en promedio" no basta: la UX de autocompletado la define
la cola, no la media.

### Fase 8 — Sincronización: mantener el espejo al día

Cómo el índice derivado se mantiene fresco sin reindexar todo cada vez.
Reindexado incremental desde Postgres, el patrón **outbox** y una mirada a
CDC (change data capture). Se nombra sin miedo la **ventana de inconsistencia**
—el índice va un poco por detrás de la verdad, y eso está bien— y se mide su
tamaño. 🪞 Instinto: *"tiene que estar sincronizado al milisegundo"* — no, es un
índice, no un libro contable; la consistencia eventual es la feature, no el bug.

### Fase 9 — Reconstrucción y zero-downtime reindex

La prueba de fuego del mantra: tirar el índice entero y regenerarlo desde
Postgres **sin cortar el servicio**, usando alias/swap. Si el índice fuera la
fuente de verdad, esto sería imposible; como es derivado, es rutina. Se mide el
downtime observado del swap de alias en ES/OpenSearch frente a recrear en Meili.
Esta fase es la refutación práctica del villano antes de su autopsia formal.

### Fase 10 — Los industriales a fondo: cuándo la potencia se justifica

Se abren las capacidades que Meili/Typesense no cubren: analyzers a medida,
multi-idioma serio, agregaciones complejas, pipelines de ingest. El "vs" no es
"quién gana" sino "qué compras y qué pagas": la potencia de Lucene contra su
peso operativo (JVM, sharding, tuning). El estudiante sale sabiendo reconocer
el punto donde un ligero deja de alcanzar — y el punto donde el industrial es
sobre-ingeniería.

### Fase 11 — La autopsia del villano y el veredicto

⚰️ El anti-patrón medido de punta a punta: un Buscafino donde el índice guarda
datos que no viven en Postgres. Se corrompe el índice a propósito y se mide qué
se pierde y cuánto cuesta recuperar (spoiler: si era la fuente de verdad, no se
recupera). Luego el ⚖️ **veredicto honesto**: el árbol de decisión de cuándo NO
montar un motor de búsqueda dedicado (volumen moderado + relevancia simple =
Postgres+GIN y a otra cosa). Se cierra `INSTINTOS.md` y `BENCHMARKS.md` con el
balance completo del curso.

### Apéndices

- **Apéndice A — Arranque de los cinco motores vía contenedores.** Requisitos
  de memoria (ojo con la JVM de ES/OpenSearch), healthchecks, y el orden de
  arranque. Troubleshooting del "por qué Elasticsearch no levanta" (casi
  siempre `vm.max_map_count` o RAM).
- **Apéndice B — `docker-compose.yml` de trabajo.** El compose completo y
  comentado, con volúmenes para persistir índices entre reinicios y perfiles
  para levantar solo los motores que una fase necesita.
- **Apéndice C — Guía rápida de los lenguajes de consulta.** Un lado a lado de
  cómo se expresa la misma búsqueda facetada en Meili, en el Query DSL de
  ES/OpenSearch, en Typesense y en SQL+GIN. Referencia, no tutorial.
- **Apéndice D — El generador de datos.** Cómo produce el corpus semántico
  común, cómo se siembran sinónimos y errores típicos a propósito, y cómo se
  escala el volumen para las mediciones.
- **Apéndice E — Troubleshooting de setup.** Los baches clásicos: mappings que
  no cuadran, analyzers que no tokenizan como esperas, conteos de faceta que no
  suman, índices que quedaron a medias tras un reindex interrumpido.

---

## 📓 Artefactos acumulativos

`INSTINTOS.md` es el diario de reeducación del instinto relacional. Cada vez
que el curso enfrenta una intuición SQL a la realidad del modelo de búsqueda,
la registra con tres partes: la **predicción** ("esto será más lento que un
`ILIKE`"), el **experimento cronometrado** (con `vs.ts`), y el **veredicto
escrito** (acertaste, fallaste, o "depende, y aquí está de qué"). Crece fase a
fase y al final es un mapa honesto de dónde el instinto SQL sirve y dónde
engaña, específico para búsqueda.

`BENCHMARKS.md` es la memoria de todas las mediciones. Cada "vs" que el curso
afirma vive aquí con su corpus, su consulta, sus tiempos (p50/p95/p99), su
medición de calidad cuando aplica, y la versión de cada motor usada. Es
acumulativo y append-only: una fase posterior puede citar la medición de una
anterior, pero no borrarla. Juntos, `INSTINTOS.md` (lo que creías) y
`BENCHMARKS.md` (lo que midió el cronómetro) son el contrapeso que evita que el
curso caiga en fanboyismo de cualquier bando.

---

## 📚 Referencias por fase (semilla)

> ⚠️ **Todas las URLs, títulos e IDs de video de abajo deben verificarse antes
> de publicar.** No se inventan números de página, DOIs ni IDs de YouTube. Las
> versiones de la documentación deben coincidir con las fijadas en el stack; si
> un enlace apunta a otra versión, se advierte en el texto.

**Fase 0 — Laboratorio**
- Docker Compose (docs oficiales): https://docs.docker.com/compose/ *(verificar)*
- Meilisearch — Quick start: https://www.meilisearch.com/docs/learn/getting_started/quick_start *(verificar)*
- Elasticsearch — Run with Docker: https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html *(verificar)*
- OpenSearch — Docker install: https://opensearch.org/docs/latest/install-and-configure/install-opensearch/docker/ *(verificar)*
- Typesense — Install: https://typesense.org/docs/ *(verificar versión v30.x)*
- Orden de lectura: quick start de Meili → compose de Docker → los demás motores en paralelo.

**Fase 1 — Índice derivado**
- PostgreSQL Full Text Search: https://www.postgresql.org/docs/18/textsearch.html *(verificar)*
- Meilisearch — Indexing / documents: https://www.meilisearch.com/docs/learn/getting_started/documents *(verificar)*
- Orden de lectura: FTS de Postgres primero (terreno conocido) → indexado en Meili.

**Fases 2–3 — Relevancia**
- PostgreSQL — `ts_rank` y pesos: https://www.postgresql.org/docs/18/textsearch-controls.html *(verificar)*
- Meilisearch — Ranking rules: https://www.meilisearch.com/docs/learn/relevancy/ranking_rules *(verificar)*
- Elasticsearch — Relevance / BM25: https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules-similarity.html *(verificar)*
- Libro (verificar edición vigente): *Relevant Search* (Turnbull & Berryman), Manning — conceptual, sigue vigente aunque los ejemplos sean de ES antiguo.
- Orden de lectura: capítulo conceptual de relevancia → ranking rules de Meili → similarity de ES.

**Fases 4–5 — Facetas**
- Meilisearch — Faceted search: https://www.meilisearch.com/docs/learn/filtering_and_sorting/search_with_facet_filters *(verificar)*
- Elasticsearch — Aggregations / facets: https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations.html *(verificar)*
- Orden de lectura: facetas de Meili (simple) → aggregations de ES (potente).

**Fase 6 — Tolerancia a errores**
- PostgreSQL `pg_trgm`: https://www.postgresql.org/docs/18/pgtrgm.html *(verificar)*
- Meilisearch — Typo tolerance: https://www.meilisearch.com/docs/learn/relevancy/typo_tolerance_settings *(verificar)*
- Orden de lectura: `pg_trgm` (lo conocido) → typo tolerance nativa.

**Fase 7 — Autocompletado**
- Typesense — Search / prefix: https://typesense.org/docs/latest/api/search.html *(verificar)*
- Meilisearch — Search parameters: https://www.meilisearch.com/docs/reference/api/search *(verificar)*
- Orden de lectura: parámetros de búsqueda de ambos → medir p95/p99.

**Fase 8 — Sincronización**
- Debezium / CDC (concepto): https://debezium.io/documentation/ *(verificar)*
- Patrón outbox (artículo de referencia — *verificar título y autor antes de citar*).
- Orden de lectura: concepto de outbox → CDC como industrialización.

**Fase 9 — Reconstrucción / zero-downtime**
- Elasticsearch — Index aliases: https://www.elastic.co/guide/en/elasticsearch/reference/current/aliases.html *(verificar)*
- OpenSearch — Index aliases: https://opensearch.org/docs/latest/im-plugin/index-alias/ *(verificar)*
- Orden de lectura: alias en ES → equivalente en OpenSearch → swap en Meili.

**Fase 10 — Industriales a fondo**
- Elasticsearch — Analysis / analyzers: https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis.html *(verificar)*
- OpenSearch — Text analysis: https://opensearch.org/docs/latest/analyzers/ *(verificar)*
- Orden de lectura: analyzers → multi-idioma → aggregations complejas.

**Fase 11 — Autopsia y veredicto**
- Relectura crítica de todo `BENCHMARKS.md` e `INSTINTOS.md` del curso.
- Video/apoyo: charla de conferencia sobre "search as a derived index" o
  "don't use Elasticsearch as your primary datastore" — *buscar y verificar
  título, ponente e ID antes de citar; no inventar*.

---

## 🧪 Nota sobre ejercicios

Cada fase lleva entre **20 y 40 ejercicios**, graduados 🟢🟡🟠🔴 (fácil → muy
difícil), todos anclados al dominio de Buscafino (productos, marcas, facetas,
consultas reales de usuario). Al menos un puñado por fase son de
**diagnóstico**: se entrega un bug —conteos de faceta que no suman, un ranking
que pone lo irrelevante arriba, un índice que quedó a medias tras un reindex
interrumpido, un autocompletado que se dispara a 400 ms— y se pide reproducir
y localizar, no solo construir. Los 🔴 exigen integrar varias fases o medir
algo esquivo (una cola de latencia bajo carga, una ventana de inconsistencia,
la degradación de recall al subir la tolerancia a typos). Distribución
sugerida para una fase de ~30: ~8 🟢, ~9 🟡, ~8 🟠, ~5 🔴, más los 🔥 opcionales
aparte.

---

## 🧩 Decisiones pendientes de confirmar antes de redactar la Fase 0

- [ ] **Corpus semilla:** ¿dataset sintético generado (control total sobre
      sinónimos y errores sembrados) o un dataset público de productos adaptado
      (más realista, menos controlable)? *Propuesta por defecto: sintético
      generado, para poder inyectar typos y sinónimos a voluntad y medir recall
      con verdad esperada conocida. Pendiente de confirmar.*
- [ ] **¿Los cuatro motores desde la Fase 0, o escalonados?** El compose los
      soporta a todos, pero ES+OpenSearch pesan en RAM. *Propuesta: Meili +
      Postgres desde Fase 0; Typesense entra en Fase 7 (autocompletado);
      ES/OpenSearch entran fuertes en Fase 10, montados opcionalmente antes vía
      perfil de compose para quien tenga RAM. Pendiente.*
- [ ] **¿El sistema transaccional (Postgres) se implementa de verdad o se
      simula?** *Propuesta: Postgres real y mínimo (tabla de productos + outbox)
      porque el mantra del índice derivado pierde fuerza si la fuente de verdad
      es de mentira. Pendiente.*
- [ ] **Sincronización en Fase 8:** ¿outbox propio a mano, o CDC con Debezium?
      *Propuesta: outbox a mano primero (se entiende el mecanismo), CDC como
      ampliación 🔥. Pendiente.*
- [ ] **Multi-idioma:** ¿el corpus es solo español, o español + inglés para
      ejercitar analyzers de la Fase 10? *Propuesta: español como base, un
      subconjunto bilingüe para la Fase 10. Pendiente.*
- [ ] **Formato de fase:** ¿se mantiene la plantilla de 9 secciones del estilo
      de la ruta o se ajusta por ser un curso de servicio (menos "entidades",
      más "endpoints")? *Propuesta: 9 secciones, adaptando "modelado de datos" a
      "modelado de índice y mapping". Pendiente.*

---

## 💭 Consideraciones adicionales

### El costo operativo real del modelo

Adoptar un motor de búsqueda dedicado es sumar una superficie operativa
completa: otro servicio que monitorear, otro que respaldar (aunque —lección
del curso— si es índice derivado, el "backup" es reconstruir desde el
transaccional), otra curva de aprendizaje, y una fuente nueva de inconsistencia
(el índice va por detrás de la verdad). Elasticsearch/OpenSearch añaden encima
el peso de la JVM y el sharding. El curso obliga a nombrar ese costo en cada
"vs": la pregunta nunca es solo "¿es más rápido?" sino "¿vale el motor extra
que voy a operar un martes a las 3 am?".

### Los límites de la analogía con SQL

El índice invertido no es un índice B-tree con esteroides: es una estructura
distinta que mapea término → documentos, y por eso la relevancia y las facetas
son baratas donde en SQL son caras. Pero la analogía inversa también engaña: el
motor de búsqueda **no** te da transacciones, ni joins arbitrarios, ni
integridad referencial. Cada vez que el instinto SQL pida una garantía
transaccional del índice, el curso responde lo mismo: eso vive en Postgres, el
índice es un espejo. Nombrar ese límite temprano y a menudo es lo que evita al
estudiante el error del villano.

### {NOTAS_ESPECIALES} — el patrón "índice derivado, nunca fuente de verdad"

Esta es la nota especial del curso y merece decirse sin rodeos: Buscafino
existe, en buena medida, para instalar **un solo patrón** hasta que sea
reflejo. El motor de búsqueda es un índice **derivado, reconstruible en
cualquier momento a partir del sistema transaccional**, y **nunca** la fuente
de verdad. El patrón se enuncia en la Fase 1, se pone a prueba en la Fase 9
(reconstruir sin downtime), se viola a propósito y se mide el daño en la Fase
11 (la autopsia del villano), y se repite en cada fase intermedia como criterio
de diseño. Si el estudiante sale del curso recordando una sola frase, que sea
esta: *si no puedes tirar tu índice de búsqueda y regenerarlo entero desde tu
base de verdad, no tienes un índice de búsqueda — tienes una bomba de tiempo
que además busca mal.*

### Cómo se valida contra un mercado real (productizable ✅ Fuerte)

Buscafino no es un juguete de laboratorio: es la forma de una categoría de
producto real. Existe un mercado vivo de "búsqueda como servicio" —Algolia como
referencia comercial dominante, y toda una generación de alternativas
self-hosted (Meilisearch, Typesense) posicionadas explícitamente como
sustitutos más ligeros y económicos. Un servicio de búsqueda facetada
reutilizable, medido y con criterio de cuándo cada motor conviene, es
exactamente lo que un equipo de producto necesita construir o comprar. El curso
ancla cada decisión a esa realidad de mercado, de modo que el estudiante termine
no solo sabiendo búsqueda, sino sabiendo **defender una elección de motor de
búsqueda ante un CTO con presupuesto**, con números y no con banderas.
