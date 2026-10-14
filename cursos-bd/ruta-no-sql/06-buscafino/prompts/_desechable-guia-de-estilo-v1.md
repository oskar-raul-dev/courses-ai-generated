# ✍️ Guía de estilo, tono y convenciones — Buscafino

> Deriva de `GUIA-DE-ESTILO-Y-CONVENCIONES.md` (curso legacy), adaptada al
> modelo de búsqueda de texto. Se copia lo que sigue siendo cierto para toda
> la ruta y se reescribe lo que es propio de este curso: el villano, el
> diccionario de traducción y los recuadros que instalan el mantra del
> índice derivado. Cualquier `.md` de Buscafino sigue esta guía.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien decida, con números propios,
si su búsqueda necesita un motor dedicado o si su Postgres ya basta.** No
enseñamos Meilisearch "de moda": enseñamos a reconocer un patrón de acceso
distinto al `WHERE`, a medirlo contra la alternativa relacional, y a no
repetir el error del villano — tratar el índice de búsqueda como si fuera la
base de datos. Si un párrafo no ayuda a modelar, medir o diagnosticar
búsqueda, sobra.

## 2. Tono

Cálido, informal, directo — de colega senior a colega senior, con humor con
moderación. El lector domina SQL y ha operado sistemas en producción; **no
le expliques qué es un índice, un `EXPLAIN` o una transacción**: lo sabe. Lo
nuevo es cómo cambian esas nociones cuando el índice es invertido y la
pregunta es de relevancia, no de igualdad.

- **Segunda persona, con "tú".** El curso usa **tú**, nunca voseo. No
  aparece "vos", "tenés", "sabés" ni sus conjugaciones en ningún documento
  del curso, ni siquiera en ejemplos informales o citas de personajes
  ficticios del dominio (reseñas de producto, tickets de soporte, etc.):
  "activa el índice y verás el resultado", no "activá el índice y vas a
  ver". Esta es una regla de forma sin excepciones — si aparece voseo en un
  borrador, se corrige antes de publicar.
- **Honesto sobre el asterisco.** El veredicto de Buscafino no es 5-0: es
  "vota búsqueda dedicada, con un asterisco". El tono lo refleja sin
  ambigüedad — nunca se vende Meilisearch como solución universal, y Postgres
  con GIN se trata con el mismo respeto con el que se trata al motor
  dedicado cuando gana la medición.
- **Orientado a la duda real.** Anticipa "¿y esto para qué, si con un
  `ILIKE` ya funciona?" y respóndela con el mismo argumento de fondo del
  curso: funciona para la demo, no para la pregunta real que hace un
  usuario de e-commerce.
- **Cercanía sin condescendencia.** No expliques qué es un `GROUP BY`; sí
  explica por qué un `GROUP BY` por faceta no escala igual que un índice
  invertido diseñado para facetas.

> 🧠 **Matiz propio del curso.** El lector llega con instinto de motor
> transaccional: cree que "buscar" es un `WHERE` más caro. El tono lo
> interpela de frente con dos micro-secciones recurrentes (§7): 🪞 *"tu
> instinto SQL dice… y esta vez se equivoca"* y 🩻 *"esto sí viaja igual"*.
> Nunca se ridiculiza el instinto: se lo honra y se lo recalibra hacia el
> modelo de índice invertido.

Evitar: promesas vacías ("vas a dominar la búsqueda"), motivación de coach,
solemnidad de manual corporativo, y vender el motor dedicado como bala de
plata — el curso existe justamente para desactivar ese reflejo.

## 3. Idioma y forma (narrativa)

- Español claro y técnico para todo lo que **no** es código: títulos,
  explicaciones, ejercicios, referencias. Los términos del dominio se dejan
  en inglés cuando son el nombre real de la técnica o la estructura:
  *ranking*, *facet*, *query*, *token*, *stemming*, *stopword*, *inverted
  index*, *typo-tolerance*, *boost*, *relevance*, *sharding*, *alias/swap*,
  *reindex*. No se traducen forzadamente a un neologismo torpe ("índice
  invertido" sí se traduce porque tiene equivalente natural; "typo-tolerance"
  no se fuerza a "tolerancia de errores tipográficos" cada vez, se usa el
  término técnico con su glosa la primera vez que aparece).
