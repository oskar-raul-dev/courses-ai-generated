// Incidente 17 (copia de zz-code; la misma prueba que publica el cuaderno). TestScheduler de rxjs/testing.
import { TestScheduler } from "rxjs/testing";
import { pollingEpic, POLLING_INTERVAL_MS } from "../features/purchases/epics/pollingEpic";
import { startPolling, pollingFailed } from "../features/purchases/purchaseSlice";

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
