#!/usr/bin/env python3
"""K5: aplica a los repos de las rutas Q y VU lo que Q4/VU4 publican y no se había integrado,
y corrige los fragmentos de los documentos. Desde la raíz del repositorio."""
import json, pathlib, re
C = pathlib.Path("cursos-legacy/vue2-legacy-for-backend-devs/01-vue2-legacy")
Z = pathlib.Path("zz-code/vue2-legacy-for-backend-devs-20261014-b44a")
Q, VU = Z / "rutas/q/tiquetera-q", Z / "rutas/vu/tiquetera-legacy"

def ed(p, o, n, cuenta=1):
    s = p.read_text(encoding="utf-8"); assert s.count(o) == cuenta, (str(p), o[:60], s.count(o))
    p.write_text(s.replace(o, n), encoding="utf-8")

# 1) before || {}: documentos y repo Q (el VU recibe la action entera más abajo)
for f in (C / "q4-timeline-actividad.md", C / "vu4-timeline-vuetify.md", Q / "src/store/modules/tickets.js"):
    ed(f, "var before = context.getters.ticketById(payload.id); // getter-función de F10",
          "// || {}: si el ticket no está en el store (llegó por otra vía), no hay \"antes\" que comparar\n"
          "    var before = context.getters.ticketById(payload.id) || {}; // getter-función de F10"
          if "tickets.js" in str(f) else
          "// || {}: si el ticket no está en el store (llegó por otra vía), no hay \"antes\" que comparar\n"
          "  var before = context.getters.ticketById(payload.id) || {}; // getter-función de F10")

# 2) VU: la action de VU4 §4, tal cual la publica el documento
vu4 = (C / "vu4-timeline-vuetify.md").read_text(encoding="utf-8")
m = re.search(r"```js\n(// store/modules/tickets\.js[^\n]*\n(updateTicket: function.*?\n\}))\n```", vu4, re.S)
accion = m.group(2)
accion = "\n".join(("  " + l) if l else l for l in accion.splitlines())
t = (VU / "src/store/modules/tickets.js").read_text(encoding="utf-8")
a = t.index("  updateTicket: function (context, payload) {"); b = t.index("\n};\n\nexport default")
t = t[:a] + accion + t[b:]
t = t.replace('import ticketService from "../../services/ticketService";',
              'import ticketService from "../../services/ticketService";\nimport activityEmitter from "../../services/activityEmitter";', 1)
(VU / "src/store/modules/tickets.js").write_text(t, encoding="utf-8")

# 3) VU: db.json y relé (los de VU4 §1 y §3)
bl = json.loads((Z / "k/bloques.json").read_text(encoding="utf-8"))
act = [b for b in bl if b["archivo"].endswith("vu4-timeline-vuetify.md") and '"activity": [' in b["codigo"]][0]["codigo"]
d = json.loads((VU / "db.json").read_text()); d["activity"] = json.loads(act)["activity"]
(VU / "db.json").write_text(json.dumps(d, indent=2, ensure_ascii=False) + "\n")
s = (VU / "server/socket-server.js").read_text()
if "activity:created" not in s:
    i = s.index('  socket.on("disconnect"')
    s = s[:i] + '''  // añadir junto a ticket:created
  socket.on("activity:created", function (activity) {
    socket.broadcast.emit("activity:created", activity); // a todos menos al emisor
  });

''' + s[i:]
    (VU / "server/socket-server.js").write_text(s)

# 4) Detalle: el timeline junto al detalle de F5 (el formulario vive en TicketEditView)
DET_Q = '''    <div v-else-if="ticket" class="row q-col-gutter-md">
      <div class="col-12 col-md-7">'''
DET_VU = '''    <v-row v-else-if="ticket">
      <v-col cols="12" md="7">'''
for repo, ini, cierre_col, cierre_fila, imp in (
        (Q, DET_Q, "      </div>\n      <div class=\"col-12 col-md-5\">\n        <!-- :key fuerza el remount al cambiar de ticket: la lista muere y renace. A propósito. -->\n        <ticket-activity :key=\"ticket.id\" :ticket-id=\"ticket.id\" />\n      </div>\n    </div>", None, None),
        (VU, DET_VU, "      </v-col>\n      <v-col cols=\"12\" md=\"5\">\n        <!-- :key fuerza el remount al cambiar de ticket: la lista muere y renace. A propósito. -->\n        <ticket-activity :key=\"ticket.id\" :ticket-id=\"ticket.id\" />\n      </v-col>\n    </v-row>", None, None)):
    p = repo / "src/views/TicketDetailView.vue"; s = p.read_text()
    if "ticket-activity" in s: continue
    a = s.index('    <div v-else-if="ticket">'); b = s.index("  </section>\n</template>")
    cuerpo = s[a + len('    <div v-else-if="ticket">\n'):b]
    cuerpo = cuerpo[:cuerpo.rindex("    </div>\n")]
    cuerpo = "\n".join(("  " + l) if l else l for l in cuerpo.splitlines())
    s = s[:a] + ini + "\n" + cuerpo + "\n" + cierre_col + "\n" + s[b:]
    s = s.replace('import PageTitle from "../components/common/PageTitle.vue";',
                  'import PageTitle from "../components/common/PageTitle.vue";\nimport TicketActivity from "../components/TicketActivity.vue";')
    s = s.replace("components: { PageTitle },", "components: { PageTitle, TicketActivity },")
    p.write_text(s)

# 5) VU: el interruptor de dark mode, AÑADIDO al AppHeader de F8 (no un header nuevo)
p = VU / "src/components/layout/AppHeader.vue"; s = p.read_text()
if "toggleDark" not in s:
    s = s.replace('''      <span class="mr-3">{{ currentUser.name }}</span>''', '''      <!-- VU4: el interruptor. Un flag. Nada más. -->
      <v-btn icon dark small class="mr-2" @click="toggleDark" :title="dark ? 'Modo claro' : 'Modo oscuro'">
        <v-icon>{{ dark ? "mdi-weather-sunny" : "mdi-weather-night" }}</v-icon>
      </v-btn>
      <span class="mr-3">{{ currentUser.name }}</span>''')
    s = s.replace('''    currentUser: function () {
      return this.$store.getters["auth/currentUser"];
    }
  },''', '''    currentUser: function () {
      return this.$store.getters["auth/currentUser"];
    },
    dark: function () {
      return this.$vuetify.theme.dark; // lectura reactiva del flag global
    }
  },''')
    s = s.replace('''  methods: {
    logout: function () {''', '''  methods: {
    toggleDark: function () {
      this.$vuetify.theme.dark = !this.$vuetify.theme.dark; // una línea. Toda la app responde.
      // (persistir en localStorage → ejercicio 🟢 5)
    },
    logout: function () {''')
    p.write_text(s)
print("ok")
