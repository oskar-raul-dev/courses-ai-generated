// Mediciones de la Fase 16: Qdrant contra pgvector sobre el mismo millón de vectores. Recall del
// índice contra ef (con la búsqueda exacta como referencia), páginas que toca pgvector, la consulta
// filtrada por aeronave, la memoria, y la apuesta de los prefijos (acierto de tipo de avería).
//
//   node 16-vectorial-romper-y-medir/measure.ts [--dataset lab/data/pirep-1m] [--only apuesta,filtro,prefijos,memoria]
//      (desde src/, con vectorial cargado por ingest.py y base por load_pgvector.py, los dos con pirep-1m)
import { execFileSync } from "node:child_process";
import { resolve, join } from "node:path";
import { parseArgs } from "node:util";
import { pipeline } from "@huggingface/transformers";
import { QdrantClient } from "@qdrant/js-client-rest";
import pg from "pg";
import { readNdjson, verifyDataset } from "../lab/harness/dataset.ts";

const { values: args } = parseArgs({ options: {
  dataset: { type: "string", default: "lab/data/pirep-1m" },
  only: { type: "string", default: "apuesta,filtro,prefijos,memoria" }, // y halfvec, a mano
  queries: { type: "string", default: "100" },
  "prefix-queries": { type: "string", default: "500" },
} });
const only = new Set(args.only!.split(","));
const dir = resolve(args.dataset!);
const manifest = await verifyDataset(dir);
const extractor = await pipeline("feature-extraction", "intfloat/multilingual-e5-small", { revision: "614241f622f53c4eeff9890bdc4f31cfecc418b3", dtype: "fp32" });
const embed = async (texts: string[]) => {
  const out: number[][] = [];
  for (let i = 0; i < texts.length; i += 64) out.push(...((await extractor(texts.slice(i, i + 64), { pooling: "mean", normalize: true })).tolist() as number[][]));
  return out;
};
const qdrant = new QdrantClient({ url: `http://localhost:${process.env.VECTORIAL_HTTP_PORT ?? 16333}`, timeout: 600_000 });
const pgc = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "postgres" });
await pgc.connect();
const lit = (v: number[]) => `[${v.join(",")}]`;

// las consultas: reportes repartidos por todo el dataset, siempre los mismos
const pireps: { pirepId: string; aircraft: string; text: string }[] = [];
for await (const p of readNdjson<{ pirepId: string; aircraft: string; text: string }>(join(dir, "pirep.ndjson"))) pireps.push(p);
const pick = (n: number) => Array.from({ length: n }, (_, i) => Math.floor((i * pireps.length) / n) + 7);
const archetype: string[] = [];
for await (const l of readNdjson<{ archetype: string }>(join(dir, "pirep-labels.ndjson"))) archetype.push(l.archetype);

type Hit = { id: number; sim: number };
const qSearch = async (collection: string, v: number[], opts: Record<string, unknown> = {}, limit = 10): Promise<Hit[]> =>
  (await qdrant.query(collection, { query: v, limit, ...opts })).points.map((p) => ({ id: Number(p.id), sim: p.score }));
const pSearch = async (v: number[], where = "", params: unknown[] = []): Promise<Hit[]> =>
  (await pgc.query(`SELECT id, 1 - (embedding <=> $1::vector) AS sim FROM pirep_embedding ${where} ORDER BY embedding <=> $1::vector LIMIT 10`, [lit(v), ...params])).rows.map((r) => ({ id: r.id, sim: Number(r.sim) }));
// recall con empates: el 15 % de pirep-1m son duplicados exactos, y dos puntos con el mismo vector
// son igual de correctos. Cuenta como acierto todo resultado tan parecido como el décimo exacto.
const recall = (got: Hit[], exact: Hit[]) => got.filter((h) => h.sim >= exact[exact.length - 1].sim - 1e-5).length / exact.length;
const qps = (n: number, ms: number) => (n / (ms / 1000)).toFixed(0);

