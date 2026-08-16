# ✍️ Guía de estilo, tono y convenciones — Base de la Ruta NoSQL

> **Documento base y reutilizable.** Esta es la guía editorial madre de
> **todos** los cursos de la Ruta NoSQL. Sirve para dos cosas: (1) redactar
> las semillas y artefactos que se generan en el proyecto de arranque, y (2)
> arrancar cada curso nuevo en su propia conversación sin rehacer la
> deliberación de forma y tono.
>
> Cada curso deriva de aquí su propia `<NOMBRE>-GUIA-ESTILO.md` cambiando solo
> lo que es específico del modelo: el **villano** (anti-patrón del curso), el
> **diccionario de traducción** desde el paradigma de origen, el **vocabulario
> del dominio** y los **recuadros propios**. Todo lo demás —tono, idioma del
> código, callouts, plantilla de fase, reglas de ejercicios— se hereda tal
> cual.

> 🧭 **Regla de una línea que rige todo el código:** el **código fuente en
> inglés**; todo lo demás —narrativa, comentarios, textos de interfaz— **en
> español latinoamericano neutro, con tuteo**. El detalle completo está en §4.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien tome —o repare— una decisión de
arquitectura sin romper nada, y sepa defenderla con números.** No enseñamos el
motor "de moda" ni el motor "de siempre": enseñamos a **medir** en qué dominio
gana cada familia y en cuál pierde. Si un párrafo no ayuda a decidir,
diagnosticar, medir o construir bien, sobra.

El norte compartido de toda la ruta es una sola pregunta que reemplaza a "¿qué
base es mejor?": **"¿qué modelo de acceso tiene mi dominio?"**. Cada curso
enseña **un modelo de acceso** (no un producto), lo aplica en un proyecto
concreto, y lo mide con arnés propio (`scripts/vs.ts`) contra sus rivales
reales. Todo lo que escribimos sirve a esa promesa.

> 🧭 **La segunda regla de oro:** *medir, nunca narrar.* Ningún "esta base es
> mejor para X" aparece sin un benchmark ejecutado y volcado en
> `BENCHMARKS.md`. Los benchmarks de marketing —de cualquiera de los dos
> bandos— se rechazan explícitamente.

---

## 2. Tono

El tono es **semiformal y ameno** — de colega senior a colega senior, con
cercanía y algo de humor cuando cae bien, pero sin la informalidad total de un
chat de pasillo. No es un manual acartonado ni un hilo de mensajería: es
alguien con oficio explicándote una decisión difícil con confianza,
respetando tu tiempo y tu criterio.

- **Segunda persona, con tuteo neutro latinoamericano.** Se le habla al lector de "tú": "si el `$lookup` te tienta, primero mide", "vas a sentir el dolor del EAV en vivo". Nunca "vos", nunca "usted", nunca "vosotros". El tuteo es la única forma verbal de segunda persona en toda la ruta.
- **Español latinoamericano neutro.** Se evita el léxico marcado de una sola región (ni "ordenador"/"vale"/"coger" de España, ni modismos muy locales de un solo país). Se busca el vocabulario que un lector de México, Colombia, Argentina, Chile o Perú entiende sin fricción: "computadora", "correo", "archivo", "eliminar", "ejecutar", "consulta". Ver §3.1.
- **Ameno con moderación.** Un 😉 ocasional, un chiste seco sobre "el líder que quería NoSQL", un 🪦 para jubilar un enfoque que ya no aplica. El humor desdramatiza una decisión técnica tensa; no rellena ni convierte la guía en stand-up.
- **Honesto sobre los trade-offs.** Cuando un motor pierde en un caso (y en esta ruta *todos* pierden en algún capítulo), se dice sin eufemismos y con el número al lado: "aquí JSONB empata en lectura de blob; este no es un 'vs' que Mongo gane". No se vende nada.
- **Orientado a la duda real.** Anticipa "¿y esto por qué gana acá y no allá?" y lo responde midiendo, muchas veces con una **nota de contexto** (📝) que da la historia de por qué existe el patrón.
- **Cercanía sin condescendencia.** El lector es senior y llega con un paradigma dominado (casi siempre el relacional). No le expliques qué es un índice, una transacción, un JOIN o el plan de una query: **lo sabe**. Lo nuevo es cómo cambia —o no— en el modelo que enseña el curso.

