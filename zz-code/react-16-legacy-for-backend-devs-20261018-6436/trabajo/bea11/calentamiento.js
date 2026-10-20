// Error 2: el calentamiento. Dos escenarios seguidos sobre el mismo binario recién arrancado:
// los primeros 3 segundos y los 10 siguientes, con la misma tasa, cada uno con su etiqueta.
import http from "k6/http";

const shape = { executor: "constant-arrival-rate", rate: 100, timeUnit: "1s", preAllocatedVUs: 20, maxVUs: 50 };
export const options = {
  scenarios: {
    frio: { ...shape, duration: "3s", tags: { fase: "frio" } },
    caliente: { ...shape, duration: "10s", startTime: "3s", tags: { fase: "caliente" } },
  },
  thresholds: {
    "http_req_duration{fase:frio}": ["p(95)>=0"],
    "http_req_duration{fase:caliente}": ["p(95)>=0"],
  },
};

export default function () {
  http.get(`${__ENV.BASE_URL}/wheels`, { headers: { Authorization: `Bearer ${__ENV.TOKEN}` } });
}
