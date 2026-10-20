var __a = [
// http — el servidor de sockets (F8): crear un server sin Express
var http = require("http");
var server = http.createServer();
server.listen(4000, callback);

// fs — archivos: el watch del ejercicio 22 (F8), el generador de datos (F7 ej. 21)
var fs = require("fs");
fs.writeFileSync("db.json", JSON.stringify(data, null, 2));
fs.watch("db.json", callback);

// process — el proceso actual: env vars y argumentos
process.env.NODE_ENV      // "development"/"production" — el strict mode (F10)
process.argv              // argumentos de línea de comandos
process.exit(1)           // terminar con código de error

// path + __dirname — rutas a prueba de sistema operativo
var path = require("path");
path.join(__dirname, "db.json");  // __dirname = carpeta de ESTE archivo
];