Evitar: promesas vacías ("vas a dominar NoSQL"), motivación de coach,
solemnidad corporativa, y explicar lo obvio para el perfil. Lo ameno es
condimento, no plato principal.

> 🧠 **El eje de tono de toda la ruta.** El lector no llega en blanco: llega
> con años de instintos de su paradigma de origen. El tono **honra ese
> instinto y lo recalibra**, nunca lo ridiculiza. Se materializa en dos
> micro-secciones recurrentes (§7.4): 🪞 *"tu instinto \[del paradigma origen]
> dice… y esta vez se equivoca"* y 🩻 *"esto sí funciona igual"*.

---

## 3. Idioma y forma (narrativa)

- **Español latinoamericano neutro y técnico** para todo lo que **no** es código (títulos, explicaciones, ejercicios, referencias). Los términos del stack se dejan en inglés cuando son el nombre real: *store*, *pipeline*, *aggregation*, *replica set*, *index*, *sharding*, *bucket pattern*, *change stream*, *embedding*, *facet*, *roll-up*, *shard*, *consistency*, *TTL*, *N+1*. No se traducen forzadamente.
- Markdown siempre.
- Encabezados con emoji **con moderación** — uno por sección de plantilla. Los subtítulos internos pueden llevar emoji-tipo (§7) cuando aportan lectura rápida.
- **Prosa antes que listas.** Se prefiere razonar en párrafos. Las listas se usan cuando de verdad son una lista (pasos, ítems paralelos).
- **Tablas solo para comparar, decidir o mapear.** "Cuándo usar X vs Y", matrices de decisión, mapeos versión-a-versión, tablas de opciones, y —clave en esta ruta— **tablas de traducción \[paradigma origen] ↔ \[modelo del curso]** (§7.4). No para narrar.

### 3.1 Español neutro: criterio práctico

No se persigue un "neutro" imposible; se persigue **que ningún lector regional
tropiece**. Guía rápida:

| Se prefiere (neutro) | Se evita (marcado regional) |
|---|---|
| computadora | ordenador |
| archivo | fichero |
| eliminar / borrar | quitar (ambiguo) |
| ejecutar / correr | lanzar (ambiguo fuera de contexto) |
| arreglar / reparar | apañar |
| de acuerdo / bien | vale |
| tú (siempre) | vos, usted, vosotros |
| aquí / acá (indistinto) | — |

- **Verbos en segunda persona: siempre tuteo estándar** — "tú mides", "tú modelas", "haz", "ten", "ve" (no "medís/modelás/hacé", no "mida/tenga/vaya").
- Cuando un término tenga varias formas regionales, elige la más ampliamente comprensible y sé consistente en todo el curso.
- El inglés técnico es neutro por definición: ante la duda entre dos traducciones regionales de un término técnico, muchas veces la mejor decisión es **dejar el término en inglés** (*deploy*, *commit*, *cache*).

---

## 4. Idioma del código fuente (código en inglés, curso en español)

Esta sección es normativa para **todo** fragmento de código de **todos** los
cursos de la ruta, sea en el cuerpo de una fase, en un incidente, en un
apéndice o en un ejercicio resuelto.

### 4.1 Regla general

| Capa | Idioma | Ejemplo |
|---|---|---|
| **Código fuente** (identificadores) | 🇬🇧 Inglés | `function findProduct(id) {}`, `const isInStock = false` |
| **Endpoints y rutas** | 🇬🇧 Inglés | `/products`, `/products/:id/reviews`, `/search` |
| **Constantes y enums internos** | 🇬🇧 Inglés | `category: 'electronics'`, `SET_LOADING`, `TTL_SECONDS` |
| **Colecciones, tablas, campos, keys** | 🇬🇧 Inglés | `db.collection('products')`, `{ sku, price, createdAt }` |
| **Nombres de archivo, módulo, servicio** | 🇬🇧 Inglés | `product.service.ts`, `vs.ts`, `searchController` |
| **Comentarios de código** | 🇪🇸 Español (neutro) | `// el documento ES la página: localidad perfecta` |
| **Textos de interfaz (UI)** | 🇪🇸 Español (neutro) | `<button>Agregar al carrito</button>`, `"Cargando…"` |
| **Narrativa del tutorial** | 🇪🇸 Español (neutro) | Todo el texto fuera de bloques de código |

