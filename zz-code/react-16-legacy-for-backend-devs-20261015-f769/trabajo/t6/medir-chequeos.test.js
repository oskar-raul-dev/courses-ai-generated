// Medición (no va al curso): ms por acción con la bitácora del evento en el store, con y sin ignoredPaths.
import { store } from "../app/store";
import { login } from "../features/auth/authSlice";
import { fetchDashboard } from "../features/dashboard/dashboardSlice";
import { undoGrant } from "../features/grants/grantSlice";

test("medir", async () => {
  await store.dispatch(login({ email: "ibatista@esclusa.test", password: "esclusa123" }));
  await store.dispatch(fetchDashboard(2));
  expect(store.getState().dashboard.spinLog).toHaveLength(180000);
  const times = [];
  for (let i = 0; i < 9; i++) {
    const t0 = performance.now();
    store.dispatch(undoGrant("g-inexistente")); // una acción cualquiera de otra pantalla
    times.push(performance.now() - t0);
  }
  times.sort((a, b) => a - b);
  process.stderr.write(`MEDICION por acción: mediana ${times[4].toFixed(1)} ms, máximo ${times[8].toFixed(1)}\n`);
}, 120000);
