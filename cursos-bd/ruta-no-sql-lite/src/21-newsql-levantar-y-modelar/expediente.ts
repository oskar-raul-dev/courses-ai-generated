// El expediente de HC-2157, el Twin Otter del operador estatal ecuatoriano (OP-EST), y las dos órdenes
// del escenario de octubre de 2026: la rutina en el Coca y la inspección mayor en Bogotá. Las dos órdenes
// son del escenario, no del dataset: el generador nunca manda una aeronave fuera de las bases de su país, y
// la historia de Cóndor sí (sección 6.1). Sus ids empiezan por WO-F21 para que nadie las confunda.
//
// Este archivo es un módulo: lo usan transactions.ts (sección 6.2) y regions.ts (sección 6.4).
import type pg from "pg";

export const AIRCRAFT = "HC-2157";

export interface ScenarioOrder {
  workOrderId: string;
  hangarId: string;
  country: string;         // desde dónde se escribe: la base que firma
  type: string;
  openedAt: string;
  closedAt: string;
  technicianIds: string[];
  releasedBy: string;
  laborHours: number;
  tasks: string[];
  position: string;
  removed: { serialNumber: string; partNumber: string; disposition: string; supplierId: string | null };
  installed: { serialNumber: string; partNumber: string };
}

export const COCA: ScenarioOrder = {
  workOrderId: "WO-F21-0001", hangarId: "OCC", country: "EC", type: "routine",
  openedAt: "2026-10-05T13:00:00Z", closedAt: "2026-10-05T22:00:00Z",
  technicianIds: ["T-007"], releasedBy: "T-007", laborHours: 9, tasks: ["inspección visual", "cambio de llanta"],
  position: "tire-nose",
  removed: { serialNumber: "SN-0001685", partNumber: "32-796851-02", disposition: "scrap", supplierId: null },
  installed: { serialNumber: "SN-0001174", partNumber: "32-796851-02" },
};

export const BOGOTA: ScenarioOrder = {
  workOrderId: "WO-F21-0002", hangarId: "BOG", country: "CO", type: "major",
  openedAt: "2026-10-12T12:00:00Z", closedAt: "2026-10-26T21:00:00Z",
  technicianIds: ["T-002", "T-011"], releasedBy: "T-002", laborHours: 290, tasks: ["inspección mayor", "cambio de actuador"],
  position: "gear-actuator-nose",
  removed: { serialNumber: "SN-0001068", partNumber: "32-385762-22", disposition: "repairShop", supplierId: "S-017" },
  installed: { serialNumber: "SN-0000011", partNumber: "32-385762-22" },
};

/** Las tres formas del esquema: la de la Fase 01 copiada, con la región por fila, y con la autoridad en la clave. */
export type Schema = "copy" | "regional" | "autoridad";

/** Una sentencia con nombre, para medirla sola; si escribe, la fila que escribe (tabla y clave primaria). */
export interface Step { name: string; sql: string; params: unknown[]; row?: { table: string; key: unknown[] } }

/** Lo que pide una autoridad: la aeronave, sus órdenes con quién las firmó y qué se movió, y lo instalado hoy.
 *  Con la autoridad en la clave, la consulta la dice: es la que le permite al motor ir a una sola región. */
export const readSteps = (schema: Schema = "copy", reg = AIRCRAFT, country = "EC"): Step[] =>
  schema === "autoridad"
    ? [
        { name: "la aeronave", sql: `SELECT * FROM aircraft WHERE country = $2 AND registration = $1`, params: [reg, country] },
        { name: "sus órdenes", sql: `SELECT work_order_id, type, hangar_id, opened_at, released_by FROM work_order WHERE authority = $2 AND aircraft = $1`, params: [reg, country] },
        { name: "técnicos de cada orden", sql: `SELECT t.work_order_id, t.technician_id FROM work_order w JOIN work_order_technician t USING (authority, work_order_id) WHERE w.authority = $2 AND w.aircraft = $1`, params: [reg, country] },
        { name: "movimientos de piezas", sql: `SELECT m.work_order_id, m.kind, m.serial_number, m.position FROM work_order w JOIN work_order_movement m USING (authority, work_order_id) WHERE w.authority = $2 AND w.aircraft = $1`, params: [reg, country] },
        { name: "lo instalado hoy", sql: `SELECT serial_number, part_number, position FROM part WHERE aircraft = $1`, params: [reg] },
      ]
    : [
        { name: "la aeronave", sql: `SELECT * FROM aircraft WHERE registration = $1`, params: [reg] },
        { name: "sus órdenes", sql: `SELECT work_order_id, type, hangar_id, opened_at, released_by FROM work_order WHERE aircraft = $1`, params: [reg] },
        { name: "técnicos de cada orden", sql: `SELECT t.work_order_id, t.technician_id FROM work_order w JOIN work_order_technician t USING (work_order_id) WHERE w.aircraft = $1`, params: [reg] },
        { name: "movimientos de piezas", sql: `SELECT m.work_order_id, m.kind, m.serial_number, m.position FROM work_order w JOIN work_order_movement m USING (work_order_id) WHERE w.aircraft = $1`, params: [reg] },
        { name: "lo instalado hoy", sql: `SELECT serial_number, part_number, position FROM part WHERE aircraft = $1`, params: [reg] },
      ];