Los proyectos pedagógicos de la ruta **no tienen i18n**: son apps en español
para lectores hispanohablantes. Los textos que ve la persona usuaria —labels,
botones, mensajes— van en español neutro. Lo que va en inglés es el código que
lee y mantiene un equipo técnico: nombres de función, variable, colección,
campo, key, endpoint, evento y constante.

> 📝 **Por qué esta regla.** El código de un sistema real mantenido por un
> equipo técnico suele estar en inglés (con comentarios en español, igual que
> acá). Escribirlo así hace que el vocabulario de identificadores sea el mismo
> que la persona va a encontrar en producción — y que todos los cursos de la
> ruta nombren lo mismo de la misma forma.

### 4.2 Qué se traduce y qué no (criterio rápido)

| Elemento | ¿Inglés? | Ejemplo |
|---|---|---|
| `function`, `const`, `let`, tipos TS (nombre) | ✅ Sí | `function getProducts()`, `type Product = {…}` |
| Campos de documento / columnas / keys | ✅ Sí | `{ price, stock, categoryId }`, `cart:{userId}` |
| Endpoints y rutas | ✅ Sí | `apiClient.get('/products')`, `router.patch('/orders/:id')` |
| Colecciones, tablas, índices | ✅ Sí | `collection('reviews')`, índice `status_1_createdAt_-1` |
| Valores de enum/status | ✅ Sí | `status: 'in_progress'` (no `'en_progreso'`) |
| Nombres de módulo/archivo/servicio/capa | ✅ Sí | `products.controller.ts`, `vs.ts` |
| Eventos (socket, change stream, cola) | ✅ Sí | `product:created`, `order:placed` |
| Comentarios `//`, `/* */`, `<!-- -->` | ❌ No | `// valida antes de confiar en el payload` |
| Strings de interfaz (lo que ve el usuario) | ❌ No | `"Agregar al carrito"`, `"Sin stock"` |
| Mensajes de error legibles para el usuario | ❌ No | `{ message: 'No se pudo cargar el producto' }` — **key** en inglés, **valor** en español |
| Nombres del dominio en la narrativa | ❌ No | El texto habla de "producto", "reseña", "pedido", "carrito" |

> ⚠️ **Caso mixto frecuente — mensajes y etiquetas de estado.** El objeto usa
> keys en inglés (`{ message, type }`), pero el **valor** que ve el usuario va
> en español: `{ message: 'El servidor no respondió a tiempo', type: 'timeout' }`.
> Igual con el mapeo de enum a etiqueta: la **clave** es el enum en inglés, el
> **valor** es lo que ve el usuario en español.
>
> ```ts
> // lib/statusMeta.ts
> export const STATUS_META = {
>   active:   { label: 'Activo',    css: 'badge-success' },
>   draft:    { label: 'Borrador',  css: 'badge-secondary' },
>   archived: { label: 'Archivado', css: 'badge-dark' }
> } as const;
> ```
>
> La clave (`active`) es el enum que viaja por la API y vive en la base; el
> `label` (`'Activo'`) es UI y va en español. **Nunca** guardes `'Activo'`
> como valor de `status` en la base o en el payload.

### 4.3 Diccionario del dominio (por curso)

Cada curso mantiene su propio diccionario dominio-español ↔ código-inglés en su
`<NOMBRE>-GUIA-ESTILO.md` (o en un `DICCIONARIO-CODIGO.md` propio si crece).
La forma es siempre esta tabla:

| Español (dominio, narrativa, UI) | Inglés (código) |
|---|---|
| producto / productos | `product` / `products` |
| reseña | `review` |
| pedido | `order` |
| carrito | `cart` |
| almacén | `warehouse` |
| … (lo que el dominio del curso pida) | … |

Los nombres de módulos, servicios, controllers y funciones se arman
combinando estos términos con verbos técnicos habituales (`get`, `fetch`,
`create`, `update`, `delete`, `search`, `index`).

### 4.4 Convenciones de nombrado (comunes a la ruta)

