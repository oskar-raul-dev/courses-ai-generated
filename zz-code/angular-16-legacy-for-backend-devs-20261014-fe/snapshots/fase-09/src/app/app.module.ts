import { HttpClientModule } from '@angular/common/http';
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { CoreModule } from './core/core.module';
import { LayoutModule } from './layout/layout.module';

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
  providers: [],

  // El quinto array, y sólo lo tiene el módulo raíz: por dónde empieza todo.
  bootstrap: [AppComponent],
})
export class AppModule {}
