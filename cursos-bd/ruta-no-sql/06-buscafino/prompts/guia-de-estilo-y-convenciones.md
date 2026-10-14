# ✍️ Guía de estilo, tono y convenciones
## Buscafino — el modelo de búsqueda a fondo

> **Qué es este documento:** la fuente de verdad editorial del curso: **cómo** se escribe. Cualquier sesión
> que produzca un `.md` de Buscafino la sigue, para que todas las fases se lean como escritas por la misma mano
> y apunten al mismo sitio: **que el lector decida dónde vive cada dato, cómo llega al índice y cómo se
> encuentra, se ordena y se cuenta ahí, y lo defienda con números propios.**
> **Vigencia:** 2026-10-07. **Cerrada salvo lo que depende de la propuesta de fases**: la plantilla rígida de
> fase (§6.2) y las longitudes (§9), que se fijan con ella (§15).
> **Herencia:** se escribió con la guía de Ruta NoSQL Lite y las de los cursos anteriores de la ruta como
> modelo, porque es la misma ruta y el lector viene de lite. Diverge de lite en: un solo dominio y una sola
> familia, una sola plantilla de fase, Mermaid, tiempos permitidos con dispersión, la profundidad full geek y
> **la relevancia contra juicios como primera medida**. La guía de agosto (`_desechable-guia-de-estilo-v1.md`)
> queda de consulta.
> **Precedencia.** Por encima solo está [`alcance-del-proyecto.md`](alcance-del-proyecto.md). Por debajo van el
> contrato de nombres, el diccionario, las propuestas, las plantillas y los prompts. El `CLAUDE.md` del
> repositorio aplica en todo lo que este curso no haya declarado como excepción (§13).

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien que el lunes tiene que explicarle
a su directora general dónde vive una oferta, y por qué el buscador encuentra mejor que el mes pasado.

---

## 1. 🧭 Principio rector

**Todo lo que se escribe apunta a que alguien decida con criterio qué buscador necesita, por dónde entra cada
dato y cómo se mide si encuentra bien, y lo pueda defender con números propios, incluido lo que pasa dentro del
motor.**

No enseñamos OpenSearch como producto ni formamos ingenieros de relevancia de tiempo completo. Formamos la
capacidad de mirar una búsqueda, escribir qué debería devolver, medir lo que devuelve, cambiar un analizador o
un sinónimo por el número, saber qué hace Lucene con cada documento, y saber cuándo un motor más no hacía falta.

El filtro para cada párrafo: **¿esto ayuda a modelar, a medir, a diagnosticar o a decidir?** Si no, sobra.

> 🧠 **Primero los juicios, después el motor.** En este modelo "encuentra mejor" no es una impresión: es un
> número contra lo que debía aparecer. Por eso un cambio de relevancia nunca se publica sin su nDCG antes y
> después, una faceta nunca sin su conteo contra el exacto, y un tiempo nunca sin el tamaño del corpus, la
> mezcla de idiomas y las consultas por segundo al lado.

### 1.1 Qué NO es este curso

No es un curso de la consulta de OpenSearch desde cero, ni de OpenSearch como producto, ni de reclutamiento, ni
de búsqueda semántica. No repite Ruta NoSQL Lite: lo que lite enseñó de búsqueda se **usa** sin volver a
explicarlo, empezando por que el índice no es una fuente de verdad.

### 1.2 Requisitos y autocontención

Lo publicado nombra Ruta NoSQL Lite **solo como requisito de entrada**, en el README y en la primera fase. **No
usa su contenido**: no remite a sus fases, no reutiliza sus ejemplos, sus datos ni sus mediciones; si el curso
necesita algo que lite enseñó, lo da por sabido o lo dice con sus propias palabras y con Vacantia (D-03). Ningún
documento publicado cita otros cursos de la ruta ni el `CLAUDE.md` del repositorio.

---

## 2. 🎤 Tono

**Semiformal, cálido y directo**, con humor cuando cae bien: un colega que estuvo de guardia la cuesta de enero y
te lo cuenta con paciencia.