- **Funciones y variables:** `camelCase` en inglés — `findProduct`, `isInStock`, `createdAt`.
- **Tipos / interfaces / clases:** `PascalCase` en inglés — `Product`, `OrderSnapshot`, `SearchResult`.
- **Constantes de configuración:** `SCREAMING_SNAKE_CASE` — `TTL_SECONDS`, `MAX_BATCH_SIZE`.
- **Endpoints REST:** sustantivo en plural, inglés — `/products`, `/products/:id/reviews`, `/search`.
- **Valores de enum/status:** inglés, `snake_case` si son compuestos — `in_progress` (no `inProgress` ni `en_progreso`).
- **Colecciones / tablas:** sustantivo plural en inglés — `products`, `reviews`, `orders`.
- **Keys de clave-valor:** patrón `namespace:id` en inglés — `session:{userId}`, `rate:{ip}`.
- **Eventos:** `recurso:acción` en inglés — `product:created`, `order:placed`.
- **Índices:** nombre autogenerado del motor o uno explícito en inglés — `category_1_price_-1`.
- **Archivos del arnés y scripts:** en inglés — `scripts/vs.ts`, `scripts/seed.ts`.

Cada `<NOMBRE>-GUIA-ESTILO.md` añade las convenciones específicas de su stack
(por ejemplo, nombres de pipeline en Mongo, de query N1QL en Couchbase, de
tabla-por-consulta en Cassandra) sin contradecir estas.

### 4.5 Lo que nunca cambia

- **Comentarios de código:** 100% español neutro, explicando el porqué (§5).
- **Textos de interfaz de usuario:** 100% español neutro — labels, botones, placeholders, mensajes, `alt`, `title`, y los `label` de los mapeos de estado.
- **Narrativa del tutorial:** 100% español neutro con tuteo.
- **Nombres del dominio en la narrativa:** "producto", "reseña", "pedido" siguen siendo las palabras con que *hablas* del sistema, aunque el código diga `product`, `review`, `order`.

### 4.6 El villano también se normaliza a inglés

Cada curso tiene un **anti-patrón villano** (§villano). Aunque el villano sea
"código feo" o "modelo mal decidido", **sus identificadores también van en
inglés**, para no confundir dos problemas independientes: *"está en español"*
y *"está mal diseñado"*. El olor del villano se mantiene por sus **decisiones
de diseño**, no por su idioma. (Si el español agrega valor histórico genuino
—por ejemplo, mostrar cómo nació un legacy real—, se admite en un comentario
📝 de nota de contexto, nunca en los identificadores.)

---

## 5. Orientación a la práctica

Cada concepto se ancla en el dominio del curso y en código que corre.

- **Nada de teoría suelta.** Si se explica un `$inc` atómico, es sobre el decremento de stock concurrente, no en abstracto. Si se explica un TTL, es sobre la sesión que expira.
- **Código ejecutable y coherente.** Todo fragmento corre con las versiones fijadas del stack del curso y no contradice fases anteriores. Nada de pseudocódigo que "se entiende".
- **Código mínimo.** El fragmento más pequeño que muestra el punto, pero ejecutable.
- **Comentarios que explican el porqué, no el qué, siempre en español neutro.** `// la precondición va en el filtro: si otro proceso ya lo tomó, matchea 0 docs` sí; `// incrementa i` no.
- **Distinguir capas.** Siempre queda claro si un comportamiento vive en la app, en el servicio, en la query, en el índice o en el propio motor. Es la distinción que salva al que depura.

---

## 6. Manejo de las decisiones de arquitectura (el corazón de la ruta)

- **Medir antes de afirmar.** Todo "gana X" nace de `scripts/vs.ts` y aterriza en `BENCHMARKS.md`. La opinión sin número no entra.
- **El rival no es de paja.** En cada curso el paradigma de origen (casi siempre el relacional) se construye **en paralelo**, se mide, y **gana en más de un capítulo**. Se honra al rival.
- **Costo de operar, no solo de modelar.** Cada motor nuevo suma superficie operativa (backups, guardia, curva de aprendizaje). Se nombra ese costo explícitamente en cada curso.
- **Corrección mínima vs rediseño.** Ante un problema, se distingue el parche mínimo del rediseño de fondo, igual que en un sistema real.
- **El idioma del código (§4) no es negociable, ni siquiera en el villano.** El mal diseño se muestra tal cual es, pero con identificadores en inglés (§4.6).

