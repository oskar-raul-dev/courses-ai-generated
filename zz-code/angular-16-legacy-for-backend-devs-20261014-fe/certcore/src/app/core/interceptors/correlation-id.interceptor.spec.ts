import { HttpHandler, HttpRequest, HttpResponse } from '@angular/common/http';
import { TestBed } from '@angular/core/testing';
import { of } from 'rxjs';

import { CorrelationIdInterceptor } from './correlation-id.interceptor';

// 🧬 EL MISMO TRABAJO, EN LA OTRA GENERACIÓN.
//
// `CorrelationIdInterceptor` se escribió en 2021 y sigue siendo una clase con
// `@Injectable()`. Su spec se escribe en el estilo del archivo que prueba: se
// inyecta la clase y se llama a su método `intercept`. Ni `runInInjectionContext`
// —no hace `inject()` por dentro, lo recibe todo por constructor— ni funciones
// sueltas. Es el 🧬 de esta fase: el mismo objetivo, dos técnicas, y la que
// eliges la decide el archivo y no tu gusto.
describe('CorrelationIdInterceptor', () => {
  it('estampa un identificador de correlación en cada petición', () => {
    TestBed.configureTestingModule({ providers: [CorrelationIdInterceptor] });

    const interceptor = TestBed.inject(CorrelationIdInterceptor);

    const forwarded: HttpRequest<unknown>[] = [];
    const next: HttpHandler = {
      handle: (request) => {
        forwarded.push(request);
        return of(new HttpResponse({ status: 200 }));
      },
    };

    interceptor.intercept(new HttpRequest('GET', '/api/clients'), next).subscribe();

    // ⚠️ No se compara con un valor concreto: el interceptor usa
    // `crypto.randomUUID()` y el valor es distinto en cada ejecución. Un
    // `toBe('algo')` aquí sería un test que falla el 100 % de las veces; un
    // `toBeTruthy()` sería uno que no prueba nada. Se comprueba la FORMA, que
    // es lo único estable de un valor aleatorio — y ésta es la primera lección
    // del incidente 17.
    expect(forwarded[0]?.headers.get('X-Correlation-Id')).toMatch(
      /^[0-9a-f-]{36}$/,
    );
  });
});
