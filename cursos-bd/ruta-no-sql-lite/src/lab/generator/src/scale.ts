// Cuánto de cada entidad se genera. La base son los números de la casa de Cóndor
// (00-historia-de-condor.md §5) llevados a una ventana de cinco años; el volumen del curso fija
// cuántos registros tiene la entidad principal, y todo lo demás escala en la misma proporción.

export const WINDOW_START = Date.UTC(2021, 9, 1); // 01/10/2021
export const WINDOW_END = Date.UTC(2026, 8, 30, 23, 59, 59); // 30/09/2026
export const DAY_MS = 86_400_000;

/**
 * Entidades que pueden ser la principal de una familia. `aircraft` no está: ninguna familia
 * mide aeronaves (documental mide `part`), y 10 k aeronaves solo inflaban el dataset.
 */
export type Focus = "part" | "partCatalog" | "workOrder" | "reading" | "pirep";

/** Cinco años de Cóndor a escala 1. */
export const BASE = {
  aircraft: 140, // 140 aeronaves de 8 operadores
  aircraftWithRecorder: 30, // 30 de 140 descargan parámetros de vuelo
  part: 40_000, // ≈ 40.000 piezas con número de serie rastreadas
  partCatalog: 80_000, // ≈ 80.000 referencias en el catálogo
  workOrder: 54_000, // ≈ 900 órdenes al mes × 60 meses
  pirep: 11_800, // ≈ 26.000 desde 2015; la parte de estos cinco años
  // una lectura por minuto de vuelo: 30 aeronaves × ~2 vuelos diarios × ~80 min × 5 años
  reading: 8_760_000,
} as const;

/** Lo que no escala: la estructura de la empresa. */
export const FIXED = {
  hangar: 6,
  operators: 8,
  repairShops: 19, // talleres aliados con convenio
  partsSuppliers: 41,
} as const;

/** Minutos de vuelo que una aeronave puede registrar en cinco años sin solapar vuelos. */
export const MAX_READINGS_PER_AIRCRAFT = 1_200_000;

/**
 * Tope de escala para las entidades que no son la principal. Sin él, 1 M de pireps (base de
 * 11.800) multiplicaría la empresa entera por 85 y el generador se quedaría sin memoria.
 */
export const MAX_SCALE = 25;

/** Tope de lecturas cuando la familia no es la de series: nadie más necesita millones. */
export const READING_CAP_WHEN_NOT_FOCUS = 200_000;

export interface Counts {
  scale: number;
  aircraft: number;
  aircraftWithRecorder: number;
  technician: number;
  part: number;
  partCatalog: number;
  workOrder: number;
  pirep: number;
  reading: number;
}

export function parseVolume(text: string): number {
  const m = /^(\d+(?:\.\d+)?)([km]?)$/i.exec(text.trim());
  if (!m) throw new Error(`volumen inválido: "${text}" (usa 10k, 1m o un entero)`);
  const factor = { "": 1, k: 1_000, m: 1_000_000 }[m[2].toLowerCase() as "" | "k" | "m"];
  return Math.round(Number(m[1]) * factor);
}

export function computeCounts(focus: Focus, volume: number): Counts {
  const scale = Math.min(volume / BASE[focus], MAX_SCALE);
  const scaled = (n: number, min: number) => Math.max(min, Math.round(n * scale));
  const aircraft = scaled(BASE.aircraft, 4);
  const counts: Counts = {
    scale,
    aircraft,
    aircraftWithRecorder: Math.max(1, Math.round((aircraft * BASE.aircraftWithRecorder) / BASE.aircraft)),
    technician: Math.max(12, Math.round(aircraft * 0.35)), // 49 técnicos e inspectores para 140
    // al menos dos piezas por posición instalada, para que haya repuestos con que cambiar
    part: focus === "part" ? volume : Math.max(scaled(BASE.part, 0), aircraft * 20 * 2),
    partCatalog: focus === "partCatalog" ? volume : scaled(BASE.partCatalog, 500),
    workOrder: focus === "workOrder" ? volume : scaled(BASE.workOrder, 50),
    pirep: focus === "pirep" ? volume : scaled(BASE.pirep, 50),
    // fuera de series, las lecturas son contexto: como mucho cinco por registro principal
    reading: focus === "reading" ? volume : Math.min(scaled(BASE.reading, 1_000), volume * 5, READING_CAP_WHEN_NOT_FOCUS),
  };
  // si no caben las lecturas pedidas, hacen falta más aeronaves con grabador
  counts.aircraftWithRecorder = Math.min(counts.aircraft, Math.max(counts.aircraftWithRecorder, Math.ceil(counts.reading / MAX_READINGS_PER_AIRCRAFT)));
  return counts;
}
