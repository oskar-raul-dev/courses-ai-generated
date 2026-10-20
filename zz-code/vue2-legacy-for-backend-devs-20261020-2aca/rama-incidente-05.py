#!/usr/bin/env python3
"""Aplica la rama incidente/05 (lo que publica la preparación del cuaderno) sobre un árbol de la Fase 5
(aquí, el estado final de F7) y crea mock/db.incidente-05.json. Uso: python3 -I rama-incidente-05.py <árbol>
"""
import json
import os
import sys

R = sys.argv[1]

def editar(rel, pares):
    p = os.path.join(R, rel)
    t = open(p, encoding="utf-8").read()
    for a, b in pares:
        assert t.count(a) == 1, (rel, a[:50])
        t = t.replace(a, b)
    open(p, "w", encoding="utf-8").write(t)

editar("src/components/tickets/TicketsTable.vue", [
("""          <th>Asignado</th>
""", """          <th>Asignado</th>
          <th>Etiquetas</th>
          <th></th>
"""),
("""          <td>{{ ticket.assignee }}</td>
""", """          <td>{{ ticket.assignee }}</td>
          <td>
            <span v-for="tag in ticket.tags" :key="tag" class="ticket-tag badge badge-light border mr-1">{{ tag }}</span>
          </td>
          <td>
            <!-- etiquetado rápido: .stop para que el clic no abra el detalle -->
            <button class="btn btn-sm btn-outline-info" @click.stop="$emit('add-tag', ticket)">
              🏷️ facturación
            </button>
          </td>
"""),
])
editar("src/views/TicketsView.vue", [
("""<tickets-table :tickets="filteredTickets" @select="goToDetail" />""",
 """<tickets-table :tickets="filteredTickets" @select="goToDetail" @add-tag="addBillingTag" />"""),
("""    goToDetail: function (ticket) {""",
 """    // etiquetado rápido: guarda en la Mock API y actualiza la fila sin recargar la lista
    addBillingTag: function (ticket) {
      var tags = (ticket.tags || []).concat("facturación");
      ticketService.updateTicket(ticket.id, { tags: tags }).then(function (saved) {
        ticket.tags = saved.tags;
      });
    },
    goToDetail: function (ticket) {"""),
])
d = json.load(open(os.path.join(R, "db.json"), encoding="utf-8"))
for t in d["tickets"]:
    if t["id"] == 2:
        t["tags"] = ["correo"]
os.makedirs(os.path.join(R, "mock"), exist_ok=True)
json.dump(d, open(os.path.join(R, "mock/db.incidente-05.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print("rama aplicada; mock/db.incidente-05.json con tags solo en el ticket 2")
