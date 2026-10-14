// La tarjeta de la apuesta de la Fase 18: cinco medidas de forma sobre las mismas 50 M lecturas, Cassandra
// contra Postgres particionado bien jugado. Las tres consultas de la Fase 17 (filas leídas para contestar,
// con las particiones tocadas al lado), el disco que ocupa todo lo que las contesta, y los bytes escritos
// al disco para cargarlo, que dejaron load.ts y baseline.ts. La apuesta pide que Postgres quede a 1,25× o
// menos de Cassandra en al menos cuatro de cinco.
//
//   node 18-columnar-romper-y-medir/scorecard.ts   (desde src/, después de load.ts y baseline.ts)
import { readFileSync } from "node:fs";
import pg from "pg";
import { columnar, traced } from "../lab/harness/cassandra-trace.ts";
import { explain } from "../lab/harness/explain.ts";
import { MiB, readWrites } from "../lab/harness/io.ts";

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

interface Row { label: string; cassandra: number; postgres: number; unit: string; detail: string }
const card: Row[] = [];
try {
  // el vuelo de la Fase 17 y el día con más excedencias, los mismos en los dos motores
  const flight = "FL-00002996";
  const { rows: [busiest] } = await pgc.query("SELECT ts::date AS day FROM reading WHERE egt_c >= 720 GROUP BY 1 ORDER BY count(*) DESC, 1 LIMIT 1");
  const day = busiest.day.toISOString().slice(0, 10);
  const next = new Date(new Date(`${day}T00:00:00Z`).getTime() + 86_400_000).toISOString().slice(0, 10);

  const queries = [
    {
      label: `1 · ${trend.aircraft}, 60 días`,
      c: () => traced(cs, "SELECT ts, egt_c FROM reading_x10_by_aircraft_month WHERE aircraft = ? AND month IN ? AND ts >= ? AND ts < ?", [trend.aircraft, months, from, to]),
      p: () => explain(pgc, "SELECT ts, egt_c FROM reading_part WHERE aircraft = $1 AND ts >= $2 AND ts < $3 ORDER BY ts", [trend.aircraft, trend.from, trend.to]),
    },
    {
      label: `2 · vuelo ${flight}`,
      c: () => traced(cs, "SELECT ts, egt_c FROM reading_x10_by_flight WHERE flight_id = ?", [flight]),
      p: () => explain(pgc, "SELECT ts, egt_c FROM reading_part_flight WHERE flight_id = $1 ORDER BY ts", [flight]),
    },
    {
      label: `3 · excedencias, ${day}`,
      c: () => traced(cs, "SELECT aircraft, ts, egt_c FROM egt_x10_exceedance_by_day WHERE day = ?", [day]),
      p: () => explain(pgc, "SELECT aircraft, ts, egt_c FROM reading_part WHERE egt_c >= 720 AND ts >= $1 AND ts < $2", [day, next]),
    },
  ];
  // dos pasadas: la primera calienta las cachés; se publica la segunda
  for (const pass of [1, 2]) {
    for (const q of queries) {
      const c = await q.c();
      const p = await q.p();
      if (pass === 1) continue;
      if (c.returned !== p.returned) console.log(`⚠️ ${q.label}: no devuelven lo mismo (${c.returned} contra ${p.returned})`);
      console.log(`${q.label} · devueltas ${c.returned}`);
      console.log(`  cassandra  particiones ${c.partitions} · sstables ${c.sstables} · filas vivas leídas ${c.liveRows}`);
      console.log(`  postgres   particiones ${partitionsOf(p.access)} · examinadas ${p.examined} · páginas ${p.sharedHit + p.sharedRead}`);
      card.push({ label: `filas leídas · ${q.label}`, cassandra: c.liveRows, postgres: p.examined, unit: "filas", detail: `${c.partitions} / ${partitionsOf(p.access)} part.` });
    }
  }

  const w = readWrites();
  card.push({ label: "disco de lo que contesta las tres", cassandra: MiB(w.cassandra.liveBytes), postgres: MiB(w.postgres.liveBytes), unit: "MiB", detail: "" });
  // Postgres bien jugado: la mejor de sus dos cargas, la de fábrica y la de ingesta (baseline.ts --tuned)
  const [best, other] = [w.postgres, w["postgres-tuned"]].filter(Boolean).sort((a, b) => a.writtenBytes - b.writtenBytes);
  card.push({ label: "escrito al disco para cargarlo", cassandra: MiB(w.cassandra.writtenBytes), postgres: MiB(best.writtenBytes), unit: "MiB", detail: other ? `(la otra configuración: ${MiB(other.writtenBytes).toFixed(0)} MiB)` : "" });

  console.log("\nla tarjeta (Cassandra / Postgres; la apuesta pide Postgres ≤ 1,25× en cuatro de cinco)");
  let ok = 0;
  for (const r of card) {
    const ratio = r.postgres / r.cassandra;
    const pass = ratio <= 1.25;
    if (pass) ok++;
    console.log(`  ${r.label.padEnd(44)} ${r.cassandra.toFixed(r.unit === "MiB" ? 0 : 0).padStart(8)} · ${r.postgres.toFixed(0).padStart(8)} ${r.unit.padEnd(6)} → ${ratio.toFixed(2)}× ${pass ? "✓" : "✗"} ${r.detail}`);
  }
  console.log(`  Postgres llega en ${ok} de ${card.length}`);
} finally {
  await cs.shutdown();
  await pgc.end();
}
