# 🧭 Plan de acción — documentos base de la Ruta NoSQL Lite

> **Qué es esto:** el guion de trabajo para crear el andamiaje editorial del curso
> `ruta-no-sql-lite/` — guías, plantillas, propuestas de alcance y prompts— antes de
> escribir una sola fase de contenido.
> **Fecha:** 10 de septiembre de 2026
> **Estado:** propuesta para revisión. Nada de lo que sigue está escrito todavía.
> **Qué NO es:** el temario definitivo. El temario sale de
> `prompts/propuesta-fases-y-alcance.md`, que es uno de los entregables de este plan.
> **🗑️ Documento desechable, y esto es normativo.** Es andamio de trabajo: se borra en
> cuanto los documentos base estén escritos. **Ningún archivo del curso —fases,
> apéndices, guías, plantillas, prompts, README— puede citarlo, enlazarlo ni apoyarse en
> él.** Todo lo que de aquí deba sobrevivir se copia, redactado en su forma final, dentro
> del documento base que le corresponda; lo que no se copie, se pierde a propósito.

---

## 1. 🎯 Qué es la Ruta NoSQL Lite

Un curso corto —**4 a 6 meses a 10–12 h por semana**— que enseña a **elegir familia de
base de datos con criterio**, tocando diez motores de verdad en lugar de leer sobre
ellos. No forma expertos en ningún producto y lo dice en la primera línea.

La tesis que ordena todo el curso, y que conviene no diluir nunca:

> 🧠 **El villano no es Mongo, ni Cassandra, ni el hype.** Es *elegir por un criterio que
> no predice el fracaso, y pagarlo dos años después*. Las preguntas con las que la gente
> elige —"¿tengo esquema fijo?", "¿quiero evitar joins?"— no son las que discriminan. Las
> que sí lo hacen son otras cinco, y el curso entero es el instrumento para hacérselas.

De ahí salen tres compromisos editoriales que separan este curso de los mil *"MongoDB en
20 minutos"* que ya existen, y que son los que hay que blindar en la guía de estilo:

- **Se mide la forma, no la velocidad.** *"Esta consulta necesita tres viajes y escanea la
  partición entera"* sigue siendo cierto dentro de cinco años; *"tarda 12 ms"* no. Viajes
  de ida y vuelta, documentos/filas/columnas examinados, fan-out, amplificación de
  escritura, qué pasa cuando el dato deja de caber en un nodo.
- **Una apuesta falsable por familia.** Antes de ejecutar se escribe la predicción y el
  número esperado; después se mide y se publica el resultado, se gane o se pierda. La
  apuesta que se pierde en público vale más que diez mediciones favorables.
- **Un punto de rotura por familia.** Levantar y modelar lo hace cualquiera. Llevar el
  motor hasta que se rompe, con el **mensaje de error literal** apuntado, no.

Y una honestidad que va dicha desde la semana 0, no escondida al final: **la mayoría de
las veces gana Postgres** —JSONB, full-text, `pgvector`, particionado, `WITH RECURSIVE`—
y cuando hace falta otro motor suele ser **al lado** y no en lugar de. El curso va a por
el resto de los casos, y los demuestra con las dos bases montadas, no con una cita.

### 1.1 Cómo se relaciona con lo que ya existe en el repositorio

- **`ruta-no-sql/`** es la especificación de los cursos profundos —once carpetas con
  alcance, guía y semilla, ~150.000 palabras de diseño y cero de contenido—. Este curso
  **la consume como fuente** (dominio, rivales, anti-patrones, veredictos) y **no la
  toca**. Cada minicurso de la Lite es, de hecho, el tráiler de su curso profundo.
- **`docker-container-legacy/`** es la infraestructura de laboratorio. Aquí no se enseña
  Docker: se dan recetas y se enlaza allí para lo demás.
- **Angular 8 / Angular 16 / React 16** aportan el andamiaje editorial que se imita —guía
  de estilo, plantillas de capítulo, propuestas de alcance, prompts por fase y apéndice—.

