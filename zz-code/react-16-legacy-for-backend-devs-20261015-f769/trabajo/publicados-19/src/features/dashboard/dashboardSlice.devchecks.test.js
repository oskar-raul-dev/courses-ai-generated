// src/features/dashboard/dashboardSlice.devchecks.test.js (la misma prueba que corre en el repo de prueba)
// Contra los dos mocks, con la Semana del Canal sembrada: node mock/seed-reconciliation.js --event
import { store } from "../../app/store";
import { login } from "../auth/authSlice";
import { fetchDashboard } from "./dashboardSlice";
import { undoGrant } from "../grants/grantSlice";

test("cargar la bitácora del evento, y después una acción de otra pantalla, no disparan el aviso de Toolkit", async () => {
  await store.dispatch(login({ email: "ibatista@esclusa.test", password: "esclusa123" }));
  const warn = jest.spyOn(console, "warn").mockImplementation(() => {});
  await store.dispatch(fetchDashboard(2)); // la acción que trae las 180.000 filas
  expect(store.getState().dashboard.spinLog).toHaveLength(180000);
  store.dispatch(undoGrant("g-inexistente")); // cualquier acción, de cualquier pantalla
  const slow = warn.mock.calls.filter(([message]) => String(message).includes("which is more than the warning threshold"));
  warn.mockRestore();
  expect(slow).toEqual([]); // con el bug: "SerializableStateInvariantMiddleware took … ms"
}, 60000);
