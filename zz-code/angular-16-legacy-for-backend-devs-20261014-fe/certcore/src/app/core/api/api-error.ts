import { HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';

/**
 * Un fallo de la API, ya traducido a algo que un componente puede mostrar.
 * Extender Error funciona sin trucos porque el target es ES2022; con ES5 haría
 * falta el arreglo del prototipo que se ve en tantos proyectos viejos.
 */
export class ApiError extends Error {
  constructor(
    message: string,
    /** El status HTTP, o `null` si nunca hubo respuesta. */
    readonly status: number | null,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

/** Traduce cualquier fallo en un ApiError y lo relanza. Nunca lo traga. */
export function toApiError(error: unknown): Observable<never> {
  // Un ApiError que ya viene construido —el del chequeo de forma, por ejemplo—
  // pasa tal cual. Sin esta línea, el mensaje específico («no es una lista de
  // plantillas») se convierte en el genérico de abajo y la pantalla no dice qué falló.
  if (error instanceof ApiError) {
    return throwError(() => error);
  }

  if (error instanceof HttpErrorResponse) {
    const message =
      error.status === 0
        ? // status 0 NO significa que el servidor respondiera cero: significa
          // que no hubo respuesta. Servidor caído, red ausente, o el navegador
          // bloqueando la petición por CORS antes de dejarla salir.
          'No se pudo contactar con el servidor. Puede ser la red, el servidor caído o un CORS mal configurado.'
        : `El servidor respondió ${error.status} al pedir ${error.url ?? 'el recurso'}.`;

    return throwError(() => new ApiError(message, error.status));
  }

  return throwError(() => new ApiError('Fallo inesperado al hablar con la API.', null));
}
