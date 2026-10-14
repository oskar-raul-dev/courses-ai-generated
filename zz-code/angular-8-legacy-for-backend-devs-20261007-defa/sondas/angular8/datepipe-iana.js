// Probe: does Angular 8's formatDate (what DatePipe calls) honor an IANA zone id?
const { formatDate, registerLocaleData } = require('@angular/common');
const es = require('@angular/common/locales/es').default;
registerLocaleData(es, 'es');
const cases = [
  ['winter', '2022-01-01T00:30:00Z'],   // 2021-12-31 19:30 in Ottawa (-05:00)
  ['summer', '2021-07-01T00:30:00Z'],   // 2021-06-30 20:30 in Ottawa (-04:00)
];
const zones = ['America/Toronto', 'America/Bogota', '-0500', '-0400', 'EST', 'EDT', undefined];
console.log('process TZ =', process.env.TZ, '| node', process.version);
for (const [label, iso] of cases) {
  for (const z of zones) {
    console.log(label.padEnd(6), String(z).padEnd(16), formatDate(iso, 'yyyy-MM-dd HH:mm ZZZZZ', 'es', z));
  }
}
