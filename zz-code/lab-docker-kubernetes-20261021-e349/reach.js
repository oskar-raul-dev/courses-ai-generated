// F20 §4 y §8: la prueba de alcance. Desde adentro de un pod con Node, cuatro destinos con un timeout de 3 s.
const net = require('node:net');
const http = async (url) => {
  try { const r = await fetch(url, { signal: AbortSignal.timeout(3000) }); return `HTTP ${r.status}`; }
  catch (e) { return e.cause?.code ? `${e.name} ${e.cause.code}` : e.name; }
};
const tcp = (host, port) => new Promise((ok) => {
  const s = net.connect({ host, port, timeout: 3000 }, () => { s.destroy(); ok('conecta'); });
  s.on('timeout', () => { s.destroy(); ok('timeout (3 s)'); });
  s.on('error', (e) => ok(e.code));
});
const own = process.env.OWN_NS || 'apps-b';
(async () => {
  console.log('pricing de apps (8080)        ', await http('http://pricing.apps.svc.cluster.local:8080/health/live'));
  console.log('inventory de apps (8080)      ', await http('http://inventory.apps.svc.cluster.local:8080/health/live'));
  console.log('pricing de su cadena (8080)   ', await http(`http://pricing.${own}.svc.cluster.local:8080/health/live`));
  console.log('postgres de data (5432)       ', await tcp('postgres.data.svc.cluster.local', 5432));
})();
