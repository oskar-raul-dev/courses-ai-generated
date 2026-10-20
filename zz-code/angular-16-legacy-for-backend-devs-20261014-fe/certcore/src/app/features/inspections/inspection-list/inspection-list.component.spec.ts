import { ComponentFixture, TestBed } from '@angular/core/testing';
import { MatTableModule } from '@angular/material/table';
import { RouterTestingModule } from '@angular/router/testing';
import { of } from 'rxjs';

import { Inspection } from '../../../core/models/inspection.model';
import { InspectionStateService } from '../../../core/state/inspection-state.service';
import { SharedModule } from '../../../shared/shared.module';
import { InspectionListComponent } from './inspection-list.component';

const INSPECTIONS_FIXTURE: readonly Inspection[] = [
  { id: 500, assetId: 'ASC-CENTRAL-03', inspectorId: 'INS-15', templateId: 'elevator-annual', templateVersion: 2, status: 'in_progress', startedAt: '2025-03-10T09:00:00-05:00', completedAt: null, answers: [] },
  { id: 501, assetId: 'ASC-CENTRAL-04', inspectorId: 'INS-15', templateId: 'elevator-annual', templateVersion: 1, status: 'approved', startedAt: '2023-08-02T09:00:00-05:00', completedAt: '2023-08-02T12:00:00-05:00', answers: [] },
];

// COMPONENTE HEREDADO — declarado en InspectionsModule desde la Fase 1.
describe('InspectionListComponent', () => {
  let fixture: ComponentFixture<InspectionListComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      /**
       * 🧬 Va en `declarations`, y hay que darle a mano lo que su NgModule le
       * daba: `SharedModule` para los componentes de Material que usa la
       * plantilla, y un doble del servicio de estado.
       *
       * Ponerlo en `imports` no compila, y el error —"no es un NgModule, un
       * componente standalone ni una directiva"— no dice lo que pasa. Al revés
       * pasa lo mismo: un standalone en `declarations` da un error explícito,
       * y ése sí se lee. El ejercicio 20 te hace ver los dos.
       */
      declarations: [InspectionListComponent],
      imports: [SharedModule, MatTableModule, RouterTestingModule],
      providers: [
        {
          provide: InspectionStateService,
          useValue: {
            state$: of({ items: INSPECTIONS_FIXTURE, selected: null, loading: false, error: null }),
            load: () => undefined,
          },
        },
      ],
    });

    fixture = TestBed.createComponent(InspectionListComponent);
  });

  it('lista una fila por inspección con su versión de plantilla', () => {
    fixture.detectChanges();

    const rows = fixture.nativeElement.querySelectorAll('tbody tr');

    expect(rows.length).toBe(INSPECTIONS_FIXTURE.length);
    // La versión a la vista es lo primero que se pregunta en un ticket sobre
    // esta pantalla, así que es lo que el test protege.
    expect(rows[0].textContent).toContain('v2');
  });
});
