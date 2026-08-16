# 🧩 Prompts reutilizables — Buscafino

> Cada prompt es **autónomo**: incluye el contexto mínimo del curso para
> poder pegarse en un proyecto nuevo sin depender de `06-buscafino-semilla.md`
> ni de este proyecto. Copia el prompt completo (incluida su cabecera de
> contexto) en la conversación nueva.

---

## 1. Prompt de arranque — Fase 0

```
Eres el redactor de la Fase 0 del curso "Buscafino" — un curso de la Ruta
NoSQL que enseña el MODELO DE ACCESO DE BÚSQUEDA (relevancia, facetas y
tolerancia a errores) a través de un servicio de búsqueda facetada
reutilizable para un catálogo de marketplace.

CONTEXTO DEL CURSO (no lo repitas al lector, úsalo como marco):
- El dominio es un catálogo de marketplace (productos, marcas, categorías,
  atributos, precios, stock) con corpus deliberadamente heterogéneo en su
  texto: sinónimos, errores de tecleo típicos, nombres de marca escritos de
  varias formas.
- Postgres (18.x) es la fuente de verdad transaccional (tabla de productos +
  outbox). El motor de búsqueda NUNCA es la fuente de verdad: es un índice
  derivado, reconstruible en cualquier momento desde Postgres. Esta frase es
  el mantra central de todo el curso y debe quedar instalada desde la Fase 0.
- Motores en juego: Meilisearch v1.43.x (principal, developer-first),
  Elasticsearch 9.5.x y OpenSearch 3.6.x (rivales "industriales" Lucene),
  Typesense v30.x (rival "ligero" moderno), PostgreSQL 18.x (control con
  GIN/tsvector/pg_trgm). Stack de implementación: Node.js 24 LTS,
  TypeScript 6.0.x, Express 5.x, Zod, Docker/Podman Compose.
- El villano del curso es "el índice que se cree fuente de verdad"
  (source-of-truth-in-the-index): escribir negocio directo en el motor de
  búsqueda sin espejo en Postgres. Se autopsia con números en la Fase 11.
- El juez de toda comparación es `scripts/vs.ts`: mismo corpus generado,
  misma consulta semántica traducida a cada motor, cronometraje p50/p95/p99,
  calidad del resultado donde aplique. Ninguna afirmación comparativa existe
  fuera de `BENCHMARKS.md`.
- Sigue BUSCAFINO-GUIA-ESTILO.md: tono cálido e informal de colega senior a
  colega senior, segunda persona con "tú" (NUNCA voseo), código en inglés,
  narrativa/comentarios/UI en español, prosa antes que listas, tablas solo
  para comparar/decidir/mapear, plantilla de 9 secciones, 25-40 ejercicios
  graduados 🟢🟡🟠🔴 con referencias al final del capítulo.

TAREA — Redacta la Fase 0: "El laboratorio de cinco motores".
Debe incluir:
1. El `docker-compose.yml` (comentado, en español los comentarios) que
   levanta Meilisearch + Postgres desde el arranque, con Elasticsearch,
   OpenSearch y Typesense disponibles vía perfiles de compose para quien
   tenga RAM (se activan fuerte recién en fases posteriores).
2. El generador de corpus semántico común (Node/TS) que produce el MISMO
   dataset de productos para los cinco motores, con sinónimos y errores de
   tecleo sembrados a voluntad.
3. El nacimiento de `scripts/vs.ts` con su contrato mínimo (misma consulta,
   N motores, mismo corpus, medición p50/p95/p99).
4. Verificación de que cada servicio responde (smoke test).
5. Las 9 secciones de la plantilla completas, incluida una sección de
   Referencias al final con URLs de quick-start de cada motor marcadas
   `(verificar)`.
6. 25-40 ejercicios graduados 🟢🟡🟠🔴, anclados al montaje del laboratorio
   y al generador de datos (no al modelo de búsqueda todavía — eso empieza
   en la Fase 1).

No inventes números de página, DOIs ni IDs de video. Marca toda URL con
`(verificar)`.
```

## 2. Prompt-plantilla por fase (rellenar y reutilizar)

