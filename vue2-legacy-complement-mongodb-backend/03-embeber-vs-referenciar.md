# ⚔️ Fase 3 — Embeber vs referenciar: el capítulo que decide todo

## 🎯 Propósito

Este es el capítulo por el que existe el curso. **Cambio de paradigma #1: la
normalización deja de ser la virtud por defecto.**

Durante años, "¿está al menos en 3FN?" fue tu control de calidad, y duplicar
un dato era pecado con nombre (anomalía de actualización). Esa disciplina te
sirvió porque tu motor optimizaba JOINs y custodiaba integridad. Mongo no hace
ninguna de las dos cosas — así que la pregunta de diseño cambia:

> Ya no es *"¿cuál es la forma normal de estos datos?"*
> Es *"**¿qué se lee junto y qué cambia junto?**"*

Al final de la fase decides, con números y no por reflejo, el modelo del Mini
Jira — y conoces al villano del curso: una base modelada por alguien que nunca
se hizo esa pregunta.

---

## ✅ Qué queda listo al terminar

- las dos preguntas (lectura conjunta / cambio conjunto) y los 4 cuadrantes
  como herramienta de decisión;
- los patrones con nombre: embebido, referencia, referencia extendida,
  subset, computed, bucket;
- los límites físicos que vetan diseños: 16 MB y arrays sin techo;
- el modelo del Mini Jira decidido y **defendido por escrito** en
  `DATA-MODEL.md` (nuevo entregable);
- el historial de estados diseñado (el subdominio escritura-intensiva);
- primera visita al anti-patrón ⚰️: la base "Postgres disfrazado" instalada y
  su dolor medido con números tuyos.

## 🚫 Qué NO entra todavía

- `$lookup` (Fase 5 — primero decide el modelo, después conoce la muleta)
- cómo mantener sincronizada la denormalización (Fase 5)
- validación del esquema decidido (Fase 4)
- índices para rescatar consultas (Fase 7 — y spoiler: no rescatan modelos)
- transacciones (Fase 6)

---

## 🧠 Las dos preguntas y los 4 cuadrantes

Para cada relación entre entidades (ticket–comentarios, ticket–usuario,
ticket–historial…), pregunta:

1. **¿Se leen juntos?** Cuando la aplicación muestra A, ¿casi siempre
   necesita B en la misma pantalla/operación?
2. **¿Cambian juntos?** ¿B se modifica como parte de la vida de A, o tiene
   vida propia (lo editan otras pantallas, otros procesos, otra frecuencia)?

|  | **Cambian juntos** | **Cambian por separado** |
|---|---|---|
| **Se leen juntos** | ✅ **Embebe.** El caso feliz: un documento = una unidad de trabajo. | ⚖️ El cuadrante difícil. Candidato a **referencia extendida**: referencia + copia de los 2–3 campos que la lectura necesita. Precio: sincronizar las copias. |
| **Se leen por separado** | ⚖️ Raro. Suele indicar que definiste mal las entidades. Revisa antes de modelar. | ✅ **Referencia.** Colecciones separadas sin culpa. |

Tres vetos físicos que anulan cualquier cuadrante:

- **16 MB por documento.** No es "mucho espacio": un ticket con años de
  comentarios embebidos + adjuntos en base64 (se ha visto) lo alcanza.
- **Arrays sin techo.** Si el array crece sin límite conocido (comentarios de
  un ticket polémico, eventos de un sensor), embeberlo es una bomba de
  relojería: documentos que se reescriben cada vez más grandes, y en la época
  del legacy que heredarás, el "unbounded array" es EL anti-patrón número 1
  de los post-mortems.
- **Lo que se consulta transversalmente vive mal embebido.** "Todos los
  comentarios de soporte1 en todos los tickets" contra comentarios embebidos
  es posible (multikey, Fase 7) pero incómodo; si esa consulta es frecuente,
  es un voto por la colección separada.

