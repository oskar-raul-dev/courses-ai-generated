import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError } from 'rxjs';

import { AppConfigService } from '../config/app-config.service';
import { Asset } from '../models/asset.model';
import { toApiError } from './api-error';

@Injectable({ providedIn: 'root' })
export class AssetApiService {
  private readonly http = inject(HttpClient);
  private readonly appConfig = inject(AppConfigService);

  private readonly baseUrl = `${this.appConfig.current.apiBaseUrl}/assets`;

  getAll(): Observable<readonly Asset[]> {
    return this.http.get<readonly Asset[]>(this.baseUrl).pipe(catchError(toApiError));
  }

  getByClient(clientId: number): Observable<readonly Asset[]> {
    const params = new HttpParams().set('clientId', clientId);

    return this.http
      .get<readonly Asset[]>(this.baseUrl, { params })
      .pipe(catchError(toApiError));
  }

  getById(id: string): Observable<Asset> {
    return this.http.get<Asset>(`${this.baseUrl}/${id}`).pipe(catchError(toApiError));
  }

  /**
   * El `id` de un activo lo escribe el usuario —"ASC-CENTRAL-03" está pintado
   * en el equipo—, así que va dentro del cuerpo y no lo asigna el servidor.
   * Es la diferencia con `ClientDraft`, y la razón de que aquí no exista un
   * `AssetDraft`.
   */
  create(asset: Asset): Observable<Asset> {
    return this.http.post<Asset>(this.baseUrl, asset).pipe(catchError(toApiError));
  }

  update(asset: Asset): Observable<Asset> {
    return this.http
      .put<Asset>(`${this.baseUrl}/${asset.id}`, asset)
      .pipe(catchError(toApiError));
  }

  // Sin delete(), y no es un olvido: un activo con inspecciones y certificados
  // detrás no se borra, se da de baja. Dar de baja es un cambio de estado y
  // exige un campo que el modelo no tiene todavía. Está en los 📌.
}
