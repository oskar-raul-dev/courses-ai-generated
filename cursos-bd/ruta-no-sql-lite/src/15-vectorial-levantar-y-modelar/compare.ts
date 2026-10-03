// Las dos comparaciones de la Fase 15 contra Postgres: el 🪞 ("esto es LIKE pero mejor") y la
// situación 3 (vectorial usado para una búsqueda exacta). La verdad de referencia de pirep-labels
// solo se usa para evaluar.
//
//   node 15-vectorial-levantar-y-modelar/compare.ts [--dataset lab/data/pirep-10k] [--collection pirep]
//      (desde src/, con vectorial cargado por ingest.py y base cargado con el mismo dataset por F01)
import { resolve, join } from "node:path";
import { parseArgs } from "node:util";
import { pipeline } from "@huggingface/transformers";
import { QdrantClient } from "@qdrant/js-client-rest";
import pg from "pg";
import { readNdjson, verifyDataset } from "../lab/harness/dataset.ts";
import { explain } from "../lab/harness/explain.ts";

const { values: args } = parseArgs({ options: { dataset: { type: "string", default: "lab/data/pirep-10k" }, collection: { type: "string", default: "pirep" } } });
const dir = resolve(args.dataset!);
const manifest = await verifyDataset(dir);
const extractor = await pipeline("feature-extraction", "intfloat/multilingual-e5-small", { revision: "614241f622f53c4eeff9890bdc4f31cfecc418b3", dtype: "fp32" });
const embed = async (t: string) => ((await extractor([t], { pooling: "mean", normalize: true })).tolist() as number[][])[0];
const qdrant = new QdrantClient({ url: `http://localhost:${process.env.VECTORIAL_HTTP_PORT ?? 16333}` });
const pgc = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "postgres" });
await pgc.connect();
const archetype = new Map<string, string>();
for await (const l of readNdjson<{ pirepId: string; archetype: string }>(join(dir, "pirep-labels.ndjson"))) archetype.set(l.pirepId, l.archetype);
const target = "gear-metallic-noise";
const classSize = [...archetype.values()].filter((a) => a === target).length;
const topIds = async (vector: number[], limit: number, collection = args.collection!) =>
  (await qdrant.query(collection, { query: vector, limit, with_payload: ["pirepId", "aircraft"] })).points.map((p) => p.payload as { pirepId: string; aircraft: string });

try {
  console.log(`dataset ${manifest.focus}-${manifest.volume} (${manifest.datasetSha256.slice(0, 12)}…) · ${classSize} reportes de ${target}\n`);

  // ── 🪞 · LIKE contra vectores, con la misma frase de plataforma ──────────────────────────
  console.log(`"ruido metalico al bajar tren": cuántos devuelve cada forma, cuántos son ${target}, y qué parte de los ${classSize} encuentra`);
  for (const pattern of ["%ruido metalico al bajar tren%", "%ruido metalico%", "%ruido%", "%tren%"]) {
    const { rows } = await pgc.query("SELECT pirep_id FROM pirep WHERE text ILIKE $1", [pattern]);
    const ok = rows.filter((r) => archetype.get(r.pirep_id) === target).length;
    console.log(`   ILIKE '${pattern}'`.padEnd(46) + `devuelve ${String(rows.length).padStart(5)} · ${String(ok).padStart(4)} son ${target} · encuentra ${(ok / classSize * 100).toFixed(1)} %`);
  }
  const q = await embed("query: ruido metalico al bajar tren");
  for (const k of [10, 100, classSize]) {
    const hits = await topIds(q, k);
    const ok = hits.filter((h) => archetype.get(h.pirepId) === target).length;
    console.log(`   vectores, los ${k} más parecidos`.padEnd(46) + `devuelve ${String(hits.length).padStart(5)} · ${String(ok).padStart(4)} son ${target} · encuentra ${(ok / classSize * 100).toFixed(1)} %`);
  }
  const { rows: [none] } = await pgc.query("SELECT count(*)::int AS n FROM pirep WHERE text ILIKE '%arepa%'");
  const arepas = await topIds(await embed("query: receta de arepas con queso"), 10);
  console.log(`   "arepas": ILIKE devuelve ${none.n}; vectores devuelven ${arepas.length}\n`);

  // ── ⚰️ · situación 3: los reportes de una aeronave, buscados por parecido ────────────────
  const { rows: [top] } = await pgc.query("SELECT aircraft, count(*)::int AS n FROM pirep GROUP BY aircraft ORDER BY n DESC, aircraft LIMIT 1");
  const plan = await explain(pgc, "SELECT pirep_id FROM pirep WHERE aircraft = $1", [top.aircraft]);
  console.log(`los reportes de ${top.aircraft} (${top.n}):`);
  console.log(`   Postgres, índice pirep_aircraft_reported_at: examina ${plan.examined} → devuelve ${plan.returned} · ${plan.access.join(", ")}`);
  for (const phrase of [top.aircraft, `reportes de la aeronave ${top.aircraft}`]) {
    const hits = await topIds(await embed(`query: ${phrase}`), top.n);
    const ok = hits.filter((h) => h.aircraft === top.aircraft).length;
    console.log(`   vectores, "${phrase}", los ${top.n} más parecidos: ${ok} son de ${top.aircraft}`);
  }
  const { count } = await qdrant.count(args.collection!, { filter: { must: [{ key: "aircraft", match: { value: top.aircraft } }] }, exact: true });
  console.log(`   Qdrant con filtro de payload (índice keyword sobre aircraft): ${count}`);
  // un código de tramo, que va dentro del texto
  const { rows: legs } = await pgc.query("SELECT pirep_id FROM pirep WHERE text ILIKE '%IQT-LQM%'");
  const legHits = await topIds(await embed("query: tramo IQT-LQM"), Math.max(10, legs.length));
  const legSet = new Set(legs.map((r) => r.pirep_id));
  console.log(`el tramo IQT-LQM: ILIKE encuentra ${legs.length} · vectores, los ${legHits.length} más parecidos a "tramo IQT-LQM": ${legHits.filter((h) => legSet.has(h.pirepId)).length} lo contienen`);
} finally {
  await pgc.end();
}
