import { TestBed, fakeAsync, tick } from '@angular/core/testing';
import { BehaviorSubject, of } from 'rxjs';

import { FindingApiService } from '../api/finding-api.service';
import { AssetStateService } from '../state/asset-state.service';
import { CertificateStateService } from '../state/certificate-state.service';
import { InspectionStateService } from '../state/inspection-state.service';
import { TemplateStateService } from '../state/template-state.service';
import { DASHBOARD_REFRESH_MS, DashboardMetricsService } from './dashboard-metrics.service';

describe('DashboardMetricsService', () => {
  let service: DashboardMetricsService;
  let inspectionState: { inspections$: BehaviorSubject<never[]>; load: jasmine.Spy };

  beforeEach(() => {
    inspectionState = { inspections$: new BehaviorSubject<never[]>([]), load: jasmine.createSpy('load') };

    TestBed.configureTestingModule({
      providers: [
        { provide: InspectionStateService, useValue: inspectionState },
        { provide: TemplateStateService, useValue: { state$: of({ versions: [] }), load: () => undefined } },
        { provide: CertificateStateService, useValue: { state$: of({ items: [] }), load: () => undefined } },
        { provide: AssetStateService, useValue: { assets$: of([]), load: () => undefined } },
        { provide: FindingApiService, useValue: { getAll: () => of([]) } },
      ],
    });

    service = TestBed.inject(DashboardMetricsService);
  });

  it('refresca cada minuto', fakeAsync(() => {
    const subscription = service.metrics$.subscribe();

    // `timer(0, ms)` no dispara al suscribirse: el 0 es un setTimeout de cero,
    // y en fakeAsync hasta ése hay que adelantarlo.
    tick(0);
    expect(inspectionState.load).toHaveBeenCalledTimes(1);

    tick(DASHBOARD_REFRESH_MS);

    expect(inspectionState.load).toHaveBeenCalledTimes(2);

    // Con `refCount: true`, desuscribirse mata el timer. Sin esta línea,
    // fakeAsync lanza al terminar: "Error: 1 periodic timer(s) still in the queue."
    subscription.unsubscribe();
  }));
});
