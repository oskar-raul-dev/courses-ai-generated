#!/usr/bin/env python3
"""K4: identificadores en español → inglés (guía §5), solo en contextos de código.
Uso: renombrar-k4.py  (desde la raíz del repositorio; imprime cuántos cambios hace cada regla)"""
import pathlib, re
C = "cursos-legacy/vue2-legacy-for-backend-devs/01-vue2-legacy/"
Z = "zz-code/vue2-legacy-for-backend-devs-20261014-b44a/"
NETS = [C + "q0-red-de-seguridad.md", C + "vu0-red-de-seguridad.md"] + \
       [Z + r + "/tests/unit/regression/" + f for r in ("rutas/base/tiquetera-legacy", "rutas/vu0/tiquetera-legacy",
        "rutas/vu/tiquetera-legacy", "rutas/q/tiquetera-q", "k/snapq/q-q2-cerrada", "k/snapq/q-q3-cerrada",
        "k/snapq/q-q4-cerrada", "k/snapq/q-port") for f in ("ticketForm.spec.js", "dashboard.spec.js")]
Q2H = [C + "q2-migrar-crud-qform.md", C + "q3-migrar-dashboard-qtable.md"] + \
      [Z + r + "/tests/unit/regression/" + f for r in ("rutas/q/tiquetera-q", "k/snapq/q-q2-cerrada", "k/snapq/q-q3-cerrada",
       "k/snapq/q-q4-cerrada") for f in ("ticketForm.spec.js", "dashboard.spec.js")]
