import { Injectable, inject } from '@angular/core';
import {
  BehaviorSubject,
  Observable,
  catchError,
  combineLatest,
  concatMap,
  distinctUntilChanged,
  filter,
  map,
  of,
  tap,
} from 'rxjs';

import { ApiError } from '../api/api-error';
import { TemplateApiService, buildTemplateRowId } from '../api/template-api.service';
import { AuthService } from '../auth.service';
import { TemplateFamily, groupIntoFamilies } from '../domain/template-family';
import { TemplateResolution, resolveTemplateVersion } from '../domain/resolve-template-version';
import { ChecklistItem, ChecklistTemplate } from '../models/checklist-template.model';
import { BusinessDay, addDays } from '../time/business-day';

/**
 * El estado de esta feature NO es `FeatureState<ChecklistTemplate>`, y es la
 * primera vez que el molde de la Fase 4 se queda corto. Dos diferencias:
 *
 *   - `versions` en vez de `items`: son filas de versión, no entidades sueltas,
 *     y la pantalla siempre las mira agrupadas.
 *   - `selectedFamilyId` en vez de `selected`: se selecciona una FAMILIA, que
 *     es un concepto que no existe como fila en el backend.
 *
 * Todo lo demás del molde se mantiene igual, porque lo demás sí servía: sujeto
 * privado, Observable público de sólo lectura, un único `patch()`, `readonly`
 * de punta a punta y reseteo al cerrar sesión. Romper un patrón no es tirarlo:
 * es cambiar la pieza que estorba y dejar quietas las que no.
 */
export interface TemplateState {
  readonly versions: readonly ChecklistTemplate[];
  readonly selectedFamilyId: string | null;
  readonly loading: boolean;
  readonly error: string | null;
}

function createInitialTemplateState(): TemplateState {
  return { versions: [], selectedFamilyId: null, loading: false, error: null };
}

/** Lo que el editor entrega para publicar. Sin `id` ni `validUntil`: los pone el servicio. */
export interface NewVersionDraft {
  readonly templateId: string;
  readonly version: number;
  readonly validFrom: BusinessDay;
  readonly items: readonly ChecklistItem[];
}

@Injectable({ providedIn: 'root' })
export class TemplateStateService {
  private readonly templateApi = inject(TemplateApiService);
  private readonly authService = inject(AuthService);

  private readonly stateSubject = new BehaviorSubject<TemplateState>(createInitialTemplateState());

  readonly state$: Observable<TemplateState> = this.stateSubject.asObservable();

  readonly loading$ = this.state$.pipe(map((state) => state.loading), distinctUntilChanged());
  readonly error$ = this.state$.pipe(map((state) => state.error), distinctUntilChanged());

  readonly families$: Observable<readonly TemplateFamily[]> = this.state$.pipe(
    map((state) => groupIntoFamilies(state.versions)),
    distinctUntilChanged(),
  );

  readonly selectedFamily$: Observable<TemplateFamily | null> = combineLatest([
    this.families$,
    this.state$.pipe(map((state) => state.selectedFamilyId), distinctUntilChanged()),
  ]).pipe(
    map(([families, selectedFamilyId]) =>
      selectedFamilyId === null
        ? null
        : families.find((family) => family.templateId === selectedFamilyId) ?? null,
    ),
  );

  /**
   * ⚠️ "La más alta de cada familia", que NO es "la vigente". Sigue aquí porque
   * el editor la usa como punto de partida —se edita a partir de la última—,
   * y con ese uso es correcta. Usarla para decidir con qué plantilla se hace
   * una inspección es el incidente 08. La pregunta de la vigencia la contesta
   * `resolveForDay()`, y no hay atajo.
   */
  readonly latestVersions$: Observable<readonly ChecklistTemplate[]> = this.families$.pipe(
    map((families) => families.map((family) => family.latest)),
  );

  constructor() {
    this.authService.currentUser$
      .pipe(filter((user) => user === null))
      .subscribe(() => this.reset());
  }

