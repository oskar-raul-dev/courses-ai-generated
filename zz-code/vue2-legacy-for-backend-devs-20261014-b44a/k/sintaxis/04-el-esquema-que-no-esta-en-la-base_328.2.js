var __o = {
try {
  db.tickets.insertOne({ title: "sin estado" });
} catch (e) {
  print(e.message);            // Document failed validation
  printjson(e.errInfo);        // en 4.4: nada
}
};