// El dato que no cabe en memoria, del lado de Postgres: las mismas dos consultas de spill.py, con el
// work_mem de fábrica (4 MB) y con 1 GB, leyendo del plan los bloques temporales escritos y cómo ordenó
// o agrupó cada nodo.
//
//   node 08-analitico-romper-y-medir/spill.ts   (desde src/)
import pg from "pg";

interface Node { "Node Type": string; "Sort Method"?: string; "Sort Space Used"?: number; "Sort Space Type"?: string;
  "HashAgg Batches"?: number; "Disk Usage"?: number; "Temp Written Blocks"?: number; Plans?: Node[] }

const QUERIES: Record<string, string> = {
  "group-by-flight": "SELECT flight_id, avg(egt_c), max(ts) FROM reading_x10 GROUP BY flight_id",
  "order-by-egt": "SELECT aircraft, ts, egt_c FROM reading_x10 ORDER BY egt_c, ts",
};

const client = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "analitico" });
await client.connect();
try {
  for (const workMem of ["4MB", "1GB"]) {
    await client.query(`SET work_mem = '${workMem}'`);
    for (const [name, sql] of Object.entries(QUERIES)) {
      const { rows } = await client.query(`EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) ${sql}`);
      const top = rows[0]["QUERY PLAN"][0];
      const how: string[] = [];
      const walk = (n: Node) => {
        if (n["Sort Method"]) how.push(`${n["Node Type"]}: ${n["Sort Method"]} ${n["Sort Space Used"]} kB (${n["Sort Space Type"]})`);
        if (n["HashAgg Batches"] !== undefined) how.push(`${n["Node Type"]}: ${n["HashAgg Batches"]} lotes, disco ${n["Disk Usage"] ?? 0} kB`);
        n.Plans?.forEach(walk);
      };
      walk(top.Plan);
      const temp = top.Plan["Temp Written Blocks"] ?? 0;
      console.log(`work_mem ${workMem.padEnd(4)} · ${name.padEnd(16)} temporales escritos ${((temp * 8192) / 2 ** 20).toFixed(1).padStart(7)} MiB · ${(top["Execution Time"] / 1000).toFixed(1)} s`);
      for (const h of how) console.log(`    ${h}`);
    }
  }
} finally {
  await client.end();
}
