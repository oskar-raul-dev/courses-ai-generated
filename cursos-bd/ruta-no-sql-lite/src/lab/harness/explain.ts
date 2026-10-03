// Filas examinadas contra devueltas en Postgres, leídas del plan real. El cociente es la
// métrica, no el total (guía de estilo §6).
import type pg from "pg";

export interface PlanNode {
  "Node Type": string;
  "Relation Name"?: string;
  "Index Name"?: string;
  "Actual Rows": number;
  "Actual Loops": number;
  "Rows Removed by Filter"?: number;
  "Rows Removed by Index Recheck"?: number;
  "Shared Hit Blocks"?: number;
  "Shared Read Blocks"?: number;
  Plans?: PlanNode[];
}

export interface ExplainResult {
  /** Filas que leyeron los nodos de acceso a tablas e índices, incluidas las que descartó el filtro. */
  examined: number;
  /** Filas que devolvió la consulta. */
  returned: number;
  /** Bloques de 8 kB leídos de la caché compartida (hit) o de disco (read). */
  sharedHit: number;
  sharedRead: number;
  /** Cómo accedió a cada tabla: "Index Scan on work_order", "Seq Scan on part"… */
  access: string[];
  plan: PlanNode;
}

const SCAN = /Scan$/;

export async function explain(client: pg.Client, sql: string, params: unknown[] = []): Promise<ExplainResult> {
  const { rows } = await client.query(`EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) ${sql}`, params);
  const plan = rows[0]["QUERY PLAN"][0].Plan as PlanNode;
  let examined = 0;
  const access: string[] = [];
  const walk = (node: PlanNode) => {
    // un nodo de acceso examina lo que devuelve más lo que su filtro descartó, en cada vuelta
    if (SCAN.test(node["Node Type"]) && node["Node Type"] !== "Bitmap Index Scan") {
      const perLoop = node["Actual Rows"] + (node["Rows Removed by Filter"] ?? 0) + (node["Rows Removed by Index Recheck"] ?? 0);
      // Postgres 18 da "Actual Rows" como promedio por vuelta, con decimales: se redondea el total
      examined += Math.round(perLoop * node["Actual Loops"]);
      access.push(`${node["Node Type"]} on ${node["Relation Name"]}${node["Index Name"] ? ` using ${node["Index Name"]}` : ""}`);
    }
    node.Plans?.forEach(walk);
  };
  walk(plan);
  return {
    examined,
    returned: Math.round(plan["Actual Rows"] * plan["Actual Loops"]),
    sharedHit: plan["Shared Hit Blocks"] ?? 0,
    sharedRead: plan["Shared Read Blocks"] ?? 0,
    access,
    plan,
  };
}
