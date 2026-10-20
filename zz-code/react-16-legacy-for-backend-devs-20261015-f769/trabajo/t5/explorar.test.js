// Exploración de T5 (no va al curso): oddsAudit sobre bitácoras sembradas de 10.000 giros.
import { oddsAudit, countLanded } from "../features/reconciliation/oddsAudit";
const db = require("../../mock/db.json");
const { generateSpinLog } = require("../../mock/spinLogGenerator");
const segments = db.segments.filter((s) => s.wheelId === 4);
const weights = segments.map((s) => s.weightBp);
const audit = (seed, rule) => oddsAudit(countLanded(generateSpinLog({ seed, spins: 10000, wheelId: 4, segments, rule }), segments), weights);
test("explorar", () => {
  for (const seed of [42, 7, 2026]) {
    for (const rule of ["substitute", "accommodating"]) {
      const log = generateSpinLog({ seed, spins: 10000, wheelId: 4, segments, rule });
      const counts = countLanded(log, segments);
      const delivered = rule === "substitute" ? countLanded(log.map((r) => ({ landedSegment: r.deliveredPrize })), segments) : null;
      console.log(seed, rule, JSON.stringify(counts), JSON.stringify(oddsAudit(counts, weights)),
        delivered ? "entregado: " + JSON.stringify(delivered) + " " + JSON.stringify(oddsAudit(delivered, weights)) : "");
    }
  }
  for (const rule of ["substitute", "accommodating"]) {
    let any = 0, chi = 0, band = 0;
    for (let s = 1; s <= 300; s++) { const r = audit(1000 + s, rule); if (r.chi2Alarm) chi++; if (r.bandAlarms.length) band++; if (r.chi2Alarm || r.bandAlarms.length) any++; }
    console.log("300 semillas", rule, { any, chi, band });
  }
});
