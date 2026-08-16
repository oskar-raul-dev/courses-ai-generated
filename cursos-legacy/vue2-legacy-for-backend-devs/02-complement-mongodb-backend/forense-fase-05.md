# 🕵️ Forense Fase 05 — "Esta pantalla hace seis viajes a la base" ⭐

> **Sale de:** [Fase 5 — `$lookup` y por qué es una alarma](05-lookup-y-por-que-es-una-alarma.md)
> · **Herramientas:** los logs de la API, `explain()` sobre el pipeline y
> Compass · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** la pantalla funciona y es lenta, y la lentitud
> crece con los datos, no con el código.

Ésta es la pieza donde el instinto SQL más se equivoca, y no por ignorancia: por
**exceso de confianza**. El `$lookup` se parece tanto a un JOIN que se usa igual,
y usarlo igual es el síntoma de un modelo que se diseñó como si fuera un esquema
relacional. El recorrido termina siempre en la misma pregunta incómoda: *¿esto
debió embeberse?*

---

## 🎫 El ticket

> "El dashboard de tickets tarda como cuatro segundos en abrir. Antes iba bien.
> No hemos cambiado esa pantalla en meses, solo se ha ido llenando de tickets."
>
> — coordinadora de soporte · **Ambiente:** UAT

"Solo se ha ido llenando" es el diagnóstico a medio hacer: un problema que crece
con el volumen y no con el código es de **modelo o de acceso**, nunca de una
línea que alguien tocó.

---

## 🧭 La ruta

Del más barato al más caro: contar peticiones cuesta leer un log; medir el
pipeline cuesta un `explain`; rediseñar el modelo es la conversación cara y va
al final, con números en la mano.

### Paso 1 — ¿cuántas consultas hace esa pantalla?

Antes de medir ninguna consulta, cuéntalas. En el log de la API, al abrir la
pantalla una vez:

```
GET /tickets 200 - 38 ms
GET /users/5f8a… 200 - 6 ms
GET /users/5f8b… 200 - 5 ms
GET /users/5f8c… 200 - 6 ms
GET /comments?ticketId=… 200 - 7 ms
GET /comments?ticketId=… 200 - 6 ms
… (58 líneas más)
```

**Qué descarta.** Descarta la consulta individual: ninguna de ellas es lenta.
Es el **N+1 de siempre con otro collar** — una consulta para la lista y una por
cada elemento— y se reconoce contando, no midiendo. Si en vez de sesenta líneas
vieras una sola lenta, saltarías al paso 3.

### Paso 2 — ¿el pipeline sustituye al N+1 o lo esconde?

Supongamos que ya lo resolvieron con un `$lookup`. Míralo antes de celebrar:

```js
> db.tickets.aggregate([
    { $lookup: { from: "comments", localField: "_id", foreignField: "ticketId", as: "comments" } },
    { $match: { status: "open" } }
  ]).explain("executionStats").stages[0].$cursor.executionStats
{ nReturned: 100000, totalDocsExamined: 100000, executionTimeMillis: 3184 }
```

**Qué descarta.** Descarta el índice y apunta al **orden de las etapas**: el
`$match` está después del `$lookup`, así que el motor une los 100.000 tickets
con sus comentarios y **después** se queda con los abiertos. Es el `WHERE` que
tu instinto jamás habría puesto al final en SQL, y acá se escribe así todos los
días porque el pipeline se lee como una receta. Con el `$match` primero:

```js
{ nReturned: 41230, totalDocsExamined: 41230, executionTimeMillis: 412 }
```

### Paso 3 — ¿el resultado tiene la forma que esperas?

Dos síntomas que llegan como tickets distintos y son el mismo malentendido:

```js
> db.tickets.aggregate([{ $lookup: { … , as: "comments" } }]).next()
{ _id: ObjectId("…"), title: 'La impresora no imprime',
  comments: [ { … }, { … } ] }        // ⚠️ un array, no filas planas
```

Y su reverso, cuando alguien lo "arregla" con `$unwind`:

```js
> db.tickets.aggregate([
    { $lookup: { …, as: "comments" } },
    { $unwind: "$comments" }
  ]).toArray().length
63          // de 100 tickets
```

**Qué descarta.** Descarta un bug de datos: los 37 tickets que faltan no se
borraron, **los quitó el `$unwind`**. Un `$unwind` sin
`preserveNullAndEmptyArrays: true` descarta los documentos con el array vacío:
tu LEFT JOIN se volvió INNER JOIN sin avisar. Y la forma con array no es un
error del `$lookup`: es lo que hace por diseño —agrupa—, y quien esperaba filas
planas estaba traduciendo literalmente un JOIN.

