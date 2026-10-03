// Generador del dataset canónico de Cóndor MRO.
//
//   node src/generate.ts --focus part --volume 1m [--seed condor-mro] [--out ../data]
//
// Escribe un NDJSON por entidad, manifest.json con el hash de cada archivo y answers.json con
// las respuestas de los casos plantados. Mismo comando, mismos bytes, en cualquier máquina.
import { mkdirSync, rmSync, writeFileSync } from "node:fs";
import { createHash } from "node:crypto";
import { join, resolve } from "node:path";
import { parseArgs } from "node:util";

import { createRng, type Rng } from "./rng.ts";
import { computeCounts, parseVolume, type Focus, WINDOW_START, WINDOW_END, DAY_MS } from "./scale.ts";
import {
  HANGARS, OPERATORS, MODELS, positionsFor, CATALOG_WORDS, FIRST_NAMES, LAST_NAMES,
  REPAIR_CAPABILITIES, type Category, type PositionSpec,
} from "./domain.ts";
import { ARCHETYPES, writePirepText } from "./pireps.ts";
import { NdjsonWriter, type FileSummary } from "./ndjson.ts";
import { MinHeap } from "./heap.ts";

const GENERATOR_VERSION = "1.0.0";
const FOCI: Focus[] = ["part", "partCatalog", "workOrder", "reading", "pirep"];

const { values: args } = parseArgs({
  options: {
    focus: { type: "string", default: "workOrder" },
    volume: { type: "string", default: "10k" },
    seed: { type: "string", default: "condor-mro" },
    out: { type: "string", default: resolve(import.meta.dirname, "../../data") },
  },
});
const focus = args.focus as Focus;
if (!FOCI.includes(focus)) throw new Error(`--focus debe ser uno de: ${FOCI.join(", ")}`);
const volume = parseVolume(args.volume!);
const counts = computeCounts(focus, volume);
const root = createRng(args.seed!);
const outDir = join(args.out!, `${focus}-${args.volume!.toLowerCase()}`);
rmSync(outDir, { recursive: true, force: true });
mkdirSync(outDir, { recursive: true });

const iso = (ms: number) => new Date(Math.floor(ms / 1000) * 1000).toISOString().replace(".000Z", "Z");
const day = (ms: number) => new Date(ms).toISOString().slice(0, 10);
const pad = (n: number, width: number) => String(n).padStart(width, "0");
const round2 = (x: number) => Math.round(x * 100) / 100;
const WINDOW_DAYS = Math.floor((WINDOW_END - WINDOW_START) / DAY_MS);
const summaries: Record<string, FileSummary> = {};

/** Instantes ordenados y repartidos en la ventana, sin depender del orden de generación. */
function sortedTimes(rng: Rng, n: number): number[] {
  const span = WINDOW_END - WINDOW_START;
  // al segundo: un registro de mantenimiento no tiene milisegundos
  const times = Array.from({ length: n }, () => WINDOW_START + Math.floor(rng.next() * span / 1000) * 1000);
  return times.sort((a, b) => a - b);
}

// ─── Hangares, técnicos y proveedores ────────────────────────────────────────────────────────

{
  const w = new NdjsonWriter(outDir, "hangar.ndjson");
  for (const h of HANGARS) w.write(h);
  summaries["hangar.ndjson"] = w.close();
}

interface Technician { technicianId: string; name: string; hangarId: string; licenseType: string; canSign: boolean; itinerant: boolean }
const technicians: Technician[] = [];
{
  const rng = root.fork("technician");
  // las personas de la historia, con su papel (00-historia-de-condor.md §2)
  const named: Omit<Technician, "technicianId">[] = [
    { name: "Hernán Peñaloza", hangarId: "VVC", licenseType: "inspector", canSign: true, itinerant: false },
    { name: "Édinson Riaño", hangarId: "BOG", licenseType: "inspector", canSign: true, itinerant: false },
    { name: "Camilo Duarte", hangarId: "BOG", licenseType: "B2", canSign: false, itinerant: false },
    { name: "Freddy Manrique", hangarId: "VVC", licenseType: "B1", canSign: false, itinerant: true },
  ];
  for (let i = 0; i < counts.technician; i++) {
    const base = named[i] ?? {
      name: `${rng.pick(FIRST_NAMES)} ${rng.pick(LAST_NAMES)}`,
      hangarId: rng.weighted(HANGARS.map((h) => [h.hangarId, h.pits + 1] as const)),
      licenseType: rng.weighted([["B1", 5], ["B2", 2], ["inspector", 2]] as const),
      canSign: false,
      itinerant: rng.chance(0.05),
    };
    technicians.push({ technicianId: `T-${pad(i + 1, 3)}`, ...base, canSign: base.licenseType === "inspector" });
  }
  // cada base necesita al menos un inspector que firme
  for (const h of HANGARS) {
    if (!technicians.some((t) => t.hangarId === h.hangarId && t.canSign)) {
      const t = technicians.find((t) => t.hangarId === h.hangarId && !named.some((n) => n.name === t.name));
      if (t) Object.assign(t, { licenseType: "inspector", canSign: true });
    }
  }
  const w = new NdjsonWriter(outDir, "technician.ndjson");
  for (const t of technicians) w.write(t);
  summaries["technician.ndjson"] = w.close();
}
const techByHangar = new Map<string, Technician[]>(HANGARS.map((h) => [h.hangarId, technicians.filter((t) => t.hangarId === h.hangarId)]));

