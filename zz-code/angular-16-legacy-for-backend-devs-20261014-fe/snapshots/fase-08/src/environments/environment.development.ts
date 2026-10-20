// src/environments/environment.development.ts
import { AppEnvironment } from './environment.model';

export const environment: AppEnvironment = {
  production: false,
  // El stub de json-server de la Fase 0; en la Fase 3 será el mock completo.
  apiBaseUrl: 'http://localhost:3000',
  environmentName: 'DEV',
};
