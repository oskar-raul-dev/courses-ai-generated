<template>
  <!-- transición de página de Nuxt: el name casa con el CSS de más abajo -->
  <div class="activity-page">
    <h1>Actividad · {{ ticket.title }}</h1>
    <p class="text-muted">Ticket #{{ ticket.id }}</p>

    <!-- indicador en vivo: reutiliza la idea del header de F8 -->
    <span v-if="isLive" class="badge badge-success">🟢 en vivo</span>
    <span v-else class="badge badge-secondary">🔴 histórico</span>

    <!-- maquetado A MANO con Bootstrap (sigue cargado). NO hay componente
         de timeline del framework: Nuxt no es UI. Esto es lo propio de NX4. -->
    <ul class="list-unstyled timeline mt-3">
      <li v-for="ev in activity" :key="ev.id" class="timeline-item">
        <span class="timeline-dot" :class="'dot-' + ev.type"></span>
        <strong>{{ ev.actor }}</strong>
        <span>{{ describir(ev) }}</span>
        <time class="text-muted">{{ formatear(ev.at) }}</time>
      </li>
    </ul>
  </div>
</template>

<script>
import activityService from "~/services/activityService";
import ticketService from "~/services/ticketService";
import socketService from "~/services/socketService";

export default {
  // ── 1. PORTERO: corre antes que nada. Rechaza ids no numéricos sin tocar la API.
  validate: function (context) {
    return /^\d+$/.test(context.params.id);
  },

  // ── 2. SERVIDOR: el PASADO. Corre en Node, sin `this`, antes de renderizar.
  async asyncData(context) {
    var id = context.params.id;
    try {
      // dos llamadas en paralelo: el ticket (para el título/head) y su historial
      var results = await Promise.all([
        ticketService.getTicketById(id),
        activityService.getByTicket(id)
      ]);
      return {
        ticket: results[0],
        activity: results[1] // ← el array llega YA lleno y se pinta en el HTML
      };
    } catch (e) {
      // el recurso no existe → 404 renderizado en el servidor
      context.error({ statusCode: 404, message: "Ticket no encontrado" });
    }
  },

  // `data` solo declara lo que NO viene del servidor: el estado de conexión.
  // `ticket` y `activity` los inyecta asyncData y se fusionan aquí.
  data: function () {
    return {
      isLive: false
    };
  },

  // ── 3. head DINÁMICO: corre en el servidor, viaja en el HTML. SEO/preview.
  head: function () {
    return {
      title: "Actividad · " + this.ticket.title,
      meta: [
        {
          hid: "description",
          name: "description",
          content: "Historial del ticket #" + this.ticket.id + ": " + this.ticket.title
        }
      ]
    };
  },

  // ── 4. CLIENTE: el FUTURO. Solo aquí, solo tras hidratar. Toca el socket.
  mounted: function () {
    // ❗ NO re-fetcheamos el historial: asyncData ya lo trajo y ya está pintado.
    // mounted SOLO se suscribe a lo que llegue DE AHORA EN ADELANTE.
    socketService.on("activity:created", this.onNewActivity);
    socketService.connect(); // en Nuxt no hay App.vue que conecte: idempotente, como en F8
    this.isLive = socketService.isConnected();
  },

  // baja simétrica: todo lo que se suscribe, se desuscribe (regla de F8).
  beforeDestroy: function () {
    socketService.off("activity:created", this.onNewActivity);
  },

  methods: {
    onNewActivity: function (ev) {
      // solo eventos de ESTE ticket (el socket difunde los de todos)
      if (String(ev.ticketId) !== String(this.ticket.id)) return;
      // unshift = reactivo en Vue 2 (F8). Reasignar por índice NO lo sería.
      this.activity.unshift(ev);
    },
    describir: function (ev) {
      if (ev.type === "status_change") return "cambió el estado de " + ev.from + " a " + ev.to;
      if (ev.type === "assignee_change") return "reasignó a " + ev.to;
      if (ev.type === "comment_added") return "comentó: " + ev.to;
      return ev.type;
    },
    formatear: function (iso) {
      return new Date(iso).toLocaleString();
    }
  }
};
</script>

<style scoped>
/* transición de página de Nuxt: nombra la transición en nuxt.config.js
   (pageTransition: 'fade') o por página con `transition: 'fade'` en el
   export. Estas clases las aplica Nuxt solo. */
.fade-enter-active, .fade-leave-active { transition: opacity 0.25s; }
.fade-enter, .fade-leave-to { opacity: 0; }

.timeline-item { padding: 0.5rem 0 0.5rem 1.5rem; border-left: 2px solid #dee2e6; position: relative; }
.timeline-dot { position: absolute; left: -6px; width: 10px; height: 10px; border-radius: 50%; background: #6c757d; }
.dot-status_change { background: #ffc107; }
.dot-comment_added { background: #17a2b8; }
</style>
