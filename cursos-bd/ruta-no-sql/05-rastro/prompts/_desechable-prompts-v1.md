# 🧰 Centinela de Flota — Prompts de arranque

Prompts reutilizables para generar el contenido del curso en una conversación
**nueva**, sin este proyecto de fábrica cargado. Cada prompt es autónomo:
incluye el contexto mínimo necesario para correr solo. Pega el prompt
completo (con los tres archivos semilla adjuntos donde se indica) y ajusta
los corchetes `[...]`.

Archivos que conviene adjuntar como contexto en el proyecto nuevo, siempre
que se disponga de ellos:
- `05-centinela-de-flota-semilla.md`
- `CENTINELA-DE-FLOTA-ALCANCE.md`
- `CENTINELA-DE-FLOTA-GUIA-ESTILO.md`

Si no están disponibles, cada prompt de abajo trae el contexto mínimo en
línea para que igual funcione.

---

## 1. Prompt de arranque de Fase 0

Úsalo para iniciar el curso desde cero en un proyecto nuevo: monta el
laboratorio de tres motores y el arnés `vs.ts`.

```
Eres coautor senior del curso "Centinela de Flota", que enseña el modelo de
acceso wide-column (Cassandra) a un ingeniero senior de bases relacionales,
a través de un proyecto de ingesta de telemetría de flota con roll-ups
progresivos.

CONTEXTO MÍNIMO DEL CURSO (si no tienes los archivos semilla adjuntos, usa
esto):
- Dominio: una flota de dispositivos (vehículos, sensores, medidores) emite
  una "lectura" (reading) cada pocos segundos con métricas (temperatura,
  voltaje, nivel de combustible, códigos de error). El sistema debe (a)
  aceptar ese torrente de escrituras sin volverse cuello de botella, y (b)
  responder consultas de tendencia sin recorrer los datos crudos, mediante
  roll-ups pre-computados por minuto/hora/día.
- Stack fijado: Apache Cassandra 5.0.x (motor principal), ScyllaDB 2026.1 LTS
  (rival wide-column directo, mismo protocolo CQL), Bigtable (referencia
  conceptual, no se opera), PostgreSQL 17.x (control relacional y destino de
  la migración del villano), Node.js 24 LTS + TypeScript 5.x (arnés y API),
  `cassandra-driver` y `pg` como drivers, Docker/Podman Compose para todo el
  laboratorio, Zod para validación en la frontera de la API.
- Villano del curso: usar Cassandra como base primaria de un CRUD de bajo
  volumen que no necesita escritura distribuida masiva.
- El método del curso es medir, nunca narrar: TODO "vs" entre motores pasa
  por un arnés propio `scripts/vs.ts` que cronometra la misma consulta
  semántica contra cada motor, corre suficientes repeticiones, y acumula el
  resultado en `BENCHMARKS.md`.
- Idioma: código, nombres de tabla/columna/keyspace y endpoints en INGLÉS;
  narrativa, comentarios y textos de operador en ESPAÑOL. Sin voseo (usa
  "tú", nunca "vos").
- Plantilla obligatoria de cada fase (9 secciones, en este orden): 🎯
  Propósito, ✅ Qué queda listo, 🚫 Qué queda fuera, 🧠 Conceptos mínimos,
  💻 Implementación y código comentado, ⚠️ Errores comunes y pieza forense,
  🧪 Ejercicios progresivos (20-40, graduados 🟢🟡🟠🔴), 📚 Referencias
  (propias de esta fase, con URLs completas y advertencia de verificación),
  🚀 Cierre y conexión con la siguiente fase.
- Recuadros propios del curso: 📖 tabla de traducción relacional↔CQL, 🪞
  "tu instinto relacional dice… y aquí se equivoca", 🩻 "esto sí viaja
  igual", ⚰️ caso de estudio del villano.

TAREA — Fase 0: "El laboratorio de tres motores"

Genera el archivo `fase-0-laboratorio.md` completo, siguiendo la plantilla de
9 secciones, que:
1. Levante con Docker/Podman Compose un clúster Cassandra de VARIOS nodos
   (no uno solo: el punto del modelo es la distribución), un nodo ScyllaDB, y
   un Postgres, todos en la misma red local reproducible.
2. Escriba el generador de telemetría sintética (dispositivos con región y
   tipo, métricas con deriva temporal creíble, ráfagas y huecos) que
   materialice el MISMO dataset semántico en los tres motores.
3. Haga nacer `scripts/vs.ts` con un primer duelo trivial (un `INSERT`/write
   y un `SELECT`/read por clave en los tres motores) que sirva para validar
   que el arnés cronometra correctamente. No se modela nada serio todavía.
4. Incluya, como apéndices A/B/E de esta fase (o referenciados desde aquí):
   comandos de arranque, el Compose comentado, y troubleshooting de setup
   (clúster que no forma anillo, OOM por heap, diferencia de puertos
   Cassandra/Scylla).
5. No asuma que el estudiante conoce CQL: esta fase es 100% infraestructura y
   arnés, cero modelado de datos serio (eso empieza en la Fase 1).

Antes de fijar versiones exactas de paquetes npm o imágenes Docker,
recuérdame verificarlas contra las últimas estables disponibles — no las des
por buenas solo porque están en este prompt.
```

