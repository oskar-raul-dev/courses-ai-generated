# 🕵️ Forense Fase 09 — "Mi GROUP BY devuelve UNA fila"

> **Sale de:** [Fase 9 — Aggregation](09-aggregation.md) ·
> **Herramientas:** `mongosh`, corriendo el pipeline **etapa por etapa** ·
> **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** el pipeline no falla, devuelve un documento, y
> ese documento es el total global de algo que querías desglosar.

Esta pieza promueve a archivo el recorrido que la Fase 9 ya traía en su sección
6, y le agrega el método que lo generaliza. El caso es el bug silencioso número
uno de la agregación en esta época, y su gracia pedagógica es que **la salida te
confiesa la causa** si sabes qué mirar.

---

## 🎫 El ticket

> "El reporte de tickets por estado dejó de funcionar. No da error, pero en vez
> de la tabla por estado sale una sola línea con el total de todo. Lo heredé de
> quien se fue, no lo he tocado."
>
> — el analista de reportes · **Ambiente:** desarrollo

---

## 🧭 La ruta

Del más barato al más caro: la salida ya está en pantalla y contiene la
respuesta; después se corre el pipeline por etapas; el código es lo último.

### Paso 1 — mira el `_id` de la salida

El pipeline heredado y lo que devuelve:

```js
db.tickets.aggregate([
  { $group: { _id: "status", total: { $sum: 1 } } }
])
// salida real:
// [ { "_id" : "status", "total" : 100000 } ]
```

**Qué descarta.** Descarta los datos, el índice y el volumen: el número es
correcto —son todos los tickets— y el problema está en cómo se agruparon. Y la
pista definitiva está en el `_id` de la salida: **dice `"status"`, el nombre del
campo, no `"open"`, que sería un valor de tus datos.** Ésa es la huella dactilar.

Tu ojo de SQL ya lo tradujo antes de leer esto: un `GROUP BY` que colapsa a una
fila es un `GROUP BY <constante>`.

### Paso 2 — la autopsia, que es un carácter

```js
{ $group: { _id: "status",  … } }    // el LITERAL de cuatro letras
{ $group: { _id: "$status", … } }    // el VALOR del campo
```

```js
db.tickets.aggregate([
  { $group: { _id: "$status", total: { $sum: 1 } } }
])
// [ { "_id":"open", "total":41230 }, { "_id":"closed", "total":38110 }, … ]
```

**Qué descarta.** Cierra el caso. Sin `$`, Mongo agrupó por una constante: un
solo grupo, todos los documentos dentro. No hay error porque no hay nada
ilegal — agrupar por un literal es una operación perfectamente válida, solo que
inútil.

### Paso 3 — el método que lo habría cazado en la primera etapa

Cuando una etapa da algo raro, no leas el pipeline entero: **córrelo por
partes**, mirando dos documentos.

```js
> db.tickets.aggregate([{ $match: { status: "open" } }, { $limit: 2 }]).toArray()
[ { _id: ObjectId("…"), title: 'La impresora…', status: 'open', … }, { … } ]
```

Añade una etapa, vuelve a mirar. Añade otra, vuelve a mirar.

**Qué descarta.** Descarta todas las etapas anteriores a la que rompe, una por
una, y es la técnica que convierte un pipeline opaco en algo depurable. Con
`$group` en particular hay un motivo extra para hacerlo: **el `$group` no
propaga los campos que no declaras**, así que una etapa posterior que "perdió"
un campo casi siempre lo perdió ahí.

### Paso 4 — ¿el filtro está donde tiene que estar?

Con el pipeline ya correcto, la otra familia de problemas de la fase:

```js
> db.tickets.aggregate([
    { $group: { _id: "$status", total: { $sum: 1 } } },
    { $match: { total: { $gt: 100 } } }        // ✅ esto es un HAVING
  ])
```