interface Supplier { supplierId: string; name: string; kind: "repairShop" | "partsSupplier"; capability: string | null; country: string; agreementValidUntil: string | null }
const suppliers: Supplier[] = [];
{
  const rng = root.fork("supplier");
  const countries = [["CO", 8], ["PE", 4], ["EC", 5], ["US", 2]] as const;
  for (let i = 0; i < 19; i++) {
    const capability = REPAIR_CAPABILITIES[i % REPAIR_CAPABILITIES.length];
    // cuatro convenios vencidos sin que nadie los renovara
    const expired = i % 5 === 3;
    const until = expired ? WINDOW_END - rng.int(30, 700) * DAY_MS : WINDOW_END + rng.int(60, 900) * DAY_MS;
    suppliers.push({
      supplierId: `S-${pad(i + 1, 3)}`,
      name: `Taller aliado ${rng.pick(LAST_NAMES)} ${capability}`,
      kind: "repairShop",
      capability,
      country: i === 0 ? "CO" : rng.weighted(countries),
      agreementValidUntil: day(until),
    });
  }
  for (let i = 0; i < 41; i++) {
    suppliers.push({
      supplierId: `S-${pad(i + 20, 3)}`,
      name: `${rng.pick(["Aeropartes", "Suministros", "Repuestos", "Distribuidora"])} ${rng.pick(LAST_NAMES)}`,
      kind: "partsSupplier",
      capability: null,
      country: rng.weighted([["CO", 5], ["US", 4], ["PE", 1], ["EC", 1], ["BR", 1]] as const),
      agreementValidUntil: null,
    });
  }
  const w = new NdjsonWriter(outDir, "supplier.ndjson");
  for (const s of suppliers) w.write(s);
  summaries["supplier.ndjson"] = w.close();
}
const repairShops = suppliers.filter((s) => s.kind === "repairShop");
const partsSuppliers = suppliers.filter((s) => s.kind === "partsSupplier");
const shopFor = (rng: Rng, category: Category): Supplier => {
  const capability = category === "engine" || category === "starterGenerator" ? "engines"
    : category === "propeller" || category === "rotor" ? "propellers"
    : category === "avionics" ? "avionics"
    : category === "instrument" ? "instruments"
    : "structures";
  return rng.pick(repairShops.filter((s) => s.capability === capability));
};

// ─── Catálogo ────────────────────────────────────────────────────────────────────────────────

interface CatalogEntry {
  partNumber: string; description: string; category: Category; ataChapter: number; serialized: boolean;
  compatibleModels: string[]; alternates: string[]; supplierIds: string[]; supplierPartNumbers: string[]; unitCostUsd: number;
}
const catalog: CatalogEntry[] = [];
/** Números de parte serializados por (modelo, categoría): los que ocupan posiciones. */
const serializedPn = new Map<string, CatalogEntry[]>();
const catalogByPn = new Map<string, CatalogEntry>();
{
  const rng = root.fork("partCatalog");
  const usedPn = new Set<string>();
  const newPn = (ata: number): string => {
    for (;;) {
      const pn = `${ata}-${pad(rng.int(100000, 999999), 6)}-${pad(rng.int(1, 29), 2)}`;
      if (!usedPn.has(pn)) { usedPn.add(pn); return pn; }
    }
  };
  // el mismo número escrito de cuatro formas, como lo escriben los proveedores
  const spellings = (pn: string): string[] => {
    const [a, b, c] = pn.split("-");
    return [`${a}${b}-${c}`, `${a} ${b} ${c}`, `${a}${b}${c}`, `${a}-${b}/${c}`];
  };
  const cost: Record<Category, [number, number]> = {
    engine: [180_000, 650_000], propeller: [25_000, 90_000], rotor: [40_000, 160_000], landingGear: [18_000, 70_000],
    actuator: [3_000, 14_000], tire: [300, 1_800], pump: [1_500, 9_000], starterGenerator: [6_000, 22_000],
    instrument: [1_200, 12_000], avionics: [2_500, 38_000], magneto: [900, 3_500], consumable: [2, 400],
  };
  const make = (category: Category, models: string[], serialized: boolean): CatalogEntry => {
    const words = CATALOG_WORDS[category];
    const pn = newPn(words.ata);
    const [lo, hi] = cost[category];
    const entry: CatalogEntry = {
      partNumber: pn,
      description: `${rng.pick(words.nouns)} ${rng.pick(words.qualifiers)}`,
      category, ataChapter: words.ata, serialized,
      compatibleModels: models, alternates: [],
      supplierIds: Array.from(new Set(Array.from({ length: rng.int(1, 3) }, () => rng.pick(partsSuppliers).supplierId))).sort(),
      supplierPartNumbers: spellings(pn).filter(() => rng.chance(0.6)),
      unitCostUsd: round2(lo + rng.next() * (hi - lo)),
    };
    catalog.push(entry);
    catalogByPn.set(pn, entry);
    return entry;
  };
  // dos números alternos por cada (modelo, categoría con posición serializada)
  for (const m of MODELS) {
    const categories = new Set(positionsFor(m.kind, m.engines).map((p) => p.category));
    for (const category of categories) {
      const pair = [make(category, [m.model], true), make(category, [m.model], true)];
      pair[0].alternates = [pair[1].partNumber];
      pair[1].alternates = [pair[0].partNumber];
      serializedPn.set(`${m.model}|${category}`, pair);
    }
  }
  // el resto del catálogo: mayoría de consumibles, con alternos ocasionales
  const categories = Object.keys(CATALOG_WORDS) as Category[];
  while (catalog.length < counts.partCatalog) {
    const category = rng.chance(0.7) ? "consumable" : rng.pick(categories);
    const models = MODELS.filter(() => rng.chance(0.35)).map((m) => m.model);
    const entry = make(category, models.length ? models : [rng.pick(MODELS).model], category !== "consumable");
    if (catalog.length > 10 && rng.chance(0.1)) {
      const other = catalog[rng.int(0, catalog.length - 2)];
      entry.alternates.push(other.partNumber);
    }
  }
  const w = new NdjsonWriter(outDir, "partCatalog.ndjson");
  for (const c of catalog) w.write(c);
  summaries["partCatalog.ndjson"] = w.close();
}

