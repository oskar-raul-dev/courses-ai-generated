# 🦆 Cristalería — Prompts de arranque

Prompts reutilizables para generar el contenido del curso **Cristalería**
(analítico columnar embebido y sin servidor, con DuckDB) en una conversación
o proyecto nuevo. Cada prompt es **autónomo**: incluye el contexto mínimo
necesario para correr sin depender de este proyecto de fábrica. Antes de
usarlos, adjunta los archivos fuente que cada uno referencia
(`02-cristaleria-semilla.md`, `CRISTALERIA-ALCANCE.md`,
`CRISTALERIA-GUIA-ESTILO.md`) en el proyecto nuevo.

---

## 1. Prompt de arranque de Fase 0

```
Vas a escribir la Fase 0 del curso "Cristalería": analítico columnar
embebido y sin servidor, con DuckDB como motor central, contra pandas,
Polars y SQLite como rivales medidos.

CONTEXTO DEL CURSO (resumen autónomo):
Cristalería enseña el modelo de acceso analítico-columnar-embebido a través
de un pipeline de tres tramos sobre datasets públicos reales en
Parquet/CSV: (1) consulta directa sin carga previa, (2) transformación y
materialización de un Parquet derivado, (3) publicación de un dashboard
que corre enteramente en el navegador vía DuckDB-Wasm. El lector es un
ingeniero senior que vive en SQL relacional/transaccional; el curso no le
explica lo obvio de SQL, le recalibra el instinto de "cargar antes de
consultar" y el reflejo de levantar infraestructura pesada (warehouse,
clúster) para analítica que cabe en un proceso. Cada comparación de
rendimiento se corre con un arnés propio (`scripts/vs.ts` / `vs.py`) y se
registra en `BENCHMARKS.md`; nunca se afirma "es más rápido" sin la fila
correspondiente. `INSTINTOS.md` registra cada instinto SQL puesto a
prueba, falsable, con predicción, experimento y veredicto.

STACK FIJADO (verificar versiones exactas vigentes antes de escribir):
DuckDB 1.5.x (o LTS 1.4.x), DuckDB-Wasm, Python 3.12+, Polars 1.4x,
pandas 3.0.x (PyArrow, Copy-on-Write), SQLite 3.4x, Apache Arrow/Parquet,
TypeScript 5.x, Vite 6.x, Node.js 24.x LTS, Docker/Podman Compose v2.
Cliente Node correcto: `@duckdb/node-api` (Node Neo) — el paquete `duckdb`
clásico está deprecado, no usarlo.

QUÉ CONSTRUYE ESTA FASE:
- Entorno contenerizado con los cuatro motores (DuckDB, pandas, Polars,
  SQLite) instalados y verificables lado a lado; un docker-compose de
  trabajo.
- El generador de datos que produce Parquet de tamaño controlado (mismo
  esquema, N creciente) para aislar variables en los benchmarks.
- Nace el arnés `vs` (vs.ts y vs.py) con su primer duelo trivial que
  confirma que la medición es reproducible (mismo dataset, misma máquina,
  caché frío/caliente reportados por separado).
- `INSTINTOS.md` y `BENCHMARKS.md` vacíos pero con su estructura definida.
- Arranca el diccionario de traducción SQL-transaccional → SQL-analítico-
  de-DuckDB (en su mayoría: "es el mismo SQL, con superpoderes
  analíticos").

REGLAS DE ESTILO (resumen — el detalle completo está en
CRISTALERIA-GUIA-ESTILO.md, adjúntalo si está disponible):
- Español sin voseo para toda la narrativa; código (identificadores,
  columnas, scripts) en inglés; comentarios de código en español.
- Tono cálido, informal, de colega senior a colega senior, humor con
  moderación. No expliques lo obvio de SQL.
- Prosa antes que listas; tablas solo para comparar/decidir/mapear.
- Plantilla obligatoria de 9 secciones (🎯 Propósito, ✅ Qué queda listo,
  🚫 Qué queda fuera, 🧠 Conceptos mínimos, 💻 Implementación y código
  comentado, ⚠️ Errores comunes y pieza forense, 🧪 Ejercicios
  progresivos, 📚 Referencias, 🚀 Cierre y conexión con la siguiente
  fase).
- 20-40 ejercicios graduados 🟢🟡🟠🔴 con numeración continua y
  encabezado de rango por dificultad; algunos de diagnóstico.
- Referencias con URL completa al final del capítulo, en secciones
  (oficial / libros / video / orden de lectura), con advertencia de que
  deben verificarse antes de citar. No inventes DOIs, IDs de video ni
  números de página.
- Callouts propios del curso: 📖 tabla de traducción, 🪞 "tu instinto SQL
  dice… y esta vez se equivoca", 🩻 "esto sí funciona igual", ⚰️ caso de
  estudio del villano (recién arranca en fases posteriores), 📝 nota de
  época, 🪦 retiro, ⚠️ advertencia, 💡 truco, 💸 deuda técnica.

TAREA:
Escribe la Fase 0 completa ("🧪 Laboratorio y primer quack") siguiendo la
plantilla de 9 secciones. Incluye el Containerfile/docker-compose de
trabajo, el esqueleto del generador de datos, el primer duelo trivial del
arnés `vs` (instalación de los cuatro motores lado a lado, medido), y dale
forma inicial a INSTINTOS.md y BENCHMARKS.md como artefactos que se van a
ir llenando. Cierra con la conexión a la Fase 1 (consulta directa).
```

