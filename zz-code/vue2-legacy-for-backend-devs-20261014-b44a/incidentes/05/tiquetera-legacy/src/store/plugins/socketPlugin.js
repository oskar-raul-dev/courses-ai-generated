// store/plugins/socketPlugin.js
import socketService from "../../services/socketService";

export default function socketPlugin(store) {
  // Nota: connect/disconnect siguen siendo del watch de App.vue (vida = sesión).
  // El plugin solo REGISTRA qué hacer cuando lleguen eventos.
  socketService.on("ticket:created", function (ticket) {
    store.commit("tickets/UPSERT_TICKET", ticket);
    store.commit("ui/FLASH", { type: "info", text: "🎫 Nuevo ticket #" + ticket.id });
  });

  socketService.on("ticket:updated", function (ticket) {
    store.commit("tickets/UPSERT_TICKET", ticket);
  });
}