### 1.2 La audiencia

Ingenieros de software con experiencia y **sesgo relacional declarado**: saben SQL,
saben qué es un índice y una transacción, y muchos ya tomaron —o heredaron— una decisión
de NoSQL que salió mal. No se les explica qué es una CLI, qué es Docker ni qué es un
índice. Sí se les explica, **con cero ambigüedad y sin infantilizar**, qué significa
exactamente "unidad de lectura", por qué `ALLOW FILTERING` es una trampa, o qué hace un
`$lookup` por dentro. *"Como para un bebé"* en este curso significa **ninguna caja negra
prematura**, no menos profundidad.

---

## 2. ✅ Decisiones que tomo como cerradas

Si alguna de estas está mal, es el momento de decirlo: todo lo demás cuelga de aquí.

1. **Carpeta:** `ruta-no-sql-lite/`. El nombre del curso es **Ruta NoSQL Lite** en todo
   texto visible (no "light", no "ruta corta").
2. **Idioma y tono:** español latinoamericano neutro, tuteo, semiformal y cálido, humor
   seco y moderado, emoji con criterio. Código, comandos, nombres de archivo y salida de
   terminal en inglés; comentarios de código en español.
3. **Ejercicios sí, y por fase.** Es una decisión tuya que se aparta de la idea original
   de "el ejercicio es ejecutar el curso", y va declarada como tal en la guía.
4. **Apéndices sí, transversales a la ruta y no por minicurso.** Mínimos, de receta, sin
   pedagogía de Docker.
5. **Un dominio único para todo el curso: mantenimiento de flota.** Se modela diez veces
   y es lo que hace comparables las mediciones. Fichas de vehículo (documental),
   telemetría (series temporales), catálogo de repuestos (búsqueda), dependencias entre
   piezas (grafos), sesiones y rate limiting (clave-valor), tablero de costes (columnar),
   la app del técnico sin cobertura (offline-first), *"¿qué avería se parece a esta?"*
   (vectorial), el libro de órdenes de trabajo (NewSQL).
6. **Postgres es el rival permanente**, montado al lado en cada minicurso. No es un
   apéndice opcional: es el instrumento de medida.
7. **Todo se ejecuta contra una máquina antes de publicarse.** Ningún número sin ejecutar,
   ninguna versión de memoria, y lo que no se verificó se declara.
8. **Imágenes fijadas por digest**, no por tag, con fecha de verificación en el documento.
9. **Docker Compose como camino principal**, con el equivalente Podman al lado en cada
   receta. Sin Kubernetes en ninguna parte.
10. **Dos fases por familia**, una por semana del minicurso: *levantar y modelar* y
    *romper, medir y decidir*. Veintiséis fases en total (§3).
11. **Ejercicios: 20–30 por fase**, la banda del repositorio, calibrada por fase.
12. **Boss global acumulativo —"El Taller"— y además un 💀 boss por bloque** (§4).
13. **Laboratorio mixto: TypeScript por defecto, Python donde manda** —vectorial y
    analítico embebido—. La regla que evita que degenere en dos cursos paralelos: el
    **arnés de medida y el generador de datos son TypeScript siempre**, y Python aparece
    solo donde el ecosistema de la familia vive ahí de verdad (embeddings y DuckDB). Cada
    fase declara en su encabezado con qué se ejecuta, y `a06` cubre los dos entornos con
    su tabla de equivalencias.

---

## 3. 🧱 Arquitectura propuesta del curso

### 3.1 La unidad: bloque → minicurso → fase

Un **minicurso de familia** son dos semanas (≈20 h) y se entrega como **dos fases**, una
por semana, porque un archivo de 20.000 palabras no se escribe en un chat ni se lee en
una sentada:

- **Fase A — Levantar y modelar.** El motor arriba desde la receta, el dominio de flota
  modelado *a la manera de la familia*, la situación 3 —*"elegiste bien la familia y aun
  así te fue mal, porque la modelaste como si fuera relacional"*— y el 🪞 *"tu instinto
  relacional dice… y esta vez se equivoca"*.