---

## 7. Marcadores y callouts (vocabulario visual de toda la ruta)

Este vocabulario se usa igual en todos los cursos para que el lector lo
reconozca de un vistazo.

### 7.1 Marcadores de estado

- 💸 **Deuda técnica intencional.** Shortcut o simplificación que se deja a propósito. Se **declara** en una fase y se **paga** explícitamente en otra.
- 🔥 **Opcional / ampliación.** Ejercicios o secciones que exceden el alcance base.
- ⭐ **Fase o pieza central** del curso.
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** Fácil / intermedio / difícil / muy difícil.

### 7.2 Callouts en blockquote (emoji-tipo)

- 📝 **Nota de contexto.** Historia de un patrón, una decisión de versión o un episodio de gobernanza (forks, cambios de licencia). Ej: "Valkey nació del cambio de licencia de Redis en 2024".
- 📚 **Referencia rápida inline.** Un enlace útil justo donde surge la duda.
- 🪦 **Retiro / jubilación.** Cuando un enfoque cumplió su función y se retira.
- ⚠️ **Advertencia.** Algo que rompe si lo ignoras (versión incompatible, límite del motor, supuesto de consistencia).
- 💡 **Truco o atajo** que ahorra tiempo real.

### 7.3 Secciones narrativas recurrentes (comunes)

- **💸 Pago de deuda.** Donde una deuda declarada antes se salda.
- **Detalles con intención.** Lista corta que destila las decisiones deliberadas de un bloque.
- **El patrón a memorizar.** Una o dos frases con la lección transferible.
- **Prueba de fuego.** Verificación manual concreta incrustada en el flujo.
- **Mini-repaso.** Repaso exprés en tabla de una sintaxis que el lector quizá no domina, antes del código, con su 📚.
- **La señal de que quedó bien.** En el cierre, un criterio en forma de cita.

### 7.4 El esqueleto compartido no negociable (va en cada curso)

Estas piezas son la columna vertebral de **toda** la ruta y aparecen cuando el
contenido lo pide. Cada curso las instancia con su propio paradigma de origen:

- **📖 Tabla de traducción \[origen] ↔ \[modelo del curso].** Lado a lado, la consulta o el modelo del paradigma que el lector domina y su equivalente en el modelo nuevo. Es tabla (§3), no prosa.
- **🪞 "Tu instinto \[del origen] dice… y esta vez se equivoca."** Nombra la trampa **antes** de caer. Honra el instinto y lo recalibra. Es **falsable y medida**: predicción → cronómetro → veredicto escrito.
- **🩻 "Esto sí funciona igual."** Lo reconfortante: lo que la experiencia previa conserva intacto (índices, selectividad, `explain()`, el N+1 siguen valiendo). Baja la ansiedad.
- **⚰️ Caso de estudio: el anti-patrón (el villano).** El anti-patrón del curso, medido de punta a punta: se mide, duele, se arregla, con números antes/después. Es el hilo que cose las fases.
- **⚖️ Veredicto honesto.** El árbol de decisión de **cuándo NO usar esta familia**. Cierra el curso sin fanboyismo.
- **📓 `INSTINTOS.md` y 📊 `BENCHMARKS.md`** acumulativos: cada instinto falsado y cada "vs" medido se registran ahí, curso a curso.

---

## 8. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden:

1. **🎯 Propósito** — qué resuelve esta fase; puede abrir con la situación de partida.
2. **✅ Qué queda listo al terminar** — checklist verificable.
3. **🚫 Qué queda fuera por ahora** — qué se difiere y a qué fase.
4. **🧠 Conceptos mínimos** — solo lo necesario, anclado al dominio. Aquí caben el **Mini-repaso**, las **Notas de contexto**, la 📖 tabla de traducción y los recuadros 🪞/🩻.
5. **💻 Implementación y código comentado** — el grueso; código ejecutable con comentarios de porqué, identificadores en inglés (§4). Aquí caben **Detalles con intención**, **El patrón a memorizar**, **Prueba de fuego** y **💸 Pago de deuda**.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente y cómo depurarlo.
7. **🧪 Ejercicios progresivos** — 30 a 40 (§9).
8. **📚 Referencias** — §10.
9. **🚀 Cierre y conexión con la siguiente fase** — qué sigue y por qué. Aquí va **La señal de que quedó bien** y, en la fase que corresponda, el ⚖️ veredicto.

