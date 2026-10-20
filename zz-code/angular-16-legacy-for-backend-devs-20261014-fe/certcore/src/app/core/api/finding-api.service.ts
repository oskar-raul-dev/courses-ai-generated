import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError, map } from 'rxjs';

import { AppConfigService } from '../config/app-config.service';
import { Finding } from '../models/finding.model';
import { toApiError } from './api-error';

@Injectable({ providedIn: 'root' })
export class FindingApiService {
  private readonly http = inject(HttpClient);
  private readonly appConfig = inject(AppConfigService);

  private readonly baseUrl = `${this.appConfig.current.apiBaseUrl}/findings`;

  /**
   * `/findings?inspectionId=503` y no `/inspections/503/findings`: las dos
   * rutas las sirve json-server porque `findings` es colección de primer nivel
   * con `inspectionId` dentro, y la de query param es la que acepta filtros
   * adicionales sin cambiar de forma.
   */
  getByInspection(inspectionId: number): Observable<readonly Finding[]> {
    const params = new HttpParams().set('inspectionId', inspectionId);

    return this.http
      .get<readonly Finding[]>(this.baseUrl, { params })
      .pipe(map((rows) => rows.map(normalizeFinding)), catchError(toApiError));
  }

  /**
   * Todos los hallazgos guardados, de una vez. Lo usa el panel, que necesita
   * la parte humana —descripción y fecha de resolución— de todas las
   * inspecciones a la vez y no de una.
   */
  getAll(): Observable<readonly Finding[]> {
    return this.http
      .get<readonly Finding[]>(this.baseUrl)
      .pipe(map((rows) => rows.map(normalizeFinding)), catchError(toApiError));
  }

  /** Marcar resuelto es poner una fecha. No hay más flujo, y es a propósito. */
  resolve(id: number, resolvedAt: string): Observable<Finding> {
    return this.http
      .patch<Finding>(`${this.baseUrl}/${id}`, { resolvedAt })
      .pipe(map(normalizeFinding), catchError(toApiError));
  }

  /** Reabrir es quitarla. `null` explícito, nunca borrar el campo del objeto. */
  reopen(id: number): Observable<Finding> {
    return this.http
      .patch<Finding>(`${this.baseUrl}/${id}`, { resolvedAt: null })
      .pipe(map(normalizeFinding), catchError(toApiError));
  }
}

/**
 * ⭐ EL ARREGLO DEL INCIDENTE 12, Y CABE EN UNA LÍNEA.
 *
 * `http.get<Finding[]>()` no comprueba nada: el genérico es una promesa del
 * programador, no una validación. Si el backend manda una fila SIN el campo
 * `resolvedAt`, entra como `undefined` en un objeto que el tipo declara como
 * `string | null`, y todo compila.
 *
 * A partir de ahí, `resolvedAt === null` devuelve `false` para un hallazgo que
 * nadie resolvió jamás, el `critical` deja de bloquear, y el certificado sale.
 * Las tres posibilidades del borde —valor, `null` y campo ausente— se reducen
 * a DOS aquí, en un solo sitio.
 */
function normalizeFinding(raw: Finding): Finding {
  return { ...raw, resolvedAt: raw.resolvedAt ?? null };
}
