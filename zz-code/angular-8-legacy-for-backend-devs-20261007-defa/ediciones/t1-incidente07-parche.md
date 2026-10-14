**Parche mínimo**

Para el hallazgo 2, corregir el dato: los dos bordes, con el desfase de Ottawa en
invierno, que es lo que la norma dice.

```bash
# El borde se corrige en el dato; el código no se toca.
curl -s -X PATCH -H "Content-Type: application/json" \
  -d '{"effectiveTo": "2021-12-31T23:59:59-05:00"}' http://localhost:3000/referenceRanges/31
curl -s -X PATCH -H "Content-Type: application/json" \
  -d '{"effectiveFrom": "2022-01-01T00:00:00-05:00"}' http://localhost:3000/referenceRanges/32
```

El resultado 9102 sigue `preliminary`, así que su veredicto se recalcula al
mostrarse: vuelve a salir en rojo. Si ya hubiera estado validado, el parche no lo
tocaría —`rangeVersionApplied` está congelado— y habría que revisarlo a mano: es
el detector de la prevención.

Para el hallazgo 1 **no hay parche**, y proponer uno sería el error: una alarma
que avise de verdad —un canal, un turno de guardia, un acuse de recibo— es un
subsistema, no una línea.

**La refactorización correcta** (que en Track A 💸 no se paga)

Que la vigencia deje de ser un instante y pase a ser lo que la norma dice: **una
fecha de calendario en la zona de la aplicación** (`'2022-01-01'` en
`America/Toronto`), y que `selectActiveRange` convierta el instante del evento a
esa fecha antes de comparar, con `Intl` o con una librería con soporte de zona
(Luxon, `date-fns-tz`), como dice la deuda 💸 declarada en la **Fase 8 §5.3**. Así
deja de importar cómo escribió el borde quien lo cargó, y eso arregla la clase
entera, no el caso.

Y encima de eso hay una tercera pregunta, que no es de código y que hay que hacer
antes de escribir nada: **¿a qué hora, exactamente, entra en vigor una norma
clínica?** Mientras nadie la conteste, cualquier implementación está adivinando —
que es la razón por la que un "bug de fechas" casi nunca es un bug de fechas.

**Prueba de regresión**

```typescript
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
```

