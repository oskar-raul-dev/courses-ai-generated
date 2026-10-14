// La apuesta: tres días sin señal con cien órdenes editadas sincronizan sin intervención manual. Freddy
// edita su parte de las cien en la tableta; los demás técnicos de cada orden, su parte en la base, con señal.
// El jueves Freddy sincroniza, se resuelve en el servidor y se cuenta:
//   intervención manual = una posición en disputa, o un conflicto que queda sin resolver para que alguien lo mire.
// Se corre con la forma que propone la Fase 19 (CRDT) y con la forma de siempre (orden por documento).
//
//   node 20-offline-romper-y-medir/bet.ts   (desde src/, con offline arriba)
import { conflicts, freshRemote, freshTablet, newWire, remote } from "../lab/harness/couch.ts";
import { verifyDataset } from "../lab/harness/dataset.ts";
import { crdtDoc, orderDoc, type Shape } from "../19-offline-levantar-y-modelar/trip.ts";
import { couchWinner, crdtMerge, lastWriteWins, resolve, tally, type Resolver } from "./resolve.ts";
import { DATASET, FREDDY, loadTrip } from "./scenario.ts";

await verifyDataset(DATASET);
const trip = await loadTrip(100);
const mine = trip.edits.filter((e) => e.by === FREDDY);
const theirs = trip.edits.filter((e) => e.by !== FREDDY).sort((a, b) => a.at.localeCompare(b.at));
const shared = new Set(theirs.map((e) => e.wo));
console.log(`${trip.orders.length} órdenes de Freddy en ${trip.aircraft.length} aeronaves · ${shared.size} con otro técnico · ` +
  `${mine.length} ediciones de Freddy sin señal · ${theirs.length} de ${new Set(theirs.map((e) => e.by)).size} técnicos más, con señal`);

async function run(shape: Shape, resolver: Resolver) {
  await freshRemote("f20_bet");
  const server = remote("f20_bet");
  await server.bulkDocs(trip.orders.flatMap((o) => shape.seed(o)));
  const freddy = freshTablet("freddy-100");
  await freddy.replicate.from(server);                 // lunes temprano, en Villavicencio

  for (const e of theirs) await shape.apply(server, e); // los demás, con señal
  for (const e of mine) await shape.apply(freddy, e);   // Freddy, sin señal

  const wire = newWire();
  const t0 = performance.now();
  const r = await freddy.sync(remote("f20_bet", wire)); // jueves
  const s = ((performance.now() - t0) / 1000).toFixed(1);
  const found = await conflicts(server);
  await resolve(server, resolver);
  await freddy.sync(server);
  const left = await conflicts(server);
  const [tf, to] = [await tally(server, shape, mine), await tally(server, shape, theirs)];
  const t = { kept: tf.kept + to.kept, disputed: tf.disputed + to.disputed, hidden: tf.hidden + to.hidden, lost: tf.lost + to.lost,
    disputes: new Set([...tf.disputes, ...to.disputes]) };
  const manual = t.disputes.size + left.docs.length;
  console.log(`${shape.name.padEnd(20)} · ${resolver.name.padEnd(26)} · sube ${r.push.docs_written} docs y baja ${r.pull.docs_written} · ` +
    `${wire.requests} peticiones · ${Math.round((wire.up + wire.down) / 1024)} KiB · ${s} s · conflictos ${found.docs.length} · ` +
    `conservadas ${t.kept} (de Freddy ${tf.kept}/${mine.length}, de los demás ${to.kept}/${theirs.length}) · en disputa ${t.disputed} · escondidas ${t.hidden} · perdidas ${t.lost} · ` +
    `intervenciones manuales ${manual} (disputas ${t.disputes.size}, conflictos sin resolver ${left.docs.length})`);
  await freddy.close();
  await server.close();
}

await run(crdtDoc, crdtMerge);
await run(orderDoc, couchWinner);
await run(orderDoc, lastWriteWins);
