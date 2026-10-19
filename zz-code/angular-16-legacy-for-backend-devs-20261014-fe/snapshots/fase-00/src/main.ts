import { bootstrapApplication } from '@angular/platform-browser';

import { AppComponent } from './app/app.component';
import { appConfig } from './app/app.config';

// El componente raíz ya no se "declara" en ningún lado: se arranca directo.
bootstrapApplication(AppComponent, appConfig)
  // `unknown` y no `any`: lo que llega acá puede ser cualquier cosa y hay que
  // tratarlo como tal. Con strict puesto, `any` sería hacer trampa.
  .catch((error: unknown) => console.error(error));
