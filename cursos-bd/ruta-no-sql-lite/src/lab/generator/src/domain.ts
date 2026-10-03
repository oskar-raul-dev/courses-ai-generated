// Datos de referencia de Cóndor MRO: lo que no se sortea. Sale de 00-historia-de-condor.md.

export const HANGARS = [
  { hangarId: "VVC", name: "Base Villavicencio", city: "Villavicencio", country: "CO", pits: 3 },
  { hangarId: "BOG", name: "Base Bogotá", city: "Bogotá", country: "CO", pits: 2 },
  { hangarId: "EJA", name: "Base Barrancabermeja", city: "Barrancabermeja", country: "CO", pits: 1 },
  { hangarId: "NVA", name: "Base Neiva", city: "Neiva", country: "CO", pits: 1 },
  { hangarId: "IQT", name: "Estación Iquitos", city: "Iquitos", country: "PE", pits: 1 },
  { hangarId: "OCC", name: "Estación El Coca", city: "Puerto Francisco de Orellana", country: "EC", pits: 1 },
] as const;

export const OPERATORS = [
  { operatorId: "OP-LLA", name: "Carga del Llano", country: "CO", continuousWing: true },
  { operatorId: "OP-SEL", name: "Aerotaxi Selva", country: "CO", continuousWing: true },
  { operatorId: "OP-PET", name: "Servicios Aéreos Petroleros", country: "CO", continuousWing: false },
  { operatorId: "OP-AMB", name: "Ambulancia Aérea del Oriente", country: "CO", continuousWing: true },
  { operatorId: "OP-AMZ", name: "Amazonía Air", country: "PE", continuousWing: true },
  { operatorId: "OP-ORE", name: "Transportes Aéreos de Orellana", country: "EC", continuousWing: false },
  // el operador estatal cuyo contrato exige que sus registros no salgan del país (F21–F22)
  { operatorId: "OP-EST", name: "Servicio Aéreo Estatal de Frontera", country: "EC", continuousWing: true },
  { operatorId: "OP-MIN", name: "Minera Serranía", country: "CO", continuousWing: false },
] as const;

export type AircraftKind = "turboprop-twin" | "turboprop-single" | "piston-twin" | "helicopter";

/** Modelos atendidos. Cada familia de aeronave trae campos que las otras no tienen (F03). */
export const MODELS = [
  { model: "ATR 42-500", kind: "turboprop-twin", engines: 2, weight: 3 },
  { model: "DHC-6-300 Twin Otter", kind: "turboprop-twin", engines: 2, weight: 4 },
  { model: "Beechcraft King Air 350", kind: "turboprop-twin", engines: 2, weight: 3 },
  { model: "Cessna 208B Grand Caravan", kind: "turboprop-single", engines: 1, weight: 6 },
  { model: "Piper PA-31 Navajo", kind: "piston-twin", engines: 2, weight: 2 },
  { model: "Bell 407", kind: "helicopter", engines: 1, weight: 2 },
] as const;

export type Category =
  | "engine" | "propeller" | "rotor" | "landingGear" | "actuator" | "tire" | "pump"
  | "starterGenerator" | "instrument" | "avionics" | "magneto" | "consumable";

/** Posiciones con pieza serializada, por tipo de aeronave. `mtbfDays` gobierna la rotación. */
export interface PositionSpec {
  position: string;
  category: Category;
  mtbfDays: number;
}

const COMMON: PositionSpec[] = [
  { position: "altimeter", category: "instrument", mtbfDays: 900 },
  { position: "attitude-indicator", category: "instrument", mtbfDays: 1100 },
  { position: "transponder", category: "avionics", mtbfDays: 1400 },
  { position: "com-radio-1", category: "avionics", mtbfDays: 1600 },
  { position: "fuel-pump-1", category: "pump", mtbfDays: 800 },
];

const GEAR: PositionSpec[] = [
  { position: "main-gear-left", category: "landingGear", mtbfDays: 2500 },
  { position: "main-gear-right", category: "landingGear", mtbfDays: 2500 },
  { position: "nose-gear", category: "landingGear", mtbfDays: 2200 },
  { position: "gear-actuator-left", category: "actuator", mtbfDays: 700 },
  { position: "gear-actuator-right", category: "actuator", mtbfDays: 700 },
  { position: "gear-actuator-nose", category: "actuator", mtbfDays: 650 },
  { position: "tire-main-left", category: "tire", mtbfDays: 240 },
  { position: "tire-main-right", category: "tire", mtbfDays: 240 },
  { position: "tire-nose", category: "tire", mtbfDays: 300 },
];

