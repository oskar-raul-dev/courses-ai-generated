// F19 §8: diez ventas por segundo durante treinta segundos, por la puerta; una unidad de un producto sembrado,
// en una droguería al azar (las existencias las deja la-vecina.js en 500).
import http from 'k6/http';
import { check } from 'k6';
export const options = {
  scenarios: { ventas: { executor: 'constant-arrival-rate', rate: 10, timeUnit: '1s', duration: '30s', preAllocatedVUs: 10, maxVUs: 50 } },
  summaryTrendStats: ['med', 'p(95)'],
};
const SKUS = ['SKU-0001', 'SKU-0002', 'SKU-0003', 'SKU-0004', 'SKU-0005', 'SKU-0006', 'SKU-0007', 'SKU-0008'];
export default function () {
  const store = `DRO-${String(1 + Math.floor(Math.random() * 20)).padStart(3, '0')}`;
  const sku = SKUS[Math.floor(Math.random() * SKUS.length)];
  const r = http.post('http://api.localhost:8080/inventory/sales', JSON.stringify({ store, sku, quantity: 1 }),
    { headers: { 'Content-Type': 'application/json' } });
  check(r, { '201': (x) => x.status === 201 });
}
