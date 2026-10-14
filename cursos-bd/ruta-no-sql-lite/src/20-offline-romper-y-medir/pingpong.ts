// La sincronización que no converge. El viaje de la apuesta deja 89 conflictos en el servidor y en la
// tableta de Freddy. Cada ronda, alguien los resuelve con la fusión del CRDT (la misma función, el mismo
// resultado) y todos sincronizan otra vez. Cuatro maneras de repartir quién resuelve:
//   A · solo el servidor
//   B · el servidor y la tableta, cada uno por su lado
//   C · dos tabletas, cada una por su lado
//   D · el servidor y la tableta, y la resolución anota quién la hizo y a qué hora
//   E · dos tabletas, firmando igual que en D
// Las fusiones se escriben con las claves ordenadas: dos réplicas que fusionan lo mismo escriben el mismo JSON.
//
//   node 20-offline-romper-y-medir/pingpong.ts [--rounds 10]   (desde src/, con offline arriba)
import { parseArgs } from "node:util";
import { conflicts, couch, freshRemote, freshTablet, leaves, remote, type Db } from "../lab/harness/couch.ts";
import { verifyDataset } from "../lab/harness/dataset.ts";
import { crdtDoc, mergeCrdt } from "../19-offline-levantar-y-modelar/trip.ts";
import { resolve, type Resolver } from "./resolve.ts";
import { DATASET, FREDDY, loadTrip } from "./scenario.ts";

const { values: args } = parseArgs({ options: { rounds: { type: "string", default: "10" } } });
const sorted = (v: any): any => (Array.isArray(v) ? v.map(sorted) : v && typeof v === "object"
  ? Object.fromEntries(Object.keys(v).sort().map((k) => [k, sorted(v[k])])) : v);
const canonical: Resolver = { name: "fusión del CRDT, canónica", pick: (ls) => sorted(ls.reduce(mergeCrdt)) };

// el mismo documento, guardado en una tableta nueva y en una base nueva del servidor
const probe = freshTablet("pingpong-probe");
const inTablet = (await probe.put({ _id: "x", v: 1 })).rev;
await probe.destroy();
await freshRemote("f20_probe");
const inServer = (await couch("f20_probe/x", { method: "PUT", body: JSON.stringify({ v: 1 }) })).rev;
await couch("f20_probe", { method: "DELETE" });
console.log(`{"v":1} guardado en una tableta: ${inTablet} · en el servidor: ${inServer}`);

await verifyDataset(DATASET);
const trip = await loadTrip(100);
const mine = trip.edits.filter((e) => e.by === FREDDY), theirs = trip.edits.filter((e) => e.by !== FREDDY);

/** El viaje de la apuesta, hasta el jueves: conflictos en el servidor y en las tabletas que se nombren. */
async function setup(tabletNames: string[]) {
  await freshRemote("f20_pingpong");
  const server = remote("f20_pingpong");
  await server.bulkDocs(trip.orders.flatMap((o) => crdtDoc.seed(o)));
  const tablets = tabletNames.map((n) => freshTablet(`pingpong-${n}`));
  for (const t of tablets) await t.replicate.from(server);
  for (const e of theirs) await crdtDoc.apply(server, e);
  for (const e of mine) await crdtDoc.apply(tablets[0], e);
  for (const t of [...tablets, ...tablets]) await t.sync(server);
  return { server, tablets };
}

type Who = (s: Db, t: Db[], round: number) => Promise<void>;
const variants: [string, string[], Who][] = [
  ["A · solo el servidor", ["freddy"], async (s) => { await resolve(s, canonical); }],
  ["B · servidor y tableta", ["freddy"], async (s, [t]) => { await resolve(s, canonical); await resolve(t, canonical); }],
  ["C · dos tabletas", ["freddy", "jairo"], async (_s, [a, b]) => { await resolve(a, canonical); await resolve(b, canonical); }],
  ["D · servidor y tableta, firmando", ["freddy"], async (s, [t], round) => {
    await resolve(s, canonical, { resolvedBy: "servidor", resolvedAt: `ronda ${round}` });
    await resolve(t, canonical, { resolvedBy: "tableta", resolvedAt: `ronda ${round}` });
  }],
  ["E · dos tabletas, firmando", ["freddy", "jairo"], async (_s, [a, b], round) => {
    await resolve(a, canonical, { resolvedBy: "freddy", resolvedAt: `ronda ${round}` });
    await resolve(b, canonical, { resolvedBy: "jairo", resolvedAt: `ronda ${round}` });
  }],
];

for (const [name, tabletNames, resolvers] of variants) {
  const { server, tablets } = await setup(tabletNames);
  const line: string[] = [`ronda 0: ${(await conflicts(server)).docs.length}`];
  let round = 0;
  for (round = 1; round <= Number(args.rounds); round++) {
    await resolvers(server, tablets, round);
    for (const t of [...tablets, ...tablets]) await t.sync(server);
    const left = (await conflicts(server)).docs.length;
    line.push(`${round}: ${left}`);
    if (left === 0) break;
  }
  const info = await couch("f20_pingpong");
  const doc: any = await server.get(trip.orders[0].workOrderId, { conflicts: true } as any);
  // si quedan hojas, ¿dicen lo mismo? (sin _rev, con las claves ordenadas)
  const bodies = new Set((await leaves(server, doc._id)).map(({ _rev, ...b }) => JSON.stringify(sorted(b))));
  console.log(`${name.padEnd(34)} · conflictos por ronda ${line.join(" · ")} · revisión de ${doc._id} ${doc._rev.split("-")[0]} · ` +
    `hojas ${1 + (doc._conflicts?.length ?? 0)} con ${bodies.size} cuerpo(s) distinto(s) · ` +
    `cambios en el servidor ${info.update_seq.split("-")[0]} · archivo ${(info.sizes.file / 1024).toFixed(0)} KiB`);
  for (const t of tablets) await t.close();
  await server.close();
}
