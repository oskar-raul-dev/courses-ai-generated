# 🦆 Proyecto Cristalería — Semilla del curso (Analítico embebido columnar sin servidor)

## 🎯 Motivación

Hay una pregunta que un motor relacional transaccional responde mal no por
falta de expresividad, sino por decisión de formato físico: *"dame el promedio
de una columna sobre diez millones de filas"*. Postgres puede hacerlo —tiene el
`AVG`, tiene el índice, tiene el optimizador— pero por dentro está guardando
cada fila entera de forma contigua en disco, porque lo diseñaron para el patrón
opuesto: tocar pocas filas y muchas columnas a la vez, que es lo que hace una
transacción. Una consulta analítica invierte esa forma. Toca pocas columnas
pero de casi todas las filas. Y cuando el almacenamiento es por filas, el motor
termina leyendo del disco un montón de columnas que la consulta nunca pidió,
solo porque están pegadas a las que sí.

El modelo de acceso de este curso —**analítico columnar embebido, sin
servidor**— resuelve esa desalineación de raíz: guarda cada columna de forma
contigua, la comprime aprovechando que valores vecinos se parecen, la procesa
en lotes vectorizados, y salta por completo cualquier columna que no aparezca
en el `SELECT`. No es una optimización incremental sobre lo relacional: es otro
formato físico para otro patrón de acceso. La parte "embebida" agrega el
segundo giro: el motor corre **dentro de tu proceso** (tu script de Python, tu
pestaña del navegador), sin un servidor que levantar, sin un puerto que abrir,
sin un clúster que operar. Consulta el archivo Parquet o CSV donde está, en su
formato de origen, sin cargarlo antes a ningún lado.

Para un ingeniero senior que vive en SQL, dominar este modelo cambia dos cosas
concretas. La primera es un error de arquitectura que deja de cometer: montar
un data warehouse pesado —o peor, un clúster de Spark— para una analítica que
en realidad cabe entera en un solo proceso de una laptop. Ese reflejo de "esto
es analítica, entonces necesito infraestructura de analítica" es caro,
lento de operar, y muchas veces innecesario por uno o dos órdenes de magnitud.
La segunda es un proyecto nuevo que ahora puede abordar: analítica que corre
**donde el usuario está** —embebida en una app, en un dashboard, en el propio
navegador vía WebAssembly— sin backend de datos de por medio. Es "la
herramienta correcta" que le faltaba entre "escribo un query en mi warehouse" y
"me traigo todo a pandas y rezo que entre en RAM".

---

## 🏗️ El dominio: Cristalería, un pipeline analítico sin ETL sobre datos públicos

El proyecto se llama **Cristalería** porque su promesa es la transparencia: los
datos se ven tal como llegan, sin una capa de carga opaca que los transforme
antes de que puedas mirarlos. El sistema toma **datasets públicos reales** en su
formato de origen —Parquet y CSV, típicamente los volcados abiertos de una
ciudad o de un organismo (viajes de taxi, vuelos, permisos, precios), donde un
solo archivo ya trae millones de filas— y responde preguntas analíticas sobre
ellos **sin proceso de carga previo**: nada de `CREATE TABLE` seguido de un
`COPY` que tarda horas. Se apunta el motor al archivo y se consulta.

El pipeline tiene tres tramos. Primero, **consulta directa**: agregaciones,
filtros y cruces leídos del archivo en su sitio (local o remoto por HTTP),
midiendo cuánto del archivo se leyó de verdad frente a cuánto ocupa. Segundo,
**transformación y materialización**: cuando una consulta se repite, se
materializa un Parquet derivado —más chico, ya proyectado y ordenado— y se mide
la diferencia. Tercero, **publicación**: un **dashboard que corre enteramente
en el navegador**, sin servidor, compilando el mismo motor a WebAssembly, de
modo que el usuario final ejecuta las consultas en su propia pestaña sobre los
Parquet servidos como archivos estáticos.

### Por qué el dominio exhibe el patrón de acceso de forma natural