---

## 2. Prompt-plantilla por fase (rellenar `{{...}}`)

```
Vas a escribir la Fase {{N}} del curso "Cristalería": analítico columnar
embebido y sin servidor, con DuckDB como motor central, contra pandas,
Polars y SQLite como rivales medidos.

CONTEXTO DEL CURSO (resumen autónomo — igual en todas las fases):
Cristalería enseña el modelo de acceso analítico-columnar-embebido a través
de un pipeline de tres tramos sobre datasets públicos reales en
Parquet/CSV: (1) consulta directa sin carga previa, (2) transformación y
materialización de un Parquet derivado, (3) publicación de un dashboard
que corre enteramente en el navegador vía DuckDB-Wasm. El lector es un
ingeniero senior que vive en SQL relacional/transaccional. El villano
transversal del curso es levantar infraestructura pesada (warehouse,
clúster) para analítica que cabe en un proceso — y, en su reverso, usar el
motor embebido donde sí hacía falta un clúster. Toda comparación de
rendimiento corre a través del arnés `scripts/vs.ts` / `vs.py` y queda
registrada en `BENCHMARKS.md`, con fecha, versión de cada motor, tamaño
del dataset y caché frío/caliente por separado; nunca se afirma
rendimiento sin esa fila. `INSTINTOS.md` acumula cada instinto SQL puesto
a prueba de forma falsable.

STACK FIJADO (reconfirmar versión exacta si pasó tiempo desde que se
fijó): DuckDB 1.5.x (o LTS 1.4.x), DuckDB-Wasm, Python 3.12+, Polars
1.4x, pandas 3.0.x, SQLite 3.4x, Apache Arrow/Parquet, TypeScript 5.x,
Vite 6.x, Node.js 24.x LTS (cliente `@duckdb/node-api`, no el `duckdb`
deprecado).

QUÉ YA EXISTE ANTES DE ESTA FASE (adjunta las fases previas si están
disponibles; si no, resume aquí lo que la fase anterior dejó listo, según
`02-cristaleria-semilla.md`):
{{resumen de qué dejó lista la fase N-1: pipeline construido hasta ahora,
esquema del Parquet derivado si ya existe, qué rivales entraron al vs,
qué instintos ya se pusieron a prueba}}

NÚCLEO DE ESTA FASE (según la semilla — estructura de fases):
{{copiar la fila correspondiente de la tabla "🌳 Estructura de fases" de
02-cristaleria-semilla.md: nombre de la fase, núcleo, "vs" de la fase}}

QUÉ DEBE QUEDAR LISTO AL CERRAR ESTA FASE:
{{objetivos concretos y verificables de la fase, derivados de la
descripción de la fase en la semilla}}

REGLAS DE ESTILO (resumen — el detalle completo está en
CRISTALERIA-GUIA-ESTILO.md, adjúntalo si está disponible):
- Español sin voseo para toda la narrativa; código (identificadores,
  columnas, scripts) en inglés; comentarios de código en español; textos
  del dashboard en español.
- Tono cálido, informal, de colega senior a colega senior, humor con
  moderación. No expliques lo obvio de SQL relacional.
- Prosa antes que listas; tablas solo para comparar/decidir/mapear.
- Plantilla obligatoria de 9 secciones (🎯 Propósito, ✅ Qué queda listo,
  🚫 Qué queda fuera, 🧠 Conceptos mínimos, 💻 Implementación y código
  comentado, ⚠️ Errores comunes y pieza forense, 🧪 Ejercicios
  progresivos, 📚 Referencias, 🚀 Cierre y conexión con la siguiente
  fase).
- 20-40 ejercicios graduados 🟢🟡🟠🔴, numeración continua con encabezado
  de rango, distribución aproximada 8🟢/9🟡/7🟠/5🔴 más 🔥 opcionales
  aparte; al menos un puñado de diagnóstico (se entrega un query lento o
  un Parquet mal materializado y se pide reproducir, medir y localizar la
  causa); todos anclados al dominio del dataset elegido (nunca ejemplos
  abstractos).
- Referencias con URL completa al final del capítulo, en secciones
  (oficial / libros / video / orden de lectura), advertencia de
  verificación de versión y de que las URLs pueden estar desactualizadas.
  No inventar DOIs, IDs de video ni números de página.
- Usa los callouts propios del curso donde aporten: 📖 tabla de traducción
  SQL-transaccional ↔ SQL-analítico-DuckDB, 🪞 "tu instinto SQL dice… y
  esta vez se equivoca", 🩻 "esto sí funciona igual", ⚰️ caso de estudio
  del villano (si esta fase lo toca), 📝 nota de época, 🪦 retiro, ⚠️
  advertencia, 💡 truco, 💸 deuda técnica declarada o pagada, ⭐ si es
  fase central.
- El "vs" de esta fase se implementa como duelo(s) real(es) del arnés
  `scripts/vs.ts`/`vs.py`, no como comparación narrada: se corre, se mide,
  se pega el número en el cuerpo de la fase y se agrega la fila a
  `BENCHMARKS.md`.

ALCANCE (verificar contra CRISTALERIA-ALCANCE.md si está disponible):
Esta fase NO debe entrar en: orquestación de pipelines externa (Airflow/
dbt), un warehouse o clúster real en producción, streaming/ingesta en
tiempo real, concurrencia de escritura multiusuario, ML/feature
engineering, BI de arrastrar-y-soltar, ni particionado distribuido de
DuckDB — salvo que se marque explícitamente como 🔥 opcional.

TAREA:
Escribe la Fase {{N}} completa ("{{emoji}} {{nombre de la fase}}")
siguiendo la plantilla de 9 secciones y las reglas de estilo. Incluye el
código del duelo del `vs` de esta fase con su resultado esperado en
`BENCHMARKS.md`, y al menos una entrada nueva propuesta para
`INSTINTOS.md`. Cierra con la conexión a la Fase {{N+1}}.
```

