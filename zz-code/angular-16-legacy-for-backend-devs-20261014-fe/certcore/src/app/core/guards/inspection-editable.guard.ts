import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { map, of } from 'rxjs';

import { InspectionApiService } from '../api/inspection-api.service';
import { isEditable } from '../domain/inspection-rules';

/**
 * Guard funcional, como los de la Fase 2. No decide nada por su cuenta: le
 * pregunta a la misma función pura que usa el servicio, y si la respuesta es
 * no, redirige a los hallazgos en vez de dejar la pantalla en blanco.
 *
 * ⚠️ Y esto hay que decirlo: **un guard no es seguridad.** Corre en el
 * navegador y cualquiera con las DevTools abiertas lo esquiva. Lo que impide de
 * verdad editar una inspección aprobada es que `InspectionStateService` se
 * niegue, y ni siquiera eso es seguridad: sería una comprobación en el backend,
 * que CertCore no tiene. El guard es experiencia de usuario.
 */
export const inspectionEditableGuard: CanActivateFn = (route) => {
  const router = inject(Router);
  const inspectionApi = inject(InspectionApiService);
  const id = Number(route.paramMap.get('id'));

  if (!Number.isInteger(id)) {
    return of(router.createUrlTree(['/inspections']));
  }

  return inspectionApi
    .getById(id)
    .pipe(
      map((inspection) =>
        isEditable(inspection) ? true : router.createUrlTree(['/inspections', id, 'findings']),
      ),
    );
};
