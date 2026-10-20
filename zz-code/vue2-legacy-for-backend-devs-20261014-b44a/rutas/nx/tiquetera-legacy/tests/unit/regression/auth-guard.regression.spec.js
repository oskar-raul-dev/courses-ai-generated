// El guard del router (F2) lee localStorage directamente:
//
//   router.beforeEach(function (to, from, next) {
//     var token = localStorage.getItem("token");   // ⚠️ toca window
//     ...
//   });
//
// Extraemos la función a un módulo testeable (como en F11, ej. 19) y la
// probamos. En jsdom, localStorage EXISTE. El test pasa feliz.

import { authGuard } from "@/router/authGuard";

describe("REGRESIÓN · authGuard (F2) — y la mentira de jsdom", function () {
  beforeEach(function () {
    // jsdom nos deja hacer esto. Node NO tendría window.localStorage siquiera.
    window.localStorage.clear();
  });

  it("sin token, redirige a /login", function () {
    var next = jest.fn();
    var to = { path: "/tickets", matched: [{ meta: { requiresAuth: true } }] };

    authGuard(to, {}, next); // ← lee localStorage.getItem("token") por dentro

    expect(next).toHaveBeenCalledWith("/login");
  });

  it("con token, deja pasar", function () {
    window.localStorage.setItem("token", "mock-jwt-token-123");
    var next = jest.fn();
    var to = { path: "/tickets", matched: [{ meta: { requiresAuth: true } }] };

    authGuard(to, {}, next);

    expect(next).toHaveBeenCalledWith(); // next() sin args = pasa
  });
});

describe("⚠️ el mismo guard, en un entorno SIN window (lo que hará Node)", function () {
  var realWindow;

  beforeEach(function () {
    // Amputamos localStorage para IMITAR el servidor Node dentro de jsdom.
    // Esto NO es cómo se testea SSR de verdad (eso es NX2+); es una
    // DEMOSTRACIÓN de que tus tests actuales viven en el entorno equivocado.
    realWindow = global.window.localStorage;
    Object.defineProperty(global.window, "localStorage", {
      get: function () { throw new ReferenceError("localStorage is not defined"); },
      configurable: true
    });
  });

  afterEach(function () {
    Object.defineProperty(global.window, "localStorage", {
      value: realWindow, configurable: true, writable: true
    });
  });

  it("REVIENTA — el guard que pasaba en verde ahora tira ReferenceError", function () {
    var next = jest.fn();
    var to = { path: "/tickets", matched: [{ meta: { requiresAuth: true } }] };

    // Esta es la línea que en producción SSR lanzaría "window is not defined".
    // El test de arriba NUNCA la ejecutó en estas condiciones.
    expect(function () { authGuard(to, {}, next); }).toThrow(/localStorage is not defined/);
    expect(next).not.toHaveBeenCalled();
  });
});
