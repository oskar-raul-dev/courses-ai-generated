// src/app/results/store/reference-range.selector.ts

// Elige el rango vigente para un analito en una fecha dada. Recorre las
// versiones y devuelve la que tiene la fecha dentro de su ventana
// [effectiveFrom, effectiveTo]. effectiveTo null significa "sin cierre".
//
// 💸 DEUDA INTENCIONAL: la comparación se hace con new Date(...) sobre strings
// ISO y con .getTime(), que compara instantes absolutos. Eso es correcto
// mientras los dos lados sean instantes con su offset, y deja de serlo en dos
// casos que LabCore tiene: un borde de vigencia cargado en UTC por un script
// que lo escribió con toISOString() ('2022-01-01T00:00:00Z' es el 31 de
// diciembre a las 19:00 en Ottawa), y un atDate sin hora ('2022-01-01', que
// JavaScript lee como medianoche UTC). En los dos, cuando la fecha cae junto
// al borde -la noche del 31 de diciembre- el instante queda del lado
// equivocado y se elige la versión que NO correspondía.
//
//   Lo correcto hoy: que la vigencia sea una fecha de calendario en la zona de
//   la aplicación (America/Toronto, fijada en environment desde la Fase 2), y
//   que el instante del evento se convierta a esa fecha antes de comparar, con
//   Intl o con una librería con soporte de zona (Luxon, date-fns-tz). La
//   comparación de vigencia no debería depender de cómo se escribió el borde
//   ni de la zona del navegador, que el usuario puede cambiar.
//
//   Por que en Track A NO se paga: LabCore compara así, y el bug que
//   produce -un rango de un día mal aplicado en el borde de una norma nueva-
//   es precisamente el incidente 07 que el estudiante tiene que aprender a
//   reproducir y localizar. Arreglarlo acá borraría el ejercicio.
export function selectActiveRange(ranges: any[], analyte: string, atDate: string): any {
  var target = new Date(atDate).getTime();

  for (var i = 0; i < ranges.length; i++) {
    var range = ranges[i];
    if (range.analyte !== analyte) { continue; }

    var from = new Date(range.effectiveFrom).getTime();
    // effectiveTo null: ventana abierta hacia el futuro.
    var to = range.effectiveTo ? new Date(range.effectiveTo).getTime() : Infinity;

    if (target >= from && target <= to) {
      return range;
    }
  }

  // Ningun rango cubre esa fecha. Devolver null y no reventar: un resultado sin
  // rango vigente es un caso real (analito nuevo sin norma todavía) y el
  // componente tiene que saber mostrarlo como "sin rango", no en rojo.
  return null;
}

// Dado un value y un rango, dice si está fuera de rango y si es crítico. Es
// derivado puro: no toca el store ni guarda nada.
export function evaluateResult(value: number, range: any): any {
  if (!range) {
    return { outOfRange: false, critical: false, hasRange: false };
  }
  var outOfRange = value < range.low || value > range.high;
  var critical = value <= range.criticalLow || value >= range.criticalHigh;
  return { outOfRange: outOfRange, critical: critical, hasRange: true };
}
