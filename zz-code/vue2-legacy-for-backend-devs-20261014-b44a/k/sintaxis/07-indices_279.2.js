var __o = {
createIndex({ a: 1, b: -1 }, { unique, partialFilterExpression, expireAfterSeconds })
getIndexes() / dropIndex("name")
find(...).explain("executionStats")
//   stage: COLLSCAN 🚨 | IXSCAN ✅ | SORT (en memoria) 🤔
//   eficiencia = nReturned / totalDocsExamined

// Compuestos: prefijo izquierdo · regla ESR (Equality, Sort, Range)
// Multikey: arrays y "array.campo" — un solo campo array por compuesto
// Parcial: índice con WHERE · TTL: borrado automático (campo Date o nada)
// Texto: 1 por colección, tokeniza palabras — no es LIKE %..%

// El plan de índices sale del CONTRATO, se verifica con explain,
// y se documenta con sus números. Y: el índice no arregla el modelo.
};