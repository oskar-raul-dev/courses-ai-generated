import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';

import { AppConfigService } from '../config/app-config.service';
import { Inspection } from '../models/inspection.model';
import { InspectionStateService } from './inspection-state.service';

// La 501 tal como está en la semilla: agosto de 2023, ejecutada con la v1.
const INSPECTION_501: Inspection = {
  id: 501,
  assetId: 'ASC-CENTRAL-04',
  inspectorId: 'INS-15',
  templateId: 'elevator-annual',
  templateVersion: 1,
  status: 'approved',
  startedAt: '2023-08-02T09:00:00-05:00',
  completedAt: '2023-08-02T12:00:00-05:00',
  answers: [],
};

describe('InspectionStateService — invariante de plantillas', () => {
  let service: InspectionStateService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      // Desde la Fase 13 los servicios de API leen la URL de AppConfigService,
      // que en un test nadie carga: se le da el valor a mano.
      providers: [{ provide: AppConfigService, useValue: { current: { apiBaseUrl: '/api', environmentName: 'DEV' } } }],
    });
    service = TestBed.inject(InspectionStateService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => httpMock.verify());

  it('pide la versión que la inspección guardó, no la vigente', () => {
    service.findingsOf(INSPECTION_501).subscribe();

    const templateRequest = httpMock.expectOne((request) => request.url.endsWith('/templates'));

    // ❌ El código del incidente 08 resolvía por la fecha de HOY y pedía la v2.
    expect(templateRequest.request.params.get('templateId')).toBe('elevator-annual');
    expect(templateRequest.request.params.get('version')).toBe('1');

    httpMock.expectOne((request) => request.url.endsWith('/findings')).flush([]);
    templateRequest.flush([
      { id: 'elevator-annual-v1', templateId: 'elevator-annual', version: 1, validFrom: '2021-01-01', validUntil: '2023-12-31', items: [] },
    ]);
  });
});
