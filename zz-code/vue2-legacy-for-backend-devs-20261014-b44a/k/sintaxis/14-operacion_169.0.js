// Verlo construir y medir su impacto:
db.currentOp({ "command.createIndexes": { $exists: true } })

// El precio permanente: cada índice se paga en CADA escritura (F7 dixit)
// El precio del build: I/O — en horario valle sigue siendo cortesía, no requisito