// Las tres consultas de la Fase 17 en los dos motores, medidas por su forma: particiones y SSTables
// tocadas y filas leídas contra devueltas en Cassandra (traza); particiones recorridas, filas
// examinadas y páginas en Postgres particionado (EXPLAIN). Los dos tienen que devolver lo mismo.
//
//   node 17-columnar-levantar-y-modelar/measure.ts [--x10]   (desde src/, después de load.ts y baseline.ts)
import { readFileSync } from "node:fs";
import { parseArgs } from "node:util";
import pg from "pg";
import { columnar, traced, type TraceResult } from "../lab/harness/cassandra-trace.ts";
import { explain } from "../lab/harness/explain.ts";

const { values: args } = parseArgs({ options: { x10: { type: "boolean", default: false } } });

// la aeronave y los 60 días del caso plantado egtTrend (a05): la EGT sube 0,6 °C por día
const trend = JSON.parse(readFileSync("lab/data/reading-5m/answers.json", "utf8")).egtTrend as { aircraft: string; from: string; to: string };
const from = new Date(`${trend.from}T00:00:00Z`);
const to = new Date(`${trend.to}T00:00:00Z`);
const months: string[] = [];
for (let d = new Date(from); d < to; d = new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth() + 1, 1))) months.push(d.toISOString().slice(0, 7));

const cs = columnar();
await cs.connect();
const pgc = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "series_base" });
await pgc.connect();

const partitionsOf = (access: string[]) => new Set(access.map((a) => / on (\S+)/.exec(a)?.[1])).size;
const show = (label: string, c: TraceResult, p: Awaited<ReturnType<typeof explain>>) => {
  console.log(`${label}`);
  console.log(`  cassandra  devueltas ${c.returned} · páginas ${c.pages} · lecturas de partición ${c.partitions} · rangos ${c.rangeScans} · sstables ${c.sstables} · filas vivas leídas ${c.liveRows} · tombstones ${c.tombstones}`);
  console.log(`  postgres   devueltas ${p.returned} · particiones ${partitionsOf(p.access)} · examinadas ${p.examined} · páginas ${p.sharedHit + p.sharedRead} · ${[...new Set(p.access.map((a) => a.replace(/ on \S+/, "").replace(/ using \S+/, "")))].join(", ")}`);
  if (c.returned !== p.returned) console.log(`  ⚠️ no devuelven lo mismo: ${c.returned} contra ${p.returned}`);
};

try {
  // dos pasadas: la primera calienta las cachés de los dos; se publica la segunda
  for (const pass of [1, 2]) {
    const out = pass === 2;
    const [cTable, pTable] = args.x10 ? ["reading_x10_by_aircraft_month", "reading_part"] : ["reading_by_aircraft_month", "reading_part5"];

    // consulta 1: una aeronave en un rango de fechas; en la ×10, también una de las matrículas sintéticas,
    // que tiene que devolver lo mismo en los dos motores si la ampliación es la misma
    let c1!: Awaited<ReturnType<typeof traced>>;
    for (const aircraft of args.x10 ? [trend.aircraft, `${trend.aircraft}~9`] : [trend.aircraft]) {
      c1 = await traced(cs, `SELECT ts, egt_c FROM ${cTable} WHERE aircraft = ? AND month IN ? AND ts >= ? AND ts < ?`, [aircraft, months, from, to]);
      const p1 = await explain(pgc, `SELECT ts, egt_c FROM ${pTable} WHERE aircraft = $1 AND ts >= $2 AND ts < $3 ORDER BY ts`, [aircraft, trend.from, trend.to]);
      if (out) show(`1 · ${aircraft}, ${trend.from} → ${trend.to} (${months.length} meses) · ${cTable} / ${pTable}`, c1, p1);
    }
    if (args.x10) continue;

    // consulta 2: un vuelo completo, el primero de noviembre de esa aeronave
    const flight = c1.rows.length ? (await cs.execute("SELECT flight_id FROM reading_by_aircraft_month WHERE aircraft = ? AND month = ? AND ts >= ? LIMIT 1", [trend.aircraft, months.at(-1), new Date(`${months.at(-1)}-01T00:00:00Z`)], { prepare: true })).first().flight_id : "";
    const c2 = await traced(cs, "SELECT ts, egt_c FROM reading_by_flight WHERE flight_id = ?", [flight]);
    const p2 = await explain(pgc, "SELECT ts, egt_c FROM reading_part5 WHERE flight_id = $1 ORDER BY ts", [flight]);
    if (out) show(`2 · vuelo ${flight} completo`, c2, p2);

    // consulta 3: las excedencias de EGT de la flota en el día con más excedencias
    const { rows: [busiest] } = await pgc.query("SELECT ts::date AS day, count(*) AS n FROM reading_part5 WHERE egt_c >= 720 GROUP BY 1 ORDER BY 2 DESC, 1 LIMIT 1");
    const day = busiest.day.toISOString().slice(0, 10);
    const next = new Date(new Date(`${day}T00:00:00Z`).getTime() + 86_400_000).toISOString().slice(0, 10);
    const c3 = await traced(cs, "SELECT aircraft, ts, egt_c FROM egt_exceedance_by_day WHERE day = ?", [day]);
    const p3 = await explain(pgc, "SELECT aircraft, ts, egt_c FROM reading_part5 WHERE egt_c >= 720 AND ts >= $1 AND ts < $2", [day, next]);
    if (out) show(`3 · excedencias de la flota el ${day}`, c3, p3);

    // la consulta 3 sin su tabla: las particiones de la consulta 1, una por aeronave, filtrando en el servidor
    const { rows: ac } = await pgc.query("SELECT DISTINCT aircraft FROM reading");
    const c3b = await traced(cs, "SELECT aircraft, ts, egt_c FROM reading_by_aircraft_month WHERE aircraft IN ? AND month = ? AND ts >= ? AND ts < ? AND egt_c >= 720 ALLOW FILTERING",
      [ac.map((r) => r.aircraft), day.slice(0, 7), new Date(`${day}T00:00:00Z`), new Date(`${next}T00:00:00Z`)]);
    if (out) console.log(`3b · la misma, sobre reading_by_aircraft_month (${ac.length} aeronaves)\n  cassandra  devueltas ${c3b.returned} · particiones ${c3b.partitions} · sstables ${c3b.sstables} · filas vivas leídas ${c3b.liveRows}`);
  }
} finally {
  await cs.shutdown();
  await pgc.end();
}
