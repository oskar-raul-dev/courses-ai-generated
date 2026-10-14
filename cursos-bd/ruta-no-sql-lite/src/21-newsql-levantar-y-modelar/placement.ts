// Dónde viven las filas del operador estatal ecuatoriano (OP-EST: HC-2157 y HC-1475), que por contrato no
// pueden salir de Ecuador (us-west1 en el laboratorio). Para cada fila de su expediente se pregunta en qué
// rango está y dónde tiene copias ese rango: votantes (las que hacen consenso), no votantes (copias para
// leer) y el leaseholder (el que atiende). Con el esquema de la Fase 01 copiado, un solo estado; con un
// esquema regional, tres:
//   por defecto  · REGIONAL BY ROW por autoridad, sin más
//   restringido  · lo mismo con PLACEMENT RESTRICTED
//   y qué pasa si se pide además sobrevivir a la caída de una región (sección 6.4).
// Con --super, en lugar de PLACEMENT RESTRICTED se prueba lo que la documentación recomienda: una super región
// que contiene solo a Ecuador.
//
//   node 21-newsql-levantar-y-modelar/placement.ts --db condor_copia --schema copy                 (desde src/, con
//   node 21-newsql-levantar-y-modelar/placement.ts --db condor --schema regional|autoridad [--keep] [--super]
//                                                                                    (newsql-global y load.ts)
import { parseArgs } from "node:util";
import type pg from "pg";
import { inline } from "../lab/harness/crdb-explain.ts";
import { connect } from "./db.ts";

const { values: args } = parseArgs({ options: { db: { type: "string", default: "condor" }, schema: { type: "string", default: "regional" }, keep: { type: "boolean", default: false }, super: { type: "boolean", default: false } } });
const HOME = "us-west1";
const OPERATOR = "OP-EST";

/** Las filas del expediente del operador, con la clave primaria de cada tabla. Con la autoridad en la clave,
 *  la clave empieza por ella (el país, en la aeronave). */
const auth = args.schema === "autoridad";
const EXPEDIENTE: [string, string[], string][] = [
  ["aircraft", auth ? ["country", "registration"] : ["registration"], `SELECT a.* FROM aircraft a WHERE operator_id = $1`],
  ["work_order", [...(auth ? ["authority"] : []), "work_order_id"], `SELECT w.* FROM work_order w JOIN aircraft a ON a.registration = w.aircraft WHERE a.operator_id = $1`],
  ["work_order_technician", [...(auth ? ["authority"] : []), "work_order_id", "technician_id"], `SELECT t.* FROM work_order_technician t JOIN work_order w USING (work_order_id) JOIN aircraft a ON a.registration = w.aircraft WHERE a.operator_id = $1`],
  ["work_order_movement", [...(auth ? ["authority"] : []), "work_order_id", "kind", "serial_number"], `SELECT m.* FROM work_order_movement m JOIN work_order w USING (work_order_id) JOIN aircraft a ON a.registration = w.aircraft WHERE a.operator_id = $1`],
  ["assembly", [...(auth ? ["authority"] : []), "assembly_id"], `SELECT s.* FROM assembly s JOIN aircraft a ON a.registration = s.aircraft WHERE a.operator_id = $1`],
  ["pirep", [...(auth ? ["authority"] : []), "pirep_id"], `SELECT p.* FROM pirep p JOIN aircraft a ON a.registration = p.aircraft WHERE a.operator_id = $1`],
  ["part", ["serial_number"], `SELECT p.* FROM part p JOIN aircraft a ON a.registration = p.aircraft WHERE a.operator_id = $1`],
];

// un rango recién partido puede no tener todavía leaseholder ni localidad: cuenta como "sin región"
const regionsOf = (localities: (string | null)[]) => [...new Set(localities.map((l) => /region=([^,]+)/.exec(l ?? "")?.[1] ?? "sin región"))];

interface Census { rows: number; ranges: number; outside: boolean; replicaRegions: string[]; leaseRegions: string[]; sampled: string }

