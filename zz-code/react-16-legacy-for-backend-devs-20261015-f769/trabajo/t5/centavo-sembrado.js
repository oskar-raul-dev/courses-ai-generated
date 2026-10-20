// El descuadre de la versión rota (filas redondeadas en dólares) sobre los paquetes sembrados.
const db = require("/app/mock/db.json");
const segments = db.segments.filter((s) => s.wheelId === 4);
const broken = (price, counts) => {
  const spins = counts.reduce((a, b) => a + b, 0);
  const perSpin = price / 100 / spins;
  return counts.map((c) => Math.round(c * perSpin * 100));
};
for (const t of ["tok-ago-05", "tok-ago-12", "tok-ago-19", "tok-ago-26"]) {
  const rows = db.spinLog.filter((r) => r.purchaseToken === t);
  const counts = segments.map((s) => rows.filter((r) => r.landedSegment === s.segmentId).length);
  const b = broken(2099, counts);
  console.log(t, JSON.stringify(counts), JSON.stringify(b), "suma", b.reduce((x, y) => x + y, 0));
}
const w = [150, 100, 75, 75, 50, 40, 8, 2]; const bw = broken(2099, w);
console.log("según pesos", JSON.stringify(bw), bw.reduce((x, y) => x + y, 0));
