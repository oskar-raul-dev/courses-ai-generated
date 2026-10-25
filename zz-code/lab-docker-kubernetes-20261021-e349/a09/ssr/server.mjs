// server.mjs (a09): el storefront que arma la página en el servidor, en cada petición.
import { createServer } from 'node:http';
import { readFileSync } from 'node:fs';
import { createElement as h } from 'react';
import { renderToString } from 'react-dom/server';

const CATALOG = process.env.CATALOG_URL ?? 'http://catalog.apps.svc.cluster.local:8080';
const PRICING = process.env.PRICING_URL ?? 'http://pricing.apps.svc.cluster.local:8080';
const peso = new Intl.NumberFormat('es-CO', { style: 'currency', currency: 'COP', maximumFractionDigits: 0 });

// Dos segundos por vecino, y se rinde: una versión de verdad mostraría el catálogo de la última vez.
const getJson = async (url) => {
  const res = await fetch(url, { signal: AbortSignal.timeout(2000) });
  if (!res.ok) throw new Error(`${url} contestó ${res.status}`);
  return res.json();
};

// La marca, de un archivo montado y leída en cada petición: el ConfigMap cambia sin reiniciar el proceso.
const brandNow = () => (process.env.BRAND_FILE
  ? readFileSync(process.env.BRAND_FILE, 'utf8').trim()
  : (process.env.BRAND_NAME ?? 'Droguerías La Vecina'));

const Page = ({ brand, store, products, prices }) =>
  h('html', { lang: 'es' },
    h('head', null, h('meta', { charSet: 'utf-8' }), h('title', null, brand)),
    h('body', null,
      h('h1', null, brand),
      h('p', null, `Droguería ${store}`),
      h('ul', null, products.filter((p) => p.status === 'ACTIVE').map((p) =>
        h('li', { key: p.sku, 'data-sku': p.sku },
          `${p.name} · ${prices[p.sku] === undefined ? 'sin precio' : peso.format(prices[p.sku])}`)))));

const send = (res, status, type, body) => {
  res.writeHead(status, { 'content-type': type });
  res.end(body);
};

createServer(async (req, res) => {
  const url = new URL(req.url, 'http://localhost');
  if (url.pathname === '/health/live') return send(res, 200, 'application/json', '{"status":"live"}');
  // La readiness no pregunta por los vecinos (G4): un vecino caído no saca a este pod del Service.
  if (url.pathname === '/health/ready') return send(res, 200, 'application/json', '{"status":"ready"}');
  if (url.pathname !== '/') return send(res, 404, 'text/plain', 'no existe');
  const store = /^DRO-[0-9]{3}$/.test(url.searchParams.get('store') ?? '') ? url.searchParams.get('store') : 'DRO-007';
  try {
    const [products, priceList] = await Promise.all([
      getJson(`${CATALOG}/products`),
      getJson(`${PRICING}/prices?store=${store}`).catch(() => []),
    ]);
    const prices = Object.fromEntries(priceList.map((p) => [p.sku, p.price]));
    const html = '<!doctype html>' + renderToString(h(Page, { brand: brandNow(), store, products, prices }));
    send(res, 200, 'text/html; charset=utf-8', html);
  } catch (e) {
    send(res, 503, 'text/plain; charset=utf-8', `No se pudo armar la página: ${e.message}`);
  }
}).listen(8080, () => console.log(JSON.stringify({ level: 'INFO', service: 'storefront-ssr', msg: 'escuchando en :8080' })));
