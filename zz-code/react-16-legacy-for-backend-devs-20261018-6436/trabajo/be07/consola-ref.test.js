// trabajo/be07/consola-ref.test.js — se copia a src/features/reconciliation/ el tiempo de una corrida.
// Lo que la consola calcula para la Rueda de fin de mes, con las funciones de la Fase 8, sobre los mismos datos
// que siembra el backend (mock/db.json) y el reporte de la tienda (mock/googlePlay/earnings.json).
import { countLanded, oddsAudit } from "./oddsAudit";
import { reconcilePurchases } from "./reconciliationMath";

const db = require("../../../mock/db.json");
const earnings = require("../../../mock/googlePlay/earnings.json");

test("referencia de la consola", () => {
  const segments = db.segments.filter((s) => s.wheelId === 4);
  const counts = countLanded(db.spinLog.filter((r) => r.wheelId === 4), segments);
  const audit = oddsAudit(counts, segments.map((s) => s.weightBp));
  const purchases = reconcilePurchases(db.purchases, earnings);
  console.log("REF " + JSON.stringify({
    spins: counts.reduce((a, b) => a + b, 0), counts, chi2: audit.chi2, chi2Alarm: audit.chi2Alarm,
    bandAlarms: audit.bandAlarms.map((i) => segments[i].segmentId),
    purchases: { ...purchases.totals, missingInApi: purchases.missingInApi, duplicatedInApi: purchases.duplicatedInApi },
  }));
});
