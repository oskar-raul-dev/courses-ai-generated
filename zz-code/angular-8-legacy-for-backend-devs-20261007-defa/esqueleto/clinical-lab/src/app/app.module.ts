// Probe module (zz-code, not course code): the course's SharedModule + AppConfigService,
// the Fase 13 APP_INITIALIZER, and LOCALE_ID 'es' as Fase 02 fixes it.
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { HttpClientModule } from '@angular/common/http';
import { APP_INITIALIZER, LOCALE_ID, NgModule } from '@angular/core';
import { registerLocaleData } from '@angular/common';
import localeEs from '@angular/common/locales/es';

import { SharedModule } from './shared/shared.module';
import { AppConfigService } from './core/config/app-config.service';
import { AppComponent } from './app.component';

registerLocaleData(localeEs, 'es');

export function appConfigInitializer(configService: AppConfigService) {
  return function () {
    return configService.load();
  };
}

@NgModule({
  declarations: [AppComponent],
  imports: [BrowserModule, BrowserAnimationsModule, HttpClientModule, SharedModule],
  providers: [
    { provide: LOCALE_ID, useValue: 'es' },
    { provide: APP_INITIALIZER, useFactory: appConfigInitializer, deps: [AppConfigService], multi: true }
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