> ### 🪞 Tu instinto dice… "duplicar datos está mal, siempre"
>
> **Predicción falsable:** "si guardo el nombre del agente dentro del ticket,
> tarde o temprano habrá tickets con el nombre viejo tras un update — por eso
> se normaliza".
>
> La predicción es **correcta**. Lo que cambia es el veredicto sobre si eso
> está *mal*. En tu mundo la anomalía de actualización era inaceptable porque
> el costo de evitarla era cero: el JOIN era gratis y el motor lo optimizaba.
> Aquí evitarla cuesta (una consulta extra o un `$lookup` en cada lectura), y
> aceptarla cuesta (sincronizar N copias cuando el usuario se renombra…
> ¿cuántas veces por año se renombra un usuario? ¿cuántas veces por segundo
> se lee un ticket?).
>
> **La normalización era una respuesta, no un axioma.** La pregunta siempre
> fue "¿qué costo prefiero?" — solo que tu motor la respondía por ti, siempre
> igual. Mongo te devuelve la pregunta. **Veredicto: el instinto no se
> equivoca en los hechos; se equivoca en tratar la respuesta como
> incondicional.** 📓 A `INSTINTOS.md` — esta es la entrada más importante
> del curso.

### 🩻 Esto SÍ funciona igual

Tu entrenamiento en **entender los patrones de acceso antes de modelar** —
eso que hacías al diseñar índices y particiones— es exactamente el músculo
que este capítulo usa. Un buen DBA siempre supo qué consultas dominarían el
sistema. La diferencia: en SQL esa información afinaba el modelo normalizado;
aquí **lo dicta**.

---

## 📗 Los patrones con nombre (vocabulario de la época)

- **Embebido:** el sub-dato vive dentro del documento padre.
- **Referencia:** colección aparte, unida por convención (`ticketId`).
- **Referencia extendida** (*extended reference*): referencia + copia de los
  campos que la pantalla caliente necesita (ej.: el ticket guarda `assignee`
  como username **y** podría guardar `assigneeName` para no ir a `users` en
  cada render de la lista).
- **Subset:** embebe los N más relevantes, el resto en colección aparte (los
  10 comentarios más recientes en el ticket; el histórico completo, fuera).
- **Computed:** guarda el resultado calculado (contador `commentsCount` en el
  ticket) en vez de calcularlo al leer. Tu vieja tabla de agregados o vista
  materializada, en miniatura y a pulso.
- **Bucket:** para series de eventos, ni un documento por evento ni un array
  infinito: documentos-cubo con N eventos cada uno (abajo, con el historial).

---

## 🧮 Las cuentas sobre Mini Jira (modelar con números, no con fe)

Datos de partida (medibles en tu base; a escala, supónlos del negocio):
~3 comentarios por ticket en promedio, p99 ≈ 40, ~200 bytes por comentario.
Pantallas: la **lista** de tickets no muestra comentarios; el **detalle**
muestra ticket + todos sus comentarios; los comentarios se crean de a uno,
después de creado el ticket.

### Relación ticket–comentarios

- ¿Se leen juntos? **A medias:** en el detalle sí, en la lista (la pantalla
  más caliente) no.
- ¿Cambian juntos? **No:** el comentario nace solo, tiene autor propio,
  frecuencia propia.
- ¿Techo del array? p99 de 40 × 200 bytes ≈ 8 KB — lejos de 16 MB, pero "un
  ticket polémico" no tiene techo contractual.
- Y el factor decisivo que un libro no tendría y tú sí: **el contrato**. El
  frontend consume `GET /comments?ticketId=X&_sort=createdAt` y
  `POST /comments` como recursos independientes con su propio `id`.

**Veredicto: colección separada** (como llegó del `db.json` heredado: `comments`
ya es recurso propio con su `ticketId`). No "porque así estaba
en SQL", sino porque: lectura no siempre conjunta + vida propia + contrato
que los trata como recurso. ⚠️ Nota la honestidad: con otro frontend (uno que
pidiera el ticket con comentarios incluidos), **subset embebido habría
ganado**. El modelo correcto depende del acceso; cambia el acceso, cambia el
modelo. Escribe ambos análisis en `DATA-MODEL.md`.

### Relación ticket–usuario (assignee/reporter)

- ¿Se leen juntos? Sí: cada fila de la lista muestra quién.
- ¿Cambian juntos? No: el usuario vive en `users`.
- Cuadrante difícil → **referencia extendida**: el ticket guarda el
  `username` (ya lo hace: es lo que el frontend espera en `assignee` y
  `reporter`). Y el contrato vota por la colección separada: `users` es
  recurso propio (`GET /users?role=agent` alimenta el selector de asignados).
  Si mañana la lista necesitara el nombre completo, copiarías
  `assigneeName` al asignar y pagarías la sincronización en el rename
  (¿cuántos renames al año?). Deja la decisión y sus números en
  `DATA-MODEL.md`.

