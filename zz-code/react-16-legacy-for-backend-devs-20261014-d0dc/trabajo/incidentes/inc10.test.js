// Incidente 10 (copia de zz-code; la misma prueba que publica el cuaderno). Sin red: el adapter de axios falla.
test("un 500 al cargar la lista apaga loadingList y deja el error legible", async () => {
  jest.resetModules();
  const apiClient = require("../api/apiClient").default;
  const { store } = require("../app/store");
  const { fetchWheels } = require("../features/wheels/wheelSlice");
  apiClient.defaults.adapter = (config) => {
    const err = new Error("Request failed with status code 500");
    err.config = config;
    err.response = { status: 500, headers: {}, config, data: {} };
    return Promise.reject(err);
  };
  await store.dispatch(fetchWheels());
  expect(store.getState().wheels.loadingList).toBe(false); // con el bug: true para siempre
  expect(store.getState().wheels.error).toEqual({ message: "El servidor tuvo un problema. Intenta de nuevo.", type: "http" });
});
