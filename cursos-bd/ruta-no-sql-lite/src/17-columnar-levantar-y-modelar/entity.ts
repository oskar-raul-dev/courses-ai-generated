// La situación 3 de la Fase 17: las lecturas modeladas como entidad, con la tabla que habría en
// Postgres —una clave sustituta y las columnas— y la consulta 1 hecha con ALLOW FILTERING para que
// "funcione". Se carga cada volumen y se traza la misma pregunta: cuántas filas lee el motor para
// devolver las del caso egtTrend de ese dataset.
//
//   node 17-columnar-levantar-y-modelar/entity.ts [--datasets reading-10k,reading-1m,reading-5m]   (desde src/)
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { parseArgs } from "node:util";
import cassandra from "cassandra-driver";
import { readNdjson, verifyDataset } from "../lab/harness/dataset.ts";
import { columnar, traced, writeAll } from "../lab/harness/cassandra-trace.ts";

const { values: args } = parseArgs({ options: { datasets: { type: "string", default: "reading-10k,reading-1m,reading-5m" } } });

interface Reading { aircraft: string; flightId: string; ts: string; altitudeFt: number; iasKt: number; egtC: number; n1Pct: number; oilPressPsi: number; oilTempC: number; fuelFlowPph: number }

const client = columnar();
await client.connect();
try {
  for (const name of args.datasets!.split(",")) {
    const dir = join("lab/data", name);
    await verifyDataset(dir);
    // la tabla "como en Postgres": una fila, una clave sustituta, y el resto columnas sueltas
    await client.execute("DROP TABLE IF EXISTS reading_entity");
    await client.execute(`CREATE TABLE reading_entity (
      id uuid PRIMARY KEY, aircraft text, flight_id text, ts timestamp,
      altitude_ft int, ias_kt int, egt_c int, n1_pct int, oil_press_psi int, oil_temp_c int, fuel_flow_pph int)`);
    const insert = "INSERT INTO reading_entity (id, aircraft, flight_id, ts, altitude_ft, ias_kt, egt_c, n1_pct, oil_press_psi, oil_temp_c, fuel_flow_pph) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    let pending: { query: string; params: unknown[] }[] = [];
    let n = 0;
    const flush = async () => {
      await writeAll(client, pending);
      pending = [];
    };
    for await (const r of readNdjson<Reading>(join(dir, "reading.ndjson"))) {
      pending.push({ query: insert, params: [cassandra.types.Uuid.random(), r.aircraft, r.flightId, new Date(r.ts), r.altitudeFt, r.iasKt, r.egtC, r.n1Pct, r.oilPressPsi, r.oilTempC, r.fuelFlowPph] });
      n++;
      if (pending.length >= 20_000) await flush();
    }
    if (pending.length) await flush();

    // la consulta 1 del caso plantado de este mismo dataset
    const trend = JSON.parse(readFileSync(join(dir, "answers.json"), "utf8")).egtTrend as { aircraft: string; from: string; to: string };
    const t = await traced(client, "SELECT ts, egt_c FROM reading_entity WHERE aircraft = ? AND ts >= ? AND ts < ? ALLOW FILTERING",
      [trend.aircraft, new Date(`${trend.from}T00:00:00Z`), new Date(`${trend.to}T00:00:00Z`)], 5000);
    console.log(`${name.padEnd(12)} ${String(n).padStart(8)} filas · ${trend.aircraft} ${trend.from}→${trend.to} · devueltas ${t.returned} · páginas ${t.pages} · rangos ${t.rangeScans} · filas vivas leídas ${t.liveRows} · ${(t.liveRows / Math.max(t.returned, 1)).toFixed(0)} por cada devuelta · ${(t.durationUs / 1000).toFixed(0)} ms en la traza`);
  }
} finally {
  await client.shutdown();
}
