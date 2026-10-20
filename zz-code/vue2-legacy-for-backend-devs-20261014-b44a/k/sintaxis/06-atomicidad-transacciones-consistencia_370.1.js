function __f(){
// La escalera de la consistencia (de gratis a caro):
// 1. UN documento, UN update           → atomicidad implícita (el premio de F3)
// 2. read-modify-write                 → NO: usa $inc/$push/$pull (delta en el motor)
// 3. leer-decidir-escribir             → NO: findOneAndUpdate con PRECONDICIÓN en el filtro
// 4. invariante entre documentos       → ¿remodelable? → F3. ¿Tolerancia > 0? → reconciliación (F5)
// 5. tolerancia CERO entre documentos  → transacción (RS requerido, withTransaction, precio)

findOneAndUpdate(
  { _id, assignee: null },          // la precondición ES el lock optimista
  { $set: {...}, $push: {...} },    // multi-campo, multi-array: sigue siendo atómico
  { returnOriginal: false }
)  // → value === null: no matcheó → conflicto o inexistente

// Arrays: $push (+$each+$slice) · $pull · $addToSet · $[elem]+arrayFilters
// Durabilidad: w:1 | w:"majority" · j:true · readConcern local|majority
// Transacción: session en CADA operación · callback re-ejecutable · 60 s
}