---

## 2. Prompt-plantilla por fase (reutilizable, fases 1 a 11)

Prompt genérico: copia el bloque, rellena los campos entre `< >` con los
datos de la fase deseada (sacados de la tabla de fases de la semilla) y
pégalo entero en la conversación nueva.

```
Eres coautor senior del curso "Centinela de Flota" (wide-column, Cassandra
vs ScyllaDB vs PostgreSQL, sobre telemetría de flota con roll-ups
progresivos). Ya existen las fases anteriores; esta tarea es SOLO la
siguiente fase.

CONTEXTO MÍNIMO (repetir si no hay archivos semilla adjuntos): mismo bloque
de "CONTEXTO MÍNIMO DEL CURSO" del prompt de Fase 0 (dominio, stack,
villano, método del vs, idioma sin voseo, plantilla de 9 secciones,
recuadros 📖🪞🩻⚰️).

DATOS DE ESTA FASE:
- Número y nombre: <# — Título con emoji, tal como aparece en la tabla de
  fases de la semilla>
- Núcleo (qué se construye/aprende): <resumen de 2-4 líneas>
- "Vs" de la fase (qué mide `vs.ts` aquí): <duelo específico de esta fase>
- Qué debe estar YA resuelto de fases anteriores (para no repetirlo ni
  contradecirlo): <lista breve: tablas ya creadas, esquema ya fijado, nivel
  de consistencia ya usado, etc.>
- Instinto relacional a interpelar en el 🪞 de esta fase (si aplica):
  <descríbelo>
- Qué "esto sí viaja igual" (🩻) corresponde aquí (si aplica): <descríbelo>

TAREA

Genera el archivo `fase-<N>-<slug>.md` completo con las 9 secciones
obligatorias, en español (código en inglés), con:
- Código TypeScript/Node y CQL ejecutable contra el clúster de la Fase 0,
  usando SOLO las tablas y el esquema ya fijados en fases anteriores (no
  inventes nombres de tabla o columna nuevos sin justificarlos aquí mismo).
- Entre 20 y 40 ejercicios graduados 🟢🟡🟠🔴 anclados al dominio de la
  flota (dispositivos, lecturas, roll-ups, regiones, umbrales), con al menos
  un puñado de ejercicios de diagnóstico (se entrega un bug, se pide
  reproducir y localizar).
- Toda afirmación comparativa respaldada por una entrada nueva o actualizada
  en `BENCHMARKS.md` (describe qué mediría `vs.ts` aquí, no inventes números
  reales de latencia — eso se corre, no se redacta).
- Una entrada nueva en `INSTINTOS.md` si esta fase pone a prueba un instinto
  relacional (predicción del estudiante, qué mide el experimento, veredicto
  con el número real pendiente de correr).
- Sección de 📚 Referencias propia de esta fase, con URLs completas marcadas
  como "verificar antes de publicar" — no inventes DOIs, IDs de video ni
  números de página.
- Verifica que no contradiga el esquema de tablas ni las decisiones de fases
  anteriores; si detectas una tensión, señálala explícitamente en vez de
  resolverla en silencio.
```

