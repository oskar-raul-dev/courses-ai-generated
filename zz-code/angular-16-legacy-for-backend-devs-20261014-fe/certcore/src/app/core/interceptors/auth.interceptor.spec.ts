import { HttpHandlerFn, HttpRequest, HttpResponse } from '@angular/common/http';
import { TestBed } from '@angular/core/testing';
import { Router } from '@angular/router';
import { of } from 'rxjs';

import { AuthService } from '../auth.service';
import { authInterceptor } from './auth.interceptor';

describe('authInterceptor', () => {
  it('añade la cabecera Authorization cuando hay token', () => {
    const authService = jasmine.createSpyObj<AuthService>('AuthService', ['getToken', 'logout']);
    authService.getToken.and.returnValue('un-token');

    TestBed.configureTestingModule({
      providers: [
        { provide: AuthService, useValue: authService },
        { provide: Router, useValue: { navigate: () => Promise.resolve(true), url: '/' } },
      ],
    });

    // El "siguiente" de la cadena, escrito a mano. Captura lo que le llega y
    // devuelve una respuesta cualquiera: un interceptor se testea por lo que
    // le PASA al siguiente, no por lo que el servidor conteste.
    const forwarded: HttpRequest<unknown>[] = [];
    const next: HttpHandlerFn = (request) => {
      forwarded.push(request);
      return of(new HttpResponse({ status: 200 }));
    };

    const original = new HttpRequest('GET', '/api/inspections');

    TestBed.runInInjectionContext(() => authInterceptor(original, next).subscribe());

    expect(forwarded[0]?.headers.get('Authorization')).toBe('Bearer un-token');
  });
});
