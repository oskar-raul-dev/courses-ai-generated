// Resolver y contar, lo mismo que en la Fase 19 pero para cualquier lista de ediciones: las tres maneras de
// terminar un conflicto y la cuenta de qué edición quedó conservada, en disputa, escondida o perdida.
import { conflicts, leaves, type Db } from "../lab/harness/couch.ts";
import { found, merge, mergeCrdt, type Edit, type Shape } from "../19-offline-levantar-y-modelar/trip.ts";

export type Resolver = { name: string; pick?: (leaves: any[]) => any };
export const couchWinner: Resolver = { name: "ganadora de CouchDB" };
export const lastWriteWins: Resolver = { name: "el último que escribe gana", pick: (ls) => ls.reduce((a, b) => (b.updatedAt > a.updatedAt ? b : a)) };
export const crdtMerge: Resolver = { name: "fusión del CRDT", pick: (ls) => ls.reduce(mergeCrdt) };

/** En cada documento con conflicto: la fusión sobre la ganadora y el borrado de las perdedoras, en una llamada. */
export async function resolve(db: Db, r: Resolver, extra: Record<string, unknown> = {}): Promise<number> {
  if (!r.pick) return 0;
  const { docs } = await conflicts(db);
  for (const id of docs) {
    const current = await db.get(id);
    const all = await leaves(db, id);
    const { _rev, _conflicts, ...body } = r.pick(all);
    await db.bulkDocs([
      { ...body, ...extra, _id: id, _rev: current._rev },
      ...all.filter((l) => l._rev !== current._rev).map((l) => ({ _id: id, _rev: l._rev, _deleted: true })),
    ]);
  }
  return docs.length;
}

export interface Tally { kept: number; disputed: number; hidden: number; lost: number; disputes: Set<string> }

/** Cada edición contra lo que quedó en el servidor; una posición con más de un serial vivo es una disputa. */
export async function tally(server: Db, shape: Shape, edits: Edit[]): Promise<Tally> {
  const t: Tally = { kept: 0, disputed: 0, hidden: 0, lost: 0, disputes: new Set() };
  const views = new Map<string, any>();
  for (const e of edits) {
    if (!views.has(e.wo)) views.set(e.wo, await shape.view(server, e.wo));
    let status: string = found(views.get(e.wo), e);
    if (status === "missing") {
      const ls = await leaves(server, e.wo);
      status = ls.some((l) => found(merge([shape.leafView(l)]), e) !== "missing") ? "hidden" : "lost";
    }
    if (status === "disputed" && e.kind === "swap") t.disputes.add(`${e.wo}/${e.position}`);
    t[status as "kept"]++;
  }
  return t;
}
