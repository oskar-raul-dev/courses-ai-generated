// La cardinalidad que mata, en sus dos formas, sobre las 5 M lecturas reales (tabla reading de la base
// condor, perfil series):
//   --segmentby   comprimir agrupando por aeronave (17 series) o por aeronave y vuelo (62 486)
//   --chunks      chunks cada vez más pequeños hasta que una consulta de cinco años deja de poder
//                 planearse (el punto de rotura de la Fase 10)
//
//   node 10-series-romper-y-medir/cardinality.ts --segmentby | --chunks [--intervals "1 day,6 hours"]
import { parseArgs } from "node:util";
import pg from "pg";
import { explain, type PlanNode } from "../lab/harness/explain.ts";

const { values: args } = parseArgs({
  options: { segmentby: { type: "boolean", default: false }, chunks: { type: "boolean", default: false },
    intervals: { type: "string", default: "7 days,1 day,6 hours,2 hours,1 hour" } },
});
const c = new pg.Client({ host: "localhost", port: Number(process.env.SERIES_PORT ?? 15433), user: "postgres", password: "condor", database: "condor" });
await c.connect();
const one = async (sql: string) => (await c.query(sql)).rows[0];
const mib = (b: number) => `${(b / 2 ** 20).toFixed(1)} MiB`;
const chunksIn = (plan: PlanNode): number => {
  const seen = new Set<string>();
  const walk = (n: PlanNode) => { if (n["Relation Name"]?.startsWith("_hyper_")) seen.add(n["Relation Name"]); n.Plans?.forEach(walk); };
  walk(plan);
  return seen.size;
};
const QUERY = `SELECT date_trunc('day', ts), avg(egt_c) FROM %T WHERE aircraft = 'HC-2157' AND ts >= '2025-09-15' AND ts < '2025-11-14' GROUP BY 1`;

