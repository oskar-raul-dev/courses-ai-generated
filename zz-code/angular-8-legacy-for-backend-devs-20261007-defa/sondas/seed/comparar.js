// Runs the Fase 05 seed before and after the winter change on the Fase 04 db.json and compares the output.
const fs = require('fs'), path = require('path'), cp = require('child_process');
function run(file) {
  fs.mkdirSync('run-' + file, { recursive: true });
  fs.copyFileSync('db.json', path.join('run-' + file, 'db.json'));
  fs.copyFileSync(file, path.join('run-' + file, 'seed.js'));
  cp.execSync('node seed.js', { cwd: 'run-' + file, stdio: 'inherit' });
  return JSON.parse(fs.readFileSync(path.join('run-' + file, 'db.json'), 'utf8'));
}
const a = run('seed-antes.js'), b = run('seed-despues.js');
const strip = o => JSON.stringify(o.map(x => Object.assign({}, x, { createdAt: 0, dueAt: 0 })));
console.log('pacientes iguales:', JSON.stringify(a.patients) === JSON.stringify(b.patients));
console.log('ordenes iguales salvo fechas:', strip(a.orders) === strip(b.orders));
const f = new Intl.DateTimeFormat('en-CA', { timeZone: 'America/Toronto', timeZoneName: 'short' });
const offs = {}; const months = {};
b.orders.forEach(o => { const z = f.formatToParts(new Date(o.createdAt)).find(p => p.type === 'timeZoneName').value; offs[z] = (offs[z] || 0) + 1; months[o.createdAt.slice(0, 7)] = (months[o.createdAt.slice(0, 7)] || 0) + 1; });
console.log('zona real en Ottawa de las 40 fechas nuevas:', offs, '| por mes:', months);
console.log('antes, por mes:', a.orders.reduce((m, o) => (m[o.createdAt.slice(0, 7)] = (m[o.createdAt.slice(0, 7)] || 0) + 1, m), {}));
