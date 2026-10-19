import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';

import { AppModule } from './app/app.module';

// Así arranca CertCore desde 2021, y así sigue arrancando hoy: la migración a
// la 16 no tocó este archivo, porque no había ningún motivo para tocarlo.
platformBrowserDynamic()
  .bootstrapModule(AppModule)
  .catch((error: unknown) => console.error(error));
