// Prueba de regresión del incidente 12 (copia de zz-code). Adaptador sin red: solo el store.
import apiClient from "../api/apiClient";
import { store } from "../app/store";
import { queueGrant, sendGrant } from "../features/grants/grantSlice";

jest.setTimeout(30000);

test("un rechazo tardío no pisa un envío que ya llegó como sent", async () => {
  apiClient.defaults.adapter = (config) =>
    Promise.resolve({ data: { id: 1 }, status: 201, statusText: "Created", headers: {}, config });
  await store.dispatch(queueGrant({ id: 401, playerId: 42, reason: "prueba 12", prize: "vidas-2" }));
  await new Promise((resolve) => setTimeout(resolve, 10500));
  expect(store.getState().grants.byId[401].status).toBe("sent");
  // Llega tarde la respuesta de un intento anterior que había fallado:
  store.dispatch({ type: sendGrant.rejected.type, payload: "tardío", meta: { arg: 401 } });
  expect(store.getState().grants.byId[401].status).toBe("sent");
});
