// Pruebas de canicas de A7, una o dos por operador, contra las épicas de la F07.
// rxjs-marbles 6.0.1 corre en TestScheduler.run: el tiempo es virtual, 1 frame = 1 ms.
import { marbles } from "rxjs-marbles/jest";
import { from, of } from "rxjs";
import { catchError, concatMap, map } from "rxjs/operators";
import { ofType } from "redux-observable";
import { undoWindowEpic } from "../features/grants/epics/undoWindowEpic";
import { sendGrantEpic } from "../features/grants/epics/sendGrantEpic";
import { searchPlayerEpic } from "../features/grants/epics/searchPlayerEpic";
import { retryGrantEpic } from "../features/grants/epics/retryGrantEpic";
import { pollingEpic, POLLING_INTERVAL_MS } from "../features/purchases/epics/pollingEpic";
import {
  grantQueued, undoGrant, sendGrantRequested, sendAllRequested, grantSending, grantSent,
  grantConfirmed, rollbackGrant, playerSearchRequested, playerSearchSucceeded,
} from "../features/grants/grantSlice";
import { startPolling, pollingFailed } from "../features/purchases/purchaseSlice";
import { logout } from "../features/auth/authSlice";
import { toReadableError } from "../api/readableError";

// Datos comunes: dos envíos encolados y el state$ mínimo que leen las épicas.
const juanQueued = grantQueued({ player: { id: 42, name: "Juan P." }, caseId: "C-2210", prize: "vidas-5", reason: "caída" });
const mariaQueued = grantQueued({ player: { id: 43, name: "María R." }, caseId: "C-2210", prize: "vidas-5", reason: "caída" });
const juan = juanQueued.payload;
const maria = mariaQueued.payload;
const stateWith = (...grants) => ({
  value: { grants: { byId: Object.fromEntries(grants.map((g) => [g.id, g])), order: grants.map((g) => g.id) } },
});
const httpError = (status, data = {}) => Object.assign(new Error(String(status)), { response: { status, data } });

// --- 1. debounceTime ---
test("debounceTime: tipear rápido busca una sola vez, con el último texto", marbles((m) => {
  const calls = [];
  const api = { get: (url, { params }) => { calls.push(params.name_like); return m.cold("r|", { r: { data: [] } }); } };
  // Tres teclas separadas por 2 ms: ninguna deja pasar los 300 ms de silencio, salvo la última.
  const action$ = m.hot("-a-b-c", { a: playerSearchRequested("A"), b: playerSearchRequested("An"), c: playerSearchRequested("Ana") });
  m.expect(searchPlayerEpic(action$, null, { api })).toBeObservable("----- 300ms s", {
    s: playerSearchSucceeded({ query: "Ana", results: [] }),
  });
  m.flush();
  expect(calls).toEqual(["Ana"]); // una sola petición
}));

// --- 2. switchMap ---
test("switchMap: la búsqueda nueva cancela la vieja aunque la vieja responda después", marbles((m) => {
  const ANA = [{ id: 44, name: "Ana", status: "banned" }, { id: 45, name: "Anaís", status: "active" }];
  const ANAIS = [{ id: 45, name: "Anaís", status: "active" }];
  // «Ana» tarda 500 ms; «Anaís», 100 ms.
  const api = {
    get: (url, { params }) =>
      params.name_like === "Ana" ? m.cold("500ms r|", { r: { data: ANA } }) : m.cold("100ms r|", { r: { data: ANAIS } }),
  };
  const action$ = m.hot("-a 400ms b", { a: playerSearchRequested("Ana"), b: playerSearchRequested("Anaís") });
  // Solo llega «Anaís». La respuesta de «Ana» no aparece: la ausencia ES la aserción.
  m.expect(searchPlayerEpic(action$, null, { api })).toBeObservable("802ms s", {
    s: playerSearchSucceeded({ query: "Anaís", results: ANAIS }),
  });
}));

