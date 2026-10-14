// Carga la trazabilidad de Cóndor en Neo4j (perfil grafos): aeronaves, piezas, conjuntos, talleres y
// las órdenes con movimientos, y sobre todo las ESTADÍAS: cada vez que una pieza estuvo instalada en una
// aeronave, como una relación con su desde y su hasta. Las estadías no están en ningún archivo: se arman
// aquí, recorriendo las órdenes en orden y emparejando cada instalación con el retiro que la cierra.
//
//   node 13-grafos-levantar-y-modelar/load.ts [--dataset lab/data/workOrder-10k] [--batch 5000]   (desde src/)
import { join, resolve } from "node:path";
import { parseArgs } from "node:util";
import neo4j from "neo4j-driver";
import { readNdjson, verifyDataset } from "../lab/harness/dataset.ts";

const { values: args } = parseArgs({
  options: { dataset: { type: "string", default: "lab/data/workOrder-10k" }, batch: { type: "string", default: "5000" } },
});
const dir = resolve(args.dataset!);
const BATCH = Number(args.batch);
const manifest = await verifyDataset(dir);
console.log(`dataset ${args.dataset} · datasetSha256 ${manifest.datasetSha256.slice(0, 12)}… verificado`);

interface Movement { serialNumber: string; partNumber: string; position: string; disposition?: string; supplierId?: string | null; reason?: string }
interface WorkOrder { workOrderId: string; aircraft: string; type: string; openedAt: string; pirepId: string | null; removed: Movement[]; installed: Movement[] }
interface Part { serialNumber: string; partNumber: string; category: string; lotNumber: string; manufacturedOn: string; status: string; aircraft: string | null; position: string | null; supplierId: string | null }
interface Stint { serial: string; aircraft: string; position: string; from: string | null; to: string | null; installedBy: string | null; removedBy: string | null }

const read = async <T>(file: string): Promise<T[]> => {
  const out: T[] = [];
  for await (const r of readNdjson<T>(join(dir, file))) out.push(r);
  return out;
};
const aircraft = await read<Record<string, unknown>>("aircraft.ndjson");
const parts = await read<Part>("part.ndjson");
const suppliers = await read<Record<string, unknown>>("supplier.ndjson");
const assemblies = await read<{ assemblyId: string; kind: string; aircraft: string; position: string; partSerials: string[] }>("assembly.ndjson");
const orders: WorkOrder[] = [];
for await (const w of readNdjson<WorkOrder>(join(dir, "workOrder.ndjson"))) if (w.removed.length || w.installed.length) orders.push(w);
// en orden de tiempo: las órdenes plantadas del generador no van en orden de número
orders.sort((a, b) => a.openedAt.localeCompare(b.openedAt) || a.workOrderId.localeCompare(b.workOrderId));

// las estadías: una pieza retirada sin instalación conocida estaba puesta desde antes de la ventana
const open = new Map<string, Stint>();
const stints: Stint[] = [];
for (const w of orders) {
  for (const m of w.removed) {
    const s = open.get(m.serialNumber) ?? { serial: m.serialNumber, aircraft: w.aircraft, position: m.position, from: null, to: null, installedBy: null, removedBy: null };
    s.to = w.openedAt;
    s.removedBy = w.workOrderId;
    stints.push(s);
    open.delete(m.serialNumber);
  }
  for (const m of w.installed) open.set(m.serialNumber, { serial: m.serialNumber, aircraft: w.aircraft, position: m.position, from: w.openedAt, to: null, installedBy: w.workOrderId, removedBy: null });
}
stints.push(...open.values());
// las piezas que nunca se movieron siguen donde empezaron: su estadía es toda la ventana
const moved = new Set(stints.map((s) => s.serial));
for (const p of parts) {
  if (p.aircraft && !moved.has(p.serialNumber)) stints.push({ serial: p.serialNumber, aircraft: p.aircraft, position: p.position ?? "", from: null, to: null, installedBy: null, removedBy: null });
}
console.log(`armado: ${orders.length} órdenes con movimientos · ${stints.length} estadías`);

const driver = neo4j.driver(`bolt://localhost:${process.env.GRAFOS_BOLT_PORT ?? 17687}`, neo4j.auth.basic("neo4j", "condor-mro"));
const session = driver.session();
let trips = 0;
const run = async (cypher: string, params: Record<string, unknown> = {}) => { trips++; return session.run(cypher, params); };
const inBatches = async (rows: unknown[], cypher: string) => {
  for (let i = 0; i < rows.length; i += BATCH) await run(cypher, { rows: rows.slice(i, i + BATCH) });
};