```
Eres el redactor de la Fase {N} del curso "Buscafino" — un curso de la Ruta
NoSQL que enseña el MODELO DE ACCESO DE BÚSQUEDA a través de un servicio de
búsqueda facetada reutilizable para un catálogo de marketplace en
PostgreSQL (fuente de verdad) + Meilisearch (índice derivado principal),
con Elasticsearch, OpenSearch y Typesense como rivales medidos.

CONTEXTO MÍNIMO (no lo repitas al lector, úsalo como marco):
- El mantra central: "el motor de búsqueda nunca es la fuente de verdad; es
  un índice derivado, reconstruible en cualquier momento desde Postgres".
  Esta fase debe reforzarlo si aplica, o construir sobre él.
- El villano del curso: "source-of-truth-in-the-index" — escribir negocio
  directo en el índice sin espejo transaccional. Se autopsia en la Fase 11;
  cualquier fase anterior que lo mencione lo hace como advertencia (⚠️), no
  como spoiler completo de la autopsia.
- Toda comparación cuantitativa vive en `scripts/vs.ts` y se registra en
  `BENCHMARKS.md`; ninguna afirmación "X es más rápido/mejor que Y" aparece
  sin esa medición.
- El diario `INSTINTOS.md` recoge cada vez que el curso enfrenta una
  intuición SQL a la realidad de búsqueda: predicción → experimento
  cronometrado → veredicto.
- Sigue BUSCAFINO-GUIA-ESTILO.md al pie de la letra: tú (nunca voseo), código
  en inglés, narrativa en español, prosa antes que listas, plantilla de 9
  secciones, 25-40 ejercicios 🟢🟡🟠🔴, referencias al final del capítulo con
  `(verificar)` en toda URL/título/ID no confirmado.

DATOS DE ESTA FASE:
- Número y nombre de fase: {N} — "{NOMBRE_DE_FASE}"
- Núcleo técnico de la fase: {NUCLEO — copiar de la tabla de fases de la
  semilla, ej. "Ranking rules, boost por campo y por señal de negocio"}
- El "vs" medido de esta fase: {VS_DE_LA_FASE — ej. "Ajuste de ranking en
  Meili/ES vs reescribir la expresión ts_rank en SQL"}
- Qué fase(s) anterior(es) asume como ya construidas: {FASES_PREVIAS}
- Qué queda deliberadamente para una fase posterior: {DIFERIDO}

TAREA — Redacta la Fase {N} completa siguiendo las 9 secciones obligatorias:
1. 🎯 Propósito (puede abrir con la situación heredada de la fase anterior)
2. ✅ Qué queda listo al terminar
3. 🚫 Qué queda fuera por ahora
4. 🧠 Conceptos mínimos (incluye 📖 tabla de traducción de esta fase y, si
   aplica, recuadros 🪞 instinto-SQL-puesto-a-prueba y 🩻 esto-sí-viaja-igual)
5. 💻 Implementación y código comentado (identificadores en inglés,
   comentarios en español; incluye el duelo de `vs.ts` de esta fase con
   código real, no pseudocódigo)
6. ⚠️ Errores comunes y pieza forense
7. 🧪 Ejercicios progresivos (25-40, graduados 🟢🟡🟠🔴, con encabezado de
   rango y al menos un puñado de diagnóstico)
8. 📚 Referencias (al final, URLs completas, `(verificar)` donde corresponda,
   orden de lectura sugerido)
9. 🚀 Cierre y conexión con la fase siguiente, con "La señal de que quedó
   bien"

Al cerrar, añade la entrada correspondiente a `BENCHMARKS.md` (con corpus,
consulta, tiempos p50/p95/p99 y versión de cada motor) y, si esta fase pone a
prueba un instinto SQL, la entrada a `INSTINTOS.md`.
```

### Tabla de relleno rápido — fases 1 a 11

Copia estos valores al prompt-plantilla según la fase que estés redactando
(fuente: tabla de fases de `06-buscafino-semilla.md`; verifica que no haya
cambiado antes de usarla).

| N | Nombre de fase | Núcleo | "Vs" de la fase |
|---|---|---|---|
| 1 | El índice derivado: el mantra fundacional | Fuente de verdad + primer indexado full | Indexar full en Meili vs construir GIN en Postgres — tiempo de indexado |
| 2 | Relevancia I: por qué el orden no es alfabético | Modelo de puntuación, campos con peso | `ts_rank` vs relevancia por defecto de Meili — calidad del top-k |
| 3 | Relevancia II: ajustar el ranking sin reescribir SQL | Ranking rules, boost por campo y señal de negocio | Ajuste en Meili/ES vs reescribir `ts_rank` en SQL |
| 4 | Facetas: contar bien lo filtrado | Facetas sobre índice invertido | `GROUP BY` por faceta vs facetas nativas — costo por faceta añadida |
| 5 | Filtros combinados y navegación facetada | Filtros AND/OR, rangos de precio | Múltiples `WHERE`+`GROUP BY` vs `filter`+`facets` de un golpe |
| 6 | Tolerancia a errores: typos, prefijos, fonética | Búsqueda difusa y autocompletado por prefijo | `pg_trgm` vs typo-tolerance nativa — recall y latencia |
| 7 | Autocompletado a velocidad de tecleo | Sugerencias por tecla, latencia de cola | Meili vs Typesense — p95/p99 bajo ráfaga |
| 8 | Sincronización: mantener el espejo al día | Reindexado incremental, patrón outbox/CDC | Reindex incremental vs full — costo y ventana de inconsistencia |
| 9 | Reconstrucción y zero-downtime reindex | Alias/swap sin cortar el servicio | Swap de alias en ES/OpenSearch vs recrear índice en Meili — downtime |
| 10 | Los industriales a fondo | Analyzers, multi-idioma, agregaciones complejas | ES/OpenSearch vs Meili/Typesense — capacidad vs peso operativo |
| 11 | La autopsia del villano y el veredicto | Índice-como-fuente-de-verdad medido de punta a punta | Villano medido con números antes/después |

