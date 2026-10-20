// Exploración del incidente 18: formas naturales de prorratear 20,99 USD entre 500 giros con floats.
const price = 20.99, spins = 500;
const perSpin = price / spins;
console.log("perSpin", perSpin, "20.99*100", 20.99 * 100, "Math.round", Math.round(20.99 * 100));
let sum = 0; for (let i = 0; i < spins; i++) sum += perSpin;
console.log("suma de 500 perSpin", sum, "floor*100", Math.floor(sum * 100), "round*100", Math.round(sum * 100), "trunc toFixed", sum.toFixed(2));
// por segmento: conteos según pesos (sobre 500)
const byWeight = [150, 100, 75, 75, 50, 40, 8, 2];
const rows = byWeight.map((c) => Math.round(c * perSpin * 100) / 100);
console.log("filas redondeadas", rows, "suma", rows.reduce((a, b) => a + b, 0), "en centavos", Math.round(rows.reduce((a, b) => a + b, 0) * 100));
const rowsCents = byWeight.map((c) => Math.round(c * perSpin * 100));
console.log("filas en centavos", rowsCents, "suma", rowsCents.reduce((a, b) => a + b, 0));
// toFixed por fila
const rowsFixed = byWeight.map((c) => Number((c * perSpin).toFixed(2)));
console.log("toFixed", rowsFixed, Math.round(rowsFixed.reduce((a, b) => a + b, 0) * 100));