// ─── Aeronaves ───────────────────────────────────────────────────────────────────────────────

interface Aircraft {
  registration: string; model: string; kind: string; engines: number; operatorId: string; country: string;
  yearOfManufacture: number; baseHangarId: string; hasFlightRecorder: boolean; continuousWingContract: boolean;
  inFleetFrom: string; leftFleetOn: string | null; options: Record<string, unknown>;
}
const aircraft: Aircraft[] = [];
const activeFrom: number[] = [];
const activeUntil: number[] = [];
const positionsOf: PositionSpec[][] = [];

// casos plantados: se eligen antes de simular porque la simulación tiene que respetarlos
const PLANT = {
  directiveLot: "LOT-2022-117",
  actuatorRemovedOn: Date.UTC(2024, 4, 20, 14, 30),
  actuatorAircraftLeftOn: Date.UTC(2024, 5, 30),
  actuatorSentToShopOn: Date.UTC(2025, 3, 8),
  egtEngineRemovedOn: Date.UTC(2025, 10, 14, 9, 0),
  egtTrendDays: 60,
};
let actuatorAircraftIdx = -1;
let egtAircraftIdx = -1;
{
  const rng = root.fork("aircraft");
  const prefix: Record<string, string> = { CO: "HK", PE: "OB", EC: "HC" };
  const used = new Set<string>();
  const kindOptions = (kind: string): Record<string, unknown> => {
    switch (kind) {
      case "helicopter":
        return { rotorBlades: 4, cargoHook: rng.chance(0.5), floats: rng.chance(0.2), searchlight: rng.chance(0.4), rotorHoursSinceOverhaul: rng.int(0, 2500) };
      case "piston-twin":
        return { magnetoType: rng.pick(["Slick", "Bendix"]), deIcingBoots: rng.chance(0.3), oxygenSystem: rng.chance(0.5) };
      case "turboprop-single":
        return { cargoPod: rng.chance(0.7), floats: rng.chance(0.1), weatherRadar: rng.chance(0.5), seats: rng.pick([9, 12, 14]) };
      default:
        return { weatherRadar: rng.chance(0.8), tcas: rng.chance(0.6), cargoDoor: rng.chance(0.4), seats: rng.pick([19, 30, 48]), apu: rng.chance(0.3) };
    }
  };
  for (let i = 0; i < counts.aircraft; i++) {
    const op = rng.weighted(OPERATORS.map((o) => [o, o.continuousWing ? 3 : 2] as const));
    const m = rng.weighted(MODELS.map((mm) => [mm, mm.weight] as const));
    let registration: string;
    // el rango crece con la flota: con un rango fijo, a gran escala no quedarían matrículas libres
    const span = Math.max(1500, counts.aircraft * 4);
    do {
      registration = op.country === "CO" ? `HK-${rng.int(4000, 4000 + span - 1)}` : `${prefix[op.country]}-${rng.int(1000, 1000 + span - 1)}`;
    } while (used.has(registration));
    used.add(registration);
    // la primera aeronave está toda la ventana: siempre hay al menos una activa
    const joins = i > 0 && rng.chance(0.1) ? WINDOW_START + rng.int(30, WINDOW_DAYS - 200) * DAY_MS : WINDOW_START;
    const leaves = i > 0 && rng.chance(0.04) ? joins + rng.int(200, 1500) * DAY_MS : null;
    const bases = HANGARS.filter((h) => h.country === op.country);
    aircraft.push({
      registration, model: m.model, kind: m.kind, engines: m.engines, operatorId: op.operatorId, country: op.country,
      yearOfManufacture: rng.int(1984, 2019), baseHangarId: rng.pick(bases).hangarId, hasFlightRecorder: false,
      continuousWingContract: op.continuousWing, inFleetFrom: day(joins),
      leftFleetOn: leaves !== null && leaves < WINDOW_END ? day(leaves) : null,
      options: kindOptions(m.kind),
    });
    activeFrom.push(joins);
    activeUntil.push(leaves !== null && leaves < WINDOW_END ? leaves : Infinity);
    positionsOf.push(positionsFor(m.kind, m.engines));
  }
  // grabadores de vuelo: primero los bimotores turbohélice, que es la flota más nueva
  const byPreference = aircraft.map((a, i) => i).sort((x, y) => Number(aircraft[y].kind === "turboprop-twin") - Number(aircraft[x].kind === "turboprop-twin") || x - y);
  for (const i of byPreference.slice(0, counts.aircraftWithRecorder)) aircraft[i].hasFlightRecorder = true;
  // el actuador de marzo: una aeronave con tren retráctil que salió de la flota a mitad de 2024
  actuatorAircraftIdx = aircraft.findIndex((a, i) => a.kind === "turboprop-twin" && activeFrom[i] === WINDOW_START && !a.hasFlightRecorder);
  if (actuatorAircraftIdx < 0) actuatorAircraftIdx = aircraft.findIndex((a) => a.kind === "turboprop-twin");
  aircraft[actuatorAircraftIdx].leftFleetOn = day(PLANT.actuatorAircraftLeftOn);
  activeUntil[actuatorAircraftIdx] = PLANT.actuatorAircraftLeftOn;
  // la tendencia de EGT: una aeronave con grabador que sigue en la flota
  egtAircraftIdx = aircraft.findIndex((a, i) => a.hasFlightRecorder && activeUntil[i] === Infinity && activeFrom[i] === WINDOW_START);
  const w = new NdjsonWriter(outDir, "aircraft.ndjson");
  for (const a of aircraft) w.write(a);
  summaries["aircraft.ndjson"] = w.close();
}

