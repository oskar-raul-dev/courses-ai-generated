# 🧵 Telaraña — Prompts de arranque y redacción

> Curso #4 de la Ruta NoSQL · Modelo: **Grafo** · Motores: Neo4j + Memgraph +
> (Neptune documental) · Control: PostgreSQL · Dominio: detección de fraude
> sobre transacciones financieras sintéticas.
>
> Estos prompts están pensados para copiarse y pegarse en un **proyecto
> nuevo** (sin `04-telarana-semilla.md`, `TELARANA-ALCANCE.md` ni
> `TELARANA-GUIA-ESTILO.md` cargados). Cada uno incluye el contexto mínimo
> necesario para que el asistente redacte con criterio propio, sin tener que
> releer toda la Ruta NoSQL. Si los tres archivos de referencia SÍ están
> disponibles en el proyecto, dilo al inicio de la conversación y el
> asistente puede citarlos en vez de repetir el contexto.

---

## 0. Cómo usar este documento

- **Un prompt por mensaje.** No encadenes dos prompts en el mismo turno: cada
  fase merece su propia conversación (o al menos su propio mensaje) para que
  el asistente pueda iterar contigo antes de pasar a la siguiente.
- **El prompt de Fase 0 va siempre primero** en un proyecto nuevo: fija el
  stack, el esquema de grafo y el vocabulario que todas las fases siguientes
  dan por sentado.
- **El prompt-plantilla por fase (§2) se rellena** con los datos de la tabla
  de fases (§2.1) antes de enviarlo — no se envía en blanco.
- Los prompts de artefactos transversales (§3) se lanzan una vez al principio
  para crear el documento vacío con su estructura, y **se reabren, no se
  regeneran**, cada vez que una fase nueva aporta una entrada.

---

## 1. Prompt de arranque — Fase 0

```
Vas a redactar la Fase 0 del curso "Telaraña", un curso sobre el modelo de
acceso de GRAFO (no sobre "aprender Neo4j"). Es el curso #4 de una ruta más
grande de NoSQL, pero se sostiene solo: no necesitas el resto de la ruta.

CONTEXTO DEL CURSO
- Dominio: un sistema de detección de fraude sobre transacciones financieras
  SINTÉTICAS (sin datos reales, sin PII, sin confidencialidad que proteger).
- Dos familias de señal de fraude, ambas problemas de recorrido:
  1) Anillos de dinero: ciclos de transferencias A→B→C→A, de longitud
     variable.
  2) Identidad indirecta: cuentas sin transferencia directa entre sí pero
     conectadas por un dispositivo, dirección o teléfono compartido.
- Esquema de grafo fijo (no lo cambies):
  Nodos: Account (accountId, openedAt, status), Device (deviceId,
  fingerprint), Address (addressId, zip), Phone (phoneId).
  Aristas: TRANSFERRED_TO (Account→Account; amount, at, txId),
  USED_DEVICE (Account→Device), REGISTERED_AT (Account→Address),
  HAS_PHONE (Account→Phone).
- El mismo dataset debe existir en dos formas equivalentes: grafo (para
  Neo4j/Memgraph) y relacional normalizado con tablas puente (para
  Postgres), con anillos y señales de identidad sembrados de forma
  CONTROLADA (se sabe cuántos y de qué profundidad se plantaron, para poder
  verificar recall).

STACK (versiones a verificar en esta misma fase, no las claves de memoria)
- Neo4j Community, línea CalVer vigente (aprox. 2026.0x) o 5.26 LTS como
  alternativa conservadora — confirmar la última estable.
- Memgraph 3.x (imagen memgraph-mage) — confirmar la última estable.
- Amazon Neptune: NO se opera, solo se documenta en fases posteriores.
- PostgreSQL 18 como control relacional (CTE recursivos).
- Node.js LTS activo + TypeScript para el arnés, el generador de datos y
  cualquier script de soporte.
- Driver Neo4j: neo4j-driver (Node) vía protocolo Bolt; el mismo driver
  puede usarse contra Memgraph (Cypher-compatible por Bolt).
- Driver Postgres: pg (node-postgres).
- Todo el stack corre contenerizado (Docker o Podman), sin instalación
  nativa.

QUÉ DEBE PRODUCIR ESTA FASE
1. Un docker-compose.yml (o equivalente) que levante Neo4j + Memgraph +
   Postgres con un solo comando, con healthchecks y credenciales por
   defecto documentadas.
2. Un generador de datos sintéticos en TypeScript que produzca el MISMO
   dataset semántico en las dos formas (grafo y relacional), sembrando un
   número conocido de anillos de profundidades variadas y de señales de
   identidad compartida, validando la forma de los datos con Zod.
3. El arranque de scripts/vs.ts: el arnés de benchmark que va a crecer fase
   a fase. En esta fase solo necesita un duelo trivial (un conteo de nodos
   o filas) para probar que el cableado a los tres motores funciona.
4. NO se modela fraude todavía más allá del esquema fijo de arriba: esta
   fase monta la mesa, no juega la partida.

REGLAS DE ESTILO (resumen — ver guía completa si está disponible)
- Código (etiquetas de nodo, tipos de arista, propiedades, funciones,
  nombres de archivo/módulo) SIEMPRE en inglés. Narrativa, comentarios de
  código y textos de salida del arnés SIEMPRE en español, sin voseo (usa
  "tú", nunca "vos").
- Tono: colega senior a colega senior, cálido, informal, humor con
  moderación. El lector domina SQL a fondo: no le expliques qué es un
  índice o un JOIN.
- Prosa antes que listas; tablas solo para comparar/decidir/mapear.
- Estructura de fase en 9 secciones: 🎯 Propósito, ✅ Qué queda listo,
  🚫 Qué queda fuera por ahora, 🧠 Conceptos mínimos, 💻 Implementación y
  código comentado, ⚠️ Errores comunes y pieza forense, 🧪 Ejercicios
  progresivos (20-40, graduados 🟢🟡🟠🔴), 📚 Referencias del capítulo (con
  URL completa y advertencia de que deben verificarse), 🚀 Cierre y
  conexión con la fase siguiente.
- No inventes URLs, títulos, DOIs ni versiones de memoria: verifica antes
  de fijarlas, o márcalas explícitamente como "a verificar".

Redacta la Fase 0 completa como un archivo .md siguiendo esta estructura.
Antes de escribir, si algo del stack o del alcance no está claro, pregunta
o marca la decisión como pendiente en vez de bloquear.
```

