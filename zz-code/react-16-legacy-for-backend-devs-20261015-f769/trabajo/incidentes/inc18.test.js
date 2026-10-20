// Incidente 18 (copia de zz-code; la misma prueba que publica el cuaderno). Contra los dos mocks.
import { store } from "../app/store";
import { login } from "../features/auth/authSlice";
import { fetchReconciliation } from "../features/reconciliation/reconciliationSlice";

test("el prorrateo del paquete que muestra la conciliación suma exactamente su precio", async () => {
  await store.dispatch(login({ email: "mdegracia@esclusa.test", password: "esclusa123" }));
  await store.dispatch(fetchReconciliation(4));
  const { purchaseToken, cents, packagePriceCents } = store.getState().reconciliation.packageProration;
  expect(purchaseToken).toBe("tok-ago-05");
  expect(cents.reduce((sum, c) => sum + c, 0)).toBe(packagePriceCents); // con el bug: 2100 contra 2099
}, 20000);
