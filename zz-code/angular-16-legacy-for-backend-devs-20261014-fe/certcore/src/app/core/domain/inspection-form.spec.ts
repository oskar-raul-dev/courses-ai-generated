// src/app/core/domain/inspection-form.spec.ts
import { ChecklistTemplate } from '../models/checklist-template.model';
import { InspectionAnswer } from '../models/inspection.model';
import { buildAnswerForm, toAnswers } from './inspection-form';

/**
 * Sorpresa útil: `FormRecord`, `FormGroup` y `FormControl` son clases de
 * TypeScript, no directivas. No necesitan `TestBed`, ni un componente, ni una
 * plantilla, ni detección de cambios. Un formulario reactivo se puede construir
 * y comprobar en un test tan barato como el de una función pura, y casi nadie
 * lo sabe: la mayoría de los ejemplos que vas a encontrar montan un componente
 * entero para probar una validación.
 */
const template: ChecklistTemplate = {
  id: 'elevator-annual-v2',
  templateId: 'elevator-annual',
  version: 2,
  validFrom: '2024-01-01',
  validUntil: null,
  items: [
    { id: 'main-cable', title: 'Cable principal', criteria: ['no_wear', 'light_wear', 'critical_wear'], photoRequired: true, nonComplianceSeverity: 'critical' },
    { id: 'door-sensor', title: 'Sensor de puerta', criteria: ['ok', 'intermittent', 'failed'], photoRequired: false, nonComplianceSeverity: 'major' },
  ],
};

describe('buildAnswerForm', () => {
  it('crea un control por ítem, con el itemId como clave', () => {
    const form = buildAnswerForm(template, []);

    expect(Object.keys(form.controls)).toEqual(['main-cable', 'door-sensor']);
  });

  it('marca inválida la evidencia ausente cuando el ítem la exige', () => {
    const answers: readonly InspectionAnswer[] = [
      { itemId: 'main-cable', answer: 'light_wear', evidenceUrl: null, note: null },
    ];

    const form = buildAnswerForm(template, answers);

    // `photoRequired: true` en la plantilla se convierte en un validador. Que
    // esto se pueda comprobar sin pintar nada es la prueba de que la regla
    // vive en el DATO y no en la pantalla.
    expect(form.get(['main-cable', 'evidenceUrl'])?.hasError('required')).toBeTrue();
  });

  it('rechaza una respuesta que no está entre los criterios del ítem', () => {
    const answers: readonly InspectionAnswer[] = [
      { itemId: 'main-cable', answer: 'no_se', evidenceUrl: null, note: null },
    ];

    const form = buildAnswerForm(template, answers);

    expect(form.get(['main-cable', 'answer'])?.hasError('notAllowed')).toBeTrue();
  });
});

describe('toAnswers', () => {
  it('no incluye los ítems sin responder', () => {
    const form = buildAnswerForm(template, [
      { itemId: 'door-sensor', answer: 'ok', evidenceUrl: null, note: null },
    ]);

    // Una inspección a medias guarda lo respondido, no un hueco por ítem. Es
    // la decisión de la Fase 8 §5.3 y éste es el test que la fija.
    expect(toAnswers(form).map((answer) => answer.itemId)).toEqual(['door-sensor']);
  });
});
