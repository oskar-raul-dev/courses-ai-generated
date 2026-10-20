// src/features/grants/epics/searchPlayerEpic.order.test.js (la misma prueba que corre en el repo de prueba).
import { TestScheduler } from "rxjs/testing";
import { searchPlayerEpic } from "./searchPlayerEpic";
import { playerSearchRequested, playerSearchSucceeded } from "../grantSlice";

test("buscar «Ana» y enseguida «Anaís»: solo llega la respuesta de «Anaís»", () => {
  const scheduler = new TestScheduler((actual, expected) => expect(actual).toEqual(expected));
  scheduler.run(({ hot, cold, expectObservable }) => {
    const ANA = [{ id: 44, name: "Ana", status: "banned" }, { id: 45, name: "Anaís", status: "active" }];
    const ANAIS = [{ id: 45, name: "Anaís", status: "active" }];
    // «Ana» tarda más que «Anaís»: es la latencia que el caos alto produce de vez en cuando.
    const api = {
      get: (url, { params }) =>
        params.name_like === "Ana" ? cold("500ms r|", { r: { data: ANA } }) : cold("100ms r|", { r: { data: ANAIS } }),
    };
    const action$ = hot("-a 400ms b", { a: playerSearchRequested("Ana"), b: playerSearchRequested("Anaís") });
    // Con el bug (mergeMap) llegan las dos, y la de «Ana» en último lugar.
    expectObservable(searchPlayerEpic(action$, null, { api })).toBe("802ms s", {
      s: playerSearchSucceeded({ query: "Anaís", results: ANAIS }),
    });
  });
});
