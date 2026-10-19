// Prueba de regresión del incidente 04 (copia de zz-code; no va al curso).
import React from "react";
import { render, act } from "@testing-library/react";
import { MemoryRouter, Route } from "react-router-dom";
import WheelDetailPage from "../pages/WheelDetailPage";

test("al cambiar el id de la ruta, muestra la rueda nueva", () => {
  let history = null;
  const { container } = render(
    <MemoryRouter initialEntries={["/wheels/1"]}>
      <Route path="/wheels/:id" component={WheelDetailPage} />
      <Route render={(props) => { history = props.history; return null; }} />
    </MemoryRouter>
  );
  expect(container.querySelector("h1").textContent).toBe("Esclusa de Oro");
  act(() => history.push("/wheels/2"));
  expect(container.querySelector("h1").textContent).toBe("Semana del Canal");
});
