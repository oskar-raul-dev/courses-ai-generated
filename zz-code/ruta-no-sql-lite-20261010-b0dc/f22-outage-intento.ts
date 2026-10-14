// La región que se cae (sección 6): con el expediente restringido a Ecuador, se apagan los tres nodos de Ecuador
// (n4–n6) y se intenta lo de siempre: Bogotá firma la inspección mayor de HC-2157, Perú pide el expediente, y
// Bogotá trabaja con una aeronave colombiana. Cada sentencia lleva un statement_timeout de 15 s.
//
//   node 22-newsql-romper-y-medir/outage.ts   (desde src/, con newsql-global y la base de la autoridad restringida;
//                                              el demo queda sin Ecuador: hay que recrearlo después)
import { execSync } from "node:child_process";
import type pg from "pg";
import { inline } from "../lab/harness/crdb-explain.ts";
import { connect } from "../21-newsql-levantar-y-modelar/db.ts";
import { BOGOTA, readSteps, reset, signSteps } from "../21-newsql-levantar-y-modelar/expediente.ts";

const sh = (cmd: string) => { try { return execSync(cmd, { stdio: ["ignore", "pipe", "pipe"] }).toString().trim(); } catch (e: any) { return (e.stdout?.toString() || e.stderr?.toString() || e.message).trim(); } };
async function attempt(label: string, db: pg.Client, sql: string) {
  const t0 = performance.now();
  try { await db.query(sql); console.log(`  ${label.padEnd(44)} · bien · ${(performance.now() - t0).toFixed(0)} ms`); }
  catch (e: any) { console.log(`  ${label.padEnd(44)} · ${e.code} ${e.message.split("\n")[0].slice(0, 160)} · ${(performance.now() - t0).toFixed(0)} ms`); await db.query("ROLLBACK").catch(() => {}); }
}
const jobs = async (when: string) => {
  console.log(when);
  const co = await connect("global", "condor", "CO"), pe = await connect("global", "condor", "PE");
  for (const db of [co, pe]) await db.query("SET statement_timeout = '15s'");
  await reset(co).catch(() => {});
  await attempt("Bogotá firma la inspección de HC-2157", co, ["BEGIN", ...signSteps(BOGOTA, "autoridad").map((s) => inline(co, s.sql, s.params)), "COMMIT"].join(";\n"));
  await attempt("Perú pide el expediente de HC-2157", pe, readSteps("autoridad").map((s) => inline(pe, s.sql, s.params)).join(";\n"));
  await attempt("Bogotá lee la aeronave colombiana HK-5339", co, `SELECT * FROM aircraft WHERE country = 'CO' AND registration = 'HK-5339'`);
  await attempt("Bogotá cambia una pieza de Colombia", co, `UPDATE part SET hours_since_new = hours_since_new WHERE serial_number = 'SN-0000011'`);
  await Promise.all([co.end(), pe.end()]);
};

await jobs("con las tres regiones arriba");
for (const n of [4, 5, 6]) console.log(`apagar n${n}: ${sh(`docker exec condor-lab-newsql-global-1 cockroach node drain ${n} --shutdown --insecure --host=localhost:26257`).split("\n").pop()}`);
console.log(`nodos: ${sh(`docker exec condor-lab-newsql-global-1 cockroach node status --insecure --host=localhost:26257 --format=csv`).split("\n").map((l) => l.split(",")).filter((c) => /^\d/.test(c[0])).map((c) => `n${c[0]} ${c.at(-1)}`).join(" · ")}`);
await jobs("sin Ecuador");
