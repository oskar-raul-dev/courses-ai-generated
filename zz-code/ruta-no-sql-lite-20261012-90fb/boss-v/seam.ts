// Solución privada del boss V, punto 4: la costura de SIGMA hacia el sistema de Camilo, si se queda como índice.
// SIGMA es de un proveedor: no se le puede agregar un INSERT al outbox en su código. Un trigger lo hace en la misma
// transacción, sin tocar el código ni el WAL. Un relevo lleva cada pieza cambiada a MongoDB; la ventana se mide como en
// la Fase 24: del COMMIT a que la pieza tiene en Mongo el valor nuevo, con un observador que mira mientras corre la carga.
// Escribe en camilo.component_index (una copia), no en camilo.component: el boss tiene que seguir divergido.
//
//   node seam.ts   (base y documental arriba; deja expediente y camilo como estaban)
import { MongoClient } from "mongodb";
import pg from "pg";

const conn = () => new pg.Client({ host: "localhost", port: 15432, user: "postgres", password: "condor", database: "expediente" });
const [writer, relay] = [conn(), conn()];
await writer.connect(); await relay.connect();
const mongo = new MongoClient("mongodb://localhost:27018/?directConnection=true");
await mongo.connect();
const camilo = mongo.db("camilo");
await camilo.collection("component_index").drop().catch(() => {});
await camilo.collection("component").aggregate([{ $out: "component_index" }]).toArray();
const index = camilo.collection("component_index");

await writer.query(`CREATE TABLE part_outbox (id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, serial_number text NOT NULL)`);
await writer.query(`CREATE FUNCTION part_outbox_fn() RETURNS trigger LANGUAGE plpgsql AS $$
  BEGIN INSERT INTO part_outbox (serial_number) VALUES (NEW.serial_number); RETURN NEW; END $$`);
await writer.query(`CREATE TRIGGER part_outbox_tg AFTER INSERT OR UPDATE ON part FOR EACH ROW EXECUTE FUNCTION part_outbox_fn()`);

let stop = false;
const relayLoop = (async () => {
  while (!stop) {
    await relay.query("BEGIN");
    const { rows } = await relay.query(`SELECT o.id, p.serial_number, p.status, p.aircraft, p.position, p.hangar_id, p.supplier_id, p.hours_since_new
      FROM part_outbox o JOIN part p USING (serial_number) ORDER BY o.id LIMIT 500 FOR UPDATE OF o SKIP LOCKED`);
    if (rows.length) {
      await index.bulkWrite(rows.map((r) => ({ updateOne: { filter: { _id: r.serial_number }, update: { $set: {
        status: r.status, aircraft: r.aircraft, position: r.position, hangarId: r.hangar_id, supplierId: r.supplier_id, hoursSinceNew: r.hours_since_new } } } })));
      await relay.query(`DELETE FROM part_outbox WHERE id = ANY($1)`, [rows.map((r) => r.id)]);
    }
    await relay.query("COMMIT");
    if (!rows.length) await new Promise((r) => setTimeout(r, 100));
  }
})();

// el observador, en paralelo con la carga: cada 20 ms mira las piezas confirmadas que todavía no ve con su valor nuevo
const committed = new Map<string, { at: number; hours: number }>();
const seen = new Map<string, number>();
let loading = true;
const observer = (async () => {
  const deadline = () => !loading && (seen.size === committed.size || Date.now() > end + 30_000);
  let end = Infinity;
  while (!deadline()) {
    if (!loading && end === Infinity) end = Date.now();
    const pending = [...committed.keys()].filter((s) => !seen.has(s));
    if (pending.length) {
      for (const d of await index.find({ _id: { $in: pending as any } }, { projection: { hoursSinceNew: 1 } }).toArray()) {
        const id = d._id as unknown as string;
        if (d.hoursSinceNew === committed.get(id)!.hours) seen.set(id, Date.now());
      }
    }
    await new Promise((r) => setTimeout(r, 20));
  }
})();

// la carga: 2000 piezas, las horas de cada una +1, a 200 por segundo, como en la Fase 24
const { rows: serials } = await writer.query(`SELECT serial_number FROM part ORDER BY serial_number LIMIT 2000`);
const t0 = Date.now();
for (let i = 0; i < serials.length; i++) {
  const wait = t0 + i * 5 - Date.now();
  if (wait > 0) await new Promise((r) => setTimeout(r, wait));
  const { rows: [r] } = await writer.query(`UPDATE part SET hours_since_new = hours_since_new + 1 WHERE serial_number = $1 RETURNING hours_since_new`, [serials[i].serial_number]);
  committed.set(serials[i].serial_number, { at: Date.now(), hours: r.hours_since_new });
}
loading = false;
await observer;
stop = true;
await relayLoop;
const w = [...seen].map(([s, t]) => t - committed.get(s)!.at).sort((a, b) => a - b);
const pct = (p: number) => w[Math.max(0, Math.ceil((p / 100) * w.length) - 1)];
console.log(`outbox por trigger, SIGMA → índice de Camilo · ${committed.size} cambios a 200/s · llegaron ${seen.size} · p50 ${pct(50)} ms · p99 ${pct(99)} ms · máx ${w.at(-1)} ms`);
console.log("  (incluye hasta 20 ms del sondeo del observador)");

// dejar expediente y camilo como estaban: sentencia por sentencia, primero el trigger para que la resta no deje filas
await writer.query(`DROP TRIGGER part_outbox_tg ON part`);
await writer.query(`DROP FUNCTION part_outbox_fn()`);
await writer.query(`DROP TABLE part_outbox`);
await writer.query(`UPDATE part SET hours_since_new = hours_since_new - 1 WHERE serial_number = ANY($1)`, [[...committed.keys()]]);
await index.drop();
await writer.end(); await relay.end(); await mongo.close();
