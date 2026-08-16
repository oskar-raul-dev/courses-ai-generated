# ✍️ Guía de estilo, tono y convenciones
## Paquete Mini Jira — Curso 01 (Vue 2 legacy) + Curso 02 (MongoDB/Express)

Esta guía es la **fuente de verdad editorial de todo el directorio**
`vue2-legacy-for-backend-devs/`. Cualquier chat que produzca o edite un `.md`
de este paquete la sigue, sin importar a qué curso pertenezca el archivo.

Su objetivo es simple: que los ~50 documentos de los dos cursos se lean como
escritos por la misma mano, con la misma voz y el mismo criterio, y que todos
apunten al mismo lugar — **mantener un sistema real sin romperlo**.

Los dos cursos comparten un único dominio pedagógico —**Mini Jira**, una mesa
de soporte interna— y por eso comparten esta guía, un único diccionario de
código y un único contrato de API:

- **Curso 01 — `01-vue2-legacy/`** construye el frontend heredado (Vue 2,
  época 2018–2021) sobre un mock, y luego lo enfrenta a un framework encima
  (Quasar, Vuetify o Nuxt) en tres rutas opcionales.
- **Curso 02 — `02-complement-mongodb-backend/`** construye el backend real
  (MongoDB 4.4 + Express/Node 14) que reemplaza al mock **sin que el frontend
  se entere**.

> 🧭 **La regla de una línea que rige todo el código:** el **código en inglés**;
> todo lo demás —narrativa, comentarios, textos de interfaz— **en español
> latinoamericano con tuteo**. El detalle completo está en §5.

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien
que mañana tiene que arreglar un bug en producción con el jefe mirando por
encima del hombro.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien arregle un sistema real sin
romperlo.**

No enseñamos Vue "bonito" ni MongoDB "de moda". No formamos arquitectos de
frontend ni evangelistas de NoSQL. Formamos capacidad de leer código ajeno y
viejo, reproducir un bug desde un ticket vago, depurar un bundle minificado o
un `explain()` que no cuadra, y aplicar un fix que no rompa otras tres cosas.

El filtro para cada párrafo es este: **¿esto ayuda a diagnosticar, depurar,
corregir o prevenir?** Si no, sobra. Aunque esté muy bien escrito. Sobre todo
si está muy bien escrito.

### La señal de éxito compartida

Los dos cursos apuntan a una sola frase verificable:

> **Se cambia el `baseURL` del frontend y la aplicación no se entera.**

El Curso 01 deja el frontend viviendo de un mock (json-server en `:3000`); el
Curso 02 lo reemplaza por un backend real que honra el mismo contrato. Todo lo
que escribimos sirve a esa promesa, y el documento que la hace exigible es
`02-complement-mongodb-backend/00-audit-contrato.md`.

---

## 2. Tono

El tono es **semiformal, cálido y directo**, con humor cuando cae bien. Piensa
en un colega senior que ya sufrió este código y te lo explica con confianza,
sin solemnidad de manual corporativo, pero también sin palmaditas en la
espalda.

Cómo se ve eso en la práctica:

- **Tuteo latinoamericano, siempre.** Le hablas al lector de "tú": *"apaga el
  mock y verás el error real"*, *"si el `$lookup` te tienta, primero mide"*.
  **Nada de voseo** (*"agregá"*, *"fijate"*, *"tenés"*, *"sabés"*, *"vos"*),
  nada de vosotros (*"acordáis"*, *"mirad"*), nada de "usted", y nada de
  impersonal permanente ("se debe configurar…") que enfría el texto. Esta
  regla es dura: ver §4.6 y la lista de sustituciones de §4.7.
- **Español latinoamericano neutro.** Sin regionalismos de España
  (*"ordenador"*, *"vale"*, *"chulo"*) ni de un solo país de América
  (*"chido"*, *"bacán"*, *"platita"*). Si una palabra necesita nota al pie
  para entenderse fuera de tu ciudad, no va.
- **Semiformal.** Cercano, pero no chat de WhatsApp. Frases completas,
  puntuación correcta, cero abreviaturas de mensajería. Un "che" no, un "ojo
  con esto" sí.
- **Humor seco y con moderación.** Un 😉 bien puesto, un chiste sobre las
  veinte horas que perdiste depurando el frontend cuando lo que estaba caído
  era el mock. El humor sirve para desdramatizar la fricción del legacy, no
  para rellenar. Regla práctica: **máximo un chiste por sección**, y si no
  fluye solo, se borra.
- **Honesto sobre lo feo.** En legacy hay patrones horribles y se dicen
  horribles: *"esto es un componente de 600 líneas con lógica de negocio
  adentro; es feo, está en producción y así lo vas a encontrar"*. No fingimos
  elegancia donde no la hay. El Curso 02 lleva esto a un caso central: la base
  `soporte_v1` es fea a propósito y se la nombra sin piedad.
- **Cálido sin condescendencia.** El lector es un dev senior de backend.
  Cálido significa acompañarlo en la fricción, no explicarle qué es HTTP,
  JSON, un token o una petición asíncrona. En el Curso 02, tampoco qué es un
  índice, una transacción o el plan de una consulta: **eso lo sabe de SQL**.
  Lo nuevo es cómo cambia (o no) en Mongo.
- **Orientado a la duda real.** Anticipa el *"¿y esto por qué está así?"* y
  respóndelo, muchas veces con una 📝 **Nota de época** que dé el contexto
  histórico. En 2019 esa decisión tenía sentido; explicarlo evita que el
  estudiante juzgue en vez de entender.

