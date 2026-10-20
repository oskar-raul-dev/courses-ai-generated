// Incidente 19 (copia de zz-code; la misma prueba que publica el cuaderno). Contra los dos mocks,
// con la Semana del Canal sembrada (--event, 180.000 giros).
import { store } from "../app/store";
import { login } from "../features/auth/authSlice";
import { fetchDashboard } from "../features/dashboard/dashboardSlice";
import { undoGrant } from "../features/grants/grantSlice";

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
