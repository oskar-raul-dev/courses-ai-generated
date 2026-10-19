import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError } from 'rxjs';

import { environment } from '../../../environments/environment';
import { Client } from '../models/client.model';
import { toApiError } from './api-error';

@Injectable({ providedIn: 'root' })
export class ClientApiService {
  private readonly http = inject(HttpClient);

  private readonly baseUrl = `${environment.apiBaseUrl}/clients`;

  getAll(): Observable<readonly Client[]> {
    return this.http.get<readonly Client[]>(this.baseUrl).pipe(catchError(toApiError));
  }

  getById(id: number): Observable<Client> {
    // Aquí sí pedimos un recurso por su id, y json-server devuelve el objeto
    // solo. Es la diferencia con el filtro de getByVersion, y confundirlas es
    // el error más frecuente al escribir el tercer servicio.
    return this.http.get<Client>(`${this.baseUrl}/${id}`).pipe(catchError(toApiError));
  }
}
