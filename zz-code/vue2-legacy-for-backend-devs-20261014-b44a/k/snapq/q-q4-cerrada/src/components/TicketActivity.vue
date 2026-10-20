<template>
  <!-- Nada de <div class="card"> de Bootstrap: aquí mandan QCard y q-pa-md (Q1) -->
  <q-card flat bordered class="q-pa-md">
    <div class="row items-center q-mb-md">
      <div class="text-h6 col">Actividad</div>
      <q-badge v-if="live" color="green" align="middle">en vivo</q-badge>
    </div>

    <!-- 3 estados: loading / error / data. El patrón de F3, intacto -->
    <div v-if="loading" class="q-py-md">
      <q-skeleton type="text" v-for="n in 3" :key="n" class="q-mb-sm" />
    </div>

    <q-banner v-else-if="error" dense class="bg-red-1 text-red-9">
      No se pudo cargar la actividad.
      <template v-slot:action>
        <q-btn flat dense label="Reintentar" @click="load" />
      </template>
    </q-banner>

    <div v-else-if="entries.length === 0" class="text-grey-7 q-py-md">
      Sin actividad todavía.
    </div>

    <q-timeline v-else color="primary" layout="comfortable">
      <q-timeline-entry
        v-for="e in entries"
        :key="e.id"
        :icon="meta(e.type).icon"
        :color="meta(e.type).color"
        :subtitle="formatDate(e.at)"
      >
        <template v-slot:title>
          <q-chip
            dense
            square
            :color="meta(e.type).color"
            text-color="white"
            :icon="meta(e.type).icon"
          >
            {{ meta(e.type).label }}
          </q-chip>
          <span class="text-weight-medium q-ml-sm">{{ e.actor }}</span>
        </template>

        <div class="text-body2">{{ describe(e) }}</div>
      </q-timeline-entry>
    </q-timeline>
  </q-card>
</template>

<script>
import activityService from "../services/activityService";
import socketService from "../services/socketService"; // F8, sin tocar

// Mapa de tipos: fuera de data() — es una constante, no estado reactivo.
// (Misma disciplina que el chart de F7 y el socket de F8: lo que no cambia, no reacciona.)
var TYPE_META = {
  created:         { label: "creado",     color: "primary", icon: "add_circle" },
  status_change:   { label: "estado",     color: "orange",  icon: "swap_horiz" },
  assigned:        { label: "asignado",   color: "purple",  icon: "person_add" },
  priority_change: { label: "prioridad",  color: "red",     icon: "priority_high" },
  comment:         { label: "comentario", color: "teal",    icon: "chat_bubble" }
};
var FALLBACK = { label: "evento", color: "grey", icon: "circle" };

export default {
  name: "TicketActivity",

  props: {
    ticketId: { type: [Number, String], required: true }
  },

  data: function () {
    return {
      entries: [],   // 🎯 LOCAL, no Vuex. Ver Concepto 4.
      loading: false,
      error: null,
      live: false,
      onActivityHandler: null // la referencia estable para el off(). F8, lección 1.
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
          self.$q.notify({ type: "negative", message: "Error cargando actividad" });
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
