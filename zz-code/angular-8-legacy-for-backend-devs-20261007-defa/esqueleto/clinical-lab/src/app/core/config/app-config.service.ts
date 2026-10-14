// src/app/core/config/app-config.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

// La forma de la configuración. La tipamos aunque sea a mano: el día que alguien
// agregue una clave al config.json y se olvide de la plantilla, este tipo es la
// única pista que va a tener antes de que reviente en runtime.
export interface AppConfig {
  apiUrl: string;
  environmentName: string;
  // La zona del laboratorio, no la del navegador del usuario. Viene de la Fase 2,
  // donde vivía en environment.ts, y se muda acá por la misma razón que apiUrl:
  // es un valor que cambia entre ambientes. Si el sistema se desplegara para un
  // laboratorio en otra zona, esto es lo único que habría que tocar.
  timeZone: string;
  features: {
    deliveryPdfEnabled: boolean;
  };
}

@Injectable({ providedIn: 'root' })
export class AppConfigService {

  // any tolerado a propósito: hasta que load() resuelva, no hay config, y no
  // queremos que el compilador nos obligue a inicializarla con un objeto falso
  // que después confunda al que debuguee. Se comenta, no se corrige.
  private config: AppConfig = null as any;

  constructor(private http: HttpClient) { }

  // Devuelve una promesa porque el APP_INITIALIZER espera una promesa y no
  // arranca la aplicación hasta que resuelva. function () {} y no arrow: es el
  // estilo del curso y además .toPromise() no necesita capturar this.
  load(): Promise<void> {
    // `var self` y no `.bind(this)`: el callback vive dentro de un .then() de
    // promesa, no de un observable, y ahí el idioma habitual del curso no aplica
    // limpio. Es la segunda de las dos excepciones que declara la guia §6.
    var self = this;
    // Le pegamos una marca de tiempo para saltarnos el cache: si el navegador
    // sirve un config.json viejo, apuntas al ambiente equivocado y no hay error.
    // Es exactamente la clase de bug que esta fase existe para prevenir.
    return this.http.get<AppConfig>('assets/config.json?ts=' + Date.now())
      .toPromise()
      .then(function (loaded) {
        self.config = loaded;
      });
  }

  // A partir de que load() resolvió, todo el mundo pregunta acá. Nadie vuelve a
  // importar environment para leer apiUrl.
  get apiUrl(): string {
    return this.config.apiUrl;
  }

  get environmentName(): string {
    return this.config.environmentName;
  }

  get timeZone(): string {
    return this.config.timeZone;
  }

  isFeatureEnabled(feature: string): boolean {
    // Acceso defensivo: si la feature no existe en el config, se asume apagada.
    // En un feature flag, "no se que es esto" siempre significa "apagado".
    return !!(this.config.features && (this.config.features as any)[feature]);
  }
}
