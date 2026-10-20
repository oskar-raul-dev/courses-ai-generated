var __a = [
// v1 (2019): sin prioridad, fecha string 😱
{ _id: ..., title: "...", status: "open",
  reporter: "dprios", createdAt: "2019-06-01T10:00:00Z" }

// v2 (2020): prioridad y assignee, fecha ya Date
{ _id: ..., title: "...", status: "open", priority: "high",
  assignee: null, reporter: "dprios", createdAt: ISODate("...") }

// v3 (2021): history embebido (¡nuestra Fase 3!), tags
{ _id: ..., title: "...", status: "open", priority: "high",
  assignee: "lmcano", reporter: "dprios", createdAt: ISODate("..."),
  history: [ ... ], tags: ["hardware"] }
];