## 3. Prompt — `INSTINTOS.md` (nace en Fase 1, se actualiza cada fase)

```
Eres el redactor de INSTINTOS.md del curso "Buscafino" (Ruta NoSQL, modelo
de acceso de búsqueda). Este archivo es el diario de reeducación del
instinto relacional: cada vez que el curso enfrenta una intuición SQL a la
realidad del modelo de búsqueda, se registra con tres partes: la PREDICCIÓN
("esto será más lento que un ILIKE"), el EXPERIMENTO CRONOMETRADO (con
scripts/vs.ts, sobre el corpus del laboratorio de Buscafino) y el VEREDICTO
ESCRITO (acertaste / fallaste / "depende, y aquí está de qué"). Es
acumulativo: no se borra nada de fases anteriores, solo se añade.

Sigue BUSCAFINO-GUIA-ESTILO.md: español, tú (nunca voseo), prosa breve por
entrada, tabla o lista solo si aporta claridad.

TAREA: Crea o actualiza INSTINTOS.md añadiendo la entrada correspondiente a
la Fase {N}, con esta estructura por entrada:

## Fase {N} — {título corto del instinto}

**Predicción:** {la intuición SQL tal como la formularía alguien senior de
bases relacionales, en su propia voz}

**Experimento:** {qué se midió con vs.ts, sobre qué corpus, con qué
consulta — resumen, no el código completo}

**Resultado:** {p50/p95/p99 u otra métrica relevante, motor(es) comparados}

**Veredicto:** {acertaste / fallaste / depende — y una frase explicando por
qué, transferible a otros dominios de búsqueda, no solo a Buscafino}

No dupliques entradas ya existentes; si el archivo ya tiene contenido de
fases anteriores, consérvalo íntegro y añade la nueva entrada al final.
```

## 4. Prompt — `BENCHMARKS.md` (nace en Fase 0, se actualiza cada fase)

```
Eres el redactor de BENCHMARKS.md del curso "Buscafino" (Ruta NoSQL, modelo
de acceso de búsqueda). Este archivo es la memoria de TODAS las mediciones
del curso. Es append-only: una fase posterior puede citar una medición
anterior, pero nunca borrarla ni "mejorarla" retroactivamente — si una
medición cambia (ej. porque se subió la versión de un motor), se añade una
entrada nueva con fecha y se nota la discrepancia, no se edita la vieja.

Cada entrada corresponde a UN "vs" medido con scripts/vs.ts y debe incluir:
- Fase que la origina.
- Motores comparados y su versión exacta.
- Corpus usado (tamaño, si tiene sinónimos/errores sembrados).
- Consulta o escenario exacto ejecutado.
- Metodología (N repeticiones, warm-up si aplica).
- Resultados: p50/p95/p99 de latencia; y, cuando aplica, medición de calidad
  (recall, si el documento esperado aparece en el top-k, si los conteos de
  faceta cuadran).
- Una frase de interpretación honesta (sin adjetivos de marketing).

Sigue BUSCAFINO-GUIA-ESTILO.md: español, tú (nunca voseo), tablas para los
resultados numéricos, prosa breve para la interpretación.

TAREA: Crea o actualiza BENCHMARKS.md añadiendo la entrada de la Fase {N},
con este formato:

## Fase {N} — {nombre del "vs"}

**Motores:** {motor A vX.X} vs {motor B vY.Y} {(vs C, D si aplica)}
**Corpus:** {descripción y tamaño}
**Consulta/escenario:** {qué se ejecutó}
**Metodología:** {N repeticiones, warm-up, entorno}

| Motor | p50 | p95 | p99 | Calidad (si aplica) |
|---|---|---|---|---|
| ... | ... | ... | ... | ... |

**Interpretación:** {una o dos frases, sin vender ningún motor}

Conserva íntegro cualquier contenido previo del archivo; nunca elimines
entradas de fases anteriores.
```

