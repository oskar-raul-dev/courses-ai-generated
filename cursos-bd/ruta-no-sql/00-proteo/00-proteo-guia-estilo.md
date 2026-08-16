# ✍️ Guía de estilo, tono y convenciones — Proyecto Proteo

> Deriva de `GUIA-DE-ESTILO-Y-CONVENCIONES.md` (curso legacy), adaptada al
> modelo **documental** y al dominio de Proteo (marketplace multi-vertical +
> PIM). No se copia literal: se ajusta el villano, el diccionario de
> traducción y los recuadros propios del modelo. Ante conflicto con la
> semilla (`00-proteo-semilla.md`), gana la semilla.

> 🧭 **Regla de una línea que rige todo el código:** el **código en inglés**;
> todo lo demás —narrativa, comentarios, textos de interfaz— **en español**.
> Detalle completo en §4.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien decida, con números, si un
dominio va en documento o en tabla — y lo defienda.** No enseñamos MongoDB
"de moda" ni relacional "por costumbre". Enseñamos a aplicar el marco de 5
preguntas antes de modelar, a medir en vez de narrar, y a reconocer cuándo
la respuesta correcta es "no uses este motor acá". Si un párrafo no ayuda a
decidir, a modelar, a medir o a defender esa decisión, sobra.

El norte del curso es una sola promesa: **cada "vs" que aparece en el texto
pasó primero por `scripts/vs.ts`.** Ninguna afirmación de rendimiento vive
solo en la prosa.

---

## 2. Tono

Cálido, informal y directo — de colega senior a colega senior, con humor
cuando cae bien. El lector llega con años de instintos relacionales; el
tono los honra y los recalibra, nunca los ridiculiza.

- **Segunda persona, cercana, sin voseo.** Se usa **"tú"**, nunca "vos" ni
  sus conjugaciones ("mides", no "medís"; "prueba", no "probá"). Es una
  convención fija de toda la ruta, no una preferencia regional: "monta el
  laboratorio y corre el primer `vs.ts`", "si el `$lookup` te tienta,
  primero mide".
- **Humor seco permitido.** Un 😉, una broma sobre "veinte minutos
  depurando un `$jsonSchema` que aceptaba cualquier basura", un 🪦 para
  jubilar una tabla EAV cuando le toca. El humor desdramatiza la fricción
  de modelar, no rellena espacio.