### Paso 4 — ¿el pipeline interno corre una vez o N veces?

Cuando un `$lookup` con `let` iba bien y se degrada al crecer:

```js
{ $lookup: {
    from: "comments",
    let: { tid: "$_id" },
    pipeline: [
      { $match: { $expr: { $eq: ["$ticketId", "$$tid"] } } },
      { $sort: { createdAt: -1 } },      // ⚠️ por CADA ticket
      { $limit: 3 }
    ],
    as: "lastComments" } }
```

**Qué descarta.** Descarta la consulta externa. Ese pipeline interno se ejecuta
**una vez por cada documento de la izquierda**: un `$sort` caro ahí dentro se
multiplica por 100.000. Es el equivalente exacto de la subconsulta correlacionada
que en tu motor de siempre aprendiste a temer, y acá no tiene un plan de
ejecución que te la señale con nombre propio.

### Paso 5 — la pregunta que la fase te obliga a hacer

Con los números anteriores, la conversación deja de ser técnica:

```
tickets   ←→ comments      3 lookups por pantalla
tickets   ←→ users         1 lookup por pantalla
comments  ←→ users         1 lookup anidado
```

**Qué descarta.** Descarta la optimización como solución. Una **cadena** de
lookups no es una consulta que afinar: es el síntoma de que el modelo se diseñó
como un esquema relacional y se guardó en Mongo. La pregunta es si esos datos se
leen siempre juntos —y entonces debían **embeberse**— o si de verdad son
entidades independientes. La fase da el criterio y la
[Fase 8](forense-fase-08.md) lo mide con `soporte_v1` en la mesa de autopsias.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Una pantalla hace decenas de peticiones | N+1: cuenta las consultas antes de medirlas |
| El `$lookup` devuelve arrays donde esperabas filas | Agrupa por diseño: no es un JOIN |
| Desaparecieron documentos al agregar `$unwind` | Falta `preserveNullAndEmptyArrays`: LEFT convertido en INNER |
| El pipeline iba rápido y se degradó al crecer | Falta el `$match` previo, o el `let` interno corre por documento |
| `$sort` que revienta con error de 100 MB | Sin `allowDiskUse`, y si lo pones en un endpoint caliente, era un batch |
| Una cadena de tres lookups | El modelo, no la consulta: pregunta si debió embeberse |
| Un batch con `$in` "modernizado" a `$lookup` y ahora va peor | Se cambió sin medir: `$in` sano era mejor |
| Copias denormalizadas que divergen | Denormalizar sin protocolo de reconciliación |
| La reconciliación nocturna tarda horas | Recorre todo: acota con `updatedAt` |

---

## ⚰️ Los callejones

**"Le pongo un índice al `$lookup` y listo."** El índice sobre `ticketId` es
necesario y no suficiente: si el `$match` está después, seguirás uniendo 100.000
documentos antes de filtrar. El orden de las etapas manda sobre el índice, y es
gratis cambiarlo.

**"Meto todo en un solo pipeline para hacer una sola petición."** Reduce el
número de viajes y puede empeorar el tiempo total: un pipeline que une tres
colecciones y ordena por un campo sin índice es una sola petición larguísima.
Menos peticiones no es lo mismo que menos trabajo.

**"En SQL esto era un JOIN de tres tablas y volaba."** Es verdad, y por eso duele.
El motor relacional tenía un optimizador que reordenaba tu consulta y estadísticas
para elegir el plan; acá el orden que escribes es, en buena medida, el orden que
corre. El instinto sigue siendo bueno —filtrar antes de unir—, lo que cambió es
que ahora es **tu** responsabilidad escribirlo así.

---

## 🧠 El patrón transferible

**Un `$lookup` frecuente es una pregunta sobre el modelo disfrazada de consulta.**
La técnica de esta pieza —contar peticiones, mirar el orden de las etapas, medir
`totalDocsExamined`— sirve para localizar el coste, pero el hallazgo casi nunca
es "esta consulta está mal escrita": es "estos datos se leen siempre juntos y
están guardados separados".

Lo que se transfiere fuera de Mongo: **cuando la lentitud crece con el volumen y
no con el código, deja de mirar líneas y empieza a mirar accesos.** Cuántas
idas y vueltas, cuántos documentos examinados por documento devuelto, y qué se
lee siempre en compañía de qué. Esas tres preguntas resuelven la mayoría de los
"antes iba bien" de cualquier base de datos.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 5](05-lookup-y-por-que-es-una-alarma.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 05](cuaderno-incidentes.md); y la autopsia con números en la
[pieza de la Fase 8](forense-fase-08.md).
