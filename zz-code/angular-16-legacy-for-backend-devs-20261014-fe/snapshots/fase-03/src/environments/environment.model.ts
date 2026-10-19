/**
 * El contrato que los dos archivos de entorno tienen que cumplir. Sin esto,
 * un archivo puede quedarse sin un campo y el error aparece en tiempo de
 * ejecución, en el ambiente equivocado y en el peor momento.
 */
export interface AppEnvironment {
  readonly production: boolean;
  readonly apiBaseUrl: string;
  readonly environmentName: 'DEV' | 'UAT' | 'PROD';
}
