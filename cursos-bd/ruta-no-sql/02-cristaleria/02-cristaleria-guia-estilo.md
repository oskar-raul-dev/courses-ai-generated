# ✍️ Guía de estilo, tono y convenciones — Curso Cristalería
## Analítico columnar embebido y sin servidor (DuckDB)

Esta guía es la fuente de verdad editorial del curso **Cristalería**. Deriva
de `GUIA-DE-ESTILO-Y-CONVENCIONES.md` (el legacy de Vue/MongoDB) adaptada al
modelo de acceso de este curso: no se copia literal porque el villano, el
diccionario de traducción y los recuadros propios cambian de dominio. Todo
`.md` que se produzca para Cristalería sigue esta guía.

> 🧭 **Regla de una línea que rige todo el código:** el **código en inglés**
> (SQL, Python, TypeScript); toda la narrativa, comentarios y textos de
> interfaz **en español**, sin voseo — se usa "tú", nunca "vos" ni "che".
> Detalle completo en §4.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien con instinto SQL relacional
sepa, con números propios, cuándo un motor columnar embebido resuelve su
problema mejor que lo que ya usa — y cuándo no.** No enseñamos DuckDB "de
moda": enseñamos a reconocer el patrón de acceso analítico, medirlo contra
las alternativas reales (pandas, Polars, SQLite, un warehouse pesado), y
tomar la decisión de arquitectura con evidencia, no con fanboyismo.

El norte compartido del curso es una sola señal de éxito: **responder la
misma pregunta analítica con el motor embebido y con la alternativa, y que
la tabla de `BENCHMARKS.md` diga cuál gana y por qué**, no una opinión.

---

## 2. Tono

Cálido, informal y directo — de colega senior a colega senior que ya corrió
los benchmarks y te ahorra el tiempo de repetirlos a ciegas.

- **Segunda persona, cercana, sin voseo.** "Apunta el motor al Parquet y
  consúltalo", "si el instinto te dice que hay que cargar la tabla primero,
  mide antes de obedecerlo". Nunca "apuntá", "consultá" ni "medí".
- **Humor seco permitido.** Un 😉, un chiste sobre "media hora de `COPY`
  para responder algo que DuckDB contesta en tres segundos leyendo el
  archivo en el sitio", un 🪦 cuando algo se jubila (el `CREATE TABLE`
  reflejo, por ejemplo). El humor desdramatiza, no rellena.
- **Honesto sobre los límites del modelo.** Cuando DuckDB pierde —en el
  join grande, en la concurrencia de escritura— se dice sin adornos: "acá
  pierde, y está bien que pierda; no es el problema para el que se diseñó".
  El curso no es un panfleto pro-DuckDB (ver §7.4 y la nota especial de la
  semilla sobre pandas/Polars).
- **Orientado a la duda real.** Anticipa "¿por qué no cargo esto a una tabla
  como siempre?" y la responde con el número del medidor de E/S, no con una
  afirmación.
- **Cercanía sin condescendencia.** El lector es senior y vive en SQL. No le
  expliques qué es un `GROUP BY`, un índice o un plan de consulta: **lo
  sabe**. Lo nuevo es el formato físico por debajo y cuándo cambia (o no)
  su instinto.

> 🧠 **Matiz propio del curso.** El lector no llega en blanco: llega con años
> de instinto relacional y transaccional. El tono lo interpela de frente con
> dos micro-secciones recurrentes (§7.4): 🪞 *"tu instinto SQL dice… y esta
> vez se equivoca"* y 🩻 *"esto sí funciona igual"*. Nunca se ridiculiza el
> instinto: se lo honra y se lo recalibra con un número.

Evitar: promesas vacías ("vas a dominar la analítica"), motivación de coach,
solemnidad de manual corporativo, explicar lo obvio de SQL, y afirmar
rendimiento sin la fila correspondiente en `BENCHMARKS.md`.

---

## 3. Idioma y forma (narrativa)

- Español claro y técnico, **sin voseo**, para todo lo que no es código:
  títulos, explicaciones, ejercicios, referencias. Los términos del stack
  se dejan en inglés cuando son el nombre real: *query*, *pipeline*,
  *dataframe*, *lazy evaluation*, *spilling*, *streaming*, *vectorización*
  (esta sí se traduce, es término técnico establecido en español), *cache
  frío/caliente*, *range request*, *worker*, *bundle*. No se traducen
  forzadamente los nombres propios de API o de opción de configuración.