// ─── Piezas: las instaladas al comienzo de la ventana y los repuestos ───────────────────────

interface Part {
  serialNumber: string; partNumber: string; category: Category; lotNumber: string; manufacturedOn: string;
  hoursSinceNew: number; cyclesSinceNew: number; details: Record<string, unknown>;
  status: string; aircraft: string | null; position: string | null; hangarId: string | null;
  supplierId: string | null; sentToSupplierOn: string | null;
}
const parts: Part[] = [];
const installedAt = new Map<number, number>(); // índice de pieza → instante de instalación
const slot = new Map<string, number>(); // "aeronave|posición" → índice de pieza instalada
const storePool = new Map<string, number[]>(); // número de parte → repuestos disponibles ya
const lotSerials: string[] = [];
let actuatorPartIdx = -1;
{
  const rng = root.fork("part");
  const details = (category: Category): Record<string, unknown> => {
    switch (category) {
      case "engine": return { tboHours: rng.pick([3600, 4000, 6000]), hoursSinceOverhaul: rng.int(0, 3500), cyclesSinceOverhaul: rng.int(0, 5000) };
      case "instrument": return { calibrationIntervalDays: rng.pick([365, 730]), lastCalibrationOn: day(WINDOW_START - rng.int(0, 700) * DAY_MS) };
      case "tire": return { retreadCount: rng.int(0, 4), maxRetreads: 5, plyRating: rng.pick([6, 8, 10]) };
      case "actuator": return { lifeLimitCycles: rng.pick([20000, 30000]), overhaulIntervalCycles: rng.pick([6000, 8000]) };
      case "avionics": return { softwareVersion: `${rng.int(1, 9)}.${rng.int(0, 20)}` };
      case "propeller": return { hoursSinceOverhaul: rng.int(0, 3000), blades: rng.pick([3, 4]) };
      case "rotor": return { retirementHours: rng.pick([5000, 7500]), hoursSinceOverhaul: rng.int(0, 2000) };
      default: return {};
    }
  };
  const create = (pn: string, category: Category): number => {
    const idx = parts.length;
    const made = WINDOW_START - rng.int(200, 9000) * DAY_MS;
    parts.push({
      serialNumber: `SN-${pad(idx + 1, 7)}`, partNumber: pn, category,
      lotNumber: `LOT-${new Date(made).getUTCFullYear()}-${pad(rng.int(1, 400), 3)}`,
      manufacturedOn: day(made), hoursSinceNew: rng.int(0, 12000), cyclesSinceNew: rng.int(0, 15000),
      details: details(category), status: "inStore", aircraft: null, position: null,
      hangarId: rng.pick(HANGARS).hangarId, supplierId: null, sentToSupplierOn: null,
    });
    return idx;
  };
  const pnFor = (a: Aircraft, category: Category) => serializedPn.get(`${a.model}|${category}`)!;
  // piezas instaladas: una por posición en cada aeronave
  aircraft.forEach((a, ai) => {
    for (const p of positionsOf[ai]) {
      const pn = rng.pick(pnFor(a, p.category)).partNumber;
      const idx = create(pn, p.category);
      Object.assign(parts[idx], { status: "installed", aircraft: a.registration, position: p.position, hangarId: null });
      slot.set(`${a.registration}|${p.position}`, idx);
      installedAt.set(idx, Math.max(WINDOW_START, activeFrom[ai]));
    }
  });
  // el actuador de marzo es el actuador izquierdo de su aeronave
  actuatorPartIdx = slot.get(`${aircraft[actuatorAircraftIdx].registration}|gear-actuator-left`)!;
  // repuestos, repartidos entre los números de parte serializados según cuántas posiciones usan
  const usage: [string, Category, number][] = [];
  for (const [key, entries] of serializedPn) {
    const [model, category] = key.split("|") as [string, Category];
    const positions = aircraft.filter((a) => a.model === model).length * positionsOf[aircraft.findIndex((a) => a.model === model)]?.filter((p) => p.category === category).length || 0;
    for (const e of entries) usage.push([e.partNumber, category, Math.max(1, positions)]);
  }
  const usageWeights = usage.map(([pn, c, w]) => [[pn, c] as const, w] as const);
  while (parts.length < counts.part) {
    const [pn, category] = rng.weighted(usageWeights);
    const idx = create(pn, category);
    const pool = storePool.get(pn) ?? [];
    pool.push(idx);
    storePool.set(pn, pool);
  }
  // el lote de la directiva: actuadores de un mismo número de parte, fabricados en 2022
  // primero piezas instaladas en aeronaves distintas y después repuestos: un lote que solo
  // estuviera en almacén no daría a F14 ninguna pregunta que valga la pena
  const actuatorPn = parts[actuatorPartIdx].partNumber;
  const same = parts.map((p, i) => i).filter((i) => parts[i].partNumber === actuatorPn && i !== actuatorPartIdx);
  const seen = new Set<string>();
  const installedFirst = same.filter((i) => parts[i].aircraft !== null && !seen.has(parts[i].aircraft!) && seen.add(parts[i].aircraft!));
  const spares = same.filter((i) => parts[i].aircraft === null);
  const lotSize = Math.max(8, Math.round(same.length * 0.08));
  const installedShare = Math.min(installedFirst.length, Math.ceil(lotSize / 2));
  const candidates = [
    ...installedFirst.slice(0, installedShare),
    ...spares.filter((_, k) => k % Math.max(1, Math.floor(spares.length / (lotSize - installedShare))) === 0).slice(0, lotSize - installedShare),
  ];
  for (let k = 0; k < candidates.length; k++) {
    const i = candidates[k];
    parts[i].lotNumber = PLANT.directiveLot;
    parts[i].manufacturedOn = day(Date.UTC(2022, 1, 1) + rng.int(0, 60) * DAY_MS);
    lotSerials.push(parts[i].serialNumber);
  }
}

