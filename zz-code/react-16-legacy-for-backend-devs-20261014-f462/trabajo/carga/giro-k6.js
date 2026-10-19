// Carga de la verificación P7 con k6 (grafana/k6:1.5.0). Cada jugador reintenta el
// giro con la MISMA clave, como hace un cliente que perdió la respuesta: dos
// peticiones por clave. Las cifras (dobles y stock excedido) salen del SQL después.
import http from "k6/http";
import { check } from "k6";

const BASE = __ENV.BASE || "http://app:3000";

export const options = {
  scenarios: {
    giro: {
      executor: "shared-iterations",
      vus: 50,
      iterations: 1500,
      maxDuration: "5m",
    },
  },
};

export default function () {
  const key = `k-${__VU}-${__ITER}`;
  const player = `p-${__VU}`;
  const body = JSON.stringify({ key });
  const headers = { "Content-Type": "application/json" };
  // Primer intento y reintento con la misma clave.
  const a = http.post(`${BASE}/players/${player}/spins`, body, { headers });
  const b = http.post(`${BASE}/players/${player}/spins`, body, { headers });
  check(a, { "primer intento responde": (r) => r.status === 200 || r.status === 409 });
  check(b, { "reintento responde": (r) => r.status === 200 || r.status === 409 });
}