- Markdown siempre.
- Encabezados con emoji **con moderación** — uno por sección de plantilla.
  Los subtítulos internos pueden llevar emoji-tipo (§7) cuando aporta
  lectura rápida.
- **Prosa antes que listas.** Se explica razonando en párrafos. Las listas
  se usan cuando son de verdad una lista (pasos, ítems paralelos).
- **Tablas solo para comparar, decidir o mapear.** "Cuándo usar consulta
  directa vs materializar", matrices de decisión, el árbol de "cuándo NO
  usar esta familia", y —columna vertebral del curso— **tablas de
  traducción SQL-transaccional ↔ SQL-analítico-de-DuckDB** y **tablas de
  equivalencia SQL ↔ operación de dataframe** (§7.4). No para narrar.

---

## 4. Idioma del código fuente (código en inglés, curso en español)

Normativa para todo fragmento de código del curso: SQL de DuckDB, Python
(pandas/Polars/cliente `duckdb`), TypeScript (dashboard WASM, arnés `vs`).

### 4.1 Regla general

| Capa | Idioma | Ejemplo |
|---|---|---|
| **Identificadores de código** (columnas, alias, variables, funciones) | 🇬🇧 Inglés | `avg_fare_amount`, `def load_trips_parquet()`, `const tripCount` |
| **Nombres de archivo, script, módulo** | 🇬🇧 Inglés | `vs.ts`, `data_generator.py`, `io_meter.py`, `Dashboard.tsx` |
| **Rutas y nombres de dataset derivado** | 🇬🇧 Inglés | `data/derived/trips_by_hour.parquet`, `flights_clean.parquet` |
| **Nombres de columna en el Parquet derivado** | 🇬🇧 Inglés | `pickup_hour`, `tip_pct`, `carrier`, `delay_minutes` |
| **Comentarios de código** | 🇪🇸 Español | `# la proyección de columnas es la que hace la diferencia acá` |
| **Textos de interfaz del dashboard (UI)** | 🇪🇸 Español | `"Promedio de propina por hora"`, `"Cargando consulta…"` |
| **Narrativa del tutorial** | 🇪🇸 Español | Todo el texto fuera de bloques de código |

> 📝 **Por qué esta regla.** Un pipeline de datos real mantenido por un
> equipo técnico nombra columnas y scripts en inglés (con comentarios en
> español, igual que acá), porque ese vocabulario es el que el estudiante
> va a encontrar en cualquier equipo de datos. El dashboard final —lo que
> ve un usuario final hispanohablante— sí lleva textos en español, igual
> que cualquier producto en producción con esa audiencia.

### 4.2 Qué se traduce y qué no (criterio rápido)

| Elemento | ¿Inglés? | Ejemplo |
|---|---|---|
| Nombre de columna en Parquet/CSV derivado | ✅ Sí | `pickup_datetime`, `trip_distance`, `fare_amount` |
| Alias de `SELECT ... AS` | ✅ Sí | `SELECT AVG(fare_amount) AS avg_fare` |
| Nombre de función/script Python o TS | ✅ Sí | `measure_bytes_read()`, `runDuckdbVsPolars()` |
| Constantes de configuración | ✅ Sí | `CHUNK_SIZE`, `CACHE_WARM_RUNS` |
| Comentarios `#`, `//`, `/* */` | ❌ No | `# frío: primera corrida, sin cache del SO` |
| Etiquetas y textos del dashboard WASM | ❌ No | `"Vuelos por aerolínea"`, `"Sin datos para este filtro"` |
| Nombres de fase, sección y dominio en la narrativa | ❌ No | El texto sigue hablando de "viajes", "vuelos", "permisos" |
| Título de las entradas de `BENCHMARKS.md` | ✅ Sí (identificador) / ❌ No (descripción) | `duckdb_vs_polars_groupby` como id; "DuckDB vs Polars: agregación de referencia" como descripción |

> ⚠️ **Caso frecuente — nombres de dataset original vs derivado.** Si un
> dataset público llega con columnas en otro idioma o con nombres poco
> claros (`VendorID`, `tpep_pickup_datetime`), el curso lo respeta tal cual
> en la **fuente**, pero cuando se materializa un Parquet derivado (Fase 6)
> se renombra a un esquema propio, consistente y en inglés (`vendor_id`,
> `pickup_datetime`). Ese renombrado es parte de la lección: "materializar"
> también es una oportunidad de imponer forma.

