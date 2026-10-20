import { AbstractControl, ValidationErrors } from '@angular/forms';

/**
 * Valida que no haya dos ítems con el mismo `id` dentro de una versión. Se
 * aplica al FormArray entero y no a cada control, porque la regla no habla de
 * un ítem: habla de la relación entre todos.
 */
export function uniqueItemIdsValidator(control: AbstractControl): ValidationErrors | null {
  // El valor de un AbstractControl llega sin tipar: se trata como `unknown` y
  // se estrecha, que es la regla del proyecto para estos casos.
  const value: unknown = control.value;

  if (!Array.isArray(value)) {
    return null;
  }

  const ids = value
    .map((item: unknown) =>
      typeof item === 'object' && item !== null && 'id' in item && typeof item.id === 'string'
        ? item.id.trim()
        : null,
    )
    .filter((id): id is string => id !== null && id !== '');

  const duplicated = ids.filter((id, index) => ids.indexOf(id) !== index);

  return duplicated.length === 0 ? null : { duplicatedItemIds: [...new Set(duplicated)] };
}
