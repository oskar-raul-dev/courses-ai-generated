// ¿Es el inventario de piezas un índice de las órdenes de trabajo, o una segunda verdad? Se proyecta el
// estado de cada pieza desde sus movimientos (el último, por apertura de la orden) y se compara con lo que
// guarda la tabla `part`. Lo que no coincide se clasifica: el saldo inicial (piezas sin ningún movimiento),
// los intercambios y sustitutos que el generador anotó en answers.json y la base no, y el resto.
//
//   node 23-poliglota-el-diseno/inventory.ts [--db postgres] [--dataset lab/data/workOrder-1m]   (desde src/, con base arriba)
import { readFileSync } from "node:fs";
import { parseArgs } from "node:util";
import pg from "pg";

const { values } = parseArgs({ options: { db: { type: "string", default: "postgres" }, dataset: { type: "string", default: "lab/data/workOrder-1m" } } });
const answers = JSON.parse(readFileSync(`${values.dataset}/answers.json`, "utf8"));
const exchanges: { outSerial: string; inSerial: string }[] = answers.exchanges;

const client = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: values.db });
await client.connect();
try {
  // el rastro que el generador guardó aparte: la base no lo tiene, como la memoria de Yamile
  await client.query("CREATE TEMP TABLE exchange_log (out_serial text, in_serial text)");
  await client.query("INSERT INTO exchange_log SELECT * FROM unnest($1::text[], $2::text[])", [exchanges.map((e) => e.outSerial), exchanges.map((e) => e.inSerial)]);

  const t0 = performance.now();
  const { rows } = await client.query(`
    WITH last AS (
      -- el generador fecha cada movimiento con la apertura de la orden: ordenar por cierre mezcla órdenes
      -- largas con cortas que se abrieron después (sección 9 de la fase)
      SELECT DISTINCT ON (m.serial_number) m.serial_number, m.kind, m.disposition, m.position, m.supplier_id,
             w.aircraft, w.hangar_id
      FROM work_order_movement m JOIN work_order w USING (work_order_id)
      ORDER BY m.serial_number, w.opened_at DESC, m.work_order_id DESC, (m.kind = 'installed') DESC
    ), projected AS (
      SELECT p.serial_number, p.status, l.serial_number IS NULL AS no_moves,
             CASE WHEN l.kind = 'installed' AND a.left_fleet_on IS NOT NULL THEN 'leftWithAircraft'
                  WHEN l.kind = 'installed' THEN 'installed'
                  WHEN l.disposition = 'store' THEN 'inStore'
                  WHEN l.disposition = 'repairShop' THEN 'atSupplier'
                  WHEN l.disposition = 'scrap' THEN 'scrapped' END AS derived,
             CASE WHEN l.kind = 'installed' THEN p.aircraft IS NOT DISTINCT FROM l.aircraft AND p.position IS NOT DISTINCT FROM l.position
                  WHEN l.disposition = 'repairShop' THEN p.supplier_id IS NOT DISTINCT FROM l.supplier_id
                  ELSE p.hangar_id IS NOT DISTINCT FROM l.hangar_id END AS same_place,
             l.disposition
      FROM part p
      LEFT JOIN last l USING (serial_number)
      LEFT JOIN aircraft a ON a.registration = l.aircraft
    )
    SELECT CASE WHEN no_moves THEN 'saldo inicial: sin ningún movimiento'
                WHEN status = derived AND same_place THEN 'reconstruible desde las órdenes'
                WHEN serial_number IN (SELECT out_serial FROM exchange_log) THEN 'intercambio: salió y no volvió'
                WHEN serial_number IN (SELECT in_serial FROM exchange_log) THEN 'sustituto del intercambio'
                WHEN status = 'inStore' AND disposition = 'repairShop' THEN 'regreso del taller'
                WHEN serial_number = $1 THEN 'el actuador de marzo: al taller sin orden'
                ELSE 'otro' END AS kind,
           status, derived, count(*)::int AS parts
    FROM projected
    GROUP BY 1, 2, 3
    ORDER BY 1, 2, 3`, [answers.marchActuator.serialNumber]);
  const seconds = (performance.now() - t0) / 1000;

  const total = rows.reduce((s, r) => s + r.parts, 0);
  console.log(`${values.db} · ${total} piezas · ${exchanges.length} intercambios en answers.json · proyección en ${seconds.toFixed(1)} s`);
  console.log("clase                                      guardado          proyectado        piezas");
  for (const r of rows) console.log(`${r.kind.padEnd(42)} ${String(r.status).padEnd(17)} ${String(r.derived ?? "—").padEnd(17)} ${String(r.parts).padStart(7)}`);
  const byKind = new Map<string, number>();
  for (const r of rows) byKind.set(r.kind, (byKind.get(r.kind) ?? 0) + r.parts);
  console.log("\nresumen");
  for (const [k, n] of byKind) console.log(`  ${k.padEnd(42)} ${String(n).padStart(7)}  ${(100 * n / total).toFixed(1).padStart(5)} %`);
} finally {
  await client.end();
}
