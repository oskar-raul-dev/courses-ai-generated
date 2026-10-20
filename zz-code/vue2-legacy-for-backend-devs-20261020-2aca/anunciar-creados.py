#!/usr/bin/env python3
"""Rutas VU y Q: los caminos de creación migrados vuelven a anunciar ticket:created (como F8).
Edita los documentos del curso y los árboles validados de las rutas. Uso: python3 -I anunciar-creados.py <raíz del repo>
"""
import os
import re
import sys

R = sys.argv[1]
C = os.path.join(R, "cursos-legacy/vue2-legacy-for-backend-devs/01-vue2-legacy")
T = os.path.join(R, "zz-code/vue2-legacy-for-backend-devs-20261014-b44a/rutas")
EMIT = 'socketService.emit("ticket:created", created); // 📣 anunciar a los demás, como en F8'
IMP = 'import socketService from "../services/socketService";'

def upsert(texto, esperado):
    # después de cada commit UPSERT de un ticket recién creado, con la misma indentación
    pat = re.compile(r'^(\s*)self\.\$store\.commit\("tickets/UPSERT_TICKET", created\);\n', re.M)
    n = len(pat.findall(texto))
    assert n == esperado, (n, esperado)
    return pat.sub(lambda m: m.group(0) + m.group(1) + EMIT + "\n", texto)

def importar(texto, esperado):
    pat = re.compile(r'^import ticketService from "\.\./services/ticketService";\n', re.M)
    n = len(pat.findall(texto))
    assert n == esperado, (n, esperado)
    return pat.sub(lambda m: m.group(0) + IMP + "\n", texto)

def editar(p, f):
    t = open(p, encoding="utf-8").read()
    t2 = f(t)
    open(p, "w", encoding="utf-8").write(t2)
    print("editado", os.path.relpath(p, R))

editar(os.path.join(C, "vu2-migrar-crud-vuetify.md"), lambda t: importar(upsert(t, 1), 1))
editar(os.path.join(C, "vu3-migrar-dashboard-vdatatable.md"), lambda t: importar(upsert(t, 1), 1))
editar(os.path.join(C, "q3-migrar-dashboard-qtable.md"), lambda t: importar(upsert(t, 2), 1))
q2 = '''        .then(function (created) {
          self.$q.notify({ type: "positive", message: "Ticket creado ✅" });'''
q2n = '''        .then(function (created) {
          socketService.emit("ticket:created", created); // 📣 anunciar a los demás, como en F8
          self.$q.notify({ type: "positive", message: "Ticket creado ✅" });'''
def f_q2(t):
    assert t.count(q2) == 1
    t = t.replace(q2, q2n)
    a = 'import TicketForm from "../components/tickets/TicketForm.vue";\nimport ticketService from "../services/ticketService";\n\nexport default {\n  name: "TicketCreateView",'
    assert t.count(a) == 1
    return t.replace(a, a.replace('import ticketService from "../services/ticketService";\n', 'import ticketService from "../services/ticketService";\n' + IMP + "\n"))
editar(os.path.join(C, "q2-migrar-crud-qform.md"), f_q2)
# árboles validados
editar(os.path.join(T, "vu/tiquetera-legacy/src/views/TicketsView.vue"), lambda t: importar(upsert(t, 1), 1))
editar(os.path.join(T, "q/tiquetera-q/src/views/TicketsView.vue"), lambda t: importar(upsert(t, 1), 1))
def f_q2t(t):
    assert t.count(q2) == 1
    return importar(t.replace(q2, q2n), 1)
editar(os.path.join(T, "q/tiquetera-q/src/views/TicketCreateView.vue"), f_q2t)
