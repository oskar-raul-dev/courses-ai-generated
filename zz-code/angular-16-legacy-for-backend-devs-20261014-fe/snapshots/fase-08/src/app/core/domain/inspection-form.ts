import {
  AbstractControl,
  FormControl,
  FormGroup,
  FormRecord,
  ValidationErrors,
  ValidatorFn,
  Validators,
} from '@angular/forms';

import { ChecklistItem, ChecklistTemplate } from '../models/checklist-template.model';
import { InspectionAnswer } from '../models/inspection.model';

/**
 * La forma de UNA respuesta. Las claves del formulario no se conocen en
 * compilación —las decide la plantilla—, pero el tipo de cada valor sí, y eso
 * es exactamente lo que FormRecord modela.
 */
export interface AnswerForm {
  /** Uno de los `criteria` del ítem. '' significa "sin responder todavía". */
  answer: FormControl<string>;
  /** `null` = sin evidencia. No es lo mismo que la cadena vacía. */
  evidenceUrl: FormControl<string | null>;
  note: FormControl<string | null>;
}

export type InspectionForm = FormRecord<FormGroup<AnswerForm>>;

/**
 * Construye el formulario de una inspección a partir de la plantilla con la
 * que se ejecutó y de las respuestas que ya tiene guardadas.
 *
 * ⚠️ `template` tiene que ser la versión que la inspección guardó, obtenida con
 * `getByVersion(inspection.templateId, inspection.templateVersion)`. Si le
 * pasas la vigente, esta función construye un formulario perfectamente válido
 * con la plantilla equivocada y nadie se entera. Es el incidente 08 de la
 * Fase 7, visto desde aquí.
 */
export function buildAnswerForm(
  template: ChecklistTemplate,
  answers: readonly InspectionAnswer[],
): InspectionForm {
  const form: InspectionForm = new FormRecord<FormGroup<AnswerForm>>({});
  const answerByItemId = new Map(answers.map((answer) => [answer.itemId, answer]));

  // El orden de inserción es el orden de la plantilla, y `getRawValue()` lo
  // respeta. Aun así, la pantalla pinta recorriendo `template.items` y no las
  // claves del formulario: el orden es de la plantilla, no del formulario.
  for (const item of template.items) {
    form.addControl(item.id, buildItemGroup(item, answerByItemId.get(item.id) ?? null));
  }

  return form;
}

function buildItemGroup(
  item: ChecklistItem,
  answer: InspectionAnswer | null,
): FormGroup<AnswerForm> {
  return new FormGroup<AnswerForm>({
    answer: new FormControl(answer?.answer ?? '', {
      nonNullable: true,
      // Los dos validadores salen del DATO, no de una decisión de pantalla:
      // el ítem dice qué respuestas admite y esto lo hace cumplir.
      validators: [Validators.required, oneOfValidator(item.criteria)],
    }),
    evidenceUrl: new FormControl<string | null>(answer?.evidenceUrl ?? null, {
      // `photoRequired` es un campo de la plantilla y aquí se vuelve un
      // validador. Cambiar ese booleano en una v3 cambia la validación de la
      // pantalla sin tocar una línea de este archivo. Eso es lo que significa
      // "derivado de la plantilla".
      validators: item.photoRequired ? [Validators.required] : [],
    }),
    note: new FormControl<string | null>(answer?.note ?? null),
  });
}

/** La respuesta tiene que ser uno de los criterios del ítem. */
export function oneOfValidator(allowed: readonly string[]): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    // El valor de un AbstractControl llega sin tipar: `unknown` y estrechar,
    // que es la regla del proyecto desde la Fase 6.
    const value: unknown = control.value;

    if (typeof value !== 'string' || value === '') {
      // Vacío no es inválido por este validador: de eso se ocupa `required`.
      // Un control con dos errores a la vez confunde el mensaje al usuario.
      return null;
    }

    return allowed.includes(value) ? null : { notAllowed: { value, allowed } };
  };
}

/**
 * El camino de vuelta: del formulario al modelo del dominio.
 *
 * Los ítems sin responder NO viajan. `answers` guarda lo respondido, no un
 * hueco por cada ítem: así una inspección a medias se distingue de una
 * inspección respondida con vacíos, y la 500 de la semilla —una respuesta de
 * cuatro ítems— es exactamente eso.
 */
export function toAnswers(form: InspectionForm): readonly InspectionAnswer[] {
  return Object.entries(form.getRawValue())
    .filter(([, value]) => value.answer !== '')
    .map(([itemId, value]) => ({
      itemId,
      answer: value.answer,
      evidenceUrl: value.evidenceUrl,
      note: value.note,
    }));
}

/**
 * Comparador barato para `distinctUntilChanged`: si el JSON es el mismo, no
 * hay nada que guardar. Es O(n) sobre un array de decenas de elementos y se
 * ejecuta como mucho una vez cada segundo y medio; una comparación profunda
 * hecha a mano sería más rápida y bastante más fácil de romper.
 */
export function serializeAnswers(answers: readonly InspectionAnswer[]): string {
  return JSON.stringify(answers);
}
