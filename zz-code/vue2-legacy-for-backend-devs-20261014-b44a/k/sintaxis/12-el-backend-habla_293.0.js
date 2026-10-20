// dentro de init(), antes de io.on("connection"):
const { verify: verifyToken } = require("../lib/auth");     // el verify de la Fase 11

io.use(function (socket, next) {
  const token = socket.handshake.query && socket.handshake.query.token;
  if (!token) {
    socket.user = null;                            // modo compatible: anónimo
    return next();
  }
  try {
    socket.user = verifyToken(token);
    next();
  } catch (e) {
    next(new Error("invalid token"));              // token PRESENTE e inválido: fuera
  }
});