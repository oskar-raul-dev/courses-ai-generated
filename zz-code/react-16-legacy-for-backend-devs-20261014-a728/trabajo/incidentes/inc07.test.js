// Prueba de regresión del incidente 07 (copia de zz-code; no va al curso).
// Corre contra el mock con CHAOS_LEVEL=high: ninguna petición de login puede quedar colgada.
import { store } from "../app/store";
import { login } from "../features/auth/authSlice";

test("ninguna petición de login se queda colgada con el caos alto", async () => {
  const promesas = Array.from({ length: 200 }, () =>
    store.dispatch(login({ email: "ibatista@esclusa.test", password: "esclusa123" }))
  );
  const estado = await Promise.race([
    Promise.all(promesas.map((p) => p.then(() => "resuelta"))).then(() => "todas resueltas"),
    new Promise((resolve) => setTimeout(() => resolve("hay colgadas"), 20000)),
  ]);
  expect(estado).toBe("todas resueltas");
}, 40000);
