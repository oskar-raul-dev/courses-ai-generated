db.demo.insertMany([{ a: "x" }, { a: null }, { }])
db.demo.countDocuments({ a: { $ne: "x" } })       // ¿2?
db.demo.countDocuments({ a: { $exists: true, $ne: "x" } })