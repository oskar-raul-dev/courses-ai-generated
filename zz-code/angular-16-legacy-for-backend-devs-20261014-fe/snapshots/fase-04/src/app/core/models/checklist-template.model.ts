import { FindingSeverity } from './finding.model';

export interface ChecklistItem {
  readonly id: string;
  readonly title: string;
  /** Las respuestas admisibles, en orden de mejor a peor. */
  readonly criteria: readonly string[];
  readonly photoRequired: boolean;
  /** Qué severidad tiene un hallazgo sobre este ítem si no cumple. */
  readonly nonComplianceSeverity: FindingSeverity;
}

/**
 * Se llama ChecklistTemplate y no Template a propósito: en un curso de Angular,
 * "plantilla" ya significa otra cosa, y el lector va a leer las dos palabras en
 * el mismo párrafo durante ocho fases. El endpoint sigue siendo /templates y
 * los campos del dominio siguen siendo templateId y templateVersion.
 */
export interface ChecklistTemplate {
  /** Clave de la fila: "elevator-annual-v2". Compuesta, y por eso única. */
  readonly id: string;
  /** Identificador lógico, compartido por todas las versiones. */
  readonly templateId: string;
  readonly version: number;
  readonly validFrom: string;
  /** `null` significa "vigente indefinidamente". No es un campo sin decidir. */
  readonly validUntil: string | null;
  readonly items: readonly ChecklistItem[];
}