- **Honesto sobre lo feo.** Cuando EAV es doloroso, se dice con gracia
  ("esto es lo que un equipo relacional hace cuando el negocio pide
  atributos flexibles y nadie quiere un `ALTER TABLE` por vertical") y se
  mide, no se caricaturiza: se le da a Postgres su mejor versión (JSONB
  incluido) antes de mostrar dónde cede.
- **Orientado a la duda real.** Anticipa "¿y esto por qué en documento y no
  en tabla?" y la responde con el marco de 5 preguntas aplicado al caso
  concreto de la fase, nunca en abstracto.
- **Cercanía sin condescendencia.** El lector es senior: no le expliques
  qué es un índice, una transacción o un plan de ejecución — **eso lo sabe
  de SQL**. Lo nuevo es cómo cambia (o no) en un motor documental, y dónde
  el instinto relacional traiciona.

> 🧠 **Matiz propio de Proteo (el eje del curso).** El lector no llega en
> blanco: llega con diez años de instintos relacionales. Dos micro-secciones
> recurrentes (§7.4) interpelan ese instinto de frente: 🪞 *"tu instinto SQL
> dice… y esta vez se equivoca"* y 🩻 *"esto sí funciona igual"*. Un tercer
> recuadro, propio de Proteo, cierra el círculo: ⚖️ *"y acá el instinto SQL
> tenía razón"* — porque el curso también admite, con la misma evidencia,
> las fases donde documento no gana (la lectura de blob por id en la Fase 3,
> el libro mayor de la Fase 12).

Evitar: promesas vacías ("vas a dominar Mongo"/"documento resuelve todo"),
motivación de coach, solemnidad de manual corporativo, y explicar lo obvio
para el perfil senior. El humor es condimento, no plato principal.

---

## 3. Idioma y forma (narrativa)

- **Español claro y técnico, sin voseo, para todo lo que no es código**
  (títulos, explicaciones, ejercicios, referencias). Segunda persona con
  "tú" de forma consistente en todo el curso.
- Los términos del stack se dejan en inglés cuando son el nombre real:
  *aggregation*, *pipeline*, *bucket pattern*, *computed pattern*,
  *sharding*, *replica set*, *change stream*, *facet*, *upsert*, *race
  condition*, *N+1*. No se traducen forzadamente ("agregación" sí se usa
  como narrativa genérica, pero `$lookup`, `$facet`, `findOneAndUpdate`
  quedan tal cual, con backticks).
- Markdown siempre.
- Encabezados con emoji **con moderación** — uno por sección de plantilla.
  Los subtítulos internos llevan emoji-tipo (§7) cuando aporta lectura
  rápida (🪞, 🩻, ⚰️, 📖, ⚖️).
- **Prosa antes que listas.** Se explica razonando en párrafos. Las listas
  se reservan para lo que de verdad es una lista (pasos, ítems paralelos).
- **Tablas solo para comparar, decidir o mapear.** El marco de 5 preguntas,
  "cuándo embeber vs referenciar", matrices de stack, y —muy importante en
  Proteo— **tablas de traducción SQL ↔ MQL ↔ N1QL/SQL++** (§7.4). Nunca para
  narrar.

---

## 4. Idioma del código fuente (código en inglés, curso en español)

Normativo para todo fragmento de código del curso: fase, incidente,
apéndice o ejercicio resuelto.

### 4.1 Regla general

| Capa | Idioma | Ejemplo |
|---|---|---|
| **Código fuente** (identificadores) | 🇬🇧 Inglés | `function decrementStock(sku, qty) {}`, `const isBackordered = false` |
| **Endpoints y rutas** | 🇬🇧 Inglés | `/products`, `/products/:id/reviews`, `/orders/:id` |
| **Constantes y enums internos** | 🇬🇧 Inglés | `category: 'electronics'`, `SET_LOADING`, `STOCK_LOW_THRESHOLD` |
| **Colecciones y campos de Mongo/Couchbase** | 🇬🇧 Inglés | `db.collection('products')`, `{ sku, warehouseId, expiryDate }` |
| **Tablas y columnas de Postgres (EAV y JSONB)** | 🇬🇧 Inglés | `product_attribute`, `attribute_value_text`, `products_jsonb.attrs` |
| **Nombres de archivo, módulo, servicio, script** | 🇬🇧 Inglés | `productService.ts`, `vs.ts`, `products.controller.ts` |
| **Comentarios de código** | 🇪🇸 Español | `// la precondición va en el filtro: si el stock ya bajó de 0, matchea 0 docs` |
| **Textos de interfaz (mensajes de error, logs de usuario)** | 🇪🇸 Español | `{ message: 'No hay stock suficiente en el almacén' }` |
| **Narrativa del curso** | 🇪🇸 Español | Todo el texto fuera de bloques de código |

> 📝 **Por qué esta regla.** El código de un backend real de e-commerce
> suele estar en inglés, con comentarios en el idioma del equipo. Escribir
> el pedagógico así deja al lector con el mismo vocabulario que va a
> encontrar en producción, y hace que el arnés (`vs.ts`), el backend y los
> tres motores nombren lo mismo de la misma forma.

### 4.2 Diccionario del dominio (mínimo — el completo va en un
    `DICCIONARIO-CODIGO.md` propio de Proteo si el curso lo requiere)

| Español (narrativa, UI) | Inglés (código) |
|---|---|
| producto | `product` |
| vertical / categoría | `vertical` / `category` |
| reseña | `review` |
| almacén | `warehouse` |
| variante (talle, color…) | `variant` |
| stock / existencias | `stock` |
| pedido | `order` |
| carrito | `cart` |
| ficha (de producto) | `product document` / `productDoc` |
| fecha de vencimiento | `expiryDate` |
| meses de garantía | `warrantyMonths` |
| unidad de mantenimiento de stock | `sku` |
| congelar (el pedido) | `freeze` / `snapshot` |
| decrementar / reponer stock | `decrementStock` / `restockItem` |
| bucket (de reseñas) | `reviewBucket` |
| faceta | `facet` |

### 4.3 Convenciones de nombrado

- **Funciones y variables:** `camelCase` en inglés — `getProductBySlug`,
  `isOutOfStock`, `createdAt`.
