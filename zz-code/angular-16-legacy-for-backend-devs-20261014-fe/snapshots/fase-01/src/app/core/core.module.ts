import { HttpClientModule } from '@angular/common/http';
import { NgModule, Optional, SkipSelf } from '@angular/core';

@NgModule({
  // HttpClientModule vive aquí porque el cliente HTTP debe existir una sola
  // vez. En la Fase 2 esta línea se sustituye por provideHttpClient(), que es
  // la forma moderna de registrar lo mismo — y ahí llega el primer 🧬.
  imports: [HttpClientModule],
  exports: [HttpClientModule],
})
export class CoreModule {
  /**
   * El guard de doble importación, un clásico de 2021 que sigue siendo útil.
   * @SkipSelf() le dice al inyector "búscalo hacia arriba, no en mí mismo", y
   * @Optional() que devuelva null en vez de explotar si no lo encuentra.
   * Si encuentra algo, es que alguien ya importó CoreModule más arriba.
   */
  constructor(@Optional() @SkipSelf() parentModule?: CoreModule) {
    // ⚠️ Comprobación por verdad, no por `!== undefined`. Aunque el parámetro
    // sea opcional y TypeScript lo tipe como `CoreModule | undefined`,
    // @Optional() inyecta `null` en tiempo de ejecución. Comparar contra
    // undefined haría que esto lanzara SIEMPRE, incluso en el caso bueno.
    if (parentModule) {
      throw new Error(
        'CoreModule ya está cargado. Impórtalo únicamente en AppModule.',
      );
    }
  }
}