- **Tuteo latinoamericano, siempre.** *"Cambia el analizador del título a inglés y mide cuánto sube el nDCG de
  las consultas en inglés, y cuánto baja el de las otras"*. Nada de voseo, nada de "usted", nada de impersonal
  permanente.
- **Semiformal.** Frases completas, cero abreviaturas de mensajería.
- **Humor seco y con moderación.** Máximo un chiste por sección; el blanco es la situación (el "diay" de Kenneth
  frente al disco al 82 %), nunca una persona.
- **Cálido sin condescendencia.** El lector es senior y ya hizo lite.
- **Honesto sobre lo feo.** Si ParadeDB alcanza, si Typesense gana el autocompletado, si un sinónimo empeora la
  precisión, se dice con esas palabras y con el número delante.
- **Cuidadoso con las personas del dominio.** Los candidatos son sintéticos; el curso nunca muestra un dato
  personal real ni enseña a perfilar a alguien más allá de lo que la búsqueda de Talento necesita.

### 2.1 El tono de las autopsias

⚰️ Una autopsia se escribe sobre una **decisión**, jamás sobre una persona. Los feeds directo al índice los puso
Javier, con aval de Mauricio y con un buen argumento —seis horas menos de atraso—; los destacados como campo los
pidió Daniela para salir a vender. El buscador, de Mauricio, encuentra lo que el `ILIKE` nunca encontró. Si un
párrafo suena a *"quien escribió al índice sin pasar por PostgreSQL no sabía"*, el curso pierde a su mejor
personaje y al lector que hizo algo parecido.

Se escribe en este orden: la decisión con su mejor argumento; por qué era razonable entonces; qué pasó después,
con número; cuánto cuesta salir, con número; qué pregunta, hecha a tiempo, habría cambiado el resultado. Lo que
nunca aparece: "obviamente", "cualquiera habría visto", "error de novato".

---

## 3. 🗣️ Idioma y forma de la narrativa

- **Español latinoamericano neutro** para todo lo que no sea código o salida de terminal.
- **Los términos del oficio se quedan en inglés** cuando son el nombre real de la cosa: *analyzer*,
  *tokenizer*, *token filter*, *stemmer*, *BM25*, *nDCG*, *MRR*, *recall*, *explain*, *function score*,
  *decay*, *post filter*, *terms aggregation*, *cardinality*, *completion suggester*, *search-as-you-type*,
  *edge n-gram*, *fuzziness*, *segment*, *refresh*, *flush*, *translog*, *merge*, *doc values*, *shard*,
  *replica*, *circuit breaker*, *watermark*, *alias*, *snapshot*, *outbox*. Los que tienen traducción asentada
  —índice, analizador, sinónimo, faceta, agregación, fragmento, réplica, segmento, fusión, instantánea,
  relevancia, exhaustividad— se alternan con naturalidad. **No se inventa vocabulario.**
- **"Índice"** se usa para el del motor de búsqueda; cuando haga falta hablar de uno de PostgreSQL, se dice
  *índice GIN* o *índice de PostgreSQL*.
- **Las consultas de ejemplo van en el idioma del usuario que las escribiría**: *"contador San José"*, *"remote
  backend developer"*, *"desenvolvedor"*. Son datos, no narrativa.
- **Markdown siempre**, sin HTML embebido. **Prosa antes que listas.** Una frase aislada por sección, dos si es
  larga.
- **Tablas solo para lo tabular y corto**: comparación de motores, resultados por consulta o por idioma, la
  traducción SQL ↔ consulta del motor.
- **Diagramas en Mermaid** (D-12): el camino de un documento hasta ser buscable, los segmentos y sus fusiones, el
  camino de un feed, el alias antes y después. Árboles de archivos y salidas en `text`.
- **Salida de terminal literal**, en `text` o `json`, sin recortar la parte incómoda (sobre todo la de
  `_explain`, la de una agregación con error y la del clúster en rojo).
- **Encabezados con emoji, con moderación.**

---

## 4. 🎓 Pedagogía: cómo se explica

