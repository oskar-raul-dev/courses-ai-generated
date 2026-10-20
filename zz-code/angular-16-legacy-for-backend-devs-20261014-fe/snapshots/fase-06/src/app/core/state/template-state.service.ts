import { Injectable, inject } from '@angular/core';
import { BehaviorSubject, Observable, distinctUntilChanged, filter, map, shareReplay } from 'rxjs';

import { TemplateApiService } from '../api/template-api.service';
import { ApiError } from '../api/api-error';
import { AuthService } from '../auth.service';
import { ChecklistTemplate } from '../models/checklist-template.model';
import { FeatureState, createInitialState } from './feature-state.model';

@Injectable({ providedIn: 'root' })
export class TemplateStateService {
  private readonly templateApi = inject(TemplateApiService);
  private readonly authService = inject(AuthService);

  /**
   * El sujeto es privado y se llama `stateSubject`; lo público es `state$`.
   * Regla del proyecto: los dos nombres se distinguen por la palabra, no por el
   * signo. Un `state` privado y un `state$` público difieren en un carácter, y
   * ese carácter se pierde en un `Ctrl+F` a las siete de la tarde.
   */
  private readonly stateSubject = new BehaviorSubject<FeatureState<ChecklistTemplate>>(
    createInitialState<ChecklistTemplate>(),
  );

  /** Sólo lectura. Sin asObservable(), cualquiera podría hacerle next(). */
  readonly state$: Observable<FeatureState<ChecklistTemplate>> = this.stateSubject.asObservable();

  // Derivados. distinctUntilChanged evita que un cambio en `loading` haga
  // reevaluar a quien sólo mira `items`.
  readonly templates$ = this.state$.pipe(map((state) => state.items), distinctUntilChanged());
  readonly selected$ = this.state$.pipe(map((state) => state.selected), distinctUntilChanged());
  readonly loading$ = this.state$.pipe(map((state) => state.loading), distinctUntilChanged());
  readonly error$ = this.state$.pipe(map((state) => state.error), distinctUntilChanged());

  /**
   * La versión más alta de cada familia. Es un cálculo, no un dato: guardarlo
   * sería tener dos fuentes de verdad que se pueden desincronizar.
   *
   * Ojo: esto NO resuelve "qué versión aplica a esta fecha", que es otra cosa y
   * es la Fase 7 entera ⭐. Aquí sólo es "la más nueva de cada una".
   */
  readonly latestVersions$: Observable<ChecklistTemplate[]> = this.templates$.pipe(
    map((templates) => {
      const latestByFamily = new Map<string, ChecklistTemplate>();

      for (const template of templates) {
        const current = latestByFamily.get(template.templateId);

        if (current === undefined || template.version > current.version) {
          latestByFamily.set(template.templateId, template);
        }
      }

      return [...latestByFamily.values()];
    }),
    // Sin esto, el Map se recorre una vez POR CADA suscriptor. Con cuatro
    // pantallas mirando, cuatro cálculos idénticos en cada emisión.
    //
    // ⚠️ `refCount: true` es la mitad que importa: hace que la suscripción a la
    // fuente se cierre cuando se va el último suscriptor. Con `refCount: false`
    // —que es el valor por defecto del atajo `shareReplay(1)`— la suscripción
    // interna queda viva para siempre aunque no quede nadie escuchando, y eso es
    // una fuga con nombre y apellido. Ejercicio 15.
    shareReplay({ bufferSize: 1, refCount: true }),
  );

  constructor() {
    // Cuando la sesión se cierra —por el botón de la toolbar o por un 401 que
    // cazó el interceptor— el estado del usuario anterior desaparece. Esto no
    // es rendimiento: es privacidad. Y al hacerlo aquí, ningún sitio que llame
    // a logout() tiene que acordarse de limpiar nada.
    //
    // Nadie se desuscribe de esta suscripción, y es CORRECTO: los dos servicios
    // son providedIn: 'root' y viven lo mismo que la aplicación, así que la
    // suscripción no sobrevive a nadie. Una fuga es una suscripción que
    // sobrevive a su dueño; ésta no tiene a quién sobrevivir. Ejercicio 24.
    this.authService.currentUser$
      .pipe(filter((user) => user === null))
      .subscribe(() => this.reset());
  }

  load(): void {
    this.patch({ loading: true, error: null });

    // Suscripción a pelo, y aquí también está bien: un observable de HttpClient
    // completa por su cuenta en cuanto llega la respuesta, así que no queda
    // nada abierto. Compáralo con la suscripción del componente de la sección
    // 6, que nunca completa — ésa sí es una fuga.
    this.templateApi.getAll().subscribe({
      next: (templates) => {
        // Sin copia: el estado ya es readonly de la Fase 6 en adelante (ver
        // FeatureState). Pagar la deuda es quitar la copia que la disfrazaba.
        this.patch({ items: templates, loading: false });
      },
      error: (error: unknown) => {
        this.patch({
          loading: false,
          error: error instanceof ApiError
            ? error.message
            : 'No se pudieron cargar las plantillas.',
        });
      },
    });
  }

  select(rowId: string): void {
    const selected = this.stateSubject.value.items.find((template) => template.id === rowId) ?? null;
    this.patch({ selected });
  }

  reset(): void {
    this.stateSubject.next(createInitialState<ChecklistTemplate>());
  }

  /**
   * El único punto del servicio que llama a next(). Reemplaza el objeto de
   * estado entero: la referencia cambia siempre, que es lo que hace posible
   * OnPush y distinctUntilChanged.
   */
  private patch(changes: Partial<FeatureState<ChecklistTemplate>>): void {
    this.stateSubject.next({ ...this.stateSubject.value, ...changes });
  }
}
