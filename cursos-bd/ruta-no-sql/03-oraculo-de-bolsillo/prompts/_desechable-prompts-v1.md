# 🧰 Oráculo de Bolsillo — Prompts reutilizables

> Cada prompt de este archivo es **autónomo**: incluye el contexto mínimo
> necesario para correr en un proyecto nuevo, sin depender de este proyecto
> de fábrica. Copiá el prompt completo (incluido el bloque de contexto) al
> arrancar la conversación correspondiente.

---

## 1. Prompt de arranque — Fase 0

```
Eres mi coautor para escribir el curso "Oráculo de Bolsillo", el curso #3
de una ruta de formación en NoSQL. Enseña el MODELO DE ACCESO VECTORIAL
(no un producto puntual) a través de un proyecto concreto.

CONTEXTO DEL CURSO (no negociable, no lo reinterpretes)
- Dominio: un sistema de preguntas y respuestas sobre un corpus de
  documentos propios del usuario, con CITAS VERIFICABLES por afirmación
  (documento, página o sección exacta que sustenta cada frase de la
  respuesta). El requisito de la cita es lo que separa un RAG serio de un
  generador que alucina con apariencia de fundamento.
- La unidad de trabajo es el "chunk": fragmento de documento con texto,
  embedding y procedencia. Anatomía fija:
  id (uuid), documentId (uuid, FK relacional), content (text),
  embedding (vector(N)), page/section (int/text), tokenCount (int),
  chunkIndex (int), createdAt (timestamptz).
- Doctrina central del curso: EMPEZAR SIN MOTOR DEDICADO. El curso arranca
  en pgvector (extensión vectorial de Postgres) y SOLO migra a un motor
  especializado cuando el propio benchmark del curso (arnés `vs.ts`)
  demuestra que el volumen o la latencia lo justifican. Ningún motor
  dedicado se adopta por adelantado ni se narra como "mejor" sin una
  corrida de `vs.ts` que lo respalde.
- El villano del curso: montar un motor vectorial dedicado (Qdrant,
  Weaviate, Pinecone) para un corpus que pgvector resuelve de sobra. Su
  gemelo simétrico: quedarse en pgvector cuando el volumen o el filtrado ya
  lo piden a gritos. El villano transversal de toda la ruta es "usar el
  motor donde no toca", en cualquiera de las dos direcciones.
- Stack fijado (2026): PostgreSQL 18.6 + pgvector 0.8.x (punto de
  partida) · Qdrant 1.19.x y Weaviate 1.37.x (dedicados, entran en Fases 7
  y 8) · Pinecone (managed, referencia, entra en Fase 9) · Node.js 24 LTS +
  TypeScript 5.x + Express 5.x (servicio y arnés) · Python 3.13.x
  (pipeline de embeddings e ingesta, por el ecosistema de
  sentence-transformers) · Docker/Podman (todo contenerizado).
- Estructura de 12 fases (0-11): 0 Laboratorio y generador · 1 Embeddings y
  el espacio · 2 pgvector, la vía barata · 3 HNSW vs IVFFlat (⭐ central) ·
  4 RAG con citas verificables · 5 Filtrado y la costura híbrida · 6 El
  techo de pgvector (⭐ central, mide el punto de quiebre) · 7 Entra Qdrant
  · 8 Entra Weaviate e híbrido · 9 Pinecone y el costo de no operar · 10
  Producción del RAG · 11 Autopsia del villano y veredicto.
- Método del "vs": `scripts/vs.ts` es el juez del curso. Corre las mismas
  consultas contra cada motor con el mismo recall objetivo, mide latencia
  p50/p95/p99, recall real contra ground truth de fuerza bruta, costo de
  construcción del índice y memoria, y acumula todo con fecha, versión y
  parámetros en `BENCHMARKS.md`. Regla dura: ningún "X gana a Y" se escribe
  sin una corrida de `vs.ts` que lo respalde.
- Artefactos acumulativos transversales: `INSTINTOS.md` (instintos
  relacionales puestos a prueba: instinto → predicción → medición →
  veredicto) y `BENCHMARKS.md` (todo "vs" del curso, nunca escrito a mano).
- Reglas de estilo: código en inglés, narrativa/comentarios/UI en español;
  tono cálido e informal de colega senior a colega senior, SIN VOSEO
  (siempre "tú", nunca "vos"); prosa antes que listas; tablas solo para
  comparar/decidir/mapear; plantilla de fase de 9 secciones; 20-40
  ejercicios por fase graduados 🟢🟡🟠🔴 con diversidad de tipo, no solo de
  dificultad; referencias siempre al final de cada fase/capítulo.

TU TAREA AHORA — Fase 0: Laboratorio contenerizado y generador de datos
Escribe el .md completo de la Fase 0 siguiendo la plantilla de 9 secciones
(Propósito / Qué queda listo / Qué queda fuera / Conceptos mínimos /
Implementación y código comentado / Errores comunes / Ejercicios /
Referencias / Cierre). Contenido esperado de esta fase:
- Levantar el entorno completo con un comando: Postgres 18 + pgvector, y
  Qdrant + Weaviate ya declarados en el docker-compose (aunque no se usen
  hasta más tarde).
- Escribir el generador de corpus sintético parametrizable (número de
  documentos, tamaño de chunk, dimensión del embedding, distribución
  temática, semilla para reproducibilidad).
- Hacer nacer el esqueleto de `scripts/vs.ts` (sin medir nada todavía: se
  monta el juez y la mesa).
- Abrir el diccionario de traducción SQL→vectorial con sus primeras
  entradas (📖).
- No mides recall ni latencia todavía — eso empieza en la Fase 3.

Antes de escribir, confírmame o proponme por defecto (y márcalo como
decisión pendiente si no confirmo): dataset semilla (sintético vs. real
pequeño), modelo de embeddings (local vs. API) y dimensión del vector.
```