/** Los rangos que guardan las filas del operador: en la copia, todos los de la tabla (cada uno mezcla las tres
 *  autoridades); en el esquema regional, los de la partición de Ecuador, que tienen su leaseholder en Ecuador.
 *  Una muestra de filas, ubicada con SHOW RANGE … FOR ROW, comprueba que caen en esos rangos. */
async function census(db: pg.Client, regional: boolean) {
  const out: Record<string, Census> = {};
  for (const [table, pk, sql] of EXPEDIENTE) {
    const { rows } = await db.query(sql, [OPERATOR]);
    rows.sort((a, b) => pk.map((k) => a[k]).join("|").localeCompare(pk.map((k) => b[k]).join("|")));
    const { rows: [{ locality }] } = await db.query(`SELECT locality FROM [SHOW TABLES] WHERE table_name = $1`, [table]);
    const byRow = regional && /REGIONAL BY ROW/.test(locality ?? "");
    // la muestra, en orden de clave: la primera, la última y diez repartidas
    const sample = [...new Set([0, rows.length - 1, ...Array.from({ length: 10 }, (_, i) => Math.floor((i * rows.length) / 10))])].filter((i) => i >= 0 && i < rows.length);
    const where = async (i: number) => {
      // en REGIONAL BY ROW la clave empieza por la región; SHOW RANGE … FOR ROW no acepta parámetros (E-73)
      const values = [...(byRow ? [HOME] : []), ...pk.map((k) => rows[i][k])];
      const { rows: [range] } = await db.query(inline(db,
        `SELECT range_id, lease_holder_locality FROM [SHOW RANGE FROM TABLE ${table} FOR ROW (${values.map((_, j) => `$${j + 1}`).join(", ")})]`, values));
      return range as { range_id: number; lease_holder_locality: string };
    };
    // en REGIONAL BY ROW, el clúster tarda en llevar los leaseholders a su región: se espera a que la muestra esté en casa
    if (byRow) {
      const t0 = performance.now();
      const located = async () => { const rs = []; for (const i of sample) rs.push(await where(i)); return rs; };
      while ((await located()).some((r) => regionsOf([r.lease_holder_locality])[0] !== HOME) && performance.now() - t0 < 300_000)
        await new Promise((ok) => setTimeout(ok, 5000));
    }
    const { rows: all } = await db.query(`SELECT range_id, lease_holder_locality, replica_localities FROM [SHOW RANGES FROM TABLE ${table} WITH DETAILS]`);
    const holding = all.filter((r) => !byRow || regionsOf([r.lease_holder_locality])[0] === HOME);
    const ids = new Set(holding.map((r) => r.range_id));
    let inside = 0;
    for (const i of sample) if (ids.has((await where(i)).range_id)) inside++;
    const replicaRegions = [...new Set(holding.flatMap((r) => regionsOf(r.replica_localities)))].sort();
    out[`${table} (${(locality ?? "sin localidad").replace("REGIONAL BY TABLE IN PRIMARY REGION", "REGIONAL BY TABLE").replace(/ IN "[^"]+"/, "")})`] = {
      rows: rows.length, ranges: holding.length, outside: replicaRegions.some((x) => x !== HOME), replicaRegions,
      leaseRegions: [...new Set(holding.map((r) => regionsOf([r.lease_holder_locality])[0]))].sort(),
      sampled: `${inside}/${sample.length}`,
    };
  }
  return out;
}

function report(label: string, c: Record<string, Census>) {
  const rows = Object.values(c).reduce((n, x) => n + x.rows, 0), outside = Object.values(c).reduce((n, x) => n + (x.outside ? x.rows : 0), 0);
  console.log(`\n${label} · filas del expediente de ${OPERATOR}: ${rows} · en rangos con alguna copia fuera de ${HOME}: ${outside}`);
  for (const [t, x] of Object.entries(c))
    console.log(`  ${t.padEnd(46)} ${String(x.rows).padStart(4)} filas · ${x.ranges} rango(s) (muestra dentro: ${x.sampled}) · ` +
      `copias en ${x.replicaRegions.join(", ")} · leaseholder en ${x.leaseRegions.join(", ")}`);
}

