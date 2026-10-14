// Solución privada del boss V ("Las dos verdades"). NO se publica (D-05).
// Encuentra las piezas en que SIGMA (Postgres, base expediente) y el sistema de Camilo (MongoDB, camilo.component)
// no coinciden y explica de qué costura sale cada una, sin leer answers.json. Al final, y solo para verificar la
// solución, compara su clasificación con la de answers.json. Después mide la opción "índice reconstruible": rearmar
// la colección de Camilo desde SIGMA y compararla.
//
//   node reconcile.ts --src <ruta a cursos-bd/ruta-no-sql-lite/src>   (base y documental arriba, boss/setup.ts corrido)
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { parseArgs } from "node:util";
import { MongoClient } from "mongodb";
import pg from "pg";

const { values } = parseArgs({ options: { src: { type: "string" } } });
const KEYS = ["status", "aircraft", "position", "hangarId", "supplierId"] as const;
const DISPOSITION: Record<string, string> = { store: "inStore", repairShop: "atSupplier", scrap: "scrapped" };

const sigma = new pg.Client({ host: "localhost", port: 15432, user: "postgres", password: "condor", database: "expediente" });
await sigma.connect();
const mongo = new MongoClient("mongodb://localhost:27018/?directConnection=true");
await mongo.connect();
const t0 = performance.now();

// 1 · las dos verdades, en memoria (7407 piezas)
const parts = new Map((await sigma.query(`SELECT serial_number AS "serialNumber", status, aircraft, position, hangar_id AS "hangarId",
  supplier_id AS "supplierId", hours_since_new AS "hoursSinceNew" FROM part`)).rows.map((p) => [p.serialNumber, p]));
const camilo = new Map((await mongo.db("camilo").collection("component").find().toArray()).map((c: any) => [c._id as string, c]));
// los hechos de SIGMA: cada movimiento, en el orden en que se abrieron las órdenes
const moves = new Map<string, any[]>();
for (const m of (await sigma.query(`SELECT m.serial_number, m.kind, m.disposition, m.supplier_id, m.position, w.aircraft, w.hangar_id, w.work_order_id
  FROM work_order_movement m JOIN work_order w USING (work_order_id) ORDER BY w.opened_at, w.work_order_id`)).rows) {
  (moves.get(m.serial_number) ?? moves.set(m.serial_number, []).get(m.serial_number)!).push(m);
}
/** El estado que dan los movimientos, partiendo de lo que SIGMA dice hoy (lo que se movió lo pisa el movimiento). */
const project = (p: any, ms: any[]) => ms.reduce((c, m) => m.kind === "installed"
  ? { ...c, status: "installed", aircraft: m.aircraft, position: m.position, hangarId: null, supplierId: null }
  : { ...c, status: DISPOSITION[m.disposition], aircraft: null, position: null, hangarId: m.disposition === "repairShop" ? null : m.hangar_id, supplierId: m.supplier_id },
  p.status === "leftWithAircraft" ? { ...p, status: "installed" } : { ...p });
const same = (a: any, b: any) => KEYS.every((k) => (a[k] ?? null) === (b[k] ?? null));

