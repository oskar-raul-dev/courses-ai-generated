var __o = {
// El listado del contrato: GET /tickets?status=open&_sort=createdAt&_order=desc
// E: status (igualdad) · S: createdAt (orden) · R: (no hay)
db.tickets.createIndex({ status: 1, createdAt: -1 })

// find({status:"open"}).sort({createdAt:-1})
//   → IXSCAN + SIN etapa SORT: el índice YA entrega ordenado. El premio ESR.

// ¿Y si hubiera rango? "abiertos de 2020, ordenados por prioridad":
// E: status · S: priority · R: createdAt
db.tickets.createIndex({ status: 1, priority: 1, createdAt: -1 })
};