El dominio no está forzado a ser columnar: lo es por su forma. Las preguntas
que se le hacen a un volcado público son casi siempre agregaciones sobre pocas
columnas de muchísimas filas ("promedio de propina por hora del día",
"percentil 95 de demora por aerolínea", "conteo de permisos por barrio y año").
Nadie pide "tráeme la fila 4.812.339 completa": eso sería el patrón
transaccional, y aquí no aparece. Los archivos son inmutables —un volcado
mensual no se actualiza fila por fila, se reemplaza entero—, lo que encaja con
un motor que brilla en solo-lectura-por-rango y no necesita el andamiaje
transaccional. Y el volumen es del tamaño exacto de la propuesta de valor:
suficientemente grande para que el formato por filas duela, suficientemente
chico para que un solo proceso lo resuelva sin clúster.

### El marco de 5 preguntas, aplicado ANTES de modelar

| Pregunta | Respuesta en Cristalería |
|---|---|
| **¿Qué se lee junto?** | Pocas columnas, muchísimas filas: una o dos métricas más una o dos dimensiones de agrupación por consulta. Casi nunca la entidad completa. |
| **¿Quién custodia la forma y las invariantes?** | Nadie las custodia en escritura: el dato ya viene fijo desde la fuente (el organismo público). No hay inserción transaccional que validar; el archivo es la verdad y es inmutable. |
| **¿Cuánto se une en caliente?** | Poco y controlado: cruces ocasionales entre dos datasets (viajes × clima, vuelos × aeropuertos), resueltos en el momento del análisis, no en un modelo normalizado permanente. |
| **¿Dónde viven las invariantes?** | En la fuente y en el esquema del Parquet (tipos por columna). No hay invariantes de negocio cruzadas que mantener en el tiempo: es analítica de solo lectura. |
| **¿Qué pide la operación?** | Lectura masiva por rango, latencia interactiva (segundos, no minutos), cero superficie operativa (sin servidor, sin guardia), evolución por reemplazo de archivo. |

**Veredicto: vota analítico-columnar-embebido 5–0.** No hay una sola de las
cinco respuestas que empuje hacia un motor transaccional por filas, ni hacia la
infraestructura pesada de un warehouse. El dominio pide exactamente lo que el
modelo da: leer mucho, escribir nada, unir poco, operar cero. El matiz honesto
—que el curso mide en lugar de afirmar— es el cruce en caliente: ahí un
relacional bien indexado compite, y la fase de joins existe para ver dónde está
esa frontera.

### El villano: levantar infraestructura pesada para lo que cabe en un proceso

El anti-patrón que Cristalería disecciona con autopsia medida es **levantar un
data warehouse pesado —o directamente un clúster de Spark— para una analítica
que cabe entera en un solo proceso**. Es el villano por exceso: el reflejo de
"esto es Big Data" aplicado a datos que son, con generosidad, Medium Data. Se
manifiesta en su versión más honesta como una tabla cargada a un warehouse
gestionado con su `COPY` de media hora, su costo por consulta y su latencia de
red, para responder una pregunta que el motor embebido contesta en segundos
leyendo el Parquet en el sitio. La autopsia (última fase) mide las dos rutas
sobre el mismo dataset y la misma pregunta: tiempo de puesta en marcha, tiempo
de consulta, líneas de infraestructura, y —el número que más duele— el costo
operativo de tener algo que alguien debe respaldar, monitorear y atender un
martes a las 3 am. El villano tiene su reverso, que el veredicto también
nombra: usar el motor embebido donde **sí** hacía falta el clúster (concurrencia
de miles de usuarios, escritura transaccional, datos que no caben ni ordenados).
Medir ambas direcciones es la vacuna contra el fanboyismo.

---

## 📐 Stack (2026, estable y moderno)

> Todas las versiones se fijaron verificando la última estable en 2026 al
> redactar esta semilla. Antes de arrancar la Fase 0, reconfírmalas: se mueven
> rápido (ver Decisiones pendientes).

