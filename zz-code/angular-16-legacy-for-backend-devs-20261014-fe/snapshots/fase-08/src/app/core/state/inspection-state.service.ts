import { Injectable, inject } from '@angular/core';
import { BehaviorSubject, Observable, distinctUntilChanged, filter, map } from 'rxjs';

import { ApiError } from '../api/api-error';
import { InspectionApiService } from '../api/inspection-api.service';
import { AuthService } from '../auth.service';
import { Inspection } from '../models/inspection.model';
import { FeatureState, createInitialState } from './feature-state.model';

/**
 * Aquí el molde de la Fase 4 se usa tal cual, y decirlo importa. Después de que
 * la Fase 7 lo rompiera con TemplateState, la tentación es romperlo cada vez. El
 * listado de inspecciones ES "cargar una lista", así que FeatureState le va bien.
 */
@Injectable({ providedIn: 'root' })
export class InspectionStateService {
  private readonly inspectionApi = inject(InspectionApiService);
  private readonly authService = inject(AuthService);

  private readonly stateSubject = new BehaviorSubject<FeatureState<Inspection>>(
    createInitialState<Inspection>(),
  );

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

    this.inspectionApi.getAll().subscribe({
      next: (items) => this.patch({ items, loading: false }),
      error: (error: unknown) =>
        this.patch({
          loading: false,
          error:
            error instanceof ApiError ? error.message : 'No se pudieron cargar las inspecciones.',
        }),
    });
  }

  reset(): void {
    this.stateSubject.next(createInitialState<Inspection>());
  }

  private patch(changes: Partial<FeatureState<Inspection>>): void {
    this.stateSubject.next({ ...this.stateSubject.value, ...changes });
  }
}
