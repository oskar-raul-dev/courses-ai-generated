// Las cien órdenes de la apuesta: las últimas cien de Freddy (T-004) en workOrder-1m, reabiertas, y lo que
// cada técnico de la orden hace en ellas mientras Freddy está tres días sin señal. La regla (paso 1 de la
// fase): el trabajo de cada orden —sus tareas, sus cambios de pieza y sus horas— se reparte entre los
// técnicos que el dataset le asigna; Freddy edita en la tableta, los demás en la base, con señal. Hay
// incompatibilidad solo si dos técnicos registran un cambio de pieza en la misma posición.
import { createReadStream } from "node:fs";
import { createInterface } from "node:readline";
import type { Edit } from "../19-offline-levantar-y-modelar/trip.ts";

export const DATASET = "lab/data/workOrder-1m";
export const FREDDY = "T-004";

export interface Trip { orders: any[]; edits: Edit[]; aircraft: string[] }

/** Lunes 21 a miércoles 23 de septiembre de 2026, de 07:00 a 17:00: el instante de la edición k de n. */
function instant(k: number, n: number): string {
  const minutes = Math.floor((k / n) * 3 * 600);
  const day = 21 + Math.floor(minutes / 600), m = 7 * 60 + (minutes % 600);
  const two = (x: number) => String(x).padStart(2, "0");
  // los segundos separan dos ediciones del mismo técnico en el mismo minuto: la etiqueta del CRDT lleva la hora
  return `2026-09-${day}T${two(Math.floor(m / 60))}:${two(m % 60)}:${two(k % 60)}-05:00`;
}

export async function loadTrip(n = 100): Promise<Trip> {
  const mine: any[] = [];
  // un millón de líneas: se descartan por texto antes de parsear
  for await (const line of createInterface({ input: createReadStream(`${DATASET}/workOrder.ndjson`) }))
    if (line.includes(`"${FREDDY}"`)) mine.push(JSON.parse(line));
  const picked = mine.slice(-n);
  const orders = picked.map(({ removed, installed, laborHours, laborCostUsd, partsCostUsd, closedAt, releasedBy, tasks, ...header }) =>
    ({ ...header, status: "open", taskList: tasks }));

  // cada orden reparte su trabajo entre sus técnicos, empezando por Freddy
  const work: Edit[] = [];
  for (const w of picked) {
    const techs = [FREDDY, ...w.technicianIds.filter((t: string) => t !== FREDDY)];
    const items: Omit<Edit, "by" | "at">[] = [
      ...w.tasks.map((task: string) => ({ wo: w.workOrderId, kind: "task" as const, task })),
      ...w.installed.map((i: any) => ({
        wo: w.workOrderId, kind: "swap" as const, position: i.position, installed: i.serialNumber,
        removed: w.removed.find((r: any) => r.position === i.position)?.serialNumber ?? "",
      })),
    ];
    items.forEach((it, k) => work.push({ ...it, by: techs[k % techs.length], at: "" } as Edit));
    const share = Math.max(1, Math.round(w.laborHours / techs.length));
    for (const by of techs) work.push({ wo: w.workOrderId, kind: "labor", hours: share, by, at: "" });
  }
  // los instantes, por técnico, en el orden en que trabajó
  const byTech = new Map<string, Edit[]>();
  for (const e of work) byTech.set(e.by, [...(byTech.get(e.by) ?? []), e]);
  for (const list of byTech.values()) list.forEach((e, k) => (e.at = instant(k, list.length)));
  return { orders, edits: work, aircraft: [...new Set(picked.map((w) => w.aircraft))].sort() };
}
