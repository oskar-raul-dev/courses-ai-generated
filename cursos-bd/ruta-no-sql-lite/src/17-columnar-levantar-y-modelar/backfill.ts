// La consulta que llega después: "los últimos diez vuelos de una aeronave, con su EGT máxima". En
// Cassandra no hay tabla que la conteste, así que es una tabla nueva más un backfill: recorrer entera
// una tabla que ya existe (reading_by_flight) y escribir la nueva. En Postgres es una consulta nueva
// sobre el mismo índice. Se mide lo que cuesta cada camino.
//
//   node 17-columnar-levantar-y-modelar/backfill.ts   (desde src/, después de load.ts y baseline.ts)
import { readFileSync } from "node:fs";
import cassandra from "cassandra-driver";
import pg from "pg";
import { columnar, traced, writeAll } from "../lab/harness/cassandra-trace.ts";
import { explain } from "../lab/harness/explain.ts";

const cs = columnar();
await cs.connect();
const pgc = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "series_base" });
await pgc.connect();
const trend = JSON.parse(readFileSync("lab/data/reading-5m/answers.json", "utf8")).egtTrend as { aircraft: string };

try {
  await cs.execute("DROP TABLE IF EXISTS flights_by_aircraft");
  await cs.execute(`CREATE TABLE flights_by_aircraft (
      aircraft text, first_ts timestamp, flight_id text, last_ts timestamp, readings int, max_egt_c int,
      PRIMARY KEY ((aircraft), first_ts, flight_id)
    ) WITH CLUSTERING ORDER BY (first_ts DESC, flight_id ASC)`);

  // el backfill: recorrer toda reading_by_flight, partición por partición, en páginas de 5000
  const started = performance.now();
  const flights = new Map<string, { aircraft: string; first: Date; last: Date; readings: number; maxEgt: number }>();
  let read = 0;
  const stream = cs.stream("SELECT flight_id, ts, aircraft, egt_c FROM reading_by_flight", [], { prepare: true, fetchSize: 5000 });
  for await (const row of stream as AsyncIterable<cassandra.types.Row>) {
    read++;
    const f = flights.get(row.flight_id);
    if (!f) flights.set(row.flight_id, { aircraft: row.aircraft, first: row.ts, last: row.ts, readings: 1, maxEgt: row.egt_c });
    else {
      f.readings++;
      if (row.ts < f.first) f.first = row.ts;
      if (row.ts > f.last) f.last = row.ts;
      if (row.egt_c > f.maxEgt) f.maxEgt = row.egt_c;
    }
  }
  const scanned = (performance.now() - started) / 1000;
  const writes = [...flights].map(([id, f]) => ({
    query: "INSERT INTO flights_by_aircraft (aircraft, first_ts, flight_id, last_ts, readings, max_egt_c) VALUES (?, ?, ?, ?, ?, ?)",
    params: [f.aircraft, f.first, id, f.last, f.readings, f.maxEgt],
  }));
  await writeAll(cs, writes);
  const total = (performance.now() - started) / 1000;
  console.log(`backfill: ${read} filas leídas de reading_by_flight en ${scanned.toFixed(0)} s · ${writes.length} filas escritas en flights_by_aircraft · ${total.toFixed(0)} s en total`);

  // y desde ahora, cada vuelo nuevo se escribe también aquí: el cargador lleva una escritura más
  for (const pass of [1, 2]) {
    const c = await traced(cs, "SELECT flight_id, first_ts, max_egt_c FROM flights_by_aircraft WHERE aircraft = ? LIMIT 10", [trend.aircraft]);
    const p = await explain(pgc, `SELECT flight_id, min(ts) AS first_ts, max(egt_c) AS max_egt_c FROM reading_part5
        WHERE aircraft = $1 GROUP BY flight_id ORDER BY first_ts DESC LIMIT 10`, [trend.aircraft]);
    if (pass === 2) {
      console.log(`4 · últimos diez vuelos de ${trend.aircraft}`);
      console.log(`  cassandra  devueltas ${c.returned} · particiones ${c.partitions} · sstables ${c.sstables} · filas vivas leídas ${c.liveRows}`);
      console.log(`  postgres   devueltas ${p.returned} · examinadas ${p.examined} · páginas ${p.sharedHit + p.sharedRead}`);
    }
  }
  const { rows } = await pgc.query(`SELECT flight_id FROM reading_part5 WHERE aircraft = $1 GROUP BY flight_id ORDER BY min(ts) DESC LIMIT 10`, [trend.aircraft]);
  const c = await cs.execute("SELECT flight_id FROM flights_by_aircraft WHERE aircraft = ? LIMIT 10", [trend.aircraft], { prepare: true });
  console.log(`  los mismos diez vuelos en los dos: ${rows.map((x) => x.flight_id).join() === c.rows.map((x) => x.flight_id).join() ? "sí" : "NO"}`);
} finally {
  await cs.shutdown();
  await pgc.end();
}
