import { TestBed, discardPeriodicTasks, fakeAsync, tick } from '@angular/core/testing';
import { RouterTestingModule } from '@angular/router/testing';
import { NEVER, of } from 'rxjs';

import { DASHBOARD_REFRESH_MS, DashboardMetricsService } from '../../../core/dashboard/dashboard-metrics.service';
import { InspectionStateService } from '../../../core/state/inspection-state.service';
import { DashboardModule } from '../dashboard.module';
import { DashboardHomeComponent } from './dashboard-home.component';

// Componente HEREDADO: se monta con su módulo alrededor, como en 2021.
describe('DashboardHomeComponent', () => {
  let inspectionState: { inspections$: unknown; load: jasmine.Spy };

  beforeEach(() => {
    inspectionState = { inspections$: of([]), load: jasmine.createSpy('load') };

    TestBed.configureTestingModule({
      imports: [DashboardModule, RouterTestingModule],
      providers: [
        // El panel de verdad no importa aquí: NEVER deja el cascarón en
        // "Cargando" y sin ningún timer propio que confunda la cuenta.
        { provide: DashboardMetricsService, useValue: { metrics$: NEVER } },
        { provide: InspectionStateService, useValue: inspectionState },
      ],
    });
  });

  it('no deja nada pidiendo cuando se destruye', fakeAsync(() => {
    const fixture = TestBed.createComponent(DashboardHomeComponent);
    fixture.detectChanges();
    tick(DASHBOARD_REFRESH_MS);
    const beforeDestroy = inspectionState.load.calls.count();

    fixture.destroy();
    tick(3 * DASHBOARD_REFRESH_MS);

    // Falla con el refresco del incidente: tres llamadas más, de un componente
    // que ya no existe.
    expect(inspectionState.load.calls.count()).toBe(beforeDestroy);
    discardPeriodicTasks();
  }));
});
