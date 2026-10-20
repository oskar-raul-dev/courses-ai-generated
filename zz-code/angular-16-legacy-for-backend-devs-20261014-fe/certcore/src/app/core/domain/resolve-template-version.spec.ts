// src/app/core/domain/resolve-template-version.spec.ts
import { ChecklistTemplate } from '../models/checklist-template.model';
import { BusinessDay } from '../time/business-day';
import { TemplateResolution, resolveTemplateVersion } from './resolve-template-version';

/**
 * Constructor de fixtures. Un test que declara ocho objetos completos con sus
 * seis campos es ilegible; uno que declara `version(1, '2021-01-01',
 * '2023-12-31')` se lee como la tabla que copia.
 *
 * Los `items` van vacíos porque a esta función no le importan. Rellenarlos
 * "por realismo" añadiría ruido a lo único que el lector tiene que comparar.
 */
function version(
  versionNumber: number,
  validFrom: BusinessDay,
  validUntil: BusinessDay | null,
): ChecklistTemplate {
  return {
    id: `elevator-annual-v${versionNumber}`,
    templateId: 'elevator-annual',
    version: versionNumber,
    validFrom,
    validUntil,
    items: [],
  };
}

const v1 = version(1, '2021-01-01', '2023-12-31');
const v2 = version(2, '2024-01-01', null);

interface ResolutionCase {
  readonly name: string;
  readonly versions: readonly ChecklistTemplate[];
  readonly day: BusinessDay;
  readonly expected: TemplateResolution['status'];
  /** Qué versión debe resolver. `null` cuando el resultado no es `resolved`. */
  readonly expectedVersion: number | null;
}

// La misma tabla de la Fase 7 §5.3, fila por fila. Que el test y la
// documentación tengan la misma forma no es casualidad: la tabla se escribió
// pensando en esto, dos fases antes de que existiera Jasmine en el proyecto.
const CASES: readonly ResolutionCase[] = [
  { name: 'caso normal: día dentro de la v1', versions: [v1, v2], day: '2023-08-02', expected: 'resolved', expectedVersion: 1 },
  { name: 'primer día de vigencia de la v2', versions: [v1, v2], day: '2024-01-01', expected: 'resolved', expectedVersion: 2 },
  { name: 'último día de vigencia de la v1', versions: [v1, v2], day: '2023-12-31', expected: 'resolved', expectedVersion: 1 },
  { name: 'antes de que existiera ninguna versión', versions: [v1], day: '2020-12-31', expected: 'none', expectedVersion: null },
  { name: 'hueco entre versiones', versions: [v1, version(2, '2024-02-01', null)], day: '2024-01-15', expected: 'none', expectedVersion: null },
  { name: 'solape por cierre olvidado', versions: [version(1, '2021-01-01', null), v2], day: '2024-06-01', expected: 'ambiguous', expectedVersion: null },
  { name: 'vigente indefinidamente', versions: [v2], day: '2030-01-01', expected: 'resolved', expectedVersion: 2 },
  { name: 'familia vacía', versions: [], day: '2024-06-01', expected: 'none', expectedVersion: null },
];

describe('resolveTemplateVersion', () => {
  // ⚠️ El `it` se genera DENTRO del bucle, uno por caso. La alternativa —un
  // solo `it` con el bucle dentro— es más corta y mucho peor: cuando falla,
  // Jasmine dice "resolveTemplateVersion falla" y tú tienes que averiguar cuál
  // de los ocho. Con un `it` por fila, el nombre del test ES el diagnóstico.
  for (const testCase of CASES) {
    it(`resuelve ${testCase.expected} — ${testCase.name}`, () => {
      const resolution = resolveTemplateVersion(testCase.versions, testCase.day);

      expect(resolution.status).toBe(testCase.expected);

      // El estrechamiento de la unión discriminada vale también aquí: dentro
      // de este `if`, TypeScript sabe que `resolution.template` existe. Sin la
      // unión, harían falta un `as` o un `!`, y en CertCore no se usan.
      if (resolution.status === 'resolved') {
        expect<number | null>(resolution.template.version).toBe(testCase.expectedVersion);
      }
    });
  }
});
