// El punto de rotura de la familia: la consulta sin límite de profundidad sobre un grafo con ciclos.
// En Neo4j, pedir los CAMINOS (no los nodos) de cualquier largo desde una pieza; en Postgres, el
// WITH RECURSIVE con UNION ALL y sin CYCLE. Los dos con un tope de tiempo, porque ninguno termina solo.
//
//   node 14-grafos-romper-y-medir/unbounded.ts [--timeout 120]   (desde src/, después de edges.sql)
import { parseArgs } from "node:util";
import neo4j from "neo4j-driver";
import pg from "pg";

const { values: args } = parseArgs({ options: { timeout: { type: "string", default: "120" } } });
const SECONDS = Number(args.timeout);
const driver = neo4j.driver(`bolt://localhost:${process.env.GRAFOS_BOLT_PORT ?? 17687}`, neo4j.auth.basic("neo4j", "condor-mro"));
const session = driver.session();
const db = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "postgres" });
await db.connect();
await db.query(`SET statement_timeout = '${SECONDS}s'`);

const SERIAL = "SN-0391969";
try {
  // el mismo alcance, pidiendo nodos: termina (DISTINCT deja podar)
  let t = performance.now();
  const ok = await session.run("MATCH (p:Part {serialNumber: $s})-[:INSTALLED*]-(x) RETURN count(DISTINCT x) AS n", { s: SERIAL });
  console.log(`neo4j    · nodos alcanzables, sin límite: ${ok.records[0].get("n").toNumber()} · ${((performance.now() - t) / 1000).toFixed(1)} s`);
  // pidiendo caminos: no hay poda posible
  t = performance.now();
  try {
    const r = await session.run("MATCH p = (s:Part {serialNumber: $s})-[:INSTALLED*]-(x) RETURN count(p) AS n", { s: SERIAL }, { timeout: SECONDS * 1000 });
    console.log(`neo4j    · caminos: ${r.records[0].get("n").toNumber()}`);
  } catch (e) {
    console.log(`neo4j    · caminos, a los ${((performance.now() - t) / 1000).toFixed(1)} s: ${(e as { code?: string }).code} · ${(e as Error).message.split("\n").slice(0, 2).join(" ")}`);
  }

  t = performance.now();
  const closure = await db.query(`WITH RECURSIVE t(node) AS (SELECT 'part:${SERIAL}' UNION SELECT e.dst FROM t JOIN stint_edge e ON e.src = t.node) SELECT count(*) AS n FROM t`);
  console.log(`postgres · cierre con UNION, sin límite: ${closure.rows[0].n} nodos · ${((performance.now() - t) / 1000).toFixed(1)} s`);
  t = performance.now();
  try {
    await db.query(`WITH RECURSIVE t(node) AS (SELECT 'part:${SERIAL}' UNION ALL SELECT e.dst FROM t JOIN stint_edge e ON e.src = t.node) SELECT count(*) FROM t`);
  } catch (e) {
    console.log(`postgres · UNION ALL sin CYCLE, a los ${((performance.now() - t) / 1000).toFixed(1)} s: ${(e as { code?: string }).code} · ${(e as Error).message}`);
  }
} finally {
  await session.close();
  await driver.close();
  await db.end();
}
