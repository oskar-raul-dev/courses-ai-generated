// El sistema de componentes de Camilo, ya divergido de SIGMA: el dataset del boss del Bloque V ("Las dos verdades").
//
//   node src/diverge.ts [--from ../data/workOrder-10k] [--seed condor-mro] [--per-class 100]
//
// Lee un dataset ya generado (y comprobado contra su manifiesto) y escribe, al lado, `camilo-<volumen>/` con
// component.ndjson —un documento por pieza, como lo guarda el MongoDB de Camilo—, answers.json con cada discrepancia
// y la costura de la que sale, y manifest.json con su hash. No toca el dataset de origen ni el generador canónico:
// ningún hash publicado cambia.
//
// El sistema de Camilo se alimentó de las órdenes de trabajo, y por eso su pieza es la proyección de sus movimientos
// (la de la Fase 23). Eso solo ya produce cuatro discrepancias naturales, las mismas clases que la Fase 23 midió en
// SIGMA. Encima se siembran cuatro clases que salen de una costura mal hecha (Fase 24), --per-class de cada una.
import { createHash } from "node:crypto";
import { mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { basename, join, resolve } from "node:path";
import { parseArgs } from "node:util";
import { createRng } from "./rng.ts";
import { NdjsonWriter, type FileSummary } from "./ndjson.ts";
import { HANGARS } from "./domain.ts";

const { values: args } = parseArgs({
  options: {
    from: { type: "string", default: resolve(import.meta.dirname, "../../data/workOrder-10k") },
    seed: { type: "string", default: "condor-mro" },
    "per-class": { type: "string", default: "100" },
  },
});
const from = resolve(args.from!);
const perClass = Number(args["per-class"]);

// el origen tiene que ser el del curso: mismo criterio que lab/harness/dataset.ts
const sourceManifest = JSON.parse(readFileSync(join(from, "manifest.json"), "utf8"));
for (const [name, f] of Object.entries<any>(sourceManifest.files)) {
  const sha = createHash("sha256").update(readFileSync(join(from, name), "utf8")).digest("hex");
  if (sha !== f.sha256) throw new Error(`${name}: el hash no coincide con el manifiesto del origen`);
}
const ndjson = (name: string): any[] => readFileSync(join(from, name), "utf8").split("\n").filter(Boolean).map((l) => JSON.parse(l));
const sigmaParts = ndjson("part.ndjson");
const orders = ndjson("workOrder.ndjson");
const answersIn = JSON.parse(readFileSync(join(from, "answers.json"), "utf8"));

interface Move { workOrderId: string; at: string; kind: "removed" | "installed"; aircraft: string; position: string; disposition?: string; hangarId: string; supplierId?: string | null }
const DISPOSITION: Record<string, string> = { store: "inStore", repairShop: "atSupplier", scrap: "scrapped" };
/** El estado de una pieza después de un movimiento, como lo escribe la integración de Camilo. */
const apply = (c: any, m: Move) => m.kind === "installed"
  ? { ...c, status: "installed", aircraft: m.aircraft, position: m.position, hangarId: null, supplierId: null }
  : { ...c, status: DISPOSITION[m.disposition!], aircraft: null, position: null,
      hangarId: m.disposition === "repairShop" ? null : m.hangarId, supplierId: m.supplierId ?? null };

// la historia de cada pieza, en el orden en que se abrieron las órdenes (el archivo ya viene así)
const history = new Map<string, Move[]>();
for (const o of orders) {
  for (const r of o.removed) (history.get(r.serialNumber) ?? history.set(r.serialNumber, []).get(r.serialNumber)!)
    .push({ workOrderId: o.workOrderId, at: o.openedAt, kind: "removed", aircraft: o.aircraft, position: r.position, disposition: r.disposition, hangarId: o.hangarId, supplierId: r.supplierId });
  for (const i of o.installed) (history.get(i.serialNumber) ?? history.set(i.serialNumber, []).get(i.serialNumber)!)
    .push({ workOrderId: o.workOrderId, at: o.openedAt, kind: "installed", aircraft: o.aircraft, position: i.position, hangarId: o.hangarId });
}

// el punto de partida de Camilo: la carga inicial, con lo que SIGMA sabía de cada pieza antes de cualquier orden. Para
// las piezas que nunca se movieron es su estado de hoy, salvo las que se fueron con su aeronave: eso no lo trae ninguna
// orden, así que Camilo las sigue viendo instaladas
const initial = (p: any) => (p.status === "leftWithAircraft" ? { ...p, status: "installed" } : p);
const project = (p: any, moves: Move[]) => moves.reduce(apply, { ...initial(p), history: moves.map((m) => ({ workOrderId: m.workOrderId, kind: m.kind, at: m.at })) });

const camilo = new Map<string, any>();
for (const p of sigmaParts) camilo.set(p.serialNumber, project(p, history.get(p.serialNumber) ?? []));

// ─── Las naturales: lo que SIGMA cambió sin una orden, y que Camilo no pudo enterarse ─────────────
const sigma = new Map(sigmaParts.map((p) => [p.serialNumber, p]));
const exchangedOut = new Set(answersIn.exchanges.map((e: any) => e.outSerial));
const substitutes = new Set(answersIn.exchanges.map((e: any) => e.inSerial));
const natural: Record<string, string[]> = { leftWithAircraft: [], exchangedSerial: [], substituteSerial: [], returnedFromShop: [], marchActuator: [], other: [] };
for (const [serial, c] of camilo) {
  const s = sigma.get(serial)!;
  if (["status", "aircraft", "position", "hangarId", "supplierId"].every((k) => c[k] === s[k])) continue;
  if (s.status === "leftWithAircraft") natural.leftWithAircraft.push(serial);
  else if (serial === answersIn.marchActuator.serialNumber) natural.marchActuator.push(serial);
  else if (exchangedOut.has(serial)) natural.exchangedSerial.push(serial);
  else if (substitutes.has(serial)) natural.substituteSerial.push(serial);
  else if (s.status === "inStore" && c.status === "atSupplier") natural.returnedFromShop.push(serial);
  else natural.other.push(serial);   // ninguna, si el generador no cambió: está para que nada se clasifique de más
}

// ─── Las sembradas: cada una, la huella de una costura ─────────────────────────────────────────
const rng = createRng(args.seed!).fork("camilo");
const touched = new Set(Object.values(natural).flat());
/** perClass piezas al azar entre las que cumplen, sin repetir entre clases. */
const sample = (eligible: (serial: string) => boolean) => {
  const pool = [...camilo.keys()].filter((s) => !touched.has(s) && eligible(s));
  const chosen: string[] = [];
  while (chosen.length < Math.min(perClass, pool.length)) {
    const s = pool.splice(rng.int(0, pool.length - 1), 1)[0];
    chosen.push(s);
    touched.add(s);
  }
  return chosen.sort();
};
const moved = (n: number) => (s: string) => (history.get(s)?.length ?? 0) >= n;
const seeded = {
  // la doble escritura que falló: el último movimiento nunca llegó. Con dos movimientos o más, para que lo que queda
  // sea el estado después del penúltimo y no la carga inicial, que con uno solo podría coincidir con SIGMA
  lostWrite: sample(moved(2)).map((serial) => {
    const moves = history.get(serial)!;
    camilo.set(serial, project(sigma.get(serial), moves.slice(0, -1)));
    return { serialNumber: serial, missingWorkOrderId: moves.at(-1)!.workOrderId };
  }),
  // dos escrituras concurrentes aplicadas al revés: gana el penúltimo movimiento
  outOfOrder: sample(moved(2)).map((serial) => {
    const moves = history.get(serial)!;
    camilo.set(serial, project(sigma.get(serial), [...moves.slice(0, -2), moves.at(-1)!, moves.at(-2)!]));
    return { serialNumber: serial, appliedLast: moves.at(-2)!.workOrderId };
  }),
  // un contador que se actualiza solo en un lado: horas sumadas en SIGMA y no en Camilo
  hoursDrift: sample(() => true).map((serial) => {
    const c = camilo.get(serial), delta = rng.int(50, 800);
    c.hoursSinceNew = Math.max(0, c.hoursSinceNew - delta);
    return { serialNumber: serial, sigmaHours: sigma.get(serial)!.hoursSinceNew, camiloHours: c.hoursSinceNew };
  }),
  // una corrección hecha a mano en el derivado: el almacén cambiado solo en Camilo
  manualEdit: sample((s) => camilo.get(s).status === "inStore").map((serial) => {
    const c = camilo.get(serial), other = HANGARS.map((h) => h.hangarId).filter((h) => h !== c.hangarId);
    c.hangarId = other[rng.int(0, other.length - 1)];
    return { serialNumber: serial, sigmaHangarId: sigma.get(serial)!.hangarId, camiloHangarId: c.hangarId };
  }),
};

// ─── Escritura, manifiesto y respuestas ────────────────────────────────────────────────────────
const volume = basename(from).split("-").at(-1);
const outDir = join(resolve(from, ".."), `camilo-${volume}`);
rmSync(outDir, { recursive: true, force: true });
mkdirSync(outDir, { recursive: true });
const summaries: Record<string, FileSummary> = {};
const w = new NdjsonWriter(outDir, "component.ndjson");
for (const serial of [...camilo.keys()].sort()) {
  const { serialNumber, partNumber, category, status, aircraft, position, hangarId, supplierId, hoursSinceNew, cyclesSinceNew, history: h } = camilo.get(serial);
  w.write({ _id: serialNumber, partNumber, category, status, aircraft, position, hangarId, supplierId, hoursSinceNew, cyclesSinceNew, history: h });
}
summaries["component.ndjson"] = w.close();
const answers = {
  source: { dir: basename(from), datasetSha256: sourceManifest.datasetSha256 },
  counts: { natural: Object.fromEntries(Object.entries(natural).map(([k, v]) => [k, v.length])), seeded: Object.fromEntries(Object.entries(seeded).map(([k, v]) => [k, v.length])) },
  natural, seeded,
};
const text = JSON.stringify(answers, null, 2) + "\n";
writeFileSync(join(outDir, "answers.json"), text);
summaries["answers.json"] = { records: 1, bytes: Buffer.byteLength(text), sha256: createHash("sha256").update(text).digest("hex") };
const names = Object.keys(summaries).sort();
const datasetSha256 = createHash("sha256").update(names.map((n) => `${n}:${summaries[n].sha256}`).join("\n")).digest("hex");
writeFileSync(join(outDir, "manifest.json"), JSON.stringify({ generator: "diverge.ts", seed: args.seed, perClass, source: answers.source,
  files: Object.fromEntries(names.map((n) => [n, summaries[n]])), datasetSha256 }, null, 2) + "\n");
console.log(outDir);
console.log(`  naturales ${JSON.stringify(answers.counts.natural)}`);
console.log(`  sembradas ${JSON.stringify(answers.counts.seeded)}`);
console.log(`datasetSha256 ${datasetSha256}`);
