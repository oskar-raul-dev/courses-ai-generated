import { TestBed, fakeAsync, tick } from '@angular/core/testing';
import { of } from 'rxjs';

import { AssetApiService } from '../api/asset-api.service';
import { ClientApiService } from '../api/client-api.service';
import { AuthService } from '../auth.service';
import { Client } from '../models/client.model';
import { ClientStateService } from './client-state.service';
import { FeatureState } from './feature-state.model';

describe('ClientStateService', () => {
  let service: ClientStateService;
  let clientApi: jasmine.SpyObj<ClientApiService>;

  beforeEach(() => {
    // Un doble tipado. `createSpyObj` con el genérico puesto obliga a que los
    // nombres de método existan de verdad: si mañana `search` se renombra,
    // este archivo deja de compilar en vez de fallar en ejecución.
    clientApi = jasmine.createSpyObj<ClientApiService>('ClientApiService', ['search']);

    TestBed.configureTestingModule({
      providers: [
        { provide: ClientApiService, useValue: clientApi },
        { provide: AssetApiService, useValue: jasmine.createSpyObj<AssetApiService>('AssetApiService', ['getByClient']) },
        { provide: AuthService, useValue: { currentUser$: of(null) } },
      ],
    });
  });

  /**
   * ⭐ `fakeAsync` es lo que convierte un test de 300 ms en uno de cero.
   *
   * `ClientStateService` tiene un `debounceTime(300)` en su buscador (Fase 6
   * §5.5). Sin `fakeAsync`, este test tendría que esperar de verdad —y ese es
   * el patrón que llena las suites de veinte minutos—. Con `fakeAsync`, el
   * tiempo es una variable que `tick()` adelanta.
   */
  it('agrupa las pulsaciones en una sola petición', fakeAsync(() => {
    clientApi.search.and.returnValue(of([]));
    service = TestBed.inject(ClientStateService);

    service.search('Cen');
    service.search('Cent');
    service.search('Central');

    // Antes del debounce todavía no ha salido nada. Comprobarlo ANTES del
    // tick es lo que distingue "se agrupó" de "sólo llamé una vez".
    expect(clientApi.search).not.toHaveBeenCalled();

    tick(300);

    expect(clientApi.search).toHaveBeenCalledTimes(1);
    expect(clientApi.search).toHaveBeenCalledWith('Central');
  }));

  it('emite el estado nuevo a quien esté suscrito', fakeAsync(() => {
    const clients: readonly Client[] = [{ id: 1, legalName: 'Edificio Central S.A.S.', taxId: '900123456' }];
    clientApi.search.and.returnValue(of(clients));
    service = TestBed.inject(ClientStateService);

    /**
     * Así se testea un BehaviorSubject: se colecciona lo que emite en un array
     * y se comprueba la SECUENCIA, no sólo el último valor. Un servicio que
     * llega al estado correcto pasando por uno intermedio equivocado —el
     * `loading` que se queda en true, la lista que parpadea vacía— produce un
     * parpadeo en pantalla que sólo se ve aquí.
     *
     * Nada de `TestScheduler` ni de cadenas con guiones: para esto, un array y
     * un `expect` se leen mejor y no obligan a aprender un segundo lenguaje.
     */
    const emissions: FeatureState<Client>[] = [];
    const subscription = service.state$.subscribe((state) => emissions.push(state));

    service.search('Central');
    tick(300);

    expect(emissions.length).toBeGreaterThan(1);
    expect(emissions[emissions.length - 1].items).toEqual(clients);
    expect(emissions[emissions.length - 1].loading).toBeFalse();

    // Desuscribirse en el test también. Un spec que deja una suscripción viva
    // en un servicio `providedIn: 'root'` es cómo un test contamina al
    // siguiente — y con `random: true`, "el siguiente" cambia cada vez.
    subscription.unsubscribe();
  }));
});
