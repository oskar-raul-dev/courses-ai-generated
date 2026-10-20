const { MongoClient } = require("mongodb");
const { computeStats, serializeStats } = require("../lib/stats");
async function main() {
  const client = await MongoClient.connect(process.env.MONGO_URL, { useUnifiedTopology: true });
  const db = client.db("tiquetera");
  const t0 = Date.now();
  const raw = await computeStats(db);
  const s = serializeStats(raw);
  console.log("computeStats:", Date.now() - t0, "ms");
  console.log(JSON.stringify({ byStatus: s.byStatus, resolvedPercent: s.resolvedPercent, activeByAgent: s.activeByAgent.slice(0, 3), resolution: s.resolution }));
  const r = await db.collection("tickets").aggregate([{ $limit: 1 }, { $project: { _id: 0, a: { $round: [62.5, 0] }, b: { $round: [63.5, 0] }, c: { $round: [0.625, 2] } } }]).toArray();
  console.log("$round 62.5 →", r[0].a, "| 63.5 →", r[0].b, "| Math.round(62.5) →", Math.round(62.5));
  await client.close();
}
main().catch(function (e) { console.error(e.message); process.exit(1); });