### El historial de estados (el subdominio escritura-intensiva)

💸 Hoy nadie registra las transiciones (deuda del sistema heredado: la máquina
de estados vive solo en el cliente; se salda cuando el backend persista el
historial embebido, con su regalo de atomicidad en la Fase 6). El backend real va a necesitar auditoría:
quién movió qué ticket, de qué estado a cuál, cuándo.

Opciones sobre la mesa:

1. **Array embebido `history` en el ticket.** Se lee junto (pestaña de
   actividad del detalle), cambia junto (la transición ES un cambio del
   ticket — y en la Fase 6 verás el regalo: ticket + su historial se
   actualizan en **una** operación atómica, sin transacción). Techo: un
   ticket sano transiciona pocas veces (open→in_progress→resolved→closed,
   quizá algún reopen). ✅ **Elegido** para transiciones. Bonus de contrato:
   `history` es un campo interno del backend — el frontend no lo pide, así
   que las respuestas actuales no cambian de forma (la capa API de la Fase 10
   decide si lo proyecta fuera; exponerlo algún día sería extensión, no
   ruptura — régimen de `AUDIT-CONTRATO.md`).
2. **Colección `ticket_events`.** Correcto si el volumen fuera alto o el
   acceso transversal ("todo lo que hizo soporte1 hoy") fuera lo caliente.
3. **Bucket:** si registráramos *todo* (cada edición de campo, cada
   vista) — cientos de eventos por ticket — ni array infinito ni un documento
   por micro-evento: documentos-cubo por ticket y día/centena:

```js
// Patrón bucket (para el caso hipotético de auditoría total)
{
  ticketId: ObjectId("..."),
  bucket: 3,                    // tercer cubo de este ticket
  count: 47,                    // eventos en el cubo (se cierra en 100)
  events: [ { at: ISODate(...), user: "soporte1", type: "field_edit", ... } ]
}
```

🔎 **Qué hace el bucket:** convierte "un insert por evento" (millones de
micro-documentos) o "un array eterno" (documento bomba) en un punto medio:
documentos de tamaño acotado que se rellenan con `$push` + `$inc` hasta el
tope y se cierra el cubo. Es el patrón de la época para IoT, logs y métricas
— y el corolario incómodo en versión constructiva.

> 📝 **El corolario incómodo, en voz alta:** si TODO tu dominio fuera así —
> escritura torrencial, todo cambia por separado, lecturas transversales y
> agregadas — estarías forzando patrones para compensar el motor. Un sistema
> puramente transaccional de alta contención con integridad dura era y sigue
> siendo territorio relacional. Este curso te enseña Mongo, no te vende
> Mongo. La conversación completa, en la Fase 15.

### `DATA-MODEL.md` (nuevo entregable)

Cada decisión con este formato — es el documento que le dejarías al siguiente
dev (o el que desearías que te hubieran dejado):

```markdown
## comments: colección separada
- Se leen juntos: solo en detalle (lista no) | Cambian juntos: no
- Techo: p99 40×200B, sin techo contractual
- Contrato: recurso independiente (GET/POST /comments)
- Decisión: referencia. Alternativa considerada: subset embebido
  (ganaría si el detalle fuera la única lectura). Revisar si el
  contrato cambia.
```

---

## ⚰️ Primera visita al anti-patrón: "Postgres disfrazado"

Te instalo al villano. `soporte_v1` es la base de un Mini Jira paralelo,
modelada por alguien que "migró a Mongo" en 2019 transcribiendo su esquema
relacional tabla por tabla:

```
soporte_v1
  users          { _id, username, name, roleId }
  roles          { _id: 1, name: "agent" }          ← lookup table. En Mongo.
  priorities     { _id: 2, name: "high", order: 3 }
  statuses       { _id: 1, name: "open" }
  tickets        { _id, title, description, statusId, priorityId,
                   assigneeId, reporterId, createdAt }
  comments       { _id, ticketId, authorId, body, createdAt }
  ticketHistory  { _id, ticketId, fromStatusId, toStatusId,
                   userId, at }
```

Siete colecciones. Cada valor humano escondido tras un id. Las "FKs" son
enteros que nadie valida (lo peor de ambos mundos: la rigidez del diseño
relacional **sin** el motor relacional que lo hacía funcionar).

