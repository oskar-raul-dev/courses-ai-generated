// El viaje de Freddy Manrique (T-004) al Guaviare, del lunes 21 al jueves 24 de septiembre de 2026, y lo
// que hizo Jairo Vélez (T-009) en dos de las mismas aeronaves sin poder verlo. Las cuatro órdenes son las
// de workOrder-10k, reabiertas como estaban al salir; las ediciones salen de lo que esas órdenes dicen que
// pasó. Cada edición es un guardado de la app: una revisión nueva del documento que toca.
//
// El mismo viaje se guarda de tres formas (sección 6.4 de la fase): una orden por documento, un documento por cosa
// que se edita, y una orden por documento con sus campos como CRDT.
import { readNdjson } from "../lab/harness/dataset.ts";
import type { Db } from "../lab/harness/couch.ts";
import { gInc, gMerge, mvMerge, mvRegister, mvSet, mvValues, orAdd, orMerge, orRemove, orSet, orValues } from "./crdt.ts";

export const DATASET = "lab/data/workOrder-10k";
export const TRIP_AIRCRAFT = ["HK-4107", "HK-4235", "HK-4287", "HK-5258"];
/** Lo que el técnico necesita en la tableta: las órdenes, abiertas y cerradas, de sus cuatro aeronaves. */
export const tripSelector = { aircraft: { $in: TRIP_AIRCRAFT } };

/** Pendientes que ya estaban anotados en la orden al salir. */
const OPEN_ITEMS: Record<string, string[]> = {
  "WO-0009931": ["llanta principal derecha: desgaste fuera de límite"],
  "WO-0009951": ["bomba de combustible 1: fuga en el acople"],
};

export type Edit = { by: string; at: string; wo: string } & (
  | { kind: "task"; task: string }
  | { kind: "swap"; position: string; removed: string; installed: string }
  | { kind: "labor"; hours: number }
  | { kind: "closeItem"; item: string }
  | { kind: "note"; text: string });

const F = "T-004", J = "T-009";
const at = (day: number, hm: string) => `2026-09-${day}T${hm}:00-05:00`;
const TIRE = OPEN_ITEMS["WO-0009931"][0], PUMP = OPEN_ITEMS["WO-0009951"][0];

/** Freddy, sin señal de lunes a miércoles: HK-4107 y HK-5258 en la primera pista, HK-4235 en la segunda, HK-4287 en la tercera. */
export const FREDDY: Edit[] = [
  { by: F, at: at(21, "07:40"), wo: "WO-0009931", kind: "task", task: "inspección visual" },
  { by: F, at: at(21, "09:10"), wo: "WO-0009931", kind: "swap", position: "tire-main-right", removed: "SN-0002447", installed: "SN-0002822" },
  { by: F, at: at(21, "09:15"), wo: "WO-0009931", kind: "closeItem", item: TIRE },
  { by: F, at: at(21, "09:20"), wo: "WO-0009931", kind: "task", task: "reemplazo de componente" },
  { by: F, at: at(21, "11:30"), wo: "WO-0009931", kind: "labor", hours: 6 },
  { by: F, at: at(21, "14:10"), wo: "WO-0009951", kind: "task", task: "inspección visual" },
  { by: F, at: at(21, "15:30"), wo: "WO-0009951", kind: "swap", position: "fuel-pump-1", removed: "SN-0004232", installed: "SN-0004130" },
  { by: F, at: at(21, "15:35"), wo: "WO-0009951", kind: "closeItem", item: PUMP },
  { by: F, at: at(21, "16:50"), wo: "WO-0009951", kind: "swap", position: "attitude-indicator", removed: "SN-0004403", installed: "SN-0007093" },
  { by: F, at: at(21, "17:30"), wo: "WO-0009951", kind: "labor", hours: 5 },
  { by: F, at: at(22, "08:00"), wo: "WO-0009941", kind: "task", task: "ajuste de tensión de cables" },
  { by: F, at: at(22, "09:45"), wo: "WO-0009941", kind: "swap", position: "tire-main-left", removed: "SN-0002967", installed: "SN-0006645" },
  { by: F, at: at(22, "11:20"), wo: "WO-0009941", kind: "swap", position: "gear-actuator-left", removed: "SN-0007271", installed: "SN-0002586" },
  { by: F, at: at(22, "12:00"), wo: "WO-0009941", kind: "task", task: "inspección visual" },
  { by: F, at: at(22, "12:30"), wo: "WO-0009941", kind: "labor", hours: 11 },
  { by: F, at: at(23, "07:30"), wo: "WO-0009927", kind: "task", task: "prueba de fugas" },
  { by: F, at: at(23, "09:00"), wo: "WO-0009927", kind: "task", task: "inspección boroscópica" },
  { by: F, at: at(23, "10:40"), wo: "WO-0009927", kind: "task", task: "cambio de aceite" },
  { by: F, at: at(23, "11:10"), wo: "WO-0009927", kind: "labor", hours: 8 },
];

