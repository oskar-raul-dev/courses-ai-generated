# 🕵️ Forense Fase 02 — "Traduje mi WHERE y devuelve de más" ⭐

> **Sale de:** [Fase 2 — Consultar: tu SQL traducido](02-consultar-tu-sql-traducido.md)
> · **Herramientas:** `mongosh`, comparando siempre contra el conteo ·
> **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** la consulta funciona, no da error, y el conjunto
> que devuelve no es el que pediste.

Ésta es la pieza que más rinde del Curso 02, porque cubre el sitio exacto donde
el instinto relacional contesta rápido y contesta mal: **la traducción literal
casi funciona.** Un `WHERE` mal traducido no revienta; devuelve un resultado
plausible, y un resultado plausible se cuela hasta producción.

---

## 🎫 El ticket

> "El reporte de tickets sin asignar me da 34 y el que hice yo a mano en Compass
> me da 41. Los dos filtran por lo mismo. Ninguno da error. ¿Cuál está bien?"
>
> — el analista que heredó los reportes · **Ambiente:** desarrollo

La pregunta correcta no es cuál está bien: es **qué está contando cada uno**. Y
la respuesta, casi siempre, es que uno de los dos incluye documentos donde el
campo ni siquiera existe.

---

## 🧭 La ruta

Del más barato al más caro, con una regla propia de esta fase que ordena todo:
**cada paso se contesta con un conteo, no con una impresión.** Mirar veinte
documentos y decir "parece bien" es exactamente cómo se cuelan estos bugs.

### Paso 1 — ¿cuántos son en total, y cuántos devuelve cada versión?

```js
> db.tickets.countDocuments()
100
> db.tickets.countDocuments({ assignee: null })
41
> db.tickets.countDocuments({ assignee: { $type: "null" } })
34
> db.tickets.countDocuments({ assignee: { $exists: false } })
7
```

**Qué descarta.** Descarta la idea de que uno de los dos filtros esté "mal
escrito": los dos hacen exactamente lo que dicen, y la diferencia —7— tiene
nombre. En Mongo hay **tres estados**, no dos: campo con valor, campo con `null`
explícito, y campo **ausente**. `{ assignee: null }` matchea los dos últimos.

> 🪞 Tu instinto de SQL dice que `= NULL` no matchea nada y hace falta
> `IS NULL`. Acá se equivoca **en la dirección contraria**: la igualdad con
> `null` matchea, y matchea de más.

### Paso 2 — ¿el filtro negado excluye lo que crees?

La otra mitad de la misma trampa, y la que produce reportes que faltan filas:

```js
> db.tickets.countDocuments({ assignee: { $ne: "soporte1" } })
72
> db.tickets.countDocuments({ assignee: { $ne: "soporte1", $exists: true, $ne: null } })
```

Como `$ne` no se puede repetir en el mismo objeto, se escribe explícito:

```js
> db.tickets.countDocuments({ assignee: { $nin: ["soporte1", null], $exists: true } })
31
```

**Qué descarta.** Descarta la lectura ingenua de `$ne`. *"Asignados a alguien
que no es soporte1"* y *"no asignados a soporte1"* son dos preguntas distintas:
la segunda incluye a los que no están asignados a nadie. En SQL la
tricotomía te obligaba a decidirlo; acá el filtro más corto decide por ti, y
decide mal.

### Paso 3 — ¿estás comparando el tipo correcto?

Si los conteos no cuadran y el campo no es nullable, sospecha del tipo antes que
del filtro:

```js
> db.tickets.countDocuments({ priority: { $type: "string" } })
99
> db.tickets.countDocuments({ priority: { $not: { $type: "string" } } })
1
> db.tickets.findOne({ priority: { $not: { $type: "string" } } })
{ _id: ObjectId("…"), title: 'Ticket de prueba', priority: 3 }
```

**Qué descarta.** Descarta el filtro y apunta a los datos: **nadie custodia los
tipos**. Un `priority: 3` numérico entre 99 strings no rompe nada, no aparece en
ningún reporte por prioridad, y sobrevive meses. Lo mismo con `_id` como string
y `createdAt` como texto, que es lo que la [Fase 1](forense-fase-01.md) enseña a
detectar. Un auditor de tipos por campo sospechoso es de las cosas más rentables
que puedes escribir en una base heredada.

