// src/features/purchases/epics/pollingEpic.logout.test.js (la misma prueba que corre en el repo de prueba).
import { TestScheduler } from "rxjs/testing";
import { pollingEpic, POLLING_INTERVAL_MS } from "./pollingEpic";
import { startPolling } from "../purchaseSlice";
import { logout } from "../../auth/authSlice";

test("después del logout no sale ni una consulta más", () => {
  const scheduler = new TestScheduler((actual, expected) => expect(actual).toEqual(expected));
  let calls = 0;
  scheduler.run(({ hot, cold, expectObservable }) => {
    const store = { get: () => { calls += 1; return cold("r|", { r: { data: { state: "pending" } } }); } };
    const action$ = hot(`a ${POLLING_INTERVAL_MS + 500}ms L`, { a: startPolling("tok-oxxo-2"), L: logout() });
    // Se mira lo que pasa en los diez segundos siguientes al logout.
    expectObservable(pollingEpic(action$, null, { store }), `^ ${POLLING_INTERVAL_MS + 10500}ms !`).toBe(`p ${POLLING_INTERVAL_MS - 1}ms q`, {
      p: expect.objectContaining({ type: "purchases/purchaseStatusReceived" }),
      q: expect.objectContaining({ type: "purchases/purchaseStatusReceived" }),
    });
  });
  expect(calls).toBe(2); // con el bug: siguen saliendo, una cada dos segundos
});
