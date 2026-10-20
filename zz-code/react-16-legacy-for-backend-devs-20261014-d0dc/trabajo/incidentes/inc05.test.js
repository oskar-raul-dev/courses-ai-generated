// Prueba de regresión del incidente 05 (copia de zz-code; no va al curso).
import apiClient from "../api/apiClient";
import { store } from "../app/store";
import { login } from "../features/auth/authSlice";

test("después de loguear, las peticiones salen con Authorization", async () => {
  // Sin red: el adaptador devuelve la config que axios iba a mandar.
  apiClient.defaults.adapter = (config) =>
    Promise.resolve({ data: [], status: 200, statusText: "OK", headers: {}, config });

  store.dispatch({
    type: login.fulfilled.type,
    payload: { id: 1, email: "ibatista@esclusa.test", name: "Itzel Batista", token: "tok_ibatista_3c7e" },
  });

  const response = await apiClient.get("/wheels");
  expect(response.config.headers.Authorization).toBe("Bearer tok_ibatista_3c7e");
});