RULES = [C + "q2-migrar-crud-qform.md"] + [Z + r + "/src/utils/rules.js" for r in ("rutas/q/tiquetera-q", "k/snapq/q-q2-cerrada", "k/snapq/q-q3-cerrada", "k/snapq/q-q4-cerrada")]
Q3V = [C + "q3-migrar-dashboard-qtable.md"] + [Z + r + "/src/views/TicketsView.vue" for r in ("rutas/q/tiquetera-q", "k/snapq/q-q3-cerrada", "k/snapq/q-q4-cerrada")]
NX4 = [C + "nx4-pagina-ssr-nueva.md", Z + "rutas/nx1/tiquetera-nx/pages/tickets/_id/activity.vue"]
R = [
 (NETS, r"\bVALIDO\b", "VALID"),
 (NETS, r"function rechaza\(valores\)", "function rejects(values)"),
 (NETS, r"VALID, valores\)", "VALID, values)"),
 (NETS, r"return rechaza\(", "return rejects("),
 (NETS, r"const boton = ", "const button = "),
 (NETS, r"\bboton\.attributes", "button.attributes"),
 (NETS, r"const texto = ", "const text = "),
 (NETS, r"expect\(texto\)", "expect(text)"),
 (Q2H, r"function campo\(", "function field("),
 (Q2H, r"\bcampo\(wrapper", "field(wrapper"),
 (Q2H, r"function elegir\(", "function pick("),
 (Q2H, r"\belegir\(", "pick("),
 (Q2H, r"`elegir\(\)`", "`pick()`"),
 (Q2H, r"const opcion = ", "const option = "),
 (Q2H, r"\(opcion === undefined\)", "(option === undefined)"),
 (Q2H, r"toggleOption\(opcion\)", "toggleOption(option)"),
 (Q2H, r"function enviar\(wrapper\)", "function submitForm(wrapper)"),
 (Q2H, r"\benviar\(wrapper\)", "submitForm(wrapper)"),
 (Q2H, r"un `enviar` que espera la promesa, un `campo` que", "un `submitForm` que espera la promesa, un `field` que"),
 ([C + "q2-migrar-crud-qform.md", C + "vu2-migrar-crud-vuetify.md"], r"(this|self)\.enviar\(\)", r"\1.save()"),
 ([C + "q2-migrar-crud-qform.md"], r"\besValido\b", "isValid"),
 ([C + "q2-migrar-crud-qform.md"], r"\bconfirmandoBorrado\b", "confirmingDelete"),
 ([C + "q2-migrar-crud-qform.md"], r"\bremoveTicketConDialogo\b", "removeTicketWithDialog"),
 (RULES, r"oneOf\(valores, mensaje\)", "oneOf(values, message)"),
 (RULES, r"return valores\.indexOf\(val\) !== -1 \|\| \(mensaje \|\|", "return values.indexOf(val) !== -1 || (message ||"),
 (Q3V, r"var guardar = ticket", "var request = ticket"),
 (Q3V, r"return guardar\n", "return request\n"),
 ([C + "nx2-hidratacion-window-not-defined.md"], r"\{\{ ahora \}\}", "{{ loadedAt }}"),
 ([C + "nx2-hidratacion-window-not-defined.md"], r"^(\s*)ahora: function", r"\1loadedAt: function"),
 ([C + "nx2-hidratacion-window-not-defined.md"], r"\{ ahora: \"\" \}", '{ loadedAt: "" }'),
 ([C + "nx2-hidratacion-window-not-defined.md"], r"this\.ahora = ", "this.loadedAt = "),
 ([C + "nx2-hidratacion-window-not-defined.md"], r"`ahora`", "`loadedAt`"),
 (NX4, r"\bonNuevaActividad\b", "onNewActivity"),
 (NX4, r"this\.usuarioActual\.username", "this.$store.getters[\"auth/currentUser\"].username"),
 (NX4, r"from: estadoAnterior,", "from: previousStatus,"),
 (NX4, r"to: nuevoEstado,", "to: newStatus,"),
 (NX4, r"var evento = \{", "var activity = {"),
 (NX4, r'emit\("activity:created", evento\)', 'emit("activity:created", activity)'),
 ([C + "q1-leer-quasar.md"], r"this\.mensaje = ", "this.message = "),
 ([C + "q1-leer-quasar.md"], r"\btipoAlerta\b", "alertType"),
 ([C + "q1-leer-quasar.md"], r"\bmostrarAlerta\b", "showAlert"),
 ([C + "q1-leer-quasar.md"], r"\bticketAEliminar\b", "ticketToDelete"),
 ([C + "q1-leer-quasar.md"], r"\bmostrarModalConfirmacion\b", "showConfirmModal"),
 ([C + "q1-leer-quasar.md"], r"\bmostrarModal\b", "showModal"),
 ([C + "q1-leer-quasar.md"], r"confirmarEliminacion\(\), y otro cancelar\(\)", "confirmDelete(), y otro cancel()"),
 ([C + "q1-leer-quasar.md"], r"^(\s*)guardar: function", r"\1save: function"),
 ([C + "q1-leer-quasar.md"], r"^(\s*)eliminar: function", r"\1remove: function"),
 ([C + "q1-leer-quasar.md"], r"'tickets/eliminar'", "'tickets/deleteTicket'"),
 ([C + "q1-leer-quasar.md"], r"'tickets/cargar', id", "'tickets/deleteTicket', id"),
 ([C + "q1-leer-quasar.md"], r'@click="eliminar"', '@click="remove"'),
 ([C + "q1-leer-quasar.md"], r"^(\s*)eliminar \(\) \{", r"\1remove () {"),
 ([C + "q1-leer-quasar.md"], r"`eliminar \(\) \{\}` shorthand", "`remove () {}` shorthand"),
 ([C + "q1-leer-quasar.md"], r"ticket\.titulo", "ticket.title"),
 ([C + "q1-leer-quasar.md"], r"ticket\.prioridad", "ticket.priority"),
]
for files, pat, rep in R:
    total = 0
    for f in files:
        p = pathlib.Path(f)
        if not p.exists(): continue
        s = p.read_text(encoding="utf-8"); n = len(re.findall(pat, s, flags=re.M))
        if n: p.write_text(re.sub(pat, rep, s, flags=re.M), encoding="utf-8"); total += n
    print(f"{total:3}  {pat}")