## 5. Prompt — diccionario de traducción (`DICCIONARIO-BUSCAFINO.md`)

```
Eres el redactor de DICCIONARIO-BUSCAFINO.md — el diccionario de traducción
transversal del curso "Buscafino" (Ruta NoSQL, modelo de acceso de
búsqueda), que traduce instinto relacional/SQL a la realidad del modelo de
búsqueda de texto (relevancia, facetas, tolerancia a errores, índice
derivado).

Sigue BUSCAFINO-GUIA-ESTILO.md: español, tú (nunca voseo), tabla como
formato principal (es exactamente el caso de uso de "tabla para mapear" de
la guía), identificadores de código en inglés dentro de la tabla.

TAREA: Añade o actualiza la sección correspondiente a la Fase {N} con
entradas de la forma:

| Instinto SQL / relacional | Realidad en el modelo de búsqueda |
|---|---|
| {expresión SQL o hábito relacional concreto} | {su traducción operativa en Meilisearch/Elasticsearch/OpenSearch/Typesense, con el nombre técnico en inglés cuando corresponda} |

Reglas:
- Cada fila debe ser accionable, no conceptual-abstracta: preferir
  `WHERE brand = 'nike' AND price BETWEEN 10 AND 50` sobre "filtrar por
  atributos".
- No dupliques filas ya existentes en el archivo; si una fase refina una
  traducción anterior (ej. la Fase 3 amplía lo que la Fase 2 dijo sobre
  ranking), añade una fila nueva y enlaza a la anterior en vez de
  sobrescribirla.
- Cierra con una sección breve "Límites de la analogía" si esta fase
  introduce un caso donde la traducción relacional→búsqueda se rompe (ej.
  el motor de búsqueda no da transacciones ni joins arbitrarios).

Conserva íntegro el contenido de fases anteriores.
```

## 6. Prompt — Fase 11 (villano, autopsia y veredicto de cierre)

```
Eres el redactor de la Fase 11 (cierre) del curso "Buscafino" — Ruta NoSQL,
modelo de acceso de búsqueda.

CONTEXTO MÍNIMO:
- El villano del curso es "source-of-truth-in-the-index": escribir negocio
  directo en el motor de búsqueda (Meilisearch/Elasticsearch) sin espejo en
  Postgres, aceptando ahí escrituras que el motor no está diseñado para
  garantizar.
- El antídoto instalado desde la Fase 1: "el índice se reconstruye desde el
  transaccional en cualquier momento; si no puedes tirarlo y regenerarlo, no
  tienes un índice de búsqueda — tienes una bomba de tiempo que además busca
  mal".
- El veredicto de fondo del curso (marco de 5 preguntas, ver semilla): vota
  búsqueda dedicada, PERO con un asterisco honesto — para volumen moderado y
  relevancia simple, Postgres+GIN gana por operar menos.
- Sigue BUSCAFINO-GUIA-ESTILO.md: tú (nunca voseo), código en inglés,
  narrativa en español, referencias al final del capítulo.

TAREA — Redacta la Fase 11 completa, con las 9 secciones habituales, y
además:
1. Construye (código real, no narrado) el subsistema "villano": un servicio
   que escribe datos de negocio SOLO en Meilisearch, sin persistirlos en
   Postgres.
2. Mide con scripts/vs.ts, con números concretos: qué pasa cuando el índice
   se corrompe o se borra (pérdida de datos), cuánto tiempo toma "recuperar"
   algo que nunca tuvo respaldo real, qué pasa al intentar cambiar el
   mapping con datos que no existen en ningún otro lado. Registra los
   resultados en BENCHMARKS.md.
3. Cierra con el árbol de decisión "cuándo NO usar un motor de búsqueda
   dedicado" (ver BUSCAFINO-ALCANCE.md §4) como sección final de veredicto,
   con los números reales de esta fase y de BENCHMARKS.md acumulado
   sosteniendo cada rama del árbol.
4. Ejercicios (25-40, 🟢🟡🟠🔴): incluye varios 🔴 que pidan reproducir la
   autopsia con una variación (otro tipo de corrupción, otro motor) y
   argumentar el veredicto con datos propios.
5. Referencias al final, con relectura crítica de INSTINTOS.md y
   BENCHMARKS.md completos como una de las "lecturas" de cierre.

No inventes cifras: si no puedes ejecutar la medición en este contexto,
deja el placeholder de tabla vacío y marca explícitamente
`[PENDIENTE DE MEDICIÓN REAL]` en vez de rellenar con un número inventado.
```
