// Prueba de regresión del incidente 07 (copia de zz-code; la misma que publica el cuaderno).
// Corre contra el mock con CHAOS_LEVEL=high: ninguna petición de login puede quedar colgada.
import { store } from "../app/store";
import { login } from "../features/auth/authSlice";

test("ninguna petición de login se queda colgada con el caos alto", async () => {
  const logins = Array.from({ length: 200 }, () =>
    store.dispatch(login({ email: "ibatista@esclusa.test", password: "esclusa123" }))
  );
  const outcome = await Promise.race([
    Promise.all(logins).then(() => "todas resueltas"),
    new Promise((resolve) => setTimeout(() => resolve("hay colgadas"), 20000)),
  ]);
  expect(outcome).toBe("todas resueltas");
}, 40000);
