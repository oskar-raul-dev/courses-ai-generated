// A07 §6 table: real output of Angular 8 formatDate for 2026-09-03 14:05 in Ottawa (summer, -04:00),
// with the offset the appDate pipe would compute. Also the 'long' format in winter for contrast.
const { formatDate, registerLocaleData } = require('@angular/common');
['es', 'fr', 'en'].forEach(function (l) {
  if (l !== 'en') registerLocaleData(require('@angular/common/locales/' + l).default, l);
});
const summer = '2026-09-03T14:05:00-04:00';
const winter = '2026-01-15T14:05:00-05:00';
['short', 'medium', 'long', 'shortDate', 'mediumDate', 'shortTime', 'dd/MM/yyyy HH:mm'].forEach(function (f) {
  console.log(f.padEnd(18), JSON.stringify(formatDate(summer, f, 'es', '-0400')));
});
console.log('long winter'.padEnd(18), JSON.stringify(formatDate(winter, 'long', 'es', '-0500')));
// Incident 04: patient card "medium" with lastOrderDate of the seed, in es and the locales of the app
['es', 'fr', 'en'].forEach(function (l) {
  console.log('inc04 medium', l, JSON.stringify(formatDate('2022-01-03T08:15:00-05:00', 'medium', l, '-0500')));
});
