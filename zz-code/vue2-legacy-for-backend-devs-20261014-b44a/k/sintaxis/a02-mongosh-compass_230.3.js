var __a = [
// El shell ES JavaScript: variables, funciones, map/filter/forEach, JSON
const t = db.tickets.findOne(); Object.keys(t)
db.col.find().forEach(d => ...)          // reparación quirúrgica (pocos docs)
// ⬆️ ¿muchos docs, o corre solo? → script con driver, no shell

// Salida legible
find({}, { campo: 1, _id: 0 })  ·  countDocuments()  ·  print(...)  ·  `it`

// Reconocimiento (5 min): show collections → getCollectionInfos (validator!)
//   → countDocuments → findOne → getIndexes → formas()

// Scripting
mongosh "$URI" --quiet --eval 'JSON.stringify(x)'    # parseable por bash
mongosh "$URI" script.js  ·  load("helpers.js")
~/.mongoshrc.js  →  tus helpers permanentes (lentas, colscans, idx)

// Fósiles: count() miente → countDocuments() · db.copyDatabase() ya no existe

// Compass: Schema (drift) · Explain visual · Pipeline Builder (+ export a Node)
//   · Indexes con uso real.  MIRAR sí; OPERAR no.
];