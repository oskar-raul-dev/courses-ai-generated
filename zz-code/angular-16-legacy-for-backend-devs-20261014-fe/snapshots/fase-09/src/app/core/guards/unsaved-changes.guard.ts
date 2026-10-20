import { CanDeactivateFn } from '@angular/router';
import { Observable } from 'rxjs';

/**
 * El contrato que un componente cumple para poder ser protegido. Se tipa así
 * —y no con el componente concreto— para que la Fase 9 pueda reutilizar el
 * guard en su pantalla sin tocarlo.
 */
export interface CanLeave {
  canLeave(): Observable<boolean>;
}

/**
 * Guard funcional, como los de la Fase 2. No hace nada por su cuenta: pregunta
 * al componente, que es el único que sabe si tiene algo pendiente.
 */
export const unsavedChangesGuard: CanDeactivateFn<CanLeave> = (component) => component.canLeave();