| Componente | Versión / elección | Rol |
|---|---|---|
| **DuckDB** | 1.5.x (estable; 1.4.x LTS como alternativa conservadora) | Motor principal: analítico columnar embebido, consulta directa de Parquet/CSV |
| **DuckDB-Wasm** | 1.5.x (`@duckdb/duckdb-wasm`) | El mismo motor compilado a WebAssembly para el dashboard en el navegador |
| **Python** | 3.12+ (mínimo 3.11) | Lenguaje base del pipeline y de los análisis; cliente `duckdb` de PyPI |
| **Polars** | 1.4x | Rival #1 del "vs": DataFrames en Rust, lazy, multi-core |
| **pandas** | 3.0.x (PyArrow por defecto, Copy-on-Write) | Rival #2 del "vs": la línea base que todo equipo de datos ya tiene |
| **SQLite** | 3.4x | Rival #3: embebido por filas — el contraste columnar-vs-por-filas dentro de la misma categoría "sin servidor" |
| **Apache Arrow / Parquet** | Arrow 18+ / Parquet vía Arrow | Formato columnar en disco y en memoria; la lingua franca entre los cuatro |
| **TypeScript** | 5.x | Solo para el dashboard WASM (capa de navegador) |
| **Vite** | 6.x | Bundler del dashboard; sirve los `.wasm` y los Parquet estáticos |
| **Node.js** | 24.x LTS | Runtime de build del dashboard y del arnés `vs` en TS |
| **Docker / Podman** | Compose v2 | Todo contenerizado: entorno reproducible multiplataforma (WSL/Linux/macOS) |

### Por qué DuckDB como motor principal

Es el estándar emergente de la categoría y el que mejor encarna la propuesta de
valor completa: cero servidor, consulta directa de archivos remotos por HTTP,
integración nativa con Parquet y Arrow, y —clave para la Fase de dashboard—
compilación oficial a WebAssembly mantenida por el mismo equipo. Habla SQL
estándar con extensiones analíticas potentes (window functions, `PIVOT`,
`QUALIFY`, `list`/`struct`), lo que mantiene al lector senior en terreno
conocido mientras le cambia el motor por debajo. Un detalle operativo que la
Fase 0 debe respetar: el cliente Node antiguo (`duckdb` en npm) está
**deprecado** y no se publica para la línea 1.5; el reemplazo es
`@duckdb/node-api` (Node Neo). En Python el cliente `duckdb` de PyPI sigue siendo
la vía normal y soportada.

### Por qué esos rivales (y por qué NO son "otra base de datos")

**pandas y Polars entran como la alternativa real que un equipo de datos
consideraría, no como bases de datos.** Esta es la nota especial del curso y
gobierna todo el "vs": la pregunta honesta no es "DuckDB vs una base", es
"¿escribo SQL sobre archivos, o escribo código de manipulación de dataframes?".
pandas es la línea base universal —todo equipo ya la tiene, y su 3.0 con Arrow
por defecto es un rival mucho más digno que el pandas de hace tres años. Polars
es el retador serio: columnar, lazy, multi-core, con un motor de streaming que
maneja tablas más grandes que la RAM, exactamente el terreno donde uno
supondría que DuckDB gana sin discusión. Medir contra Polars es lo que impide
que el curso sea un panfleto. **SQLite** entra por una razón distinta: es el
otro embebido sin servidor, pero **por filas**, y sirve para aislar la variable
correcta —el contraste no es "embebido vs servidor" sino "columnar vs
por-filas" dentro de lo embebido.

### Por qué Python como lenguaje base (y TS solo en el borde)

El modelo es analítica, y el idioma nativo de la analítica —y de los tres
rivales— es Python + SQL. Forzar TypeScript en el pipeline sería nadar contra la
corriente del ecosistema (pandas, Polars y el cliente DuckDB más maduro viven
en Python). TypeScript aparece **solo donde el modelo lo pide de verdad**: el
dashboard WASM en el navegador, donde DuckDB-Wasm se maneja desde JS/TS. Es la
excepción justificada a la preferencia por defecto de TS+Node: aquí el patrón de
acceso manda sobre la convención de stack.

### Validación y tooling transversal

Además del arnés `vs` (sección siguiente), el laboratorio incluye un
**generador de datos** para producir Parquet de tamaño controlado cuando se
quiere una variable limpia (mismo esquema, N creciente), un **validador de
esquema** que confirma que un Parquet derivado conserva tipos y semántica del
origen, y un **medidor de E/S** que reporta no solo el tiempo sino cuántos bytes
del archivo se leyeron realmente —el número que hace visible la ventaja columnar.

---

## ⚖️ El método del "vs": un arnés, no anécdotas

