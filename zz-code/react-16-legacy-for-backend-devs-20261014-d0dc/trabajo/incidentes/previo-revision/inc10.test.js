// Prueba de regresión del incidente 10 (copia de zz-code; no va al curso).
import apiClient from "../api/apiClient";
import { store } from "../app/store";
import { fetchWheels } from "../features/wheels/wheelSlice";

test("cuando la lista de ruedas llega, deja de estar cargando", async () => {
  apiClient.defaults.adapter = (config) => {
    const data = config.url === "/wheels"
      ? [{ id: 1, name: "Esclusa de Oro", status: "live" }]
      : [];
    return Promise.resolve({ data, status: 200, statusText: "OK", headers: {}, config });
  };
  await store.dispatch(fetchWheels());
  expect(store.getState().wheels.items.length).toBe(1);
  expect(store.getState().wheels.loading).toBe(false);
});
