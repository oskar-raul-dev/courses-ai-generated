// El punto de rotura: la partición sin cota. La tabla de la Fase 17 sin el mes en la partition key —una
// partición por aeronave, para siempre— y una aeronave que escribe una lectura por segundo, como pide el
// contrato nuevo. La partición crece por escalones y en cada uno se hacen las tres lecturas que alguien le
// pediría: la última hora, la EGT máxima de toda la historia, y la historia entera de una vez para
// exportarla. Se sigue hasta que algo deja de contestar o el nodo cae.
//
//   node 18-columnar-romper-y-medir/unbounded.ts [--steps 1,2,5,10,20,50]   (millones de filas acumuladas;
//                                                 desde src/, con columnar arriba y nada más cargando)
import { execFileSync } from "node:child_process";
import { parseArgs } from "node:util";
import { columnar, traced, writeAll } from "../lab/harness/cassandra-trace.ts";

const { values: args } = parseArgs({ options: { steps: { type: "string", default: "1,2,5,10,20,50" } } });
const docker = (...a: string[]) => execFileSync("docker", ["compose", "-f", "lab/compose.yaml", ...a], { encoding: "utf8" });
const nodetool = (...a: string[]) => docker("exec", "-T", "columnar", "nodetool", ...a);
const heap = () => /Heap Memory \(MB\)\s*:\s*(\S+ \/ \S+)/.exec(nodetool("info"))?.[1] ?? "?";
const alive = () => {
  try {
    return docker("ps", "--status", "running", "--services").includes("columnar") && /UN/.test(nodetool("status"));
  } catch {
    return false;
  }
};

const AIRCRAFT = "HC-2157";
const START = Date.UTC(2021, 9, 1);
const client = columnar();
await client.connect();
await client.execute("DROP TABLE IF EXISTS reading_unbounded");
nodetool("clearsnapshot", "--all");
await client.execute(`CREATE TABLE reading_unbounded (aircraft text, ts timestamp, egt_c int, n1_pct int, fuel_flow_pph int,
  PRIMARY KEY ((aircraft), ts))`);
const insert = "INSERT INTO reading_unbounded (aircraft, ts, egt_c, n1_pct, fuel_flow_pph) VALUES (?, ?, ?, ?, ?)";

let written = 0;
try {
  for (const step of args.steps!.split(",").map((s) => Number(s) * 1_000_000)) {
    const t0 = performance.now();
    try {
      while (written < step) {
        const n = Math.min(20_000, step - written);
        const batch = Array.from({ length: n }, (_, j) => {
          const i = written + j;
          return { query: insert, params: [AIRCRAFT, new Date(START + i * 1000), 650 + (i % 90), 85 + (i % 15), 400 + (i % 200)] };
        });
        await writeAll(client, batch);
        written += n;
      }
    } catch (e) {
      // el nodo puede quedar vivo para nodetool y muerto para los clientes: se muestran las dos caras
      console.log(`  💥 escribiendo, con ${written} filas: ${(e as Error).name}: ${(e as Error).message}`);
      console.log(`  nodetool: ${nodetool("info").split("\n").filter((l) => /Native Transport|Gossip|Heap Memory/.test(l)).map((l) => l.replace(/\s+/g, " ")).join(" · ")}`);
      console.log(docker("logs", "--tail", "200", "columnar").split("\n").filter((l) => /OutOfMemory error|Force-closing|G1 Old Generation GC in \d{4,}/.test(l)).slice(-4).map((l) => l.slice(0, 220)).join("\n"));
      process.exit(0);
    }
    nodetool("flush", "condor", "reading_unbounded");
    const stats = nodetool("tablestats", "condor.reading_unbounded");
    const size = Number(/Space used \(live\): (\d+)/.exec(stats)?.[1]) / 1024 / 1024;
    const days = written / 86_400;
    console.log(`== ${written} filas (${days.toFixed(0)} días a 1 Hz) · partición de ${size.toFixed(0)} MiB en ${/SSTable count: (\d+)/.exec(stats)?.[1]} SSTables · escritas en ${((performance.now() - t0) / 1000).toFixed(0)} s · heap ${heap()} MB`);

    const end = new Date(START + written * 1000);
    const reads: [string, () => Promise<string>][] = [
      ["la última hora", async () => {
        const t = await traced(client, "SELECT ts, egt_c FROM reading_unbounded WHERE aircraft = ? AND ts >= ?", [AIRCRAFT, new Date(end.getTime() - 3_600_000)]);
        return `devueltas ${t.returned} · sstables ${t.sstables} · ${(t.durationUs / 1000).toFixed(0)} ms en la traza`;
      }],
      ["la EGT máxima de toda la historia", async () => {
        const rs = await client.execute("SELECT max(egt_c) AS m FROM reading_unbounded WHERE aircraft = ?", [AIRCRAFT], { prepare: true });
        return `max ${rs.first().m}`;
      }],
      ["la historia entera en una página", async () => {
        const rs = await client.execute("SELECT ts, egt_c FROM reading_unbounded WHERE aircraft = ?", [AIRCRAFT], { prepare: true, fetchSize: written });
        return `devueltas ${rs.rowLength}`;
      }],
    ];
    for (const [label, read] of reads) {
      const t = performance.now();
      try {
        const out = await read();
        console.log(`  ${label.padEnd(34)} ${out} · ${((performance.now() - t) / 1000).toFixed(1)} s`);
      } catch (e) {
        console.log(`  ${label.padEnd(34)} falla a los ${((performance.now() - t) / 1000).toFixed(1)} s · ${(e as Error).name}: ${(e as Error).message}`);
      }
      if (!alive()) {
        console.log(`  💥 el nodo cayó: ${docker("ps", "-a", "--format", "{{.Service}} {{.Status}}").split("\n").find((l) => l.startsWith("columnar"))}`);
        console.log(docker("logs", "--tail", "40", "columnar").split("\n").filter((l) => /OutOfMemory|ERROR|Exception|heap/i.test(l)).slice(-6).join("\n"));
        process.exit(0);
      }
    }
    console.log(`  heap después de leer ${heap()} MB`);
  }
} finally {
  await client.shutdown().catch(() => {});
}
