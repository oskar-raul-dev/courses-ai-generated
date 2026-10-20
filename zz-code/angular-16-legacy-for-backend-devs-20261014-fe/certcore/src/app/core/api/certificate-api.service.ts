import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError, map } from 'rxjs';

import { AppConfigService } from '../config/app-config.service';
import { Certificate } from '../models/certificate.model';
import { Instant } from '../time/business-day';
import { toApiError } from './api-error';

@Injectable({ providedIn: 'root' })
export class CertificateApiService {
  private readonly http = inject(HttpClient);
  private readonly appConfig = inject(AppConfigService);

  private readonly baseUrl = `${this.appConfig.current.apiBaseUrl}/certificates`;

  getAll(): Observable<readonly Certificate[]> {
    return this.http
      .get<readonly Certificate[]>(this.baseUrl)
      .pipe(map((rows) => rows.map(normalizeCertificate)), catchError(toApiError));
  }

  /**
   * Devuelve un array y no un `Certificate | null`: json-server filtra y devuelve
   * lista. El "como mucho uno" es una regla que se hace cumplir en el servicio.
   */
  getByInspection(inspectionId: number): Observable<readonly Certificate[]> {
    const params = new HttpParams().set('inspectionId', inspectionId);

    return this.http
      .get<readonly Certificate[]>(this.baseUrl, { params })
      .pipe(map((rows) => rows.map(normalizeCertificate)), catchError(toApiError));
  }

  issue(certificate: Certificate): Observable<Certificate> {
    return this.http
      .post<Certificate>(this.baseUrl, certificate)
      .pipe(map(normalizeCertificate), catchError(toApiError));
  }

  /** Revocar es poner una fecha, igual que resolver un hallazgo. */
  revoke(id: string, revokedAt: Instant): Observable<Certificate> {
    return this.http
      .patch<Certificate>(`${this.baseUrl}/${id}`, { revokedAt })
      .pipe(map(normalizeCertificate), catchError(toApiError));
  }
}

/** El mismo `?? null` de `normalizeFinding` de la Fase 9, sobre el campo equivalente. */
function normalizeCertificate(raw: Certificate): Certificate {
  return { ...raw, revokedAt: raw.revokedAt ?? null };
}
