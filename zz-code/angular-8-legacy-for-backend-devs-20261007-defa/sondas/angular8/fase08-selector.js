// Fase 08 / incidente 07: run selectActiveRange as extracted from the markdown (transpiled with TS 3.5).
const fs = require('fs');
const ts = require('typescript');
const src = fs.readFileSync('extraidos/reference-range.selector.ts', 'utf8');
const js = ts.transpileModule(src, { compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2015 } }).outputText;
const m = { exports: {} };
new Function('module', 'exports', 'require', js)(m, m.exports, require);
const { selectActiveRange } = m.exports;

const glucose = [
  { analyte: 'glucose', version: 1, effectiveFrom: '2019-01-01T00:00:00-05:00', effectiveTo: '2021-12-31T23:59:59-05:00' },
  { analyte: 'glucose', version: 2, effectiveFrom: '2022-01-01T00:00:00-05:00', effectiveTo: null },
];
const cases = [
  ['offset explicito, 20:00 del 31 (Fase 08 ~1005)', '2021-12-31T20:00:00-05:00'],
  ['offset explicito, 20:15 del 31 (incidente 07)', '2021-12-31T20:15:00-05:00'],
  ['offset explicito, 12:15 del 31', '2021-12-31T12:15:00-05:00'],
  ['la misma hora en UTC (toISOString)', '2022-01-01T01:15:00.000Z'],
  ['fecha sin hora del 31', '2021-12-31'],
  ['fecha sin hora del 1', '2022-01-01'],
  ['hora local sin offset, 20:15 del 31', '2021-12-31T20:15:00'],
];
console.log('TZ', process.env.TZ);
for (const [label, at] of cases) {
  const r = selectActiveRange(glucose, 'glucose', at);
  console.log('  v' + (r ? r.version : '-'), label.padEnd(44), at);
}
