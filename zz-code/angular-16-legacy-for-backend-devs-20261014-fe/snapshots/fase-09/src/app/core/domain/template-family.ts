import { ChecklistTemplate } from '../models/checklist-template.model';

/**
 * Todas las versiones de una misma plantilla lógica, ordenadas de la más
 * antigua a la más nueva. No existe en el backend: se calcula agrupando por
 * `templateId`. Guardarla sería tener dos fuentes de verdad para lo mismo.
 */
export interface TemplateFamily {
  readonly templateId: string;
  /** Ordenadas por `version` ascendente. Nunca vacía. */
  readonly versions: readonly ChecklistTemplate[];
  /**
   * La de número más alto. ⚠️ NO es "la vigente": una versión publicada con
   * `validFrom` en el futuro es la más alta y no rige todavía. Para saber cuál
   * rige un día concreto está `resolveTemplateVersion`, y no hay atajo.
   */
  readonly latest: ChecklistTemplate;
}

export function groupIntoFamilies(
  templates: readonly ChecklistTemplate[],
): readonly TemplateFamily[] {
  const byTemplateId = new Map<string, ChecklistTemplate[]>();

  for (const template of templates) {
    const group = byTemplateId.get(template.templateId);

    if (group === undefined) {
      byTemplateId.set(template.templateId, [template]);
    } else {
      // Se muta el array LOCAL del Map, que nadie más ha visto todavía. Mutar
      // lo que acabas de crear no es lo que la 💸 de la Fase 4 prohibía;
      // prohibía mutar lo que ya está publicado en el estado.
      group.push(template);
    }
  }

  return [...byTemplateId.entries()]
    .map(([templateId, group]) => {
      const versions = [...group].sort((a, b) => a.version - b.version);
      // El grupo nunca está vacío —se creó con un elemento dentro—, así que el
      // último existe. Se escribe con reduce y no con versions[length - 1]
      // para que el tipo salga `ChecklistTemplate` y no `... | undefined`.
      const latest = versions.reduce((best, current) =>
        current.version > best.version ? current : best,
      );

      return { templateId, versions, latest };
    })
    .sort((a, b) => a.templateId.localeCompare(b.templateId));
}
