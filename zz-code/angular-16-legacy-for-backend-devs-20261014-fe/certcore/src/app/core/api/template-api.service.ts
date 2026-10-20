import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError, map } from 'rxjs';

import { AppConfigService } from '../config/app-config.service';
import { ChecklistTemplate } from '../models/checklist-template.model';
import { BusinessDay } from '../time/business-day';
import { ApiError, toApiError } from './api-error';

/** El `id` de la fila, compuesto. Se arma en un solo sitio para que nadie lo teclee. */
export function buildTemplateRowId(templateId: string, version: number): string {
  return `${templateId}-v${version}`;
}

@Injectable({ providedIn: 'root' })
export class TemplateApiService {
  // inject() y no constructor: este servicio es de 2024. En el mismo directorio
  // vive AuthService, que es de 2021 y usa constructor. Los dos están bien; lo
  // que no estaría bien es mezclar las dos formas dentro de un archivo.
  private readonly http = inject(HttpClient);
  private readonly appConfig = inject(AppConfigService);

  private readonly baseUrl = `${this.appConfig.current.apiBaseUrl}/templates`;

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

  /** Todas las versiones de una familia. El orden lo pone `groupIntoFamilies`. */
  getFamily(templateId: string): Observable<readonly ChecklistTemplate[]> {
    const params = new HttpParams().set('templateId', templateId);

    return this.http
      .get<readonly ChecklistTemplate[]>(this.baseUrl, { params })
      .pipe(catchError(toApiError));
  }

  /**
   * Crea una versión. El `id` compuesto viaja en el cuerpo: json-server lo
   * respeta si se lo das, y aquí lo damos porque la clave es del dominio y no
   * del backend. Si lo dejáramos autogenerar, tendríamos dos identificadores
   * para la misma cosa.
   */
  create(template: ChecklistTemplate): Observable<ChecklistTemplate> {
    return this.http.post<ChecklistTemplate>(this.baseUrl, template).pipe(catchError(toApiError));
  }

  /**
   * Cierra una versión poniéndole fecha de fin. Es lo único que se le puede
   * cambiar a una versión publicada: sus ítems son historia y el histórico no
   * se edita.
   */
  close(template: ChecklistTemplate, lastDay: BusinessDay): Observable<ChecklistTemplate> {
    const closed: ChecklistTemplate = { ...template, validUntil: lastDay };

    return this.http
      .put<ChecklistTemplate>(`${this.baseUrl}/${template.id}`, closed)
      .pipe(catchError(toApiError));
  }

  // Sin delete(), y esta vez no es alcance: es dominio. Borrar una versión deja
  // huérfanas a todas las inspecciones que la usaron, y una inspección sin su
  // plantilla es un certificado que no se puede volver a imprimir. Una versión
  // se cierra; no se borra. Que la operación no exista es la mejor forma de
  // impedirla.
}
