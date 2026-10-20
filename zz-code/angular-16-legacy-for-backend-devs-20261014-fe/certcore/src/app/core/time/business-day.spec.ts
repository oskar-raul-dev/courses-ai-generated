// src/app/core/time/business-day.spec.ts — el único que necesita andamio
import { todayInBusinessZone } from './business-day';

describe('todayInBusinessZone', () => {
  /**
   * ⚠️ ÉSTE es el que necesita andamio, y es el único del archivo.
   * `todayInBusinessZone()` no recibe nada: pregunta la hora. Para testearlo
   * hay que falsear el reloj del navegador entero.
   *
   * Compáralo con `deriveCertificateStatus`, más arriba, que hace lo mismo y recibe el
   * instante. La diferencia entre los dos archivos no es de test: es de diseño,
   * y el test es lo que la delata. Guarda esta comparación para el ejercicio 26.
   */
  beforeEach(() => {
    jasmine.clock().install();
    // Las 23:30 en Bogotá del 6 de septiembre. En UTC ya es el día 7, y ése es
    // exactamente el bug que `toBusinessDay` existe para no tener.
    jasmine.clock().mockDate(new Date('2026-09-07T04:30:00Z'));
  });

  afterEach(() => {
    // Si esto se olvida, el reloj falso sobrevive a este `describe` y
    // contamina los siguientes — que con `random: true` no son siempre los
    // mismos. Bienvenido al incidente 17.
    jasmine.clock().uninstall();
  });

  it('devuelve el día del negocio, no el de UTC', () => {
    expect(todayInBusinessZone()).toBe('2026-09-06');
  });
});