  load(): void {
    this.patch({ loading: true, error: null });

    this.templateApi.getAll().subscribe({
      next: (versions) => this.patch({ versions, loading: false }),
      error: (error: unknown) => {
        this.patch({
          loading: false,
          error:
            error instanceof ApiError ? error.message : 'No se pudieron cargar las plantillas.',
        });
      },
    });
  }

  selectFamily(templateId: string | null): void {
    this.patch({ selectedFamilyId: templateId });
  }

  /**
   * ¿Qué versión de esta familia rige este día? Es una CONSULTA, no estado: no
   * guarda nada y su respuesta caduca. Por eso devuelve un Observable derivado
   * y no hay ningún `resolvedTemplate` dentro de `TemplateState`.
   */
  resolveForDay(templateId: string, day: BusinessDay): Observable<TemplateResolution> {
    return this.families$.pipe(
      map((families) => families.find((family) => family.templateId === templateId)),
      map((family) =>
        family === undefined
          ? ({ status: 'none', day } satisfies TemplateResolution)
          : resolveTemplateVersion(family.versions, day),
      ),
    );
  }

  /**
   * ⭐ PUBLICAR. La operación más peligrosa del sistema, y merece leerse dos
   * veces: son DOS escrituras y el backend no tiene transacciones.
   *
   * Orden elegido: primero se CIERRA la anterior, después se CREA la nueva.
   * Si falla la segunda, queda un hueco —`none`— y nadie puede empezar una
   * inspección hasta que alguien lo arregle: ruidoso, visible e inofensivo.
   * Con el orden contrario, un fallo dejaría dos versiones vigentes a la vez
   * —`ambiguous`—, y ahí el daño depende de que todo el que consulte se niegue
   * a elegir. Nuestro resolver se niega; el reporte que alguien escriba dentro
   * de dos años, quizá no.
   *
   * Lo correcto de verdad es un endpoint que haga las dos cosas o ninguna.
   * Eso es trabajo de backend, está en los 📌 y es el ejercicio 31.
   */
  publishNewVersion(
    draft: NewVersionDraft,
    previous: ChecklistTemplate | null,
  ): Observable<ChecklistTemplate> {
    const created: ChecklistTemplate = {
      id: buildTemplateRowId(draft.templateId, draft.version),
      templateId: draft.templateId,
      version: draft.version,
      validFrom: draft.validFrom,
      // Nace abierta: la que se cierra es la anterior. Una versión con fecha de
      // fin en el momento de nacer sería una versión que ya sabe cuándo muere,
      // y eso lo decide la norma siguiente, que todavía no existe.
      validUntil: null,
      items: draft.items,
    };

    const close$: Observable<ChecklistTemplate | null> =
      previous === null || previous.validUntil !== null
        ? // No hay anterior, o ya estaba cerrada. `of(null)` mantiene la tubería
          // con una sola forma en vez de partir el método en dos caminos.
          of(null)
        : this.templateApi.close(previous, addDays(draft.validFrom, -1));

    return close$.pipe(
      // concatMap y NO switchMap. Es la regla que la Fase 6 dejó escrita: para
      // leer, switchMap; para escribir, jamás. Cancelar el cierre a mitad
      // dejaría el sistema en el peor de los dos estados rotos.
      concatMap(() => this.templateApi.create(created)),
      tap(() => this.load()),
    );
  }

  /** Retirar una familia: cerrar su versión abierta y no crear ninguna. */
  retire(template: ChecklistTemplate, lastDay: BusinessDay): Observable<ChecklistTemplate> {
    return this.templateApi.close(template, lastDay).pipe(tap(() => this.load()));
  }

  reset(): void {
    this.stateSubject.next(createInitialTemplateState());
  }

  private patch(changes: Partial<TemplateState>): void {
    this.stateSubject.next({ ...this.stateSubject.value, ...changes });
  }
}
