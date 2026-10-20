// Exploración de A14 (no va al curso): ley de grandes números y potencia de detección.
import { oddsAudit, countLanded } from "../features/reconciliation/oddsAudit";
const db = require("../../mock/db.json");
const { generateSpinLog } = require("../../mock/spinLogGenerator");
const segments = db.segments.filter((s) => s.wheelId === 4);
const weights = segments.map((s) => s.weightBp);
test("explorar", () => {
  for (const n of [100, 1000, 10000, 100000]) {
    const c = countLanded(generateSpinLog({ seed: 42, spins: n, wheelId: 4, segments }), segments);
    console.log("LGN", n, "esclusa", c[7], "frecuencia", (c[7] / n * 100).toFixed(3) + " %", "sin-premio", (c[0] / n * 100).toFixed(2) + " %");
  }
  for (const n of [200, 500, 1000, 2000, 5000]) {
    let any = 0, chi = 0;
    for (let s = 1; s <= 300; s++) {
      const r = oddsAudit(countLanded(generateSpinLog({ seed: 1000 + s, spins: n, wheelId: 4, segments, rule: "accommodating" }), segments), weights);
      if (r.chi2Alarm) chi++; if (r.chi2Alarm || r.bandAlarms.length) any++;
    }
    console.log("potencia", n, "chi", chi, "cualquiera", any, "de 300");
  }
});
