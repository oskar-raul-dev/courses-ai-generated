// El boss del Bloque III: comprueba que los dos motores tienen lo que el encargo necesita —el grafo de
// pirep-1m en Neo4j, con el reporte de piloto de cada orden, y los reportes de pirep-1m en la colección
// "pirep" de Qdrant— y dice qué cargar si falta. No resuelve nada: deja el reporte nuevo y su aeronave.
//
//   node 16-vectorial-romper-y-medir/boss/setup.ts   (desde src/, con los perfiles grafos y vectorial arriba)
//
// Si falta algo:
//   node 13-grafos-levantar-y-modelar/load.ts --dataset lab/data/pirep-1m      (reemplaza el grafo; ~200 s)
//   uv run python 15-vectorial-levantar-y-modelar/ingest.py --dataset lab/data/pirep-1m
import { readFileSync } from "node:fs";
import { QdrantClient } from "@qdrant/js-client-rest";
import neo4j from "neo4j-driver";
import { readNdjson } from "../../lab/harness/dataset.ts";

const DATASET = "lab/data/pirep-1m";
const manifest = JSON.parse(readFileSync(`${DATASET}/manifest.json`, "utf8"));
let pireps = 0;
for await (const _ of readNdjson(`${DATASET}/pirep.ndjson`)) pireps++;
let expected = 0;
for await (const w of readNdjson<{ pirepId: string | null; removed: unknown[]; installed: unknown[] }>(`${DATASET}/workOrder.ndjson`)) {
  if (w.pirepId && w.removed.length + w.installed.length > 0) expected++;
}
const aircraft = readFileSync(`${DATASET}/aircraft.ndjson`, "utf8").trim().split("\n").map((l) => JSON.parse(l))
  .filter((a) => a.kind === "turboprop-twin" && a.leftFleetOn === null).sort((a, b) => a.registration.localeCompare(b.registration));

const driver = neo4j.driver(`bolt://localhost:${process.env.GRAFOS_BOLT_PORT ?? 17687}`, neo4j.auth.basic("neo4j", "condor-mro"));
const session = driver.session();
let ok = true;
try {
  const n = (await session.run("MATCH (w:WorkOrder) WHERE w.pirepId IS NOT NULL RETURN count(w) AS n, count(DISTINCT w.pirepId) AS p")).records[0];
  const withPirep = n.get("n").toNumber();
  console.log(`neo4j   · órdenes con reporte de piloto en el grafo: ${withPirep} (esperadas para ${DATASET}: ${expected})`);
  if (withPirep !== expected) { ok = false; console.log("          falta el grafo de pirep-1m: node 13-grafos-levantar-y-modelar/load.ts --dataset lab/data/pirep-1m"); }
} finally {
  await session.close();
  await driver.close();
}
const qd = new QdrantClient({ url: `http://localhost:${process.env.VECTORIAL_PORT ?? 16333}` });
const points = await qd.count("pirep").then((c) => c.count).catch(() => 0);
console.log(`qdrant  · colección pirep: ${points} puntos (reportes en ${DATASET}: ${pireps})`);
if (points !== pireps) { ok = false; console.log("          falta la colección: uv run python 15-vectorial-levantar-y-modelar/ingest.py --dataset lab/data/pirep-1m"); }

console.log(`dataset · ${DATASET} · datasetSha256 ${manifest.datasetSha256.slice(0, 12)}…`);
console.log(`encargo · aeronave ${aircraft[0].registration} · reporte nuevo: "ruido metalico al bajar tren, intermitente"`);
process.exitCode = ok ? 0 : 1;
