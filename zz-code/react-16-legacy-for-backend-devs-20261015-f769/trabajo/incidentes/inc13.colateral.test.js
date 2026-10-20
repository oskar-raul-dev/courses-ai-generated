// Incidente 13, daño colateral (copia de zz-code): con el epic de envío muerto, ¿la búsqueda sigue viva?
const wait = (ms) => new Promise((r) => setTimeout(r, ms));
test("después del envío fallido, la búsqueda todavía responde", async () => {
  jest.resetModules();
  const apiClient = require("../api/apiClient").default;
  const { store } = require("../app/store");
  const grants = require("../features/grants/grantSlice");
  apiClient.defaults.adapter = (config) => {
    if (config.method === "post") {
      const err = new Error("Request failed with status code 503");
      err.config = config; err.response = { status: 503, data: {}, headers: {}, config };
      return Promise.reject(err);
    }
    return Promise.resolve({ status: 200, data: [{ id: 45, name: "Anaís", status: "active" }], headers: {}, config, statusText: "OK" });
  };
  const g = store.dispatch(grants.grantQueued({ player: { id: 42, name: "Juan P." }, caseId: "C-1", prize: "vidas-5", reason: "caída" })).payload;
  store.dispatch(grants.sendGrantRequested(g.id));
  await wait(100);
  store.dispatch(grants.playerSearchRequested("Anaís"));
  await wait(600);
  expect(store.getState().grants.playerSearch.results.map((p) => p.name)).toEqual(["Anaís"]);
});