/** Espera a que el clúster mueva las réplicas a lo que dice la configuración nueva (o se rinde a los 5 min).
 *  Mira los rangos con el leaseholder en Ecuador: los del expediente. */
async function settle(db: pg.Client) {
  const t0 = performance.now();
  for (;;) {
    const { rows } = await db.query(`SELECT count(*)::int AS n FROM [SHOW RANGES FROM DATABASE ${args.db} WITH DETAILS] WHERE array_length(non_voting_replicas, 1) > 0 AND lease_holder_locality LIKE '%${HOME}%'`);
    if (rows[0].n === 0 || performance.now() - t0 > 300_000) return { left: rows[0].n, seconds: (performance.now() - t0) / 1000 };
    await new Promise((ok) => setTimeout(ok, 5000));
  }
}

const db = await connect("global", args.db!);
if (args.schema === "copy") {
  report("copia (esquema de la Fase 01)", await census(db, false));
  const { rows: [zc] } = await db.query(`SELECT raw_config_sql FROM [SHOW ZONE CONFIGURATION FROM TABLE work_order]`);
  console.log(`  configuración: ${zc.raw_config_sql.replace(/\s+/g, " ")}`);
} else {
  // PLACEMENT viene apagado: el primer intento falla con su mensaje literal (E-70 en a09)
  try { await db.query(`ALTER DATABASE ${args.db} PLACEMENT DEFAULT`); }
  catch (e: any) { console.log(`\nALTER DATABASE ${args.db} PLACEMENT DEFAULT · ${e.code} ${e.message} · HINT: ${e.hint}`); }
  await db.query("SET enable_multiregion_placement_policy = on");
  await db.query(`ALTER DATABASE ${args.db} PLACEMENT DEFAULT`);
  report(`${args.schema}, por defecto`, await census(db, true));
  const { rows: [zc] } = await db.query(`SELECT raw_config_sql FROM [SHOW ZONE CONFIGURATION FROM TABLE work_order]`);
  console.log(`  configuración: ${zc.raw_config_sql.replace(/\s+/g, " ")}`);

  const sql = `ALTER DATABASE ${args.db} SURVIVE REGION FAILURE`;
  const survive = async () => {
    try { await db.query(sql); console.log(`\n${sql} · aceptado`); await db.query(`ALTER DATABASE ${args.db} SURVIVE ZONE FAILURE`); }
    catch (e: any) { console.log(`\n${sql} · ${e.code} ${e.message}${e.hint ? ` · HINT: ${e.hint}` : ""}`); }
  };
  if (!args.super) {
    await db.query(`ALTER DATABASE ${args.db} PLACEMENT RESTRICTED`);
    const s = await settle(db);
    console.log(`\nPLACEMENT RESTRICTED · réplicas movidas en ${s.seconds.toFixed(0)} s · rangos de Ecuador que todavía tienen copias no votantes: ${s.left}`);
    report(`${args.schema}, con PLACEMENT RESTRICTED`, await census(db, true));
  } else {
    // la super región: los datos de sus regiones no salen de ella; con una sola región, no salen de Ecuador
    const add = `ALTER DATABASE ${args.db} ADD SUPER REGION "ecuador" VALUES "us-west1"`;
    try { await db.query(add); }
    catch (e: any) {
      console.log(`\n${add} · ${e.code} ${e.message}${e.hint ? ` · HINT: ${e.hint}` : ""}`);
      await db.query("SET enable_super_regions = 'on'");
      await db.query(add);
    }
    const s = await settle(db);
    console.log(`\nSUPER REGION "ecuador" · réplicas movidas en ${s.seconds.toFixed(0)} s · rangos de Ecuador que todavía tienen copias no votantes: ${s.left}`);
    report(`${args.schema}, con la super región de Ecuador`, await census(db, true));
  }
  // sobrevivir a la caída de Ecuador exige votantes fuera de Ecuador
  await survive();
  if (!args.keep) await db.query(`ALTER DATABASE ${args.db} PLACEMENT DEFAULT`);
}
await db.end();
