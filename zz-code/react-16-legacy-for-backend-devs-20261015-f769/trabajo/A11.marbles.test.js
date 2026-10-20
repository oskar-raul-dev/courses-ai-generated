// Pruebas de canicas de A11, contra las épicas de la F07.
// rxjs-marbles 6.0.1 corre en TestScheduler.run: el tiempo es virtual, 1 frame = 1 ms.
import { marbles } from "rxjs-marbles/jest";
import { undoWindowEpic } from "../features/grants/epics/undoWindowEpic";
import { searchPlayerEpic, SEARCH_DEBOUNCE_MS } from "../features/grants/epics/searchPlayerEpic";
import { pollingEpic, POLLING_INTERVAL_MS } from "../features/purchases/epics/pollingEpic";
import { cancelOnLogoutEpic } from "../app/cancelOnLogoutEpic";
import {
  grantQueued, undoGrant, sendGrantRequested, grantsReset, playerSearchRequested, playerSearchSucceeded,
} from "../features/grants/grantSlice";
import { startPolling, stopPolling } from "../features/purchases/purchaseSlice";
import { logout } from "../features/auth/authSlice";

const juanQueued = grantQueued({ player: { id: 42, name: "Juan P." }, caseId: "C-2210", prize: "vidas-5", reason: "caída" });
const juan = juanQueued.payload;

// §3 — hot frente a cold
test("hot: el «Deshacer» a los 6 s del encolado corta la ventana", marbles((m) => {
  const action$ = m.hot("5000ms q 6000ms u", { q: juanQueued, u: undoGrant(juan.id) });
  m.expect(undoWindowEpic(action$)).toBeObservable("");
}));

test("cold: el mismo diagrama deja salir el envío, porque el takeUntil ve su propia copia", marbles((m) => {
  const action$ = m.cold("5000ms q 6000ms u", { q: juanQueued, u: undoGrant(juan.id) });
  // El takeUntil se suscribe en el frame 5000 y su copia del «Deshacer» llega en el 16001:
  // tarde para una ventana que vence en el 15000.
  m.expect(undoWindowEpic(action$)).toBeObservable("15000ms s", { s: sendGrantRequested(juan.id) });
}));

// §4 — el molde
test("el logout reinicia los envíos", marbles((m) => {
  const action$ = m.hot("  -L", { L: logout() });
  const expected = "       -r";
  const values = { r: grantsReset() };
  m.expect(cancelOnLogoutEpic(action$)).toBeObservable(expected, values);
}));

// §5 — debounceTime
test("tipear rápido busca una sola vez, con el último texto", marbles((m) => {
  const calls = [];
  const api = { get: (url, { params }) => { calls.push(params.name_like); return m.cold("r|", { r: { data: [] } }); } };
  const action$ = m.hot("-a-b-c", {
    a: playerSearchRequested("A"),
    b: playerSearchRequested("An"),
    c: playerSearchRequested("Ana"),
  });
  // La última tecla cae en el frame 5; la búsqueda sale SEARCH_DEBOUNCE_MS después.
  m.expect(searchPlayerEpic(action$, null, { api })).toBeObservable(`----- ${SEARCH_DEBOUNCE_MS}ms s`, {
    s: playerSearchSucceeded({ query: "Ana", results: [] }),
  });
  m.flush();
  expect(calls).toEqual(["Ana"]);
}));

// §6 — switchMap
test("la búsqueda nueva cancela la vieja aunque la vieja responda después", marbles((m) => {
  const ANA = [{ id: 44, name: "Ana", status: "banned" }, { id: 45, name: "Anaís", status: "active" }];
  const ANAIS = [{ id: 45, name: "Anaís", status: "active" }];
  const api = {
    get: (url, { params }) =>
      params.name_like === "Ana" ? m.cold("500ms r|", { r: { data: ANA } }) : m.cold("100ms r|", { r: { data: ANAIS } }),
  };
  const action$ = m.hot("-a 400ms b", { a: playerSearchRequested("Ana"), b: playerSearchRequested("Anaís") });
  m.expect(searchPlayerEpic(action$, null, { api })).toBeObservable("802ms s", {
    s: playerSearchSucceeded({ query: "Anaís", results: ANAIS }),
  });
}));

// §7 — takeUntil
test("el logout dentro de la ventana corta el timer: no sale nada", marbles((m) => {
  const action$ = m.hot("-q 3000ms L", { q: juanQueued, L: logout() });
  m.expect(undoWindowEpic(action$)).toBeObservable("");
}));

test("el «Deshacer» de OTRO envío no corta esta ventana", marbles((m) => {
  const action$ = m.hot("-q 5000ms u", { q: juanQueued, u: undoGrant("g-otro") });
  m.expect(undoWindowEpic(action$)).toBeObservable("- 10000ms s", { s: sendGrantRequested(juan.id) });
}));

// §8 — polling
test("el polling pregunta cada POLLING_INTERVAL_MS y deja de preguntar con el stop", marbles((m) => {
  let calls = 0;
  const store = { get: () => { calls += 1; return m.cold("r|", { r: { data: { state: "pending" } } }); } };
  const action$ = m.hot("a 4500ms S", { a: startPolling("tok-oxxo-2"), S: stopPolling() });
  const tick = expect.objectContaining({ type: "purchases/purchaseStatusReceived" });
  // Ticks en 0, 2000 y 4000; el stop en 4501; la prueba mira hasta el 15000.
  m.expect(pollingEpic(action$, null, { store }), "^ 15000ms !").toBeObservable(
    `p ${POLLING_INTERVAL_MS - 1}ms q ${POLLING_INTERVAL_MS - 1}ms r`,
    { p: tick, q: tick, r: tick }
  );
  m.flush();
  expect(calls).toBe(3);
}));

test("el polling termina solo cuando la compra se confirma", marbles((m) => {
  let calls = 0;
  const store = {
    get: () => {
      calls += 1;
      const state = calls < 3 ? "pending" : "confirmed";
      return m.cold("r|", { r: { data: { state } } });
    },
  };
  const action$ = m.hot("a", { a: startPolling("tok-efecty-1") });
  const status = (state) => expect.objectContaining({ payload: expect.objectContaining({ state }) });
  // Sin marca de suscripción: el takeWhile completa el timer, y el tiempo virtual termina.
  m.expect(pollingEpic(action$, null, { store })).toBeObservable(
    `p ${POLLING_INTERVAL_MS - 1}ms q ${POLLING_INTERVAL_MS - 1}ms c`,
    { p: status("pending"), q: status("pending"), c: status("confirmed") }
  );
  m.flush();
  expect(calls).toBe(3);
}));
