// Prueba de regresión del incidente 06 (copia de zz-code; no va al curso).
import React from "react";
import { Provider } from "react-redux";
import { MemoryRouter } from "react-router-dom";
import { render, act } from "@testing-library/react";
import { store } from "../app/store";
import Navbar from "../components/Navbar";
import { login, logout } from "../features/auth/authSlice";

test("al cerrar sesión, la barra deja de mostrar el usuario", () => {
  store.dispatch({
    type: login.fulfilled.type,
    payload: { id: 1, email: "ibatista@esclusa.test", name: "Itzel Batista", token: "tok_ibatista_3c7e" },
  });
  const { container } = render(
    <Provider store={store}>
      <MemoryRouter>
        <Navbar />
      </MemoryRouter>
    </Provider>
  );
  expect(container.textContent).toContain("Itzel Batista");
  act(() => {
    store.dispatch(logout());
  });
  expect(container.textContent).not.toContain("Itzel Batista");
});