Los apéndices no siguen esta plantilla: usan índice de salto rápido +
secciones cortas + tabla "cuándo usar qué" + 5-10 ejercicios cortos.

---

## 9. Ejercicios

- **Cantidad: 30 a 40 por fase.** Menos de 30 se queda corto.
- **Distribución equilibrada por nivel.** Reparte parejo entre 🟢🟡🟠🔴. Guía razonable para ~35: ~9 🟢, ~10 🟡, ~9 🟠, ~5-7 🔴, más los 🔥 aparte.
- **Numeración continua con encabezado de rango por dificultad:**
  ```
  ## 🧪 Ejercicios (35)

  **🟢 Fácil (1–9)**
  1. ...
  **🟡 Intermedio (10–19)**
  10. ...
  **🟠 Difícil (20–28)**
  20. ...
  **🔴 Muy difícil (29–35)**
  29. ...
  **🔥 Opcionales**
  - 🔥 ...
  ```
  El título lleva el conteo total: `## 🧪 Ejercicios (35)`.
- **Progresión real.** Los 🟢 calientan; los 🔴 exigen integrar varias fases o depurar algo esquivo (medir un `explain()`, reproducir un N+1, cerrar una race condition, forzar un conflicto de sync).
- **Accionables y verificables.** "Haz que el stock del `sku ABC-123` no baje de cero bajo decremento concurrente" — no "reflexiona sobre concurrencia".
- **Algunos de diagnóstico.** Al menos un puñado entrega un bug y pide reproducir y localizar, no solo construir.
- **Al menos uno de medición por fase.** Corre el "vs" con `scripts/vs.ts`, registra el número en `BENCHMARKS.md`, escribe el veredicto.
- **Enganchados al dominio.** Usan las entidades reales del curso, no ejemplos abstractos.
- **Cuando un ejercicio nombra código, usa el identificador en inglés vigente** ("agrega la función `createOrder`", "escribe el `serializeProduct`"), aunque el enunciado esté en español.
- Los 🔥 son opcionales y se listan aparte, sin numeración continua.

En apéndices bastan 5-10 ejercicios cortos.

---

## 10. Bibliografía y referencias

**Regla:** documentación oficial compatible con las versiones fijadas del
curso **primero**; luego libros; luego blogs, videos y tutoriales. Siempre se
advierte cuando un enlace apunta a docs de una versión distinta a la fijada.

### 10.1 Formato

- **URLs completas y clicables**, no solo el dominio.
- **Secciones separadas** dentro de "Referencias": Documentación oficial (con URL completa y nota de versión), Libros cuando apliquen, Video/apoyo, y **Orden de lectura sugerido** (una línea que encadena qué leer primero).

### 10.2 Advertencias sobre citas

- Cuando se mencione un artículo, libro, video o post específico, hay que dejar claro que **URLs y títulos pueden estar desactualizados o ser inexactos**; el lector debe verificarlos. **No se inventan números de página, DOIs ni IDs de video.**
- Cada curso fija sus fuentes oficiales por producto en su propia guía, siempre con URL completa y nota de versión.

---

## 11. Sobre los dominios (ficticios, sin NDA)

Los dominios de la ruta (Proteo, Portalón, Telaraña, etc.) son **enteramente
ficticios**: casos inventados para enseñar cada modelo. No hay confidencialidad
que preservar. Esto permite que los ejemplos sean todo lo concretos que
convenga, y que el vocabulario del dominio sea estable y se fije por curso.

La regla de idioma del código (§4) es una convención de calidad, no una
cuestión de NDA: se traduce el vocabulario del dominio pedagógico por
consistencia y realismo, no por confidencialidad.

---

## 12. Coherencia entre documentos y entre cursos

