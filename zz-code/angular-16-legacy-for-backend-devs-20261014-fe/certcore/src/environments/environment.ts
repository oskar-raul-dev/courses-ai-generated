import { AppEnvironment } from './environment.model';

/**
 * 🪦 LA DEUDA DE LA FASE 0, PAGADA. Trece fases después.
 *
 * En la Fase 0 la URL vivía dentro de un componente. En la Fase 1 se mudó aquí
 * y quedó más ordenada sin dejar de estar horneada. Hoy se va a
 * `assets/config.json` y este archivo se queda con lo único que de verdad es de
 * compilación: el interruptor `production`.
 *
 * La factura se lee en un comando, y lo dejó escrito la convención de git:
 *     git diff fase-00 fase-13 -- src/environments src/assets
 */
export const environment: Pick<AppEnvironment, 'production'> = {
  production: true,
};