// ─── Reportes de piloto ──────────────────────────────────────────────────────────────────────

const pirepTimes = sortedTimes(root.fork("pirep-times"), counts.pirep);
const pirepAircraft: number[] = [];
{
  const rng = root.fork("pirep");
  const w = new NdjsonWriter(outDir, "pirep.ndjson");
  const labels = new NdjsonWriter(outDir, "pirep-labels.ndjson");
  pirepTimes.forEach((t, i) => {
    let ai = rng.int(0, aircraft.length - 1);
    while (!(activeFrom[ai] <= t && t < activeUntil[ai])) ai = (ai + 1) % aircraft.length;
    const archetype = rng.weighted(ARCHETYPES.map((a, k) => [a, k < 4 ? 3 : 2] as const));
    const pirepId = `PR-${pad(i + 1, 7)}`;
    w.write({ pirepId, aircraft: aircraft[ai].registration, reportedAt: iso(t), ataChapter: archetype.ata, text: writePirepText(rng, archetype) });
    labels.write({ pirepId, archetype: archetype.id });
    pirepAircraft.push(ai);
  });
  summaries["pirep.ndjson"] = w.close();
  summaries["pirep-labels.ndjson"] = labels.close();
}

// ─── Órdenes de trabajo: la simulación de cinco años ─────────────────────────────────────────

interface Forced { at: number; aircraftIdx: number; position: string; disposition: string; reason: string; plant: string }
const forced: Forced[] = [
  { at: PLANT.actuatorRemovedOn, aircraftIdx: actuatorAircraftIdx, position: "gear-actuator-left", disposition: "store", reason: "remoción por inspección de tren", plant: "marchActuator" },
];
if (egtAircraftIdx >= 0) forced.push({ at: PLANT.egtEngineRemovedOn, aircraftIdx: egtAircraftIdx, position: "engine-1", disposition: "repairShop", reason: "EGT fuera de tendencia", plant: "egtTrend" });
forced.sort((a, b) => a.at - b.at);
// posiciones protegidas: la simulación aleatoria no toca la pieza plantada antes de su cita
const lockedUntil = new Map(forced.map((f) => [`${aircraft[f.aircraftIdx].registration}|${f.position}`, f.at] as const));

