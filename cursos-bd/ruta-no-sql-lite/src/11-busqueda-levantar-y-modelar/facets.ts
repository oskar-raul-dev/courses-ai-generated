// Las facetas de la pantalla de Sandra: buscar "juntas toricas" y ver, al lado, cuántas hay por
// categoría, por capítulo ATA, por modelo compatible y por proveedor. En OpenSearch, una petición con
// cuatro agregaciones; en Postgres, lo mismo con GROUP BY, y las filas que examina cada forma.
//
//   node 11-busqueda-levantar-y-modelar/facets.ts   (desde src/)
import { Client as OpenSearch } from "@opensearch-project/opensearch";
import pg from "pg";
import { explain } from "../lab/harness/explain.ts";
import { countRoundTrips } from "../lab/harness/roundtrips.ts";

const os = new OpenSearch({ node: `http://localhost:${process.env.BUSQUEDA_PORT ?? 19200}` });
const db = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "busqueda_base" });
await db.connect();
const osTrips = countRoundTrips(os, "search");

try {
  const { body } = await os.search({
    index: "part_catalog",
    body: {
      size: 0,
      track_total_hits: true,
      query: { match: { description: { query: "juntas toricas", operator: "and" } } },
      aggs: {
        category: { terms: { field: "category", size: 5 } },
        ataChapter: { terms: { field: "ataChapter", size: 5 } },
        model: { terms: { field: "compatibleModels", size: 6 } },
        supplier: { terms: { field: "supplierIds", size: 3 } },
        // la misma faceta pidiendo más candidatos por fragmento antes de cortar en 3
        supplierExact: { terms: { field: "supplierIds", size: 3, shard_size: 100 } },
      },
    },
  });
  console.log(`opensearch · ${osTrips.count} viaje · ${body.hits.total.value} coincidencias`);
  for (const [name, agg] of Object.entries(body.aggregations as Record<string, { buckets: { key: string; doc_count: number }[]; doc_count_error_upper_bound: number }>)) {
    console.log(`  ${name.padEnd(13)} ${agg.buckets.map((b) => `${b.key}: ${b.doc_count}`).join(" · ")} · error máximo ${agg.doc_count_error_upper_bound}`);
  }

  // Postgres: el filtro de texto que tiene a mano (ILIKE con la frase exacta) y una consulta por faceta
  const where = "description ILIKE '%junta tórica%'";
  const FACETS: Record<string, string> = {
    category: `SELECT category AS k, count(*) FROM part_catalog WHERE ${where} GROUP BY 1 ORDER BY 2 DESC LIMIT 5`,
    ataChapter: `SELECT ata_chapter AS k, count(*) FROM part_catalog WHERE ${where} GROUP BY 1 ORDER BY 2 DESC LIMIT 5`,
    model: `SELECT m AS k, count(*) FROM part_catalog, unnest(compatible_models) m WHERE ${where} GROUP BY 1 ORDER BY 2 DESC LIMIT 6`,
    supplier: `SELECT s AS k, count(*) FROM part_catalog, unnest(supplier_ids) s WHERE ${where} GROUP BY 1 ORDER BY 2 DESC LIMIT 3`,
  };
  let examined = 0;
  const lines: string[] = [];
  for (const [name, sql] of Object.entries(FACETS)) {
    const e = await explain(db, sql);
    examined += e.examined;
    const { rows } = await db.query(sql);
    lines.push(`  ${name.padEnd(13)} ${rows.map((r) => `${r.k}: ${r.count}`).join(" · ")}`);
  }
  // los viajes de las cuatro consultas, sin contar los EXPLAIN del arnés
  console.log(`postgres · ${Object.keys(FACETS).length} viajes · filas examinadas en total ${examined}`);
  for (const l of lines) console.log(l);
} finally {
  await os.close();
  await db.end();
}
