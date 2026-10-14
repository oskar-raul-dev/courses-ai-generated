// El viaje de Freddy y lo que hizo Jairo, sincronizado con cada forma de documento y cada manera de
// resolver. Jairo vuelve a tener señal el miércoles en la noche y sincroniza primero; Freddy, el jueves.
// Después se resuelve (o no) en el servidor, las dos tabletas sincronizan otra vez, y cada una de las 26
// ediciones se busca en lo que quedó:
//   conservada · en disputa (sobrevive junto a otra incompatible) · escondida (solo en una revisión
//   perdedora, que nadie lee) · perdida (no está en ninguna hoja).
//
//   node 19-offline-levantar-y-modelar/conflicts.ts [--detail]   (desde src/, con offline arriba)
import { parseArgs } from "node:util";
import { conflicts, freshRemote, freshTablet, leaves, remote, type Db } from "../lab/harness/couch.ts";
import { verifyDataset } from "../lab/harness/dataset.ts";
import {
  DATASET, FREDDY, JAIRO, TRIP_ORDERS, crdtDoc, found, loadOrders, merge, mergeCrdt, orderDoc, splitDocs, tripSelector,
  type Edit, type Shape,
} from "./trip.ts";

const { values: args } = parseArgs({ options: { detail: { type: "boolean", default: false } } });

type Resolver = { name: string; pick?: (leaves: any[]) => any };
const couchWinner: Resolver = { name: "ganadora de CouchDB" };
const lastWriteWins: Resolver = {
  name: "el último que escribe gana",
  pick: (ls) => ls.reduce((a, b) => (b.updatedAt > a.updatedAt ? b : a)),
};
/** La fusión que uno escribe a mano para una orden: unir tareas, notas y pendientes; una posición con
 *  dos seriales distintos queda marcada para que la vea una persona. */
const handMerge: Resolver = {
  name: "fusión a mano",
  pick: (ls) => {
    const out = structuredClone(ls[0]);
    for (const l of ls.slice(1)) {
      for (const [t, s] of Object.entries<any[]>(l.tasks))
        out.tasks[t] = [...(out.tasks[t] ?? []), ...s.filter((x) => !out.tasks[t]?.some((y: any) => y.by === x.by && y.at === x.at))];
      for (const [p, v] of Object.entries<any>(l.parts)) {
        const mine = out.parts[p];
        if (!mine) out.parts[p] = v;
        else if (mine.installed !== v.installed) (out.disputes ??= {})[p] = [mine, v];
      }
      for (const [k, h] of Object.entries<number>(l.labor)) out.labor[k] = Math.max(out.labor[k] ?? 0, h);
      out.openItems = [...new Set([...out.openItems, ...l.openItems])];
      out.notes = [...new Set([...out.notes, ...l.notes])];
    }
    return out;
  },
};
const crdtMerge: Resolver = { name: "fusión del CRDT", pick: (ls) => ls.reduce(mergeCrdt) };

/** El documento que toca cada edición en cada forma. */
const docOf = (shape: Shape, e: Edit): string => {
  if (shape !== splitDocs) return e.wo;
  const slug = (s: string) => s.normalize("NFD").replace(/\p{Diacritic}/gu, "").replace(/[^\w]+/g, "-").toLowerCase();
  const id = e.kind === "task" ? e.task : e.kind === "swap" ? e.position : e.kind === "labor" ? e.by
    : e.kind === "closeItem" ? e.item : `${e.by}-${e.at}`;
  const kind = e.kind === "swap" ? "part" : e.kind === "closeItem" ? "item" : e.kind;
  return `${e.wo}/${kind}/${slug(id)}`;
};

/** JSON con las claves ordenadas: dos objetos iguales dan el mismo texto aunque se hayan armado en otro orden. */
const canonical = (v: unknown): string => JSON.stringify(v, (_k, x) =>
  x && typeof x === "object" && !Array.isArray(x) ? Object.fromEntries(Object.entries(x).sort(([a], [b]) => a.localeCompare(b))) : x);

async function resolve(db: Db, r: Resolver): Promise<void> {
  if (!r.pick) return;
  for (const id of (await conflicts(db)).docs) {
    const current = await db.get(id);
    const all = await leaves(db, id);
    const { _rev, _conflicts, ...body } = r.pick(all);
    await db.bulkDocs([
      { ...body, _id: id, _rev: current._rev },
      ...all.filter((l) => l._rev !== current._rev).map((l) => ({ _id: id, _rev: l._rev, _deleted: true })),
    ]);
  }
}

