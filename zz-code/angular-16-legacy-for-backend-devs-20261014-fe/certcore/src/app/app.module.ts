import { HttpClientModule } from '@angular/common/http';
import { APP_INITIALIZER, NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { AppConfigService } from './core/config/app-config.service';
import { CoreModule } from './core/core.module';
import { LayoutModule } from './layout/layout.module';

export function loadAppConfig(appConfig: AppConfigService): () => Promise<void> {
  return () => appConfig.load();
}

@NgModule({
  // Lo que nace aquí. El módulo raíz declara poco: sólo el componente que
  // Angular arranca. Todo lo demás vive en su feature.
  declarations: [AppComponent],

  imports: [
    // BrowserModule sólo va en el módulo raíz: incluye CommonModule y la
    // fontanería del navegador. En un módulo de feature se importa CommonModule.
    BrowserModule,
    BrowserAnimationsModule,
    CoreModule,
    LayoutModule,
    // El routing va último a propósito: la ruta comodín ** de AppRoutingModule
    // tiene que quedar después de todas las demás o se come el resto.
    AppRoutingModule,
  ],

  // Vacío, y no por casualidad: los servicios de este curso se registran con
  // providedIn: 'root' o en CoreModule. Ver 5.7.
  providers: [
    {
      provide: APP_INITIALIZER,
      useFactory: loadAppConfig,
      deps: [AppConfigService],
      multi: true,
    },
  ],

  // El quinto array, y sólo lo tiene el módulo raíz: por dónde empieza todo.
  bootstrap: [AppComponent],
})
export class AppModule {}
