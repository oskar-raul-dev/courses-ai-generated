// El observador: escucha el _changes de CouchDB y anota la primera vez que ve cada orden, con el reloj de la máquina
// (el mismo con que run.ts anota el COMMIT). Imprime una línea por orden: "id milisegundos". Si CouchDB se cae, vuelve
// a conectarse desde la última secuencia que vio. Va con node:http y no con fetch: con CouchDB detenido, fetch
// lanzaba el error fuera de la promesa y tumbaba el proceso.
//
//   node 24-poliglota-la-costura/watch.ts   (lo lanza run.ts)
import { get } from "node:http";
import { createInterface } from "node:readline";
import { COUCH, sleep } from "./common.ts";

const port = Number(process.env.OFFLINE_PORT ?? 15984);
const seen = new Set<string>();
process.stdout.on("error", () => process.exit(0));   // run.ts terminó y cerró la tubería
let since = "now";

/** Una conexión al feed, que termina cuando CouchDB la corta o no responde. */
const listen = () => new Promise<void>((done) => {
  const req = get({ host: "localhost", port, auth: "condor:condor", path: `/${COUCH}/_changes?feed=continuous&heartbeat=1000&since=${since}` }, (res) => {
    createInterface({ input: res }).on("line", (line) => {
      if (!line.trim()) return;
      const change = JSON.parse(line);
      if (change.seq) since = change.seq;
      if (change.id && !seen.has(change.id)) { seen.add(change.id); process.stdout.write(`${change.id} ${Date.now()}\n`); }
    }).on("close", () => done()).on("error", () => done());
    res.on("error", () => done());
  });
  req.on("error", () => done());
});

for (;;) {
  await listen();
  await sleep(200);
}
