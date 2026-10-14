// La situación 3 de la Fase 17, empujada hasta que deja de contestar: la tabla por entidad (un uuid por
// lectura) crece de 5 M en 5 M con las copias de la ampliación ×10, y después de cada copia se repite la
// misma consulta con ALLOW FILTERING —la curva de HC-2157 en 60 días, que siempre devuelve 9666 filas—. Lo
// que crece es lo que lee, hasta que una página no termina a tiempo y el nodo la cancela. Se detiene en la
// primera copia que falla: las siguientes fallan igual.
//
//   node 18-columnar-romper-y-medir/filtering.ts [--copies 10]   (desde src/, con columnar arriba)
import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { parseArgs } from "node:util";
import cassandra from "cassandra-driver";
import { readNdjson } from "../lab/harness/dataset.ts";
import { columnar, traced, writeAll } from "../lab/harness/cassandra-trace.ts";

const { values: args } = parseArgs({ options: { copies: { type: "string", default: "10" } } });
const nodetool = (...a: string[]) =>
  execFileSync("docker", ["compose", "-f", "lab/compose.yaml", "exec", "-T", "columnar", "nodetool", ...a], { encoding: "utf8" });
const dir = "lab/data/reading-5m";
const trend = JSON.parse(readFileSync(join(dir, "answers.json"), "utf8")).egtTrend as { aircraft: string; from: string; to: string };

const client = columnar();
await client.connect();
try {
  await client.execute("DROP TABLE IF EXISTS reading_entity");
  nodetool("clearsnapshot", "--all");
  await client.execute(`CREATE TABLE reading_entity (
    id uuid PRIMARY KEY, aircraft text, flight_id text, ts timestamp,
    altitude_ft int, ias_kt int, egt_c int, n1_pct int, oil_press_psi int, oil_temp_c int, fuel_flow_pph int)`);
  const insert = "INSERT INTO reading_entity (id, aircraft, flight_id, ts, altitude_ft, ias_kt, egt_c, n1_pct, oil_press_psi, oil_temp_c, fuel_flow_pph) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
  let total = 0;
  for (let k = 0; k < Number(args.copies); k++) {
    // la copia k de la ampliación: k = 0 es el original, las demás llevan sufijo y no las pide la consulta
    const sfx = k === 0 ? "" : `~${k}`;
    let pending: { query: string; params: unknown[] }[] = [];
    for await (const r of readNdjson<{ aircraft: string; flightId: string; ts: string; altitudeFt: number; iasKt: number; egtC: number; n1Pct: number; oilPressPsi: number; oilTempC: number; fuelFlowPph: number }>(join(dir, "reading.ndjson"))) {
      pending.push({ query: insert, params: [cassandra.types.Uuid.random(), r.aircraft + sfx, r.flightId + sfx, new Date(r.ts), r.altitudeFt, r.iasKt, r.egtC, r.n1Pct, r.oilPressPsi, r.oilTempC, r.fuelFlowPph] });
      if (pending.length >= 20_000) {
        await writeAll(client, pending);
        pending = [];
      }
      total++;
    }
    if (pending.length) await writeAll(client, pending);
    nodetool("flush", "condor", "reading_entity");

    const t0 = performance.now();
    try {
      const t = await traced(client, "SELECT ts, egt_c FROM reading_entity WHERE aircraft = ? AND ts >= ? AND ts < ? ALLOW FILTERING",
        [trend.aircraft, new Date(`${trend.from}T00:00:00Z`), new Date(`${trend.to}T00:00:00Z`)], 5000);
      console.log(`${String(total).padStart(9)} filas · devueltas ${t.returned} · páginas ${t.pages} · filas vivas leídas ${t.liveRows} · ${(t.durationUs / 1000).toFixed(0)} ms en la traza`);
    } catch (e) {
      console.log(`${String(total).padStart(9)} filas · falla a los ${((performance.now() - t0) / 1000).toFixed(1)} s · ${(e as Error).name}: ${(e as Error).message}`);
      break;
    }
  }
} finally {
  await client.shutdown();
}
