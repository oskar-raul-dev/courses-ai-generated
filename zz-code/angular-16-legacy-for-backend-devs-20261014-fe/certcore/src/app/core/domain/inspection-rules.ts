import { Inspection, InspectionStatus } from '../models/inspection.model';

/**
 * Las transiciones de la máquina de estados completa. `completed` la escribió la
 * Fase 8; `approved` y `rejected` dependen de los hallazgos y aquí se estrenan.
 *
 * Se escribe como un mapa de estado → estados alcanzables y no como una cadena
 * de `if`, para que la máquina de estados del `alcance-del-proyecto.md` §5 se
 * pueda LEER en el código.
 */
const ALLOWED_TRANSITIONS: Readonly<Record<InspectionStatus, readonly InspectionStatus[]>> = {
  requested: ['scheduled'],
  scheduled: ['in_progress'],
  in_progress: ['completed'],
  completed: ['approved', 'rejected'],
  // Los dos finales. Aprobar es irreversible (alcance §5) y rechazar también:
  // una inspección rechazada se repite, no se corrige.
  approved: [],
  rejected: [],
};

export function canTransition(from: InspectionStatus, to: InspectionStatus): boolean {
  return ALLOWED_TRANSITIONS[from].includes(to);
}

/**
 * ⭐ La herencia incómoda de la Fase 8, resuelta. Hoy la inspección 501 —
 * aprobada en agosto de 2023— se abre y se edita como cualquier otra, y el
 * `alcance-del-proyecto.md` §5 dice que aprobar es irreversible.
 */
export function isEditable(inspection: Inspection): boolean {
  return inspection.status !== 'approved' && inspection.status !== 'rejected';
}

/**
 * Un error de REGLA DE NEGOCIO, que no es un error de red y no debe pintarse
 * como uno. `ApiError` significa "el backend falló y quizá reintentando
 * funcione"; esto significa "el sistema funcionó perfectamente y la respuesta
 * es no".
 */
export class BusinessRuleError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'BusinessRuleError';
  }
}