try {
  if (args.segmentby) {
    for (const [name, segmentby] of [["reading_seg_aircraft", "aircraft"], ["reading_seg_flight", "aircraft, flight_id"]]) {
      await c.query(`DROP TABLE IF EXISTS ${name}`);
      await c.query(`CREATE TABLE ${name} (LIKE reading)`);
      await c.query(`SELECT create_hypertable('${name}', by_range('ts', INTERVAL '7 days'))`);
      await c.query(`INSERT INTO ${name} SELECT * FROM reading ORDER BY aircraft, ts`);
      await c.query(`ALTER TABLE ${name} SET (timescaledb.compress, timescaledb.compress_segmentby = '${segmentby}', timescaledb.compress_orderby = 'ts')`);
      const t = performance.now();
      await c.query(`SELECT count(compress_chunk(x)) FROM show_chunks('${name}') x`);
      const seconds = (performance.now() - t) / 1000;
      await c.query(`VACUUM ANALYZE ${name}`);
      const stats = await one(`SELECT sum(before_compression_total_bytes) AS b, sum(after_compression_total_bytes) AS a FROM chunk_compression_stats('${name}')`);
      // los lotes comprimidos: una fila por segmento y por cada hasta 1000 lecturas
      const batches = await one(`SELECT sum(z.numrows_post_compression) AS n FROM _timescaledb_catalog.compression_chunk_size z
        JOIN _timescaledb_catalog.chunk ch ON ch.id = z.chunk_id JOIN _timescaledb_catalog.hypertable h ON h.id = ch.hypertable_id
        WHERE h.table_name = '${name}'`);
      const r = await explain(c, QUERY.replace("%T", name));
      console.log(`segmentby ${segmentby.padEnd(20)} ${mib(Number(stats.b))} → ${mib(Number(stats.a))} · lotes comprimidos ${batches.n} · comprimir ${seconds.toFixed(1)} s · HC-2157 60 días: páginas ${r.sharedHit + r.sharedRead}, examinadas ${r.examined}`);
      try {
        await c.query(`DROP TABLE ${name}`);
      } catch (e) {
        // borrar la tabla también toma un candado por chunk; se borra por tandas con drop_chunks
        const err = e as { message: string; hint?: string };
        console.log(`chunk de ${interval.padEnd(8)} DROP TABLE: ERROR: ${err.message} · HINT: ${err.hint}`);
        for (let m = 0; m < 66; m += 3) {
          const cut = new Date(Date.UTC(2021, 9 + m, 1)).toISOString().slice(0, 10);
          await c.query(`SELECT drop_chunks('${name}', older_than => TIMESTAMP '${cut}')`);
        }
        await c.query(`DROP TABLE ${name}`);
        console.log(`chunk de ${interval.padEnd(8)} borrada por tandas de tres meses`);
      }
    }
  }
  if (args.chunks) {
    const locks = await one("SELECT current_setting('max_locks_per_transaction') AS l, current_setting('max_connections') AS m");
    console.log(`max_locks_per_transaction ${locks.l} · max_connections ${locks.m}`);
    for (const interval of args.intervals!.split(",")) {
      const name = "reading_tiny";
      await c.query(`DROP TABLE IF EXISTS ${name}`);
      await c.query(`CREATE TABLE ${name} (LIKE reading)`);
      await c.query(`SELECT create_hypertable('${name}', by_range('ts', INTERVAL '${interval}'))`);
      await c.query(`CREATE INDEX ON ${name} (aircraft, ts DESC)`);
      let t = performance.now();
      try {
        await c.query(`INSERT INTO ${name} SELECT * FROM reading ORDER BY aircraft, ts`);
      } catch (e) {
        const err = e as { message: string; hint?: string };
        const need = (await one(`SELECT count(DISTINCT time_bucket(INTERVAL '${interval}', ts)) AS n FROM reading`)).n;
        console.log(`chunk de ${interval.padEnd(8)} el INSERT de una vez (${need} chunks) falla: ERROR: ${err.message} · HINT: ${err.hint}`);
        // la misma carga, un mes por transacción: cada una crea pocos chunks
        t = performance.now();
        for (let m = 0; m < 63; m++) {
          const from = new Date(Date.UTC(2021, 9 + m, 1)).toISOString().slice(0, 10);
          const to = new Date(Date.UTC(2021, 10 + m, 1)).toISOString().slice(0, 10);
          await c.query(`INSERT INTO ${name} SELECT * FROM reading WHERE ts >= '${from}' AND ts < '${to}' ORDER BY aircraft, ts`);
        }
        console.log(`chunk de ${interval.padEnd(8)} cargado un mes por transacción`);
      }
      const load = (performance.now() - t) / 1000;
      await c.query(`ANALYZE ${name}`);
      const n = Number((await one(`SELECT count(*) AS n FROM timescaledb_information.chunks WHERE hypertable_name = '${name}'`)).n);
      for (const [label, sql] of [["60 días", QUERY.replace("%T", name)], ["cinco años", `SELECT avg(egt_c) FROM ${name} WHERE aircraft = 'HC-2157'`]]) {
        t = performance.now();
        try {
          const { rows } = await c.query(`EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) ${sql}`);
          const p = rows[0]["QUERY PLAN"][0];
          console.log(`chunk de ${interval.padEnd(8)} ${String(n).padStart(6)} chunks · carga ${load.toFixed(1)} s · ${label.padEnd(10)} chunks en el plan ${String(chunksIn(p.Plan)).padStart(6)} · planificar ${p["Planning Time"].toFixed(0)} ms · ejecutar ${p["Execution Time"].toFixed(0)} ms`);
        } catch (e) {
          const err = e as { message: string; hint?: string };
          console.log(`chunk de ${interval.padEnd(8)} ${String(n).padStart(6)} chunks · ${label}: ERROR: ${err.message} · HINT: ${err.hint}`);
        }
      }
      try {
        await c.query(`DROP TABLE ${name}`);
      } catch (e) {
        // borrar la tabla también toma un candado por chunk; se borra por tandas con drop_chunks
        const err = e as { message: string; hint?: string };
        console.log(`chunk de ${interval.padEnd(8)} DROP TABLE: ERROR: ${err.message} · HINT: ${err.hint}`);
        for (let m = 0; m < 66; m += 3) {
          const cut = new Date(Date.UTC(2021, 9 + m, 1)).toISOString().slice(0, 10);
          await c.query(`SELECT drop_chunks('${name}', older_than => TIMESTAMP '${cut}')`);
        }
        await c.query(`DROP TABLE ${name}`);
        console.log(`chunk de ${interval.padEnd(8)} borrada por tandas de tres meses`);
      }
    }
  }
} finally {
  await c.end();
}