try {
  console.log(`dataset ${manifest.focus}-${manifest.volume} (${manifest.datasetSha256.slice(0, 12)}…)\n`);
  const qi = pick(Number(args.queries));
  const qv = await embed(qi.map((i) => `query: ${pireps[i].text}`));

  if (only.has("apuesta")) {
    const info = await qdrant.getCollection("pirep");
    console.log(`Qdrant pirep: ${info.points_count} puntos, ${info.indexed_vectors_count} en HNSW · pgvector pirep_embedding con HNSW m 16, ef_construction 100`);
    const exact: Hit[][] = [];
    for (const v of qv) exact.push(await qSearch("pirep", v, { params: { exact: true } }));
    // comprobación: la búsqueda exacta de Postgres (sin índice) da los mismos parecidos
    await pgc.query("SET enable_indexscan = off");
    let agree = 0;
    for (let i = 0; i < 10; i++) agree += recall(await pSearch(qv[i]), exact[i]);
    await pgc.query("RESET enable_indexscan");
    console.log(`referencia: búsqueda exacta de Qdrant; la de Postgres sin índice coincide en ${(agree / 10).toFixed(3)} (10 consultas)`);
    console.log(`${qv.length} consultas, una a una · recall@10 del índice · consultas por segundo (contexto, esta máquina) · páginas por consulta en Postgres`);
    for (const ef of [10, 20, 40, 80, 160, 320]) {
      let rq = 0; let rp = 0;
      let t = performance.now();
      for (let i = 0; i < qv.length; i++) rq += recall(await qSearch("pirep", qv[i], { params: { hnsw_ef: ef } }), exact[i]);
      const tq = performance.now() - t;
      await pgc.query(`SET hnsw.ef_search = ${ef}`);
      t = performance.now();
      for (let i = 0; i < qv.length; i++) rp += recall(await pSearch(qv[i]), exact[i]);
      const tp = performance.now() - t;
      let pages = 0;
      for (let i = 0; i < 20; i++) {
        const { rows: [r] } = await pgc.query(`EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) SELECT id FROM pirep_embedding ORDER BY embedding <=> $1::vector LIMIT 10`, [lit(qv[i])]);
        const plan = r["QUERY PLAN"][0].Plan;
        pages += (plan["Shared Hit Blocks"] ?? 0) + (plan["Shared Read Blocks"] ?? 0);
      }
      console.log(`   ef ${String(ef).padStart(3)}   Qdrant ${(rq / qv.length).toFixed(3)} · ${qps(qv.length, tq).padStart(4)}/s   pgvector ${(rp / qv.length).toFixed(3)} · ${qps(qv.length, tp).padStart(4)}/s · ${(pages / 20).toFixed(0)} páginas de 8 kB`);
    }
    await pgc.query("RESET hnsw.ef_search");
    console.log("");
  }

  if (only.has("filtro")) {
    // una aeronave de tamaño medio: los parecidos, pero solo de ella
    const counts = new Map<string, number>();
    for (const p of pireps) counts.set(p.aircraft, (counts.get(p.aircraft) ?? 0) + 1);
    const sorted = [...counts].sort((a, b) => a[1] - b[1] || a[0].localeCompare(b[0]));
    const [reg, n] = sorted[Math.floor(sorted.length / 2)];
    const filter = { must: [{ key: "aircraft", match: { value: reg } }] };
    let rq = 0; let rpOff = 0; let rpOn = 0; let shortOff = 0; let shortOn = 0;
    const m = 20;
    for (let i = 0; i < m; i++) {
      const exact = await qSearch("pirep", qv[i], { filter, params: { exact: true } });
      rq += recall(await qSearch("pirep", qv[i], { filter }), exact);
      const off = await pSearch(qv[i], "WHERE aircraft = $2", [reg]);
      rpOff += recall(off, exact); if (off.length < 10) shortOff++;
      await pgc.query("SET hnsw.iterative_scan = relaxed_order");
      const on = await pSearch(qv[i], "WHERE aircraft = $2", [reg]);
      await pgc.query("RESET hnsw.iterative_scan");
      rpOn += recall(on, exact); if (on.length < 10) shortOn++;
    }
    const { rows: [pl] } = await pgc.query(`EXPLAIN (FORMAT JSON) SELECT id FROM pirep_embedding WHERE aircraft = $2 ORDER BY embedding <=> $1::vector LIMIT 10`, [lit(qv[0]), reg]);
    console.log(`filtro aircraft = ${reg} (${n} de ${pireps.length} reportes) · ${m} consultas`);
    console.log(`   Qdrant, filtro de payload:                    recall@10 ${(rq / m).toFixed(3)}`);
    console.log(`   pgvector, WHERE + HNSW, por defecto:           recall@10 ${(rpOff / m).toFixed(3)} · ${shortOff} de ${m} devolvieron menos de 10 · plan: ${pl["QUERY PLAN"][0].Plan["Node Type"]}${pl["QUERY PLAN"][0].Plan.Plans ? " → " + pl["QUERY PLAN"][0].Plan.Plans.map((x: { "Node Type": string; "Index Name"?: string }) => `${x["Node Type"]} ${x["Index Name"] ?? ""}`).join(", ") : ""}`);
    console.log(`   pgvector, hnsw.iterative_scan = relaxed_order: recall@10 ${(rpOn / m).toFixed(3)} · ${shortOn} de ${m} devolvieron menos de 10`);
    // un filtro poco selectivo y sin índice B-tree: aquí el planificador sí usa el HNSW, y filtra después
    const ata = 22;
    const { rows: [c] } = await pgc.query("SELECT count(*)::int AS n FROM pirep_embedding WHERE ata_chapter = $1", [ata]);
    const fAta = { must: [{ key: "ataChapter", match: { value: ata } }] };
    rq = 0; rpOff = 0; rpOn = 0; shortOff = 0; shortOn = 0;
    let rowsOff = 0;
    for (let i = 0; i < m; i++) {
      const exact = await qSearch("pirep", qv[i], { filter: fAta, params: { exact: true } });
      rq += recall(await qSearch("pirep", qv[i], { filter: fAta }), exact);
      const off = await pSearch(qv[i], "WHERE ata_chapter = $2", [ata]);
      rowsOff += off.length; rpOff += recall(off, exact); if (off.length < 10) shortOff++;
      await pgc.query("SET hnsw.iterative_scan = relaxed_order");
      const on = await pSearch(qv[i], "WHERE ata_chapter = $2", [ata]);
      await pgc.query("RESET hnsw.iterative_scan");
      rpOn += recall(on, exact); if (on.length < 10) shortOn++;
    }
    const { rows: [pa] } = await pgc.query(`EXPLAIN (FORMAT JSON) SELECT id FROM pirep_embedding WHERE ata_chapter = $2 ORDER BY embedding <=> $1::vector LIMIT 10`, [lit(qv[0]), ata]);
    const node = (x: { "Node Type": string; "Index Name"?: string; Plans?: unknown[] }): string => `${x["Node Type"]}${x["Index Name"] ? " " + x["Index Name"] : ""}${x.Plans ? " → " + (x.Plans as typeof x[]).map(node).join(", ") : ""}`;
    console.log(`filtro ata_chapter = ${ata} (${c.n} de ${pireps.length}, sin índice B-tree) · ${m} consultas · plan: ${node(pa["QUERY PLAN"][0].Plan)}`);
    console.log(`   Qdrant, filtro de payload:                    recall@10 ${(rq / m).toFixed(3)}`);
    console.log(`   pgvector, WHERE + HNSW, por defecto:           recall@10 ${(rpOff / m).toFixed(3)} · ${shortOff} de ${m} devolvieron menos de 10 (${(rowsOff / m).toFixed(1)} filas de media)`);
    console.log(`   pgvector, hnsw.iterative_scan = relaxed_order: recall@10 ${(rpOn / m).toFixed(3)} · ${shortOn} de ${m} devolvieron menos de 10`);
    // la línea base bien jugada: recorrido iterativo, en los dos órdenes, y con más filas recorridas
    // que las 20 000 de hnsw.max_scan_tuples por defecto
    for (const [order, maxScan] of [["relaxed_order", 20000], ["relaxed_order", 500000], ["strict_order", 20000], ["strict_order", 500000]] as const) {
      await pgc.query(`SET hnsw.iterative_scan = ${order}; SET hnsw.max_scan_tuples = ${maxScan}`);
      let r = 0; let short = 0;
      for (let i = 0; i < m; i++) {
        const got = await pSearch(qv[i], "WHERE ata_chapter = $2", [ata]);
        if (got.length < 10) short++;
        r += recall(got, await qSearch("pirep", qv[i], { filter: fAta, params: { exact: true } }));
      }
      await pgc.query("RESET hnsw.iterative_scan; RESET hnsw.max_scan_tuples");
      console.log(`   pgvector, ${order.padEnd(13)} max_scan_tuples ${String(maxScan).padStart(6)}: recall@10 ${(r / m).toFixed(3)} · ${short} de ${m} con menos de 10`);
    }
    // y la salida relacional: un B-tree en ata_chapter, para que el planificador filtre primero y ordene
    // exacto después. Acierta siempre; el precio son las filas examinadas
    await pgc.query("CREATE INDEX IF NOT EXISTS pirep_embedding_ata ON pirep_embedding (ata_chapter); ANALYZE pirep_embedding");
    let rb = 0;
    for (let i = 0; i < m; i++) rb += recall(await pSearch(qv[i], "WHERE ata_chapter = $2", [ata]), await qSearch("pirep", qv[i], { filter: fAta, params: { exact: true } }));
    const { rows: [pb] } = await pgc.query(`EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) SELECT id FROM pirep_embedding WHERE ata_chapter = $2 ORDER BY embedding <=> $1::vector LIMIT 10`, [lit(qv[0]), ata]);
    const leaf = (x: Record<string, unknown>): Record<string, unknown> => (x.Plans ? leaf((x.Plans as Record<string, unknown>[])[0]) : x);
    const lp = pb["QUERY PLAN"][0].Plan;
    console.log(`   pgvector con B-tree en ata_chapter, el planificador elige: recall@10 ${(rb / m).toFixed(3)} · plan: ${node(lp)}`);
    // forzar el camino exacto: filtrar con el B-tree (bitmap) y ordenar las filas que quedan
    await pgc.query("SET enable_indexscan = off");
    let rx = 0;
    for (let i = 0; i < m; i++) rx += recall(await pSearch(qv[i], "WHERE ata_chapter = $2", [ata]), await qSearch("pirep", qv[i], { filter: fAta, params: { exact: true } }));
    const { rows: [px] } = await pgc.query(`EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) SELECT id FROM pirep_embedding WHERE ata_chapter = $2 ORDER BY embedding <=> $1::vector LIMIT 10`, [lit(qv[0]), ata]);
    await pgc.query("RESET enable_indexscan");
    const xp = px["QUERY PLAN"][0].Plan;
    const scan = leaf(xp);
    console.log(`   pgvector con B-tree, camino exacto forzado: recall@10 ${(rx / m).toFixed(3)} · plan: ${node(xp)} · ${scan["Actual Rows"]} filas examinadas, ${(xp["Shared Hit Blocks"] ?? 0) + (xp["Shared Read Blocks"] ?? 0)} páginas`);
    await pgc.query("DROP INDEX pirep_embedding_ata; ANALYZE pirep_embedding");
    console.log("");
  }

  if (only.has("prefijos")) {
    // la apuesta 4: acierto de tipo de avería con búsqueda exacta, sin contar el propio reporte
    const pi = pick(Number(args["prefix-queries"]));
    const withQ = await embed(pi.map((i) => `query: ${pireps[i].text}`));
    const noQ = await embed(pi.map((i) => pireps[i].text));
    const typeHit = async (collection: string, vs: number[][]) => {
      let ok = 0;
      for (let k = 0; k < vs.length; k++) {
        const hits = (await qSearch(collection, vs[k], { params: { exact: true } }, 11)).filter((h) => h.id !== pi[k]).slice(0, 10);
        ok += hits.filter((h) => archetype[h.id] === archetype[pi[k]]).length;
      }
      return (ok / (vs.length * 10)) * 100;
    };
    console.log(`prefijos · ${pi.length} reportes como consulta, búsqueda exacta, acierto de tipo en los diez primeros (sin el propio)`);
    console.log(`   passage: en la colección, query: en la consulta   ${(await typeHit("pirep", withQ)).toFixed(2)} %`);
    console.log(`   passage: en la colección, consulta sin prefijo     ${(await typeHit("pirep", noQ)).toFixed(2)} %`);
    console.log(`   sin prefijo en ningún lado                          ${(await typeHit("pirep_noprefix", noQ)).toFixed(2)} %\n`);
  }

  if (only.has("halfvec")) {
    // la salida de pgvector para que el índice ocupe menos: HNSW sobre halfvec (2 bytes por dimensión).
    // Necesita el índice de load_pgvector.py --skip-load --halfvec. La referencia es la búsqueda exacta
    // de Postgres sobre los float32, que coincide con la de Qdrant (sección apuesta)
    await pgc.query("SET enable_indexscan = off");
    const exact: Hit[][] = [];
    for (const v of qv) exact.push(await pSearch(v));
    await pgc.query("RESET enable_indexscan");
    const { rows: [sz] } = await pgc.query("SELECT pg_relation_size('pirep_embedding_hnsw_half') AS h");
    for (const ef of [40, 80, 160]) {
      await pgc.query(`SET hnsw.ef_search = ${ef}`);
      let r = 0;
      for (let i = 0; i < qv.length; i++) {
        const got = (await pgc.query(`SELECT id, 1 - (embedding <=> $1::vector) AS sim FROM pirep_embedding ORDER BY embedding::halfvec(384) <=> $1::halfvec(384) LIMIT 10`, [lit(qv[i])])).rows.map((x) => ({ id: x.id, sim: Number(x.sim) }));
        r += recall(got, exact[i]);
      }
      console.log(`halfvec · índice de ${(Number(sz.h) / 2 ** 20).toFixed(0)} MiB · ef ${ef}: recall@10 ${(r / qv.length).toFixed(3)}`);
    }
    await pgc.query("RESET hnsw.ef_search");
    console.log("");
  }

  if (only.has("memoria")) {
    const raw = pireps.length * 384 * 4;
    // docker stats resta la caché de archivos, y Qdrant lee los vectores por mmap: se lee el cgroup
    const cg = (c: string) => {
      const stat = execFileSync("docker", ["exec", c, "cat", "/sys/fs/cgroup/memory.stat"]).toString();
      const get = (k: string) => Number(stat.match(new RegExp(`^${k} (\\d+)`, "m"))![1]) / 2 ** 20;
      const current = Number(execFileSync("docker", ["exec", c, "cat", "/sys/fs/cgroup/memory.current"]).toString()) / 2 ** 20;
      const shown = execFileSync("docker", ["stats", "--no-stream", "--format", "{{.MemUsage}}", c]).toString().trim().split(" / ")[0];
      return `${c.replace("condor-lab-", "").replace("-1", "")}: memory.current ${current.toFixed(0)} MiB (anónima ${get("anon").toFixed(0)}, archivos ${get("file").toFixed(0)}, de ellos mapeados ${get("file_mapped").toFixed(0)}) · docker stats dice ${shown}`;
    };
    const stats = [cg("condor-lab-vectorial-1"), cg("condor-lab-base-1")].join("\n   ");
    const disk = execFileSync("docker", ["exec", "condor-lab-vectorial-1", "du", "-sm", "/qdrant/storage"]).toString().split("\t")[0];
    const { rows: [s] } = await pgc.query(`SELECT pg_table_size('pirep_embedding') AS t, pg_relation_size('pirep_embedding_hnsw_passage') AS i`);
    console.log(`memoria · 1 M × 384 float32 = ${(raw / 2 ** 20).toFixed(0)} MiB crudos`);
    console.log(`   ${stats}`);
    console.log(`   Qdrant en disco: ${disk} MiB · Postgres: tabla ${(Number(s.t) / 2 ** 20).toFixed(0)} MiB, HNSW ${(Number(s.i) / 2 ** 20).toFixed(0)} MiB`);
  }
} finally {
  await pgc.end();
}
