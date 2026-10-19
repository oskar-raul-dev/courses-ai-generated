// Prototipo de oddsAudit para la verificación P7 (no es código del curso).
// Pesos en puntos básicos (suman 10.000). Rueda honesta vs rueda que se acomoda.
// PRNG sembrado (mulberry32) para que cada corrida sea reproducible.
const W_CONFIG = [3000, 2000, 1500, 1500, 1000, 800, 150, 50];   // segmento 7 = 0,5 %
const W_ACOMODADA = [2850, 2000, 1500, 1500, 1000, 800, 150, 200]; // mismo segmento, 2 %
const N = 20000;        // giros por corrida
const RUNS = 300;       // corridas por escenario
const CHI2_CRIT_DF7_05 = 14.067;

function mulberry32(a) {
  return function () {
    a |= 0; a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function simulate(weights, seed) {
  const rnd = mulberry32(seed);
  const counts = new Array(weights.length).fill(0);
  const cum = [];
  let acc = 0;
  for (const w of weights) { acc += w; cum.push(acc); }
  for (let i = 0; i < N; i++) {
    const r = rnd() * 10000;
    let k = 0;
    while (r >= cum[k]) k++;
    counts[k]++;
  }
  return counts;
}

// oddsAudit: banda de ±3σ por segmento y chi-cuadrado global, contra los pesos configurados.
function oddsAudit(counts, weightsBp) {
  const n = counts.reduce((a, b) => a + b, 0);
  const alarmas = [];
  let chi2 = 0;
  weightsBp.forEach((w, k) => {
    const p = w / 10000;
    const e = n * p;
    const sigma = Math.sqrt(n * p * (1 - p));
    const lo = e - 3 * sigma, hi = e + 3 * sigma;
    if (counts[k] < lo || counts[k] > hi) alarmas.push(k);
    chi2 += ((counts[k] - e) ** 2) / e;
  });
  return { alarmaBanda: alarmas, chi2: +chi2.toFixed(2), alarmaChi2: chi2 > CHI2_CRIT_DF7_05 };
}

function tasaAlarmas(weights, configurados) {
  let conAlarma = 0, alarmaSeg7 = 0;
  for (let r = 0; r < RUNS; r++) {
    const res = oddsAudit(simulate(weights, 1000 + r), configurados);
    if (res.alarmaBanda.length > 0 || res.alarmaChi2) conAlarma++;
    if (res.alarmaBanda.includes(7)) alarmaSeg7++;
  }
  return { corridas: RUNS, conAlarma, tasa: +(conAlarma / RUNS * 100).toFixed(2), alarmaSeg7 };
}

// Un caso de referencia con detalle, y luego la tasa sobre RUNS corridas.
const ref = oddsAudit(simulate(W_CONFIG, 42), W_CONFIG);
const refAcomodada = oddsAudit(simulate(W_ACOMODADA, 42), W_CONFIG);
console.log("referencia honesta (semilla 42):", JSON.stringify(ref));
console.log("referencia acomodada (semilla 42):", JSON.stringify(refAcomodada));
console.log("honesta, alarmas sobre", RUNS, "corridas:", JSON.stringify(tasaAlarmas(W_CONFIG, W_CONFIG)));
console.log("acomodada, alarmas sobre", RUNS, "corridas:", JSON.stringify(tasaAlarmas(W_ACOMODADA, W_CONFIG)));
// Prorrateo de 20,99 USD entre 500 giros, con enteros (ver A10): centavos exactos.
const total = 2099, giros = 500;
const base = Math.floor(total / giros), resto = total - base * giros;
console.log("prorrateo 2099 centavos / 500 giros: base", base, "giros con +1 centavo", resto, "suma", base * giros + resto);
