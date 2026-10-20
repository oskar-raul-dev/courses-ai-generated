import { ChecklistTemplate } from '../models/checklist-template.model';
import { BusinessDay } from '../time/business-day';

/**
 * El resultado de preguntar "¿qué versión rige el día D?". Son TRES respuestas
 * y no dos, porque `ChecklistTemplate | null` mete en la misma bolsa el hueco
 * —molesto e inofensivo— y el solape —silencioso y peligroso—, que se
 * diagnostican distinto y se arreglan distinto.
 */
export type TemplateResolution =
  | { readonly status: 'resolved'; readonly template: ChecklistTemplate }
  | { readonly status: 'none'; readonly day: BusinessDay }
  | { readonly status: 'ambiguous'; readonly candidates: readonly ChecklistTemplate[] };

/**
 * ¿Esta versión cubre este día? Los dos extremos son INCLUSIVE: una versión
 * que va del 1 de enero al 31 de diciembre rige los dos días. `validUntil:
 * null` significa "vigente indefinidamente", tal como lo definió el modelo de
 * la Fase 3 — y no "sin decidir".
 */
export function appliesOn(template: ChecklistTemplate, day: BusinessDay): boolean {
  // Comparación de cadenas, no de Date. Con el formato 'YYYY-MM-DD' el orden
  // lexicográfico y el cronológico son el mismo, y eso ahorra el huso horario
  // entero. Es la razón de que estos campos NO lleven hora.
  return template.validFrom <= day && (template.validUntil === null || day <= template.validUntil);
}

/**
 * Resuelve qué versión rige un día.
 *
 * ⚠️ `versions` tiene que ser UNA familia: todas con el mismo `templateId`. Si
 * le pasas versiones mezcladas, el resultado es basura con buena pinta —dos
 * plantillas distintas vigentes el mismo día son un `ambiguous` que no lo es—.
 * Quien tiene las familias bien formadas es `groupIntoFamilies`, y por eso
 * esta función recibe versiones y no un `templateId`: así no necesita saber de
 * dónde salieron ni hablar con nadie. El ejercicio 25 te hace decidir si eso
 * merece una comprobación en tiempo de ejecución.
 */
export function resolveTemplateVersion(
  versions: readonly ChecklistTemplate[],
  day: BusinessDay,
): TemplateResolution {
  const matches = versions.filter((version) => appliesOn(version, day));

  if (matches.length === 0) {
    // Se devuelve el día dentro del resultado para que quien lo pinte pueda
    // decir "no hay plantilla vigente el 15 de enero de 2024" y no un genérico
    // "no hay plantilla", que no se puede diagnosticar.
    return { status: 'none', day };
  }

  if (matches.length > 1) {
    // NO se elige la más alta. Elegir aquí taparía un error de datos y haría
    // que la versión con la que se ejecuta una inspección dependiera de un
    // detalle de implementación. Se devuelven las candidatas para que la
    // pantalla las enseñe y alguien arregle las fechas. Incidente 09.
    return { status: 'ambiguous', candidates: matches };
  }

  const [only] = matches;

  if (only === undefined) {
    // Inalcanzable: length === 1. Está aquí porque `matches[0]` se tipa como
    // ChecklistTemplate aunque el array pudiera estar vacío, y prefiero una
    // guarda explícita a un aserto de no-nulo, que en CertCore no se usa.
    return { status: 'none', day };
  }

  return { status: 'resolved', template: only };
}