/** Jairo, el miércoles en la primera pista, también sin señal y con la copia que bajó el lunes. La prueba
 *  funcional de la bomba falla; él la cambia y anota que retiró la que su copia dice que estaba. */
export const JAIRO: Edit[] = [
  { by: J, at: at(23, "08:15"), wo: "WO-0009931", kind: "task", task: "inspección visual" },
  { by: J, at: at(23, "08:40"), wo: "WO-0009931", kind: "note", text: "llanta derecha con presión baja; revisar en 50 h" },
  { by: J, at: at(23, "09:00"), wo: "WO-0009931", kind: "labor", hours: 2 },
  { by: J, at: at(23, "10:30"), wo: "WO-0009951", kind: "task", task: "prueba funcional" },
  { by: J, at: at(23, "11:45"), wo: "WO-0009951", kind: "swap", position: "fuel-pump-1", removed: "SN-0004232", installed: "SN-0000829" },
  { by: J, at: at(23, "11:50"), wo: "WO-0009951", kind: "closeItem", item: PUMP },
  { by: J, at: at(23, "12:30"), wo: "WO-0009951", kind: "labor", hours: 4 },
];

export const TRIP_ORDERS = [...new Set([...FREDDY, ...JAIRO].map((e) => e.wo))].sort();

/** Las órdenes del dataset; las cuatro del viaje, reabiertas: sin cierre, sin piezas y sin horas. */
export async function loadOrders(): Promise<{ history: any[]; trip: any[] }> {
  const history: any[] = [], trip: any[] = [];
  for await (const w of readNdjson<any>(`${DATASET}/workOrder.ndjson`)) {
    if (!TRIP_ORDERS.includes(w.workOrderId)) { history.push({ _id: w.workOrderId, ...w }); continue; }
    const { removed, installed, laborHours, laborCostUsd, partsCostUsd, closedAt, releasedBy, tasks, ...header } = w;
    trip.push({ ...header, status: "open", taskList: tasks });
  }
  return { history, trip };
}

/** Lo que una orden dice al final, sea cual sea su forma: la vista contra la que se cuentan las ediciones. */
export interface View {
  tasks: Record<string, string[]>;      // tarea → técnicos que la firmaron
  parts: Record<string, string[]>;      // posición → seriales instalados que sobreviven (más de uno: en disputa)
  labor: Record<string, number>;        // técnico → horas
  openItems: string[];
  notes: string[];
}

/** Una forma de guardar las órdenes: cómo nace, cómo aplica una edición y cómo se lee. */
export interface Shape {
  name: string;
  seed(order: any): any[];
  apply(db: Db, e: Edit): Promise<void>;
  view(db: Db, wo: string): Promise<View>;
  /** La vista de cada hoja de un documento, para saber si una edición quedó en una revisión perdedora. */
  leafView(leaf: any): Partial<View>;
}

const signed = (e: Edit) => ({ by: e.by, at: e.at });

