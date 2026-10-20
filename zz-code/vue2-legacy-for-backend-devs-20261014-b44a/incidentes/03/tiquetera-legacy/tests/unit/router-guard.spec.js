// tests/unit/router-guard.spec.js
import { authGuard } from "@/router";
import store from "@/store";

describe("guard de autenticación", function () {
  it("limpia el store cuando expulsa por falta de token", function () {
    localStorage.setItem("token", "mock-jwt-token-123");
    store.commit("auth/SET_SESSION", {
      token: "mock-jwt-token-123",
      user: { username: "admin", name: "Andrés Felipe Ríos" }
    });

    localStorage.removeItem("token");
    var next = jest.fn();
    authGuard({ path: "/tickets", matched: [{ meta: { requiresAuth: true } }] }, {}, next);

    expect(store.state.auth.token).toBe("");
    expect(next).toHaveBeenCalledWith(expect.objectContaining({ path: "/login" }));
  });
});