- **Constantes de configuración:** `SCREAMING_SNAKE_CASE` —
  `REVIEW_BUCKET_MAX_SIZE`, `CART_TTL_SECONDS`.
- **Endpoints REST:** sustantivo en plural, inglés — `/products`,
  `/products/:id/reviews`, `/carts/:id`.
- **Colecciones (Mongo/Couchbase):** sustantivo plural en inglés —
  `products`, `reviews`, `orders`.
- **Tablas (Postgres):** `snake_case` en inglés — `products`,
  `product_attribute`, `warehouse_stock`.
- **Valores de enum/status:** inglés, `snake_case` si son compuestos —
  `in_stock`, `out_of_stock`, `pending_payment` (nunca `en_stock`).
- **Capas del backend:** `<dominio>.<capa>.ts` — `products.routes.ts` →
  `products.controller.ts` → `products.service.ts`; el arnés vive en
  `scripts/vs.ts` con sus duelos en `scripts/duels/*.ts`.

### 4.4 Lo que nunca cambia

- **Comentarios de código:** 100% español, explicando el porqué.
- **Textos de interfaz y mensajes de error legibles:** 100% español — la
  **key** del objeto en inglés, el **valor** que ve la persona usuaria en
  español (mismo patrón que el curso legacy, §4 de esa guía).
- **Narrativa del curso:** 100% español, sin voseo.
- **Nombres propios del dominio en la narrativa:** "producto", "reseña",
  "almacén", "pedido" siguen siendo las palabras con que se *habla* del
  sistema, aunque el código diga `product`, `review`, `warehouse`, `order`.

### 4.5 El villano también se normaliza a inglés

Igual que el curso legacy fijó esta regla para su anti-patrón, Proteo la
hereda: la tabla EAV del villano (`product_attribute`, `attribute_value`,
`attribute_type`) se nombra en inglés. El olor del villano es
**estructural** (una fila por atributo, tipos perdidos en texto, una ficha
que exige una docena de joins), no de idioma. Un EAV bien nombrado en
inglés es igual de doloroso que uno en español — y así el ejercicio de
"detectar EAV" de la Fase 11 huele estructura, no vocabulario.

---

## 5. Orientación a la práctica

Cada concepto se ancla en el dominio de Proteo y en código que corre contra
los motores reales del stack.

- **Nada de teoría suelta.** Si se explica `$jsonSchema` con `oneOf`, se
  explica sobre las cuatro verticales del catálogo, no en abstracto. Si se
  explica el bucket pattern, es sobre reseñas de producto, no sobre un
  ejemplo genérico de "documentos grandes".
- **Código ejecutable y coherente.** Todo fragmento corre con las versiones
  fijadas en la semilla (Mongo 8.0, Couchbase 8, Postgres 18, Node 24,
  Express 5) y no contradice fases anteriores. Nada de pseudocódigo que "se
  entiende".
- **Código mínimo.** El fragmento más pequeño que muestra el punto, pero
  ejecutable de punta a punta.
- **Comentarios que explican el porqué, no el qué, siempre en español.**
  `// el candado vive en el filtro: si qty ya bajó de 0, no matchea` sí;
  `// incrementa i` no.
- **Distinguir capas.** Siempre queda claro si un comportamiento vive en la
  ruta, el controller, el service, o en el motor mismo (`$jsonSchema`,
  índice, trigger). Es la distinción que salva a quien depura.

---

## 6. Manejo del villano (EAV) y de los rivales

- **No modernizar el EAV a mitad de curso.** Se construye con la mejor
  intención posible de un equipo relacional serio (tipos separados por
  columna, índices sobre `attribute_id`), no como hombre de paja. Se
  moderniza recién en la Fase 11, con números, no antes.
- **A Postgres se le dan sus dos mejores armas.** EAV bien hecho y JSONB
  con GIN. El curso no compara Mongo contra un Postgres deliberadamente
  débil.
- **A Couchbase se le da su arquitectura real.** Memoria-first, N1QL/SQL++
  idiomático — no se lo trata como "Mongo con otro nombre".
- **El idioma del código (§4) no es negociable ni en el villano.** Ver §4.5.

---

## 7. Marcadores y callouts (vocabulario visual del curso)

### 7.1 Marcadores de estado

