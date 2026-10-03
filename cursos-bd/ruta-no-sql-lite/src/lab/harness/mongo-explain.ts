// Documentos examinados contra devueltos en MongoDB, leídos de explain("executionStats"). Es el
// equivalente de filas examinadas contra devueltas en Postgres (a04).

export interface MongoExplainResult {
  docsExamined: number;
  keysExamined: number;
  returned: number;
  /** El plan ganador, resumido: COLLSCAN, IXSCAN { campo: 1 }… */
  stages: string[];
}

interface Stage { stage: string; keyPattern?: Record<string, number>; inputStage?: Stage; inputStages?: Stage[] }

function summarize(stage: Stage | undefined, out: string[] = []): string[] {
  if (!stage) return out;
  out.push(stage.keyPattern ? `${stage.stage} ${JSON.stringify(stage.keyPattern)}` : stage.stage);
  summarize(stage.inputStage, out);
  stage.inputStages?.forEach((s) => summarize(s, out));
  return out;
}

/** Para un find: pasa el cursor ya construido, sin iterarlo. */
export async function explainFind(cursor: { explain(verbosity: "executionStats"): Promise<any> }): Promise<MongoExplainResult> {
  const e = await cursor.explain("executionStats");
  const s = e.executionStats;
  return {
    docsExamined: s.totalDocsExamined,
    keysExamined: s.totalKeysExamined,
    returned: s.nReturned,
    stages: summarize(s.executionStages),
  };
}