- **No contradecir la lista maestra** (`01-ruta-nosql.md`): nombres de curso, rivales del "vs", proyecto y modelo son intocables.
- **No contradecir fases anteriores** dentro de un curso.
- **Fuentes de verdad, en orden:** (1) instrucciones del proyecto de arranque, (2) `01-ruta-nosql.md`, (3) `02-ruta-nosql-fundamentos.md`, (4) la semilla del curso (`<nombre>-semilla.md`), (5) decisiones explícitas del chat actual.
- **CouchDB ≠ Couchbase.** CouchDB (offline-first) → curso 7; Couchbase (rival documental) → curso 0. No confundirlos nunca.
- **El Árbitro (curso 10) es cierre de ruta**, no "producto #11": su material enfoca la *factura* de la persistencia políglota, no un modelo nuevo.
- Nombres de archivos, módulos, servicios, colecciones y campos se mantienen estables entre fases (en inglés, §4.4). Si algo se renombra, se documenta.

---

## 13. Post-mortems e incidentes

Cada incidente sigue esta estructura de ocho puntos:

1. Síntoma.
2. Pasos de reproducción.
3. Evidencia observable (logs, profiler, `explain()`, métricas del arnés).
4. Causa raíz.
5. Corrección.
6. Prueba de regresión.
7. Prevención.
8. Post-mortem **sin culpabilización** (blameless): se analiza el sistema y el proceso, no a la persona.

El tono del post-mortem es sereno y analítico. Lo ameno del resto del curso
baja un punto aquí: un post-mortem es serio, aunque no acartonado.

---

## 14. Checklist rápido antes de dar por cerrado un `.md`

- [ ] Sigue la plantilla de 9 secciones (o el formato de apéndice).
- [ ] Tono semiformal y ameno, segunda persona con **tuteo neutro**, humor con moderación.
- [ ] **Español latinoamericano neutro** (sin léxico marcado de una sola región; §3.1).
- [ ] Todo el código corre con las versiones fijadas del curso.
- [ ] **Identificadores, endpoints, colecciones, campos, keys, constantes y enums del código en inglés (§4).**
- [ ] **Comentarios de código y textos de interfaz (UI) en español neutro (§4.5).**
- [ ] No contradice la lista maestra ni ninguna fase anterior.
- [ ] Distingue capas (app / servicio / query / índice / motor) donde importa.
- [ ] Usa el vocabulario de callouts (📝 🪦 📚 ⚠️ 💡) y el esqueleto compartido (📖 🪞 🩻 ⚰️ ⚖️) donde aporte.
- [ ] Marca 💸 la deuda técnica (y la paga si corresponde) y 🔥 lo opcional.
- [ ] Tiene 30-40 ejercicios numerados con rangos 🟢🟡🟠🔴 equilibrados (o 5-10 en apéndices), con al menos uno de medición.
- [ ] Todo "vs" está **medido con `scripts/vs.ts` y volcado en `BENCHMARKS.md`**, nunca solo narrado.
- [ ] Referencias con URL completa, secciones (oficial / libros / video / orden de lectura), advertencia de versión, sin datos inventados.
- [ ] Explica el *porqué* de cada decisión relevante.
- [ ] Incluye "La señal de que quedó bien" en el cierre, y el ⚖️ veredicto donde corresponda.

---

## 15. Cómo deriva cada curso su propia guía

Cada `<NOMBRE>-GUIA-ESTILO.md` **hereda esta base entera** y solo sobrescribe
cuatro bloques, dejando el resto igual:

1. **El villano del curso** — el anti-patrón concreto del modelo (EAV para documental, Redis-como-base-primaria para clave-valor, grafo-para-dos-saltos, etc.) y su autopsia medida.
2. **El diccionario de traducción** — el par \[paradigma origen] ↔ \[modelo del curso], con su 📖 tabla y sus recuadros 🪞/🩻 instanciados.
3. **El vocabulario del dominio** — la tabla §4.3 con las entidades reales del proyecto del curso.
4. **El stack y sus fuentes oficiales** — versiones fijadas (§4.4 y §10.2) del curso.

Todo lo demás —principio rector, tono, español neutro, idioma del código,
callouts, plantilla de fase, reglas de ejercicios y checklist— se hereda sin
cambios para que los once cursos se lean como escritos por la misma mano.
