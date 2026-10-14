// src/app/shared/offset-check.spec.ts
import { offsetDoesNotMatchZone } from './offset-check';

describe('offsetDoesNotMatchZone', function () {
  var ottawa = 'America/Toronto';

  it('marca el -05:00 escrito en horario de verano', function () {
    expect(offsetDoesNotMatchZone('2021-03-15T09:00:00-05:00', ottawa)).toBe(true);
  });

  it('no marca el -05:00 de invierno, que es verdad', function () {
    expect(offsetDoesNotMatchZone('2021-03-12T09:00:00-05:00', ottawa)).toBe(false);
  });

  it('no marca un -04:00 de verano ni una marca en Z', function () {
    expect(offsetDoesNotMatchZone('2021-03-15T09:00:00-04:00', ottawa)).toBe(false);
    expect(offsetDoesNotMatchZone('2021-03-15T13:38:00.000Z', ottawa)).toBe(false);
  });
});
