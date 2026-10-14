// Las cuatro facetas de la Fase 11 con el filtro de texto de Postgres bien montado (el GIN de fts.sql)
// en lugar del ILIKE: filas examinadas y viajes, contra la petición única de OpenSearch.
//
//   node 12-busqueda-romper-y-medir/facets-fts.ts   (desde src/)
import pg from "pg";
import { explain } from "../lab/harness/explain.ts";

const db = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "busqueda_base" });
await db.connect();
const where = "description_tsv @@ plainto_tsquery('es_unaccent', 'juntas toricas')";
const FACETS: Record<string, string> = {
  category: `SELECT category AS k, count(*) FROM part_catalog WHERE ${where} GROUP BY 1 ORDER BY 2 DESC LIMIT 5`,
  ataChapter: `SELECT ata_chapter AS k, count(*) FROM part_catalog WHERE ${where} GROUP BY 1 ORDER BY 2 DESC LIMIT 5`,
  model: `SELECT m AS k, count(*) FROM part_catalog, unnest(compatible_models) m WHERE ${where} GROUP BY 1 ORDER BY 2 DESC LIMIT 6`,
  supplier: `SELECT s AS k, count(*) FROM part_catalog, unnest(supplier_ids) s WHERE ${where} GROUP BY 1 ORDER BY 2 DESC LIMIT 3`,
  // las cuatro en una consulta, con GROUPING SETS sobre una sola lectura del filtro
  together: `WITH hit AS MATERIALIZED (SELECT * FROM part_catalog WHERE ${where})
    SELECT 'category' AS f, category AS k, count(*) FROM hit GROUP BY category
    UNION ALL SELECT 'ata', ata_chapter::text, count(*) FROM hit GROUP BY ata_chapter
    UNION ALL SELECT 'model', m, count(*) FROM hit, unnest(compatible_models) m GROUP BY m
    UNION ALL SELECT 'supplier', s, count(*) FROM hit, unnest(supplier_ids) s GROUP BY s`,
};
try {
  for (const [name, sql] of Object.entries(FACETS)) {
    const e = await explain(db, sql);
    console.log(`${name.padEnd(10)} examinadas ${String(e.examined).padStart(8)} · páginas ${String(e.sharedHit + e.sharedRead).padStart(6)} · ${[...new Set(e.access)].join(", ")}`);
  }
} finally {
  await db.end();
}
