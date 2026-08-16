# 🧩 El Vigía — Prompts reutilizables

Prompts autónomos para generar el contenido del curso **El Vigía** (series
temporales, curso #8 de la Ruta NoSQL) en un proyecto nuevo, sin necesitar
este proyecto de fábrica como contexto previo. Cada uno incluye el mínimo de
contexto de dominio y stack necesario para correr solo.

Orden de uso: **Prompt 0** (arranque de Fase 0) → **Prompt de fase**
(reutilizado 11 veces, una por fase 1–11) → **Prompts transversales**
(`INSTINTOS.md`, `BENCHMARKS.md`, diccionario de traducción) según se vayan
necesitando a lo largo del curso.

---

## 🚀 Prompt 0 — Arranque de la Fase 0 (el laboratorio de tres relojes)

```
Eres un instructor senior escribiendo la Fase 0 de "El Vigía", un curso de
series temporales para ingenieros senior de bases de datos relacionales.

CONTEXTO DEL CURSO
El Vigía es un sistema de monitoreo de métricas de infraestructura: recibe
un flujo continuo de mediciones desde una flota de hosts (uso de CPU,
memoria, disco, latencia de red, contadores de request), las almacena por
tiempo, y responde consultas de tablero con retención escalonada y
downsampling automático. El curso mide tres motores en paralelo contra el
mismo dataset semántico:

- InfluxDB 3 Core (motor de series dedicado, generación reescrita en Rust,
  motor columnar sobre formato tipo Parquet) — motor principal del curso.
- TimescaleDB (extensión de PostgreSQL 17/18 con hypertables) — rival #1:
  "no necesitas un motor nuevo, extiende el que ya tienes".
- MongoDB 8.x con colecciones Time Series nativas — rival #2: evidencia de
  que hasta un motor documental generalista incorporó soporte de primera
  clase para este patrón.

Stack transversal: Node.js 24 LTS + TypeScript 5.x, Docker/Podman,
Grafana opcional. Todo enteramente contenerizado.

El VILLANO del curso: guardar series temporales en una tabla genérica
`metrics(id, timestamp, metric, host, value)` con un índice B-tree sobre
`timestamp`, sin partición ni compresión especializada — "funciona" con diez
mil filas, se convierte en un pantano a los tres mil millones.

EL LECTOR
Es un ingeniero senior de bases de datos relacionales. Sabe SQL, índices,
`EXPLAIN`, transacciones. No le expliques eso. Lo que no sabe es cómo el eje
temporal cambia el diseño físico, la cardinalidad como métrica de diseño, y
la retención como decisión de día 0, no de mantenimiento.

QUÉ CONSTRUYE ESTA FASE (0)
1. Un `docker-compose.yml` que levanta los tres motores (InfluxDB 3 Core,
   PostgreSQL 17/18 con extensión TimescaleDB, MongoDB 8.x) con un comando,
   datos efímeros por defecto y volúmenes nombrados opcionales para persistir.
2. Un generador de telemetría en TypeScript que produce el MISMO dataset
   semántico (misma flota de hosts, misma cadencia, misma cardinalidad) en
   tres formas de entrada: line protocol (InfluxDB), SQL/inserts (Timescale),
   documentos Time Series (Mongo). Cardinalidad y cadencia deben ser
   parametrizables.
3. El arnés `scripts/vs.ts`: corre la misma consulta semántica contra los
   motores en juego, descarta warm-up, cronometra percentiles (p50/p95/p99,
   no solo promedio), mide tamaño en disco tras compresión, y escribe a
   `BENCHMARKS.md`.
4. El primer recuadro 🩻 "esto SÍ viaja igual": SQL, EXPLAIN, la noción de
   índice y selectividad, y "mide antes de optimizar" cruzan intactos desde
   el mundo relacional a los tres motores.

FORMATO OBLIGATORIO
Sigue exactamente la plantilla de 9 secciones: 🎯 Propósito, ✅ Qué queda
listo al terminar, 🚫 Qué queda fuera por ahora, 🧠 Conceptos mínimos, 💻
Implementación y código comentado, ⚠️ Errores comunes y pieza forense, 🧪
Ejercicios progresivos (20-40, graduados 🟢🟡🟠🔴, numeración continua con
rangos, enunciados sin voseo), 📚 Referencias (documentación oficial con URL
completa y advertencia de verificar versión; nunca inventar DOIs o IDs de
video), 🚀 Cierre y conexión con la siguiente fase (con "La señal de que
quedó bien").

REGLAS DE FORMA
- Código (identificadores, endpoints, measurements/hypertables/colecciones,
  tags, campos, nombres de archivo) SIEMPRE en inglés. Comentarios de código,
  narrativa, textos de interfaz SIEMPRE en español.
- Trata al lector de "tú", nunca de "vos". Cero voseo en todo el documento.
- Tono cálido, informal, de colega senior a colega senior, con humor
  moderado. Prosa antes que listas; tablas solo para comparar/decidir/mapear.
- No inventes números de página, DOIs ni IDs de video; marca que las URLs
  deben verificarse antes de publicar.

Escribe la Fase 0 completa como un único archivo `.md`.
```

---

## 📄 Prompt-plantilla por fase (reutilizable, fases 1–11)

Rellena los placeholders `{{...}}` con los datos de la fase correspondiente
(la tabla de la semilla `08-el-vigia-semilla.md` §"Estructura de fases" trae
todos los valores para las once fases).

```
Eres un instructor senior escribiendo la Fase {{NÚMERO}} de "El Vigía", un
curso de series temporales para ingenieros senior de bases de datos
relacionales. Esta fase se llama "{{TÍTULO DE LA FASE}}".

CONTEXTO MÍNIMO DEL CURSO (por si no tienes fases anteriores a mano)
El Vigía es un sistema de monitoreo de métricas de infraestructura, medido
en paralelo contra InfluxDB 3 Core (motor de series dedicado), TimescaleDB
(hypertables sobre PostgreSQL 17/18) y MongoDB 8.x con colecciones Time
Series nativas. Stack: Node.js 24 LTS + TypeScript 5.x, todo contenerizado.
El villano del curso es una tabla `metrics(id, timestamp, metric, host,
value)` genérica con índice B-tree sobre `timestamp`, sin partición ni
compresión, que colapsa a escala. El lector es senior de SQL: no le
expliques índices ni transacciones; recalíbrale el instinto sobre el eje
temporal.

Existe un arnés de benchmark, `scripts/vs.ts`, que corre la misma consulta
semántica contra los motores en juego, descarta warm-up, mide percentiles de
latencia y tamaño en disco comprimido, y alimenta `BENCHMARKS.md`. NINGUNA
afirmación de rendimiento entra a esta fase sin pasar por ese arnés.
`INSTINTOS.md` acumula, fase a fase, el ritual 🪞 predicción → cronometrado →
veredicto sobre los instintos SQL puestos a prueba.

NÚCLEO DE ESTA FASE
{{NÚCLEO — pegar la columna "Núcleo" de la tabla de fases de la semilla}}

"VS" DE ESTA FASE (qué se mide, contra quién)
{{VS DE LA FASE — pegar la columna "Vs de la fase" de la tabla de la semilla}}

DESARROLLO NARRATIVO DE LA FASE (si la semilla trae una sección propia
"### Fase {{NÚMERO}} — ..." con más detalle, pégala aquí completa; si no,
deriva el desarrollo del núcleo y el "vs" de arriba, manteniendo coherencia
con las fases anteriores).
{{DESARROLLO NARRATIVO DETALLADO DE LA SEMILLA, SI EXISTE}}

RECUADROS A INCLUIR SI APLICAN A ESTA FASE
- 🪞 "tu instinto SQL dice… y esta vez se equivoca" — nombra la trampa antes
  de caer en ella.
- 🩻 "esto sí viaja igual" — lo que no cambia respecto del mundo relacional.
- 📖 tabla de traducción SQL ↔ InfluxDB/TimescaleDB/Mongo, si la fase toca
  consultas.
- ⚰️ autopsia del villano con números antes/después, si la fase mide contra
  la tabla genérica.
- ⭐ si la semilla marca esta fase como central, dale ese peso narrativo.

FORMATO OBLIGATORIO (plantilla de 9 secciones, en este orden)
1. 🎯 Propósito — puede abrir enlazando con lo heredado de la fase anterior.
2. ✅ Qué queda listo al terminar — checklist verificable.
3. 🚫 Qué queda fuera por ahora — qué se difiere y a qué fase.
4. 🧠 Conceptos mínimos — anclados al dominio del monitoreo; aquí van 📖/🪞/🩻
   si aplican.
5. 💻 Implementación y código comentado — código ejecutable, identificadores
   en inglés, comentarios de porqué en español; incluye Detalles con
   intención y El patrón a memorizar.
6. ⚠️ Errores comunes y pieza forense — qué se rompe típicamente y cómo
   depurarlo con EXPLAIN/profiler del motor correspondiente.
7. 🧪 Ejercicios progresivos — entre 20 y 40, graduados 🟢🟡🟠🔴, numeración
   continua con encabezado de rango por dificultad, al menos un par de
   diagnóstico (se entrega un motor mal configurado y se pide reproducir y
   localizar antes de arreglar), enganchados al dominio (hosts, métricas,
   tags, ventanas, retención), enunciados SIN voseo. Los 🔥 opcionales van
   aparte sin numeración continua.
8. 📚 Referencias — documentación oficial con URL completa y nota de
   versión a verificar; libros y video solo si existen y se marcan como "a
   verificar"; nunca inventar DOIs, páginas ni IDs de video.
9. 🚀 Cierre y conexión con la siguiente fase — incluye "La señal de que
   quedó bien".

REGLAS DE FORMA (no negociables)
- Código en inglés; narrativa, comentarios y UI en español.
- Trata al lector de "tú"; cero voseo.
- Prosa antes que listas; tablas solo para comparar/decidir/mapear.
- No contradigas ninguna fase anterior ni el dataset semántico del
  generador (mismo host, métrica, tag y valor en las tres formas de entrada).
- Si esta fase agrega una entrada a `INSTINTOS.md` o a `BENCHMARKS.md`,
  escríbela también, siguiendo el formato de esos dos artefactos.

Escribe la Fase {{NÚMERO}} completa como un único archivo `.md`.
```

---

## 📓 Prompt — `INSTINTOS.md` (arranque y actualización)

```
Genera o actualiza `INSTINTOS.md`, el cuaderno acumulativo de instintos SQL
puestos a prueba en el curso "El Vigía" (series temporales: InfluxDB 3 Core,
TimescaleDB, MongoDB Time Series, medidos con el arnés `scripts/vs.ts`).

Cada entrada sigue el ritual de tres pasos:
1. 🪞 PREDICCIÓN — la frase textual del instinto relacional, en primera
   persona del ingeniero que llega de SQL. Ej.: "meterle un índice al
   timestamp resuelve el rango".
2. ⏱️ CRONOMETRADO — qué se midió con `vs.ts` para poner a prueba esa
   predicción (motores comparados, dataset, qué percentil o métrica se miró).
3. ⚖️ VEREDICTO — uno de: confirmado / recalibrado / refutado, con una
   frase que resume qué cambia el instinto original.

Si estás arrancando el archivo, crea la entrada de la Fase 1 (el instinto
del índice sobre `timestamp`). Si estás actualizando, añade la entrada de la
fase que corresponda sin reescribir las anteriores. Instintos que el curso
va acumulando fase a fase, para referencia: Fase 1 el índice sobre
timestamp; Fase 2 "el índice ya me da el rango"; Fase 4 "un tag más no
cuesta nada" (cardinalidad); Fase 5 "ya hago el downsampling con un GROUP BY
nocturno"; Fase 9 throughput vs. latencia y por qué las colas mienten.

Formato: español, sin voseo, tono cálido pero preciso — este documento es
evidencia, no narrativa de fase. Markdown, una entrada por instinto, en
orden de aparición.
```

---

## 📊 Prompt — `BENCHMARKS.md` (arranque y actualización)

```
Genera o actualiza `BENCHMARKS.md`, el registro acumulativo de todo "vs"
medido en el curso "El Vigía" con el arnés `scripts/vs.ts`.

Cada entrada de benchmark registra, en tabla o en prosa breve con tabla de
apoyo:
- Fase de origen.
- Consulta semántica ejecutada (en palabras, no solo el código).
- Motores comparados (InfluxDB 3 Core / TimescaleDB / MongoDB Time Series /
  la tabla genérica villana, según corresponda).
- Dataset: cardinalidad y cadencia usadas.
- Número de corridas y cuántas se descartaron como warm-up.
- Percentiles de latencia (p50/p95/p99) — nunca solo el promedio.
- Tamaño en disco tras compresión (si aplica a esa consulta).
- Una línea de interpretación: qué dice el número, no una opinión sin
  respaldo.

Los cuatro duelos que atraviesan el curso, para ubicar cada entrada:
1. InfluxDB 3 vs. tabla genérica en Postgres (el villano) — ingesta,
   tamaño en disco, consulta de rango.
2. InfluxDB 3 vs. TimescaleDB — ingesta, compresión, agregados continuos vs.
   downsampling nativo, ergonomía de consulta.
3. InfluxDB 3 vs. MongoDB Time Series nativo — cuánto acorta la brecha el
   generalista con soporte de primera clase.
4. MongoDB Time Series nativo vs. bucket pattern manual en Mongo — qué
   compra el soporte nativo frente a la artesanía a mano.

Esta tabla se alimenta EXCLUSIVAMENTE de corridas reales de `vs.ts` — nunca
de benchmarks de marketing de ningún motor, nunca "de memoria". Si no hay
una corrida real disponible todavía, marca la entrada como pendiente en vez
de inventar números.

Formato: español, sin voseo, markdown, tablas para los datos numéricos,
prosa breve solo para la interpretación.
```

---

## 📖 Prompt — Diccionario de traducción SQL ↔ motor temporal

```
Genera (o extiende) la tabla de traducción SQL ↔ InfluxDB ↔ TimescaleDB ↔
MongoDB Time Series para la Fase {{NÚMERO}} de "El Vigía", curso de series
temporales.

Para cada operación relacional relevante a esta fase, arma una fila con:
- La consulta o concepto en SQL estándar (ej. `GROUP BY date_trunc(...)`,
  índice B-tree, `BETWEEN`, `UPDATE`, retención manual con un cron).
- Su equivalente en InfluxDB 3 Core (SQL nativo si Core lo soporta, o su
  lenguaje de consulta vigente — verificar en la Fase 0 cuál aplica).
- Su equivalente en TimescaleDB (SQL puro sobre PostgreSQL con las
  funciones/objetos de Timescale: `time_bucket`, hypertable, continuous
  aggregate, retention policy, según corresponda).
- Su equivalente en MongoDB Time Series (aggregation pipeline sobre una
  colección Time Series nativa, o el bucket pattern manual si la fase
  compara ambos — ver Fase 7).
- Una nota corta de matiz cuando el equivalente no sea 1 a 1 (ej.
  "TimescaleDB no tiene UPDATE de negocio sobre el histórico: hay append e
  inmutabilidad, no corrección").

Contexto de la fase para calibrar qué operaciones incluir:
{{NÚCLEO Y "VS" DE LA FASE — pegar de la semilla o del prompt de fase}}

Formato: tabla markdown (nunca prosa para esto — es explícitamente
comparar/mapear), español para las notas, identificadores de código en
inglés dentro de los ejemplos, sin voseo. Si algún equivalente requiere
verificar la versión vigente del lenguaje de consulta (caso típico:
InfluxDB 3 Core, SQL vs. InfluxQL), márcalo con ⚠️ "verificar en Fase 0".
```
