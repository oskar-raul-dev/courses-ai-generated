// Los rangos de una base: cuántos hay, qué tablas cubre cada uno, quién es su leaseholder y dónde están sus
// réplicas votantes y no votantes. En un nodo (newsql) y en nueve (newsql-global) (sección 6.3).
//
//   node 21-newsql-levantar-y-modelar/ranges.ts --target newsql|global --db condor   (desde src/, con load.ts corrido)
import { parseArgs } from "node:util";
import { connect, type Target } from "./db.ts";

const { values: args } = parseArgs({ options: { target: { type: "string", default: "newsql" }, db: { type: "string", default: "condor" } } });
const db = await connect(args.target as Target, args.db!);
const where = (locality: string) => /region=([^,]+)/.exec(locality)?.[1] ?? "sin región";

const { rows } = await db.query(`
  SELECT r.range_id, r.lease_holder, r.lease_holder_locality, r.replicas, r.replica_localities, r.voting_replicas, r.non_voting_replicas,
         array_agg(DISTINCT r.table_name) AS tables
    FROM [SHOW RANGES FROM DATABASE ${args.db} WITH TABLES, DETAILS] r
   GROUP BY 1, 2, 3, 4, 5, 6, 7 ORDER BY 1`);
const { rows: [zc] } = await db.query(`SELECT raw_config_sql FROM [SHOW ZONE CONFIGURATION FROM DATABASE ${args.db}]`);
console.log(`${args.target} · base ${args.db} · ${rows.length} rango(s) · ${zc.raw_config_sql.replace(/\s+/g, " ")}`);
for (const r of rows) {
  const at = new Map((r.replicas as number[]).map((n, i) => [n, where(r.replica_localities[i])]));
  const list = (ns: number[]) => ns.map((n) => `n${n} ${at.get(n)}`).join(", ") || "ninguna";
  console.log(`  rango ${r.range_id} · ${r.tables.length} tabla(s): ${[...r.tables].sort().join(", ")}`);
  console.log(`    leaseholder n${r.lease_holder} ${where(r.lease_holder_locality)} · votantes: ${list(r.voting_replicas)} · no votantes: ${list(r.non_voting_replicas)}`);
}
await db.end();
