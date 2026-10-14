// Incidente 07 (new design, 2026-10-07): the potassium v2 boundary was loaded in UTC ('Z') by a script,
// the sample carries -05:00. Uses selectActiveRange and evaluateResult as extracted from Fase 08.
const fs = require('fs');
const ts = require('typescript');
const src = fs.readFileSync('extraidos/reference-range.selector.ts', 'utf8');
const js = ts.transpileModule(src, { compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2015 } }).outputText;
const m = { exports: {} };
new Function('module', 'exports', 'require', js)(m, m.exports, require);
const { selectActiveRange, evaluateResult } = m.exports;

const v1 = { id: 31, analyte: 'potassium', version: 1, low: 3.5, high: 5.1, criticalLow: 2.5, criticalHigh: 6.5, effectiveFrom: '2019-01-01T00:00:00-05:00' };
const v2 = { id: 32, analyte: 'potassium', version: 2, low: 3.5, high: 5.2, criticalLow: 2.8, criticalHigh: 7.0, effectiveTo: null };
const broken = [ Object.assign({}, v1, { effectiveTo: '2021-12-31T23:59:59Z' }), Object.assign({}, v2, { effectiveFrom: '2022-01-01T00:00:00Z' }) ];
const fixed  = [ Object.assign({}, v1, { effectiveTo: '2021-12-31T23:59:59-05:00' }), Object.assign({}, v2, { effectiveFrom: '2022-01-01T00:00:00-05:00' }) ];
function show(label, ranges, at) {
  const r = selectActiveRange(ranges, 'potassium', at);
  const e = evaluateResult(6.8, r);
  console.log('  ' + label.padEnd(8), at, '-> v' + (r ? r.version : '-'), e.critical ? 'CRITICO (rojo)' : (e.outOfRange ? 'fuera (amarillo)' : 'dentro'));
}
console.log('TZ', process.env.TZ);
['2021-12-31T12:15:00-05:00', '2021-12-31T18:59:00-05:00', '2021-12-31T19:00:00-05:00', '2021-12-31T20:15:00-05:00', '2022-01-01T00:30:00-05:00'].forEach(function (at) {
  show('roto', broken, at);
  show('arreglado', fixed, at);
});
