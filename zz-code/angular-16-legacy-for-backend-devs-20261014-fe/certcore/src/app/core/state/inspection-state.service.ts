import { Injectable, inject } from '@angular/core';
import { BehaviorSubject, Observable, Subscription, combineLatest, concatMap, distinctUntilChanged, filter, map, tap, throwError } from 'rxjs';

import { ApiError } from '../api/api-error';
import { FindingApiService } from '../api/finding-api.service';
import { InspectionApiService } from '../api/inspection-api.service';
import { TemplateApiService } from '../api/template-api.service';
import { AuthService } from '../auth.service';
import { computeProgress } from '../domain/inspection-progress';
import { BusinessRuleError, canTransition } from '../domain/inspection-rules';
import {
  InspectionFinding,
  deriveFindings,
  summarizeFindings,
} from '../domain/inspection-findings';
import { Inspection, InspectionAnswer } from '../models/inspection.model';
import { FeatureState, createInitialState } from './feature-state.model';

/**
 * El listado de inspecciones sigue el molde de la Fase 4. Lo que se añade aquí
 * es la máquina de estados: completar, aprobar y rechazar pasan por estas
 * funciones y no por la pantalla, porque las reglas tienen que cumplirse
 * también fuera de ella.
 */
@Injectable({ providedIn: 'root' })
export class InspectionStateService {
  private readonly inspectionApi = inject(InspectionApiService);
  private readonly templateApi = inject(TemplateApiService);
  private readonly findingApi = inject(FindingApiService);
  private readonly authService = inject(AuthService);

  private readonly stateSubject = new BehaviorSubject<FeatureState<Inspection>>(
    createInitialState<Inspection>(),
  );

  /** La carga en curso. Ver load() y reset(). */
  private loading?: Subscription;

  readonly state$: Observable<FeatureState<Inspection>> = this.stateSubject.asObservable();
  readonly inspections$ = this.state$.pipe(map((state) => state.items), distinctUntilChanged());
  readonly loading$ = this.state$.pipe(map((state) => state.loading), distinctUntilChanged());
  readonly error$ = this.state$.pipe(map((state) => state.error), distinctUntilChanged());

  constructor() {
    this.authService.currentUser$
      .pipe(filter((user) => user === null))
      .subscribe(() => this.reset());
  }

  load(): void {
    this.patch({ loading: true, error: null });

    // La carga anterior se cancela antes de empezar otra, y reset() también la
    // cancela: una respuesta que llega después de cerrar sesión no puede volver
    // a llenar el estado con los datos del usuario anterior (medido en navegador).
    this.loading?.unsubscribe();
    this.loading = this.inspectionApi.getAll().subscribe({
      next: (items) => this.patch({ items, loading: false }),
      error: (error: unknown) =>
        this.patch({
          loading: false,
          error:
            error instanceof ApiError ? error.message : 'No se pudieron cargar las inspecciones.',
        }),
    });
  }

  /**
   * Los hallazgos de una inspección, derivados. Es una CONSULTA y no estado: no
   * se guarda en el BehaviorSubject. Un derivado dentro del estado es el mismo
   * error que un derivado dentro de la base de datos, sólo que más rápido de cometer.
   */
  findingsOf(inspection: Inspection): Observable<readonly InspectionFinding[]> {
    return combineLatest([
      // 🧭 La versión que la inspección GUARDÓ. La misma línea que en la Fase 7
      // y la Fase 8: cuando algo se repite idéntico y nadie lo abstrae, es
      // porque abstraerlo lo volvería más fácil de olvidar.
      this.templateApi.getByVersion(inspection.templateId, inspection.templateVersion),
      this.findingApi.getByInspection(inspection.id),
    ]).pipe(map(([template, stored]) => deriveFindings(template, inspection, stored)));
  }

  /**
   * Cerrar la inspección. La condición ya la calculaba `computeProgress` desde
   * la Fase 8; lo nuevo es que ahora se comprueba AQUÍ y no sólo en el
   * `[disabled]` de un botón. Un botón deshabilitado es una cortesía; esto es
   * la regla.
   */
  complete(inspection: Inspection, answers: readonly InspectionAnswer[]): Observable<Inspection> {
    if (!canTransition(inspection.status, 'completed')) {
      return throwError(
        () => new BusinessRuleError(`Una inspección ${inspection.status} no se puede completar.`),
      );
    }

    return this.templateApi
      .getByVersion(inspection.templateId, inspection.templateVersion)
      .pipe(
        // concatMap y no switchMap: detrás viene una ESCRITURA. Regla de la
        // Fase 6.
        concatMap((template) => {
          const progress = computeProgress(template, answers);

          if (!progress.canComplete) {
            const missing = [...progress.unanswered, ...progress.missingEvidence];

            return throwError(
              () =>
                new BusinessRuleError(
                  `Faltan respuestas o evidencia en: ${missing.join(', ')}.`,
                ),
            );
          }

          return this.inspectionApi.complete(inspection.id, answers, new Date().toISOString());
        }),
        tap(() => this.load()),
      );
  }

  /**
   * ⭐ APROBAR. La operación que esta fase existe para poder negar.
   *
   * Aprobar es irreversible (alcance §5), así que la comprobación no puede
   * vivir en la pantalla: tiene que estar en el camino por el que pasa
   * cualquiera que apruebe, hoy y dentro de dos años.
   */
  approve(inspection: Inspection): Observable<Inspection> {
    return this.decide(inspection, 'approved');
  }

  /** Rechazar. Misma puerta, distinta salida: aquí los hallazgos no bloquean. */
  reject(inspection: Inspection): Observable<Inspection> {
    return this.decide(inspection, 'rejected');
  }

  reset(): void {
    this.loading?.unsubscribe();
    this.stateSubject.next(createInitialState<Inspection>());
  }

  private decide(inspection: Inspection, to: 'approved' | 'rejected'): Observable<Inspection> {
    if (!canTransition(inspection.status, to)) {
      return throwError(
        () =>
          new BusinessRuleError(
            `Una inspección ${inspection.status} no se puede pasar a ${to}. Sólo se decide sobre inspecciones completadas.`,
          ),
      );
    }

    // Rechazar NO se comprueba contra los hallazgos: se rechaza precisamente
    // porque hay problemas. Comprobar aquí sería impedir rechazar una
    // inspección con un hallazgo crítico, que es la única que hay que rechazar.
    if (to === 'rejected') {
      return this.inspectionApi.setStatus(inspection.id, 'rejected').pipe(tap(() => this.load()));
    }

    return this.findingsOf(inspection).pipe(
      map(summarizeFindings),
      concatMap((summary) => {
        if (summary.blocking.length > 0) {
          return throwError(
            () =>
              new BusinessRuleError(
                `No se puede aprobar: hay hallazgos críticos sin resolver en ${summary.blocking.join(', ')}.`,
              ),
          );
        }

        if (summary.undetermined.length > 0) {
          return throwError(
            () =>
              new BusinessRuleError(
                `No se puede aprobar: el sistema no pudo clasificar las respuestas de ${summary.undetermined.join(', ')}. Revísalas antes de decidir.`,
              ),
          );
        }

        return this.inspectionApi.setStatus(inspection.id, 'approved');
      }),
      tap(() => this.load()),
    );
  }

  private patch(changes: Partial<FeatureState<Inspection>>): void {
    this.stateSubject.next({ ...this.stateSubject.value, ...changes });
  }
}
