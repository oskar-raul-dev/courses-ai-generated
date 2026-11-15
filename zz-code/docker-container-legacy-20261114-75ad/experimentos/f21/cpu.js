let acc = 0;
const t0 = Date.now();
for (let i = 0; i < 30000000; i++) { acc += Math.sqrt(i) % 7; }
console.log(process.arch, Math.round(acc), (Date.now() - t0) + ' ms');
