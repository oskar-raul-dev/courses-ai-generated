// La situación 3 de la familia: el grafo modelado como tablas. Al lado del grafo de load.ts, el mismo
// dato con un solo label (:Node, con un campo "type") y una sola relación (:REL) sin propiedades: como
// una tabla de nodos y una de aristas. Se mide la directiva con fechas en los dos modelos, y el aviso de
// Cypher por un producto cartesiano.
//
//   node 13-grafos-levantar-y-modelar/generic.ts [--dataset lab/data/workOrder-1m]   (desde src/, después de load.ts)
import { join, resolve } from "node:path";
import { readFileSync } from "node:fs";
import { parseArgs } from "node:util";
import neo4j from "neo4j-driver";
import { profile } from "../lab/harness/neo4j-profile.ts";

const { values: args } = parseArgs({ options: { dataset: { type: "string", default: "lab/data/workOrder-1m" } } });
const LOT = JSON.parse(readFileSync(join(resolve(args.dataset!), "answers.json"), "utf8")).directiveLot.lotNumber;
const driver = neo4j.driver(`bolt://localhost:${process.env.GRAFOS_BOLT_PORT ?? 17687}`, neo4j.auth.basic("neo4j", "condor-mro"));
const session = driver.session();
const n = (r: { records: { get(k: string): { toNumber(): number } }[] }) => r.records[0].get("n").toNumber();
// en tandas que cierran su transacción, primero las relaciones: de una vez agota la memoria de
// transacciones de Neo4j con el heap del laboratorio (E-53)
const dropGeneric = async () => {
  for (const q of ["MATCH (:Node)-[r:REL]->() WITH r LIMIT 5000 DELETE r RETURN count(*) AS n", "MATCH (x:Node) WITH x LIMIT 5000 DELETE x RETURN count(*) AS n"]) {
    for (let deleted = 1; deleted > 0;) deleted = n(await session.run(q));
  }
};

try {
  // el modelo genérico, construido desde el bueno: nodos sin label propio y aristas sin fechas
  await dropGeneric();
  await session.run("CREATE INDEX node_key IF NOT EXISTS FOR (n:Node) ON (n.key)");
  await session.run(`MATCH (p:Part) CALL (p) { CREATE (:Node {type: 'Part', key: p.serialNumber, lot: p.lotNumber}) } IN TRANSACTIONS OF 10000 ROWS`);
  await session.run(`MATCH (a:Aircraft) CALL (a) { CREATE (:Node {type: 'Aircraft', key: a.registration}) } IN TRANSACTIONS OF 10000 ROWS`);
  await session.run(`MATCH (p:Part)-[:INSTALLED]->(a:Aircraft) CALL (p, a) {
      MATCH (x:Node {key: p.serialNumber}), (y:Node {key: a.registration}) MERGE (x)-[:REL]->(y) } IN TRANSACTIONS OF 10000 ROWS`);
  const nodes = n(await session.run("MATCH (x:Node) RETURN count(x) AS n"));
  const rels = n(await session.run("MATCH (:Node)-[r:REL]->() RETURN count(r) AS n"));
  console.log(`modelo genérico: ${nodes} nodos :Node · ${rels} relaciones :REL sin propiedades`);

  // la directiva con fechas: ¿en qué aeronaves estuvo una pieza del lote durante 2024?
  const typed = await profile(session, `MATCH (p:Part {lotNumber: $lot})-[s:INSTALLED]->(a:Aircraft)
    WHERE coalesce(s.from, datetime('2000-01-01')) < datetime('2025-01-01') AND coalesce(s.to, datetime('2100-01-01')) >= datetime('2024-01-01')
    RETURN count(DISTINCT a) AS n`, { lot: LOT });
  const generic = await profile(session, `MATCH (p:Node {type: 'Part', lot: $lot})-[:REL]->(a:Node {type: 'Aircraft'})
    RETURN count(DISTINCT a) AS n`, { lot: LOT });
  const all = await profile(session, "MATCH (p:Part {lotNumber: $lot})-[:INSTALLED]->(a:Aircraft) RETURN count(DISTINCT a) AS n", { lot: LOT });
  const r = (x: { records: unknown[] }) => (x.records[0] as { n: { toNumber(): number } }).n.toNumber();
  console.log(`durante 2024, con estadías fechadas: ${r(typed)} aeronaves · db hits ${typed.dbHits} · ${[...new Set(typed.operators)].join(" ")}`);
  console.log(`modelo genérico (no hay fechas que filtrar): ${r(generic)} aeronaves · db hits ${generic.dbHits} · ${[...new Set(generic.operators)].join(" ")}`);
  console.log(`  (en todo el período, con el modelo bueno: ${r(all)})`);

  // el producto cartesiano: dos patrones sin conexión en el mismo MATCH
  const cart = await session.run("EXPLAIN MATCH (p:Part {lotNumber: $lot}), (a:Aircraft) RETURN count(*) AS n", { lot: LOT });
  for (const note of cart.summary.notifications) console.log(`aviso: ${note.code} · ${note.title} · ${note.description}`);
  const cartRun = await profile(session, "MATCH (p:Part {lotNumber: $lot}), (a:Aircraft) RETURN count(*) AS n", { lot: LOT });
  console.log(`  ejecutado: ${(cartRun.records[0] as { n: { toNumber(): number } }).n.toNumber()} filas · db hits ${cartRun.dbHits}`);
  // el modelo genérico se va: el grafo del curso queda como lo dejó load.ts
  await dropGeneric();
  await session.run("DROP INDEX node_key IF EXISTS");
} finally {
  await session.close();
  await driver.close();
}
