// scripts/false-alarms.js — las cifras de A14: σ y banda por segmento, la muestra para el
// segmento raro, y la tasa de falsas alarmas de una rueda honesta, simulada.
//   node scripts/false-alarms.js 100000   (100.000 simulaciones de 10.000 giros; unos 30 s)
const W = [3000, 2000, 1500, 1500, 1000, 800, 150, 50];
const NAMES = ["sin-premio", "vidas-2", "avatar-comun", "set-gemas-basico", "vidas-5", "set-gemas-plata", "avatar-raro", "esclusa-de-oro"];
const N = 10000, SIMS = Number(process.argv[2] || 100000), CRIT = 14.067;
console.log("n =", N);
W.forEach((w, i) => {
  const p = w / 10000, e = N * p, s = Math.sqrt(N * p * (1 - p));
  console.log(NAMES[i].padEnd(17), "p", p, "esperado", e, "σ", s.toFixed(2), "banda", (e - 3 * s).toFixed(1), "–", (e + 3 * s).toFixed(1), "relativa ±", (300 * s / e).toFixed(1) + " %");
});
// Muestra mínima: (a) para que el esperado del raro llegue a 5 (regla del chi-cuadrado);
// (b) para que pasar de 0,5 % a 1 % y a 2 % quede a más de 3σ del esperado.
const p0 = 0.005;
console.log("esperado ≥ 5 en el raro: n ≥", Math.ceil(5 / p0));
for (const p1 of [0.01, 0.02]) {
  const n = Math.ceil((9 * p0 * (1 - p0)) / ((p1 - p0) ** 2));
  console.log(`de 0,5 % a ${p1 * 100} % a 3σ: n ≥`, n);
}
function mulberry32(a) { return function () { a = (a + 0x6d2b79f5) | 0; let t = Math.imul(a ^ (a >>> 15), 1 | a); t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; }; }
const cum = []; W.reduce((acc, w) => { cum.push(acc + w); return acc + w; }, 0);
const rnd = mulberry32(20261016);
let band = 0, chi = 0, either = 0; const perSeg = W.map(() => 0);
const t0 = Date.now();
for (let s = 0; s < SIMS; s++) {
  const c = [0, 0, 0, 0, 0, 0, 0, 0];
  for (let i = 0; i < N; i++) { const r = Math.floor(rnd() * 10000); let k = 0; while (r >= cum[k]) k++; c[k]++; }
  let b = false, x2 = 0;
  W.forEach((w, i) => { const d = c[i] * 10000 - N * w; if (d * d > 9 * N * w * (10000 - w)) { b = true; perSeg[i]++; } x2 += (d * d) / (10000 * N * w); });
  if (b) band++; if (x2 > CRIT) chi++; if (b || x2 > CRIT) either++;
}
const pct = (k) => (100 * k / SIMS).toFixed(2) + " %";
console.log(`${SIMS} simulaciones de ${N} giros (rueda honesta, semilla 20261016), ${((Date.now() - t0) / 1000).toFixed(0)} s`);
console.log("alarma de banda:", band, pct(band), "· chi-cuadrado:", chi, pct(chi), "· cualquiera:", either, pct(either));
console.log("banda por segmento:", NAMES.map((n, i) => `${n} ${pct(perSeg[i])}`).join(" · "));
