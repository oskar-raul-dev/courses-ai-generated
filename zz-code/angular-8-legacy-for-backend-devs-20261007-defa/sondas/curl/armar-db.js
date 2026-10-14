// Builds a db.json with the incident 07 and 22 preparation records (extracted), for the cuaderno's curl commands.
const fs = require('fs');
const objs = f => fs.readFileSync(f, 'utf8').replace(/\/\/.*$/mg, '').match(/\{[\s\S]*?\}/g).map(s => JSON.parse(s));
const p07 = objs('./angular8/extraidos/prep07.jsonc'), p22 = objs('./angular8/inc22/prep22.jsonc');
const db = { samples: p07.filter(o => o.collectedAt).concat(p22), results: p07.filter(o => o.analyte && o.value),
             referenceRanges: p07.filter(o => o.version), orders: [] };
fs.writeFileSync('/tmp/db.json', JSON.stringify(db, null, 2));