El curso trae `scripts/seed-antipattern.js` que la genera a escala:
100.000 tickets, 400.000 comentarios, 300.000 entradas de historial.

**El laboratorio de hoy (solo medir; la cirugía es en la Fase 8):**

Renderizar el detalle de UN ticket — lo que el frontend pide en una pantalla —
exige en `soporte_v1`:

```js
// 1 ticket + 2 lookup-tables + 2 usuarios + comentarios + autores de comentarios
const t   = db.tickets.findOne({ _id: id });
const st  = db.statuses.findOne({ _id: t.statusId });
const pri = db.priorities.findOne({ _id: t.priorityId });
const asg = db.users.findOne({ _id: t.assigneeId });
const rep = db.users.findOne({ _id: t.reporterId });
const com = db.comments.find({ ticketId: id }).toArray();
// ...y un viaje más POR CADA autor de comentario distinto. Hola, N+1.
```

Cronométralo (ejercicios 22–24) y compáralo contra el detalle equivalente en
`minijira` (1–2 consultas). Guarda los números en `DATA-MODEL.md`, sección
"La autopsia — mediciones (antes)": los vas a necesitar en las fases 5, 7
y la Fase 8.

> 🎯 Lo que el villano enseña ya: ninguna de estas 7 colecciones es
> *incorrecta* por sí sola. El error no está en ningún documento — está en
> que **nadie hizo las dos preguntas**. Es un modelo traducido, no diseñado.
> Aprende a olerlo: lookup-tables para enums, ids numéricos simulados,
> cadenas de `*_id` que obligan a 6 viajes por pantalla.

---

## 🧩 Chuleta de la fase

```
Las 2 preguntas: ¿se leen juntos? ¿cambian juntos?
  sí+sí  → embebe
  sí+no  → referencia extendida (copia lo mínimo, presupuesta el sync)
  no+no  → referencia
  no+sí  → revisa tus entidades

Vetos: 16 MB · array sin techo · consulta transversal frecuente

Patrones: embebido | referencia | ref. extendida | subset | computed | bucket

Olores de "traducido, no diseñado":
  lookup-tables para enums · *_id en cadena · N+1 por pantalla
  · ningún documento se parece a lo que la UI muestra

Regla de oro de la época:
  "lo que se accede junto, se guarda junto" — y se DEMUESTRA con números
```

---

## ⚠️ Errores comunes