const engineSet = (n: number, prop: boolean): PositionSpec[] =>
  Array.from({ length: n }, (_, i) => [
    { position: `engine-${i + 1}`, category: "engine" as const, mtbfDays: 2000 },
    { position: `starter-generator-${i + 1}`, category: "starterGenerator" as const, mtbfDays: 900 },
    ...(prop ? [{ position: `propeller-${i + 1}`, category: "propeller" as const, mtbfDays: 1800 }] : []),
  ]).flat();

export function positionsFor(kind: AircraftKind, engines: number): PositionSpec[] {
  switch (kind) {
    case "helicopter":
      return [
        ...engineSet(1, false),
        { position: "main-rotor-head", category: "rotor", mtbfDays: 1500 },
        { position: "tail-rotor-gearbox", category: "rotor", mtbfDays: 1300 },
        { position: "hydraulic-pump", category: "pump", mtbfDays: 900 },
        ...COMMON,
      ];
    case "piston-twin":
      return [
        ...engineSet(engines, true),
        { position: "magneto-1", category: "magneto", mtbfDays: 700 },
        { position: "magneto-2", category: "magneto", mtbfDays: 700 },
        ...GEAR,
        ...COMMON,
      ];
    default:
      return [
        ...engineSet(engines, true),
        { position: "hydraulic-pump", category: "pump", mtbfDays: 1000 },
        ...GEAR,
        ...COMMON,
      ];
  }
}

/** Vocabulario del catálogo, en el español del almacén. */
export const CATALOG_WORDS: Record<Category, { nouns: string[]; qualifiers: string[]; ata: number }> = {
  engine: { nouns: ["motor", "turbina", "módulo caliente", "caja de accesorios"], qualifiers: ["overhaul", "reparado", "nuevo", "de intercambio"], ata: 72 },
  propeller: { nouns: ["hélice", "pala de hélice", "gobernador de hélice", "cubo de hélice"], qualifiers: ["tripala", "cuatripala", "reversible"], ata: 61 },
  rotor: { nouns: ["cabeza de rotor", "caja de transmisión de cola", "pala de rotor", "plato oscilante"], qualifiers: ["principal", "de cola"], ata: 62 },
  landingGear: { nouns: ["tren principal", "tren de nariz", "amortiguador", "brazo de torsión"], qualifiers: ["izquierdo", "derecho", "completo"], ata: 32 },
  actuator: { nouns: ["actuador de retracción", "actuador de puerta de tren", "actuador de flap", "actuador de compensador"], qualifiers: ["hidráulico", "eléctrico", "de nariz", "principal"], ata: 32 },
  tire: { nouns: ["llanta", "neumático", "cámara", "rin"], qualifiers: ["principal", "de nariz", "recauchado", "tubeless"], ata: 32 },
  pump: { nouns: ["bomba de combustible", "bomba hidráulica", "bomba de vacío", "bomba de aceite"], qualifiers: ["eléctrica", "mecánica", "auxiliar"], ata: 28 },
  starterGenerator: { nouns: ["arrancador generador", "generador", "regulador de voltaje"], qualifiers: ["28 V", "de 200 A", "de 300 A"], ata: 24 },
  instrument: { nouns: ["altímetro", "indicador de actitud", "indicador de velocidad", "tacómetro", "indicador de temperatura de gases"], qualifiers: ["digital", "analógico", "de reserva"], ata: 34 },
  avionics: { nouns: ["transpondedor", "radio de comunicaciones", "GPS", "radar meteorológico", "ELT"], qualifiers: ["modo S", "VHF", "con WAAS"], ata: 34 },
  magneto: { nouns: ["magneto", "arnés de encendido", "bujía"], qualifiers: ["izquierdo", "derecho", "de impulso"], ata: 74 },
  consumable: { nouns: ["junta tórica", "empaque", "filtro de aceite", "filtro de combustible", "remache", "abrazadera", "manguera", "rodamiento", "sello", "tornillo"], qualifiers: ["del tren", "del motor", "de cabina", "de la hélice", "del tanque", "hidráulico", "de alta presión"], ata: 20 },
};

export const FIRST_NAMES = ["Hernán", "Lucía", "Yamile", "Édinson", "Camilo", "Freddy", "Sandra", "Jhon", "Diana", "Óscar", "Luz Marina", "Wilson", "Paola", "Jairo", "Marcela", "Andrés", "Nelly", "Rubén", "Carolina", "Fabio", "Gloria", "Iván", "Adriana", "Germán"];
export const LAST_NAMES = ["Peñaloza", "Arango", "Cruz", "Riaño", "Duarte", "Manrique", "Vélez", "Rojas", "Gómez", "Parra", "Quintero", "Castaño", "Suárez", "Ospina", "Guerrero", "Mora", "Cárdenas", "Salazar", "Ríos", "Huamán", "Tapia", "Chávez"];

export const REPAIR_CAPABILITIES = ["engines", "propellers", "ndt", "avionics", "structures", "instruments"] as const;
