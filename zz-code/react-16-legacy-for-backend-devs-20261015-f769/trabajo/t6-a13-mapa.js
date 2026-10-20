// A13: busca un texto de interfaz en el bundle minificado y lo resuelve con el source map.
// Uso (desde el proyecto): node t6-a13-mapa.js build/static/js/main.<hash>.chunk.js "<texto>"
const fs = require("fs");
const { SourceMapConsumer } = require("source-map");
const [file, text] = process.argv.slice(2);
const code = fs.readFileSync(file, "utf8");
const at = code.indexOf(text);
const before = code.slice(0, at).split("\n");
const line = before.length;
const column = before[before.length - 1].length - 1; // la comilla que abre el literal
console.log(`"${text}" en ${file.split("/").pop()}:${line}:${column}`);
const map = JSON.parse(fs.readFileSync(file + ".map", "utf8"));
Promise.resolve(new SourceMapConsumer(map)).then((consumer) => {
  const original = consumer.originalPositionFor({ line, column, bias: SourceMapConsumer.GREATEST_LOWER_BOUND });
  console.log(`→ ${original.source}:${original.line}:${original.column}`);
});
