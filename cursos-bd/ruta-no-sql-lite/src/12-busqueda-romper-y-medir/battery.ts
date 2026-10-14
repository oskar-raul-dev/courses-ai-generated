// La apuesta de la Fase 12: veinte búsquedas del almacén —diez de descripción, diez de número de parte—
// contra OpenSearch (índice part_catalog de la Fase 11) y contra el full-text de Postgres bien montado
// (fts.sql). La verdad sale del catálogo. Una búsqueda está "cubierta" si los diez primeros de Postgres
// traen tantos aciertos como los diez primeros de OpenSearch; la apuesta pide 18 de 20.
//
//   node 12-busqueda-romper-y-medir/battery.ts   (desde src/, después de 11-…/load.ts con el millón y fts.sql)
import { Client as OpenSearch } from "@opensearch-project/opensearch";
import pg from "pg";
import { explain } from "../lab/harness/explain.ts";

const os = new OpenSearch({ node: `http://localhost:${process.env.BUSQUEDA_PORT ?? 19200}` });
const db = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "busqueda_base" });
await db.connect();
const set = async (sql: string, params: unknown[] = []) => new Set((await db.query(sql, params)).rows.map((r) => r.part_number as string));

interface Case { typed: string; truth: Set<string>; os: object; pg: { sql: string; params: unknown[] } }
const cases: Case[] = [];

// diez de descripción: lo que escribe la gente, y la verdad en las descripciones exactas del catálogo
const DESCRIPTIONS: [string, string][] = [
  ["juntas toricas tren", "description = 'junta tórica del tren'"],
  ["oring del tren", "description = 'junta tórica del tren'"],
  ["neumaticos principales", "description IN ('neumático principal', 'llanta principal')"],
  ["filtros de aceite del motor", "description = 'filtro de aceite del motor'"],
  ["abrazaderas hidraulicas", "description = 'abrazadera hidráulico'"],
  ["empaques del tanque", "description IN ('empaque del tanque', 'sello del tanque')"],
  ["rodamientos de cabina", "description = 'rodamiento de cabina'"],
  ["bomba de combustible electrica", "description = 'bomba de combustible eléctrica'"],
  ["actuador flap", "description LIKE 'actuador de flap%'"],
  ["helice tripala", "description = 'hélice tripala'"],
];
const PG_TEXT = `WITH q AS (SELECT ts_rewrite(plainto_tsquery('es_unaccent', $1), 'SELECT target, substitute FROM warehouse_synonym') AS q)
  SELECT part_number FROM part_catalog, q WHERE description_tsv @@ q.q ORDER BY ts_rank(description_tsv, q.q) DESC, part_number LIMIT 10`;
for (const [typed, truth] of DESCRIPTIONS) {
  cases.push({
    typed, truth: await set(`SELECT part_number FROM part_catalog WHERE ${truth}`),
    os: { match: { description: { query: typed, operator: "and" } } },
    pg: { sql: PG_TEXT, params: [typed] },
  });
}

// diez de número: referencias con alterno, escritas de una forma distinta cada una
const { rows } = await db.query(`SELECT part_number, alternates, supplier_part_numbers FROM part_catalog
  WHERE cardinality(alternates) > 0 AND cardinality(supplier_part_numbers) > 0 ORDER BY md5(part_number) LIMIT 10`);
const PG_NUMBER = `WITH m AS (SELECT part_number, alternates FROM part_catalog
    WHERE pn_normalize(part_number) = pn_normalize($1) OR pn_normalize_all(supplier_part_numbers) @> ARRAY[pn_normalize($1)])
  SELECT part_number FROM m
  UNION SELECT unnest(alternates) FROM m
  UNION SELECT c.part_number FROM part_catalog c, m WHERE c.alternates @> ARRAY[m.part_number]
  ORDER BY 1 LIMIT 10`;
rows.forEach((r, i) => {
  const forms = [
    r.supplier_part_numbers[0],                                  // como lo escribe un proveedor
    r.part_number.replace(/[^0-9A-Za-z]/g, ""),                  // sin separadores
    r.part_number.replace(/-/g, " "),                            // con espacios
    r.alternates[0],                                             // el alterno, buscando el original
  ];
  const typed = forms[i % forms.length];
  cases.push({
    typed, truth: new Set(),
    os: { multi_match: { query: typed, fields: ["partNumber.normalized", "supplierPartNumbers", "alternates.normalized", "alternateOf.normalized"] } },
    pg: { sql: PG_NUMBER, params: [typed] },
  });
  // la verdad: la referencia buscada (la del alterno, en el último caso), sus alternos y las que la nombran
  const target = i % forms.length === 3 ? r.alternates[0] : r.part_number;
  cases[cases.length - 1].truth = new Set([target]);
});
for (const c of cases.slice(10)) {
  const [target] = [...c.truth];
  c.truth = await set(`SELECT part_number FROM part_catalog WHERE part_number = $1
    OR part_number IN (SELECT unnest(alternates) FROM part_catalog WHERE part_number = $1) OR $1 = ANY(alternates)`, [target]);
}

let covered = 0;
console.log("búsqueda                          verdad · OpenSearch top10 · Postgres top10 · Postgres examinadas · cubierta");
for (const c of cases) {
  const { body } = await os.search({ index: "part_catalog", body: { query: c.os, size: 10, _source: false } });
  const osTop: string[] = body.hits.hits.map((h: { _id: string }) => h._id);
  const pgTop = (await db.query(c.pg.sql, c.pg.params)).rows.map((r) => r.part_number as string);
  const e = await explain(db, c.pg.sql, c.pg.params);
  const hitsOs = osTop.filter((x) => c.truth.has(x)).length;
  const hitsPg = pgTop.filter((x) => c.truth.has(x)).length;
  const ok = hitsPg >= hitsOs;
  if (ok) covered++;
  console.log(`  ${c.typed.padEnd(32)} ${String(c.truth.size).padStart(6)} · ${String(hitsOs).padStart(2)}/10 · ${String(hitsPg).padStart(2)}/10 · ${String(e.examined).padStart(7)} · ${ok ? "sí" : "NO"}`);
}
console.log(`cubiertas por Postgres: ${covered} de ${cases.length}`);
await os.close();
await db.end();