---

## 2. Prompt-plantilla por fase (parametrizable)

Usar este prompt para **cualquier fase 1 a 11**, reemplazando los
`{placeholders}`. Los datos de cada fase están en la tabla de abajo.

```
Eres mi coautor del curso "Oráculo de Bolsillo" (modelo de acceso
VECTORIAL, curso #3 de una ruta de formación NoSQL). Ya escribimos fases
anteriores; esta debe encajar sin contradecirlas.

CONTEXTO MÍNIMO (si no tienes las fases anteriores a mano, usa esto)
- Dominio: sistema de Q&A sobre documentos propios con citas verificables
  por afirmación. Unidad de trabajo: el "chunk" (id, documentId, content,
  embedding, page/section, tokenCount, chunkIndex, createdAt).
- Doctrina: empezar SIN motor dedicado; solo migrar cuando `vs.ts` lo
  demuestre. Villano: motor dedicado prematuro (y su gemelo, quedarse en
  pgvector cuando ya no alcanza).
- Stack: PostgreSQL 18.6 + pgvector 0.8.x · Qdrant 1.19.x · Weaviate
  1.37.x · Pinecone (managed) · Node 24 LTS + TypeScript 5.x + Express 5.x
  · Python 3.13.x (ingesta) · Docker/Podman.
- Arnés: `scripts/vs.ts` mide latencia p50/p95/p99, recall real y costo de
  construcción; todo resultado va a `BENCHMARKS.md` con fecha, versión y
  parámetros. Ningún "X gana a Y" sin esa corrida.
- Estilo: código en inglés, narrativa en español, SIN VOSEO (usa "tú"),
  tono cálido e informal, prosa antes que listas, plantilla de 9 secciones,
  20-40 ejercicios 🟢🟡🟠🔴 con diversidad de tipo, referencias al final del
  capítulo.
- Recuadros propios del curso: 📖 diccionario de traducción SQL↔vectorial,
  🪞 "tu instinto SQL dice… y esta vez se equivoca", 🩻 "esto sí viaja
  igual", ⚰️ caso de estudio del villano.

TU TAREA AHORA — Fase {numero}: {nombre_de_fase}
Núcleo de la fase: {nucleo}
"Vs" de esta fase (debe quedar medido en `BENCHMARKS.md`, no narrado):
{vs_de_la_fase}
¿Es fase ⭐ central? {si_no}

Escribe el .md completo de esta fase con la plantilla de 9 secciones:
1. 🎯 Propósito — puede abrir retomando dónde quedó la fase anterior.
2. ✅ Qué queda listo al terminar.
3. 🚫 Qué queda fuera por ahora (y a qué fase se difiere).
4. 🧠 Conceptos mínimos — incluye 📖/🪞/🩻 si esta fase los pide.
5. 💻 Implementación y código comentado — identificadores en inglés,
   comentarios en español, ejecutable contra el stack fijado.
6. ⚠️ Errores comunes y pieza forense.
7. 🧪 Ejercicios progresivos (20-40, graduados y variados en tipo).
8. 📚 Referencias (oficial / papers si aplica / video si aplica / orden de
   lectura) — con advertencia de que URLs y títulos deben verificarse.
9. 🚀 Cierre y conexión con la fase siguiente — incluye "la señal de que
   quedó bien".

No contradigas ninguna fase anterior. Si necesitas asumir algo que no está
en este contexto (p. ej. una decisión pendiente de la semilla), asúmelo
razonablemente y márcalo en línea como supuesto a confirmar.
```

