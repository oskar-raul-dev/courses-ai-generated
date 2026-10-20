import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError, map } from 'rxjs';

import { environment } from '../../../environments/environment';
import { Client } from '../models/client.model';
import { toApiError } from './api-error';

/** Un cliente todavía sin `id`: lo asigna el servidor al crearlo. */
export type ClientDraft = Omit<Client, 'id'>;

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

  /**
   * Búsqueda por razón social. json-server implementa `q` como búsqueda de
   * texto completo sobre todos los campos del recurso, así que buscar "900"
   * también encuentra por NIT — y eso es exactamente lo que un usuario espera
   * de una caja de búsqueda, así que se deja.
   */
  search(term: string): Observable<readonly Client[]> {
    const trimmed = term.trim();
    const params = trimmed === '' ? new HttpParams() : new HttpParams().set('q', trimmed);

    return this.http
      .get<readonly Client[]>(this.baseUrl, { params })
      .pipe(catchError(toApiError));
  }

  create(draft: ClientDraft): Observable<Client> {
    return this.http.post<Client>(this.baseUrl, draft).pipe(catchError(toApiError));
  }

  update(client: Client): Observable<Client> {
    // PUT y no PATCH: el formulario manda la entidad entera, así que reemplazar
    // es honesto. Un PATCH con el objeto completo miente sobre la intención.
    return this.http
      .put<Client>(`${this.baseUrl}/${client.id}`, client)
      .pipe(catchError(toApiError));
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`).pipe(catchError(toApiError));
  }

  /**
   * ¿Existe ya este NIT? `exceptId` es el cliente que se está editando: sin él,
   * editar la razón social de un cliente daría "NIT repetido" contra sí mismo,
   * que es el bug número uno de los validadores de unicidad.
   */
  existsByTaxId(taxId: string, exceptId: number | null): Observable<boolean> {
    const params = new HttpParams().set('taxId', taxId);

    return this.http.get<readonly Client[]>(this.baseUrl, { params }).pipe(
      map((matches) => matches.some((client) => client.id !== exceptId)),
      catchError(toApiError),
    );
  }
}