Lo que evitamos: promesas vacías ("vas a dominar Vue", "Mongo lo resuelve
todo"), motivación de coach, solemnidad de manual, y explicar lo obvio para el
perfil.

> 🧠 **Matiz propio del Curso 02 (su eje pedagógico).** El lector no llega en
> blanco: llega con diez años de instintos relacionales. El tono reconoce esos
> instintos y los interpela de frente con dos micro-secciones recurrentes
> (§8.4): 🪞 *"tu instinto SQL dice… y esta vez se equivoca"* y 🩻 *"esto sí
> funciona igual"*. **Nunca se ridiculiza el instinto SQL:** se lo honra y se
> lo recalibra.

---

## 3. Idioma y forma de la narrativa

- **Español latinoamericano neutro**, técnico y claro, para todo lo que no es
  código: títulos, explicaciones, ejercicios, referencias, callouts.
- **Los términos del stack se quedan en inglés** cuando son el nombre real de
  la cosa: *store*, *mutation*, *action*, *getter*, *computed*, *watcher*,
  *mixin*, *slot*, *boot file*, *hidratación*, *bundle*, *source map*,
  *pipeline*, *aggregation*, *replica set*, *index*, *sharding*, *upsert*,
  *race condition*, *memory leak*, *N+1*. Traducirlos forzadamente
  ("mutación", "tubería") confunde más de lo que aclara y no es lo que van a
  leer en el código.
- **Markdown siempre.** Nada de HTML embebido salvo que no haya alternativa.
- **Prosa antes que listas.** Se prefiere razonar en párrafos: un párrafo que
  explica *por qué* vale más que cinco viñetas que enumeran *qué*. Las listas
  se usan cuando la cosa es de verdad una lista — pasos secuenciales, ítems
  paralelos, opciones.
- **Listas antes que tablas en comparativas extensas.** Cuando compares tres
  frameworks, cuatro estrategias de modelado o cinco entornos, **usa una lista
  con subtítulos**, no una tabla ancha. Una tabla de siete columnas se lee mal
  en pantalla, se lee peor en móvil y no deja espacio para explicar el porqué
  de cada celda. La lista sí.

  Formato recomendado para comparativas:

  ```markdown
  **Opción A — Embeber los comentarios en el ticket**

  Qué es: los comentarios viven como array dentro del documento del ticket.
  Cuándo conviene: cuando siempre se leen junto al ticket y son pocos.
  El costo: el documento crece sin techo y el ticket caliente se vuelve pesado.
  Veredicto: es la que recomendamos por defecto en Mini Jira.
  ```

- **Tablas solo para lo que de verdad es tabular y corto.** Versiones fijadas,
  mapeo estado → etiqueta, matriz de dificultad de ejercicios, tres columnas
  como máximo. Y —muy importante en el Curso 02— **tablas de traducción
  SQL ↔ Mongo** (§8.4), que son tabulares por naturaleza. Si necesitas
  explicar una celda, ya no es una tabla: es una lista.
- **Encabezados con emoji, con moderación.** Uno por sección de la plantilla.
  Los subtítulos internos pueden llevar emoji-tipo (§8) cuando ayudan a la
  lectura rápida. Un documento que parece un teclado de emojis pierde
  autoridad.

---

## 4. Pedagogía: cómo se explica

Esta sección es la que más define el paquete. El estudiante es senior en
backend pero novato en este stack. La explicación tiene que ser rápida sin ser
hueca.

### 4.1 La regla del andamio

Todo concepto nuevo se presenta en tres tiempos, en este orden:

1. **El problema primero.** Antes de nombrar la herramienta, muestra el dolor
   que resuelve. *"Tienes cuatro componentes que necesitan saber si el usuario
   está autenticado. Puedes pasarlo por props en cadena y sufrir, o puedes…"*
2. **La herramienta después.** Ahora sí, el nombre y la definición mínima.
   Definición mínima significa: lo justo para usarla hoy, no el capítulo
   completo de la documentación.
3. **El código que corre.** El fragmento más pequeño que demuestra el punto,
   con comentarios que explican el porqué.

Presentar la herramienta antes que el problema produce estudiantes que saben
escribir una action de Vuex pero no saben cuándo hace falta, o que meten un
`$lookup` porque "Mongo también tiene JOIN".

### 4.2 Analogías con backend y con SQL, sin abusar

El estudiante viene de backend, y muchas veces de años de SQL.
Aprovéchalo: un interceptor de axios es primo de un filtro o middleware; un
guard de router es un check de autorización antes del handler; el store es un
estado en memoria compartido con transiciones controladas; el aggregation
pipeline es tu `GROUP BY` con pasos nombrados.

Dos límites: la analogía se usa **una vez, para abrir la puerta**, y después
se abandona; y **se dice explícitamente dónde se rompe**: *"hasta acá el
paralelo funciona; la diferencia es que el guard corre en el navegador y el
usuario puede saltárselo, así que no es seguridad, es experiencia de
usuario"*. Una analogía que no se cierra genera bugs conceptuales que
aparecen tres fases después.

### 4.3 Explica el porqué, no solo el cómo

Un paso sin justificación es un paso que el estudiante no puede adaptar cuando
el sistema real difiera del ejemplo. Cada decisión relevante lleva su porqué,
aunque sea media línea entre paréntesis.

Y cuando el porqué es histórico y no técnico —que en legacy pasa seguido—, se
dice también: *"esto está así porque en 2019 era la única forma; hoy hay tres
mejores y ninguna te sirve porque no vas a migrar"*.

### 4.4 Densidad calibrada

- Un concepto nuevo por vez. Si un bloque de código introduce tres cosas
  desconocidas, se parte en tres bloques.
- Repetir lo importante está bien. Los conceptos que sostienen el paquete
  —flujo de datos, dónde vive el estado, qué corre en el navegador y qué en el
  servidor, qué garantiza el documento y qué no— pueden reaparecer varias
  veces con otras palabras. La repetición espaciada funciona; la enciclopedia
  no.
- Ninguna sección teórica supera las dos pantallas sin que aparezca código.

### 4.5 Cierra los bucles

Si abres un paréntesis pedagógico —*"esto lo vemos en la Fase 7"*, *"acá
dejamos deuda 💸"*— tiene que cerrarse en algún documento del paquete. Un
pendiente que nunca se resuelve es ruido, y el lector deja de confiar en las
promesas del texto.

Los bucles pueden cruzar cursos: una deuda declarada en el Curso 01 ("el
cliente emite el evento de socket, cosa que debería hacer el servidor 💸") se
paga en el Curso 02, y el pago se nombra citando la fase de origen.

### 4.6 🧨 Tuteo: la regla de forma más incumplida

El voseo se cuela solo, sobre todo en imperativos y en el tono coloquial de
las fases más informales. Es el defecto de estilo número uno de este paquete,
así que se revisa **explícitamente** antes de cerrar cualquier `.md`.

Qué cuenta como voseo (y no va):

- **Imperativos acentuados en la última sílaba:** *agregá, mirá, abrí, buscá,
  escribí, dejá, borrá, seguí, probá, usá, contá, listá, identificá, explicá,
  verificá, reiniciá, cloná, copiá, marcá, elegí, poné, hacé, decí, vení*.
- **Presentes de segunda persona con tilde final:** *tenés, podés, sabés,
  querés, hacés, decís, usás, mirás, escribís, pasás, armás, agregás, notás,
  clonás, migrás, trabajás, enchufás, copiás, borrás, sacás, cambiás*.
- **Participios y formas de "distinguir/entender/reconocer/leer":**
  *distinguís, entendés, reconocés, leés*.
- **Pronombre `vos`** y sus combinaciones (*para vos*, *vos venís*).
- **Enclíticos voseantes:** *reconocelo, traducilo, confirmalo, sabelo,
  fijate, acordate, ponele*.
- **Y su primo de España, el vosotros:** *acordáis, mirad, tenéis*.

La sustitución es mecánica y está tabulada en §4.7. Lo que **no** es mecánico
—y hay que revisar a mano— son dos trampas:

- **Homógrafos legítimos.** *"Yo medí el tiempo"*, *"escribí el informe
  ayer"*, *"leí la doc"* son pretéritos de primera persona, correctos en
  tuteo. Solo son voseo cuando son **órdenes al lector**. Lee la frase
  completa antes de tocarla.
- **El imperfecto no es voseo.** *"venía", "escribías", "tenías", "pedía"* son
  correctos y aparecen mucho en este paquete al narrar el sistema heredado.
  Déjalos.

### 4.7 Tabla de sustitución rápida (voseo → tuteo)

| Voseo (prohibido) | Tuteo (correcto) |
|---|---|
| `agregá` / `agregás` | `agrega` / `agregas` |
| `mirá` / `mirás` | `mira` / `miras` |
| `abrí` (orden) | `abre` |
| `buscá` / `buscás` | `busca` / `buscas` |
| `escribí` (orden) / `escribís` | `escribe` / `escribes` |
| `tenés` / `podés` / `sabés` / `querés` | `tienes` / `puedes` / `sabes` / `quieres` |
| `hacé` / `hacés` | `haz` / `haces` |
| `poné` / `ponés` | `pon` / `pones` |
| `decí` / `decís` | `di` / `dices` |
| `usá` / `usás` | `usa` / `usas` |
| `dejá` / `dejás` | `deja` / `dejas` |
| `seguí` (orden) | `sigue` |
| `probá` / `probás` | `prueba` / `pruebas` |
| `elegí` (orden) | `elige` |
| `distinguís` / `entendés` / `reconocés` / `leés` | `distingues` / `entiendes` / `reconoces` / `lees` |
| `vení` / `venís` | `ven` / `vienes` |
| `fijate` / `acordate` | `fíjate` / `acuérdate` |
| `reconocelo` / `traducilo` / `confirmalo` / `sabelo` | `reconócelo` / `tradúcelo` / `confírmalo` / `sábelo` |
| `vos` | `tú` (o se reformula) |
| `acordáis` / `tenéis` (vosotros) | `lo acuerdan` / `tienen` — o `lo acuerdas con el backend` |

> 💡 **Truco de revisión.** Antes de cerrar un `.md`, un `grep -nE` con las
> formas de la columna izquierda sobre el archivo entero encuentra el 95% de
> los casos en dos segundos. El 5% restante son los homógrafos de §4.6, que se
> leen a mano.

---

## 5. Idioma del código fuente

> **Regla normativa y no negociable: todo el código fuente del paquete se
> escribe en inglés —variables, funciones, componentes, archivos, endpoints,
> constantes, enums, colecciones, campos, clases CSS propias— y todos los
> comentarios se escriben en español.** Aplica a cada fragmento de código de
> los dos cursos, sin excepción: fases, apéndices, rutas, incidentes,
> ejercicios resueltos, tests, `db.json`, `docker-compose.yml` y scripts.
> No hay código legacy "demasiado feo" ni ejemplo "demasiado rápido" que quede
> fuera de esta regla.

El sistema real lo mantiene un equipo técnico y su código está en inglés. Si
el tutorial usara `crearTicket` y `servicioTickets`, el vocabulario que el
estudiante practica durante semanas no sería el que va a leer en producción.
Y hay una razón extra en este paquete: **los dos cursos tienen que nombrar lo
mismo de la misma forma.** `ticket` es `ticket` en Vue, en Express y en Mongo.

La contraparte importa igual: **los comentarios van siempre en español**,
porque son el canal donde se explica el *porqué* de un patrón raro, y ese
razonamiento tiene que leerse en el idioma en que se piensa el curso. Un
comentario en inglés en este paquete es un error de estilo, aunque el código
que acompañe esté impecable.

### 5.1 Regla general

| Capa | Idioma | Ejemplo |
|---|---|---|
| Identificadores de código | 🇬🇧 Inglés | `function takeTicket(id) {}`, `const isLoading = false` |
| Endpoints y rutas | 🇬🇧 Inglés | `/tickets`, `/tickets/:id/comments`, `/auth/login` |
| Constantes y enums | 🇬🇧 Inglés | `status: 'open'`, `SET_LOADING`, `POLLING_INTERVAL_MS` |
| Colecciones y campos de Mongo | 🇬🇧 Inglés | `db.collection('tickets')`, `{ assignee, reporter, createdAt }` |
| Archivos, componentes, módulos, servicios | 🇬🇧 Inglés | `TicketForm.vue`, `ticketsModule`, `tickets.service.js` |
| Clases CSS propias y `data-testid` | 🇬🇧 Inglés | `.ticket-card`, `data-testid="ticket-row"` |
| Comentarios de código | 🇪🇸 Español | `// el ticket nace 'open': regla de negocio, no del form` |
| Textos de interfaz (UI) | 🇪🇸 Español | `<button>Tomar ticket</button>`, `"Cargando tickets…"` |
| Narrativa del tutorial | 🇪🇸 Español | Todo el texto fuera de bloques de código |

**La app pedagógica no tiene i18n.** Es una app en español para usuarios de
habla hispana; por eso los textos que ve la persona usuaria —labels, botones,
mensajes de alerta, placeholders, `alt`, `title` de tooltips— se escriben
como literales en español, no como claves de traducción.

### 5.2 Qué se traduce y qué no (criterio rápido)

| Elemento | ¿Inglés? | Ejemplo |
|---|---|---|
| Nombre de función, variable, constante | ✅ Sí | `function getTickets()` |
| `data()`, props, computed de un componente | ✅ Sí | `this.form.assignee`, `<ticket-form :initial-ticket="…" />` |
| Endpoints (servicios y rutas de Express) | ✅ Sí | `apiClient.get('/tickets')`, `router.patch('/tickets/:id')` |
| Módulos Vuex, mutations, actions, getters | ✅ Sí | `SET_TICKETS`, `fetchTickets`, `currentUser` |
| Colecciones, campos y valores de enum de Mongo | ✅ Sí | `collection('comments')`, `status: 'in_progress'` |
| Nombres de componente / archivo / capa | ✅ Sí | `TicketsTable.vue`, `tickets.controller.js` |
| Clases CSS/Sass propias | ✅ Sí | `.ticket-card`, no `.tarjeta-ticket` |
| `data-testid` | ✅ Sí | `data-testid="ticket-row"` |
| Comentarios `//`, `/* */`, `<!-- -->` | ❌ No | `// valida antes de confiar en res.data` |
| Strings de interfaz | ❌ No | `"Tomar ticket"`, `"No hay tickets todavía…"` |
| Mensajes de error legibles | ❌ No | key en inglés, valor en español |
| Vocabulario del dominio en la narrativa | ❌ No | el texto habla de "ticket", "agente", "reportador" |

> ⚠️ **Caso mixto frecuente — errores y etiquetas de estado.** El objeto usa
> keys en inglés y el **valor** que ve el usuario va en español:
> `{ message: 'El servidor no respondió a tiempo', type: 'timeout' }`. Igual
> con el mapeo de estado a etiqueta: la **clave** es el enum que viaja por la
> API y vive en Mongo; el `label` es UI y va en español.
>
> ```js
> // components/tickets/statusMeta.js  (Curso 01)
> export const STATUS_META = {
>   open:        { label: 'Abierto',     css: 'badge-danger' },
>   in_progress: { label: 'En progreso', css: 'badge-warning' },
>   resolved:    { label: 'Resuelto',    css: 'badge-success' },
>   closed:      { label: 'Cerrado',     css: 'badge-secondary' }
> };
> ```
>
> **Nunca** guardes `'Abierto'` como valor de `status` en la base o en el
> payload.

### 5.3 Diccionario mínimo del dominio (Mini Jira)

El diccionario completo —entidades, estados, roles, campos, verbos de negocio,
jerga de Vue y jerga de Mongo/Express— vive en
`02-complement-mongodb-backend/prompts/diccionario-codigo.md`. Referencia
mínima:

- ticket → `ticket`
- comentario → `comment`
- usuario → `user`
- adjunto → `attachment`
- agente / reportador → `agent` / `reporter` (roles)
- asignado a → `assignee` · reportado por → `reporter`
- estados: `open` → `in_progress` → `resolved` → `closed`
- prioridades: `low`, `medium`, `high`
- tomar (un ticket) → `take`
- asignar / resolver / cerrar / reabrir → `assign` / `resolve` / `close` / `reopen`
- actividad (timeline de las rutas) → `activity`
- métricas / estadísticas → `stats`

Los nombres de componentes, módulos, servicios, actions y controllers se arman
combinando estos términos con los verbos técnicos habituales: `get`, `fetch`,
`create`, `update`, `delete`, `take`, `assign`, `validate`.

### 5.4 Convenciones de nombrado

**Comunes a los dos cursos**

- **Funciones y variables:** `camelCase` en inglés — `takeTicket`,
  `isTicketOpen`, `createdAt`.
- **Constantes de configuración:** `SCREAMING_SNAKE_CASE` —
  `POLLING_INTERVAL_MS`, `MAX_UPLOAD_BYTES`.
- **Endpoints REST:** sustantivo plural en inglés — `/tickets`,
  `/tickets/:id/comments`, `/stats`.
- **Valores de enum:** inglés, `snake_case` si son compuestos —
  `in_progress` (no `inProgress` ni `en_progreso`).

**Curso 01 (Vue 2)**

- **Componentes:** `PascalCase` en inglés — `TicketsTable`, `TicketForm`,
  `TicketWizard`, `StatusBadge`. En template, kebab-case: `<ticket-form>`.
- **Archivos de componente:** mismo nombre que el componente, `.vue`.
- **Módulos Vuex:** `<dominio>Module`, namespaces cortos — `ticketsModule`,
  `'tickets'`, `'auth'`, `'ui'`, `'comments'`.
- **Mutations:** `SCREAMING_SNAKE_CASE` — `SET_TICKETS`, `UPSERT_TICKET`,
  `CLEAR_SESSION`.
- **Actions:** verbo + dominio, `camelCase` — `fetchTickets`, `createTicket`,
  `takeTicket`, `login`.
- **Getters:** sustantivo o `is/can` — `currentUser`, `openTickets`,
  `canTransition`.
- **Servicios:** `<dominio>Service` — `ticketService`, `authService`,
  `commentService`, `socketService`, `statsService`.

**Curso 02 (Mongo/Express)**

- **Colecciones:** sustantivo plural en inglés — `tickets`, `users`,
  `comments`, `attachments`.
- **Campos de documento:** `camelCase` en inglés — `title`, `status`,
  `priority`, `assignee`, `reporter`, `createdAt`, `updatedAt`,
  `schemaVersion`, `history`.
- **Capas del backend:** `<dominio>.<capa>.js` — `tickets.routes.js` →
  `tickets.controller.js` → `tickets.service.js`; helpers en `lib/`
  (`lib/serializers.js`, `lib/jwt.js`), `middleware/auth.js`, `realtime/io.js`.
- **Eventos de socket:** `recurso:acción` en inglés — `ticket:created`,
  `ticket:updated`, `ticket:deleted`. Cualquier otro se declara como
  extensión en `02-complement-mongodb-backend/00-audit-contrato.md`.
- **Índices:** el nombre autogenerado de Mongo o uno explícito en inglés —
  `status_1_createdAt_-1`.

### 5.5 Lo que nunca cambia

- **Comentarios de código:** 100% español, explicando el porqué.
- **Textos de interfaz:** 100% español.
- **Narrativa del tutorial:** 100% español latinoamericano con tuteo.
- **Vocabulario del dominio en la narrativa:** "ticket", "comentario",
  "agente", "reportador" siguen siendo las palabras con que **hablas** del
  sistema, aunque el código diga `ticket`, `comment`, `agent`, `reporter`.

### 5.6 Ajuste de documentos ya escritos

Cuando un `.md` entregado use identificadores en español o se le haya colado
voseo, se ajusta en este orden:

1. Aplicar el diccionario de código a cada bloque de código.
2. Verificar consistencia con lo ya ajustado **y entre cursos**: si el Curso
   01 llama a la action `takeTicket`, el Curso 02 expone la operación de forma
   coherente; no aparece `tomarTicket` en ningún lado.
3. Pasar la revisión de tuteo de §4.6/§4.7.
4. Dejar intactos comentarios, narrativa y textos de UI (más allá del tuteo).
5. Revisar ejercicios y referencias que citen nombres de código.

No se reescribe la explicación ni la pedagogía: es un cambio de forma, no de
contenido.

> ⚖️ **La excepción del villano — `soporte_v1` (Curso 02).** El anti-patrón
> `soporte_v1` de las fases 3, 5, 7 y 8 es una base "migrada a Mongo
> transcribiendo el esquema relacional tabla por tabla". **El villano también
> se nombra en inglés** —`statuses`, `priorities`, `statusId`, `assigneeId`—
> para no confundir dos problemas independientes: *"está en español"* y *"está
> mal diseñado"*. Un esquema en inglés puede ser igual de Postgres-disfrazado.
> El **olor** del villano se mantiene por sus decisiones, no por su idioma:
> lookup-tables de diez documentos con forma `{_id numérico, name}`, FKs
> enteras que nadie valida, siete colecciones para lo que el buen modelo
> resuelve en una o dos.

---

## 6. Orientación a la práctica

Cada concepto se ancla en el dominio de Mini Jira y en código que corre.

- **Nada de teoría suelta.** Si se explica `findOneAndUpdate` con
  precondición, se explica sobre el doble "tomar" de un ticket, no en
  abstracto. Si se explica un `watcher` de Vue, es sobre el filtro de estado
  del dashboard.
- **Código ejecutable y coherente.** Todo fragmento corre con las versiones
  fijadas de su curso y no contradice fases anteriores ni al otro curso. Nada
  de pseudocódigo que "se entiende".
- **Código mínimo.** El fragmento más pequeño que muestra el punto, pero
  ejecutable.
- **Comentarios que explican el porqué, no el qué, siempre en español.**
  `// la precondición va en el filtro: si otro agente ya lo tomó, matchea 0 docs`
  sí; `// incrementa i` no.
- **Distinguir capas.** Siempre queda claro si un comportamiento vive en el
  componente Vue, en el store, en el servicio HTTP, o —en el Curso 02— en la
  ruta, el controller, el service o el propio Mongo. Es la distinción que
  salva al que depura.

---

## 7. Manejo del código legacy (el corazón de los dos cursos)

Acá está la tentación grande: escribir código *bueno* en vez de código *real*.
No lo hacemos.

- **No modernizar por reflejo.** Si el módulo real es un componente con
  Options API y `this.$store`, se muestra así. Nada de Composition API,
  `<script setup>`, Pinia, Vite ni TypeScript. En el Curso 02, **driver nativo
  primero y Mongoose recién cuando el curso lo introduce**: primero a mano,
  después el wrapper.
- **Options API siempre**, también en las rutas: Quasar 1, Vuetify 2 y Nuxt 2
  son Vue 2.
- **`function () {}` en métodos de componente**, no arrow, para mantener el
  sabor de la época y hacer visible el tema del `this`. Las arrow sí se usan
  en callbacks cortos donde el código real las usaría.
- **Estilos legacy conviven.** Bootstrap 4 y jQuery dando vueltas, algún
  patrón viejo de Vuex, un componente gordo con lógica de negocio adentro. Se
  enseña a leer código mezclado sin marearse.
- **Corrección mínima vs refactor.** Cada vez que aparece un fix, se distingue
  el parche mínimo —lo que va en un hotfix un viernes— de la refactorización
  —lo que iría con calma y pruebas. Es una de las lecciones más transferibles
  del paquete.
- **El idioma del código (§5) no es negociable ni en el código más feo.** Un
  componente de 600 líneas se muestra tal cual, pero con identificadores en
  inglés y comentarios en español. La fealdad que enseñamos es de arquitectura
  y de decisiones, no de idioma.
- **Fechas con zona horaria explícita.** Nunca un `new Date()` suelto donde
  importe el día. En el Curso 02: `Date` de BSON en la base, **ISO string** en
  la frontera de la API, porque lo exige el contrato.
- **Promesas siempre atrapadas** en el backend: el `asyncHandler` del apéndice
  de Express existe exactamente por esto.
- **Dinero en enteros**, si alguna vez aparece. Nunca floats.

---

## 8. Marcadores y callouts

Vocabulario visual compartido por todos los documentos del paquete, para que
el lector lo reconozca de un vistazo.

### 8.1 Marcadores de estado

- 💸 **Deuda técnica intencional.** Todo atajo o patrón feo que se deja a
  propósito para reproducir el sistema real. Se **declara** en una fase y se
  **paga** explícitamente en otra —posiblemente del otro curso—. Ejemplos
  vivos: el "cliente mentiroso" que emite el evento de socket (Curso 01) se
  paga cuando el servidor lo emite (Curso 02); el doble "tomar" sin candado se
  paga con la precondición en el filtro.
- 🔥 **Opcional o ampliación.** Fases, secciones y ejercicios fuera del
  alcance base.
- ⭐ **Pieza central.** Las fases más formativas: en el Curso 01, las de CRUD,
  Vuex y testing; en el Curso 02, embeber-vs-referenciar y atomicidad.
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** Fácil, intermedio, difícil, muy
  difícil.
- 🏷️ **Tag de progreso.** El recordatorio de cerrar la fase con su tag de git.
  Va **una sola vez por fase**, en el cierre, con la forma fija de §9.1.

### 8.2 Callouts en blockquote

- 📝 **Nota de época.** Contexto histórico de un patrón que hoy se ve raro.
- 📚 **Referencia rápida inline.** El enlace útil justo donde nace la duda,
  sin esperar a la sección de referencias.
- ⚠️ **Advertencia.** Algo que rompe si lo ignoras: versión incompatible,
  socket.io 2.x contra 3.x, `id` numérico contra string hex del contrato,
  `node_modules` compartido entre arquitecturas.
- 💡 **Truco o atajo** que ahorra tiempo real.
- 🪦 **Retiro.** Cuando algo cumple su función y sale del proyecto: *"🪦 se
  apaga json-server: el mock ya cumplió"*.
- 🔑 **La frase para memorizar.** Una línea que el lector debería poder
  repetir de memoria seis meses después.

No hace falta usarlos todos en cada documento. Se usan cuando aportan.

### 8.3 Secciones narrativas recurrentes (comunes)

Micro-secciones con nombre fijo, que aparecen cuando el contenido las pide:

- **💸 Pago de deuda.** Donde una deuda declarada antes se salda. Se nombra
  qué deuda era, de qué fase venía, y se muestra el cambio.
- **Detalles con intención.** Lista corta con las decisiones deliberadas de un
  bloque de código y su porqué.
- **El patrón a memorizar.** Una o dos frases que destilan la lección
  transferible del fragmento.
- **Prueba de fuego.** Verificación manual concreta, incrustada en el flujo y
  no en los ejercicios: *"apaga json-server, apunta el `baseURL` al Express,
  recarga: el dashboard carga igual"*.
- **Mini-repaso.** Cuando la fase usa sintaxis que el dev de backend quizá no
  domina (`computed`/`watch` de Vue, el pipeline de aggregation para alguien
  que viene de SQL), un repaso exprés antes de entrar al código, con su 📚 a
  la documentación oficial.
- **La señal de que quedó bien.** En el cierre, un criterio en forma de cita
  que describe cómo se siente el trabajo bien hecho.

### 8.4 Secciones propias del Curso 02 (SQL → Mongo)

Estas cuatro son la columna vertebral del curso de MongoDB y aparecen cuando
el contenido lo pide:

- **📖 Tabla de traducción SQL ↔ Mongo.** Lado a lado, la consulta relacional
  y su equivalente en MQL. Es tabla (§3), no prosa.
- **🪞 "Tu instinto SQL dice… y esta vez se equivoca."** Nombra la trampa
  **antes** de caer: el `$lookup` que parece un JOIN gratis, la transacción
  multi-documento como moneda corriente, el `_id` numérico autoincremental.
- **🩻 "Esto sí funciona igual."** Lo reconfortante: índices, selectividad,
  `explain()`, el N+1 siguen valiendo lo que valían en SQL.
- **⚰️ Autopsia del anti-patrón.** `soporte_v1` mal diseñada: se mide, duele,
  se arregla. Es el hilo que cose las fases 3 a 8, con números de antes y
  después — nunca con adjetivos.

---

## 9. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden —
más el bloque de servicio 📌 que va después del cierre (§9.1). El esqueleto
rellenable está en `plantilla-de-fase.md`.

1. **🎯 Propósito** — qué resuelve la fase. Puede abrir con la situación
   heredada de la fase anterior.
2. **✅ Qué queda listo al terminar** — checklist verificable, no promesas.
3. **🚫 Qué NO entra todavía** — qué se difiere y a qué fase exacta.
4. **🧠 Concepto mínimo** — la teoría justa, anclada al dominio. Acá caben el
   Mini-repaso, las Notas de época y, en el Curso 02, la 📖 tabla de
   traducción y los recuadros 🪞/🩻.
5. **💻 Código mínimo con comentarios** — el grueso. Código ejecutable con las
   versiones fijadas, identificadores en inglés, comentarios en español. Acá
   caben Detalles con intención, El patrón a memorizar, Prueba de fuego y
   💸 Pago de deuda.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente y cómo se
   depura. El **resumen** va en la fase; el **recorrido completo** vive en su
   propio archivo (§9.2).
7. **🧪 Ejercicios** — ver §10.
8. **📚 Referencias** — ver §11.
9. **🚀 Cierre** — qué sigue, por qué, La señal de que quedó bien, y el
   recordatorio 🏷️ del tag de la fase (§9.1).

En los encabezados, **el emoji va primero**: `## 🎯 Propósito`. La numeración
explícita (`## 🎯 1. Propósito`) es opcional y se reserva para las fases que
numeran sus subsecciones y las citan con `§N` — hoy, las cuatro fases largas de
ruta del Curso 01 (`q1`, `q3`, `vu1`, `vu3`). El resto usa la forma sin número.
Lo que **no** varía: el encabezado de ejercicios lleva su conteo entre
paréntesis, `## 🧪 Ejercicios (30)`.

### 9.1 El recordatorio del tag, en el cierre

Toda fase termina con un bloque 🏷️ que recuerda cerrarla en git. Es de forma
fija —cambian solo el nombre del tag, la etiqueta de la fase y el prefijo de
commit— y va **después** de "La señal de que quedó bien" y **antes** de
"Siguiente parada", que es siempre lo último que se lee:

````markdown
> 🏷️ **No cierres la fase sin el tag.** Con el checklist de arriba en verde y
> `git status` limpio:
>
> ```bash
> git tag -a fase-04-dashboard-tickets -m "F4 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f04: …`) y los de ejercicio su
> número (`f04 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f04/17`, y un incidente resuelto en el par `inc/f04/<slug>-roto` /
> `-fix`. Todo eso está en
> [`../prompts/convencion-de-git-y-tags.md`](../prompts/convencion-de-git-y-tags.md).
````

El nombre del tag es **`fase-` + el mismo slug del archivo `.md`**, sin
excepciones (`04-dashboard-tickets.md` → `fase-04-dashboard-tickets`,
`q2-migrar-crud-qform.md` → `fase-q2-migrar-crud-qform`), y el prefijo de
commit es `f` + dos dígitos en las fases numeradas o el código de ruta en las
de ruta (`q2`, `vu3`, `nx0`). Nada más se reexplica en la fase: se enlaza.

Los apéndices **no** llevan este bloque, porque no producen código de fase.

Después de "Siguiente parada" —y solo después— va el bloque
`### 📌 Reservas para el cuaderno de incidentes`, con la tabla de los IDs que
esta fase aporta al `cuaderno-incidentes.md` de su curso. No contradice lo de
arriba: "Siguiente parada" sigue siendo lo último **de la fase**, y el 📌 no es
narrativa, es un bloque de servicio para quien escribe el cuaderno y para quien
audita que los IDs cuadren. Los apéndices tampoco lo llevan.

Los apéndices **no** siguen esta plantilla: usan índice de salto rápido,
secciones cortas, una guía final de "cuándo usar qué" y 5–10 ejercicios
cortos.

### 9.2 La pieza forense va en su archivo

La sección 6 se reparte entre dos documentos, y conviene decir por qué, porque
esta guía antes la daba por entera dentro de la fase.

**En la fase** queda lo que se lee de corrido: los errores comunes con su
síntoma → causa → fix mínimo, el resumen de qué depurar y con qué, y el bloque
🧨 **Rompe a propósito** que el estudiante ejecuta. **En el archivo** queda el
recorrido paso a paso, con las salidas literales, los callejones que hay que
descartar y el diagnóstico por síntoma completo.

La fase cierra su sección 6 con una línea de forma fija, que es el contrato
entre las dos:

```markdown
> 📄 El recorrido completo, con las salidas literales, en `forense-fase-08.md`.
```

**Por qué se separan.** La fase se lee una vez, en orden y de principio a fin.
La pieza forense se consulta **fuera de orden y meses después**, cuando llega
un ticket vago y no sabes ni de qué fase es tu problema: un archivo se abre por
su nombre, y una sección enterrada en una fase de novecientas líneas no se
encuentra. Además, una pieza bien hecha son doscientas líneas más sobre fases
que ya pesan entre quinientas y mil novecientas.

**La regla anti-solapamiento:** si un párrafo cabe igual de bien en los dos
sitios, va en la fase y la pieza lo enlaza. La fase se lee siempre; la pieza,
solo cuando hace falta. La especificación completa —estructura de la pieza,
cómo se escribe un paso, y la tabla de frontera— está en
`prompts/formato-piezas-forenses.md`, y no se reexplica en ninguna fase.

Los apéndices tampoco llevan pieza forense, por lo mismo que no llevan bloque
🏷️: no producen código de fase.

---

## 10. Ejercicios

- **Cantidad: 25 mínimo, 30 ideal por fase, hasta 35 en las densas.** Menos de
  25 se queda corto para una sesión de práctica. Más de 35 y el bloque de
  ejercicios pesa más que la fase.
- **Distribución equilibrada.** Para ~30 ejercicios: unos 8 🟢, 9 🟡, 7 🟠 y
  5–6 🔴, más los 🔥 aparte. No cargues todo en fácil.
- **Numeración continua con encabezado de rango**, así:

  ```markdown
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

  El título lleva el conteo total.
- **Accionables y verificables.** *"Haz que el ticket `#0347` no pueda tomarse
  dos veces con doble clic rápido"* — no *"reflexiona sobre concurrencia"*.
- **Al menos un tercio son de diagnóstico**, no de construcción: se entrega
  algo roto y se pide reproducir, localizar y explicar. Es el músculo que
  este paquete entrena.
- **Progresión real.** Los 🟢 calientan; los 🔴 exigen integrar varias fases o
  depurar algo esquivo: medir un `explain()`, reproducir un N+1, cerrar una
  race condition en el "tomar", predecir un bug de hidratación sin ejecutar el
  proyecto.
- **Enganchados al dominio.** Tickets, comentarios, agentes, reportadores,
  estados, prioridades. Nunca `foo` y `bar`.
- **Con el identificador vigente.** Si el ejercicio nombra código, usa el
  nombre en inglés que ya existe en la fase (`createTicket`, no
  `crearTicket`), y el enunciado en tuteo (*"agrega la action `createTicket`"*).

En apéndices bastan 5–10 ejercicios cortos de consulta.

---

## 11. Bibliografía y referencias

**Regla:** documentación oficial compatible con las versiones fijadas primero;
después libros; después blogs y videos. Siempre se advierte cuando un enlace
apunta a una versión distinta de la que usamos — que con Vue 2 y Mongo 4.4
pasa casi siempre.

### 11.1 Formato

URLs completas y clicables, nunca solo el dominio. Dentro de "Referencias" se
separa en documentación oficial (con nota de versión), libros cuando apliquen,
video y apoyo, y una línea final de **orden de lectura sugerido** que encadene
qué leer primero.

### 11.2 Fuentes oficiales por tema

**Curso 01 — tronco (Vue 2 legacy)**

- **Vue 2:** https://v2.vuejs.org — ⚠️ el dominio raíz `vuejs.org` sirve Vue 3.
- **Vuex 3:** https://v3.vuex.vuejs.org
- **Vue Router 3:** https://v3.router.vuejs.org
- **Vue Test Utils 1 (Vue 2):** https://v1.test-utils.vuejs.org
- **Bootstrap 4.6:** https://getbootstrap.com/docs/4.6
- **axios:** https://axios-http.com/docs/intro
- **vuelidate 0.7:** https://vuelidate-next.netlify.app — ⚠️ documenta la v2;
  para 0.7 usar https://vuelidate.js.org
- **chart.js 2.9:** https://www.chartjs.org/docs/2.9.4
- **socket.io 2.x:** https://socket.io/docs/v2/
- **json-server 0.16:** https://github.com/typicode/json-server/tree/v0.16.3
- **Jest:** https://jestjs.io

**Curso 01 — rutas**

- **Quasar 1:** https://v1.quasar.dev — ⚠️ `quasar.dev` sirve la v2 (Vue 3).
- **Vuetify 2:** https://v2.vuetifyjs.com — ⚠️ el raíz sirve la v3.
- **Nuxt 2:** https://v2.nuxt.com — ⚠️ `nuxt.com` sirve Nuxt 3. EOL desde
  junio de 2024, y eso lo hace *más* relevante para un curso de legacy.

**Curso 02 (MongoDB / Express)**

- **MongoDB 4.4:** https://www.mongodb.com/docs/v4.4/
- **Driver Node `mongodb` 3.6:** https://www.mongodb.com/docs/drivers/node/v3.6/
- **Mongoose 5:** https://mongoosejs.com/docs/5.x/
- **Express 4:** https://expressjs.com/en/4x/api.html
- **supertest:** https://github.com/ladjs/supertest
- **mongodb-memory-server:** https://github.com/nodkz/mongodb-memory-server
- **Docker:** https://docs.docker.com

**Común**

- **MDN** para JavaScript base: https://developer.mozilla.org
- **Node 14:** https://nodejs.org/docs/latest-v14.x/api/

### 11.3 Advertencias

- Cuando se cite un artículo, libro o video específico, se aclara que el
  título o la URL pueden haber cambiado y que conviene verificarlos. **No se
  inventan** números de página, ISBN, DOI ni identificadores de video.
- **No usar en el código principal:** Composition API como norma,
  `<script setup>`, Vue Router 4, Vuex 4, Pinia, Vite, TypeScript, Quasar 2,
  Vuetify 3, Nuxt 3, MongoDB ≥ 5, driver `mongodb` 4/5/6, socket.io 3/4,
  Mongoose ≥ 6. Aparecen solo como comparación o en secciones 🔥.
- **socket.io 2.x y 3.x no se mezclan ni se hablan como si fueran lo mismo:**
  la versión importa y el cliente tiene que coincidir con el servidor.

---

## 12. Sobre el dominio (ficticio, sin NDA)

Mini Jira es un dominio **enteramente ficticio**: una mesa de soporte interna
inventada para estos cursos. No hay confidencialidad que preservar ni sistema
real que disfrazar. Eso simplifica dos cosas respecto de otros cursos del
catálogo:

- Los ejemplos pueden ser todo lo concretos que convenga; no hace falta
  "generalizar ante la duda".
- El vocabulario del dominio es estable y se fija en el diccionario de código;
  no compite con ningún vocabulario "real" que haya que evitar.

La regla de idioma del código (§5) es una convención de calidad, no una
cuestión de NDA: se traduce el vocabulario del dominio pedagógico ("ticket" →
`ticket`) por consistencia y realismo.

---

## 13. Coherencia entre documentos y entre cursos

- **No contradecir fases anteriores**, ni dentro de un curso ni respecto del
  otro. Un fragmento de la Fase 6 del Curso 02 no puede devolver una forma de
  `ticket` distinta de la que el frontend del Curso 01 espera.
- **No reescribir decisiones aprobadas** sin señalar explícitamente la
  incompatibilidad y explicar por qué.
- **Nombres estables.** Archivos, componentes, módulos, servicios, actions,
  colecciones y campos se mantienen idénticos entre fases y entre cursos. Si
  algo se renombra, se documenta el cambio y se ajustan los documentos
  afectados.
- **El contrato es la costura entre cursos.** Endpoints, forma de las
  respuestas, enums (`status`, `priority`), nombres de evento de socket y el
  mapeo `id` ↔ `_id` son idénticos a ambos lados. Si un curso los cambia, el
  otro se entera y se documenta.
- **Referencias a archivos, siempre con el nombre vigente.** Este paquete ya
  pasó por una ronda de renombrado; antes de citar un `.md`, se confirma que
  exista con ese nombre exacto.

### 13.1 Fuentes de verdad, en este orden

1. Las instrucciones del proyecto (`CLAUDE.md` del repositorio).
2. `02-complement-mongodb-backend/00-audit-contrato.md` — el contrato que
   une los dos cursos.
3. `01-vue2-legacy/0-plan-del-curso.md` y
   `01-vue2-legacy/0-ESTRUCTURA-CURSO.md` — alcance, stack y arquitectura del
   Curso 01.
4. `02-complement-mongodb-backend/prompts/instrucciones-proyecto-track-b.md` —
   alcance del Curso 02.
5. Esta guía y sus tres anexos: `prompts/convencion-de-git-y-tags.md` para
   todo lo que toque git, repos y tags; `prompts/formato-piezas-forenses.md` y
   `prompts/formato-cuaderno-incidentes.md` para el track forense y el
   cuaderno de incidentes.
6. Entregables ya aprobados de fases anteriores.
7. Decisiones explícitas del chat actual.

> 🚫 **Documentos deprecados que no cuentan como fuente:**
> `02-complement-mongodb-backend/prompts/plan-formacion-nosql-mongodb.md`
> (descartado y así declarado en las instrucciones del Curso 02) y
> `02-complement-mongodb-backend/prompts/guia-de-estilo-y-convenciones.md`
> (la guía del Track B, superada por ésta y con su aviso 🪦 dentro).
>
> Los duplicados de respaldo `* copy.md` que vivían en ese `prompts/` **se
> borraron el 2026-09-10**: eran copias exactas, el historial de git las
> conserva, y un duplicado sin autoridad editorial es una fuente de verdad
> esperando a que alguien lo abra por error.

### 13.2 Nomenclatura de archivos vigente

- **Fases del Curso 01 (tronco):** `00-setup-hola-mundo.md` …
  `11-testing-minimo.md`.
- **Apéndices del Curso 01:** `a1-bootstrap.md` … `a5-webpack-babel.md`
  (minúscula, un dígito).
- **Rutas del Curso 01:** `q0`…`q4`, `vu0`…`vu4`, `nx0`…`nx4`, en minúscula
  (`q1-leer-quasar.md`).
- **Fases del Curso 02:** `00-preliminares.md` … `15-el-veredicto-honesto.md`.
- **Apéndices del Curso 02:** `a01-docker.md` … `a05-mongo-vs-sql.md`
  (minúscula, dos dígitos).
- **Track forense (uno de cada por curso):** `forense-master.md`,
  `forense-fase-00.md` … `forense-fase-NN.md`, y —solo en el Curso 01—
  `forense-ruta-q.md`, `forense-ruta-vu.md` y `forense-ruta-nx.md`, una por
  ruta y no una por fase de ruta.
- **Cuaderno de incidentes:** `cuaderno-incidentes.md`, uno por curso.
- **Documentos maestros:** `0-plan-del-curso.md`, `0-ESTRUCTURA-CURSO.md`,
  `README.md` (que hace de índice de cada curso).

En la narrativa, las fases del Curso 01 se citan como **Fase N** o **F*N***;
las rutas como **Q0–Q4 / VU0–VU4 / NX0–NX4**, y **X0…X4** cuando algo aplica
a las tres. Las fases del Curso 02 se citan como **Fase N** dentro de su
curso, y como **Curso 02, Fase N** cuando se las nombra desde el Curso 01.

---

## 14. Post-mortems e incidentes

Cada incidente sigue esta estructura de ocho puntos:

1. Síntoma, en palabras del usuario.
2. Pasos de reproducción exactos.
3. Evidencia observable: consola, Network, DevTools, logs; en el Curso 02
   también el profiler o el `explain()`.
4. Causa raíz, hasta la línea o el commit.
5. Corrección aplicada.
6. Prueba de regresión que falla antes del fix y pasa después.
7. Prevención: test, feature flag o alerta.
8. Post-mortem **sin culpabilización**: se analiza el sistema y el proceso, no
   a la persona.

El tono acá baja un punto de humor. Un post-mortem es sereno y analítico — no
acartonado, pero tampoco el lugar para el chiste.

Los puntos 1 a 6 tienen traducción exacta a git, y conviene pedirla cuando el
incidente es del alumno: el par de tags `inc/<fase>/<slug>-roto` y
`inc/<fase>/<slug>-fix` deja el síntoma y la prueba en rojo en el primero, la
causa raíz y el fix en el segundo, y el `git diff` entre los dos **es** el
punto 5 aislado del ruido. El detalle está en
`convencion-de-git-y-tags.md`, y las fases lo enlazan desde su bloque 🏷️ sin
reexplicarlo.

---

## 15. Checklist antes de dar por cerrado un `.md`

- [ ] Sigue la plantilla de 9 secciones (o el formato de apéndice).
- [ ] Tono semiformal y cálido, **tuteo latinoamericano**, humor con
      moderación.
- [ ] **Cero voseo y cero vosotros** — pasada de `grep` con la tabla de §4.7
      hecha, homógrafos revisados a mano.
- [ ] Español neutro: sin regionalismos de España ni de un solo país.
- [ ] Explica el problema antes que la herramienta, y el porqué de cada
      decisión.
- [ ] Prosa antes que listas; listas antes que tablas en comparativas
      extensas.
- [ ] Todo el código corre con las versiones fijadas del stack de su curso.
- [ ] **Todo el código en inglés** (variables, funciones, componentes,
      archivos, endpoints, constantes, enums, colecciones, campos) y **todos
      los comentarios en español**; textos de interfaz en español literal
      (§5).
- [ ] Options API, `function () {}` en métodos, driver nativo antes de
      Mongoose, sin features modernas fuera de secciones 🔥.
- [ ] Marca 💸 la deuda intencional (y dice en qué fase se paga) y 🔥 lo
      opcional.
- [ ] Distingue capas (componente / store / servicio / ruta / controller /
      service / Mongo) donde importa.
- [ ] Tiene 25–35 ejercicios con rangos 🟢🟡🟠🔴 equilibrados, al menos un
      tercio de diagnóstico (o 5–10 cortos en apéndices).
- [ ] Referencias con URL completa a la documentación de la versión correcta,
      con advertencia cuando el enlace cubra otra.
- [ ] **Cada `.md` citado existe con ese nombre exacto** (§13.2).
- [ ] No contradice ninguna fase anterior ni el otro curso; respeta el
      contrato.
- [ ] Incluye "La señal de que quedó bien" en el cierre.
- [ ] Lleva el bloque 🏷️ del tag de la fase, con el nombre correcto
      (`fase-` + slug del archivo) y el prefijo de commit correcto (§9.1). Los
      apéndices no lo llevan.
- [ ] La sección 6 lleva su pieza forense —resumen, 🧨 «Rompe a propósito» y la
      línea 📄 hacia el archivo del recorrido (§9.2)—, o dice por qué no.
- [ ] Lleva el bloque «📌 Reservas para el cuaderno de incidentes», o declara
      que esta fase no reserva ninguno. Los apéndices no lo llevan.
- [ ] Cada ID reservado existe en el índice del `cuaderno-incidentes.md` de su
      curso, y ninguno se reasignó.

---

## 16. El track forense y el cuaderno de incidentes

Dos entregables por curso, además de las fases. No son material extra: son el
desarrollo de una sección que la plantilla ya cuenta (§9.2) y de una estructura
que esta guía ya define (§14).

**El track forense** son las piezas de recorrido, más su puerta de entrada. Cada
`forense-fase-NN.md` lleva una investigación completa —el ticket como llegó,
cada paso con su salida literal, y qué descarta cada paso—, y `forense-master.md`
trae el método de cuatro preguntas y el 🩺 índice de síntomas transversal, que es
lo que de verdad se consulta: nadie llega sabiendo de qué fase es su problema,
llega con *"la pantalla se quedó en blanco"*. En el Curso 01 son doce piezas de
tronco más tres de ruta —una por ruta, porque son excluyentes y quien elige
Quasar no leerá nunca las de Vuetify—; en el Curso 02, doce como piso.

**El cuaderno de incidentes** es un archivo por curso con doce tickets vagos, de
los que llegan de verdad, cada uno con su preparación, tres pistas plegadas,
espacio para tu investigación y una solución de referencia con parche mínimo,
prueba de regresión en código y post-mortem. Es donde la estructura de ocho
puntos de §14 deja de ser una especificación y se instancia.

> ⚠️ **Los dos cursos son independientes, y el material forense lo respeta.** Hay
> quien hará solo el Curso 01 y no tocará Mongo nunca. Ninguna pieza ni incidente
> del Curso 01 puede depender del Curso 02 —puede nombrar una deuda 💸 y decir
> dónde se paga, pero el recorrido cierra solo—, y los incidentes de costura del
> Curso 02 se resuelven partiendo de un frontend que se entrega ya construido.

La especificación completa vive en `prompts/formato-piezas-forenses.md` y
`prompts/formato-cuaderno-incidentes.md`, que son anexos de esta guía (§13.1) y
mandan sobre todo lo que se escriba en esos archivos. Esta sección no los
duplica: dice que existen y para qué.
