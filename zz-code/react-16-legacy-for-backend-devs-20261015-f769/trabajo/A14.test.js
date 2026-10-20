// Ejemplos de A14, contra el oddsAudit de la F08 y su generador sembrado de bitácoras.
import { oddsAudit, countLanded, CHI2_CRITICAL_DF7_05 } from "../features/reconciliation/oddsAudit";

const db = require("../../mock/db.json");
const { generateSpinLog } = require("../../mock/spinLogGenerator");
const segments = db.segments.filter((s) => s.wheelId === 4);
const weights = segments.map((s) => s.weightBp);
const honest = (seed, spins) => countLanded(generateSpinLog({ seed, spins, wheelId: 4, segments }), segments);

// §1 — la ley de grandes números
test("§1: la frecuencia de la Esclusa de Oro se acerca a 0,5 % a medida que crecen los giros", () => {
  const goldOf = (spins) => honest(42, spins)[7];
  expect([100, 1000, 10000, 100000].map(goldOf)).toEqual([1, 6, 57, 484]);
  // 1 % · 0,6 % · 0,57 % · 0,484 %: el desvío relativo baja; el absoluto, no
});

// §3 — la banda de ±3σ, en enteros
test("§3: con 10.000 giros, 71 Esclusas de Oro está en la banda y 72 no", () => {
  // Los giros de más de la Esclusa de Oro salen de sin-premio: n sigue siendo 10.000.
  const with71 = [2979, 2000, 1500, 1500, 1000, 800, 150, 71];
  const with72 = [2978, 2000, 1500, 1500, 1000, 800, 150, 72];
  expect(with71.reduce((a, b) => a + b, 0)).toBe(10000);
  expect(oddsAudit(with71, weights).bandAlarms).toEqual([]);
  expect(oddsAudit(with72, weights).bandAlarms).toEqual([7]);
});

// §4 — el chi-cuadrado
test("§4: la bitácora sembrada de la Fase 8 da χ² = 4,49, lejos del crítico", () => {
  const r = oddsAudit(honest(42, 10000), weights);
  expect(r.chi2).toBeCloseTo(4.4877, 4);
  expect(r.chi2).toBeLessThan(CHI2_CRITICAL_DF7_05);
});

// §5 — cuánta muestra hace falta: la regla vieja, con pocos giros
test("§5: la rueda que se acomoda se detecta casi siempre desde 1.000 giros", () => {
  const detected = (spins) => {
    let alarms = 0;
    for (let s = 1; s <= 300; s++) {
      const log = generateSpinLog({ seed: 1000 + s, spins, wheelId: 4, segments, rule: "accommodating" });
      const r = oddsAudit(countLanded(log, segments), weights);
      if (r.chi2Alarm || r.bandAlarms.length > 0) alarms += 1;
    }
    return alarms;
  };
  expect([200, 500, 1000, 2000].map(detected)).toEqual([69, 211, 299, 300]);
});

// §6 — pasar la auditoría no es ser impredecible
test("§6: un generador sembrado pasa la auditoría y es completamente predecible", () => {
  const a = generateSpinLog({ seed: 42, spins: 10000, wheelId: 4, segments });
  const b = generateSpinLog({ seed: 42, spins: 10000, wheelId: 4, segments });
  expect(b.map((r) => r.landedSegment)).toEqual(a.map((r) => r.landedSegment)); // misma semilla, mismos giros
  expect(oddsAudit(countLanded(a, segments), weights).chi2Alarm).toBe(false);
});
