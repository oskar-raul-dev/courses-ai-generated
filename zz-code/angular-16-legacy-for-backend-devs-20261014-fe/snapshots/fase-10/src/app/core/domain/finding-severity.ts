import { ChecklistItem } from '../models/checklist-template.model';
import { FindingSeverity } from '../models/finding.model';

/**
 * Qué severidad queda al bajar un escalón. Es un Record TOTAL sobre la unión:
 * si mañana alguien añade 'blocker' a FindingSeverity, este objeto deja de
 * compilar y el compilador te lleva de la mano hasta aquí.
 *
 * `minor` se mapea a sí mismo a propósito: no existe una severidad más leve.
 * Lo más leve que hay es "no hay hallazgo", y esa decisión la toma
 * `deriveSeverity` con el índice 0, que es otro asunto.
 */
const DOWNGRADED: Readonly<Record<FindingSeverity, FindingSeverity>> = {
  critical: 'major',
  major: 'minor',
  minor: 'minor',
};

/** De más grave a menos. La usa la agregación para ordenar y para decidir el máximo. */
export const SEVERITY_ORDER: readonly FindingSeverity[] = ['critical', 'major', 'minor'];

/**
 * Etiquetas para pantalla. A diferencia del `criterionLabel` de la Fase 8 —que
 * arrastra un 💸 porque los criterios son datos abiertos y su tabla puede
 * quedarse corta—, esto es un Record total sobre una unión cerrada de tres
 * valores: no puede quedarse corto y no necesita un `?? code` de rescate.
 */
const SEVERITY_LABELS: Readonly<Record<FindingSeverity, string>> = {
  critical: 'Crítico',
  major: 'Mayor',
  minor: 'Menor',
};

export function severityLabel(severity: FindingSeverity): string {
  return SEVERITY_LABELS[severity];
}

/**
 * El resultado de preguntar "¿esta respuesta genera hallazgo, y de qué
 * gravedad?". Tres casos y no dos, por la misma razón que
 * `TemplateResolution` de la Fase 7 tenía tres: `FindingSeverity | null`
 * metería en la misma bolsa "la respuesta es conforme" —normal y esperado— y
 * "la respuesta no está entre los criterios del ítem" —dato corrupto—, que se
 * diagnostican distinto y se pintan distinto.
 */
export type SeverityDerivation =
  | { readonly status: 'compliant' }
  | { readonly status: 'derived'; readonly severity: FindingSeverity }
  | { readonly status: 'unknown-criterion'; readonly answer: string };

/**
 * ⭐ La regla de negocio central de la fase.
 *
 * `criteria` está documentado desde la Fase 3 como "las respuestas admisibles,
 * en orden de mejor a peor". Ese orden ES la regla: el primero conforma, el
 * último incumple del todo, y los de en medio incumplen a medias.
 *
 * ⚠️ `item` tiene que venir de la versión de plantilla que la inspección
 * GUARDÓ. Con la vigente, esta función devuelve una severidad perfectamente
 * plausible y equivocada, y nadie se entera.
 */
export function deriveSeverity(item: ChecklistItem, answer: string): SeverityDerivation {
  const index = item.criteria.indexOf(answer);

  if (index === -1) {
    // Ni conforme ni no conforme: es una respuesta que este ítem no admite.
    // Pasa cuando alguien edita db.json a mano, o cuando una respuesta viaja
    // desde otra plantilla. No se inventa una severidad para taparlo.
    return { status: 'unknown-criterion', answer };
  }

  if (index === 0) {
    return { status: 'compliant' };
  }

  // El último criterio es no conformidad plena. Con sólo dos criterios —el
  // `flue-gas` de las calderas— el segundo es también el último, así que no
  // hay degradado y sale la severidad completa del ítem. Es correcto.
  const isFullNonCompliance = index === item.criteria.length - 1;

  return {
    status: 'derived',
    severity: isFullNonCompliance
      ? item.nonComplianceSeverity
      : DOWNGRADED[item.nonComplianceSeverity],
  };
}
