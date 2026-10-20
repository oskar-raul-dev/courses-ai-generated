// Integración de F08 contra los dos mocks (copia de zz-code; no va al curso).
import axios from "axios";
import { store } from "../app/store";
import { login } from "../features/auth/authSlice";
import { fetchWheels } from "../features/wheels/wheelSlice";
import { fetchReconciliation, reconcileWheel } from "../features/reconciliation/reconciliationSlice";

test("concilia la rueda 4: probabilidades, compras y la transición", async () => {
  await store.dispatch(login({ email: "mdegracia@esclusa.test", password: "esclusa123" }));
  await store.dispatch(fetchWheels());
  await store.dispatch(fetchReconciliation(4));
  const r = store.getState().reconciliation;
  expect(r.error).toBeNull();
  expect(r.counts.reduce((a, b) => a + b, 0)).toBe(10000);
  expect(r.audit.chi2Alarm).toBe(false);
  expect(r.purchases.missingInApi).toEqual(["tok-ago-31"]);
  expect(r.packageProration.cents.reduce((a, b) => a + b, 0)).toBe(2099);

  await store.dispatch(reconcileWheel());
  expect(store.getState().wheels.items.find((w) => w.id === 4).status).toBe("reconciled");
  expect(store.getState().reconciliation.record.wheelId).toBe(4);

  // La segunda vez el servidor dice que no: reconciled no tiene salida ni repetición.
  const again = await axios.post("http://localhost:3001/wheels/4/reconciliation", {}, {
    headers: { Authorization: `Bearer ${store.getState().auth.token}` },
    validateStatus: () => true,
  });
  expect(again.status).toBe(409);
  const live = await axios.post("http://localhost:3001/wheels/1/reconciliation", {}, {
    headers: { Authorization: `Bearer ${store.getState().auth.token}` },
    validateStatus: () => true,
  });
  expect(live.status).toBe(409);
}, 30000);