---

## 2. Prompt-plantilla por fase (Fases 1 a 11)

Rellena los cinco campos entre `{{ }}` con los datos de la tabla §2.1 antes
de enviarlo. El resto del prompt no cambia entre fases.

```
Vas a redactar la Fase {{NUMERO}} del curso "Telaraña" (modelo de acceso de
GRAFO, dominio de detección de fraude sobre transacciones financieras
sintéticas). Este prompt asume que las fases anteriores ya existen y deben
respetarse; si no las tienes cargadas, pide un resumen antes de continuar
en vez de inventar contenido que pueda contradecirlas.

ESQUEMA DE GRAFO FIJO (no lo cambies)
Nodos: Account (accountId, openedAt, status), Device (deviceId,
fingerprint), Address (addressId, zip), Phone (phoneId).
Aristas: TRANSFERRED_TO (Account→Account; amount, at, txId), USED_DEVICE
(Account→Device), REGISTERED_AT (Account→Address), HAS_PHONE
(Account→Phone).

STACK FIJO
Neo4j (Community, CalVer vigente o 5.26 LTS) + Memgraph 3.x + PostgreSQL 18
como control relacional + Node/TypeScript para el arnés scripts/vs.ts,
generador de datos y drivers (neo4j-driver por Bolt, pg). Todo
contenerizado. Neptune se documenta, no se opera.

QUÉ CUBRE ESTA FASE
Núcleo: {{NUCLEO_DE_LA_FASE}}
El "vs" de esta fase (motores/enfoques comparados y qué se mide):
{{VS_DE_LA_FASE}}

Contexto de una línea de qué trae la fase anterior y a qué fase conecta
esta al cerrar: {{CONTEXTO_PREVIO_Y_SIGUIENTE}}

REGLA DEL "VS": ningún resultado de comparación se narra sin haberlo
corrido (aunque sea de forma simulada/razonada en este chat) por el arnés
scripts/vs.ts. Si comparas algo, muestra el código de ambos lados, el
número, y de qué depende ese número (profundidad k, tamaño de dataset,
repeticiones). Prohibido escribir "el grafo es mucho más rápido" sin una
cifra al lado.

Si la fase involucra un recorrido de profundidad variable, recuerda que la
tesis central del curso es que la ventaja del grafo es CONDICIONAL a la
profundidad: nunca la presentes como una ventaja universal.

REGLAS DE ESTILO (resumen)
- Código en inglés (etiquetas de nodo PascalCase, tipos de arista
  SCREAMING_SNAKE_CASE, propiedades camelCase, funciones TS camelCase,
  archivos camelCase.ts); comentarios de código y narrativa en español sin
  voseo.
- Tono cálido, informal, de colega senior a colega senior; el lector domina
  SQL, no le expliques lo obvio de su paradigma de origen.
- Prosa antes que listas; tablas solo para comparar/decidir/mapear.
- Usa los recuadros propios del curso donde aporten: 📖 tabla de traducción
  SQL↔Cypher, 🪞 "tu instinto SQL dice… y esta vez se equivoca", 🩻 "esto sí
  funciona igual", ⚰️ caso de estudio del anti-patrón (grafo donde bastaba
  un JOIN), 💸 deuda técnica, 🔥 opcional, 📝 nota de época/diseño,
  ⚠️ advertencia, 💡 truco.
- Estructura obligatoria de 9 secciones: 🎯 Propósito, ✅ Qué queda listo,
  🚫 Qué queda fuera por ahora, 🧠 Conceptos mínimos, 💻 Implementación y
  código comentado, ⚠️ Errores comunes y pieza forense, 🧪 Ejercicios
  progresivos (20-40, graduados 🟢🟡🟠🔴, con variación real de dificultad
  dentro de cada rango, numeración continua con encabezado de rango, un
  puñado de diagnóstico que pide reproducir y localizar un fallo), 📚
  Referencias del capítulo (URL completa, nota de versión, advertencia de
  que deben verificarse — esta fase NO puede omitir su propio bloque de
  referencias aunque repita fuentes ya citadas antes), 🚀 Cierre y conexión
  con la siguiente fase (incluye "la señal de que quedó bien").
- No inventes URLs, títulos, DOIs ni IDs de video: verifica o marca como
  pendiente de verificación.

Redacta la Fase {{NUMERO}} completa como un archivo .md. Antes de escribir,
si algo del alcance no está claro, pregunta o márcalo como decisión
pendiente en vez de bloquear.
```

