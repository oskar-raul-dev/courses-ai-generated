// src/services/activityEmitter.js
// 💸 ESTO NO DEBERÍA EXISTIR. Ver la sección de deuda.
import activityService from "./activityService";
import socketService from "./socketService"; // el de F8, intacto

function record(evt) {
  var activity = {
    ticketId: evt.ticketId,
    type: evt.type,
    actor: evt.actor,
    from: evt.from === undefined ? null : evt.from,
    to: evt.to === undefined ? null : evt.to,
    at: new Date().toISOString() // 💸 el reloj del CLIENTE. Ver deuda.
  };

  // 1) persistir  → para el que entre después y haga GET
  // 2) emitir     → para el que YA está mirando el ticket ahora
  return activityService.create(activity).then(function (saved) {
    socketService.emit("activity:created", saved); // emitimos el guardado (trae id real)
    return saved;
  });
}

export default { record: record };
