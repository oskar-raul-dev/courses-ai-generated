// src/app/core/guards/auth.guard.spec.ts
import { TestBed } from '@angular/core/testing';
import { ActivatedRouteSnapshot, Router, RouterStateSnapshot, UrlTree } from '@angular/router';

import { AuthService } from '../auth.service';
import { authGuard } from './auth.guard';

describe('authGuard', () => {
  let authService: jasmine.SpyObj<AuthService>;

  beforeEach(() => {
    authService = jasmine.createSpyObj<AuthService>('AuthService', ['isAuthenticated']);

    TestBed.configureTestingModule({
      providers: [
        { provide: AuthService, useValue: authService },
        // Un Router de mentira con lo único que el guard usa. Montar
        // `RouterTestingModule` entero funcionaría y traería un router de
        // verdad con sus rutas: más lento, más frágil, y sin nada que ganar.
        {
          provide: Router,
          useValue: { createUrlTree: (commands: readonly string[]) => ({ commands }) as unknown as UrlTree },
        },
      ],
    });
  });

  /**
   * ⭐ `TestBed.runInInjectionContext()` es LA pieza que hace testeable todo el
   * estilo nuevo del proyecto.
   *
   * Un guard funcional es una función, así que se llama. Lo que pasa es que por
   * dentro hace `inject(AuthService)`, y `inject()` fuera de un contexto de
   * inyección lanza `NG0203`. Esto abre ese contexto alrededor de la llamada.
   *
   * Compáralo con lo que costaría un guard de clase: `TestBed.inject(AuthGuard)`
   * y llamar a `canActivate`. Es más corto de escribir en el test y exige que
   * el guard sea una clase inyectable con su decorador. Ninguna de las dos
   * formas es mejor; son distintas, y el ejercicio 13 de la Fase 2 ya te hizo
   * escribir las dos.
   */
  function run(url: string) {
    const route = {} as ActivatedRouteSnapshot;
    const state = { url } as RouterStateSnapshot;

    return TestBed.runInInjectionContext(() => authGuard(route, state));
  }

  it('deja pasar a un usuario autenticado', () => {
    authService.isAuthenticated.and.returnValue(true);

    expect(run('/inspections')).toBeTrue();
  });

  it('devuelve un UrlTree al login con la ruta de vuelta', () => {
    authService.isAuthenticated.and.returnValue(false);

    // No se comprueba que navegara: se comprueba que DEVOLVIÓ el UrlTree. Es
    // la diferencia entre testear la decisión del guard y testear al router,
    // que ya está testeado por Angular.
    const result = run('/inspections/500') as unknown as { commands: readonly string[] };

    expect(result.commands).toEqual(['/login']);
  });
});
