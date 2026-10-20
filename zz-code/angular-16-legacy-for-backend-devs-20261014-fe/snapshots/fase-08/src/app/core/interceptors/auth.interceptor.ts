import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';

import { AuthService } from '../auth.service';

export const authInterceptor: HttpInterceptorFn = (request, next) => {
  // Se inyecta ARRIBA DEL TODO. Aquí seguimos dentro del contexto de
  // inyección; dentro del catchError de más abajo ya no estaríamos, y llamar a
  // inject() ahí da NG0203. Ver el ejercicio 10.
  const authService = inject(AuthService);
  const router = inject(Router);

  // El login es el único endpoint cuyo 401 significa "te equivocaste de contraseña"
  // en vez de "tu sesión caducó". Distinguirlo evita el bucle de la sección 6.
  const isLoginRequest = request.url.endsWith('/auth/login');
  const token = authService.getToken();

  const authorizedRequest =
    token === null
      ? request
      : request.clone({ setHeaders: { Authorization: `Bearer ${token}` } });

  return next(authorizedRequest).pipe(
    catchError((error: unknown) => {
      if (error instanceof HttpErrorResponse && error.status === 401 && !isLoginRequest) {
        authService.logout();
        // router.url es la ruta actual: la guardamos para volver después.
        void router.navigate(['/login'], { queryParams: { returnUrl: router.url } });
      }

      // El error se relanza SIEMPRE. El interceptor reacciona; no se traga el
      // fallo. Si se lo tragara, quien llamó creería que todo salió bien.
      return throwError(() => error);
    }),
  );
};
