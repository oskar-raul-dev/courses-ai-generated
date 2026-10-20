import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError } from 'rxjs';

import { AppConfigService } from '../config/app-config.service';
import { Finding } from '../models/finding.model';
import { Inspection, InspectionAnswer } from '../models/inspection.model';
import { toApiError } from './api-error';

/** Lo que hace falta para crear una inspección. El resto lo pone el servicio. */
export interface NewInspection {
  readonly assetId: string;
  readonly inspectorId: string;
  readonly templateId: string;
  /** La versión resuelta al empezar. A partir de aquí es inmutable. Fase 7. */
  readonly templateVersion: number;
  readonly startedAt: string;
}

@Injectable({ providedIn: 'root' })
export class InspectionApiService {
  private readonly http = inject(HttpClient);
  private readonly appConfig = inject(AppConfigService);

  private readonly baseUrl = `${this.appConfig.current.apiBaseUrl}/inspections`;

  getAll(): Observable<readonly Inspection[]> {
    return this.http.get<readonly Inspection[]>(this.baseUrl).pipe(catchError(toApiError));
  }

  getById(id: number): Observable<Inspection> {
    return this.http.get<Inspection>(`${this.baseUrl}/${id}`).pipe(catchError(toApiError));
  }

  /** La Fase 9 vive de esto; aquí sólo se deja escrito el endpoint. */
  getFindings(inspectionId: number): Observable<readonly Finding[]> {
    return this.http
      .get<readonly Finding[]>(`${this.baseUrl}/${inspectionId}/findings`)
      .pipe(catchError(toApiError));
  }

  create(draft: NewInspection): Observable<Inspection> {
    const created = {
      ...draft,
      // Nace agendada y sin respuestas. El primer guardado la pasa a
      // in_progress: el estado lo mueve el trabajo, no un botón aparte.
      status: 'scheduled' as const,
      completedAt: null,
      answers: [],
    };

    return this.http.post<Inspection>(this.baseUrl, created).pipe(catchError(toApiError));
  }

  /**
   * 💸 DEUDA TÉCNICA INTENCIONAL
   * Cada guardado manda el array `answers` ENTERO, aunque haya cambiado una
   * letra de una nota. Con cuatro ítems son dos kilobytes; con los sesenta de
   * una plantilla de subestación eléctrica, cada tecla mueve treinta.
   * Lo correcto es un PATCH por respuesta: `PATCH /inspections/500/answers/main-cable`.
   * SE PAGA A MEDIAS EN LA FASE 11, midiendo el costo con el volumen del
   * dashboard delante. Entera no se paga, y el motivo es de alcance: las
   * respuestas son un array anidado dentro de la inspección, no una colección
   * propia, así que un endpoint por respuesta hay que escribirlo en el mock —
   * trabajo de backend que no enseña ni una línea de Angular. El ejercicio 31
   * lo diseña y mide el ahorro para que la decisión sea tuya y no mía.
   */
  saveAnswers(
    id: number,
    answers: readonly InspectionAnswer[],
    status: Inspection['status'],
  ): Observable<Inspection> {
    // PATCH y no PUT: mandamos dos campos de la inspección, no la entidad
    // entera. json-server los mezcla con lo que ya hay, así que `startedAt` y
    // `templateVersion` no pueden perderse por accidente — y eso último
    // importa más de lo que parece, porque `templateVersion` es el invariante.
    return this.http
      .patch<Inspection>(`${this.baseUrl}/${id}`, { answers, status })
      .pipe(catchError(toApiError));
  }

  complete(
    id: number,
    answers: readonly InspectionAnswer[],
    completedAt: string,
  ): Observable<Inspection> {
    return this.http
      .patch<Inspection>(`${this.baseUrl}/${id}`, { answers, status: 'completed', completedAt })
      .pipe(catchError(toApiError));
  }

  /**
   * Un PATCH de un solo campo. Deliberadamente no acepta cualquier estado: el
   * tipo lo limita a los dos que la Fase 9 estrena. Un `setStatus` genérico
   * permitiría cualquier transición desde cualquier sitio, que es justo lo que
   * `canTransition` existe para impedir.
   */
  setStatus(id: number, status: 'approved' | 'rejected'): Observable<Inspection> {
    return this.http
      .patch<Inspection>(`${this.baseUrl}/${id}`, { status })
      .pipe(catchError(toApiError));
  }
}
