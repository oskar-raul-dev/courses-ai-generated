// Las búsquedas de Sandra, tal como las escribe, contra el catálogo de un millón: en OpenSearch con los
// analizadores de catalog-index.json y en Postgres con LIKE/ILIKE. Para cada una, la verdad sale del
// propio catálogo (la descripción exacta, las grafías de proveedor y los alternos), y se mide qué parte
// de esa verdad encuentra cada uno, cuántas filas examina Postgres y cuántos documentos devuelve OpenSearch.
//
//   node 11-busqueda-levantar-y-modelar/search.ts   (desde src/, después de load.ts --dataset …-1m)
import { Client as OpenSearch } from "@opensearch-project/opensearch";
import pg from "pg";
import { explain } from "../lab/harness/explain.ts";

const os = new OpenSearch({ node: `http://localhost:${process.env.BUSQUEDA_PORT ?? 19200}` });
const db = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "busqueda_base" });
await db.connect();
const ids = async (sql: string, params: unknown[] = []) => new Set((await db.query(sql, params)).rows.map((r) => r.part_number as string));

/** Todos los documentos que OpenSearch devuelve para la consulta, en orden de relevancia. */
const osSearch = async (query: object, size = 10000): Promise<{ total: number; hits: string[] }> => {
  const { body } = await os.search({ index: "part_catalog", body: { query, size, _source: false, track_total_hits: true } });
  return { total: body.hits.total.value, hits: body.hits.hits.map((h: { _id: string }) => h._id) };
};
const recall = (found: Iterable<string>, truth: Set<string>) => [...found].filter((x) => truth.has(x)).length;
/** Cuántos de la verdad devuelve OpenSearch, contados por el motor y no limitados a una página. */
const osRecall = async (query: object, truth: Set<string>): Promise<number> => {
  const { body } = await os.count({ index: "part_catalog", body: { query: { bool: { must: [query], filter: [{ ids: { values: [...truth] } }] } } } });
  return body.count;
};

try {
  // el número de parte de prueba: el primero que tiene alterno y una grafía de proveedor con barra
  const { rows } = await db.query(`SELECT part_number, alternates, supplier_part_numbers FROM part_catalog
    WHERE cardinality(alternates) > 0 AND EXISTS (SELECT 1 FROM unnest(supplier_part_numbers) s WHERE s LIKE '%/%')
    ORDER BY part_number LIMIT 1`);
  const pn: string = rows[0].part_number;
  const slash: string = rows[0].supplier_part_numbers.find((s: string) => s.includes("/"));
  const bare = pn.replace(/[^0-9A-Za-z]/g, "");
  // la verdad de un número: la entrada, sus alternos y las que lo tienen de alterno
  const pnTruth = await ids(`SELECT part_number FROM part_catalog WHERE part_number = $1 OR part_number = ANY($2) OR $1 = ANY(alternates)`, [pn, rows[0].alternates]);

  const pnQuery = (text: string) => ({ multi_match: { query: text, fields: ["partNumber.normalized", "supplierPartNumbers", "alternates.normalized", "alternateOf.normalized"] } });
  const CASES: { label: string; typed: string; truth: Set<string>; os: object; likes: [string, unknown[]][] }[] = [
    {
      label: "descripción con plural y sin tildes", typed: "juntas toricas tren",
      truth: await ids("SELECT part_number FROM part_catalog WHERE description = 'junta tórica del tren'"),
      os: { match: { description: { query: "juntas toricas tren", operator: "and" } } },
      likes: [["description LIKE '%juntas toricas tren%'", []], ["description ILIKE '%junta%'", []]],
    },
    {
      label: "jerga de taller", typed: "oring del tren",
      truth: await ids("SELECT part_number FROM part_catalog WHERE description = 'junta tórica del tren'"),
      os: { match: { description: { query: "oring del tren", operator: "and" } } },
      likes: [["description ILIKE '%oring%'", []]],
    },
    {
      label: "número con barra, como lo escribe un proveedor", typed: slash, truth: pnTruth, os: pnQuery(slash),
      likes: [["part_number = $1", [slash]], ["$1 = ANY(supplier_part_numbers)", [slash]]],
    },
    {
      label: "número sin separadores", typed: bare, truth: pnTruth, os: pnQuery(bare),
      likes: [["part_number = $1", [bare]], ["replace(part_number, '-', '') = $1", [bare]],
        // lo mejor que hace SQL: normalizar, y buscar también los alternos de lo encontrado
        ["part_number IN (SELECT p FROM part_catalog c, unnest(c.part_number || c.alternates) p WHERE replace(c.part_number, '-', '') = $1)", [bare]]],
    },
  ];
  console.log(`número de prueba ${pn} · alternos ${rows[0].alternates.join(", ")} · verdad del número: ${pnTruth.size} entradas`);
  for (const c of CASES) {
    const r = await osSearch(c.os);
    console.log(`\n«${c.typed}» — ${c.label} · verdad: ${c.truth.size}`);
    console.log(`  opensearch                           devueltos ${String(r.total).padStart(6)} · de la verdad ${await osRecall(c.os, c.truth)} · en los 10 primeros ${recall(r.hits.slice(0, 10), c.truth)}`);
    for (const [where, params] of c.likes) {
      const sql = `SELECT part_number FROM part_catalog WHERE ${where}`;
      const e = await explain(db, sql, params);
      const found = await ids(sql, params);
      console.log(`  postgres ${where.padEnd(40)} examinadas ${String(e.examined).padStart(7)} · devueltas ${String(e.returned).padStart(6)} · de la verdad ${recall(found, c.truth)}`);
    }
  }
} finally {
  await os.close();
  await db.end();
}
