// Qué regiones toca cada sentencia del expediente, según el esquema y según desde dónde se escribe. Tres
// trabajos, cada uno desde su puerta:
//   la autoridad de Ecuador pide el expediente de HC-2157 · desde Ecuador
//   el Coca firma la rutina de HC-2157                    · desde Ecuador
//   Bogotá firma la inspección mayor de HC-2157           · desde Colombia
// Dos fuentes, porque ninguna alcanza sola:
//   · el EXPLAIN ANALYZE de cada sentencia, en el servidor: las regiones que leyó, incluidas las comprobaciones
//     de unicidad y de clave foránea. Un INSERT por el "fast path" no lista la región donde escribe;
//   · SHOW RANGE … FOR ROW de cada fila escrita, después del COMMIT: dónde está su leaseholder y dónde sus
//     votantes, que son los que tienen que confirmar la escritura (sección 6.4).
//
//   node 21-newsql-levantar-y-modelar/regions.ts --db condor_copia --schema copy        (desde src/, con newsql-global
//   node 21-newsql-levantar-y-modelar/regions.ts --db condor --schema regional|autoridad  y la base cargada con load.ts)
import { parseArgs } from "node:util";
import { crdbExplain, inline } from "../lab/harness/crdb-explain.ts";
import { connect } from "./db.ts";
import { BOGOTA, COCA, readSteps, reset, signSteps, type Schema, type Step } from "./expediente.ts";

const { values: args } = parseArgs({ options: { db: { type: "string", default: "condor" }, schema: { type: "string", default: "regional" } } });
const schema = args.schema as Schema;
const HOME = "us-west1";   // la región de la autoridad de Ecuador, la de todas las filas que se escriben aquí

const jobs: [string, "CO" | "EC", Step[], boolean][] = [
  ["la autoridad de Ecuador pide el expediente", "EC", readSteps(schema), false],
  ["el Coca firma la rutina", "EC", signSteps(COCA, schema), true],
  ["Bogotá firma la inspección mayor", "CO", signSteps(BOGOTA, schema), true],
];

const regionOf = (locality: string | null) => /region=([^,]+)/.exec(locality ?? "")?.[1] ?? "sin región";
const admin = await connect("global", args.db!);
const { rows: tables } = await admin.query(`SELECT table_name, locality FROM [SHOW TABLES]`);
const byRow = new Set(tables.filter((t) => /REGIONAL BY ROW/.test(t.locality ?? "")).map((t) => t.table_name));

/** Dónde vive una fila escrita: la región de su leaseholder y las de sus votantes. */
async function placement(row: NonNullable<Step["row"]>) {
  const values = [...(byRow.has(row.table) ? [HOME] : []), ...row.key];
  const { rows: [r] } = await admin.query(inline(admin,
    `SELECT lease_holder_locality, replicas, replica_localities, voting_replicas FROM [SHOW RANGE FROM TABLE ${row.table} FOR ROW (${values.map((_, i) => `$${i + 1}`).join(", ")})]`, values));
  // replicas y replica_localities van en el mismo orden; voting_replicas dice cuáles votan
  const where = new Map((r.replicas as number[]).map((n, i) => [n, regionOf(r.replica_localities[i])]));
  const voters = (r.voting_replicas as number[]).map((n) => where.get(n)!);
  const lease = regionOf(r.lease_holder_locality);
  // Raft confirma con la mayoría de los votantes: si la región del leaseholder no la tiene, hace falta otra
  const quorumAtHome = voters.filter((v) => v === lease).length > voters.length / 2;
  return { lease, voters: [...new Set(voters)].sort(), quorumAtHome };
}

console.log(`${args.db} · esquema ${schema}`);
await reset(admin);
for (const [label, country, steps, tx] of jobs) {
  const db = await connect("global", args.db!, country);
  const { rows: [{ g }] } = await db.query("SELECT gateway_region() AS g");
  console.log(`  ${label} · desde ${country} (${g})`);
  const all = new Set<string>([g]);
  const lines: string[] = [];
  let quorumAway = false;
  if (tx) await db.query("BEGIN");
  for (const s of steps) {
    const e = await crdbExplain(db, s.sql, s.params);
    e.regions.forEach((r) => all.add(r));
    lines.push(`    ${s.name.padEnd(28)} lee en ${(e.regions.join(", ") || g).padEnd(36)} nodos ${(e.kvNodes.join(" ") || "—").padEnd(18)} filas del almacén ${String(e.kvRows).padStart(3)}`);
  }
  if (tx) await db.query("COMMIT");
  // después del COMMIT, dónde quedó cada fila escrita
  for (const [i, s] of steps.entries()) {
    if (!s.row) continue;
    const p = await placement(s.row);
    all.add(p.lease);
    quorumAway ||= !p.quorumAtHome;
    lines[i] += ` · escribe en ${p.lease}, votan ${p.voters.join(" ")}${p.quorumAtHome ? "" : " (quórum fuera)"}`;
  }
  lines.forEach((l) => console.log(l));
  const out = [...all].filter((r) => r !== g);
  const quorum = quorumAway ? " · y el quórum de alguna escritura necesita otra región más" : "";
  console.log(`    en total: ${[...all].sort().join(", ")} · ${out.length ? `${out.length} región(es) fuera de ${g}` : "todo local"}${quorum}`);
  await db.end();
}
await reset(admin);
await admin.end();