### 2.1 Tabla de relleno por fase

| # | `{{NUCLEO_DE_LA_FASE}}` | `{{VS_DE_LA_FASE}}` |
|---|---|---|
| 1 | Diccionario de traducción SQL ↔ Cypher; modelar el dominio de fraude en Postgres (tablas + tablas puente) y en grafo (nodos y aristas) en paralelo, sin recorridos todavía | Modelado: tabla puente reconstruida por JOIN vs arista de primera clase con identidad propia (conceptual, sin cronómetro) |
| 2 | Índices, selectividad, `PROFILE` de Cypher vs `EXPLAIN ANALYZE` de Postgres, consulta de un solo salto con filtro por propiedad | Neo4j vs Postgres en un salto — se espera y se mide un empate honesto |
| 3 | `MATCH` de longitud fija (1, 2, 3 saltos); primera predicción falsable del lector sobre el costo de un recorrido corto | CTE recursivo de profundidad fija vs Cypher de profundidad fija — dónde empatan todavía |
| 4 ⭐ | Patrones `*1..k` de longitud variable; la curva de costo por profundidad creciente (k=1..6) | SQL vs grafo a profundidad creciente — el punto de quiebre medido, hallazgo central del curso |
| 5 | Detección de ciclos `TRANSFERRED_TO` de longitud variable (anillos de fraude) | Patrón de ciclo en Cypher vs CTE recursivo con control explícito de visitados en SQL |
| 6 | `shortestPath` y caminos ponderados por `amount` entre dos cuentas | Primitiva nativa de camino más corto vs implementación manual en SQL |
| 7 | Vecindarios densos vía `Device`/`Address`/`Phone` compartido (identidad indirecta) | Grafo vs `JOIN` múltiple + `GROUP BY`/`HAVING COUNT(*) > 1` en SQL |
| 8 | Algoritmos de análisis de red: PageRank (influencia), Louvain (comunidades), centralidad como 🔥 opcional | Neo4j GDS vs Memgraph MAGE — grafo vs grafo en analítica, sin equivalente en SQL |
| 9 | Duelo completo Neo4j (disco) vs Memgraph (memoria): misma detección, latencia, throughput de ingesta, consumo de recursos | El duelo grafo-grafo, medido de punta a punta |
| 10 | Diseño y modelo de costos de Amazon Neptune (documental, sin operarlo) | Operar vs pagar por no operar — análisis de costo, no cronómetro |
| 11 ⚰️⚖️ | Autopsia del villano: base "grafo" con 90% de consultas de un salto, medida contra Postgres; árbol de decisión de cuándo NO usar grafo | El villano medido: el grafo pierde el caso de 1-2 saltos frente a Postgres |

