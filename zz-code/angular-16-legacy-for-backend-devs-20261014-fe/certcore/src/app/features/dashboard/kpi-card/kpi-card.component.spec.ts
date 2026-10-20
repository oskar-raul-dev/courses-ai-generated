import { ComponentFixture, TestBed } from '@angular/core/testing';

import { KpiCardComponent } from './kpi-card.component';

// COMPONENTE NUEVO — standalone.
describe('KpiCardComponent', () => {
  let fixture: ComponentFixture<KpiCardComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      // Va en `imports` porque es standalone: el componente ya declara lo que
      // usa —NgIf, MatIconModule— en su propio decorador, así que el TestBed
      // sólo tiene que conocerlo a él.
      imports: [KpiCardComponent],
    });

    fixture = TestBed.createComponent(KpiCardComponent);
  });

  it('pinta el valor y la etiqueta', () => {
    // `setInput` y no `fixture.componentInstance.label = …`. Con
    // `@Input({ required: true })` es la forma correcta, y además dispara
    // `ngOnChanges` — que es lo que el gráfico de la Fase 11 necesita y una
    // asignación directa no hace.
    fixture.componentRef.setInput('label', 'Certificados vencidos');
    fixture.componentRef.setInput('value', 7);
    fixture.componentRef.setInput('icon', 'error');

    fixture.detectChanges();

    const text: string = fixture.nativeElement.textContent;

    expect(text).toContain('7');
    expect(text).toContain('Certificados vencidos');
  });

  it('no pinta la aclaración cuando no la hay', () => {
    fixture.componentRef.setInput('label', 'Inspecciones en curso');
    fixture.componentRef.setInput('value', 3);
    fixture.componentRef.setInput('icon', 'assignment');
    fixture.detectChanges();

    // `hint` es `string | null` y el `null` significa "sin aclaración". El
    // test comprueba la ausencia del nodo, no que el texto esté vacío.
    expect(fixture.nativeElement.querySelector('.kpi-card-hint')).toBeNull();
  });
});