---

## 3. Prompts para artefactos transversales

### 3.1 `INSTINTOS.md` (arranque)

```
Crea el archivo `INSTINTOS.md` del curso "Centinela de Flota" (wide-column:
Cassandra/ScyllaDB vs PostgreSQL, telemetría de flota con roll-ups
progresivos). Es un registro ACUMULATIVO de instintos relacionales puestos a
prueba fase a fase, en formato falsable, con tres campos por entrada:

1. **Instinto/predicción** — lo que un ingeniero relacional senior asumiría
   antes de medir (ej.: "normalizar y hacer JOIN será más rápido que
   duplicar en tres tablas").
2. **Experimento** — qué corrió `scripts/vs.ts` para ponerlo a prueba
   (dataset, motores comparados, qué se cronometró).
3. **Veredicto escrito** — qué ganó, con el número (cuando ya se corrió) o
   marcado como "[pendiente de medir]" si el instinto ya está identificado
   pero el número aún no.

Estructura el archivo con un encabezado, una tabla o lista por fase (en el
orden en que las fases aparecen en la semilla), y dos entradas de ejemplo ya
completas para que sirvan de plantilla:
- Fase 1: "normalizar gana a bajo volumen" (verdadero — Postgres gana en el
  régimen de bajo caudal).
- Fase 6: "un solo nodo relacional aguanta cualquier caudal razonable"
  (falso pasado el punto de cruce medido).

Español para toda la narrativa; código/identificadores citados en inglés
donde aplique. Sin voseo.
```

### 3.2 `BENCHMARKS.md` (arranque)

```
Crea el archivo `BENCHMARKS.md` del curso "Centinela de Flota". Es el
registro ACUMULATIVO de todo "vs" medido con `scripts/vs.ts` — el contrapeso
empírico de `INSTINTOS.md`. Ninguna afirmación comparativa del curso ("X es
más rápido que Y") existe sin una entrada aquí.

Cada entrada de benchmark documenta:
- **Duelo:** qué motores se comparan (Cassandra vs PostgreSQL / Cassandra vs
  ScyllaDB / diseño correcto vs diseño ingenuo dentro de Cassandra).
- **Consulta semántica medida:** en lenguaje de dominio ("escribir N lecturas
  de un dispositivo", "leer el roll-up horario de una región").
- **Dataset y hardware:** tamaño del dataset, especificación de la máquina
  donde se corrió (o "[pendiente]" si aún no se corrió).
- **Repeticiones:** cuántas corridas, para que la varianza no engañe.
- **Resultado:** mediana y dispersión (o "[pendiente de correr]").
- **Veredicto de una línea:** qué gana y en qué régimen — nunca "X es
  mejor" sin calificar el régimen (volumen, tamaño de partición, nivel de
  consistencia).

Organiza el archivo en tres bloques fijos, uno por cada duelo transversal
del curso (Cassandra vs PostgreSQL; Cassandra vs ScyllaDB; diseño correcto
vs diseño ingenuo), cada uno con sus entradas en orden cronológico de fase.
Deja los tres bloques creados con su encabezado aunque todavía no tengan
entradas.

Español para toda la narrativa. Sin voseo. No inventes números: si el
benchmark aún no se corrió, dilo explícitamente.
```

### 3.3 Diccionario de traducción (arranque)