### Paso 4 — ¿la proyección está haciendo lo que crees?

Otro reporte de la misma familia, con síntoma distinto:

```js
> db.tickets.find({}, { title: 1, assignee: 0 })
MongoServerError: Cannot do exclusion on field assignee in inclusion projection
```

**Qué descarta.** Es de los pocos casos de esta fase donde Mongo **sí** grita, y
conviene reconocerlo para no perder tiempo: una proyección o incluye o excluye,
no las dos cosas; `_id` es la única excepción, y por eso `{ title: 1, _id: 0 }`
sí es legal. Si tu consulta trae campos que no pediste, mira la proyección antes
que el serializer.

### Paso 5 — el filtro es correcto y aun así el número extraña

Última comprobación antes de cerrar: que no estés contando con la herramienta
equivocada.

```js
> db.tickets.count()
100
> db.tickets.countDocuments({ status: "open" })
41
```

**Qué descarta.** Descarta el filtro. `count()` sin filtro puede devolver una
**estimación** basada en metadatos —rápida y, tras un apagón sucio, mentirosa—,
mientras `countDocuments()` cuenta de verdad. En un reporte que alguien va a
firmar, la diferencia importa; en SQL nunca tuviste que elegir.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Dos filtros "iguales" con conteos distintos | Los tres estados: valor / `null` / ausente |
| `$ne` trae documentos que no esperabas | `$ne` incluye a los ausentes: no significa "tiene otro valor" |
| Un filtro por valor deja fuera documentos que lo cumplen | Tipos mezclados en el campo |
| `$or` que no filtra nada | Está escrito dentro del campo en vez de en la raíz |
| La proyección falla o devuelve de más | Se mezclaron `1` y `0`: solo `_id` va a contracorriente |
| Un rango de fechas devuelve cualquier cosa | Fechas guardadas como string (Fase 1) |
| El conteo cambia entre dos formas de contarlo | `count()` estima; `countDocuments()` cuenta |
| Paginar la página 400 tarda un mundo | `skip` gigante: el mismo pecado que `OFFSET` |
| El regex encuentra de más con textos raros | Falta escapar: el `?q=` del contrato vive de esto (Fase 10) |
| `distinct` devuelve `null` entre los valores | Es un valor legítimo: filtra en el segundo argumento |

---

## ⚰️ Los callejones

**"La base está corrupta."** Casi nunca. Lo que suele haber es una base **sin
custodia de tipos** —que es otra cosa— y una consulta que asume un esquema que
nadie hace cumplir. La diferencia importa porque el arreglo es distinto: no se
repara la base, se le pone un validator (Fase 4) y se auditan los tipos.

**"Le agrego `$exists: true` a todo por si acaso."** Convierte cada filtro en un
conjuro y esconde la pregunta real, que es de negocio: *¿"sin asignar" incluye a
los tickets que nunca tuvieron el campo?* Contéstala primero, escribe el filtro
después, y déjala escrita en el código — porque el siguiente que lo lea va a
tener la misma duda.

**"Lo arreglo en la capa API con un `filter` de JavaScript."** Traer 100.000
documentos para descartar 60.000 en Node funciona en desarrollo y muere en
producción. Y además esconde el problema: la consulta sigue siendo incorrecta, y
el siguiente que la use sin tu `filter` va a heredar el bug.

---

## 🧠 El patrón transferible

**Un resultado plausible es más peligroso que un error.** Todo lo de esta pieza
—los tres estados del campo, el `$ne` que incluye ausentes, los tipos sin
custodia— produce consultas que devuelven algo razonable, y por eso llegan a
producción y se convierten en reportes que alguien firma.

De ahí el método, que es lo que de verdad se lleva uno: **valida por conteo, no
por muestra.** Escribe la consulta de las dos formas que se te ocurran, cuenta
las dos, y si los números difieren has encontrado una pregunta de negocio que
nadie había contestado. Es la técnica más barata que existe para auditar una
migración, un reporte heredado o cualquier filtro que no escribiste tú.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 2](02-consultar-tu-sql-traducido.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 03](cuaderno-incidentes.md); y la misma disciplina de medir, aplicada
al rendimiento, en la [pieza de la Fase 7](forense-fase-07.md).