**Qué descarta.** Descarta la confusión más común de quien viene de SQL: un
`$match` **antes** del `$group` es el `WHERE` —y debe ir lo más al principio
posible, para que use índices—, y un `$match` **después** es el `HAVING`. No son
la misma etapa en distinto sitio: son dos filtros distintos con costes muy
distintos. Un `$match` que podía ir primero y quedó tercero se regala un
COLLSCAN.

### Paso 5 — el pipeline que revienta con 100 MB

Último síntoma de la fase, y el que conviene leer como diagnóstico y no como
obstáculo:

```
MongoServerError: Sort exceeded memory limit of 104857600 bytes,
but did not opt in to external sorting.
```

**Qué descarta.** Descarta el bug: el pipeline está bien escrito, y lo que hay es
un `$sort` sobre demasiados documentos. `allowDiskUse: true` lo desbloquea —y si
lo estás poniendo en un endpoint que se llama en cada carga de pantalla, acabas
de confesar que eso era un proceso por lotes disfrazado de consulta. La salida
suele ser filtrar antes, o aceptar que es un batch y sacarlo del camino
caliente.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Un `GROUP BY` que colapsa a una fila | Falta el `$` : agrupaste por el literal |
| El `_id` de la salida trae el nombre de un campo | La misma huella: revisa cada referencia a campo |
| Una etapa perdió campos que sí existían | El `$group` solo propaga lo que declaras |
| El pipeline va lentísimo | `$match` tarde: debería ir lo más al principio posible |
| `$unwind` que multiplica millones de documentos | Falta el `$match` previo (Fase 5) |
| Error de 100 MB en un `$sort` | Sin `allowDiskUse`; y si lo necesitas en caliente, era un batch |
| El `$facet` no usa el índice | El filtro indexable quedó dentro en vez de antes |
| Reescribiste un `find` como pipeline y va peor | Sin `$group`/`$unwind`/transformación, `find` + índices gana |

---

## ⚰️ Los callejones

**"El pipeline está roto, lo reescribo entero."** Es la reacción natural ante un
resultado absurdo, y tira información: el pipeline heredado funcionaba en algún
momento, y el `_id` de su salida te está diciendo exactamente qué se rompió.
Corre por etapas antes de reescribir; en el 80% de los casos el arreglo es un
carácter.

**"Es un bug de Mongo, un `GROUP BY` no puede devolver eso."** Devuelve
exactamente lo que se le pidió. El instinto SQL ayuda a **reconocer** el síntoma
—esto huele a agrupar por constante— y estorba si lo lleva a esperar un error de
sintaxis que acá no existe: agrupar por un literal es legal.

**"Le agrego un índice al `$group`."** Los índices ayudan al `$match` y al `$sort`
que van **antes**; el `$group` en sí no se indexa. Si el pipeline es lento, mira
el orden de las etapas antes de crear nada — y si el `explain()` ya está limpio,
el problema es el modelo (Fase 5).

---

## 🧠 El patrón transferible

**Cuando una etapa dé algo raro, mira su salida antes que su código.** El `_id`
de un `$group` es una confesión: si trae el nombre literal de un campo en lugar
de un valor de tus datos, te comiste un `$`. Y ese hábito —leer la salida como
evidencia, no como resultado— es lo mismo que hace la
[pieza de la Fase 2](forense-fase-02.md) con los conteos.

Lo que se transfiere a cualquier sistema de transformación de datos, sea un
pipeline de Mongo, un ETL o una cadena de `map`/`reduce`: **la unidad de
depuración no es el programa, es la etapa.** Correr una etapa, mirar dos
documentos, añadir la siguiente. Es lento de escribir y rapidísimo de depurar, y
es exactamente lo contrario de lo que hace todo el mundo la primera vez.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 9](09-aggregation.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 09](cuaderno-incidentes.md); y la relación entre pipelines y modelo,
en la [pieza de la Fase 5](forense-fase-05.md).