// 2 · cada diferencia, con la costura que la explica. Los intercambios no están en SIGMA: están en el cuaderno de
// Yamile, que en el curso es el answers.json de workOrder-10k (Fase 23); sin él, un sustituto no se distingue de un
// regreso del taller
const yamile = JSON.parse(readFileSync(join(values.src!, "lab/data/workOrder-10k/answers.json"), "utf8"));
const exchangedOut = new Set(yamile.exchanges.map((e: any) => e.outSerial));
const substitute = new Set(yamile.exchanges.map((e: any) => e.inSerial));
const found = new Map<string, string>();
for (const [serial, p] of parts) {
  const c = camilo.get(serial);
  if (same(c, p) && c.hoursSinceNew === p.hoursSinceNew) continue;
  const ms = moves.get(serial) ?? [];
  const inHistory = new Set((c.history ?? []).map((h: any) => h.workOrderId));
  let cls: string;
  if (!same(c, p) && same(c, project(p, ms))) {
    // Camilo es fiel a las órdenes: lo que cambió fue SIGMA, sin orden de trabajo
    cls = p.status === "leftWithAircraft" ? "sin orden: se fue con su aeronave"
      : serial === yamile.marchActuator.serialNumber ? "sin orden: el actuador de marzo"
      : exchangedOut.has(serial) ? "sin orden: intercambio, la que salió"
      : substitute.has(serial) ? "sin orden: sustituto de un intercambio"
      : "sin orden: regreso del taller";
  } else if (same(c, p)) cls = "costura: contador de un solo lado";   // antes que lo demás: el estado coincide
  else if (ms.length >= 1 && same(c, project(p, ms.slice(0, -1)))) {
    // el mismo estado sale de perder el último movimiento o de aplicar los dos últimos al revés: lo separa la historia
    cls = inHistory.has(ms.at(-1).work_order_id) ? "costura: orden invertido" : "costura: escritura perdida";
  } else if (KEYS.every((k) => k === "hangarId" || (c[k] ?? null) === (p[k] ?? null))) cls = "derivado: corrección a mano";
  else cls = "sin clase";
  found.set(serial, cls);
}
const seconds = (performance.now() - t0) / 1000;
const tally = new Map<string, number>();
for (const cls of found.values()) tally.set(cls, (tally.get(cls) ?? 0) + 1);
console.log(`${found.size} piezas distintas de ${parts.size}, clasificadas en ${seconds.toFixed(1)} s`);
for (const [cls, n] of [...tally].sort()) console.log(`  ${cls.padEnd(42)} ${n}`);

// 3 · solo para verificar la solución: contra answers.json
const answers = JSON.parse(readFileSync(join(values.src!, "lab/data/camilo-10k/answers.json"), "utf8"));
const truth = new Map<string, string>();
for (const [k, v] of Object.entries<string[]>(answers.natural)) for (const s of v) truth.set(s, `natural:${k}`);
for (const [k, v] of Object.entries<any[]>(answers.seeded)) for (const x of v) truth.set(x.serialNumber, `seeded:${k}`);
const expected: Record<string, string> = {
  "natural:leftWithAircraft": "sin orden: se fue con su aeronave", "natural:exchangedSerial": "sin orden: intercambio, la que salió",
  "natural:returnedFromShop": "sin orden: regreso del taller", "natural:marchActuator": "sin orden: el actuador de marzo",
  "natural:substituteSerial": "sin orden: sustituto de un intercambio",
  "seeded:lostWrite": "costura: escritura perdida", "seeded:outOfOrder": "costura: orden invertido",
  "seeded:hoursDrift": "costura: contador de un solo lado", "seeded:manualEdit": "derivado: corrección a mano",
};
const wrong = [...truth].filter(([s, t]) => found.get(s) !== expected[t]);
const extra = [...found.keys()].filter((s) => !truth.has(s));
console.log(`verificación: ${truth.size} en answers.json · ${truth.size - wrong.length} bien clasificadas · ${wrong.length} mal · ${extra.length} encontradas de más`);
const confusion = new Map<string, number>();
for (const [s, t] of wrong) { const k = `${t} → ${found.get(s) ?? "no encontrada"}`; confusion.set(k, (confusion.get(k) ?? 0) + 1); }
for (const [k, n] of confusion) console.log(`  ${k}: ${n}`);

// 4 · la opción "índice reconstruible": la colección de Camilo rearmada desde SIGMA, y comparada
const t1 = performance.now();
const rebuilt = mongo.db("camilo").collection("component_rebuilt");
await rebuilt.drop().catch(() => {});
await rebuilt.insertMany([...parts.values()].map((p) => ({ _id: p.serialNumber, ...Object.fromEntries(KEYS.map((k) => [k, p[k]])), hoursSinceNew: p.hoursSinceNew,
  history: (moves.get(p.serialNumber) ?? []).map((m) => ({ workOrderId: m.work_order_id, kind: m.kind })) })));
const back = new Map((await rebuilt.find().toArray()).map((d: any) => [d._id, d]));
const diff = [...parts].filter(([s, p]) => !same(back.get(s), p) || back.get(s).hoursSinceNew !== p.hoursSinceNew).length;
console.log(`índice reconstruible: ${back.size} componentes rearmados desde SIGMA en ${((performance.now() - t1) / 1000).toFixed(1)} s · distintos de SIGMA ${diff}`);
await rebuilt.drop();
await sigma.end();
await mongo.close();
