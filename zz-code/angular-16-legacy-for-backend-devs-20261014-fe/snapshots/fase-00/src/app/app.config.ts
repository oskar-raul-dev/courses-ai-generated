import { ApplicationConfig } from '@angular/core';
import { provideHttpClient } from '@angular/common/http';

// Esto es el array `providers` que antes vivía dentro del @NgModule, ahora
// suelto. Cada `provide*` registra una pieza de Angular en el inyector raíz.
export const appConfig: ApplicationConfig = {
  providers: [
    // Sin esto, cualquier inject(HttpClient) explota con NullInjectorError.
    // En la Fase 2 esta misma línea crece: provideHttpClient(withInterceptors([...])).
    provideHttpClient(),
  ],
};