### Datos por fase para el prompt-plantilla

| # | `{nombre_de_fase}` | `{nucleo}` | `{vs_de_la_fase}` | `{si_no}` |
|---|---|---|---|---|
| 1 | Embeddings y el espacio de alta dimensión | Qué es un embedding, distancias, dimensión, pipeline de ingesta en Python | Coseno vs L2 vs producto interno | No |
| 2 | pgvector, la vía barata primero | Chunk en Postgres, búsqueda exacta (fuerza bruta), primer RAG de punta a punta | Exacto (seq scan) vs índice | No |
| 3 | HNSW vs IVFFlat dentro de pgvector | Índices ANN de la extensión, recall vs latencia vs costo de construcción | HNSW vs IVFFlat en pgvector | **Sí** |
| 4 | RAG con citas verificables | Recuperar → (re-rank opcional) → construir contexto → generar → atribuir | Recuperación con/sin re-ranking | No |
| 5 | Filtrado y la costura híbrida | Filtro por metadatos + vecindad; dónde va la costura relacional/vectorial | Filtro-luego-ANN vs ANN-luego-filtro | No |
| 6 | El techo de pgvector | Escalar el corpus 10k→100k→1M chunks, medir el punto de quiebre del SLA | pgvector a 10k / 100k / 1M chunks | **Sí** |
| 7 | Entra Qdrant | Primer motor dedicado; portar corpus y arnés | pgvector vs Qdrant, mismo corpus | No |
| 8 | Entra Weaviate y lo híbrido | Segundo dedicado; búsqueda híbrida nativa (BM25 + vectorial) | Qdrant vs Weaviate; híbrido vs puro | No |
| 9 | Pinecone y el costo de no operar | Managed serverless; latencia y costo por consulta | Auto-hospedado vs Pinecone | No |
| 10 | Producción del RAG | Re-embedding, versionado, invalidación, evaluación (recall@k, MRR, nDCG) | Estrategias de re-indexado (rebuild total vs incremental) | No |
| 11 | Autopsia del villano y veredicto honesto | El villano bajo el bisturí con todos los números acumulados; árbol de decisión | Recopilación de todos los duelos previos | No |

> Para la **Fase 11**, agregar al prompt una línea extra: *"Esta fase
> cierra `INSTINTOS.md` con el veredicto de cada instinto falsado y
> construye el árbol de decisión completo de cuándo NO usar un motor
> dedicado (y, simétricamente, cuándo NO quedarse en pgvector). No abre
> instintos nuevos: relee y cierra los de fases anteriores."*

---

## 3. Prompt — artefacto `INSTINTOS.md`

