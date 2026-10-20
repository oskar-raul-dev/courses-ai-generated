// Error 2, otra forma: una avalancha contra el binario recién arrancado, con el pool vacío.
// Los primeros 2 segundos y los 8 siguientes, con los mismos 100 VUs, cada tramo con su etiqueta.
import http from "k6/http";

const shape = { executor: "constant-vus", vus: 100 };
export const options = {
  scenarios: {
    frio: { ...shape, duration: "2s", tags: { fase: "frio" } },
    caliente: { ...shape, duration: "8s", startTime: "2s", tags: { fase: "caliente" } },
  },
  thresholds: {
    "http_req_duration{fase:frio}": ["p(95)>=0"],
    "http_req_duration{fase:caliente}": ["p(95)>=0"],
  },
};

export default function () {
  http.get(`${__ENV.BASE_URL}/wheels`, { headers: { Authorization: `Bearer ${__ENV.TOKEN}` } });
}