El público es senior, relacional de oficio y ya pasó por lite: **no explicar lo que ya sabe, y no dejar ambiguo
nada de lo que no.**

### 4.1 La regla del andamio

1. **El problema primero**, siempre en Vacantia: *"Alguien en Guayaquil escribe 'desarrollador react remoto'.
   Hay cuatro mil ofertas que le sirven, la mitad en inglés. ¿Cuántas de las diez primeras van a ser en inglés
   con el analizador en español? Apúntalo antes de ejecutar."*
2. **El mecanismo después**: el nombre y la definición mínima.
3. **La consulta que corre**, con su salida real y la línea que importa señalada.

### 4.2 Del instinto se parte, no se reniega

- 🩻 **"Esto sí funciona igual"** — lo que se transfiere sin cambios del relacional: el índice se paga al
  escribir, la selectividad manda, el plan se lee, la copia no es un respaldo hasta que se restaura.
- 🪞 **"Tu instinto dice… y esta vez se equivoca"** — el relacional (*"un conteo es un conteo"*), el de la
  conferencia (*"más sinónimos, mejor búsqueda"*) o el que lite dejó demasiado firme (*"si el índice se
  reconstruye desde PostgreSQL, estoy a salvo"*). **Una por fase como mínimo.**
- ⚖️ **"Y aquí el instinto SQL tenía razón"** — las preguntas donde el veredicto va en la otra dirección: el
  destacado, el contador, el conteo exacto, la supresión. Sin este recuadro el curso sonaría a folleto.

### 4.3 Nada de cajas negras prematuras

Primero `curl` contra el motor y `psql` a pelo; después el cliente y el servicio. Primero `_analyze`, `_explain`
y `_cat/segments`; después el panel que los dibuja. Si se habla de un sinónimo, se muestran los tokens que
produce.

### 4.4 Analogías, con fecha de caducidad

Una vez, para abrir la puerta, y se abandonan diciendo dónde se rompen. La más peligrosa del curso: **"la
relevancia es un `ORDER BY` más sofisticado"**. Se desmonta en el mismo párrafo: un `ORDER BY` ordena por un
valor que el dato tiene; la relevancia es un cálculo sobre la consulta, el documento y la colección entera, y
cambia cuando cambia cualquiera de los tres.

### 4.5 Explica el porqué

Cada decisión lleva su porqué: por qué este analizador para este campo, por qué este sinónimo al buscar y no al
indexar, por qué este tamaño de fragmento, por qué este dato entra por PostgreSQL.

### 4.6 Densidad calibrada

Un concepto nuevo por vez. Ninguna sección teórica supera las dos pantallas sin una consulta, una medición o un
diagrama. Reaparecen con otras palabras: la pregunta del curso, "¿dónde vive?", "el espejo" y "lo encontrado
contra los juicios".

### 4.7 Cierra los bucles

Todo paréntesis abierto —*"esto lo pagamos en el bloque de los motores"*, *"deuda 💸"*— se cierra.

---

## 5. 💻 Código, comandos y archivos

> **Regla normativa:** todo lo que se ejecuta o se versiona va en inglés —archivos, rutas, variables,
> identificadores, índices, campos, tablas— y **todos los comentarios van en español con tildes**. Lo que ve un
> candidato o una empresa en el portal va en español (o en el idioma de la oferta).

- **Código ejecutable y mínimo**, que corre de punta a punta con las versiones fijadas.
- **Comentarios que explican el porqué**: `// el sinónimo va al buscar: cambiarlo no obliga a reindexar` sí;
  `// agrega sinónimo` no.
- **Bloques con su lenguaje declarado**: `ts`, `json`, `sql`, `bash`, `yaml`, `text`.
- **Un bloque, una idea.** **Nunca `foo`, `bar`, `doc1` ni `test1`**: todo usa Vacantia.
- **Consultas siempre construidas con el cliente o con parámetros**, nunca concatenando lo que escribió el
  usuario; en el servicio, siempre después de Zod.

### 5.1 Versiones fijadas

**Digest para las imágenes y archivo de bloqueo para las librerías y los complementos**, con la versión legible
en un comentario. **Ninguna versión se escribe de memoria**, y hasta la verificación previa ningún documento
publica un número de versión (§15). **Lo no verificado se dice con esas palabras**: si una imagen no corre
nativa en arm64 y se midió emulada, la medición lo dice; si una función de consulta no existe en uno de los
motores, se dice cuál y desde qué versión.

### 5.2 Los nombres del dominio

Fijos en todo el curso y en inglés. Hasta que exista el contrato de nombres, estos son los vigentes:

| En la narrativa | En el motor de búsqueda | En PostgreSQL |
|---|---|---|
| oferta | alias `jobs`, índices `jobs_vNN` | `jobs` |
| empresa | campo `company_name` | `companies` |
| feed, ítem de feed | — | `feeds`, `feed_items` |
| destacado | campo `featured_until` (villano) | `featured_listings` |
| postulación | campo `application_count` (villano) | `applications` |
| candidato, currículo | alias `resumes`, índices `resumes_vNN` | `candidates`, `resumes` |
| solicitud de supresión | — | `erasure_requests` |
| bandeja de salida | — | `search_outbox` |
| consulta de prueba, juicio | — | `test_queries`, `judgments` |
| tipo de cambio | campo `salary_usd` | `exchange_rates` |

**Índices, campos y tablas en `snake_case`** en los dos mundos; tipos y variables de TypeScript en `camelCase` y
`PascalCase`. La misma entidad lleva el mismo nombre en los dos mundos. **El servicio siempre consulta por
alias**, nunca por el índice con versión. Una fase no renombra un campo ni una tabla: si necesita uno nuevo, lo
declara y se agrega aquí y en la historia.

### 5.3 El villano también va en inglés

El código del villano se nombra como estaba en Vacantia: `importFeeds.ts`, que escribe directo al índice;
`featureJob.ts`, que actualiza `featured_until` en el documento; `incrementApplications.ts`, que suma al
contador en cada postulación; y `rebuildFromPostgres.ts`, el procedimiento de la noche del 11 de enero. Su olor
es **de arquitectura**: un dato que solo vive en el índice, un índice que se actualiza como si fuera una tabla,
una reconstrucción que compite con el tráfico.

### 5.4 Nombres de archivo del curso

Fases `NN-slug.md`; apéndices `aNN-slug.md`; la historia `00-historia-de-vacantia.md`; documentos vivos en la raíz
(§7). Minúsculas y guiones, salvo `README.md`, `INSTINTOS.md` y `BENCHMARKS.md`.

---

## 6. 🧱 La plantilla de los documentos

> 🚧 **Preliminar:** la plantilla rígida de fase se fija con la propuesta de fases. Punto de partida, el mismo de
> los cursos anteriores de la ruta: una sola plantilla que modela **y** mide.

### 6.1 Encabezado obligatorio de fase

```markdown
# 🔍 Fase 02 — Dev, programador, ingeniero de software

> **Curso:** Buscafino · Fase 02 de NN · Bloque I · **10 h**
> **Motor:** OpenSearch `opensearchproject/opensearch@sha256:…` · **Base de verdad:** PostgreSQL `…@sha256:…`
> **Rivales en esta fase:** {{Elasticsearch · Meilisearch · Typesense · PostgreSQL con ParadeDB · ninguno}}
> **Corpus y carga:** {{ofertas, mezcla de idiomas, consultas de prueba, consultas por segundo}}
> **Depende de:** Fase 01 · **Habilita:** Fase 03
> **Fecha de verificación ejecutada:** DD/MM/AAAA
> **Objetivo:** …
```

El título nombra el dolor de Vacantia, no la función del motor.

### 6.2 Secciones de una fase (punto de partida)

1. Título y encabezado
2. 🧭 **Dónde estamos** — qué dejó la fase anterior, y el dolor de Vacantia que abre esta
3. 🎯 **Objetivos**, verificables
4. 🚫 **Qué NO entra todavía**, con destino
5. 🧩 **El modelo** — la búsqueda, lo que debería devolver, el mapeo y la consulta en los dos mundos
6. 🪞 **La apuesta**, escrita antes de medir
7. 📐 **La medición**: lo encontrado contra los juicios, la forma y el tiempo
8. 💥 **El punto de rotura**, con volumen y mensaje literal
9. ⚖️ **Veredicto honesto: cuándo NO hacer esto**
10. ⚠️ **Errores comunes y diagnóstico**, con mensaje literal
11. 📋 **Checklist de validación**, ejecutable
12. 🧪 **Ejercicios** (§8)
13. 📚 **Referencias** (§10)
14. 🏁 **Resultado de la fase** y La señal de que quedó bien

Después, fuera de lo que lee el estudiante, puede ir **📌 Pendientes sugeridos**.

### 6.3 Cómo se presenta una medición

**Toda medición se publica con cinco datos**: qué se midió (lo encontrado y la forma primero), sobre qué corpus y
qué consultas de prueba, con qué motor, digest y configuración frente a qué alternativa, en qué máquina si hay
tiempos, y el comando exacto para reproducirla. **Siempre con el tamaño del corpus, la mezcla de idiomas y las
consultas por segundo.**

```markdown
> 📐 **Medición — sinónimos de cargos al buscar** · 1,4 M ofertas (64 % es, 27 % en, 9 % pt), 300 consultas
> de prueba · `opensearch@sha256:…` frente a `postgres@sha256:…` con ParadeDB · verificado el DD/MM/AAAA ·
> {{máquina}}
>
> | motor | configuración | nDCG@10 | exhaustividad@100 | MRR | p50 | p95 | p99 |
> |---|---|---|---|---|---|---|---|
> | OpenSearch | sin sinónimos | … | … | … | … | … | … |
> | OpenSearch | sinónimos al buscar | … | … | … | … | … | … |
> | PostgreSQL + ParadeDB | sinónimos al buscar | … | … | … | … | … | … |
>
> Reproducir: `node scripts/measure.ts relevance --set job-titles --qps 50`
```

**Los tiempos van con su dispersión** (mediana, p95 y p99, repeticiones y calentamiento declarados) y la
máquina, **y nunca sostienen solos un veredicto** (D-19). Los costos de los gestionados llevan ☁️, la fuente y la
fecha (D-22). La 🪞 apuesta se escribe antes y no se edita.

---

## 7. 📐 Los tipos de documento y su coherencia

- **Fases**, **apéndices** y la **historia**, documento del lector y fuente de verdad narrativa: ningún dato de
  Vacantia se inventa en una fase.
- **Documentos vivos** en la raíz, que son producto: `INSTINTOS.md` (cada 🪞 con su medición),
  **`BENCHMARKS.md`** (toda medición publicada, con los cinco datos de §6.3) y el catálogo de errores con su
  mensaje literal (si es apéndice o documento aparte, lo dice la propuesta de apéndices).
- **Los apéndices no repiten una fase, y viceversa: se enlazan.** **Una fase no cita el temario ni el plan.** 🗑️
  **Los `_desechable-*` no se citan nunca.**
- **Git:** tags `fase-NN-<slug>`, prefijo de commit `fNN:`, ejercicios `fNN ejM: …` (D-09).

---

## 8. 🧪 Evaluación: ejercicios

- **Cantidad: 20 mínimo y 30 máximo por fase**, calibrada con *"¿cuántas cosas distintas enseña esta fase que se
  puedan comprobar por separado?"*.
- **La escala:** 🟢 reproducir · 🟡 aplicar el patrón a otra búsqueda de Vacantia · 🟠 combinar, diagnosticar,
  decidir · 🔴 abierto o adversarial · 🔥 extra, fuera del mínimo.
- **Distribución ≈ 30 % 🟢, 30 % 🟡, 25 % 🟠, 15 % 🔴**, con margen; el bloque de los motores carga hacia 🟠 y 🔴.
- **Al menos un tercio de diagnóstico o medición**: una faceta que no suma, un sinónimo que arruina la precisión,
  una oferta vencida que sigue apareciendo, un segmento lleno de borrados, un autocompletado a 400 ms; se pide
  reproducir, medir y explicar.
- **Predecir antes de ejecutar** en 🟠 y 🔴. **Cada ejercicio cierra con su criterio** (`Objetivo` o `Pregunta`),
  y si es de relevancia, con el número contra los juicios. **Agrupados por dificultad**, con el conteo en el
  título.
- **Sin solución publicada** (D-05). **Taller global:** el buscador en `src/`.
- **💀 Boss de bloque**, cuando el bloque lo admita: un buscador roto o un encargo completo de alguien de
  Vacantia (con nombre, de la historia §2), que cruza al menos dos fases y se entrega como artefacto.

---

## 9. 📏 Longitud y densidad

> 🚧 **Preliminar**, a fijar con la propuesta de fases. Punto de partida para una fase de 10 h: **4.000–5.000
> palabras de cuerpo**, contadas hasta el encabezado de 🧪 Ejercicios. Los apéndices son cortos, con índice de
> salto rápido, una tabla de "cuándo usar qué" y de 5 a 10 ejercicios de consulta.

---

## 10. 📚 Referencias y enlaces

### 10.1 Enlaces externos

**Orden de prioridad:** documentación oficial de la versión que usamos (OpenSearch, Elasticsearch, Apache Lucene,
Meilisearch, Typesense, ParadeDB, PostgreSQL); después los papers y textos de base de la recuperación de
información (BM25, nDCG); después libros; después blogs y videos, con escepticismo explícito ante las
comparativas de parte interesada. **Siempre se advierte cuando un enlace apunta a otra versión**, y con las
licencias y los precios se cita la fecha. Cada URL se comprueba por código de estado en la sesión que la escribe.

Cada fase cierra sus referencias con un **orden de lectura sugerido**: antes de ejecutar, durante y después.

### 10.2 Enlaces internos y anclas

Rutas relativas; anclas comprobadas; **ningún enlace a un documento que todavía no existe**.

### 10.3 Vigencia

Las secciones de referencias advierten que las URL y los contenidos cambian, que las consultas y las funciones de
cada motor cambian entre versiones, y que las licencias y los precios cambian: se cita la fecha.

---

## 11. 🧷 Vocabulario visual

**Marcadores de estado:** 💸 deuda intencional (con fase de pago) · 🔥 opcional · 🚧 fuera de alcance por ahora,
con destino · ☁️ tomado de documentación, no medido · 🟢🟡🟠🔴 dificultad · ⭐ valoración bibliográfica, solo en
referencias.

**Callouts en blockquote:** 📐 **Medición** (§6.3) · 🪞 **Apuesta / instinto que falla** · 💥 **Punto de rotura** ·
⚰️ **Autopsia** · ⚖️ **Veredicto honesto** y **"Y aquí el instinto SQL tenía razón"** · 🩻 **Esto sí funciona
igual** · 📖 **Traducción** SQL ↔ consulta del motor, en tabla · 🧠 **Modelo mental** · ⚠️ **Advertencia** · 📝
**Nota de contexto** (licencias, historia de un proyecto) · 💡 **Truco** · 🩺 **Diagnóstico**, la consulta o la
salida que confirma o descarta una hipótesis.

**Secciones narrativas recurrentes:** *Dónde estamos* · *Detalles con intención* · *El patrón a memorizar* ·
*Prueba de fuego* · *La señal de que quedó bien*.

---

## 12. ✅ Checklist antes de dar por cerrado un `.md`

```text
[ ] El encabezado está completo, con motor, digest, rivales, corpus y carga, y fecha de verificación
[ ] La fase abre con un dolor de Vacantia que está en la historia
[ ] Ningún dato de la empresa se inventó en la fase (si hacía falta, se agregó a la historia)
[ ] Nada de lo que Ruta NoSQL Lite ya enseñó se explicó de nuevo; ninguna remisión a sus fases
[ ] Todo número salió de una ejecución real; lo emulado o no verificado está declarado
[ ] Toda medición trae los cinco datos de §6.3, con corpus, mezcla de idiomas y consultas por segundo
[ ] Todo cambio de relevancia trae su número contra los juicios; toda faceta, su conteo contra el exacto
[ ] PostgreSQL jugó con lo mejor que tiene (configuraciones por idioma, pesos, trigramas, ParadeDB)
[ ] Los costos de la nube llevan ☁️, fuente y fecha; las licencias, con fecha
[ ] La apuesta se escribió antes de medir y no se editó después
[ ] El punto de rotura trae volumen exacto y mensaje literal
[ ] Hay un ⚖️ veredicto con la pérdida cuantificada
[ ] Ninguna autopsia juzga a una persona; ningún dato personal real aparece
[ ] Las mediciones, los errores y el 🪞 entraron en sus documentos vivos
[ ] Ejercicios: 20–30, agrupados, con conteo, un tercio de diagnóstico, cada uno con Objetivo o Pregunta
[ ] Los diagramas están en Mermaid; los árboles y salidas, en text o json
[ ] Tuteo en todo el documento; cero voseo, cero "usted"
[ ] Código en inglés, comentarios en español con tildes; el servicio consulta por alias
[ ] Ningún enlace a un documento que no existe; grep -ln "_desechable-" *.md no devuelve nada
```

---

## 13. ⚖️ Excepciones declaradas

1. **Ruta NoSQL Lite como prerrequisito** (D-14) → no se explican los fundamentos de búsqueda → los da lite, y
   repetirlos sería el curso que el lector ya hizo.
2. **Los ejercicios no traen solución publicada** (D-05) → el método del curso es apostar y medir antes de mirar,
   y cada ejercicio trae su criterio.

Todo lo demás del `CLAUDE.md` aplica tal cual.

---

## 14. 🧪 Laboratorio

- **Docker Compose es el camino principal**; cada receta trae su equivalente en Podman. **Aquí no se enseña
  Docker. Sin Kubernetes.**
- **Perfiles de Compose** para no pasar de 16 GB: PostgreSQL con ParadeDB, el servicio y el arnés siempre; **un
  motor de la máquina virtual de Java a la vez**; los livianos juntos; OpenSearch en tres nodos solo en la fase
  de fragmentos (D-20).
- **Cada motor con su configuración documentada** (memoria de la máquina virtual de Java, `vm.max_map_count`
  donde haga falta, memoria de los livianos), nunca con la de otro. Si una imagen no corre nativa en arm64, se
  declara (D-29).
- **Servicios nombrados por papel** (`relacional`, `buscador`, `buscador-rival`, `liviano`), para que cambiar de
  motor no rompa los comandos escritos.
- **Los complementos vienen instalados en la imagen** (D-33); **la seguridad, desactivada** salvo en la fase de
  los currículos (D-25).
- **Datos sintéticos con semilla fija**, las consultas de prueba con sus juicios, los feeds y la copia simulados
  (D-21, D-26, D-27, D-30, D-31).
- **Las pruebas de la producción** corren en contenedores etiquetados con el curso y en puertos altos aleatorios;
  el código de las sesiones va a `zz-code/` con su README.

---

## 15. 📌 Pendientes que afectan a esta guía

- **La plantilla rígida de fase (§6.2) y las longitudes (§9)** se fijan con la propuesta de fases. Todas las
  decisiones del alcance están cerradas (07/10/2026).
- **El diccionario de términos y el contrato de nombres** se escriben después de la propuesta de fases; hasta
  entonces mandan §3 y §5.2.
- **Versiones, digests, complementos y licencias sin fijar** hasta la verificación previa (D-24, D-33); lo mismo
  los precios de los gestionados y lo que trae la seguridad de la edición libre de OpenSearch (D-25).
- **El recorte contra lite** se revisa cuando sus fases 11 y 12 estén escritas.
- **El verificador del curso** se copia de `zz-instrucciones/herramientas/` y se ajusta cuando la plantilla de
  fase esté fijada.
