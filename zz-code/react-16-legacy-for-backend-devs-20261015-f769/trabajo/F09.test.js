// Pruebas de F09 (copia de zz-code; no va al curso): cálculos puros y la memoria de los selectores.
import { summarizeSpins, countManualSpins, netRevenueCents, bandRows } from "../features/dashboard/dashboardMath";
import { selectSpinSummary, selectBands } from "../features/dashboard/dashboardSelectors";

const db = require("../../mock/db.json");
const earnings = require("../../mock/googlePlay/earnings.json");
const segments = db.segments.filter((s) => s.wheelId === 4);
const spinLog = db.spinLog.filter((r) => r.wheelId === 4);
const stateWith = (extra = {}) => ({ dashboard: { wheelId: 4, segments, spinLog, grants: [], earnings, ...extra } });

test("summarizeSpins: totales por origen y conteos por segmento en una pasada", () => {
  const s = summarizeSpins(spinLog, segments);
  expect(s.total).toBe(10000);
  expect(s.free + s.paid).toBe(10000);
  expect(s.paid).toBe(2434 - 0); // los pagos que consumieron compras
  expect(s.countsByOrigin.all).toEqual([3017, 1962, 1515, 1483, 1040, 784, 142, 57]);
  expect(s.countsByOrigin.free.map((c, i) => c + s.countsByOrigin.paid[i])).toEqual(s.countsByOrigin.all);
});

test("countManualSpins y netRevenueCents", () => {
  expect(countManualSpins([{ prize: "spin:4" }, { prize: "vidas-5" }, { prize: "spin:1" }, { prize: "spin:4" }], 4)).toBe(2);
  expect(netRevenueCents(earnings)).toBe(13560);
});

test("bandRows: la banda de la Esclusa de Oro con 10.000 giros", () => {
  const rows = bandRows([3017, 1962, 1515, 1483, 1040, 784, 142, 57], segments.map((s) => s.weightBp));
  expect(rows[7].expected).toBe(50);
  expect(rows[7].low).toBeCloseTo(28.84, 2);
  expect(rows[7].high).toBeCloseTo(71.16, 2);
});

test("la memoria: misma bitácora, ninguna pasada más; bitácora nueva, una", () => {
  const before = selectSpinSummary.recomputations();
  const state = stateWith();
  selectBands(state);
  selectBands({ ...state, other: 1 }); // otra rama cambió; la del tablero no
  selectBands(state);
  expect(selectSpinSummary.recomputations() - before).toBe(1);
  selectBands(stateWith({ spinLog: spinLog.slice(0, 100) }));
  expect(selectSpinSummary.recomputations() - before).toBe(2);
});