/** Revisión ganadora y conflictos de cada documento del viaje, para comparar réplicas. */
async function state(db: Db): Promise<string> {
  const rows = (await db.allDocs({ conflicts: true, include_docs: true })).rows.filter((r) => TRIP_ORDERS.some((wo) => r.id.startsWith(wo)));
  return rows.map((r) => `${r.id}@${r.value.rev}+${(r.doc?._conflicts ?? []).join(",")}`).join(" ");
}

async function run(shape: Shape, resolver: Resolver, orders: any[]) {
  const name = `f19_trip`;
  await freshRemote(name);
  const server = remote(name);
  await server.bulkDocs(orders.flatMap((o) => shape.seed(o)));

  // el lunes temprano, en Villavicencio, las dos tabletas bajan las órdenes de las cuatro aeronaves
  const freddy = freshTablet("freddy"), jairo = freshTablet("jairo");
  for (const t of [freddy, jairo]) await t.replicate.from(server, { selector: tripSelector } as any);

  // sin señal: cada uno guarda en su tableta
  for (const e of FREDDY) await shape.apply(freddy, e);
  for (const e of JAIRO) await shape.apply(jairo, e);

  await jairo.sync(server);                       // miércoles en la noche
  await freddy.sync(server);                      // jueves
  const found1 = await conflicts(server);
  const onTablet = await conflicts(freddy);
  const winners = await Promise.all(found1.docs.map(async (id) => {
    const ls = await leaves(server, id);
    const w = await server.get(id);
    return `${id}: gana ${w._rev.split("-")[0]}-… de ${(w as any).updatedBy} sobre ` +
      ls.filter((l) => l._rev !== w._rev).map((l) => `${l._rev.split("-")[0]}-… de ${l.updatedBy}`).join(", ");
  }));

  // la fusión del CRDT no depende del orden: se comprueba con las hojas de cada conflicto, en los dos sentidos
  const commutes = resolver === crdtMerge ? await Promise.all(found1.docs.map(async (id) => {
    const ls = (await leaves(server, id)).map(({ _rev, ...b }) => b);
    return canonical(ls.reduce(mergeCrdt)) === canonical([...ls].reverse().reduce(mergeCrdt));
  })) : [];
  await resolve(server, resolver);
  await freddy.sync(server);
  await jairo.sync(server);
  const left = await conflicts(server);
  const [s, f, j] = await Promise.all([state(server), state(freddy), state(jairo)]);

  const tally = { kept: 0, disputed: 0, hidden: 0, lost: 0, freddy: 0, jairo: 0 };
  const detail: string[] = [];
  for (const e of [...FREDDY, ...JAIRO]) {
    let status: string = found(await shape.view(server, e.wo), e);
    if (status === "missing") {
      const ls = await leaves(server, docOf(shape, e));
      status = ls.some((l) => found(merge([shape.leafView(l)]), e) !== "missing") ? "hidden" : "lost";
    }
    tally[status as "kept"]++;
    if (status === "kept" || status === "disputed") tally[e.by === "T-004" ? "freddy" : "jairo"]++;
    if (status !== "kept") detail.push(`    ${status.padEnd(8)} ${e.by} ${e.at.slice(5, 16)} ${e.wo} ${e.kind} ${"task" in e ? e.task : "position" in e ? `${e.position} ${e.installed}` : "item" in e ? e.item : "text" in e ? e.text : `${e.hours} h`}`);
  }
  console.log(`${shape.name.padEnd(22)} · ${resolver.name.padEnd(26)} · conflictos ${found1.docs.length} (${found1.losers} perdedoras; en la tableta de Freddy ${onTablet.docs.length})` +
    ` · de Freddy ${tally.freddy}/${FREDDY.length} · de Jairo ${tally.jairo}/${JAIRO.length}` +
    ` · en disputa ${tally.disputed} · escondidas ${tally.hidden} · perdidas ${tally.lost}` +
    ` · conflictos al final ${left.docs.length} · réplicas iguales ${s === f && f === j ? "sí" : "no"}` +
    (commutes.length ? ` · fusión en los dos órdenes, igual: ${commutes.every(Boolean) ? "sí" : "no"}` : ""));
  if (args.detail) for (const w of winners) console.log(`    ${w}`);
  if (args.detail) for (const d of detail) console.log(d);
  for (const t of [freddy, jairo, server]) await t.close();
}

await verifyDataset(DATASET);
const { trip } = await loadOrders();
console.log(`viaje: ${trip.length} órdenes reabiertas · ${FREDDY.length} ediciones de Freddy (T-004) · ${JAIRO.length} de Jairo (T-009), sin señal los dos`);
await run(orderDoc, couchWinner, trip);
await run(orderDoc, lastWriteWins, trip);
await run(orderDoc, handMerge, trip);
await run(splitDocs, couchWinner, trip);
await run(crdtDoc, crdtMerge, trip);