// ── 1. Una orden por documento: lo que haría cualquiera que viene de un documental ─────────────────
export const orderDoc: Shape = {
  name: "orden por documento",
  seed: (o) => [{
    _id: o.workOrderId, ...o,
    tasks: Object.fromEntries(o.taskList.map((t: string) => [t, []])),
    parts: {}, labor: {}, openItems: OPEN_ITEMS[o.workOrderId] ?? [], notes: [],
  }],
  async apply(db, e) {
    const d: any = await db.get(e.wo);
    if (e.kind === "task") d.tasks[e.task] = [...(d.tasks[e.task] ?? []), signed(e)];
    if (e.kind === "swap") d.parts[e.position] = { removed: e.removed, installed: e.installed, ...signed(e) };
    if (e.kind === "labor") d.labor[e.by] = (d.labor[e.by] ?? 0) + e.hours;
    if (e.kind === "closeItem") d.openItems = d.openItems.filter((i: string) => i !== e.item);
    if (e.kind === "note") d.notes = [...d.notes, e.text];
    d.updatedAt = e.at;
    d.updatedBy = e.by;
    await db.put(d);
  },
  async view(db, wo) { return orderDoc.leafView(await db.get(wo)) as View; },
  leafView: (d) => ({
    tasks: Object.fromEntries(Object.entries(d.tasks).map(([t, s]: [string, any]) => [t, s.map((x: any) => x.by)])),
    parts: Object.fromEntries(Object.entries(d.parts).map(([p, v]: [string, any]) =>
      [p, d.disputes?.[p] ? d.disputes[p].map((x: any) => x.installed) : [v.installed]])),
    labor: d.labor, openItems: d.openItems, notes: d.notes,
  }),
};

// ── 2. Un documento por cosa que se edita: tarea, posición, horas de un técnico, pendiente, nota ───
const key = (s: string) => s.normalize("NFD").replace(/\p{Diacritic}/gu, "").replace(/[^\w]+/g, "-").toLowerCase();
const tripPart = (wo: string, kind: string, id: string) => `${wo}/${kind}/${key(id)}`;
export const splitDocs: Shape = {
  name: "un documento por cosa",
  seed: (o) => {
    const base = { aircraft: o.aircraft, workOrderId: o.workOrderId };
    return [
      { _id: o.workOrderId, ...o },
      ...o.taskList.map((t: string) => ({ _id: tripPart(o.workOrderId, "task", t), ...base, task: t, signatures: [] })),
      ...(OPEN_ITEMS[o.workOrderId] ?? []).map((i) => ({ _id: tripPart(o.workOrderId, "item", i), ...base, item: i, open: true })),
    ];
  },
  async apply(db, e) {
    const { aircraft } = (await db.get(e.wo)) as any;
    const upsert = async (id: string, change: (d: any) => any) => {
      const d = await db.get(id).catch(() => ({ _id: id }));
      await db.put({ ...change(d), aircraft, workOrderId: e.wo, updatedAt: e.at, updatedBy: e.by });
    };
    if (e.kind === "task") await upsert(tripPart(e.wo, "task", e.task), (d) => ({ ...d, task: e.task, signatures: [...(d.signatures ?? []), signed(e)] }));
    if (e.kind === "swap") await upsert(tripPart(e.wo, "part", e.position), (d) => ({ ...d, position: e.position, removed: e.removed, installed: e.installed }));
    if (e.kind === "labor") await upsert(tripPart(e.wo, "labor", e.by), (d) => ({ ...d, technicianId: e.by, hours: (d.hours ?? 0) + e.hours }));
    if (e.kind === "closeItem") await upsert(tripPart(e.wo, "item", e.item), (d) => ({ ...d, open: false }));
    if (e.kind === "note") await upsert(tripPart(e.wo, "note", `${e.by}-${e.at}`), (d) => ({ ...d, text: e.text }));
  },
  async view(db, wo) {
    const rows = (await db.allDocs({ include_docs: true, startkey: `${wo}/`, endkey: `${wo}/￰` })).rows.map((r) => r.doc);
    return merge(rows.map((d) => splitDocs.leafView(d)));
  },
  leafView: (d) => {
    if (d.signatures) return { tasks: { [d.task]: d.signatures.map((s: any) => s.by) } };
    if (d.position) return { parts: { [d.position]: [d.installed] } };
    if (d.technicianId) return { labor: { [d.technicianId]: d.hours } };
    if (d.item) return { openItems: d.open ? [d.item] : [] };
    if (d.text) return { notes: [d.text] };
    return {};
  },
};