- 💸 **Deuda técnica intencional.** Todo shortcut que se deja a propósito y
  se paga después. Ejemplo vivo: el carrito vive primero solo en Mongo
  (Fase 3) y se migra a Redis recién en la Fase 9, cuando el curso puede
  explicar por qué.
- 🔥 **Opcional / ampliación.** Ejercicios o secciones fuera del alcance
  base (ver `PROTEO-ALCANCE.md`).
- ⭐ **Fase o pieza central.** Fases 1, 3, 7 y 11 son las columnas
  vertebrales del "vs".
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** Fácil / intermedio / difícil / muy
  difícil.

### 7.2 Callouts en blockquote (emoji-tipo)

- 📝 **Nota de época.** Contexto de por qué existe un patrón (ej.: "EAV
  nació en los 2000 para simular columnas dinámicas antes de que JSONB
  existiera en Postgres").
- 📚 **Referencia rápida inline.** Un enlace justo donde surge la duda.
- 🪦 **Retiro.** Cuando un patrón cumple su función y se abandona (ej.:
  "🪦 se jubila la tabla EAV una vez medida su autopsia").
- ⚠️ **Advertencia.** Algo que rompe si se ignora (Couchbase ≠ CouchDB, el
  `replica set` de un nodo necesario para Change Streams, el techo de 16 MB).
- 💡 **Truco o atajo** que ahorra tiempo real.

### 7.3 Secciones narrativas recurrentes

- **💸 Pago de deuda.** Dónde se salda una deuda declarada antes.
- **Detalles con intención.** Lista corta de decisiones deliberadas de un
  bloque de código.
- **El patrón a memorizar.** Una o dos frases con la lección transferible.
- **Prueba de fuego.** Verificación manual incrustada en el flujo: "corre
  `vs.ts read-product`, compará p50 entre los tres motores."
- **Mini-repaso.** Repaso exprés en tabla cuando la fase usa sintaxis nueva
  (aggregation, N1QL) para alguien que viene de SQL puro.
- **La señal de que quedó bien.** Cierre en forma de cita: "si mañana
  aparece la vertical 'hogar y jardín', no tocás una sola migración."

### 7.4 Secciones propias de Proteo (SQL → documento)

- **📖 Tabla de traducción SQL ↔ MQL ↔ N1QL/SQL++.** Lado a lado, la
  consulta relacional y su equivalente en los dos motores documentales.
  Ej.: `SELECT * FROM products WHERE category='electronics'` ↔
  `db.products.find({ category: 'electronics' })` ↔
  `SELECT * FROM products WHERE category = 'electronics'` (N1QL). Es tabla
  (§3), no prosa.
- **🪞 "Tu instinto SQL dice… y esta vez se equivoca."** Nombra la trampa
  antes de caer: "embebé todo" como normalización invertida, una
  transacción multi-documento como moneda corriente, el `_id` como
  autoincremental.
- **🩻 "Esto sí funciona igual."** Índices, selectividad, `explain()`, el
  N+1 siguen valiendo lo mismo. Baja la ansiedad del lector.
- **⚖️ "Y acá el instinto SQL tenía razón."** Propio de Proteo: las fases
  donde el veredicto es honesto en la otra dirección — la lectura de blob
  por id (Fase 3, JSONB empata) y el libro mayor (Fase 12, relacional
  gana). Sin este recuadro, el curso sonaría a folleto de Mongo.
- **⚰️ Caso de estudio: el villano (EAV).** Se construye, se mide, duele,
  se convierte. Es el hilo que cose las fases 1 y 11.

---

## 8. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden
(idéntica estructura a la del curso legacy, para consistencia de toda la
ruta):

1. **🎯 Propósito** — qué resuelve esta fase; puede abrir retomando la
   fricción heredada de la fase anterior.
2. **✅ Qué queda listo al terminar** — checklist verificable.
3. **🚫 Qué queda fuera por ahora** — qué se difiere y a qué fase.
4. **🧠 Conceptos mínimos** — solo lo necesario, anclado al dominio. Aquí
   viven el mini-repaso, las notas de época, la 📖 tabla de traducción y los
   recuadros 🪞/🩻/⚖️.
5. **💻 Implementación y código comentado** — el grueso; código ejecutable
   con comentarios de porqué, identificadores en inglés (§4). Aquí caben
   **Detalles con intención**, **El patrón a memorizar**, **Prueba de
   fuego** y **💸 Pago de deuda**.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente y cómo
   depurarlo (incluye lectura de `explain()` en los tres motores cuando
   aplica).
7. **🧪 Ejercicios progresivos** — 20 a 40, graduados (§9).
8. **📚 Referencias** — al cierre de la fase, formato §10.
9. **🚀 Cierre y conexión con la siguiente fase** — qué sigue y por qué.
   Aquí va **La señal de que quedó bien**.

Los apéndices no siguen esta plantilla: usan índice de salto rápido +
secciones cortas + tabla "cuándo usar qué" + 5-10 ejercicios cortos.

---

## 9. Ejercicios

- **Cantidad: 20 a 40 por fase**, con la guía de distribución de la semilla
  para ~30: ~8 🟢, ~9 🟡, ~7 🟠, ~4-6 🔴, más 🔥 aparte.
- **Distribución equilibrada por nivel**, sin agrupar toda la dificultad
  al final: cada bloque de nivel tiene coherencia interna.
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

  El título lleva el conteo total: `## 🧪 Ejercicios (30)`.
- **Progresión real.** Los 🟢 calientan (una query, un `$inc`, un `$facet`
  simple). Los 🔴 exigen integrar varias fases o depurar algo esquivo: medir
  un `explain()` a tres motores, reproducir una sobreventa bajo
  concurrencia, convertir una porción de EAV midiendo antes/después.
- **Accionables y verificables.** "Hacé que el SKU `ELEC-0192` no pueda
  venderse por debajo de cero bajo dos decrementos simultáneos" — no
  "reflexioná sobre concurrencia en inventario".
- **Algunos de diagnóstico.** Al menos un puñado por fase entrega un bug (un
  `$jsonSchema` que acepta basura, un índice que `explain()` no usa, un
  decremento que vende de más) y pide reproducir y localizar, no solo
  construir.
- **Enganchados al dominio.** Productos, verticales, reseñas, inventario,
  pedidos, facetas — no ejemplos abstractos de "colección A" y "colección B".
- **Cuando un ejercicio nombra código, usa el identificador en inglés
  vigente** ("agregá el `findOneAndUpdate` con precondición a
  `decrementStock`"), aunque el enunciado esté en español, sin voseo.
- Los 🔥 son opcionales, sin numeración continua, listados aparte.

En apéndices bastan 5-10 ejercicios cortos de consulta.

---

## 10. Bibliografía y referencias

**Regla:** documentación oficial de la versión fijada en el stack
**primero**; luego libros; luego blogs, videos y tutoriales. Siempre se
advierte cuando un enlace apunta a una versión distinta de la fijada.

### 10.1 Formato

Cada fase cierra su sección 8 (📚 Referencias) con:

- **URLs completas y clicables**, no solo el dominio.
- **Secciones separadas**: Documentación oficial (con URL completa y nota
  de versión), Libros cuando apliquen, Video/apoyo, y **Orden de lectura
  sugerido** (una línea que encadena qué leer primero para esa fase
  específica).
- Toda referencia respeta la advertencia de `00-proteo-semilla.md`: **no se
  inventan** números de página, DOIs ni IDs de video; si un enlace no
  resuelve al redactar, se busca el equivalente vigente y se marca la
  versión.

### 10.2 Fuentes oficiales base (usar URL completa al citar; ver también la
    lista completa en la semilla)

- **MongoDB 8.0:** https://www.mongodb.com/docs/v8.0/
- **PostgreSQL 18 (JSON/JSONB, GIN):** https://www.postgresql.org/docs/18/datatype-json.html
- **Couchbase Server 8.0 / N1QL:** https://docs.couchbase.com/server/current/
- **Express 5:** https://expressjs.com/en/5x/api.html
- **Zod:** https://zod.dev
- **Redis/Valkey (TTL):** https://redis.io/docs/latest/ · https://valkey.io/docs/
- **Meilisearch:** https://www.meilisearch.com/docs
- **MDN** (JS base): https://developer.mozilla.org

### 10.3 Advertencias

- **No usar en el código principal:** MongoDB < 8.0, driver `mongodb` de
  serie anterior a la actual, Express 4, Mongoose salvo mención explícita
  (el curso usa driver nativo primero, igual que el legacy con Express
  crudo). Alternativas más nuevas o más viejas aparecen solo como
  comparación o en 🔥 opcional.
- **Sobre citas:** cuando se mencione un artículo, libro, video o post
  específico, se advierte que URLs y títulos pueden estar desactualizados;
  el lector debe verificarlos.

---

## 11. Sobre el dominio (ficticio, sin NDA)

Proteo es un marketplace **enteramente ficticio**: no hay confidencialidad
que preservar ni sistema real que disfrazar. Esto simplifica dos cosas:

- Los ejemplos pueden ser todo lo concretos que convenga (verticales,
  atributos, montos) sin "generalizar ante la duda".
- El vocabulario del dominio (producto, vertical, reseña, almacén, pedido)
  es estable y se fija en §4.2; no compite con ningún vocabulario "real"
  que haya que evitar.

La regla de idioma del código (§4) es una convención de calidad y de
realismo, igual que en el curso legacy — no una cuestión de NDA.

---

## 12. Coherencia entre documentos

- **No contradecir fases anteriores.** El `$jsonSchema` de la Fase 2 no
  puede devolver una forma de producto distinta de la que la Fase 3 sirve
  como ficha; el snapshot de la Fase 6 no puede omitir un campo que la Fase
  3 sí expone.
- **No reescribir decisiones aprobadas** sin señalar explícitamente la
  incompatibilidad y por qué.
- **Fuentes de verdad, en orden:** (1) instrucciones del proyecto, (2)
  `RUTA-NOSQL.md` (lista maestra), (3) `RUTA-NOSQL-FUNDAMENTOS.md`, (4)
  `00-proteo-semilla.md`, (5) `PROTEO-ALCANCE.md`, (6) entregables
  aprobados de fases anteriores, (7) decisiones explícitas del chat actual.
- Nombres de archivos, colecciones, tablas y campos se mantienen estables
  entre fases (en inglés, §4.3). Si algo se renombra, se documenta el
  cambio y se propaga a `INSTINTOS.md`/`BENCHMARKS.md` si corresponde.

---

## 13. Post-mortems e incidentes

Cada incidente sigue esta estructura de ocho puntos:

1. Síntoma.
2. Pasos de reproducción.
3. Evidencia observable (`explain()` en el motor correspondiente, logs,
   salida de `vs.ts`).
4. Causa raíz.
5. Corrección.
6. Prueba de regresión.
7. Prevención.
8. Post-mortem **sin culpabilización** (blameless): se analiza el sistema y
   el proceso, no a la persona.

El tono del post-mortem es sereno y analítico. El humor cálido del resto
del curso baja un punto aquí: un post-mortem es serio, aunque no acartonado.

---

## 14. Checklist rápido antes de dar por cerrado un `.md`

- [ ] Sigue la plantilla de 9 secciones (o el formato de apéndice).
- [ ] Tono cálido e informal, segunda persona con "tú" (**sin voseo**),
      humor con moderación.
- [ ] Todo el código corre con las versiones fijadas del stack (semilla).
- [ ] **Identificadores, endpoints, colecciones/tablas, campos, constantes
      y enums del código en inglés (§4).**
- [ ] **Comentarios de código y textos de interfaz en español (§4.4).**
- [ ] No contradice ninguna fase anterior ni el `PROTEO-ALCANCE.md`.
- [ ] Distingue capas (ruta / controller / service / motor) donde importa.
- [ ] Usa el vocabulario de callouts (📝 🪦 📚 ⚠️ 💡) y los recuadros propios
      del modelo (📖 🪞 🩻 ⚖️ ⚰️) donde aporten.
- [ ] Marca 💸 la deuda técnica (y la paga si corresponde) y 🔥 lo opcional.
- [ ] Tiene 20-40 ejercicios numerados con rangos 🟢🟡🟠🔴 equilibrados (o
      5-10 en apéndices).
- [ ] Todo "vs" citado en prosa tiene su fila correspondiente en
      `BENCHMARKS.md`; ninguna afirmación de rendimiento vive solo en texto.
- [ ] Referencias **al final del capítulo/fase**, con URL completa,
      secciones (oficial / libros / video / orden de lectura), advertencia
      de versión, y sin IDs ni DOIs inventados.
- [ ] Explica el *porqué* de cada decisión de modelado relevante.
- [ ] Incluye "La señal de que quedó bien" en el cierre.
