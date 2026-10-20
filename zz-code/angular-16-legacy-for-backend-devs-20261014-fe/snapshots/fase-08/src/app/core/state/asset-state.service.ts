import { Injectable, inject } from '@angular/core';
import { BehaviorSubject, Observable, distinctUntilChanged, filter, map, tap } from 'rxjs';

import { ApiError } from '../api/api-error';
import { AssetApiService } from '../api/asset-api.service';
import { AuthService } from '../auth.service';
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

    this.assetApi.getAll().subscribe({
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

  update(asset: Asset): Observable<Asset> {
    return this.assetApi.update(asset).pipe(tap(() => this.load()));
  }

  reset(): void {
    this.stateSubject.next(createInitialState<Asset>());
  }

  private patch(changes: Partial<FeatureState<Asset>>): void {
    this.stateSubject.next({ ...this.stateSubject.value, ...changes });
  }
}
