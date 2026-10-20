var __a = [
// ...imports previos



// dentro de routes:
{ path: "/tickets", name: "tickets", component: TicketsView, meta: { requiresAuth: true } },

// ⚠️ /tickets/new ANTES que /tickets/:id — si no, "new" se interpreta
// como un :id (lo viste venir en el ejercicio 22 de la Fase 1 😉)
{ path: "/tickets/new", name: "ticket-create", component: TicketCreateView, meta: { requiresAuth: true } },
{ path: "/tickets/:id", name: "ticket-detail", component: TicketDetailView, meta: { requiresAuth: true } },
{ path: "/tickets/:id/edit", name: "ticket-edit", component: TicketEditView, meta: { requiresAuth: true } },
];