/** Firmar una orden: la orden, sus técnicos, los dos movimientos y las dos piezas, en una transacción. */
export const signSteps = (o: ScenarioOrder, schema: Schema = "copy", authority = "EC"): Step[] => {
  // la columna de la autoridad solo existe en los esquemas regionales; en el de la autoridad, abre cada clave
  const xCols = schema === "copy" ? [] : ["authority"], xVals = schema === "copy" ? [] : [authority];
  const key = (...k: unknown[]) => (schema === "autoridad" ? [authority, ...k] : k);
  const cols = (base: string[]) => [...base, ...xCols].join(", ");
  const ph = (n: number) => Array.from({ length: n + xCols.length }, (_, i) => `$${i + 1}`).join(", ");
  return [
    { name: "INSERT orden", sql: `INSERT INTO work_order (${cols(["work_order_id", "aircraft", "hangar_id", "type", "opened_at", "closed_at", "pirep_id", "released_by", "labor_hours", "labor_cost_usd", "parts_cost_usd", "tasks"])}) VALUES (${ph(12)})`,
      params: [o.workOrderId, AIRCRAFT, o.hangarId, o.type, o.openedAt, o.closedAt, null, o.releasedBy, o.laborHours, o.laborHours * 45, 0, o.tasks, ...xVals],
      row: { table: "work_order", key: key(o.workOrderId) } },
    ...o.technicianIds.map((t) => ({ name: `INSERT técnico ${t}`, sql: `INSERT INTO work_order_technician (${cols(["work_order_id", "technician_id"])}) VALUES (${ph(2)})`,
      params: [o.workOrderId, t, ...xVals], row: { table: "work_order_technician", key: key(o.workOrderId, t) } })),
    { name: "INSERT movimiento retirado", sql: `INSERT INTO work_order_movement (${cols(["work_order_id", "kind", "serial_number", "part_number", "position", "disposition", "supplier_id", "reason"])}) VALUES (${ph(8)})`,
      params: [o.workOrderId, "removed", o.removed.serialNumber, o.removed.partNumber, o.position, o.removed.disposition, o.removed.supplierId, "inspección", ...xVals],
      row: { table: "work_order_movement", key: key(o.workOrderId, "removed", o.removed.serialNumber) } },
    { name: "INSERT movimiento instalado", sql: `INSERT INTO work_order_movement (${cols(["work_order_id", "kind", "serial_number", "part_number", "position"])}) VALUES (${ph(5)})`,
      params: [o.workOrderId, "installed", o.installed.serialNumber, o.installed.partNumber, o.position, ...xVals],
      row: { table: "work_order_movement", key: key(o.workOrderId, "installed", o.installed.serialNumber) } },
    { name: "UPDATE pieza retirada", sql: `UPDATE part SET status = $2, aircraft = NULL, position = NULL, supplier_id = $3 WHERE serial_number = $1 AND aircraft = $4`,
      params: [o.removed.serialNumber, o.removed.disposition === "scrap" ? "scrapped" : "atSupplier", o.removed.supplierId, AIRCRAFT],
      row: { table: "part", key: [o.removed.serialNumber] } },
    { name: "UPDATE pieza instalada", sql: `UPDATE part SET status = 'installed', aircraft = $2, position = $3, hangar_id = NULL WHERE serial_number = $1 AND status = 'inStore'`,
      params: [o.installed.serialNumber, AIRCRAFT, o.position], row: { table: "part", key: [o.installed.serialNumber] } },
  ];
};

/** Deja las dos órdenes del escenario sin hacer: borra lo que escribieron y devuelve las piezas a su sitio. */
export async function reset(db: pg.Client): Promise<void> {
  for (const o of [COCA, BOGOTA]) {
    await db.query(`DELETE FROM work_order_movement WHERE work_order_id = $1`, [o.workOrderId]);
    await db.query(`DELETE FROM work_order_technician WHERE work_order_id = $1`, [o.workOrderId]);
    await db.query(`DELETE FROM work_order WHERE work_order_id = $1`, [o.workOrderId]);
    await db.query(`UPDATE part SET status = 'installed', aircraft = $2, position = $3, supplier_id = NULL WHERE serial_number = $1`, [o.removed.serialNumber, AIRCRAFT, o.position]);
    await db.query(`UPDATE part SET status = 'inStore', aircraft = NULL, position = NULL, hangar_id = $2 WHERE serial_number = $1`, [o.installed.serialNumber, o.hangarId]);
  }
}