const returns = new MinHeap<{ at: number; idx: number }>((a, b) => a.at - b.at || a.idx - b.idx);
const exchanges: { outSerial: string; inSerial: string; workOrderId: string; supplierId: string; returnedOn: string }[] = [];
const lotHistory = new Map<string, Set<string>>(lotSerials.map((s) => [s, new Set<string>()]));
const removedWithLot: { workOrderId: string; lotSerial: string; others: string[] }[] = [];
const plantedWorkOrders: Record<string, string> = {};
const serialIndex = new Map(parts.map((p, i) => [p.serialNumber, i] as const));
for (const s of lotSerials) {
  const p = parts[serialIndex.get(s)!];
  if (p.aircraft) lotHistory.get(s)!.add(p.aircraft);
}
{
  const rng = root.fork("workOrder");
  // las órdenes plantadas cuentan dentro del volumen: 1 M son 1 M exactas
  const times = sortedTimes(root.fork("workOrder-times"), counts.workOrder - forced.length);
  const w = new NdjsonWriter(outDir, "workOrder.ndjson");
  const pendingByAircraft = new Map<number, string[]>();
  let pirepCursor = 0;
  let seq = 0;
  const TYPES = [["routine", 55], ["inspection", 15], ["defect", 25], ["major", 5]] as const;
  const MOVE_P: Record<string, number> = { routine: 0.25, inspection: 0.3, defect: 0.6, major: 0.9 };
  const LABOR: Record<string, [number, number]> = { routine: [2, 16], inspection: [8, 40], defect: [3, 30], major: [80, 600] };
  const DURATION_H: Record<string, [number, number]> = { routine: [3, 30], inspection: [12, 96], defect: [4, 72], major: [240, 1600] };
  const TASKS = ["inspección visual", "lubricación", "reemplazo de componente", "prueba funcional", "calibración", "inspección boroscópica", "ajuste de tensión de cables", "revisión de registros", "prueba de fugas", "cambio de aceite"];

  const release = (now: number) => {
    while (returns.size > 0 && returns.peek()!.at <= now) {
      const { idx } = returns.pop()!;
      const p = parts[idx];
      Object.assign(p, { status: "inStore", supplierId: null, sentToSupplierOn: null, hangarId: rng.pick(HANGARS).hangarId });
      const pool = storePool.get(p.partNumber) ?? [];
      pool.push(idx);
      storePool.set(p.partNumber, pool);
    }
  };

  const addHours = (idx: number, until: number) => {
    const since = installedAt.get(idx);
    if (since === undefined) return;
    const days = Math.max(0, (until - since) / DAY_MS);
    parts[idx].hoursSinceNew += Math.round(days * 2.2);
    parts[idx].cyclesSinceNew += Math.round(days * 1.6);
    installedAt.delete(idx);
  };

  const emit = (t: number, ai: number, type: string, positions: { spec: PositionSpec; disposition?: string; reason?: string }[], plant?: string) => {
    seq++;
    const workOrderId = `WO-${pad(seq, 7)}`;
    const a = aircraft[ai];
    // los pireps que ya existían para esta aeronave quedan en cola; una orden de defecto atiende uno
    while (pirepCursor < pirepTimes.length && pirepTimes[pirepCursor] <= t) {
      const q = pendingByAircraft.get(pirepAircraft[pirepCursor]) ?? [];
      q.push(`PR-${pad(pirepCursor + 1, 7)}`);
      pendingByAircraft.set(pirepAircraft[pirepCursor], q);
      pirepCursor++;
    }
    const pirepId = type === "defect" ? pendingByAircraft.get(ai)?.shift() ?? null : null;
    const hangarId = rng.chance(0.8) ? a.baseHangarId : rng.pick(HANGARS.filter((h) => h.country === a.country)).hangarId;
    const crew = techByHangar.get(hangarId)!.length ? techByHangar.get(hangarId)! : technicians;
    const workers = Array.from(new Set(Array.from({ length: rng.int(1, 3) }, () => rng.pick(crew).technicianId))).sort();
    const inspectors = crew.filter((x) => x.canSign);
    const releasedBy = (inspectors.length ? rng.pick(inspectors) : rng.pick(technicians.filter((x) => x.canSign))).technicianId;
    const [lh, hh] = LABOR[type];
    const [ld, hd] = DURATION_H[type];
    const removed: object[] = [];
    const installed: object[] = [];
    let partsCostUsd = 0;
    for (const { spec, disposition: forcedDisposition, reason } of positions) {
      const key = `${a.registration}|${spec.position}`;
      const outIdx = slot.get(key);
      if (outIdx === undefined) continue;
      const out = parts[outIdx];
      // reemplazo: un repuesto disponible del mismo número de parte o de su alterno
      const options = serializedPn.get(`${a.model}|${spec.category}`)!.map((e) => e.partNumber);
      const pn = options.find((o) => (storePool.get(o)?.length ?? 0) > 0);
      if (!pn) continue; // sin repuesto, la pieza no se cambia en esta orden
      const pool = storePool.get(pn)!;
      const inIdx = pool.splice(rng.int(0, pool.length - 1), 1)[0];
      addHours(outIdx, t);
      const disposition = forcedDisposition ?? rng.weighted([["store", 40], ["repairShop", 50], ["scrap", 10]] as const);
      let supplierId: string | null = null;
      if (disposition === "store" && outIdx !== actuatorPartIdx) {
        Object.assign(out, { status: "inStore", aircraft: null, position: null, hangarId });
        storePool.get(out.partNumber)!.push(outIdx);
      } else if (disposition === "store") {
        // el actuador plantado queda en almacén y nunca vuelve a instalarse (ver answers.json)
        Object.assign(out, { status: "inStore", aircraft: null, position: null, hangarId: "BOG" });
      } else if (disposition === "repairShop") {
        const shop = shopFor(rng, out.category);
        supplierId = shop.supplierId;
        Object.assign(out, { status: "atSupplier", aircraft: null, position: null, hangarId: null, supplierId, sentToSupplierOn: day(t) });
        const back = t + rng.int(14, 240) * DAY_MS;
        if (rng.chance(0.2)) {
          // intercambio: el aliado devuelve una pieza equivalente con otro número de serie, y la
          // original sale del inventario de Cóndor. Si no queda repuesto, se repara la misma.
          const substitute = storePool.get(out.partNumber)?.pop();
          if (substitute !== undefined) {
            out.status = "exchanged";
            parts[substitute].status = "atSupplier";
            parts[substitute].supplierId = supplierId;
            exchanges.push({ outSerial: out.serialNumber, inSerial: parts[substitute].serialNumber, workOrderId, supplierId, returnedOn: day(back) });
            returns.push({ at: back, idx: substitute });
          } else returns.push({ at: back, idx: outIdx });
        } else returns.push({ at: back, idx: outIdx });
      } else {
        Object.assign(out, { status: "scrapped", aircraft: null, position: null, hangarId });
      }
      const inPart = parts[inIdx];
      Object.assign(inPart, { status: "installed", aircraft: a.registration, position: spec.position, hangarId: null, supplierId: null, sentToSupplierOn: null });
      slot.set(key, inIdx);
      installedAt.set(inIdx, t);
      partsCostUsd += catalogByPn.get(inPart.partNumber)!.unitCostUsd;
      removed.push({ serialNumber: out.serialNumber, partNumber: out.partNumber, position: spec.position, disposition, supplierId, reason: reason ?? rng.pick(["fin de vida útil", "falla reportada", "inspección", "recomendación del fabricante"]) });
      installed.push({ serialNumber: inPart.serialNumber, partNumber: inPart.partNumber, position: spec.position });
      if (lotHistory.has(inPart.serialNumber)) lotHistory.get(inPart.serialNumber)!.add(a.registration);
    }
    const removedSerials = removed.map((r) => (r as { serialNumber: string }).serialNumber);
    for (const s of removedSerials) {
      if (lotHistory.has(s)) removedWithLot.push({ workOrderId, lotSerial: s, others: removedSerials.filter((o) => o !== s) });
    }
    const laborHours = rng.int(lh, hh);
    w.write({
      workOrderId, aircraft: a.registration, hangarId, type, openedAt: iso(t), closedAt: iso(t + rng.int(ld, hd) * 3_600_000),
      pirepId, technicianIds: workers, releasedBy, laborHours, laborCostUsd: laborHours * 45, partsCostUsd: round2(partsCostUsd),
      tasks: Array.from({ length: rng.int(1, 4) }, () => rng.pick(TASKS)), removed, installed,
    });
    if (plant) plantedWorkOrders[plant] = workOrderId;
  };

  let f = 0;
  for (const t of times) {
    while (f < forced.length && forced[f].at <= t) {
      const x = forced[f++];
      release(x.at);
      const spec = positionsOf[x.aircraftIdx].find((p) => p.position === x.position)!;
      emit(x.at, x.aircraftIdx, x.plant === "egtTrend" ? "defect" : "inspection", [{ spec, disposition: x.disposition, reason: x.reason }], x.plant);
    }
    release(t);
    // siempre una aeronave activa en ese instante: ninguna orden se descarta
    let ai = rng.int(0, aircraft.length - 1);
    while (!(activeFrom[ai] <= t && t < activeUntil[ai])) ai = (ai + 1) % aircraft.length;
    const type = rng.weighted(TYPES);
    const moves: { spec: PositionSpec }[] = [];
    if (rng.chance(MOVE_P[type])) {
      const specs = positionsOf[ai].filter((p) => (lockedUntil.get(`${aircraft[ai].registration}|${p.position}`) ?? 0) <= t);
      const n = type === "major" ? rng.int(2, 5) : rng.int(1, 2);
      const chosen = new Set<PositionSpec>();
      for (let k = 0; k < n; k++) chosen.add(rng.weighted(specs.map((p) => [p, 1000 / p.mtbfDays] as const)));
      for (const spec of chosen) moves.push({ spec });
    }
    emit(t, ai, type, moves);
  }
  while (f < forced.length) {
    const x = forced[f++];
    const spec = positionsOf[x.aircraftIdx].find((p) => p.position === x.position)!;
    emit(x.at, x.aircraftIdx, "inspection", [{ spec, disposition: x.disposition, reason: x.reason }], x.plant);
  }
  summaries["workOrder.ndjson"] = w.close();
  // el cierre de la ventana: horas de lo instalado y piezas que se fueron con su aeronave
  const aircraftIdx = new Map(aircraft.map((a, i) => [a.registration, i] as const));
  for (const [idx] of installedAt) addHours(idx, Math.min(WINDOW_END, activeUntil[aircraftIdx.get(parts[idx].aircraft!)!]));
  aircraft.forEach((a, ai) => {
    if (activeUntil[ai] === Infinity) return;
    for (const p of positionsOf[ai]) {
      const idx = slot.get(`${a.registration}|${p.position}`);
      if (idx !== undefined && parts[idx].aircraft === a.registration) parts[idx].status = "leftWithAircraft";
    }
  });
  // el actuador de marzo: de almacén a un taller aliado de Bogotá, y nunca volvió
  const shop = repairShops.find((s) => s.capability === "structures" && s.country === "CO") ?? repairShops.find((s) => s.capability === "structures")!;
  Object.assign(parts[actuatorPartIdx], { status: "atSupplier", hangarId: null, supplierId: shop.supplierId, sentToSupplierOn: day(PLANT.actuatorSentToShopOn) });
}