// --- 3. mergeMap ---
test("mergeMap: dos ventanas de deshacer corren en paralelo y vencen cada una a su hora", marbles((m) => {
  // Juan se encola en el frame 1; María, tres segundos después.
  const action$ = m.hot("-j 3000ms q", { j: juanQueued, q: mariaQueued });
  // Cada una vence UNDO_WINDOW_MS (10 s) después de SU encolado. Con switchMap, la de Juan no saldría.
  m.expect(undoWindowEpic(action$)).toBeObservable("- 10000ms a 3000ms b", {
    a: sendGrantRequested(juan.id),
    b: sendGrantRequested(maria.id),
  });
}));

// --- 4. concatMap (patrón de consulta: este epic NO está en el código del curso) ---
const stockAdjustmentRequested = (segmentId, delta) => ({ type: "stock/adjustmentRequested", payload: { segmentId, delta } });
const stockAdjusted = (segmentId, remaining) => ({ type: "stock/adjusted", payload: { segmentId, remaining } });
const stockAdjustmentFailed = (segmentId, error) => ({ type: "stock/adjustmentFailed", payload: { segmentId, error } });

// Cada ajuste de existencias de un segmento limitado parte del `remaining` que dejó el
// anterior: el segundo no puede salir hasta que el primero volvió.
const stockAdjustmentEpic = (action$, state$, { api }) =>
  action$.pipe(
    ofType("stock/adjustmentRequested"),
    concatMap((action) => {
      const { segmentId, delta } = action.payload;
      return from(api.patch(`/stock/${segmentId}`, { delta })).pipe(
        map((response) => stockAdjusted(segmentId, response.data.remaining)),
        catchError((error) => of(stockAdjustmentFailed(segmentId, toReadableError(error))))
      );
    })
  );

test("concatMap: el segundo ajuste espera a que vuelva el primero", marbles((m) => {
  let remaining = 10;
  // Cada PATCH tarda 3 frames y responde con el remaining que quedó.
  const api = { patch: (url, { delta }) => { remaining += delta; return m.cold("---r|", { r: { data: { remaining } } }); } };
  const action$ = m.hot("-a-b", {
    a: stockAdjustmentRequested("esclusa-de-oro", -1),
    b: stockAdjustmentRequested("esclusa-de-oro", -2),
  });
  // a sale en el frame 1 y vuelve en el 4; b, encolada, sale en el 5 (al completar a) y vuelve en el 8.
  m.expect(stockAdjustmentEpic(action$, null, { api })).toBeObservable("----x---y", {
    x: stockAdjusted("esclusa-de-oro", 9),
    y: stockAdjusted("esclusa-de-oro", 7),
  });
}));

// --- 5. exhaustMap ---
test("exhaustMap: el doble clic da un solo envío", marbles((m) => {
  let calls = 0;
  const api = { post: () => { calls += 1; return m.cold("----r|", { r: { data: {} } }); } };
  // El segundo clic llega en el frame 3, con el primer POST todavía en vuelo.
  const action$ = m.hot("-a-b", { a: sendGrantRequested(juan.id), b: sendGrantRequested(juan.id) });
  m.expect(sendGrantEpic(action$, stateWith(juan), { api })).toBeObservable("-(st)c", {
    s: grantSending(juan.id),
    t: grantSent({ grantId: juan.id }),
    c: grantConfirmed(juan.id),
  });
  m.flush();
  expect(calls).toBe(1);
}));

// --- 6. takeUntil ---
test("takeUntil: «Deshacer» dentro de la ventana corta el timer y no sale nada", marbles((m) => {
  const action$ = m.hot("-q 5000ms u", { q: juanQueued, u: undoGrant(juan.id) });
  m.expect(undoWindowEpic(action$)).toBeObservable("");
}));

