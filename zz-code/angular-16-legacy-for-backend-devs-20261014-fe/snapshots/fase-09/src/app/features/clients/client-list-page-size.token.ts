import { InjectionToken } from '@angular/core';

/**
 * Cuántos clientes muestra el listado por página. Es configuración de UNA
 * pantalla, así que vive en el inyector de esa ruta y no en el raíz. Cinco es
 * un número bajo a propósito: la semilla trae tres clientes y con veinticinco
 * por página el paginador de la Fase 6 no paginaría nunca.
 *
 * Fíjate en lo que NO lleva: no lleva `factory`. Con
 * `new InjectionToken<number>('…', { providedIn: 'root', factory: () => 25 })`
 * el token nunca fallaría… y tampoco te avisaría nunca de que estás montando
 * la pantalla fuera de su ruta. Aquí preferimos el error: un NullInjectorError
 * en desarrollo cuesta cinco minutos; una paginación silenciosamente distinta
 * en producción cuesta un ticket.
 */
export const CLIENT_LIST_PAGE_SIZE = new InjectionToken<number>('CLIENT_LIST_PAGE_SIZE');