- Markdown siempre.
- **No voseo, en ningún documento del curso** (ver §2).
- Encabezados con emoji, con moderación — uno por sección de plantilla.
- **Prosa antes que listas.** Se explica razonando en párrafos.
- **Tablas solo para comparar, decidir o mapear** — muy en particular las
  tablas de traducción relacional ↔ búsqueda (§6) y las de decisión ("motor
  ligero vs industrial", "cuándo Postgres basta").

## 4. Idioma del código fuente (código en inglés, curso en español)

Regla normativa para todo fragmento de código del curso, en cualquier fase,
apéndice o ejercicio resuelto.

| Capa | Idioma | Ejemplo |
|---|---|---|
| Identificadores de código (TS/Node) | 🇬🇧 Inglés | `function buildFacetQuery(filters) {}` |
| Nombres de índice / colección de búsqueda | 🇬🇧 Inglés | `products_index`, `catalog_v2` |
| Campos del documento indexado | 🇬🇧 Inglés | `title`, `brand`, `priceCents`, `popularityScore`, `stockQty` |
| Nombres de faceta (`facets` en la config del motor) | 🇬🇧 Inglés | `brand`, `category`, `color`, `rating` |
| Endpoints del servicio de búsqueda | 🇬🇧 Inglés | `/search`, `/autocomplete`, `/reindex` |
| Ranking rules / reglas de relevancia (config) | 🇬🇧 Inglés | `words`, `typo`, `proximity`, `attribute`, `exactness` (nombres nativos del motor, no se traducen) |
| Tablas y columnas de Postgres (fuente de verdad) | 🇬🇧 Inglés | `products`, `outbox_events`, `price_cents`, `updated_at` |
| Comentarios de código | 🇪🇸 Español | `// el índice se reconstruye completo: no confiamos parches parciales` |
| Textos de interfaz (labels de facetas, mensajes) | 🇪🇸 Español | `"Marca"`, `"Sin resultados para tu búsqueda"` |
| Narrativa del tutorial | 🇪🇸 Español | Todo el texto fuera de bloques de código |

> 📝 **Por qué esta regla.** El código de un motor de búsqueda real que
> mantiene un equipo técnico está en inglés — nombres de índice, de campo, de
> regla de ranking. Escribir el pedagógico igual hace que el vocabulario de
> identificadores sea el mismo que el estudiante encuentra en la
> documentación oficial de Meilisearch, Elasticsearch, OpenSearch y
> Typesense, que está en inglés.

### 4.1 Qué se traduce y qué no

| Elemento | ¿Inglés? | Ejemplo |
|---|---|---|
| Nombre de índice, campo, faceta | ✅ Sí | `brand`, `products_index` |
| Nombre de función, variable, endpoint | ✅ Sí | `computeFacetCounts`, `/search` |
| Ranking rules nativas del motor | ✅ Sí (no se traducen) | `sort`, `typo`, `words` |
| Comentarios de código | ❌ No | `// esto evita reconsultar Postgres en el camino caliente` |
| Labels de faceta que ve el usuario final | ❌ No | `"Marca"`, `"Precio"`, `"Valoración"` |
| Mensajes de error legibles | ❌ No (la *key* sí va en inglés) | `{ code: 'index_not_ready', message: 'El índice todavía se está construyendo' }` |
| Nombres del dominio en la narrativa | ❌ No | El texto sigue hablando de "producto", "marca", "faceta", "reindexado" |

## 5. El villano y cómo se nombra

El anti-patrón central de Buscafino es **el índice que se cree fuente de
verdad**: escribir primero (o solo) en el motor de búsqueda, guardar ahí
datos que no viven en ningún otro lado, y descubrir el día que el índice se
corrompe o hay que cambiar el mapping que no hay reconstrucción posible. El
curso lo nombra sin rodeos como el patrón **"source-of-truth-in-the-index"**
(el nombre técnico se deja en inglés, como el resto de la jerga del modelo;
la explicación es en español).

El villano se construye **de verdad**, no se narra: en algún punto del curso
(ver `BUSCAFINO-PROMPTS.md`, prompt de la Fase 11) se monta un subsistema
deliberadamente roto que escribe negocio directo en Meilisearch, y se mide
con `vs.ts` el costo exacto de esa decisión — pérdida de datos ante
corrupción del índice, tiempo de recuperación, imposibilidad de reindexar.
La autopsia siempre tiene números de antes/después; nunca se afirma sin
medir.

> ⚖️ **Antídoto, repetido como mantra.** "El índice se reconstruye desde el
> transaccional en cualquier momento; si no puedes tirarlo y regenerarlo, lo
> estás usando mal." Esta frase (o una reformulación fiel) aparece al menos
> una vez por fase a partir de la Fase 1.

## 6. Diccionario de traducción (instinto relacional ↔ búsqueda)

El diccionario completo vive en `DICCIONARIO-BUSCAFINO.md` (artefacto
transversal, ver `BUSCAFINO-PROMPTS.md`). Como referencia mínima:

| Instinto SQL / relacional | Realidad en el modelo de búsqueda |
|---|---|
| `WHERE title ILIKE '%zapato%'` | Consulta de texto libre contra un índice invertido, con ranking de relevancia |
| `ORDER BY created_at DESC` | Ranking rules combinando relevancia textual + señales de negocio (frescura como una señal más, no la única) |
| `GROUP BY brand, COUNT(*)` | Facetas nativas, recalculadas por consulta sobre el índice invertido |
| Índice B-tree | Índice invertido (término → lista de documentos) |
| `pg_trgm` para typos | Typo-tolerance nativa, con distancia de edición configurable |
| `JOIN` para traer marca/categoría | Documento desnormalizado al indexar — no se une nada en la consulta |
| Backup con `pg_dump` | Reconstrucción completa desde el transaccional (el índice no se respalda, se regenera) |
| Vista materializada | Índice derivado — la analogía más cercana, con la salvedad de que se consulta con lenguaje de búsqueda, no SQL |
| Migración de esquema | Cambio de *mapping*/configuración de índice + reindexado (no siempre requiere downtime, ver Fase 9) |

## 7. Marcadores y callouts

### 7.1 Marcadores de estado

- 💸 **Deuda técnica intencional.** Ejemplo vivo: el outbox a mano de la
  Fase 8, que se "paga" al migrar a CDC con Debezium.
- 🔥 **Opcional / ampliación** (CDC con Debezium, perfil bilingüe de la Fase
  10, clúster de ES/OpenSearch para quien tenga RAM).
- ⭐ **Fase o pieza central** (Fase 1 — índice derivado; Fase 11 — autopsia).
- 🟢🟡🟠🔴 **Dificultad de ejercicios.**

### 7.2 Callouts en blockquote

- 📝 **Nota de época.** Contexto histórico de una decisión (ej. el cambio de
  licencia de Elasticsearch y el nacimiento de OpenSearch).
- 📚 **Referencia rápida inline**, junto a la duda que la origina.
- ⚠️ **Advertencia** (versión incompatible, `CouchDB ≠ Couchbase`, un
  parámetro de ranking que rompe el orden esperado).
- 💡 **Truco o atajo** real.
- 🪞 **Instinto SQL, puesto a prueba.** Predicción explícita + medición con
  `vs.ts` + veredicto. Alimenta `INSTINTOS.md`.
- 🩻 **Esto sí viaja igual.** Lo que del paradigma relacional se traslada sin
  fricción (ej. "un `WHERE precio BETWEEN` sigue siendo la forma natural de
  pensar un filtro de rango, aunque lo traduzcas a un `filter` de Meili").
- ⚰️ **Caso de estudio del villano**, con autopsia y números antes/después.
- ⚖️ **Veredicto de una fase o del curso**, siempre después de medir, nunca
  antes.

### 7.3 Secciones narrativas recurrentes

- **💸 Pago de deuda** — cuándo aplica.
- **🪞/🩻 pareja** — casi siempre juntas: primero el instinto que falla,
  después lo que sí se salva.

## 8. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden.
Se hereda del esqueleto de la ruta con un único ajuste: donde el legacy dice
"modelado de datos", aquí se lee **"modelado de índice y mapping"**.

1. **🎯 Propósito** — qué resuelve esta fase; puede abrir con la situación
   heredada ("hasta ahora tu búsqueda es un `ILIKE` que funciona en la demo…").
2. **✅ Qué queda listo al terminar** — checklist verificable.
3. **🚫 Qué queda fuera por ahora** — qué se difiere y a qué fase.
4. **🧠 Conceptos mínimos** — anclado al dominio de Buscafino. Aquí viven la
   📖 tabla de traducción de la fase y los recuadros 🪞/🩻.
5. **💻 Implementación y código comentado** — el grueso; identificadores en
   inglés (§4). Aquí caben **Detalles con intención**, **El patrón a
   memorizar**, **Prueba de fuego** y **💸 Pago de deuda**.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente
   (conteos de faceta que no suman, ranking invertido, reindex a medias) y
   cómo depurarlo.
7. **🧪 Ejercicios progresivos** — 25 a 40 (§9).
8. **📚 Referencias** — al **final del capítulo**, siempre (§10). Ninguna
   fase se da por cerrada sin esta sección, aunque sea breve.
9. **🚀 Cierre y conexión con la siguiente fase** — qué sigue y por qué.
   Aquí va **La señal de que quedó bien**.

Los apéndices no siguen esta plantilla: usan índice de salto rápido +
secciones cortas + tabla "cuándo usar qué" + 5-10 ejercicios cortos.

## 9. Ejercicios

- **Cantidad: mínimo 25, ideal 30-40 por fase**, todos anclados al dominio
  de Buscafino (productos, marcas, facetas, consultas reales de usuario) —
  nunca ejemplos abstractos tipo `foo`/`bar`.
- **Niveles de dificultad obligatorios y equilibrados**, marcados con
  🟢🟡🟠🔴 y numeración continua con encabezado de rango:

  ```
  ## 🧪 Ejercicios (30)

  **🟢 Fácil (1–8)**
  1. ...
  **🟡 Intermedio (9–17)**
  9. ...
  **🟠 Difícil (18–25)**
  18. ...
  **🔴 Muy difícil (26–30)**
  26. ...
  **🔥 Opcionales**
  - 🔥 ...
  ```

  Distribución sugerida para ~30: ~8 🟢, ~9 🟡, ~8 🟠, ~5 🔴, más los 🔥
  aparte y sin numeración continua.
- **Progresión real por nivel:**
  - 🟢 calientan: ejecutar una consulta ya escrita, leer un conteo de
    faceta, distinguir en qué campo matcheó un resultado.
  - 🟡 construyen: agregar una faceta nueva, ajustar un peso de campo,
    escribir un filtro combinado.
  - 🟠 integran: medir con `vs.ts`, diagnosticar un ranking sospechoso,
    reproducir una desincronización entre índice y transaccional.
  - 🔴 exigen integrar varias fases o medir algo esquivo: una cola de
    latencia bajo ráfaga de teclas, una ventana de inconsistencia real, la
    degradación de recall al subir la tolerancia a typos.
- **Al menos un puñado por fase son de diagnóstico**: se entrega un bug ya
  inyectado (facetas que no suman, autocompletado a 400 ms, reindex
  interrumpido a medias) y se pide reproducir y localizar, no solo construir.
- **Enganchados al dominio siempre**: "haz que la faceta `brand` cuente
  correctamente tras filtrar por `category`", no "practica agregaciones".
- Cuando un ejercicio nombra código, usa el identificador en inglés vigente
  ("agrega el campo `popularityScore` al índice"), aunque el enunciado esté
  en español.

## 10. Referencias

- **Van al final de cada capítulo/fase**, en su propia sección numerada
  (punto 8 de la plantilla, §8), nunca dispersas en el cuerpo del texto —
  salvo el callout inline 📚 para un enlace puntual que resuelve una duda en
  el momento en que surge, que además se repite en la lista final.
- Formato por referencia: **título**, **URL completa**, y una nota de
  contexto corta (oficial / libro / video / orden de lectura sugerido).
- **Toda URL, título de libro o ID de video se marca `(verificar)`** hasta
  que se confirme antes de publicar. No se inventan números de página, DOIs
  ni IDs de YouTube — nunca, bajo ninguna presión de completar la sección.
- Si una versión de la documentación citada no coincide con la fijada en el
  stack del curso, se advierte explícitamente en el texto de la referencia.
- Se agrupan por fase y, cuando aplica, se sugiere un **orden de lectura**
  (ej. "FTS de Postgres primero —terreno conocido— → indexado en Meili").

## 11. Checklist rápido antes de dar por cerrado un `.md`

- [ ] Sigue la plantilla de 9 secciones (o el formato de apéndice).
- [ ] Tono cálido e informal, segunda persona con **tú** (nunca voseo).
- [ ] Todo el código corre con las versiones fijadas del stack de Buscafino.
- [ ] Identificadores, endpoints, campos de índice y nombres de faceta en
      inglés (§4).
- [ ] Comentarios de código y textos de interfaz en español (§4.1).
- [ ] No contradice ninguna fase anterior ni la semilla; respeta el mantra
      "índice derivado, nunca fuente de verdad".
- [ ] Usa el vocabulario de callouts (📝 📚 ⚠️ 💡) y los recuadros propios
      (🪞 🩻 ⚰️ ⚖️ 📖) donde aporten.
- [ ] Marca 💸 la deuda técnica (y la paga si corresponde) y 🔥 lo opcional.
- [ ] Tiene 25-40 ejercicios numerados con rangos 🟢🟡🟠🔴 equilibrados,
      incluidos ejercicios de diagnóstico.
- [ ] **Tiene una sección de Referencias al final**, con URLs completas y
      advertencia `(verificar)` donde corresponda.
- [ ] Toda afirmación comparativa ("X es más rápido que Y") cita o produce
      una entrada en `BENCHMARKS.md`; ninguna vive suelta en el texto.
- [ ] Explica el *porqué* de cada decisión relevante.
- [ ] Incluye "La señal de que quedó bien" en el cierre.
