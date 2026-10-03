// La consulta de referencia de la Fase 01 y su prueba de fuego: las órdenes de trabajo de una
// aeronave en un trimestre, con lo que se instaló y retiró en cada una. Mide la forma:
// filas examinadas contra devueltas, sin índices y con ellos, y los viajes de dos maneras de
// pedir lo mismo. Imprime la ficha M-01 lista para la bitácora.
//
//   node 01-el-dominio-de-flota-y-el-arnes/reference-query.ts [--dataset lab/data/workOrder-1m]
//                                  (desde src/, con el perfil base arriba y el dataset cargado)
import { readFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { parseArgs } from "node:util";
import pg from "pg";
import { verifyDataset } from "../lab/harness/dataset.ts";
import { explain } from "../lab/harness/explain.ts";
import { countRoundTrips } from "../lab/harness/roundtrips.ts";
import { formatFicha } from "../lab/harness/ficha.ts";

const { values: args } = parseArgs({
  options: {
    dataset: { type: "string", default: "lab/data/workOrder-1m" },
    aircraft: { type: "string" },
    from: { type: "string", default: "2025-01-01" },
    to: { type: "string", default: "2025-04-01" },
  },
});
const manifest = await verifyDataset(resolve(args.dataset!));
const here = import.meta.dirname;

const client = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "postgres" });
await client.connect();
const trips = countRoundTrips(client, "query");

try {
  // la aeronave con más órdenes en el trimestre: se elige igual en cualquier máquina
  const aircraft = args.aircraft ?? (await client.query(
    `SELECT aircraft FROM work_order WHERE opened_at >= $1 AND opened_at < $2
     GROUP BY aircraft ORDER BY count(*) DESC, aircraft LIMIT 1`, [args.from, args.to])).rows[0].aircraft;
  const params = [aircraft, args.from, args.to];

  const REFERENCE = `
    SELECT wo.work_order_id, wo.opened_at, wo.type, m.kind, m.serial_number, m.position
    FROM work_order wo
    LEFT JOIN work_order_movement m ON m.work_order_id = wo.work_order_id
    WHERE wo.aircraft = $1 AND wo.opened_at >= $2 AND wo.opened_at < $3
    ORDER BY wo.opened_at, m.kind, m.serial_number`;

  // 1. sin índices secundarios: solo las claves primarias del esquema
  await client.query("DROP INDEX IF EXISTS work_order_aircraft_opened_at, work_order_movement_serial, part_aircraft, part_part_number, pirep_aircraft_reported_at; ANALYZE;");
  const before = await explain(client, REFERENCE, params);

  // 2. con los índices de referencia
  await client.query(readFileSync(join(here, "indexes.sql"), "utf8"));
  const after = await explain(client, REFERENCE, params);

  // 3. los viajes: una consulta con JOIN contra las órdenes primero y sus movimientos de a una (N+1)
  trips.reset();
  await client.query(REFERENCE, params);
  const joinTrips = trips.count;
  trips.reset();
  const { rows: orders } = await client.query(
    "SELECT work_order_id FROM work_order WHERE aircraft = $1 AND opened_at >= $2 AND opened_at < $3 ORDER BY opened_at", params);
  for (const o of orders) await client.query("SELECT kind, serial_number, position FROM work_order_movement WHERE work_order_id = $1", [o.work_order_id]);
  const nPlusOneTrips = trips.count;

  console.log(`aeronave ${aircraft} · ${args.from} a ${args.to} · ${orders.length} órdenes · ${after.returned} filas devueltas\n`);
  for (const [label, r] of [["sin índices", before], ["con índices", after]] as const) {
    console.log(`${label}: examinadas ${r.examined} · devueltas ${r.returned} · cociente ${(r.examined / r.returned).toFixed(1)} · bloques ${r.sharedHit + r.sharedRead}`);
    for (const a of r.access) console.log(`   ${a}`);
  }
  console.log(`viajes: JOIN ${joinTrips} · N+1 ${nPlusOneTrips}\n`);

  const today = new Date().toLocaleDateString("es-CO", { day: "2-digit", month: "2-digit", year: "numeric" });
  console.log(formatFicha({
    id: "M-01",
    title: "órdenes de una aeronave en un trimestre, con sus movimientos",
    volume: `${manifest.focus}-${manifest.volume}`,
    datasetSha256: manifest.datasetSha256,
    engine: "PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…`",
    columns: ["", "filas examinadas", "devueltas", "viajes"],
    rows: [
      ["sin índices secundarios", before.examined, before.returned, joinTrips],
      ["con los índices de referencia", after.examined, after.returned, joinTrips],
      ["con índices, en N+1", "—", after.returned, nPlusOneTrips],
    ],
    reproduce: "node 01-el-dominio-de-flota-y-el-arnes/reference-query.ts --dataset lab/data/workOrder-1m",
    verifiedOn: today,
  }));
} finally {
  await client.end();
}
