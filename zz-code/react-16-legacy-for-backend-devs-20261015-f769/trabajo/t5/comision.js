// Ejercicio 23 de F08: ¿Math.round(c * 0.15) difiere alguna vez de la regla entera?
const fee = (c) => Math.floor((c * 1500 + 5000) / 10000);
const diffs = [];
for (let c = 1; c <= 100000; c++) if (Math.round(c * 0.15) !== fee(c)) diffs.push(c);
console.log("diferencias entre 1 y 100.000:", diffs.length, "primeras:", diffs.slice(0, 8).join(", "), "→", diffs.slice(0, 3).map((c) => `${c}*0.15=${c * 0.15}`).join(" · "));