Para los **apéndices (A-F)**, usa el mismo prompt pero indica explícitamente
que la fase es un apéndice: la estructura cambia a índice de salto rápido +
secciones cortas + tabla "cuándo usar qué" + 5-10 ejercicios cortos, sin las
9 secciones completas.

---

## 3. Prompts de artefactos transversales

### 3.1 `INSTINTOS.md` — creación inicial

```
Crea el archivo INSTINTOS.md del curso "Telaraña" (modelo de grafo, dominio
de detección de fraude). Es un documento ACUMULATIVO: hoy solo necesito su
estructura inicial vacía, lista para que cada fase agregue una entrada.

Cada entrada de INSTINTOS.md registra, para UN instinto relacional puesto a
prueba en una fase concreta:
1. La fase de origen.
2. La PREDICCIÓN que un senior de SQL haría antes de medir (ej.: "un
   recorrido de 5 saltos en SQL costará parecido a uno de 2, solo un poco
   más").
3. El VEREDICTO MEDIDO, con la cifra real y un enlace a la entrada
   correspondiente de BENCHMARKS.md (ej.: "falso: el costo se disparó ~40×
   entre k=2 y k=5; ver BENCHMARKS.md#fase-4").
4. Si el instinto SOBREVIVE (ej.: los de la Fase 2, índices y selectividad)
   o se ROMPE (ej.: los de recorrido profundo).

Genera el archivo con un encabezado explicando su propósito, una tabla o
lista con las columnas (Fase | Instinto / predicción | Veredicto medido |
¿Sobrevive?), y dos o tres filas de EJEMPLO marcadas claramente como
"ejemplo — reemplazar al redactar la fase real", para que quede clara la
forma sin inventar datos de fases que todavía no se escribieron. Idioma:
español, sin voseo. Sin código; es un documento narrativo con tabla.
```

### 3.2 `INSTINTOS.md` — prompt de actualización por fase

```
Acabas de redactar (o tienes disponible) la Fase {{NUMERO}} del curso
Telaraña. Actualiza INSTINTOS.md agregando una entrada nueva para el
instinto SQL que esa fase pone a prueba.

Contenido de la fase (pega aquí el .md completo o un resumen fiel de su
sección 🪞/🩻 y de los números medidos en su 💻 Implementación).

Agrega la fila siguiendo el formato ya establecido en el documento (Fase |
Instinto / predicción | Veredicto medido, con cifra y referencia a
BENCHMARKS.md | ¿Sobrevive?). No reescribas entradas de otras fases. Si el
documento todavía tiene las filas de ejemplo marcadas como "reemplazar",
elimínalas solo cuando haya al menos una entrada real que las sustituya en
esa posición.
```

### 3.3 `BENCHMARKS.md` — creación inicial

```
Crea el archivo BENCHMARKS.md del curso "Telaraña" (modelo de grafo,
dominio de fraude). Es el registro ACUMULATIVO de todo "vs" ejecutado con
scripts/vs.ts. Hoy solo necesito su estructura inicial.

Cada entrada de BENCHMARKS.md registra:
1. La fase de origen (con ancla, ej. "#fase-4").
2. La consulta semántica comparada, en una frase (ej.: "todas las cuentas
   alcanzables desde una dada, hasta profundidad k").
3. Los motores/enfoques comparados (ej.: Neo4j 2026.0x vs PostgreSQL 18,
   CTE recursivo).
4. La profundidad k, cuando aplica.
5. Los tiempos medidos, CON repeticiones y dispersión (no un solo número
   suelto): ej. "5 corridas, media 12ms, desviación ±2ms".
6. El tamaño del dataset usado (número de nodos/filas, número de aristas).
7. La fecha de la corrida.

Nada entra a este documento sin haber pasado por el arnés. Genera el
archivo con un encabezado explicando su propósito y la regla de "nada sin
medir", una tabla con esas columnas, y dos o tres filas de EJEMPLO
marcadas como "ejemplo — reemplazar con la corrida real". Idioma: español,
sin voseo. Los nombres de motor/versión pueden ir en su forma técnica
habitual (Neo4j, PostgreSQL, etc.).
```

### 3.4 `BENCHMARKS.md` — prompt de actualización por fase