// ── 3. Una orden por documento, con cada campo como CRDT ─────────────────────────────────────────
export const crdtDoc: Shape = {
  name: "orden como CRDT",
  seed: (o) => [{
    _id: o.workOrderId, ...o,
    tasks: orSet(), parts: {}, labor: {}, notes: orSet(),
    openItems: (OPEN_ITEMS[o.workOrderId] ?? []).reduce((s, i, n) => orAdd(s, `seed-${n}`, i), orSet<string>()),
  }],
  async apply(db, e) {
    const d: any = await db.get(e.wo);
    const tag = `${e.by}@${e.at}`;
    if (e.kind === "task") d.tasks = orAdd(d.tasks, tag, { task: e.task, ...signed(e) });
    if (e.kind === "swap") d.parts[e.position] = mvSet(d.parts[e.position] ?? mvRegister(), tag, { removed: e.removed, installed: e.installed, ...signed(e) });
    if (e.kind === "labor") d.labor = gInc(d.labor, e.by, e.hours);
    if (e.kind === "closeItem") d.openItems = orRemove(d.openItems, (i: string) => i === e.item);
    if (e.kind === "note") d.notes = orAdd(d.notes, tag, e.text);
    d.updatedAt = e.at;
    d.updatedBy = e.by;
    await db.put(d);
  },
  async view(db, wo) { return crdtDoc.leafView(await db.get(wo)) as View; },
  leafView: (d) => {
    const tasks: Record<string, string[]> = {};
    for (const t of orValues<any>(d.tasks)) (tasks[t.task] ??= []).push(t.by);
    return {
      tasks, labor: d.labor, openItems: orValues(d.openItems), notes: orValues(d.notes),
      parts: Object.fromEntries(Object.entries(d.parts).map(([p, r]: [string, any]) => [p, mvValues<any>(r).map((v) => v.installed)])),
    };
  },
};

/** La fusión de un CRDT no sabe nada del dominio: campo por campo, según su tipo. */
export function mergeCrdt(a: any, b: any): any {
  const parts: any = { ...a.parts };
  for (const [p, r] of Object.entries<any>(b.parts)) parts[p] = parts[p] ? mvMerge(parts[p], r) : r;
  return {
    ...a, tasks: orMerge(a.tasks, b.tasks), notes: orMerge(a.notes, b.notes), openItems: orMerge(a.openItems, b.openItems),
    labor: gMerge(a.labor, b.labor), parts,
    ...(a.updatedAt > b.updatedAt ? { updatedAt: a.updatedAt, updatedBy: a.updatedBy } : { updatedAt: b.updatedAt, updatedBy: b.updatedBy }),
  };
}

/** Junta vistas parciales (los documentos sueltos de una orden, o todas sus hojas). */
export function merge(views: Partial<View>[]): View {
  const v: View = { tasks: {}, parts: {}, labor: {}, openItems: [], notes: [] };
  for (const p of views) {
    for (const [t, by] of Object.entries(p.tasks ?? {})) v.tasks[t] = [...(v.tasks[t] ?? []), ...by];
    for (const [pos, s] of Object.entries(p.parts ?? {})) v.parts[pos] = [...new Set([...(v.parts[pos] ?? []), ...s])];
    Object.assign(v.labor, p.labor ?? {});
    v.openItems.push(...(p.openItems ?? []));
    v.notes.push(...(p.notes ?? []));
  }
  return v;
}

/** ¿La edición está en la vista? Si su posición tiene más de un serial vivo, quedó en disputa. */
export function found(v: Partial<View>, e: Edit): "kept" | "disputed" | "missing" {
  if (e.kind === "task") return v.tasks?.[e.task]?.includes(e.by) ? "kept" : "missing";
  if (e.kind === "swap") {
    const s = v.parts?.[e.position] ?? [];
    return !s.includes(e.installed) ? "missing" : s.length > 1 ? "disputed" : "kept";
  }
  if (e.kind === "labor") return (v.labor?.[e.by] ?? 0) >= e.hours ? "kept" : "missing";
  if (e.kind === "closeItem") return v.openItems && !v.openItems.includes(e.item) ? "kept" : "missing";
  return v.notes?.includes(e.text) ? "kept" : "missing";
}
