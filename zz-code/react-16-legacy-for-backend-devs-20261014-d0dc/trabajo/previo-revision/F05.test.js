// Pruebas de F05 (copia de zz-code): máquina de estados, ventana de deshacer, fallos a medias.
// Tiempos reales: la ventana de 10 s es parte de lo que se prueba.
jest.setTimeout(30000);
const { store } = require("./app/store");
const apiClient = require("./api/apiClient").default;
const { queueGrant, undoGrant, revertGrant, selectGrantById } = require("./features/grants/grantSlice");

let llamadas = [];
function adaptador(fallaPara = []) {
  return (config) => {
    llamadas.push(JSON.parse(config.data));
    const jugador = Number(config.url.split("/")[2]);
    if (fallaPara.includes(jugador)) {
      const err = new Error("Request failed with status code 503");
      err.config = config;
      err.response = { status: 503, headers: {}, config, data: {} };
      return Promise.reject(err);
    }
    return Promise.resolve({ data: { id: 1, playerId: jugador }, status: 201, statusText: "Created", headers: {}, config });
  };
}
const estado = (id) => selectGrantById(id)(store.getState());
const esperar = (ms) => new Promise((r) => setTimeout(r, ms));

beforeEach(() => { llamadas = []; });

test("un envío sin deshacer pasa por sending y queda sent tras la ventana", async () => {
  apiClient.defaults.adapter = adaptador();
  await store.dispatch(queueGrant({ id: 101, playerId: 42, reason: "prueba", prize: "vidas-2" }));
  expect(estado(101).status).toBe("queued");
  await esperar(10300);
  expect(estado(101).status).toBe("sent");
  expect(llamadas.length).toBe(1);
});

test("deshacer dentro de la ventana: nunca sale", async () => {
  apiClient.defaults.adapter = adaptador();
  await store.dispatch(queueGrant({ id: 102, playerId: 42, reason: "prueba", prize: "vidas-2" }));
  await store.dispatch(undoGrant(102));
  expect(estado(102).status).toBe("reverted");
  await esperar(10300);
  expect(llamadas.length).toBe(0);
});

test("un fallo del servidor deja el envío failed con mensaje, y revertir lo cierra", async () => {
  apiClient.defaults.adapter = adaptador([42]);
  await store.dispatch(queueGrant({ id: 103, playerId: 42, reason: "prueba", prize: "vidas-2" }));
  await esperar(10300);
  expect(estado(103).status).toBe("failed");
  expect(estado(103).error).toMatch(/enviar el premio/);
  store.dispatch(revertGrant(103));
  expect(estado(103).status).toBe("reverted");
});

test("envío masivo a medias: los que fallan no tocan a los demás", async () => {
  apiClient.defaults.adapter = adaptador([43]);
  await store.dispatch(queueGrant({ id: 104, playerId: 42, reason: "masivo", prize: "vidas-2" }));
  await store.dispatch(queueGrant({ id: 105, playerId: 43, reason: "masivo", prize: "vidas-2" }));
  await esperar(10300);
  expect(estado(104).status).toBe("sent");
  expect(estado(105).status).toBe("failed");
});

test("transiciones no permitidas se ignoran: un envío enviado no se deshace", async () => {
  apiClient.defaults.adapter = adaptador();
  await store.dispatch(queueGrant({ id: 106, playerId: 42, reason: "prueba", prize: "vidas-2" }));
  await esperar(10300);
  await store.dispatch(undoGrant(106));
  expect(estado(106).status).toBe("sent");
});
