// La consulta de vectorial (Fase 15): "esto ya lo vimos" sobre los reportes de piloto en Qdrant. La
// consulta se embebe en TypeScript con el mismo modelo que la ingesta (paridad verificada en a06).
// Mide lo que devuelve, cuánto acierta el tipo de avería, el filtro por payload y el parámetro ef.
//
//   node 15-vectorial-levantar-y-modelar/search.ts [--dataset lab/data/pirep-10k] [--collection pirep]
//                          (desde src/, con vectorial arriba y la ingesta de ingest.py hecha)
import { resolve, join } from "node:path";
import { parseArgs } from "node:util";
import { pipeline } from "@huggingface/transformers";
import { QdrantClient } from "@qdrant/js-client-rest";
import { readNdjson, verifyDataset } from "../lab/harness/dataset.ts";
import { countRoundTrips } from "../lab/harness/roundtrips.ts";

const { values: args } = parseArgs({ options: { dataset: { type: "string", default: "lab/data/pirep-10k" }, collection: { type: "string", default: "pirep" } } });
const dir = resolve(args.dataset!);
const manifest = await verifyDataset(dir);
const collection = args.collection!;
const E5 = "intfloat/multilingual-e5-small";
const E5_REVISION = "614241f622f53c4eeff9890bdc4f31cfecc418b3";
const extractor = await pipeline("feature-extraction", E5, { revision: E5_REVISION, dtype: "fp32" });
const embed = async (texts: string[]) => (await extractor(texts, { pooling: "mean", normalize: true })).tolist() as number[][];

const client = new QdrantClient({ url: `http://localhost:${process.env.VECTORIAL_HTTP_PORT ?? 16333}` });
const trips = countRoundTrips(client, "query");
// la verdad de referencia solo se usa para evaluar: nunca se carga en el motor (a05)
const archetype = new Map<string, string>();
for await (const l of readNdjson<{ pirepId: string; archetype: string }>(join(dir, "pirep-labels.ndjson"))) archetype.set(l.pirepId, l.archetype);
type Hit = { id: string | number; score: number; payload?: Record<string, unknown> | null };
const search = async (vector: number[], opts: Record<string, unknown> = {}) =>
  (await client.query(collection, { query: vector, limit: 10, with_payload: true, ...opts })).points as Hit[];
const show = (hits: Hit[]) => hits.forEach((h) => console.log(`   ${h.score.toFixed(3)}  ${archetype.get(h.payload!.pirepId as string)!.padEnd(22)} ${h.payload!.text}`));

const info = await client.getCollection(collection);
console.log(`dataset ${manifest.focus}-${manifest.volume} (${manifest.datasetSha256.slice(0, 12)}…) · colección ${collection}: ${info.points_count} puntos, ${info.indexed_vectors_count} en HNSW\n`);

// 1 · "esto ya lo vimos": una consulta en palabras de plataforma
const [q] = await embed(["query: ruido metalico al bajar tren"]);
trips.reset();
const hits = await search(q);
console.log(`"ruido metalico al bajar tren" · ${trips.count} viaje · ${hits.filter((h) => archetype.get(h.payload!.pirepId as string) === "gear-metallic-noise").length} de 10 son gear-metallic-noise`);
show(hits);

// 2 · una consulta sin sentido también devuelve diez: el motor no sabe decir "no hay"
const [nonsense] = await embed(["query: receta de arepas con queso"]);
const nh = await search(nonsense);
console.log(`\n"receta de arepas con queso" · devuelve ${nh.length} · similitud de ${nh.at(-1)!.score.toFixed(3)} a ${nh[0].score.toFixed(3)}`);
show(nh.slice(0, 3));

// 3 · el filtro por payload: lo mismo, pero solo de una aeronave y solo del capítulo ATA 32
const reg = hits[0].payload!.aircraft as string;
const fa = await search(q, { filter: { must: [{ key: "aircraft", match: { value: reg } }] } });
const fata = await search(q, { filter: { must: [{ key: "ataChapter", match: { value: 32 } }] } });
const { count: regCount } = await client.count(collection, { filter: { must: [{ key: "aircraft", match: { value: reg } }] }, exact: true });
console.log(`\nfiltro aircraft = ${reg} (${regCount} reportes de esa aeronave): ${fa.length} resultados, ${fa.filter((h) => archetype.get(h.payload!.pirepId as string) === "gear-metallic-noise").length} gear-metallic-noise`);
show(fa.slice(0, 3));
// dónde quedan, dentro de esa aeronave, todos sus reportes del tipo buscado
const all = await search(q, { filter: { must: [{ key: "aircraft", match: { value: reg } }] }, limit: regCount });
const ranks = all.map((h, i) => [i + 1, h] as const).filter(([, h]) => archetype.get(h.payload!.pirepId as string) === "gear-metallic-noise");
console.log(`   ${reg} tiene ${ranks.length} gear-metallic-noise; puestos entre sus ${regCount}: ${ranks.map(([r]) => r).join(", ")}`);
ranks.filter(([r]) => r > 10).forEach(([r, h]) => console.log(`   #${r}  ${h.score.toFixed(3)}  ${h.payload!.text}`));
console.log(`filtro ataChapter = 32: ${fata.filter((h) => h.payload!.ataChapter === 32).length} de ${fata.length} del capítulo 32`);

// 4 · coseno y producto interno: con vectores normalizados ordenan igual
const [p] = (await client.retrieve(collection, { ids: [hits[0].id], with_vector: true })) as { vector: number[] }[];
const dot = q.reduce((s, x, i) => s + x * p.vector[i], 0);
const norm = (v: number[]) => Math.sqrt(v.reduce((s, x) => s + x * x, 0));
console.log(`\ncoseno según Qdrant ${hits[0].score.toFixed(6)} · producto interno a mano ${dot.toFixed(6)} · normas ${norm(q).toFixed(6)} y ${norm(p.vector).toFixed(6)}`);

// 5 · 100 reportes como consulta: el tipo de avería en los diez primeros, y el recall del índice
//     (HNSW contra la búsqueda exacta de Qdrant) según hnsw_ef
const sample: { pirepId: string; text: string }[] = [];
for await (const r of readNdjson<{ pirepId: string; text: string }>(join(dir, "pirep.ndjson"))) { sample.push(r); if (sample.length === 100) break; }
const qv = await embed(sample.map((s) => `query: ${s.text}`));
let sameType = 0;
const exact: Set<string | number>[] = [];
for (let i = 0; i < qv.length; i++) {
  const ex = await search(qv[i], { params: { exact: true } });
  exact.push(new Set(ex.map((h) => h.id)));
  sameType += ex.filter((h) => archetype.get(h.payload!.pirepId as string) === archetype.get(sample[i].pirepId)).length;
}
console.log(`\n100 reportes como consulta, búsqueda exacta: ${(sameType / 1000 * 100).toFixed(1)} % de los diez primeros comparten tipo de avería`);
for (const ef of [4, 10, 32, 128]) {
  let found = 0;
  for (let i = 0; i < qv.length; i++) found += (await search(qv[i], { params: { hnsw_ef: ef }, with_payload: false })).filter((h) => exact[i].has(h.id)).length;
  console.log(`   hnsw_ef ${String(ef).padStart(3)}: recall@10 del índice ${(found / 1000).toFixed(3)}`);
}
