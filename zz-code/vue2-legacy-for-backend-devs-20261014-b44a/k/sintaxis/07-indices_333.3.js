var __a = [
db.tickets.find({ title: /impresora/ }).explain("executionStats").executionStats
// mira totalDocsExamined y nReturned, y anótalos
db.tickets.createIndex({ title: 1 })
db.tickets.find({ title: /impresora/ }).explain("executionStats").executionStats
];