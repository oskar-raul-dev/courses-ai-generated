// src/app/results/store/reference-range.selector.spec.ts
var V1 = { version: 1, analyte: 'potassium', low: 3.5, high: 5.1, criticalLow: 2.5, criticalHigh: 6.5,
           effectiveFrom: '2019-01-01T00:00:00-05:00' };
var V2 = { version: 2, analyte: 'potassium', low: 3.5, high: 5.2, criticalLow: 2.8, criticalHigh: 7.0,
           effectiveTo: null };

it('con los bordes en hora de Ottawa, la noche del 31 aplica la v1', function () {
  var ranges = [
    Object.assign({}, V1, { effectiveTo: '2021-12-31T23:59:59-05:00' }),
    Object.assign({}, V2, { effectiveFrom: '2022-01-01T00:00:00-05:00' })
  ];
  // 20:15 del 31 en Ottawa = 01:15Z del 1. Con el borde bien escrito, sigue
  // siendo el 31 para la norma, y un potasio de 6.8 sale crítico.
  var range = selectActiveRange(ranges, 'potassium', '2021-12-31T20:15:00-05:00');
  expect(range.version).toBe(1);
  expect(evaluateResult(6.8, range).critical).toBe(true);
});

it('un borde escrito en UTC adelanta la norma nueva a las 19:00 del 31', function () {
  var ranges = [
    Object.assign({}, V1, { effectiveTo: '2021-12-31T23:59:59Z' }),
    Object.assign({}, V2, { effectiveFrom: '2022-01-01T00:00:00Z' })
  ];
  // Documenta la trampa: si este test deja de pasar, alguien cambió cómo
  // compara selectActiveRange y hay que revisar todos los bordes cargados.
  expect(selectActiveRange(ranges, 'potassium', '2021-12-31T18:59:00-05:00').version).toBe(1);
  expect(selectActiveRange(ranges, 'potassium', '2021-12-31T19:00:00-05:00').version).toBe(2);
});
