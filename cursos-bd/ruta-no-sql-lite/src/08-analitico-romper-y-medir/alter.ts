// La apuesta de la Fase 08, del lado de Postgres: lo que cuesta añadir una métrica nueva
// (el margen de EGT, 765 − egt_c) a la tabla ancha de 50 M lecturas, de cuatro formas. Cada forma
// empieza de una copia limpia de reading_x10 y se mide en bytes de WAL escritos y en el tamaño de la
// tabla antes y después; el tiempo va como contexto.
//
//   node 08-analitico-romper-y-medir/alter.ts [--only constant|update|stored|virtual]   (desde src/)
import { parseArgs } from "node:util";
import pg from "pg";

const { values: args } = parseArgs({ options: { only: { type: "string" } } });

const FORMS: Record<string, string[]> = {
  // un valor constante: desde Postgres 11, solo se anota en el catálogo
  constant: ["ALTER TABLE reading_alter ADD COLUMN egt_margin_c integer DEFAULT 0"],
  // la métrica calculada para cada fila: la columna y después el UPDATE de los 50 M
  update: ["ALTER TABLE reading_alter ADD COLUMN egt_margin_c integer", "UPDATE reading_alter SET egt_margin_c = 765 - egt_c"],
  // columna generada que se guarda: Postgres reescribe la tabla
  stored: ["ALTER TABLE reading_alter ADD COLUMN egt_margin_c integer GENERATED ALWAYS AS (765 - egt_c) STORED"],
  // columna generada virtual (Postgres 18): se calcula al leer
  virtual: ["ALTER TABLE reading_alter ADD COLUMN egt_margin_c integer GENERATED ALWAYS AS (765 - egt_c) VIRTUAL"],
};

const client = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "analitico" });
await client.connect();
const one = async (sql: string) => (await client.query(sql)).rows[0];
const mib = (bytes: number) => (bytes / 2 ** 20).toFixed(1).padStart(8);
try {
  const { version } = await one("SELECT current_setting('server_version') AS version");
  console.log(`PostgreSQL ${version} · copia de reading_x10 por forma`);
  for (const [name, statements] of Object.entries(FORMS)) {
    if (args.only && args.only !== name) continue;
    await client.query("DROP TABLE IF EXISTS reading_alter");
    await client.query("CREATE TABLE reading_alter AS SELECT * FROM reading_x10");
    await client.query("VACUUM ANALYZE reading_alter");
    await client.query("CHECKPOINT");
    const before = await one("SELECT pg_relation_size('reading_alter') AS size, pg_current_wal_insert_lsn() AS lsn");
    const started = performance.now();
    for (const sql of statements) await client.query(sql);
    const seconds = (performance.now() - started) / 1000;
    const after = await one(`SELECT pg_relation_size('reading_alter') AS size,
      pg_wal_lsn_diff(pg_current_wal_insert_lsn(), '${before.lsn}') AS wal`);
    console.log(`  ${name.padEnd(9)} WAL ${mib(Number(after.wal))} MiB · tabla ${mib(Number(before.size))} → ${mib(Number(after.size))} MiB · ${seconds.toFixed(1)} s`);
  }
  await client.query("DROP TABLE IF EXISTS reading_alter");
} finally {
  await client.end();
}
