// El fixture mínimo que ejercita TODOS los caminos del dashboard:
// 4 estados distintos, 3 prioridades, un asignado vacío y títulos
// diseñados para que la búsqueda discrimine.
export function makeTickets() {
  return [
    {
      id: 1, title: "Impresora no imprime", description: "La del piso 3",
      status: "open", priority: "high", assignee: "lmcorrea",
      reporter: "user1", createdAt: "2020-03-10T09:00:00Z"
    },
    {
      id: 2, title: "VPN caída", description: "No conecta desde casa",
      status: "in_progress", priority: "high", assignee: "agente2",
      reporter: "user2", createdAt: "2020-03-09T09:00:00Z"
    },
    {
      id: 3, title: "Solicitud de licencia", description: "Office para el nuevo",
      status: "resolved", priority: "low", assignee: "",
      reporter: "user1", createdAt: "2020-03-08T09:00:00Z"
    },
    {
      id: 4, title: "Impresora atascada", description: "Otra vez la del piso 3",
      status: "closed", priority: "medium", assignee: "lmcorrea",
      reporter: "user3", createdAt: "2020-03-07T09:00:00Z"
    }
  ];
}

// "impresora" → tickets 1 y 4 (dos, no uno: obliga al filtro a filtrar de verdad)
// "impresora" + status=open → solo el 1 (la COMBINACIÓN de filtros, que es
//                                         donde vive el bug clásico del &&)
