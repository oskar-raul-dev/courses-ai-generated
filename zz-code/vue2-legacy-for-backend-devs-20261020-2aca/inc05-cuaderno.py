#!/usr/bin/env python3
"""Reescribe el incidente 05 del Curso 01 en el cuaderno con la rama probada (t-inc05.sh, t-inc05-normalizado.sh).
Uso: python3 -I inc05-cuaderno.py <cuaderno-incidentes.md>
"""
import sys

p = sys.argv[1]
t = open(p, encoding="utf-8").read()
E = [
("""> **Tiempo sugerido:** 40-60 min
>
> ⚠️ **No verificado por ejecución.** La reproducción supone un campo `tags` que
> ninguna fase del tronco agrega (ni la semilla ni el formulario de edición lo
> tienen) y un `onTicketUpdated` en `TicketsView` que el curso solo escribe en el
> panel de soporte de la Fase 9. La refactorización y su prueba de regresión sí
> están verificadas.

### 🎫 El ticket

> "Abro el ticket #3, le agrego la etiqueta 'facturación' desde el formulario de
> edición, le doy guardar y me dice que se guardó. Pero en la tabla el ticket
> sigue sin etiqueta. Si recargo con F5 ahí sí aparece. A veces me pasa y a veces
> no, no sé de qué depende.\"""",
"""> **Tiempo sugerido:** 40-60 min

### 🎫 El ticket

> "En la lista de tickets, al #3 le doy al botón de la etiqueta 'facturación' y
> no pasa nada: la fila sigue sin etiqueta. Si recargo con F5 ahí sí aparece.
> Con el #2 funciona a la primera. A veces me pasa y a veces no, no sé de qué
> depende.\""""),
("""### 🔧 Preparación

Un `db.json` alterno: el bug solo se ve con tickets que **no traen** el campo
`tags` desde el mock, y la semilla actual se lo pone a todos.

```bash
git checkout -- db.json          # guarda antes lo que tengas
cp mock/db.incidente-05.json db.json
```

El archivo alterno es el `db.seed.json` con una sola diferencia: a los tickets
1 y 3 se les quitó por completo la clave `tags` (no vacía: **ausente**).""",
"""### 🔧 Preparación

Una rama con el **etiquetado rápido** que el legacy le agregó a la lista, tal como
llegó a producción:

```bash
git switch -c incidente/05 fase-05-crud-tickets
```

En `components/tickets/TicketsTable.vue`, dos columnas más: la cabecera, después de
`<th>Asignado</th>`, y las celdas, después de la del `assignee`:

```html
<th>Etiquetas</th>
<th></th>
```

```html
<td>
  <span v-for="tag in ticket.tags" :key="tag" class="ticket-tag badge badge-light border mr-1">{{ tag }}</span>
</td>
<td>
  <!-- etiquetado rápido: .stop para que el clic no abra el detalle -->
  <button class="btn btn-sm btn-outline-info" @click.stop="$emit('add-tag', ticket)">
    🏷️ facturación
  </button>
</td>
```

En `views/TicketsView.vue`, el evento en la tabla y su método:

```html
<tickets-table :tickets="filteredTickets" @select="goToDetail" @add-tag="addBillingTag" />
```

```js
// etiquetado rápido: guarda en la Mock API y actualiza la fila sin recargar la lista
addBillingTag: function (ticket) {
  var tags = (ticket.tags || []).concat("facturación");
  ticketService.updateTicket(ticket.id, { tags: tags }).then(function (saved) {
    ticket.tags = saved.tags;
  });
},
```

Y en `db.json`, agrega `"tags": ["correo"]` **solo al ticket 2**. Los demás se
quedan sin la clave: no vacía, **ausente**. Al terminar, `git checkout -- db.json`
deja la semilla como estaba."""),
("""**Causa raíz.** Vue 2 hace reactivas las propiedades que **existen en el momento
en que el objeto entra en `data`**. Los tickets que el mock devuelve sin `tags`
entran sin esa propiedad, y el `ticket.tags = […]` posterior crea una propiedad
que ningún getter/setter vigila.""",
"""**Causa raíz.** Vue 2 hace reactivas las propiedades que **existen en el momento
en que el objeto entra en `data`**. Los tickets que el mock devuelve sin `tags`
entran sin esa propiedad, y el `ticket.tags = saved.tags` posterior crea una
propiedad que ningún getter/setter vigila. En el #2 la misma línea funciona porque
`tags` ya existía y tenía su setter."""),
("""**Parche mínimo** — el del viernes a las seis:

```js
// views/TicketsView.vue — al aplicar el ticket actualizado
onTicketUpdated: function (updated) {
  var index = this.tickets.findIndex(function (t) { return t.id === updated.id; });
  // splice y no tickets[index] = updated: la asignación por índice en un array
  // tampoco es reactiva en Vue 2. Son las dos caras de la misma limitación.
  if (index === -1) {
    this.tickets.push(updated);
  } else {
    this.tickets.splice(index, 1, updated);
  }
}
```""",
"""**Parche mínimo** — el del viernes a las seis:

```js
// views/TicketsView.vue
addBillingTag: function (ticket) {
  var self = this;
  var tags = (ticket.tags || []).concat("facturación");
  ticketService.updateTicket(ticket.id, { tags: tags }).then(function (saved) {
    // $set y no ticket.tags = …: una propiedad que no existía cuando el ticket
    // entró a data no es reactiva en Vue 2
    self.$set(ticket, "tags", saved.tags);
  });
},
```

La misma limitación tiene otra cara: asignar por índice en un array
(`this.tickets[i] = x`) tampoco es reactivo, y por eso el `onTicketUpdated` de la
Fase 8 reemplaza con `splice`."""),
("""**Por qué llegó a producción.** Porque en desarrollo la semilla es completa: todos
los tickets del `db.json` traen todos los campos, así que la propiedad siempre
existía cuando el objeto entraba y el bug era invisible. El primer ticket sin
`tags` lo creó un usuario meses después, por un camino que no ponía el campo.""",
"""**Por qué llegó a producción.** Porque la función se probó con el ticket que ya
tenía etiquetas, que era el que todos usaban para probar: la propiedad existía
cuando el objeto entraba y el bug era invisible. Los tickets sin `tags` eran casi
todos los demás, y nadie los etiquetó hasta producción."""),
]
for i, (a, b) in enumerate(E, 1):
    n = t.count(a)
    if n != 1:
        sys.exit(f"edición {i}: aparece {n} veces")
    t = t.replace(a, b)
open(p, "w", encoding="utf-8").write(t)
print(f"{len(E)} ediciones")
