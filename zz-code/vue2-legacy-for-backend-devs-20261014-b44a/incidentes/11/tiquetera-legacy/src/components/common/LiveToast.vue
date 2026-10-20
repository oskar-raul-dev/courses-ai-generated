<template>
  <div
    v-if="visible"
    class="position-fixed"
    style="bottom: 20px; right: 20px; z-index: 1050; min-width: 300px;"
  >
    <div class="card shadow border-primary" style="cursor: pointer;" @click="go">
      <div class="card-body py-2 px-3">
        <strong>🎫 Nuevo ticket #{{ ticket.id }}</strong>
        <div class="small text-muted">{{ ticket.title }}</div>
      </div>
    </div>
  </div>
</template>

<script>
import socketService from "../../services/socketService";

export default {
  name: "LiveToast",
  data: function () {
    return { ticket: null, visible: false };
  },
  mounted: function () {
    // guardamos la referencia enlazada para poder darla de baja idéntica
    this.handler = this.onTicketCreated.bind(this);
    socketService.on("ticket:created", this.handler);
  },
  beforeDestroy: function () {
    socketService.off("ticket:created", this.handler);
    clearTimeout(this.timer);
  },
  methods: {
    onTicketCreated: function (ticket) {
      this.ticket = ticket;
      this.visible = true;
      clearTimeout(this.timer);
      this.timer = setTimeout(this.hide.bind(this), 5000); // timer NO reactivo
    },
    hide: function () {
      this.visible = false;
    },
    go: function () {
      this.hide();
      this.$router.push("/tickets/" + this.ticket.id);
    }
  }
};
</script>
