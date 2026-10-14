// La línea base de la apuesta de la Fase 10: Postgres con particionado declarativo por mes, sin
// extensiones, sobre las mismas 50 M lecturas de reading_x10 (base series_base). Una partición por mes
// de la ventana y una DEFAULT, que recoge lo que no tiene mes: las lecturas posteriores al 30/09/2026.
//
//   node 10-series-romper-y-medir/partition.ts   (desde src/, después de 09-…/load.ts)
import pg from "pg";

const c = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "series_base" });
await c.connect();
try {
  // CASCADE: scorecard.ts deja colgada de esta tabla la vista reading_part_daily_mv, y la recrea al correr
  await c.query("DROP TABLE IF EXISTS reading_part CASCADE");
  await c.query(`CREATE TABLE reading_part (LIKE reading_x10) PARTITION BY RANGE (ts)`);
  // una partición por mes, de octubre de 2021 a septiembre de 2026: 60 tablas escritas por un bucle,
  // que es exactamente el trabajo que Timescale hace solo al insertar
  for (let m = 0; m < 60; m++) {
    const from = new Date(Date.UTC(2021, 9 + m, 1)).toISOString().slice(0, 10);
    const to = new Date(Date.UTC(2021, 10 + m, 1)).toISOString().slice(0, 10);
    await c.query(`CREATE TABLE reading_part_${from.slice(0, 7).replace("-", "_")} PARTITION OF reading_part FOR VALUES FROM ('${from}') TO ('${to}')`);
  }
  await c.query("CREATE TABLE reading_part_default PARTITION OF reading_part DEFAULT");
  // el índice se declara una vez y Postgres lo crea en cada partición
  await c.query("CREATE INDEX ON reading_part (aircraft, ts)");
  const t = performance.now();
  await c.query("INSERT INTO reading_part SELECT * FROM reading_x10");
  await c.query("VACUUM ANALYZE reading_part");
  const { rows } = await c.query(`SELECT count(*) AS partitions, pg_size_pretty(sum(pg_total_relation_size(inhrelid))) AS size,
      (SELECT count(*) FROM reading_part_default) AS in_default
    FROM pg_inherits WHERE inhparent = 'reading_part'::regclass`);
  console.log(`reading_part: ${rows[0].partitions} particiones · ${rows[0].size} con índices · ${rows[0].in_default} lecturas en DEFAULT · cargada en ${((performance.now() - t) / 1000).toFixed(1)} s`);
} finally {
  await c.end();
}
