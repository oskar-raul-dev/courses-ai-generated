// La misma fila desde varias regiones (secciones 4.3 y 5). La fila es el motor 1 de HC-2157 (SN-0005382), que vive
// en Colombia: cada vuelo le suma horas, y los vuelos aterrizan en los tres países. Cada trabajador, desde la puerta
// de su país, repite durante --seconds una de dos transacciones:
//   leer-y-escribir · BEGIN; lee las horas; escribe las horas + 1; COMMIT       (la forma de la aplicación)
//   atómica         · UPDATE … SET hours_since_new = hours_since_new + 1        (una sentencia, sin leer antes)
//   partida         · cada país suma en su propia fila (engine_hours_by_region, una fila por país, en su región);
//                     las horas del motor son la suma de las tres, al leer                  (sección 6)
// con withRetry, y escalones de 1, 2, 4, 8 y 16 trabajadores por región. Al final de cada escalón se comprueba que
// las horas sumadas sean exactamente las transacciones confirmadas.
// La latencia de cada transacción es la del cliente, que está en la misma máquina que su puerta: el servidor más
// el loopback, transacción por transacción, nunca un lote.
//
//   node 22-newsql-romper-y-medir/contention.ts --target global [--seconds 20] [--regions CO,EC,PE] [--kind rmw|atomic|split]
//   node 22-newsql-romper-y-medir/contention.ts --target primario …   (Postgres, sin red: la referencia sin geografía)
import { parseArgs } from "node:util";
import type pg from "pg";
import { connect, type Target } from "../21-newsql-levantar-y-modelar/db.ts";
import { withRetry, type RetryStats } from "./retry.ts";

const { values: args } = parseArgs({ options: {
  target: { type: "string", default: "global" }, seconds: { type: "string", default: "20" }, regions: { type: "string", default: "CO,EC,PE" },
  kind: { type: "string", default: "rmw" }, steps: { type: "string", default: "1,2,4,8,16" }, isolation: { type: "string", default: "SERIALIZABLE" },
} });
const target = args.target as Target;
const database = target === "global" ? "condor" : "expediente";
const ENGINE = "SN-0005382";
const regions = args.regions!.split(",") as ("CO" | "EC" | "PE")[];
const pct = (xs: number[], p: number) => { const s = [...xs].sort((a, b) => a - b); return s.length ? s[Math.min(s.length - 1, Math.floor(p * s.length))] : NaN; };

async function rmw(db: pg.Client) {
  const { rows: [r] } = await db.query(`SELECT hours_since_new FROM part WHERE serial_number = $1`, [ENGINE]);
  await db.query(`UPDATE part SET hours_since_new = $2 WHERE serial_number = $1`, [ENGINE, Number(r.hours_since_new) + 1]);   // INT de CockroachDB es de 8 bytes: el driver lo trae como texto
}
async function split(db: pg.Client, country: string) {
  const r = await db.query(`UPDATE engine_hours_by_region SET hours = hours + 1 WHERE country = $2 AND serial_number = $1`, [ENGINE, country]);
  if (r.rowCount !== 1) throw new Error(`la fila de ${country} no existe: la suma no se hizo`);
}
async function atomic(db: pg.Client) {
  await db.query(`UPDATE part SET hours_since_new = hours_since_new + 1 WHERE serial_number = $1`, [ENGINE]);
}

const admin = await connect(target, database);
if (args.kind === "split") {
  // una fila por país, cada una en su región: el país va en la clave y la región sale de él, como en la Fase 21
  await admin.query(`DROP TABLE IF EXISTS engine_hours_by_region`);
  await admin.query(`CREATE TABLE engine_hours_by_region (country text NOT NULL, serial_number text NOT NULL, hours int NOT NULL DEFAULT 0,
    crdb_region crdb_internal_region NOT VISIBLE NOT NULL AS (
      CASE country WHEN 'EC' THEN 'us-west1' WHEN 'PE' THEN 'europe-west1' ELSE 'us-east1' END) STORED,
    PRIMARY KEY (country, serial_number)) LOCALITY REGIONAL BY ROW`);
  for (const c of ["CO", "EC", "PE"]) await admin.query(`INSERT INTO engine_hours_by_region (country, serial_number) VALUES ($1, $2)`, [c, ENGINE]);
}
const hours = args.kind === "split"
  ? async () => Number((await admin.query(`SELECT sum(hours) AS h FROM engine_hours_by_region WHERE serial_number = $1`, [ENGINE])).rows[0].h)
  : async () => Number((await admin.query(`SELECT hours_since_new FROM part WHERE serial_number = $1`, [ENGINE])).rows[0].hours_since_new);
const original = await hours();
console.log(`${target} · ${{ atomic: "atómica", split: "partida por región", rmw: "leer-y-escribir" }[args.kind!]} · ${args.isolation} · regiones ${regions.join(", ")} · ${args.seconds} s por escalón · fila ${ENGINE}`);

const seen = new Set<string>();
for (const perRegion of args.steps!.split(",").map(Number)) {
  const before = await hours();
  const stats: RetryStats = { attempts: 0, reasons: {}, samples: {} };
  const lat: Record<string, number[]> = {};
  let commits = 0, gaveUp = 0;
  const end = performance.now() + Number(args.seconds) * 1000;
  const workers = await Promise.all(regions.flatMap((country) => Array.from({ length: perRegion }, async () => {
    const db = await connect(target, database, country);
    if (args.isolation !== "SERIALIZABLE") await db.query(`SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL ${args.isolation}`);
    else if (target !== "global") await db.query(`SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL SERIALIZABLE`);
    return { db, country };
  })));
  await Promise.all(workers.map(async ({ db, country }) => {
    while (performance.now() < end) {
      const t0 = performance.now();
      const done = args.kind === "atomic" ? await atomic(db).then(() => (stats.attempts++, true))
        : args.kind === "split" ? await split(db, country).then(() => (stats.attempts++, true))
        : await withRetry(db, async (d) => (await rmw(d), true), stats);
      if (done) { commits++; (lat[country] ??= []).push(performance.now() - t0); } else gaveUp++;
    }
  }));
  await Promise.all(workers.map(({ db }) => db.end()));
  const all = Object.values(lat).flat();
  const added = (await hours()) - before;
  const retries = stats.attempts - commits - gaveUp;
  console.log(`  ${String(perRegion * regions.length).padStart(3)} trabajadores · ${(commits / Number(args.seconds)).toFixed(1).padStart(6)} confirmadas/s · ` +
    `reintentos por confirmada ${(retries / Math.max(1, commits)).toFixed(2).padStart(5)} · se rindieron ${gaveUp} · ` +
    `p50 ${pct(all, 0.5).toFixed(0).padStart(5)} ms · p99 ${pct(all, 0.99).toFixed(0).padStart(5)} ms · ` +
    regions.map((c) => `${c} p50 ${pct(lat[c] ?? [], 0.5).toFixed(0)}`).join(" · ") +
    ` · horas sumadas ${added} de ${commits}${added === commits ? "" : " ⚠️"} · ` + Object.entries(stats.reasons).map(([k, v]) => `${k} ${v}`).join(", "));
  for (const [k, m] of Object.entries(stats.samples ?? {})) if (!seen.has(k)) { seen.add(k); console.log(`      ${k}, literal: ${m}`); }
}
if (args.kind === "split") await admin.query(`DROP TABLE engine_hours_by_region`);
else await admin.query(`UPDATE part SET hours_since_new = $2 WHERE serial_number = $1`, [ENGINE, original]);
await admin.end();