- **Fase B — Romper, medir y decidir.** La apuesta falsable, el punto de rotura, la
  comparación contra Postgres midiendo la forma, el ⚰️ anti-patrón con números antes y
  después, y el ⚖️ veredicto honesto: cuándo NO usar esto.

### 3.2 Los bloques, en orden de aprendizaje

El orden es el de **aprender**, no el de publicar; el README declarará los dos.

| Bloque | Familias | Fases | Horas |
|---|---|---|---|
| **0 · El instrumento** | Tesis, dominio, las cinco preguntas | F00–F02 | 12 h |
| **I · Los dos que ya usas** | Documental · Clave-valor | F03–F06 | 40 h |
| **II · Leer de otra forma** | Analítico embebido · Series temporales · Búsqueda | F07–F12 | 60 h |
| **III · Preguntas que no sabes escribir en SQL** | Grafos · Vectorial | F13–F16 | 40 h |
| **IV · Cuando el dato no cabe en un nodo** | Columnar ancha · NewSQL · Offline-first | F17–F22 | 60 h |
| **V · El árbitro** | Capstone políglota | F23–F25 | 40 h |
| | | **26 fases** | **252 h** |

Con 20–30 ejercicios por fase, cada archivo queda en 4.000–5.000 palabras de cuerpo más
1.300–2.800 de aparato de ejercicios: unas **160.000–190.000 palabras** en total, que es
la mitad larga del curso de Docker y sigue siendo un curso corto para lo que cubre.

**252 h ÷ 12 h semanales ≈ 21 semanas ≈ 5 meses.** A 10 h semanales son 25 semanas ≈ 6
meses. Entra en la ventana de 4–6 meses sin recortar familias; lo que se recortó respecto
de la idea original es el capstone, de 8 semanas a 4.

> 🧭 **Por qué los bloques y no una fila de diez minicursos.** Porque el bloque es lo que
> permite un 💀 **boss de bloque** que obliga a comparar dos familias entre sí, y porque
> da un punto de corte natural para publicar por tandas. El Bloque I solo ya es un curso
> completo defendible: *"lo básico, bien hecho"*.

### 3.3 Bloque 0 en detalle, porque es el que sostiene todo

- **F00 — La decisión que se hereda.** Las autopsias ⚰️ como gancho: *"elegimos Mongo
  porque no queríamos joins"*, *"elegimos Cassandra porque escala"*, *"metimos el JSON
  completo y listo"*, Redis como almacén primario, Elasticsearch como fuente de verdad.
  Decisión → razón que se dio → qué pasó a los dos años → cuánto costó salir. **Autopsia,
  no juicio:** en la mesa está la decisión, nunca la persona.
- **F01 — El dominio de flota y el arnés.** El dominio único, el generador de datos, y
  cómo se mide la forma en cada motor (`explain`, `profile`, contadores del servidor).
  Sale de aquí el `compose.yaml` maestro y el primer Postgres arriba.
- **F02 — Las cinco preguntas.** El instrumento de decisión: dónde está la **frontera
  transaccional** (la que más caro sale ignorar), si **conoces tus consultas de antemano**
  y son estables, cuál es la **unidad de lectura**, cuántos **saltos** tiene tu relación
  típica, y si necesitas **exactitud o parecido**. Cierra con el triaje de *"ya elegiste
  mal, ¿ahora qué?"*: migrar 400 GB en producción sin parar el negocio.

### 3.4 Motores candidatos por familia

Candidatos, **sin verificar todavía**: las versiones exactas y los digests se fijan
ejecutando, en la tarea T9 de §6.

