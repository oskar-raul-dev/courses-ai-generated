// El reloj. Primero, qué hora da cada región: el reloj híbrido (HLC) de CockroachDB, pared más contador
// lógico. Después, la incertidumbre provocada: una lectura que llega a un valor escrito "en su futuro
// cercano", menos de 500 ms después de que empezó, en un nodo que todavía no había visitado.
//
//   lectora  (Quito)  BEGIN · lee la última orden de HC-2157 ·                      · lee el actuador de nariz
//   firmante (Coca)                                       · cambia la orden y el actuador · COMMIT
//
// La orden vive en Ecuador y el actuador (la pieza) en Colombia, que la lectora no ha visitado. Al leer el
// actuador encuentra un valor con fecha posterior a la suya pero dentro de su intervalo de incertidumbre:
// no sabe si se escribió antes o después de que ella empezara. Para avanzar tendría que mover su fecha y
// volver a validar lo ya leído, y lo ya leído (la orden) también cambió: la transacción se reinicia (sección 6.5).
//
//   node 21-newsql-levantar-y-modelar/clock.ts [--schema autoridad] [--runs 5]   (desde src/, con newsql-global y la
//                                                                                base condor cargada con load.ts)
import { parseArgs } from "node:util";
import { connect } from "./db.ts";
import { AIRCRAFT } from "./expediente.ts";

const { values: args } = parseArgs({ options: { runs: { type: "string", default: "5" }, schema: { type: "string", default: "autoridad" } } });
const ORDER = "WO-0009965", PART = "SN-0001068";
// con la autoridad en la clave, la orden se pide con su autoridad: si no, el motor la busca en las tres regiones
// y, al pasar por Colombia, la lectora ya no tendría incertidumbre sobre el actuador (sección 6.5)
const byOrder = args.schema === "autoridad" ? `authority = 'EC' AND work_order_id = $1` : `work_order_id = $1`;

// qué hora dice cada región, una tras otra
for (const country of ["CO", "EC", "PE"] as const) {
  const db = await connect("global", "condor", country);
  const { rows: [r] } = await db.query(`SELECT gateway_region() AS region, cluster_logical_timestamp()::string AS hlc, now()::string AS now`);
  console.log(`${country} · ${r.region.padEnd(12)} · cluster_logical_timestamp ${r.hlc} · now() ${r.now}`);
  await db.end();
}

const reader = await connect("global", "condor", "EC");
const signer = await connect("global", "condor", "EC");
const { rows: [{ labor_hours: original }] } = await signer.query(`SELECT labor_hours FROM work_order WHERE ${byOrder}`, [ORDER]);
const { rows: [{ hours_since_new: originalHours }] } = await signer.query(`SELECT hours_since_new FROM part WHERE serial_number = $1`, [PART]);

let restarts = 0;
for (let run = 1; run <= Number(args.runs); run++) {
  const t0 = performance.now();
  const ms = () => `${(performance.now() - t0).toFixed(0).padStart(4)} ms`;
  const log: string[] = [];
  await reader.query("BEGIN");
  const { rows: [{ ts }] } = await reader.query(`SELECT cluster_logical_timestamp()::string AS ts`);
  await reader.query(`SELECT labor_hours FROM work_order WHERE ${byOrder}`, [ORDER]);
  log.push(`${ms()} lectora lee la orden`);
  await signer.query("BEGIN");
  await signer.query(`UPDATE work_order SET labor_hours = labor_hours + 1 WHERE ${byOrder}`, [ORDER]);
  await signer.query(`UPDATE part SET hours_since_new = hours_since_new + 1 WHERE serial_number = $1 AND aircraft = $2`, [PART, AIRCRAFT]);
  await signer.query("COMMIT");
  log.push(`${ms()} firmante confirma`);
  try {
    await reader.query(`SELECT hours_since_new FROM part WHERE serial_number = $1`, [PART]);
    await reader.query("COMMIT");
    log.push(`${ms()} lectora lee el actuador y confirma`);
  } catch (e: any) {
    restarts++;
    await reader.query("ROLLBACK");
    const m = /ReadWithinUncertaintyIntervalError: read at time ([\d.,]+) encountered previous write with future timestamp ([\d.,]+) within uncertainty interval `t <= \(local=([\d.,]+), global=([\d.,]+)\)`/.exec(e.message);
    log.push(`${ms()} lectora: ${e.code} ${m ? "ReadWithinUncertaintyIntervalError" : e.message.split("\n")[0]}`);
    if (m) {
      const sec = (s: string) => Number(s.split(",")[0]);
      log.push(`         su fecha ${m[1]} · la escritura ${m[2]} (+${((sec(m[2]) - sec(m[1])) * 1000).toFixed(0)} ms) · su límite ${m[4]} (+${((sec(m[4]) - sec(m[1])) * 1000).toFixed(0)} ms)`);
      if (run === 1) log.push(`         ${e.message.split("\n")[0]}`);
    }
  }
  console.log(`\nvuelta ${run} · la lectora empezó en ${ts}`);
  for (const l of log) console.log(`  ${l}`);
}
console.log(`\nreinicios por incertidumbre: ${restarts} de ${args.runs}`);
await signer.query(`UPDATE work_order SET labor_hours = $2 WHERE ${byOrder}`, [ORDER, original]);
await signer.query(`UPDATE part SET hours_since_new = $2 WHERE serial_number = $1`, [PART, originalHours]);
await Promise.all([reader.end(), signer.end()]);