try {
  const started = performance.now();
  // de cero, en tandas que cierran cada una su transacción, y primero las relaciones: con el heap del
  // laboratorio, borrar nodos con muchas relaciones de una vez agota la memoria de transacciones (E-53)
  for (const q of ["MATCH ()-[r]->() WITH r LIMIT 5000 DELETE r RETURN count(*) AS c", "MATCH (n) WITH n LIMIT 5000 DELETE n RETURN count(*) AS c"]) {
    for (let deleted = 1; deleted > 0;) deleted = (await run(q)).records[0].get("c").toNumber();
  }
  for (const c of ["Aircraft(registration)", "Part(serialNumber)", "WorkOrder(workOrderId)", "Assembly(assemblyId)", "Supplier(supplierId)"]) {
    const [label, prop] = c.split(/[()]/);
    await run(`CREATE CONSTRAINT ${label.toLowerCase()}_key IF NOT EXISTS FOR (n:${label}) REQUIRE n.${prop} IS UNIQUE`);
  }
  await run("CREATE INDEX part_lot IF NOT EXISTS FOR (p:Part) ON (p.lotNumber)");
  await run("CREATE INDEX work_order_pirep IF NOT EXISTS FOR (w:WorkOrder) ON (w.pirepId)");
  await inBatches(aircraft, "UNWIND $rows AS r CREATE (:Aircraft {registration: r.registration, model: r.model, operatorId: r.operatorId, country: r.country})");
  await inBatches(suppliers, "UNWIND $rows AS r CREATE (:Supplier {supplierId: r.supplierId, kind: r.kind, capability: r.capability, country: r.country})");
  await inBatches(parts, "UNWIND $rows AS r CREATE (:Part {serialNumber: r.serialNumber, partNumber: r.partNumber, category: r.category, lotNumber: r.lotNumber, manufacturedOn: r.manufacturedOn, status: r.status})");
  // pirepId: el reporte de piloto que atendió la orden de defecto, si hubo; lo usa el boss del Bloque III
  await inBatches(orders.map((w) => ({ id: w.workOrderId, aircraft: w.aircraft, type: w.type, openedAt: w.openedAt, pirepId: w.pirepId })),
    "UNWIND $rows AS r MATCH (a:Aircraft {registration: r.aircraft}) CREATE (w:WorkOrder {workOrderId: r.id, type: r.type, openedAt: datetime(r.openedAt), pirepId: r.pirepId})-[:ON]->(a)");
  // la estadía: la relación lleva las fechas y las órdenes que la abren y la cierran
  await inBatches(stints, `UNWIND $rows AS r MATCH (p:Part {serialNumber: r.serial}), (a:Aircraft {registration: r.aircraft})
    CREATE (p)-[:INSTALLED {position: r.position, from: CASE WHEN r.from IS NULL THEN null ELSE datetime(r.from) END,
      to: CASE WHEN r.to IS NULL THEN null ELSE datetime(r.to) END, installedBy: r.installedBy, removedBy: r.removedBy}]->(a)`);
  const moves = orders.flatMap((w) => [
    ...w.removed.map((m) => ({ wo: w.workOrderId, serial: m.serialNumber, rel: "REMOVED_IN", disposition: m.disposition, supplierId: m.supplierId ?? null })),
    ...w.installed.map((m) => ({ wo: w.workOrderId, serial: m.serialNumber, rel: "INSTALLED_IN", disposition: null, supplierId: null })),
  ]);
  await inBatches(moves.filter((m) => m.rel === "REMOVED_IN"),
    "UNWIND $rows AS r MATCH (p:Part {serialNumber: r.serial}), (w:WorkOrder {workOrderId: r.wo}) CREATE (p)-[:REMOVED_IN {disposition: r.disposition}]->(w)");
  await inBatches(moves.filter((m) => m.rel === "INSTALLED_IN"),
    "UNWIND $rows AS r MATCH (p:Part {serialNumber: r.serial}), (w:WorkOrder {workOrderId: r.wo}) CREATE (p)-[:INSTALLED_IN]->(w)");
  // la pieza que salió a un taller aliado: la fecha es la de la orden que la retiró
  await inBatches(moves.filter((m) => m.supplierId),
    "UNWIND $rows AS r MATCH (p:Part {serialNumber: r.serial}), (s:Supplier {supplierId: r.supplierId}), (w:WorkOrder {workOrderId: r.wo}) CREATE (p)-[:SENT_TO {at: w.openedAt}]->(s)");
  await inBatches(assemblies, "UNWIND $rows AS r MATCH (a:Aircraft {registration: r.aircraft}) CREATE (x:Assembly {assemblyId: r.assemblyId, kind: r.kind, position: r.position})-[:MOUNTED_ON]->(a)");
  await inBatches(assemblies.flatMap((x) => x.partSerials.map((s) => ({ id: x.assemblyId, serial: s }))),
    "UNWIND $rows AS r MATCH (p:Part {serialNumber: r.serial}), (x:Assembly {assemblyId: r.id}) CREATE (p)-[:PART_OF]->(x)");
  const seconds = (performance.now() - started) / 1000;
  const nodes = (await run("MATCH (n) RETURN count(n) AS n")).records[0].get("n").toNumber();
  const rels = (await run("MATCH ()-[r]->() RETURN count(r) AS n")).records[0].get("n").toNumber();
  console.log(`neo4j: ${nodes} nodos · ${rels} relaciones · ${trips} viajes · ${seconds.toFixed(1)} s`);
} finally {
  await session.close();
  await driver.close();
}
