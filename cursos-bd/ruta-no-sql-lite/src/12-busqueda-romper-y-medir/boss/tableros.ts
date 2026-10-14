// Los otros dos tableros del boss del Bloque II: Timescale y OpenSearch, cada uno con su cálculo del
// costo por hora volada del Twin Otter, enero a septiembre de 2026.
//
//   node 12-busqueda-romper-y-medir/boss/tableros.ts   (desde src/, después de setup.ts)
import { Client as OpenSearch } from "@opensearch-project/opensearch";
import pg from "pg";

const ts = new pg.Client({ host: "localhost", port: Number(process.env.SERIES_PORT ?? 15433), user: "postgres", password: "condor", database: "condor" });
await ts.connect();
const os = new OpenSearch({ node: `http://localhost:${process.env.BUSQUEDA_PORT ?? 19200}` });
try {
  // Timescale: horas del agregado mensual (mes colombiano) y órdenes abiertas en esos meses
  const { rows } = await ts.query(`
    WITH fleet AS (SELECT registration FROM boss_aircraft WHERE model = 'DHC-6-300 Twin Otter' AND has_flight_recorder),
    hours AS (SELECT sum(flight_hours) AS h FROM boss_hours_monthly
              WHERE aircraft IN (SELECT registration FROM fleet) AND month_co >= '2026-01-01 05:00' AND month_co < '2026-10-01 05:00'),
    cost AS (SELECT sum(labor_cost_usd + parts_cost_usd) AS c FROM boss_work_order
             WHERE aircraft IN (SELECT registration FROM fleet) AND opened_at - INTERVAL '5 hours' >= '2026-01-01' AND opened_at - INTERVAL '5 hours' < '2026-10-01')
    SELECT round(c, 2) AS c, round(h, 1) AS h, round(c / h, 2) AS r FROM hours, cost`);
  console.log(`Timescale  · Twin Otter, ene–sep 2026 · costo ${rows[0].c} USD · horas ${rows[0].h} · ${rows[0].r} USD por hora volada`);
  const hours = Number(rows[0].h);

  // OpenSearch: mano de obra de las órdenes y partes al precio del catálogo; las horas, las de Timescale
  const fleet = (await ts.query("SELECT registration FROM boss_aircraft WHERE model = 'DHC-6-300 Twin Otter' AND has_flight_recorder")).rows.map((r) => r.registration);
  const { body } = await os.search({ index: "boss_work_order", body: {
    size: 10000, _source: ["laborCostUsd", "installedPartNumbers"],
    query: { bool: { filter: [{ terms: { aircraft: fleet } }, { range: { openedAt: { gte: "2026-01-01T05:00:00Z", lt: "2026-10-01T05:00:00Z" } } }] } } } });
  const hits = body.hits.hits as { _source: { laborCostUsd: number; installedPartNumbers: string[] } }[];
  const pns = [...new Set(hits.flatMap((h) => h._source.installedPartNumbers))];
  const { body: prices } = await os.mget({ index: "boss_catalog", body: { ids: pns }, _source_includes: ["unitCostUsd"] });
  const price = new Map(prices.docs.map((d: { _id: string; _source: { unitCostUsd: number } }) => [d._id, d._source.unitCostUsd]));
  const cost = hits.reduce((s, h) => s + h._source.laborCostUsd + h._source.installedPartNumbers.reduce((p, pn) => p + (price.get(pn) ?? 0), 0), 0);
  console.log(`OpenSearch · Twin Otter, ene–sep 2026 · costo ${cost.toFixed(2)} USD · horas ${hours} · ${(cost / hours).toFixed(2)} USD por hora volada`);
} finally {
  await ts.end();
  await os.close();
}