---

## 3. Prompts para artefactos transversales

### 3.1 `INSTINTOS.md`

```
Vas a inicializar (o actualizar) el artefacto acumulativo INSTINTOS.md del
curso "Cristalería" (analítico columnar embebido con DuckDB, contra
pandas/Polars/SQLite).

QUÉ ES: INSTINTOS.md registra cada instinto relacional/transaccional que
el curso pone a prueba, en formato falsable: la predicción del lector
senior ("hay que cargar la tabla antes de consultar", "columnar siempre
gana", "si no entra en RAM, hace falta un clúster", "normalizar siempre
es mejor"), el experimento que la confronta (referencia al duelo del
arnés `vs` o a la medición concreta), el número que salió, y el veredicto
escrito. Crece una o dos entradas por fase. Su gemelo 🩻 —"esto sí viaja
igual"— también se anota (índices, `EXPLAIN`, selectividad, semántica de
`WHERE`/`SELECT`), porque bajar la ansiedad del lector es parte del
método.

FORMATO POR ENTRADA:
- Instinto (la predicción tal como la tendría un senior de SQL).
- Fase donde se pone a prueba.
- Experimento (qué se corrió, con qué dataset y tamaño).
- Resultado medido (número real, con referencia a la fila de
  BENCHMARKS.md si aplica).
- Veredicto (se cumple / se equivoca / depende de X — nunca ambiguo).

REGLAS DE ESTILO: español sin voseo, tono cálido e informal, sin relato
sin número detrás. Identificadores de código en inglés si aparecen.

TAREA:
{{Si es la primera vez: crea el archivo con su estructura y las primeras
2-3 entradas de la Fase 0/1.}}
{{Si ya existe: adjunta el INSTINTOS.md actual y agrega las entradas
nuevas que correspondan a la Fase {{N}} que se acaba de escribir, sin
tocar las anteriores.}}
```