| Familia | Motor del curso | Rival permanente | Nota |
|---|---|---|---|
| Documental | MongoDB | Postgres JSONB | licencia SSPL → apéndice |
| Clave-valor | Valkey | tabla `UNLOGGED` | Valkey y no Redis, por licencia |
| Analítico embebido | DuckDB | Postgres | **habla SQL**: rompe la etiqueta "NoSQL" |
| Series temporales | TimescaleDB | Postgres particionado | el rival *es* Postgres, y es el punto |
| Búsqueda | OpenSearch | Postgres FTS | OpenSearch y no Elasticsearch, por licencia |
| Grafos | Neo4j Community | `WITH RECURSIVE` | aquí se pierde la apuesta en público |
| Vectorial | Qdrant | `pgvector` | la familia más defendible de todas |
| Columnar ancha | Cassandra o ScyllaDB | Postgres particionado | la más difícil; va tarde |
| NewSQL | CockroachDB | Postgres de un nodo | la síntesis: por qué existe y qué cuesta |
| Offline-first | CouchDB + PouchDB | — | conflictos y CRDTs; sin rival relacional |

---

## 4. 🏆 Proyecto boss

**Sí, hay un boss global, y además uno por bloque.** Los dos son opcionales y viven
fuera de las 252 h.

- 🏆 **El boss global — "El Taller".** Un sistema de mantenimiento de flota que **crece
  con el curso**: cada bloque le añade un motor y una capacidad. Se consume en el orden
  canónico —es la única parte del curso que se acopla— y por eso es opcional. Es el mejor
  portafolio que deja la ruta, y es una serie de contenido distinta de la del curso: la
  ruta enseña el modelo, el boss enseña el sistema creciendo.
- 💀 **El boss de bloque.** Un encargo que solo se resuelve cruzando las familias del
  bloque. El del Bloque I: *"tienes el catálogo en Mongo y las sesiones en Valkey; una
  avería duplicada entró hace tres meses y nadie sabe cuándo — encuéntrala y explica qué
  frontera se disolvió"*. Empieza siempre con un sistema roto o un encargo completo, no
  con un ejercicio 🔴 con mejor nombre.
- ⚖️ **El capstone políglota (Bloque V) no es opcional ni es el boss global**: es la
  conclusión que el curso lleva prometiendo cinco meses —añadir un motor al lado y **pagar
  la factura de tenerlo**—, y tiene sus propias fases y ejercicios.

---

## 5. 📚 Apéndices propuestos

Transversales a toda la ruta, **de receta y no de pedagogía**, y sus horas no cuentan en
las 252. Regla de oro del bloque de infraestructura: **comandos y nada más**; para
entender qué hace cada uno está `docker-container-legacy/`, y se enlaza.

