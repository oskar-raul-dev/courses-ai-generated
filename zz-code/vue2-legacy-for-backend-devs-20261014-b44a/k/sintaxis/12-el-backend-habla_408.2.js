var __o = {
// src/app.js — el manejador central de la Fase 10, con la traducción de multer
app.use(function (err, req, res, next) {
  if (err.code === "LIMIT_FILE_SIZE") {                   // MulterError
    return res.status(413).json({ error: "Archivo demasiado grande" });
  }
  console.error(err);
  res.status(500).json({ error: "Internal error" });
});
};