{
  const w = new NdjsonWriter(outDir, "part.ndjson");
  for (const p of parts) w.write(p);
  summaries["part.ndjson"] = w.close();
}

// ─── Conjuntos: motor, tren y hélice como una sola cosa, con lo que tienen dentro hoy ─────────

{
  const w = new NdjsonWriter(outDir, "assembly.ndjson");
  aircraft.forEach((a, ai) => {
    const at = (position: string) => {
      const idx = slot.get(`${a.registration}|${position}`);
      return idx !== undefined && parts[idx].aircraft === a.registration ? parts[idx].serialNumber : null;
    };
    const has = (position: string) => positionsOf[ai].some((p) => p.position === position);
    for (let e = 1; e <= a.engines; e++) {
      w.write({
        assemblyId: `ASM-${a.registration}-ENG${e}`, kind: "powerplant", aircraft: a.registration, position: `engine-${e}`,
        partSerials: [at(`engine-${e}`), at(`starter-generator-${e}`), has(`propeller-${e}`) ? at(`propeller-${e}`) : null].filter(Boolean),
      });
    }
    if (has("main-gear-left")) {
      for (const [side, pos] of [["L", "left"], ["R", "right"]] as const) {
        w.write({
          assemblyId: `ASM-${a.registration}-MLG${side}`, kind: "landingGear", aircraft: a.registration, position: `main-gear-${pos}`,
          partSerials: [at(`main-gear-${pos}`), at(`gear-actuator-${pos}`), at(`tire-main-${pos}`)].filter(Boolean),
        });
      }
      w.write({
        assemblyId: `ASM-${a.registration}-NLG`, kind: "landingGear", aircraft: a.registration, position: "nose-gear",
        partSerials: [at("nose-gear"), at("gear-actuator-nose"), at("tire-nose")].filter(Boolean),
      });
    }
  });
  summaries["assembly.ndjson"] = w.close();
}

