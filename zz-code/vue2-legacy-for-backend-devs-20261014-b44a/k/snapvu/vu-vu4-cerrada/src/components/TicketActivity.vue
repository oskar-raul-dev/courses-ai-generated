<template>
  <!-- Nada de <div class="card"> de Bootstrap: aquí manda <v-card>.
       ⚠️ Este componente ASUME que hay un <v-app> ancestro (VU1). Sin él,
       v-timeline no calcula sus estilos y el detalle es sutil de diagnosticar. -->
  <v-card outlined class="pa-4">
    <div class="d-flex align-center mb-4">
      <span class="text-h6">Actividad</span>
      <v-spacer />
      <v-chip v-if="live" small color="success" text-color="white">en vivo</v-chip>
    </div>

    <!-- 3 estados: loading / error / data. El patrón de F3, intacto -->
    <div v-if="loading" class="py-4">
      <v-skeleton-loader type="list-item-two-line@3" />
    </div>

    <v-alert v-else-if="error" type="error" dense text>
      No se pudo cargar la actividad.
      <template v-slot:append>
        <v-btn small text @click="load">Reintentar</v-btn>
      </template>
    </v-alert>

    <div v-else-if="entries.length === 0" class="text--secondary py-4">
      Sin actividad todavía.
    </div>

    <!-- ⭐ El timeline. dense = todo a un lado, compacto (cabe en la columna del detalle) -->
    <v-timeline v-else dense>
      <v-timeline-item
        v-for="e in entries"
        :key="e.id"
        :color="meta(e.type).color"
        :icon="meta(e.type).icon"
        small
        fill-dot
      >
        <!-- La fecha va enfrentada al nodo. En dense se ve como subtítulo. -->
        <template v-slot:opposite>
          <span class="text-caption text--secondary">{{ formatDate(e.at) }}</span>
        </template>

        <div class="d-flex align-center flex-wrap">
          <!-- ⭐ EL CHIP CLAVE: color = rol del tema. Cambia el tema → cambia esto.
               NUNCA un hex aquí. Si escribes color="#ff9800" pierdes la fase. -->
          <v-chip
            small
            label
            :color="meta(e.type).color"
            text-color="white"
            class="mr-2"
          >
            <v-icon left small>{{ meta(e.type).icon }}</v-icon>
            {{ meta(e.type).label }}
          </v-chip>
          <span class="font-weight-medium">{{ e.actor }}</span>
        </div>

        <div class="text-body-2 mt-1">{{ describe(e) }}</div>
      </v-timeline-item>
    </v-timeline>
  </v-card>
</template>

<script>
import activityService from "../services/activityService";
import socketService from "../services/socketService"; // F8, sin tocar

// ⭐ Mapa de tipos: fuera de data() — es una constante, no estado reactivo.
// (Misma disciplina que el chart de F7 y el socket de F8: lo que no cambia, no reacciona.)
//
// 🎨 LA DECISIÓN DE LA FASE ESTÁ AQUÍ: el `color` es un ROL del tema
// (primary/warning/error/...), NO un hex ni una clase. Vuetify lo resuelve
// contra theme.themes.light — o theme.themes.dark si el modo oscuro está activo.
// Cambiar el look de TODOS los timelines del sistema = editar vuetify.js, no esto.
var TYPE_META = {
  created:         { label: "creado",     color: "primary", icon: "mdi-plus-circle" },
  status_change:   { label: "estado",     color: "warning", icon: "mdi-swap-horizontal" },
  assigned:        { label: "asignado",   color: "info",    icon: "mdi-account-plus" },
  priority_change: { label: "prioridad",  color: "error",   icon: "mdi-priority-high" },
  comment:         { label: "comentario", color: "success", icon: "mdi-comment-text" }
};
// El fallback también usa un rol (grey), no un hex: degrada Y sigue respetando el tema.
var FALLBACK = { label: "evento", color: "grey", icon: "mdi-circle-small" };

export default {
  name: "TicketActivity",

  props: {
    ticketId: { type: [Number, String], required: true }
  },

  data: function () {
    return {
      entries: [],   // 🎯 LOCAL, no Vuex. Ver Concepto 5.
      loading: false,
      error: null,
      live: false,
      onActivityHandler: null // referencia estable para el off(). F8, lección 1.
    };
  },

  methods: {
    meta: function (type) {
      return TYPE_META[type] || FALLBACK; // degrada, no revienta
    },

    describe: function (e) {
      if (e.type === "comment") return e.to;
      if (e.from === null) return e.to;
      return e.from + " → " + e.to;
    },

    formatDate: function (iso) {
      return new Date(iso).toLocaleString();
    },

    load: function () {
      var self = this;
      this.loading = true;
      this.error = null;

      return activityService
        .getByTicket(this.ticketId)
        .then(function (data) {
          self.entries = data;
        })
        .catch(function (err) {
          self.error = err;
        })
        .finally(function () {
          self.loading = false;
        });
    },

    onActivity: function (activity) {
      // 🔎 El socket es un canal ABIERTO: llegan eventos de TODOS los tickets.
      // Filtrar por ticketId no es opcional. (El ejercicio 18 lo arregla con rooms.)
      if (String(activity.ticketId) !== String(this.ticketId)) return;

      // unshift: orden descendente, lo nuevo arriba. Método parcheado por Vue 2 → reactivo.
      this.entries.unshift(activity);
    }
  },

  mounted: function () {
    this.load();

    this.onActivityHandler = this.onActivity.bind(this);
    socketService.on("activity:created", this.onActivityHandler);
    this.live = socketService.isConnected();
  },

  beforeDestroy: function () {
    // Simétrico y completo. Todo lo que se suscribe, se desuscribe. (F8)
    socketService.off("activity:created", this.onActivityHandler);
    this.onActivityHandler = null;
  }
};
</script>