`scripts/vs.ts` (con su gemelo `scripts/vs.py` para los duelos que viven en
Python) ejecuta **la misma consulta semántica** —la misma pregunta de negocio—
contra cada motor en juego, la cronometra en condiciones comparables (mismo
dataset, misma máquina, caché frío y caliente reportados por separado), y
acumula el resultado en `BENCHMARKS.md` con fecha, versión de cada motor y
tamaño del dato. Nunca se afirma "DuckDB es más rápido"; se corre el arnés y se
pega el número. Un benchmark de marketing —venga del bando que venga— se
rechaza explícitamente: solo cuenta lo que reproduce este arnés.

Los duelos concretos que atraviesan el curso:

- **DuckDB vs pandas** — la agregación de referencia sobre el dataset grande: dónde el formato por filas de pandas (aun con Arrow) paga el peaje, y dónde el tamaño chico hace que el overhead de Python domine y el gap se colapse.
- **DuckDB vs Polars** — el duelo digno: group-by, join y expresiones sobre millones de filas, incluyendo el caso larger-than-RAM donde el streaming de Polars pelea de igual a igual con el spilling de DuckDB.
- **DuckDB vs SQLite** — columnar contra por-filas dentro de lo embebido: la misma consulta analítica en ambos para aislar el efecto del formato físico, no del "tener o no servidor".
- **SQL-sobre-archivos vs código-de-dataframe** — el meta-duelo del curso: no solo tiempo, también líneas de código, legibilidad y facilidad de cambio de la misma transformación expresada como query o como pipeline de dataframe.
- **Embebido vs warehouse pesado** — el duelo del villano (última fase): puesta en marcha, latencia, infraestructura y costo operativo de responder la misma pregunta con el motor en el proceso frente a con un warehouse/clúster.

---

## 🌳 Estructura de fases

| # | Fase | Núcleo | "Vs" de la fase |
|---|---|---|---|
| 0 | 🧪 Laboratorio y primer quack | Entorno contenerizado, generador de datos, nace `vs.ts`/`vs.py` | Instalación de los cuatro motores lado a lado |
| 1 | 📥 Consulta sin carga | Leer Parquet/CSV en el sitio, sin `COPY`; el medidor de E/S | DuckDB vs pandas: leer el archivo |
| 2 | 🧱 Por qué columnar gana (y cuándo no) | Formato físico, proyección de columnas, vectorización | DuckDB vs SQLite: mismo query, otro formato |
| 3 | 🧮 Agregaciones a escala | `GROUP BY`, `PIVOT`, window functions sobre millones de filas | DuckDB vs pandas vs Polars: la agregación de referencia |
| 4 | 🐍 SQL o dataframe: el meta-duelo | La misma transformación como query y como pipeline de dataframe | DuckDB vs Polars vs pandas: tiempo **y** código |
| 5 | 🔗 Joins en caliente | Cruzar dos datasets sin modelo normalizado permanente | DuckDB vs Polars: join de N millones |
| 6 | 🗜️ Materializar Parquet derivado | Proyectar, ordenar y comprimir; medir el "antes/después" | Parquet crudo vs derivado; DuckDB vs Polars al escribir |
| 7 | 🌊 Más grande que la RAM | Spilling, streaming, límites de memoria | DuckDB (spilling) vs Polars (streaming) |
| 8 | 🌐 Datos remotos | Consulta de Parquet por HTTP/S3 sin descargar entero | DuckDB `httpfs` vs "descargar y cargar" |
| 9 | 🦆 El motor en el navegador (WASM) | DuckDB-Wasm, el dashboard sin servidor, Parquet estáticos | WASM en pestaña vs backend de datos |
| 10 | 📊 Dashboard publicado | Cerrar el pipeline: publicación estática, consultas en el cliente | Costo/latencia: cliente vs servidor |
| 11 | ⚰️ Autopsia del villano y ⚖️ veredicto | Embebido vs warehouse/clúster medido; cuándo NO usar la familia | El duelo del villano, en números |

### Fase 0 — 🧪 Laboratorio y primer quack

