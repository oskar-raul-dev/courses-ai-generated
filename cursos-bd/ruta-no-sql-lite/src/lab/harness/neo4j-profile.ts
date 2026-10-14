// Lo que recorre Neo4j para contestar: el PROFILE del plan real, sumado. "db hits" son los accesos al
// almacén (nodos, relaciones, propiedades, índices); las filas son las que pasan de un operador al
// siguiente. Es la cardinalidad de travesía, la medida de la familia de grafos (a04).
import type { Session } from "neo4j-driver";

interface ProfiledPlan { operatorType: string; dbHits: number; rows: number; children: ProfiledPlan[]; arguments: Record<string, unknown> }

export interface ProfileResult {
  dbHits: number;
  /** Filas que produjo el operador más ancho del plan: el tamaño máximo de la travesía. */
  maxRows: number;
  /** Filas que devolvió la consulta. */
  returned: number;
  operators: string[];
  records: unknown[];
}

export async function profile(session: Session, cypher: string, params: Record<string, unknown> = {}): Promise<ProfileResult> {
  const result = await session.run(`PROFILE ${cypher}`, params);
  const plan = result.summary.profile as unknown as ProfiledPlan;
  let dbHits = 0;
  let maxRows = 0;
  const operators: string[] = [];
  const walk = (p: ProfiledPlan) => {
    dbHits += Number(p.dbHits);
    maxRows = Math.max(maxRows, Number(p.rows));
    operators.push(p.operatorType.split("@")[0]);
    p.children.forEach(walk);
  };
  walk(plan);
  return { dbHits, maxRows, returned: result.records.length, operators, records: result.records.map((r) => r.toObject()) };
}
