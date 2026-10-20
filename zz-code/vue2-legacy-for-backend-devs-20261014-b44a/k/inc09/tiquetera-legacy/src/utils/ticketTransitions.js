// La máquina de estados del ticket. UNA fuente de verdad para
// qué movimientos existen y cómo se llaman de cara al usuario.
export var TRANSITIONS = {
  open:        ["in_progress"],
  in_progress: ["resolved", "open"],
  resolved:    ["closed", "open"],
  closed:      ["open"]
};

export var TRANSITION_LABELS = {
  in_progress: { label: "▶️ Empezar a trabajar", css: "btn-warning" },
  resolved:    { label: "✅ Marcar resuelto",    css: "btn-success" },
  closed:      { label: "🔒 Cerrar",             css: "btn-secondary" },
  open:        { label: "↩️ Reabrir",            css: "btn-outline-danger" }
};

export function nextStatuses(status) {
  return TRANSITIONS[status] || [];
}
