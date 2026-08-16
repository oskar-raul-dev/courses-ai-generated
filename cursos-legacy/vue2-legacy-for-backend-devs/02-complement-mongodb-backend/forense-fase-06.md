# 🕵️ Forense Fase 06 — "Dos agentes tomaron el mismo ticket" ⭐

> **Sale de:** [Fase 6 — Atomicidad, transacciones y consistencia](06-atomicidad-transacciones-consistencia.md)
> · **Herramientas:** dos sesiones de `mongosh`, `matchedCount` /
> `modifiedCount`, y el log de la API · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** dos operaciones que deberían excluirse mutuamente
> tuvieron éxito las dos, y ninguna dio error.

Ésta es la pieza donde el instinto relacional falla por una razón muy concreta:
en tu motor de siempre, la transacción era gratis y estaba puesta por defecto en
la mitad de los frameworks. Acá **no hay nada puesto**, y el bug no se ve nunca
en desarrollo, donde eres un solo usuario haciendo una cosa a la vez.

---

## 🎫 El ticket

> "Ana y yo tomamos el mismo ticket casi al mismo tiempo. A los dos nos dijo que
> quedó asignado. En la pantalla de ella figura ella, en la mía figuro yo, y en
> el listado aparece asignado a Ana. Nadie recibió ningún error."
>
> — agente de soporte · **Ambiente:** UAT, con dos usuarios reales

Este ticket es un regalo: trae la reproducción incluida. La mayoría llegan como
"a veces se pierden asignaciones", sin nombres y sin hora.

---

## 🧭 La ruta

Del más barato al más caro: primero se lee lo que la propia escritura devolvió,
después se mira el código, después se reproduce, y la transacción —la
herramienta cara— se discute al final y casi siempre se descarta.

### Paso 1 — ¿qué devolvió cada escritura?

En el log de la API, o repitiendo la operación en `mongosh`:

```js
> db.tickets.updateOne({ _id: id }, { $set: { assignee: "soporte1", status: "in_progress" } })
{ acknowledged: true, matchedCount: 1, modifiedCount: 1 }
> db.tickets.updateOne({ _id: id }, { $set: { assignee: "soporte2", status: "in_progress" } })
{ acknowledged: true, matchedCount: 1, modifiedCount: 1 }
```

**Qué descarta.** Descarta cualquier fallo del motor: las dos escrituras hicieron
exactamente lo que se les pidió, y la segunda pisó a la primera con todo el
derecho del mundo. **El filtro no dice nada sobre quién puede tomar el ticket**:
dice "este ticket", y ese ticket existe. No hubo carrera perdida: hubo dos
carreras ganadas.

### Paso 2 — ¿el código lee y después escribe?

El sospechoso tiene una forma reconocible, y se busca sin leer todo el archivo:

```bash
grep -n "findOne" -A 6 src/services/ticketService.js
```

```js
var ticket = await tickets.findOne({ _id: id });
if (ticket.assignee) {
  throw new ConflictError("El ticket ya está asignado");
}
await tickets.updateOne({ _id: id }, { $set: { assignee: user } });
```

**Qué descarta.** Cierra el diagnóstico. Entre el `findOne` y el `updateOne` hay
una ventana, y esa ventana es el bug: los dos procesos leyeron "sin asignar" y
los dos escribieron. La comprobación existe, está bien escrita y **no sirve**,
porque comprobar y escribir son dos operaciones distintas. En tu motor de
siempre, un `SELECT … FOR UPDATE` dentro de una transacción tapaba esto sin que
tuvieras que pensarlo.

### Paso 3 — reproducirlo a voluntad

Sin reproducción no hay caso, y con dos sesiones de `mongosh` alcanza. En la
primera, prepara el ticket libre; después ejecuta en las dos, lo más seguido que
puedas:

```js
// sesión A y sesión B, casi a la vez
db.tickets.updateOne({ _id: id }, { $set: { assignee: "soporte1" } })
db.tickets.updateOne({ _id: id }, { $set: { assignee: "soporte2" } })
```

```
A: { matchedCount: 1, modifiedCount: 1 }
B: { matchedCount: 1, modifiedCount: 1 }
```

**Qué descarta.** Descarta la idea de que haga falta carga o concurrencia real
para verlo: dos terminales bastan. Y demuestra la parte incómoda: **el bug es
determinista**, no intermitente. Lo intermitente era que dos personas
coincidieran, no que el sistema fallara.

### Paso 4 — la precondición va en el filtro

Ahora la misma operación, escrita como una sola:

