import { buildTemplateRowId } from '../api/template-api.service';
import { ChecklistTemplate } from '../models/checklist-template.model';
import { Finding } from '../models/finding.model';
import { Inspection } from '../models/inspection.model';
import { InspectionFinding, deriveFindings } from './inspection-findings';

/**
 * ⭐ La pieza que hace posible el panel.
 *
 * `InspectionStateService.findingsOf()` —de la Fase 9— hace DOS peticiones por
 * inspección: una para la versión de plantilla congelada y otra para los
 * hallazgos guardados. Para una pantalla de detalle es perfecto. Para un panel
 * con doscientas inspecciones son cuatrocientas peticiones y un backend
 * llorando.
 *
 * Aquí se hace lo mismo sin una sola petición extra: las plantillas ya están
 * cargadas en `TemplateStateService` desde la Fase 7, los hallazgos guardados
 * se piden una vez, y `deriveFindings` es PURA — así que llamarla doscientas
 * veces es un bucle, no una tormenta de red.
 *
 * Ése es el pago de haber escrito el dominio sin inyecciones desde la Fase 7.
 * Una `deriveFindings` que hubiera inyectado el `HttpClient` "para conseguir la
 * plantilla ella misma" haría este archivo imposible.
 */
export interface InspectionWithFindings {
  readonly inspection: Inspection;
  readonly findings: readonly InspectionFinding[];
}

export function deriveAllFindings(
  inspections: readonly Inspection[],
  versions: readonly ChecklistTemplate[],
  stored: readonly Finding[],
): readonly InspectionWithFindings[] {
  // La clave del Map es el `id` compuesto de la fila —"elevator-annual-v2"— y
  // se construye con `buildTemplateRowId`, que la Fase 7 escribió justo para
  // que nadie la teclee. Una segunda función que concatenara lo mismo sería el
  // primer paso hacia dos formatos de clave.
  const templateByRowId = new Map(versions.map((version) => [version.id, version]));

  const storedByInspectionId = new Map<number, Finding[]>();

  for (const finding of stored) {
    const group = storedByInspectionId.get(finding.inspectionId);

    if (group === undefined) {
      storedByInspectionId.set(finding.inspectionId, [finding]);
    } else {
      group.push(finding);
    }
  }

  const result: InspectionWithFindings[] = [];

  for (const inspection of inspections) {
    const template = templateByRowId.get(
      // 🧭 Quinta y última aparición de esta línea en el curso: la versión que
      // la inspección GUARDÓ. Que aquí sea una búsqueda en un Map en vez de una
      // petición no cambia nada del invariante — cambia el costo.
      buildTemplateRowId(inspection.templateId, inspection.templateVersion),
    );

    if (template === undefined) {
      // Una inspección que apunta a una versión que no existe es un dato roto.
      // NO se deriva con la versión más cercana, ni con la vigente, ni se
      // inventa nada: se deja fuera y se cuenta. Rellenar aquí sería el
      // incidente 08 de la Fase 7 disfrazado de robustez.
      continue;
    }

    result.push({
      inspection,
      findings: deriveFindings(template, inspection, storedByInspectionId.get(inspection.id) ?? []),
    });
  }

  return result;
}

/** Aplana los hallazgos de todas las inspecciones. Lo que cuentan los KPI. */
export function flattenFindings(
  derived: readonly InspectionWithFindings[],
): readonly InspectionFinding[] {
  return derived.flatMap((entry) => entry.findings);
}
