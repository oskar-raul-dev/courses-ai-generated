// Error 3: la red del contenedor. El mismo binario, la misma carga, por dos caminos.
import http from "k6/http";

export const options = {
  scenarios: {
    pico: { executor: "constant-arrival-rate", rate: 200, timeUnit: "1s", duration: "10s", preAllocatedVUs: 20, maxVUs: 100 },
  },
};

export default function () {
  http.get(`${__ENV.BASE_URL}/health`);
}
