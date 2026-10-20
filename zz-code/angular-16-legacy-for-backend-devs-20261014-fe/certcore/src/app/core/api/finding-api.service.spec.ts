// src/app/core/api/finding-api.service.spec.ts
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';

import { AppConfigService } from '../config/app-config.service';
import { Finding } from '../models/finding.model';
import { FindingApiService } from './finding-api.service';

const API = '/api';

describe('FindingApiService', () => {
  let service: FindingApiService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      /**
       * ⚠️ `HttpClientTestingModule` es un NgModule, y en un proyecto donde la
       * aplicación se configura con `provideHttpClient()` eso chirría. No hay
       * alternativa en Angular 16: `provideHttpClientTesting()` llega en la 17.
       * Es la fricción de versión de la que habla la nota de migración de §4, y
       * te la vas a encontrar en cada artículo reciente que copies.
       */
      imports: [HttpClientTestingModule],
      providers: [{ provide: AppConfigService, useValue: { current: { apiBaseUrl: API, environmentName: 'DEV' } } }],
    });

    service = TestBed.inject(FindingApiService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    // `verify()` falla si quedó alguna petición sin atender. Sin esto, un
    // servicio que hace una llamada de más pasa el test igual y el bug aparece
    // en producción como tráfico que nadie pidió.
    httpMock.verify();
  });

  it('pide los hallazgos de una inspección por query param', () => {
    service.getByInspection(503).subscribe();

    const request = httpMock.expectOne(`${API}/findings?inspectionId=503`);

    expect(request.request.method).toBe('GET');
    request.flush([]);
  });

  /**
   * ⭐ TEST DE REGRESIÓN — INCIDENTE 12.
   *
   * Éste es el test que conviene ver fallar antes de creérselo. Quita el
   * `normalizeFinding` del servicio (Fase 9 §5.3), corre esto, y se pone rojo.
   * Vuelve a ponerlo y pasa. Ese par de estados es lo que hace que un test de
   * regresión valga algo.
   *
   * Fíjate en el `as unknown as Finding` del fixture: es deliberado y es la
   * única aserción de tipo de todo el curso. La fila que manda el backend NO
   * cumple el tipo `Finding` —le falta un campo— y ése es exactamente el bug.
   * Escribirla bien tipada haría un test que no puede fallar. `unknown` de por
   * medio, y comentado, en vez de un `any` que apagaría el compilador entero.
   */
  it('normaliza a `null` un `resolvedAt` que el backend no manda', () => {
    const rowWithoutResolvedAt = {
      id: 902,
      inspectionId: 501,
      itemId: 'door-sensor',
      severity: 'major',
      description: 'El sensor no detecta obstáculos en el tercio inferior',
      // Sin `resolvedAt`. Es la fila que produce el certificado emitido sobre
      // un hallazgo crítico abierto.
    } as unknown as Finding;

    let received: readonly Finding[] = [];
    service.getByInspection(501).subscribe((findings) => (received = findings));

    httpMock
      .expectOne(`${API}/findings?inspectionId=501`)
      .flush([rowWithoutResolvedAt]);

    // `toBeNull()` y no `toBeFalsy()`: `undefined` también es falsy, así que
    // con `toBeFalsy` este test pasaría CON el bug puesto. Es el error de
    // aserción más común y el que convierte un test de regresión en adorno.
    expect(received[0].resolvedAt).toBeNull();
  });
});