```
Crea el archivo `DICCIONARIO-CQL.md` del curso "Centinela de Flota". Es el
diccionario de traducción acumulativo relacional → wide-column/CQL que
alimenta los recuadros 📖 de cada fase.

Arranca con esta tabla base (amplíala fase a fase, nunca la reduzcas ni
contradigas entradas ya fijadas):

| Relacional (instinto de origen) | Wide-column / CQL |
|---|---|
| tabla | column family / tabla CQL |
| primary key (identifica la fila) | partition key (decide el nodo) + clustering columns (ordenan dentro de la partición) |
| JOIN | tabla desnormalizada diseñada por consulta |
| WHERE sobre cualquier columna | WHERE solo sobre partition key/clustering, salvo índice secundario o SAI |
| ORDER BY en tiempo de consulta | orden físico ya materializado por el clustering |
| índice secundario de uso libre | secondary index / SAI — recurso acotado; ALLOW FILTERING como olor |
| transacción multi-fila ACID | BATCH logueado (agrupa, no aísla entre particiones) |
| DELETE físico inmediato | tombstone + compactación |
| job de borrado por antigüedad | TTL nativo por fila |
| vista materializada / agregación en SELECT | tabla de roll-up pre-computada en el camino de ingesta |
| nivel de aislamiento | nivel de consistencia por consulta (ONE, QUORUM, ALL) |

Deja una nota al pie explicando que cada fase que introduzca un término
nuevo del dominio wide-column (partición caliente, time-bucketing, tombstone,
SAI, etc.) debe agregar su fila aquí en el mismo momento en que lo introduce
en la narrativa, no después. Español para toda la narrativa; los términos
técnicos se dejan en inglés cuando son el nombre real del concepto (ver §3
de la guía de estilo). Sin voseo.
```

---

## 4. Prompt para apéndices (A–E)

Los apéndices no siguen la plantilla de 9 secciones; usa este prompt más
ligero.

```
Eres coautor senior del curso "Centinela de Flota" (wide-column). Genera el
apéndice <letra> — "<título del apéndice>", con este formato (no la
plantilla de 9 secciones de una fase):
- Índice de salto rápido al inicio.
- Secciones cortas, orientadas a consulta rápida durante el trabajo, no a
  lectura lineal.
- Al menos una tabla "cuándo usar qué" si el apéndice compara opciones
  (ej.: CQL vs SQL, cuándo delegar en cassandra-stress vs el generador
  propio).
- 5 a 10 ejercicios cortos de consulta al cierre, sin necesidad de graduarlos
  en 🟢🟡🟠🔴.
- Español para la narrativa, código en inglés, sin voseo.

Contenido específico de este apéndice: <describe brevemente qué cubre, por
ejemplo: "Apéndice C — Guía rápida de CQL para quien viene de SQL: qué se
parece a SQL y te traiciona por parecerse (SELECT, WHERE, INSERT), y qué no
existe (JOIN, subqueries, GROUP BY arbitrario, transacciones multi-fila).
Tabla CQL ↔ SQL.">
```

---

## 5. Nota de uso

- Corre el prompt de Fase 0 primero siempre; las fases 1-11 dependen del
  esquema y el arnés que nacen ahí.
- Al pasar de una fase a la siguiente, adjunta el `.md` de la fase anterior
  (o al menos su sección "✅ Qué queda listo al terminar") como contexto,
  para que el prompt-plantilla de §2 no reinvente el esquema.
- `INSTINTOS.md`, `BENCHMARKS.md` y el diccionario se crean una sola vez al
  arrancar (junto con la Fase 0) y luego se **actualizan**, no se recrean,
  en cada prompt de fase subsiguiente — pide explícitamente "agrega una
  entrada a `INSTINTOS.md`/`BENCHMARKS.md`" en vez de "crea `INSTINTOS.md`"
  a partir de la Fase 1.
