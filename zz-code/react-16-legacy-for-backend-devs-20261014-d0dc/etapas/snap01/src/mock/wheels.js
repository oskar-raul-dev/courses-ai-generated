// 💸 Deuda técnica intencional: datos hardcodeados en el front.
// Lo correcto es traerlos de la API — llega en Fase 3 (json-server).
// Por ahora esto nos deja construir la navegación sin depender de un backend.

/**
 * @typedef {Object} Segment
 * @property {string} segmentId  - slug kebab: el slug es el id
 * @property {'none'|'lives'|'avatar'|'gemSet'} prizeType
 * @property {number} weightBp   - peso en puntos básicos; la rueda suma 10.000
 */

/**
 * @typedef {Object} Wheel
 * @property {number} id
 * @property {string} name
 * @property {string} timezone     - zona de presentación (America/Panama)
 * @property {string} closesAt     - ISO 8601 con offset de zona horaria
 * @property {'draft'|'scheduled'|'live'|'ended'|'reconciled'} status
 * @property {Segment[]} segments
 */

// Los pesos son los de la Esclusa de Oro (suman 10.000); la misma tabla
// sirve a las tres ruedas de demo para que F04 valide una sola regla.
const demoSegments = [
  { segmentId: "sin-premio", prizeType: "none", weightBp: 3000 },
  { segmentId: "vidas-2", prizeType: "lives", weightBp: 2000 },
  { segmentId: "avatar-comun", prizeType: "avatar", weightBp: 1500 },
  { segmentId: "set-gemas-basico", prizeType: "gemSet", weightBp: 1500 },
  { segmentId: "vidas-5", prizeType: "lives", weightBp: 1000 },
  { segmentId: "set-gemas-plata", prizeType: "gemSet", weightBp: 800 },
  { segmentId: "avatar-raro", prizeType: "avatar", weightBp: 150 },
  { segmentId: "esclusa-de-oro", prizeType: "gemSet", weightBp: 50 },
];

/** @type {Wheel[]} */
export const demoWheels = [
  {
    id: 1,
    name: "Esclusa de Oro",
    timezone: "America/Panama",
    closesAt: "2026-10-31T20:00:00-05:00",
    status: "live",
    segments: demoSegments,
  },
  {
    id: 2,
    name: "Semana del Canal",
    timezone: "America/Panama",
    closesAt: "2026-08-15T20:00:00-05:00",
    status: "scheduled",
    segments: demoSegments,
  },
  {
    id: 3,
    name: "Rueda de la costa",
    timezone: "America/Panama",
    closesAt: "2026-02-15T20:00:00-05:00",
    status: "reconciled",
    segments: demoSegments,
  },
];

/**
 * Busca una rueda por id. Recibe el id como string (viene de la URL)
 * y lo compara como número — el clásico bug de params lo evitamos acá.
 * @param {string} idParam
 * @returns {Wheel | undefined}
 */
export function findWheel(idParam) {
  const id = Number(idParam);
  return demoWheels.find((wheel) => wheel.id === id);
}
