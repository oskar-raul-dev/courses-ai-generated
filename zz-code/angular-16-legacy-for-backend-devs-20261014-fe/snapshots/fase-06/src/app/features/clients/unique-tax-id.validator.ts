import { AbstractControl, AsyncValidatorFn, ValidationErrors } from '@angular/forms';
import { Observable, catchError, first, map, of, switchMap, timer } from 'rxjs';

import { ClientApiService } from '../../core/api/client-api.service';

/**
 * Valida que el NIT no esté ya registrado. Es una fábrica y no un validador
 * suelto porque necesita dos cosas del contexto: el servicio con el que
 * preguntar y el cliente que se está editando —para no chocar consigo mismo—.
 */
export function uniqueTaxIdValidator(
  clientApi: ClientApiService,
  exceptId: number | null,
): AsyncValidatorFn {
  return (control: AbstractControl): Observable<ValidationErrors | null> => {
    // El valor de un AbstractControl no está tipado: llega como `any`, y en
    // este proyecto eso se trata como `unknown` y se estrecha. Es el caso
    // exacto del §6.4 de la guía.
    const value: unknown = control.value;

    if (typeof value !== 'string' || value.trim() === '') {
      return of(null);
    }

    const taxId = value.trim();

    return timer(400).pipe(
      // El timer es el que evita una petición por tecla. Si el usuario sigue
      // escribiendo, Angular cancela este observable y arranca otro.
      switchMap(() => clientApi.existsByTaxId(taxId, exceptId)),
      map((exists) => (exists ? { taxIdTaken: true } : null)),
      // Un fallo de red no convierte un NIT válido en inválido: el usuario no
      // tiene la culpa de que el servidor esté caído. El error saldrá al
      // guardar, que es donde sí se puede explicar.
      catchError(() => of(null)),
      // Sin first(), el observable no completa y el control se queda `pending`
      // para siempre: el formulario nunca vuelve a ser válido y el botón nunca
      // se habilita. Es el bug que más tiempo hace perder de esta pantalla.
      first(),
    );
  };
}
