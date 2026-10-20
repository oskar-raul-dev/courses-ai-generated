import {
  HTTP_INTERCEPTORS,
  provideHttpClient,
  withInterceptors,
  withInterceptorsFromDi,
} from '@angular/common/http';
import { NgModule, Optional, SkipSelf } from '@angular/core';

import { CorrelationIdInterceptor } from './interceptors/correlation-id.interceptor';
import { authInterceptor } from './interceptors/auth.interceptor';

@NgModule({
  providers: [
    // 🧬 PUNTO DE CONTACTO ENTRE GENERACIONES
    // provideHttpClient() sustituye al HttpClientModule que este módulo
    // importaba en la Fase 1. Registra el cliente HTTP con dos features:
    //
    //   withInterceptorsFromDi() → sigue ejecutando los interceptores de
    //     CLASE registrados en HTTP_INTERCEPTORS. Sin esta línea, el
    //     CorrelationIdInterceptor de 2021 deja de correr EN SILENCIO.
    //   withInterceptors([...])  → registra los interceptores FUNCIONALES.
    //
    // El orden en que aparecen las dos features decide cuál cadena corre
    // primero. No lo des por sabido: compruébalo con un log (ejercicio 17).
    provideHttpClient(withInterceptorsFromDi(), withInterceptors([authInterceptor])),

    // El registro de 2021, intacto. `multi: true` porque HTTP_INTERCEPTORS es
    // un token de múltiples valores: cada interceptor añade el suyo.
    { provide: HTTP_INTERCEPTORS, useClass: CorrelationIdInterceptor, multi: true },
  ],
})
export class CoreModule {
  constructor(@Optional() @SkipSelf() parentModule?: CoreModule) {
    if (parentModule) {
      throw new Error(
        'CoreModule ya está cargado. Impórtalo únicamente en AppModule.',
      );
    }
  }
}
