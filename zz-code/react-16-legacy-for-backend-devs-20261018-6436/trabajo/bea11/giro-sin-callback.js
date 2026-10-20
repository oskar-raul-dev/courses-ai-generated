// server/load/giro.js
// La noche de la Esclusa de Oro, a escala: giros con clave de idempotencia, y
// cada clave enviada dos veces seguidas (el reintento del juego con la señal
// mala). Por defecto, 50 giros por segundo: los ~3.000 por minuto del pico de
// la Semana del Canal 2025 (historia §8).
//
// Dos escenarios (SCENARIO):
//   pico          llegadas parejas a RATE por segundo (constant-arrival-rate)
//   notificacion  VUS jugadores a la vez, cada uno gira apenas recibe respuesta:
//                 la notificación de las 7:00 p. m. llegando a todos juntos
//
//   docker run --rm -i --network <red> -e BASE_URL=http://api:3001 \
//     grafana/k6:1.5.0 run - < server/load/giro.js
import http from "k6/http";
import { check } from "k6";
import { Counter } from "k6/metrics";
import exec from "k6/execution";

const BASE_URL = __ENV.BASE_URL || "http://localhost:3001";
const RATE = Number(__ENV.RATE || 50); // giros por segundo
const KEYS = Number(__ENV.KEYS || 1500); // claves distintas; cada una va dos veces
const PLAYERS = Number(__ENV.PLAYERS || 300); // jugadores de la carga, con 5 giros gratis cada uno
const PLAYER_BASE = Number(__ENV.PLAYER_BASE || 10000);
const SCENARIO = __ENV.SCENARIO || "pico";
const VUS = Number(__ENV.VUS || 100);

const scenarios = {
  pico: {
    executor: "constant-arrival-rate",
    rate: RATE,
    timeUnit: "1s",
    duration: `${Math.ceil((KEYS * 2) / RATE)}s`,
    preAllocatedVUs: 50,
    maxVUs: 500,
  },
  notificacion: {
    executor: "shared-iterations",
    vus: VUS,
    iterations: KEYS * 2,
    maxDuration: "5m",
  },
};

// Un contador con el status como etiqueta: el resumen de k6 solo muestra el
// desglose de las submétricas que aparecen en thresholds.
const responses = new Counter("respuestas");

// 409 es una respuesta de negocio (sin giros, giro en proceso, agotado), no un
// fallo del servidor: sin esto, http_req_failed los cuenta como errores.
// (sin setResponseCallback: el 409 cuenta como fallo)

export const options = {
  scenarios: { [SCENARIO]: scenarios[SCENARIO] },
  thresholds: {
    http_req_failed: ["rate<0.01"],
    "http_req_duration{name:giro}": ["p(95)<500"],
    "respuestas{status:200}": ["count>=0"],
    "respuestas{status:409}": ["count>=0"],
    "respuestas{status:500}": ["count>=0"],
  },
};

export default function () {
  const i = exec.scenario.iterationInTest;
  if (i >= KEYS * 2) return; // la última vuelta puede pasarse por redondeo
  const key = Math.floor(i / 2);
  const player = PLAYER_BASE + (key % PLAYERS) + 1;
  const res = http.post(`${BASE_URL}/players/${player}/spins`, JSON.stringify({ idempotencyKey: `k6-${key}` }), {
    headers: { "Content-Type": "application/json" },
    tags: { name: "giro" },
  });
  responses.add(1, { status: String(res.status) });
  check(res, { "200 o 409": (r) => r.status === 200 || r.status === 409 });
}
