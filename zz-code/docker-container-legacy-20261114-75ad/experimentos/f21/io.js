const fs = require('fs');
const os = require('os');
const path = require('path');
const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'io-'));
const buf = Buffer.alloc(4096, 'x');
const t0 = Date.now();
for (let i = 0; i < 2000; i++) { fs.writeFileSync(path.join(dir, 'f' + i), buf); }
for (let i = 0; i < 2000; i++) { fs.readFileSync(path.join(dir, 'f' + i)); }
console.log(process.arch, (Date.now() - t0) + ' ms');