### 4.3 Diccionario de traducción del dominio (SQL relacional → analítico columnar)

El diccionario completo vive en `BENCHMARKS.md`/notas de cada fase; como
referencia mínima, el vocabulario que atraviesa el curso:

| Instinto relacional (SQL transaccional) | Su forma en Cristalería (DuckDB / columnar) |
|---|---|
| `CREATE TABLE` + `COPY`/`INSERT` antes de consultar | `SELECT ... FROM read_parquet('archivo.parquet')` directo, sin carga |
| Índice B-tree para acelerar un filtro | Proyección de columnas + orden físico del Parquet (comprimir mejor, leer menos) |
| Normalizar en varias tablas para evitar redundancia | Denormalizar hacia una tabla ancha cuando se lee siempre junta (ver villano, §6) |
| Transacción ACID multi-fila | No aplica: el archivo es inmutable, se reemplaza entero, no se actualiza fila por fila |
| `EXPLAIN` / `EXPLAIN ANALYZE` | Existen igual en DuckDB — 🩻 esto sí viaja igual |
| Escalar verticalmente el servidor de base de datos | Escalar el proceso local (más RAM/disco) o pasar a spilling/streaming antes de pensar en clúster |
| Vista materializada | Parquet derivado materializado a disco (Fase 6) — misma idea, otro mecanismo |

### 4.4 Convenciones de nombrado

- **Columnas y variables:** `snake_case` en inglés — `pickup_hour`,
  `avg_tip_pct`, `bytes_read`.
- **Funciones y scripts Python:** `snake_case` — `load_parquet()`,
  `measure_io()`, `run_benchmark()`.
- **Módulos y funciones TypeScript (dashboard/arnés `vs`):** `camelCase` —
  `runDuckdbQuery()`, `loadWasmDb()`, `formatBenchmarkRow()`.
- **Componentes del dashboard:** `PascalCase` en inglés —
  `RevenueChart.tsx`, `FilterPanel.tsx`.
- **Archivos de datos derivados:** descriptivos, en inglés,
  `snake_case.parquet` — `trips_by_hour_2025.parquet`.
- **Entradas de `BENCHMARKS.md`:** id en inglés `snake_case`, descripción en
  español — ver ejemplo en §4.2.

### 4.5 Lo que nunca cambia

- **Comentarios de código:** 100% español, explicando el porqué.
- **Textos de interfaz del dashboard:** 100% español.
- **Narrativa del tutorial:** 100% español, sin voseo.
- **Nombres propios del dominio en la narrativa:** "viajes", "vuelos",
  "permisos", "propina", "demora" siguen siendo las palabras con que
  *hablas* del sistema, aunque las columnas digan `trips`, `flights`,
  `permits`, `tip_amount`, `delay_minutes`.

---

## 5. Orientación a la práctica

Cada concepto se ancla en el dominio de Cristalería (viajes, vuelos,
permisos, precios) y en código que corre de verdad contra un motor real.

- **Nada de teoría suelta.** Si se explica vectorización, se explica sobre
  el `AVG(fare_amount)` de diez millones de filas, no en abstracto.
- **Código ejecutable y medido.** Todo fragmento corre con las versiones
  fijadas del stack y, cuando compara rendimiento, corre a través del arnés
  `vs` — nunca una afirmación de tiempo sin su corrida.
- **Código mínimo.** El fragmento más chico que muestra el punto, pero
  ejecutable.
- **Comentarios que explican el porqué, siempre en español.**
  `# se lee solo esta columna: el resto ni toca disco` sí; `# suma valores`
  no.
- **Distinguir capas.** Siempre queda claro si algo pasa en la consulta SQL,
  en el pipeline de Python (pandas/Polars), en el Parquet derivado, o en el
  cliente WASM del navegador. Es la distinción que salva a quien depura un
  query lento.

---

## 6. El villano y su manejo (el corazón del curso)

- **El villano es levantar infraestructura pesada para lo que cabe en un
  proceso**: un data warehouse gestionado o un clúster de Spark para
  analítica que DuckDB resuelve en segundos sobre un Parquet local. Se
  introduce con su primer aviso en la Fase 5 y se autopsia con números en
  la Fase 11.
- **No modernizar el reflejo antes de medirlo.** Si el ejemplo del villano
  es "cargar todo a un warehouse con su `COPY` de media hora", se muestra
  así, con su costo real estimado — no se lo caricaturiza sin números.
