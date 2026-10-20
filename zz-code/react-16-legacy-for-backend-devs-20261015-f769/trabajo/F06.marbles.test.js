// Pruebas de canicas de F06, una por épica (copia de zz-code; no va al curso).
// rxjs-marbles 6.0.1 corre en TestScheduler.run: el tiempo es virtual, 1 frame = 1 ms.
import { marbles } from "rxjs-marbles/jest";
import { undoWindowEpic } from "../features/grants/epics/undoWindowEpic";
import { sendGrantEpic } from "../features/grants/epics/sendGrantEpic";
import { searchPlayerEpic } from "../features/grants/epics/searchPlayerEpic";
import { retryGrantEpic } from "../features/grants/epics/retryGrantEpic";
import { cancelOnLogoutEpic } from "../app/cancelOnLogoutEpic";
import {
  grantQueued, undoGrant, sendGrantRequested, sendAllRequested, grantSending, grantSent,
  grantConfirmed, rollbackGrant, playerSearchRequested, playerSearchSucceeded, grantsReset,
} from "../features/grants/grantSlice";
import { logout } from "../features/auth/authSlice";

const JUAN = { id: 42, name: "Juan P." };
const queuedAction = grantQueued({ player: JUAN, caseId: "C-2210", prize: "vidas-5", reason: "caída" });
const g = queuedAction.payload;
const stateWith = (grant) => ({ value: { grants: { byId: { [grant.id]: grant }, order: [grant.id] } } });

describe("undoWindowEpic", () => {
  test("a los 10 s pide el envío", marbles((m) => {
    const action$ = m.hot("-q", { q: queuedAction });
    m.expect(undoWindowEpic(action$)).toBeObservable("- 10000ms s", { s: sendGrantRequested(g.id) });
  }));
  test("«Deshacer» dentro de la ventana corta el timer: no sale nada", marbles((m) => {
    const action$ = m.hot("-q 5000ms u", { q: queuedAction, u: undoGrant(g.id) });
    m.expect(undoWindowEpic(action$)).toBeObservable("");
  }));
  test("el logout también corta la ventana", marbles((m) => {
    const action$ = m.hot("-q 3000ms L", { q: queuedAction, L: logout() });
    m.expect(undoWindowEpic(action$)).toBeObservable("");
  }));
  test("el «Deshacer» de OTRO envío no corta esta ventana", marbles((m) => {
    const action$ = m.hot("-q 5000ms u", { q: queuedAction, u: undoGrant("g-otro") });
    m.expect(undoWindowEpic(action$)).toBeObservable("- 10000ms s", { s: sendGrantRequested(g.id) });
  }));
});

describe("sendGrantEpic", () => {
  test("doble clic: exhaustMap ignora el segundo mientras el primero vuela; una sola petición", marbles((m) => {
    let calls = 0;
    const api = { post: () => { calls += 1; return m.cold("----r|", { r: { data: {} } }); } };
    const action$ = m.hot("-a-b", { a: sendGrantRequested(g.id), b: sendGrantRequested(g.id) });
    const out = sendGrantEpic(action$, stateWith(g), { api });
    m.expect(out).toBeObservable("-(st)c", { s: grantSending(g.id), t: grantSent({ grantId: g.id }), c: grantConfirmed(g.id) });
    m.flush();
    expect(calls).toBe(1);
  }));
  test("un envío que falla no mata la épica: el siguiente sale", marbles((m) => {
    const other = { ...g, id: "g-99" };
    const state$ = { value: { grants: { byId: { [g.id]: g, [other.id]: other }, order: [g.id, other.id] } } };
    const err = Object.assign(new Error("503"), { response: { status: 503, data: {} } });
    const api = { post: (url, body) => (body.grantId === g.id ? m.cold("----#", {}, err) : m.cold("----r|", { r: {} })) };
    const action$ = m.hot("-a 10ms b", { a: sendGrantRequested(g.id), b: sendGrantRequested(other.id) });
    const out = sendGrantEpic(action$, state$, { api });
    m.expect(out).toBeObservable("-(st)f 6ms (uv)c", {
      s: grantSending(g.id), t: grantSent({ grantId: g.id }),
      f: rollbackGrant({ grantId: g.id, caseId: g.caseId, playerId: g.playerId, error: { message: "El servidor tuvo un problema. Intenta de nuevo.", type: "http" } }),
      u: grantSending(other.id), v: grantSent({ grantId: other.id }), c: grantConfirmed(other.id),
    });
  }));
  test("la guarda de origen: un envío ya enviado no crea petición", marbles((m) => {
    const api = { post: () => { throw new Error("no debía llamarse"); } };
    const action$ = m.hot("-a", { a: sendGrantRequested(g.id) });
    m.expect(sendGrantEpic(action$, stateWith({ ...g, status: "sent", confirmed: true }), { api })).toBeObservable("");
  }));
});

