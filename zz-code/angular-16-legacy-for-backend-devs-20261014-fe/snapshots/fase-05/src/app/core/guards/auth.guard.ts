import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';

import { AuthService } from '../auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isAuthenticated()) {
    return true;
  }

  // Devolvemos un UrlTree en vez de llamar a router.navigate(): el router
  // cancela esta navegación y ejecuta la otra en un solo paso. Con navigate()
  // habría dos navegaciones compitiendo y el historial quedaría raro.
  return router.createUrlTree(['/login'], {
    queryParams: { returnUrl: state.url },
  });
};