- **El reverso también se nombra.** Usar el motor embebido donde sí hacía
  falta el clúster (concurrencia de miles de usuarios, escritura
  transaccional, datos que no caben ni ordenados) es la otra cara del mismo
  villano: "usar el motor donde no toca" corre en ambas direcciones, tal
  como fija el villano transversal de la Ruta NoSQL.
- **Corrección mínima vs. rediseño.** Ante un query lento, se distingue "el
  ajuste que resuelve hoy" (proyectar menos columnas, materializar) de "el
  rediseño de arquitectura" (¿de verdad hace falta un clúster?).
- **El idioma del código (§4) no es negociable ni en el ejemplo del
  villano.** El warehouse mal usado se muestra con columnas e
  identificadores en inglés igual que el resto: la fealdad que se enseña es
  de decisión de arquitectura, no de idioma.

---

## 7. Marcadores y callouts (vocabulario visual del curso)

### 7.1 Marcadores de estado

- 💸 **Deuda técnica intencional.** Un atajo que se deja a propósito y se
  paga en otra fase (ej.: no materializar en la Fase 1 a propósito, para
  sentir el costo, y pagarlo materializando en la Fase 6).
- 🔥 **Opcional / ampliación** (fuera del alcance base, ver `-ALCANCE.md`).
- ⭐ **Fase o pieza central.** En Cristalería: Fases 3, 4 y 11.
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** Fácil / intermedio / difícil / muy
  difícil.

### 7.2 Callouts en blockquote

