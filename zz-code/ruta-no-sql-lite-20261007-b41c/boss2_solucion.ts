// Solución privada del boss II (no se publica): descompone las tres cifras. Desde src/ del curso.
import { Client as OpenSearch } from "@opensearch-project/opensearch";
import pg from "pg";
const ts = new pg.Client({ host: "localhost", port: 15433, user: "postgres", password: "condor", database: "condor" });
await ts.connect();
const os = new OpenSearch({ node: "http://localhost:19200" });
const q = async (sql: string) => (await ts.query(sql)).rows;
const fleet = (await q("SELECT registration FROM boss_aircraft WHERE model = 'DHC-6-300 Twin Otter' AND has_flight_recorder")).map((r) => r.registration);
console.log("flota", fleet.join(", "));
console.log("horas por aeronave (UTC ventana, Bogotá ventana, año 2026 completo, máx ts):");
for (const r of await q(`SELECT aircraft, round(count(*) FILTER (WHERE ts >= '2026-01-01' AND ts < '2026-10-01')/60.0,1) utc,
  round(count(*) FILTER (WHERE ts - interval '5 hours' >= '2026-01-01' AND ts - interval '5 hours' < '2026-10-01')/60.0,1) bog,
  round(count(*) FILTER (WHERE extract(year from ts) = 2026)/60.0,1) y2026, max(ts) mx
  FROM reading WHERE aircraft = ANY('{${fleet.join(",")}}') GROUP BY 1 ORDER BY 1`)) console.log(" ", JSON.stringify(r));
console.log("costo almacenado por aeronave ene–sep 2026 (Bogotá):");
for (const r of await q(`SELECT aircraft, sum(labor_cost_usd) labor, sum(parts_cost_usd) parts, count(*) n FROM boss_work_order
  WHERE aircraft = ANY('{${fleet.join(",")}}') AND opened_at - interval '5 hours' >= '2026-01-01' AND opened_at - interval '5 hours' < '2026-10-01' GROUP BY 1 ORDER BY 1`)) console.log(" ", JSON.stringify(r));
const { body } = await os.search({ index: "boss_work_order", body: { size: 10000, _source: ["workOrderId", "laborCostUsd", "installedPartNumbers"],
  query: { bool: { filter: [{ terms: { aircraft: fleet } }, { range: { openedAt: { gte: "2026-01-01T05:00:00Z", lt: "2026-10-01T05:00:00Z" } } }] } } } });
const hits = body.hits.hits.map((h: { _source: { workOrderId: string; laborCostUsd: number; installedPartNumbers: string[] } }) => h._source);
const ids = new Set(hits.map((h: { workOrderId: string }) => h.workOrderId));
console.log(`OpenSearch: ${hits.length} documentos de orden, ${ids.size} órdenes distintas, duplicadas ${hits.length - ids.size}`);
const dup = hits.filter((h: { workOrderId: string }, i: number) => hits.findIndex((x: { workOrderId: string }) => x.workOrderId === h.workOrderId) !== i);
const pns = [...new Set(hits.flatMap((h: { installedPartNumbers: string[] }) => h.installedPartNumbers))] as string[];
const { body: prices } = await os.mget({ index: "boss_catalog", body: { ids: pns }, _source_includes: ["unitCostUsd"] });
const price = new Map(prices.docs.map((d: { _id: string; _source: { unitCostUsd: number } }) => [d._id, d._source.unitCostUsd]));
const costOf = (h: { laborCostUsd: number; installedPartNumbers: string[] }) => h.laborCostUsd + h.installedPartNumbers.reduce((p, pn) => p + (price.get(pn) ?? 0), 0);
const total = hits.reduce((s: number, h: never) => s + costOf(h), 0);
const dupCost = dup.reduce((s: number, h: never) => s + costOf(h), 0);
console.log(`costo OpenSearch ${total.toFixed(2)} · de duplicados ${dupCost.toFixed(2)} · sin duplicados ${(total - dupCost).toFixed(2)}`);
await ts.end(); await os.close();