test("takeUntil: después del logout el polling no pregunta más", marbles((m) => {
  let calls = 0;
  const store = { get: () => { calls += 1; return m.cold("r|", { r: { data: { state: "pending" } } }); } };
  const action$ = m.hot(`a ${POLLING_INTERVAL_MS + 500}ms L`, { a: startPolling("tok-oxxo-2"), L: logout() });
  // Dos ticks (0 y 2 s) antes del logout, y nada en los diez segundos siguientes.
  m.expect(pollingEpic(action$, null, { store }), `^ ${POLLING_INTERVAL_MS + 10500}ms !`).toBeObservable(
    `p ${POLLING_INTERVAL_MS - 1}ms q`,
    {
      p: expect.objectContaining({ type: "purchases/purchaseStatusReceived" }),
      q: expect.objectContaining({ type: "purchases/purchaseStatusReceived" }),
    }
  );
  m.flush();
  expect(calls).toBe(2);
}));

// --- 7. retryWhen ---
test("retryWhen: un 503 se reintenta con backoff (500 ms, 1 s) y confirma al tercer intento", marbles((m) => {
  let call = 0;
  const api = { post: () => { call += 1; return call < 3 ? m.cold("-#", {}, httpError(503)) : m.cold("-r|", { r: {} }); } };
  const action$ = m.hot("-a", { a: sendAllRequested() });
  // 1 + 500 + 1 + 1000 + 1 frames después del pedido llega la confirmación.
  m.expect(retryGrantEpic(action$, stateWith(juan), { api })).toBeObservable("-(st) 1499ms c", {
    s: grantSending(juan.id),
    t: grantSent({ grantId: juan.id }),
    c: grantConfirmed(juan.id),
  });
}));

test("retryWhen: un 409 no se reintenta, cae directo en el rollback", marbles((m) => {
  let calls = 0;
  const conflict = httpError(409, { error: "Ese caso ya fue compensado para este jugador." });
  const api = { post: () => { calls += 1; return m.cold("----#", {}, conflict); } };
  const action$ = m.hot("-a", { a: sendAllRequested() });
  m.expect(retryGrantEpic(action$, stateWith(juan), { api })).toBeObservable("-(st)f", {
    s: grantSending(juan.id),
    t: grantSent({ grantId: juan.id }),
    f: rollbackGrant({
      grantId: juan.id, caseId: "C-2210", playerId: 42,
      error: { message: "Ese caso ya fue compensado para este jugador.", type: "conflict" },
    }),
  });
  m.flush();
  expect(calls).toBe(1); // reintentar un conflict da diez 409
}));

// --- 8. catchError ---
test("catchError adentro: un envío que falla no mata el epic; el siguiente sale", marbles((m) => {
  const api = {
    post: (url, body) => (body.grantId === juan.id ? m.cold("----#", {}, httpError(503)) : m.cold("----r|", { r: {} })),
  };
  const action$ = m.hot("-a 10ms b", { a: sendGrantRequested(juan.id), b: sendGrantRequested(maria.id) });
  m.expect(sendGrantEpic(action$, stateWith(juan, maria), { api })).toBeObservable("-(st)f 6ms (uv)c", {
    s: grantSending(juan.id),
    t: grantSent({ grantId: juan.id }),
    f: rollbackGrant({
      grantId: juan.id, caseId: "C-2210", playerId: 42,
      error: { message: "El servidor tuvo un problema. Intenta de nuevo.", type: "http" },
    }),
    u: grantSending(maria.id),
    v: grantSent({ grantId: maria.id }),
    c: grantConfirmed(maria.id),
  });
}));

test("catchError por tick: después de un 500, el polling pregunta igual", marbles((m) => {
  let call = 0;
  const store = {
    get: () => {
      call += 1;
      return call === 1 ? m.cold("#", {}, httpError(500)) : m.cold("r|", { r: { data: { state: "confirmed" } } });
    },
  };
  const action$ = m.hot("a", { a: startPolling("tok-efecty-1") });
  // El primer tick falla; el segundo, dos segundos después, trae la confirmación y el polling termina.
  m.expect(pollingEpic(action$, null, { store })).toBeObservable(`f ${POLLING_INTERVAL_MS - 1}ms c`, {
    f: pollingFailed({ token: "tok-efecty-1", error: { message: "El servidor tuvo un problema. Intenta de nuevo.", type: "http" } }),
    c: expect.objectContaining({ type: "purchases/purchaseStatusReceived", payload: expect.objectContaining({ state: "confirmed" }) }),
  });
}));
