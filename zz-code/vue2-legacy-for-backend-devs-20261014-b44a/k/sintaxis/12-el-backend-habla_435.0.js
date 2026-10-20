// El principio de la fase:
//   el evento es CONSECUENCIA de la persistencia, no testimonio del cliente
//   → emit en el service, DESPUÉS del insert/update, con el MISMO serializer

realtime.emit("ticket:created", serializeTicket(doc))   // misma forma que la API
// notificación UI → at-most-once basta (tolerancia documentada)
// evento de negocio → outbox transaccional (F6 ej. 30)

// socket.io 2.4 (el cliente es 2.4.0: 2.x↔3.x NO se hablan)
io.use(middleware)                     // handshake: token en query → socket.user
// modo compatible: sin token = anónimo escucha · token inválido = rechazado

// GridFS: fs.files (metadata) + fs.chunks (255 KB) vía GridFSBucket
openUploadStream(name, { contentType, metadata }) ← stream.end(buffer)
openDownloadStream(id).pipe(res)       // streaming: la RAM no es tu buffer
multer({ memoryStorage, limits: { fileSize } })  // límite DECLARADO…
//   …y traducido en el manejador central: LIMIT_FILE_SIZE → 413 (si no, 500)