```
Eres mi coautor del curso "Oráculo de Bolsillo" (modelo vectorial, ruta
NoSQL). Necesito que arranques o actualices el artefacto acumulativo
`INSTINTOS.md`.

QUÉ ES: un registro vivo de los instintos RELACIONALES que el curso pone a
prueba, uno por fase (no todas las fases abren uno nuevo). Cada entrada
tiene exactamente esta forma:

- **Instinto** — redactado tal como lo diría el lector que viene de SQL
  (primera persona, coloquial). Ej.: "un índice sobre el vector me da
  rangos baratos, como un B-tree."
- **Predicción** — qué implica ese instinto si fuera cierto, en términos
  verificables.
- **Medición** — qué corrida de `vs.ts` (o qué experimento puntual) lo
  confronta, con el resultado real.
- **Veredicto** — una palabra: CONFIRMADO / RECALIBRADO / FALSADO, más una
  frase de una línea.

Instintos que el curso abre, en orden (no inventes otros salvo que la fase
concreta que estás redactando lo pida explícitamente):
- Fase 1: "un índice sobre el vector me da rangos baratos como un B-tree."
- Fase 3: "el índice aproximado me da siempre el mismo resultado que el
  exacto."
- Fase 5: "filtro primero con un WHERE y busco vecindad después, como un
  índice compuesto."
- (Agregar cualquier instinto adicional que la fase actual introduzca,
  siguiendo la misma forma de cuatro campos.)

TU TAREA AHORA: {si estás abriendo el artefacto en la Fase 0 → crea el
archivo con el título, la explicación de qué es y de su regla de cuatro
campos, y una tabla vacía de "instintos pendientes de medir" con los tres
de arriba en estado PENDIENTE. Si estás en una fase que mide uno de ellos →
agrega/actualiza esa entrada con predicción, medición real (basada en la
tabla de BENCHMARKS.md de esa fase) y veredicto. Si estás en la Fase 11 →
relee el archivo completo y cierra cada entrada pendiente con su veredicto
final, sin abrir instintos nuevos.}
No inventes números: la medición de cada entrada remite a una fila
concreta de `BENCHMARKS.md`; si esa fila no existe todavía, deja el
veredicto como PENDIENTE en vez de inventarlo.
```

---

## 4. Prompt — artefacto `BENCHMARKS.md`

```
Eres mi coautor del curso "Oráculo de Bolsillo" (modelo vectorial, ruta
NoSQL). Necesito que arranques o actualices el artefacto acumulativo
`BENCHMARKS.md`.

QUÉ ES: el libro de resultados del curso. Todo "vs" vive acá, generado por
`scripts/vs.ts`, nunca escrito a mano. Regla inviolable: si un número no
salió de una corrida reproducible de `vs.ts`, no entra.

Cada tabla de duelo lleva, como mínimo, estas columnas:
fecha | motor(es) comparado(s) | versión exacta de cada motor | hardware /
perfil de contenedor | corpus (tamaño, dimensión del embedding) |
parámetros de índice (ef_construction, M, nlist/nprobe, etc. según motor) |
recall objetivo | latencia p50 | latencia p95 | latencia p99 | recall real
medido | costo de construcción del índice | uso de memoria | notas de
costo operativo.

Duelos que el curso acumula, en este orden:
1. pgvector HNSW vs pgvector IVFFlat (Fase 3).
2. La curva de escalado de pgvector, 10k/100k/1M chunks (Fase 6).
3. pgvector vs Qdrant, mismo corpus (Fase 7).
4. Qdrant vs Weaviate; híbrido vs puro (Fase 8).
5. Auto-hospedado vs Pinecone managed (Fase 9).
6. Estrategias de re-indexado, rebuild total vs incremental (Fase 10).

TU TAREA AHORA: {si estás en la Fase 0 → crea el archivo con el título, la
explicación de la regla inviolable, y el esqueleto de las seis tablas
vacías con sus columnas, marcadas "pendiente de corrida". Si estás en una
fase que corre un duelo → pídeme (o genera vos mismo si tienes acceso al
entorno) la salida real de `vs.ts` para esa fase, y agrega la fila completa
con todos los campos. Nunca completes una fila con un número estimado o de
memoria — si no hay corrida real disponible, deja la fila como pendiente y
dilo explícitamente.}
```

