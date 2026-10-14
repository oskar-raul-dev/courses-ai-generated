// La carga de la apuesta, lado Postgres, bien jugado: las mismas 50 M lecturas en dos tablas particionadas.
// reading_part, por mes (la de la Fase 10) con un índice para la consulta 1 y uno parcial para la 3; y
// reading_part_flight, una segunda copia partida por hash del vuelo para la consulta 2, que es la misma idea
// de Cassandra —duplicar para tener otra forma de partir— dentro de Postgres. Mide los bytes que el
// contenedor escribió de verdad (WAL, tablas, índices, VACUUM y el checkpoint final).
//
// Con --tuned, la carga corre con Postgres configurado para ingesta (max_wal_size 16 GB y WAL comprimido):
// con el max_wal_size de 1 GB por defecto, el checkpoint llega cada pocos segundos de carga y cada página
// tocada después vuelve a escribirse entera en el WAL. La configuración se devuelve a la de siempre al final.
//
//   node 18-columnar-romper-y-medir/baseline.ts [--tuned]   (desde src/, con base arriba y reading_x10 cargada)
import { parseArgs } from "node:util";
import pg from "pg";
import { containerWrites, MiB, recordWrites } from "../lab/harness/io.ts";

const { values: args } = parseArgs({ options: { tuned: { type: "boolean", default: false } } });
const c = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "series_base" });
await c.connect();
try {
  // CASCADE: la vista reading_part_daily_mv de la Fase 10 cuelga de reading_part
  await c.query("DROP TABLE IF EXISTS reading_part CASCADE");
  await c.query("DROP TABLE IF EXISTS reading_part_flight");
  await c.query("CHECKPOINT");
  if (args.tuned) {
    await c.query("ALTER SYSTEM SET max_wal_size = '16GB'");
    await c.query("ALTER SYSTEM SET wal_compression = 'lz4'");
    await c.query("SELECT pg_reload_conf()");
  }

  await c.query("CREATE TABLE reading_part (LIKE reading_x10) PARTITION BY RANGE (ts)");
  for (let m = 0; m < 60; m++) {
    const from = new Date(Date.UTC(2021, 9 + m, 1)).toISOString().slice(0, 10);
    const to = new Date(Date.UTC(2021, 10 + m, 1)).toISOString().slice(0, 10);
    await c.query(`CREATE TABLE reading_part_${from.slice(0, 7).replace("-", "_")} PARTITION OF reading_part FOR VALUES FROM ('${from}') TO ('${to}')`);
  }
  await c.query("CREATE TABLE reading_part_default PARTITION OF reading_part DEFAULT");
  await c.query("CREATE INDEX ON reading_part (aircraft, ts)"); // consulta 1
  await c.query("CREATE INDEX ON reading_part (ts) WHERE egt_c >= 720"); // consulta 3

  // la segunda copia: 16 particiones por hash del vuelo, porque un vuelo no dice en qué mes cae
  await c.query("CREATE TABLE reading_part_flight (LIKE reading_x10) PARTITION BY HASH (flight_id)");
  for (let i = 0; i < 16; i++) await c.query(`CREATE TABLE reading_part_flight_${i} PARTITION OF reading_part_flight FOR VALUES WITH (MODULUS 16, REMAINDER ${i})`);
  await c.query("CREATE INDEX ON reading_part_flight (flight_id, ts)"); // consulta 2

  // los índices existen antes de cargar, como en una ingesta continua: cada fila los mantiene al llegar
  const w0 = containerWrites("base");
  // y lo que el propio Postgres dice que escribió, por tipo: WAL, WAL de segmentos nuevos y páginas de tablas
  await c.query("SELECT pg_stat_reset_shared('io')");
  const { rows: [{ lsn: lsn0 }] } = await c.query("SELECT pg_current_wal_lsn() AS lsn");
  const t = performance.now();
  await c.query("INSERT INTO reading_part SELECT * FROM reading_x10");
  await c.query("INSERT INTO reading_part_flight SELECT * FROM reading_x10");
  // VACUUM deja escritos el mapa de visibilidad y los hint bits; el checkpoint, las páginas sucias
  await c.query("VACUUM ANALYZE reading_part");
  await c.query("VACUUM ANALYZE reading_part_flight");
  await c.query("CHECKPOINT");
  const secs = (performance.now() - t) / 1000;
  const { rows: [{ wal }] } = await c.query("SELECT pg_wal_lsn_diff(pg_current_wal_lsn(), $1) AS wal", [lsn0]);
  const written = containerWrites("base") - w0;
  const { rows: io } = await c.query(`SELECT CASE WHEN object = 'wal' AND context = 'init' THEN 'segmentos de WAL nuevos (ceros)'
      WHEN object = 'wal' THEN 'WAL' WHEN context = 'vacuum' THEN 'páginas escritas por VACUUM' ELSE 'páginas de tablas e índices' END AS kind,
      sum(write_bytes) AS bytes FROM pg_stat_io WHERE write_bytes > 0 GROUP BY 1 ORDER BY 2 DESC`);
  const { rows: [{ live }] } = await c.query(`SELECT sum(pg_total_relation_size(inhrelid)) AS live FROM pg_inherits
    WHERE inhparent IN ('reading_part'::regclass, 'reading_part_flight'::regclass)`);

  console.log(`postgres${args.tuned ? " (max_wal_size 16GB, wal_compression lz4)" : ""}: 100000000 filas en 2 tablas (61 + 16 particiones, 3 índices) · cargadas en ${secs.toFixed(0)} s`);
  console.log(`  escrito al disco ${MiB(written).toFixed(0)} MiB · de eso, WAL ${MiB(Number(wal)).toFixed(0)} MiB · en disco al final ${MiB(Number(live)).toFixed(0)} MiB`);
  for (const r of io) console.log(`    ${r.kind.padEnd(32)} ${MiB(Number(r.bytes)).toFixed(0).padStart(7)} MiB`);
  console.log(`  amplificación: ${(written / Number(live)).toFixed(2)} bytes escritos por byte que queda`);
  recordWrites(args.tuned ? "postgres-tuned" : "postgres", { rows: 100_000_000, writtenBytes: written, walBytes: Number(wal), liveBytes: Number(live), seconds: secs });
} finally {
  if (args.tuned) {
    await c.query("ALTER SYSTEM RESET max_wal_size");
    await c.query("ALTER SYSTEM RESET wal_compression");
    await c.query("SELECT pg_reload_conf()");
  }
  await c.end();
}
