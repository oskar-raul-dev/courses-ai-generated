// T2: A07 §6 number/currency line and the separators table, real output of Angular 8 with es/en/fr registered.
const { formatNumber, formatCurrency, getCurrencySymbol, formatPercent, registerLocaleData } = require('@angular/common');
registerLocaleData(require('@angular/common/locales/es').default, 'es');
registerLocaleData(require('@angular/common/locales/fr').default, 'fr');
const show = s => JSON.stringify(s) + ' [' + [...s].map(c => c.charCodeAt(0) > 127 ? 'U+' + c.charCodeAt(0).toString(16).toUpperCase().padStart(4, '0') : c).join('') + ']';
for (const l of ['es', 'en', 'fr']) {
  const sym = getCurrencySymbol('CAD', 'narrow', l);
  console.log(l.padEnd(3),
    'number 12.5 1.2-2:', show(formatNumber(12.5, l, '1.2-2')),
    '| currency 1234.5 CAD symbol-narrow 1.2-2:', show(formatCurrency(1234.5, l, sym, 'CAD', '1.2-2')),
    '| number 1234.5:', show(formatNumber(1234.5, l)));
}
