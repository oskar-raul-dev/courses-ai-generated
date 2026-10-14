// Solución privada del boss III (no se publica): reporte nuevo → parecidos en Qdrant → órdenes que los
// atendieron → piezas retiradas → piezas de la aeronave del reporte nuevo en esas posiciones. Desde src/.
import { pipeline } from "@huggingface/transformers";
import { QdrantClient } from "@qdrant/js-client-rest";
import neo4j from "neo4j-driver";
import { readFileSync } from "node:fs";
import { profile } from "./lab/harness/neo4j-profile.ts";
import { countRoundTrips } from "./lab/harness/roundtrips.ts";
const NEW = "ruido metalico al bajar tren, intermitente";
const aircraft = readFileSync("lab/data/pirep-1m/aircraft.ndjson", "utf8").trim().split("\n").map((l) => JSON.parse(l))
  .filter((a) => a.kind === "turboprop-twin" && a.leftFleetOn === null).sort((a, b) => a.registration.localeCompare(b.registration));
const REG = aircraft[0].registration;
const extractor = await pipeline("feature-extraction", "intfloat/multilingual-e5-small", { revision: "614241f622f53c4eeff9890bdc4f31cfecc418b3", dtype: "fp32" });
const [q] = (await extractor([`query: ${NEW}`], { pooling: "mean", normalize: true })).tolist() as number[][];
const qd = new QdrantClient({ url: "http://localhost:16333" });
const trips = countRoundTrips(qd, "query");
const hits = (await qd.query("pirep", { query: q, limit: 50, with_payload: true, params: { hnsw_ef: 128 } })).points;
console.log(`reporte nuevo en ${REG}: "${NEW}" · Qdrant: ${hits.length} parecidos en ${trips.count} viaje`);
const driver = neo4j.driver("bolt://localhost:17687", neo4j.auth.basic("neo4j", "condor-mro"));
const s = driver.session();
const ids = hits.map((h) => (h.payload as { pirepId: string }).pirepId);
const wo = await profile(s, `UNWIND range(0, size($ids) - 1) AS i WITH i, $ids[i] AS id
  MATCH (w:WorkOrder {pirepId: id})<-[r:REMOVED_IN]-(p:Part) RETURN i, id, w.workOrderId AS wo, collect(p.partNumber + '@' + p.category) AS removed ORDER BY i`, { ids });
const recs = wo.records as { i: { toNumber(): number }; id: string; wo: string; removed: string[] }[];
console.log(`neo4j: de los 50 parecidos, ${recs.length} tienen orden con piezas retiradas · db hits ${wo.dbHits}`);
const top5 = recs.slice(0, 5);
for (const r of top5) console.log(`  #${r.i.toNumber() + 1} ${r.id} (${(hits[r.i.toNumber()].payload as { text: string }).text}) → ${r.wo} retiró ${r.removed.join(", ")}`);
const cats = [...new Set(top5.flatMap((r) => r.removed.map((x) => x.split("@")[1])))];
const cur = await profile(s, `MATCH (a:Aircraft {registration: $reg})<-[st:INSTALLED]-(p:Part) WHERE st.to IS NULL AND p.category IN $cats
  OPTIONAL MATCH (p)-[h:INSTALLED]->(other:Aircraft) RETURN p.serialNumber AS sn, p.category AS cat, st.position AS pos, p.lotNumber AS lot, count(DISTINCT other) AS aircraftHistory ORDER BY pos`, { reg: REG, cats });
console.log(`neo4j: piezas instaladas hoy en ${REG} de las categorías ${cats.join(", ")} · db hits ${cur.dbHits}`);
for (const r of cur.records as { sn: string; cat: string; pos: string; lot: string; aircraftHistory: { toNumber(): number } }[]) console.log(`  ${r.pos} ${r.sn} ${r.cat} ${r.lot} · estuvo en ${r.aircraftHistory.toNumber()} aeronaves`);
await s.close(); await driver.close();