```
Acabas de correr (o simular de forma razonada) el arnés scripts/vs.ts para
la Fase {{NUMERO}} del curso Telaraña. Aquí están los resultados:

{{PEGAR AQUÍ: consulta semántica, motores comparados, profundidad k si
aplica, tiempos por repetición, tamaño de dataset, fecha}}

Agrega una entrada nueva a BENCHMARKS.md siguiendo el formato ya
establecido. No modifiques entradas de otras fases. Si esta fase alimenta
directamente la curva de la Fase 4 (costo vs profundidad), asegúrate de que
la entrada incluya todos los valores de k medidos, no solo el último, para
que el gráfico pueda reconstruirse a partir del registro.
```

### 3.5 Diccionario de traducción SQL ↔ Cypher — creación inicial

```
Crea el diccionario de traducción SQL ↔ Cypher del curso "Telaraña" (puede
vivir como sección de la Fase 1 o como archivo propio, según cómo esté
organizado el proyecto). Cubre dos niveles:

NIVEL 1 — Vocabulario del dominio (fijo, no lo cambies):
cuenta→Account, dispositivo→Device, dirección→Address, teléfono→Phone,
transferencia (arista)→TRANSFERRED_TO, usó el dispositivo→USED_DEVICE,
declaró la dirección→REGISTERED_AT, declaró el teléfono→HAS_PHONE,
anillo/ciclo→ring/cycle, profundidad→depth/k, conjunto de
visitados→visited, camino más corto→shortestPath, identidad
compartida→sharedIdentity, vecindario→neighborhood.

NIVEL 2 — Patrones de consulta (amplíalo con ejemplos concretos del
dominio de fraude, lado a lado):
- SELECT con filtro simple ↔ MATCH con WHERE por propiedad.
- JOIN de dos tablas ↔ patrón de un salto (arista directa).
- CTE recursivo de profundidad fija ↔ MATCH de longitud fija (*n).
- CTE recursivo con control de visitados y profundidad desconocida ↔
  patrón *min..max.
- JOIN múltiple + GROUP BY + HAVING COUNT(*) > 1 ↔ patrón de vecindario
  compartido.
- Sin equivalente cómodo en SQL puro ↔ shortestPath, algoritmos GDS/MAGE
  (PageRank, Louvain).

Preséntalo como una tabla de dos columnas (SQL | Cypher) para el nivel 1, y
como una tabla de tres columnas (Patrón | SQL | Cypher) con al menos un
ejemplo de código real del dominio de fraude para cada fila del nivel 2.
Marca explícitamente en una nota los patrones que en SQL no tienen
equivalente cómodo, para que el lector no busque uno. Idioma: español, sin
voseo, código en inglés.
```

### 3.6 Diccionario de traducción — prompt de ampliación por fase

```
La Fase {{NUMERO}} del curso Telaraña introdujo el/los siguiente(s)
patrón(es) de consulta nuevo(s), con su código en Cypher y su equivalente
(o falta de equivalente) en SQL:

{{PEGAR AQUÍ: patrón(es) nuevo(s) con código de ambos lados}}

Agrega la(s) fila(s) correspondiente(s) al nivel 2 de la tabla del
diccionario de traducción, siguiendo el formato ya establecido (Patrón |
SQL | Cypher). No dupliques filas si el patrón ya está cubierto; en ese
caso, evalúa si esta fase aporta una variante que merece una fila aparte
(por ejemplo, la misma primitiva pero con un parámetro nuevo como peso o
dirección) o si basta con enriquecer la fila existente.
```

---

## 4. Prompt de repaso de coherencia (uso ocasional)

Útil cuando ya hay varias fases escritas y quieres una pasada de
consistencia antes de seguir avanzando.

```
Tengo varias fases redactadas del curso Telaraña (modelo de grafo, fraude
sintético). Voy a pegarte las fases {{LISTA}} completas o resumidas.
Revisa:
1. Que el esquema de grafo (etiquetas Account/Device/Address/Phone,
   aristas TRANSFERRED_TO/USED_DEVICE/REGISTERED_AT/HAS_PHONE) se use de
   forma idéntica en todas — mismos nombres, mismas propiedades.
2. Que ningún "vs" se narre sin un número medido al lado.
3. Que el idioma se respete: código en inglés, narrativa/comentarios en
   español sin voseo.
4. Que ninguna fase posterior contradiga el alcance fijado en
   TELARANA-ALCANCE.md (si lo tienes disponible, pégalo también) — por
   ejemplo, que no aparezca de golpe un dashboard o un motor de ML que el
   alcance excluye explícitamente.
5. Que cada fase tenga su propio bloque de referencias con URLs completas
   y advertencia de verificación.

Reporta discrepancias fase por fase, sin reescribir el contenido todavía:
primero quiero el diagnóstico.
```
