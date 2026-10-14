// La misma prueba de visibility.ts del lado de Postgres: se da de alta una referencia en una conexión y se
// busca por texto desde otra, inmediatamente después del COMMIT.
//
//   node 12-busqueda-romper-y-medir/visibility-pg.ts   (desde src/, después de fts.sql)
import pg from "pg";

const cfg = { host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "busqueda_base" };
const writer = new pg.Client(cfg);
const reader = new pg.Client(cfg);
await writer.connect();
await reader.connect();
try {
  for (let t = 0; t < 5; t++) {
    const pn = `99-VISPG-${t}`;
    await writer.query("INSERT INTO part_catalog (part_number, description, category, ata_chapter) VALUES ($1, 'junta tórica recién llegada', 'consumable', 20)", [pn]);
    const { rows } = await reader.query("SELECT part_number FROM part_catalog WHERE description_tsv @@ plainto_tsquery('es_unaccent', 'junta torica recien llegada') AND part_number = $1", [pn]);
    console.log(`postgres · alta ${pn} · la siguiente búsqueda desde otra conexión la encontró: ${rows.length === 1}`);
    await writer.query("DELETE FROM part_catalog WHERE part_number = $1", [pn]);
  }
} finally {
  await writer.end();
  await reader.end();
}
