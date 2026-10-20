// Render de F04 (copia de zz-code): la edición de pesos respeta el estado de la rueda.
import React from "react";
import { render, act } from "@testing-library/react";
import { Provider } from "react-redux";
import { MemoryRouter, Route } from "react-router-dom";
import { store } from "./app/store";
import WheelEditPage from "./pages/WheelEditPage";
import { fetchWheels } from "./features/wheels/wheelSlice";

test("rueda en vivo: los campos de peso quedan deshabilitados; programada: editables", async () => {
  await store.dispatch(fetchWheels());
  const pantalla = (id) => render(
    <Provider store={store}>
      <MemoryRouter initialEntries={[`/wheels/${id}/edit`]}>
        <Route path="/wheels/:id/edit" component={WheelEditPage} />
      </MemoryRouter>
    </Provider>
  );
  const enVivo = pantalla(1);
  const inputsVivo = enVivo.container.querySelectorAll("input");
  expect(inputsVivo.length).toBe(8);
  expect(Array.from(inputsVivo).every((i) => i.disabled)).toBe(true);
  expect(enVivo.container.textContent).toContain("no se editan");
  enVivo.unmount();
  const programada = pantalla(2);
  const inputsProg = programada.container.querySelectorAll("input");
  expect(Array.from(inputsProg).every((i) => !i.disabled)).toBe(true);
  expect(programada.container.textContent).toContain("Suma: 10000 de 10000");
  programada.unmount();
});