- Modelar sin haber listado las pantallas/consultas dominantes (modelar "los
  datos" en abstracto es el hábito SQL; aquí se modela **el acceso**).
- El extremo contrario al villano: embeberlo TODO porque "en Mongo se
  embebe" — y fabricar documentos-bomba con arrays sin techo.
- Crear lookup-tables para enums (`statuses`, `priorities`): un enum es un
  string en el documento + validación (Fase 4). Punto.
- Elegir referencia extendida sin presupuestar la sincronización (¿quién
  actualiza las copias? ¿cuándo? — la respuesta seria llega en la Fase 5,
  pero la pregunta se hace HOY, por escrito).
- Decidir "para siempre": el modelo correcto depende del patrón de acceso;
  si el producto cambia las pantallas, el modelo se re-discute. Por eso
  `DATA-MODEL.md` registra alternativas, no solo ganadores.
- Tomar el p50 en vez del p99 para el techo de un array.

---

## 🧪 Ejercicios (34)

Los de análisis se entregan en `DATA-MODEL.md`; los de medición, con números.

**🟢 Fácil (1–10)**

1. Clasifica en los 4 cuadrantes, con una línea de justificación: pedido–líneas de pedido, post–comentarios, empleado–departamento, factura–cliente, sensor–lecturas, usuario–preferencias de UI.
2. Para cada caso del ejercicio 1: ¿aplica algún veto físico (16 MB / array sin techo)?
3. Calcula: un ticket con historial embebido, 10 transiciones de ~150 bytes. ¿Qué porcentaje del límite de 16 MB usa? ¿Y con 10.000? ¿El veto aplica a nuestro historial de transiciones? ¿Por qué no?
4. Escribe el documento JSON de un ticket del Mini Jira con las decisiones tomadas en la fase (comentarios fuera, `history` embebido con 2 transiciones de ejemplo).
5. Dibuja (texto o papel) el modelo `minijira` final: colecciones, campos, qué referencia a qué. Compáralo con el diagrama ER que habrías hecho en SQL. Marca cada diferencia con la pregunta que la justificó.
6. Identifica en `soporte_v1` las tres lookup-tables y escribe cómo queda cada una en el modelo bien diseñado.
7. En la doc 4.4, localiza el límite de 16 MB y qué se recomienda para datos que lo excedan (te va a sonar: GridFS, Fase 12).
8. `distinct("statusId")` en `soporte_v1.tickets` y tradúcelo a nombres con la lookup-table. Siente el fastidio. Anótalo: el fastidio es dato.
9. Escribe la entrada de `INSTINTOS.md` de esta fase (la del 🪞) con tus palabras, incluyendo el cálculo renames/año vs lecturas/segundo de TU experiencia en algún sistema real que hayas mantenido.
10. Inicia `DATA-MODEL.md` con la plantilla dada y las 3 decisiones de la fase (comments, assignee, history).

**🟡 Intermedio (11–21)**

11. El frontend v2 (hipotético) mostrará en la lista el **conteo de comentarios** por ticket. Sin cambiar comments de lugar: propón el patrón computed (`commentsCount` en el ticket), define quién lo incrementa y qué pasa si se desincroniza. ¿Cómo lo repararías? (Un script de reconciliación es tu viejo amigo el batch nocturno.)
12. El frontend v2 también mostrará los 3 últimos comentarios al pasar el mouse. Diseña el subset: qué se embebe, cuándo se poda, qué consulta sirve el hover y cuál el detalle completo.
13. Un ticket "polémico" real: genera un ticket con 5.000 comentarios en la colección separada. Verifica que el detalle sigue siendo sano (paginación range-based que practicaste en el ej. 23 de la Fase 2). Ahora simula qué documento habría resultado con todo embebido: constrúyelo y mide su tamaño con `Object.bsonsize()`.
14. Diseña el modelo para "etiquetas" (tags) de tickets: ¿array de strings en el ticket, colección `tags` + referencias, o ambas? El requisito caliente: filtrar tickets por tag (pantalla principal) y renombrar un tag globalmente (una vez al trimestre). Defiende con los cuadrantes.
15. Diseña "adjuntos" (metadata solamente: nombre, tamaño, tipo, quién, cuándo — los bytes van a GridFS en la Fase 12): ¿embebido en el ticket o colección? Considera: se listan en el detalle, se suben de a uno, p99 = 5 por ticket.
16. Caso clásico de la época — carrito de compras: producto en el catálogo cambia de precio, pero la orden ya pagada debe conservar el precio del momento. ¿Qué patrón es? (Pista: aquí la "anomalía de actualización" no es un bug: es el requisito.) Escribe el documento `order`.
17. Del mundo real de tu pasado: elige un esquema SQL que hayas mantenido (3+ tablas). Redis­éñalo para Mongo con las dos preguntas, documentando cada decisión. Entrega: el antes (DDL), el después (documentos ejemplo), y la tabla de decisiones.
18. Sobre `soporte_v1`: escribe la función mongosh `ticketDetail(id)` que haga TODOS los viajes (incluidos los autores de comentarios, sin duplicar consultas por autor repetido). Cuenta cuántas consultas ejecuta para un ticket con 8 comentarios de 5 autores distintos.
19. La misma función contra `minijira`: `healthyTicketDetail(id)`. ¿Cuántas consultas? ¿Qué dato de usuario NO tienes y el frontend actual NO necesita? (Mira el contrato: el frontend pinta `assignee` como username. La referencia extendida ya estaba pagada.)
20. El historial embebido: escribe el update que agrega una transición (`$push` a `history` + `$set` del status) — en UNA operación. Todavía no sabes por qué esa unicidad es oro (Fase 6), pero deja el comentario: "// esto es atómico y me va a encantar".
21. Encuentra el olor: te doy tres modelos de un blog (a: posts con comments embebidos y tags array; b: posts, comments, tags, post_tags como 4 colecciones; c: posts con subset de comments + colección comments). Para cada uno, di qué patrón de acceso lo justificaría y cuál lo condena. (No hay respuesta única: hay justificaciones buenas y malas.)

**🟠 Difícil (22–29)**

22. **Medición base del villano:** cronometra `ticketDetail(id)` de `soporte_v1` sobre 100 ids aleatorios (bucle en mongosh o script Node). Reporta promedio y p95. Haz lo mismo con `healthyTicketDetail` en una `minijira` inflada al mismo volumen (usa el generador). Tabla comparativa a `DATA-MODEL.md`, sección "autopsia (antes)".
23. Mide el **listado**: la pantalla principal (20 tickets con status/prioridad/asignado legibles por humanos) contra ambas bases. En `soporte_v1` necesitas resolver 3 ids por fila. Implementa la versión ingenua (N+1) y la versión "batch" (junta ids, `$in`, mapea en memoria). Los tres tiempos a la tabla.
24. La consulta transversal: "toda la actividad de soporte1 hoy" (tickets asignados + comentarios escritos + transiciones hechas) contra ambos modelos. ¿Dónde es más natural? ¿El modelo sano pierde en algo? Sé honesto en la tabla: el diseño por acceso optimiza los accesos elegidos, y este no fue elegido.
25. Implementa el bucket para la auditoría total hipotética: función `recordEvent(ticketId, event)` que haga `$push` + `$inc` sobre el cubo abierto y cree cubo nuevo al llegar a 100. (Te va a faltar atomicidad fina — anota exactamente DÓNDE está la carrera; la Fase 6 te espera con la respuesta.)
26. Genera 50.000 eventos con esa función y compara contra la alternativa "un documento por evento": tamaño total en disco (`db.stats()`), cantidad de documentos, y el tiempo de leer "todos los eventos del ticket X".
27. El rename de usuario con referencia extendida: supón que el ticket guarda `assigneeName` copiado. Escribe el update masivo que sincroniza el rename del agente soporte1 (su `name` pasa de "Agente Uno" a "Agente Uno Pérez") en todos sus tickets. Mídelo con 10.000 tickets afectados. Ahora tienes el costo REAL del lado malo del trade — compáralo contra el costo de 1 consulta extra × lecturas/día del lado bueno. ¿A partir de cuántas lecturas diarias gana la copia? Esa cuenta ES el capítulo.
28. Diseña el modelo Mongo para un dominio hostil: sistema de turnos médicos (pacientes, médicos, agendas, turnos, historias clínicas — acceso transversal intenso, escritura concurrente sobre la agenda, integridad dura en el turno). Documenta dónde Mongo te obliga a forzar patrones y escribe el párrafo honesto: ¿lo harías en Mongo? Anticipas la Fase 15.
29. Audita un esquema ajeno: busca en GitHub un proyecto Node+Mongo de la época (2018–2020) con modelos definidos (los tutoriales de "MEAN stack blog" abundan). Aplica el olfato: ¿diseñado o traducido? Evidencias concretas, veredicto en 5 líneas. (Es la promesa del curso, versión entrenamiento.)

**🔴 Muy difícil (30–34)**

30. **La bomba de 16 MB, detonación controlada:** construye programáticamente un documento que se acerque al límite (array de sub-documentos). ¿Qué error exacto lanza el driver al pasarlo? ¿Y qué pasa con un `$push` sobre un documento que está a 100 bytes del límite? Documenta ambos mensajes de error: reconocerlos en un log de producción legacy vale oro.
31. Mide la degradación del array creciente: script que haga `$push` de a 1.000 elementos hasta 200.000, cronometrando cada lote. Grafica/tabula tiempo por lote vs tamaño del documento. Explica la curva con lo que sepas de cómo el motor reescribe documentos. (Esta curva es la razón física del veto al array sin techo — ahora la tienes medida, no creída.)
32. El subset con poda atómica: implementa "insertar comentario" que (a) inserte en la colección `comments`, (b) haga push al subset del ticket **manteniendo solo los 3 últimos** (investiga `$push` con `$slice` — sí, existe y es de época), (c) incremente `commentsCount`. Señala qué parte del combo puede quedar inconsistente si el proceso muere entre (a) y (b), y qué estrategia de reconciliación propones.
33. Escribe el **detector de "traducido, no diseñado"**: script Node que recibe el nombre de una base y reporta olores: colecciones con ≤10 documentos y campos {_id numérico, nombre} (lookup-table probable), campos `*_id` numéricos, colecciones cuyo nombre singular/plural aparece referenciado en más de N otras colecciones, documentos cuyo tamaño promedio es sospechosamente uniforme y pequeño (~fila). Pruébalo contra `soporte_v1` (debe gritar) y `minijira` (debe callar).
34. **El ensayo de la fase** (1–2 páginas, al final de `DATA-MODEL.md`): "La normalización como respuesta cacheada". Tesis a desarrollar: las formas normales son la respuesta precalculada a las dos preguntas para un motor con JOIN gratis e integridad custodiada; al cambiar el motor, la respuesta cacheada se invalida pero la pregunta sobrevive. Usa tus mediciones (ej. 22–27) como evidencia. Este texto es el que le mostrarías a un colega SQL escéptico — escríbelo para él.

---

## 📚 Referencias

**Documentación oficial (4.4)**

- Data Modeling Introduction: https://www.mongodb.com/docs/v4.4/core/data-modeling-introduction/
- Embedded Data Models vs References (el capítulo oficial de esta fase): https://www.mongodb.com/docs/v4.4/core/data-model-design/
- Model One-to-Many with Embedded Documents: https://www.mongodb.com/docs/v4.4/tutorial/model-embedded-one-to-many-relationships-between-documents/
- Model One-to-Many with References: https://www.mongodb.com/docs/v4.4/tutorial/model-referenced-one-to-many-relationships-between-documents/
- Document Size Limit (BSON limits): https://www.mongodb.com/docs/v4.4/reference/limits/
- `$push` con `$slice` (para el subset): https://www.mongodb.com/docs/v4.4/reference/operator/update/slice/

**La serie canónica de la época (léela: es EL material)**

- *Building with Patterns* (Ken W. Alger & Daniel Coupal, MongoDB blog,
  2019) — la serie que nombró los patrones: https://www.mongodb.com/blog/post/building-with-patterns-a-summary
- *6 Rules of Thumb for MongoDB Schema Design* (William Zola, clásico
  absoluto): https://www.mongodb.com/blog/post/6-rules-of-thumb-for-mongodb-schema-design

**Libros**

- *MongoDB: The Definitive Guide*, 3.ª ed. — cap. 9 (Application Design).
- *MongoDB Applied Design Patterns* (Rick Copeland, O'Reilly) — viejo pero
  es exactamente la mentalidad de la época que vas a heredar.

**Cursos / video**

- MongoDB University — M320 Data Modeling (el curso oficial de esta fase entera): https://learn.mongodb.com/
- MongoDB Schema Design Best Practices — Joe Karlsson (MongoDB): https://www.youtube.com/watch?v=QAqK-R9HUhc
- Data Modeling with MongoDB — Yulia Genkina (MongoDB): https://www.youtube.com/watch?v=3GHZd0zv170

**Orden de lectura sugerido para perfil senior:**
6 Rules of Thumb (30 min, vas a discutir en voz alta con el artículo — es
parte del método) → Embedded vs References de la doc → Building with
Patterns (la serie completa, con calma) → ejercicios de medición 22–27 →
M320 si quieres la versión larga.

> ⚠️ **Aviso de versión:** todos los enlaces apuntan a **MongoDB 4.4**, la
> versión fijada del track. El modelado de datos y los patrones (embebido,
> referencia, subset, computed, bucket) son estables entre versiones, pero si
> saltas a la doc de 5.x/6.x verás rutas y ejemplos distintos —y `$push` con
> `$slice` (ej. 32) mantiene su semántica, aunque a partir de 5.0 conviven
> operadores de array más nuevos que aquí no usamos.

---

## 🚀 Cierre

Al final de esta fase tienes el cambio de paradigma #1 instalado: modelar es
responder "¿qué se lee junto y qué cambia junto?" con números del negocio, no
recitar formas normales. Tienes el modelo del Mini Jira decidido y defendido
en `DATA-MODEL.md`, el historial de estados diseñado, el vocabulario de
patrones de la época, y al villano `soporte_v1` medido y documentado —
esperando su autopsia en la Fase 8.

La señal de que quedó bien:

> "puedo defender por qué comments es colección y history es array embebido
> **sin usar la palabra 'normalización'** — y sé exactamente qué cambio en el
> producto me haría revisar ambas decisiones".

**Siguiente parada:** 🧬 Fase 4 — El esquema que no está en la base. Ya
decidiste la forma de tus documentos; ahora la pregunta incómoda: si el motor
no la custodia… ¿quién la custodia? (Spoiler: hay tres documentos con tres
formas distintas conviviendo en toda base legacy real. Vas a aprender a vivir
con ellos.)
