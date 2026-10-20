// Express SÍ atrapa los throws SÍNCRONOS (y solo esos):
app.get("/x", function (req, res) { throw new Error("boom"); });   // ✅ va al handler

// Pero NO los de un callback asíncrono:
app.get("/y", function (req, res, next) {
  setTimeout(function () { throw new Error("boom"); }, 10);        // 💀 mata el proceso
});
// La regla: dentro de cualquier callback async, los errores se pasan con next(err) A MANO