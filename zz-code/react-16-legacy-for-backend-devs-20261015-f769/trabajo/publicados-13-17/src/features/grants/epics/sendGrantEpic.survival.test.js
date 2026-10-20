// src/features/grants/epics/sendGrantEpic.survival.test.js (la misma prueba que corre en el repo de prueba).
import { TestScheduler } from "rxjs/testing";
import { sendGrantEpic } from "./sendGrantEpic";
import { grantQueued, sendGrantRequested, grantSending, grantSent, grantConfirmed, rollbackGrant } from "../grantSlice";

test("un envío que falla no mata el epic: el siguiente sale igual", () => {
  const scheduler = new TestScheduler((actual, expected) => expect(actual).toEqual(expected));
  scheduler.run(({ hot, cold, expectObservable }) => {
    const a = grantQueued({ player: { id: 42, name: "Juan P." }, caseId: "C-1", prize: "vidas-5", reason: "caída" }).payload;
    const b = grantQueued({ player: { id: 43, name: "María R." }, caseId: "C-1", prize: "vidas-5", reason: "caída" }).payload;
    const state$ = { value: { grants: { byId: { [a.id]: a, [b.id]: b }, order: [a.id, b.id] } } };
    const error = Object.assign(new Error("503"), { response: { status: 503, data: {} } });
    // El primero falla con un 503; el segundo sale bien.
    const api = { post: (url, body) => (body.grantId === a.id ? cold("----#", {}, error) : cold("----r|", { r: {} })) };
    const action$ = hot("-a 10ms b", { a: sendGrantRequested(a.id), b: sendGrantRequested(b.id) });
    // Con el bug, el diagrama termina en error (#) en el frame del fallo, y b nunca sale.
    expectObservable(sendGrantEpic(action$, state$, { api })).toBe("-(st)f 6ms (uv)c", {
      s: grantSending(a.id),
      t: grantSent({ grantId: a.id }),
      f: rollbackGrant({ grantId: a.id, caseId: "C-1", playerId: 42, error: { message: "El servidor tuvo un problema. Intenta de nuevo.", type: "http" } }),
      u: grantSending(b.id),
      v: grantSent({ grantId: b.id }),
      c: grantConfirmed(b.id),
    });
  });
});
