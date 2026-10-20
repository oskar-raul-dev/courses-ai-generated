import { Injectable, inject } from '@angular/core';
import { BehaviorSubject, Observable, Subscription, distinctUntilChanged, filter, map, tap, throwError } from 'rxjs';

import { ApiError } from '../api/api-error';
import { AssetApiService } from '../api/asset-api.service';
import { AuthService } from '../auth.service';
import { BusinessRuleError } from '../domain/inspection-rules';
import { changesClient } from '../domain/asset-rules';
import { Asset } from '../models/asset.model';
import { FeatureState, createInitialState } from './feature-state.model';

/**
 * Molde de ClientStateService (Fase 6 §5.5) sin el buscador: el listado de
 * activos carga todo y la pantalla no filtra todavía. Se escribe igual para que
 * las dos features se lean igual.
 */
@Injectable({ providedIn: 'root' })
export class AssetStateService {
  private readonly assetApi = inject(AssetApiService);
  private readonly authService = inject(AuthService);

  private readonly stateSubject = new BehaviorSubject<FeatureState<Asset>>(
    createInitialState<Asset>(),
  );

  /** La carga en curso. Ver load() y reset(). */
  private loading?: Subscription;

  readonly state$: Observable<FeatureState<Asset>> = this.stateSubject.asObservable();

  readonly assets$ = this.state$.pipe(map((state) => state.items), distinctUntilChanged());
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
    this.loading = this.assetApi.getAll().subscribe({
      next: (assets) => this.patch({ items: assets, loading: false }),
      error: (error: unknown) =>
        this.patch({
          loading: false,
          error: error instanceof ApiError ? error.message : 'No se pudieron cargar los activos.',
        }),
    });
  }

  /** Igual que en ClientStateService: devuelve el observable y deja la decisión a la pantalla. */
  create(asset: Asset): Observable<Asset> {
    return this.assetApi.create(asset).pipe(tap(() => this.load()));
  }

  /**
   * 🪦 LA DEUDA DE LA FASE 6, PAGADA — segunda mitad, y la que importa.
   *
   * La regla ya no depende de que la pantalla deshabilite un control. Si
   * mañana llega el import de CSV, pasa por aquí y la regla se cumple sin que
   * nadie se acuerde de ella.
   */
  update(next: Asset): Observable<Asset> {
    const current = this.stateSubject.value.items.find((asset) => asset.id === next.id);

    if (current !== undefined && changesClient(current, next)) {
      // throwError y no un `return of(current)` silencioso: una regla que se
      // salta sin avisar es peor que una que no existe, porque el que la
      // intentó saltar cree que funcionó.
      return throwError(
        () =>
          new BusinessRuleError(
            'Un activo no puede cambiar de cliente. Da de baja el activo y créalo en el cliente nuevo.',
          ),
      );
    }

    return this.assetApi.update(next).pipe(tap(() => this.load()));
  }

  reset(): void {
    this.loading?.unsubscribe();
    this.stateSubject.next(createInitialState<Asset>());
  }

  private patch(changes: Partial<FeatureState<Asset>>): void {
    this.stateSubject.next({ ...this.stateSubject.value, ...changes });
  }
}
