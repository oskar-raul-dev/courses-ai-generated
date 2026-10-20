// Prueba de regresión del incidente 09 (copia de zz-code; no va al curso).
import React from "react";
import { render } from "@testing-library/react";
import { Provider } from "react-redux";
import { MemoryRouter, Route } from "react-router-dom";
import { store } from "../app/store";
import WheelEditPage from "../pages/WheelEditPage";
import { fetchWheels } from "../features/wheels/wheelSlice";

test("enviar el formulario de pesos no recarga la página", async () => {
  await store.dispatch(fetchWheels());
  const { container } = render(
    <Provider store={store}>
      <MemoryRouter initialEntries={["/wheels/2/edit"]}>
        <Route path="/wheels/:id/edit" component={WheelEditPage} />
      </MemoryRouter>
    </Provider>
  );
  const form = container.querySelector("form");
  const evento = new Event("submit", { bubbles: true, cancelable: true });
  form.dispatchEvent(evento);
  expect(evento.defaultPrevented).toBe(true);
});
