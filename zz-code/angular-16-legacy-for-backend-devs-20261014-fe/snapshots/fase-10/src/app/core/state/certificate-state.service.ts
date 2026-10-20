import { Injectable, inject } from '@angular/core';
import {
  BehaviorSubject,
  Observable,
  concatMap,
  map,
  tap,
  throwError,
} from 'rxjs';

import { CertificateApiService } from '../api/certificate-api.service';
import { CertificateView, buildCertificateView } from '../domain/certificate-status';
import { computeValidity } from '../domain/certificate-validity';
import { canIssueCertificate, summarizeFindings } from '../domain/inspection-findings';
import { BusinessRuleError } from '../domain/inspection-rules';
import { Certificate } from '../models/certificate.model';
import { Inspection } from '../models/inspection.model';
import { Instant, nowInstant, toBusinessDay } from '../time/business-day';
import { InspectionStateService } from './inspection-state.service';

interface CertificateState {
  readonly items: readonly Certificate[];
  readonly loading: boolean;
  readonly error: string | null;
}

@Injectable({ providedIn: 'root' })
export class CertificateStateService {
  private readonly certificateApi = inject(CertificateApiService);
  private readonly inspectionState = inject(InspectionStateService);

  private readonly stateSubject = new BehaviorSubject<CertificateState>({
    items: [],
    loading: false,
    error: null,
  });

  readonly state$: Observable<CertificateState> = this.stateSubject.asObservable();

  /**
   * Los certificados con su estado ya derivado. `nowInstant()` se llama DENTRO
   * del map, así que cada emisión recalcula. Que el estado no cambie por el paso
   * del tiempo es la 💸 declarada en el estado derivado.
   */
  readonly views$: Observable<readonly CertificateView[]> = this.state$.pipe(
    map((state) => {
      const now = nowInstant();

      return state.items.map((certificate) => buildCertificateView(certificate, now));
    }),
  );

  load(): void {
    this.stateSubject.next({ ...this.stateSubject.value, loading: true, error: null });

    this.certificateApi.getAll().subscribe({
      next: (items) => this.stateSubject.next({ items, loading: false, error: null }),
      error: (error: unknown) =>
        this.stateSubject.next({
          items: [],
          loading: false,
          error: error instanceof Error ? error.message : 'No se pudieron cargar los certificados.',
        }),
    });
  }

  /** Un certificado con su vista derivada, o `undefined` si no existe en la lista cargada. */
  viewOf(id: string): Observable<CertificateView | undefined> {
    return this.views$.pipe(map((views) => views.find((view) => view.certificate.id === id)));
  }

  /**
   * ⭐ EMITIR. Tres puertas, en este orden y por este motivo:
   *   1. ¿Ya tiene certificado? Es lo más barato de comprobar y lo que más veces
   *      va a pasar (alguien pulsa dos veces).
   *   2. ¿Se puede emitir? Aprobada y sin hallazgos críticos bloqueantes. Esa
   *      regla vive en `canIssueCertificate`, no aquí.
   *   3. Sólo entonces se calcula la vigencia y se escribe.
   */
  issue(inspection: Inspection): Observable<Certificate> {
    return this.certificateApi.getByInspection(inspection.id).pipe(
      concatMap((existing) => {
        if (existing.length > 0) {
          return throwError(
            () =>
              new BusinessRuleError(
                `La inspección ${inspection.id} ya tiene el certificado ${existing[0].id}. Para reemplazarlo hay que revocarlo primero.`,
              ),
          );
        }

        return this.inspectionState.findingsOf(inspection).pipe(map(summarizeFindings));
      }),
      concatMap((summary) => {
        if (!canIssueCertificate(inspection, summary)) {
          // La FUNCIÓN decide; estas cadenas sólo explican.
          const reason =
            inspection.status !== 'approved'
              ? `la inspección está ${inspection.status} y sólo se certifica lo aprobado`
              : `hay hallazgos críticos sin resolver en ${summary.blocking.join(', ')}`;

          return throwError(
            () => new BusinessRuleError(`No se puede emitir el certificado: ${reason}.`),
          );
        }

        const issuedAt = nowInstant();
        const validity = computeValidity(issuedAt);

        return this.certificateApi.issue({
          id: buildCertificateId(issuedAt, inspection.id),
          inspectionId: inspection.id,
          issuedAt,
          validUntil: validity.until,
          // `issued` es LO ÚNICO cierto en este instante. Después, este campo es historia.
          status: 'issued',
          revokedAt: null,
        });
      }),
      tap(() => this.load()),
    );
  }

  /**
   * Revocar. Cuando aparece un hallazgo crítico en una inspección ya aprobada, la
   * inspección NO se desaprueba —aprobar es irreversible— y el certificado SÍ se
   * revoca. Ésa es la única salida coherente con las dos reglas a la vez.
   */
  revoke(certificate: Certificate): Observable<Certificate> {
    if (certificate.revokedAt !== null) {
      return throwError(
        () => new BusinessRuleError(`El certificado ${certificate.id} ya estaba revocado.`),
      );
    }

    return this.certificateApi.revoke(certificate.id, nowInstant()).pipe(tap(() => this.load()));
  }
}

/**
 * `CERT-2024-000502`: el año del día de negocio de la emisión, más el id de la
 * inspección a seis dígitos. Reproduce el formato de la semilla.
 *
 * ⚠️ En un sistema real el identificador de un documento oficial lo asigna el
 * backend, en una transacción. Aquí lo compone el cliente, y con dos pestañas
 * abiertas sobre la misma inspección saldrían dos ids idénticos. La regla de
 * "una inspección, un certificado" de `issue()` lo tapa en la práctica; no lo resuelve.
 */
function buildCertificateId(issuedAt: Instant, inspectionId: number): string {
  const year = toBusinessDay(issuedAt).slice(0, 4);

  return `CERT-${year}-${String(inspectionId).padStart(6, '0')}`;
}
