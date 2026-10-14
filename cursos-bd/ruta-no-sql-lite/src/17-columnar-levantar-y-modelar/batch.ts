// Escribir la misma lectura en dos tablas: ¿sueltas, en un BATCH sin registro o en un BATCH con
// registro? El BATCH con registro garantiza que, si una escritura entra, entran todas —tarde o
// temprano—, y lo paga escribiendo el lote entero en system.batches antes de aplicarlo. Se cuenta con
// las escrituras locales de esa tabla.
//
//   node 17-columnar-levantar-y-modelar/batch.ts [--readings 100000]   (desde src/, después de schema.cql)
import { join } from "node:path";
import { parseArgs } from "node:util";
import { execFileSync } from "node:child_process";
import cassandra from "cassandra-driver";
import { readNdjson } from "../lab/harness/dataset.ts";
import { columnar } from "../lab/harness/cassandra-trace.ts";

const { values: args } = parseArgs({ options: { readings: { type: "string", default: "100000" } } });
const limit = Number(args.readings);

interface Reading { aircraft: string; flightId: string; ts: string; egtC: number }
const rows: Reading[] = [];
for await (const r of readNdjson<Reading>(join("lab/data/reading-5m", "reading.ndjson"))) {
  rows.push(r);
  if (rows.length >= limit) break;
}

// escrituras locales de system.batches, leídas de nodetool dentro del contenedor
const batchWrites = (): number => {
  const out = execFileSync("docker", ["compose", "-f", "lab/compose.yaml", "exec", "-T", "columnar", "nodetool", "tablestats", "system.batches"], { encoding: "utf8" });
  return Number(/Local write count: (\d+)/.exec(out)?.[1] ?? 0);
};

const client = columnar();
await client.connect();
try {
  await client.execute("CREATE TABLE IF NOT EXISTS batch_a (aircraft text, month text, ts timestamp, egt_c int, PRIMARY KEY ((aircraft, month), ts))");
  await client.execute("CREATE TABLE IF NOT EXISTS batch_b (flight_id text, ts timestamp, egt_c int, PRIMARY KEY ((flight_id), ts))");
  const A = "INSERT INTO batch_a (aircraft, month, ts, egt_c) VALUES (?, ?, ?, ?)";
  const B = "INSERT INTO batch_b (flight_id, ts, egt_c) VALUES (?, ?, ?)";
  const pair = (r: Reading) => [
    { query: A, params: [r.aircraft, r.ts.slice(0, 7), new Date(r.ts), r.egtC] },
    { query: B, params: [r.flightId, new Date(r.ts), r.egtC] },
  ];
  for (const mode of ["sueltas", "BATCH sin registro", "BATCH con registro"] as const) {
    await client.execute("TRUNCATE batch_a");
    await client.execute("TRUNCATE batch_b");
    const before = batchWrites();
    const t = performance.now();
    if (mode === "sueltas") {
      const r = await cassandra.concurrent.executeConcurrent(client, rows.flatMap(pair), { concurrencyLevel: 64, raiseOnFirstError: true });
      if (r.errors.length) throw r.errors[0];
    } else {
      const logged = mode === "BATCH con registro";
      // un lote por lectura: sus dos escrituras van a dos tablas y dos particiones distintas
      for (let i = 0; i < rows.length; i += 64) {
        await Promise.all(rows.slice(i, i + 64).map((r) => client.batch(pair(r), { prepare: true, logged })));
      }
    }
    const secs = (performance.now() - t) / 1000;
    console.log(`${mode.padEnd(20)} ${rows.length} lecturas · ${rows.length * 2} escrituras · escrituras en system.batches ${batchWrites() - before} · ${secs.toFixed(1)} s`);
  }
  await client.execute("DROP TABLE batch_a");
  await client.execute("DROP TABLE batch_b");
} finally {
  await client.shutdown();
}