| Apéndice | Contenido | Horas |
|---|---|---|
| **a01 — Laboratorio contenerizado en tres plataformas** | Receta pura para Windows 11 (WSL2), macOS arm64 y Linux: instalar, verificar, `compose up`, puertos, volúmenes, límites de memoria, apagar y limpiar. Tabla de equivalencias **Docker Compose ⇄ `podman compose` / `podman-compose`** y las tres diferencias que de verdad muerden (rootless, puertos <1024, permisos de volumen) | 3 h |
| **a02 — El `compose.yaml` de la ruta** | El archivo maestro con un perfil por familia (`--profile mongo`, `--profile flota-search`…), digests fijados, healthchecks y la advertencia de RAM: qué se puede levantar a la vez en 16 GB y qué no | 2 h |
| **a03 — CLIs de los diez motores** | Chuleta de entrada y salida: `mongosh`, `valkey-cli`, `duckdb`, `psql`, `cqlsh`, `cypher-shell`, API de Qdrant, `curl` a OpenSearch, `cockroach sql`, Fauxton. Conectar, listar, insertar, consultar, salir | 3 h |
| **a04 — El arnés de medida** | Cómo se mide la forma en cada motor: `explain()` y `$indexStats` en Mongo, `EXPLAIN ANALYZE` y `pg_stat_statements` en Postgres, `PROFILE` en Neo4j, `tracing on` en Cassandra, `EXPLAIN` de DuckDB, `profile` de OpenSearch. Qué campo mirar y cuál ignorar | 3 h |
| **a05 — El dominio de flota y sus datos** | El modelo conceptual, el generador de datos **en TypeScript** y los tres volúmenes del curso (10 k / 1 M / punto de rotura). Semilla determinista: la misma medición en tu máquina y en la mía | 2 h |
| **a06 — Lenguajes, drivers y frameworks** | Los dos entornos del laboratorio y cuándo se usa cada uno: **Node/TypeScript** por defecto —driver por motor con su versión, conexión, `docker compose exec` contra script local— y **Python** en vectorial y analítico embebido, con el mínimo de sintaxis para quien no lo escribe a diario y la tabla de equivalencias entre ambos | 4 h |
| **a07 — Postgres como línea base** | JSONB, GIN, full-text, `pgvector`, `WITH RECURSIVE`, particionado declarativo y `UNLOGGED`. El apéndice que sostiene el *"casi siempre gana Postgres"* | 3 h |
| **a08 — Diccionario de traducción y glosario** | SQL → cada modelo y vuelta: qué es una `VIEW` en agregaciones, qué reemplaza a un `JOIN`, qué significa "índice" en cada familia, partición contra sharding, consistencia eventual sin misticismo | 2 h |
| **a09 — Catálogo de errores con mensaje literal** | `E11000 duplicate key error`, `Transaction numbers are only allowed on a replica set member or mongos`, `ALLOW FILTERING`, `OOM command not allowed when used memory > 'maxmemory'`, `cluster_block_exception … read-only-allow-delete`, el aviso de producto cartesiano de Neo4j. Crece durante todo el curso | 3 h |
| **a10 — Licencias y riesgo** | SSPL, BSL, Elastic License y sus forks. Por qué el curso usa Valkey y OpenSearch, y qué preguntar antes de meter un motor en una empresa | 1 h |

> ⚠️ **Advertencia de alcance sobre a01.** La tentación de explicar redes de contenedores,
> capas o volúmenes nombrados es enorme y hay que resistirla: ese es otro curso del
> repositorio y está escrito. Si una sección de a01 necesita más de dos párrafos de
> explicación, es que pertenece a `docker-container-legacy/`.

---

## 6. 📄 Los documentos base a crear, y en qué orden

Todo vive en `ruta-no-sql-lite/prompts/`, salvo el README y este plan. **Un documento,
un chat**, y cada uno se cierra antes de abrir el siguiente porque el siguiente lo cita.

> 🗑️ **Este plan no entra en la cadena de citas.** Se usa como insumo del chat que
> escribe T1 y T2 —se pega o se sube, no se enlaza— y desaparece de ahí en adelante. La
> columna "Depende de" nunca vuelve a nombrarlo: a partir de T1, la fuente de verdad es
> `alcance-del-proyecto.md`. Si un documento del curso necesita algo que solo está aquí,
> la corrección es **moverlo al documento base**, nunca citar el plan.

