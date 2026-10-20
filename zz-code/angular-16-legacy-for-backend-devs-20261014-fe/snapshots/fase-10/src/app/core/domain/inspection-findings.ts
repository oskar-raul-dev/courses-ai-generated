import { ChecklistTemplate } from '../models/checklist-template.model';
import { Finding, FindingSeverity } from '../models/finding.model';
import { Inspection } from '../models/inspection.model';
import { SEVERITY_ORDER, deriveSeverity } from './finding-severity';

/**
 * Un hallazgo tal como lo ve la aplicación: la severidad DERIVADA, más la
 * parte humana que sí está guardada. Los dos casos se distinguen por `kind`,
 * y el compilador se encarga de que nadie lea `severity` esperando un valor
 * donde estructuralmente no puede haberlo.
 */
export type InspectionFinding =
  | {
      readonly kind: 'item';
      readonly itemId: string;
      readonly title: string;
      readonly answer: string;
      /** Derivada. Nunca se lee de la fila guardada. */
      readonly severity: FindingSeverity;
      readonly description: string;
      readonly resolvedAt: string | null;
      /** La fila de `findings`, si existe. Sólo para diagnóstico y para el borde HTTP. */
      readonly stored: Finding | null;
    }
  | {
      readonly kind: 'retired-item' | 'unknown-criterion';
      readonly itemId: string;
      readonly answer: string;
      /**
       * `null` significa "lo calculé y NO HAY severidad", no "no lo miré".
       * En el primer caso porque el ítem ya no está en esta versión de la
       * plantilla; en el segundo porque la respuesta no está entre sus
       * criterios. Las dos veces falta el dato del que saldría la severidad.
       */
      readonly severity: null;
      readonly description: string;
      readonly resolvedAt: string | null;
      readonly stored: Finding | null;
    };

export interface FindingSummary {
  readonly total: number;
  readonly bySeverity: Readonly<Record<FindingSeverity, number>>;
  /** `itemId` de cada `critical` sin resolver. Es lo que bloquea. */
  readonly blocking: readonly string[];
  /** `itemId` de cada hallazgo sin severidad derivable. También bloquea. */
  readonly undetermined: readonly string[];
  readonly canApprove: boolean;
}

/**
 * ⭐ Deriva los hallazgos de una inspección.
 *
 * ⚠️ `template` tiene que ser la versión que la inspección guardó, la que
 * devuelve `getByVersion(inspection.templateId, inspection.templateVersion)`.
 * Es la MISMA advertencia que lleva `buildAnswerForm` de la Fase 8.
 *
 * `stored` aporta ÚNICAMENTE la parte que no se puede calcular: la
 * descripción que alguien escribió y la fecha en que se resolvió. El campo
 * `severity` de la fila guardada NO se lee nunca. Si difiere de lo derivado,
 * la fila es historia y el cálculo es la verdad de hoy.
 */
export function deriveFindings(
  template: ChecklistTemplate,
  inspection: Inspection,
  stored: readonly Finding[],
): readonly InspectionFinding[] {
  const itemById = new Map(template.items.map((item) => [item.id, item]));
  // Una fila por ítem: la clave del negocio es (inspectionId, itemId), aunque
  // json-server insista en darle además un `id` numérico propio.
  const storedByItemId = new Map(stored.map((finding) => [finding.itemId, finding]));
  const findings: InspectionFinding[] = [];

  for (const answer of inspection.answers) {
    const item = itemById.get(answer.itemId);
    const row = storedByItemId.get(answer.itemId) ?? null;

    if (item === undefined) {
      // Respuesta huérfana: la Fase 7 decidió que no se borra y la Fase 8 la
      // pinta aparte. Aquí se le da la única lectura honesta posible — hay una
      // no conformidad potencial y el sistema NO sabe de qué gravedad.
      findings.push({
        kind: 'retired-item',
        itemId: answer.itemId,
        answer: answer.answer,
        severity: null,
        description: row?.description ?? 'Respuesta de un ítem retirado en esta versión.',
        resolvedAt: row?.resolvedAt ?? null,
        stored: row,
      });
      continue;
    }

    const derivation = deriveSeverity(item, answer.answer);

    if (derivation.status === 'compliant') {
      continue;
    }

    if (derivation.status === 'unknown-criterion') {
      findings.push({
        kind: 'unknown-criterion',
        itemId: item.id,
        answer: answer.answer,
        severity: null,
        description: `La respuesta "${answer.answer}" no está entre los criterios de "${item.title}".`,
        resolvedAt: row?.resolvedAt ?? null,
        stored: row,
      });
      continue;
    }

    findings.push({
      kind: 'item',
      itemId: item.id,
      title: item.title,
      answer: answer.answer,
      severity: derivation.severity,
      // La descripción sí sale de la fila guardada cuando existe: la escribió
      // una persona y no hay forma de recalcularla. Cuando no existe, se
      // compone una legible en vez de dejar la celda vacía.
      description: row?.description ?? `${item.title}: ${answer.answer}. ${answer.note ?? ''}`.trim(),
      resolvedAt: row?.resolvedAt ?? null,
      stored: row,
    });
  }

  // Lo que bloquea, arriba. Dentro de cada severidad, el orden de la
  // plantilla; los indeterminados, al final, porque son un problema de datos
  // y no de la inspección.
  return [...findings].sort((a, b) => severityRank(a.severity) - severityRank(b.severity));
}

function severityRank(severity: FindingSeverity | null): number {
  return severity === null ? SEVERITY_ORDER.length : SEVERITY_ORDER.indexOf(severity);
}

/**
 * La agregación por inspección, y la única regla que dice que no.
 *
 * Dos cosas bloquean la aprobación, y la segunda sorprende a todo el mundo:
 *
 *   1. Un `critical` sin resolver. Es la regla del `alcance-del-proyecto.md` §5.
 *   2. Un hallazgo cuya severidad NO se pudo derivar. Certificar es afirmar que
 *      revisaste todo, y aquí hay una respuesta que el sistema no sabe
 *      clasificar. Que decida una persona, no un `?? 'minor'`.
 */
export function summarizeFindings(findings: readonly InspectionFinding[]): FindingSummary {
  const bySeverity: Record<FindingSeverity, number> = { critical: 0, major: 0, minor: 0 };
  const blocking: string[] = [];
  const undetermined: string[] = [];

  for (const finding of findings) {
    if (finding.severity === null) {
      undetermined.push(finding.itemId);
      continue;
    }

    bySeverity[finding.severity] += 1;

    // `=== null` y no `== null`, y esto sólo es seguro porque el borde HTTP
    // normaliza el campo (ver finding-api.service.ts). Sin esa normalización,
    // esta línea es el incidente 12.
    if (finding.severity === 'critical' && finding.resolvedAt === null) {
      blocking.push(finding.itemId);
    }
  }

  return {
    total: findings.length,
    bySeverity,
    blocking,
    undetermined,
    canApprove: blocking.length === 0 && undetermined.length === 0,
  };
}

/**
 * La puerta que la Fase 10 va a usar para emitir. Se escribe aquí porque la
 * regla es de hallazgos, no de certificados.
 */
export function canIssueCertificate(inspection: Inspection, summary: FindingSummary): boolean {
  return inspection.status === 'approved' && summary.blocking.length === 0;
}
