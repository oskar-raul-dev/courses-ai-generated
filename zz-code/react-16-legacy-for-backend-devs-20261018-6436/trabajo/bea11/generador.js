// Error 1: medir el generador. Se pide una tasa que los VUs disponibles no pueden sostener
// contra un giro que tarda 100 ms en entregar (SPIN_DELIVERY_MS=100).
import http from "k6/http";
import exec from "k6/execution";

export const options = {
  scenarios: {
    pico: {
      executor: "constant-arrival-rate",
      rate: Number(__ENV.RATE || 200),
      timeUnit: "1s",
      duration: "10s",
      preAllocatedVUs: Number(__ENV.VUS || 5),
      maxVUs: Number(__ENV.VUS || 5),
    },
  },
};

export default function () {
  const i = exec.scenario.iterationInTest;
  http.post(`${__ENV.BASE_URL}/players/${10001 + (i % 300)}/spins`, JSON.stringify({ idempotencyKey: `gen-${i}` }));
}
