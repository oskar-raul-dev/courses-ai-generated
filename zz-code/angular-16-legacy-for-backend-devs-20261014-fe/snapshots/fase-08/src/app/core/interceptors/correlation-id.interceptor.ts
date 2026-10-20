import {
  HttpEvent,
  HttpHandler,
  HttpInterceptor,
  HttpRequest,
} from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

/**
 * Escrito en 2021 y sin tocar desde entonces. Estampa un identificador en cada
 * petición para que una línea del log del servidor se pueda casar con una
 * petición concreta del navegador — la trazabilidad es requisito del negocio,
 * no un lujo de observabilidad.
 *
 * Hoy se escribiría como HttpInterceptorFn, en diez líneas menos. No se
 * reescribe: funciona, nadie se ha quejado, y no hay ninguna línea suya que
 * haya que tocar. Modernizar sin motivo es cómo se rompen otras tres cosas.
 */
@Injectable()
export class CorrelationIdInterceptor implements HttpInterceptor {
  intercept(
    request: HttpRequest<unknown>,
    next: HttpHandler,
  ): Observable<HttpEvent<unknown>> {
    // Las peticiones son inmutables: clone() devuelve una nueva con la
    // cabecera añadida. Mutar `request` no haría nada y no daría error.
    const correlatedRequest = request.clone({
      setHeaders: { 'X-Correlation-Id': crypto.randomUUID() },
    });

    return next.handle(correlatedRequest);
  }
}
