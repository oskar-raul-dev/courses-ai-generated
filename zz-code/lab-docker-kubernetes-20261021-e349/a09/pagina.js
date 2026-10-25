// a09: lo que tarda la página con sus datos, a 20 por segundo durante 30 s, por la puerta. MODE=static: las cuatro
// peticiones de la estática en serie (el HTML, /config.json, el catálogo y los precios); MODE=ssr: una.
import http from 'k6/http';
import { check } from 'k6';
import { Trend } from 'k6/metrics';

const page = new Trend('pagina', true);
const G = 'http://127.0.0.1:8080';
const host = (h) => ({ headers: { Host: h } });

export const options = {
  scenarios: { pagina: { executor: 'constant-arrival-rate', rate: 20, timeUnit: '1s', duration: '30s', preAllocatedVUs: 20 } },
  summaryTrendStats: ['med', 'p(95)'],
};

export default function () {
  const t0 = Date.now();
  if (__ENV.MODE === 'ssr') {
    check(http.get(`${G}/?store=DRO-007`, host('ssr.localhost')), { 200: (r) => r.status === 200 });
  } else {
    const rs = [
      http.get(`${G}/`, host('storefront.localhost')),
      http.get(`${G}/config.json`, host('storefront.localhost')),
      http.get(`${G}/catalog/products`, host('api.localhost')),
      http.get(`${G}/pricing/prices?store=DRO-007`, host('api.localhost')),
    ];
    check(rs, { '200': (all) => all.every((r) => r.status === 200) });
  }
  page.add(Date.now() - t0);
}
