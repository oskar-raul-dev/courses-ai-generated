// T1 checks on blocks extracted from the course (extraer/t1-entradas.sh). Prints PASS/FAIL per check.
'use strict';
const fs = require('fs');
const ts = require('typescript');
const E = 'extraidos/';
const results = [];
function check(name, ok, detail) { results.push([ok ? 'PASS' : 'FAIL', name, detail || '']); }
function load(file, extraGlobals) {
  const js = ts.transpileModule(fs.readFileSync(E + file, 'utf8'),
    { compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2015, experimentalDecorators: true } }).outputText;
  const m = { exports: {} };
  const names = Object.keys(extraGlobals || {});
  new Function('module', 'exports', 'require', ...names, js)(m, m.exports, require, ...names.map(n => extraGlobals[n]));
  return m.exports;
}
const sel = load('reference-range.selector.ts');

// 1. Fase 04 db.json: valid JSON, every timestamp is in the T1 table with its real offset
const db = JSON.parse(fs.readFileSync(E + 'fase04-db.json', 'utf8'));
const tabla = JSON.parse(fs.readFileSync('../../fechas/tabla.json', 'utf8'));
const nuevos = new Set(tabla.map(r => r.nuevo));
const stamps = JSON.stringify(db).match(/20\d\d-\d\d-\d\dT[^"]+/g);
const fuera = stamps.filter(s => !nuevos.has(s));
check('Fase 04 db.json es JSON valido y sus ' + stamps.length + ' marcas estan en la tabla', fuera.length === 0, fuera.join(', '));
const v2 = db.referenceRanges.find(r => r.analyte === 'glucose' && r.version === 2);
check('Fase 04: la v2 de glucosa rige desde 2022-01-01 en Ottawa', v2.effectiveFrom === '2022-01-01T00:00:00-05:00', v2.effectiveFrom);
const val = db.results.find(r => r.status === 'validated');
check('Fase 04: el validado 9002 (TSH) aplica una version que existia', sel.selectActiveRange(db.referenceRanges, 'tsh', val.validatedAt).version === val.rangeVersionApplied);

// 2. Incident 07 preparation, as written: v2 at 20:15, v1 at 12:15; 6.8 yellow vs red; fixed borders -> v1
const prep = fs.readFileSync(E + 'prep07.jsonc', 'utf8').replace(/\/\/.*$/mg, '');
const objs = prep.match(/\{[\s\S]*?\}/g).map(o => JSON.parse(o));
const ranges = objs.filter(o => o.analyte === 'potassium' && o.version);
const sample = objs.find(o => o.id === 612);
const at = sample.collectedAt;
const r1 = sel.selectActiveRange(ranges, 'potassium', at);
check('Prep 07: la muestra 612 (' + at + ') elige la v2 con el dato roto', r1 && r1.version === 2);
check('Prep 07: con la v2, 6.8 sale fuera de rango y NO critico (amarillo)', (e => e.outOfRange && !e.critical)(sel.evaluateResult(6.8, r1)));
check('Prep 07: a las 12:15 del mismo dia elige la v1', sel.selectActiveRange(ranges, 'potassium', '2021-12-31T12:15:00-05:00').version === 1);
const fixed = ranges.map(r => Object.assign({}, r, r.version === 1 ? { effectiveTo: '2021-12-31T23:59:59-05:00' } : { effectiveFrom: '2022-01-01T00:00:00-05:00' }));
const r2 = sel.selectActiveRange(fixed, 'potassium', at);
check('Prep 07: con los bordes del parche (-05:00) elige la v1 y 6.8 es critico (rojo)', r2.version === 1 && sel.evaluateResult(6.8, r2).critical);
check('Prep 07: el chequeo del dato (grep [0-9]Z") encuentra los 2 bordes rotos', (JSON.stringify(ranges).match(/[0-9]Z"/g) || []).length === 2);

// 3. Forense 08 route 1 with the PROD borders for glucose
const glu = [
  { analyte: 'glucose', version: 1, low: 70, high: 110, effectiveFrom: '2019-01-01T00:00:00-05:00', effectiveTo: '2021-12-31T23:59:59Z' },
  { analyte: 'glucose', version: 2, low: 70, high: 100, effectiveFrom: '2022-01-01T00:00:00Z', effectiveTo: null }];
check('Forense 08 paso 3: 20:00 del 31 -> v2, 12:00 -> v1',
  sel.selectActiveRange(glu, 'glucose', '2021-12-31T20:00:00-05:00').version === 2 && sel.selectActiveRange(glu, 'glucose', '2021-12-31T12:00:00-05:00').version === 1);
const gluSeed = [Object.assign({}, glu[0], { effectiveTo: '2021-12-31T23:59:59-05:00' }), Object.assign({}, glu[1], { effectiveFrom: '2022-01-01T00:00:00-05:00' })];
check('Forense 08 / Fase 08: con los bordes del semillero las dos llamadas devuelven v1',
  sel.selectActiveRange(gluSeed, 'glucose', '2021-12-31T20:00:00-05:00').version === 1 && sel.selectActiveRange(gluSeed, 'glucose', '2021-12-31T12:00:00-05:00').version === 1);
check('Fase 08 prueba de fuego: 105 el 15/1/2022 fuera (v2), el 15/12/2021 dentro (v1)',
  sel.evaluateResult(105, sel.selectActiveRange(gluSeed, 'glucose', '2022-01-15T10:00:00-05:00')).outOfRange &&
  !sel.evaluateResult(105, sel.selectActiveRange(gluSeed, 'glucose', '2021-12-15T10:00:00-05:00')).outOfRange);

// 4. Fase 05 toLocalDate: local midnight of the same day, whatever the zone
const toLocalDate = new Function(fs.readFileSync(E + 'fase05-toLocalDate.ts', 'utf8').replace('isoDate: string): Date', 'isoDate)') + '; return toLocalDate;')();
const d = toLocalDate('1984-03-12');
check('Fase 05 toLocalDate("1984-03-12") es el 12 local a medianoche', d.getDate() === 12 && d.getHours() === 0, d.toString());

// 5. Fase 02 pipe: offsetAt for Ottawa, winter/summer and around midnight and the DST change
const core = { Inject: () => () => {}, LOCALE_ID: 'LOCALE_ID', Pipe: () => c => c };
const pipeMod = load('app-date.pipe.ts', {});
check('Fase 02 offsetAt: invierno -0500, verano -0400, medianoche local y el cambio de hora',
  pipeMod.offsetAt(new Date('2022-01-03T05:00:00Z'), 'America/Toronto') === '-0500' &&
  pipeMod.offsetAt(new Date('2021-07-01T04:00:00Z'), 'America/Toronto') === '-0400' &&
  pipeMod.offsetAt(new Date('2020-03-08T06:59:59Z'), 'America/Toronto') === '-0500' &&
  pipeMod.offsetAt(new Date('2020-03-08T07:00:00Z'), 'America/Toronto') === '-0400');
let threw = false; try { pipeMod.offsetAt(new Date(), 'America/Ottawa'); } catch (e) { threw = e instanceof RangeError; }
check('Fase 02: una zona que no existe (America/Ottawa) lanza RangeError', threw);
const P = new pipeMod.AppDatePipe('es');
require('@angular/common').registerLocaleData(require('@angular/common/locales/es').default, 'es');
check('Fase 02 appDate:\'medium\' del incidente 04 = "3 ene. 2022 8:15:00"', P.transform('2022-01-03T08:15:00-05:00', 'medium', 'America/Toronto') === '3 ene. 2022 8:15:00', P.transform('2022-01-03T08:15:00-05:00', 'medium', 'America/Toronto'));

console.log('TZ', process.env.TZ);
results.forEach(r => console.log(r[0], r[1], r[2] ? '-> ' + r[2] : ''));
const fails = results.filter(r => r[0] === 'FAIL').length;
console.log(results.length - fails + '/' + results.length + ' PASS');

// 6. The cuaderno's regression spec for incident 07, under Jasmine
const Jasmine = require('jasmine');
const j = new Jasmine();
global.selectActiveRange = sel.selectActiveRange; global.evaluateResult = sel.evaluateResult;
const specJs = ts.transpileModule(fs.readFileSync(E + 'inc07-regression.spec.ts', 'utf8'), { compilerOptions: { target: ts.ScriptTarget.ES2015 } }).outputText;
fs.mkdirSync('specs-generados', { recursive: true });
fs.writeFileSync('specs-generados/inc07.spec.js', 'describe("incidente 07 (cuaderno)", function () {\n' + specJs + '\n});\n');
j.loadConfig({ spec_dir: 'specs-generados', spec_files: ['inc07.spec.js'] });
j.exitOnCompletion = false;
j.onComplete(function (ok) { console.log('Jasmine incidente 07:', ok ? 'verde' : 'ROJO'); process.exitCode = (fails || !ok) ? 1 : 0; });
j.execute();
