// src/environments/environment.ts  ← el de PRODUCCIÓN (es el archivo por defecto)
import { AppEnvironment } from './environment.model';

/**
 * 💸 LA DEUDA DE LA FASE 0, MUDADA DE CASA
 * En la Fase 0 la URL del backend estaba escrita dentro de un componente.
 * Ahora está aquí, y se ve mucho más ordenado. Que no te engañe: sigue
 * HORNEADA EN TIEMPO DE COMPILACIÓN. Cambiarla exige recompilar y volver a
 * desplegar, que es exactamente el problema.
 * SE PAGA EN LA FASE 13, leyendo la configuración en tiempo de arranque.
 * Si hiciste el ejercicio 27 de la Fase 0, ya sabes que mover la constante de
 * archivo no cambia absolutamente nada; esto es lo mismo, con mejor letra.
 */
export const environment: AppEnvironment = {
  production: true,
  apiBaseUrl: '/api',
  environmentName: 'PROD',
};
