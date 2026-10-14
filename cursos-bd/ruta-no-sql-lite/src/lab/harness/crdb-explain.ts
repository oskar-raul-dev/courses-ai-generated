// La forma de una sentencia en CockroachDB, leída de su EXPLAIN ANALYZE: filas y bytes que se leyeron del
// almacén distribuido (KV), los nodos que guardan lo que se leyó, los nodos que ejecutaron el SQL y las
// regiones que tocó. Es la versión distribuida de explain.ts: aquí la métrica no son los bloques de 8 kB
// sino a cuántas máquinas, y a cuántas regiones, tuvo que ir la sentencia (a04).
import type pg from "pg";

export interface CrdbExplain {
  /** "rows decoded from KV": filas que se leyeron del almacén, en todos los nodos. */
  kvRows: number;
  kvBytes: string;
  grpcCalls: number;
  /** Nodos que guardan lo que se leyó o escribió ("kv nodes"), y nodos que ejecutaron el SQL ("sql nodes"). */
  kvNodes: string[];
  sqlNodes: string[];
  /** Regiones que tocó la sentencia; solo aparece en un clúster con regiones. */
  regions: string[];
  /** Tiempo de ejecución en el servidor, en ms. Se guarda, pero en F21 no es el argumento (sección 6.5). */
  executionMs: number;
  /** Los operadores del plan, en orden: "scan", "lookup join", "insert fast path"… */
  operators: string[];
  /** El texto completo, por si hay que mostrarlo. */
  text: string[];
}

const toMs = (s: string) => { const m = /([\d.]+)(µs|ms|s)/.exec(s); return m ? Number(m[1]) * (m[2] === "s" ? 1000 : m[2] === "ms" ? 1 : 0.001) : 0; };
const list = (lines: string[], key: string) =>
  [...new Set(lines.filter((l) => l.startsWith(`${key}:`)).flatMap((l) => l.slice(key.length + 1).split(",").map((s) => s.trim()).filter(Boolean)))].sort();

export function parseCrdbExplain(text: string[]): CrdbExplain {
  const lines = text.map((l) => l.replace(/^[\s│└├─•]+/, "").trim());
  const kv = /rows decoded from KV: ([\d,]+) \(([^,]+), ([\d,]+) gRPC calls?\)/.exec(lines.find((l) => l.startsWith("rows decoded from KV")) ?? "");
  return {
    kvRows: kv ? Number(kv[1].replace(/,/g, "")) : 0,
    kvBytes: kv ? kv[2] : "0 B",
    grpcCalls: kv ? Number(kv[3].replace(/,/g, "")) : 0,
    kvNodes: list(lines, "kv nodes"),
    sqlNodes: list(lines, "sql nodes"),
    regions: list(lines, "regions"),
    executionMs: toMs(lines.find((l) => l.startsWith("execution time")) ?? ""),
    operators: text.filter((l) => l.includes("• ")).map((l) => l.slice(l.indexOf("• ") + 2).trim()),
    text,
  };
}

/** CockroachDB no acepta parámetros en un EXPLAIN (E-73 en a09): se escriben como literales. */
export function inline(client: pg.Client, sql: string, params: unknown[]): string {
  const lit = (v: unknown): string =>
    v === null || v === undefined ? "NULL"
      : Array.isArray(v) ? `ARRAY[${v.map(lit).join(", ")}]`
        : typeof v === "number" || typeof v === "boolean" ? String(v)
          : client.escapeLiteral(String(v));
  return sql.replace(/\$(\d+)/g, (_, i) => lit(params[Number(i) - 1]));
}

export async function crdbExplain(client: pg.Client, sql: string, params: unknown[] = []): Promise<CrdbExplain> {
  const { rows } = await client.query(`EXPLAIN ANALYZE ${inline(client, sql, params)}`);
  return parseCrdbExplain(rows.map((r) => r.info as string));
}

const intervalMs = (s: string) => { const [h, m, sec] = s.split(":"); return (Number(h) * 3600 + Number(m) * 60 + Number(sec)) * 1000; };

/** La latencia en el servidor de la sentencia anterior de esta sesión, incluido un COMMIT (`SHOW LAST QUERY
 *  STATISTICS`): `service` es lo que tardó el servidor en atenderla, de que llegó a que respondió. Se pide
 *  sentencia por sentencia, nunca sobre un lote (a04). */
export async function lastStatement(client: pg.Client): Promise<{ serviceMs: number; planMs: number; execMs: number }> {
  const { rows: [r] } = await client.query("SHOW LAST QUERY STATISTICS");
  return { serviceMs: intervalMs(r.service_latency), planMs: intervalMs(r.plan_latency), execMs: intervalMs(r.exec_latency) };
}
