// src/features/grants/grantSlice.test.js (la misma prueba que corre en el repo de prueba)
test("doble clic en 'Enviar ahora': sale una sola petición", async () => {
  jest.resetModules();
  const apiClient = require("../../api/apiClient").default;
  const { store } = require("../../app/store");
  const { queueGrant, sendGrant } = require("./grantSlice");
  let posts = 0;
  apiClient.defaults.adapter = (config) => {
    posts += 1;
    return Promise.resolve({ status: 201, data: JSON.parse(config.data), headers: {}, config, statusText: "Created" });
  };
  const grant = store.dispatch(queueGrant({ player: { id: 42, name: "Juan P." }, caseId: "C-2210", prize: "vidas-5", reason: "caída" }));
  // Los dos clics, sin que la respuesta del primero haya llegado.
  await Promise.all([store.dispatch(sendGrant(grant.id)), store.dispatch(sendGrant(grant.id))]);
  expect(posts).toBe(1); // con el bug: 2
});
