// Borrar en Cassandra es escribir: cada DELETE deja una marca (tombstone) que las lecturas tienen que leer
// y saltar hasta que una compactación la purga, y no la purga antes de gc_grace_seconds (10 días). Sobre una
// copia de una partición de la Fase 17 (HC-2157, octubre de 2025): borrar fila por fila contra borrar el
// rango de una vez, lo que lee después la consulta, lo que ocupa, y la partición que deja de poder leerse
// al pasar tombstone_failure_threshold (100 000).
//
//   node 18-columnar-romper-y-medir/tombstones.ts   (desde src/, con columnar arriba y el keyspace de la Fase 17)
import { execFileSync } from "node:child_process";
import { columnar, traced, writeAll } from "../lab/harness/cassandra-trace.ts";

const nodetool = (...args: string[]) =>
  execFileSync("docker", ["compose", "-f", "lab/compose.yaml", "exec", "-T", "columnar", "nodetool", ...args], { encoding: "utf8" });
const liveSize = (table: string) => Number(/Space used \(live\): (\d+)/.exec(nodetool("tablestats", `condor.${table}`))?.[1] ?? 0);

const client = columnar();
await client.connect();
const KEY = ["HC-2157", "2025-10"];
const SELECT = "SELECT ts, egt_c FROM reading_tomb WHERE aircraft = ? AND month = ?";
const show = async (label: string) => {
  nodetool("flush", "condor", "reading_tomb");
  const t = await traced(client, SELECT, KEY);
  console.log(`${label.padEnd(36)} devueltas ${String(t.returned).padStart(5)} · filas vivas leídas ${String(t.liveRows).padStart(5)} · tombstones leídos ${String(t.tombstones).padStart(6)} · sstables ${t.sstables} · en disco ${(liveSize("reading_tomb") / 1024).toFixed(0)} KiB`);
};
const copy = async () => {
  const rows = (await client.execute("SELECT ts, flight_id, egt_c FROM reading_by_aircraft_month WHERE aircraft = ? AND month = ?", KEY, { prepare: true, fetchSize: 50_000 })).rows;
  await writeAll(client, rows.map((r) => ({ query: "INSERT INTO reading_tomb (aircraft, month, ts, flight_id, egt_c) VALUES (?, ?, ?, ?, ?)", params: [...KEY, r.ts, r.flight_id, r.egt_c] })));
  return rows;
};
const reset = async (extra = "") => {
  await client.execute("DROP TABLE IF EXISTS reading_tomb");
  await client.execute(`CREATE TABLE reading_tomb (aircraft text, month text, ts timestamp, flight_id text, egt_c int,
    PRIMARY KEY ((aircraft, month), ts)) ${extra}`);
};

try {
  // 1 · borrar fila por fila: una marca por fila
  await reset();
  const rows = await copy();
  await show("la partición copiada");
  await writeAll(client, rows.map((r) => ({ query: "DELETE FROM reading_tomb WHERE aircraft = ? AND month = ? AND ts = ?", params: [...KEY, r.ts] })));
  await show(`${rows.length} DELETE, uno por fila`);
  nodetool("compact", "condor", "reading_tomb");
  await show("compactada (gc_grace_seconds 10 días)");

  // 2 · borrar el rango de una vez: una sola marca de rango. Los datos ya están en disco, como en la vida real
  await reset();
  await copy();
  nodetool("flush", "condor", "reading_tomb");
  await client.execute("DELETE FROM reading_tomb WHERE aircraft = ? AND month = ? AND ts >= ? AND ts < ?", [...KEY, new Date("2025-10-01T00:00:00Z"), new Date("2025-11-01T00:00:00Z")], { prepare: true });
  await show("un DELETE del rango del mes");

  // 3 · con gc_grace_seconds 0 la compactación sí purga las marcas (y en un anillo eso resucita filas: sección 9)
  await reset("WITH gc_grace_seconds = 0");
  await copy();
  nodetool("flush", "condor", "reading_tomb");
  await writeAll(client, rows.map((r) => ({ query: "DELETE FROM reading_tomb WHERE aircraft = ? AND month = ? AND ts = ?", params: [...KEY, r.ts] })));
  nodetool("flush", "condor", "reading_tomb");
  nodetool("compact", "condor", "reading_tomb");
  await show("fila por fila, gc_grace 0, compactada");

  // 4 · el umbral: borrar celdas una por una en una partición hasta pasar las 100 000 marcas. Se borra
  // la columna egt_c de cada fila, que deja una marca de celda (lo que cuenta el umbral) y no de fila
  await reset();
  const base = new Date("2025-10-01T00:00:00Z").getTime();
  for (const n of [999, 1_001, 99_999, 100_001]) {
    await client.execute("TRUNCATE reading_tomb");
    const dels = Array.from({ length: n }, (_, i) => ({ query: "DELETE egt_c FROM reading_tomb WHERE aircraft = ? AND month = ? AND ts = ?", params: [...KEY, new Date(base + i * 1000)] }));
    await writeAll(client, dels);
    nodetool("flush", "condor", "reading_tomb");
    try {
      const rs = await client.execute(SELECT, KEY, { prepare: true, fetchSize: 50_000 });
      console.log(`${String(n).padStart(7)} marcas · devueltas ${rs.rowLength}${rs.info.warnings?.length ? ` · aviso: ${rs.info.warnings.join(" | ")}` : ""}`);
    } catch (e) {
      console.log(`${String(n).padStart(7)} marcas · ${(e as Error).name}: ${(e as Error).message}`);
    }
  }
  await client.execute("DROP TABLE reading_tomb");
  nodetool("clearsnapshot", "--all");
} finally {
  await client.shutdown();
}
