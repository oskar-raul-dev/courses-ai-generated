// Comisión: sobre el total contra cobro por cobro, y tasas donde el float sí difiere.
const fee = (c, bp) => Math.floor((c * bp + 5000) / 10000);
const rows = [...Array(6).fill(2099), ...Array(34).fill(99)];
const perRow = rows.reduce((s, c) => s + fee(c, 1500), 0);
const total = rows.reduce((s, c) => s + c, 0);
console.log("total", total, "comisión cobro por cobro", perRow, "comisión sobre el total", fee(total, 1500));
for (const [rate, bp] of [[0.07, 700], [0.3, 3000], [0.12, 1200], [0.035, 350]]) {
  const d = []; for (let c = 1; c <= 100000; c++) if (Math.round(c * rate) !== fee(c, bp)) d.push(c);
  console.log(`tasa ${rate}: ${d.length} diferencias, primeras ${d.slice(0, 3).join(", ")}`, d.length ? `(${d[0]}*${rate}=${d[0] * rate})` : "");
}
