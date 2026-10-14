**Hallazgo 2 — Y además el veredicto estaba mal calculado.**

Esa es la parte del ticket que parecía un detalle —*"lo mostraba en amarillo, no
en rojo"*— y es un bug real.

```bash
curl -s "http://localhost:3000/samples/612" | grep collectedAt
# "collectedAt": "2021-12-31T20:15:00-05:00"      ← viernes 31, 8:15 de la noche
curl -s "http://localhost:3000/referenceRanges?analyte=potassium"
# v1 … "criticalHigh": 6.5, "effectiveTo": "2021-12-31T23:59:59Z"
# v2 … "criticalHigh": 7.0, "effectiveFrom": "2022-01-01T00:00:00Z"
```

```
muestra   2021-12-31T20:15:00-05:00   ==   2022-01-01T01:15:00Z
borde v2  2022-01-01T00:00:00Z        ==   2021-12-31T19:00:00-05:00
                                           └─ la v2 "empezó" a las 7 de la noche del 31
```

La norma armonizada rige desde la medianoche del 1 de enero **en Ottawa**, pero el
script que la cargó escribió los dos bordes con `toISOString()`, en UTC. La
medianoche UTC son las 19:00 del 31 en Ottawa, y la muestra de las 20:15 cae del
lado de la v2. `selectActiveRange` compara bien —con `.getTime()`, instantes
absolutos—; lo que no está bien es el borde. Resultado: se aplicó la norma que
todavía no regía. Con la v1, que era la que le tocaba, 6.8 supera el
`criticalHigh` de 6.5 y es **crítico** (rojo); con la v2, que sube el crítico a
7.0, queda solo **fuera de rango** (amarillo). Eso es exactamente lo que vio la
coordinadora.

Confirmado sin depurador, sobre la función pura:

```js
selectActiveRange(ranges, 'potassium', '2021-12-31T20:15:00-05:00').version
// 2      ← debería ser 1
selectActiveRange(ranges, 'potassium', '2021-12-31T12:15:00-05:00').version
// 1      ← la misma fecha, de día, elige bien
```

**La hora, y no el día, decide el veredicto.** Y eso explica la parte del ticket
que sonaba a superstición: falla **de noche**, y en el borde. En el 95% de los días
da igual porque la fecha cae lejos de un límite; los días que no da igual son los
bordes, y este cayó en la noche de un viernes antes de un feriado, cuando nadie
estaba mirando.