---

## 5. Prompt — diccionario de traducción SQL → Vectorial

```
Eres mi coautor del curso "Oráculo de Bolsillo" (modelo vectorial, ruta
NoSQL). Necesito que arranques o amplíes el diccionario de traducción
SQL → Vectorial (el recuadro 📖 recurrente del curso).

QUÉ ES: una tabla acumulativa, lado a lado, de la operación relacional y su
equivalente en el modelo vectorial. Formato de fila:
| Operación SQL | Equivalente vectorial | Nota |

Ejemplos ya fijados que debes respetar y no reformular:
| `SELECT * FROM t WHERE id = $1` | búsqueda por clave exacta — sigue
existiendo, no la reemplaza el vector | el vector no sustituye la búsqueda
por clave, la complementa |
| `SELECT * FROM chunks ORDER BY (embedding <=> $1) LIMIT k` | los k
vecinos más cercanos por distancia coseno | `<=>` es el operador de
distancia coseno de pgvector; `<->` es L2, `<#>` es producto interno |
| índice B-tree | índice HNSW o IVFFlat | ambos evitan el escaneo completo,
pero el vectorial es APROXIMADO — no hay garantía de exactitud |
| `WHERE` + índice compuesto | filtro + ANN, con la costura como decisión
de diseño (Fase 5) | filtrar antes puede vaciar el grafo HNSW de
candidatos: no se comporta como un índice compuesto relacional |
| `EXPLAIN` | `EXPLAIN (ANALYZE)` sobre la consulta con operador de
distancia | sigue leyéndose igual; confirma si se usó el índice ANN o cayó
a seq scan |

TU TAREA AHORA: agrega al diccionario las entradas nuevas que introduce la
fase {numero_o_nombre_de_fase} que estamos redactando (p. ej., en la Fase 7
suma la jerga de Qdrant: collection ↔ tabla, point ↔ fila, payload ↔
columnas no vectoriales; en la Fase 8, la jerga de Weaviate). No dupliques
entradas ya fijadas arriba; si una fase las amplía con matices, agrega una
fila nueva en vez de reescribir la existente.
```

---

## 6. Prompt — apéndices (A a E)

```
Eres mi coautor del curso "Oráculo de Bolsillo" (modelo vectorial, ruta
NoSQL). Necesito el apéndice {letra}: {titulo_del_apendice}.

Los apéndices NO siguen la plantilla de 9 secciones de las fases: usan
índice de salto rápido + secciones cortas + tabla "cuándo usar qué" (si
aplica) + 5-10 ejercicios cortos de consulta, sin graduación 🟢🟡🟠🔴
obligatoria.

Apéndices del curso:
- A) Arranque de motores vía contenedores — comandos para levantar
  Postgres 18 + pgvector, Qdrant 1.19 y Weaviate 1.37 con un solo `up`, y
  cómo dar de alta credenciales de Pinecone.
- B) docker-compose / Containerfile de trabajo — el fichero real del
  laboratorio, comentado, con volúmenes persistentes y puertos (ojo con el
  6334 de Qdrant).
- C) Guía rápida de MQL vectorial por motor — chuleta lado a lado: la
  misma búsqueda de vecindad en pgvector (SQL), Qdrant, Weaviate y
  Pinecone.
- D) Generador de corpus sintético — parámetros, distribuciones temáticas,
  cómo fijar semilla para reproducibilidad.
- E) Troubleshooting de setup — dimensiones que no coinciden, índice que
  no se usa (falta ANALYZE / parámetros de sesión), OOM al construir HNSW,
  el puerto gRPC de Qdrant, migraciones de versión que no saltan escalones.

Estilo: código en inglés, narrativa en español, SIN VOSEO, tono cálido e
informal. Referencias al final, con advertencia de verificar versiones.
```
