// Sondeo F14: alcance por profundidad desde SN-0391969, en Neo4j y en Postgres (dos formas de CTE).
import neo4j from "neo4j-driver";
import pg from "pg";
const d = neo4j.driver("bolt://localhost:17687", neo4j.auth.basic("neo4j", "condor-mro"));
const s = d.session();
const db = new pg.Client({ host: "localhost", port: 15432, user: "postgres", password: "condor", database: "postgres" });
await db.connect();
await db.query(`CREATE TABLE IF NOT EXISTS stint_edge AS SELECT DISTINCT 'part:'||serial_number src, 'aircraft:'||aircraft dst FROM part_stint
  UNION SELECT DISTINCT 'aircraft:'||aircraft, 'part:'||serial_number FROM part_stint`);
await db.query("CREATE INDEX IF NOT EXISTS stint_edge_src ON stint_edge (src)"); await db.query("ANALYZE stint_edge");
for (let depth = 1; depth <= 6; depth++) {
  const t0 = performance.now();
  let g;
  try {
    const r = await s.run(`PROFILE MATCH (p:Part {serialNumber: 'SN-0391969'})-[:INSTALLED*1..${depth}]-(x) RETURN count(DISTINCT x) AS n`);
    let hits = 0; const ops: string[] = [];
    const walk = (pl: any) => { hits += Number(pl.dbHits); ops.push(pl.operatorType.split("@")[0]); pl.children.forEach(walk); };
    walk(r.summary.profile);
    g = `${r.records[0].get("n").toNumber()} nodos · ${hits} db hits · ${ops.join(">")} · ${((performance.now() - t0) / 1000).toFixed(1)}s`;
  } catch (e) { g = `ERR ${(e as Error).message.slice(0, 120)}`; }
  const t1 = performance.now();
  let p;
  try {
    await db.query("SET statement_timeout = '120s'");
    const r = await db.query(`EXPLAIN (ANALYZE, FORMAT JSON) WITH RECURSIVE t(node, depth) AS (SELECT 'part:SN-0391969', 0 UNION ALL
      SELECT e.dst, t.depth + 1 FROM t JOIN stint_edge e ON e.src = t.node WHERE t.depth < ${depth}) CYCLE node SET is_cycle USING path
      SELECT count(DISTINCT node) FROM t WHERE depth > 0`);
    const plan = r.rows[0]["QUERY PLAN"][0];
    // filas del CTE: el nodo Recursive Union
    let cte = 0; const walk = (n: any) => { if (n["Node Type"] === "Recursive Union") cte = Math.round(n["Actual Rows"] * n["Actual Loops"]); n.Plans?.forEach(walk); };
    walk(plan.Plan);
    p = `filas del CTE ${cte} · ${((performance.now() - t1) / 1000).toFixed(1)}s`;
  } catch (e) { p = `ERR ${(e as Error).message.slice(0, 80)}`; }
  const t2 = performance.now();
  let u;
  try {
    // cierre sin profundidad en la fila: UNION descarta nodos ya vistos, pero la profundidad no se puede limitar así
    u = "—";
  } catch { u = "—"; }
  console.log(`profundidad ${depth} · neo4j: ${g}\n              postgres CYCLE: ${p}`);
}
await s.close(); await d.close(); await db.end();
