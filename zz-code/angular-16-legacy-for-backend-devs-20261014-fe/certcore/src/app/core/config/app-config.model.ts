/**
 * Lo que puede cambiar entre dos despliegues DEL MISMO artefacto.
 *
 * Compáralo con `AppEnvironment` de la Fase 1: aquel tenía tres campos y éste
 * tiene dos. El que falta es `production`, y no es un olvido — es un
 * interruptor del compilador, no un dato. Ver §4.
 */
export interface AppConfig {
  readonly apiBaseUrl: string;
  readonly environmentName: 'DEV' | 'UAT' | 'PROD';
}