| # | Documento | Qué fija | Depende de |
|---|---|---|---|
| **T1** | `prompts/alcance-del-proyecto.md` | La tesis, la audiencia, el dominio de flota, qué entra y qué no, criterios de éxito, decisiones cerradas. **Absorbe §1 a §4 de este plan en su forma final** | — (arranca la cadena) |
| **T2** | `prompts/guia-de-estilo-y-convenciones.md` | Tono, idioma, pedagogía, callouts, plantilla de fase, escala y cantidad de ejercicios, convención Docker/Podman, checklist de cierre, **y las excepciones declaradas a `CLAUDE.md`** | T1 |
| **T3** | `prompts/propuesta-fases-y-alcance.md` | Las 26 fases con alcance, horas, ejercicios, apuesta falsable, punto de rotura y boss de bloque. **El temario.** | T1, T2 |
| **T4** | `prompts/propuesta-apendices-y-alcance.md` | Los diez apéndices con alcance, horas y qué queda explícitamente fuera | T3 |
| **T5** | `prompts/plantillas-de-capitulo.md` | Los dos esqueletos: fase (rígido) y apéndice (laxo), con el bloque de metadatos y el bloque 🏷️ de git | T2, T3, T4 |
| **T6** | `prompts/formato-bitacora-de-medicion.md` | El aparato que hace real al curso: la ficha de apuesta falsable, la de punto de rotura, cómo se anota una medición de forma y cómo entra un error al catálogo a09 | T2, T3 |
| **T7** | `prompts/prompts-de-fase.md` | Un prompt listo para copiar por cada una de las 26 fases | T3, T5, T6 |
| **T8** | `prompts/prompts-de-apendice.md` | Un prompt por apéndice | T4, T5 |
| **T9** | `README.md` del curso | La puerta de entrada: qué es, para quién, orden de aprendizaje y de publicación, mapa de bloques, stack y cómo se usa el laboratorio | todo lo anterior |

Y una tarea que **no es un documento pero bloquea la publicación de la primera fase**:

| # | Tarea | Por qué |
|---|---|---|
| **T10** | **Sesión de verificación de laboratorio.** Levantar los diez motores en las tres plataformas, fijar digests, medir el consumo de RAM real y anotar todo error con su mensaje literal | Ninguna versión del curso se publica de memoria, y el catálogo de errores nace aquí |

> 🧭 **Regla de precedencia entre estos documentos**, para que ninguna sesión futura la
> reabra: manda `alcance-del-proyecto.md`, después la guía de estilo, después las dos
> propuestas, y las plantillas y los prompts se actualizan **después** y nunca al revés.
> Por encima de todos ellos, solo el `CLAUDE.md` del repositorio en lo que este curso no
> haya declarado como excepción.

---

## 7. ⚖️ Excepciones a `CLAUDE.md` que hay que declarar por escrito

`CLAUDE.md` permite que un curso se aparte de los defaults **si lo declara y dice por
qué**. Estas son las de este curso, y van en la guía de estilo (T2) con esta redacción o
una equivalente. Sin esto, cada sesión futura las va a "arreglar" de vuelta:

1. **Ejercicios: se mantiene la banda del repositorio, 20–30 por fase**, calibrada fase
   por fase con la pregunta *"¿cuántas cosas distintas enseña esta fase que se puedan
   comprobar por separado?"*. Escala 🟢🟡🟠🔴 con 🔥 y 💀, reparto equilibrado (≈30/30/25/15)
   y **al menos un tercio de diagnóstico**. No hay excepción que declarar aquí; lo que sí
   va escrito es que el aparato de ejercicios añade entre 1.300 y 2.800 palabras sobre el
   cuerpo de la fase, y que la banda de 4.000–5.000 palabras se mide **sobre el cuerpo**.
2. **Apéndices transversales al curso, no por fase.** Diez apéndices para veintiséis
   fases, y ninguno pertenece a una familia concreta.
3. **`BENCHMARKS.md` se sustituye por la bitácora de medición** (T6). El motivo es de
   fondo y no de forma: este curso **mide la forma y no la velocidad**, así que un archivo
   de latencias sería exactamente el artefacto que envejece mal. Lo que se versiona son
   viajes, documentos examinados, fan-out y amplificación de escritura, con su fecha y su
   digest de imagen.
4. **`INSTINTOS.md` sí se mantiene**, y es central: es donde se acumulan los 🪞 *"tu
   instinto relacional dice… y esta vez se equivoca"* de las diez familias.

---

## 8. 📁 Convención de nombres