### 3.2 `BENCHMARKS.md`

```
Vas a inicializar (o actualizar) el artefacto acumulativo BENCHMARKS.md
del curso "Cristalería".

QUÉ ES: BENCHMARKS.md acumula TODO "vs" corrido con el arnés `scripts/
vs.ts` / `vs.py` a lo largo del curso. Ninguna afirmación de rendimiento
entra a una fase sin su fila aquí. Los duelos centrales del curso son:
DuckDB vs pandas, DuckDB vs Polars, DuckDB vs SQLite, SQL-sobre-archivos
vs código-de-dataframe (meta-duelo: tiempo Y líneas de código), y —fase
final— embebido vs warehouse/clúster pesado (el duelo del villano).

FORMATO POR FILA (tabla):
| Fecha | Fase | Duelo (id en inglés) | Motor A (versión) | Motor B
(versión) | Dataset / tamaño | Caché frío (s) | Caché caliente (s) |
Bytes leídos | Notas |

REGLAS: cada fila debe ser reproducible (mismo dataset, misma máquina
declarada). Nunca se pega un benchmark de marketing de terceros: solo
cuenta lo que reproduce este arnés. El id del duelo va en inglés
snake_case (p.ej. `duckdb_vs_polars_groupby`, `wasm_vs_backend_latency`);
la nota puede ir en español.

TAREA:
{{Si es la primera vez: crea el archivo con la tabla vacía y su
cabecera, más el primer duelo trivial de la Fase 0.}}
{{Si ya existe: adjunta el BENCHMARKS.md actual y agrega las filas
correspondientes al duelo de la Fase {{N}} que se acaba de escribir.}}
```

### 3.3 Diccionario de traducción (SQL-transaccional ↔ SQL-analítico-DuckDB)

```
Vas a construir (o ampliar) el diccionario de traducción del curso
"Cristalería": una tabla que traduce el instinto/reflejo de SQL
relacional-transaccional a su forma equivalente (o su ausencia
justificada) en el modelo analítico-columnar-embebido con DuckDB.

CONTEXTO: el lector viene de años de SQL transaccional. El diccionario es
el ancla que le permite mapear lo que ya sabe a lo nuevo, y nombrar
explícitamente dónde el mapeo no existe (porque no hace falta: no hay
transacciones multi-fila en un archivo inmutable, por ejemplo).

FORMATO (tabla, no prosa — es una tabla de mapeo según la guía de
estilo):
| Instinto relacional (SQL transaccional) | Su forma en Cristalería
(DuckDB / columnar) |

Incluye como mínimo estas filas base (ya fijadas en la guía de estilo;
no las cambies, solo puedes ampliar con nuevas si la fase lo justifica):
- CREATE TABLE + COPY/INSERT antes de consultar → SELECT ... FROM
  read_parquet(...) directo.
- Índice B-tree → proyección de columnas + orden físico del Parquet.
- Normalizar en varias tablas → denormalizar en tabla ancha cuando se lee
  siempre junta (con referencia al villano).
- Transacción ACID multi-fila → no aplica (archivo inmutable, se
  reemplaza entero).
- EXPLAIN / EXPLAIN ANALYZE → existen igual (🩻 esto sí viaja igual).
- Escalar verticalmente el servidor → escalar el proceso local o pasar a
  spilling/streaming antes de pensar en clúster.
- Vista materializada → Parquet derivado materializado a disco.

REGLAS: español sin voseo en la columna descriptiva; los términos de
código/SQL se dejan tal cual (en inglés cuando son el nombre real del
comando o cláusula). No es prosa: es tabla, por instrucción de la guía de
estilo del curso.

TAREA:
{{Agrega al diccionario las filas nuevas que surjan de la Fase {{N}} —
por ejemplo, del cruce en caliente (Fase 5), del formato de escritura
Parquet (Fase 6), o del modelo de ejecución en WASM (Fase 9)—, sin
duplicar ni contradecir las filas base ya fijadas.}}
```