Levanta el entorno **contenerizado** con los cuatro motores (DuckDB, pandas,
Polars, SQLite) instalados y verificables lado a lado, un `docker-compose` de
trabajo, y el **generador de datos** que produce Parquet de tamaño controlado.
Nace el arnés `vs` (en sus dos caras, `vs.py` y `vs.ts`) con su primer duelo
trivial que confirma que la medición es reproducible. Cierra con el primer
`INSTINTOS.md` y `BENCHMARKS.md` vacíos pero estructurados. 📖 Aquí arranca el
diccionario de traducción SQL → MQL-de-DuckDB (que en su mayoría es "es el mismo
SQL, con superpoderes analíticos").

### Fase 1 — 📥 Consulta sin carga

El gesto fundacional del modelo: apuntar el motor a un Parquet/CSV y
consultarlo **sin cargarlo antes a ninguna tabla**. Se construye el primer tramo
del pipeline (consulta directa) y el **medidor de E/S** que reporta bytes leídos
vs bytes del archivo. 🪞 Primer instinto a falsar: *"antes de consultar hay que
hacer `CREATE TABLE` y `COPY`"* — y esta vez se equivoca. 🩻 Esto sí viaja igual:
el `WHERE`, el `SELECT`, la semántica de tipos.

### Fase 2 — 🧱 Por qué columnar gana (y cuándo no)

El corazón conceptual. Se explica el formato físico columnar contra el por-filas
con el dataset ya cargado en DuckDB y en SQLite, y se mide la misma consulta
analítica en ambos para que la diferencia sea número, no relato. Se nombra
también el reverso: la consulta que toca una fila entera, donde el por-filas
gana. 🪞 *"columnar es siempre más rápido"* — falso, y se mide el caso donde
pierde.

### Fase 3 — 🧮 Agregaciones a escala

`GROUP BY`, `PIVOT`, `QUALIFY`, window functions sobre millones de filas: el
patrón dominante del dominio. Duelo central de rendimiento **DuckDB vs pandas vs
Polars** sobre la agregación de referencia. 🩻 Índices, selectividad y el plan de
la consulta siguen valiendo lo que valían en SQL; `EXPLAIN`/`EXPLAIN ANALYZE`
existe y se lee.

### Fase 4 — 🐍 SQL o dataframe: el meta-duelo

La pregunta que define el curso. La misma transformación no trivial (varios
pasos de filtro, agregación y derivación) se escribe como query SQL de DuckDB y
como pipeline de Polars y de pandas. Se mide tiempo, pero también **líneas de
código, legibilidad y facilidad de cambiar un requisito**. 🪞 *"para
transformar datos en Python necesito un dataframe"* — a veces el SQL embebido es
más corto y más claro.

### Fase 5 — 🔗 Joins en caliente

El cruce ocasional entre datasets (viajes × clima, vuelos × aeropuertos)
resuelto en el momento del análisis. Aquí vive el matiz honesto del veredicto:
el join es donde un relacional bien armado compite. Se mide DuckDB vs Polars en
joins de varios millones. ⚰️ Primer aviso del villano por defecto: el que
normaliza en siete tablas un dato que es analítico y se lee siempre junto.

### Fase 6 — 🗜️ Materializar Parquet derivado

Cuando una consulta se repite, se materializa un Parquet más chico —ya
proyectado, ordenado y comprimido— y se mide el "antes/después" en tamaño y
latencia. Segundo tramo del pipeline. Se toca compresión por columna y orden de
filas como palanca (valores vecinos que se parecen comprimen mejor). 💡 El orden
de escritura es una decisión de rendimiento, no un detalle.

### Fase 7 — 🌊 Más grande que la RAM

Qué pasa cuando el dato no entra en memoria: spilling a disco en DuckDB,
streaming en Polars. El caso donde el instinto "me lo traigo todo a un
dataframe" revienta con un out-of-memory. 🪞 *"si no entra en RAM necesito un
clúster"* — todavía no; primero el motor embebido con spilling/streaming.

### Fase 8 — 🌐 Datos remotos

Consultar un Parquet por HTTP o S3 **sin descargarlo entero**, leyendo solo los
rangos de bytes que la consulta necesita (`httpfs`, range requests). Contrasta
con el reflejo "descargo el archivo y después lo cargo". 🩻 La selectividad
sigue mandando: menos columnas y buen filtro = menos bytes por la red.

### Fase 9 — 🦆 El motor en el navegador (WASM)

El giro que casi ningún curso cubre: el **mismo motor** compilado a WebAssembly
corriendo en la pestaña del usuario. Se levanta DuckDB-Wasm, se sirven Parquet
como archivos estáticos, y las consultas se ejecutan **en el cliente**, sin
backend de datos. Límites reales del entorno WASM (memoria ~4 GB, un hilo por
defecto) nombrados sin adornos. 🪞 *"analítica en el navegador = mandar todo al
servidor y traer el resultado"* — no necesariamente.

### Fase 10 — 📊 Dashboard publicado

Se cierra el pipeline: el dashboard WASM publicado como sitio estático, con las
consultas corriendo en el cliente sobre los Parquet derivados de la Fase 6. Se
mide el costo y la latencia de esta arquitectura frente a la clásica
"backend + base de datos + API". La **prueba de fuego**: subir el sitio a un
hosting estático y que un tercero corra las consultas sin que exista servidor
alguno.

### Fase 11 — ⚰️ Autopsia del villano y ⚖️ veredicto honesto

La disección medida del villano: responder la pregunta analítica de referencia
con el motor embebido y con un warehouse pesado (o el diseño de un clúster,
documentado si no se levanta de verdad), comparando puesta en marcha, latencia,
infraestructura y costo operativo. Cierra con el ⚖️ **veredicto honesto**: el
árbol de decisión de **cuándo NO usar analítico embebido** (concurrencia alta de
escritura, transaccional, datos que superan de verdad un nodo, necesidad de un
servidor central compartido con permisos finos). Se consolidan `INSTINTOS.md` y
`BENCHMARKS.md`.

### Apéndices

- **A) Arranque de motores vía contenedores** — imágenes y comandos para tener DuckDB, Python (con pandas/Polars) y SQLite verificables en un `docker compose up`.
- **B) `docker-compose` y `Containerfile` de trabajo** — el entorno reproducible completo, con notas para WSL/Linux/macOS.
- **C) Guía rápida del SQL analítico de DuckDB** — `PIVOT`, `QUALIFY`, `list`/`struct`, `read_parquet`/`read_csv`, `COPY ... TO`, diferencias con SQL de Postgres.
- **D) Generador de datos** — cómo producir Parquet de esquema fijo y N creciente para aislar variables en el `vs`.
- **E) Troubleshooting de setup** — cliente Node deprecado vs `@duckdb/node-api`, límites de memoria en WASM, `httpfs` y CORS, versiones de Arrow entre motores.