- 📝 **Nota de época/contexto.** Por qué un reflejo existe (ej.: "el
  reflejo de `CREATE TABLE` + `COPY` viene de dos décadas de motores
  transaccionales; no es irracional, es el instinto correcto en otro
  contexto").
- 📚 **Referencia rápida inline.** Un enlace justo donde surge la duda.
- 🪦 **Retiro.** Cuando algo cumple su función y se apaga (ej.: "🪦 se apaga
  el warehouse de prueba del villano: ya dio su número").
- ⚠️ **Advertencia.** Algo que rompe si se ignora (versión de DuckDB,
  cliente Node deprecado, límites de memoria en WASM).
- 💡 **Truco o atajo** que ahorra tiempo real.

### 7.3 Secciones narrativas recurrentes

- **💸 Pago de deuda.** Dónde se salda una deuda declarada antes.
- **Detalles con intención.** Lista corta que destila decisiones
  deliberadas de un bloque de código o de un query.
- **El patrón a memorizar.** Una o dos frases con la lección transferible.
- **Prueba de fuego.** Verificación manual concreta: "apaga la conexión de
  red, recarga el dashboard: sigue funcionando porque el Parquet ya está
  servido como archivo estático".
- **Mini-repaso.** Cuando una fase usa sintaxis que el lector quizá no
  domina (window functions avanzadas, `PIVOT`/`QUALIFY`, la API lazy de
  Polars), un repaso exprés en tabla antes del código, con su 📚.
- **La señal de que quedó bien.** Cierre en forma de cita verificable: "si
  mañana cambio el Parquet de origen por uno más grande, el dashboard sigue
  cargando sin que yo toque una línea de infraestructura".

### 7.4 Secciones propias del curso (SQL-transaccional → analítico columnar)

Columna vertebral del curso; aparecen cuando el contenido lo pide:

- **📖 Tabla de traducción SQL-transaccional ↔ SQL-analítico-DuckDB.** Lado
  a lado, el reflejo relacional y su forma en DuckDB. Es tabla (§3), no
  prosa.
- **🪞 "Tu instinto SQL dice… y esta vez se equivoca."** Nombra la trampa
  antes de caer: "hay que cargar antes de consultar", "columnar siempre
  gana", "si no entra en RAM, necesito un clúster". Honra el instinto y lo
  recalibra con un número del arnés `vs`.
- **🩻 "Esto sí funciona igual."** Lo reconfortante: `WHERE`, `SELECT`,
  `EXPLAIN`, la semántica de tipos, la selectividad de un filtro. Baja la
  ansiedad del lector senior.
- **⚰️ Caso de estudio: el villano.** El warehouse/clúster sobredimensionado,
  medido, duele, se compara. Es el hilo que cose las fases 5, 6 y 11.

---

## 8. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden:

1. **🎯 Propósito** — qué resuelve esta fase; puede abrir con la situación
   heredada ("hasta ahora consultábamos el archivo entero cada vez…").
2. **✅ Qué queda listo al terminar** — checklist verificable.
3. **🚫 Qué queda fuera por ahora** — qué se difiere y a qué fase (coherente
   con `CRISTALERIA-ALCANCE.md`).
4. **🧠 Conceptos mínimos** — solo lo necesario, anclado al dominio. Aquí
   viven el **Mini-repaso**, las **Notas de época**, la 📖 tabla de
   traducción y los recuadros 🪞/🩻.
5. **💻 Implementación y código comentado** — el grueso; código ejecutable
   con comentarios de porqué, identificadores en inglés (§4). Aquí caben
   **Detalles con intención**, **El patrón a memorizar**, **Prueba de
   fuego** y **💸 Pago de deuda**.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente (un
   query lento, un Parquet mal materializado) y cómo depurarlo con
   `EXPLAIN ANALYZE` y el medidor de E/S.
7. **🧪 Ejercicios progresivos** — 20 a 40 (§9), graduados 🟢🟡🟠🔴.
8. **📚 Referencias** — §10, al final del capítulo.
9. **🚀 Cierre y conexión con la siguiente fase** — qué sigue y por qué.
   Aquí va **La señal de que quedó bien**.

Los apéndices no siguen esta plantilla: usan índice de salto rápido +
secciones cortas + tabla "cuándo usar qué" + 5-10 ejercicios cortos.

---

## 9. Ejercicios

- **Cantidad: mínimo 20, ideal 30-35 por fase** (rango de la semilla:
  20-40; usar 30 como default salvo que la fase lo justifique).
- **Distribución equilibrada por nivel.** Guía razonable para ~30: ~8 🟢
  (correr una consulta, leer un Parquet, medir bytes), ~9 🟡 (agregación no
  trivial, un `PIVOT`, un join simple), ~7 🟠 (reproducir un duelo del
  `vs`, materializar y comparar, medir spilling), ~5 🔴 (integrar varias
  fases, optimizar un query grande, montar una consulta en WASM), más los
  🔥 opcionales aparte.
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
- **Progresión real.** Los 🟢 calientan; los 🔴 exigen integrar varias fases
  o depurar algo esquivo (reproducir spilling, cerrar un query que lee de
  más, montar una consulta remota con `httpfs`).
- **Accionables y verificables.** "Haz que la consulta sobre `trips.parquet`
  lea menos de 50 MB para responder el promedio de propina por hora" — no
  "reflexiona sobre rendimiento".
- **Al menos un puñado por fase son de diagnóstico.** Se entrega un query
  lento o un Parquet mal materializado y se pide reproducir, medir con el
  medidor de E/S, y localizar la causa.
- **Enganchados al dominio.** Viajes, vuelos, permisos, precios; nunca
  ejemplos abstractos.
- **Cuando un ejercicio nombra código, usa el identificador en inglés
  vigente** ("agrega la columna `tip_pct` al Parquet derivado", "corre
  `measure_io()` sobre el archivo remoto"), aunque el enunciado esté en
  español.
- Los 🔥 son opcionales y se listan aparte, sin numeración continua.

En apéndices bastan 5-10 ejercicios cortos de consulta.

---

## 10. Bibliografía y referencias (al final de cada capítulo/fase)

**Regla:** documentación oficial de la versión fijada en el stack
**primero**; luego libros si aplican; luego blogs, charlas y video; siempre
con advertencia de verificación de versión.

### 10.1 Formato

Cada fase cierra su sección 8 (§8 de la plantilla) con:

- **URLs completas y clicables**, no solo el dominio.
- **Secciones separadas:** Documentación oficial (con URL completa y nota
  de versión), Libros cuando apliquen, Video/apoyo (con URL completa, IDs
  verificados), y **Orden de lectura sugerido** (una línea que encadena qué
  leer primero).
- Este formato es el mismo que ya usa `02-cristaleria-semilla.md` en su
  sección de referencias por fase — se reutiliza tal cual al redactar cada
  fase completa, no se reinventa.

### 10.2 Fuentes oficiales por tema (usar URL completa al citar)

- **DuckDB:** https://duckdb.org/docs/ · línea LTS: https://duckdb.org/docs/lts/
- **DuckDB-Wasm:** https://duckdb.org/docs/lts/clients/wasm/overview
- **Apache Parquet:** https://parquet.apache.org/docs/
- **Apache Arrow:** https://arrow.apache.org/docs/
- **Polars:** https://docs.pola.rs/
- **pandas:** https://pandas.pydata.org/docs/whatsnew/
- **SQLite:** https://www.sqlite.org/docs.html
- **Vite:** https://vitejs.dev/
- **`@duckdb/node-api` (Node Neo):** verificar en npm — el cliente `duckdb`
  clásico está deprecado, no confundir.

### 10.3 Advertencias

- **Sobre citas:** URLs, títulos e IDs de video pueden estar desactualizados
  o ser inexactos; el lector debe verificarlos. No se inventan números de
  página, DOIs ni IDs de video.
- **No usar en el código principal:** el cliente Node `duckdb` deprecado
  (usar `@duckdb/node-api`), versiones de DuckDB anteriores a la fijada en
  el stack de la semilla salvo que se compare explícitamente.
- **Precaución de nombres:** no confundir **CouchDB** (offline-first, curso
  7 de la ruta) con **Couchbase** (rival documental del curso 0); tampoco
  confundir el **DuckDB embebido** de este curso con motores columnares de
  servidor (ClickHouse, etc.) que pertenecen a otra conversación.

---

## 11. Sobre el dominio (datasets públicos reales)

A diferencia de un dominio ficticio, Cristalería usa **datasets públicos
reales** (volcados de viajes, vuelos, permisos). Esto cambia dos cosas
respecto de un curso con dominio inventado:

- **Se verifica la licencia de uso** del dataset elegido antes de fijarlo
  (ver decisión pendiente de la semilla) y se documenta la fuente.
- **El vocabulario de columnas del dataset de origen puede no estar en
  inglés limpio ni ser consistente** (nombres crípticos, mayúsculas
  mezcladas). El curso lo respeta en la fuente y lo normaliza recién al
  materializar (§4.2), nunca antes: mostrar el dato "tal como llega" es
  parte de la propuesta de transparencia del proyecto.

---

## 12. Coherencia entre documentos

- **No contradecir fases anteriores.** Si la Fase 6 fija un esquema de
  columnas para el Parquet derivado, la Fase 9 (dashboard WASM) lo consume
  tal cual.
- **No reescribir decisiones aprobadas** sin señalar explícitamente la
  incompatibilidad y por qué.
- **Fuentes de verdad, en orden:** (1) instrucciones del proyecto de la
  Ruta NoSQL, (2) `RUTA-NOSQL-FUNDAMENTOS.md`, (3)
  `02-cristaleria-semilla.md`, (4) `CRISTALERIA-ALCANCE.md`, (5) esta guía,
  (6) entregables aprobados de fases anteriores, (7) decisiones explícitas
  del chat actual.
- Nombres de scripts, columnas y datasets derivados se mantienen estables
  entre fases (en inglés, §4). Si algo se renombra, se documenta el cambio.

---

## 13. Checklist rápido antes de dar por cerrado un `.md`

- [ ] Sigue la plantilla de 9 secciones (o el formato de apéndice).
- [ ] Tono cálido e informal, segunda persona **sin voseo**, humor con
      moderación.
- [ ] Todo el código corre con las versiones fijadas del stack de
      `02-cristaleria-semilla.md`.
- [ ] **Columnas, scripts, funciones y constantes de código en inglés (§4).**
- [ ] **Comentarios de código y textos del dashboard en español (§4.5).**
- [ ] No contradice ninguna fase anterior ni el alcance fijado en
      `CRISTALERIA-ALCANCE.md`.
- [ ] Distingue capas (SQL / pipeline Python / Parquet derivado / cliente
      WASM) donde importa.
- [ ] Usa el vocabulario de callouts (📝 🪦 📚 ⚠️ 💡) y los recuadros
      📖 🪞 🩻 ⚰️ ⚖️ donde aporten.
- [ ] Marca 💸 la deuda técnica (y la paga si corresponde) y 🔥 lo opcional.
- [ ] Tiene 20-40 ejercicios numerados con rangos 🟢🟡🟠🔴 equilibrados (o
      5-10 en apéndices), ninguna afirmación de rendimiento sin su fila en
      `BENCHMARKS.md`.
- [ ] **Referencias con URL completa al final del capítulo**, secciones
      (oficial / libros / video / orden de lectura), advertencia de
      versión.
- [ ] Explica el *porqué* de cada decisión relevante.
- [ ] Incluye "La señal de que quedó bien" en el cierre.
