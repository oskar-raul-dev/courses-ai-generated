// Fase 09: formatDate of the report service as extracted (method body), with environment.timeZone = America/Toronto.
const fs = require('fs');
const body = fs.readFileSync('extraidos/fase09-formatDate.ts', 'utf8')
  .replace(/^\s*formatDate\(iso: string\): string \{/, '').replace(/\}\s*$/, '');
const environment = { timeZone: 'America/Toronto' };
const formatDate = new Function('environment', 'iso', body).bind(null, environment);
console.log('TZ', process.env.TZ, 'ICU', process.versions.icu);
[['invierno, 23:40 Ottawa', '2022-01-04T04:40:00Z'], ['verano, 23:40 Ottawa', '2021-07-01T03:40:00Z'],
 ['incidente 17', '2022-01-08T21:04:10.887-05:00']].forEach(function (c) {
  console.log('  ' + c[0].padEnd(24), c[1].padEnd(30), '->', formatDate(c[1]));
});
