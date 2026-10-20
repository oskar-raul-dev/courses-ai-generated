// src/features/reconciliation/reconciliationSlice.proration.test.js (la misma prueba que corre en el repo de prueba)
import { store } from "../../app/store";
import { login } from "../auth/authSlice";
import { fetchReconciliation } from "./reconciliationSlice";

test("el prorrateo del paquete que muestra la conciliación suma exactamente su precio", async () => {
  await store.dispatch(login({ email: "mdegracia@esclusa.test", password: "esclusa123" }));
  await store.dispatch(fetchReconciliation(4));
  const { purchaseToken, cents, packagePriceCents } = store.getState().reconciliation.packageProration;
  expect(purchaseToken).toBe("tok-ago-05");
  expect(cents.reduce((sum, c) => sum + c, 0)).toBe(packagePriceCents); // con el bug: 2100 contra 2099
}, 20000);
