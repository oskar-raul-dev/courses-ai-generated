// Incidente 21: los conteos de la Rueda de fin de mes (id 4) contra los pesos publicados, el χ² y
// cuántos jugadores sacaron el avatar común dos o más veces. Lee mock/db.json del directorio actual.
const db = require(require("path").resolve("mock/db.json"));
const WHEEL_ID = 4;
const segments = db.segments.filter((s) => s.wheelId === WHEEL_ID);
const rows = db.spinLog.filter((r) => r.wheelId === WHEEL_ID);
const counts = {};
for (const r of rows) counts[r.landedSegment] = (counts[r.landedSegment] || 0) + 1;
let chi2 = 0;
for (const s of segments) {
  const expected = (rows.length * s.weightBp) / 10000;
  const observed = counts[s.segmentId] || 0;
  chi2 += ((observed - expected) ** 2) / expected;
  console.log(`  ${s.segmentId.padEnd(18)} esperado ${String(expected).padStart(5)}  observado ${String(observed).padStart(5)}`);
}
const perPlayer = new Map();
for (const r of rows) if (r.landedSegment === "avatar-comun") perPlayer.set(r.playerId, (perPlayer.get(r.playerId) || 0) + 1);
const repeated = [...perPlayer.values()].filter((n) => n >= 2).length;
console.log(`  giros ${rows.length} · χ² ${chi2.toFixed(2)} · avatar-comun repetido en ${repeated} jugadores`);
