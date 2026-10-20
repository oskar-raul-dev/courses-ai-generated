// src/features/purchases/epics/pollingEpic.survival.test.js (la misma prueba que corre en el repo de prueba).
import { TestScheduler } from "rxjs/testing";
import { pollingEpic, POLLING_INTERVAL_MS } from "./pollingEpic";
import { startPolling, pollingFailed } from "../purchaseSlice";

test("después de un 500, el tick siguiente pregunta igual y llega la confirmación", () => {
  const scheduler = new TestScheduler((actual, expected) => expect(actual).toEqual(expected));
  scheduler.run(({ hot, cold, expectObservable }) => {
    const error = Object.assign(new Error("500"), { response: { status: 500, data: {} } });
    let call = 0;
    const store = {
      get: () => {
        call += 1;
        return call === 1 ? cold("#", {}, error) : cold("r|", { r: { data: { state: "confirmed" } } });
      },
    };
    const action$ = hot("a", { a: startPolling("tok-efecty-1") });
    // Con el bug, el diagrama se queda en «f»: el polling murió en el primer 500.
    expectObservable(pollingEpic(action$, null, { store })).toBe(`f ${POLLING_INTERVAL_MS - 1}ms c`, {
      f: pollingFailed({ token: "tok-efecty-1", error: { message: "El servidor tuvo un problema. Intenta de nuevo.", type: "http" } }),
      c: expect.objectContaining({ type: "purchases/purchaseStatusReceived", payload: expect.objectContaining({ state: "confirmed" }) }),
    });
  });
});
