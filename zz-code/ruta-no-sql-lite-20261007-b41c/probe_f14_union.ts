// Sondeo F14: el mismo alcance con UNION en lugar de UNION ALL + CYCLE: cada (nodo, profundidad) una vez.
import pg from "pg";
const db = new pg.Client({ host: "localhost", port: 15432, user: "postgres", password: "condor", database: "postgres" });
await db.connect();
await db.query("SET statement_timeout = '300s'");
for (let depth = 1; depth <= 8; depth++) {
  const t = performance.now();
  const r = await db.query(`EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) WITH RECURSIVE t(node, depth) AS (SELECT 'part:SN-0391969', 0 UNION
    SELECT e.dst, t.depth + 1 FROM t JOIN stint_edge e ON e.src = t.node WHERE t.depth < ${depth})
    SELECT count(DISTINCT node) FROM t WHERE depth > 0`);
  const plan = r.rows[0]["QUERY PLAN"][0];
  let cte = 0; const walk = (n: any) => { if (n["Node Type"] === "Recursive Union") cte = Math.round(n["Actual Rows"] * n["Actual Loops"]); n.Plans?.forEach(walk); };
  walk(plan.Plan);
  const nodes = (await db.query(`WITH RECURSIVE t(node, depth) AS (SELECT 'part:SN-0391969', 0 UNION
    SELECT e.dst, t.depth + 1 FROM t JOIN stint_edge e ON e.src = t.node WHERE t.depth < ${depth}) SELECT count(DISTINCT node) n FROM t WHERE depth > 0`)).rows[0].n;
  console.log(`profundidad ${depth} · postgres UNION: ${nodes} nodos · filas del CTE ${cte} · páginas ${plan.Plan["Shared Hit Blocks"] + plan.Plan["Shared Read Blocks"]} · ${((performance.now() - t) / 1000).toFixed(1)}s`);
}
// el cierre: sin profundidad en la fila, UNION no vuelve a visitar un nodo y termina solo
const t = performance.now();
const c = (await db.query(`WITH RECURSIVE t(node) AS (SELECT 'part:SN-0391969' UNION SELECT e.dst FROM t JOIN stint_edge e ON e.src = t.node) SELECT count(*) n FROM t`)).rows[0].n;
console.log(`cierre completo, sin límite de profundidad: ${c} nodos · ${((performance.now() - t) / 1000).toFixed(1)}s`);
await db.end();