---

## 📓 Artefactos acumulativos

**`INSTINTOS.md`** registra cada instinto relacional que el curso pone a prueba,
en formato falsable: la predicción del lector senior ("esto va a necesitar
cargar la tabla primero", "columnar siempre gana", "si no entra en RAM, es
clúster"), el experimento que la confronta, el número que salió y el veredicto
escrito. Crece una o dos entradas por fase; al final es un mapa de por dónde el
instinto SQL acierta y por dónde lo traiciona la analítica columnar. Su gemelo
🩻 —"esto sí viaja igual"— también se anota, porque bajar la ansiedad es parte
del método.

**`BENCHMARKS.md`** acumula **todo** "vs" corrido con el arnés: fecha, versión de
cada motor, tamaño del dataset, caché frío/caliente, tiempo, y —marca de la
casa— bytes leídos del archivo. Ninguna afirmación de rendimiento entra al curso
sin su fila aquí. Crece cada vez que una fase corre un duelo, de modo que la
última fase no "concluye" nada nuevo: solo lee la tabla que se fue llenando.

---

## 📚 Referencias por fase (semilla)

> ⚠️ **Todas las URLs, títulos e IDs de video de abajo deben verificarse antes
> de citarlos en una fase.** No se inventan números de página, DOIs ni IDs de
> video. Cuando una versión de la doc no coincida con la fijada en el stack, se
> advierte explícitamente.

**Transversal (todas las fases)**
- DuckDB — documentación oficial: https://duckdb.org/docs/
- DuckDB — línea LTS: https://duckdb.org/docs/lts/
- Apache Parquet — formato: https://parquet.apache.org/docs/
- Apache Arrow: https://arrow.apache.org/docs/

**Fase 0 — Laboratorio**
- DuckDB installation: https://duckdb.org/docs/installation/
- Docker (Compose v2): https://docs.docker.com/compose/
- *Orden de lectura:* installation → primer query en el CLI → compose de trabajo.

**Fases 1–2 — Consulta sin carga y columnar**
- DuckDB `read_parquet` / `read_csv`: https://duckdb.org/docs/data/parquet/overview
- Blog "por qué columnar" (verificar URL): https://duckdb.org/
- *Orden de lectura:* leer archivos → formato columnar → medir E/S.

**Fases 3–5 — Agregaciones, meta-duelo y joins**
- DuckDB SQL (aggregates, window, `PIVOT`, `QUALIFY`): https://duckdb.org/docs/sql/
- Polars — user guide: https://docs.pola.rs/
- pandas 3.0 — what's new: https://pandas.pydata.org/docs/whatsnew/
- *Orden de lectura:* SQL analítico de DuckDB → guía de Polars → correr el `vs`.

**Fase 6 — Parquet derivado**
- DuckDB `COPY ... TO` y opciones de Parquet: https://duckdb.org/docs/sql/statements/copy
- *Orden de lectura:* escribir Parquet → compresión y orden → medir antes/después.

**Fase 7 — Más grande que la RAM**
- DuckDB memory management / spilling: https://duckdb.org/docs/
- Polars streaming (verificar URL): https://docs.pola.rs/
- *Orden de lectura:* límites de memoria → spilling → streaming.

**Fase 8 — Datos remotos**
- DuckDB `httpfs`: https://duckdb.org/docs/extensions/httpfs
- *Orden de lectura:* httpfs → range requests → selectividad por la red.

**Fases 9–10 — WASM y dashboard**
- DuckDB-Wasm — overview: https://duckdb.org/docs/lts/clients/wasm/overview
- DuckDB-Wasm — deploying: https://duckdb.org/docs/lts/clients/wasm/deploying_duckdb_wasm
- `@duckdb/duckdb-wasm` (npm): https://www.npmjs.com/package/@duckdb/duckdb-wasm
- Vite: https://vitejs.dev/
- *Orden de lectura:* overview WASM → bundles y worker → servir Parquet estáticos → dashboard.

**Fase 11 — Autopsia y veredicto**
- (Comparativa embebido vs warehouse: construir con mediciones propias; citar solo fuentes verificadas.)
- *Orden de lectura:* correr ambas rutas → leer `BENCHMARKS.md` → escribir el árbol de decisión.

**Video/YouTube de apoyo (verificar todos los IDs y títulos; no se inventan)**
- Charlas de los creadores de DuckDB (Hannes Mühleisen / Mark Raasveldt) — buscar y verificar antes de citar.

---

## 🧪 Nota sobre ejercicios

Cada fase lleva entre **20 y 40 ejercicios** numerados con encabezado de rango
por dificultad, graduados 🟢🟡🟠🔴. Distribución sugerida para ~30: ~8 🟢
(calientan: correr una consulta, leer un Parquet, medir bytes), ~9 🟡 (una
agregación no trivial, un `PIVOT`, un join simple), ~7 🟠 (reproducir un duelo
del `vs`, materializar y comparar, medir spilling), ~5 🔴 (integrar varias fases,
optimizar un query grande, montar una consulta en WASM), más los 🔥 opcionales
aparte. **Al menos un puñado por fase son de diagnóstico**: se entrega un query
lento o un Parquet mal materializado y se pide reproducir, medir y localizar la
causa —no "reflexionar sobre rendimiento". Todos anclados al dominio: viajes,
vuelos, permisos, precios; nunca ejemplos abstractos. Cuando un ejercicio nombra
código, usa el identificador en inglés vigente.

---

## 🧩 Decisiones pendientes de confirmar antes de redactar la Fase 0

- [ ] **Dataset semilla.** Propuesta por defecto: un volcado público grande y estable con Parquet oficial (p.ej. viajes de taxi de una ciudad, o estadísticas de vuelos). Confirmar cuál, verificar licencia de uso libre y que exista en Parquet, y fijar un espejo por si la fuente cae. *Pendiente.*
- [ ] **Versiones exactas del stack.** Reconfirmar en la web la última estable de DuckDB (1.5.x vs LTS 1.4.x), Polars, pandas 3.0.x, DuckDB-Wasm y Node LTS el día de arrancar. *Pendiente.*
- [ ] **¿Los tres rivales entran desde Fase 0, o escalonados?** Propuesta por defecto: pandas y DuckDB desde Fase 1; Polars desde Fase 3; SQLite desde Fase 2. Confirmar. *Pendiente.*
- [ ] **El warehouse del villano: ¿se levanta de verdad o se documenta como diseño?** Propuesta por defecto: documentar el diseño y el costo con números defendibles, levantarlo solo si hay una opción local sin costo cloud. *Pendiente.*
- [ ] **Cliente Node para el arnés `vs.ts`.** Usar `@duckdb/node-api` (Node Neo), no el `duckdb` deprecado. Confirmar madurez de la API en la versión elegida. *Pendiente.*
- [ ] **Formato exacto de fase** (¿9 secciones estilo legacy, o el esqueleto de la ruta?). Propuesta por defecto: esqueleto de la ruta con las 9 secciones como columna vertebral. *Pendiente.*
- [ ] **Alcance del dashboard WASM:** ¿una vista o varias? Propuesta por defecto: una vista rica (un par de gráficos + un filtro facetado) que demuestre las consultas en el cliente sin sobre-construir. *Pendiente.*

---

## 💭 Consideraciones adicionales

### La nota especial del curso: pandas y Polars NO son "otra base de datos"

Es el eje que evita que Cristalería sea un panfleto pro-DuckDB. El lenguaje base
es **Python + SQL**, y pandas/Polars se presentan como lo que un equipo de datos
realmente evaluaría frente a "escribir SQL sobre archivos": código de
manipulación de dataframes. El "vs" no pregunta "¿qué base es mejor?" sino
"¿para esta transformación, gana el query o gana el pipeline de dataframe, y por
qué?". A veces gana DuckDB por tiempo y por concisión; a veces gana Polars en
larger-than-RAM o en expresividad de una transformación fila-a-fila; a veces
pandas es suficiente y migrar no se justifica. El curso mide y lo dice sin
bandera.

### Costo operativo del modelo (el número que el villano ignora)

La gran ventaja operativa del modelo es que **casi no tiene costo operativo**:
no hay servidor que respaldar, monitorear ni atender de madrugada. Pero eso no
es gratis en todos los ejes: no hay concurrencia de escritura transaccional, no
hay control de acceso fino por servidor, y "operar" se traslada a **gestionar
los archivos** (versionado de Parquet, dónde viven, quién puede leerlos). El
curso nombra ese traslado explícitamente para que la decisión sea arquitectónica
y no un espejismo de "cero costo".

### Límites de la analogía con SQL

DuckDB habla SQL, y eso es un regalo para el lector senior: 🩻 la mayor parte de
su instinto viaja intacto. Pero hay tres lugares donde la analogía se estira y
el curso los marca: (1) no hay transacciones concurrentes multi-usuario como en
un RDBMS servido —el modelo es de un proceso; (2) "cargar" es opcional y muchas
veces contraproducente, al revés del reflejo relacional; (3) el rendimiento no
depende de índices B-tree sino del formato columnar, la proyección de columnas y
el orden físico —optimizar es otro juego, aunque `EXPLAIN` siga estando.

### Validación contra un mercado real (productizable: ✅ Media-fuerte)

El proyecto se valida contra un mercado existente: la analítica embebida y sin
servidor compite de verdad con soluciones como los dashboards que hoy exigen un
backend de datos, con las herramientas de BI ligeras, y con el reflejo de montar
un warehouse gestionado para volúmenes que no lo necesitan. La pieza más
productizable es el **dashboard WASM sin servidor**: analítica que se publica
como un sitio estático y corre en el navegador del usuario, con costo de
operación cercano a cero —un diferenciador concreto frente a alternativas que
cobran por consulta o por servidor encendido. La fuerza "media" del rótulo
reconoce el techo: como producto horizontal es más una capacidad que un SaaS
por sí solo; su valor se maximiza embebido en un vertical concreto.
