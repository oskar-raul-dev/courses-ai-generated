// Incident 22: run the extracted detector, its spec (Jasmine), the preparation data and the custody display.
const fs = require('fs'), ts = require('typescript'), path = require('path');
const out = path.join(__dirname, 'out'); fs.mkdirSync(out, { recursive: true });
for (const f of ['app-date.pipe.ts', 'offset-check.ts', 'offset-check.spec.ts']) {
  const js = ts.transpileModule(fs.readFileSync(path.join(__dirname, f), 'utf8'),
    { compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2015, experimentalDecorators: true } }).outputText;
  fs.writeFileSync(path.join(out, f.replace(/\.ts$/, '.js')), js);
}
const { registerLocaleData } = require('@angular/common');
registerLocaleData(require('@angular/common/locales/es').default, 'es');
const { AppDatePipe } = require(path.join(out, 'app-date.pipe.js'));
const { offsetDoesNotMatchZone } = require(path.join(out, 'offset-check.js'));
const pipe = new AppDatePipe('es');
const samples = fs.readFileSync(path.join(__dirname, 'prep22.jsonc'), 'utf8').replace(/\/\/.*$/mg, '').match(/\{[\s\S]*?\}/g).map(s => JSON.parse(s));
console.log('TZ', process.env.TZ);
for (const s of samples) {
  const inv = Date.parse(s.receivedAt) < Date.parse(s.collectedAt);
  console.log(`  ${s.id} Recogida — ${s.collectedBy} — ${pipe.transform(s.collectedAt, 'short', 'America/Toronto')} | Recibida — ${s.receivedBy} — ${pipe.transform(s.receivedAt, 'short', 'America/Toronto')} | detector: ${offsetDoesNotMatchZone(s.collectedAt, 'America/Toronto')} | recibida antes de tomada: ${inv}`);
}
console.log('  toLocaleString del cuaderno:', eval(fs.readFileSync(path.join(__dirname, 'tolocale.js'), 'utf8').split('\n')[0]));
const Jasmine = require('jasmine'); const j = new Jasmine();
j.loadConfig({ spec_dir: 'inc22/out', spec_files: ['offset-check.spec.js'] }); j.exitOnCompletion = false;
j.onComplete(ok => console.log('  Jasmine incidente 22:', ok ? 'verde' : 'ROJO'));
j.execute();
