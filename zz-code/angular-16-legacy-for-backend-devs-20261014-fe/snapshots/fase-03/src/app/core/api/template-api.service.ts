import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError, map } from 'rxjs';

import { environment } from '../../../environments/environment';
import { ChecklistTemplate } from '../models/checklist-template.model';
import { ApiError, toApiError } from './api-error';

@Injectable({ providedIn: 'root' })
export class TemplateApiService {
  // inject() y no constructor: este servicio es de 2024. En el mismo directorio
  // vive AuthService, que es de 2021 y usa constructor. Los dos están bien; lo
  // que no estaría bien es mezclar las dos formas dentro de un archivo.
  private readonly http = inject(HttpClient);

  private readonly baseUrl = `${environment.apiBaseUrl}/templates`;

  getAll(): Observable<readonly ChecklistTemplate[]> {
    return this.http.get<readonly ChecklistTemplate[]>(this.baseUrl).pipe(
      // El genérico de arriba es una promesa nuestra, no una verificación.
      // Estas tres líneas comprueban la FORMA —lo que dijimos que era un array
      // lo es— y ni una cosa más. Es el punto medio del §4: sin esto, un
      // CHAOS=malformed explota dentro de un *ngFor, tres capas más allá.
      map((templates) => {
        if (!Array.isArray(templates)) {
          throw new ApiError('El servidor devolvió algo que no es una lista de plantillas.', 200);
        }

        return templates;
      }),
      catchError(toApiError),
    );
  }

  /**
   * Resuelve UNA versión concreta. Es el método que sostiene el invariante del
   * curso: una inspección se lee con la versión que guardó, no con la vigente.
   */
  getByVersion(templateId: string, version: number): Observable<ChecklistTemplate> {
    const params = new HttpParams().set('templateId', templateId).set('version', version);

    // json-server devuelve un array al filtrar una colección, aunque la
    // coincidencia sea única. Desempaquetar aquí evita que cada componente
    // tenga que recordar ese detalle del backend.
    return this.http.get<readonly ChecklistTemplate[]>(this.baseUrl, { params }).pipe(
      map((matches) => {
        const [template] = matches;

        if (template === undefined) {
          throw new ApiError(
            `No existe la plantilla ${templateId} en su versión ${version}.`,
            404,
          );
        }

        return template;
      }),
      catchError(toApiError),
    );
  }
}