// ─── Lecturas de vuelo: una por minuto de vuelo, por aeronave con grabador ───────────────────

const egtTrend = { aircraft: egtAircraftIdx >= 0 ? aircraft[egtAircraftIdx].registration : null, from: day(PLANT.egtEngineRemovedOn - PLANT.egtTrendDays * DAY_MS), to: day(PLANT.egtEngineRemovedOn) };
{
  const rng = root.fork("reading");
  const w = new NdjsonWriter(outDir, "reading.ndjson");
  const recorders = aircraft.map((a, i) => i).filter((i) => aircraft[i].hasFlightRecorder);
  const perAircraft = Math.floor(counts.reading / recorders.length);
  let remainder = counts.reading - perAircraft * recorders.length;
  let flightSeq = 0;
  for (const ai of recorders) {
    const quota = perAircraft + (remainder-- > 0 ? 1 : 0);
    const start = Math.max(WINDOW_START, activeFrom[ai]);
    const end = Math.min(WINDOW_END, activeUntil[ai]);
    const minutesPerMs = quota / (end - start);
    let t = start;
    let written = 0;
    while (written < quota) {
      const length = rng.int(40, 120);
      const flightId = `FL-${pad(++flightSeq, 8)}`;
      const baseEgt = rng.int(640, 680);
      const trendStart = PLANT.egtEngineRemovedOn - PLANT.egtTrendDays * DAY_MS;
      const drift = ai === egtAircraftIdx && t >= trendStart && t < PLANT.egtEngineRemovedOn ? Math.round(((t - trendStart) / DAY_MS) * 0.6) : 0;
      for (let m = 0; m < length && written < quota; m++, written++) {
        const phase = m < 12 ? "climb" : m > length - 12 ? "descent" : "cruise";
        const alt = phase === "climb" ? m * 1400 : phase === "descent" ? (length - m) * 1300 : 16000 + rng.int(-200, 200);
        w.write({
          aircraft: aircraft[ai].registration, flightId, ts: iso(t + m * 60_000),
          altitudeFt: Math.max(0, alt), iasKt: phase === "cruise" ? rng.int(210, 245) : rng.int(120, 190),
          egtC: baseEgt + (phase === "climb" ? 40 : 0) + drift + rng.int(-8, 8), n1Pct: phase === "climb" ? rng.int(95, 100) : rng.int(82, 92),
          oilPressPsi: rng.int(95, 115), oilTempC: rng.int(70, 95), fuelFlowPph: phase === "climb" ? rng.int(560, 640) : rng.int(380, 450),
        });
      }
      // el siguiente vuelo, espaciado para repartir la cuota en toda la ventana
      t += Math.max(length * 60_000 + 30 * 60_000, Math.round(length / minutesPerMs));
    }
  }
  summaries["reading.ndjson"] = w.close();
}

// ─── Respuestas de los casos plantados y manifiesto ──────────────────────────────────────────

const actuator = parts[actuatorPartIdx];
const answers = {
  directiveLot: {
    lotNumber: PLANT.directiveLot,
    partNumber: parts[serialIndex.get(lotSerials[0])!]?.partNumber ?? null,
    serials: lotSerials,
    aircraftEverInstalled: Array.from(new Set([...lotHistory.values()].flatMap((s) => [...s]))).sort(),
    bySerial: Object.fromEntries([...lotHistory].map(([s, set]) => [s, [...set].sort()])),
    removedTogether: removedWithLot,
  },
  marchActuator: {
    serialNumber: actuator.serialNumber,
    partNumber: actuator.partNumber,
    lastAircraft: aircraft[actuatorAircraftIdx].registration,
    aircraftLeftFleetOn: day(PLANT.actuatorAircraftLeftOn),
    removedBy: plantedWorkOrders.marchActuator ?? null,
    removedOn: day(PLANT.actuatorRemovedOn),
    sentToSupplierOn: day(PLANT.actuatorSentToShopOn),
    supplierId: actuator.supplierId,
    truth: "retirado en 2024 a almacén de Bogotá, enviado a un taller aliado en abril de 2025 y nunca devuelto",
  },
  egtTrend: { ...egtTrend, workOrderId: plantedWorkOrders.egtTrend ?? null, driftCPerDay: 0.6 },
  exchanges,
  pirepLabels: "pirep-labels.ndjson",
};
writeFileSync(join(outDir, "answers.json"), JSON.stringify(answers, null, 2) + "\n");
summaries["answers.json"] = (() => {
  const text = JSON.stringify(answers, null, 2) + "\n";
  return { records: 1, bytes: Buffer.byteLength(text), sha256: createHash("sha256").update(text).digest("hex") };
})();

const names = Object.keys(summaries).sort();
const datasetSha256 = createHash("sha256").update(names.map((n) => `${n}:${summaries[n].sha256}`).join("\n")).digest("hex");
const manifest = {
  generatorVersion: GENERATOR_VERSION, seed: args.seed, focus, volume: args.volume, scale: Math.round(counts.scale * 10000) / 10000,
  window: { from: day(WINDOW_START), to: day(WINDOW_END) }, counts, files: Object.fromEntries(names.map((n) => [n, summaries[n]])), datasetSha256,
};
writeFileSync(join(outDir, "manifest.json"), JSON.stringify(manifest, null, 2) + "\n");
console.log(`${outDir}`);
for (const n of names) console.log(`  ${n.padEnd(22)} ${String(summaries[n].records).padStart(9)} registros`);
console.log(`datasetSha256 ${datasetSha256}`);
