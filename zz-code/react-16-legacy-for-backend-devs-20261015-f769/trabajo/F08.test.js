// Pruebas unitarias de F08 (copia de zz-code; no va al curso). Sin red: sobre el db.json sembrado.
import { toCents, formatCents } from "../features/reconciliation/money";
import { prizeShare, prorateSpinPrice, storeFeeCents, reconcilePurchases } from "../features/reconciliation/reconciliationMath";
import { oddsAudit, countLanded, CHI2_CRITICAL_DF7_05 } from "../features/reconciliation/oddsAudit";
import wheelReducer from "../features/wheels/wheelSlice";
import { reconcileWheel } from "../features/reconciliation/reconciliationSlice";

const db = require("../../mock/db.json");
const earnings = require("../../mock/googlePlay/earnings.json");
const { generateSpinLog } = require("../../mock/spinLogGenerator");
const segments = db.segments.filter((s) => s.wheelId === 4);
const weights = segments.map((s) => s.weightBp);
const log = db.spinLog.filter((r) => r.wheelId === 4);

describe("money", () => {
  test("toCents sin floats, y rechaza tres decimales", () => {
    expect(toCents("20.99")).toBe(2099);
    expect(toCents("20,99")).toBe(2099);
    expect(toCents("0.5")).toBe(50);
    expect(toCents(21)).toBe(2100);
    expect(() => toCents("20.999")).toThrow();
  });
  test("formatCents", () => {
    expect(formatCents(2099)).toBe("US$20,99");
    expect(formatCents(1596000)).toBe("US$15.960,00");
    expect(formatCents(-50)).toBe("-US$0,50");
    expect(() => formatCents(4.198)).toThrow();
  });
});

describe("prorrateo", () => {
  test("prizeShare de 2.099 entre 500: base 4, +1 en 99, suma exacta", () => {
    const shares = prizeShare(2099, 500);
    expect(shares.filter((c) => c === 5)).toHaveLength(99);
    expect(shares.filter((c) => c === 4)).toHaveLength(401);
    expect(shares.reduce((a, b) => a + b, 0)).toBe(2099);
    expect(() => prizeShare(20.99, 500)).toThrow();
  });
  test("prorateSpinPrice: las filas suman exactamente el precio", () => {
    const cents = prorateSpinPrice(2099, [150, 100, 75, 75, 50, 40, 8, 2]);
    expect(cents).toEqual([699, 400, 300, 300, 200, 160, 32, 8]);
    expect(cents.reduce((a, b) => a + b, 0)).toBe(2099);
  });
  test("con los paquetes de la bitácora sembrada, también", () => {
    for (const token of ["tok-ago-05", "tok-ago-12", "tok-ago-19", "tok-ago-26"]) {
      const counts = countLanded(log.filter((r) => r.purchaseToken === token), segments);
      expect(counts.reduce((a, b) => a + b, 0)).toBe(500);
      expect(prorateSpinPrice(2099, counts).reduce((a, b) => a + b, 0)).toBe(2099);
    }
  });
});

describe("compras", () => {
  test("la comisión de la tienda, redondeada al centavo sin floats", () => {
    expect(storeFeeCents(2099)).toBe(315); // 314,85
    expect(storeFeeCents(99)).toBe(15); // 14,85
    expect(storeFeeCents(100)).toBe(15);
  });
  test("API contra tienda, con los datos sembrados", () => {
    const r = reconcilePurchases(db.purchases, earnings);
    expect(r.missingInApi).toEqual(["tok-ago-31"]);
    expect(r.duplicatedInApi).toEqual(["tok-ago-17"]);
    expect(r.missingInStore).toEqual([]);
    expect(r.matched).toBe(39);
    expect(r.totals).toEqual({ chargedCents: 15960, feeCents: 2400, netCents: 13560 });
    expect(earnings.every((row) => row.feeCents === storeFeeCents(row.chargedCents))).toBe(true);
  });
});

describe("oddsAudit", () => {
  test("la rueda honesta sembrada (10.000 giros, semilla 42) no da alarma", () => {
    const counts = countLanded(log, segments);
    expect(counts).toEqual([3017, 1962, 1515, 1483, 1040, 784, 142, 57]);
    const r = oddsAudit(counts, weights);
    expect(r.bandAlarms).toEqual([]);
    expect(r.chi2).toBeCloseTo(4.4877, 4);
    expect(r.chi2Alarm).toBe(false);
  });
  test("auditar el premio entregado en vez del segmento da una falsa alarma", () => {
    const delivered = countLanded(log.map((r) => ({ landedSegment: r.deliveredPrize })), segments);
    const r = oddsAudit(delivered, weights);
    expect(r.chi2Alarm).toBe(true);
    expect(r.bandAlarms.map((i) => segments[i].segmentId)).toEqual(["avatar-comun", "set-gemas-basico", "avatar-raro"]);
  });
  test("la rueda que se acomoda alarma", () => {
    const old = generateSpinLog({ seed: 42, spins: 10000, wheelId: 4, segments, rule: "accommodating" });
    const r = oddsAudit(countLanded(old, segments), weights);
    expect(r.chi2Alarm).toBe(true);
    expect(r.chi2).toBeGreaterThan(CHI2_CRITICAL_DF7_05 * 10);
  });
  test("sin giros: ni alarma ni NaN", () => {
    expect(oddsAudit([0, 0, 0, 0, 0, 0, 0, 0], weights)).toEqual({ bandAlarms: [], chi2: 0, chi2Alarm: false });
  });
  test("solo enteros", () => {
    expect(() => oddsAudit([1.5, 2], [5000, 5000])).toThrow();
  });
});

describe("ended → reconciled", () => {
  const stateWith = (status) => ({ items: [{ id: 4, status, segments: [] }], loadingList: false, loadingMutation: false, error: null, editingId: null });
  const fulfilled = (status) => reconcileWheel.fulfilled({ wheel: { id: 4, status }, reconciliation: {} }, "req");
  test("desde ended pasa a reconciled", () => {
    expect(wheelReducer(stateWith("ended"), fulfilled("reconciled")).items[0].status).toBe("reconciled");
  });
  test("desde live no pasa (el reducer es la última barrera)", () => {
    expect(wheelReducer(stateWith("live"), fulfilled("reconciled")).items[0].status).toBe("live");
  });
});
