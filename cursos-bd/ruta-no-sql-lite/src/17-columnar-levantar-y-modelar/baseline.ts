// La línea base de la Fase 17, bien jugada: Postgres con particionado declarativo por mes (el de la
// Fase 10) sobre las 5 M lecturas de reading-5m, con un índice por consulta. Las 50 M ampliadas viven en
// reading_part, que crea 10-…/partition.ts.
//
//   node 17-columnar-levantar-y-modelar/baseline.ts   (desde src/, después de 09-…/load.ts)
import pg from "pg";

const c = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "series_base" });
await c.connect();
try {
  await c.query("DROP TABLE IF EXISTS reading_part5");
  await c.query("CREATE TABLE reading_part5 (LIKE reading) PARTITION BY RANGE (ts)");
  for (let m = 0; m < 60; m++) {
    const from = new Date(Date.UTC(2021, 9 + m, 1)).toISOString().slice(0, 10);
    const to = new Date(Date.UTC(2021, 10 + m, 1)).toISOString().slice(0, 10);
    await c.query(`CREATE TABLE reading_part5_${from.slice(0, 7).replace("-", "_")} PARTITION OF reading_part5 FOR VALUES FROM ('${from}') TO ('${to}')`);
  }
  await c.query("CREATE TABLE reading_part5_default PARTITION OF reading_part5 DEFAULT");
  // un índice por consulta, como en Cassandra hay una tabla por consulta
  await c.query("CREATE INDEX ON reading_part5 (aircraft, ts)"); // consulta 1
  await c.query("CREATE INDEX ON reading_part5 (flight_id, ts)"); // consulta 2
  await c.query("CREATE INDEX ON reading_part5 (ts) WHERE egt_c >= 720"); // consulta 3: índice parcial
  const t = performance.now();
  await c.query("INSERT INTO reading_part5 SELECT * FROM reading");
  await c.query("VACUUM ANALYZE reading_part5");
  const { rows } = await c.query(`SELECT count(*) AS partitions,
      pg_size_pretty(sum(pg_table_size(inhrelid))) AS heap, pg_size_pretty(sum(pg_indexes_size(inhrelid))) AS indexes
    FROM pg_inherits WHERE inhparent = 'reading_part5'::regclass`);
  console.log(`reading_part5: ${rows[0].partitions} particiones · tabla ${rows[0].heap} · índices ${rows[0].indexes} · cargada en ${((performance.now() - t) / 1000).toFixed(1)} s`);
} finally {
  await c.end();
}
