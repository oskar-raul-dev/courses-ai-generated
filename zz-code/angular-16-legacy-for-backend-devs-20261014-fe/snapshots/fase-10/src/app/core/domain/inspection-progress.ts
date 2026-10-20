import { ChecklistTemplate } from '../models/checklist-template.model';
import { InspectionAnswer } from '../models/inspection.model';

export interface InspectionProgress {
  readonly answered: number;
  readonly total: number;
  /** Ítems con `photoRequired` respondidos pero sin evidencia. */
  readonly missingEvidence: readonly string[];
  /** Ítems sin responder, por `id`. Lo usa el mensaje de "Completar". */
  readonly unanswered: readonly string[];
  /** ¿Se puede cerrar? Es la ÚNICA regla que bloquea algo en esta fase. */
  readonly canComplete: boolean;
}

export function computeProgress(
  template: ChecklistTemplate,
  answers: readonly InspectionAnswer[],
): InspectionProgress {
  const answerByItemId = new Map(answers.map((answer) => [answer.itemId, answer]));

  const missingEvidence = template.items
    .filter((item) => {
      const answer = answerByItemId.get(item.id);

      return item.photoRequired && answer !== undefined && answer.evidenceUrl === null;
    })
    .map((item) => item.id);

  const unanswered = template.items
    .filter((item) => !answerByItemId.has(item.id))
    .map((item) => item.id);

  // Sólo cuentan las respuestas de ítems que la plantilla tiene. Una respuesta
  // huérfana no suma progreso: no pertenece a este checklist.
  const answered = template.items.length - unanswered.length;

  return {
    answered,
    total: template.items.length,
    missingEvidence,
    unanswered,
    canComplete: unanswered.length === 0 && missingEvidence.length === 0,
  };
}

/**
 * Respuestas que no corresponden a ningún ítem de esta plantilla. Ocurre
 * cuando un ítem se retiró en una versión posterior y alguien movió la
 * inspección a esa versión, o cuando alguien editó a mano una versión
 * publicada.
 *
 * La decisión la tomó la Fase 7 y aquí se cumple: NO se borran. Se muestran
 * aparte, en sólo lectura, marcadas como pertenecientes a un ítem retirado.
 * Borrarlas sería destruir el trabajo de un inspector para que la pantalla
 * quede limpia.
 */
export function findOrphanAnswers(
  template: ChecklistTemplate,
  answers: readonly InspectionAnswer[],
): readonly InspectionAnswer[] {
  const itemIds = new Set(template.items.map((item) => item.id));

  return answers.filter((answer) => !itemIds.has(answer.itemId));
}
