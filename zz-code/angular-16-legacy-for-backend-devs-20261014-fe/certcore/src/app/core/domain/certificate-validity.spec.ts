// src/app/core/domain/certificate-validity.spec.ts — los dos casos que valen por diez
import { computeValidity } from './certificate-validity';

describe('computeValidity', () => {
  // `addMonths` es privada a propósito (Fase 10 §5.2), así que el recorte se
  // prueba por la única puerta que lo usa. Un test que la importara fijaría un
  // detalle de implementación que la Fase 10 decidió no publicar.

  it('recorta al último día del mes cuando el día no existe allí', () => {
    // 29 de febrero de un año bisiesto, más doce meses. La aritmética ingenua
    // da el 1 de marzo y REGALA un día de vigencia; la correcta recorta al 28.
    // Es un caso que llega una vez cada cuatro años y que ningún QA prueba.
    expect(computeValidity('2024-02-29T09:00:00-05:00').until).toBe('2025-02-28T23:59:59-05:00');
  });

  it('cuenta desde el día del negocio, no desde el de UTC', () => {
    // Emitido a las 23:30 del 15 de marzo en Bogotá, que en UTC ya es el 16.
    // Vence el 15: es el mismo borde que `todayInBusinessZone`, abajo, pero
    // sin andamio, porque aquí el instante entra por parámetro.
    expect(computeValidity('2024-03-15T23:30:00-05:00').until).toBe('2025-03-15T23:59:59-05:00');
  });
});