```js
> db.tickets.updateOne(
    { _id: id, assignee: null },
    { $set: { assignee: "soporte1", status: "in_progress" } })
{ matchedCount: 1, modifiedCount: 1 }
> db.tickets.updateOne(
    { _id: id, assignee: null },
    { $set: { assignee: "soporte2", status: "in_progress" } })
{ matchedCount: 0, modifiedCount: 0 }        // ← el segundo pierde, y se entera
```

**Qué descarta.** Descarta la necesidad de una transacción para este caso: una
escritura sobre **un** documento ya es atómica, y meter la precondición en el
filtro convierte el "comprobar y escribir" en una sola operación indivisible.

Y trae de regalo la distinción que el contrato necesita: `matchedCount: 0` **no
significa "no existe"**. Puede existir y no cumplir la precondición. Son dos
respuestas distintas —404 y 409— y confundirlas produce el reporte gemelo: *"me
dice que el ticket no existe y ahí está"*.

### Paso 5 — ¿y cuando de verdad hay que tocar dos documentos?

Si el caso involucra dos colecciones —crear el ticket y su primer comentario, por
ejemplo— y una de las dos escrituras aparece a veces sola:

```js
await session.withTransaction(async function () {
  await tickets.insertOne(doc, { session });
  await comments.insertOne(comment);      // ⚠️ sin { session }
});
```

**Qué descarta.** Descarta el motor y las transacciones como culpables. Una
operación sin `{ session }` corre **fuera** de la transacción, sin error y sin
aviso: si algo falla después, se revierte lo de dentro y se queda lo de fuera. Es
el fallo más traicionero de la fase, porque el código *parece* transaccional y el
`withTransaction` reporta éxito.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Dos operaciones excluyentes que ambas tuvieron éxito | Read-modify-write: la precondición no está en el filtro |
| Un contador quedó corto tras un pico | `doc.n++; save()` es una carrera con disfraz: usa `$inc` |
| `matchedCount: 0` y el documento existe | Tu filtro llevaba precondición: es 409, no 404 |
| La transacción "funcionó" y falta una escritura | Falta `{ session }` en alguna operación |
| La transacción aborta con conflictos bajo carga | Trabajo lento o llamadas externas dentro de `withTransaction` |
| El código comprueba y falla igual | La ventana entre comprobar y escribir |
| El test de concurrencia pasa siempre | Una sola ronda: la carrera es probabilística (Fase 13) |
| Todo va bien en desarrollo y falla en UAT | En desarrollo eres un usuario haciendo una cosa a la vez |

---

## ⚰️ Los callejones

**"Hay que meter una transacción."** Es el reflejo que trae todo el mundo desde
SQL, y en este caso es **de más**: una escritura sobre un solo documento ya es
atómica, y envolverla en una transacción paga precio —sesión, límite de 60 s,
conflictos— por una garantía que ya tenías. Las transacciones son para varios
documentos, y son la excepción, no la norma.

**"Es que Mongo no tiene bloqueos."** Los tiene, y no es lo que falta acá. Lo que
falta es que la condición del negocio esté **dentro** de la operación que
escribe. Es el mismo `UPDATE … WHERE assignee IS NULL` que habrías escrito en
SQL sin pensarlo — la diferencia es que allá la transacción por defecto te
perdonaba escribirlo mal.

**"Lo arreglo con un reintento."** Reintentar una operación mal condicionada la
repite mal. Y peor: esconde el conflicto en vez de reportarlo, cuando el
conflicto es información que el usuario necesita —*"Ana se te adelantó"* es una
respuesta útil; un reintento silencioso que reasigna el ticket, no.

---

## 🧠 El patrón transferible

**Comprobar y actuar son la misma operación, o no son nada.** Da igual el motor,
el lenguaje o la capa: en cuanto entre la comprobación y el efecto hay una
ventana, alguien se va a meter por ella. Lo que cambia entre tecnologías es
**quién te tapaba esa ventana sin que lo supieras** — en tu base relacional, la
transacción implícita del framework; acá, nadie.

Y el corolario que vale para diseñar contratos de API: **"no pasó nada" tiene al
menos dos motivos, y el usuario merece saber cuál.** No existe y no cumplió la
condición son 404 y 409, y colapsarlos en el mismo mensaje convierte un conflicto
legítimo en un misterio.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 6](06-atomicidad-transacciones-consistencia.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 06](cuaderno-incidentes.md); y cómo se prueba de verdad una carrera,
en la [pieza de la Fase 13](forense-fase-13.md).
