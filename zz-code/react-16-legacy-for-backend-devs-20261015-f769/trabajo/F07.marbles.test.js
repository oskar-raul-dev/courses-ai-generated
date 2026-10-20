// Pruebas de F07 (copia de zz-code; no va al curso): el cierre con el reloj fijado y el polling, en canicas.
import { marbles } from "rxjs-marbles/jest";
import { isWheelClosed, msUntilClosing, spinWheelId } from "../features/wheels/closing";
import { sendGrantEpic } from "../features/grants/epics/sendGrantEpic";
import { pollingEpic, POLLING_INTERVAL_MS } from "../features/purchases/epics/pollingEpic";
import { grantQueued, sendGrantRequested, grantSending, grantSent, grantConfirmed, rollbackGrant } from "../features/grants/grantSlice";
import { startPolling, stopPolling, purchaseStatusReceived, pollingFailed } from "../features/purchases/purchaseSlice";
import { logout } from "../features/auth/authSlice";

const WHEEL = { id: 4, name: "Rueda de fin de mes", status: "live", closesAt: "2026-08-30T20:00:00-05:00" };
const CLOSE = Date.parse(WHEEL.closesAt);

describe("closing", () => {
  test("cerrada en el instante exacto del cierre, abierta un milisegundo antes", () => {
    expect(isWheelClosed(WHEEL, CLOSE - 1)).toBe(false);
    expect(isWheelClosed(WHEEL, CLOSE)).toBe(true);
    expect(msUntilClosing(WHEEL, CLOSE - 1500)).toBe(1500);
  });
  test("el instante no depende de la zona: 20:00 en Panamá son las 01:00 UTC del 31", () => {
    expect(new Date(CLOSE).toISOString()).toBe("2026-08-31T01:00:00.000Z");
  });
  test("ended o reconciled, o un closesAt ilegible: cerrada", () => {
    expect(isWheelClosed({ ...WHEEL, status: "ended" }, CLOSE - 1e9)).toBe(true);
    expect(isWheelClosed({ ...WHEEL, closesAt: "no-es-fecha" }, 0)).toBe(true);
    expect(spinWheelId("spin:4")).toBe(4);
    expect(spinWheelId("vidas-5")).toBe(null);
  });
});

describe("el envío de un giro con el reloj fijado", () => {
  const spin = grantQueued({ player: { id: 42, name: "Juan P." }, caseId: "C-7", prize: "spin:4", reason: "caída" }).payload;
  const state$ = { value: { grants: { byId: { [spin.id]: spin } }, wheels: { items: [WHEEL] } } };
  test("un milisegundo antes del cierre, sale", marbles((m) => {
    const api = { post: () => m.cold("----r|", { r: {} }) };
    const out = sendGrantEpic(m.hot("-a", { a: sendGrantRequested(spin.id) }), state$, { api, now: () => CLOSE - 1 });
    m.expect(out).toBeObservable("-(st)c", { s: grantSending(spin.id), t: grantSent({ grantId: spin.id }), c: grantConfirmed(spin.id) });
  }));
  test("en el instante del cierre, se rechaza sin petición", marbles((m) => {
    const api = { post: () => { throw new Error("no debía llamarse"); } };
    const out = sendGrantEpic(m.hot("-a", { a: sendGrantRequested(spin.id) }), state$, { api, now: () => CLOSE });
    m.expect(out).toBeObservable("-(sr)", {
      s: grantSending(spin.id),
      r: rollbackGrant({ grantId: spin.id, caseId: "C-7", playerId: 42, error: { message: "La rueda ya cerró: no se envían giros de ella.", type: "closed" } }),
    });
  }));
});

describe("pollingEpic", () => {
  const T = POLLING_INTERVAL_MS;
  const pending = { data: { state: "pending" } };
  const confirmed = { data: { state: "confirmed" } };
  const checked = (state) => expect.objectContaining({ type: purchaseStatusReceived.type, payload: expect.objectContaining({ token: "tok-1", state }) });

  test("pregunta cada 2 s y termina en la confirmación", marbles((m) => {
    let call = 0;
    const store = { get: () => { call += 1; return m.cold("r|", { r: call < 3 ? pending : confirmed }); } };
    const out = pollingEpic(m.hot("a", { a: startPolling("tok-1") }), null, { store });
    m.expect(out).toBeObservable(`p ${T - 1}ms q ${T - 1}ms c`, { p: checked("pending"), q: checked("pending"), c: checked("confirmed") });
  }));
  test("un 500 en un tick no mata el polling: el siguiente tick pregunta igual", marbles((m) => {
    const err = Object.assign(new Error("500"), { response: { status: 500, data: {} } });
    let call = 0;
    const store = { get: () => { call += 1; return call === 1 ? m.cold("#", {}, err) : m.cold("r|", { r: confirmed }); } };
    const out = pollingEpic(m.hot("a", { a: startPolling("tok-1") }), null, { store });
    m.expect(out).toBeObservable(`f ${T - 1}ms c`, {
      f: pollingFailed({ token: "tok-1", error: { message: "El servidor tuvo un problema. Intenta de nuevo.", type: "http" } }),
      c: checked("confirmed"),
    });
  }));
  test("el logout corta el polling: después no sale ninguna consulta", marbles((m) => {
    let calls = 0;
    const store = { get: () => { calls += 1; return m.cold("r|", { r: pending }); } };
    const out = pollingEpic(m.hot(`a ${T + 500}ms L`, { a: startPolling("tok-1"), L: logout() }), null, { store });
    m.expect(out).toBeObservable(`p ${T - 1}ms q`, { p: checked("pending"), q: checked("pending") });
    m.flush();
    expect(calls).toBe(2);
  }));
  test("stopPolling también lo corta", marbles((m) => {
    const store = { get: () => m.cold("r|", { r: pending }) };
    const out = pollingEpic(m.hot(`a ${T + 500}ms s`, { a: startPolling("tok-1"), s: stopPolling() }), null, { store });
    m.expect(out).toBeObservable(`p ${T - 1}ms q`, { p: checked("pending"), q: checked("pending") });
  }));
  test("switchMap: consultar otra compra cancela el polling de la primera", marbles((m) => {
    const tokens = [];
    const store = { get: (url) => { tokens.push(url); return m.cold("r|", { r: pending }); } };
    // el stop final corta el polling de tok-2: en TestScheduler.run, un timer sin fin no deja terminar la prueba
    const out = pollingEpic(m.hot(`a ${T + 500}ms b ${T}ms s`, { a: startPolling("tok-1"), b: startPolling("tok-2"), s: stopPolling() }), null, { store });
    m.expect(out).toBeObservable(`p ${T - 1}ms q ${500}ms x ${T - 1}ms y`, {
      p: checked("pending"), q: checked("pending"),
      x: expect.objectContaining({ payload: expect.objectContaining({ token: "tok-2" }) }),
      y: expect.objectContaining({ payload: expect.objectContaining({ token: "tok-2" }) }),
    });
    m.flush();
  }));
});
