// El mismo esquema y las mismas sentencias en Postgres y en CockroachDB de un nodo: leer el expediente de
// HC-2157 y firmar la inspección mayor de Bogotá en una transacción. Cada sentencia se mide sola, con el
// EXPLAIN ANALYZE de cada motor, dentro de la transacción (sección 6.2).
//
//   node 21-newsql-levantar-y-modelar/transactions.ts   (desde src/, con base y newsql arriba y load.ts corrido)
import type pg from "pg";
import { explain } from "../lab/harness/explain.ts";
import { crdbExplain } from "../lab/harness/crdb-explain.ts";
import { connect, type Target } from "./db.ts";
import { BOGOTA, readSteps, reset, signSteps, type Step } from "./expediente.ts";

/** Postgres: filas examinadas, bloques y cuántas comprobaciones de clave foránea disparó la sentencia. */
async function pgShape(db: pg.Client, s: Step) {
  const e = await explain(db, s.sql, s.params);
  return `filas examinadas ${String(e.examined).padStart(5)} · bloques ${String(e.sharedHit + e.sharedRead).padStart(4)} · claves foráneas ${e.fkChecks}`;
}

async function crdbShape(db: pg.Client, s: Step) {
  const e = await crdbExplain(db, s.sql, s.params);
  const checks = e.operators.filter((o) => /constraint-check|check/.test(o)).length;
  return `filas leídas del almacén ${String(e.kvRows).padStart(5)} · llamadas gRPC ${String(e.grpcCalls).padStart(2)} · operadores ${e.operators.length} (${checks} de comprobación) · ${e.operators.join(", ")}`;
}

for (const [target, database] of [["base", "expediente"], ["newsql", "condor"]] as [Target, string][]) {
  const db = await connect(target, database);
  await reset(db);
  const shape = target === "base" ? pgShape : crdbShape;
  const { rows: [{ v }] } = await db.query(target === "base" ? "SELECT split_part(version(), ' on', 1) AS v" : "SELECT split_part(version(), ' (', 1) AS v");
  const { rows: [{ transaction_isolation }] } = await db.query("SHOW transaction_isolation");
  console.log(`\n${v} · aislamiento por defecto: ${transaction_isolation}`);
  console.log("  leer el expediente de HC-2157");
  for (const s of readSteps()) console.log(`    ${s.name.padEnd(28)} ${await shape(db, s)}`);
  console.log("  firmar la inspección mayor de Bogotá, en una transacción");
  await db.query("BEGIN");
  for (const s of signSteps(BOGOTA)) console.log(`    ${s.name.padEnd(28)} ${await shape(db, s)}`);
  await db.query("COMMIT");
  const { rows: [after] } = await db.query(`SELECT count(*) FILTER (WHERE status = 'installed') AS installed FROM part WHERE serial_number = $1`, [BOGOTA.installed.serialNumber]);
  console.log(`    COMMIT · el actuador nuevo quedó instalado: ${Number(after.installed) === 1 ? "sí" : "no"}`);
  await reset(db);
  await db.end();
}