```
ruta-no-sql-lite/
├── README.md
├── plan-accion-creacion-docs-base.md      ← 🗑️ desechable: se borra al cerrar T9
├── 0-programa-del-curso.md                ← se escribe con la primera fase
├── 00-la-decision-que-se-hereda.md
├── 01-el-dominio-de-flota-y-el-arnes.md
├── 02-las-cinco-preguntas.md
├── 03-documental-levantar-y-modelar.md
├── 04-documental-romper-y-medir.md
│   … hasta …
├── 25-el-arbitro-la-factura-del-poliglota.md
├── a01-laboratorio-contenerizado.md … a10-licencias-y-riesgo.md
├── INSTINTOS.md
├── bitacora-de-medicion.md
└── prompts/
    ├── alcance-del-proyecto.md
    ├── guia-de-estilo-y-convenciones.md
    ├── propuesta-fases-y-alcance.md
    ├── propuesta-apendices-y-alcance.md
    ├── plantillas-de-capitulo.md
    ├── formato-bitacora-de-medicion.md
    ├── prompts-de-fase.md
    └── prompts-de-apendice.md
```

Dos dígitos en todo, incluidos los apéndices. Tags de git `fase-NN-<slug>` y prefijo de
commit `fNN:`, igual que el resto del repositorio.

> 🗑️ **Los dos documentos desechables del curso son este plan y `nuevas-ideas.md`.**
> Ninguno de los dos se versiona junto al curso ni se cita desde ningún archivo. El
> checklist de cierre de la guía de estilo (T2) incluye una comprobación explícita:
> `grep -rn "nuevas-ideas\|plan-accion-creacion-docs-base"` sobre el curso no devuelve
> nada.

---

## 9. ❓ Lo que necesito que decidas

Cuatro ya están resueltas y quedan registradas en §2. Estas son las que siguen abiertas,
con mi valor por defecto puesto:

- **Duración objetivo.** Propongo 252 h ≈ 21 semanas a 12 h/semana. Si prefieres 4 meses
  justos, lo que se recorta es el capstone y el Bloque IV se publica como segunda tanda.
- **Orden de publicación contra orden de aprendizaje.** Documental abre por los dos
  criterios. Después hay tensión: clave-valor por aprendizaje, vectorial por tracción.
  Propongo **declarar los dos órdenes en el README y publicar vectorial en tercer lugar**,
  fuera de su sitio, porque el curso puede permitírselo — los minicursos son
  independientes salvo el boss global.
- **Los apéndices, ¿antes o sobre la marcha?** Propongo escribir **a01, a02, a05 y a06
  antes de la primera fase** —sin ellos no hay laboratorio— y dejar que a03, a04, a08 y
  a09 crezcan con el curso. a07 y a10 van cuando toque su familia.

---

## 10. ⚠️ Riesgos, y qué los desactiva

**El riesgo serio es degenerar en resumen de documentación.** Es el mismo que arruinaría
cualquier curso de diez motores en seis meses, y no se desactiva con más palabras: se
desactiva con las tres anclas de §1 —forma medida, apuesta falsable, punto de rotura— y
con la regla de que **nada se publica sin haberse ejecutado**. El criterio para dar una
fase por buena es brutalmente simple: si cierra con *"medí esto y me sorprendió"*, vale;
si cierra con *"la documentación dice que"*, se reescribe.

**El segundo riesgo es la hipoteca de mantenimiento.** A diferencia de los cursos legacy
del repositorio, que se pueden congelar porque todo lo que enseñan está EOL, aquí los diez
motores se mueven solos. Mitigación: digests y no tags, fecha de verificación visible en
cada documento, y apuntar al mecanismo. Lo que envejece de verdad son los `compose.yaml`,
y esos se actualizan en diez minutos.

**El tercero es el tono.** Si una autopsia suena a *"quien eligió Mongo es tonto"*, pierdes
justo al lector que más la necesita: el que lo eligió. Y en la mitad de los casos ese
lector **es literalmente la audiencia objetivo** —ingenieros con experiencia y sesgo
relacional—. La versión que funciona **defiende el argumento antes de desmontarlo**: quien
pide Mongo no suele decir una tontería, dice *"el esquema va a cambiar mucho"* o *"esto
tiene que escalar"*, que son preocupaciones legítimas con el instrumento equivocado.
