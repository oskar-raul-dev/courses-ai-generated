// Builds the old -> new date table for the Ottawa turn (plan D7, decisions of 2026-10-07).
// Input: inventario.json (from inventario.py). Output: tabla.json and tabla.md, plus checks on stdout.
// Run in node:14.21.3. Every new instant is checked against the real offset of America/Toronto.
'use strict';
const fs = require('fs');
const path = require('path');
const here = __dirname;
const inv = JSON.parse(fs.readFileSync(path.join(here, 'inventario.json'), 'utf8'));

const DAY = 86400000;
// Shift rules by original calendar date (the date part of the literal, as written).
// Each shift is a whole number of weeks, so weekdays are preserved.
const RULES = [
  { from: '2019-05-31', to: '2019-06-01', days: 945, why: 'incidente 07 y borde de rangos v1/v2 -> 31/12/2021 y 1/1/2022' },
  { from: '2019-08-20', to: '2019-09-07', days: 854, why: 'semilla de ordenes, custodias y validaciones -> semana del 3/1/2022' },
  { from: '2019-06-14', to: '2019-06-14', days: -119, why: 'validado sin norma del incidente 12: dato del sistema anterior, invierno de 2019' },
];
const KEEP = ['2019-01-01', '2019-11-08'];   // v1 effectiveFrom; a04 build stamp (UTC, not data)

function ruleFor(datePart) {
  return RULES.find(r => datePart >= r.from && datePart <= r.to);
}
const WD = ['dom', 'lun', 'mar', 'mie', 'jue', 'vie', 'sab'];
function torontoParts(ms) {
  const f = new Intl.DateTimeFormat('en-CA', { timeZone: 'America/Toronto', hour12: false,
    year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit', weekday: 'short' });
  const p = {};
  f.formatToParts(new Date(ms)).forEach(x => { p[x.type] = x.value; });
  if (p.hour === '24') p.hour = '00';
  const wall = Date.UTC(+p.year, +p.month - 1, +p.day, +p.hour, +p.minute, +p.second);
  const off = Math.round((wall - Math.floor(ms / 1000) * 1000) / 60000);
  const sign = off < 0 ? '-' : '+';
  const a = Math.abs(off);
  return { local: `${p.year}-${p.month}-${p.day} ${p.hour}:${p.minute}`, weekday: p.weekday,
           offset: `${sign}${String(Math.floor(a / 60)).padStart(2, '0')}:${String(a % 60).padStart(2, '0')}` };
}
function shiftLiteral(lit, days) {
  const datePart = lit.slice(0, 10);
  const d = new Date(Date.UTC(+datePart.slice(0, 4), +datePart.slice(5, 7) - 1, +datePart.slice(8, 10)) + days * DAY);
  return d.toISOString().slice(0, 10) + lit.slice(10);   // keep time and offset exactly as written
}
function dateWeekday(datePart) {
  return WD[new Date(datePart + 'T12:00:00Z').getUTCDay()];
}

const rows = [];
const seen = new Map();
let problems = 0;
for (const e of inv) {
  const lit = e.literal;
  const datePart = lit.slice(0, 10);
  if (!datePart.startsWith('2019')) continue;            // BE "today" stamps (2026), 2020 data: handled in T3
  let nuevo = lit, rule = null;
  if (!KEEP.includes(datePart)) {
    rule = ruleFor(datePart);
    if (!rule) { console.log('SIN REGLA', e.file, e.line, lit); problems++; continue; }
    nuevo = shiftLiteral(lit, rule.days);
  }
  const hasTime = lit.length > 10;
  const row = { file: e.file, line: e.line, viejo: lit, nuevo, diaViejo: dateWeekday(datePart), diaNuevo: dateWeekday(nuevo.slice(0, 10)) };
  if (row.diaViejo !== row.diaNuevo) { console.log('CAMBIA EL DIA', row); problems++; }
  if (hasTime) {
    const ms = Date.parse(nuevo);
    if (isNaN(ms)) { console.log('NO PARSEA', nuevo); problems++; continue; }
    const t = torontoParts(ms);
    row.utc = new Date(ms).toISOString();
    row.ottawa = t.local + ' ' + t.weekday;
    row.desfaseReal = t.offset;
    const written = (nuevo.match(/([+-]\d\d:\d\d)$/) || [])[1] || (nuevo.endsWith('Z') ? 'Z' : 'sin desfase');
    row.desfaseEscrito = written;
    if (written !== 'Z' && written !== t.offset) { console.log('DESFASE ESCRITO != REAL', row); problems++; }
  }
  rows.push(row);
  const k = lit + ' -> ' + nuevo;
  if (!seen.has(k)) seen.set(k, row);
}

fs.writeFileSync(path.join(here, 'tabla.json'), JSON.stringify(rows, null, 1));
let md = '| Viejo | Nuevo | Dia | UTC | Ottawa (hora real) | Desfase real |\n|---|---|---|---|---|---|\n';
for (const r of [...seen.values()].sort((a, b) => a.viejo < b.viejo ? -1 : 1)) {
  md += `| \`${r.viejo}\` | \`${r.nuevo}\` | ${r.diaNuevo} | ${r.utc || '-'} | ${r.ottawa || '-'} | ${r.desfaseReal || '-'} |\n`;
}
fs.writeFileSync(path.join(here, 'tabla.md'), md);

// DST transitions in America/Toronto 2019-2022, found by scanning hour by hour.
const changes = [];
let prev = torontoParts(Date.UTC(2019, 0, 1)).offset;
for (let ms = Date.UTC(2019, 0, 1); ms < Date.UTC(2023, 0, 1); ms += 3600000) {
  const o = torontoParts(ms).offset;
  if (o !== prev) { changes.push(`${new Date(ms).toISOString()} ${prev} -> ${o} (local ${torontoParts(ms).local})`); prev = o; }
}
console.log('node', process.version, 'TZ', process.env.TZ, 'ICU', process.versions.icu, 'tz data', process.versions.tz);
console.log('Cambios de hora America/Toronto 2019-2022:\n  ' + changes.join('\n  '));
console.log(rows.length, 'apariciones,', seen.size, 'equivalencias unicas,', problems, 'problemas');
console.log(md);
