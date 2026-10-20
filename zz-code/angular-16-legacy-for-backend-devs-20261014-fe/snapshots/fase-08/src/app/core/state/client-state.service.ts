import { Injectable, inject } from '@angular/core';
import {
  BehaviorSubject,
  EMPTY,
  Observable,
  Subject,
  catchError,
  combineLatest,
  debounceTime,
  distinctUntilChanged,
  filter,
  map,
  startWith,
  switchMap,
  tap,
  throwError,
} from 'rxjs';

import { ApiError } from '../api/api-error';
import { AssetApiService } from '../api/asset-api.service';
import { ClientApiService, ClientDraft } from '../api/client-api.service';
import { AuthService } from '../auth.service';
import { Client } from '../models/client.model';
import { FeatureState, createInitialState } from './feature-state.model';

@Injectable({ providedIn: 'root' })
export class ClientStateService {
  private readonly clientApi = inject(ClientApiService);
  private readonly assetApi = inject(AssetApiService);
  private readonly authService = inject(AuthService);

  private readonly stateSubject = new BehaviorSubject<FeatureState<Client>>(
    createInitialState<Client>(),
  );

  readonly state$: Observable<FeatureState<Client>> = this.stateSubject.asObservable();

  readonly clients$ = this.state$.pipe(map((state) => state.items), distinctUntilChanged());
  readonly selected$ = this.state$.pipe(map((state) => state.selected), distinctUntilChanged());
  readonly loading$ = this.state$.pipe(map((state) => state.loading), distinctUntilChanged());
  readonly error$ = this.state$.pipe(map((state) => state.error), distinctUntilChanged());

  /** El criterio de búsqueda vigente. Es estado de la feature, no del componente. */
  private readonly criteriaSubject = new BehaviorSubject<string>('');
  readonly criteria$ = this.criteriaSubject.asObservable();

  /** Un disparo manual para releer sin cambiar el criterio. */
  private readonly reloadSubject = new Subject<void>();

  constructor() {
    // El reseteo al cerrar sesión, igual que en TemplateStateService: dos
    // servicios raíz, nadie sobrevive a nadie, nadie se desuscribe. Fase 4 §5.6.
    this.authService.currentUser$
      .pipe(filter((user) => user === null))
      .subscribe(() => this.reset());

    combineLatest([
      // debounceTime + distinctUntilChanged: el usuario escribe "Central" y
      // sale UNA petición, no siete. distinctUntilChanged además ignora el
      // teclazo que borra y reescribe la misma letra.
      this.criteriaSubject.pipe(debounceTime(300), distinctUntilChanged()),
      this.reloadSubject.pipe(startWith(undefined)),
    ])
      .pipe(
        tap(() => this.patch({ loading: true, error: null })),
        // ⭐ switchMap es lo que arregla los dos límites de la Fase 4: al llegar
        // un criterio nuevo CANCELA la petición anterior, así que ya no puede
        // ganar una respuesta vieja que llegó tarde, y `loading` sólo describe
        // una petición porque sólo hay una viva.
        switchMap(([term]) =>
          this.clientApi.search(term).pipe(
            catchError((error: unknown) => {
              this.patch({
                loading: false,
                error:
                  error instanceof ApiError
                    ? error.message
                    : 'No se pudieron cargar los clientes.',
              });

              // EMPTY y no throwError: si el error saliera del pipe, mataría
              // esta suscripción y el buscador dejaría de funcionar para
              // siempre después del primer fallo. Ejercicio 20.
              return EMPTY;
            }),
          ),
        ),
      )
      .subscribe((clients) => this.patch({ items: clients, loading: false }));
  }

  /** Lo llama el buscador de la pantalla en cada tecla. El debounce vive aquí. */
  search(term: string): void {
    this.criteriaSubject.next(term);
  }

  /** Relee con el criterio actual. Se usa después de escribir. */
  reload(): void {
    this.reloadSubject.next();
  }

  select(id: number): void {
    const selected = this.stateSubject.value.items.find((client) => client.id === id) ?? null;
    this.patch({ selected });
  }

  /**
   * Devuelve el observable en vez de suscribirse: quien escribe necesita saber
   * si salió bien para navegar y mostrar el snackbar, y eso es decisión de la
   * pantalla, no del servicio.
   *
   * ⚠️ Y aquí NO hay switchMap. `switchMap` es la respuesta correcta para leer
   * y la equivocada para escribir: cancelar un POST que ya salió no deshace
   * nada en el servidor, sólo te deja sin enterarte del resultado.
   */
  create(draft: ClientDraft): Observable<Client> {
    return this.clientApi.create(draft).pipe(tap(() => this.reload()));
  }

  update(client: Client): Observable<Client> {
    return this.clientApi.update(client).pipe(tap(() => this.reload()));
  }

  /**
   * La regla de negocio "no se borra un cliente con activos" vive AQUÍ, en el
   * servicio, y no en el componente. Es donde va: si mañana el borrado se
   * dispara desde el detalle del cliente o desde un proceso en lote, la regla
   * sigue puesta sin que nadie la copie. Compárala con la 💸 de 5.10, que es
   * la misma clase de regla escrita en el sitio equivocado.
   */
  remove(client: Client): Observable<void> {
    return this.assetApi.getByClient(client.id).pipe(
      // switchMap encadenando lectura → escritura. Es seguro porque el diálogo
      // de confirmación es modal y no se puede pedir dos borrados a la vez; si
      // el botón fuera pulsable en ráfaga, esto sería concatMap.
      switchMap((assets) => {
        if (assets.length > 0) {
          return throwError(
            () =>
              new ApiError(
                `No se puede eliminar ${client.legalName}: tiene ${assets.length} activos asociados.`,
                null,
              ),
          );
        }

        return this.clientApi.delete(client.id);
      }),
      tap(() => this.reload()),
    );
  }

  reset(): void {
    this.criteriaSubject.next('');
    this.stateSubject.next(createInitialState<Client>());
  }

  private patch(changes: Partial<FeatureState<Client>>): void {
    this.stateSubject.next({ ...this.stateSubject.value, ...changes });
  }
}
