function __f(){
// El espejo condensado
find({ a: 1 })                          // WHERE a = 1
find({ a: 1, b: 2 })                    // AND implícito
find({ a: { $gt: 5, $lte: 10 } })       // rangos / BETWEEN
find({ a: { $in: [1, 2] } })            // IN
find({ $or: [{ a: 1 }, { b: 2 }] })     // OR (en la raíz, array)
find({ t: { $regex: /^abc/i } })        // LIKE 'abc%'  (anclado = indexable)
find({}, { a: 1, _id: 0 })              // lista de columnas
.sort({ a: 1, b: -1 }).skip(20).limit(10)
countDocuments({ ... })                 // COUNT(*) honesto
distinct("campo")

// Las trampas
{ a: null }                    // null explícito Y campo ausente
{ a: { $exists: false } }      // solo ausente
{ a: { $ne: "x" } }            // "distinto de x" INCLUYE a los que no tienen a
{ a: { $type: "string" } }     // auditor de tipos

// El cursor
find() devuelve cursor → toArray() / for await
}