describe("searchPlayerEpic", () => {
  test("switchMap: la respuesta vieja (Ana, lenta) se descarta; gana la búsqueda nueva (Anaís)", marbles((m) => {
    const ANA = [{ id: 44, name: "Ana", status: "banned" }, { id: 45, name: "Anaís", status: "active" }];
    const ANAIS = [{ id: 45, name: "Anaís", status: "active" }];
    const api = { get: (url, { params }) => (params.name_like === "Ana" ? m.cold("500ms r|", { r: { data: ANA } }) : m.cold("100ms r|", { r: { data: ANAIS } })) };
    const action$ = m.hot("-a 400ms b", { a: playerSearchRequested("Ana"), b: playerSearchRequested("Anaís") });
    m.expect(searchPlayerEpic(action$, null, { api })).toBeObservable("802ms s", { s: playerSearchSucceeded({ query: "Anaís", results: ANAIS }) });
  }));
  test("debounce: tipear rápido busca una sola vez, con el último texto", marbles((m) => {
    const calls = [];
    const api = { get: (url, { params }) => { calls.push(params.name_like); return m.cold("r|", { r: { data: [] } }); } };
    const action$ = m.hot("-a-b-c", { a: playerSearchRequested("A"), b: playerSearchRequested("An"), c: playerSearchRequested("Ana") });
    m.expect(searchPlayerEpic(action$, null, { api })).toBeObservable("----- 300ms s", { s: playerSearchSucceeded({ query: "Ana", results: [] }) });
    m.flush();
    expect(calls).toEqual(["Ana"]);
  }));
});

describe("retryGrantEpic", () => {
  test("reintenta los 503 con backoff (500 ms, 1 s) y confirma al tercer intento", marbles((m) => {
    const err = Object.assign(new Error("503"), { response: { status: 503, data: {} } });
    let call = 0;
    const api = { post: () => { call += 1; return call < 3 ? m.cold("-#", {}, err) : m.cold("-r|", { r: {} }); } };
    const action$ = m.hot("-a", { a: sendAllRequested() });
    m.expect(retryGrantEpic(action$, stateWith(g), { api })).toBeObservable("-(st) 1499ms c", {
      s: grantSending(g.id), t: grantSent({ grantId: g.id }), c: grantConfirmed(g.id),
    });
  }));
  test("un 409 no se reintenta: rollback de inmediato", marbles((m) => {
    const err = Object.assign(new Error("409"), { response: { status: 409, data: { error: "Ese caso ya fue compensado para este jugador." } } });
    let call = 0;
    const api = { post: () => { call += 1; return m.cold("----#", {}, err); } };
    const action$ = m.hot("-a", { a: sendAllRequested() });
    m.expect(retryGrantEpic(action$, stateWith(g), { api })).toBeObservable("-(st)f", {
      s: grantSending(g.id), t: grantSent({ grantId: g.id }),
      f: rollbackGrant({ grantId: g.id, caseId: g.caseId, playerId: g.playerId, error: { message: "Ese caso ya fue compensado para este jugador.", type: "conflict" } }),
    });
    m.flush();
    expect(call).toBe(1);
  }));
});

describe("cancelOnLogoutEpic", () => {
  test("el logout (auth/logout, del action creator) reinicia los envíos", marbles((m) => {
    const action$ = m.hot("-L", { L: logout() });
    m.expect(cancelOnLogoutEpic(action$)).toBeObservable("-r", { r: grantsReset() });
  }));
});
